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

JSL !reserveNormalSlot48

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
ColorDestiny: db $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F
ColorLowByte: db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ColorHihByte: db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

PaletteChange:

	LDA !paletteNumber
	STA $00
	CLC
	ADC #$0F ;put the number of colors that you will change
	CMP #$80
	BCC +
	RTS
+
	STA !paletteNumber
	DEC A
	TAX
	
	LDY #$0F 
.loop
	LDA ColorDestiny,y
	STA !paletteDestiny,x

	LDA ColorLowByte,y
	STA !paletteLow,x

	LDA ColorHihByte,y
	STA !paletteHigh,x

	DEY
	DEX
	BMI +
	CPX $00
	BCS .loop
+
	RTS
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
	dw $0000,$0004

AnimationsFrames:
volarFrames:
	db $00,$01,$02,$01
morirFrames:
	db $03,$04,$05,$06,$07

AnimationsNFr:
volarNext:
	db $01,$02,$03,$00
morirNext:
	db $01,$02,$03,$04,$04

AnimationsTFr:
volarTimes:
	db $01,$01,$01,$01
morirTimes:
	db $01,$01,$01,$01,$01

AnimationsFlips:
volarFlip:
	db $00,$00,$00,$00
morirFlip:
	db $00,$00,$00,$00,$00

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
FramesTotalTiles:
	db $07,$07,$06,$07,$07,$08,$08,$06,$07,$07,$06,$07,$07,$08,$08,$06

StartPositionFrames:
	dw $0007,$000F,$0016,$001E,$0026,$002F,$0038,$003F,$0047,$004F,$0056,$005E,$0066,$006F,$0078,$007F

EndPositionFrames:
	dw $0000,$0008,$0010,$0017,$001F,$0027,$0030,$0039,$0040,$0048,$0050,$0057,$005F,$0067,$0070,$0079

FramesXDisp:
frame1XDisp:
	db $00,$F0,$00,$10,$F8,$08,$10,$10
frame2XDisp:
	db $FD,$0D,$ED,$FD,$0D,$15,$FD,$0D
frame3XDisp:
	db $F1,$01,$11,$F9,$09,$11,$09
frame4XDisp:
	db $F9,$09,$F1,$01,$09,$F1,$01,$11
frame5XDisp:
	db $00,$10,$F0,$00,$08,$F8,$08,$10
frame6XDisp:
	db $01,$E9,$F9,$09,$11,$F1,$01,$09,$F9
frame7XDisp:
	db $00,$08,$F0,$00,$10,$F0,$00,$08,$F8
frame8XDisp:
	db $F0,$00,$08,$F0,$00,$10,$F0
frame1FlipXXDisp:
	db $F0,$00,$F0,$E0,$F8,$E8,$E0,$E0
frame2FlipXXDisp:
	db $F3,$E3,$03,$F3,$E3,$DB,$F3,$E3
frame3FlipXXDisp:
	db $FF,$EF,$DF,$F7,$E7,$DF,$E7
frame4FlipXXDisp:
	db $F7,$E7,$FF,$EF,$E7,$FF,$EF,$DF
frame5FlipXXDisp:
	db $F0,$E0,$00,$F0,$E8,$F8,$E8,$E0
frame6FlipXXDisp:
	db $EF,$07,$F7,$E7,$DF,$FF,$EF,$E7,$F7
frame7FlipXXDisp:
	db $F0,$E8,$00,$F0,$E0,$00,$F0,$E8,$F8
frame8FlipXXDisp:
	db $00,$F0,$E8,$00,$F0,$E0,$00


FramesYDisp:
frame1yDisp:
	db $E8,$F8,$F8,$F8,$08,$08,$08,$10
frame2yDisp:
	db $F0,$F0,$00,$00,$00,$00,$10,$10
frame3yDisp:
	db $F8,$F8,$F8,$08,$08,$08,$18
frame4yDisp:
	db $F2,$F2,$02,$02,$02,$12,$12,$12
frame5yDisp:
	db $F8,$F8,$08,$08,$08,$18,$18,$18
frame6yDisp:
	db $F6,$06,$06,$06,$06,$16,$16,$16,$26
frame7yDisp:
	db $F8,$F8,$08,$08,$08,$18,$18,$18,$28
frame8yDisp:
	db $00,$00,$00,$10,$10,$10,$20
frame1FlipXyDisp:
	db $E8,$F8,$F8,$F8,$08,$08,$08,$10
frame2FlipXyDisp:
	db $F0,$F0,$00,$00,$00,$00,$10,$10
frame3FlipXyDisp:
	db $F8,$F8,$F8,$08,$08,$08,$18
frame4FlipXyDisp:
	db $F2,$F2,$02,$02,$02,$12,$12,$12
frame5FlipXyDisp:
	db $F8,$F8,$08,$08,$08,$18,$18,$18
frame6FlipXyDisp:
	db $F6,$06,$06,$06,$06,$16,$16,$16,$26
frame7FlipXyDisp:
	db $F8,$F8,$08,$08,$08,$18,$18,$18,$28
frame8FlipXyDisp:
	db $00,$00,$00,$10,$10,$10,$20


FramesPropertie:
frame1Properties:
	db $39,$39,$39,$39,$39,$39,$39,$39
frame2Properties:
	db $39,$39,$39,$39,$39,$39,$39,$39
frame3Properties:
	db $39,$39,$39,$39,$39,$39,$39
frame4Properties:
	db $39,$39,$39,$39,$39,$39,$39,$39
frame5Properties:
	db $39,$39,$39,$39,$39,$39,$39,$39
frame6Properties:
	db $39,$39,$39,$39,$39,$39,$39,$39,$39
frame7Properties:
	db $39,$39,$39,$39,$39,$39,$39,$39,$39
frame8Properties:
	db $39,$39,$39,$39,$39,$39,$39
frame1FlipXProperties:
	db $79,$79,$79,$79,$79,$79,$79,$79
frame2FlipXProperties:
	db $79,$79,$79,$79,$79,$79,$79,$79
frame3FlipXProperties:
	db $79,$79,$79,$79,$79,$79,$79
frame4FlipXProperties:
	db $79,$79,$79,$79,$79,$79,$79,$79
frame5FlipXProperties:
	db $79,$79,$79,$79,$79,$79,$79,$79
frame6FlipXProperties:
	db $79,$79,$79,$79,$79,$79,$79,$79,$79
frame7FlipXProperties:
	db $79,$79,$79,$79,$79,$79,$79,$79,$79
frame8FlipXProperties:
	db $79,$79,$79,$79,$79,$79,$79


FramesTile:
frame1Tiles:
	db $80,$82,$84,$86,$88,$8A,$8B,$8D
frame2Tiles:
	db $80,$82,$84,$86,$88,$89,$8B,$8D
frame3Tiles:
	db $80,$82,$84,$86,$88,$89,$8B
frame4Tiles:
	db $80,$82,$84,$86,$87,$89,$8B,$8D
frame5Tiles:
	db $80,$82,$84,$86,$87,$89,$8B,$8C
frame6Tiles:
	db $80,$82,$84,$86,$87,$89,$8B,$8C,$8E
frame7Tiles:
	db $80,$81,$83,$85,$87,$89,$8B,$8C,$8E
frame8Tiles:
	db $80,$82,$83,$85,$87,$89,$8B
frame1FlipXTiles:
	db $80,$82,$84,$86,$88,$8A,$8B,$8D
frame2FlipXTiles:
	db $80,$82,$84,$86,$88,$89,$8B,$8D
frame3FlipXTiles:
	db $80,$82,$84,$86,$88,$89,$8B
frame4FlipXTiles:
	db $80,$82,$84,$86,$87,$89,$8B,$8D
frame5FlipXTiles:
	db $80,$82,$84,$86,$87,$89,$8B,$8C
frame6FlipXTiles:
	db $80,$82,$84,$86,$87,$89,$8B,$8C,$8E
frame7FlipXTiles:
	db $80,$81,$83,$85,$87,$89,$8B,$8C,$8E
frame8FlipXTiles:
	db $80,$82,$83,$85,$87,$89,$8B


;===================================
;Dynamic Routine
;===================================
VramTable:
	dw $0000,$0400,$0800,$0C00,$1000,$1400,$1800,$1C00

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

	JSL !DynamicRoutine48Start
	
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
	
	LDA #$0400
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
	
	JSL !Ping48

	RTS
	
GFXPointer:
dw resource

;fill this with the name of your exgfx (replace "resource.bin" for the name of your graphic.bin)
resource:
incbin sprites\zinger.bin

