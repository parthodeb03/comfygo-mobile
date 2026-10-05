@echo off
setlocal EnableDelayedExpansion

title ComfyGo - Starting...

echo.
echo  ╔══════════════════════════════════════╗
echo  ║       ComfyGo - One-Click Start      ║
echo  ╚══════════════════════════════════════╝
echo.

:: ─── Check prerequisites ────────────────────────────────────────
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found. Please install Python 3.10+
    pause
    exit /b 1
)

where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter not found. Please install Flutter SDK.
    pause
    exit /b 1
)

:: ─── Backend ─────────────────────────────────────────────────────
echo [1/4] Setting up backend...
cd /d "%~dp0backend"

if not exist "venv" (
    echo       Creating Python virtual environment...
    python -m venv venv
)

call venv\Scripts\activate.bat

echo [2/4] Installing Python dependencies...
pip install -r requirements.txt --quiet

echo [3/4] Starting backend server on http://localhost:8000 ...
start "ComfyGo Backend" cmd /k "title ComfyGo Backend && cd /d %~dp0backend && venv\Scripts\activate.bat && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"

:: Wait for backend to be ready
echo       Waiting for backend to start...
timeout /t 3 /nobreak >nul

:: ─── Frontend ────────────────────────────────────────────────────
cd /d "%~dp0"

echo [4/4] Starting Flutter frontend...
echo.
echo  ╔══════════════════════════════════════╗
echo  ║  Backend  : http://localhost:8000     ║
echo  ║  Frontend : flutter run               ║
echo  ║                                          ║
echo  ║  Press Ctrl+C in the Flutter terminal   ║
echo  ║  to stop the frontend.                 ║
echo  ║  Close the Backend window to stop it.  ║
echo  ╚══════════════════════════════════════╝
echo.

flutter run

echo.
echo Frontend stopped. Close the Backend window manually to stop the backend.
pause
