# Building BBACPlugin with ImGui

## Quick Build Guide

### Step 1: Clean Previous Build
```powershell
cd C:\Users\16514\Documents\myStuff\CSF\BeatBattleAntiCheat\deploys\BBACPlugin
Remove-Item -Recurse -Force build_cmake -ErrorAction SilentlyContinue
```

### Step 2: Run CMake
```powershell
mkdir build_cmake
cd build_cmake
cmake ..
```

This will:
- Configure VST3 SDK
- Create ImGui static library
- Configure BBACPlugin to link everything

### Step 3: Build Release Version
```powershell
cmake --build . --config Release --target BBACPlugin
```

Or for Debug (with more error checking):
```powershell
cmake --build . --config Debug --target BBACPlugin
```

### Step 4: Find Your Plugin

The built plugin will be automatically copied to:
```
C:\Users\16514\AppData\Local\Programs\Common\VST3\BBACPlugin.vst3
```

### Step 5: Test in FL Studio

1. Open FL Studio
2. Add a new channel → VST → BBACPlugin
3. Click the "Show Editor" button
4. You should see the ImGui UI!

## Troubleshooting Build Errors

### Error: "Cannot find imgui files"
Make sure ImGui is at: `C:\Users\16514\Documents\myStuff\CSF\imgui`

Check with:
```powershell
Test-Path C:\Users\16514\Documents\myStuff\CSF\imgui\imgui.cpp
```

Should return `True`.

### Error: "Cannot find Python"
Update Python path in `CMakeLists.txt` if your Python is elsewhere:
```cmake
set(PYTHON_ROOT "C:/Users/16514/AppData/Local/Programs/Python/Python312")
```

### Error: "d3d11.lib not found"
Install Windows SDK if not already installed. CMake should find it automatically.

### Error: "VST3 SDK errors"
Make sure VST3 SDK is at: `C:\Users\16514\Documents\myStuff\CSF\VST_SDK\vst3sdk`

## What Gets Built

```
build_cmake/
├── BBACPlugin.dir/
│   └── Release/
│       ├── BBACPlugin.obj     (Your code compiled)
│       └── ...
├── imgui.dir/
│   └── Release/
│       ├── imgui.obj          (ImGui compiled)
│       ├── imgui_draw.obj
│       └── ...
└── Release/
    └── BBACPlugin.vst3        (Final plugin - copied to VST3 folder)
```

## File Sizes to Expect

After successful build:
- `BBACPlugin.vst3`: ~4-6 MB (includes ImGui statically)
- Build folder: ~200 MB (includes all intermediate files)

## Rebuild After Code Changes

### If you modified BBACPlugin.cpp or BBACPlugin.h:
```powershell
cd build_cmake
cmake --build . --config Release --target BBACPlugin
```

### If you modified CMakeLists.txt:
```powershell
cd build_cmake
cmake ..
cmake --build . --config Release --target BBACPlugin
```

### Full clean rebuild:
```powershell
Remove-Item -Recurse -Force build_cmake
mkdir build_cmake
cd build_cmake
cmake ..
cmake --build . --config Release --target BBACPlugin
```

## Development Tips

### Use Debug Build While Developing
```powershell
cmake --build . --config Debug --target BBACPlugin
```

Benefits:
- Easier to debug in Visual Studio
- Better error messages
- Python errors show more detail

### Use Release Build for Distribution
```powershell
cmake --build . --config Release --target BBACPlugin
```

Benefits:
- Smaller file size
- Faster performance
- Optimized code

## Visual Studio Integration (Optional)

### Open in Visual Studio:
```powershell
cd build_cmake
start BBACPlugin.sln
```

Then:
1. Set BBACPlugin as startup project (right-click → Set as Startup Project)
2. Build → Build Solution (Ctrl+Shift+B)
3. Or just hit F5 to build and debug

### Attach to FL Studio for Debugging:
1. Build Debug version
2. Start FL Studio manually
3. In Visual Studio: Debug → Attach to Process
4. Find FL Studio process
5. Load your plugin in FL Studio
6. Breakpoints in your code will now hit!

## Distribution Package

After building Release version, copy these files for distribution:

```
YourPlugin_v1.0/
├── BBACPlugin.vst3              (From VST3 folder)
├── python312.dll                (From Python\Python312\)
├── python312.zip                (From Python\Python312\ or Lib folder zipped)
└── BBAC2.py                     (Your Python script)
```

Users just copy to their VST3 folder:
```
C:\Program Files\Common Files\VST3\
```

## Build Times

Typical build times (Release mode):
- **First build**: 5-10 minutes (compiles everything including VST SDK, ImGui)
- **Incremental build** (after code change): 10-30 seconds
- **Full rebuild**: 5-10 minutes

## Success Indicators

Build succeeded if you see:
```
[100%] Built target BBACPlugin
```

Plugin installed if you see:
```
-- [SMTG] SMTG_PLUGIN_TARGET_PATH is set to: C:\Users\16514\AppData\Local\Programs\Common\VST3
```

Ready to test! 🎉
