;~@sa1 <-- DO NOT REMOVE THIS LINE!
PRINT "INIT ",pc
incsrc sprites\header.asm
;Point to the current frame
!FramePointer = $D8,x

;Point to the current frame on the animation
!AnFramePointer = $74F4,x

;Point to the current animation
!AnPointer = $750A,x

;Time for the next frame change
!AnimationTimer = $32C6,x

!invisible = $3284,x

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

	LDA $3242,x			;\
	CMP #$08			; | If sprite dead,
	BNE Return			;/ Return.

	LDA $9D				;\
	BNE Return			;/ If locked, return.
	JSL !SUB_OFF_SCREEN_X0
	
	
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
EndPositionAnim:
	dw $0000

AnimationsFrames:
rotateFrames:
	db $00,$01,$02,$03,$04,$03,$02,$01

AnimationsNFr:
rotateNext:
	db $01,$02,$03,$04,$05,$06,$07,$00

AnimationsTFr:
rotateTimes:
	db $04,$04,$04,$04,$04,$04,$04,$04

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
	STA $6300,y ;load the tile X position

	LDA FramesYDisp,x
	CLC
	ADC $01
	STA $6301,y ;load the tile Y position

	LDA FramesPropertie,x
	ORA $64
	ORA $0B
	STA $6303,y ;load the tile Propertie

	LDA FramesTile,x
	CLC
	ADC $0F
	STA $6302,y ;load the tile

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

	db $27,$1E,$1E,$21,$1D

StartPositionFrames:
	dw $0027,$0046,$0065,$0087,$00A5

EndPositionFrames:
	dw $0000,$0028,$0047,$0066,$0088

FramesXDisp:
f1XDisp:
	db $FF,$FF,$FF,$07,$07,$07,$F4,$F4,$04,$04,$14,$14,$F2,$F2,$F2,$02,$02,$02,$12,$12,$12,$1A,$1A,$1A,$EC,$EC,$FC,$FC,$0C,$0C,$1C,$1C,$F4,$F4,$F4,$04,$14,$14,$15,$15
f2XDisp:
	db $FA,$FA,$0A,$0A,$02,$0A,$FB,$0B,$13,$F8,$F6,$08,$06,$18,$16,$F0,$00,$10,$20,$F0,$00,$10,$20,$14,$16,$16,$26,$FA,$FA,$FA,$0A
f3XDisp:
	db $FB,$FB,$0B,$0B,$03,$0B,$FF,$0F,$17,$FA,$FA,$0A,$0A,$1A,$1A,$F8,$08,$18,$20,$F9,$09,$19,$21,$03,$03,$03,$1B,$1B,$1B,$0B,$0B
f4XDisp:
	db $F8,$F8,$08,$08,$10,$10,$FE,$0E,$00,$10,$18,$00,$10,$18,$F8,$08,$18,$F8,$08,$18,$20,$F8,$08,$18,$20,$01,$11,$19,$05,$17,$1F,$02,$12,$1A
f5XDisp:
	db $F8,$F6,$08,$06,$18,$16,$FA,$0A,$03,$13,$03,$13,$1B,$F8,$08,$18,$F8,$08,$18,$20,$F8,$08,$18,$20,$08,$18,$09,$19,$06,$16


FramesYDisp:
f1yDisp:
	db $B0,$C0,$C8,$B0,$C0,$C8,$D8,$E0,$D8,$E0,$D8,$E0,$F0,$00,$08,$F0,$00,$08,$F0,$00,$08,$F0,$00,$08,$18,$20,$18,$20,$18,$20,$18,$20,$30,$40,$50,$30,$30,$40,$48,$58
f2yDisp:
	db $B0,$C0,$B0,$C0,$D0,$D0,$E0,$E0,$E0,$F0,$00,$F0,$00,$F0,$00,$10,$10,$10,$10,$20,$20,$20,$20,$30,$40,$50,$4C,$30,$40,$50,$40
f3yDisp:
	db $B0,$C0,$B0,$C0,$D0,$D0,$E0,$E0,$E0,$F0,$00,$F0,$00,$F0,$00,$10,$10,$10,$10,$20,$20,$20,$20,$30,$40,$50,$30,$40,$50,$30,$48
f4yDisp:
	db $B0,$C0,$B0,$C0,$B0,$C0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$10,$10,$10,$10,$20,$20,$20,$20,$30,$30,$30,$40,$40,$40,$50,$50,$50
f5yDisp:
	db $B0,$C0,$B0,$C0,$B0,$C0,$D0,$D0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$10,$10,$10,$10,$20,$20,$20,$20,$30,$30,$40,$40,$50,$50


FramesPropertie:
f1Properties:
	db $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
f2Properties:
	db $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
f3Properties:
	db $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
f4Properties:
	db $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
f5Properties:
	db $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C


FramesTile:
f1Tiles:
	db $80,$A0,$B0,$81,$A1,$B1,$D0,$E0,$D2,$E2,$D4,$E4,$83,$A3,$B3,$85,$A5,$B5,$87,$A7,$B7,$88,$A8,$B8,$D6,$E6,$D8,$E8,$DA,$EA,$DC,$EC,$8E,$AE,$CE,$8A,$8C,$AC,$BC,$BA
f2Tiles:
	db $80,$A0,$82,$A2,$C1,$C2,$E0,$E2,$E3,$84,$A4,$86,$A6,$88,$A8,$C5,$C7,$C9,$CB,$E5,$E7,$E9,$EB,$8C,$8A,$AA,$ED,$8E,$AE,$CE,$ED
f3Tiles:
	db $80,$A0,$82,$A2,$C1,$C2,$E0,$E2,$E3,$84,$A4,$86,$A6,$88,$A8,$C4,$C6,$C8,$C9,$E5,$E7,$E9,$EA,$8E,$AE,$CE,$8C,$AC,$CC,$8A,$BA
f4Tiles:
	db $80,$A0,$82,$A2,$83,$A3,$C0,$C2,$E0,$E2,$E3,$85,$87,$88,$A5,$A7,$A9,$C4,$C6,$C8,$C9,$E5,$E7,$E9,$EA,$8A,$8C,$8D,$AB,$AD,$AE,$CB,$CD,$CE
f5Tiles:
	db $80,$A0,$82,$A2,$84,$A4,$C0,$C2,$E0,$E2,$86,$88,$89,$A6,$A8,$AA,$C4,$C6,$C8,$C9,$E4,$E6,$E8,$E9,$8B,$8D,$AC,$AE,$CC,$CE

VramTable: dw $0000,$1000,$2000,$3000,$4000

VramDest: dw $6800,$7000

DynamicRoutine:

	LDA !FramePointer
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

	PHB
	PLA
	STA !GFXBnk,x
	STA !GFXBnk+$02,x
	LDA #$00
	STA !GFXBnk+$01,x
	STA !GFXBnk+$03,x

	LDY $3000
	
	REP #$20
	LDA GFXPointer
	CLC
	ADC VramTable,y
	STA !GFXRec,x
	CLC
	ADC #$0800
	STA !GFXRec+$02,x

	LDA #$0800
	STA !GFXLenght,x
	STA !GFXLenght+$02,x

	LDY $3001
	LDA VramDest,y
	STA !GFXVram,x
	CLC
	ADC #$0400
	STA !GFXVram+$02,x

	SEP #$20
	RTS


GFXPointer:
dw resource

;fill this with the name of your exgfx (replace "resource.bin" for the name of your graphic.bin)
resource:
incbin sprites\monoeye.bin
