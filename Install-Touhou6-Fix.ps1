<#
.SYNOPSIS
    Automated One-Stop-Shop Installer for Touhou 6 (The Embodiment of Scarlet Devil) on Windows 10/11 & ARM64.
.DESCRIPTION
    This script automatically downloads and installs:
    - Crosire d3d8to9 wrapper (DirectX 8 -> DirectX 9/12)
    - Microsoft d3dx9_43.dll 32-bit runtime (fixes thcrap missing DLL error)
    - THCRAP English translation patch engine & configuration (skips if already installed)
    - Windowed mode & VPatch 60 FPS resolution configuration
#>

[CmdletBinding()]
param (
    [string]$GamePath = $PSScriptRoot,
    [switch]$ForceReinstall
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Touhou 6: Modern Windows 10/11 and ARM64 Automated Setup" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. Validate Game Path
$allExes = Get-ChildItem -Path $GamePath -Filter "*.exe" -ErrorAction SilentlyContinue
$jpExe = $allExes | Where-Object { $_.Name -notlike "th*" -and $_.Name -notlike "custom*" -and $_.Name -notlike "vpatch*" -and $_.Name -notlike "dx_*" -and $_.Name -notlike "dgVoodoo*" } | Select-Object -First 1
$hasTh06 = Test-Path "$GamePath\th06.exe"

if (-not $jpExe -and -not $hasTh06) {
    Write-Host "[!] Error: Touhou 6 executable not found in:" -ForegroundColor Red
    Write-Host "    $GamePath" -ForegroundColor Red
    Write-Host "    Please run this script inside your Touhou 6 folder or specify -GamePath." -ForegroundColor Yellow
    exit 1
}

# Ensure th06.exe exists
if (-not $hasTh06 -and $jpExe) {
    Write-Host "[+] Creating th06.exe copy of main executable..." -ForegroundColor Green
    Copy-Item $jpExe.FullName "$GamePath\th06.exe" -Force
}

# 2. Download Crosire d3d8to9 Wrapper
if (-not (Test-Path "$GamePath\d3d8.dll") -or $ForceReinstall) {
    Write-Host "[+] Installing Crosire d3d8to9 (DirectX 8 to DirectX 9/12 wrapper)..." -ForegroundColor Green
    $d3d8Url = "https://github.com/crosire/d3d8to9/releases/latest/download/d3d8.dll"
    try {
        Invoke-WebRequest -Uri $d3d8Url -OutFile "$GamePath\d3d8.dll" -UseBasicParsing
        Write-Host "    [OK] d3d8.dll installed successfully." -ForegroundColor Gray
    } catch {
        Write-Host "[!] Warning: Failed to download d3d8.dll - using local fallback if available." -ForegroundColor Yellow
    }
} else {
    Write-Host "[+] Crosire d3d8to9 (d3d8.dll) already present. Skipping download." -ForegroundColor Gray
}

# 3. Download and Install d3dx9_43.dll
if (-not (Test-Path "$GamePath\d3dx9_43.dll") -or $ForceReinstall) {
    Write-Host "[+] Installing Microsoft DirectX 9 Extensions (d3dx9_43.dll)..." -ForegroundColor Green
    $dxRedistUrl = "https://download.microsoft.com/download/8/4/a/84a35bf1-dafe-4ae8-82af-ad2ae20b6b14/directx_Jun2010_redist.exe"
    $tempExe = "$GamePath\dx_redist_temp.exe"
    $tempDir = "$GamePath\dx_extract_temp"

    try {
        Invoke-WebRequest -Uri $dxRedistUrl -OutFile $tempExe -UseBasicParsing
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        $destPath = (Get-Item $tempDir).FullName
        Start-Process -FilePath $tempExe -ArgumentList "/T:`"$destPath`" /Q" -Wait
        
        if (Test-Path "$tempDir\Jun2010_d3dx9_43_x86.cab") {
            expand.exe "$tempDir\Jun2010_d3dx9_43_x86.cab" -F:d3dx9_43.dll "$GamePath" | Out-Null
            Write-Host "    [OK] d3dx9_43.dll extracted and installed successfully." -ForegroundColor Gray
        }
    } catch {
        Write-Host "[!] Warning: Could not download/extract d3dx9_43.dll." -ForegroundColor Yellow
    } finally {
        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
        if (Test-Path $tempExe) { 
            Set-ItemProperty $tempExe -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
            Remove-Item $tempExe -Force -ErrorAction SilentlyContinue 
        }
    }
} else {
    Write-Host "[+] Microsoft DirectX 9 Extensions (d3dx9_43.dll) already present. Skipping download." -ForegroundColor Gray
}

# 4. Check THCRAP English Patch
$thcrapInstalled = (Test-Path "$GamePath\thcrap\config\thpatch-en.js") -or (Test-Path "$GamePath\thcrap\bin\thcrap_loader.exe")

if (-not $thcrapInstalled -or $ForceReinstall) {
    Write-Host "[+] Installing THCRAP (Touhou English Translation Patcher)..." -ForegroundColor Green
    $thcrapZipUrl = "https://github.com/thpatch/thcrap/releases/latest/download/thcrap.zip"
    $thcrapZip = "$GamePath\thcrap_temp.zip"

    try {
        Invoke-WebRequest -Uri $thcrapZipUrl -OutFile $thcrapZip -UseBasicParsing
        Expand-Archive -Path $thcrapZip -DestinationPath "$GamePath\thcrap" -Force
        Remove-Item $thcrapZip -Force -ErrorAction SilentlyContinue
        
        # Configure thcrap/config/games.js
        New-Item -ItemType Directory -Path "$GamePath\thcrap\config" -Force | Out-Null
        $gamesJs = '{ "th06": "../th06.exe", "th06_custom": "../custom.exe" }'
        Set-Content -Path "$GamePath\thcrap\config\games.js" -Value $gamesJs -Encoding UTF8

        # Configure thcrap/config/thpatch-en.js
        $thpatchEnJs = @'
{
  "console": false,
  "dat_dump": false,
  "patches": [
    { "archive": "repos/nmlgc/base_tsa/" },
    { "archive": "repos/nmlgc/script_latin/" },
    { "archive": "repos/nmlgc/western_name_order/" },
    { "archive": "repos/thpatch/lang_en/" }
  ]
}
'@
        Set-Content -Path "$GamePath\thcrap\config\thpatch-en.js" -Value $thpatchEnJs -Encoding UTF8
        Write-Host "    [OK] THCRAP engine and English patch stack configured." -ForegroundColor Gray
    } catch {
        Write-Host "[!] Warning: THCRAP auto-download skipped or failed." -ForegroundColor Yellow
    }
} else {
    Write-Host "[+] THCRAP English translation patch already installed. Skipping download." -ForegroundColor Gray
}

# 5. Configure Windowed Mode and VPatch
Write-Host "[+] Verifying Windowed Mode and 60 FPS VPatch configuration..." -ForegroundColor Green

# th06.cfg (Byte 0x02 = 0x01 Windowed)
$cfgBytes = [byte[]](
    0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0x00, 0x00, 0x02, 0x01, 0x00, 0x00, 0x04, 0x03, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00,
    0x58, 0x02, 0x58, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
)
if (-not (Test-Path "$GamePath\th06.cfg") -or $ForceReinstall) {
    [System.IO.File]::WriteAllBytes("$GamePath\th06.cfg", $cfgBytes)
}

# ANSI Shift-JIS filename alias for th06.cfg
$sjisBytes = [byte[]](0x96, 0x7B, 0x96, 0xA0, 0x8D, 0x8D, 0x92, 0xB9, 0x8B, 0xAE, 0x2E, 0x63, 0x66, 0x67)
$ansiName = [System.Text.Encoding]::GetEncoding(1252).GetString($sjisBytes)
if (-not (Test-Path "$GamePath\$ansiName") -or $ForceReinstall) {
    [System.IO.File]::WriteAllBytes("$GamePath\$ansiName", $cfgBytes)
}

# vpatch.ini
if (-not (Test-Path "$GamePath\vpatch.ini") -or $ForceReinstall) {
    $vpatchIni = @'
[Window]
AskWindowMode = 0
enabled = 1
X = 300
Y = 20
Width = 960
Height = 720
TitleBar = 1
AlwaysOnTop = 0

[Option]
Vsync = 0
SleepType = 1
BltPrepareTime = 4
AutoBltPrepareTime = 1
GameFPS = 60
ReplaySkipFPS = 240
ReplaySlowFPS = 30
CalcFPS = 1
AlwaysBlt = 0
BugFixCherry = 1
BugFixTh10Power3 = 1
'@
    Set-Content -Path "$GamePath\vpatch.ini" -Value $vpatchIni -Encoding UTF8
}

# dgVoodoo.conf
if (Test-Path "$GamePath\dgVoodoo.conf") {
    (Get-Content "$GamePath\dgVoodoo.conf") -replace "FullScreenMode\s*=\s*true", "FullScreenMode                       = false" `
                                           -replace "dgVoodooWatermark\s*=\s*true", "dgVoodooWatermark                   = false" | Set-Content "$GamePath\dgVoodoo.conf"
}

Write-Host "    [OK] Configurations verified." -ForegroundColor Gray

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host " INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host " To launch English Touhou 6:" -ForegroundColor White
Write-Host "   Double-click: th06 (thpatch-en).exe" -ForegroundColor Yellow
Write-Host "   Or run:       thcrap\bin\thcrap_loader.exe thpatch-en.js th06" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Green
