@echo off
setlocal enabledelayedexpansion

REM === Step 1: Assign drive letter F: to EFI partition (Disk 0, Partition 1) ===
echo select disk 0 > diskpart_script.txt
echo select partition 1 >> diskpart_script.txt
echo assign letter=F >> diskpart_script.txt
echo exit >> diskpart_script.txt

diskpart /s diskpart_script.txt >nul
del diskpart_script.txt

REM Verify F: exists
if not exist F:\EFI\debian\shimx64.efi (
    echo ERROR: shimx64.efi not found on F:\EFI\debian\
    pause
    exit /b 1
)

REM === Step 2: Create a new boot entry copying current boot ===
for /f "tokens=2 delims={}" %%a in ('bcdedit /copy {current} /d "Shim Boot (One-Time)" 2^>nul') do (
    set GUID=%%a
)

if "!GUID!"=="" (
    echo ERROR: Failed to create new boot entry
    pause
    exit /b 1
)

set GUID={!GUID!}

REM === Step 3: Set device and path for the new boot entry ===
bcdedit /set %GUID% device partition=F:
bcdedit /set %GUID% path \EFI\debian\shimx64.efi

REM === Step 4: Configure boot manager to boot this entry only once ===
bcdedit /set {bootmgr} bootsequence %GUID%

echo One-time boot entry created successfully.
echo The system will reboot now and boot shim once.
timeout /t 5 /nobreak >nul

shutdown /r /t 0
