@echo off
setlocal EnableDelayedExpansion
color 0

call "scripts\check_for_config.bat" %1
set "rom_file=%~1" & set "rom_name=%~n1"
set "current_level=%~3"
TITLE [%rom_name%] Open a Bookmark

echo(
if not exist "%bookmark_list%" (
	start "" scripts\error.bat "echo(Bookmark list not found." "echo([%bookmark_list%]"
	exit
)

set "LM_path=%cd%"

cd /D %resources_path%

set /a slot=1
set "selection=%2"
if "%2"=="choice" (
	
	for /F "usebackq tokens=*" %%i in ("%bookmark_list%") do (
		if not !slot! == 10 (
			echo( [!slot!] %%~i
			
			set /a slot=!slot!+1
		)
	)
	echo(
	echo( Select an entry or press M to exit this menu.
	choice /c 1234567890M >nul
	if !errorlevel!==11 (
		exit
	) else (
		set "selection=!errorlevel!"
	)
)

set /a errorlevel=0

set /a slot=1
for /F "usebackq tokens=*" %%i in ("%bookmark_list%") do (
	echo(%%i
	if !slot!==!selection! (
		
		start "" %%i
		
		if not !errorlevel!==0 (
			start "" "%LM_path%\scripts\error.bat" "echo(Program failed to execute." "echo([%%~i]"
		)
	)
	
	set /a slot=!slot!+1
	if !slot!==10 (
		set /a slot=0
	)
)
exit