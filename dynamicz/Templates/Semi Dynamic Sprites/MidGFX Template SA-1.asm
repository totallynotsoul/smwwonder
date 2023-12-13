;~@sa1 <-- DO NOT REMOVE THIS LINE!
PRINT "INIT ",pc
incsrc sprites\header.asm

;Point to the current frame
!FramePointer = $D8,x

;Point to the current frame on the animation
!AnFramePointer = $74F4,x

;Point to the current animation
!AnPointer = $750A,x

!invisible = $3284,x

;Time for the next frame change
!AnimationTimer = $32C6,x

!GlobalFlipper = $32B0,x

!LocalFlipper = $331E,x

!SelectedSlot = $400057,x

LDA #$06
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

	LDA !invisible
	BEQ ++
	CMP #$05
	BNE +
	JSR semiDynamicRoutine
	BMI MustbeReloaded
	BEQ +

	;Here you can load the palette of color if you want

+
	LDA !invisible
	DEC A
	STA !invisible
	BRA .ret
++

	JSR Graphics ;graphic routine

	LDA $3242,x			;\
	CMP #$08			; | If sprite dead,
	BNE Return			;/ Return.

	LDA $9D				;\
	BNE Return			;/ If locked, return.
	JSL !SUB_OFF_SCREEN_X0
	
	;Here you can put the logic of the sprite.
	
	JSR GraphicManager ;manage the frames of the sprite and decide what frame show
.ret
	RTS
	
MustbeReloaded:
	LDY $7578,x
	LDA #$00
	PHX
	TYX
	STA $418A00,x
	PLX        
	STZ $3242,x
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
	
	LDA !GlobalFlipper
	EOR AnimationsFlips,y
	STA !LocalFlipper
	
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
FlipAdder: db $00,$0F
relativeDisp: db $00,$40,$80,$C0
movePage: db $00,$00,$01,$01
Graphics:
	REP #$10
	LDY #$0000
	SEP #$10
	
	LDA !SelectedSlot
	TAY
	LDA relativeDisp,y
	STA $0F
	LDA movePage,y
	STA $0C
	STA $6DBF

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
	AND #$01
	BEQ +
	LDA FramesTile,x
	BRA .tile
+
	LDA FramesTile,x
	CMP #$80
	BCC .tile
	CMP #$C0
	BCS .tile
	CLC
	ADC $0F
	STA $6302,y ;load the tile
	
	LDA FramesPropertie,x
	ORA $64
	EOR $0C
	STA $6303,y ;load the tile Propertie
	BRA ++
.tile
	STA $6302,y ;load the tile
	
	LDA FramesPropertie,x
	ORA $64
	STA $6303,y ;load the tile Propertie
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
;Semi Dynamic Routine
;===================================
vram: dw $6800,$6C00,$7000,$7400 

semiDynamicRoutine:

	LDA $400083,x
	STA $02	

	PHX
	LDA !SelectedSlot 
	TAX ;x = selected slot
	
	LDA !SemiDynamicSlots,x ;if the slot is not used then try to start
	CMP #$FF
	BEQ .start
	PLX
	CMP $400083,x ;if this sprite is a copy of the sprite that reserve the slot then return
	BNE +
	LDA #$00
	RTS
+
	PHX
	
	STA $00 ;$00 = index of the sprite that use the slot
	LDX #$0B
.loop
	LDA $400083,x ;if exists a copy of the sprite that use the slot then return
	BEQ ++
	CMP #$FF
	BEQ ++
	CMP $02
	BEQ ++
	CMP $00
	BNE +
	PLX
	LDA #$FF
	RTS
+
++
	DEX
	BPL .loop
	
.start
	
	LDA !GFXNumber
	CMP #$0A
	BCC +
	LDA #$FF
	RTS
+
	PLX
	PHX

	LDA $400083,x
	STA $00
	
	LDA !SelectedSlot
	TAX
	ASL
	TAY
	
	LDA $00
	STA !SemiDynamicSlots,x ;reserve the slot

	LDA !GFXNumber
	INC A
	STA !GFXNumber 
	DEC A
	ASL
	TAX
	
	PHB
	PHK
	PLB

	PHB
	PLA
	STA !GFXBnk,x
	LDA #$00
	STA !GFXBnk+$01,x

	REP #$20
	LDA GFXPointer
	STA !GFXRec,x

	LDA #$0800
	STA !GFXLenght,x

	LDA vram,y
	STA !GFXVram,x

	SEP #$20
	PLB
	PLX
	LDA #$01
	RTS
	
GFXPointer:
dw resource

resource:
incbin sprites\GFXName.bin ;replace this for your GFX name