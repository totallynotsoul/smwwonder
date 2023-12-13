@echo off
setlocal EnableDelayedExpansion
color 0

set "rom_file=%1" & set "rom_name=%~n1" & set "LM_path=%cd%"
TITLE [%rom_name%] Apply UberASM From Library to Level

if not exist "%~dp1config.bat" (
	start "" "scripts\error.bat"
	exit
) else (
	set rom_path=%~dp1
	call "%~dp1config.bat"
)

if not exist "%uber_path%\UberASMTool.exe" (
	echo(
	echo(UberASMTool.exe not found.
	echo([%uber_path%\UberASMTool.exe]
	pause >nul
	exit
) else if not exist "%uber_path%\library\" (
	echo(
	echo(Library folder not found.
	echo([%uber_path%\library]
	pause >nul
	exit
)

set /a line=0
for /f "usebackq tokens=1 delims= " %%a in ("%uber_list%") do (
	if "%%a" == "%~2" (
		set /a subline=0
		for /f "usebackq tokens=2 delims= " %%b in ("%uber_list%") do (
			set /a subline=!subline!+1
			if !subline! == !line! (
				if exist "%uber_path%\level\%%b" (
					echo(
					echo(This level already has an UberASM file. [%%b]
					choice /c YN /n /m "Overwrite it anyway? [Y/N]"
					if !errorlevel! == 1 (cls)
					if !errorlevel! == 2 (exit)
				)	
			)
		)
	)
	set /a line=!line!+1
)

set level=%~2

set choices=AC
echo(
echo( This pulls files from the UberASM library folder.
echo(
echo( A - Apply selected files
echo( C - Cancel
echo(
		
set /a file_num=0
:: search in main folder
for /f "tokens=*" %%a in ('dir /b /o:n "%uber_path%\library\*.asm"') do (
		set /a file_num=!file_num!+1
		echo( !file_num! - %%~nxa
		set choices=!choices! !file_num!
		set "file_list[!file_num!]=%%~nxa"
)

:: search all subfolders
FOR /f "tokens=*" %%i in ('DIR /a:d /o:n /b "%uber_path%\library\"') DO (
	for /f "tokens=*" %%a in ('dir /b /o:n "%uber_path%\library\%%~i\*.asm"') do (
		set /a file_num=!file_num!+1
		echo( !file_num! - %%~i\%%~nxa
		set choices=!choices! !file_num!
		set "file_list[!file_num!]=%%~i\%%~nxa"
	)
)

echo(
echo(Select files you want inserted to level %~2:

:: check choices one by one

for %%a in (%choices:~3%) do set choices_array[%%a]=%%a

set no_selection=1
set i=%choices:~3%
set /a j=1
:loop
	choice /c %choices: =% >nul
	
	if %errorlevel% == 1 (
		goto end_loop
	) else if %errorlevel% == 2 (
		exit
	) else if %errorlevel% GTR 2 (
		set /a val=%errorlevel%-2
		set level_array[%val%]=%val%
	)
	
	:: make sure you didn't input this choice already for it to count
	set invalid=0
	for %%a in (%choices:~3%) do (
		if not "!chosen[%%a]!" == "" (
			if !level_array[%val%]! == !chosen[%%a]! set invalid=1
		)
	)
	
	if %invalid% == 0 (
		set no_selection=0
		set chosen[%j%]=%val%
		set level_string=%level_string%%val% 
		set /a j=%j%+1
		set i=%i:~2%
		for %%d in ("%uber_path%\library\!file_list[%val%]!") do echo(  %val% - %%~nxd
	)
	
	if not "%i%" == "" (goto loop)
:end_loop

echo("; Level %~2's code">temp
echo("">>temp
echo("macro call_library(i)">>temp
echo("   PHB">>temp
echo("   LDA.b #<i>>>16">>temp
echo("   PHA">>temp
echo("   PLB">>temp
echo("   JSL <i>">>temp
echo("   PLB">>temp
echo("endmacro">>temp
echo("">>temp
echo("">>temp
echo("init:">>temp

call :check_label init

echo("RTL">>temp
echo("">>temp
echo("main:">>temp

call :check_label main


echo("RTL">>temp
echo("">>temp
echo("nmi:">>temp

call :check_label nmi

echo("RTL">>temp


echo(>"%uber_path%\level\%~2.asm"
for /F "usebackq tokens=*" %%a in ("temp") do (
	echo(%%~a>>"%uber_path%\level\%~2.asm"
)
del "temp"

:: now change the list file

for /f "tokens=1,* delims=]" %%a in ('
    find /n /v "" ^< "%uber_list%"
') do (
	set line_content=%%b
	
	if "!line_content:~0,3!"=="%~2"  (
		if %no_selection% == 0 (>>"%uber_path%\level\temp" echo(%~2 %~2.asm)
		set replaced_level=1
	) else (
		if "!line_content!"=="" (set "line_content= ")
		>>"%uber_path%\level\temp" echo(%%b
	)
)

if not !replaced_level! == 1 (
::	echo(>"%uber_path%\level\temp"
del "%uber_path%\level\temp"
	
	for /f "tokens=1,* delims=]" %%a in ('
    find /n /v "" ^< "%uber_list%"
') do (
		set line_content=%%b
		
		>>"%uber_path%\level\temp" echo(%%b
		if "!line_content:~0,6!"=="level:" (
			if %no_selection% == 0 (>>"%uber_path%\level\temp" echo(%~2 %~2.asm)
		)
	)
)

copy "%uber_path%\level\temp" "%uber_list%" >nul
del "%uber_path%\level\temp"
if %no_selection% == 1 (del "%uber_path%\level\%~2.asm")

set LM_path=%cd%

echo(
cd /D %uber_path%
"%uber_path%\UberASMTool.exe" "%uber_list%" %rom_file%

call "%LM_path%\scripts\refresh_LM.exe" "%3" 2

exit

:check_label
for %%a in (%level_string%) do (
	set found_label=0
	set /a line=0
	for /F "usebackq tokens=1* delims=;" %%b in ("%uber_path%\library\!file_list[%%a]!") do (
		set /a line=!line!+1
		set line_content=%%b
		if not "!line_content:%1=!"=="!line_content!" (
			:: echo(!line! !line_content!
			set found_label=1
		)
	)
	if !found_label! == 1 (
		for %%l in ("!file_list[%%a]!") do (
			set labelname=%%~l
			set labelname=!labelname:\=/!
			set labelname=!labelname:/=_!
			echo("%%call_library(!labelname:~0,-4!_%1)">>temp
		)
	)
)
exit /b