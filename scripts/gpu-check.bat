@echo off
setlocal
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
endlocal
