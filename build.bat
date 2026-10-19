@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0build-and-install.ps1"
if errorlevel 1 (
  echo.
  echo Apex helper exited with an error.
)
endlocal
