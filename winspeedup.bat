@echo off
REM Check if the script is running with administrative privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :skip
) else (
    echo Administrator permissions required. Restarting script...
    pause >nul
    cd /d "%~dp0"
    powershell Start-Process cmd.exe -ArgumentList '/c %~dpnx0' -Verb runAs
    exit /b
)

:skip
REM Disable Windows Search Indexing
net stop "WSearch"
sc config "WSearch" start= disabled

REM Disable Superfetch Service
sc config "SysMain" start= disabled
sc stop "SysMain"

REM Disable Windows Update Service
sc config "wuauserv" start= disabled
sc stop "wuauserv"

REM Disable Windows Error Reporting Service
sc config "WerSvc" start= disabled
sc stop "WerSvc"

REM Disable Windows Remote Management Service
sc config "WinRM" start= disabled
sc stop "WinRM"

REM Disable Diagnostic Tracking Service
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

REM Disable Background Apps
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f

REM Disable Prefetch and Superfetch
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f

REM Set Power Plan to High Performance
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

echo Windows speedup tweaks applied successfully!
pause>nul
