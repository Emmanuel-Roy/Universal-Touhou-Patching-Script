# Universal Touhou Patching Script

> [!NOTE]
> **This project was vibe-coded.** ⚡
> Built to get the complete Touhou series running seamlessly on modern Windows 10/11 & ARM64 hardware with zero hassle.

---

A single, self-contained batch file (**`Install-Touhou-Fix.bat`**) that **automatically downloads, installs, and configures English translation patches for ALL Touhou Windows games (Touhou 06 through Touhou 20)** and gets them running natively on modern **Windows 10 / Windows 11 (x86, x64, and ARM64 PCs)**.

Fixes startup crashes, 640x480 resolution mode switch errors, 1000 FPS hyper-speed bugs, missing DirectX runtimes, and `thcrap` `"failed to learn d3dx9_43.dll"` warnings in one click.

---

## 🎮 Supported Games (Touhou 06 – Touhou 20)

| Game ID | Full Title | x86 / x64 (Tested) | ARM64 (Tested) |
|---|---|:---:|:---:|
| **th06** | Touhou 06: The Embodiment of Scarlet Devil | | | ✅ |
| **th07** | Touhou 07: Perfect Cherry Blossom | | | ✅ |
| **th08** | Touhou 08: Imperishable Night | | | ✅ |
| **th09** | Touhou 09: Phantasmagoria of Flower View | | | ✅ |
| **th095** | Touhou 09.5: Shoot the Bullet | | | ✅ |
| **th10** | Touhou 10: Mountain of Faith | | | ✅ |
| **th105** | Touhou 10.5: Scarlet Weather Rhapsody | | |
| **th11** | Touhou 11: Subterranean Animism | | | ✅ |
| **th12** | Touhou 12: Undefined Fantastic Object | | ✅ |
| **th123** | Touhou 12.3: Hisoutensoku | | |
| **th125** | Touhou 12.5: Double Spoiler | | | ✅ |
| **th128** | Touhou 12.8: Fairy Wars | | | ✅ |
| **th13** | Touhou 13: Ten Desires | | | ✅ |
| **th135** | Touhou 13.5: Hopeless Masquerade | | | ✅ |
| **th14** | Touhou 14: Double Dealing Character | | | ✅ |
| **th143** | Touhou 14.3: Impossible Spell Card | | | ✅ |
| **th145** | Touhou 14.5: Urban Legend in Limbo | | |
| **th15** | Touhou 15: Legacy of Lunatic Kingdom | | | ✅ |
| **th155** | Touhou 15.5: Antinomy of Common Flowers | | |
| **th16** | Touhou 16: Hidden Star in Four Seasons | | | ✅ |
| **th165** | Touhou 16.5: Secret Sealing Auto-dap | | | ✅ |
| **th17** | Touhou 17: Wily Beast and Weakest Creature | | | ✅ |
| **th175** | Touhou 17.5: Sunken Fossil World | | |
| **th18** | Touhou 18: Unconnected Marketeers | | | ✅ |
| **th185** | Touhou 18.5: 100th Black Market | | | ✅ |
| **th19** | Touhou 19: Unfinished Dream of All Living Ghost | | | ✅ |
| **th20** | Touhou 20: Fossilized Wonders | | | ✅ |

*(Note: Touhou 7.5 Immaterial and Missing Power is not supported by the THCRAP engine).*

> [!TIP]
> **How ARM64 Support Works for Older Games (TH06–TH08)**:
> Legacy DirectX 8 games natively call `d3d8.dll`, which Windows 11 ARM64 and modern GPUs do not support. The installer automatically injects Crosire's **`d3d8to9`** wrapper (`d3d8.dll`), translating DirectX 8 calls directly into Direct3D 9/12 to enable flawless execution on ARM64 hardware!

---

## ⚡ Quick Start (1-Click Double-Click Setup)

1. Download **`Install-Touhou-Fix.bat`** and drop it into your Touhou game folder (TH06 through TH20).
2. Double-click **`Install-Touhou-Fix.bat`**!
3. The script automatically:
   - Auto-detects which Touhou game(s) are present in the folder (`th06` – `th20`)
   - Creates standardized executables (`th06.exe` – `th20.exe`)
   - **Downloads and installs the THCRAP English translation patches for each game**
   - Downloads & installs Crosire `d3d8to9` wrapper (`d3d8.dll`) for legacy D3D8 games (enabling ARM64 compatibility)
   - Downloads & extracts Microsoft `d3dx9_43.dll` 32-bit runtime
   - Pre-configures Windowed Mode and 60 FPS VPatch (`vpatch.ini`)
   - **Skips downloading components if they are already installed!**
4. **Launch and play**: Double-click `<game> (thpatch-en).cmd` or `<game> (thpatch-en).exe`!

---

## 🕹️ All Launch & Play Options

Once the setup completes, you have full access to **all 4 launch modes**:

| Play / Launch Option | How to Launch | Description |
|---|---|---|
| **1. English Translation Patch (`thcrap`)** | Double-click `<game> (thpatch-en).cmd` / `<game> (thpatch-en).exe`<br>*(or run `thcrap\bin\thcrap_loader.exe thpatch-en.js <game>`)* | Full live English translation patch stack automatically installed & configured. |
| **2. 60 FPS VPatch** | Double-click `vpatch.exe` | Locks game framerate to 60 FPS, fixes input latency, and runs in configured window size (960x720). |
| **3. Original Unpatched Game** | Double-click `<game>.exe` | Native unpatched game executable with Direct3D hardware acceleration. |
| **4. Settings & Controller Config** | Double-click `custom.exe` | Official configuration utility for pad input, graphics depth, and audio settings. |
