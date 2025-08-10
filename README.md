# Lenovo Debian BootFix

A simple Windows batch script to quickly restore boot access to Debian after a Lenovo BIOS update removes or overwrites the Linux boot entry.

## Why this exists
Many Lenovo laptops remove custom EFI boot entries when the BIOS is updated. This often leaves Debian (and other Linux distros) unbootable until GRUB or another boot manager is restored.  
This script adds a **temporary UEFI boot entry** pointing to your Debian installation so you can boot immediately without a full reinstall or rescue media.

---

## Features
- Works entirely from Windows — no live USB required.
- No permanent changes to firmware (entry is temporary until reboot).
- Lightweight and portable (single `.bat` file).

---

## Requirements
- **Windows with Administrator privileges**
- Built-in Windows tools: `bcdedit` and `bcdboot`
- Knowledge of your Debian EFI partition location (usually `/boot/efi`)

---

## Usage (Windows)
1. Download `debian-bios.bat` from the [releases](./releases) section or clone this repo.
2. Open **Command Prompt as Administrator**  
   - Press `Win` → type **cmd** → right-click → **Run as administrator**.
3. Navigate to the folder containing `debian-bios.bat`.
4. Run:
   ```cmd
   debian-bios.bat
