# FL Studio Configuration & File System Research

## Table of Contents
1. [FL Studio Registry Findings](#fl-studio-registry-findings)
2. [Plugin Path Storage](#plugin-path-storage)
3. [Suggested Workarounds](#suggested-workarounds)
4. [Windows Command Reference](#windows-command-reference)
5. [Python Implementation](#python-implementation)
6. [C++ Implementation](#c-implementation)

---

## FL Studio Registry Findings

### Registry Location
```
HKEY_CURRENT_USER\Software\Image-Line\FL Studio 24\
```

### Key Variables Discovered

#### Project Paths
- **`LastProjectPath`** - Most recently opened project folder
  - Value: `C:\Users\16514\Documents\Image-Line\FL Studio\Projects\New\newnew\`
  - Type: `REG_SZ` (String)
  - Updates: Every time user opens a project

- **`NewProjectFolder`** - Default location for new projects
  - Value: `C:\Users\16514\Documents\Image-Line\FL Studio\Projects\New\newnew\`
  - Type: `REG_SZ` (String)
  - Updates: When user creates new project or changes default location

#### Sample Browser Search Paths
Located at: `HKCU\Software\Image-Line\FL Studio 24\Search paths\`

Stored as numbered entries (0, 1, 2, 3...):
```
0 = C:\Users\16514\Downloads\
1 = C:\Users\16514\Downloads\(@hshsmarian) kit ##ceolifestyle\
3 = C:\Users\16514\Documents\myStuff\musicMats\
4 = C:\Users\16514\Documents\myStuff\
5 = C:\Medal\Clips\Screen Recording\
```

#### Other Relevant Keys
- `AlwaysAskProjectFolder` - Whether FL prompts for project location
- `Browser search folders` - Enable/disable custom search paths
- `PluginScan` - Plugin scanning status flag

---

## Plugin Path Storage

### The Problem
FL Studio **does NOT store custom plugin paths in accessible registry or text files**.

### Where Plugins Are Actually Stored

#### Standard VST3 Locations (Hardcoded)
FL Studio automatically scans these Windows standard paths:
```
C:\Program Files\Common Files\VST3\
C:\Program Files\VSTPlugins\
C:\Program Files (x86)\VSTPlugins\
C:\Program Files\Steinberg\VSTPlugins\
```

#### Custom Plugin Paths (User-Added)
When users add custom plugin search paths in FL Studio (Options → File Settings → Manage plugins), these are stored in:

**Location:**
```
C:\Users\[Username]\Documents\Image-Line\FL Studio\Presets\Plugin database\
```

**Format:** Proprietary binary format (likely custom database or SQLite with encryption)

**Files Found:**
- `Plugin database\Installed\Effects\`
- `Plugin database\Installed\Generators\`
- Internal `.fst` or binary database files

**Accessibility:** ❌ **Not readable** without reverse engineering FL Studio's proprietary format

### Why This Matters
- Registry only shows **project paths** and **sample browser paths**
- Plugin paths are **intentionally obscured** in binary format
- No XML, JSON, or INI files for plugin configuration
- Can't programmatically detect where users have configured FL to scan for plugins

---

## Suggested Workarounds

### Option 1: Use Standard Windows VST Paths ✅ **Recommended**
**Install your plugin to standard locations:**
```
C:\Program Files\Common Files\VST3\YourPlugin.vst3
```

**Pros:**
- FL Studio automatically finds it
- No custom configuration needed
- Industry standard

**Cons:**
- Requires installer or admin rights

---

### Option 2: Read Available Registry Data
**Read what IS accessible:**
- Project folders (for monitoring `.flp` files)
- Sample browser paths (for sample management)
- Last opened project (for context awareness)

**Use Case Example:**
- Monitor `LastProjectPath` to know which project user is working on
- Watch that folder for file changes
- Scan sample browser paths for sample detection

---

### Option 3: User-Configured Paths in Your Plugin
**Let users set paths in YOUR plugin's GUI:**
```python
# Store in your own config file
user_config = {
    "plugin_install_path": "C:/MyPlugins/",
    "watched_project_folder": "C:/Projects/",
    "sample_library": "C:/Samples/"
}
```

**Pros:**
- Full control
- Portable across DAWs
- Can store additional metadata

**Cons:**
- User must configure manually

---

### Option 4: File System Search
**Scan the entire system for plugins:**
```python
import os

def find_vst3_plugins():
    search_paths = [
        "C:\\Program Files\\Common Files\\VST3\\",
        "C:\\Program Files\\VSTPlugins\\",
        # Add more paths
    ]

    plugins = []
    for path in search_paths:
        if os.path.exists(path):
            for root, dirs, files in os.walk(path):
                for file in files:
                    if file.endswith('.vst3'):
                        plugins.append(os.path.join(root, file))
    return plugins
```

**Pros:**
- Finds all plugins in standard locations
- No user configuration needed

**Cons:**
- Slow on large drives
- Doesn't find custom FL Studio paths

---

## Windows Command Reference

### Registry Query (`reg` command)

#### Basic Syntax
```cmd
reg query <KeyPath> [Options]
```

#### Common Options

| Option | Description | Example |
|--------|-------------|---------|
| `/v <ValueName>` | Query specific value | `reg query "HKCU\Software\Image-Line\FL Studio 24" /v LastProjectPath` |
| `/s` | Search all subkeys recursively | `reg query "HKCU\Software\Image-Line" /s` |
| `/f <SearchTerm>` | Find keys/values containing term | `reg query HKCU /s /f "FL Studio"` |
| `/k` | Search key names only | `reg query HKCU /s /f "VST" /k` |
| `/d` | Search data only | `reg query HKCU /s /f "C:\\" /d` |
| `/e` | Export to file | `reg export "HKCU\Software\Image-Line" output.reg` |

#### Registry Key Shortcuts

| Shortcut | Full Path |
|----------|-----------|
| `HKCU` | `HKEY_CURRENT_USER` |
| `HKLM` | `HKEY_LOCAL_MACHINE` |
| `HKCR` | `HKEY_CLASSES_ROOT` |
| `HKU` | `HKEY_USERS` |
| `HKCC` | `HKEY_CURRENT_CONFIG` |

#### Examples

**Query single value:**
```cmd
reg query "HKCU\Software\Image-Line\FL Studio 24" /v LastProjectPath
```

**Search entire registry for term:**
```cmd
reg query HKCU /s /f "sample" /d
```

**Export registry key to file:**
```cmd
reg export "HKCU\Software\Image-Line\FL Studio 24" fl_studio_config.reg
```

---

### PowerShell Get-ChildItem

#### Basic Syntax
```powershell
Get-ChildItem [Path] [Options]
```

#### Common Options

| Option | Alias | Description | Example |
|--------|-------|-------------|---------|
| `-Path` | | Specify directory path | `Get-ChildItem -Path "C:\Users"` |
| `-Filter` | | Filter by pattern (fast) | `Get-ChildItem -Filter "*.py"` |
| `-Include` | | Include pattern (with Recurse) | `Get-ChildItem -Include "*.wav"` |
| `-Exclude` | | Exclude pattern | `Get-ChildItem -Exclude "temp*"` |
| `-Recurse` | `-r` | Search subdirectories | `Get-ChildItem -Recurse` |
| `-File` | | Files only | `Get-ChildItem -File` |
| `-Directory` | | Directories only | `Get-ChildItem -Directory` |
| `-Hidden` | | Include hidden items | `Get-ChildItem -Hidden` |
| `-Force` | | Include system files | `Get-ChildItem -Force` |
| `-Depth` | | Limit recursion depth | `Get-ChildItem -Recurse -Depth 2` |
| `-ErrorAction` | | Handle errors | `Get-ChildItem -ErrorAction SilentlyContinue` |

#### Property Selection

```powershell
# Select specific properties
Get-ChildItem | Select-Object Name, Length, LastWriteTime

# Select first N items
Get-ChildItem | Select-Object -First 10

# Expand property value
Get-ChildItem | Select-Object -ExpandProperty FullName
```

#### Filtering and Where-Object

```powershell
# Filter by extension
Get-ChildItem | Where-Object { $_.Extension -eq ".py" }

# Filter by size
Get-ChildItem | Where-Object { $_.Length -gt 1MB }

# Filter by date
Get-ChildItem | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }

# Multiple conditions
Get-ChildItem | Where-Object { $_.Extension -eq ".wav" -and $_.Length -lt 10MB }
```

#### Examples

**Find all Python files recursively:**
```powershell
Get-ChildItem -Path C:\Projects -Filter "*.py" -Recurse
```

**Find all files modified in last 7 days:**
```powershell
Get-ChildItem -Recurse | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }
```

**Find large files (>100MB):**
```powershell
Get-ChildItem -Recurse -File | Where-Object { $_.Length -gt 100MB }
```

**Find directories matching pattern:**
```powershell
Get-ChildItem -Directory -Filter "*FL*" -Recurse
```

**Count files by extension:**
```powershell
Get-ChildItem -Recurse -File | Group-Object Extension | Select-Object Name, Count
```

**Export file list to CSV:**
```powershell
Get-ChildItem -Recurse | Select-Object Name, FullName, Length | Export-Csv files.csv
```

---

## Python Implementation

### Reading Windows Registry

```python
import winreg
from typing import Optional, List, Dict

class FLStudioConfig:
    """Read FL Studio configuration from Windows Registry"""

    def __init__(self, version: str = "24"):
        self.registry_path = rf"Software\Image-Line\FL Studio {version}"
        self.search_paths_key = rf"{self.registry_path}\Search paths"

    def read_registry_value(self, value_name: str) -> Optional[str]:
        """Read a single registry value"""
        try:
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, self.registry_path)
            value, _ = winreg.QueryValueEx(key, value_name)
            winreg.CloseKey(key)
            return value
        except FileNotFoundError:
            print(f"Registry key not found: {self.registry_path}")
            return None
        except Exception as e:
            print(f"Error reading registry: {e}")
            return None

    def get_last_project_path(self) -> Optional[str]:
        """Get the last opened project folder"""
        return self.read_registry_value("LastProjectPath")

    def get_new_project_folder(self) -> Optional[str]:
        """Get the default new project folder"""
        return self.read_registry_value("NewProjectFolder")

    def get_search_paths(self) -> List[str]:
        """Get all sample browser search paths"""
        paths = []
        try:
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, self.search_paths_key)
            index = 0

            while True:
                try:
                    value_name = str(index)
                    value, _ = winreg.QueryValueEx(key, value_name)
                    if value:  # Skip empty values
                        paths.append(value)
                    index += 1
                except FileNotFoundError:
                    break
                except Exception:
                    index += 1
                    if index > 100:  # Safety limit
                        break

            winreg.CloseKey(key)
        except FileNotFoundError:
            print(f"Search paths key not found: {self.search_paths_key}")
        except Exception as e:
            print(f"Error reading search paths: {e}")

        return paths

    def get_all_config(self) -> Dict[str, any]:
        """Get all FL Studio configuration as dictionary"""
        return {
            "last_project_path": self.get_last_project_path(),
            "new_project_folder": self.get_new_project_folder(),
            "search_paths": self.get_search_paths()
        }

# Usage Example
if __name__ == "__main__":
    fl_config = FLStudioConfig(version="24")

    # Get individual values
    last_project = fl_config.get_last_project_path()
    print(f"Last Project: {last_project}")

    new_project = fl_config.get_new_project_folder()
    print(f"New Project Folder: {new_project}")

    # Get all search paths
    search_paths = fl_config.get_search_paths()
    print(f"\nSample Browser Search Paths ({len(search_paths)}):")
    for i, path in enumerate(search_paths):
        print(f"  {i}: {path}")

    # Get everything
    config = fl_config.get_all_config()
    print(f"\nFull Config: {config}")
```

### Finding VST3 Plugins

```python
import os
from pathlib import Path
from typing import List

class VST3Scanner:
    """Scan for VST3 plugins in standard Windows locations"""

    STANDARD_PATHS = [
        r"C:\Program Files\Common Files\VST3",
        r"C:\Program Files\VSTPlugins",
        r"C:\Program Files (x86)\VSTPlugins",
        r"C:\Program Files\Steinberg\VSTPlugins"
    ]

    def __init__(self, custom_paths: List[str] = None):
        self.search_paths = self.STANDARD_PATHS.copy()
        if custom_paths:
            self.search_paths.extend(custom_paths)

    def scan_for_plugins(self) -> List[Dict[str, str]]:
        """Scan all paths and return list of VST3 plugins"""
        plugins = []

        for search_path in self.search_paths:
            if not os.path.exists(search_path):
                continue

            for root, dirs, files in os.walk(search_path):
                for file in files:
                    if file.endswith('.vst3'):
                        full_path = os.path.join(root, file)
                        plugins.append({
                            'name': file,
                            'path': full_path,
                            'folder': os.path.dirname(full_path)
                        })

        return plugins

    def find_plugin_by_name(self, plugin_name: str) -> Optional[str]:
        """Find a specific plugin by name"""
        plugins = self.scan_for_plugins()
        for plugin in plugins:
            if plugin_name.lower() in plugin['name'].lower():
                return plugin['path']
        return None

# Usage Example
if __name__ == "__main__":
    scanner = VST3Scanner()

    plugins = scanner.scan_for_plugins()
    print(f"Found {len(plugins)} VST3 plugins:")

    for plugin in plugins[:10]:  # Show first 10
        print(f"  - {plugin['name']}")
        print(f"    Path: {plugin['path']}")
```

### Complete FL Studio Monitor Example

```python
import os
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class FLStudioProjectMonitor:
    """Monitor FL Studio project folder for changes"""

    def __init__(self):
        self.fl_config = FLStudioConfig()
        self.project_folder = self.fl_config.get_last_project_path()
        self.observer = None

    def start_monitoring(self):
        """Start monitoring the project folder"""
        if not self.project_folder or not os.path.exists(self.project_folder):
            print(f"Project folder not found: {self.project_folder}")
            return

        event_handler = ProjectEventHandler()
        self.observer = Observer()
        self.observer.schedule(event_handler, self.project_folder, recursive=True)
        self.observer.start()

        print(f"Monitoring: {self.project_folder}")

        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            self.stop_monitoring()

    def stop_monitoring(self):
        """Stop monitoring"""
        if self.observer:
            self.observer.stop()
            self.observer.join()

class ProjectEventHandler(FileSystemEventHandler):
    """Handle file system events"""

    def on_created(self, event):
        if event.src_path.endswith('.flp'):
            print(f"New project created: {event.src_path}")

    def on_modified(self, event):
        if event.src_path.endswith('.flp'):
            print(f"Project modified: {event.src_path}")

    def on_deleted(self, event):
        if event.src_path.endswith('.flp'):
            print(f"Project deleted: {event.src_path}")

# Usage
if __name__ == "__main__":
    monitor = FLStudioProjectMonitor()
    monitor.start_monitoring()
```

### File System Search Utilities

```python
from pathlib import Path
from typing import List, Optional
import os

def find_files(directory: str, pattern: str = "*", recursive: bool = True) -> List[str]:
    """Find files matching pattern"""
    path = Path(directory)

    if recursive:
        return [str(p) for p in path.rglob(pattern)]
    else:
        return [str(p) for p in path.glob(pattern)]

def find_wav_files(directory: str) -> List[str]:
    """Find all WAV files in directory"""
    return find_files(directory, "*.wav", recursive=True)

def find_flp_projects(directory: str) -> List[str]:
    """Find all FL Studio projects"""
    return find_files(directory, "*.flp", recursive=True)

def get_file_info(filepath: str) -> dict:
    """Get detailed file information"""
    stat = os.stat(filepath)
    return {
        'path': filepath,
        'name': os.path.basename(filepath),
        'size': stat.st_size,
        'modified': stat.st_mtime,
        'created': stat.st_ctime
    }

# Usage Example
if __name__ == "__main__":
    # Find all WAV files
    wav_files = find_wav_files(r"C:\Users\16514\Documents\myStuff\musicMats")
    print(f"Found {len(wav_files)} WAV files")

    # Find FL Studio projects
    projects = find_flp_projects(r"C:\Users\16514\Documents\Image-Line\FL Studio\Projects")
    print(f"Found {len(projects)} FL Studio projects")

    # Get file info
    if projects:
        info = get_file_info(projects[0])
        print(f"Project info: {info}")
```

---

## C++ Implementation

### Reading Windows Registry

```cpp
#include <windows.h>
#include <string>
#include <vector>
#include <iostream>

class FLStudioConfig
{
public:
    FLStudioConfig(const std::string& version = "24")
    {
        registryPath = "Software\\Image-Line\\FL Studio " + version;
        searchPathsKey = registryPath + "\\Search paths";
    }

    std::string readRegistryValue(const std::string& valueName)
    {
        HKEY hKey;
        char buffer[512];
        DWORD bufferSize = sizeof(buffer);

        if (RegOpenKeyExA(HKEY_CURRENT_USER, registryPath.c_str(), 
                         0, KEY_READ, &hKey) == ERROR_SUCCESS)
        {
            if (RegQueryValueExA(hKey, valueName.c_str(), NULL, NULL, 
                               (LPBYTE)buffer, &bufferSize) == ERROR_SUCCESS)
            {
                RegCloseKey(hKey);
                return std::string(buffer);
            }
            RegCloseKey(hKey);
        }

        return "";
    }

    std::string getLastProjectPath()
    {
        return readRegistryValue("LastProjectPath");
    }

    std::string getNewProjectFolder()
    {
        return readRegistryValue("NewProjectFolder");
    }

    std::vector<std::string> getSearchPaths()
    {
        std::vector<std::string> paths;
        HKEY hKey;

        if (RegOpenKeyExA(HKEY_CURRENT_USER, searchPathsKey.c_str(), 
                         0, KEY_READ, &hKey) == ERROR_SUCCESS)
        {
            char valueName[16];
            char buffer[512];
            DWORD bufferSize;
            int index = 0;

            while (true)
            {
                sprintf_s(valueName, "%d", index);
                bufferSize = sizeof(buffer);

                if (RegQueryValueExA(hKey, valueName, NULL, NULL, 
                                   (LPBYTE)buffer, &bufferSize) != ERROR_SUCCESS)
                    break;

                if (strlen(buffer) > 0)
                    paths.push_back(std::string(buffer));

                index++;

                if (index > 100) break; // Safety limit
            }

            RegCloseKey(hKey);
        }

        return paths;
    }

private:
    std::string registryPath;
    std::string searchPathsKey;
};

// Usage Example
int main()
{
    FLStudioConfig config("24");

    std::string lastProject = config.getLastProjectPath();
    std::cout << "Last Project: " << lastProject << std::endl;

    std::string newProject = config.getNewProjectFolder();
    std::cout << "New Project Folder: " << newProject << std::endl;

    std::vector<std::string> searchPaths = config.getSearchPaths();
    std::cout << "\nSample Browser Search Paths (" << searchPaths.size() << "):" << std::endl;

    for (size_t i = 0; i < searchPaths.size(); i++)
    {
        std::cout << "  " << i << ": " << searchPaths[i] << std::endl;
    }

    return 0;
}
```

### Finding VST3 Plugins

```cpp
#include <filesystem>
#include <vector>
#include <string>
#include <iostream>

namespace fs = std::filesystem;

class VST3Scanner
{
public:
    VST3Scanner()
    {
        standardPaths = {
            "C:\\Program Files\\Common Files\\VST3",
            "C:\\Program Files\\VSTPlugins",
            "C:\\Program Files (x86)\\VSTPlugins",
            "C:\\Program Files\\Steinberg\\VSTPlugins"
        };
    }

    struct PluginInfo
    {
        std::string name;
        std::string path;
        std::string folder;
    };

    std::vector<PluginInfo> scanForPlugins()
    {
        std::vector<PluginInfo> plugins;

        for (const auto& searchPath : standardPaths)
        {
            if (!fs::exists(searchPath))
                continue;

            for (const auto& entry : fs::recursive_directory_iterator(searchPath))
            {
                if (entry.path().extension() == ".vst3")
                {
                    PluginInfo plugin;
                    plugin.name = entry.path().filename().string();
                    plugin.path = entry.path().string();
                    plugin.folder = entry.path().parent_path().string();
                    plugins.push_back(plugin);
                }
            }
        }

        return plugins;
    }

    std::string findPluginByName(const std::string& pluginName)
    {
        auto plugins = scanForPlugins();

        for (const auto& plugin : plugins)
        {
            if (plugin.name.find(pluginName) != std::string::npos)
                return plugin.path;
        }

        return "";
    }

private:
    std::vector<std::string> standardPaths;
};

// Usage Example
int main()
{
    VST3Scanner scanner;

    auto plugins = scanner.scanForPlugins();
    std::cout << "Found " << plugins.size() << " VST3 plugins:" << std::endl;

    for (size_t i = 0; i < std::min(plugins.size(), size_t(10)); i++)
    {
        std::cout << "  - " << plugins[i].name << std::endl;
        std::cout << "    Path: " << plugins[i].path << std::endl;
    }

    return 0;
}
```

---

## Summary

### What We Can Access ✅
- FL Studio project paths (registry)
- Sample browser search paths (registry)
- Standard VST3 installation locations (file system)
- Project files (.flp) in known directories

### What We Cannot Access ❌
- Custom user-added plugin search paths (proprietary binary)
- FL Studio's internal plugin database (encrypted/binary)
- Plugin-specific metadata without reverse engineering

### Recommended Approach
1. **Read accessible registry data** for project/sample paths
2. **Monitor standard VST3 locations** for plugin detection
3. **Let users configure** custom paths in your application
4. **Watch project folders** for .flp file changes
5. **Store your own metadata** in JSON/XML for flexibility

---

**Good night! Great progress today on understanding FL Studio's architecture!** 🚀

## FL API RENAMING BUSTER
When the hint message displays start render, the plugin will press the enter key and keygen - clunky but best.
When the hint message displays abort render the plugin will keygen - forces user to keep mouse hovered on the start render button - clunky
Stenography probably the best bet for this but would be very complex to be checked on the website. - clunky
When the hint message displays start render, and the left mouse button is clicked the plugin will keygen
if it detects abort render and click it will throw out that keygen - ding ding ding. use pynput.

## Other DAWS to anti cheat
-ardour (the free one)
-logic (big problem)
-ableton
-reaper

___

v3, watch project file and audio export folder, only append keygen if a) there are no other daws running/no duplicate daws. 
b) the last window clicked was associated with the proper daw, and c) parsed project file filepaths are all to valid samples or renders of valid samples.

---

## DAW API Comparison

This section compares the APIs and capabilities of major DAWs for implementing the Beat Battle Anti-Cheat system.

### Complete DAW Feature Matrix

| DAW | API Type | Export Detection | Sample Extraction | Auto-Signing Possible? | Rating |
|-----|----------|------------------|-------------------|------------------------|--------|
| **Reaper** | Python/Lua (ReaScript) | ✅ Direct hooks | ✅ Full access | ✅ YES | ⭐⭐⭐⭐⭐ |
| **Ardour** | Lua scripting | ✅ Export status | ✅ XML access | ✅ YES | ⭐⭐⭐⭐ |
| **Tracktion Waveform** | C++ Engine API | ✅ Callbacks | ✅ Engine API | ✅ YES | ⭐⭐⭐⭐ |
| **Ableton Live** | Python (limited) | ❌ None | ⚠️ Fragile | ❌ NO | ⭐⭐ |
| **FL Studio** | None | ❌ None | ⚠️ Binary | ❌ NO | ⭐⭐ |
| **Logic Pro** | AppleScript (basic) | ❌ None | ❌ Proprietary | ❌ NO | ⭐ |
| **Pro Tools** | None | ❌ None | ✅ XML (offline) | ❌ NO | ⭐ |

---

### Tier 1: Full Automation (Recommended) 🟢

These DAWs support complete automatic render detection and signing without user intervention.

#### **Reaper** - ⭐⭐⭐⭐⭐ BEST CHOICE

**API Type:** ReaScript (Python/Lua/EEL)

**Capabilities:**
- ✅ Direct render start/complete callbacks
- ✅ Access to project file path
- ✅ Access to render destination and filename
- ✅ Full track and sample information
- ✅ Can create pre/post-render hooks

**Implementation Method:**
```python
# ReaScript automatically detects render events
def OnExportBegin():
    create_signature_file(project_path, session_key)

def OnExportEnd():
    embed_signature_in_wav(render_path, session_key)
```

**User Experience:** Install ReaScript → Render normally → Automatic signing

**Cost:** $60 (60-day full-featured trial)

---

#### **Ardour** - ⭐⭐⭐⭐ EXCELLENT FREE OPTION

**API Type:** Lua scripting

**Capabilities:**
- ✅ Export status monitoring
- ✅ Session file access (XML format)
- ✅ Export handler callbacks
- ✅ Complete sample path extraction
- ✅ Can inject metadata into session files

**Implementation Method:**
```lua
-- Lua script monitors export status
function factory()
    return function()
        if session:export_status() == ARDOUR.ExportStatus.Running then
            create_signature()
        end
    end
end
```

**User Experience:** Install Lua script → Render normally → Automatic signing

**Cost:** 100% Free and Open Source

---

#### **Tracktion Waveform** - ⭐⭐⭐⭐ DEVELOPER-FRIENDLY

**API Type:** C++ Engine API

**Capabilities:**
- ✅ Full C++ SDK with export callbacks
- ✅ Direct access to edit/project state
- ✅ Complete render job management
- ✅ Modern codebase with documentation
- ✅ Can build custom plugins that hook renders

**Implementation Method:**
```cpp
// C++ listener hooks into render events
class BBACExportListener : public RenderManager::Job::Listener {
    void jobStarted(RenderManager::Job& job) override {
        createSignatureFile(job.getEdit()->getEditFile());
    }
    void jobFinished(RenderManager::Job& job, bool ok) override {
        signWavFile(job.getOutputFile());
    }
};
```

**User Experience:** Install plugin → Render normally → Automatic signing

**Cost:** Free version available (Waveform Free)

---

### Tier 2: Semi-Automatic (Workarounds Required) 🟡

These DAWs require file system monitoring and user confirmation.

#### **Ableton Live** - ⭐⭐ LIMITED API

**API Type:** Python Control Surface (limited)

**Capabilities:**
- ⚠️ Can monitor playback/track state
- ⚠️ Can read project path (via hack)
- ⚠️ Limited sample path access (clips only)
- ❌ No export detection callbacks
- ❌ Cannot detect when user clicks "Export Audio/Video"

**Implementation Method:**
```python
# Control Surface + external file watcher
class BBACMonitor(ControlSurface):
    # Monitor project saves, not exports
    def on_data_change(self):
        if project_was_saved():
            prepare_for_possible_export()

# Separate file watcher detects new audio files
# User must confirm which project created the export
```

**User Experience:** Install control surface → Render → Click notification to confirm project

**Cost:** Ableton Live Lite (free with hardware) to Suite ($749)

**Limitations:** Cannot auto-link exports to projects; requires user confirmation

---

#### **FL Studio** - ⭐⭐ NO API, CREATIVE WORKAROUNDS

**API Type:** None

**Capabilities:**
- ❌ No scripting API
- ❌ No export callbacks
- ❌ Project file format is proprietary binary
- ⚠️ Can monitor registry for project paths
- ⚠️ Can watch file system for new WAV files

**Implementation Method:**
```python
# Mouse position monitoring + file watcher
# Detect when user hovers over "Start rendering" button
# Watch for new audio files in monitored folders
# Ask user to confirm which project created the render
```

**User Experience:** Run background monitor → Click notification after render → Confirm project

**Cost:** $99 (Fruity) to $499 (All Plugins Bundle)

**Limitations:** Highly dependent on user cooperation; vulnerable to rename attacks without careful implementation

---

### Tier 3: Manual Only (No Real-Time API) 🔴

These DAWs require completely manual workflows in the web application.

#### **Logic Pro** - ⭐ APPLE LOCKDOWN

**API Type:** AppleScript (transport control only)

**Capabilities:**
- ⚠️ Can control play/stop/record via AppleScript
- ❌ No bounce/export detection
- ❌ No project file access via API
- ❌ .logicx format is proprietary package
- ❌ No render callbacks or hooks
- ❌ Audio Units are sandboxed (no DAW access)

**Implementation Method:**
```python
# File system watcher only
# User bounces wherever they want
# System detects new audio files
# User manually selects which project created it
```

**User Experience:** Bounce in Logic → Open web app → Manually select project + bounce files → Sign

**Cost:** $199 (macOS only)

**Limitations:** No automation possible; completely manual linking required

---

#### **Pro Tools** - ⭐ MOST LOCKED DOWN

**API Type:** None

**Capabilities:**
- ❌ No scripting API whatsoever
- ❌ No export detection possible
- ❌ AAX plugins cannot access session state
- ❌ EUCON protocol is for hardware controllers only
- ✅ Session files (.ptx) are readable XML (after save)

**Implementation Method:**
```python
# Post-export verification only
# User exports in Pro Tools
# User uploads session + export to web app
# System parses .ptx XML to verify samples
```

**User Experience:** Export in Pro Tools → Open web app → Upload session + audio files → Verify

**Cost:** $99/month subscription or $599+ perpetual

**Limitations:** No real-time monitoring; can only verify after-the-fact; manual workflow only

---

### Support Tier Recommendations

#### **Priority 1: Implement Full Automation**
Focus development on DAWs with complete APIs:
- **Reaper** (Best API, worth $60 investment for testing)
- **Ardour** (Free, excellent API)
- **Tracktion Waveform** (Free version, good C++ API)

**Benefits:**
- Prove the concept works perfectly
- Build user confidence in the system
- Create reference implementation for other DAWs

---

#### **Priority 2: Implement Semi-Auto Workflows**
Add workarounds for popular DAWs:
- **FL Studio** (Most popular for beat battles)
- **Ableton Live** (Popular for electronic music)

**Implementation:**
- File system monitoring
- User confirmation dialogs
- Mouse position detection (FL Studio)
- Registry monitoring (FL Studio)

**Benefits:**
- Cover majority of beat makers
- Acceptable user experience with one extra click
- Still prevents most cheating scenarios

---

#### **Priority 3: Manual Workflow for All Others**
Provide web-based manual signing for:
- **Logic Pro**
- **Pro Tools**
- **Studio One**
- **Cubase**
- **Bitwig**
- **Any other DAW**

**Implementation:**
```python
class ManualSigningWorkflow:
    def sign_submission(self):
        project_file = user_selects_project()
        audio_file = user_selects_audio()

        # Generate signature
        session_key = generate_key()

        # Embed in audio
        embed_signature(audio_file, session_key)

        # Create .bbac signature file
        create_signature_file(project_file, session_key)
```

**User Experience:**
1. User renders in any DAW
2. User opens BBAC web app
3. User selects project file
4. User selects rendered audio
5. System signs both files
6. User uploads to competition

**Benefits:**
- Works with every DAW
- Simple implementation
- Still provides cryptographic verification
- Prevents rename attacks via steganography

---

### Summary: Best Path Forward

```python
# Recommended implementation strategy
class BBACDAWSupport:
    TIER_1 = ['Reaper', 'Ardour', 'Tracktion']     # Full auto
    TIER_2 = ['FL Studio', 'Ableton Live']          # Semi-auto
    TIER_3 = ['Logic', 'Pro Tools', '*']            # Manual

    def get_support_level(self, daw_name):
        if daw_name in self.TIER_1:
            return "Full automation - install script and render"
        elif daw_name in self.TIER_2:
            return "Semi-automatic - one confirmation click"
        else:
            return "Manual workflow - upload via web app"
```

**Development Timeline:**
1. **Week 1-2:** Build Reaper ReaScript (proof of concept)
2. **Week 3:** Add FL Studio mouse hooks + file watcher
3. **Week 4:** Build manual web workflow (covers all DAWs)
4. **Week 5+:** Add Ardour, Ableton, others as time permits

**Result:** A system that works perfectly for some DAWs, acceptably for popular DAWs, and universally via manual workflow.

---

**Good night! Sleep well - you've got a solid roadmap now!** 🌙🎵
