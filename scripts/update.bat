@echo off
setlocal
cd /d "%~dp0\.."

if not exist ".settings.env" (
    echo ERROR: .settings.env not found. Run scripts\install.bat first.
    exit /b 1
)

docker compose --env-file .settings.env -f docker-compose.windows.yml pull
if errorlevel 1 exit /b 1

docker compose --env-file .settings.env -f docker-compose.windows.yml up -d
endlocal
