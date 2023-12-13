@echo off
setlocal EnableDelayedExpansion
color 6

call "scripts\check_for_config.bat" %1
set "rom_file=%1" & set "rom_name=%~n1" & set "LM_path=%cd%"
TITLE [%rom_name%] Apply a Single ASM Patch

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
cls

:start:
echo(
echo(Input patch location (optionally, it can be relative to the defined patches folder)
echo(Example: hex edits/patch 1.asm
echo(
set /p patch_path=""

CALL :NORMALIZEPATH "%patch_path%"

if not "%patch_path%" == "" (
if exist "%RETVAL%" (set patch_path=%RETVAL% & goto apply
) else if exist "%patch_folder%\%patch_path%" (set patch_path=%patch_folder%\%patch_path% & goto apply
) else if exist "%RETVAL%.asm" (set patch_path=%RETVAL%.asm & goto apply
) else if exist "%patch_folder%\%patch_path%.asm" (set patch_path=%patch_folder%\%patch_path%.asm & goto apply
))

echo(
choice /c YN /n /m "File not found, try again? [Y/N] "
if %errorlevel%==1 (
	cls
	goto start
) else (exit)

:apply:
	echo(
	cd /D %asar_path%
	asar.exe -v "%patch_path%" %rom_file%
	if %errorlevel%==1 (
	echo(
		choice /c YN /n /m "Try again? [Y/N] "
		if %errorlevel%==1 (
			cls
			goto start
		) else (exit)
	)
	pause
	exit

:NORMALIZEPATH
  SET RETVAL=%~f1
  EXIT /B