#Requires -Version 5.1
<#
.SYNOPSIS
    ComfyGo - One-click start for backend + frontend.
.DESCRIPTION
    Starts the FastAPI backend (uvicorn) and the Flutter frontend.
    Press Ctrl+C to stop both.
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       ComfyGo - One-Click Start      ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ─── Check prerequisites ─────────────────────────────────────
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Python not found. Please install Python 3.10+" -ForegroundColor Red
    exit 1
}
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Flutter not found. Please install Flutter SDK." -ForegroundColor Red
    exit 1
}

# ─── Backend ─────────────────────────────────────────────────
Write-Host "[1/4] Setting up backend..." -ForegroundColor Yellow
Set-Location "$ScriptDir\backend"

if (-not (Test-Path "venv")) {
    Write-Host "      Creating Python virtual environment..."
    python -m venv venv
}

& ".\venv\Scripts\Activate.ps1"

Write-Host "[2/4] Installing Python dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt --quiet 2>$null

Write-Host "[3/4] Starting backend server on http://localhost:8000 ..." -ForegroundColor Yellow
$backendJob = Start-Process -FilePath "cmd.exe" `
    -ArgumentList "/k", "title ComfyGo Backend && cd /d $ScriptDir\backend && venv\Scripts\activate.bat && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000" `
    -PassThru

Write-Host "      Waiting for backend to start..."
Start-Sleep -Seconds 3

# ─── Frontend ────────────────────────────────────────────────
Set-Location $ScriptDir

Write-Host "[4/4] Starting Flutter frontend..." -ForegroundColor Yellow
Write-Host ""
Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Backend  : http://localhost:8000     ║" -ForegroundColor Green
Write-Host "║  Frontend : flutter run               ║" -ForegroundColor Green
Write-Host "║                                      ║" -ForegroundColor Green
Write-Host "║  Close this window to stop both.     ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

try {
    flutter run
} finally {
    Write-Host ""
    Write-Host "Stopping backend..." -ForegroundColor Yellow
    if ($backendJob -and -not $backendJob.HasExited) {
        Stop-Process -Id $backendJob.Id -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Done." -ForegroundColor Green
}
