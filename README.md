# Touhou-EOSD-Windows11-ARM64-Fix

This is a vibe-coded fix to get Touhou 6 running on Windows 11 ARM64 PC's.

It assumes you already have a build for x86-64 with the fan patch installed. This is just a drag and drop fix with a set of files.

---

## ⚡ One-Stop-Shop Automated Installer (`Install-Touhou6-Fix.ps1`)

Prefer a single click or script to do everything automatically?

1. Copy `Install-Touhou6-Fix.ps1` (or this entire repo) into your Touhou 6 game folder.
2. Right-click `Install-Touhou6-Fix.ps1` -> **Run with PowerShell** (or run `.\Install-Touhou6-Fix.ps1` in PowerShell).
3. The script automatically checks if components are already present (skips downloading THCRAP or DirectX runtimes if already installed):
   - Finds your `東方紅魔郷.exe` and creates `th06.exe`
   - Downloads & installs `d3d8to9` (`d3d8.dll` v1.15.1)
   - Downloads & extracts Microsoft `d3dx9_43.dll` 32-bit runtime
   - Downloads, installs & configures `thcrap` English translation patch
   - Configures Windowed Mode (`th06.cfg`) and 60 FPS VPatch (`vpatch.ini`)
4. **Launch the game**: Double-click `th06 (thpatch-en).exe`!

---

## 🛠️ Complete Guide: From CD Rip to Playable on Windows 11 ARM64 (Manual Setup)

If you prefer doing it manually:

### 📥 Step 1: Obtain the Game Files (CD Rip / Base Game)
1. Copy or extract your physical Japanese CD rip of **Touhou 6: The Embodiment of Scarlet Devil** (`東方紅魔郷` v1.02h) into a folder on your PC (e.g., `C:\Games\Touhou 6`).
2. In your game directory, locate the main executable `東方紅魔郷.exe`.
3. **Make a copy** of `東方紅魔郷.exe` in the same folder and rename the copy to `th06.exe`.

### 🌐 Step 2: Install the English Fan Patch (THCRAP)
1. Download the official **Touhou Community Reliant Automatic Patcher (THCRAP)** from [THPatch (thpatch.net)](https://www.thpatch.net/wiki/Touhou_Patch_Center) or download the standalone `th06` English patch package.
2. Extract `thcrap` into your Touhou 6 game folder.
3. Run `thcrap_configure.exe`, select the **English language pack (`lang_en`)**, and let it detect your `th06.exe`.
4. This adds `th06 (thpatch-en).exe`, `vpatch.exe`, and the `thcrap/` translation stack to your game directory.

### 🚀 Step 3: Apply This ARM64 Fix Pack (Drag & Drop)
1. **Download this repo** (click **Code -> Download ZIP** on GitHub).
2. **Copy and replace** all files from this ZIP directly into your Touhou 6 game folder.
3. **Launch and play**:
   - For English version: double-click `th06 (thpatch-en).exe`
   - For unpatched version: double-click `vpatch.exe` or `th06.exe`

---

## 📂 File Origins & What Was Done

| File | Where it came from | What was done |
|---|---|---|
| `Install-Touhou6-Fix.ps1` | Custom automated PowerShell installer script. | One-stop-shop script that downloads Crosire `d3d8to9`, Microsoft `d3dx9_43.dll`, installs `thcrap`, configures English translation patches, and sets up windowed mode & 60 FPS VPatch automatically. Skips downloading components if already installed. |
| `d3d8.dll` | Downloaded from Crosire's official `d3d8to9` GitHub release (`crosire/d3d8to9` v1.15.1). | Placed in the game folder as `d3d8.dll` to translate legacy DirectX 8 calls to Direct3D 9 / Direct3D 12. Windows 11 ARM64 drivers fail on native DirectX 8 calls; translating them to D3D9/D3D12 enables hardware acceleration on Qualcomm Adreno GPUs. |
| `d3dx9_43.dll` | Extracted from Microsoft's official DirectX End-User Runtimes June 2010 Redistributable (`Jun2010_d3dx9_43_x86.cab`). | Placed 32-bit x86 `d3dx9_43.dll` (v9.29.952.3111) in the game directory. This provides the missing D3DX9 helper library required by `thcrap` for font rendering and text overlay hooks, resolving the `"failed to learn d3dx9_43.dll"` warning. |
| `th06.cfg` | Configured Touhou 6 settings binary file. | Byte 0x02 set to `0x01` (Windowed Mode). On non-Japanese Windows, `th06` fails to read its Shift-JIS config file name (`東方紅魔郷.cfg`) under English ANSI codepage 1252 and falls back to 640x480 16-bit fullscreen, which crashes modern displays. Providing a windowed `th06.cfg` prevents startup resolution crashes. |
| `vpatch.ini` | Pre-configured VPatch configuration file. | Configured `enabled = 1`, `AskWindowMode = 0`, `Width = 960`, `Height = 720`, `GameFPS = 60` for smooth 60 FPS windowed gameplay. |
| `dgVoodoo.conf` & `dgVoodooCpl.exe` | Downloaded from `dege-diosg/dgVoodoo2` (v2.87.3). | Pre-configured `FullScreenMode = false` and `dgVoodooWatermark = false` as an optional D3D11/D3D12 DirectX wrapper backend. |
