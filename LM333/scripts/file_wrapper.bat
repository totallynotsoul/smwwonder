@echo off
setlocal enableDelayedExpansion

call "scripts\check_for_config.bat" %1
set rom_file=%1

start "" "%~2" "%~3" "%~4" "%~5" "%~6" "%~7" "%~8" "%~9"
exit