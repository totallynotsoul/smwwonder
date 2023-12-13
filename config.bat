:: configuration

:: this is a comment. all lines that start with :: are comments
:: you can remove them if you want.
:: if you're changing anything, try to keep the format
:: (don't add spaces next to the ='s, if you want to add a comment start the line with ::, etc)

:: the variable for the currently loaded rom's directory is !rom_path!

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: resources folder

	set "resources_path=!rom_path!\..\.resources"
	
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: your preferred list editing program, by default it's notepad.exe

	set "list_program=notepad.exe"
	
	:: but if you wanted to open lists with something like notepad++
	:: you'd put in C:\Program Files (x86)\Notepad++\notepad++.exe (or wherever you installed it.)
	
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: bookmark list

	set "bookmark_list=!rom_path!\bookmark_list.txt"
	
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: asar
	:: asar.exe path
		set "asar_path=!resources_path!"
	
	:: ASM patches list and folder
		set "patch_folder=!rom_path!\code\patches"
		
		set "patch_list=!rom_path!\code\patch list.txt"
	
:: flips
	:: flips.exe path
		set "flips_path=!resources_path!"
		
	:: unmodified SMW ROM (include the filename as well!)
		set "smw_unmodified=!resources_path!\SMW.smc"

	:: backups folder
		set "backups_path=!rom_path!\backups"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: pixi
	:: pixi.exe path
		set "pixi_path=!resources_path!\PIXI"
		
	:: pixi list path
		set "pixi_list=!rom_path!\sprites\sprite list.txt"
		
	:: pixi routines path
		set "pixi_routines=!rom_path!\sprites\routines"
		
	:: custom sprite folders
		set "sprites_path=!rom_path!\sprites\sprites"
		
		set "shooters_path=!rom_path!\sprites\shooters"
		
		set "generators_path=!rom_path!\sprites\generators"
		
		set "extended_path=!rom_path!\sprites\extended"
		
		set "cluster_path=!rom_path!\sprites\cluster"

	:: .ssc base
		set "ssc_base=!rom_path!\ssc_base.ssc"
		
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: GPS
	:: GPS.exe path
		set "gps_path=!rom_path!\gps"
		
	:: GPS list path
		set "gps_list=!rom_path!\gps\list.txt"
		
	:: GPS routines path
		set "gps_routines=!rom_path!\gps\routines"
		
	:: custom blocks path
		set "gps_blocks=!rom_path!\gps\blocks"
		
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: UberASM Tool
	:: UberASMTool.exe and uberasm folders path
		set "uber_path=!rom_path!\uberasm"
		
	:: Uberasm's list file
		set "uber_list=!rom_path!\uberasm\list.txt"
		
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: AddmusicK
	:: AMK path
		set "AMK_path=!rom_path!\AMK"
		