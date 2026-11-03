@echo off
setlocal
set "VICE_BIN=D:\GTK3VICE-3.10-win64\bin"
if "%~1"=="" (
  echo Usage: run-c64.bat "path-to-listing.bas"
  exit /b 1
)
where py >nul 2>&1
if not errorlevel 1 (
  py -3 "%~dp0tools\c64.py" --run "%~1"
) else (
  python "%~dp0tools\c64.py" --run "%~1"
)
exit /b %errorlevel%
