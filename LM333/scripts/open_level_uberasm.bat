@echo off
setlocal EnableDelayedExpansion
color 0

call "scripts\check_for_config.bat" %1
set "rom_file=%1" & set "rom_name=%~n1" & set "LM_path=%cd%"
TITLE [%rom_name%] Open Current Level's UberASM Code

set "config_path=%~dp1config!specified_rom!.bat"

set level=%~2
set level2=%level:~1%
set level3=%level:~2%

set file_exists=0

set /a line=0
set actualLevel=null
for /f "tokens=2 delims=] " %%a in ('find /n /v "" ^< "%uber_list%"') do (
	set /a line=!line!+1
	
	if %%a==%level% (
		set actualLevel=%level%
		set /a digits=3
	) else if %%a==%level2% (
		set actualLevel=%level2%
		set /a digits=2
	) else if %%a==%level3% (
		set actualLevel=%level3%
		set /a digits=1
	)
	
	if %%a==!actualLevel! (
		set level_in_list=1
		set /a subline=0
		for /f "tokens=2,* delims=] " %%c in ('find /n /v "" ^< "%uber_list%"') do (
			set /a subline=!subline!+1
			if !subline! == !line! (
				if not "%%d" == "" (
				echo."%uber_path%\level\%%d"
					if exist "%uber_path%\level\%%d" (
						set file_exists=1
						"%list_program%" "%uber_path%\level\%%d"
					)
				)
			)
		)
	)
)

if !file_exists! == 0 (
	start "" scripts\error_no_uberasm.bat "%config_path%" "%level%" "!level_in_list!" "%rom_name%"
)

exit