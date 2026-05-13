; =====================================================
; BeatBattle AntiCheat - NSIS Installer Script
; =====================================================
; This installer will:
; - Let user choose main install location
; - Auto-detect VST3 path (with option to customize)
; - Install the configuration app
; - Install the VST3 plugin
; - Create shortcuts
; - Launch config app after installation
; =====================================================

; Include Modern UI
!include "MUI2.nsh"
!include "x64.nsh"
!include "FileFunc.nsh"

; =====================================================
; INSTALLER INFORMATION
; =====================================================
Name "BeatBattle AntiCheat"
OutFile "..\deploys\BBAC_Installer.exe"  ; Where the compiled installer will be saved
InstallDir "$PROGRAMFILES\BeatBattleAntiCheat"  ; Default install location
InstallDirRegKey HKCU "Software\BeatBattleAntiCheat" "InstallDir"  ; Remember install location
RequestExecutionLevel admin  ; Require admin for Program Files installation

; Branding
BrandingText "BeatBattle AntiCheat Installer"
; Icon "..\assets\icon.ico"  ; UNCOMMENT when you have an icon file

; =====================================================
; VARIABLES
; =====================================================
Var VST3Path          ; Will hold the VST3 installation path
Var VST3PathCtrl      ; Control for VST3 path input box
Var VST3BrowseBtn     ; Control for VST3 browse button

Var ConfigPath        ; Will hold the Config Manager installation path
Var ConfigPathCtrl    ; Control for Config Manager path input box
Var ConfigBrowseBtn   ; Control for Config Manager browse button

Var AutoLocPath       ; Will hold the autoLocPacks installation path
Var AutoLocPathCtrl   ; Control for autoLocPacks path input box
Var AutoLocBrowseBtn  ; Control for autoLocPacks browse button

; =====================================================
; MODERN UI CONFIGURATION
; =====================================================
!define MUI_ABORTWARNING  ; Warn user if they try to cancel
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page customization
!define MUI_WELCOMEPAGE_TITLE "Welcome to BeatBattle AntiCheat Setup"
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation.$\r$\n$\r$\nClick Next to continue."

; Finish page customization
!define MUI_FINISHPAGE_RUN "$ConfigPath\BBAC_Config.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch BeatBattle AntiCheat Configuration"
!define MUI_FINISHPAGE_SHOWREADME ""
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED

; =====================================================
; INSTALLER PAGES
; =====================================================
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\LICENSE.txt"  ; PLACE YOUR LICENSE FILE AT: BeatBattleAntiCheat/LICENSE.txt
!insertmacro MUI_PAGE_DIRECTORY  ; Let user choose main install directory

; Custom pages for component path selection
Page custom VST3PathPage VST3PathPageLeave
Page custom ConfigPathPage ConfigPathPageLeave
Page custom AutoLocPathPage AutoLocPathPageLeave

!insertmacro MUI_PAGE_INSTFILES  ; Show installation progress
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; =====================================================
; LANGUAGES
; =====================================================
!insertmacro MUI_LANGUAGE "English"

; =====================================================
; INSTALLER INITIALIZATION
; =====================================================
Function .onInit
    ; Detect if running on 64-bit system
    ${If} ${RunningX64}
        ; 64-bit system - use 64-bit Common Files
        StrCpy $VST3Path "$COMMONFILES64\VST3"
    ${Else}
        ; 32-bit system - use 32-bit Common Files
        StrCpy $VST3Path "$COMMONFILES\VST3"
    ${EndIf}

    ; Check if VST3 path actually exists, if not use fallback
    ${IfNot} ${FileExists} "$VST3Path\*.*"
        StrCpy $VST3Path "$PROGRAMFILES\Common Files\VST3"
    ${EndIf}

    ; Initialize Config Manager path to main install directory
    StrCpy $ConfigPath "$INSTDIR"

    ; Initialize autoLocPacks path to main install directory
    StrCpy $AutoLocPath "$INSTDIR"

    ; You can add more initialization here
    ; Example: Check if already installed, etc.
FunctionEnd

; =====================================================
; CUSTOM PAGE: VST3 PATH SELECTION
; =====================================================
Function VST3PathPage
    !insertmacro MUI_HEADER_TEXT "VST3 Plugin Location" "Choose where to install the VST3 plugin"

    nsDialogs::Create 1018
    Pop $0

    ; Label
    ${NSD_CreateLabel} 0 0 100% 24u "The installer has detected your VST3 folder.$\r$\nYou can change it if needed.$\r$\n$\r$\nVST3 plugins will be installed to:"
    Pop $0

    ; Directory input box
    ${NSD_CreateDirRequest} 0 40u 75% 12u "$VST3Path"
    Pop $VST3PathCtrl

    ; Browse button
    ${NSD_CreateBrowseButton} 76% 40u 24% 12u "Browse..."
    Pop $VST3BrowseBtn
    ${NSD_OnClick} $VST3BrowseBtn BrowseVST3Path

    ; Info text
    ${NSD_CreateLabel} 0 60u 100% 40u "Note: Most DAWs expect VST3 plugins in this location.$\r$\nFL Studio, Ableton, Reaper, and others scan this folder automatically.$\r$\n$\r$\nOnly change this if you know what you're doing."
    Pop $0

    nsDialogs::Show
FunctionEnd

; Browse button click handler
Function BrowseVST3Path
    ; Get current path
    ${NSD_GetText} $VST3PathCtrl $VST3Path

    ; Show folder selection dialog
    nsDialogs::SelectFolderDialog "Select VST3 Installation Folder" "$VST3Path"
    Pop $VST3Path

    ; If user didn't cancel, update the text box
    ${If} $VST3Path != "error"
        ${NSD_SetText} $VST3PathCtrl $VST3Path
    ${EndIf}
FunctionEnd

; Save the selected VST3 path when leaving the page
Function VST3PathPageLeave
    ${NSD_GetText} $VST3PathCtrl $VST3Path

    ; Validate path exists or can be created
    ${IfNot} ${FileExists} "$VST3Path\*.*"
        MessageBox MB_YESNO "The folder '$VST3Path' does not exist.$\r$\nDo you want to create it?" IDYES CreateVST3Dir
        Abort  ; Stay on page if user clicks No

        CreateVST3Dir:
        CreateDirectory "$VST3Path"
        ${IfNot} ${FileExists} "$VST3Path\*.*"
            MessageBox MB_OK|MB_ICONSTOP "Failed to create folder '$VST3Path'.$\r$\nPlease choose a different location."
            Abort
        ${EndIf}
    ${EndIf}
FunctionEnd

; =====================================================
; CUSTOM PAGE: CONFIG MANAGER PATH SELECTION
; =====================================================
Function ConfigPathPage
    !insertmacro MUI_HEADER_TEXT "Config Manager Location" "Choose where to install the Configuration Manager"

    nsDialogs::Create 1018
    Pop $0

    ; Label
    ${NSD_CreateLabel} 0 0 100% 36u "The Configuration Manager allows you to configure DAW paths, sample locations, and server settings.$\r$\n$\r$\nIt will be installed to the main program directory by default, but you can change this.$\r$\n$\r$\nInstall Configuration Manager to:"
    Pop $0

    ; Directory input box
    ${NSD_CreateDirRequest} 0 50u 75% 12u "$ConfigPath"
    Pop $ConfigPathCtrl

    ; Browse button
    ${NSD_CreateBrowseButton} 76% 50u 24% 12u "Browse..."
    Pop $ConfigBrowseBtn
    ${NSD_OnClick} $ConfigBrowseBtn BrowseConfigPath

    ; Info text
    ${NSD_CreateLabel} 0 70u 100% 30u "Note: You can launch this anytime from the Start Menu to reconfigure your settings.$\r$\n$\r$\nRecommended: Keep the default location."
    Pop $0

    nsDialogs::Show
FunctionEnd

; Browse button click handler for Config Manager
Function BrowseConfigPath
    ${NSD_GetText} $ConfigPathCtrl $ConfigPath
    nsDialogs::SelectFolderDialog "Select Configuration Manager Installation Folder" "$ConfigPath"
    Pop $ConfigPath
    ${If} $ConfigPath != "error"
        ${NSD_SetText} $ConfigPathCtrl $ConfigPath
    ${EndIf}
FunctionEnd

; Save the selected Config path when leaving the page
Function ConfigPathPageLeave
    ${NSD_GetText} $ConfigPathCtrl $ConfigPath

    ; Validate path exists or can be created
    ${IfNot} ${FileExists} "$ConfigPath\*.*"
        MessageBox MB_YESNO "The folder '$ConfigPath' does not exist.$\r$\nDo you want to create it?" IDYES CreateConfigDir
        Abort

        CreateConfigDir:
        CreateDirectory "$ConfigPath"
        ${IfNot} ${FileExists} "$ConfigPath\*.*"
            MessageBox MB_OK|MB_ICONSTOP "Failed to create folder '$ConfigPath'.$\r$\nPlease choose a different location."
            Abort
        ${EndIf}
    ${EndIf}
FunctionEnd

; =====================================================
; CUSTOM PAGE: AUTOLOCPACKS PATH SELECTION
; =====================================================
Function AutoLocPathPage
    !insertmacro MUI_HEADER_TEXT "AutoLocPacks Location" "Choose where to install AutoLocPacks"

    nsDialogs::Create 1018
    Pop $0

    ; Label
    ${NSD_CreateLabel} 0 0 100% 36u "AutoLocPacks automatically detects and monitors sample pack locations in your DAW.$\r$\n$\r$\nIt will be installed to the main program directory by default, but you can change this.$\r$\n$\r$\nInstall AutoLocPacks to:"
    Pop $0

    ; Directory input box
    ${NSD_CreateDirRequest} 0 50u 75% 12u "$AutoLocPath"
    Pop $AutoLocPathCtrl

    ; Browse button
    ${NSD_CreateBrowseButton} 76% 50u 24% 12u "Browse..."
    Pop $AutoLocBrowseBtn
    ${NSD_OnClick} $AutoLocBrowseBtn BrowseAutoLocPath

    ; Info text
    ${NSD_CreateLabel} 0 70u 100% 30u "Note: This component runs in the background to detect sample pack usage.$\r$\n$\r$\nRecommended: Keep the default location."
    Pop $0

    nsDialogs::Show
FunctionEnd

; Browse button click handler for AutoLocPacks
Function BrowseAutoLocPath
    ${NSD_GetText} $AutoLocPathCtrl $AutoLocPath
    nsDialogs::SelectFolderDialog "Select AutoLocPacks Installation Folder" "$AutoLocPath"
    Pop $AutoLocPath
    ${If} $AutoLocPath != "error"
        ${NSD_SetText} $AutoLocPathCtrl $AutoLocPath
    ${EndIf}
FunctionEnd

; Save the selected AutoLocPacks path when leaving the page
Function AutoLocPathPageLeave
    ${NSD_GetText} $AutoLocPathCtrl $AutoLocPath

    ; Validate path exists or can be created
    ${IfNot} ${FileExists} "$AutoLocPath\*.*"
        MessageBox MB_YESNO "The folder '$AutoLocPath' does not exist.$\r$\nDo you want to create it?" IDYES CreateAutoLocDir
        Abort

        CreateAutoLocDir:
        CreateDirectory "$AutoLocPath"
        ${IfNot} ${FileExists} "$AutoLocPath\*.*"
            MessageBox MB_OK|MB_ICONSTOP "Failed to create folder '$AutoLocPath'.$\r$\nPlease choose a different location."
            Abort
        ${EndIf}
    ${EndIf}
FunctionEnd

; =====================================================
; MAIN INSTALLATION SECTION
; =====================================================
Section "Core Files" SecCore
    SectionIn RO  ; Required section - cannot be unchecked

    ; Set output path to main install directory
    SetOutPath "$INSTDIR"

    ; -----------------------------------------------
    ; CORE FILES - PLACE YOUR FILES HERE:
    ; -----------------------------------------------
    ; Example: If you have other core files
    ; File "..\assets\logo.png"
    ; File "..\README.md"

    ; Create AppData folder for user settings
    CreateDirectory "$APPDATA\BeatBattleAntiCheat"

    ; Write registry keys for uninstaller and paths
    WriteRegStr HKCU "Software\BeatBattleAntiCheat" "InstallDir" "$INSTDIR"
    WriteRegStr HKCU "Software\BeatBattleAntiCheat" "VST3Path" "$VST3Path"
    WriteRegStr HKCU "Software\BeatBattleAntiCheat" "ConfigPath" "$ConfigPath"
    WriteRegStr HKCU "Software\BeatBattleAntiCheat" "AutoLocPath" "$AutoLocPath"
    WriteRegStr HKCU "Software\BeatBattleAntiCheat" "Version" "1.0.0"

    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Add to Windows Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BeatBattleAntiCheat" \
                     "DisplayName" "BeatBattle AntiCheat"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BeatBattleAntiCheat" \
                     "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BeatBattleAntiCheat" \
                     "DisplayIcon" "$\"$INSTDIR\BBAC_Config.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BeatBattleAntiCheat" \
                     "Publisher" "BeatBattle"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BeatBattleAntiCheat" \
                     "DisplayVersion" "1.0.0"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BeatBattleAntiCheat" \
                     "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BeatBattleAntiCheat" \
                     "NoRepair" 1

    ; Calculate and write install size
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BeatBattleAntiCheat" \
                     "EstimatedSize" "$0"
SectionEnd

; =====================================================
; VST3 PLUGIN INSTALLATION SECTION
; =====================================================
Section "VST3 Plugin" SecVST3
    SectionIn RO  ; Required section

    ; Set output path to user-selected VST3 directory
    SetOutPath "$VST3Path"

    ; -----------------------------------------------
    ; PLACE YOUR VST3 PLUGIN HERE:
    ; -----------------------------------------------
    ; Your compiled VST3 plugin from CMake build
    ; File "..\deploys\BBACPlugin\build_cmake\Release\BBACPlugin.vst3"
    ; WHEN READY: After building your VST3 plugin, uncomment above

    ; VST3 plugins are typically folders with .vst3 extension containing:
    ; Contents\x86_64-win\YourPlugin.vst3
    ; 
    ; If your build creates a folder structure:
    ; File /r "..\deploys\BBACPlugin\build_cmake\Release\BBACPlugin.vst3"
    ;
    ; If your build creates a single DLL:
    ; CreateDirectory "$VST3Path\BBACPlugin.vst3\Contents\x86_64-win"
    ; File /oname=BBACPlugin.vst3\Contents\x86_64-win\BBACPlugin.vst3 "..\deploys\BBACPlugin\build_cmake\Release\BBACPlugin.dll"

    ; Placeholder until you have the real plugin
    ; REMOVE THIS WHEN YOU HAVE YOUR ACTUAL VST3 PLUGIN:
    CreateDirectory "$VST3Path\BBACPlugin.vst3"
    FileOpen $0 "$VST3Path\BBACPlugin.vst3\placeholder.txt" w
    FileWrite $0 "This is a placeholder. Your actual VST3 plugin will go here."
    FileClose $0

    DetailPrint "VST3 Plugin installed to: $VST3Path"
SectionEnd

; =====================================================
; CONFIG MANAGER INSTALLATION SECTION
; =====================================================
Section "Configuration Manager" SecConfig
    SectionIn RO  ; Required section

    ; Set output path to user-selected Config Manager directory
    SetOutPath "$ConfigPath"

    ; -----------------------------------------------
    ; PLACE YOUR CONFIG MANAGER APP HERE:
    ; -----------------------------------------------
    ; Main configuration app (PyInstaller output)
    ; File "..\config_app\dist\BBAC_Config.exe"
    ; WHEN READY: Build your Python app with PyInstaller, then uncomment above

    ; Optional config files
    ; File "..\config_app\dist\config_default.json"

    ; Placeholder until you have the real file
    ; REMOVE THIS WHEN YOU HAVE YOUR ACTUAL CONFIG APP:
    File /oname=BBAC_Config.exe "$%WINDIR%\notepad.exe"  ; TEMPORARY - REPLACE WITH YOUR APP

    DetailPrint "Configuration Manager installed to: $ConfigPath"
SectionEnd

; =====================================================
; AUTOLOCPACKS INSTALLATION SECTION
; =====================================================
Section "AutoLocPacks" SecAutoLoc
    SectionIn RO  ; Required section

    ; Set output path to user-selected AutoLocPacks directory
    SetOutPath "$AutoLocPath"

    ; -----------------------------------------------
    ; PLACE YOUR AUTOLOCPACKS FILES HERE:
    ; -----------------------------------------------
    ; AutoLocPacks executable (PyInstaller output or compiled binary)
    ; File "..\autolocpacks\dist\autoLocPacks.exe"
    ; WHEN READY: Build your AutoLocPacks app, then uncomment above

    ; Optional support files
    ; File "..\autolocpacks\dist\*.dll"
    ; File "..\autolocpacks\dist\config.json"

    ; Placeholder until you have the real file
    ; REMOVE THIS WHEN YOU HAVE YOUR ACTUAL AUTOLOCPACKS:
    FileOpen $0 "$AutoLocPath\autoLocPacks.exe.placeholder" w
    FileWrite $0 "This is a placeholder. Your actual autoLocPacks.exe will go here."
    FileClose $0

    DetailPrint "AutoLocPacks installed to: $AutoLocPath"
SectionEnd

; =====================================================
; SHORTCUTS SECTION
; =====================================================
Section "Create Shortcuts" SecShortcuts
    ; Create Start Menu folder
    CreateDirectory "$SMPROGRAMS\BeatBattle AntiCheat"

    ; Create Start Menu shortcut to config app (from user-selected path)
    CreateShortCut "$SMPROGRAMS\BeatBattle AntiCheat\BeatBattle AntiCheat Config.lnk" \
                   "$ConfigPath\BBAC_Config.exe" \
                   "" \
                   "$ConfigPath\BBAC_Config.exe" 0 \
                   SW_SHOWNORMAL \
                   "" \
                   "Configure BeatBattle AntiCheat settings"

    ; Create uninstaller shortcut
    CreateShortCut "$SMPROGRAMS\BeatBattle AntiCheat\Uninstall.lnk" \
                   "$INSTDIR\Uninstall.exe" \
                   "" \
                   "$INSTDIR\Uninstall.exe" 0

    ; Optional: Create desktop shortcut
    ; CreateShortCut "$DESKTOP\BeatBattle AntiCheat.lnk" "$ConfigPath\BBAC_Config.exe"
SectionEnd

; =====================================================
; SECTION DESCRIPTIONS
; =====================================================
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "Core application files (required)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecVST3} "VST3 plugin for DAW integration (required)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecConfig} "Configuration Manager for setting up paths and server connection (required)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecAutoLoc} "AutoLocPacks for automatic sample pack detection (required)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} "Start Menu shortcuts"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; =====================================================
; UNINSTALLER SECTION
; =====================================================
Section "Uninstall"
    ; Read installation paths from registry
    ReadRegStr $VST3Path HKCU "Software\BeatBattleAntiCheat" "VST3Path"
    ReadRegStr $ConfigPath HKCU "Software\BeatBattleAntiCheat" "ConfigPath"
    ReadRegStr $AutoLocPath HKCU "Software\BeatBattleAntiCheat" "AutoLocPath"

    ; Remove core files from main install directory
    Delete "$INSTDIR\Uninstall.exe"
    ; Add other core files you installed:
    ; Delete "$INSTDIR\logo.png"
    ; Delete "$INSTDIR\README.md"

    ; Remove Config Manager files
    Delete "$ConfigPath\BBAC_Config.exe"
    ; Delete "$ConfigPath\config_default.json"
    ${If} $ConfigPath != $INSTDIR
        RMDir "$ConfigPath"  ; Only remove if it's a separate directory
    ${EndIf}

    ; Remove AutoLocPacks files
    Delete "$AutoLocPath\autoLocPacks.exe"
    Delete "$AutoLocPath\autoLocPacks.exe.placeholder"
    ; Delete "$AutoLocPath\*.dll"
    ${If} $AutoLocPath != $INSTDIR
        RMDir "$AutoLocPath"  ; Only remove if it's a separate directory
    ${EndIf}

    ; Remove main install directory
    RMDir "$INSTDIR"

    ; Remove VST3 plugin
    RMDir /r "$VST3Path\BBACPlugin.vst3"

    ; Remove shortcuts
    Delete "$SMPROGRAMS\BeatBattle AntiCheat\*.*"
    RMDir "$SMPROGRAMS\BeatBattle AntiCheat"
    Delete "$DESKTOP\BeatBattle AntiCheat.lnk"  ; If you created desktop shortcut

    ; Optional: Ask user if they want to remove settings
    MessageBox MB_YESNO "Do you want to remove all settings and configuration files?" IDNO KeepSettings
    RMDir /r "$APPDATA\BeatBattleAntiCheat"
    KeepSettings:

    ; Remove registry keys
    DeleteRegKey HKCU "Software\BeatBattleAntiCheat"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BeatBattleAntiCheat"

    DetailPrint "BeatBattle AntiCheat has been uninstalled."
SectionEnd

; =====================================================
; FILE STRUCTURE EXPECTED BY THIS SCRIPT:
; =====================================================
; BeatBattleAntiCheat/
; ├── installer/
; │   └── bbac_installer.nsi          ← This file
; ├── config_app/
; │   └── dist/
; │       └── BBAC_Config.exe         ← PyInstaller output (PLACE HERE)
; ├── autolocpacks/
; │   └── dist/
; │       └── autoLocPacks.exe        ← PyInstaller output (PLACE HERE)
; ├── deploys/
; │   ├── BBAC_Installer.exe          ← Compiled installer (OUTPUT)
; │   └── BBACPlugin/
; │       └── build_cmake/
; │           └── Release/
; │               └── BBACPlugin.vst3 ← Your VST3 plugin (PLACE HERE)
; ├── LICENSE.txt                     ← Your license file (CREATE THIS)
; └── assets/
;     └── icon.ico                    ← Optional icon (PLACE HERE)
;
; =====================================================
; INSTALLATION PATHS (User Configurable):
; =====================================================
; 1. Main Install Dir:    $INSTDIR (default: C:\Program Files\BeatBattleAntiCheat)
;    - Core files
;    - Uninstaller
;
; 2. VST3 Plugin:         $VST3Path (default: C:\Program Files\Common Files\VST3)
;    - BBACPlugin.vst3
;
; 3. Config Manager:      $ConfigPath (default: same as $INSTDIR)
;    - BBAC_Config.exe
;    - Can be launched anytime to reconfigure
;
; 4. AutoLocPacks:        $AutoLocPath (default: same as $INSTDIR)
;    - autoLocPacks.exe
;    - Runs to detect sample packs
;
; All paths are saved to registry at:
; HKCU\Software\BeatBattleAntiCheat\
;
; TO BUILD THIS INSTALLER:
; 1. Install NSIS: winget install NSIS.NSIS
; 2. Right-click this file → "Compile NSIS Script"
;    OR run: makensis bbac_installer.nsi
; 3. Output: deploys\BBAC_Installer.exe
; =====================================================
