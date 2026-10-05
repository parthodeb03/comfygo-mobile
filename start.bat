@echo off
setlocal EnableDelayedExpansion
title ComfyGo - Starting...

echo.
echo  ========================================
echo       ComfyGo - One-Click Start
echo  ========================================
echo.

:: ─── Step 1: Start Backend ──────────────────────
echo [1/5] Setting up backend...
cd /d "%~dp0backend"

if not exist "venv" (
    echo       Creating Python virtual environment...
    python -m venv venv 2>nul
    if !errorlevel! neq 0 (
        echo [ERROR] Python not found. Please install Python 3.10+
        pause
        exit /b 1
    )
)

call venv\Scripts\activate.bat >nul 2>&1

echo [2/5] Installing Python dependencies...
pip install -r requirements.txt --quiet --disable-pip-version-check 2>nul

echo [3/5] Starting backend server...
:: Kill any existing uvicorn on port 8000
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8000 ^| findstr LISTENING 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)

start "ComfyGo Backend" /min cmd /k "title ComfyGo Backend && cd /d %~dp0backend && venv\Scripts\activate.bat && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000"

:: Wait for backend to be ready
echo       Waiting for backend to start...
set /a count=0
:waitloop
if !count! geq 15 goto backendstarted
curl -s http://localhost:8000/health >nul 2>&1
if !errorlevel! equ 0 goto backendstarted
set /a count+=1
timeout /t 1 /nobreak >nul
goto waitloop
:backendstarted
echo       Backend is ready!

:: ─── Step 2: Setup ADB Reverse ──────────────────
cd /d "%~dp0"
echo [4/5] Setting up ADB reverse (phone → laptop)...
adb reverse tcp:8000 tcp:8000 >nul 2>&1
if !errorlevel! equ 0 (
    echo       ADB reverse configured!
) else (
    echo       ADB not found or no device connected. Skipping.
    echo       If using a physical device, run: adb reverse tcp:8000 tcp:8000
)

:: ─── Step 3: Start Flutter ──────────────────────
echo [5/5] Starting Flutter app...
echo.
echo  ========================================
echo   Backend  : http://localhost:8000
echo   ADB      : tcp:8000 forwarded
echo   Frontend : flutter run
echo  ========================================
echo.

flutter run
