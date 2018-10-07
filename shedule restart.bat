@echo off
rem set to "on" or "off" to see all the output or not

echo ##################################################
echo #                                                #
echo #             Script Author  : SK                #
echo #             Script Version : 0.5               #
echo #                                                #
echo ##################################################
echo #                                                #
echo #        ! ! ! USE AT YOUR ONE RISK ! ! !        #
echo #     ! ! ! FOR INSTAL EDIT config.txt ! ! !     #
echo #               NO UASECO OUTPUT                 #
echo #           \uaseco\logs for more info           #
echo #                                                #
echo ##################################################
rem #####################################################################
rem #																	#
rem #		  	  !!! USE THIS SCRIPT ON YOUR OWN RISK !!!				#
rem #					   !!! I DONT CARE !!!							#
rem #																	#
rem #####################################################################
rem #																	#
rem #	!!! YOU NEED TO EDIT THE SERVER CONTROLLER START *.bat !!!		#
rem #																	#
rem #	  This script is writen for uaseco, for other controllers 		#
rem #	  you have to change more of this code.							#
rem #																	#
rem #	I highly recomend to use Notepad++ for script editing			#
rem #																	#
rem #	@ webrequest.bat 	add at top of code "title webrequest"		#
rem #	@ uaseco.bat		add at top of code "title uaseco"			#
rem #																	#
rem #	This will give this .bat files a window title wich is needed	#
rem #	to find the required programm to kill it.						#
rem #																	#
rem #####################################################################
rem #																	#
rem #	To configurate this script for your needs, go to config.txt		#
rem #	there you can edit all the directoys and config files			#
rem #																	#
rem #	Author: SK														#
rem #																	#
rem #####################################################################

rem import of config.txt
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
)
rem shows the configuration
echo  Dedicated Server Root : %line1%
echo Server Controller Root : %line2%
echo           Shedule Time : %line3%
echo Name of webrequest.bat : %line4%
echo     Name of uaseco.bat : %line5%
echo             Title Pack : %line7%
echo     MatchSettings File : %line8%
echo  Dedicated Config File : %line9%

rem set config to values
set path_to_server=%line1%
set path_to_controller=%line2%
set restart_time=%line3%
set name_of_webrequest=%line4%
set name_of_uaseco=%line5%
set titlepack=%line7%
set matchsettings=%line8%
set dedicated_cfg=%line9%

rem TIME CALCULATING START
SET HOUR=%time:~0,2%
SET dtStamp9=0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%time:~0,2%%time:~3,2%%time:~6,2%
if "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) else (SET dtStamp=%dtStamp24%)
ECHO      TIME NOW AS STAMP : %dtStamp%                 

set STARTTIME=%dtStamp:~0,2%:%dtStamp:~2,2%:%dtStamp:~4,2%
echo      SCRIPT START TIME : %STARTTIME%             
set ENDTIME=%restart_time%
echo    SERVER RESTART TIME : %ENDTIME%  
           
rem converting time to seconds
set /A STARTTIME=(1%STARTTIME:~0,2%-100)*3600 + (1%STARTTIME:~3,2%-100)*60 + (1%STARTTIME:~6,2%-100)/100
set /A ENDTIME=(1%ENDTIME:~0,2%-100)*3600 + (1%ENDTIME:~3,2%-100)*60 + (1%ENDTIME:~6,2%-100)/100

rem calculating time to next restart at shedule time
set /A DURATION=%ENDTIME%-%STARTTIME%
echo        TIME DIFFERENCE : %DURATION% in seconds

rem real timeout without the server start delay
set /A TIMEOUT=%DURATION%-12
rem TIME CALCULATING END

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
start ManiaPlanetServer.exe /title=%titlepack% /game_settings=%matchsettings% /dedicated_cfg=%dedicated_cfg%
timeout /t 10 /nobreak
:start_uaseco
echo START UASECO SERVER CONTROLLER
cd "%path_to_controller%"

rem ########################################################################################################
rem  delete ">NUL" if you want to see the uaseco output, but it will be a mess
rem if you have problems to run uaseco you can view the log files in *\uaseco\logs for more info
rem ########################################################################################################
start /B %name_of_webrequest%
timeout /t 2 /nobreak
start /B %name_of_uaseco% >NUL



echo %TIMEOUT% SECONDS TO RESTART
timeout /t %TIMEOUT% /nobreak
echo KILLING MANIAPLANETSERVER AND UASECO

rem this will kill server controller and dedicated server
tasklist /V /FI "WINDOWTITLE eq uaseco" | find /I "uaseco" >NUL && (taskkill /FI "WINDOWTITLE eq uaseco" /T /F)
tasklist /V /FI "WINDOWTITLE eq webrequest" | find /I "webrequest" >NUL && (taskkill /FI "WINDOWTITLE eq webrequest" /T /F)
taskkill /im ManiaPlanetServer.exe /f
timeout /t 15 /nobreak

rem this is the end of loop and jumps to begining of loop
goto loop