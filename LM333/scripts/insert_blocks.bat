@echo off
setlocal EnableDelayedExpansion
color E

call "scripts\check_for_config.bat" %1
set "rom_file=%1" & set "rom_name=%~n1" & set "LM_path=%cd%"
TITLE [%rom_name%] Insert Custom Blocks

echo(
if not exist "%gps_path%\GPS.exe" (
	echo(GPS.exe not found.
	echo([%gps_path%\GPS.exe]
	pause >nul
	exit
) else if not exist "%gps_list%" (
	echo(List file not found.
	echo([%gps_list%]
	pause >nul
	exit
) else if not exist "%gps_blocks%" (
	echo(Blocks folder not found.
	echo([%gps_blocks%]
	pause >nul
	exit
) else if not exist "%gps_routines%" (
	echo(Routines folder not found.
	echo([%gps_routines%]
	pause >nul
	exit
)

set "gps_path=%gps_path:\\=\%"
set "gps_list=%gps_list:\\=\%"
set "gps_blocks=%gps_blocks:\\=\%"
set "gps_routines=%gps_routines:\\=\%"

:: execute gps
cd /D %gps_path%
"gps.exe" -b "%gps_blocks:\=/%/" -l "%gps_list%" -s "%gps_routines:\=/%/" %rom_file:\=/%
echo(
if !errorlevel! == 0 (
	call :separator " Custom Block List "
	echo(
	type "%gps_list%"
	echo(
	echo(
	call :separator
	echo(
	call "%LM_path%\scripts\refresh_LM.exe" "%2" 2 >nul
)
pause
exit

:separator
setlocal
:: get string length
	echo(%~1>"%LM_path%\scripts\temp"
	FOR %%? IN ("%LM_path%\scripts\temp") DO ( SET /A strlength=%%~z? - 2 )

:: 	get window size
	mode>"%LM_path%\scripts\temp"
	set /a line=0
	for /F "usebackq tokens=*" %%a in ("%LM_path%\scripts\temp") do (
		if !line! == 3 (
		for %%L in (%%a) do set /a columns=%%L-1
		)
		set /a line=!line!+1
	)
	
:: create separator with string
	set /a halfcolumn=(!columns!-!strlength!)/2
	
:: create separator	
	set "separator="
	set /a count=0
	:loop:
	set separator=!separator!=
	set /a count=!count!+1
	if !count! LSS !halfcolumn! (goto :loop:)

:: adjust length if uneven value
	echo(!separator!%~1!separator!>"%LM_path%\scripts\temp"
	FOR %%? IN ("%LM_path%\scripts\temp") DO ( SET /A strlength=%%~z? - 2 )
	
	set "text=!separator!%~1!separator!"
	
	if !strlength! LSS !columns! (
		echo(!text!=
	) else (
		echo(!text!
	)
	
	del /Q "%LM_path%\scripts\temp"
endlocal
exit /b