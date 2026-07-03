@echo off
setlocal

if "%~1"=="" (
  echo Usage: cal.cmd path\to\app.apk
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0cal.ps1" "%~1"
