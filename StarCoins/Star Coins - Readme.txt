NSMB Star coins.
Version 1.14
By LX5

;;;;;;;;;;;;;;;;;;;;;;;;;;

This resource tries to emulate the Star Coins of NSMB series and includes some variations:

- 16x32 Star coins (Pretty much a Yoshi Coin)
- 16x16 Star coins (Like a golden coin... I think)

Also, since 1.1 you can have up to EIGHT Star Coins in each level instead of 3!

;;;;;;;;;;;;;;;;;;;;;;;;;;

Requeriments:
- A 2MB Super Mario World ROM.
- Have at least one level edited in the ROM.
- Knowledge of inserting custom objects in a level.
- Know how to insert blocks with GPS.

;;;;;;;;;;;;;;;;;;;;;;;;;;

In the .zip you can find this archives:

- StarCoins.asm
The main file, it contains all of the code that handles the Star Coins, you may do not want to edit this file.

- StarCoinsDefs.asm
This is an important file, it has A LOT of defines that allows to you to customize some things in the patch without messing it.

- sram_plus.asm & sram_table.asm
This saves the Star Coins to SRAM, it is essential to make this patch usable unless you do not want to save the Star Coins. See SRAM Plus download page for further information.

- Objectool.asm (+ custobjcode.asm, custobjptrs1.asm, custobjptrs2.asm & custobjptrs3.asm)
This made possible to Star Coins to not spawn when they are already collected. See Objectool 0.4 download page for further information.

- MinorExtendedSprites.asm & MinorExtendedSpritesCode.asm
This is not essential, but it will give to the coins a nice sparkle effect. This patch is ripped from Custom Other Sprites and adapted to Asar.

- routines/spawn_star_coin_special_sparkle.asm
This is a routine that spawns my sparkle effect. Not required.

- routines/spawn_score_sprite.asm
This is a routine that allows to the blocks to give points when they are collected.
Both routines listed above can be used for other things too.

- routines/change_map16.asm
This is an edit of the included change_map16 in GPS, but it now works on vertical levels.

- blocks/StarCoin*.asm
There is not a file with that name, this just reffers to ALL blocks in the "blocks" folder.

- sprites/StarCoin.asm
A 32x32 sprite version of the Star Coins, made for PIXI. It has all necessary info within it in case you want to use it.

- sprites/StarCoin.cfg
The respective configuration file for the above sprite which is called for insertion through PIXI.

- list.txt
This .txt contains a pre-made list with the Star Coin blocks, you can edit as much you want.

- ExGFX60.bin
A sample bin file with the frames for the animation of the 32x32 Star Coin.

- ExGFX80.bin
A file with sample graphics for the Star Coins. They were made by Carld923 (only the star coins, the ugly outlines were made by me).

- ExGFX81.bin
A file with sample graphics for the sprite version of Star Coins. It uses SP4 by default.

- StarCoins.map16
This map16 contains how the blocks are inserted and have the same tile numbers as the StarCoinsDef.asm

- SampleStarCoins.ips
A .bps file with some levels filled with Star Coins, this can be used to know how to insert custom objects in a level.

;;;;;;;;;;;;;;;;;;;;;;;;;;

How to insert NSMB Star Coins patch in your ROM.

0) Make a backup of your ROM, just in case.

1) Open StarCoinsDefs.asm and configure as much you want the patch, once you are done you can continue.

1.2) If you use SA-1, you HAVE to point the !FreeRAM into BW-RAM like $419C00 (I chose that for testing)

1.4) In addition to 1) and 1.2), you can reinsert the patch much times as you want too, just in case that you configured something wrong.

1.6) If you want, you can use the StarCoins.map16 that contains the placement of the default values of the defines in StarCoinsDefs.asm and list.txt

1.8) And, you can also check the included bps if you want to see how are placed the Star Coins in a level and if you want to copy the animated frames.

2) When you are done with the settings, you need to put StarCoinsDefs.asm not only into the folder where StarCoins.asm is located but also inside the "blocks" folder of GPS.

3) Insert StarCoins.asm with Asar

4) Put the contents of the "blocks" folder in GPS "blocks" folder. Do the same with the "routines" folder.

5) Edit as you want the list.txt, by default it has ALL Star Coins (56 asm files!).

6) Insert the blocks with GPS.

7) You can also insert the 32x32 sprite version of the Star Coin through PIXI, Just don't forget to copy over the routines to 'routines' folder and make the necessary changes, as well as copy 'StarCoinsDefs.asm' over to 'sprites' folder.

8) Enjoy the NSMB Star Coins!

;;;;;;;;;;;;;;;;;;;;;;;;;;

List of default Custom Objects:
- 98 - First 32x32 Star Coin
- 99 - Second 32x32 Star Coin
- 9A - Third 32x32 Star Coin
- 9B - First 16x32 Star Coin
- 9C - Second 16x32 Star Coin
- 9D - Third 16x32 Star Coin
- 9E - First 16x16 Star Coin
- 9F - Second 16x16 Star Coin
- A0 - Third 16x16 Star Coin

;;;;;;;;;;;;;;;;;;;;;;;;;;

How to add more Custom Objects:

1) Open custobjcode.asm and search for a "CustObjXX:" without code in it, the XX refers to the Custom Object Number. The first unused Custom Object number is A1.
2) Add the following lines of code if you are using the 32x32 Star Coins:

	LDA	!LevelCoins
	AND	#$XX
	BNE	.nope
	LDX	#$YY
	JSR	StarCoinFull
	RTS	
.nope	JSR	StarCoinEmpty
	RTS	

Use this with 16x32 Star Coins:

	LDA	!LevelCoins
	AND	#$XX
	BNE	.nope
	LDX	#$YY
	JSR	StarCoin16x32F
	RTS	
.nope	JSR	StarCoin16x32E
	RTS	

And this with 16x16 Star Coins:

	LDA	!LevelCoins
	AND	#$XX
	BNE	.nope
	LDX	#$YY
	JSR	StarCoin16x16F
	RTS	
.nope	JSR	StarCoin16x16E
	RTS	

Change the XX with one of this possible values:

01 - First Star Coin
02 - Second Star Coin
04 - Third Star Coin
08 - Fourth Star Coin
10 - Fifth Star Coin
20 - Sixth Star Coin
40 - Seventh Star Coin
80 - Eighth Star Coin

And change the YY with one of the following values:

00 - First Star Coin
02 - Second Star Coin
04 - Third Star Coin
06 - Fourth Star Coin
08 - Fifth Star Coin
0A - Sixth Star Coin
0C - Seventh Star Coin
0E - Eighth Star Coin

3) Repeat if you want more Star Coins Custom Objects.

;;;;;;;;;;;;;;;;;;;;;;;;;;

If there is a bug please report it via PM, this applies for suggestions too. Thanks!

;;;;;;;;;;;;;;;;;;;;;;;;;;

FAQ

Q: Do you want credit?
A: If you want, yeah. Also make sure that you credit to imamelia and MarioE for their patches and Carld923 for his graphics (in case that you use them).

Q: All of the blocks can coexist in the same ROM?
A: Yes, you can use a 32x32 Star Coin, a 16x32 Star Coin and a 16x16 Star Coin in the same level without problems.

Q: It does not work with Ladida's minimalist patch >:(
A: Eh, I do not know how it works, maybe later I will see how implement in that patch.
A: IT NOW WORKS!, however, I won't submit it but you can grab it from here: http://bin.smwcentral.net/u/12344/min_status_mod.zip

Q: It does not work with WYE's DKCR Status Patch >:(
A: Maybe someday I will make it compatible.

Q: It does no work with Multiple Midway Points Patch >:(
A: Same as above, it would be cool if it works with that patch, but also I need some free time, so... Maybe someday.

Q: Reapplying SA-1 pack crashes the game >:(
A: Due to conflicting hijacks, I had to overwrite an SA-1 hijack and SA-1 pack will overwrite this hijack. Fortunatelly, SA-1 pack is a patch you usually apply only once.

;;;;;;;;;;;;;;;;;;;;;;;;;;

Changelog:

v1.14 (24/Apr/18)
- Remoderation update (MFG/Blind Devil)
- Added SA-1 support
- Changed animation file to require only one ExAnimation slot.
- Included a custom sprite (PIXI) version of the Star Coin - check out the ASM file for more info.
v1.13 (16/Sep/15)
- Fixed the routine that generates sparkles.
- Fixed the .ips having some weird stuff.
- Included an edited change_map16 routine to make the star coins work correctly on vertical levels
v1.12 (16/May/15)
- Fixed some initialization code
- Removed some jimmy code
- Fixed a define and some descriptions in StarCoinsDefs.asm
v1.11 (4/Jan/15)
- Submitted to SMWC.
- Fixed minor things in the file.
v1.1 (22/Dec/14)
- Now is possible to have eight star coins in each level.
- Added documentation about custom objects.
- Added a small tutorial of how to create more Custom Objects.
- Removed some dumb and useless things from StarCoinsDefs.asm
v1.0 (20/Dec/14)
- C3 RELEASE (yay!).
- Fixed a lot of thigs with the midpoint.
- Translated all files.
v0.2 (14/Dec/14)
- Fixed a crash when you die
- Fixed a bug related to the give points routine.
v0.1 (14/Dec/14)
- Initial release in Fortaleza Reznor (Spanish forum)