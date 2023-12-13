;32x32 Star Coin, sprite version, by Blind Devil
;This is a sprite version of LX5's Star Coin blocks.

;Extra bit: determines if it goes in front or behind layer 1.
;clear = in front
;set = behind

;Extra byte 1 (extension): determines the coin number. Valid values range from 00 to 07.
;00 = 1st coin
;01 = 2nd coin
;02 = 3rd coin
;03 = 4th coin
;04 = 5th coin
;05 = 6th coin
;06 = 7th coin
;07 = 8th coin

;NOTE: Don't forget to copy the routines to PIXI's 'routines' folder,
;and change 'incsrc ../blocks/StarCoinsDefs.asm' within
;'star_coin_give_points' to 'incsrc ../sprites/StarCoinsDefs.asm'.
;And yeah, don't forget to place 'StarCoinsDefs.asm' into PIXI's
;'sprites' folder.

;Configurable defines:

;SHELL-LIKE-COLLECTIBLE
;If this is enabled, the coin can be collected via thrown sprites such as
;Koopa shells, throw blocks and others.
;Possible values: 0 = disabled, 1 = enabled.
	!ShellCollect = 0

;TILEMAPS
;What tiles to use for the coin and outline.
	!CoinTL = $C0
	!CoinTR = $85
	!CoinBL = $E0
	!CoinBR = $8A
	!Outline = $EA

;Codes start below.

!bank = !BankB
!dp = !Base1
!addr = !Base2
incsrc StarCoinsDefs.asm

print "INIT ",pc
PHB			;preserve data bank
PHK			;push program bank into stack
PLB			;pull program bank as new data bank
LDA !7FAB10,x		;load extra bits
AND #$04		;check if first extra bit is set
BEQ .notset		;if not, skip ahead.

INC !1632,x		;make sprite go behind layer 1 by incrementing the flag

.notset
LDA !7FAB40,x		;load extra byte 1 (extension 1)
AND #$07		;preserve bits 0, 1, 2 and 3
TAY			;transfer to Y

+
LDA !LevelCoins		;load coins collected
AND BitTable,y		;check if the respective coin was collected
BEQ +			;if not collected, skip ahead.

INC !C2,x		;set collected flag

+
PLB			;restore previous data bank
RTL			;return.

BitTable:
db $01,$02,$04,$08,$10,$20,$40,$80

print "MAIN ",pc
PHB			;preserve data bank
PHK			;push program bank into stack
PLB			;pull program bank as new data bank
JSR SpriteCode		;call main sprite code
PLB			;restore previous data bank
RTL			;return.

Return:
RTS			;return.

SpriteCode:
JSR Graphics		;call graphics drawing routine

LDA !14C8,x		;load sprite status
CMP #$08		;check if default/alive
BNE Return		;if not equal, return.
LDA $9D			;load sprites/animation locked flag
BNE Return		;if set, return.

LDA #$00		;load value
%SubOffScreen()		;call offscreen handling routine

LDA !C2,x		;load coin is collected roughly in this gameplay flag
BNE Return		;if collected, return.

JSL $01A7DC|!BankB	;call player/sprite interaction routine
BCC +			;if there's no interaction, branch.

LDA !1632,x		;load sprite is behind layer 1 flag
CMP $13F9|!Base2	;compare with player is behind layer 1 flag
BEQ CollectIt		;if equal, collect coin.

+
if !ShellCollect
LDY #!SprSize-1		;sprite slot loop count
Loop:
LDA !14C8,y		;load sprite state
CMP #$09		;check if stunned
BEQ Process		;if yes, check for contact.
CMP #$0A		;check if kicked
BEQ Process		;if yes, check for contact.

LoopSprSpr:
DEY			;decrement Y by one
BPL Loop		;loop while it's positive.
RTS			;return.

Process:
LDA !1632,x		;load sprite is behind layer 1 flag
CMP !1632,y		;compare with kicked sprite is behind layer 1 flag
BNE LoopSprSpr		;if not equal, redo the loop.

PHX			;preserve sprite index
TYX			;transfer Y to X
JSL $03B6E5|!BankB	;get sprite clipping B
PLX			;restore sprite index
JSL $03B69F|!BankB	;get sprite clipping A
JSL $03B72B|!BankB	;check for contact
BCC LoopSprSpr		;if there's no contact, redo the loop.
else
RTS			;return.
endif

CollectIt:
LDA #!StarCoinSFXNumber		;load SFX value
STA !StarCoinSFXPort|!Base2	;store to address to play it.

INC !C2,x		;set collected flag

LDA !7FAB40,x		;load extra byte 1 (extension 1)
AND #$07		;preserve bits 0, 1, 2 and 3
TAY			;transfer to Y
LDA BitTable,y		;load respective bit for current coin collected
ORA !LevelCoins		;OR with current star coins collected
STA !LevelCoins		;store result back.
LDA !LevelCoinsNum	;load number of star coins collected
INC			;increment A
STA !LevelCoinsNum	;store result back.

PHX			;preserve sprite index

LDA !D8,x
CLC
ADC #$08
STA $98
LDA !14D4,x
ADC #$00
STA $99
LDA !E4,x
CLC
ADC #$08
STA $9A
LDA !14E0,x
ADC #$00
STA $9B

	if !UseNewSparkleEffect == 1
		%spawn_star_coin_special_sparkle()
	else		
		PHK	
		PEA.w	.endglitter-1
		PEA.w	$0084CF|!bank-1
		JML	$00FD5A|!bank
.endglitter		
	endif		
	if !GivePoints == 1
		%star_coin_give_points()
		%spawn_score_sprite()
	endif

PLX			;restore sprite index
RTS			;return.

Tilemap:
db !CoinTL,!CoinTR
db !CoinBL,!CoinBR

XDisp:
db $00,$10
db $00,$10

YDisp:
db $00,$00
db $10,$10

OutlineProps:
db $00,$40
db $80,$C0

Graphics:
%GetDrawInfo()		;get sprite positions within the screen and OAM index for sprite tile slots

STZ $03			;reset scratch RAM.
STZ $04			;reset scratch RAM.

LDA !1632,x		;load sprite is behind layer 1 flag
BNE +			;if behind layer 1, don't set priority bits.

LDA $64			;load in level priority bits
STA $03			;store to scratch RAM.

+
LDA !15F6,x		;load palette/properties from CFG
ORA $03			;OR with set up in level priority bits
STA $02			;store to scratch RAM.

LDA !C2,x		;load coin is collected roughly in this gameplay flag
BEQ +			;if not set, skip ahead.

INC $04			;increment scratch RAM, use it as outline flag

+
PHX			;preserve sprite index
LDX #$03		;loop count

GFXLoop:
LDA $00			;load sprite X-pos within the screen
CLC			;clear carry
ADC XDisp,x		;add displacement value from table according to index
STA $0300|!Base2,y	;store to OAM.

LDA $01			;load sprite Y-pos within the screen
CLC			;clear carry
ADC YDisp,x		;add displacement value from table according to index
STA $0301|!Base2,y	;store to OAM.

LDA $04			;load outline flag
BEQ +			;if not set, draw regular coin

LDA #!Outline		;load tile number
STA $0302|!Base2,y	;store to OAM.

LDA $02			;load final palette/properties from scratch RAM
ORA OutlineProps,x	;set flip bits accordingly
BRA .propsover		;branch ahead

+
LDA Tilemap,x		;load tilemap from table according to index
STA $0302|!Base2,y	;store to OAM.

LDA $02			;load final palette/properties from scratch RAM

.propsover
STA $0303|!Base2,y	;store to OAM.

INY #4			;increment Y by one four times
DEX			;decrement X by one
BPL GFXLoop		;keep looping while X is positive.

PLX			;restore sprite index
LDY #$02		;load value into Y (means all tiles are 16x16)
LDA #$03		;load value into A (amount of tiles drawn, minus one)
JSL $01B7B3|!BankB	;bookkeeping
RTS			;return.