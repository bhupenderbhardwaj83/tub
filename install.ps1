# ─────────────────────────────────────────────────────────────────────────────
#  TUB — Tutorial Hub  |  Windows PowerShell installer
#
#  User install   (current user only):  powershell -ExecutionPolicy Bypass -File install.ps1
#  System install (all users, run as Administrator):
#                                        powershell -ExecutionPolicy Bypass -File install.ps1 -System
# ─────────────────────────────────────────────────────────────────────────────
#Requires -Version 5.1
param([switch]$System)

$ErrorActionPreference = "Stop"
$SrcDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ── Install mode ──────────────────────────────────────────────────────────────
function Test-Admin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = [System.Security.Principal.WindowsPrincipal]$id
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if ($System) {
    if (-not (Test-Admin)) {
        Write-Host "  [XX]  -System requires Administrator. Re-run as Admin." -ForegroundColor Red
        exit 1
    }
    $InstallDir = "C:\ProgramData\tub"
    $BinDir     = "C:\ProgramData\tub\bin"
    $PathScope  = "Machine"
    $Mode       = "system (all users)"
} else {
    $InstallDir = "$env:USERPROFILE\.tub"
    $BinDir     = "$env:USERPROFILE\.local\bin"
    $PathScope  = "User"
    $Mode       = "user ($env:USERNAME)"
}

$AppDir = "$InstallDir\app"
$Venv   = "$InstallDir\venv"

function info  ($msg) { Write-Host "  [OK]  $msg" -ForegroundColor Green }
function warn  ($msg) { Write-Host "  [!!]  $msg" -ForegroundColor Yellow }
function error ($msg) { Write-Host "  [XX]  $msg" -ForegroundColor Red; exit 1 }
function step  ($msg) { Write-Host "`n  ──  $msg" -ForegroundColor Cyan }

Write-Host "`n  TUB  ·  Tutorial Hub Installer (Windows)" -ForegroundColor White
Write-Host "  Mode: $Mode`n" -ForegroundColor White

# ── 1. Find Python 3.8+ ───────────────────────────────────────────────────────
step "Checking Python"
$Python = $null
foreach ($cmd in @("python", "python3", "py")) {
    try {
        $out = & $cmd -c "import sys; print(sys.version_info >= (3,8))" 2>$null
        if ($out -eq "True") { $Python = $cmd; break }
    } catch {}
}
if (-not $Python) {
    error "Python 3.8+ required.  Get it at https://python.org (check 'Add to PATH' during install)"
}
info "Found $(& $Python --version)"

# ── 2. Stop any running instance ──────────────────────────────────────────────
step "Pre-install check"
# PID file is always user-specific, even on system installs
$UserTubDir = "$env:USERPROFILE\.tub"
$PidFile    = "$UserTubDir\tub.pid"
if (Test-Path $PidFile) {
    $oldPid = (Get-Content $PidFile -ErrorAction SilentlyContinue) -as [int]
    if ($oldPid) {
        $proc = Get-Process -Id $oldPid -ErrorAction SilentlyContinue
        if ($proc) {
            warn "Stopping running TUB instance (PID $oldPid) ..."
            Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
        }
    }
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
}
info "Clean to install"

# ── 3. Copy app files ─────────────────────────────────────────────────────────
step "Copying files  ->  $AppDir"
if (Test-Path $AppDir) { Remove-Item $AppDir -Recurse -Force }
New-Item -ItemType Directory -Path $AppDir -Force | Out-Null

$robocopyArgs = @($SrcDir, $AppDir, "/E", "/XD", ".git", "__pycache__", ".venv", "venv", "/XF", "*.pyc")
$rc = (Start-Process robocopy -ArgumentList $robocopyArgs -Wait -PassThru -NoNewWindow).ExitCode
if ($rc -ge 8) { error "File copy failed (robocopy exit $rc)" }
info "Files installed"

# ── 4. Virtual environment ────────────────────────────────────────────────────
step "Setting up Python environment"
if (-not (Test-Path $Venv)) {
    & $Python -m venv $Venv
    info "Virtual environment created"
} else {
    info "Reusing existing virtual environment"
}

& "$Venv\Scripts\pip.exe" install --quiet --upgrade pip

# Install the tub package — pip reads pyproject.toml, installs flask,
# and generates a real Windows executable at $Venv\Scripts\tub.exe
& "$Venv\Scripts\pip.exe" install --quiet $AppDir
info "Package installed  ->  $Venv\Scripts\tub.exe"

# ── 5. Symlink pip-generated executable into BinDir ──────────────────────────
step "Linking  tub  ->  $BinDir"
if (-not (Test-Path $BinDir)) { New-Item -ItemType Directory -Path $BinDir -Force | Out-Null }

$tubExe = "$Venv\Scripts\tub.exe"
$tubLink = "$BinDir\tub.exe"

# Remove old link/file if present
if (Test-Path $tubLink) { Remove-Item $tubLink -Force }

# Use a hard link (works without developer mode unlike symlinks)
New-Item -ItemType HardLink -Path $tubLink -Target $tubExe | Out-Null
info "Linked:  $tubLink  ->  $tubExe"

# Also drop a tub.cmd shim so plain 'tub' works in cmd.exe without the .exe
$cmdContent = "@echo off`r`n`"$tubLink`" %*`r`n"
[System.IO.File]::WriteAllText("$BinDir\tub.cmd", $cmdContent)
info "tub.cmd shim written (for cmd.exe compatibility)"

# ── 6. PATH ───────────────────────────────────────────────────────────────────
step "Checking PATH"
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", $PathScope)
if ($currentPath -notlike "*$BinDir*") {
    [System.Environment]::SetEnvironmentVariable("PATH", "$BinDir;$currentPath", $PathScope)
    $env:PATH = "$BinDir;$env:PATH"
    if ($System) {
        warn "$BinDir added to system PATH (all users)."
    } else {
        warn "$BinDir added to your user PATH."
    }
    warn "Restart your terminal for 'tub' to work everywhere."
} else {
    info "PATH already includes $BinDir"
}

# ── 7. Write sample config (only on first install — never overwrite edits) ────
step "Config file"
$ConfigFile = "$env:USERPROFILE\.tub\config.toml"
if (-not (Test-Path $ConfigFile)) {
    $configContent = @"
# TUB -- Tutorial Hub configuration
# Changes take effect on next:  tub restart
#
# Priority order (highest wins):
#   Environment variables  >  this file  >  .env file  >  built-in defaults

[tub]
user     = "bhupender"
password = "secret"
port     = 8787

# host controls who can reach TUB:
#   127.0.0.1  -- localhost only, secure (default)
#   0.0.0.0    -- all network interfaces; makes TUB reachable from other
#                 machines on your network (use only on trusted networks)
host = "127.0.0.1"
"@
    [System.IO.File]::WriteAllText($ConfigFile, $configContent)
    info "Config written  ->  $ConfigFile"
} else {
    info "Existing config kept  ->  $ConfigFile"
}

# ── 8. Smoke test ─────────────────────────────────────────────────────────────
step "Verifying install"
try {
    & "$tubLink" status
    info "tub command works"
} catch {
    warn "Could not run smoke test — check manually with: tub status"
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host "`n  TUB installed successfully!  [$Mode]`n" -ForegroundColor Green
Write-Host "  tub start      ->  start server + open browser"
Write-Host "  tub stop       ->  stop server"
Write-Host "  tub restart    ->  restart server"
Write-Host "  tub status     ->  show PID and URL"
Write-Host "  tub open       ->  open browser (server must be running)"
Write-Host ""
Write-Host "  Credentials:   bhupender / secret"
Write-Host "  Port:          8787  (override: `$env:TUB_PORT=9000; tub start)"
Write-Host "  Logs:          $env:USERPROFILE\.tub\tub.log"
Write-Host "  Installed to:  $AppDir"
Write-Host ""

$reply = Read-Host "  Start TUB now? [Y/n]"
if (-not $reply) { $reply = "Y" }
if ($reply -match "^[Yy]") {
    & "$tubLink" start
}
