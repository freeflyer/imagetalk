@echo off
setlocal enabledelayedexpansion

where nvidia-smi >nul 2>&1
if errorlevel 1 (
    echo ERROR: nvidia-smi not found. ImageTalk requires an NVIDIA GPU on Windows.
    echo        Make sure your NVIDIA driver is installed.
    exit /b 1
)

for /f "delims=" %%A in ('nvidia-smi --query-gpu=name --format=csv^,noheader') do (
    if not defined _NAME set "_NAME=%%A"
)
for /f "delims=" %%A in ('nvidia-smi --query-gpu=memory.total --format=csv^,noheader^,nounits') do (
    if not defined _VRAM_MIB set "_VRAM_MIB=%%A"
)

if not defined _VRAM_MIB (
    echo ERROR: Could not read VRAM info from nvidia-smi.
    exit /b 1
)

REM Round MiB to nearest GB (e.g. 24564 MiB -> 24 GB).
set /a _VRAM_GB=(%_VRAM_MIB% + 512) / 1024

set "_PROFILE=insufficient"
if %_VRAM_GB% GEQ 16 set "_PROFILE=16gb"
if %_VRAM_GB% GEQ 24 set "_PROFILE=24gb"
if %_VRAM_GB% GEQ 32 set "_PROFILE=32gb"

echo GPU: %_NAME%
echo VRAM: %_VRAM_GB% GB
echo RECOMMENDED_PROFILE: %_PROFILE%
if "%_PROFILE%"=="insufficient" (
    echo NOTE: ImageTalk needs at least 16 GB of GPU memory.
)

endlocal
