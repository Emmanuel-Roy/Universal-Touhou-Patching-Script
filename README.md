# Touhou-Classic-Windows11-ARM64-Fix

A self-contained, single-script installer (**`Install-Touhou-Fix.ps1`**) to run classic Touhou games (**Touhou 6, 7, and 8**) natively on modern **Windows 10 / Windows 11 (x86, x64, and ARM64 PCs)**.

Fixes startup crashes, 640x480 resolution mode switch errors, 1000 FPS hyper-speed bugs, and `thcrap` `"failed to learn d3dx9_43.dll"` warnings in one click.

---

## 🎮 Supported Games

* **Touhou 6: The Embodiment of Scarlet Devil** (`th06`)
* **Touhou 7: Perfect Cherry Blossom** (`th07`)
* **Touhou 8: Imperishable Night** (`th08`)

---

## ⚡ Quick Start (Single-Script Automated Setup)

1. Download **`Install-Touhou-Fix.ps1`** and place it inside your Touhou game folder (TH06, TH07, or TH08).
2. Right-click **`Install-Touhou-Fix.ps1`** -> **Run with PowerShell** (or run `powershell -ExecutionPolicy Bypass -File .\Install-Touhou-Fix.ps1`).
3. The script automatically:
   - Detects which Touhou game(s) are present (`th06`, `th07`, `th08`)
   - Creates standardized executables (`th06.exe`, `th07.exe`, `th08.exe`)
   - Downloads & installs Crosire `d3d8to9` wrapper (`d3d8.dll` v1.15.1)
   - Downloads & extracts Microsoft `d3dx9_43.dll` 32-bit runtime
   - Downloads, installs & configures `thcrap` English translation patch
   - Pre-configures Windowed Mode (`th06.cfg`/`th07.cfg`/`th08.cfg`) and 60 FPS VPatch (`vpatch.ini`)
   - **Skips downloading components if they are already installed!**

---

## 🕹️ All Launch & Play Options

Once the script completes, you have full access to **all 4 launch modes**:

| Play / Launch Option | How to Launch | Description |
|---|---|---|
| **1. English Translation Patch (`thcrap`)** | Double-click `th06 (thpatch-en).exe`<br>*(or run `thcrap\bin\thcrap_loader.exe thpatch-en.js <game>`)* | Full live English translation patch stack with live updates. |
| **2. 60 FPS VPatch** | Double-click `vpatch.exe` | Locks game framerate to 60 FPS, fixes input latency, and runs in configured window size (960x720). |
| **3. Original Unpatched Game** | Double-click `th06.exe` / `th07.exe` / `th08.exe` | Native unpatched game executable with Direct3D 8 -> 9/12 hardware acceleration. |
| **4. Settings & Controller Config** | Double-click `custom.exe` | Official configuration utility for pad input, graphics depth, and audio settings. |

---

## 🛠️ Step-by-Step Guide: From CD Rip to Playable

1. **Base Game Setup**: Copy or extract your physical Japanese CD rip of Touhou 6, 7, or 8 into a folder on your PC (e.g. `C:\Games\Touhou 6`).
2. **Run Script**: Drop `Install-Touhou-Fix.ps1` into the folder and run it with PowerShell.
3. **Play**: Pick any of the launch options above and start playing!
