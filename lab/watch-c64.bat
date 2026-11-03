@echo off
setlocal
set "VICE_BIN=D:\GTK3VICE-3.10-win64\bin"
where py >nul 2>&1
if not errorlevel 1 (
  py -3 -u "%~dp0tools\c64.py" --watch "%~dp0programs" --run
) else (
  python -u "%~dp0tools\c64.py" --watch "%~dp0programs" --run
)
exit /b %errorlevel%
