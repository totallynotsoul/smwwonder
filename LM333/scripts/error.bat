@echo off
TITLE [Error]

if not "%~1" == "" (
	echo( 
	%~1
	%~2
	%~3
	%~4
	echo( 
) else (
	echo( 
	echo(This ROM doesn't have a config.bat file.
	echo( 
)
pause >nul
exit