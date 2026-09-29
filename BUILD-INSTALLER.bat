@echo off
REM Potta Finance - Automated Installer Build Script

echo.
echo ============================================================================
echo                    POTTA FINANCE INSTALLER BUILDER
echo ============================================================================
echo.

REM Check if Inno Setup is installed
set "INNO_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if exist "%INNO_PATH%" goto INNO_OK
echo [ERROR] Inno Setup 6 not found at: %INNO_PATH%
echo.
echo Please install Inno Setup 6.7 from:
echo https://jrsoftware.org/isdl.php
echo.
pause
exit /b 1
:INNO_OK

echo [1/4] Checking wizard images...
echo.

REM The .iss uses PNG files (potta_wizard_large.png / potta_wizard_small.png)
if not exist "potta_wizard_large.png" (
    echo [WARNING] Wizard images not found. Generating...
    echo.
    
    python --version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Python not found. Cannot generate wizard images.
        echo.
        echo Please install Python and run: python generate_wizard_images.py
        echo.
        pause
        exit /b 1
    )
    
    pip install Pillow >nul 2>&1
    python generate_wizard_images.py
    
    if errorlevel 1 (
        echo [ERROR] Failed to generate wizard images.
        echo.
        pause
        exit /b 1
    )
) else (
    echo [OK] Wizard images found!
)

echo.
REM ============================================================================
REM Read VERSION.txt and publish both apps into build-temp
REM ============================================================================
set VERSION_FILE=..\VERSION.txt
if exist "%VERSION_FILE%" goto VERSION_OK
echo [ERROR] VERSION.txt not found at: %VERSION_FILE%
echo Please create it ^(example: 1.3.4.5^) and try again.
pause
exit /b 1
:VERSION_OK

set /p VERSION=<"%VERSION_FILE%"
if not "%VERSION%"=="" goto VERSION_NONEMPTY
echo [ERROR] VERSION.txt is empty.
pause
exit /b 1
:VERSION_NONEMPTY

echo ============================================
echo              BUILD POTTA v%VERSION%
echo ============================================

set SCRIPT_DIR=%~dp0
set BUILD_TEMP=%SCRIPT_DIR%build-temp
set FINANCE_OUT=%BUILD_TEMP%\Potta Finance
set API_OUT=%BUILD_TEMP%\PottaAPI
set KDS_OUT=%BUILD_TEMP%\PottaKDS

REM Clean build-temp
if exist "%BUILD_TEMP%" rmdir /s /q "%BUILD_TEMP%"
mkdir "%BUILD_TEMP%"
mkdir "%FINANCE_OUT%"
mkdir "%API_OUT%"
mkdir "%KDS_OUT%"

echo.
echo Restoring dependencies for win-x64...
dotnet restore "..\Potta Finance\Potta Finance.csproj" -r win-x64
dotnet restore "..\PottaAPI\PottaAPI.csproj" -r win-x64
dotnet restore "..\PottaKDS\PottaKDS.csproj" -r win-x64

echo.
echo [1/4] Publishing Potta Finance (WPF)...

REM ------------------------------------------
REM IMPORTANT: We use --self-contained true so that ALL .NET 8 runtime assemblies
REM (including WindowsBase.dll, PresentationCore.dll, PresentationFramework.dll, etc.)
REM are included in the publish output. Without self-contained, these WPF assemblies
REM are NOT copied to the output folder, causing an immediate crash on machines
REM that do not have the .NET 8 Desktop Runtime installed.
REM ------------------------------------------
dotnet publish "..\Potta Finance\Potta Finance.csproj" ^
    -c Release ^
    -r win-x64 ^
    --self-contained true ^
    -p:PublishSingleFile=false ^
    -p:APP_VERSION=%VERSION% ^
    -o "%FINANCE_OUT%"

if errorlevel 1 (
    echo [ERROR] WPF publish failed!
    pause
    exit /b 1
)

echo.
echo Verifying critical runtime assemblies in WPF publish output...

REM -----------------------------------------------------------------------
REM These DLLs are REQUIRED for a self-contained .NET 8 WPF app.
REM If any are missing, the app will crash before showing a window.
REM Missing files here almost always mean the project is not truly
REM self-contained check that your .csproj has:
REM   <SelfContained>true</SelfContained>  or  <RuntimeIdentifier>win-x64</RuntimeIdentifier>
REM and that you are NOT setting PublishSingleFile=true (which bundles everything
REM into one exe and would make these checks pointless here).
REM -----------------------------------------------------------------------

set MISSING=0

if not exist "%FINANCE_OUT%\WindowsBase.dll" (
    echo [ERROR] Missing: WindowsBase.dll
    set MISSING=1
)
if not exist "%FINANCE_OUT%\PresentationCore.dll" (
    echo [ERROR] Missing: PresentationCore.dll
    set MISSING=1
)
if not exist "%FINANCE_OUT%\PresentationFramework.dll" (
    echo [ERROR] Missing: PresentationFramework.dll
    set MISSING=1
)
if not exist "%FINANCE_OUT%\Microsoft.Data.Sqlite.dll" (
    echo [ERROR] Missing: Microsoft.Data.Sqlite.dll
    set MISSING=1
)

if "%MISSING%"=="1" (
    echo.
    echo [ERROR] One or more critical assemblies are missing from the publish output.
    echo         Path: %FINANCE_OUT%
    echo.
    echo Possible causes:
    echo   1. Project is not truly self-contained. Verify your .csproj:
    echo         ^<RuntimeIdentifier^>win-x64^</RuntimeIdentifier^>
    echo         ^<SelfContained^>true^</SelfContained^>
    echo   2. PublishSingleFile=true is bundling files if so, remove the checks above.
    echo   3. A Directory.Build.props or NuGet config is stripping runtime assemblies.
    echo.
    echo Aborting installer build.
    pause
    exit /b 1
)

echo [OK] All critical WPF runtime assemblies present.

echo.
echo [2/4] Publishing PottaAPI (Core Engine)...
dotnet publish "..\PottaAPI\PottaAPI.csproj" ^
    -c Release ^
    -r win-x64 ^
    --self-contained true ^
    -p:APP_VERSION=%VERSION% ^
    -o "%API_OUT%"

if errorlevel 1 (
    echo [ERROR] API publish failed!
    pause
    exit /b 1
)

if not exist "%API_OUT%\Microsoft.Data.Sqlite.dll" (
    echo [WARNING] PottaAPI publish output is missing Microsoft.Data.Sqlite.dll.
    echo           This may indicate a packaging issue with the API project.
)

echo.
echo [3/4] Publishing PottaKDS (Kitchen Display System)...
dotnet publish "..\PottaKDS\PottaKDS.csproj" ^
    -c Release ^
    -r win-x64 ^
    --self-contained true ^
    -p:PublishSingleFile=false ^
    -p:APP_VERSION=%VERSION% ^
    -o "%KDS_OUT%"

if errorlevel 1 (
    echo [ERROR] PottaKDS publish failed!
    pause
    exit /b 1
)

echo.
echo Verifying critical runtime assemblies in PottaKDS publish output...
set KDS_MISSING=0

if not exist "%KDS_OUT%\WindowsBase.dll" (
    echo [ERROR] Missing in KDS: WindowsBase.dll
    set KDS_MISSING=1
)
if not exist "%KDS_OUT%\PresentationCore.dll" (
    echo [ERROR] Missing in KDS: PresentationCore.dll
    set KDS_MISSING=1
)
if not exist "%KDS_OUT%\PresentationFramework.dll" (
    echo [ERROR] Missing in KDS: PresentationFramework.dll
    set KDS_MISSING=1
)

if "%KDS_MISSING%"=="1" (
    echo.
    echo [ERROR] One or more critical assemblies are missing from PottaKDS publish output.
    echo         Path: %KDS_OUT%
    echo Aborting installer build.
    pause
    exit /b 1
)

echo [OK] All critical PottaKDS runtime assemblies present.

echo.
echo [4/4] Compiling installer with Inno Setup...

"%INNO_PATH%" /dMyAppVersion=%VERSION% /dSourceDir="%BUILD_TEMP%" "PottaSetup-Professional.iss"

if errorlevel 1 (
    echo [ERROR] Installer compilation failed!
    pause
    exit /b 1
)

echo [OK] Installer compiled successfully!

echo.
echo Verifying output...

set EXPECTED_EXE=installer-output\PottaSetup_v%VERSION%.exe

if exist "%EXPECTED_EXE%" (
    echo [OK] Installer created successfully!
    echo.
    echo ============================================================================
    echo                              SUCCESS!
    echo ============================================================================
    echo.
    echo Installer location:
    echo %SCRIPT_DIR%installer-output\PottaSetup_v%VERSION%.exe
    echo.
    
    for %%A in ("%EXPECTED_EXE%") do (
        set size=%%~zA
    )
    echo File size: %size% bytes
    echo.
    
    set /p OPEN="Open installer folder? (Y/N): "
    if /i "%OPEN%"=="Y" (
        explorer "installer-output"
    )
) else (
    echo [ERROR] Installer file not found!
    echo Expected: %EXPECTED_EXE%
)

echo.
pause
