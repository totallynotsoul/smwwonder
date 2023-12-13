@echo off
setlocal EnableDelayedExpansion
TITLE [%~4] Open Current Level's UberASM Code

set /a timer=1000

call %1
set /a digits2=%digits%+1
set /a digits3=%digits2%+7

echo(
echo(Level %~2 either has no UberASM code assigned to it, or the assigned file doesn't exist.
choice /c YN /n /m "Create one for it? [Y/N] "
if %errorlevel% == 1 (
	if not exist "%uber_path%\level\%~2.asm" (
	
		echo(; Level %~2's code>"%uber_path%\level\%~2.asm"
		echo(>>"%uber_path%\level\%~2.asm"
		echo(main:>>"%uber_path%\level\%~2.asm"
		echo(>>"%uber_path%\level\%~2.asm"
		echo(RTL>>"%uber_path%\level\%~2.asm"
		
		if "%~3" == "1" (
			call :replace_in_list
		) else (
			call :add_to_list
		)
		copy "%uber_path%\level\temp" "%uber_list%" >nul
		del "%uber_path%\level\temp"
		
		echo(
		echo(Created [%uber_path%\level\%~2.asm]
		pause
		start "" "!list_program!" "%uber_path%\level\%~2.asm"
		
		:loop:
		if not !timer! == 0 (
			set /a timer=!timer!-1
			goto loop
		)
	) else (
		echo(
		echo(There already Exists a file named %~2.asm, so the list has been updated to use that.
		if "%~3" == "1" (
			call :replace_in_list
		) else (
			call :add_to_list
		)
		copy "%uber_path%\level\temp" "%uber_list%" >nul
		del "%uber_path%\level\temp" >nul
		pause
		start "" "!list_program!" "%uber_path%\level\%~2.asm"
		
		:loop:
		if not !timer! == 0 (
			set /a timer=!timer!-1
			goto loop
		)
	)
)
exit


:replace_in_list
setlocal
for /f "tokens=1,* delims=]" %%a in ('
    find /n /v "" ^< "%uber_list%"
') do (
	set line_content=%%b
	
	if "!line_content:~0,%digits%!"=="!actualLevel!"  (
		>>"%uber_path%\level\temp" echo(%level% %level%.asm
		set replaced_level=1
	) else (
		if "!line_content!"=="" (set "line_content= ")
		>>"%uber_path%\level\temp" echo(%%b
	)
)
endlocal
exit /b

:add_to_list
setlocal
	
for /f "tokens=1,* delims=]" %%a in ('
    find /n /v "" ^< "%uber_list%"
') do (
	set line_content=%%b
	
	>>"%uber_path%\level\temp" echo(%%b
	if "!line_content:~0,6!"=="level:" (
		>>"%uber_path%\level\temp" echo(%level% %level%.asm
	)
)
endlocal
exit /b