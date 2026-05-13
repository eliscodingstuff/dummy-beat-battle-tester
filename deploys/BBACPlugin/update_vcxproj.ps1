# Run this script to add ImGui paths to BBACPlugin.vcxproj
# Usage: .\update_vcxproj.ps1

$vcxprojPath = ".\BBACPlugin.vcxproj"

Write-Host "Reading $vcxprojPath..." -ForegroundColor Cyan

$content = Get-Content $vcxprojPath -Raw

Write-Host "Adding ImGui include paths..." -ForegroundColor Yellow

# Add ImGui paths to include directories (4 times - one for each configuration)
$oldInclude = 'C:\Users\16514\Documents\myStuff\CSF\VST_SDK\vst3sdk;C:\Users\16514\AppData\Local\Programs\Python\Python312\include'
$newInclude = 'C:\Users\16514\Documents\myStuff\CSF\VST_SDK\vst3sdk;C:\Users\16514\Documents\myStuff\CSF\imgui;C:\Users\16514\Documents\myStuff\CSF\imgui\backends;C:\Users\16514\AppData\Local\Programs\Python\Python312\include'

$content = $content.Replace($oldInclude, $newInclude)

Write-Host "Adding DirectX library dependencies..." -ForegroundColor Yellow

# Add DirectX libs to linker dependencies
$content = $content.Replace('python312.lib;%(AdditionalDependencies)', 'python312.lib;d3d11.lib;dxgi.lib;d3dcompiler.lib;%(AdditionalDependencies)')

Write-Host "Writing updated file..." -ForegroundColor Cyan

$content | Out-File -FilePath $vcxprojPath -Encoding UTF8

Write-Host "Done! ImGui paths and DirectX libs added to all configurations." -ForegroundColor Green
Write-Host "Close and reopen Visual Studio for IntelliSense to pick up the changes." -ForegroundColor Cyan
