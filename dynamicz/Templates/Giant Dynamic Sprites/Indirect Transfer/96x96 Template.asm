PRINT "INIT ",pc
incsrc sprites\header.asm

!Bank1 = #$30
!Bank2 = #$31
!Bank3 = #$32
;.
;.
;.

!Source1 = #$8008
!Source2 = #$8008
!Source3 = #$8008
;.
;.
;.

;Point to the current frame
!FramePointer = $C2,x

;Point to the current frame on the animation
!AnFramePointer = $1504,x

;Point to the current animation
!AnPointer = $1510,x

;Time for the next frame change
!AnimationTimer = $1540,x

!invisible = $151C,x

LDA #$00
STA !tileRelativePositionNormal,x

LDA #$02
STA !invisible



STZ !FramePointer
STZ !AnPointer
STZ !AnFramePointer
LDA #$04
STA !AnimationTimer

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

	JSR Graphics ;graphic routine

	LDA $14C8,x			;\
	CMP #$08			; | If sprite dead,
	BNE Return			;/ Return.

	LDA $9D				;\
	BNE Return			;/ If locked, return.
	JSL !SUB_OFF_SCREEN_X0
	
	;Here you can put the logic of the sprite.
	
	JSR GraphicManager ;manage the frames of the sprite and decide what frame show
	
	RTS
	
;===================================
;Graphic Manager
;===================================	
GraphicManager:

	;if !AnimationTimer is Zero go to the next frame
	LDA !AnimationTimer
	BEQ ChangeFrame
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
	
	LDA !tileRelativePositionNormal,x
	EOR #$01
	STA !tileRelativePositionNormal,x
	
	JSR DynamicRoutine
	
	RTS	

;===================================
;Animation
;===================================
;See the Tutorial to know how to fill these tables.
EndPositionAnim:
	dw 

AnimationsFrames:
	db
AnimationsNFr:
	db
AnimationsTFr:
	db
AnimationsFlips:
	db

;===================================
;Graphic Routine
;===================================

tileRelative: db $00,$80

Graphics:
	REP #$10
	LDY #$0000
	SEP #$10

	JSL !GET_DRAW_INFO
	LDA $06
	BEQ .cont ;if the sprite is off-screen don't draw it
	RTS
.cont
	
	PHX
	LDA !tileRelativePositionNormal,x
	STA $0B
	TAX
	LDA tileRelative,x
	STA $0F
	PLX
	PHX
	
	LDA !FramePointer
	
	REP #$30

	AND #$00FF
	ASL
	TAX
	
	LDA EndPositionFrames,x
	STA $0D
	
	LDA StartPositionFrames,x
	TAX
	SEP #$20

.loop
	LDA FramesXDisp,x 
	CLC
	ADC $00
	STA $0300,y ;load the tile X position

	LDA FramesYDisp,x
	CLC
	ADC $01
	STA $0301,y ;load the tile Y position

	LDA FramesPropertie,x
	ORA $64
	ORA $0B
	STA $0303,y ;load the tile Propertie

	LDA FramesTile,x
	CLC
	ADC $0F
	STA $0302,y ;load the tile

	INY
	INY
	INY
	INY ;next slot

	DEX
	BMI +
	CPX $0D
	BCS .loop ;if Y < 0 exit to loop
+
	SEP #$10
	PLX
	
	LDA !FramePointer
	TAY
	LDA FramesTotalTiles,y ;load the total of tiles on $0E
	LDY #$02 ;load the size
	JSL $01B7B3 ;call the oam routine
	RTS
	
;===================================
;Frames
;===================================
;See the Tutorial to know how to fill these tables.
FramesTotalTiles:
	db
StartPositionFrames:
	dw
EndPositionFrames:
	dw
	
FramesXDisp:
	db
FramesYDisp:
	db 
FramesPropertie:
	db
FramesTile:
	db
	
;===================================
;Dynamic Routine
;===================================
;See the Tutorial to know how to fill this tables.
VramTable: dw $0000,$1000,$2000,$3000,$4000

VramDest: dw $6800,$7000

banks: db

sources: dw

DynamicRoutine:

	LDA !FramePointer
	STA $03
	ASL
	STA $00
	
	PHX
	LDA !tileRelativePositionNormal,x
	ASL
	STA $01
	
	JSR GraphicChange
	
	PLX
	
	RTS
	
GraphicChange:

	LDA !GFXNumber
	CMP #$0A
	BCC +
	RTS
+
	ASL
	TAX
	LSR
	INC A
	INC A
	STA !GFXNumber

	LDY $0003
	LDA banks,y
	STA !GFXBnk,x
	STA !GFXBnk+$02,x
	LDA #$00
	STA !GFXBnk+$01,x
	STA !GFXBnk+$03,x

	LDY $0000
	
	REP #$20
	LDA sources,y
	CLC
	ADC VramTable,y
	STA !GFXRec,x
	CLC
	ADC #$0800
	STA !GFXRec+$02,x

	LDA #$0800
	STA !GFXLenght,x
	STA !GFXLenght+$02,x

	LDY $0001
	LDA VramDest,y
	STA !GFXVram,x
	CLC
	ADC #$0400
	STA !GFXVram+$02,x

	SEP #$20
	RTS
