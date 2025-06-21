@echo off

:: ==========================================
::   Configuration
:: ==========================================
setlocal

:: Show selection for timeserver
echo.
echo ----------------------------------------
echo     Select a time server:
echo ----------------------------------------
echo 1. ptbtime1.ptb.de        (Germany)
echo 2. time.cloudflare.com    (Global, Cloudflare)
echo 3. time.windows.com       (Microsoft, USA)
echo 4. time.nist.gov          (NIST, USA)
echo 5. Custom input
echo.

set /p choice="Choose an option (1, 2, 3, 4 or 5): "

if "%choice%"=="1" (
    set TIMESERVER=ptbtime1.ptb.de
) else if "%choice%"=="2" (
    set TIMESERVER=time.cloudflare.com
) else if "%choice%"=="3" (
    set TIMESERVER=time.windows.com
) else if "%choice%"=="4" (
    set TIMESERVER=time.nist.gov
) else if "%choice%"=="5" (
    set /p TIMESERVER="Enter your preferred time server: "
) else (
    echo [ERROR] Invalid choice. Exiting script.
    pause
    exit /b
)
echo [INFO] Time server set to: %TIMESERVER%

:: ==========================================
::   Initialization
:: ==========================================
cls
echo.
echo ----------------------------------------
echo          TIME SYNCHRONIZATION
echo ----------------------------------------
echo   (c) 2025 Open Source Project
echo   by https://github.com/Nirus2000
echo ----------------------------------------
echo.
echo [INFO] This script is intended for Windows 7 or higher.
echo.

:: ==========================================
::   System checks
:: ==========================================
call :CheckWindowsVersion
call :CheckAdminRights
call :CheckW32Time

:: ==========================================
::   Get system information
:: ==========================================
call :GetSystemInfo

:: ==========================================
::   Start synchronization
:: ==========================================
call :ConfigureTimeService
call :RestartTimeService
call :ForceSync
call :ShowSyncStatus

:: ==========================================
::   Function definitions
:: ==========================================
:CheckWindowsVersion
for /f "tokens=4-5 delims=. " %%a in ('ver') do (
	if %%a LSS 6 (
		echo.
		echo ----------------------------------------
		echo [ERROR] This script requires Windows 7 or higher!
		echo [NOTE] Please run the script on a compatible system.
		echo ----------------------------------------
		pause
		exit
	)
)
exit /b

:CheckAdminRights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Administrator rights required!
    echo [NOTE] Right-click this file and select "Run as administrator"
    pause
    exit
)
exit /b

:CheckW32Time
echo.
echo ----------------------------------------
echo [STATUS] Checking Windows Time service...
echo ----------------------------------------
sc query w32time | find "STOPPED" >nul
if %errorLevel% equ 0 (
    echo [WARNING] Windows Time service is stopped.
    echo [ACTION] Starting the service...
    net start w32time
    if %errorLevel% neq 0 (
        echo [ACTION] Attempting to repair the service...
        sc qc w32time >nul 2>&1
        if %errorLevel% neq 0 (
            echo [ACTION] Re-registering the service...
            w32tm /unregister
            w32tm /register
        )
        net start w32time
        if %errorLevel% neq 0 (
            echo [ERROR] Failed to start Windows Time service.
            echo [NOTE] Check group policies or contact your administrator.
            pause
            exit /b 1
        ) else (
            echo [SUCCESS] Windows Time service started successfully.
        )
    )
) else (
    echo [OK] Windows Time service is already running.
)
exit /b

:GetSystemInfo
for /f %%a in ('hostname') do set _HOSTNAME=%%a
set _USERNAME=%USERNAME%

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set _IP=%%a
if defined _IP (
    set _IP=%_IP: =%
) else (
    set _IP=Not detected
)

for /f "tokens=1 delims= " %%a in ('getmac ^| findstr /R /C:"[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]"') do set _MAC=%%a
if not defined _MAC set _MAC=Not detected

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "Default Gateway"') do set gateway=%%a
if not defined gateway set gateway=Not detected

for /f "tokens=2 delims=:" %%a in ('nslookup 8.8.8.8 ^| findstr "Address"') do set dns=%%a
if not defined dns set dns=Not detected

set _OS=%OS%

echo.
echo ----------------------------------------
echo           SYSTEM INFORMATION
echo ----------------------------------------
echo [INFO] PC Name: %_HOSTNAME%
echo [INFO] User: %_USERNAME%
echo [INFO] Operating System: %_OS%
echo [INFO] IP Address: %_IP%
echo [INFO] MAC Address: %_MAC%
echo [INFO] Default Gateway: %gateway%
echo [INFO] DNS Server: %dns%
echo [INFO] System Time: %date% %time%
exit /b

:ConfigureTimeService
echo.
echo ----------------------------------------
echo [ACTION] Checking and setting time server...
echo ----------------------------------------
:: Check if current default time server is already the desired one
for /f "tokens=2 delims==" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v NtpServer ^| findstr "NtpServer"') do set CURRENT_TIMESERVER=%%a
set CURRENT_TIMESERVER=%CURRENT_TIMESERVER: =%

if "%CURRENT_TIMESERVER%"=="%TIMESERVER%" (
    echo [INFO] Time server %TIMESERVER% is already set as default.
) else (
    echo [ACTION] Setting %TIMESERVER% as default time server...
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v NtpServer /t REG_SZ /d "%TIMESERVER%" /f
)

:: Check if TIMESERVER is already in the server list
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" | findstr /I "%TIMESERVER%" >nul
if %errorLevel% neq 0 (
    echo [ACTION] Adding %TIMESERVER% to server list...
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "1" /t REG_SZ /d "%TIMESERVER%" /f
) else (
    echo [INFO] Time server %TIMESERVER% is already in the list.
)

:: Set sync interval to 8 hours (28800 seconds)
echo [ACTION] Setting sync interval to 8 hours...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v SpecialPollInterval /t REG_DWORD /d 28800 /f

:: Enable NtpClient
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v Enabled /t REG_DWORD /d 1 /f

:: Set AnnounceFlags (recommended: 5)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v AnnounceFlags /t REG_DWORD /d 5 /f

:: Configure manual time sync
w32tm /config /manualpeerlist:"%TIMESERVER%" /syncfromflags:manual /update

:: Set time service to auto-start
sc config w32time start= auto

:: Restart service on failure
sc failure w32time reset= 0 actions= restart/60000/restart/60000/restart/60000

sc config w32time start= auto
exit /b

:RestartTimeService
echo.
echo ----------------------------------------
echo [ACTION] Restarting Windows Time service...
echo ----------------------------------------
net stop w32time
w32tm /unregister
timeout /t 5 /nobreak >nul
w32tm /register
timeout /t 5 /nobreak >nul
net start w32time
exit /b

:ForceSync
echo.
echo ----------------------------------------
echo [ACTION] Forcing immediate time sync...
echo ----------------------------------------
:: Apply config again
w32tm /config /manualpeerlist:"%TIMESERVER%" /syncfromflags:manual /update

:: Forced resync
w32tm /resync /force
if %errorLevel% neq 0 (
    echo [ERROR] Time synchronization failed.
    pause
    exit /b 1
) else (
    echo [SUCCESS] Time synchronization completed successfully.
)

:: Verify active time source
echo.
echo [STATUS] Current sync source:
w32tm /query /source
exit /b

:ShowSyncStatus
echo.
echo ----------------------------------------
echo [STATUS] Checking time server configuration...
echo ----------------------------------------
w32tm /query /status
w32tm /query /peers
echo.
echo =========================================
echo   Synchronization complete!
echo =========================================
echo [SUCCESS] Your system is now correctly synchronized with the time server.
echo [INFO] No further action required.
pause
exit
