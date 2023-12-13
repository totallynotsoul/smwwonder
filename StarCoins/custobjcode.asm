@includefrom Objectool.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This is where you put the code for extended objects 02-0F.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CustObj02:
CustObj03:
CustObj04:
CustObj05:
CustObj06:
CustObj07:
CustObj08:
CustObj09:
CustObj0A:
CustObj0B:
CustObj0C:
CustObj0D:
CustObj0E:
CustObj0F:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This is where you put the code for extended objects 98-FF.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Store:		SEP	#$20
		STA	[$6B],y
		XBA	
		STA	[$6E],y
		RTS
StarCoinEmpty:	LDY	$57
		REP	#$20
		LDA	#!BlankTileUpLeft
		JSR	Store
		JSR	ShiftObjRight
		REP	#$20
		LDA	#!BlankTileUpRight
		JSR	Store
		JSR	ShiftObjDown
		JSR	ShiftObjRight
		REP	#$20
		LDA	#!BlankTileDownRight
		JSR	Store
		JSR	ShiftObjLeft
		REP	#$20
		LDA	#!BlankTileDownLeft
		JSR	Store
		RTS
StarCoinFull:	LDY	$57
		REP	#$20
		LDA.w	UpLeft,x
		JSR	Store
		JSR	ShiftObjRight
		REP	#$20
		LDA.w	UpRight,x
		JSR	Store
		JSR	ShiftObjDown
		JSR	ShiftObjRight
		REP	#$20
		LDA.w	DownRight,x
		JSR	Store
		JSR	ShiftObjLeft
		REP	#$20
		LDA.w	DownLeft,x
		JSR	Store
		RTS	
StarCoin16x32F:	LDY	$57
		REP	#$20
		LDA.w	Up,x
		JSR	Store
		JSR	ShiftObjDown
		REP	#$20
		LDA.w	Down,x
		JSR	Store
		RTS	
StarCoin16x32E:	LDY	$57
		REP	#$20
		LDA.w	#!BlankTile16x32Up
		JSR	Store
		JSR	ShiftObjDown
		REP	#$20
		LDA.w	#!BlankTile16x32Down
		JSR	Store
		RTS	
StarCoin16x16F:	LDY	$57
		REP	#$20
		LDA.w	Center,x
		JSR	Store
		RTS	
StarCoin16x16E:	LDY	$57
		REP	#$20
		LDA	#!BlankTile16x16
		JSR	Store
		RTS	

UpLeft:		dw !FirstCoinUpLeft,!SecondCoinUpLeft,!ThirdCoinUpLeft,!FourthCoinUpLeft
		dw !FifthCoinUpLeft,!SixthCoinUpLeft,!SeventhCoinUpLeft,!EighthCoinUpLeft
UpRight:	dw !FirstCoinUpRight,!SecondCoinUpRight,!ThirdCoinUpRight,!FourthCoinUpRight
		dw !FifthCoinUpRight,!SixthCoinUpRight,!SeventhCoinUpRight,!EighthCoinUpRight
DownLeft:	dw !FirstCoinDownLeft,!SecondCoinDownLeft,!ThirdCoinDownLeft,!FourthCoinDownLeft
		dw !FifthCoinDownLeft,!SixthCoinDownLeft,!SeventhCoinDownLeft,!EighthCoinDownLeft
DownRight:	dw !FirstCoinDownRight,!SecondCoinDownRight,!ThirdCoinDownRight,!FourthCoinDownLeft
		dw !FifthCoinDownRight,!SixthCoinDownRight,!SeventhCoinDownRight,!EighthCoinDownLeft

Up:		dw !FirstCoinTile16x32Up,!SecondCoinTile16x32Up,!ThirdCoinTile16x32Up,!FourthCoinTile16x32Up
		dw !FifthCoinTile16x32Up,!SixthCoinTile16x32Up,!SeventhCoinTile16x32Up,!EighthCoinTile16x32Up
Down:		dw !FirstCoinTile16x32Down,!SecondCoinTile16x32Down,!ThirdCoinTile16x32Down,!FourthCoinTile16x32Down
		dw !FifthCoinTile16x32Down,!SixthCoinTile16x32Down,!SeventhCoinTile16x32Down,!EighthCoinTile16x32Down

Center:		dw !FirstCoin16x16,!SecondCoin16x16,!ThirdCoin16x16,!FourthCoin16x16
		dw !FifthCoin16x16,!SixthCoin16x16,!SeventhCoin16x16,!EighthCoin16x16

;; 32x32
			
CustObj98:	LDA	!LevelCoins
		AND	#$01
		BNE	.nope
		LDX	#$00
		JMP	StarCoinFull	
.nope		JMP	StarCoinEmpty

CustObj99:	LDA	!LevelCoins
		AND	#$02
		BNE	.nope
		LDX	#$02
		JMP	StarCoinFull	
.nope		JMP	StarCoinEmpty
	
CustObj9A:	LDA	!LevelCoins
		AND	#$04
		BNE	.nope
		LDX	#$04
		JMP	StarCoinFull	
.nope		JMP	StarCoinEmpty

;; 16x32

CustObj9B:	LDA	!LevelCoins
		AND	#$01
		BNE	.nope
		LDX	#$00
		JMP	StarCoin16x32F	
.nope		JMP	StarCoin16x32E

CustObj9C:	LDA	!LevelCoins
		AND	#$02
		BNE	.nope
		LDX	#$02
		JMP	StarCoin16x32F	
.nope		JMP	StarCoin16x32E

CustObj9D:	LDA	!LevelCoins
		AND	#$04
		BNE	.nope
		LDX	#$04
		JMP	StarCoin16x32F	
.nope		JMP	StarCoin16x32E


;; 16x16

CustObj9E:	LDA	!LevelCoins
		AND	#$01
		BNE	.nope
		LDX	#$00
		JMP	StarCoin16x16F
.nope		JMP	StarCoin16x16E

CustObj9F:	LDA	!LevelCoins
		AND	#$02
		BNE	.nope
		LDX	#$02
		JMP	StarCoin16x16F
.nope		JMP	StarCoin16x16E

CustObjA0:	LDA	!LevelCoins
		AND	#$04
		BNE	.nope
		LDX	#$04
		JMP	StarCoin16x16F
.nope		JMP	StarCoin16x16E

CustObjA1:
CustObjA2:
CustObjA3:
CustObjA4:
CustObjA5:
CustObjA6:
CustObjA7:
CustObjA8:
CustObjA9:
CustObjAA:
CustObjAB:
CustObjAC:
CustObjAD:
CustObjAE:
CustObjAF:
CustObjB0:
CustObjB1:
CustObjB2:
CustObjB3:
CustObjB4:
CustObjB5:
CustObjB6:
CustObjB7:
CustObjB8:
CustObjB9:
CustObjBA:
CustObjBB:
CustObjBC:
CustObjBD:
CustObjBE:
CustObjBF:
CustObjC0:
CustObjC1:
CustObjC2:
CustObjC3:
CustObjC4:
CustObjC5:
CustObjC6:
CustObjC7:
CustObjC8:
CustObjC9:
CustObjCA:
CustObjCB:
CustObjCC:
CustObjCD:
CustObjCE:
CustObjCF:
CustObjD0:
CustObjD1:
CustObjD2:
CustObjD3:
CustObjD4:
CustObjD5:
CustObjD6:
CustObjD7:
CustObjD8:
CustObjD9:
CustObjDA:
CustObjDB:
CustObjDC:
CustObjDD:
CustObjDE:
CustObjDF:
CustObjE0:
CustObjE1:
CustObjE2:
CustObjE3:
CustObjE4:
CustObjE5:
CustObjE6:
CustObjE7:
CustObjE8:
CustObjE9:
CustObjEA:
CustObjEB:
CustObjEC:
CustObjED:
CustObjEE:
CustObjEF:
CustObjF0:
CustObjF1:
CustObjF2:
CustObjF3:
CustObjF4:
CustObjF5:
CustObjF6:
CustObjF7:
CustObjF8:
CustObjF9:
CustObjFA:
CustObjFB:
CustObjFC:
CustObjFD:
CustObjFE:
CustObjFF:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This is where you put the code for NORMAL object 2D.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CustObj2Dx00:
CustObj2Dx01:
CustObj2Dx02:
CustObj2Dx03:
CustObj2Dx04:
CustObj2Dx05:
CustObj2Dx06:
CustObj2Dx07:
CustObj2Dx08:
CustObj2Dx09:
CustObj2Dx0A:
CustObj2Dx0B:
CustObj2Dx0C:
CustObj2Dx0D:
CustObj2Dx0E:
CustObj2Dx0F:
CustObj2Dx10:
CustObj2Dx11:
CustObj2Dx12:
CustObj2Dx13:
CustObj2Dx14:
CustObj2Dx15:
CustObj2Dx16:
CustObj2Dx17:
CustObj2Dx18:
CustObj2Dx19:
CustObj2Dx1A:
CustObj2Dx1B:
CustObj2Dx1C:
CustObj2Dx1D:
CustObj2Dx1E:
CustObj2Dx1F:
CustObj2Dx20:
CustObj2Dx21:
CustObj2Dx22:
CustObj2Dx23:
CustObj2Dx24:
CustObj2Dx25:
CustObj2Dx26:
CustObj2Dx27:
CustObj2Dx28:
CustObj2Dx29:
CustObj2Dx2A:
CustObj2Dx2B:
CustObj2Dx2C:
CustObj2Dx2D:
CustObj2Dx2E:
CustObj2Dx2F:
CustObj2Dx30:
CustObj2Dx31:
CustObj2Dx32:
CustObj2Dx33:
CustObj2Dx34:
CustObj2Dx35:
CustObj2Dx36:
CustObj2Dx37:
CustObj2Dx38:
CustObj2Dx39:
CustObj2Dx3A:
CustObj2Dx3B:
CustObj2Dx3C:
CustObj2Dx3D:
CustObj2Dx3E:
CustObj2Dx3F:
CustObj2Dx40:
CustObj2Dx41:
CustObj2Dx42:
CustObj2Dx43:
CustObj2Dx44:
CustObj2Dx45:
CustObj2Dx46:
CustObj2Dx47:
CustObj2Dx48:
CustObj2Dx49:
CustObj2Dx4A:
CustObj2Dx4B:
CustObj2Dx4C:
CustObj2Dx4D:
CustObj2Dx4E:
CustObj2Dx4F:
CustObj2Dx50:
CustObj2Dx51:
CustObj2Dx52:
CustObj2Dx53:
CustObj2Dx54:
CustObj2Dx55:
CustObj2Dx56:
CustObj2Dx57:
CustObj2Dx58:
CustObj2Dx59:
CustObj2Dx5A:
CustObj2Dx5B:
CustObj2Dx5C:
CustObj2Dx5D:
CustObj2Dx5E:
CustObj2Dx5F:
CustObj2Dx60:
CustObj2Dx61:
CustObj2Dx62:
CustObj2Dx63:
CustObj2Dx64:
CustObj2Dx65:
CustObj2Dx66:
CustObj2Dx67:
CustObj2Dx68:
CustObj2Dx69:
CustObj2Dx6A:
CustObj2Dx6B:
CustObj2Dx6C:
CustObj2Dx6D:
CustObj2Dx6E:
CustObj2Dx6F:
CustObj2Dx70:
CustObj2Dx71:
CustObj2Dx72:
CustObj2Dx73:
CustObj2Dx74:
CustObj2Dx75:
CustObj2Dx76:
CustObj2Dx77:
CustObj2Dx78:
CustObj2Dx79:
CustObj2Dx7A:
CustObj2Dx7B:
CustObj2Dx7C:
CustObj2Dx7D:
CustObj2Dx7E:
CustObj2Dx7F:
CustObj2Dx80:
CustObj2Dx81:
CustObj2Dx82:
CustObj2Dx83:
CustObj2Dx84:
CustObj2Dx85:
CustObj2Dx86:
CustObj2Dx87:
CustObj2Dx88:
CustObj2Dx89:
CustObj2Dx8A:
CustObj2Dx8B:
CustObj2Dx8C:
CustObj2Dx8D:
CustObj2Dx8E:
CustObj2Dx8F:
CustObj2Dx90:
CustObj2Dx91:
CustObj2Dx92:
CustObj2Dx93:
CustObj2Dx94:
CustObj2Dx95:
CustObj2Dx96:
CustObj2Dx97:
CustObj2Dx98:
CustObj2Dx99:
CustObj2Dx9A:
CustObj2Dx9B:
CustObj2Dx9C:
CustObj2Dx9D:
CustObj2Dx9E:
CustObj2Dx9F:
CustObj2DxA0:
CustObj2DxA1:
CustObj2DxA2:
CustObj2DxA3:
CustObj2DxA4:
CustObj2DxA5:
CustObj2DxA6:
CustObj2DxA7:
CustObj2DxA8:
CustObj2DxA9:
CustObj2DxAA:
CustObj2DxAB:
CustObj2DxAC:
CustObj2DxAD:
CustObj2DxAE:
CustObj2DxAF:
CustObj2DxB0:
CustObj2DxB1:
CustObj2DxB2:
CustObj2DxB3:
CustObj2DxB4:
CustObj2DxB5:
CustObj2DxB6:
CustObj2DxB7:
CustObj2DxB8:
CustObj2DxB9:
CustObj2DxBA:
CustObj2DxBB:
CustObj2DxBC:
CustObj2DxBD:
CustObj2DxBE:
CustObj2DxBF:
CustObj2DxC0:
CustObj2DxC1:
CustObj2DxC2:
CustObj2DxC3:
CustObj2DxC4:
CustObj2DxC5:
CustObj2DxC6:
CustObj2DxC7:
CustObj2DxC8:
CustObj2DxC9:
CustObj2DxCA:
CustObj2DxCB:
CustObj2DxCC:
CustObj2DxCD:
CustObj2DxCE:
CustObj2DxCF:
CustObj2DxD0:
CustObj2DxD1:
CustObj2DxD2:
CustObj2DxD3:
CustObj2DxD4:
CustObj2DxD5:
CustObj2DxD6:
CustObj2DxD7:
CustObj2DxD8:
CustObj2DxD9:
CustObj2DxDA:
CustObj2DxDB:
CustObj2DxDC:
CustObj2DxDD:
CustObj2DxDE:
CustObj2DxDF:
CustObj2DxE0:
CustObj2DxE1:
CustObj2DxE2:
CustObj2DxE3:
CustObj2DxE4:
CustObj2DxE5:
CustObj2DxE6:
CustObj2DxE7:
CustObj2DxE8:
CustObj2DxE9:
CustObj2DxEA:
CustObj2DxEB:
CustObj2DxEC:
CustObj2DxED:
CustObj2DxEE:
CustObj2DxEF:
CustObj2DxF0:
CustObj2DxF1:
CustObj2DxF2:
CustObj2DxF3:
CustObj2DxF4:
CustObj2DxF5:
CustObj2DxF6:
CustObj2DxF7:
CustObj2DxF8:
CustObj2DxF9:
CustObj2DxFA:
CustObj2DxFB:
CustObj2DxFC:
CustObj2DxFD:
CustObj2DxFE:
CustObj2DxFF:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; These are example codes and subroutines, many of them ripped directly from SMW.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This subroutine lets an object go across screen boundaries horizontally without
; glitching.  It doesn't work in vertical levels, though.  Ripped from $0DA95B.

ShiftObjRight:		;

INY			; increment the subscreen index
TYA			;
AND #$0F		; if the next tile is not at X-position 0 within the screen...
BNE NoChangeScreen	; return
LDA $6B			;
CLC			;
ADC #$B0			; add 1B0 to the low byte of the Map16 pointer,
STA $6B			; effectively shifting the screen number over 1
STA $6E			;
LDA $6C			;
ADC #$01		; handle the high byte of the pointer
STA $6C			;
STA $6F			;
INC $1BA1|!addr		; increment...the current screen being processed?
LDA $57			;
AND #$F0		;
TAY			;
NoChangeScreen:		;
RTS			;

; This subroutine lets an object go across screen boundaries vertically without
; glitching.  It doesn't work in vertical levels, though.  Ripped from $0DA97D.

ShiftObjDown:		;

LDA $57			;
CLC			;
ADC #$10		; shift the subscreen position down one line
STA $57			;
TAY			;
BCC NoChangeScreen2	; if there was no overflow, don't shift the subscreen number
LDA $6C			;
ADC #$00		; the carry flag is already set, so add 1 to the subscreen number
STA $6C			;
STA $6F			;
STA $05			;
NoChangeScreen2:		;
RTS			;

; This subroutine lets an object go across screen boundaries *backward* horizontally without
; glitching.  It doesn't work in vertical levels, though.  Ripped from $0DA95B.

ShiftObjLeft:		;

DEY			;
TYA			;
AND #$0F		; if the next tile is not at X-position F within the screen...
CMP #$0F			;
BNE NoChangeScreen3	; return
LDA $6B			;
SEC			;
SBC #$B0			; add 1B0 to the low byte of the Map16 pointer,
STA $6B			; effectively shifting the screen number over 1
STA $6E			;
LDA $6C			;
SBC #$01			; handle the high byte of the pointer
STA $6C			;
STA $6F			;
DEC $1BA1|!addr		; increment...the current screen being processed?
LDA $57			;
AND #$F0		;
ORA #$0F			;
TAY			;
NoChangeScreen3:		;
RTS			;

; This subroutine lets an object go across screen boundaries *backward* vertically without
; glitching.  It doesn't work in vertical levels, though.  Adapted from $0DA97D.

ShiftObjUp:		;

LDA $57			;
SEC			;
SBC #$10			; shift the subscreen position down one line
STA $57			;
TAY			;
BCS NoChangeScreen4	; if there was no overflow, don't shift the subscreen number
LDA $6C			;
SBC #$00			; the carry flag is already clear, so subtract 1 from the subscreen number
STA $6C			;
STA $6F			;
STA $05			;
NoChangeScreen4:		;
RTS			;

; This subroutine lets an object go across screen boundaries horizontally without
; glitching, but it shifts the position over a customizable number of tiles instead
; of just one.  Load the number of tiles to shift over into A before calling this.

ShiftObjRight2:		;

STA $0E			;
LDA $57			;
AND #$0F		;
STA $0F			;
CLC			;
ADC $0E			;
CMP #$10			;
AND #$0F		;
STA $0F			;
BCC NoChangeScreen5	; return
LDA $6B			;
CLC			;
ADC #$B0			; add 1B0 to the low byte of the Map16 pointer,
STA $6B			; effectively shifting the screen number over 1
STA $6E			;
LDA $6C			;
ADC #$01		; handle the high byte of the pointer
STA $6C			;
STA $6F			;
INC $1BA1|!addr		; increment...the current screen being processed?
NoChangeScreen5:		;
LDA $57			;
AND #$F0		;
ORA $0F			;
STA $57			;
RTS			;

; This subroutine lets an object go across screen boundaries backward horizontally
; without glitching, but it shifts the position over a customizable number of tiles
; instead of just one.  Load the number of tiles to shift over into A before calling this.

ShiftObjLeft2:		;

STA $0E			;
LDA $57			;
AND #$0F		;
STA $0F			;
SEC			;
SBC $0E			;
CMP #$10			;
AND #$0F		;
STA $0F			;
BCC NoChangeScreen6	; return
LDA $6B			;
SEC			;
SBC #$B0			; add 1B0 to the low byte of the Map16 pointer,
STA $6B			; effectively shifting the screen number over 1
STA $6E			;
LDA $6C			;
SBC #$01			; handle the high byte of the pointer
STA $6C			;
STA $6F			;
DEC $1BA1|!addr		; increment...the current screen being processed?
NoChangeScreen6:		;
LDA $57			;
AND #$F0		;
ORA $0F			;
STA $57			;
RTS			;

; This subroutine creates an object composed of only one Map16 tile that can be
; set to take item memory into account.  Adapted from $0DA8C3.
; Input: $0C-$0D = tile number, X = 00 -> use item memory, X != 00 -> don't
; use item memory.

SingleTileObj:		;

LDY $57			;
LDA $59			;
AND #$0F		; get the object's Y size
STA $00			;
STA $02			;
LDA $59			;
LSR #4			; get the object's X size
STA $01			;

JSR BackUpPtrs		;

StartObjLoop0:		;

CPX #$00			; The only object here that used item memory was object 05, the coins,
BNE SetTileNumber		; but now you can choose whether to use it or not.

JSR GetItemMemoryBit	; check the item memory

LDA $0F			; if the item memory routine returned zero...
BEQ SetTileNumber		; continue the object routine

JSR ShiftObjRight		; if the item memory bit was set, then skip this tile
BRA DecAndLoop0		;

SetTileNumber:		;

LDA $0C			; set the tile number
STA [$6B],y		; this routine originally used a table for the low byte
LDA $0D			; and checked the index to determine whether to set
STA [$6E],y		; the high byte to 00 or 01, but I have circumvented that

JSR ShiftObjRight		; shift the tile position right one tile

DecAndLoop0:		;

DEC $02			; if there are more tiles to draw on this line...
BPL StartObjLoop0		; loop the routine

JSR RestorePtrs		; if not, restore the base tile position...
JSR ShiftObjDown		; and move on to the next line

LDA $00			;
STA $02			; also reset the X position counter
DEC $01			; decrement the Y position (line) counter
BMI EndObjLoop0		; if still positive...
JMP StartObjLoop0		; loop the routine

EndObjLoop0:		;
RTS			;

; This subroutine backs up the low bytes of the Map16 pointers in scratch RAM.
; Ripped from $0DA6B1.

BackUpPtrs:	;

LDA $6B		;
STA $04		;
LDA $6C		;
STA $05		;
RTS		;

; This subroutine restores the low bytes of the Map16 pointers from scratch RAM.
; Ripped from $0DA6BA.

RestorePtrs:	;

LDA $04		;
STA $6B		;
STA $6E		;
LDA $05		;
STA $6C		;
STA $6F		;
LDA $1928|!addr	;
STA $1BA1|!addr	;
RTS		;

; This subroutine checks the item memory bits for a particular position
; on the screen.  It can be used with either normal or extended objects.
; Ripped from $0DA8DC.
; Output: $0F = 00 -> item memory bit not set, $0F != 00 -> item memory bit set.

GetItemMemoryBit:		;

PHX			;
PHY			;

LDX $13BE|!addr		; item memory setting
LDA #$F8			; base address low byte
CLC			;
ADC $0DA8AE|!bank,x		; plus offset
STA $08			;
if !sa1 == 1
LDA #$79			; base address high byte
else
LDA #$19			; base address high byte
endif
ADC $0DA8B1|!bank,x		; plus offset
STA $09			; forms a 16-bit pointer

LDA $1BA1|!addr		;
ASL #2			;
STA $0E			;
LDA $0A			; I think $0A contained the "NBBYYYYY" byte?...
AND #$10		; if the object is on the lower subscreen...
BEQ UpperSubscreen	;
LDA $0E			;
ORA #$02			;
STA $0E			;
UpperSubscreen:		;
TYA			;
AND #$08		; if the object is on the left half of the subscreen...
BEQ LeftHalfOfScreen	;
LDA $0E			;
ORA #$01			;
STA $0E			;
LeftHalfOfScreen:		;
TYA			;
AND #$07		;
TAX			; get the bit index into the table
LDY $0E			; get the byte index
LDA ($08),y		; item memory pointer
AND $0DA8A6|!bank,x		; check a particular bit
STA $0F			;

PLY			;
PLX			;
RTS			;

; This subroutine stores an object's X position to $06, Y position to $07, width to $08, and height to $09.

StoreNybbles:
LDA $57
AND #$0F
STA $06
LDA $57
LSR #4
STA $07
LDA $59
AND #$0F
STA $08
LDA $59
LSR #4
STA $09
RTS













