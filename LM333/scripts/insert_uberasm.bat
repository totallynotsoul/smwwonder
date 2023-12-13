@echo off
setlocal EnableDelayedExpansion
color F

call "scripts\check_for_config.bat" %1
set "rom_file=%1" & set "rom_name=%~n1" & set "LM_path=%cd%"
TITLE [%rom_name%] Apply UberASM Code

if not exist "%uber_path%\UberASMTool.exe" (
	echo(
	echo(UberASMTool.exe not found.
	echo([%uber_path%\UberASMTool.exe]
	pause >nul
	exit
)

set LM_path=%cd%
cd /D %uber_path%
"%uber_path%\UberASMTool.exe" "%uber_list%" %rom_file%

call "%LM_path%\scripts\refresh_LM.exe" "%2" 2