PRINT "INIT ",pc
incsrc sprites\header.asm
;Point to the current frame
!FramePointer = $C2,x

;Point to the current frame on the animation
!AnFramePointer = $1504,x

;Point to the current animation
!AnPointer = $1510,x

;Time for the next frame change
!AnimationTimer = $1540,x

!invisible = $151C,x

!firstOrSecond = $1534,x

LDA #$00
STA !tileRelativePositionNormal,x
STa !firstOrSecond

LDA #$02
STA !invisible

STZ !FramePointer
STZ !AnPointer
STZ !AnFramePointer
LDA #$04
STA !AnimationTimer

LDA #$01
STA !mode50

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

	JSR Graphics ;graphic routine

	LDA $14C8,x			;\
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
eatFrames:
	db $00,$01,$02,$03,$02,$01

AnimationsNFr:
eatNext:
	db $01,$02,$03,$04,$05,$00

AnimationsTFr:
eatTimes:
	db $06,$06,$06,$06,$06,$06
;===================================
;Graphic Routine
;===================================

tileRelative: db $00,$C0

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
FramesTotalTiles:
	db $2C,$2C,$2C,$2A

StartPositionFrames:
	dw $002C,$0059,$0086,$00B1

EndPositionFrames:
	dw $0000,$002D,$005A,$0087

FramesXDisp:
frame1XDisp:
	db $40,$50,$58,$10,$20,$30,$40,$50,$60,$10,$10,$20,$20,$30,$30,$40,$40,$50,$50,$60,$60,$68,$68,$08,$18,$28,$38,$48,$58,$68,$08,$18,$28,$38,$48,$58,$68,$00,$10,$20,$30,$40,$50,$60,$70
frame2XDisp:
	db $38,$48,$50,$08,$18,$28,$38,$48,$58,$68,$18,$28,$38,$48,$58,$60,$10,$10,$20,$20,$30,$30,$40,$40,$50,$50,$60,$60,$68,$68,$08,$18,$28,$38,$48,$58,$68,$00,$10,$20,$30,$40,$50,$60,$70
frame3XDisp:
	db $28,$38,$48,$50,$18,$28,$38,$48,$58,$10,$10,$20,$20,$30,$30,$40,$40,$50,$50,$60,$60,$68,$68,$08,$18,$28,$38,$48,$58,$68,$08,$18,$28,$38,$48,$58,$68,$00,$10,$20,$30,$40,$50,$60,$70
frame4XDisp:
	db $28,$38,$48,$18,$28,$38,$48,$58,$17,$27,$37,$47,$57,$5F,$10,$20,$30,$40,$50,$60,$68,$08,$18,$28,$38,$48,$58,$68,$08,$18,$28,$38,$48,$58,$68,$00,$10,$20,$30,$40,$50,$60,$70


FramesYDisp:
frame1yDisp:
	db $A0,$A0,$A0,$B0,$B0,$B0,$B0,$B0,$B0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$00,$00,$00,$00,$00,$00,$00,$00
frame2yDisp:
	db $A0,$A0,$A0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$B0,$B0,$B0,$B0,$B0,$B0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$00,$00,$00,$00,$00,$00,$00,$00
frame3yDisp:
	db $A0,$A0,$A0,$A0,$B0,$B0,$B0,$B0,$B0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$C0,$D0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$00,$00,$00,$00,$00,$00,$00,$00
frame4yDisp:
	db $A0,$A0,$A0,$B0,$B0,$B0,$B0,$B0,$C0,$C0,$C0,$C0,$C0,$C0,$D0,$D0,$D0,$D0,$D0,$D0,$D0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$00,$00,$00,$00,$00,$00,$00,$00


FramesPropertie:
frame1Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F
frame2Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F
frame3Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F
frame4Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F


FramesTile:
frame1Tiles:
	db $80,$82,$83,$A0,$A2,$A4,$A6,$A8,$AA,$C0,$E0,$C2,$E2,$C4,$E4,$C6,$E6,$C8,$E8,$CA,$EA,$CB,$EB,$85,$87,$89,$8B,$8D,$AC,$AE,$01,$03,$05,$07,$09,$0B,$0D,$20,$22,$24,$26,$28,$2A,$2C,$2E
frame2Tiles:
	db $80,$82,$83,$85,$87,$89,$8B,$8D,$AC,$AE,$A0,$A2,$A4,$A6,$A8,$A9,$C0,$E0,$C2,$E2,$C4,$E4,$C6,$E6,$C8,$E8,$CA,$EA,$CB,$EB,$01,$03,$05,$07,$09,$0B,$0D,$20,$22,$24,$26,$28,$2A,$2C,$2E
frame3Tiles:
	db $80,$82,$84,$85,$A0,$A2,$A4,$A6,$A8,$C0,$E0,$C2,$E2,$C4,$E4,$C6,$E6,$C8,$E8,$CA,$EA,$CB,$EB,$87,$89,$8B,$8D,$AA,$AC,$AE,$01,$03,$05,$07,$09,$0B,$0D,$20,$22,$24,$26,$28,$2A,$2C,$2E
frame4Tiles:
	db $80,$82,$84,$A0,$A2,$A4,$A6,$A8,$C0,$C2,$C4,$C6,$C8,$C9,$E0,$E2,$E4,$E6,$E8,$EA,$EB,$86,$88,$8A,$8C,$8E,$AA,$AC,$01,$03,$05,$07,$09,$0B,$0D,$20,$22,$24,$26,$28,$2A,$2C,$2E

VramTable: dw $0000,$1800,$3000,$4800

VramDest: dw $6800,$7400

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

	LDY $0000
	
	REP #$20
	LDA GFXPointer
	CLC
	ADC VramTable,y
	STA !GFXRec,x
	CLC
	ADC #$0C00
	STA !GFXRec+$02,x

	LDA #$0C00
	STA !GFXLenght,x
	STA !GFXLenght+$02,x

	LDY $0001
	LDA VramDest,y
	STA !GFXVram,x
	CLC
	ADC #$0600
	STA !GFXVram+$02,x

	SEP #$20
	RTS


GFXPointer:
dw resource

;fill this with the name of your exgfx (replace "resource.bin" for the name of your graphic.bin)
resource:
incbin sprites\orca.bin