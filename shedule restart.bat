@echo off
rem set to "on" or "off" to see all the output or not

rem saves the curent location to value in order to know where to save the log file
set "batch_path=%cd%"

rem starting frame
set /p Build=<version.txt
type starter.txt
timeout /t 2 /nobreak

rem import config
< config.txt (
  set /p line1=
  set /p line2=
  set /p line3=
  set /p line4=
  set /p line5=
  set /p line6=
  set /p line7=
  set /p line8=
  set /p line9=
  set /p line10=
  set /p line11=
  set /p line12=
  set /p line13=
  set /p line14=
  set /p line15=
  set /p line16=
  set /p line17=
  set /p line18=
  set /p line19=
  set /p line20=
)

rem stripping start info of every used line
rem set config to values
set path_to_server=%line2:~22,999%
set path_to_controller=%line3:~23,999%
set restart_time=%line4:~13,999%
set name_of_webrequest=%line7:~23,999%
set name_of_uaseco=%line8:~19,999%
set mps_exe=%line11:~13,999%
set titlepack=%line12:~11,999%
set matchsettings=%line13:~20,999%
set dedicated_cfg=%line14:~22,999%
set u_output=%line17:~14,999%
set debug_info=%line18:~11,999%
set restart_count=0
rem shows the configuration
echo -----------------------------------------------------------
echo            Script Author  : SK               
echo            Script Version : %Build%             
echo -----------------------------------------------------------
echo           SCRIPT SETTINGS :
echo     Dedicated Server Root : %path_to_server%
echo    Server Controller Root : %path_to_controller%
echo              Shedule Time : %restart_time%
echo    Name of webrequest.bat : %name_of_webrequest%
echo        Name of uaseco.bat : %name_of_uaseco%
echo -----------------------------------------------------------
echo DEDICATED SERVER SETTINGS :
echo                Server.exe : %mps_exe%
echo                Title Pack : %titlepack%
echo        MatchSettings File : %matchsettings%
echo     Dedicated Config File : %dedicated_cfg%
echo -----------------------------------------------------------

rem TIME CALCULATING START
SET HOUR=%time:~0,2%
SET dtStamp9=0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%time:~0,2%%time:~3,2%%time:~6,2%
if "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) else (SET dtStamp=%dtStamp24%)
set STARTTIME=%dtStamp:~0,2%:%dtStamp:~2,2%:%dtStamp:~4,2%
set ENDTIME=%restart_time%
rem converting time to seconds
set /A STARTTIME=(1%STARTTIME:~0,2%-100)*3600 + (1%STARTTIME:~3,2%-100)*60 + (1%STARTTIME:~6,2%-100)/100
set /A ENDTIME=(1%ENDTIME:~0,2%-100)*3600 + (1%ENDTIME:~3,2%-100)*60 + (1%ENDTIME:~6,2%-100)/100
rem calculating time to next restart at shedule time
set /A DURATION=%ENDTIME%-%STARTTIME%
rem real timeout without the server start delay
set /A TIMEOUT=%DURATION%-12
rem TIME CALCULATING END
if %debug_info%==false (goto skip_debug_info) else (goto show_debug_info)
:show_debug_info
echo            DEBUGNING INFO :
echo             Uaseco output : %u_output%
echo         TIME NOW AS STAMP : %dtStamp%                 
echo         SCRIPT START TIME : %STARTTIME%             
echo       SERVER RESTART TIME : %ENDTIME%  
echo           TIME DIFFERENCE : %DURATION% in seconds
echo           RESTART COUNTER : %restart_count%
echo -----------------------------------------------------------
:skip_debug_info

rem this is checking if maniaplanet server is runing or not
SETLOCAL EnableExtensions
set EXE=ManiaPlanetServer.exe
FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %EXE%"') DO IF %%x == %EXE% goto FOUND
echo MANIAPLANET SERVER IS NOT RUNNING    
goto start_all
:FOUND
echo MANIAPLANET SERVER IS RUNNING  
goto start_uaseco

rem this is the begining of the loop
:loop
set init_config=0
:start_all
rem TIME CALCULATING START
SET HOUR=%time:~0,2%
SET dtStamp9=0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%time:~0,2%%time:~3,2%%time:~6,2%
if "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) else (SET dtStamp=%dtStamp24%)
set STARTTIME=%dtStamp:~0,2%:%dtStamp:~2,2%:%dtStamp:~4,2%
set ENDTIME=%restart_time%

rem converting time to seconds
set /A STARTTIME=(1%STARTTIME:~0,2%-100)*3600 + (1%STARTTIME:~3,2%-100)*60 + (1%STARTTIME:~6,2%-100)/100
set /A ENDTIME=(1%ENDTIME:~0,2%-100)*3600 + (1%ENDTIME:~3,2%-100)*60 + (1%ENDTIME:~6,2%-100)/100

rem calculating time to next restart at shedule time
set /A DURATION=%ENDTIME%-%STARTTIME%

rem real timeout without the server start delay
set /A TIMEOUT=%DURATION%-12
rem TIME CALCULATING END

echo %DURATION% SECONDS TO RESTART
echo START MANIAPLANET SERVER
cd "%path_to_server%"
start %mps_exe% /title=%titlepack% /game_settings=%matchsettings% /dedicated_cfg=%dedicated_cfg%
timeout /t 10 /nobreak
:start_uaseco
echo START UASECO SERVER CONTROLLER
cd "%path_to_controller%"

start /B %name_of_webrequest%
timeout /t 2 /nobreak

rem starting uaseco with or without output, depends on config
if %u_output%==false (set "u_para=>NUL") else (set "u_para=")
start /B %name_of_uaseco% %u_para%

echo %TIMEOUT% SECONDS TO RESTART
timeout /t %TIMEOUT% /nobreak
echo KILLING MANIAPLANETSERVER AND UASECO

rem this will kill server controller and dedicated server
tasklist /V /FI "WINDOWTITLE eq uaseco" | find /I "uaseco" >NUL && (taskkill /FI "WINDOWTITLE eq uaseco" /T /F)
tasklist /V /FI "WINDOWTITLE eq webrequest" | find /I "webrequest" >NUL && (taskkill /FI "WINDOWTITLE eq webrequest" /T /F)
taskkill /im ManiaPlanetServer.exe /f
timeout /t 15 /nobreak

rem counting the restarts 
set restart_count=%restart_count%+1

rem saving the restart count in a log file
cd %batch_path%
set "write1=Total Restart Count till crash: %restart_count%"
(
  echo %write1%
) > log.txt

rem reading config for next run
< config.txt (
  set /p line1=
  set /p line2=
  set /p line3=
  set /p line4=
  set /p line5=
  set /p line6=
  set /p line7=
  set /p line8=
  set /p line9=
  set /p line10=
  set /p line11=
  set /p line12=
  set /p line13=
  set /p line14=
  set /p line15=
  set /p line16=
  set /p line17=
  set /p line18=
  set /p line19=
  set /p line20=
)

rem stripping start info of every used line
rem set config to values
set path_to_server=%line2:~22,999%
set path_to_controller=%line3:~23,999%
set restart_time=%line4:~13,999%
set name_of_webrequest=%line7:~23,999%
set name_of_uaseco=%line8:~19,999%
set mps_exe=%line11:~13,999%
set titlepack=%line12:~11,999%
set matchsettings=%line13:~20,999%
set dedicated_cfg=%line14:~22,999%
set u_output=%line17:~14,999%
set debug_info=%line18:~11,999%

echo -----------------------------------------------------------
echo           SCRIPT SETTINGS :
echo     Dedicated Server Root : %path_to_server%
echo    Server Controller Root : %path_to_controller%
echo              Shedule Time : %restart_time%
echo    Name of webrequest.bat : %name_of_webrequest%
echo        Name of uaseco.bat : %name_of_uaseco%
echo -----------------------------------------------------------
echo DEDICATED SERVER SETTINGS :
echo                Title Pack : %titlepack%
echo        MatchSettings File : %matchsettings%
echo     Dedicated Config File : %dedicated_cfg%
echo -----------------------------------------------------------
if %debug_info%==false (goto skip_debug_info2) else (goto show_debug_info2)
:show_debug_info2
echo            DEBUGNING INFO :
echo             Uaseco output : %u_output%
echo         TIME NOW AS STAMP : %dtStamp%                 
echo         SCRIPT START TIME : %STARTTIME%             
echo       SERVER RESTART TIME : %ENDTIME%  
echo           TIME DIFFERENCE : %DURATION% in seconds
echo           RESTART COUNTER : %restart_count%
echo -----------------------------------------------------------
:skip_debug_info2
rem this is the end of loop and jumps to begining of loop
goto loop