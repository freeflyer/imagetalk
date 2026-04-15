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

set "_OMLM=%OLLAMA_MAX_LOADED_MODELS%"
if "%_OMLM%"=="" set "_OMLM=1"
if "%_OMLM%"=="1" (
    echo WARNING: Recommended: set system env var OLLAMA_MAX_LOADED_MODELS=2 or higher.
    echo          A search uses two models; keeping both loaded at once ^(if the VRAM size allows^)
    echo          makes searches faster.
)
set "_OMLM="

docker compose --env-file .settings.env up -d
if errorlevel 1 exit /b 1

for /f "usebackq tokens=1,2 delims== eol=#" %%A in (".settings.env") do (
    if "%%A"=="FRONTEND_PORT" set "FRONTEND_PORT=%%B"
)

echo.
echo === ImageTalk is starting ===
echo Open http://localhost:%FRONTEND_PORT% in your browser.
endlocal
