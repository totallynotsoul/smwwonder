ExGFX Revolution patches - by edit1754
Patchset v1.2.2

Original C3 post: http://smwcentral.net/?p=thread&id=34112
YF's rerelease C3 post: https://www.smwcentral.net/?p=viewthread&t=123732

Read "Instructions.txt" for more info

NEW in v1.3.1 (yoshifanatic's update)
	- Made the patch Lunar Magic 3.40 compatible
	- Made a couple fixes spooonsss suggested

NEW in v1.3.0 (yoshifanatic's update)
	- Converted the patch to use asar instead of xkas
	- Made the patch SA-1 and Lunar Magic 3.33 compatible
	- Fixed an oversight where the !LevelNum define wasn't used in some places
	- Made it so that applying REMAP.asm will apply the full patch at once.
	- Made the patch detect if the Lunar Magic VRAM or compression patches are not installed.
	- Added defines for all the LM VRAM patch hijacks to make it easier for updates to this patch to handle different VRAM patches or older LM versions.

NEW in v1.2.2
	- new version of REMAP.asm (v1.2.2) for LM1.91. Old version included in REMAP_old.asm (v1.2.1)
	- unrolled loop in transparencyfix.asm

NEW in v1.2.1
	- genericuploader.asm (v1.2) now uses pointers to smaller GFX file tables rather than a large messy table.
	- REMAP.asm (v1.2.1) now includes an optimized version of the stripe image routine with its hijacks included,
	  in order to eliminate the vblank overflow on the title screen when the game selection menu is brought up.
	- LZ2.asm is no longer included. LM1.82 and beyond apply this patch automatically if you select the option.
	  You may also use LZ3.
	- Fixed errors in this Readme, updated Instructions.txt

NEW in v1.2
	- genericuploader.asm (v1.1.2) no longer integrates the LZ2 patch. Instead it is included as a separate ASM file
	  (also, moved restored hijack to separate .asm file. APPLY THIS TO YOUR ROM FIRST IF YOU USED A VERSION BEFORE v1.1!!)
	- REMAP.asm (v1.2) includes an option to force layer priority for all tiles in the FG, which is very helpful for 8BPP BGs

NEW in v1.1.1:
	- genericuploader.asm (v1.1.1) now works with ExGFX80-FF (it hadn't since LM1.6, which was before this patch was official)
	- added a tiny piece of code to transparencyfix.asm (v1.0.1) that turns off HDMA effects when teleporting/dying

NEW in v1.1:
	- fixed glitches in REMAP.asm (v1.1) in which X/Y would be 8-bit and cause levels 100-1FF to not work properly
	- added options in REMAP.asm (v1.1) to disable layer 1 and/or layer 2 uploading - useful for bypassing map16
	- genericuploader.asm (v1.1) no longer screws up animated tile GFX
	- integrated the optimized LZ2 deompression routine with genericuploader.asm (v1.1)



to bypass map16: (not covered in Instructions.txt)
	- insert a 512x256 BG into the very top of the BG tilemap editor
	- set the BG Initial position to 00 in "Modify Main and Midway Entrance"
	- make a savestate in zSNES
	- open the savestate with Racing Stripe (in the tools section) and go to "BG2"
	- go to File > Save Tilemap/Stripe (As), and save a "Raw Tilemap File" (.bin) as an ExGFX file to insert with LM
	- in genericuploader.asm, add these entries for your level:
		- "dw $3800,$yourexgfxfile" (if you're NOT using BG4+5(+6+7) / options 1&2, and/or using 8BPP / option 3)
		- "dw $5800,$yourexgfxfile" (if you're using BG4+5(+6+7) / options 1&2)
	- delete the map16 pages, and clear out the BG tilemap editor
	- in REMAP.asm, enable flag 3 for your level to disable default tilemap uploading for layer 2