# Touhou-Classic-Windows11-ARM64-Fix

A clean, drag-and-drop fix pack and automated one-stop installer to run classic Touhou games (**Touhou 6, 7, and 8**) natively on modern **Windows 10 / Windows 11 (x86, x64, and ARM64 PCs)**.

Fixes startup crashes, 640x480 resolution mode switch errors, framerate speedup bugs, and `thcrap` `"failed to learn d3dx9_43.dll"` warnings.

---

## 🎮 Supported Games

* **Touhou 6: The Embodiment of Scarlet Devil** (`th06`)
* **Touhou 7: Perfect Cherry Blossom** (`th07`)
* **Touhou 8: Imperishable Night** (`th08`)

---

## ⚡ One-Stop Automated Installer (`Install-Touhou-Fix.ps1`)

The script works on all modern Windows PCs (x86, x64, and ARM64).

1. Copy `Install-Touhou-Fix.ps1` (or this entire repo) into your Touhou game folder (TH06, TH07, or TH08).
2. Right-click `Install-Touhou-Fix.ps1` -> **Run with PowerShell** (or run `powershell -ExecutionPolicy Bypass -File .\Install-Touhou-Fix.ps1`).
3. The script automatically:
   - Detects which Touhou game(s) are present (`th06`, `th07`, `th08`)
   - Creates standardized executables (`th06.exe`, `th07.exe`, `th08.exe`)
   - Installs Crosire `d3d8to9` wrapper (`d3d8.dll`)
   - Installs Microsoft `d3dx9_43.dll` 32-bit runtime
   - Installs & configures `thcrap` English translation patch for all detected games
   - Configures Windowed Mode (`th06.cfg`/`th07.cfg`/`th08.cfg`) and 60 FPS VPatch (`vpatch.ini`)
   - **Skips downloading components if they are already installed!**
4. **Launch and play**: Double-click `th06 (thpatch-en).exe` (or run `thcrap\bin\thcrap_loader.exe thpatch-en.js <game>`)!

---

## 🛠️ Setup Guide: From CD Rip to Playable

### 📥 Step 1: Base Game Setup
1. Extract your physical Japanese CD rip of **Touhou 6, 7, or 8** into a folder (e.g. `C:\Games\Touhou 6`).
2. Make a copy of the main Japanese executable in the folder:
   - For TH06 (`東方紅魔郷.exe`): copy and rename to `th06.exe`
   - For TH07 (`東方妖々夢.exe`): copy and rename to `th07.exe`
   - For TH08 (`東方永夜抄.exe`): copy and rename to `th08.exe`

### 🚀 Step 2: Apply This Fix Pack (Drag & Drop or Script)
* **Automated**: Run `Install-Touhou-Fix.ps1` inside the folder.
* **Manual**: Copy and replace all files from this ZIP directly into your Touhou game folder.

---

## 📂 File Origins & What Was Done

| File | Where it came from | What was done |
|---|---|---|
| `Install-Touhou-Fix.ps1` | Custom automated PowerShell installer script. | One-stop script that auto-detects TH06, TH07, and TH08, downloads Crosire `d3d8to9`, Microsoft `d3dx9_43.dll`, installs `thcrap`, configures English translation patches, and sets up windowed mode & 60 FPS VPatch automatically. Skips downloading components if already present. Works on x86, x64, and ARM64 PCs. |
| `d3d8.dll` | Downloaded from Crosire's official `d3d8to9` GitHub release (`crosire/d3d8to9` v1.15.1). | Placed in the game folder as `d3d8.dll` to translate legacy DirectX 8 calls to Direct3D 9 / Direct3D 12. Modern GPU drivers (and ARM64 Qualcomm drivers) fail on native DirectX 8 calls; translating them to D3D9/D3D12 enables hardware acceleration and locks framerate for TH06, TH07, and TH08. |
| `d3dx9_43.dll` | Extracted from Microsoft's official DirectX End-User Runtimes June 2010 Redistributable (`Jun2010_d3dx9_43_x86.cab`). | Placed 32-bit x86 `d3dx9_43.dll` (v9.29.952.3111) in the game directory. This provides the missing D3DX9 helper library required by `thcrap` for font rendering and text overlay hooks across all Touhou games, resolving the `"failed to learn d3dx9_43.dll"` warning. |
| `th06.cfg` / `th07.cfg` / `th08.cfg` | Configured Touhou settings binary files. | Byte 0x02 set to `0x01` (Windowed Mode). On non-Japanese Windows, classic Touhou games fail to read Shift-JIS config file names under English ANSI codepage 1252 and fall back to 640x480 16-bit fullscreen, which crashes modern displays. Providing windowed config files prevents startup resolution crashes. |
| `vpatch.ini` | Pre-configured VPatch configuration file. | Configured `enabled = 1`, `AskWindowMode = 0`, `Width = 960`, `Height = 720`, `GameFPS = 60` for smooth 60 FPS windowed gameplay. |
| `dgVoodoo.conf` & `dgVoodooCpl.exe` | Downloaded from `dege-diosg/dgVoodoo2` (v2.87.3). | Pre-configured `FullScreenMode = false` and `dgVoodooWatermark = false` as an optional D3D11/D3D12 DirectX wrapper backend. |
