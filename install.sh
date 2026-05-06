#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  TUB — Tutorial Hub  |  macOS / Linux installer
#  Run from the project folder:  bash install.sh
#  No sudo required — everything installs under ~/.tub/
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.tub"
BIN_DIR="$HOME/.local/bin"
VENV="$INSTALL_DIR/venv"
APP_DIR="$INSTALL_DIR/app"
TUB_BIN="$BIN_DIR/tub"

# ── Colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
info()  { echo -e "${GREEN}✔${NC}  $*"; }
warn()  { echo -e "${YELLOW}⚠${NC}  $*"; }
error() { echo -e "${RED}✖${NC}  $*" >&2; exit 1; }
step()  { echo -e "\n${BOLD}──  $*${NC}"; }

echo -e "\n${BOLD}  TUB  ·  Tutorial Hub Installer${NC}\n"

# Guard: refuse to run as root — everything must be user-owned
if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    error "Do not run this installer with sudo. Run it as your normal user:  bash install.sh"
fi

# ── 1. Find Python 3.8+ ───────────────────────────────────────────────────────
step "Checking Python"
PYTHON=""
for cmd in python3 python; do
    if command -v "$cmd" &>/dev/null; then
        ok=$("$cmd" -c "import sys; print(sys.version_info >= (3,8))" 2>/dev/null || true)
        if [[ "$ok" == "True" ]]; then
            PYTHON="$cmd"
            break
        fi
    fi
done
[[ -z "$PYTHON" ]] && error "Python 3.8+ is required.  Install it from https://python.org"
info "Found $($PYTHON --version)"

# ── 2. Stop any running instance ──────────────────────────────────────────────
step "Pre-install check"
PID_FILE="$INSTALL_DIR/tub.pid"
if [[ -f "$PID_FILE" ]]; then
    OLD_PID=$(cat "$PID_FILE" 2>/dev/null || true)
    if [[ -n "$OLD_PID" ]] && kill -0 "$OLD_PID" 2>/dev/null; then
        warn "Stopping running TUB instance (PID $OLD_PID) ..."
        kill "$OLD_PID" 2>/dev/null || true
        sleep 1
    fi
    rm -f "$PID_FILE"
fi
info "Clean to install"

# ── 3. Copy app files ─────────────────────────────────────────────────────────
step "Copying files  →  $APP_DIR"
mkdir -p "$APP_DIR"

if command -v rsync &>/dev/null; then
    rsync -a --delete \
        --exclude='.git' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='.venv' \
        --exclude='venv' \
        "$SRC_DIR/" "$APP_DIR/"
else
    rm -rf "$APP_DIR"
    cp -r "$SRC_DIR" "$APP_DIR"
    rm -rf "$APP_DIR/.git" "$APP_DIR/__pycache__" "$APP_DIR/.venv" "$APP_DIR/venv"
fi
info "Files copied"

# ── 4. Virtual environment + dependencies ────────────────────────────────────
step "Setting up Python environment"
if [[ ! -d "$VENV" ]]; then
    "$PYTHON" -m venv "$VENV"
    info "Virtual environment created"
else
    info "Reusing existing virtual environment"
fi

"$VENV/bin/pip" install --quiet --upgrade pip

# Editable install (-e): keeps __file__ pointing at APP_DIR/tub/app.py so that
# ROOT resolves to APP_DIR/ where templates/ and static/ live. A regular install
# would copy the package into site-packages/ and lose the path to those folders.
"$VENV/bin/pip" install --quiet -e "$APP_DIR"
info "Package installed  →  $VENV/bin/tub"

# ── 5. Link into ~/.local/bin ────────────────────────────────────────────────
step "Linking  tub  →  $TUB_BIN"
mkdir -p "$BIN_DIR"
rm -f "$TUB_BIN"
ln -s "$VENV/bin/tub" "$TUB_BIN"
info "Symlink created:  $TUB_BIN  →  $VENV/bin/tub"

# ── 6. PATH ───────────────────────────────────────────────────────────────────
step "Checking PATH"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
ADDED_TO=()

add_to_rc() {
    local rc="$1"
    grep -qF '.local/bin' "$rc" 2>/dev/null && return
    printf '\n# Added by TUB installer\n%s\n' "$PATH_LINE" >> "$rc"
    ADDED_TO+=("$rc")
}

# Write to both login-shell and interactive-shell configs.
# On macOS, Terminal.app opens login shells → reads .zprofile, not .zshrc.
SHELL_NAME="$(basename "${SHELL:-zsh}")"
case "$SHELL_NAME" in
    zsh)
        add_to_rc "$HOME/.zprofile"   # login shells  (macOS Terminal.app)
        add_to_rc "$HOME/.zshrc"      # interactive shells (VS Code terminal, etc.)
        ;;
    bash)
        add_to_rc "$HOME/.bash_profile"
        add_to_rc "$HOME/.bashrc"
        ;;
    *)
        add_to_rc "$HOME/.profile"
        ;;
esac

if [[ ${#ADDED_TO[@]} -gt 0 ]]; then
    warn "Added ~/.local/bin to PATH in: ${ADDED_TO[*]}"
else
    info "~/.local/bin already in shell config"
fi

# Always activate in the current session so tub works immediately here
# without needing to open a new terminal.
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
info "~/.local/bin active in this session"

# ── 7. Config file (first install only — never overwrite) ────────────────────
step "Config file"
CONFIG_FILE="$INSTALL_DIR/config.toml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<'EOF'
# TUB — Tutorial Hub configuration
# Changes take effect on next:  tub restart
#
# Priority order (highest wins):
#   Environment variables  >  this file  >  .env file  >  built-in defaults

[tub]
user     = "bhupender"
password = "secret"
port     = 8787

# host controls who can reach TUB:
#   127.0.0.1  — localhost only, secure (default)
#   0.0.0.0    — all network interfaces; makes TUB reachable from other
#                machines on your network (use only on trusted networks)
host = "127.0.0.1"
EOF
    info "Config written  →  $CONFIG_FILE"
else
    info "Existing config kept  →  $CONFIG_FILE"
fi

# ── 8. Smoke test ─────────────────────────────────────────────────────────────
step "Verifying install"
if "$TUB_BIN" status; then
    info "tub command works"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${GREEN}  TUB installed successfully!${NC}\n"
echo    "  tub start      →  start server + open browser"
echo    "  tub stop       →  stop server"
echo    "  tub restart    →  restart server"
echo    "  tub status     →  show PID and URL"
echo    "  tub config     →  show config file and settings"
echo    "  tub --help     →  full command reference"
echo -e "\n  Credentials:   bhupender / secret"
echo    "  Config:        $CONFIG_FILE"
echo    "  Logs:          $INSTALL_DIR/tub.log"
echo    "  Installed to:  $APP_DIR"
echo ""

read -r -p "  Start TUB now? [Y/n] " REPLY
REPLY="${REPLY:-Y}"
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    "$TUB_BIN" start
fi
