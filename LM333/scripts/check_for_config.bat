
if exist "%~dp1config-%~n1.bat" (
	set "rom_path=%~dp1"
	set "rom_path=!rom_path:~0,-1!"
	set "specified_rom=-%~n1"
	call "%~dp1config-%~n1.bat"
	
) else if exist "%~dp1config.bat" (
	set "rom_path=%~dp1"
	set "rom_path=!rom_path:~0,-1!"
	set "specified_rom="
	call "%~dp1config.bat"
	
) else (
	pause
	start "" "scripts\error.bat"
	exit
)
