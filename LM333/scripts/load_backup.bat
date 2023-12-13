@echo off
setlocal EnableDelayedExpansion
color 0

call "scripts\check_for_config.bat" %1
set "rom_file=%1" & set "rom_name=%~n1" & set "LM_path=%cd%"
TITLE [%rom_name%] Overwrite Current ROM With Latest Backup

set "romtype=%~x1"
set "romtype=%romtype:~1%"
if "%backup_type%" == "" (set "backup_type=0")
if %backup_type% == 0 (set "filetype=bps") else (set "filetype=!romtype!")

echo(
echo(The current ROM will be replaced with the latest .!filetype! backup available.
choice /c YN /n /m "Confirm this action? [Y/N] "
if errorlevel == 2 exit

echo(
if not %backup_type% == 1 (
	if not exist "%flips_path%\flips.exe" (
		echo(flips.exe not found.
		echo([%flips_path%\flips.exe]
		pause >nul
		exit
	) else if not exist "%backups_path%" (
		echo(Backups folder not found.
		echo([%backups_path%]
		pause >nul
		exit
	) else if not exist "%smw_unmodified%" (
		echo(Unmodified copy of SMW not found.
		echo([%smw_unmodified%]
		pause >nul
		exit
	)	
)

if exist "%backups_path%\%rom_name%-latest.%filetype%" (
	if not %backup_type% == 0 (copy "%backups_path%\%rom_name%-latest.!romtype!" "%rom_path:"=%\%rom_name%.!romtype!" >nul
	) else ("%flips_path%\flips.exe" --apply "%backups_path%\%rom_name%-latest.bps" "%smw_unmodified%" "%rom_path:"=%\%rom_name%.!romtype!"
	)
	
	
) else (
	FOR /F "delims=" %%I IN ('DIR "%backups_path%\*.%filetype%" /A-D /B /O:D') DO SET "NewestFile=%%I"
	if not exist "%backups_path%\!NewestFile!" (set no_backups=1)
	
	copy "%backups_path%\!NewestFile!" "%backups_path%\%rom_name%-latest.%filetype%" >nul
	if !errorlevel! == 1 (set copy_fail=1) else (echo(The loaded backup is now the latest one.)
	
	if not %backup_type% == 0 (copy "%backups_path%\!NewestFile!" "%rom_path:"=%\%rom_name%.!romtype!" >nul
	) else ("%flips_path%\flips.exe" --apply "%backups_path%\!NewestFile!" "%smw_unmodified%" "%rom_path:"=%\%rom_name%.!romtype!"
	)
	
	if !errorlevel! == 1 (set copy_fail=1)
)

if !copy_fail! == 1 (
	echo(
	echo(Something went wrong...
	echo(Check the backup folder's defines, or if the backup filenames are right and are not corrupted files.
	exit
)
if !no_backups! == 1 (
	echo(
	echo(There don't seem to be any backups in the defined backups folder.
	echo([%backups_path%]
)
pause
call "scripts\refresh_LM.exe" "%2" 2 >nul