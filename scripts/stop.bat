@echo off
setlocal
cd /d "%~dp0\.."
docker compose --env-file .settings.env down
endlocal
