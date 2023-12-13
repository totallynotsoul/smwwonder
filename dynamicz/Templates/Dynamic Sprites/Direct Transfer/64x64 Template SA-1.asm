;~@sa1 <-- DO NOT REMOVE THIS LINE!
PRINT "INIT ",pc
incsrc sprites\header.asm

!FramePointer = $D8,x

;Point to the current frame on the animation
!AnFramePointer = $74F4,x

;Point to the current animation
!AnPointer = $750A,x

!invisible = $3284,x

!DynamicSwitch = $329A,x

;Time for the next frame change
!AnimationTimer = $33CE,x

!extraBit = $400040,x

!GlobalFlipper = $32B0,x

!LocalFlipper = $331E,x

LDA #$04
STA !invisible

LDA #$00
STA !FramePointer
STZ !AnPointer
STZ !AnFramePointer
STZ !DynamicSwitch
LDA #$01
STA !AnimationTimer

LDA #$FF
STA !tileRelativePositionNormal,x

JSL !reserveNormalSlot64

LDA !tileRelativePositionNormal,x
CMP #$FF
BNE +
LDY $7578,x
LDA #$00
PHX
TYX
STA $418A00,x
PLX        
STZ $3242,x
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
	LDA !invisible
	BEQ +

	DEC A
	STA !invisible
	BRA .ret
+	
	JSR sendSignal
	JSR Graphics ;graphic routine

	LDA $3242,x			;\
	CMP #$08			; | If sprite dead,
	BNE .ret2			;/ Return.
	
	JSL !SUB_OFF_SCREEN_X0

	LDA $9D				;\
	BNE .ret			;/ If locked, return.
	
	;Here you can put the logic of the sprite.

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
FlipAdder: db $00,$08
tileRel: db $00,$08,$20,$28,$40,$48,$60,$68,$80,$88,$A0,$A8,$C0,$C8,$E0,$E8	

Graphics:
	REP #$10
	LDY #$0000
	SEP #$10
	
	LDA !tileRelativePositionNormal,x
	TAY
	LDA tileRel,y
	STA $0F ;load the relative position of the tiles on $0F

	JSL !GET_DRAW_INFO
	LDA $06
	BEQ .cont ;if the sprite is off-screen don't draw it
	RTS
.cont
	
	PHX
	LDA !LocalFlipper
	PHA
	LDA !FramePointer
	PLX
	CLC
	ADC FlipAdder,x
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
	STA $6300,y ;load the tile X position

	LDA FramesYDisp,x
	CLC
	ADC $01
	STA $6301,y ;load the tile Y position

	LDA FramesPropertie,x
	ORA $64
	STA $6303,y ;load the tile Propertie
	BIT #$01
	BNE +
	LDA FramesTile,x
	STA $6302,y ;load the tile
	BRA ++
+
	LDA FramesTile,x
	BMI +
	STA $6302,y ;load the tile
	BRA ++
+
	CLC
	ADC $0F ;add the relative position of the tile on the Vram map
	STA $6302,y ;load the tile
++

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
VramTable:
	dw

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

	JSL !DynamicRoutine64Start
	
	LDA !FramePointer
	ASL
	TAY 
	
	PHX
	LDX $3000
	
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
	
	LDA #$0800
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
	
	JSL !Ping64

	RTS
	
adder: db $00,$40,$C0,$20
	
GFXPointer:
dw recurso

recurso:
incbin sprites\GFXName.bin