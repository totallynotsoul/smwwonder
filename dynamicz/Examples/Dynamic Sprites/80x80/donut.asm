PRINT "INIT ",pc
incsrc sprites\header.asm

!FramePointer = $C2,x

;Point to the current frame on the animation
!AnFramePointer = $1504,x

;Point to the current animation
!AnPointer = $1510,x

!invisible = $151C,x

!DynamicSwitch = $1528,x

;Time for the next frame change
!AnimationTimer = $1602,x

!extraBit = $7FAB10,x

!GlobalFlipper = $1534,x

!LocalFlipper = $1570,x

LDA #$04
STA !invisible

LDA #$00
STA !FramePointer
STZ !AnPointer
STZ !AnFramePointer
STZ !DynamicSwitch
LDA #$01
STA !AnimationTimer

LDA #$01
STA !mode50

LDA #$FF
STA !tileRelativePositionNormal,x

JSL !reserveNormalSlot80

LDA !tileRelativePositionNormal,x
CMP #$FF
BNE +
LDY $161A,x
LDA #$00
STA $1938,y
STZ $14C8,x
+

RTL

PRINT "MAIN ",pc

PHB
PHK
PLB
JSR SpriteCode
PLB
RTL

;===================================
;Sprite Function
;===================================

Return:
	RTS

SpriteCode:
	LDA #$01
	STA !mode50
	
	LDA !invisible
	BEQ +

	DEC A
	STA !invisible
	BRA .ret
+
	JSR sendSignal
	JSR Graphics ;graphic routine

	LDA $14C8,x			;\
	CMP #$08			; | If sprite dead,
	BNE .ret2			;/ Return.
	
	JSL !SUB_OFF_SCREEN_X0

	LDA $9D				;\
	BNE .ret			;/ If locked, return.

	JSR GraphicManager ;manage the frames of the sprite and decide what frame show

.ret2
	RTS
.ret
	JSR preDynRoutine ;get a dynamic slot to make the dma routine using dynamic z
	RTS
;===================================
;Graphic Manager
;===================================	
;					 $00,$08,$20,$28,$40,$48,$60,$68
spriteAorBMode50: db $00,$00,$01,$01,$01,$01,$01,$01
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
				db $00,$00,$00,$00,$00,$00,$00,$00
					
;			   $00,$08,$20,$28,$40,$48,$60,$68
spriteAorB: db $00,$00,$00,$00,$01,$01,$01,$01

GraphicManager:
	LDA !tileRelativePositionNormal,x
	TAY
	
	LDA !mode50
	BEQ +
	LDA spriteAorBMode50,y
	STA $00
	BRA ++
+
	LDA spriteAorB,y
	STA $00
++
	
	LDA !DTimer ;timer
	AND #$01
	CMP $00
	BNE .ret
	
	;if !AnimationTimer is Zero go to the next frame
	LDA !AnimationTimer
	BEQ ChangeFrame
	DEC !AnimationTimer
	RTS
.ret
	LDA !DynamicSwitch
	BEQ +
	JSR DynamicRoutine ;get a dynamic slot to make the dma routine using dynamic z
+
	RTS

ChangeFrame:

	;Load the animation pointer X2
	LDA !AnPointer
	
	REP #$30
	AND #$00FF
	TAY
	
	
	LDA !AnFramePointer
	CLC
	ADC EndPositionAnim,y
	TAY
	SEP #$30
	
	LDA AnimationsFrames,y
	STA !FramePointer
	
	LDA AnimationsNFr,y
	STA !AnFramePointer
	
	LDA AnimationsTFr,y
	STA !AnimationTimer
	
	LDA !GlobalFlipper
	EOR AnimationsFlips,y
	STA !LocalFlipper
	
	LDA #$01
	STA !DynamicSwitch
	
	RTS	
	
;===================================
;Animation
;===================================
EndPositionAnim:
	dw $0000

AnimationsFrames:
rotarFrames:
	db $00,$01,$02,$01

AnimationsNFr:
rotarNext:
	db $01,$02,$03,$00

AnimationsTFr:
rotarTimes:
	db $02,$02,$02,$02

AnimationsFlips:
rotarFlip:
	db $00,$00,$00,$00
	
;===================================
;Graphic Routine
;===================================
tileRel: db $00,$08,$20,$28,$40,$48,$60,$68,$80,$88,$A0,$A8,$C0,$C8,$E0,$E8

Graphics:
	LDA !tileRelativePositionNormal,x
	TAY
	LDA tileRel,y
	STA $0F ;load the relative position of the tiles on $0F

	JSL !GET_DRAW_INFO
	LDA $06
	BEQ + ;if the sprite is off-screen don't draw it
	RTS
+
	PHX
	
	LDX #$15 ;load the total of tiles on Y
-
	LDA frame1XDisp,x 
	CLC
	ADC $00
	STA $0300,y ;load the tile X position

	LDA frame1YDisp,x
	CLC
	ADC $01
	STA $0301,y ;load the tile Y position

	LDA #$2F
	ORA $64
	STA $0303,y ;load the tile Propertie

	LDA frame1Tile,x
	CLC
	ADC $0F ;add the relative position of the tile on the Vram map
	STA $0302,y ;load the tile

	INY
	INY
	INY
	INY ;next slot

	DEX
	BPL - ;if Y < 0 exit to loop
	
	PLX
	LDY #$02 ;load the size
	LDA #$15 ;load the total of tiles on $0E
	JSL $01B7B3 ;call the oam routine	
	RTS

;===================================
;Frames
;===================================

;#################frame1#################
frame1XDisp:
	db $00,$10,$20,$30,$00,$10,$20,$30,$38,$00,$10,$20,$30,$38,$00,$10,$20,$28,$38,$10,$20,$28

frame1YDisp:
	db $00,$00,$00,$00,$F0,$F0,$F0,$F0,$F0,$E0,$E0,$E0,$E0,$E0,$D0,$D0,$D0,$D0,$D0,$C0,$C0,$C0

frame1Tile:
	db $C0,$C2,$C4,$C6,$A0,$A2,$A4,$A6,$A7,$80,$82,$84,$86,$87,$A9,$AB,$AD,$AE,$C9,$8B,$8D,$8E


;===================================
;Dynamic Routine
;===================================

VramTable:
	dw $0000,$0C00,$1800,$2400

preDynRoutine:

	STZ !DynamicSwitch

	LDA !tileRelativePositionNormal,x
	TAY
	
	LDA !mode50
	BEQ +
	LDA spriteAorBMode50,y
	STA $00
	BRA ++
+
	LDA spriteAorB,y
	STA $00
++
	
	LDA !DTimer ;timer
	AND #$01
	CMP $00
	BNE startDyn
	RTS

DynamicRoutine:

	STZ !DynamicSwitch

	LDA !tileRelativePositionNormal,x
	TAY
startDyn:	

	JSL !DynamicRoutine80Start
	
	LDA !FramePointer
	ASL
	TAY 
	
	PHX
	LDX $0000
	
	PHB
	PLA
	STA !dynSpBnk,x ;set the BNK of the graphics
	LDA #$00
	STA !dynSpBnk+$01,x

	REP #$20
	LDA VramTable,y
	CMP #$FFFF
	BEQ +	
	CLC
	ADC GFXPointer ;get the graphic pointer to the current frame
	STA !dynSpRec,x
	
	LDA #$0C00
	STA !dynSpLength,x
	
	LDA #$FFFF
	STA !nextDynSlot,x
+
	SEP #$20
	
	PLX
.ret
	RTS
	
sendSignal:
	LDA !tileRelativePositionNormal,x
	TAY
	
	JSL !Ping80

	RTS
	
adder: db $C0,$20
	
GFXPointer:
dw recurso

recurso:
incbin sprites\donut.bin