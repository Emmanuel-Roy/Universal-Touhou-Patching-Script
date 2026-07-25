# Touhou-Classic-Windows11-ARM64-Fix

A self-contained, single-script installer (**`Install-Touhou-Fix.ps1`**) that **automatically downloads and installs the English translation patches** for classic Touhou games (**Touhou 6, 7, and 8**) and gets them running natively on modern **Windows 10 / Windows 11 (x86, x64, and ARM64 PCs)**.

Fixes startup crashes, 640x480 resolution mode switch errors, 1000 FPS hyper-speed bugs, and `thcrap` `"failed to learn d3dx9_43.dll"` warnings in one click.

---

## 🎮 Supported Games

* **Touhou 6: The Embodiment of Scarlet Devil** (`th06`)
* **Touhou 7: Perfect Cherry Blossom** (`th07`)
* **Touhou 8: Imperishable Night** (`th08`)

---

## 🌐 Automatic English Translation Patching

**You do NOT need to configure THCRAP manually.**

When you run `Install-Touhou-Fix.ps1`, it automatically:
1. Downloads the official **THCRAP (Touhou Community Reliant Automatic Patcher)** engine from GitHub.
2. Auto-detects which games are installed (`th06`, `th07`, `th08`).
3. Downloads & links the official English translation patch stack (`lang_en`, `base_tsa`, `script_latin`, `western_name_order`).
4. Generates direct double-clickable English launcher shortcuts (`th06 (thpatch-en).exe`, `th07 (thpatch-en).exe`, `th08 (thpatch-en).exe`).

---

## ⚡ Quick Start (Single-Script Automated Setup)

1. Download **`Install-Touhou-Fix.ps1`** and place it inside your Touhou game folder (TH06, TH07, or TH08).
2. Right-click **`Install-Touhou-Fix.ps1`** -> **Run with PowerShell** (or run `powershell -ExecutionPolicy Bypass -File .\Install-Touhou-Fix.ps1`).
3. The script automatically:
   - Detects which Touhou game(s) are present (`th06`, `th07`, `th08`)
   - Creates standardized executables (`th06.exe`, `th07.exe`, `th08.exe`)
   - **Downloads and installs the THCRAP English translation patches for each game**
   - Downloads & installs Crosire `d3d8to9` wrapper (`d3d8.dll` v1.15.1)
   - Downloads & extracts Microsoft `d3dx9_43.dll` 32-bit runtime
   - Pre-configures Windowed Mode (`th06.cfg`/`th07.cfg`/`th08.cfg`) and 60 FPS VPatch (`vpatch.ini`)
   - **Skips downloading components if they are already installed!**
4. **Launch and play**: Double-click `th06 (thpatch-en).exe`, `th07 (thpatch-en).exe`, or `th08 (thpatch-en).exe`!

---

## 🕹️ All Launch & Play Options

Once the script completes, you have full access to **all 4 launch modes**:

| Play / Launch Option | How to Launch | Description |
|---|---|---|
| **1. English Translation Patch (`thcrap`)** | Double-click `th06 (thpatch-en).exe` / `th07 (thpatch-en).exe` / `th08 (thpatch-en).exe`<br>*(or run `thcrap\bin\thcrap_loader.exe thpatch-en.js <game>`)* | Full live English translation patch stack automatically installed & configured. |
| **2. 60 FPS VPatch** | Double-click `vpatch.exe` | Locks game framerate to 60 FPS, fixes input latency, and runs in configured window size (960x720). |
| **3. Original Unpatched Game** | Double-click `th06.exe` / `th07.exe` / `th08.exe` | Native unpatched game executable with Direct3D 8 -> 9/12 hardware acceleration. |
| **4. Settings & Controller Config** | Double-click `custom.exe` | Official configuration utility for pad input, graphics depth, and audio settings. |

---

## 🛠️ Step-by-Step Guide: From CD Rip to Playable

1. **Base Game Setup**: Copy or extract your physical Japanese CD rip of Touhou 6, 7, or 8 into a folder on your PC (e.g. `C:\Games\Touhou 6`).
2. **Run Script**: Drop `Install-Touhou-Fix.ps1` into the folder and run it with PowerShell.
3. **Play**: Double-click `th06 (thpatch-en).exe` to play in English!
