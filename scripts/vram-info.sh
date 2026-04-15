#!/usr/bin/env bash
set -eu

GPU=""
VRAM_GB=0

if command -v nvidia-smi >/dev/null 2>&1; then
    GPU=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    VRAM_MIB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n1 | tr -d ' ')
    # Round MiB to nearest GB (e.g. 24564 MiB -> 24 GB).
    VRAM_GB=$(( (VRAM_MIB + 512) / 1024 ))
elif [ "$(uname -s)" = "Darwin" ]; then
    if [ "$(uname -m)" = "arm64" ]; then
        # Apple Silicon: unified memory. The GPU can use up to ~75% of system
        # RAM by default (configurable via iogpu.wired_limit_mb), so we report
        # that as the practical VRAM ceiling.
        GPU="Apple Silicon GPU (unified memory)"
        RAM_BYTES=$(sysctl -n hw.memsize)
        RAM_GB=$(( RAM_BYTES / 1024 / 1024 / 1024 ))
        VRAM_GB=$(( RAM_GB * 3 / 4 ))
    else
        # Intel Mac with discrete GPU.
        GPU=$(system_profiler SPDisplaysDataType | awk -F': ' '/Chipset Model/ { print $2; exit }')
        VRAM_LINE=$(system_profiler SPDisplaysDataType | grep -i "VRAM" | head -n1 || true)
        case "$VRAM_LINE" in
            *GB*) VRAM_GB=$(echo "$VRAM_LINE" | sed -E 's/.*: *([0-9]+) GB.*/\1/') ;;
            *MB*) VRAM_MB=$(echo "$VRAM_LINE" | sed -E 's/.*: *([0-9]+) MB.*/\1/'); VRAM_GB=$(( VRAM_MB / 1024 )) ;;
        esac
    fi
fi

if [ -z "$GPU" ] || [ -z "${VRAM_GB:-}" ] || [ "$VRAM_GB" = "0" ]; then
    echo "ERROR: Could not detect GPU/VRAM."
    echo "       On Linux/Windows nvidia-smi must be available; on macOS the script"
    echo "       auto-detects Apple Silicon and discrete GPUs via system_profiler."
    exit 1
fi

PROFILE="insufficient"
if [ "$VRAM_GB" -ge 16 ]; then PROFILE="16gb"; fi
if [ "$VRAM_GB" -ge 24 ]; then PROFILE="24gb"; fi
if [ "$VRAM_GB" -ge 32 ]; then PROFILE="32gb"; fi

echo "GPU: $GPU"
echo "VRAM: ${VRAM_GB} GB"
echo "RECOMMENDED_PROFILE: $PROFILE"
if [ "$PROFILE" = "insufficient" ]; then
    echo "NOTE: ImageTalk needs at least 16 GB of GPU memory."
fi
