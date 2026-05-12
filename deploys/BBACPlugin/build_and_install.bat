@echo off
echo ================================================
echo   BBAC VST3 Plugin - Complete Build Script
echo ================================================
echo.

set WORKSPACE=C:\Users\16514\Documents\myStuff\CSF\BeatBattleAntiCheat
set VST_SDK=C:\Users\16514\Documents\myStuff\CSF\VST_SDK\vst3sdk
set INSTALL_DIR=C:\Program Files\Common Files\VST3

echo Step 1: Building VST3 SDK libraries...
cd "%VST_SDK%"

if not exist build (
    echo Creating build directory...
    mkdir build
)

cd build

echo Running CMake configuration...
cmake .. -G "Visual Studio 17 2022" -A x64

echo Building Release configuration...
cmake --build . --config Release

echo.
echo Step 2: Building BBACPlugin...
cd "%WORKSPACE%\BBACPlugin"

echo Building with MSBuild...
msbuild BBACPlugin.sln /p:Configuration=Release /p:Platform=x64 /m

if errorlevel 1 (
    echo.
    echo ❌ Build failed! Check the errors above.
    pause
    exit /b 1
)

echo.
echo ✅ Build successful!
echo.
echo Step 3: Installation...
echo Built plugin is at: %WORKSPACE%\BBACPlugin\build\x64\Release\BBACPlugin.vst3
echo.

choice /C YN /M "Do you want to install the plugin to %INSTALL_DIR%"
if errorlevel 2 goto :skip_install
if errorlevel 1 goto :do_install

:do_install
echo Copying plugin...
copy /Y "%WORKSPACE%\BBACPlugin\build\x64\Release\BBACPlugin.vst3" "%INSTALL_DIR%\"
if errorlevel 1 (
    echo ⚠️  Installation failed. You may need to run as Administrator.
    echo Or manually copy the file from: %WORKSPACE%\BBACPlugin\build\x64\Release\BBACPlugin.vst3
) else (
    echo ✅ Plugin installed successfully!
)
goto :end

:skip_install
echo Skipping installation.
echo You can manually copy from: %WORKSPACE%\BBACPlugin\build\x64\Release\BBACPlugin.vst3
echo                         to: %INSTALL_DIR%\

:end
echo.
echo ================================================
echo   Build Complete!
echo ================================================
echo.
echo Next: Open your DAW and scan for new plugins!
echo.
pause
