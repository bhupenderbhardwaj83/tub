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
```

The installer will:
1. Detect your Python
2. Copy the app to `~/.tub/`
3. Create an isolated virtual environment and install Flask
4. Generate a `tub` executable and link it into `~/.local/bin/`
5. Add `~/.local/bin` to your shell PATH (`.zshrc` / `.bashrc`)
6. Ask if you want to start TUB immediately

> **First-time install:** restart your terminal (or `source ~/.zshrc`) once after installing so the `tub` command is on your PATH.

**System-wide install** (makes `tub` available to all users on the machine):

```bash
sudo bash install.sh
```

This installs to `/usr/local/bin/tub` — no PATH changes needed, works in every shell immediately.

---

### Windows

Open PowerShell and run:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

**System-wide install** (run PowerShell as Administrator):

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -System
```

---

## Usage

```
tub start      Start the server and open in browser
tub stop       Stop the server
tub restart    Restart the server
tub status     Show running status, PID, and URL
tub open       Open browser (server must already be running)
```

TUB runs at **http://127.0.0.1:8787** and is restricted to localhost only — it never accepts connections from other machines on your network.

---

## Login

The portal is protected by basic authentication.

| Field | Default |
|---|---|
| Username | `bhupender` |
| Password | `secret` |

---

## Configuration

TUB reads settings from three places. Higher entries win:

```
1. Environment variables   (highest — good for one-off overrides)
2. ~/.tub/config.toml      (recommended for permanent changes)
3. ~/.tub/.env             (alternative flat format)
```

### config.toml (recommended)

The installer creates `~/.tub/config.toml` automatically on first install:

```toml
# TUB — Tutorial Hub configuration
# Changes take effect on next:  tub restart

[tub]
user     = "bhupender"
password = "secret"
port     = 8787
```

Edit this file, then run `tub restart` — done.

### .env file (alternative)

If you prefer a flat dotenv format, create `~/.tub/.env`:

```env
TUB_USER=alice
TUB_PASS=mypassword
TUB_PORT=9000
```

### Environment variables (one-off overrides)

```bash
TUB_USER=alice TUB_PASS=mypassword tub start
```

| Variable | config.toml key | Default | Description |
|---|---|---|---|
| `TUB_USER` | `user` | `bhupender` | Login username |
| `TUB_PASS` | `password` | `secret` | Login password |
| `TUB_PORT` | `port` | `8787` | Port the server listens on |

---

## Logs & files

| Path | Contents |
|---|---|
| `~/.tub/tub.log` | Server stdout / stderr |
| `~/.tub/tub.pid` | PID of the running server (managed automatically) |
| `~/.tub/app/` | Installed app files |
| `~/.tub/venv/` | Isolated Python environment |

---

## Reinstall / update

Pull the latest code and run the installer again — it stops any running instance, syncs the files, and re-links the binary.

```bash
bash install.sh
```

---

## Project structure

```
tub/
├── tub/
│   ├── app.py          Flask application
│   └── cli.py          tub CLI (start / stop / restart / status / open)
├── templates/          HTML tutorial pages (23 topics)
├── static/
│   ├── default_css/    Stylesheet
│   ├── default_js/     JavaScript
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
