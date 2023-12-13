@echo off
setlocal EnableDelayedExpansion
color 6

call "scripts\check_for_config.bat" %1
set "rom_file=%1" & set "rom_name=%~n1" & set "LM_path=%cd%"
TITLE [%rom_name%] Apply ASM Patches From List

echo(
if not exist "%asar_path%\asar.exe" (
	echo(asar.exe not found.
	echo([%asar_path%\asar.exe]
	pause >nul
	exit
) else if not exist "%patch_list%" (
	echo(List file not found.
	echo([%patch_list%]
	pause >nul
	exit
) else if not exist "%patch_folder%" (
	echo(Patch folder not found.
	echo([%patch_folder%]
	pause >nul
	exit
)

cd /D %asar_path%
set asar_path=%cd%
cd /D %patch_folder%
set patch_folder=%cd%

set /a total_errors=0

for /F "usebackq tokens=*" %%a in ("%patch_list%") do (
	set foundfile=0
	call :separator "[%%~a]"
	echo(
	if /I exist "%%~fa" (
		color 6
		"%asar_path%\asar.exe" -v "%%~fa" %rom_file%
		if !errorlevel! == 1 (
			set /a total_errors=!total_errors!+1
			color C
			echo(Press any button to proceed.
			pause >nul
		)
		set foundfile=1
	)
	if !foundfile!==0 (			
		set /a total_errors=!total_errors!+1
		color C
		echo(File '%%~a' not found.
		pause
	)
	echo(
) 
color 6
set "plural=s were"
if !total_errors! == 0 (color B) else if !total_errors! == 1 (set "plural= was")
call :separator
echo(
echo(Insertion finished. !total_errors! error%plural% encountered during insertion.
echo(Press any button to close this window.
pause >nul

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