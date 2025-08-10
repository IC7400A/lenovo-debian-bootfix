@echo off
setlocal enabledelayedexpansion

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script must be run as Administrator.
    pause
    exit /b
)

echo =========================================
echo   Linux EFI Boot Entry Temporary Fix
echo   (Lenovo BIOS Update Recovery Tool)
echo =========================================
echo.

:: Step 1: Detect EFI System Partition
echo Searching for EFI System Partition...
for /f "tokens=2" %%a in ('mountvol ^| find ":\"') do (
    if exist "%%aEFI\" (
        set "EFI_DRIVE=%%a"
        goto :foundEFI
    )
)
echo ERROR: Could not locate EFI partition.
pause
exit /b

:foundEFI
echo Found EFI partition at %EFI_DRIVE%
echo.

:: Step 2: Search for known Linux distro folders in EFI
set "DISTRO_DIR="
for %%d in (debian ubuntu fedora arch manjaro opensuse elementary popos zorin) do (
    if exist "%EFI_DRIVE%EFI\%%d\" (
        set "DISTRO_DIR=%%d"
        goto :foundDistro
    )
)

echo ERROR: No known Linux EFI folder found on EFI partition.
pause
exit /b

:foundDistro
echo Found Linux distro: %DISTRO_DIR%
echo.

:: Step 3: Detect bootloader file (.efi)
set "BOOT_FILE="
if exist "%EFI_DRIVE%EFI\%DISTRO_DIR%\grubx64.efi" set "BOOT_FILE=grubx64.efi"
if exist "%EFI_DRIVE%EFI\%DISTRO_DIR%\shimx64.efi" set "BOOT_FILE=shimx64.efi"

if not defined BOOT_FILE (
    echo ERROR: Could not find grubx64.efi or shimx64.efi in %DISTRO_DIR%.
    pause
    exit /b
)

echo Using bootloader: %BOOT_FILE%
echo.

:: Step 4: Create temporary boot entry
for /f "tokens=3" %%b in ('bcdedit /create /d "%DISTRO_DIR% (Temporary Boot)" /application bootsector') do (
    set "BOOT_GUID=%%b"
)

:: Point boot entry to EFI loader
bcdedit /set %BOOT_GUID% device partition=%EFI_DRIVE:~0,2%
bcdedit /set %BOOT_GUID% path \EFI\%DISTRO_DIR%\%BOOT_FILE%
bcdedit /displayorder %BOOT_GUID% /addlast

echo Temporary boot entry created for %DISTRO_DIR%.
echo Select it at next boot to start Linux.
pause
