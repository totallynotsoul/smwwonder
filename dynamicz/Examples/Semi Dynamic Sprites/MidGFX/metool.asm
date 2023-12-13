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
	dw $0000,$0006,$000C,$000F

AnimationsFrames:
unhideFrames:
	db $00,$01,$02,$03,$02,$03
hideFrames:
	db $03,$02,$01,$00,$01,$00
walkFrames:
	db $04,$05,$06
explosionFrames:
	db $07,$08,$07,$09,$0A,$0B,$0C,$0D,$0E

AnimationsNFr:
unhideNext:
	db $01,$02,$03,$04,$05,$05
hideNext:
	db $01,$02,$03,$04,$05,$05
walkNext:
	db $01,$02,$00
explosionNext:
	db $01,$02,$03,$04,$05,$06,$07,$08,$08

AnimationsTFr:
unhideTimes:
	db $04,$04,$04,$04,$04,$04
hideTimes:
	db $04,$04,$04,$04,$04,$04
walkTimes:
	db $04,$04,$04
explosionTimes:
	db $02,$01,$02,$04,$04,$04,$04,$04,$04

AnimationsFlips:
unhideFlip:
	db $00,$00,$00,$00,$00,$00
hideFlip:
	db $00,$00,$00,$00,$00,$00
walkFlip:
	db $00,$00,$00
explosionFlip:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00

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
	CMP #$C0
	BCS .tile
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

	db $01,$03,$03,$03,$03,$03,$03,$00,$03,$03,$03,$03,$03,$03,$01,$01,$03,$03,$03,$03,$03,$03,$00,$03,$03,$03,$03,$03,$03,$01

StartPositionFrames:
	dw $0001,$0005,$0009,$000D,$0011,$0015,$0019,$001A,$001E,$0022,$0026,$002A,$002E,$0032,$0034,$0036,$003A,$003E,$0042,$0046,$004A,$004E,$004F,$0053,$0057,$005B,$005F,$0063,$0067,$0069

EndPositionFrames:
	dw $0000,$0002,$0006,$000A,$000E,$0012,$0016,$001A,$001B,$001F,$0023,$0027,$002B,$002F,$0033,$0035,$0037,$003B,$003F,$0043,$0047,$004B,$004F,$0050,$0054,$0058,$005C,$0060,$0064,$0068

FramesXDisp:
hide1XDisp:
	db $00,$08
hide2XDisp:
	db $00,$08,$00,$08
hide3XDisp:
	db $00,$08,$00,$08
hide4XDisp:
	db $00,$08,$00,$08
walk1XDisp:
	db $00,$10,$02,$0F
walk2XDisp:
	db $00,$00,$08,$08
walk3XDisp:
	db $00,$10,$10,$03
explosion1XDisp:
	db $03
explosion2XDisp:
	db $FB,$FB,$0B,$0B
explosion3XDisp:
	db $FB,$FB,$0B,$0B
explosion4XDisp:
	db $FB,$FB,$0B,$0B
explosion5XDisp:
	db $FB,$FB,$0B,$0B
explosion6XDisp:
	db $FB,$FB,$0B,$0B
explosion7XDisp:
	db $FB,$FB,$0B,$0B
explosion8XDisp:
	db $FB,$0B
hide1FlipXXDisp:
	db $06,$FE
hide2FlipXXDisp:
	db $06,$FE,$06,$FE
hide3FlipXXDisp:
	db $06,$FE,$06,$FE
hide4FlipXXDisp:
	db $06,$FE,$06,$FE
walk1FlipXXDisp:
	db $06,$F6,$04,$F7
walk2FlipXXDisp:
	db $06,$06,$FE,$FE
walk3FlipXXDisp:
	db $06,$F6,$F6,$03
explosion1FlipXXDisp:
	db $03
explosion2FlipXXDisp:
	db $0B,$0B,$FB,$FB
explosion3FlipXXDisp:
	db $0B,$0B,$FB,$FB
explosion4FlipXXDisp:
	db $0B,$0B,$FB,$FB
explosion5FlipXXDisp:
	db $0B,$0B,$FB,$FB
explosion6FlipXXDisp:
	db $0B,$0B,$FB,$FB
explosion7FlipXXDisp:
	db $0B,$0B,$FB,$FB
explosion8FlipXXDisp:
	db $0B,$FB


FramesYDisp:
hide1yDisp:
	db $00,$00
hide2yDisp:
	db $0E,$0E,$FE,$FE
hide3yDisp:
	db $09,$09,$F9,$F9
hide4yDisp:
	db $08,$08,$F8,$F8
walk1yDisp:
	db $00,$08,$F8,$00
walk2yDisp:
	db $FB,$03,$FB,$03
walk3yDisp:
	db $00,$08,$00,$F8
explosion1yDisp:
	db $00
explosion2yDisp:
	db $F8,$08,$F8,$08
explosion3yDisp:
	db $00,$08,$00,$08
explosion4yDisp:
	db $F8,$08,$F8,$08
explosion5yDisp:
	db $F8,$08,$F8,$08
explosion6yDisp:
	db $F8,$08,$F8,$08
explosion7yDisp:
	db $FC,$04,$FC,$04
explosion8yDisp:
	db $00,$00
hide1FlipXyDisp:
	db $00,$00
hide2FlipXyDisp:
	db $0E,$0E,$FE,$FE
hide3FlipXyDisp:
	db $09,$09,$F9,$F9
hide4FlipXyDisp:
	db $08,$08,$F8,$F8
walk1FlipXyDisp:
	db $00,$08,$F8,$00
walk2FlipXyDisp:
	db $FB,$03,$FB,$03
walk3FlipXyDisp:
	db $00,$08,$00,$F8
explosion1FlipXyDisp:
	db $00
explosion2FlipXyDisp:
	db $F8,$08,$F8,$08
explosion3FlipXyDisp:
	db $00,$08,$00,$08
explosion4FlipXyDisp:
	db $F8,$08,$F8,$08
explosion5FlipXyDisp:
	db $F8,$08,$F8,$08
explosion6FlipXyDisp:
	db $F8,$08,$F8,$08
explosion7FlipXyDisp:
	db $FC,$04,$FC,$04
explosion8FlipXyDisp:
	db $00,$00


FramesPropertie:
hide1Properties:
	db $3E,$3E
hide2Properties:
	db $3E,$3E,$3E,$3E
hide3Properties:
	db $3E,$3E,$3E,$3E
hide4Properties:
	db $BE,$BE,$3E,$3E
walk1Properties:
	db $3E,$3E,$3E,$7E
walk2Properties:
	db $3E,$3E,$3E,$3E
walk3Properties:
	db $3E,$3E,$7E,$3E
explosion1Properties:
	db $34
explosion2Properties:
	db $34,$B4,$74,$F4
explosion3Properties:
	db $34,$34,$74,$74
explosion4Properties:
	db $34,$34,$74,$74
explosion5Properties:
	db $34,$34,$74,$74
explosion6Properties:
	db $34,$34,$74,$74
explosion7Properties:
	db $34,$34,$74,$74
explosion8Properties:
	db $34,$74
hide1FlipXProperties:
	db $7E,$7E
hide2FlipXProperties:
	db $7E,$7E,$7E,$7E
hide3FlipXProperties:
	db $7E,$7E,$7E,$7E
hide4FlipXProperties:
	db $FE,$FE,$7E,$7E
walk1FlipXProperties:
	db $7E,$7E,$7E,$3E
walk2FlipXProperties:
	db $7E,$7E,$7E,$7E
walk3FlipXProperties:
	db $7E,$7E,$3E,$7E
explosion1FlipXProperties:
	db $74
explosion2FlipXProperties:
	db $74,$F4,$34,$B4
explosion3FlipXProperties:
	db $74,$74,$34,$34
explosion4FlipXProperties:
	db $74,$74,$34,$34
explosion5FlipXProperties:
	db $74,$74,$34,$34
explosion6FlipXProperties:
	db $74,$74,$34,$34
explosion7FlipXProperties:
	db $74,$74,$34,$34
explosion8FlipXProperties:
	db $74,$34


FramesTile:
hide1Tiles:
	db $86,$87
hide2Tiles:
	db $A0,$A1,$86,$87
hide3Tiles:
	db $8D,$8E,$80,$81
hide4Tiles:
	db $9D,$9E,$80,$81
walk1Tiles:
	db $8B,$A8,$A6,$AB
walk2Tiles:
	db $83,$93,$84,$94
walk3Tiles:
	db $89,$AA,$AB,$A6
explosion1Tiles:
	db $C0
explosion2Tiles:
	db $C2,$C2,$C2,$C2
explosion3Tiles:
	db $D4,$E4,$D4,$E4
explosion4Tiles:
	db $C6,$E6,$C6,$E6
explosion5Tiles:
	db $C8,$E8,$C8,$E8
explosion6Tiles:
	db $CA,$EA,$CA,$EA
explosion7Tiles:
	db $CC,$DC,$CC,$DC
explosion8Tiles:
	db $CE,$CE
hide1FlipXTiles:
	db $86,$87
hide2FlipXTiles:
	db $A0,$A1,$86,$87
hide3FlipXTiles:
	db $8D,$8E,$80,$81
hide4FlipXTiles:
	db $9D,$9E,$80,$81
walk1FlipXTiles:
	db $8B,$A8,$A6,$AB
walk2FlipXTiles:
	db $83,$93,$84,$94
walk3FlipXTiles:
	db $89,$AA,$AB,$A6
explosion1FlipXTiles:
	db $C0
explosion2FlipXTiles:
	db $C2,$C2,$C2,$C2
explosion3FlipXTiles:
	db $D4,$E4,$D4,$E4
explosion4FlipXTiles:
	db $C6,$E6,$C6,$E6
explosion5FlipXTiles:
	db $C8,$E8,$C8,$E8
explosion6FlipXTiles:
	db $CA,$EA,$CA,$EA
explosion7FlipXTiles:
	db $CC,$DC,$CC,$DC
explosion8FlipXTiles:
	db $CE,$CE

;===================================
;Semi Dynamic Routine
;===================================
vram: dw $6800,$6C00,$7000,$7400 

semiDynamicRoutine:

	LDA $7FAB9E,x
	STA $02	

	PHX
	LDA !SelectedSlot 
	TAX ;x = selected slot
	
	LDA !SemiDynamicSlots,x ;if the slot is not used then try to start
	CMP #$FF
	BEQ .start
	PLX
	CMP $7FAB9E,x ;if this sprite is a copy of the sprite that reserve the slot then return
	BNE +
	LDA #$00
	RTS
+
	PHX
	
	STA $00 ;$00 = index of the sprite that use the slot
	LDX #$0B
.loop
	LDA $7FAB9E,x ;if exists a copy of the sprite that use the slot then return
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

	LDA $7FAB9E,x
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
incbin sprites\metool.bin ;replace this for your GFX name