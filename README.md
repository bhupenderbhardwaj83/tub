# TUB — Tutorial Hub

A self-hosted, offline-first learning portal that serves interactive tutorials directly from your terminal. One command starts a local web server; your browser opens to a clean hub covering Python, DevOps, data tools, and web development — no internet required after install.

---

## What's inside

| Category | Tutorials |
|---|---|
| **Python** | Basics · OOP · Decorators · Iterators · Functional Programming · File I/O · Modules & Packages |
| **Python — Data** | Advanced Python · Pandas (Advanced) · Plotly · PostgreSQL |
| **Computer Vision** | OpenCV (with visual demos) |
| **DevOps** | Docker · Docker Compose · Traefik Proxy · Linux Essentials |
| **Web & Mobile** | Next.js · React Native · Tailwind CSS · Tailwind Templates |
| **AI / Protocols** | MCP (Model Context Protocol) + RAG systems |

---

## Requirements

- Python 3.8 or newer — [python.org](https://www.python.org/downloads/)
- macOS / Linux / Windows
- Nothing else — the installer handles everything (venv, Flask, CLI binary)

---

## Install

Clone or download the repository, then run the installer from the project folder.

### macOS / Linux

```bash
bash install.sh
# or, if you've made it executable:
./install.sh
```

> Do **not** run with `sudo` — everything installs under your home directory (`~/.tub/`) and no elevated permissions are needed.

The installer will:
1. Detect your Python 3.8+
2. Copy the app to `~/.tub/app/`
3. Create an isolated virtual environment at `~/.tub/venv/` and install Flask
4. Generate a `tub` executable and symlink it into `~/.local/bin/`
5. Add `~/.local/bin` to your shell PATH (`.zprofile` / `.zshrc` for zsh, `.bash_profile` / `.bashrc` for bash)
6. Write a default `~/.tub/config.toml` on first install
7. Ask if you want to start TUB immediately

`tub` will be available in the **same terminal session** straight after install. New terminals pick it up automatically from the next login.

---

### Windows

Open PowerShell and run:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

---

## Usage

```
tub start        Start the server in the background and open in browser
tub stop         Stop the server
tub restart      Restart the server (apply config changes)
tub status       Show running status, PID, host, and URL
tub open         Open browser (server must already be running)
tub config       Show config file location and current settings
tub uninstall    Remove TUB from your system
tub --help       Full command reference
```

TUB runs at **http://127.0.0.1:8787** and is restricted to localhost by default — it never accepts connections from other machines on your network unless you explicitly change the `host` setting.

### Keyboard shortcuts (inside the browser)

| Shortcut | Action |
|---|---|
| `Cmd+K` / `Ctrl+K` | Focus the search bar |
| `Esc` | Clear search |
| `Cmd+Shift+H` / `Ctrl+Shift+H` | Go back to Hub |

---

## Login

The portal is protected by basic authentication.

| Field | Default |
|---|---|
| Username | `bhupender` |
| Password | `secret` |

Change these in `~/.tub/config.toml` and run `tub restart`.

---

## Configuration

TUB reads settings from three places. Higher entries win:

```
1. Environment variables   (highest — good for one-off overrides)
2. ~/.tub/config.toml      (recommended for permanent changes)
3. ~/.tub/.env             (alternative flat format)
```

### config.toml (recommended)

The installer creates `~/.tub/config.toml` automatically on first install. Edit it, then run `tub restart`:

```toml
# TUB — Tutorial Hub configuration
# Changes take effect on next:  tub restart

[tub]
user     = "bhupender"
password = "secret"
port     = 8787

# host controls who can reach TUB:
#   127.0.0.1  — localhost only, secure (default)
#   0.0.0.0    — all interfaces, reachable from your network
host = "127.0.0.1"
```

Run `tub config` at any time to see the current config file path and all effective values.

### .env file (alternative)

Create `~/.tub/.env` if you prefer a flat key=value format:

```env
TUB_USER=alice
TUB_PASS=mypassword
TUB_PORT=9000
TUB_HOST=127.0.0.1
```

### Environment variables (one-off overrides)

```bash
TUB_PORT=9000 tub start
```

| Variable | `config.toml` key | Default | Description |
|---|---|---|---|
| `TUB_USER` | `user` | `bhupender` | Login username |
| `TUB_PASS` | `password` | `secret` | Login password |
| `TUB_PORT` | `port` | `8787` | Port the server listens on |
| `TUB_HOST` | `host` | `127.0.0.1` | Bind address (`0.0.0.0` for network access) |

---

## Logs & files

| Path | Contents |
|---|---|
| `~/.tub/config.toml` | Your configuration (edit to change credentials, port, host) |
| `~/.tub/tub.log` | Server stdout / stderr |
| `~/.tub/tub.pid` | PID of the running server (managed automatically) |
| `~/.tub/app/` | Installed app files |
| `~/.tub/venv/` | Isolated Python environment |

---

## Reinstall / update

Pull the latest code and run the installer again — it stops any running instance, syncs the files, and re-links the binary. Your `config.toml` is never overwritten.

```bash
bash install.sh
# or
./install.sh
```

---

## Uninstall

```bash
tub uninstall
```

This will:
- Stop the running server
- Offer to keep your `config.toml` for a future reinstall
- Remove `~/.tub/` (app, venv, logs)
- Remove the `tub` command from `~/.local/bin/`

---

## Project structure

```
tub/
├── tub/
│   ├── app.py          Flask application
│   ├── cli.py          tub CLI (start/stop/restart/status/open/config/uninstall)
│   └── config.py       Config loader (env vars > config.toml > .env > defaults)
├── templates/          HTML tutorial pages (22 topics)
├── static/
│   ├── default_css/    Stylesheet
│   ├── default_js/     JavaScript + keyboard shortcuts
│   ├── default_img/    Icons and app images
│   ├── mcp_img/        MCP architecture diagrams
│   └── demos/          OpenCV visual demo screenshots
├── pyproject.toml      Package metadata and CLI entry point
├── install.sh          macOS / Linux installer
└── install.ps1         Windows PowerShell installer
```

---

## License

MIT — do whatever you like with it.
