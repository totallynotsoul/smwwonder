@echo off
setlocal EnableDelayedExpansion
color 3

call "scripts\check_for_config.bat" %1
set "rom_file=%1" & set "rom_name=%~n1" & set "LM_path=%cd%"
TITLE [%rom_name%] Auto Insert All Custom Sprites

echo(
if not exist "%pixi_path%\pixi.exe" (
	echo(pixi.exe not found.
	echo([%pixi_path%\pixi.exe]
	pause >nul
	exit
) else if not exist "%sprites_path%" (
	echo(Sprite folder not found.
	echo([%sprites_path%]
	pause >nul
	exit
) else if not exist "%shooters_path%" (
	echo(Shooter sprites folder not found.
	echo([%shooters_path%]
	pause >nul
	exit
) else if not exist "%generators_path%" (
	echo(Generator sprites folder not found.
	echo([%generators_path%]
	pause >nul
	exit
) else if not exist "%extended_path%" (
	echo(Extended sprites folder not found.
	echo([%extended_path%]
	pause >nul
	exit
) else if not exist "%cluster_path%" (
	echo(Cluster sprites folder not found.
	echo([%cluster_path%]
	pause >nul
	exit
) else if not exist "%pixi_routines%" (
	echo(Routines folder not found.
	echo([%pixi_routines%]
	pause >nul
	exit
)

:: get full file paths from short ones

cd /D %pixi_path%
set pixi_path=%cd%
cd /D %sprites_path%
set sprites_path=%cd%
cd /D %shooters_path%
set shooters_path=%cd%
cd /D %generators_path%
set generators_path=%cd%
cd /D %extended_path%
set extended_path=%cd%
cd /D %cluster_path%
set cluster_path=%cd%
cd /D %pixi_routines%
set pixi_routines=%cd%
cd /D %LM_path%

echo(All custom sprites will be automatically sorted and inserted into the rom.
choice /c YN /n /m "Confirm this action? [Y/N] "
if %errorlevel% == 2 exit
echo(
echo(Overwrite the current sprite list file? [Y/N]
choice /c YN /n /m "(Caution: This removes comment lines)"
set /a overwrite=0
if %errorlevel% == 1 (set /a overwrite=1)

setlocal EnableDelayedExpansion
echo(

:: create auto list
	set "category="
	call :create_auto_lists
	set "category=EXTENDED"
	call :create_auto_lists
	set "category=CLUSTER"
	call :create_auto_lists
	
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: normal sprites
	set "current_path=%sprites_path%"
	set /a sprite_start=0
	set /a sprite_max=0xBF
	call :auto_create

:: shooter sprites
	set "current_path=%shooters_path%"
	set /a sprite_start=0xC0
	set /a sprite_max=0xCF-0xC0
	call :auto_create
	
:: generator sprites
	set "current_path=%generators_path%"
	set /a sprite_start=0xD0
	set /a sprite_max=0xFF-0xD0
	call :auto_create
	
:: extended sprites
	set "current_path=%extended_path%"
	set "category=EXTENDED"
	set /a sprite_start=0x00
	set /a sprite_max=0xFF
	call :auto_create_2

:: cluster sprites
	set "current_path=%cluster_path%"
	set "category=CLUSTER"
	set /a sprite_start=0x00
	set /a sprite_max=0xFF
	call :auto_create_2

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo(>"scripts\pixi_auto_list_full.txt"
if exist "scripts\pixi_auto_list_.txt" (type "scripts\pixi_auto_list_.txt">>"scripts\pixi_auto_list_full.txt")
if exist "scripts\pixi_auto_list_EXTENDED.txt" (type "scripts\pixi_auto_list_EXTENDED.txt">>"scripts\pixi_auto_list_full.txt")
if exist "scripts\pixi_auto_list_CLUSTER.txt" (type "scripts\pixi_auto_list_CLUSTER.txt">>"scripts\pixi_auto_list_full.txt")

call :fix_spacing
if exist "scripts\temp" (del /Q "scripts\temp" >nul)

if %overwrite% == 1 (
	if not exist "%pixi_list%" (
		echo(List file not found. 
		echo([%pixi_list%]
		choice /c YN /n /m "Insert sprites anyway? [Y/N] "
		echo(
		if !errorlevel! == 2 (
			exit
		)
	)
	copy "scripts\pixi_auto_list_full.txt" "%pixi_list%" >nul
	if !errorlevel! == 1 (
		echo(Failed to overwrite or create list file in the specified list folder. some reason.
		echo(
	) else (
		echo(Made the auto-generated list in [%pixi_list%]
		echo(
	)
)

:: execute pixi

cd /D %pixi_path%

if exist "%LM_path%\scripts\pixi_auto_list.txt" (del /Q "%LM_path%\scripts\pixi_auto_list.txt" >nul)
if exist "%LM_path%\scripts\pixi_auto_list_.txt" (del /Q "%LM_path%\scripts\pixi_auto_list_.txt" >nul)
if exist "%LM_path%\scripts\pixi_auto_list_EXTENDED.txt" (del /Q "%LM_path%\scripts\pixi_auto_list_EXTENDED.txt" >nul)
if exist "%LM_path%\scripts\pixi_auto_list_CLUSTER.txt" (del /Q "%LM_path%\scripts\pixi_auto_list_CLUSTER.txt" >nul)

"pixi.exe" -pl "-lm-handle" "%2" -ssc "%ssc_base%" -l "%LM_path%\scripts\pixi_auto_list_full.txt" -r "%pixi_routines%" -sp "%sprites_path%" -sh "%shooters_path%" -g "%generators_path%" -e "%extended_path%" -c "%cluster_path%" %rom_file%

if %errorlevel% == 0 (
	echo(
	call :separator " auto insert list "
	echo(
	type "%LM_path%\scripts\pixi_auto_list_full.txt"
	echo(
	call :separator
	echo(
	del /Q "%LM_path%\scripts\pixi_auto_list_full.txt" >nul
	pause
) else (
	if %overwrite% == 1 (
		echo(
		call :separator " Disclaimer "
		echo(
		echo(It seems an error has occurred.
		echo(If this error was caused by having an unwanted file in the generated list,
		echo(you can manually remove the unwanted file from your list file as it has already been updated.
		del /Q "%LM_path%\scripts\pixi_auto_list_full.txt" >nul
	) else (
		echo(
		call :separator " Disclaimer "
		echo(
		echo(It seems an error has occurred.
		echo(If this error was caused by having an unwanted file in the generated list,
		echo(Trinkets cannot tell what should be a sprite or not.
		echo(The program only reads file extensions ^(.cfg, .json, .asm^)
		echo(So if you have a non-sprite file that is a .asm/.cfg/.json in your sprites folders,
		echo(you can remove it so Trinkets doesn't read it. Alternatively, you can choose to overwrite your ROM's list file.
		del /Q "%LM_path%\scripts\pixi_auto_list_full.txt" >nul
	)
	pause >nul
)
exit

:auto_create:
	set long_part=%current_path%

	:: create list
		set /A sprites=%sprite_start%
		
		:: search all subfolders
		FOR /r "%current_path%" %%G in ("*") DO (
			
			set format=%%~xG
			
			set "short_path=%%~G"
			set "short_path=!short_path:%long_part%=!"
			set "check=!short_path:~0,1!"
			if "!check!" == "\" (
				set "short_path=!short_path:~1!"
			)
			
			call :loop_a "%%~dpG"
			
			if !ignore!==0 (
				if !format! == .json (
					echo(!HexValue! !short_path!>> "scripts\pixi_auto_list_.txt"
				) else if !format! == .cfg (
					echo(!HexValue! !short_path!>> "scripts\pixi_auto_list_.txt"
				)
			)
			
			if !sprites!-%sprite_start% == %sprite_max% (goto too_much_sprites)
		)
	set /a b=!sprites!-%sprite_start%
exit /b

:auto_create_2:
	set long_part=%current_path%
	
	:: create list
		set /A sprites=%sprite_start%
		
		:: search in main folder
		FOR /r "%current_path%" %%G in ("*.asm") DO (
			
			set "short_path=%%~G"
			set "short_path=!short_path:%long_part%=!"
			set "check=!short_path:~0,1!"
			if "!check!" == "\" (
				set "short_path=!short_path:~1!"
			)
			
			if not "!short_path!"=="_header.asm" (
			if not "!short_path!"=="routines.asm" ( 
			
			call :loop_b "%%~dpG"
			
			if !ignore!==0 (
				echo(!HexValue! !short_path!>> "scripts\pixi_auto_list_!category!.txt"
			)
			))
			
			if !sprites!-%sprite_start% == %sprite_max% (goto too_much_sprites)
		)
		
		set /a b=!sprites!-%sprite_start%
		if not %b%==0 (echo(>> "scripts\pixi_auto_list_!category!.txt")
exit /b

:too_much_sprites:
	echo(There seems to be a problem...
	echo(There's too many .cfg and .json files in '%path%' for pixi to insert correctly.
	echo(Please remove unnecessary sprites files.
	echo(
	pause
	exit

:: A function to convert Decimal to Hexadecimal
:: you need to pass the Decimal as first parameter
:: and return it in the second
:: This function needs setlocal EnableDelayedExpansion to be set at the start if this batch file
:: Refer to ijprest/1207832
:ConvertDecToHex
set LOOKUP=0123456789ABCDEF
set HEXSTR=
set PREFIX=

if "%1" EQU "" (
set "%2=0"
Goto:eof
)
set /a A=%1 || exit /b 1
if !A! LSS 0 set /a A=0xFFFFFFFF + !A! + 1 & set PREFIX=F
:loop
set /a B=!A! %% 16 & set /a A=!A! / 16
set HEXSTR=!LOOKUP:~%B%,1!%HEXSTR%
if %A% GTR 0 Goto :loop
set "%2=%PREFIX%%HEXSTR%"
Goto:eof
:: End of :ConvertDecToHex function


:loop_a
call :ConvertDecToHex !sprites! HexValue
set sprite_in_list=0
set ignore=0
for /F "usebackq tokens=1,*" %%a in ("scripts\pixi_auto_list_.txt") do (
	
	call :Trim compare %~1%%~b
	
	if "%~1!short_path!"=="!compare!" (
		set ignore=1
	) else (
		if "!HexValue!"=="%%~a" (
			set sprite_in_list=1
		)
	)
)
if !ignore!==0 (
	if !sprite_in_list!==1 (
		set /A sprites=!sprites!+1
		goto loop_a
	)
)
exit /b

:loop_b
call :ConvertDecToHex !sprites! HexValue

set category_range=0
set category_exists=0
set ignore=0
set sprite_in_list=0

:: search if category exists

for /F "usebackq tokens=1,*" %%a in ("scripts\pixi_auto_list_!category!.txt") do (
	if "%%a"=="!category!:" (
		set category_range=1
		set category_exists=1
	)
	if !category_range!==1 (
		if "%%a"=="EXTENDED:" (
		if not "!category!"=="EXTENDED" (
		set category_range=0
		))
		if "%%a"=="CLUSTER:" (
		if not "!category!"=="CLUSTER" (
		set category_range=0
		))
	)
	
	:: yup.
	call :Trim compare %~1%%~b
	
	if !category_range!==1 (
		if "%~1!short_path!"=="!compare!" (
			set ignore=1
		) else (
			if "!HexValue!"=="%%~a" (
				set sprite_in_list=1
			)
		)
	)
)

if !ignore!==0 (
	if !sprite_in_list!==1 (
		set /A sprites=!sprites!+1
		goto loop_b
	)
)

if !category_exists!==0 (
	echo(>> "scripts\pixi_auto_list_!category!.txt"
	echo(!category!:>> "scripts\pixi_auto_list_!category!.txt"
	goto loop_b
)
exit /b		

:create_auto_lists

if "!category!"=="" (
	set category_range=1
	set category_exists=1
) else (
	set category_range=0
	set category_exists=0
)

echo(>"scripts\pixi_auto_list_!category!.txt"

if not exist "%pixi_list%" (
	set "original_file=scripts\pixi_auto_list_!category!.txt"
) else (
	set "original_file=%pixi_list%"
)

for /F "usebackq tokens=1,*" %%a in ("%original_file%") do (
	if not "!category!"=="" (
		if "%%a"=="!category!:" (
			set category_range=1
			set category_exists=1
		)
	)
	if !category_range!==1 (
		if "%%a"=="EXTENDED:" (
		if not "!category!"=="EXTENDED" (
		set category_range=0
		))
		
		if "%%a"=="CLUSTER:" (
		if not "!category!"=="CLUSTER" (
		set category_range=0
		))
	)
	
	if !category_range!==1 (
		echo(%%a %%b>>"scripts\pixi_auto_list_!category!.txt"
	)
)
exit /b

:fix_spacing
echo(; auto generated sprite list>"scripts\temp"
echo(>>"scripts\temp"
set space=1

for /F "delims=" %%a in ('findstr /N "^" "scripts\pixi_auto_list_full.txt"') do (
	
	set "line=%%a"
	set "line=!line:*:=!"
	
	if "!line!"=="" (
		if !space!==0 (
			echo(!line!>>"scripts\temp"
			set space=1
		)
	) else (
		echo(!line!>>"scripts\temp"
		set space=0
	)
)
echo(>>"scripts\temp"

copy "scripts\temp" "scripts\pixi_auto_list_full.txt" >nul

if !errorlevel!==1 (
	echo(Failed to create automated list file in the scripts folder.
	echo(
)
exit /b

:: this removes spaces at the end of a line
:Trim
SetLocal EnableDelayedExpansion
set Params=%*
for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
exit /b

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
	:loop_c:
	set separator=!separator!=
	set /a count=!count!+1
	if !count! LSS !halfcolumn! (goto :loop_c:)

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