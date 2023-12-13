;you can copy paste this
levelinitxxx:
	RTS
	STZ !LocalFlipper
	STZ !GlobalFlipper
	STZ !FramePointer
	STZ !AnPointer
	STZ !AnFramePointer
	LDA #$04
	STA !AnimationTimer

	RTS

levelxxx:
	RTS
	LDA #$FF
	STA $78
	
	JSR DynamicRoutine

	JSR Graphics ;graphic routine

	JSR GraphicManager ;manage the frames of the sprite and decide what frame show
	
	DEC !AnimationTimer
	
	RTS

GFXPointer:
dw resource

;fill this with the name of your exgfx (replace "resource.bin" for the name of your graphic.bin)
resource:
incbin mmxPlayer.bin
	
VramTable: dw $0000,$0400,$0800,$0C00,$1000,$1400,$1800,$2000,$2400,$1C00
	
DynamicRoutine:

	LDA #$01
	STA !marioCustomGFXOn

	JSR ChangeMarioPal
	
	LDA !FramePointer
	ASL
	TAX
	
	PHB
	PLA
	STA !marioCustomGFXBnk

	REP #$20
	LDA GFXPointer
	CLC
	ADC VramTable,x
	STA !marioCustomGFXRec
	SEP #$20

	RTS
	
;-------------86..87..88..89..8A..8B..8C..8D..8E..8f
;Fill these tables with the colors.
ColorLow: db $98,$11,$FF,$8F,$20,$AA,$86,$63,$00,$C4
ColorHih: db $25,$11,$46,$7F,$7E,$7E,$55,$5D,$7D,$44

ChangeMarioPal:
	LDA #$01
	STA !marioPal

	LDX #$09
.loop
	LDA ColorLow,x
	STA !marioPalLow,x

	LDA ColorHih,x
	STA !marioPalHigh,x

	DEX
	BPL .loop
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
EndPositionAnim:
	dw $0000

AnimationsFrames:
runFrames:
	db $00,$01,$02,$03,$04,$05,$06,$09,$07,$08

AnimationsNFr:
runNext:
	db $01,$02,$03,$04,$05,$06,$07,$08,$09,$00

AnimationsTFr:
runTimes:
	db $04,$04,$04,$04,$04,$04,$04,$04,$04,$04

AnimationsFlips:
runFlip:
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01

;===================================
;Graphic Routine
;===================================
FlipAdder: db $00,$0A
Graphics:
	REP #$10
	LDY #$0000
	SEP #$10
	
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
	STZ $09
	STZ $07
	LDA FramesXDisp,x 
	STA $08
	BPL +
	LDA #$FF
	STA $09
+
	LDA FramesYDisp,x
	STA $06	
	BPL +
	LDA #$FF
	STA $07
+
	
	REP #$20
	LDA $94
	CLC
	ADC $08
	STA $00
	
	LDA $96
	CLC
	ADC $06
	STA $02
	SEP #$20
	
	LDA #$02
	STA $04
	SEP #$10
	
	JSL getDrawInfo200
	REP #$10
	LDA $06
	BNE .next
	
	REP #$20
	PHX
	TXA
	ASL
	TAX
	LDA FramesOam,x
	TAY
	PLX
	SEP #$20

	LDA $00
	STA $0200|!base2,y ;load the tile X position

	LDA $02
	STA $0201|!base2,y ;load the tile Y position

	LDA FramesPropertie,x
	STA $0203|!base2,y ;load the tile Propertie

	LDA FramesTile,x
	STA $0202|!base2,y ;load the tile

	TYA
	LSR
	LSR	
	TAY
	LDA $04;ponemos el tamano del grafico con su modalidad
	STA $0420|!base2,y
.next
	DEX
	BMI +
	CPX $0D
	BCS .loop ;if Y < 0 exit to loop
+
	SEP #$10
	PLX
	
	RTS
	
getDrawInfo200:
	PHY
	LDA $04
	STA $05
	STZ $06
	REP #$20
	
	LDA $00
	SEC
	SBC $1A
	STA $00
	
	CMP #$0100
	BCC ++
	
	CMP #$FFF1
	BCS +
	
	SEP #$20
	LDA #$01
	STA $06
	PLY
	RTL
+
	LDY $05
	INY
	STY $04
++
	LDA $02
	SEC
	SBC $1C
	STA $02
	
	CMP #$00F0
	BCS ++	

	CMP #$00E0
	BCS +
	SEP #$20
	PLY
	RTL
	
++
	CMP #$FFF1
	BCS ++
	
	SEP #$20
	LDA #$01
	STA $06
	PLY
	RTL
+
	LDY $05
	INY
	STY $04
++
	SEP #$20
	PLY
	RTL
	
;===================================
;Frames
;===================================
FramesTotalTiles:

	db $04,$05,$06,$06,$05,$05,$05,$05,$05,$06,$04,$05,$06,$06,$05,$05,$05,$05,$05,$06

StartPositionFrames:
	dw $0004,$000A,$0011,$0018,$001E,$0024,$002A,$0030,$0036,$003D,$0042,$0048,$004F,$0056,$005C,$0062,$0068,$006E,$0074,$007B

EndPositionFrames:
	dw $0000,$0005,$000B,$0012,$0019,$001F,$0025,$002B,$0031,$0037,$003E,$0043,$0049,$0050,$0057,$005D,$0063,$0069,$006F,$0075

FramesOam:
f1Oam:
	dw $0000,$0004,$0008,$000C,$0010
f2Oam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
f3Oam:
	dw $0000,$0004,$0008,$000C,$0010,$0014,$0018
f4Oam:
	dw $0000,$0004,$0008,$000C,$0010,$0014,$0018
f5Oam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
f6Oam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
f7Oam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
f8Oam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
f9Oam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
fAOam:	
	dw $0000,$0004,$0008,$000C,$0010,$0014,$0018
f1FlipXOam:
	dw $0000,$0004,$0008,$000C,$0010
f2FlipXOam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
f3FlipXOam:
	dw $0000,$0004,$0008,$000C,$0010,$0014,$0018
f4FlipXOam:
	dw $0000,$0004,$0008,$000C,$0010,$0014,$0018
f5FlipXOam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
f6FlipXOam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
f7FlipXOam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
f8FlipXOam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
f9FlipXOam:
	dw $0000,$0004,$0008,$000C,$0010,$0014
fAFlipXOam:
	dw $0000,$0004,$0008,$000C,$0010,$0014,$0018
	
FramesXDisp:
f1XDisp:
	db $00,$08,$00,$08,$00
f2XDisp:
	db $00,$08,$00,$08,$F8,$00
f3XDisp:
	db $F8,$08,$F8,$08,$10,$F8,$08
f4XDisp:
	db $F8,$08,$F0,$00,$08,$08,$10
f5XDisp:
	db $00,$08,$F8,$08,$00,$08
f6XDisp:
	db $00,$08,$F8,$08,$F8,$00
f7XDisp:
	db $00,$08,$F8,$08,$F8,$00
f8XDisp:
	db $F8,$08,$F8,$08,$10,$08
f9XDisp:
	db $00,$08,$F8,$08,$F8,$08
fAXDisp:
	db $F8,$08,$F8,$08,$10,$F8,$08
f1FlipXXDisp:
	db $1C,$14,$1C,$14,$1C
f2FlipXXDisp:
	db $1C,$14,$1C,$14,$24,$1C
f3FlipXXDisp:
	db $24,$14,$24,$14,$0C,$24,$14
f4FlipXXDisp:
	db $24,$14,$2C,$1C,$14,$14,$0C
f5FlipXXDisp:
	db $1C,$14,$24,$14,$1C,$14
f6FlipXXDisp:
	db $1C,$14,$24,$14,$24,$1C
f7FlipXXDisp:
	db $1C,$14,$24,$14,$24,$1C
f8FlipXXDisp:
	db $24,$14,$24,$14,$0C,$14
f9FlipXXDisp:
	db $1C,$14,$24,$14,$24,$14
fAFlipXXDisp:
	db $24,$14,$24,$14,$0C,$24,$14


FramesYDisp:
f1yDisp:
	db $F8,$F8,$08,$08,$18
f2yDisp:
	db $F8,$F8,$08,$08,$18,$18
f3yDisp:
	db $F8,$F8,$08,$08,$08,$18,$18
f4yDisp:
	db $F8,$F8,$08,$08,$08,$18,$18
f5yDisp:
	db $F8,$F8,$08,$08,$18,$18
f6yDisp:
	db $F8,$F8,$08,$08,$18,$18
f7yDisp:
	db $F8,$F8,$08,$08,$18,$18
f8yDisp:
	db $F8,$F8,$08,$08,$08,$18
f9yDisp:
	db $F8,$F8,$08,$08,$18,$18
fAyDisp:
	db $F8,$F8,$08,$08,$08,$18,$18
f1FlipXyDisp:
	db $F8,$F8,$08,$08,$18
f2FlipXyDisp:
	db $F8,$F8,$08,$08,$18,$18
f3FlipXyDisp:
	db $F8,$F8,$08,$08,$08,$18,$18
f4FlipXyDisp:
	db $F8,$F8,$08,$08,$08,$18,$18
f5FlipXyDisp:
	db $F8,$F8,$08,$08,$18,$18
f6FlipXyDisp:
	db $F8,$F8,$08,$08,$18,$18
f7FlipXyDisp:
	db $F8,$F8,$08,$08,$18,$18
f8FlipXyDisp:
	db $F8,$F8,$08,$08,$08,$18
f9FlipXyDisp:
	db $F8,$F8,$08,$08,$18,$18
fAFlipXyDisp:
	db $F8,$F8,$08,$08,$08,$18,$18


FramesPropertie:
f1Properties:
	db $30,$30,$30,$30,$30
f2Properties:
	db $30,$30,$30,$30,$30,$30
f3Properties:
	db $30,$30,$30,$30,$30,$30,$30
f4Properties:
	db $30,$30,$30,$30,$30,$30,$30
f5Properties:
	db $30,$30,$30,$30,$30,$30
f6Properties:
	db $30,$30,$30,$30,$30,$30
f7Properties:
	db $30,$30,$30,$30,$30,$30
f8Properties:
	db $30,$30,$30,$30,$30,$30
f9Properties:
	db $30,$30,$30,$30,$30,$30
fAProperties:
	db $30,$30,$30,$30,$30,$30,$30
f1FlipXProperties:
	db $70,$70,$70,$70,$70
f2FlipXProperties:
	db $70,$70,$70,$70,$70,$70
f3FlipXProperties:
	db $70,$70,$70,$70,$70,$70,$70
f4FlipXProperties:
	db $70,$70,$70,$70,$70,$70,$70
f5FlipXProperties:
	db $70,$70,$70,$70,$70,$70
f6FlipXProperties:
	db $70,$70,$70,$70,$70,$70
f7FlipXProperties:
	db $70,$70,$70,$70,$70,$70
f8FlipXProperties:
	db $70,$70,$70,$70,$70,$70
f9FlipXProperties:
	db $70,$70,$70,$70,$70,$70
fAFlipXProperties:
	db $70,$70,$70,$70,$70,$70,$70


FramesTile:
f1Tiles:
	db $02,$03,$05,$06,$08
f2Tiles:
	db $02,$03,$05,$06,$08,$09
f3Tiles:
	db $01,$03,$05,$07,$08,$0A,$0C
f4Tiles:
	db $01,$03,$05,$07,$08,$0B,$0C
f5Tiles:
	db $02,$03,$05,$07,$09,$0A
f6Tiles:
	db $02,$03,$05,$07,$09,$0A
f7Tiles:
	db $02,$03,$05,$07,$09,$0A
f8Tiles:
	db $01,$03,$05,$07,$08,$0A
f9Tiles:
	db $02,$03,$05,$07,$09,$0B
fATiles:
	db $01,$03,$05,$07,$08,$0A,$0C
f1FlipXTiles:
	db $02,$03,$05,$06,$08
f2FlipXTiles:
	db $02,$03,$05,$06,$08,$09
f3FlipXTiles:
	db $01,$03,$05,$07,$08,$0A,$0C
f4FlipXTiles:
	db $01,$03,$05,$07,$08,$0B,$0C
f5FlipXTiles:
	db $02,$03,$05,$07,$09,$0A
f6FlipXTiles:
	db $02,$03,$05,$07,$09,$0A
f7FlipXTiles:
	db $02,$03,$05,$07,$09,$0A
f8FlipXTiles:
	db $01,$03,$05,$07,$08,$0A
f9FlipXTiles:
	db $02,$03,$05,$07,$09,$0B
fAFlipXTiles:
	db $01,$03,$05,$07,$08,$0A,$0C
	