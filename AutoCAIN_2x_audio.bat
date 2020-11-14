@echo off
cd /d %~dp0
set videopath="%1"
echo %videopath%
powershell -noprofile -nologo -executionpolicy bypass -File "%cd%/powershell/AutoCAIN_2x_audio.ps1"
exit

:: This script requires
:: ffmpeg.exe
:: ffprobe.exe
:: cain-ncnn-vulkan.exe