;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FreeRAMs related.
;; You require at least 200 bytes of free ram to use this. You can reorganize the freerams as you desire if you know what are you doing.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FreeRAM		= $419C00		;If you need it, you can change this address to whatever address as long you have 200 bytes of consecutive RAMs. The default address uses freeRAMs after AddMusicK RAMs, so you can use with it without problems.
;Note to use FreeRAM in BW-RAM if you use SA-1. I chose $419C00

!LevelCoins		= !FreeRAM		;1 byte. Contains the flags of the star coins that has been collected within the level. Format 87654321.
!TempCoins		= !FreeRAM+1		;1 byte. A temporary value that holds the star coins flags collected within the level, this is for evade conflicts with the OW & the midway point. Format 87654321
!PreviousLevel		= !FreeRAM+2		;1 byte. Hold the previous level number played.
!PreviousCoins		= !FreeRAM+3		;1 byte. Hold ANOTHER backup of the star coins when you are travelling to a sublevel. Format 87654321.
!PreviousCoinsF		= !FreeRAM+4		;1 byte. Check if we are going to another level to make a backup of the star coins flags. Format: #$00 = No, Any other value = Yes
!LevelCoinsNum		= !FreeRAM+5		;1 byte. Hold the total number of star coins collected in a level, also used to know how many point will give a star coin.
!TotalCoinsNum		= !FreeRAM+6		;2 bytes. Hold the number of star coins collected in the game, this address gets updated when the "Course Clear!" appears and when the Keyhole is activated. Also this address is 16-bit.
!PerLevelFlags		= !FreeRAM+8		;96 bytes. Each byte contains the flags of the star coins collected in a level. Format 87654321
!PerMidPointFlags	= !PerLevelFlags+96	;96 bytes. Each byte contains the flags of the star coins collected in a level when the midpoint is collected. Format 87654321
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Misc things.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
!MaxStarCoins		= $03			;Max number of Star Coins in a level (max value possible is $08)
			 			;If you select more than five star coins, the counter will start to overwrite somethings in the vanilla status bar, like the bonus star counter and part of the item box.
!InitLocation		= 1			;Change to 1 to obtain the insert location of all patches.
!BytesUsed		= 1			;Change to 1 to obtain the freespace used by each patch.
						
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Install other patches
;; Change to 0 to not install, leave the 1 to install them.
;; Normally you won't change anything here unless you know what are you doing.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!InstallMinorSprites	= 0			;Installs the Minor Extended Sprites patch, only required if you want my sparkle effect.
!InstallSRAMPlus	= 1			;Installs SRAM Plus, required. If you're using SA-1, it'll install BW-RAM Plus instead
!InstallObjectool	= 1			;Installs Objectool 0.4, required if you don't want the custom blocks keep reappearing when you play the level again.
!InstallStatusCounter	= 1			;Installs the counter in the status bar, it will destroy the yoshi coins counter and it doesn't require any freespace.
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Objectool things 
;; The tile numbers of the blank tiles are shared with the custom blocks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;
; 32x32 Star Coin
;;;;;;;;;;

!BlankTileUpLeft	= $0200			;Tile number of the UPPER LEFT corner blank tile of the 32x32 star coin.
!BlankTileUpRight	= $0201			;Tile number of the UPPER RIGHT corner blank tile of the 32x32 star coin.
!BlankTileDownLeft	= $0210			;Tile number of the BOTTOM LEFT corner blank tile of the 32x32 star coin.
!BlankTileDownRight	= $0211			;Tile number of the BOTTOM RIGHT corner blank tile of the 32x32 star coin.
			
!FirstCoinUpLeft	= $0202			;Tile number of the UPPER LEFT corner tile of the FIRST 32x32 star coin.
!FirstCoinUpRight	= $0203			;Tile number of the UPPER RIGHT corner tile of the FIRST 32x32 star coin.
!FirstCoinDownLeft	= $0212			;Tile number of the BOTTOM LEFT corner tile of the FIRST 32x32 star coin.
!FirstCoinDownRight	= $0213			;Tile number of the BOTTOM RIGHT corner tile of the FIRST 32x32 star coin.
			
!SecondCoinUpLeft	= $0204			;Tile number of the UPPER LEFT corner tile of the SECOND 32x32 star coin.
!SecondCoinUpRight	= $0205			;Tile number of the UPPER RIGHT corner tile of the SECOND 32x32 star coin.
!SecondCoinDownLeft	= $0214			;Tile number of the BOTTOM LEFT corner tile of the SECOND 32x32 star coin.
!SecondCoinDownRight	= $0215			;Tile number of the BOTTOM RIGHT corner tile of the SECOND 32x32 star coin.
			
!ThirdCoinUpLeft	= $0206			;Tile number of the UPPER LEFT corner tile of the THIRD 32x32 star coin.
!ThirdCoinUpRight	= $0207			;Tile number of the UPPER RIGHT corner tile of the THIRD 32x32 star coin.
!ThirdCoinDownLeft	= $0216			;Tile number of the BOTTOM LEFT corner tile of the THIRD 32x32 star coin.
!ThirdCoinDownRight	= $0217			;Tile number of the BOTTOM RIGHT corner tile of the THIRD 32x32 star coin.

!FourthCoinUpLeft	= $0208			;Tile number of the UPPER LEFT corner tile of the FOURTH 32x32 star coin.
!FourthCoinUpRight	= $0209			;Tile number of the UPPER RIGHT corner tile of the FOURTH 32x32 star coin.
!FourthCoinDownLeft	= $0218			;Tile number of the BOTTOM LEFT corner tile of the FOURTH 32x32 star coin.
!FourthCoinDownRight	= $0219			;Tile number of the BOTTOM RIGHT corner tile of the FOURTH 32x32 star coin.

!FifthCoinUpLeft	= $020A			;Tile number of the UPPER LEFT corner tile of the FIFTH 32x32 star coin.
!FifthCoinUpRight	= $020B			;Tile number of the UPPER RIGHT corner tile of the FIFTH 32x32 star coin.
!FifthCoinDownLeft	= $021A			;Tile number of the BOTTOM LEFT corner tile of the FIFTH 32x32 star coin.
!FifthCoinDownRight	= $021B			;Tile number of the BOTTOM RIGHT corner tile of the FIFTH 32x32 star coin.

!SixthCoinUpLeft	= $020C			;Tile number of the UPPER LEFT corner tile of the SIXTH 32x32 star coin.
!SixthCoinUpRight	= $020D			;Tile number of the UPPER RIGHT corner tile of the SIXTH 32x32 star coin.
!SixthCoinDownLeft	= $021C			;Tile number of the BOTTOM LEFT corner tile of the SIXTH 32x32 star coin.
!SixthCoinDownRight	= $021D			;Tile number of the BOTTOM RIGHT corner tile of the SIXTH 32x32 star coin.

!SeventhCoinUpLeft	= $020E			;Tile number of the UPPER LEFT corner tile of the SEVENTH 32x32 star coin.
!SeventhCoinUpRight	= $020F			;Tile number of the UPPER RIGHT corner tile of the SEVENTH 32x32 star coin.
!SeventhCoinDownLeft	= $021E			;Tile number of the BOTTOM LEFT corner tile of the SEVENTH 32x32 star coin.
!SeventhCoinDownRight	= $021F			;Tile number of the BOTTOM RIGHT corner tile of the SEVENTH 32x32 star coin.

!EighthCoinUpLeft	= $022E			;Tile number of the UPPER LEFT corner tile of the EIGHTH 32x32 star coin.
!EighthCoinUpRight	= $022F			;Tile number of the UPPER RIGHT corner tile of the EIGHTH 32x32 star coin.
!EighthCoinDownLeft	= $023E			;Tile number of the BOTTOM LEFT corner tile of the EIGHTH 32x32 star coin.
!EighthCoinDownRight	= $023F			;Tile number of the BOTTOM RIGHT corner tile of the EIGHTH 32x32 star coin.

;;;;;;;;;;
; 16x32 Star Coin
;;;;;;;;;;

!BlankTile16x32Up	= $0220			;Tile number of the UPPER blank tile of the 16x32 star coin.
!BlankTile16x32Down	= $0230			;Tile number of the BOTTOM blank tile of the 16x32 star coin.

!FirstCoinTile16x32Up	= $0221			;Tile number of the UPPER tile of the FIRST 16x32 star coin.
!FirstCoinTile16x32Down	= $0231			;Tile number of the BOTTOM tile of the FIRST 16x32 star coin.
			
!SecondCoinTile16x32Up	= $0222			;Tile number of the UPPER tile of the SECOND 16x32 star coin.
!SecondCoinTile16x32Down = $0232		;Tile number of the BOTTOM tile of the SECOND 16x32 star coin.
			
!ThirdCoinTile16x32Up	= $0223			;Tile number of the UPPER tile of the THIRD 16x32 star coin.
!ThirdCoinTile16x32Down	= $0233			;Tile number of the BOTTOM tile of the THIRD 16x32 star coin.

!FourthCoinTile16x32Up	= $0224			;Tile number of the UPPER tile of the FOURTH 16x32 star coin.
!FourthCoinTile16x32Down = $0234		;Tile number of the BOTTOM tile of the FOURTH 16x32 star coin.

!FifthCoinTile16x32Up	= $0225			;Tile number of the UPPER tile of the FIFTH 16x32 star coin.
!FifthCoinTile16x32Down	= $0235			;Tile number of the BOTTOM tile of the FIFTH 16x32 star coin.

!SixthCoinTile16x32Up	= $0226			;Tile number of the UPPER tile of the SIXTH 16x32 star coin.
!SixthCoinTile16x32Down	= $0236			;Tile number of the BOTTOM tile of the SIXTH 16x32 star coin.

!SeventhCoinTile16x32Up	= $0227			;Tile number of the UPPER tile of the SEVENTH 16x32 star coin.
!SeventhCoinTile16x32Down = $0237		;Tile number of the BOTTOM tile of the SEVENTH 16x32 star coin.

!EighthCoinTile16x32Up	= $0228			;Tile number of the UPPER tile of the EIGHTH 16x32 star coin.
!EighthCoinTile16x32Down = $0238		;Tile number of the BOTTOM tile of the EIGHTH 16x32 star coin.

;;;;;;;;;;			
; 16x16 Star Coin
;;;;;;;;;;
			
!BlankTile16x16		= $0240			;Tile number of the blank tile of the 16x16 star coin.
			
!FirstCoin16x16		= $0241			;Tile number of the FIRST 16x16 star coin.
!SecondCoin16x16	= $0242			;Tile number of the SECOND 16x16 star coin.
!ThirdCoin16x16		= $0243			;Tile number of the THIRD 16x16 star coin.
!FourthCoin16x16	= $0244			;Tile number of the FOURTH 16x16 star coin.
!FifthCoin16x16		= $0245			;Tile number of the FIFTH 16x16 star coin.
!SixthCoin16x16		= $0246			;Tile number of the SIXTH 16x16 star coin.
!SeventhCoin16x16	= $0247			;Tile number of the SEVENTH 16x16 star coin.
!EighthCoin16x16	= $0248			;Tile number of the EIGHTH 16x16 star coin.			

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Blocks stuff.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!UseNewSparkleEffect	= 1			;Change to 1 to use my sparkle effect. WARNING: May cause crashes if you do not install the Minor Extended Sprites patch.
!StarCoinSFXNumber	= $1C			;SFX that sounds when you touch the star coin. Visit this link if you want to change it: http://smwc.me/96604
!StarCoinSFXPort	= $1DF9			;SFX Port, check the same link if you want to change it.
!GivePoints		= 1			;Change to 1 if you want the star coins give points when they are collected.
!FirstPoints		= $0A			;Amount of points that gives the FIRST star coin collected, no matter if you collect the third or the second star coin first, it will give this amount of points.
!SecondPoints		= $0B			;Same as above, but this is for the SECOND star coin.
!ThirdPoints		= $0C			;Same as above, but this is for the THIRD star coin.
!FourthPoints		= $0C			;Same as above, but this is for the FOURTH star coin.
!FifthPoints		= $0D			;Same as above, but this is for the FIFTH star coin.
!SixthPoints		= $0E			;Same as above, but this is for the SIXTH star coin.
!SeventhPoints		= $0E			;Same as above, but this is for the SEVENTH star coin.
!EighthPoints		= $0F			;Same as above, but this is for the EIGHTH star coin.
						;Allowed values:
						;$00 = Null/0
						;$01 = 10
						;$02 = 20
						;$03 = 40
						;$04 = 80
						;$05 = 100
						;$06 = 200
						;$07 = 400
						;$08 = 800
						;$09 = 1000
						;$0A = 2000
						;$0B = 4000
						;$0C = 8000
						;$0D = 1up
						;$0E = 2up
						;$0F = 3up
						;$10 = 5up (may glitch)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Layer 3 Status bar related.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!BlankStatusCoin	= $FC			;Tile number used to fill spots in the status bar when there is no star coin collected.
!FullStatusCoin		= $2E			;Tile number used to fill spots in the status bar when there is a star coin collected.
!Position		= $0EFF			;Position where the FIRST coin will be filled in the status bar, the other two coins will be filled in order to the right. Like: Coin 1, Coin 2, Coin 3
						;Check this diagrams to know how to replace this values.
						; http://media.smwcentral.net/Diagrams/StatusBarTiles.png
						; http://media.smwcentral.net/Diagrams/StatusBarMap.png
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minor Extended Sprites related.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!SmallShine		= $6D			;Tile number of the smallest sparkle.
!MediumShine		= $6C			;Tile number of the small sparkle.
!LargeShine		= $5C			;Tile number of the large sparkle.
!Props			= $16			;Properties of ALL sparkles. Visit this link if you want to know how to replace this value: http://smwc.me/367797
!Size			= $00			;Size of ALL sparkles. $00 for 8x8, $02 for 16x16.