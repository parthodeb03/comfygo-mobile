@echo off
REM Restores the adb reverse tunnel (PC:8000 -> phone:8000) and launches ComfyGo.
REM The backend must already be running: double-click backend\start_backend.bat first.

set ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
set APPDIR=%~dp0

echo [1/4] Checking phone connection...
"%ADB%" reverse --list >nul 2>&1
"%ADB%" shell true >nul 2>&1
if errorlevel 1 (
    echo       Phone not connected wirelessly. Reconnecting via mDNS...
    for /f "tokens=1,2 delims= " %%a in ('"%ADB%" mdns services ^| findstr _adb-tls-connect') do (
        set SVCE=%%a
        set ADDR=%%b
    )
    if defined ADDR (
        echo       Found phone at %ADDR%
        "%ADB%" connect %ADDR%
        ping -n 4 127.0.0.1 >nul
    ) else (
        echo       Phone not found on the network. Make sure Wireless Debugging
        echo       is ON in Developer Options and the phone is on the same Wi-Fi.
        pause
        exit /b 1
    )
)

echo [2/4] Setting up port tunnel (localhost:8000 -^> PC:8000)...
"%ADB%" reverse tcp:8000 tcp:8000

echo [3/4] Checking backend on port 8000...
curl -s -o nul -w "       Backend responded: HTTP %%{http_code}\n" http://localhost:8000/health
if errorlevel 1 (
    echo       Backend is NOT running. Start it first: backend\start_backend.bat
    pause
    exit /b 1
)

echo [4/4] Launching app on phone...
"%ADB%" shell am start -n com.example.untitled/.MainActivity
if errorlevel 1 (
    echo       App not installed. Run: flutter run
    pause
    exit /b 1
)

echo.
echo Done. If the app shows connection errors later, close Wi-Fi briefly and
echo re-run this script - it safely re-establishes everything.
ping -n 6 127.0.0.1 >nul
