@echo off
setlocal
cd /d "%~dp0\.."

if not exist ".settings.env" (
    echo ERROR: .settings.env not found.
    exit /b 1
)

for /f %%i in ('docker compose --env-file .settings.env -f docker-compose.windows.yml ps -q 2^>nul') do set "_RUNNING=1"
if defined _RUNNING (
    echo ERROR: ImageTalk containers are still running.
    echo        Stop them first: scripts\stop.bat
    exit /b 1
)

echo This will permanently delete:
echo   - data\postgres  ^(Postgres database: catalogue, metadata^)
echo   - data\qdrant    ^(Qdrant vector index: image embeddings^)
echo.
echo Your images in IMAGETALK_ROOT are NOT touched.
echo The next start will initialize empty store, and you will need to resync the folders with your collection from scratch.
echo.
set /p "_CONFIRM=Proceed? [y/N]: "
if /i not "%_CONFIRM%"=="y" (
    echo Cancelled.
    exit /b 0
)

if exist "data\postgres" rmdir /s /q "data\postgres"
if exist "data\qdrant" rmdir /s /q "data\qdrant"

echo Done.
endlocal
