@echo off
cd /d "%~dp0"
call .venv\Scripts\activate.bat
REM Let a USB or wireless-debugging phone reach this server at localhost:8000.
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000 >nul 2>nul
where adb >nul 2>nul && adb reverse tcp:8000 tcp:8000 >nul 2>nul
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
