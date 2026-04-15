@echo off
setlocal
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

echo [3/5] Pulling Docker images...
docker compose --env-file .settings.env -f docker-compose.windows.yml pull
if errorlevel 1 (
    echo ERROR: Failed to pull Docker images.
    exit /b 1
)

echo [4/5] Starting Ollama container...
docker compose --env-file .settings.env -f docker-compose.windows.yml up -d ollama --wait
if errorlevel 1 (
    echo ERROR: Failed to start Ollama container.
    echo        For NVIDIA GPU support on Windows: make sure your NVIDIA driver is recent
    echo        and Docker Desktop's WSL2 backend is enabled.
    echo        Verify GPU passthrough with: scripts\gpu-check.bat
    exit /b 1
)
echo       Ollama is healthy.

echo [5/5] Pulling Ollama models (first run may take a while)...
for %%M in ("%EMBEDDING_MODEL%" "%DESCRIBE_MODEL%" "%TALKING_MODEL%") do (
    echo       Pulling %%~M ...
    docker compose --env-file .settings.env -f docker-compose.windows.yml exec ollama ollama pull %%~M
    if errorlevel 1 (
        echo ERROR: Failed to pull %%~M
        exit /b 1
    )
)

echo Stopping Ollama container...
docker compose --env-file .settings.env -f docker-compose.windows.yml stop ollama >nul

echo.
echo === Installation complete ===
echo Next: run scripts\start.bat
endlocal
