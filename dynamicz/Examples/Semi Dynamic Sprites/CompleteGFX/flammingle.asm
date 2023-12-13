PRINT "INIT ",pc
incsrc sprites\header.asm

;Point to the current frame
!FramePointer = $C2,x

;Point to the current frame on the animation
!AnFramePointer = $1504,x

;Point to the current animation
!AnPointer = $1510,x

!invisible = $151C,x

;Time for the next frame change
!AnimationTimer = $1540,x

!GlobalFlipper = $1534,x

!LocalFlipper = $1570,x

!SelectedSlot = $7FAB28,x

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

	LDA $14C8,x			;\
	CMP #$08			; | If sprite dead,
	BNE Return			;/ Return.

	LDA $9D				;\
	BNE Return			;/ If locked, return.
	JSL !SUB_OFF_SCREEN_X0
	
	
	JSR GraphicManager ;manage the frames of the sprite and decide what frame show
.ret
	RTS
	
MustbeReloaded:
	LDY $161A,x
	LDA #$00
	STA $1938,y
	STZ $14C8,x
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
standFrames:
	db $00,$01,$02,$03,$02,$01,$00,$01,$02,$03,$02,$01,$00,$04,$05,$04,$00,$06,$07,$08,$07,$06

AnimationsNFr:
standNext:
	db $01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$00

AnimationsTFr:
standTimes:
	db $30,$04,$04,$10,$04,$04,$10,$04,$04,$10,$04,$04,$10,$04,$04,$04,$10,$04,$04,$04,$04,$04

AnimationsFlips:
standFlip:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

;===================================
;Graphic Routine
;===================================
FlipAdder: db $00,$09
relativeDisp: db $00,$80
movePage: db $00,$01
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
	STA $0DBF

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
	STA $0300,y ;load the tile X position

	LDA FramesYDisp,x
	CLC
	ADC $01
	STA $0301,y ;load the tile Y position

	LDA FramesPropertie,x
	AND #$01
	BEQ +
	LDA FramesTile,x
	BRA .tile
+
	LDA FramesTile,x
	CMP #$80
	BCC .tile
	CLC
	ADC $0F
	STA $0302,y ;load the tile
	
	LDA FramesPropertie,x
	ORA $64
	EOR $0C
	STA $0303,y ;load the tile Propertie
	BRA ++
.tile
	STA $0302,y ;load the tile
	
	LDA FramesPropertie,x
	ORA $64
	STA $0303,y ;load the tile Propertie
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

	db $09,$09,$09,$09,$0A,$0A,$09,$09,$09,$09,$09,$09,$09,$0A,$0A,$09,$09,$09

StartPositionFrames:
	dw $0009,$0013,$001D,$0027,$0032,$003D,$0047,$0051,$005B,$0065,$006F,$0079,$0083,$008E,$0099,$00A3,$00AD,$00B7

EndPositionFrames:
	dw $0000,$000A,$0014,$001E,$0028,$0033,$003E,$0048,$0052,$005C,$0066,$0070,$007A,$0084,$008F,$009A,$00A4,$00AE

FramesXDisp:
stand1XDisp:
	db $FD,$FD,$03,$13,$05,$0D,$05,$07,$02,$02
stand2XDisp:
	db $FD,$FD,$03,$05,$0D,$05,$07,$03,$03,$13
stand3XDisp:
	db $FD,$FD,$03,$05,$0D,$05,$07,$02,$03,$13
stand4XDisp:
	db $FD,$FD,$03,$05,$0D,$05,$07,$04,$04,$13
stand5XDisp:
	db $FD,$FD,$03,$13,$05,$0D,$05,$07,$02,$02,$FC
stand6XDisp:
	db $FD,$FD,$03,$13,$05,$0D,$05,$07,$02,$02,$04
stand7XDisp:
	db $FD,$FD,$07,$03,$13,$05,$05,$0D,$02,$02
stand8XDisp:
	db $FD,$FD,$07,$03,$13,$05,$0D,$05,$02,$02
stand9XDisp:
	db $FD,$FD,$07,$03,$13,$05,$0D,$05,$02,$02
stand1FlipXXDisp:
	db $09,$09,$03,$F3,$01,$F9,$01,$FF,$04,$04
stand2FlipXXDisp:
	db $09,$09,$03,$01,$F9,$01,$FF,$03,$03,$F3
stand3FlipXXDisp:
	db $09,$09,$03,$01,$F9,$01,$FF,$04,$03,$F3
stand4FlipXXDisp:
	db $09,$09,$03,$01,$F9,$01,$FF,$02,$02,$F3
stand5FlipXXDisp:
	db $09,$09,$03,$F3,$01,$F9,$01,$FF,$04,$04,$0A
stand6FlipXXDisp:
	db $09,$09,$03,$F3,$01,$F9,$01,$FF,$04,$04,$02
stand7FlipXXDisp:
	db $09,$09,$FF,$03,$F3,$01,$01,$F9,$04,$04
stand8FlipXXDisp:
	db $09,$09,$FF,$03,$F3,$01,$F9,$01,$04,$04
stand9FlipXXDisp:
	db $09,$09,$FF,$03,$F3,$01,$F9,$01,$04,$04


FramesYDisp:
stand1yDisp:
	db $F0,$00,$E4,$EC,$E8,$F8,$00,$D6,$C7,$CE
stand2yDisp:
	db $F0,$00,$E4,$E8,$F8,$00,$D6,$CE,$BE,$EC
stand3yDisp:
	db $F0,$00,$E4,$E8,$F8,$00,$D6,$CE,$BE,$EC
stand4yDisp:
	db $F0,$00,$E4,$E8,$F8,$00,$D6,$C7,$CE,$EC
stand5yDisp:
	db $F0,$00,$E4,$EC,$E8,$F8,$00,$D6,$C7,$CE,$D3
stand6yDisp:
	db $F0,$00,$E4,$EC,$00,$F8,$E8,$D6,$C7,$CE,$D3
stand7yDisp:
	db $F0,$00,$D8,$E4,$E4,$E8,$00,$F8,$C9,$D0
stand8yDisp:
	db $F0,$00,$DA,$E4,$EC,$E8,$F8,$00,$CB,$D2
stand9yDisp:
	db $F0,$00,$DC,$E4,$EC,$00,$F8,$E8,$CD,$D4
stand1FlipXyDisp:
	db $F0,$00,$E4,$EC,$E8,$F8,$00,$D6,$C7,$CE
stand2FlipXyDisp:
	db $F0,$00,$E4,$E8,$F8,$00,$D6,$CE,$BE,$EC
stand3FlipXyDisp:
	db $F0,$00,$E4,$E8,$F8,$00,$D6,$CE,$BE,$EC
stand4FlipXyDisp:
	db $F0,$00,$E4,$E8,$F8,$00,$D6,$C7,$CE,$EC
stand5FlipXyDisp:
	db $F0,$00,$E4,$EC,$E8,$F8,$00,$D6,$C7,$CE,$D3
stand6FlipXyDisp:
	db $F0,$00,$E4,$EC,$00,$F8,$E8,$D6,$C7,$CE,$D3
stand7FlipXyDisp:
	db $F0,$00,$D8,$E4,$E4,$E8,$00,$F8,$C9,$D0
stand8FlipXyDisp:
	db $F0,$00,$DA,$E4,$EC,$E8,$F8,$00,$CB,$D2
stand9FlipXyDisp:
	db $F0,$00,$DC,$E4,$EC,$00,$F8,$E8,$CD,$D4


FramesPropertie:
stand1Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E
stand2Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$BE,$3E
stand3Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$7E,$BE,$3E
stand4Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$7E,$7E,$3E
stand5Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E
stand6Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E
stand7Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E
stand8Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E
stand9Properties:
	db $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E
stand1FlipXProperties:
	db $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
stand2FlipXProperties:
	db $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$FE,$7E
stand3FlipXProperties:
	db $7E,$7E,$7E,$7E,$7E,$7E,$7E,$3E,$FE,$7E
stand4FlipXProperties:
	db $7E,$7E,$7E,$7E,$7E,$7E,$7E,$3E,$3E,$7E
stand5FlipXProperties:
	db $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
stand6FlipXProperties:
	db $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
stand7FlipXProperties:
	db $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
stand8FlipXProperties:
	db $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
stand9FlipXProperties:
	db $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E


FramesTile:
stand1Tiles:
	db $E3,$E5,$88,$E8,$8A,$C0,$8C,$E2,$80,$84
stand2Tiles:
	db $E3,$E5,$88,$8A,$C0,$8C,$E2,$86,$CC,$E8
stand3Tiles:
	db $E3,$E5,$88,$8A,$C0,$8C,$E2,$86,$CC,$E8
stand4Tiles:
	db $E3,$E5,$88,$8A,$C0,$8C,$E2,$80,$84,$E8
stand5Tiles:
	db $E3,$E5,$88,$E8,$8A,$C0,$8C,$E2,$80,$84,$C1
stand6Tiles:
	db $E3,$E5,$88,$E8,$8C,$C0,$8A,$E2,$80,$84,$C3
stand7Tiles:
	db $E3,$E5,$E2,$88,$D8,$8A,$8C,$C0,$80,$84
stand8Tiles:
	db $E3,$E5,$E2,$88,$E8,$8A,$C0,$8C,$80,$84
stand9Tiles:
	db $E3,$E5,$E2,$88,$E8,$8C,$C0,$8A,$80,$84
stand1FlipXTiles:
	db $E3,$E5,$88,$E8,$8A,$C0,$8C,$E2,$80,$84
stand2FlipXTiles:
	db $E3,$E5,$88,$8A,$C0,$8C,$E2,$86,$CC,$E8
stand3FlipXTiles:
	db $E3,$E5,$88,$8A,$C0,$8C,$E2,$86,$CC,$E8
stand4FlipXTiles:
	db $E3,$E5,$88,$8A,$C0,$8C,$E2,$80,$84,$E8
stand5FlipXTiles:
	db $E3,$E5,$88,$E8,$8A,$C0,$8C,$E2,$80,$84,$C1
stand6FlipXTiles:
	db $E3,$E5,$88,$E8,$8C,$C0,$8A,$E2,$80,$84,$C3
stand7FlipXTiles:
	db $E3,$E5,$E2,$88,$D8,$8A,$8C,$C0,$80,$84
stand8FlipXTiles:
	db $E3,$E5,$E2,$88,$E8,$8A,$C0,$8C,$80,$84
stand9FlipXTiles:
	db $E3,$E5,$E2,$88,$E8,$8C,$C0,$8A,$80,$84
	
;===================================
;Semi Dynamic Routine
;===================================
vram: dw $6800,$7000

semiDynamicRoutine:
	
	LDA $7FAB9E,x
	STA $02
	
	PHX
	LDA !SelectedSlot 
	ASL
	TAX ;x = selected slot
	
	LDA !SemiDynamicSlots,x ;if the slot is not used then try to start
	CMP #$FF
	BEQ .start
	PLX
	CMP $02 ;if this sprite is a copy of the sprite that reserve the slot then return
	BNE +
	LDA #$00
	RTS
+

	PHX
	LDA !SelectedSlot 
	ASL
	TAX ;x = selected slot
	
	LDA !SemiDynamicSlots,x
	STA $00 ;$00 = index of the sprite that use the slot
	LDA !SemiDynamicSlots+$01,x
	STA $01
	
	LDX #$0B
.loop
	LDA $7FAB9E,x ;if exists a copy of the sprite that use the slot then return
	BEQ ++
	CMP #$FF
	BEQ ++
	CMP $02
	BEQ ++
	CMP $00
	BEQ +
	CMP $01
	BNE ++
+
	PLX
	LDA #$FF
	RTS
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

	LDA $7FAB9E,x
	STA $00
	
	LDA !SelectedSlot
	ASL
	TAX
	TAY
	
	LDA $00
	STA !SemiDynamicSlots,x ;reserve the slot
	STA !SemiDynamicSlots+$01,x

	LDA !GFXNumber
	PHA
	INC A
	INC A
	STA !GFXNumber 
	PLA
	ASL
	TAX
	
	PHB
	PHK
	PLB

	PHB
	PLA
	STA !GFXBnk,x
	STA !GFXBnk+$02,x
	LDA #$00
	STA !GFXBnk+$01,x
	STA !GFXBnk+$03,x

	REP #$20
	LDA GFXPointer
	STA !GFXRec,x
	CLC
	ADC #$0800
	STA !GFXRec+$02,x

	LDA #$0800
	STA !GFXLenght,x
	STA !GFXLenght+$02,x

	LDA vram,y
	STA !GFXVram,x
	CLC
	ADC #$0400
	STA !GFXVram+$02,x

	SEP #$20
	PLB
	PLX
	LDA #$01
	RTS
	
GFXPointer:
dw resource

resource:
incbin sprites\flammingle.bin ;replace this for your GFX name

