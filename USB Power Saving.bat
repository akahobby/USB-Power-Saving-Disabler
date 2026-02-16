@echo off
setlocal EnableExtensions EnableDelayedExpansion
title USB Power Saving Disabled

:: =========================================================
:: AUTO ELEVATE (robust) - relaunch via cmd.exe + flag
:: =========================================================
if /i not "%~1"=="__elevated" (
  >nul 2>&1 net session
  if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "Start-Process -FilePath 'cmd.exe' -Verb RunAs -ArgumentList '/k','\"\"%~f0\" __elevated\"'"
    exit /b
  )
)

:: =========================================================
:: ANSI COLOR SETUP
:: =========================================================
for /f "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"
set "C_RESET=%ESC%[0m"
set "C_RED=%ESC%[91m"
set "C_GREEN=%ESC%[92m"
set "C_YELLOW=%ESC%[93m"
set "C_CYAN=%ESC%[96m"
set "C_GRAY=%ESC%[90m"
set "C_WHITE=%ESC%[97m"

cls
echo %C_CYAN%====================================================%C_RESET%
echo %C_CYAN%              USB Power Saving Utility              %C_RESET%
echo %C_CYAN%====================================================%C_RESET%
echo.
echo %C_GRAY%Author:%C_RESET% %C_WHITE%akahobby%C_RESET%
echo.

echo %C_CYAN%[*] Scanning USB power settings...%C_RESET%
echo.

:: =========================================================
:: TEMP FILES
:: =========================================================
set "OUT=%temp%\usb_ps_out_%random%%random%.txt"
set "ERR=%temp%\usb_ps_err_%random%%random%.txt"

:: =========================================================
:: RUN POWERSHELL (writes one line: changed already total)
:: =========================================================
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$devices=Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi | Where-Object { $_.InstanceName -like '*USB*' };" ^
  "$changed=0;$already=0;" ^
  "foreach($d in $devices){" ^
  " if($d.Enable -eq $true){ $d.Enable=$false; $null=$d.Put(); $changed++ } else { $already++ }" ^
  "}" ^
  "[Console]::WriteLine(('{0} {1} {2}' -f $changed,$already,$devices.Count))" ^
  1> "%OUT%" 2> "%ERR%"

if %errorlevel% neq 0 (
  echo %C_RED%[!] PowerShell failed.%C_RESET%
  echo.
  if exist "%ERR%" (
    echo %C_GRAY%--- Error details ---%C_RESET%
    type "%ERR%"
    echo %C_GRAY%--------------------%C_RESET%
  )
  del "%OUT%" "%ERR%" >nul 2>&1
  echo.
  pause
  exit /b 1
)

if not exist "%OUT%" (
  echo %C_RED%[!] No output was produced.%C_RESET%
  del "%OUT%" "%ERR%" >nul 2>&1
  echo.
  pause
  exit /b 1
)

set /p "LINE=" < "%OUT%"
for /f "tokens=1,2,3" %%A in ("%LINE%") do (
  set "changed=%%A"
  set "already=%%B"
  set "total=%%C"
)

del "%OUT%" "%ERR%" >nul 2>&1

echo %C_GREEN%[SUCCESS] Operation Complete%C_RESET%
echo.
echo %C_GRAY%-----------------------------------------------%C_RESET%
echo %C_YELLOW% Changed           :%C_RESET% %C_WHITE%!changed!%C_RESET%
echo %C_YELLOW% Already Disabled  :%C_RESET% %C_WHITE%!already!%C_RESET%
echo %C_YELLOW% Total USB Entries :%C_RESET% %C_WHITE%!total!%C_RESET%
echo %C_GRAY%-----------------------------------------------%C_RESET%
echo.
pause
exit /b 0
