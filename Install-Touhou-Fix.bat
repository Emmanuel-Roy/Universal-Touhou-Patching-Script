@echo off
title Touhou Series Universal Installer
cd /d "%~dp0"

if exist "%~dp0Install-Touhou-Fix.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-Touhou-Fix.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -useb https://raw.githubusercontent.com/Emmanuel-Roy/Touhou-Classic-Windows11-ARM64-Fix/main/Install-Touhou-Fix.ps1 | iex"
)

echo.
echo ========================================================
echo  Setup complete! Press any key to exit.
echo ========================================================
pause >nul
