"""
Config loader — priority (highest → lowest):
  1. Environment variables  TUB_USER / TUB_PASS / TUB_PORT / TUB_HOST
  2. ~/.tub/config.toml
  3. ~/.tub/.env
  4. Built-in defaults
"""
import os
import sys

HOME        = os.path.expanduser("~")
CONFIG_TOML = os.path.join(HOME, ".tub", "config.toml")
CONFIG_ENV  = os.path.join(HOME, ".tub", ".env")

_DEFAULTS = {"user": "bhupender", "password": "secret", "port": "8787", "host": "127.0.0.1"}


def _read_toml(path: str) -> dict:
    try:
        if sys.version_info >= (3, 11):
            import tomllib
            with open(path, "rb") as f:
                data = tomllib.load(f)
        else:
            import tomli  # installed via pyproject.toml on Python < 3.11
            with open(path, "rb") as f:
                data = tomli.load(f)
        return {k: str(v) for k, v in data.get("tub", {}).items()}
    except FileNotFoundError:
        return {}
    except ImportError:
        print("[tub] Warning: tomli not found — config.toml ignored. Run: pip install tomli", file=sys.stderr)
        return {}
    except Exception as exc:
        print(f"[tub] Warning: could not parse {path}: {exc}", file=sys.stderr)
        return {}


def _read_env_file(path: str) -> dict:
    result = {}
    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, _, val = line.partition("=")
                # Accept both TUB_USER=x and user=x styles
                key = key.strip().removeprefix("TUB_").lower()
                result[key] = val.strip().strip('"').strip("'")
    except FileNotFoundError:
        pass
    return result


def load() -> dict:
    cfg = dict(_DEFAULTS)

    # Layer 3 — .env file
    cfg.update(_read_env_file(CONFIG_ENV))

    # Layer 2 — config.toml  (accept both 'pass' and 'password' as key)
    toml = _read_toml(CONFIG_TOML)
    if "pass" in toml:          # 'pass' is a Python keyword; accept it anyway
        toml["password"] = toml.pop("pass")
    cfg.update(toml)

    # Layer 1 — environment variables (always win)
    for env_var, cfg_key in (
        ("TUB_USER", "user"),
        ("TUB_PASS", "password"),
        ("TUB_PORT", "port"),
        ("TUB_HOST", "host"),
    ):
        if os.environ.get(env_var):
            cfg[cfg_key] = os.environ[env_var]

    return cfg
