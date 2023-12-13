@echo off
setlocal EnableDelayedExpansion
color 70

call "scripts\check_for_config.bat" %1
set "rom_file=%1" & set "rom_name=%~n1" & set "LM_path=%cd%"
TITLE [%rom_name%] Apply Music to ROM

if not exist "%AMK_path%\AddmusicK.exe" (
	echo(AddmusicK.exe not found.
	echo([%AMK_path%\AddmusicK.exe]
	pause >nul
	exit
)

set LM_path=%cd%

cd /D %AMK_path%

"AddmusicK.exe" %rom_file%
call "%LM_path%\scripts\refresh_LM.exe" "%2" 2 
pause >nul