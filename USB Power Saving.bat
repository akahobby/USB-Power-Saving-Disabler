@echo off
setlocal EnableExtensions EnableDelayedExpansion

title USB Sleep Guard

call :require_admin %*
if errorlevel 1 exit /b 1

call :init_colors
call :print_header
call :run_usb_update
if errorlevel 1 goto :cleanup_and_fail

call :parse_result
if errorlevel 1 goto :cleanup_and_fail

call :cleanup_temp
call :print_summary
pause
exit /b 0

:require_admin
if /i "%~1"=="__elevated" exit /b 0

>nul 2>&1 net session
if %errorlevel% equ 0 exit /b 0

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process -FilePath 'cmd.exe' -Verb RunAs -ArgumentList '/k','\"\"%~f0\" __elevated\"'"
exit /b 1

:init_colors
for /f "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"
set "CLR_RESET=%ESC%[0m"
set "CLR_INFO=%ESC%[96m"
set "CLR_OK=%ESC%[92m"
set "CLR_WARN=%ESC%[93m"
set "CLR_ERR=%ESC%[91m"
set "CLR_MUTED=%ESC%[90m"
set "CLR_TEXT=%ESC%[97m"
exit /b 0

:print_header
cls
echo %CLR_INFO%====================================================%CLR_RESET%
echo %CLR_INFO%                 USB Sleep Guard                    %CLR_RESET%
echo %CLR_INFO%====================================================%CLR_RESET%
echo.
echo %CLR_INFO%[*] Checking USB power-management flags...%CLR_RESET%
echo.
exit /b 0

:run_usb_update
set "OUT_FILE=%temp%\usb_guard_out_%random%%random%.txt"
set "ERR_FILE=%temp%\usb_guard_err_%random%%random%.txt"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$targets=Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi | Where-Object { $_.InstanceName -like '*USB*' };" ^
  "$switched=0;$unchanged=0;" ^
  "foreach($entry in $targets){" ^
  " if($entry.Enable){ $entry.Enable=$false; $null=$entry.Put(); $switched++ } else { $unchanged++ }" ^
  "}" ^
  "[Console]::WriteLine(('{0} {1} {2}' -f $switched,$unchanged,$targets.Count))" ^
  1> "%OUT_FILE%" 2> "%ERR_FILE%"

if %errorlevel% neq 0 (
  echo %CLR_ERR%[!] PowerShell execution failed.%CLR_RESET%
  if exist "%ERR_FILE%" (
    echo %CLR_MUTED%--- PowerShell output ---%CLR_RESET%
    type "%ERR_FILE%"
    echo %CLR_MUTED%------------------------%CLR_RESET%
  )
  exit /b 1
)

if not exist "%OUT_FILE%" (
  echo %CLR_ERR%[!] Missing result output.%CLR_RESET%
  exit /b 1
)
exit /b 0

:parse_result
set "RESULT_LINE="
set /p "RESULT_LINE=" < "%OUT_FILE%"

for /f "tokens=1,2,3" %%A in ("%RESULT_LINE%") do (
  set "updated_count=%%A"
  set "already_off_count=%%B"
  set "detected_count=%%C"
)

if not defined updated_count exit /b 1
if not defined already_off_count exit /b 1
if not defined detected_count exit /b 1
exit /b 0

:cleanup_temp
if defined OUT_FILE del "%OUT_FILE%" >nul 2>&1
if defined ERR_FILE del "%ERR_FILE%" >nul 2>&1
exit /b 0

:cleanup_and_fail
call :cleanup_temp
echo.
pause
exit /b 1

:print_summary
echo %CLR_OK%[SUCCESS] USB power-saving update finished.%CLR_RESET%
echo.
echo %CLR_MUTED%-----------------------------------------------%CLR_RESET%
echo %CLR_WARN% Updated entries   :%CLR_RESET% %CLR_TEXT%!updated_count!%CLR_RESET%
echo %CLR_WARN% Already disabled  :%CLR_RESET% %CLR_TEXT%!already_off_count!%CLR_RESET%
echo %CLR_WARN% Total USB entries :%CLR_RESET% %CLR_TEXT%!detected_count!%CLR_RESET%
echo %CLR_MUTED%-----------------------------------------------%CLR_RESET%
echo.
exit /b 0
