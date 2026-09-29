@echo off
setlocal

REM Runs GitHub release publishing automation for potta-releases.
REM Uses VERSION.txt automatically if no version is passed.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PUBLISH-RELEASE.ps1" %*
set EXIT_CODE=%ERRORLEVEL%

if not "%EXIT_CODE%"=="0" (
    echo.
    echo [ERROR] Release publishing failed.
    pause
    exit /b %EXIT_CODE%
)

echo.
echo [OK] Release publishing completed.
pause
exit /b 0
