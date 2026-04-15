@echo off
setlocal
cd /d "%~dp0\.."

if not exist ".settings.env" (
    echo ERROR: .settings.env not found. Run scripts\install.bat first.
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running. Start Docker Desktop and try again.
    exit /b 1
)

docker compose --env-file .settings.env -f docker-compose.windows.yml up -d
if errorlevel 1 exit /b 1

for /f "usebackq tokens=1,2 delims== eol=#" %%A in (".settings.env") do (
    if "%%A"=="FRONTEND_PORT" set "FRONTEND_PORT=%%B"
)

echo.
echo === ImageTalk is starting ===
echo Open http://localhost:%FRONTEND_PORT% in your browser.
endlocal
