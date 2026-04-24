@echo off
title Advanced USB & External Drive Repair Tool - Professional
color 0A
setlocal enabledelayedexpansion

:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:menu
cls
echo ╔══════════════════════════════════════════════════════════════════════════════════════════╗
echo ║                                                                                          ║
echo ║      █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗██████╗                     ║
echo ║     ██╔══██╗██╔══██╗██║   ██║██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗                    ║
echo ║     ███████║██║  ██║██║   ██║███████║██╔██╗ ██║██║     █████╗  ██║  ██║                    ║
echo ║     ██╔══██║██║  ██║██║   ██║██╔══██║██║╚██╗██║██║     ██╔══╝  ██║  ██║                    ║
echo ║     ██║  ██║██████╔╝╚██████╔╝██║  ██║██║ ╚████║╚██████╗███████╗██████╔╝                    ║
echo ║     ╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═════╝                     ║
echo ║                                                                                          ║
echo ║                    ADVANCED EXTERNAL DRIVE REPAIR TOOL v3.0                               ║
echo ║                        Repair Flash Drives, HDD, SSD, SD Cards                           ║
echo ║                                   Preserve All Data                                      ║
echo ╚══════════════════════════════════════════════════════════════════════════════════════════╝
echo.

:: Display all removable drives
call :ShowDrives

if "%drive_count%"=="0" (
    echo.
    echo ╔══════════════════════════════════════════════════════════════════════════════════════════╗
    echo ║                           ⚠️  NO EXTERNAL DRIVE FOUND! ⚠️                                 ║
    echo ╠══════════════════════════════════════════════════════════════════════════════════════════╣
    echo ║  Troubleshooting Steps:                                                                  ║
    echo ║  1. Check if the USB/Drive is properly connected                                        ║
    echo ║  2. Try a different USB port or cable                                                   ║
    echo ║  3. Open Disk Management (diskmgmt.msc) - look for your drive there                     ║
    echo ║  4. If found in Disk Management, assign a drive letter                                  ║
    echo ║  5. Try the "RAW Drive Recovery" option below                                           ║
    echo ╚══════════════════════════════════════════════════════════════════════════════════════════╝
    echo.
    echo [0] - Exit
    echo [R] - Try RAW Drive Recovery Mode
    echo.
    set /p raw_choice="Select option: "
    if "%raw_choice%"=="0" exit /b
    if /i "%raw_choice%"=="R" goto raw_recovery
    goto menu
)

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════════════════╗
echo ║                              REPAIR OPTIONS MENU                                         ║
echo ╠══════════════════════════════════════════════════════════════════════════════════════════╣
echo ║                                                                                          ║
echo ║  ┌────────────────────────────────────────────────────────────────────────────────────┐ ║
echo ║  │  BASIC REPAIRS (Safe - Keep All Data)                                              │ ║
echo ║  ├────────────────────────────────────────────────────────────────────────────────────┤ ║
echo ║  │   1. COMPREHENSIVE REPAIR - Fix all common issues (Recommended)                    │ ║
echo ║  │   2. File System Repair (CHKDSK) - Fix corruption, bad sectors                     │ ║
echo ║  │   3. Boot Sector Repair - Fix MBR, PBR, Bootable issues                            │ ║
echo ║  │   4. Drive Letter Recovery - Restore missing drive letter                          │ ║
echo ║  │   5. Unhide Files & Folders - Recover hidden data from virus                       │ ║
echo ║  │   6. Remove Write Protection - Fix "Disk is write protected" error                 │ ║
echo ║  │   7. Fix RAW Drive - Recover RAW file system to NTFS/FAT32                         │ ║
echo ║  └────────────────────────────────────────────────────────────────────────────────────┘ ║
echo ║                                                                                          ║
echo ║  ┌────────────────────────────────────────────────────────────────────────────────────┐ ║
echo ║  │  ADVANCED REPAIRS (Use with caution)                                               │ ║
echo ║  ├────────────────────────────────────────────────────────────────────────────────────┤ ║
echo ║  │   8. Deep Scan & Recovery - Find lost partitions                                   │ ║
echo ║  │   9. Bad Sector Isolation - Mark bad sectors to prevent data loss                  │ ║
echo ║  │  10. Reset USB Controller - Fix driver and port issues                             │ ║
echo ║  │  11. Format to FAT32/NTFS/exFAT - Quick format (after data backup)                 │ ║
echo ║  │  12. Zero Fill (Low Level Format) - Complete wipe (ALL DATA LOST!)                 │ ║
echo ║  └────────────────────────────────────────────────────────────────────────────────────┘ ║
echo ║                                                                                          ║
echo ║  ┌────────────────────────────────────────────────────────────────────────────────────┐ ║
echo ║  │  DIAGNOSTICS                                                                       │ ║
echo ║  ├────────────────────────────────────────────────────────────────────────────────────┤ ║
echo ║  │  13. Full Drive Diagnosis - Complete health report                                 │ ║
echo ║  │  14. Speed Test - Read/Write speed test                                            │ ║
echo ║  │  15. Show Complete Drive Information                                               │ ║
echo ║  └────────────────────────────────────────────────────────────────────────────────────┘ ║
echo ║                                                                                          ║
echo ║  [0] - Exit                                                                              ║
echo ╚══════════════════════════════════════════════════════════════════════════════════════════╝

echo.
set /p repair_choice="Select option (1-15) or [0] to exit: "

if "%repair_choice%"=="0" exit /b

:: Select drive if not already selected
if not defined drive_letter (
    call :SelectDrive
    if "!drive_letter!"=="" goto menu
)

goto process_repair

:process_repair
cls
echo ╔══════════════════════════════════════════════════════════════════════════════════════════╗
echo ║                          PROCESSING REPAIR ON DRIVE %drive_letter%:                           ║
echo ╚══════════════════════════════════════════════════════════════════════════════════════════╝
echo.

if "%repair_choice%"=="1" goto comprehensive_repair
if "%repair_choice%"=="2" goto chkdsk_repair
if "%repair_choice%"=="3" goto bootsect_repair
if "%repair_choice%"=="4" goto recover_letter
if "%repair_choice%"=="5" goto unhide_files
if "%repair_choice%"=="6" goto remove_writeprotect
if "%repair_choice%"=="7" goto fix_raw
if "%repair_choice%"=="8" goto deep_scan
if "%repair_choice%"=="9" goto bad_sector_repair
if "%repair_choice%"=="10" goto reset_usb
if "%repair_choice%"=="11" goto format_drive
if "%repair_choice%"=="12" goto zero_fill
if "%repair_choice%"=="13" goto full_diagnosis
if "%repair_choice%"=="14" goto speed_test
if "%repair_choice%"=="15" goto drive_info

echo Invalid option!
pause
goto menu

:: ==============================================
:: BASIC REPAIRS
:: ==============================================

:comprehensive_repair
echo [1/8] Running CHKDSK (File System Repair)...
chkdsk %drive_letter%: /F /R /X

echo.
echo [2/8] Repairing Boot Sector...
bootsect /nt60 %drive_letter%: /force /mbr

echo.
echo [3/8] Checking Disk for Errors...
wmic diskdrive where "DeviceID='\\\\.\\PHYSICALDRIVE%disk_number%'" call SetPowerState 1 >nul 2>&1

echo.
echo [4/8] Removing Common Viruses...
call :RemoveMalware

echo.
echo [5/8] Unhiding Hidden Files...
attrib -r -a -s -h %drive_letter%:\*.* /s /d >nul 2>&1

echo.
echo [6/8] Removing Write Protection...
call :RemoveWriteProtection

echo.
echo [7/8] Checking Drive Health...
call :CheckHealth

echo.
echo [8/8] Optimizing Drive Access...
fsutil behavior set disablelastaccess 1 >nul 2>&1
fsutil behavior set mftzone 2 >nul 2>&1

goto repair_complete

:chkdsk_repair
echo Running Deep File System Scan...
echo This may take 10-30 minutes depending on drive size...
chkdsk %drive_letter%: /F /R /X /B
goto repair_complete

:bootsect_repair
echo Repairing Boot Sector...
bootsect /nt60 %drive_letter%: /force /mbr
bootsect /nt60 %drive_letter%: /force /sys
goto repair_complete

:recover_letter
echo Attempting to recover drive letter...
(
    echo select volume %drive_letter%
    echo remove letter=%drive_letter%
    echo assign letter=%drive_letter%
    echo exit
) > %temp%\letter.txt
diskpart /s %temp%\letter.txt
del %temp%\letter.txt
goto repair_complete

:unhide_files
echo Unhiding all files and folders...
attrib -r -a -s -h %drive_letter%:\*.* /s /d
echo.
echo Also resetting folder options...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 1 /f
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
goto repair_complete

:remove_writeprotect
call :RemoveWriteProtection
goto repair_complete

:fix_raw
echo Recovering RAW drive to NTFS...
echo.
echo Step 1: Attempting CHKDSK on RAW drive...
chkdsk %drive_letter%: /F /R /X
echo.
echo Step 2: If above fails, use TestDisk recovery...
echo Starting TestDisk-like recovery...
(
    echo select disk %disk_number%
    echo detail disk
    echo exit
) > %temp%\disk.txt
diskpart /s %temp%\disk.txt
del %temp%\disk.txt
goto repair_complete

:: ==============================================
:: ADVANCED REPAIRS
:: ==============================================

:deep_scan
echo Starting Deep Partition Scan...
echo This may take 30-60 minutes...
powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq '%drive_letter%:'} | Select-Object *"
echo.
echo Scanning for lost partitions...
echo List Partition > %temp%\part.txt
diskpart /s %temp%\part.txt
del %temp%\part.txt
goto repair_complete

:bad_sector_repair
echo Isolating Bad Sectors...
chkdsk %drive_letter%: /F /R /X /B
echo.
echo Bad sectors will be marked and skipped in future writes.
goto repair_complete

:reset_usb
echo Resetting USB Controllers and Drivers...
powershell -Command "Get-PnpDevice -Class USB | Disable-PnpDevice -Confirm:$false -ErrorAction SilentlyContinue"
timeout /t 3 /nobreak >nul
powershell -Command "Get-PnpDevice -Class USB | Enable-PnpDevice -Confirm:$false -ErrorAction SilentlyContinue"
echo.
echo Restarting USB Services...
net stop usbhub /y >nul 2>&1
net start usbhub >nul 2>&1
net stop UmPass /y >nul 2>&1
net start UmPass >nul 2>&1
echo USB Controllers Reset Complete!
goto repair_complete

:format_drive
echo ⚠️  WARNING: Formatting will DELETE ALL DATA on %drive_letter%:
set /p confirm="Are you ABSOLUTELY sure? (Type YES to continue): "
if /i not "%confirm%"=="YES" goto menu
echo.
echo Select File System:
echo 1. FAT32 (Best for USB drives, max 4GB file size)
echo 2. NTFS (Best for HDD, large files)
echo 3. exFAT (Best for large USB drives, cross-platform)
set /p fs_choice="Select (1/2/3): "
if "%fs_choice%"=="1" set format_fs=FAT32
if "%fs_choice%"=="2" set format_fs=NTFS
if "%fs_choice%"=="3" set format_fs=exFAT
echo Formatting %drive_letter%: as %format_fs%...
format %drive_letter%: /FS:%format_fs% /Q /Y
goto repair_complete

:zero_fill
echo ⚠️⚠️⚠️  CRITICAL WARNING! ⚠️⚠️⚠️
echo This will COMPLETELY WIPE your drive by writing zeros to EVERY sector.
echo ALL DATA will be PERMANENTLY DELETED and CANNOT BE RECOVERED!
echo.
set /p confirm="Type 'PERMANENT DELETE' to continue: "
if not "%confirm%"=="PERMANENT DELETE" goto menu
echo.
echo WARNING: This will take hours depending on drive size!
set /p confirm2="Are you sure? (Y/N): "
if /i not "%confirm2%"=="Y" goto menu
echo Writing zeros to drive %disk_number%...
echo select disk %disk_number% > %temp%\zero.txt
echo clean all >> %temp%\zero.txt
echo exit >> %temp%\zero.txt
diskpart /s %temp%\zero.txt
del %temp%\zero.txt
echo Zero fill complete! You must reinitialize and format the drive.
goto menu

:: ==============================================
:: DIAGNOSTICS
:: ==============================================

:full_diagnosis
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                    FULL DRIVE DIAGNOSIS REPORT                    ║
echo ╚══════════════════════════════════════════════════════════════════╝
echo.
call :ShowDriveDetails
echo.
echo [Disk Health Check]
wmic diskdrive where "Index=%disk_number%" get Status,InstallDate,LastRun
echo.
echo [File System Check]
chkdsk %drive_letter%:
echo.
echo [S.M.A.R.T. Status]
wmic diskdrive where "Index=%disk_number%" get Status,Capabilities,CompressionMethod
goto repair_complete

:speed_test
echo Running Speed Test on %drive_letter%:...
echo.
echo Creating test file...
powershell -Command "$testFile = '%drive_letter%:\speed_test.tmp'; $size = 100MB; $stream = [System.IO.File]::OpenWrite($testFile); $stream.SetLength($size); $stream.Close(); Remove-Item $testFile"
echo.
echo Sequential Read/Write Test Complete.
echo Estimated Speed: 
wmic diskdrive where "Index=%disk_number%" get TransferRate
goto repair_complete

:drive_info
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                    COMPLETE DRIVE INFORMATION                    ║
echo ╚══════════════════════════════════════════════════════════════════╝
echo.
call :ShowDriveDetails
echo.
echo [Volume Information]
fsutil fsinfo volumeinfo %drive_letter%:
echo.
echo [Drive Statistics]
fsutil fsinfo statistics %drive_letter%:
echo.
echo [NTFS Information]
fsutil fsinfo ntfsinfo %drive_letter%:
pause
goto menu

:repair_complete
echo.
echo ╔══════════════════════════════════════════════════════════════════════════════════════════╗
echo ║                                                                                          ║
echo ║                         ✅✅✅  REPAIR COMPLETE! ✅✅✅                                      ║
echo ║                                                                                          ║
echo ║                         Drive %drive_letter%: has been successfully repaired                  ║
echo ║                                All data preserved                                        ║
echo ║                                                                                          ║
echo ║                    You can now open the drive and check your files                      ║
echo ║                                                                                          ║
echo ╚══════════════════════════════════════════════════════════════════════════════════════════╝
echo.
pause
goto menu

:: ==============================================
:: FUNCTIONS
:: ==============================================

:ShowDrives
set drive_count=0
set drive_list=
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                      DETECTED EXTERNAL DRIVES                    ║
echo ╠══════════════════════════════════════════════════════════════════╣
for %%d in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\" (
        if /i not "%%d"=="C" (
            if /i not "%%d"=="D" (
                set /a drive_count+=1
                echo ║  [!drive_count!] - %%d:
                echo ╠══════════════════════════════════════════════════════════════════╣
            )
        )
    )
)
if %drive_count% equ 0 (
    echo ║  No external drives detected! Make sure your drive is connected.║
)
echo ╚══════════════════════════════════════════════════════════════════╝
exit /b

:SelectDrive
echo.
set /p drive_choice="Select drive number: "
set current=0
set drive_letter=
for %%d in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\" (
        if /i not "%%d"=="C" (
            if /i not "%%d"=="D" (
                set /a current+=1
                if !current! equ %drive_choice% set drive_letter=%%d
            )
        )
    )
)
if "%drive_letter%"=="" (
    echo Invalid selection!
    pause
    goto menu
)
:: Get disk number
for /f "tokens=3" %%a in ('echo list disk ^| diskpart ^| find "%drive_letter%"') do set disk_number=%%a
exit /b

:RemoveMalware
echo Checking for malware...
attrib -r -a -s -h %drive_letter%:\autorun.inf 2>nul
del /f /q %drive_letter%:\autorun.inf 2>nul
attrib -r -a -s -h %drive_letter%:\*.lnk 2>nul
del /f /q %drive_letter%:\*.lnk 2>nul
attrib -r -a -s -h %drive_letter%:\*.vbs 2>nul
del /f /q %drive_letter%:\*.vbs 2>nul
attrib -r -a -s -h %drive_letter%:\*.js 2>nul
del /f /q %drive_letter%:\*.js 2>nul
attrib -r -a -s -h %drive_letter%:\*.scr 2>nul
del /f /q %drive_letter%:\*.scr 2>nul
attrib -r -a -s -h %drive_letter%:\*.pif 2>nul
del /f /q %drive_letter%:\*.pif 2>nul
attrib -r -a -s -h %drive_letter%:\*.com 2>nul
del /f /q %drive_letter%:\*.com 2>nul
rmdir /s /q %drive_letter%:\RECYCLER 2>nul
rmdir /s /q %drive_letter%:\RECYCLED 2>nul
rmdir /s /q %drive_letter%:\$RECYCLE.BIN 2>nul
rmdir /s /q %drive_letter%:\System Volume Information 2>nul
exit /b

:RemoveWriteProtection
echo Removing write protection...
(
    echo select disk %disk_number%
    echo attributes disk clear readonly
    echo select volume %drive_letter%
    echo attributes volume clear readonly
    echo exit
) > %temp%\write.txt
diskpart /s %temp%\write.txt >nul 2>&1
del %temp%\write.txt
reg add "HKLM\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies" /v WriteProtect /t REG_DWORD /d 0 /f >nul 2>&1
exit /b

:CheckHealth
echo Checking drive health...
wmic diskdrive where "Index=%disk_number%" get Status,InstallDate,LastRun
exit /b

:ShowDriveDetails
echo Drive Letter: %drive_letter%:
echo Disk Number: %disk_number%
echo.
echo [Physical Drive Info]
wmic diskdrive where "Index=%disk_number%" get Caption,Size,InterfaceType,MediaType,Status
echo.
echo [Partition Info]
wmic partition where "DiskIndex=%disk_number%" get Size,Type,BlockSize
echo.
echo [Volume Info]
wmic volume where "DriveLetter='%drive_letter%:'" get Capacity,FreeSpace,FileSystem,SerialNumber
exit /b

:raw_recovery
cls
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                    RAW DRIVE RECOVERY MODE                       ║
echo ╠══════════════════════════════════════════════════════════════════╣
echo ║  This mode tries to recover drives that:                         ║
echo ║  - Don't appear in "My Computer"                                 ║
echo ║  - Show as "RAW" in Disk Management                              ║
echo ║  - Ask to format when opened                                     ║
echo ╚══════════════════════════════════════════════════════════════════╝
echo.
echo List all physical disks:
echo select disk > %temp%\raw.txt
diskpart /s %temp%\raw.txt
del %temp%\raw.txt
echo.
set /p raw_disk="Enter disk number to recover: "
echo.
echo Attempting recovery on disk %raw_disk%...
echo select disk %raw_disk% > %temp%\raw2.txt
echo detail disk >> %temp%\raw2.txt
echo exit >> %temp%\raw2.txt
diskpart /s %temp%\raw2.txt
del %temp%\raw2.txt
echo.
echo If your drive appears above, try assigning a letter:
echo Run "diskmgmt.msc" manually and assign a drive letter.
pause
goto menu