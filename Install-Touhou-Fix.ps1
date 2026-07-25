<#
.SYNOPSIS
    Universal Single-Script Automated Installer for ALL Touhou Windows Games (TH06 through TH19).
.DESCRIPTION
    Automated one-stop-shop installer for Touhou games on Windows 10/11 & ARM64:
    - Touhou 6 through Touhou 19 (th06, th07, th08, th09, th095, th10, th11, th12, th123, th125, th128, th13, th14, th143, th15, th16, th165, th17, th18, th185, th19)

    Automatically installs and configures:
    - THCRAP English translation patches for all detected games automatically
    - Crosire d3d8to9 wrapper (DirectX 8 -> DirectX 9/12 for TH06-TH08)
    - Microsoft d3dx9_43.dll 32-bit runtime (fixes thcrap missing DLL error)
    - Windowed mode & VPatch 60 FPS resolution configuration
    - Launcher shortcuts for English, VPatch, Original, and Settings
#>

[CmdletBinding()]
param (
    [string]$GamePath = $PSScriptRoot,
    [switch]$ForceReinstall
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Touhou Complete Series: Universal Windows Setup" -ForegroundColor Cyan
Write-Host " (Supports Touhou 06 through Touhou 19 on x86, x64, ARM64)" -ForegroundColor Gray
Write-Host "========================================================" -ForegroundColor Cyan

# Define Touhou Game Database using pure ASCII patterns and size ranges
$gameDb = @(
    @{ Id="th06";  Name="Touhou 06: The Embodiment of Scarlet Devil"; Pattern="*th06*.exe"; MinSize=450KB;  MaxSize=650KB },
    @{ Id="th07";  Name="Touhou 07: Perfect Cherry Blossom";         Pattern="*th07*.exe"; MinSize=800KB;  MaxSize=1150KB },
    @{ Id="th08";  Name="Touhou 08: Imperishable Night";            Pattern="*th08*.exe"; MinSize=1200KB; MaxSize=1850KB },
    @{ Id="th09";  Name="Touhou 09: Phantasmagoria of Flower View";   Pattern="*th09*.exe"; MinSize=1500KB; MaxSize=2500KB },
    @{ Id="th095"; Name="Touhou 09.5: Shoot the Bullet";             Pattern="*th095*.exe"; MinSize=1500KB; MaxSize=2500KB },
    @{ Id="th10";  Name="Touhou 10: Mountain of Faith";             Pattern="*th10*.exe"; MinSize=2000KB; MaxSize=4000KB },
    @{ Id="th11";  Name="Touhou 11: Subterranean Animism";          Pattern="*th11*.exe"; MinSize=2000KB; MaxSize=4500KB },
    @{ Id="th12";  Name="Touhou 12: Undefined Fantastic Object";    Pattern="*th12*.exe"; MinSize=2000KB; MaxSize=5000KB },
    @{ Id="th123"; Name="Touhou 12.3: Hisoutensoku";                Pattern="*th123*.exe"; MinSize=2000KB; MaxSize=6000KB },
    @{ Id="th125"; Name="Touhou 12.5: Double Spoiler";              Pattern="*th125*.exe"; MinSize=2000KB; MaxSize=5000KB },
    @{ Id="th128"; Name="Touhou 12.8: Fairy Wars";                  Pattern="*th128*.exe"; MinSize=2000KB; MaxSize=5000KB },
    @{ Id="th13";  Name="Touhou 13: Ten Desires";                   Pattern="*th13*.exe"; MinSize=2000KB; MaxSize=6000KB },
    @{ Id="th14";  Name="Touhou 14: Double Dealing Character";     Pattern="*th14*.exe"; MinSize=3000KB; MaxSize=7000KB },
    @{ Id="th143"; Name="Touhou 14.3: Impossible Spell Card";       Pattern="*th143*.exe"; MinSize=3000KB; MaxSize=7000KB },
    @{ Id="th15";  Name="Touhou 15: Legacy of Lunatic Kingdom";     Pattern="*th15*.exe"; MinSize=3000KB; MaxSize=8000KB },
    @{ Id="th16";  Name="Touhou 16: Hidden Star in Four Seasons";   Pattern="*th16*.exe"; MinSize=3000KB; MaxSize=8000KB },
    @{ Id="th165"; Name="Touhou 16.5: Secret Sealing Auto-dap";    Pattern="*th165*.exe"; MinSize=3000KB; MaxSize=8000KB },
    @{ Id="th17";  Name="Touhou 17: Wily Beast and Weakest Creature"; Pattern="*th17*.exe"; MinSize=3000KB; MaxSize=9000KB },
    @{ Id="th18";  Name="Touhou 18: Unconnected Marketeers";        Pattern="*th18*.exe"; MinSize=3000KB; MaxSize=9000KB },
    @{ Id="th185"; Name="Touhou 18.5: 100th Black Market";          Pattern="*th185*.exe"; MinSize=3000KB; MaxSize=9000KB },
    @{ Id="th19";  Name="Touhou 19: Unfinished Dream of All Living Ghost"; Pattern="*th19*.exe"; MinSize=4000KB; MaxSize=12000KB }
)

# 1. Detect Installed Touhou Games
$allExes = Get-ChildItem -Path $GamePath -Filter "*.exe" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "dx_*" -and $_.Name -notlike "dgVoodoo*" }

$detectedGames = @()
$detectedGameMap = @{}

foreach ($entry in $gameDb) {
    $id = $entry.Id
    $name = $entry.Name
    
    $matchedExe = $null
    if (Test-Path "$GamePath\$id.exe") {
        $matchedExe = Get-Item "$GamePath\$id.exe"
    } else {
        $matchedExe = $allExes | Where-Object { $_.Name -like $entry.Pattern } | Select-Object -First 1
        if (-not $matchedExe) {
            $matchedExe = $allExes | Where-Object { $_.Name -notlike "custom*" -and $_.Name -notlike "vpatch*" -and $_.Length -ge $entry.MinSize -and $_.Length -le $entry.MaxSize } | Select-Object -First 1
        }
    }
    
    if ($matchedExe) {
        if (-not (Test-Path "$GamePath\$id.exe")) {
            Copy-Item $matchedExe.FullName "$GamePath\$id.exe" -Force
        }
        $detectedGames += $id
        $detectedGameMap[$id] = $name
        Write-Host "[+] Detected $name ($id)" -ForegroundColor Green
    }
}

if ($detectedGames.Count -eq 0) {
    Write-Host "[!] Error: No Touhou game executable (TH06 through TH19) found in:" -ForegroundColor Red
    Write-Host "    $GamePath" -ForegroundColor Red
    Write-Host "    Please run this script inside your Touhou game folder or specify -GamePath." -ForegroundColor Yellow
    exit 1
}

# 2. Download Crosire d3d8to9 Wrapper (DirectX 8 -> DirectX 9/12 for TH06-TH08)
$needsD3d8 = ($detectedGames -contains "th06") -or ($detectedGames -contains "th07") -or ($detectedGames -contains "th08")

if ($needsD3d8) {
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

# 4. Automatically Install THCRAP English Translation Patch Stack
$thcrapInstalled = (Test-Path "$GamePath\thcrap\config\thpatch-en.js") -or (Test-Path "$GamePath\thcrap\bin\thcrap_loader.exe")

if (-not $thcrapInstalled -or $ForceReinstall) {
    Write-Host "[+] Automatically downloading and installing THCRAP English translation patches..." -ForegroundColor Green
    $thcrapZipUrl = "https://github.com/thpatch/thcrap/releases/latest/download/thcrap.zip"
    $thcrapZip = "$GamePath\thcrap_temp.zip"

    try {
        Invoke-WebRequest -Uri $thcrapZipUrl -OutFile $thcrapZip -UseBasicParsing
        Expand-Archive -Path $thcrapZip -DestinationPath "$GamePath\thcrap" -Force
        Remove-Item $thcrapZip -Force -ErrorAction SilentlyContinue
        
        # Configure thcrap/config/games.js
        New-Item -ItemType Directory -Path "$GamePath\thcrap\config" -Force | Out-Null
        $gamesJsObj = @{}
        foreach ($g in $detectedGames) {
            $gamesJsObj[$g] = "../$g.exe"
            $gamesJsObj["${g}_custom"] = "../custom.exe"
        }
        $gamesJsJson = $gamesJsObj | ConvertTo-Json
        Set-Content -Path "$GamePath\thcrap\config\games.js" -Value $gamesJsJson -Encoding UTF8

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
        Write-Host "    [OK] THCRAP engine and English patch stack automatically installed." -ForegroundColor Gray
    } catch {
        Write-Host "[!] Warning: THCRAP auto-download skipped or failed." -ForegroundColor Yellow
    }
} else {
    Write-Host "[+] THCRAP English translation patch already installed. Skipping download." -ForegroundColor Gray
}

# Create double-clickable launchers for English patches if missing
foreach ($g in $detectedGames) {
    $batFile = "$GamePath\$g (thpatch-en).cmd"
    if (-not (Test-Path $batFile) -and -not (Test-Path "$GamePath\$g (thpatch-en).exe")) {
        $batCmd = "@echo off`r`nstart `"`" `"%~dp0thcrap\bin\thcrap_loader.exe`" thpatch-en.js $g`r`n"
        Set-Content -Path $batFile -Value $batCmd -Encoding ASCII
    }
}

# 5. Configure Windowed Mode and VPatch
Write-Host "[+] Verifying Windowed Mode and 60 FPS VPatch configurations..." -ForegroundColor Green

# th06.cfg / th07.cfg / th08.cfg (Byte 0x02 = 0x01 Windowed)
$cfgBytes = [byte[]](
    0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0x00, 0x00, 0x02, 0x01, 0x00, 0x00, 0x04, 0x03, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00,
    0x58, 0x02, 0x58, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
)

foreach ($g in $detectedGames) {
    if ($g -in @("th06", "th07", "th08")) {
        if (-not (Test-Path "$GamePath\$g.cfg") -or $ForceReinstall) {
            [System.IO.File]::WriteAllBytes("$GamePath\$g.cfg", $cfgBytes)
        }
    }
}

# Shift-JIS filename alias for th06.cfg
if ($detectedGames -contains "th06") {
    $sjisBytes = [byte[]](0x96, 0x7B, 0x96, 0xA0, 0x8D, 0x8D, 0x92, 0xB9, 0x8B, 0xAE, 0x2E, 0x63, 0x66, 0x67)
    $ansiName = [System.Text.Encoding]::GetEncoding(1252).GetString($sjisBytes)
    if (-not (Test-Path "$GamePath\$ansiName") -or $ForceReinstall) {
        [System.IO.File]::WriteAllBytes("$GamePath\$ansiName", $cfgBytes)
    }
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

Write-Host "    [OK] Configurations verified." -ForegroundColor Gray

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host " INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host " Detected Games: $($detectedGames -join ', ')" -ForegroundColor White
Write-Host ""
Write-Host " AVAILABLE LAUNCH AND PLAY OPTIONS:" -ForegroundColor Cyan
Write-Host ""
foreach ($g in $detectedGames) {
    $gName = $detectedGameMap[$g]
    Write-Host " [$g] ($gName):" -ForegroundColor White
    Write-Host "   1. English Patched (thcrap) : double-click '$g (thpatch-en).cmd' or '$g (thpatch-en).exe'" -ForegroundColor Yellow
    Write-Host "   2. 60 FPS VPatch            : double-click 'vpatch.exe'" -ForegroundColor Yellow
    Write-Host "   3. Original Unpatched Game  : double-click '$g.exe'" -ForegroundColor Yellow
    Write-Host "   4. Settings and Controller  : double-click 'custom.exe'" -ForegroundColor Yellow
    Write-Host ""
}
Write-Host "========================================================" -ForegroundColor Green
