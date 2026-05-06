import os
from functools import wraps
from flask import Flask, request, Response, abort, send_from_directory, render_template
from tub.config import load as _load_config

# Resolve paths relative to the installed app root (one level above this file)
_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(_HERE)

_cfg     = _load_config()
USERNAME = _cfg["user"]
PASSWORD = _cfg["password"]
PORT     = int(_cfg["port"])
HOST     = _cfg["host"]

app = Flask(
    __name__,
    static_folder=os.path.join(ROOT, "static"),
    template_folder=os.path.join(ROOT, "templates"),
)
app.config["TEMPLATES_AUTO_RELOAD"] = True


def check_auth(user, pwd):
    return user == USERNAME and pwd == PASSWORD


def authenticate():
    return Response(
        "Authentication required",
        401,
        {"WWW-Authenticate": 'Basic realm="TUB"'},
    )


def requires_auth(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return wrapper


@app.before_request
def limit_remote_access():
    # When bound to localhost only, enforce it at the app layer too (belt-and-suspenders).
    # When host is 0.0.0.0 the user has explicitly opted into network access — allow it.
    if HOST == "127.0.0.1" and request.remote_addr not in ("127.0.0.1", "::1"):
        abort(403)


@app.route("/")
@requires_auth
def index():
    return render_template("python_hub.html")


@app.route("/default.css")
@requires_auth
def default_css():
    return send_from_directory(os.path.join(ROOT, "static", "default_css"), "default.css")


@app.route("/default.js")
@requires_auth
def default_js():
    return send_from_directory(os.path.join(ROOT, "static", "default_js"), "default.js")


@app.route("/favicon.ico")
def favicon():
    return "", 204


@app.route("/<path:filename>")
@requires_auth
def serve_page(filename):
    return render_template(filename)


if __name__ == "__main__":
    app.run(host=HOST, port=PORT, debug=False)
