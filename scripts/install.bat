@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0\.."

echo === ImageTalk installer ===
echo.

if not exist ".settings.env" (
    echo ERROR: .settings.env not found.
    echo        Copy .settings.env.example to .settings.env and set IMAGETALK_ROOT first.
    exit /b 1
)

echo [1/5] Loading settings...
for /f "usebackq tokens=1,2 delims== eol=#" %%A in (".settings.env") do (
    if not "%%A"=="" set "%%A=%%B"
)

if "%IMAGETALK_ROOT%"=="" (
    echo ERROR: IMAGETALK_ROOT is not set in .settings.env
    exit /b 1
)
if not exist "%IMAGETALK_ROOT%" (
    echo ERROR: IMAGETALK_ROOT path does not exist: %IMAGETALK_ROOT%
    exit /b 1
)
echo       IMAGETALK_ROOT = %IMAGETALK_ROOT%

echo [2/5] Checking Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running or not installed.
    echo        Install Docker Desktop from https://www.docker.com/products/docker-desktop/ and start it.
    exit /b 1
)
echo       Docker is running.

echo [3/5] Checking Ollama...
ollama list >nul 2>&1
if errorlevel 1 (
    echo ERROR: Ollama is not running or not installed.
    echo        Install Ollama from https://ollama.com/download and start it.
    exit /b 1
)
echo       Ollama is running.

set "_OMLM=%OLLAMA_MAX_LOADED_MODELS%"
if "%_OMLM%"=="" set "_OMLM=1"
if "%_OMLM%"=="1" (
    echo WARNING: Recommended: set system env var OLLAMA_MAX_LOADED_MODELS=2 or higher.
    echo          A search uses two models; keeping both loaded at once ^(if the VRAM size allows^)
    echo          makes searches faster.
)
set "_OMLM="

echo [4/5] Pulling Docker images...
docker compose --env-file .settings.env pull
if errorlevel 1 (
    echo ERROR: Failed to pull Docker images.
    exit /b 1
)

echo [5/5] Pulling Ollama models (first run may take a while)...
for %%M in ("%EMBEDDING_MODEL%" "%DESCRIBE_MODEL%" "%TALKING_MODEL%") do (
    echo       Pulling %%~M ...
    ollama pull %%~M
    if errorlevel 1 (
        echo ERROR: Failed to pull %%~M
        exit /b 1
    )
)

echo.
echo === Installation complete ===
echo Next: run scripts\start.bat
endlocal
