# BBAC VST3 Plugin - Minimal VST3 SDK Implementation

This is a minimal VST3 plugin that wraps your Python Beat Battle Anti Cheat script.

## What This Does

- Implements a VST3 plugin using the VST3 SDK directly (no JUCE)
- Launches your Python script in a background thread when the plugin loads
- No audio processing, no MIDI, no GUI - just a container for your Python app
- **Much simpler than JUCE** - only ~150 lines of code!

## Prerequisites

Before building, you need to build the VST3 SDK base libraries:

### 1. Build VST3 SDK Libraries

```powershell
cd C:\Users\16514\Documents\myStuff\CSF\VST_SDK\vst3sdk
mkdir build
cd build
cmake ..
cmake --build . --config Debug
cmake --build . --config Release
```

This will create the necessary `.lib` files in `vst3sdk\build\lib\Debug` and `vst3sdk\build\lib\Release`.

## Building the Plugin

1. Open `BBACPlugin.vcxproj` in Visual Studio 2022
2. Build the project (Debug or Release)
3. The output will be `BBACPlugin.vst3` in the `build` folder

## Installing the Plugin

Copy `BBACPlugin.vst3` to your VST3 folder:
- `C:\Program Files\Common Files\VST3\`

OR create the proper VST3 bundle structure:
```
BBACPlugin.vst3\
  Contents\
    x86_64-win\
      BBACPlugin.vst3  (the actual DLL)
```

## File Structure

- `BBACPlugin.h` - Plugin interface declaration
- `BBACPlugin.cpp` - Plugin implementation and factory
- `BBACPlugin.def` - Export definitions for the DLL
- `BBACPlugin.vcxproj` - Visual Studio project file

## Customization

To customize the plugin:
- **Plugin Name**: Search for "Beat Battle Anti Cheat" in `BBACPlugin.cpp`
- **Plugin UIDs**: Generate new GUIDs at https://www.guidgenerator.com/ and replace the ones in `BBACPlugin.cpp`
- **Python Script Path**: Modify the path navigation in `initPython()` if needed

## Troubleshooting

**If you get linker errors about missing SDK libraries:**
- Make sure you built the VST3 SDK as described above
- Check that the library paths in the `.vcxproj` match your build output

**If the Python script doesn't run:**
- Check the path navigation in `initPython()` - it goes up 7 directories from the plugin DLL
- Make sure `BBAC2.py` is in the workspace root

## Advantages Over JUCE

- ✅ No Projucer, no module dependencies, no build complexity
- ✅ ~150 lines of code vs thousands in JUCE
- ✅ Smaller binary size
- ✅ Direct control over everything
- ✅ Easier to debug and understand
