@echo off
cd /d %~dp0
set videopath="%1"
echo %videopath%
powershell -noprofile -nologo -executionpolicy bypass -File "%cd%/powershell/run CAIN.ps1"
exit

:: This script requires
:: ffmpeg.exe
:: ffprobe.exe
:: cain-ncnn-vulkan.exe
:: dain-ncnn-vulkan.exe (optional)