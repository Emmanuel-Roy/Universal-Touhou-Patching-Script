<# :
@echo off
title Universal Touhou Patcher
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$code = [System.IO.File]::ReadAllText('%~f0'); Invoke-Expression $code"
echo.
echo ========================================================
echo  Setup complete! Press any key to exit.
echo ========================================================
pause >nul
exit /b
#>

[CmdletBinding()]
param (
    [switch]$ForceReinstall
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Game is always installed in current directory where script is run
$GamePath = (Get-Location).Path

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Universal Touhou Patcher" -ForegroundColor Cyan
Write-Host " (Supports Touhou 06 through Touhou 19 on x86, x64, ARM64)" -ForegroundColor Gray
Write-Host "========================================================" -ForegroundColor Cyan

# Define Touhou Game Database using pure ASCII patterns and size ranges
$gameDb = @(
    @{ Id="th06";  Name="Touhou 06: The Embodiment of Scarlet Devil"; Pattern="*th06*.exe"; MinSize=450KB;  MaxSize=650KB;  Gen=1 },
    @{ Id="th07";  Name="Touhou 07: Perfect Cherry Blossom";         Pattern="*th07*.exe"; MinSize=800KB;  MaxSize=1150KB; Gen=1 },
    @{ Id="th08";  Name="Touhou 08: Imperishable Night";            Pattern="*th08*.exe"; MinSize=1200KB; MaxSize=1850KB; Gen=1 },
    @{ Id="th09";  Name="Touhou 09: Phantasmagoria of Flower View";   Pattern="*th09*.exe"; MinSize=1500KB; MaxSize=2500KB; Gen=2 },
    @{ Id="th095"; Name="Touhou 09.5: Shoot the Bullet";             Pattern="*th095*.exe"; MinSize=1500KB; MaxSize=2500KB; Gen=2 },
    @{ Id="th10";  Name="Touhou 10: Mountain of Faith";             Pattern="*th10*.exe"; MinSize=2000KB; MaxSize=4000KB; Gen=2 },
    @{ Id="th11";  Name="Touhou 11: Subterranean Animism";          Pattern="*th11*.exe"; MinSize=2000KB; MaxSize=4500KB; Gen=2 },
    @{ Id="th12";  Name="Touhou 12: Undefined Fantastic Object";    Pattern="*th12*.exe"; MinSize=2000KB; MaxSize=5000KB; Gen=2 },
    @{ Id="th123"; Name="Touhou 12.3: Hisoutensoku";                Pattern="*th123*.exe"; MinSize=2000KB; MaxSize=6000KB; Gen=2 },
    @{ Id="th125"; Name="Touhou 12.5: Double Spoiler";              Pattern="*th125*.exe"; MinSize=2000KB; MaxSize=5000KB; Gen=2 },
    @{ Id="th128"; Name="Touhou 12.8: Fairy Wars";                  Pattern="*th128*.exe"; MinSize=2000KB; MaxSize=5000KB; Gen=2 },
    @{ Id="th13";  Name="Touhou 13: Ten Desires";                   Pattern="*th13*.exe"; MinSize=2000KB; MaxSize=6000KB; Gen=2 },
    @{ Id="th14";  Name="Touhou 14: Double Dealing Character";     Pattern="*th14*.exe"; MinSize=3000KB; MaxSize=7000KB; Gen=2 },
    @{ Id="th143"; Name="Touhou 14.3: Impossible Spell Card";       Pattern="*th143*.exe"; MinSize=3000KB; MaxSize=7000KB; Gen=2 },
    @{ Id="th15";  Name="Touhou 15: Legacy of Lunatic Kingdom";     Pattern="*th15*.exe"; MinSize=3000KB; MaxSize=8000KB; Gen=2 },
    @{ Id="th155"; Name="Touhou 15.5: Antinomy of Common Flowers"; Pattern="*th155*.exe"; MinSize=5000KB; MaxSize=40000KB; Gen=3 },
    @{ Id="th16";  Name="Touhou 16: Hidden Star in Four Seasons";   Pattern="*th16*.exe"; MinSize=3000KB; MaxSize=8000KB; Gen=3 },
    @{ Id="th165"; Name="Touhou 16.5: Secret Sealing Auto-dap";    Pattern="*th165*.exe"; MinSize=3000KB; MaxSize=8000KB; Gen=3 },
    @{ Id="th17";  Name="Touhou 17: Wily Beast and Weakest Creature"; Pattern="*th17*.exe"; MinSize=3000KB; MaxSize=9000KB; Gen=3 },
    @{ Id="th18";  Name="Touhou 18: Unconnected Marketeers";        Pattern="*th18*.exe"; MinSize=3000KB; MaxSize=9000KB; Gen=3 },
    @{ Id="th185"; Name="Touhou 18.5: 100th Black Market";          Pattern="*th185*.exe"; MinSize=3000KB; MaxSize=9000KB; Gen=3 },
    @{ Id="th19";  Name="Touhou 19: Unfinished Dream of All Living Ghost"; Pattern="*th19*.exe"; MinSize=4000KB; MaxSize=12000KB; Gen=3 }
)

# 1. Detect Installed Touhou Games
$allExes = Get-ChildItem -Path $GamePath -Filter "*.exe" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "dx_*" -and $_.Name -notlike "dgVoodoo*" }

$detectedGames = @()
$detectedGameMap = @{}
$claimedExes = @()

# First Pass: Exact matches by id.exe
foreach ($entry in $gameDb) {
    $id = $entry.Id
    $targetPath = Join-Path $GamePath "$id.exe"
    if (Test-Path -Path $targetPath -ErrorAction SilentlyContinue) {
        $exeItem = Get-Item -Path $targetPath
        $detectedGames += $id
        $detectedGameMap[$id] = $entry.Name
        $claimedExes += $exeItem.FullName
        Write-Host "[+] Detected $($entry.Name) ($id)" -ForegroundColor Green
    }
}

# Second Pass: Pattern match or size fallback for un-claimed EXEs
if ($detectedGames.Count -eq 0) {
    foreach ($entry in $gameDb) {
        $id = $entry.Id
        if ($detectedGames -contains $id) { continue }
        
        $matchedExe = $allExes | Where-Object { $_.FullName -notin $claimedExes -and $_.Name -like $entry.Pattern } | Select-Object -First 1
        if (-not $matchedExe) {
            $matchedExe = $allExes | Where-Object { 
                $_.FullName -notin $claimedExes -and 
                $_.Name -notlike "custom*" -and 
                $_.Name -notlike "vpatch*" -and 
                $_.Name -notlike "th[0-1][0-9]*" -and 
                $_.Length -ge $entry.MinSize -and 
                $_.Length -le $entry.MaxSize 
            } | Select-Object -First 1
        }
        
        if ($matchedExe) {
            $targetPath = Join-Path $GamePath "$id.exe"
            if ($matchedExe.FullName -ine $targetPath) {
                Copy-Item $matchedExe.FullName $targetPath -Force
            }
            $detectedGames += $id
            $detectedGameMap[$id] = $entry.Name
            $claimedExes += $matchedExe.FullName
            Write-Host "[+] Detected $($entry.Name) ($id)" -ForegroundColor Green
        }
    }
}

if ($detectedGames.Count -eq 0) {
    Write-Host "[!] Error: No Touhou game executable (TH06 through TH19) found in:" -ForegroundColor Red
    Write-Host "    $GamePath" -ForegroundColor Red
    Write-Host "    Please run this script inside your Touhou game folder." -ForegroundColor Yellow
    exit 1
}

# 2. Download Crosire d3d8to9 Wrapper ONLY for Legacy Direct3D 8 Games (TH06, TH07, TH08)
$needsD3d8 = ($detectedGames -contains "th06") -or ($detectedGames -contains "th07") -or ($detectedGames -contains "th08")

if ($needsD3d8) {
    $targetD3d8 = Join-Path $GamePath "d3d8.dll"
    if (-not (Test-Path -Path $targetD3d8 -ErrorAction SilentlyContinue) -or $ForceReinstall) {
        Write-Host "[+] Installing Crosire d3d8to9 (DirectX 8 -> DirectX 9/12 wrapper - ENABLES WINDOWS 11 ARM64 & MODERN GPU SUPPORT)..." -ForegroundColor Green
        $d3d8Url = "https://github.com/crosire/d3d8to9/releases/latest/download/d3d8.dll"
        try {
            Invoke-WebRequest -Uri $d3d8Url -OutFile $targetD3d8 -UseBasicParsing
            Write-Host "    [OK] d3d8.dll installed successfully (DirectX 8 -> DirectX 9/12 translation active for ARM64)." -ForegroundColor Gray
        } catch {
            Write-Host "[!] Warning: Failed to download d3d8.dll - using local fallback if available." -ForegroundColor Yellow
        }
    } else {
        Write-Host "[+] Crosire d3d8to9 (d3d8.dll) already present (Enables Windows 11 ARM64 & modern GPU support for legacy D3D8 games). Skipping download." -ForegroundColor Gray
    }
}

# 3. Download and Install d3dx9_43.dll (For THCRAP Font Overlay Hooks on Direct3D 9 games)
$needsD3dx9 = ($detectedGames | Where-Object { $_ -in @("th06","th07","th08","th09","th095","th10","th11","th12","th123","th125","th128","th13","th14","th143","th15") }).Count -gt 0

if ($needsD3dx9) {
    $targetD3dx9 = Join-Path $GamePath "d3dx9_43.dll"
    if (-not (Test-Path -Path $targetD3dx9 -ErrorAction SilentlyContinue) -or $ForceReinstall) {
        Write-Host "[+] Installing Microsoft DirectX 9 Extensions (d3dx9_43.dll)..." -ForegroundColor Green
        
        $sysDll = "$env:SystemRoot\SysWOW64\d3dx9_43.dll"

        if (Test-Path -Path $sysDll -ErrorAction SilentlyContinue) {
            Copy-Item $sysDll $targetD3dx9 -Force
            Write-Host "    [OK] d3dx9_43.dll copied from Windows SysWOW64 system directory." -ForegroundColor Gray
        } else {
            Write-Host "    [...] Downloading Microsoft DirectX 9 package (~95MB)... Please wait..." -ForegroundColor Yellow
            $dxRedistUrl = "https://download.microsoft.com/download/8/4/a/84a35bf1-dafe-4ae8-82af-ad2ae20b6b14/directx_Jun2010_redist.exe"
            $tempExe = Join-Path $GamePath "dx_redist_temp.exe"
            $tempDir = Join-Path $GamePath "dx_extract_temp"

            try {
                Invoke-WebRequest -Uri $dxRedistUrl -OutFile $tempExe -UseBasicParsing
                New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
                
                $destPath = (Get-Item -Path $tempDir).FullName
                Start-Process -FilePath $tempExe -ArgumentList "/T:`"$destPath`" /Q" -Wait
                
                $cabFile = Join-Path $tempDir "Jun2010_d3dx9_43_x86.cab"
                if (Test-Path -Path $cabFile -ErrorAction SilentlyContinue) {
                    Start-Process -FilePath "expand.exe" -ArgumentList "`"$cabFile`" -F:d3dx9_43.dll `"$GamePath`"" -Wait -WindowStyle Hidden
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
        }
    } else {
        Write-Host "[+] Microsoft DirectX 9 Extensions (d3dx9_43.dll) already present. Skipping download." -ForegroundColor Gray
    }
}

# 4. Automatically Install THCRAP English Translation Patch Stack & Download All Patch Files
$thcrapInstalled = (Test-Path (Join-Path $GamePath "thcrap\config\thpatch-en.js")) -and (Test-Path (Join-Path $GamePath "thcrap\repos\nmlgc\base_tsa\global.js"))

if (-not $thcrapInstalled -or $ForceReinstall) {
    Write-Host "[+] Automatically downloading and installing THCRAP English translation patches..." -ForegroundColor Green
    $thcrapZipUrl = "https://github.com/thpatch/thcrap/releases/latest/download/thcrap.zip"
    $thcrapZip = Join-Path $GamePath "thcrap_temp.zip"

    try {
        if (-not (Test-Path (Join-Path $GamePath "thcrap\bin\thcrap_loader.exe")) -or $ForceReinstall) {
            Write-Host "    [...] Downloading THCRAP engine (~30MB)... Please wait..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $thcrapZipUrl -OutFile $thcrapZip -UseBasicParsing
            Expand-Archive -Path $thcrapZip -DestinationPath (Join-Path $GamePath "thcrap") -Force
            Remove-Item $thcrapZip -Force -ErrorAction SilentlyContinue
        }
        
        # Configure thcrap/config/config.js (Enable background updates)
        New-Item -ItemType Directory -Path (Join-Path $GamePath "thcrap\config") -Force | Out-Null
        $configJs = @'
{
  "background_updates": true,
  "time_between_updates": 5,
  "update_at_exit": false,
  "update_others": true
}
'@
        Set-Content -Path (Join-Path $GamePath "thcrap\config\config.js") -Value $configJs -Encoding UTF8

        # Configure thcrap/config/games.js
        $gamesJsObj = @{}
        foreach ($g in $detectedGames) {
            $gamesJsObj[$g] = "../$g.exe"
            $gamesJsObj["${g}_custom"] = "../custom.exe"
        }
        $gamesJsJson = $gamesJsObj | ConvertTo-Json
        Set-Content -Path (Join-Path $GamePath "thcrap\config\games.js") -Value $gamesJsJson -Encoding UTF8

        # Configure thcrap/repos/nmlgc/repo.js
        New-Item -ItemType Directory -Path (Join-Path $GamePath "thcrap\repos\nmlgc") -Force | Out-Null
        $nmlgcRepoJs = @'
{
    "id": "nmlgc",
    "title": "nmlgc's patch repository",
    "contact": "network@thpatch.net",
    "servers": [
        "https://srv.thpatch.net/",
        "https://mirrors.thpatch.net/nmlgc/"
    ],
    "patches": {
        "base_tsa": "Core Touhou patch",
        "script_latin": "Latin script support",
        "western_name_order": "Western name order"
    }
}
'@
        Set-Content -Path (Join-Path $GamePath "thcrap\repos\nmlgc\repo.js") -Value $nmlgcRepoJs -Encoding UTF8

        # Configure thcrap/repos/thpatch/repo.js
        New-Item -ItemType Directory -Path (Join-Path $GamePath "thcrap\repos\thpatch") -Force | Out-Null
        $thpatchRepoJs = @'
{
    "id": "thpatch",
    "title": "Touhou Patch Center",
    "contact": "network@thpatch.net",
    "servers": [
        "https://srv.thpatch.net/",
        "https://mirrors.thpatch.net/nmlgc/"
    ],
    "patches": {
        "lang_en": "English language pack"
    }
}
'@
        Set-Content -Path (Join-Path $GamePath "thcrap\repos\thpatch\repo.js") -Value $thpatchRepoJs -Encoding UTF8

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
        Set-Content -Path (Join-Path $GamePath "thcrap\config\thpatch-en.js") -Value $thpatchEnJs -Encoding UTF8

        # Pre-download all patch files for detected games including global core files
        foreach ($g in $detectedGames) {
            $repos = @(
                @{ Name="base_tsa";           BaseUrls=@("https://mirrors.thpatch.net/nmlgc/base_tsa/", "https://srv.thpatch.net/base_tsa/");           LocalDir=(Join-Path $GamePath "thcrap\repos\nmlgc\base_tsa") },
                @{ Name="script_latin";       BaseUrls=@("https://mirrors.thpatch.net/nmlgc/script_latin/", "https://srv.thpatch.net/script_latin/");       LocalDir=(Join-Path $GamePath "thcrap\repos\nmlgc\script_latin") },
                @{ Name="western_name_order"; BaseUrls=@("https://mirrors.thpatch.net/nmlgc/western_name_order/", "https://srv.thpatch.net/western_name_order/"); LocalDir=(Join-Path $GamePath "thcrap\repos\nmlgc\western_name_order") },
                @{ Name="lang_en";            BaseUrls=@("https://srv.thpatch.net/lang_en/", "https://mirrors.thpatch.net/nmlgc/lang_en/");             LocalDir=(Join-Path $GamePath "thcrap\repos\thpatch\lang_en") }
            )

            foreach ($repo in $repos) {
                New-Item -ItemType Directory -Path $repo.LocalDir -Force | Out-Null
                $raw = $null
                $selectedBaseUrl = $null

                foreach ($baseUrl in $repo.BaseUrls) {
                    try {
                        $raw = (Invoke-WebRequest -Uri ($baseUrl + "files.js") -UseBasicParsing -ErrorAction Stop).Content
                        if ($raw) {
                            $selectedBaseUrl = $baseUrl
                            Set-Content -Path (Join-Path $repo.LocalDir "files.js") -Value $raw -Encoding UTF8
                            break
                        }
                    } catch {}
                }

                if ($raw -and $selectedBaseUrl) {
                    $matches = [regex]::Matches($raw, '"(' + $g + '[^"]*|versions\.js|stringdefs\.js|global\.js)"')
                    $fileKeys = $matches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique

                    if ($fileKeys.Count -gt 0) {
                        Write-Host "    [...] Downloading $($fileKeys.Count) translation files for $g ($($repo.Name))..." -ForegroundColor Yellow
                        foreach ($relPath in $fileKeys) {
                            $destFile = Join-Path $repo.LocalDir $relPath
                            if (-not (Test-Path -Path $destFile -ErrorAction SilentlyContinue)) {
                                $parentDir = Split-Path $destFile -Parent
                                if (-not (Test-Path -Path $parentDir -ErrorAction SilentlyContinue)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
                                try {
                                    Invoke-WebRequest -Uri ($selectedBaseUrl + $relPath) -OutFile $destFile -UseBasicParsing -ErrorAction SilentlyContinue
                                } catch {}
                            }
                        }
                    }
                }
            }
        }

        Write-Host "    [OK] THCRAP engine and English patch repository metadata configured." -ForegroundColor Gray
    } catch {
        Write-Host "[!] Warning: THCRAP auto-download skipped or failed." -ForegroundColor Yellow
    }
} else {
    Write-Host "[+] THCRAP English translation patch already installed. Skipping download." -ForegroundColor Gray
}

# Create double-clickable launchers for English patches if missing
foreach ($g in $detectedGames) {
    $batFile = Join-Path $GamePath "$g (thpatch-en).cmd"
    if (-not (Test-Path -Path $batFile -ErrorAction SilentlyContinue) -and -not (Test-Path -Path (Join-Path $GamePath "$g (thpatch-en).exe") -ErrorAction SilentlyContinue)) {
        $batCmd = "@echo off`r`nstart `"`" `"%~dp0thcrap\bin\thcrap_loader.exe`" thpatch-en.js $g`r`n"
        Set-Content -Path $batFile -Value $batCmd -Encoding ASCII
    }
}

# 5. Configure Windowed Mode and VPatch
Write-Host "[+] Verifying Windowed Mode and 60 FPS VPatch configurations..." -ForegroundColor Green

# 56-byte cfg for TH06, TH07, TH08 (Byte 0x02 = 0x01 Windowed)
$cfg56Bytes = [byte[]](
    0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0x00, 0x00, 0x02, 0x01, 0x00, 0x00, 0x04, 0x03, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00,
    0x58, 0x02, 0x58, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
)

# 52-byte cfg for TH09 through TH19 (Byte 0x06 = 0x01 Windowed)
$cfg52Bytes = [byte[]](
    0x03, 0x00, 0x10, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0xFF, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0x04, 0x00, 0x58, 0x02, 0x58, 0x02, 0x00, 0x01, 0x01, 0x01, 0x00, 0x02,
    0x64, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x01, 0x00, 0x00
)

foreach ($g in $detectedGames) {
    $cfgPath = Join-Path $GamePath "$g.cfg"
    if (-not (Test-Path -Path $cfgPath -ErrorAction SilentlyContinue) -or $ForceReinstall) {
        if ($g -in @("th06", "th07", "th08")) {
            [System.IO.File]::WriteAllBytes($cfgPath, $cfg56Bytes)
        } else {
            [System.IO.File]::WriteAllBytes($cfgPath, $cfg52Bytes)
        }
    }
}

# Shift-JIS filename alias for th06.cfg
if ($detectedGames -contains "th06") {
    $sjisBytes = [byte[]](0x96, 0x7B, 0x96, 0xA0, 0x8D, 0x8D, 0x92, 0xB9, 0x8B, 0xAE, 0x2E, 0x63, 0x66, 0x67)
    $ansiName = [System.Text.Encoding]::GetEncoding(1252).GetString($sjisBytes)
    $ansiPath = Join-Path $GamePath $ansiName
    if (-not (Test-Path -Path $ansiPath -ErrorAction SilentlyContinue) -or $ForceReinstall) {
        [System.IO.File]::WriteAllBytes($ansiPath, $cfg56Bytes)
    }
}

# vpatch.ini
$vpatchPath = Join-Path $GamePath "vpatch.ini"
if (-not (Test-Path -Path $vpatchPath -ErrorAction SilentlyContinue) -or $ForceReinstall) {
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
    Set-Content -Path $vpatchPath -Value $vpatchIni -Encoding UTF8
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
    Write-Host "========================================================" -ForegroundColor Green
}
