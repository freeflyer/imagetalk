@echo off
setlocal
cd /d "%~dp0\.."
docker compose --env-file .settings.env -f docker-compose.windows.yml down
endlocal
