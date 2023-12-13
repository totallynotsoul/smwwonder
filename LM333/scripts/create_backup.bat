@echo off
setlocal EnableDelayedExpansion
color 0

call "scripts\check_for_config.bat" %1
set "rom_file=%1" & set "rom_name=%~n1" & set "LM_path=%cd%"
TITLE [%rom_name%] Create Backup

set "romtype=%~x1"
set "romtype=!romtype:~1!
if "%backup_type%" == "" (set "backup_type=0")
if %backup_type% == 0 (set "filetype=bps") else (set "filetype=!romtype!")

echo(
choice /c YN /n /m "Save a .!filetype! backup of the currently open ROM? [Y/N] "
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

:: stolen from ampersam

for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set DateTime=%%a

set Year=%DateTime:~0,4%
set Month=%DateTime:~4,2%
set Day=%DateTime:~6,2%
set Hour=%DateTime:~8,2%
set Minute=%DateTime:~10,2%

set "TIMESTAMP=-%Year%-%Month%-%Day%-%Hour%-%Minute%"

set LRP_FILE="sysLMRestore\%rom_name%.lrp"

if %backup_type% == 1 (
	copy %rom_file% "%backups_path%\%rom_name%%TIMESTAMP%.!filetype!" >nul
	if not !errorlevel! == 0 (
		echo(
		echo([%backups_path%\%rom_name%%TIMESTAMP%.!filetype!]
	) else (
		copy %rom_file% "%backups_path%\%rom_name%-latest.!filetype!" >nul
		echo(A backup was created in:
		echo([%backups_path%\%rom_name%%TIMESTAMP%.!filetype!]
	)
	pause >nul
) else (
	"%flips_path%\flips.exe" --create --bps "%smw_unmodified%" %rom_file% "%backups_path%\%rom_name%%TIMESTAMP%.!filetype!"
	if not !errorlevel! == 0 (
		echo(
		echo([%backups_path%\%rom_name%%TIMESTAMP%.!filetype!]
	) else (
		"%flips_path%\flips.exe" --create --bps "%smw_unmodified%" %rom_file% "%backups_path%\%rom_name%-latest.!filetype!" >nul
		echo(A backup was created in:
		echo([%backups_path%\%rom_name%%TIMESTAMP%.!filetype!]
	)
	pause >nul
)