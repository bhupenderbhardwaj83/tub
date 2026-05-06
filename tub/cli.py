#!/usr/bin/env python3
"""TUB CLI — start / stop / restart / status / open / config / help"""
import os
import sys
import time
import subprocess
import webbrowser
import urllib.request

from tub.config import load as _load_config, CONFIG_TOML, CONFIG_ENV

_HERE    = os.path.dirname(os.path.abspath(__file__))
HOME     = os.path.expanduser("~")
TUB_DIR  = os.path.join(HOME, ".tub")
PID_FILE = os.path.join(TUB_DIR, "tub.pid")
LOG_FILE = os.path.join(TUB_DIR, "tub.log")

_cfg  = _load_config()
PORT  = int(_cfg["port"])
HOST  = _cfg["host"]
# Browser always opens on localhost regardless of bind address
URL   = f"http://127.0.0.1:{PORT}"

IS_WIN = sys.platform == "win32"


# ── Process helpers ───────────────────────────────────────────────────────────

def _read_pid():
    try:
        return int(open(PID_FILE).read().strip())
    except Exception:
        return None


def _alive(pid):
    if pid is None:
        return False
    try:
        if IS_WIN:
            import ctypes
            handle = ctypes.windll.kernel32.OpenProcess(0x0400, False, pid)
            if not handle:
                return False
            ctypes.windll.kernel32.CloseHandle(handle)
            return True
        else:
            os.kill(pid, 0)
            return True
    except (ProcessLookupError, PermissionError, OSError):
        return False


def _write_pid(pid):
    os.makedirs(TUB_DIR, exist_ok=True)
    with open(PID_FILE, "w") as f:
        f.write(str(pid))


def _clear_pid():
    try:
        os.remove(PID_FILE)
    except FileNotFoundError:
        pass


def _server_ready():
    try:
        urllib.request.urlopen(URL, timeout=1)
        return True
    except Exception:
        return False


# ── Commands ──────────────────────────────────────────────────────────────────

def cmd_start():
    pid = _read_pid()
    if _alive(pid):
        print(f"TUB is already running (PID {pid}).")
        print(f"  URL: {URL}")
        webbrowser.open(URL)
        return

    _clear_pid()
    app_script = os.path.join(_HERE, "app.py")
    os.makedirs(TUB_DIR, exist_ok=True)
    log = open(LOG_FILE, "a")

    if IS_WIN:
        DETACHED  = 0x00000008
        CREATE_NEW = 0x00000200
        proc = subprocess.Popen(
            [sys.executable, app_script],
            stdout=log, stderr=log,
            creationflags=DETACHED | CREATE_NEW,
            close_fds=True,
        )
    else:
        proc = subprocess.Popen(
            [sys.executable, app_script],
            stdout=log, stderr=log,
            start_new_session=True,
        )

    _write_pid(proc.pid)
    print(f"Starting TUB (PID {proc.pid}) ...", end="", flush=True)

    for _ in range(30):
        time.sleep(0.5)
        if not _alive(proc.pid):
            print(" FAILED.")
            print(f"  Check log: {LOG_FILE}")
            _clear_pid()
            return
        if _server_ready():
            break
        print(".", end="", flush=True)

    print(" ready.")
    print(f"  URL:  {URL}")
    print(f"  PID:  {proc.pid}")
    print(f"  Host: {HOST}  {'(localhost only)' if HOST == '127.0.0.1' else '(network accessible)'}")
    print(f"  Log:  {LOG_FILE}")
    webbrowser.open(URL)


def cmd_stop():
    pid = _read_pid()
    if not _alive(pid):
        print("TUB is not running.")
        _clear_pid()
        return

    if IS_WIN:
        subprocess.call(
            ["taskkill", "/PID", str(pid), "/F"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
    else:
        import signal
        try:
            os.kill(pid, signal.SIGTERM)
            for _ in range(20):
                time.sleep(0.3)
                if not _alive(pid):
                    break
            else:
                os.kill(pid, signal.SIGKILL)
        except ProcessLookupError:
            pass

    _clear_pid()
    print(f"TUB stopped (was PID {pid}).")


def cmd_restart():
    cmd_stop()
    time.sleep(0.5)
    cmd_start()


def cmd_status():
    pid = _read_pid()
    if _alive(pid):
        print("TUB is running")
        print(f"  PID:  {pid}")
        print(f"  URL:  {URL}")
        print(f"  Host: {HOST}  {'(localhost only)' if HOST == '127.0.0.1' else '(network accessible)'}")
        print(f"  Log:  {LOG_FILE}")
    else:
        print("TUB is not running.")
        _clear_pid()


def cmd_open():
    pid = _read_pid()
    if _alive(pid):
        print(f"Opening {URL}")
        webbrowser.open(URL)
    else:
        print("TUB is not running.  Use:  tub start")


def cmd_config():
    cfg = _load_config()

    toml_status = "exists" if os.path.exists(CONFIG_TOML) else "not found"
    env_status  = "exists" if os.path.exists(CONFIG_ENV)  else "not found"

    pwd     = cfg["password"]
    pwd_display = f"{'*' * len(pwd)}  ({len(pwd)} chars)"

    host        = cfg["host"]
    host_label  = "(localhost only — default, secure)" if host == "127.0.0.1" \
                  else "(network accessible — reachable from other machines)"

    print("TUB — Tutorial Hub  ·  Configuration")
    print()
    print("  Config files:")
    print(f"    {CONFIG_TOML}  [{toml_status}]")
    print(f"    {CONFIG_ENV}  [{env_status}]")
    print()
    print("  Effective settings:")
    print(f"    user       {cfg['user']}")
    print(f"    password   {pwd_display}")
    print(f"    port       {cfg['port']}")
    print(f"    host       {host}  {host_label}")
    print()
    print("  Priority (highest wins):")
    print("    env vars  >  config.toml  >  .env  >  built-in defaults")
    print()
    print(f"  To edit:   open {CONFIG_TOML}")
    print("  Apply:     tub restart")


def cmd_uninstall():
    import shutil

    print("TUB — Uninstaller\n")

    # Locate installed binaries (user and system locations)
    bin_candidates = [
        os.path.join(HOME, ".local", "bin", "tub"),
        "/usr/local/bin/tub",
        r"C:\ProgramData\tub\bin\tub.exe",
        os.path.join(HOME, ".local", "bin", "tub.exe"),
    ]
    # Also pick up wherever 'tub' resolves on PATH right now
    which = shutil.which("tub")
    if which and which not in bin_candidates:
        bin_candidates.insert(0, which)

    found_bins  = [b for b in bin_candidates if os.path.exists(b)]
    install_dir = os.path.join(HOME, ".tub")         # ~/.tub
    system_dir  = "/usr/local/share/tub"             # sudo install location
    found_dirs  = [d for d in (install_dir, system_dir) if os.path.isdir(d)]

    if not found_bins and not found_dirs:
        print("  Nothing to uninstall — TUB does not appear to be installed.")
        return

    print("  Will remove:")
    for b in found_bins:
        print(f"    {b}")
    for d in found_dirs:
        print(f"    {d}/  (app, venv, logs)")
    print()

    # Offer to keep config
    config_file  = os.path.join(install_dir, "config.toml")
    keep_config  = False
    if os.path.exists(config_file):
        ans = input("  Keep your config.toml for a future reinstall? [Y/n] ").strip() or "Y"
        keep_config = ans.lower().startswith("y")

    ans = input("  Proceed with uninstall? [y/N] ").strip() or "N"
    if not ans.lower().startswith("y"):
        print("  Cancelled.")
        return

    print()

    # Stop running server first
    pid = _read_pid()
    if _alive(pid):
        print(f"  Stopping TUB (PID {pid}) ...")
        cmd_stop()

    # Save config before wiping the directory
    config_saved = None
    if keep_config and os.path.exists(config_file):
        import tempfile
        config_saved = os.path.join(tempfile.gettempdir(), "tub_config_backup.toml")
        shutil.copy2(config_file, config_saved)

    # Remove binaries / symlinks
    for b in found_bins:
        try:
            os.remove(b)
            print(f"  Removed  {b}")
        except Exception as exc:
            print(f"  Warning: could not remove {b}: {exc}")

    # Remove install directories
    for d in found_dirs:
        try:
            shutil.rmtree(d)
            print(f"  Removed  {d}/")
        except Exception as exc:
            print(f"  Warning: could not remove {d}: {exc}")

    # Restore config if the user asked to keep it
    if config_saved and os.path.exists(config_saved):
        restored_dir = install_dir
        os.makedirs(restored_dir, exist_ok=True)
        shutil.move(config_saved, os.path.join(restored_dir, "config.toml"))
        print(f"  Config preserved  →  {restored_dir}/config.toml")

    print("\n  TUB uninstalled successfully.")
    if not IS_WIN:
        print("\n  If you want to clean up the PATH entry too, remove this line")
        print("  from your .zshrc / .bashrc:")
        print('    export PATH="$HOME/.local/bin:$PATH"')


def cmd_help():
    print("""\
TUB — Tutorial Hub

Usage:  tub <command>

Commands:
  start      Start the server in the background and open it in your browser.
             If already running, just opens the browser.

  stop       Stop the running server.

  restart    Stop and start the server. Run this after editing config.toml.

  status     Show whether the server is running, its PID, bound host, URL,
             and log file path.

  open       Open the browser to TUB. The server must already be running.

  config     Show the config file locations and all current effective settings,
             including which host the server is bound to.

  uninstall  Stop the server and remove TUB from your system (binary, venv,
             app files). Optionally keeps your config.toml for reinstall.

  help       Show this message.
  --help

Configuration files (edit to change credentials, port, or network access):
  ~/.tub/config.toml        TOML format  (recommended)
  ~/.tub/.env               Flat key=value format  (alternative)

Config keys:
  user       Login username          (env: TUB_USER)
  password   Login password          (env: TUB_PASS)
  port       Port to listen on       (env: TUB_PORT)  default: 8787
  host       Bind address            (env: TUB_HOST)
               127.0.0.1  — localhost only, secure  (default)
               0.0.0.0    — all interfaces, accessible from your network

Logs:  ~/.tub/tub.log
""")


# ── Dispatch ──────────────────────────────────────────────────────────────────

COMMANDS = {
    "start":     cmd_start,
    "stop":      cmd_stop,
    "restart":   cmd_restart,
    "status":    cmd_status,
    "open":      cmd_open,
    "config":    cmd_config,
    "uninstall": cmd_uninstall,
    "help":      cmd_help,
    "--help":    cmd_help,
    "-h":        cmd_help,
}


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else None
    if cmd not in COMMANDS:
        if cmd is not None:
            print(f"Unknown command: {cmd}\n")
        cmd_help()
        sys.exit(0 if cmd is None else 1)
    COMMANDS[cmd]()


if __name__ == "__main__":
    main()
