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
animFrames:
	db $00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0B,$0A,$0B,$0C,$0B,$0A,$0D,$04,$03,$02,$01

AnimationsNFr:
animNext:
	db $01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$00

AnimationsTFr:
animTimes:
	db $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$18,$04,$04,$04,$04,$30,$04,$04,$04,$10,$04,$04,$04,$10,$04,$04,$04,$04,$04

AnimationsFlips:
animFlip:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

;===================================
;Graphic Routine
;===================================
FlipAdder: db $00,$0E
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
	ORA $64
	STA $0303,y ;load the tile Propertie

	LDA FramesTile,x
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

	db $12,$12,$12,$11,$11,$11,$11,$14,$13,$12,$11,$13,$13,$10,$12,$12,$12,$11,$11,$11,$11,$14,$13,$12,$11,$13,$13,$10

StartPositionFrames:
	dw $0012,$0025,$0038,$004A,$005C,$006E,$0080,$0095,$00A9,$00BC,$00CE,$00E2,$00F6,$0107,$011A,$012D,$0140,$0152,$0164,$0176,$0188,$019D,$01B1,$01C4,$01D6,$01EA,$01FE,$020F

EndPositionFrames:
	dw $0000,$0013,$0026,$0039,$004B,$005D,$006F,$0081,$0096,$00AA,$00BD,$00CF,$00E3,$00F7,$0108,$011B,$012E,$0141,$0153,$0165,$0177,$0189,$019E,$01B2,$01C5,$01D7,$01EB,$01FF

FramesXDisp:
stand1XDisp:
	db $04,$F6,$06,$16,$F8,$F8,$08,$08,$10,$10,$FF,$0F,$08,$10,$05,$EE,$F6,$F6,$FD
stand2XDisp:
	db $04,$F6,$06,$16,$F8,$F8,$08,$08,$10,$10,$FF,$0F,$EE,$F6,$F6,$08,$10,$05,$FD
down1XDisp:
	db $04,$F2,$02,$12,$F8,$F8,$08,$08,$10,$10,$FF,$0F,$EE,$F6,$F6,$08,$10,$05,$FD
down2XDisp:
	db $F2,$02,$12,$F8,$F8,$08,$08,$10,$10,$FF,$0F,$EE,$F6,$F6,$08,$10,$05,$FD
down3XDisp:
	db $F5,$05,$15,$F8,$F8,$08,$08,$18,$10,$FF,$0F,$FD,$08,$10,$05,$EE,$F6,$F6
down4XDisp:
	db $F5,$05,$15,$18,$10,$F8,$F8,$08,$08,$FF,$0F,$FD,$F6,$EE,$F6,$08,$10,$05
open1XDisp:
	db $F5,$05,$15,$F7,$07,$0F,$FC,$FC,$F7,$07,$FE,$0E,$17,$EE,$FE,$06,$E7,$10
open2XDisp:
	db $F5,$05,$15,$F8,$F8,$08,$08,$E8,$18,$10,$FF,$0F,$0C,$0A,$1A,$1A,$FC,$F8,$08,$08,$10
open3XDisp:
	db $F5,$05,$15,$F9,$F9,$09,$09,$19,$11,$00,$10,$E9,$FE,$FD,$00,$0D,$0F,$12,$1F,$10
open4XDisp:
	db $F5,$05,$15,$F8,$F8,$08,$08,$E8,$18,$10,$FF,$0F,$FC,$F8,$F9,$0B,$0A,$0C,$0F
open5XDisp:
	db $F5,$05,$15,$F8,$F8,$08,$08,$FF,$0F,$18,$10,$E8,$FC,$F8,$F9,$0C,$0A,$0B
attack1XDisp:
	db $F5,$05,$15,$19,$11,$F9,$F9,$09,$09,$00,$10,$E9,$FD,$F9,$FA,$0B,$0D,$0C,$FE,$FE
attack2XDisp:
	db $F5,$05,$15,$01,$11,$1A,$12,$FA,$FA,$0A,$0A,$EA,$FB,$FE,$FA,$0D,$0C,$0E,$FF,$FF
close1XDisp:
	db $F5,$05,$15,$18,$10,$F8,$F8,$08,$08,$E8,$FD,$FF,$0F,$EF,$FF,$07,$FD
stand1FlipXXDisp:
	db $02,$10,$00,$F0,$0E,$0E,$FE,$FE,$F6,$F6,$07,$F7,$FE,$F6,$01,$18,$10,$10,$09
stand2FlipXXDisp:
	db $02,$10,$00,$F0,$0E,$0E,$FE,$FE,$F6,$F6,$07,$F7,$18,$10,$10,$FE,$F6,$01,$09
down1FlipXXDisp:
	db $02,$14,$04,$F4,$0E,$0E,$FE,$FE,$F6,$F6,$07,$F7,$18,$10,$10,$FE,$F6,$01,$09
down2FlipXXDisp:
	db $14,$04,$F4,$0E,$0E,$FE,$FE,$F6,$F6,$07,$F7,$18,$10,$10,$FE,$F6,$01,$09
down3FlipXXDisp:
	db $11,$01,$F1,$0E,$0E,$FE,$FE,$EE,$F6,$07,$F7,$09,$FE,$F6,$01,$18,$10,$10
down4FlipXXDisp:
	db $11,$01,$F1,$EE,$F6,$0E,$0E,$FE,$FE,$07,$F7,$09,$10,$18,$10,$FE,$F6,$01
open1FlipXXDisp:
	db $11,$01,$F1,$0F,$FF,$F7,$0A,$0A,$0F,$FF,$08,$F8,$EF,$18,$08,$00,$1F,$F6
open2FlipXXDisp:
	db $11,$01,$F1,$0E,$0E,$FE,$FE,$1E,$EE,$F6,$07,$F7,$FA,$FC,$EC,$EC,$0A,$0E,$FE,$FE,$F6
open3FlipXXDisp:
	db $11,$01,$F1,$0D,$0D,$FD,$FD,$ED,$F5,$06,$F6,$1D,$08,$09,$06,$F9,$F7,$F4,$E7,$F6
open4FlipXXDisp:
	db $11,$01,$F1,$0E,$0E,$FE,$FE,$1E,$EE,$F6,$07,$F7,$0A,$0E,$0D,$FB,$FC,$FA,$F7
open5FlipXXDisp:
	db $11,$01,$F1,$0E,$0E,$FE,$FE,$07,$F7,$EE,$F6,$1E,$0A,$0E,$0D,$FA,$FC,$FB
attack1FlipXXDisp:
	db $11,$01,$F1,$ED,$F5,$0D,$0D,$FD,$FD,$06,$F6,$1D,$09,$0D,$0C,$FB,$F9,$FA,$08,$08
attack2FlipXXDisp:
	db $11,$01,$F1,$05,$F5,$EC,$F4,$0C,$0C,$FC,$FC,$1C,$0B,$08,$0C,$F9,$FA,$F8,$07,$07
close1FlipXXDisp:
	db $11,$01,$F1,$EE,$F6,$0E,$0E,$FE,$FE,$1E,$09,$07,$F7,$17,$07,$FF,$09


FramesYDisp:
stand1yDisp:
	db $F8,$00,$00,$00,$DD,$ED,$DD,$ED,$DD,$ED,$D5,$D5,$DD,$DD,$E5,$E5,$DD,$E5,$F4
stand2yDisp:
	db $F8,$00,$00,$00,$DE,$EE,$DE,$EE,$DE,$EE,$D6,$D6,$E6,$DE,$E6,$DE,$DE,$E6,$F5
down1yDisp:
	db $FC,$00,$00,$00,$E1,$F1,$E1,$F1,$E1,$F1,$D9,$D9,$E9,$E1,$E9,$E1,$E1,$E9,$F8
down2yDisp:
	db $00,$00,$00,$E5,$F5,$E5,$F5,$E5,$F5,$DD,$DD,$ED,$E5,$ED,$DD,$DD,$ED,$FC
down3yDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$E7,$F7,$DF,$DF,$FE,$E7,$E7,$EF,$EF,$E7,$EF
down4yDisp:
	db $00,$00,$00,$E8,$F8,$E8,$F8,$E8,$F8,$E0,$E0,$FF,$E8,$F0,$F0,$E8,$E8,$F0
open1yDisp:
	db $00,$00,$00,$F7,$F7,$F7,$FE,$FA,$E7,$E7,$DF,$DF,$E7,$E6,$E6,$E6,$F7,$FA
open2yDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$F7,$E7,$F7,$DF,$DF,$E2,$D2,$D4,$D3,$E2,$D2,$D3,$D4,$03
open3yDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$E7,$F7,$DF,$DF,$F7,$FE,$DA,$D2,$D6,$DA,$D2,$D6,$FF
open4yDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$F7,$E7,$F7,$DF,$DF,$E2,$D2,$DF,$DF,$D2,$E2,$01
open5yDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$DF,$DF,$E7,$F7,$F7,$E2,$D2,$DF,$E2,$D2,$DF
attack1yDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$E7,$F7,$DF,$DF,$F7,$E2,$D2,$DF,$D2,$E2,$DF,$FE,$FA
attack2yDisp:
	db $00,$00,$00,$DF,$DF,$E7,$F7,$E7,$F7,$E7,$F7,$F7,$DF,$E2,$D2,$DF,$D2,$E2,$FE,$FA
close1yDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$E7,$F7,$F7,$FE,$DF,$DF,$E6,$E6,$E6,$FA
stand1FlipXyDisp:
	db $F8,$00,$00,$00,$DD,$ED,$DD,$ED,$DD,$ED,$D5,$D5,$DD,$DD,$E5,$E5,$DD,$E5,$F4
stand2FlipXyDisp:
	db $F8,$00,$00,$00,$DE,$EE,$DE,$EE,$DE,$EE,$D6,$D6,$E6,$DE,$E6,$DE,$DE,$E6,$F5
down1FlipXyDisp:
	db $FC,$00,$00,$00,$E1,$F1,$E1,$F1,$E1,$F1,$D9,$D9,$E9,$E1,$E9,$E1,$E1,$E9,$F8
down2FlipXyDisp:
	db $00,$00,$00,$E5,$F5,$E5,$F5,$E5,$F5,$DD,$DD,$ED,$E5,$ED,$DD,$DD,$ED,$FC
down3FlipXyDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$E7,$F7,$DF,$DF,$FE,$E7,$E7,$EF,$EF,$E7,$EF
down4FlipXyDisp:
	db $00,$00,$00,$E8,$F8,$E8,$F8,$E8,$F8,$E0,$E0,$FF,$E8,$F0,$F0,$E8,$E8,$F0
open1FlipXyDisp:
	db $00,$00,$00,$F7,$F7,$F7,$FE,$FA,$E7,$E7,$DF,$DF,$E7,$E6,$E6,$E6,$F7,$FA
open2FlipXyDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$F7,$E7,$F7,$DF,$DF,$E2,$D2,$D4,$D3,$E2,$D2,$D3,$D4,$03
open3FlipXyDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$E7,$F7,$DF,$DF,$F7,$FE,$DA,$D2,$D6,$DA,$D2,$D6,$FF
open4FlipXyDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$F7,$E7,$F7,$DF,$DF,$E2,$D2,$DF,$DF,$D2,$E2,$01
open5FlipXyDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$DF,$DF,$E7,$F7,$F7,$E2,$D2,$DF,$E2,$D2,$DF
attack1FlipXyDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$E7,$F7,$DF,$DF,$F7,$E2,$D2,$DF,$D2,$E2,$DF,$FE,$FA
attack2FlipXyDisp:
	db $00,$00,$00,$DF,$DF,$E7,$F7,$E7,$F7,$E7,$F7,$F7,$DF,$E2,$D2,$DF,$D2,$E2,$FE,$FA
close1FlipXyDisp:
	db $00,$00,$00,$E7,$F7,$E7,$F7,$E7,$F7,$F7,$FE,$DF,$DF,$E6,$E6,$E6,$FA


FramesPropertie:
stand1Properties:
	db $3A,$3A,$3A,$3A,$3A,$3A,$3A,$3A,$3B,$3B,$3A,$3A,$3A,$3A,$3A,$7A,$7A,$3A,$3A
stand2Properties:
	db $3A,$3A,$3A,$3A,$3A,$3A,$3A,$3A,$3B,$3B,$3A,$3A,$7A,$7A,$3A,$3A,$3A,$3A,$3A
down1Properties:
	db $3A,$3B,$3B,$3B,$3A,$3A,$3A,$3A,$3B,$3B,$3A,$3A,$7A,$7A,$3A,$3A,$3A,$3A,$3A
down2Properties:
	db $3B,$3B,$3B,$3A,$3A,$3A,$3A,$3B,$3B,$3A,$3A,$7A,$7A,$3A,$3A,$3A,$3A,$3A
down3Properties:
	db $3B,$3B,$3B,$3A,$3A,$3A,$3A,$3B,$3B,$3A,$3A,$3A,$3A,$3A,$3A,$7A,$7A,$3A
down4Properties:
	db $3B,$3B,$3B,$3B,$3B,$3A,$3A,$3A,$3A,$3A,$3A,$3A,$7A,$7A,$3A,$3A,$3A,$3A
open1Properties:
	db $3B,$3B,$3B,$3A,$3A,$3B,$3A,$3A,$3A,$3A,$3A,$3A,$3B,$3B,$3B,$3B,$3B,$3B
open2Properties:
	db $3B,$3B,$3B,$3A,$3A,$3A,$3A,$3B,$3B,$3B,$3A,$3A,$3A,$3A,$3B,$3B,$3A,$3A,$3B,$3B,$3B
open3Properties:
	db $3B,$3B,$3B,$3A,$3A,$3A,$3A,$3B,$3B,$3A,$3A,$3B,$3A,$3A,$3A,$3B,$3A,$3A,$3B,$3B
open4Properties:
	db $3B,$3B,$3B,$3A,$3A,$3A,$3A,$3B,$3B,$3B,$3A,$3A,$3A,$3A,$3B,$3B,$3A,$3A,$3B
open5Properties:
	db $3B,$3B,$3B,$3A,$3A,$3A,$3A,$3A,$3A,$3B,$3B,$3B,$3A,$3A,$3B,$3A,$3A,$3B
attack1Properties:
	db $3B,$3B,$3B,$3B,$3B,$3A,$3A,$3A,$3A,$3A,$3A,$3B,$3A,$3A,$3B,$3A,$3A,$3B,$3A,$3A
attack2Properties:
	db $3B,$3B,$3B,$3A,$3A,$3B,$3B,$3A,$3A,$3A,$3A,$3B,$3B,$3A,$3A,$3B,$3A,$3A,$3A,$3A
close1Properties:
	db $3B,$3B,$3B,$3B,$3B,$3A,$3A,$3A,$3A,$3B,$3A,$3A,$3A,$3B,$3B,$3B,$3A
stand1FlipXProperties:
	db $7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7B,$7B,$7A,$7A,$7A,$7A,$7A,$3A,$3A,$7A,$7A
stand2FlipXProperties:
	db $7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7B,$7B,$7A,$7A,$3A,$3A,$7A,$7A,$7A,$7A,$7A
down1FlipXProperties:
	db $7A,$7B,$7B,$7B,$7A,$7A,$7A,$7A,$7B,$7B,$7A,$7A,$3A,$3A,$7A,$7A,$7A,$7A,$7A
down2FlipXProperties:
	db $7B,$7B,$7B,$7A,$7A,$7A,$7A,$7B,$7B,$7A,$7A,$3A,$3A,$7A,$7A,$7A,$7A,$7A
down3FlipXProperties:
	db $7B,$7B,$7B,$7A,$7A,$7A,$7A,$7B,$7B,$7A,$7A,$7A,$7A,$7A,$7A,$3A,$3A,$7A
down4FlipXProperties:
	db $7B,$7B,$7B,$7B,$7B,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$3A,$3A,$7A,$7A,$7A,$7A
open1FlipXProperties:
	db $7B,$7B,$7B,$7A,$7A,$7B,$7A,$7A,$7A,$7A,$7A,$7A,$7B,$7B,$7B,$7B,$7B,$7B
open2FlipXProperties:
	db $7B,$7B,$7B,$7A,$7A,$7A,$7A,$7B,$7B,$7B,$7A,$7A,$7A,$7A,$7B,$7B,$7A,$7A,$7B,$7B,$7B
open3FlipXProperties:
	db $7B,$7B,$7B,$7A,$7A,$7A,$7A,$7B,$7B,$7A,$7A,$7B,$7A,$7A,$7A,$7B,$7A,$7A,$7B,$7B
open4FlipXProperties:
	db $7B,$7B,$7B,$7A,$7A,$7A,$7A,$7B,$7B,$7B,$7A,$7A,$7A,$7A,$7B,$7B,$7A,$7A,$7B
open5FlipXProperties:
	db $7B,$7B,$7B,$7A,$7A,$7A,$7A,$7A,$7A,$7B,$7B,$7B,$7A,$7A,$7B,$7A,$7A,$7B
attack1FlipXProperties:
	db $7B,$7B,$7B,$7B,$7B,$7A,$7A,$7A,$7A,$7A,$7A,$7B,$7A,$7A,$7B,$7A,$7A,$7B,$7A,$7A
attack2FlipXProperties:
	db $7B,$7B,$7B,$7A,$7A,$7B,$7B,$7A,$7A,$7A,$7A,$7B,$7B,$7A,$7A,$7B,$7A,$7A,$7A,$7A
close1FlipXProperties:
	db $7B,$7B,$7B,$7B,$7B,$7A,$7A,$7A,$7A,$7B,$7A,$7A,$7A,$7B,$7B,$7B,$7A


FramesTile:
stand1Tiles:
	db $A6,$88,$8A,$8C,$80,$A0,$82,$A2,$60,$62,$C0,$C2,$B9,$BA,$E9,$C4,$C6,$CE,$86
stand2Tiles:
	db $A6,$88,$8A,$8C,$80,$A0,$82,$A2,$60,$62,$C0,$C2,$C4,$C6,$CE,$B9,$BA,$E9,$86
down1Tiles:
	db $A6,$20,$22,$24,$80,$A0,$82,$A2,$60,$62,$C0,$C2,$C4,$C6,$CE,$B9,$BA,$E9,$86
down2Tiles:
	db $20,$22,$24,$80,$A0,$82,$A2,$60,$62,$C0,$C2,$C4,$C6,$CE,$A9,$AA,$E9,$86
down3Tiles:
	db $05,$07,$09,$80,$A0,$82,$A2,$61,$62,$C0,$C2,$86,$B9,$BA,$E9,$C4,$C6,$CE
down4Tiles:
	db $05,$07,$09,$61,$62,$80,$A0,$82,$A2,$C0,$C2,$86,$C6,$C4,$CE,$B9,$BA,$E9
open1Tiles:
	db $05,$07,$09,$A0,$A2,$62,$86,$A4,$80,$82,$C0,$C2,$61,$00,$02,$03,$66,$26
open2Tiles:
	db $05,$07,$09,$80,$A0,$82,$A2,$66,$61,$62,$C0,$C2,$BC,$EB,$42,$42,$BE,$EB,$42,$42,$0D
open3Tiles:
	db $05,$07,$09,$80,$A0,$82,$A2,$61,$62,$C0,$C2,$66,$84,$C8,$ED,$42,$C8,$ED,$42,$28
open4Tiles:
	db $05,$07,$09,$80,$A0,$82,$A2,$66,$61,$62,$C0,$C2,$BE,$EB,$66,$66,$EB,$BC,$2A
open5Tiles:
	db $05,$07,$09,$80,$A0,$82,$A2,$C0,$C2,$61,$62,$66,$BE,$EB,$66,$BC,$EB,$66
attack1Tiles:
	db $05,$07,$09,$61,$62,$80,$A0,$82,$A2,$C0,$C2,$66,$BE,$EB,$66,$EB,$BC,$66,$86,$A4
attack2Tiles:
	db $05,$07,$09,$C0,$C2,$61,$62,$80,$A0,$82,$A2,$66,$66,$BE,$EB,$66,$EB,$BC,$86,$A4
close1Tiles:
	db $05,$07,$09,$61,$62,$80,$A0,$82,$A2,$66,$86,$C0,$C2,$00,$02,$03,$A4
stand1FlipXTiles:
	db $A6,$88,$8A,$8C,$80,$A0,$82,$A2,$60,$62,$C0,$C2,$B9,$BA,$E9,$C4,$C6,$CE,$86
stand2FlipXTiles:
	db $A6,$88,$8A,$8C,$80,$A0,$82,$A2,$60,$62,$C0,$C2,$C4,$C6,$CE,$B9,$BA,$E9,$86
down1FlipXTiles:
	db $A6,$20,$22,$24,$80,$A0,$82,$A2,$60,$62,$C0,$C2,$C4,$C6,$CE,$B9,$BA,$E9,$86
down2FlipXTiles:
	db $20,$22,$24,$80,$A0,$82,$A2,$60,$62,$C0,$C2,$C4,$C6,$CE,$A9,$AA,$E9,$86
down3FlipXTiles:
	db $05,$07,$09,$80,$A0,$82,$A2,$61,$62,$C0,$C2,$86,$B9,$BA,$E9,$C4,$C6,$CE
down4FlipXTiles:
	db $05,$07,$09,$61,$62,$80,$A0,$82,$A2,$C0,$C2,$86,$C6,$C4,$CE,$B9,$BA,$E9
open1FlipXTiles:
	db $05,$07,$09,$A0,$A2,$62,$86,$A4,$80,$82,$C0,$C2,$61,$00,$02,$03,$66,$26
open2FlipXTiles:
	db $05,$07,$09,$80,$A0,$82,$A2,$66,$61,$62,$C0,$C2,$BC,$EB,$42,$42,$BE,$EB,$42,$42,$0D
open3FlipXTiles:
	db $05,$07,$09,$80,$A0,$82,$A2,$61,$62,$C0,$C2,$66,$84,$C8,$ED,$42,$C8,$ED,$42,$28
open4FlipXTiles:
	db $05,$07,$09,$80,$A0,$82,$A2,$66,$61,$62,$C0,$C2,$BE,$EB,$66,$66,$EB,$BC,$2A
open5FlipXTiles:
	db $05,$07,$09,$80,$A0,$82,$A2,$C0,$C2,$61,$62,$66,$BE,$EB,$66,$BC,$EB,$66
attack1FlipXTiles:
	db $05,$07,$09,$61,$62,$80,$A0,$82,$A2,$C0,$C2,$66,$BE,$EB,$66,$EB,$BC,$66,$86,$A4
attack2FlipXTiles:
	db $05,$07,$09,$C0,$C2,$61,$62,$80,$A0,$82,$A2,$66,$66,$BE,$EB,$66,$EB,$BC,$86,$A4
close1FlipXTiles:
	db $05,$07,$09,$61,$62,$80,$A0,$82,$A2,$66,$86,$C0,$C2,$00,$02,$03,$A4
;===================================
;Semi Dynamic Routine
;===================================

semiDynamicRoutine:
	LDA $7FAB9E,x
	STA $05
	
	LDA !SemiDynamicSlots ;if the slot is not used then try to start
	CMP $02 ;if this sprite is a copy of the sprite that reserve the slot then return
	BNE +
	LDA #$00
	RTS
+
	LDA !SemiDynamicSlots
	STA $00 ;$00 = index of the sprite that use the slot
	LDA !SemiDynamicSlots+$01
	STA $01
	LDA !SemiDynamicSlots+$02
	STA $02
	LDA !SemiDynamicSlots+$03
	STA $03
	
	PHX
	
	LDX #$0B
.loop
	LDA $7FAB9E,x ;if exists a copy of the sprite that use the slot then return
	BEQ ++
	CMP #$FF
	BEQ ++
	CMP $05
	BEQ ++
	CMP $00
	BEQ +
	CMP $01
	BEQ +
	CMP $02
	BEQ +
	CMP $03
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
	PLX
	LDA #$FF
	RTS
+
	PLX
	PHX
	
	LDA $7FAB9E,x
	STA !SemiDynamicSlots ;reserve the slot
	STA !SemiDynamicSlots+$01
	STA !SemiDynamicSlots+$02
	STA !SemiDynamicSlots+$03

	LDA !GFXNumber
	PHA
	CLC
	ADC #$04
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
	STA !GFXBnk+$04,x
	STA !GFXBnk+$06,x
	LDA #$00
	STA !GFXBnk+$01,x
	STA !GFXBnk+$03,x
	STA !GFXBnk+$05,x
	STA !GFXBnk+$07,x

	REP #$20
	LDA GFXPointer
	STA !GFXRec,x
	CLC
	ADC #$0800
	STA !GFXRec+$02,x
	CLC
	ADC #$0800
	STA !GFXRec+$04,x
	CLC
	ADC #$0800
	STA !GFXRec+$06,x
	

	LDA #$0800
	STA !GFXLenght,x
	STA !GFXLenght+$02,x
	STA !GFXLenght+$04,x
	STA !GFXLenght+$06,x

	LDA #$6800
	STA !GFXVram,x
	CLC
	ADC #$0400
	STA !GFXVram+$02,x
	CLC
	ADC #$0400
	STA !GFXVram+$04,x
	CLC
	ADC #$0400
	STA !GFXVram+$06,x

	SEP #$20
	PLB
	PLX
	LDA #$01
	RTS
	
GFXPointer:
dw resource

resource:
incbin sprites\gunvolt.bin ;replace this for your GFX name
