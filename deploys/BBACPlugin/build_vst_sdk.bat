@echo off
echo Building VST3 SDK base libraries...
cd C:\Users\16514\Documents\myStuff\CSF\VST_SDK\vst3sdk

if not exist build (
    mkdir build
)

cd build

echo Running CMake...
cmake ..

echo Building Debug configuration...
cmake --build . --config Debug

echo Building Release configuration...
cmake --build . --config Release

echo.
echo VST3 SDK built successfully!
echo Now you can open BBACPlugin.vcxproj in Visual Studio and build the plugin.
pause
