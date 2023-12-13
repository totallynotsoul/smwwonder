;~@sa1 <-- DO NOT REMOVE THIS LINE!
PRINT "INIT ",pc
incsrc sprites\header.asm

!GrenadeSlot = $3360,x
LDA $7415
STA !GrenadeSlot
INC $7415

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

JSL !reserveNormalSlot32

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

ChangePlayerGraphics:
	LDA #$01
	STA !marioNormalCustomGFXOn

	LDA #$35
	STA !marioNormalCustomGFXBnk

	REP #$20
	LDA #$8008
	STA !marioNormalCustomGFXRec
	SEP #$20
	RTS
	
;-------------86..87..88..89..8A..8B..8C..8D..8E..8f
;Fill these tables with the colors.
ColorLow: db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ColorHih: db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00

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

	LDA !AnPointer
	BEQ +
	JSR explosionMax
	BRA ++
+
	JSR grenadeComplete
++
	JSR InteractionWithMario
	JSR GraphicManager ;manage the frames of the sprite and decide what frame show
.ret2
	RTS
.ret
	JSR preDynRoutine ;get a dynamic slot to make the dma routine using dynamic z
	RTS

grenadeComplete:
	
	LDA !DynamicSwitch
	BEQ .ret
	
	LDA $3258,x
	BEQ .ret
	
	LDA $3216,x
	CMP #$6C
	BCC .ret
	
	LDA #$09
	STA $7DFC
	STZ !AnFramePointer
	
	LDA #$02
	STA !AnPointer
	
	LDA #$00
	STA !AnimationTimer
	
	JSR Graphics
	
.ret
	LDA $14
	AND #$01
	BEQ +
	JSL $01802A
	RTS
+
	JSL $018022
	RTS
	
explosionMax:
	LDA !AnFramePointer
	CMP #$1B
	BCC .ret
	
	LDA !AnimationTimer
	BNE .ret
	
	STZ $3242,x
.ret
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
	dw $0000,$0020

AnimationsFrames:
rotateFrames:
	db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
explodeFrames:
	db $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B

AnimationsNFr:
rotateNext:
	db $01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$00
explodeNext:
	db $01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1B

AnimationsTFr:
rotateTimes:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
explodeTimes:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

AnimationsFlips:
rotateFlip:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
explodeFlip:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00


;===================================
;Interaction
;===================================
InteractionWithMario:

	LDA !FramePointer
	TAY
	LDA TotalHitboxes,y
	BPL +
	RTS
+
	LDA !LocalFlipper
	TAY
	LDA !FramePointer
	CLC
	ADC FlipAdder,y
	REP #$30
	AND #$00FF
	CLC
	ASL
	TAY ;load the frame pointer on X
	
	
	LDA StartPositionHitboxes,y
	STA $08
	
	LDA EndPositionHitboxes,y
	STA $0A
	SEP #$10
	
	LDA #$000C ;load y disp of mario on $04
	STA $04
	
	LDA $19
	BEQ +
	LDA #$0004 ;if mario is big the y disp is 4
	STA $04
+
	LDA $96
	CLC
	ADC $04
	STA $04 ;$04 is position + ydisp
	BPL +
	LDA #$0000 ;if $04 is negative then change it to 0
+
	STA $04 
	
	LDA $04
	CLC
	ADC #$0014
	STA $06 ;$06 = bottom
	LDA $19
	BEQ +
	LDA $06
	CLC
	ADC #$0008
	STA $06 ;if mario is big then add 8 to bottom 
+	
	LDA $787A
	BEQ +
	LDA $06
	CLC
	ADC #$0010 ;if mario is riding yoshi then add 16 to bottom
	STA $06
+
	LDA $06
	BPL +
	SEP #$20
	RTS
+

	SEP #$20
	
	LDA $322C,x
	STA $00
	LDA $326E,x
	STA $01
	
	LDA $3216,x
	STA $02
	LDA $3258,x
	STA $03
	
	REP #$30
	
	LDY $08
	
.loop

	LDA $00
	CLC
	ADC FramesHitboxXDisp,y
	STA $0E
	CLC
	ADC FramesHitboxWidth,y
	BMI .next ;if x + xdisp + width < xMario || x + xdisp + width < 0 then goto next
	CMP $94
	BCC .next
	
	LDA $0E
	BPL +
	STZ $300E ;if x+xdisp < 0 then x+xdisp = 0
+
	
	LDA $94
	CLC
	ADC #$0010
	CMP $0E
	BCC .next ;if xMario + widthMario < x+xdisp then goto next
	
	LDA $02
	CLC
	ADC FramesHitboxYDisp,y
	STA $0E
	CLC
	ADC FramesHitboxHeigth,y
	BMI .next
	CMP $04
	BCC .next ;if y + ydisp + height < yMario + ydispMario || y + ydisp + height < 0 then goto next

	LDA $0E
	BPL +
	STZ $300E ;if y + ydisp < 0 then y + ydisp = 0
+	
	LDA $06
	CMP $0E
	BCC .next ;if yMario + ydispMario + heigthMario < y + ydisp then gotonext
	
	PHY
	LDA FramesHitboxAction,y
	STA $0E
	SEP #$30
	TXY
	LDX #$00
	JSR ($300E,x) ;make action of this hitbox
	REP #$30
	PLY
.next
	DEY
	DEY
	BMI .ret
	CPY $0A
	BCS .loop
.ret	
	SEP #$30
RTS

hurt:
	TYX
	LDA $7497
	BNE +
	LDA $787A
	BNE .loseYoshi
	JSL $00F5B7
+
	RTS
.loseYoshi
	JSR LOSEYOSHI
	RTS
	
vel: db $20,$E0
LOSEYOSHI:	
	LDA $787A
	BEQ NOYOSHI
	PHX
	LDX $78E2
	LDA #$10
	STA $75AF,x
	LDA #$03
	STA $7DFA
	LDA #$13
	STA $7DFC
	LDA #$02
	STA $C1,x
	STZ $787A
	STZ $6DC1
	LDA #$C0
	STA $7D
	STZ $7B
	LDY $3329,x
	PHX
	TYX
	LDA vel,x
	PLX
	STA $A9,x
	STZ $3355,x
	STZ $7515,x
	STZ $78AE
	LDA #$30
	STA $7497
	PLX
NOYOSHI:
	RTS
;===================================
;Actions
;===================================
;===================================
;Graphic Routine
;===================================

oamstuff: 	dw $0000,$0010,$0050,$0090,$00A0	

tileRel: db $00,$08,$20,$28,$40,$48,$60,$68,$80,$88,$A0,$A8,$C0,$C8,$E0,$E8	

FlipAdder: db $00,$2C,$58,$84
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
	STZ $3242,x
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
	CLC
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
	
getDrawInfo200:
	PHY
	LDA $0E
	STA $04
	STZ $05
	REP #$20
	
	LDA $6F3A
	SEC
	SBC $1A
	STA $6F3A
	
	CMP #$0100
	BCC ++
	
	CMP #$FFF1
	BCS +
	
	SEP #$20
	LDA #$01
	STA $05
	PLY
	RTS
+
	LDY $04
	INY
	STY $0E
++
	LDA $6F3C
	SEC
	SBC $1C
	STA $6F3C
	
	CMP #$00F0
	BCS ++	

	CMP #$00E0
	BCS +
	SEP #$20
	PLY
	RTS
	
++
	CMP #$FFF1
	BCS ++
	
	SEP #$20
	LDA #$01
	STA $05
	PLY
	RTS
+
	LDY $04
	INY
	STY $0E
++
	SEP #$20
	PLY
	RTS
;===================================
;Frames
;===================================
FramesTotalTiles:

	db $01,$01,$01,$01,$02,$02,$01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$00,$00,$01,$01,$01,$01,$02,$02,$01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$00,$00,$01,$01,$01,$01,$02,$02,$01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$00,$00,$01,$01,$01,$01,$02,$02,$01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$00,$00

StartPositionFrames:
	dw $0001,$0003,$0005,$0007,$000A,$000D,$000F,$0011,$0013,$0015,$0018,$001B,$001E,$0021,$0023,$0025,$0029,$002D,$0031,$0035,$0039,$003D,$0041,$0045,$0049,$004D,$0051,$0055,$0059,$005D,$0061,$0065,$0069,$006D,$0071,$0075,$0079,$007D,$0081,$0085,$0089,$008D,$008E,$008F,$0091,$0093,$0095,$0097,$009A,$009D,$009F,$00A1,$00A3,$00A5,$00A8,$00AB,$00AE,$00B1,$00B3,$00B5,$00B9,$00BD,$00C1,$00C5,$00C9,$00CD,$00D1,$00D5,$00D9,$00DD,$00E1,$00E5,$00E9,$00ED,$00F1,$00F5,$00F9,$00FD,$0101,$0105,$0109,$010D,$0111,$0115,$0119,$011D,$011E,$011F,$0121,$0123,$0125,$0127,$012A,$012D,$012F,$0131,$0133,$0135,$0138,$013B,$013E,$0141,$0143,$0145,$0149,$014D,$0151,$0155,$0159,$015D,$0161,$0165,$0169,$016D,$0171,$0175,$0179,$017D,$0181,$0185,$0189,$018D,$0191,$0195,$0199,$019D,$01A1,$01A5,$01A9,$01AD,$01AE,$01AF,$01B1,$01B3,$01B5,$01B7,$01BA,$01BD,$01BF,$01C1,$01C3,$01C5,$01C8,$01CB,$01CE,$01D1,$01D3,$01D5,$01D9,$01DD,$01E1,$01E5,$01E9,$01ED,$01F1,$01F5,$01F9,$01FD,$0201,$0205,$0209,$020D,$0211,$0215,$0219,$021D,$0221,$0225,$0229,$022D,$0231,$0235,$0239,$023D,$023E,$023F

EndPositionFrames:
	dw $0000,$0002,$0004,$0006,$0008,$000B,$000E,$0010,$0012,$0014,$0016,$0019,$001C,$001F,$0022,$0024,$0026,$002A,$002E,$0032,$0036,$003A,$003E,$0042,$0046,$004A,$004E,$0052,$0056,$005A,$005E,$0062,$0066,$006A,$006E,$0072,$0076,$007A,$007E,$0082,$0086,$008A,$008E,$008F,$0090,$0092,$0094,$0096,$0098,$009B,$009E,$00A0,$00A2,$00A4,$00A6,$00A9,$00AC,$00AF,$00B2,$00B4,$00B6,$00BA,$00BE,$00C2,$00C6,$00CA,$00CE,$00D2,$00D6,$00DA,$00DE,$00E2,$00E6,$00EA,$00EE,$00F2,$00F6,$00FA,$00FE,$0102,$0106,$010A,$010E,$0112,$0116,$011A,$011E,$011F,$0120,$0122,$0124,$0126,$0128,$012B,$012E,$0130,$0132,$0134,$0136,$0139,$013C,$013F,$0142,$0144,$0146,$014A,$014E,$0152,$0156,$015A,$015E,$0162,$0166,$016A,$016E,$0172,$0176,$017A,$017E,$0182,$0186,$018A,$018E,$0192,$0196,$019A,$019E,$01A2,$01A6,$01AA,$01AE,$01AF,$01B0,$01B2,$01B4,$01B6,$01B8,$01BB,$01BE,$01C0,$01C2,$01C4,$01C6,$01C9,$01CC,$01CF,$01D2,$01D4,$01D6,$01DA,$01DE,$01E2,$01E6,$01EA,$01EE,$01F2,$01F6,$01FA,$01FE,$0202,$0206,$020A,$020E,$0212,$0216,$021A,$021E,$0222,$0226,$022A,$022E,$0232,$0236,$023A,$023E,$023F

TotalHitboxes:
	db $00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF

StartPositionHitboxes:
	dw $0000,$0002,$0004,$0008,$000C,$0010,$0014,$0018,$001A,$001C,$0020,$0024,$0028,$002C,$0030,$0034,$0038,$003C,$003E,$0040,$0042,$0044,$0046,$0048,$004A,$004C,$004E,$0050,$0052,$0056,$005A,$005C,$005E,$0060,$0062,$0064,$0066,$0068,$006A,$006C,$006E,$0070,$0072,$0074,$0076,$0078,$007A,$007E,$0082,$0086,$008A,$008E,$0090,$0092,$0096,$009A,$009E,$00A2,$00A6,$00AA,$00AE,$00B2,$00B4,$00B6,$00B8,$00BA,$00BC,$00BE,$00C0,$00C2,$00C4,$00C6,$00C8,$00CC,$00D0,$00D2,$00D4,$00D6,$00D8,$00DA,$00DC,$00DE,$00E0,$00E2,$00E4,$00E6,$00E8,$00EA,$00EC,$00EE,$00F0,$00F4,$00F8,$00FC,$0100,$0104,$0106,$0108,$010C,$0110,$0114,$0118,$011C,$0120,$0124,$0128,$012A,$012C,$012E,$0130,$0132,$0134,$0136,$0138,$013A,$013C,$013E,$0142,$0146,$0148,$014A,$014C,$014E,$0150,$0152,$0154,$0156,$0158,$015A,$015C,$015E,$0160,$0162,$0164,$0166,$016A,$016E,$0172,$0176,$017A,$017C,$017E,$0182,$0186,$018A,$018E,$0192,$0196,$019A,$019E,$01A0,$01A2,$01A4,$01A6,$01A8,$01AA,$01AC,$01AE,$01B0,$01B2,$01B4,$01B8,$01BC,$01BE,$01C0,$01C2,$01C4,$01C6,$01C8,$01CA,$01CC,$01CE,$01D0,$01D2,$01D4,$01D6

EndPositionHitboxes:
	dw $0000,$0002,$0004,$0006,$000A,$000E,$0012,$0016,$001A,$001C,$001E,$0022,$0026,$002A,$002E,$0032,$0036,$003A,$003E,$0040,$0042,$0044,$0046,$0048,$004A,$004C,$004E,$0050,$0052,$0054,$0058,$005C,$005E,$0060,$0062,$0064,$0066,$0068,$006A,$006C,$006E,$0070,$0072,$0074,$0076,$0078,$007A,$007C,$0080,$0084,$0088,$008C,$0090,$0092,$0094,$0098,$009C,$00A0,$00A4,$00A8,$00AC,$00B0,$00B4,$00B6,$00B8,$00BA,$00BC,$00BE,$00C0,$00C2,$00C4,$00C6,$00C8,$00CA,$00CE,$00D2,$00D4,$00D6,$00D8,$00DA,$00DC,$00DE,$00E0,$00E2,$00E4,$00E6,$00E8,$00EA,$00EC,$00EE,$00F0,$00F2,$00F6,$00FA,$00FE,$0102,$0106,$0108,$010A,$010E,$0112,$0116,$011A,$011E,$0122,$0126,$012A,$012C,$012E,$0130,$0132,$0134,$0136,$0138,$013A,$013C,$013E,$0140,$0144,$0148,$014A,$014C,$014E,$0150,$0152,$0154,$0156,$0158,$015A,$015C,$015E,$0160,$0162,$0164,$0166,$0168,$016C,$0170,$0174,$0178,$017C,$017E,$0180,$0184,$0188,$018C,$0190,$0194,$0198,$019C,$01A0,$01A2,$01A4,$01A6,$01A8,$01AA,$01AC,$01AE,$01B0,$01B2,$01B4,$01B6,$01BA,$01BE,$01C0,$01C2,$01C4,$01C6,$01C8,$01CA,$01CC,$01CE,$01D0,$01D2,$01D4,$01D6

FramesXDisp:
f1XDisp:
	db $01,$01
f2XDisp:
	db $02,$02
f3XDisp:
	db $03,$FB
f4XDisp:
	db $FB,$03
f5XDisp:
	db $01,$09,$01
f6XDisp:
	db $04,$FC,$04
f7XDisp:
	db $FE,$06
f8XDisp:
	db $00,$08
f9XDisp:
	db $FA,$02
f10XDisp:
	db $FC,$04
f11XDisp:
	db $FF,$07,$07
f12XDisp:
	db $FB,$03,$03
f13XDisp:
	db $03,$FF,$07
f14XDisp:
	db $FC,$04,$04
f15XDisp:
	db $03,$03
f16XDisp:
	db $03,$03
ex1XDisp:
	db $F8,$08,$F8,$08
ex2XDisp:
	db $F8,$08,$F8,$08
ex3XDisp:
	db $FA,$0A,$FA,$0A
ex4XDisp:
	db $FA,$0A,$FA,$0A
ex5XDisp:
	db $F8,$08,$F8,$08
ex6XDisp:
	db $F8,$08,$F8,$08
ex7XDisp:
	db $F8,$08,$F8,$08
ex8XDisp:
	db $F8,$08,$F8,$08
ex9XDisp:
	db $F8,$08,$F8,$08
ex10XDisp:
	db $F8,$08,$F8,$08
ex11XDisp:
	db $F8,$08,$F8,$08
ex12XDisp:
	db $F8,$08,$F8,$08
ex13XDisp:
	db $F8,$08,$F8,$08
ex14XDisp:
	db $F8,$08,$F8,$08
ex15XDisp:
	db $F8,$08,$F8,$08
ex16XDisp:
	db $F9,$09,$F9,$09
ex17XDisp:
	db $FA,$0A,$FA,$0A
ex18XDisp:
	db $FA,$0A,$FA,$0A
ex19XDisp:
	db $FA,$0A,$FA,$0A
ex20XDisp:
	db $FA,$0A,$FA,$0A
ex21XDisp:
	db $FA,$0A,$FA,$0A
ex22XDisp:
	db $FA,$0A,$FA,$0A
ex23XDisp:
	db $FA,$0A,$FA,$0A
ex24XDisp:
	db $FA,$0A,$FA,$0A
ex25XDisp:
	db $FA,$0A,$FA,$0A
ex26XDisp:
	db $FC,$0C,$FC,$0C
ex27XDisp:
	db $00
ex28XDisp:
	db $00
f1FlipXXDisp:
	db $FF,$FF
f2FlipXXDisp:
	db $FE,$FE
f3FlipXXDisp:
	db $FD,$05
f4FlipXXDisp:
	db $05,$FD
f5FlipXXDisp:
	db $FF,$F7,$FF
f6FlipXXDisp:
	db $FC,$04,$FC
f7FlipXXDisp:
	db $02,$FA
f8FlipXXDisp:
	db $00,$F8
f9FlipXXDisp:
	db $06,$FE
f10FlipXXDisp:
	db $04,$FC
f11FlipXXDisp:
	db $01,$F9,$F9
f12FlipXXDisp:
	db $05,$FD,$FD
f13FlipXXDisp:
	db $FD,$01,$F9
f14FlipXXDisp:
	db $04,$FC,$FC
f15FlipXXDisp:
	db $FD,$FD
f16FlipXXDisp:
	db $FD,$FD
ex1FlipXXDisp:
	db $08,$F8,$08,$F8
ex2FlipXXDisp:
	db $08,$F8,$08,$F8
ex3FlipXXDisp:
	db $06,$F6,$06,$F6
ex4FlipXXDisp:
	db $06,$F6,$06,$F6
ex5FlipXXDisp:
	db $08,$F8,$08,$F8
ex6FlipXXDisp:
	db $08,$F8,$08,$F8
ex7FlipXXDisp:
	db $08,$F8,$08,$F8
ex8FlipXXDisp:
	db $08,$F8,$08,$F8
ex9FlipXXDisp:
	db $08,$F8,$08,$F8
ex10FlipXXDisp:
	db $08,$F8,$08,$F8
ex11FlipXXDisp:
	db $08,$F8,$08,$F8
ex12FlipXXDisp:
	db $08,$F8,$08,$F8
ex13FlipXXDisp:
	db $08,$F8,$08,$F8
ex14FlipXXDisp:
	db $08,$F8,$08,$F8
ex15FlipXXDisp:
	db $08,$F8,$08,$F8
ex16FlipXXDisp:
	db $07,$F7,$07,$F7
ex17FlipXXDisp:
	db $06,$F6,$06,$F6
ex18FlipXXDisp:
	db $06,$F6,$06,$F6
ex19FlipXXDisp:
	db $06,$F6,$06,$F6
ex20FlipXXDisp:
	db $06,$F6,$06,$F6
ex21FlipXXDisp:
	db $06,$F6,$06,$F6
ex22FlipXXDisp:
	db $06,$F6,$06,$F6
ex23FlipXXDisp:
	db $06,$F6,$06,$F6
ex24FlipXXDisp:
	db $06,$F6,$06,$F6
ex25FlipXXDisp:
	db $06,$F6,$06,$F6
ex26FlipXXDisp:
	db $04,$F4,$04,$F4
ex27FlipXXDisp:
	db $00
ex28FlipXXDisp:
	db $00
f1FlipYXDisp:
	db $01,$01
f2FlipYXDisp:
	db $02,$02
f3FlipYXDisp:
	db $03,$FB
f4FlipYXDisp:
	db $FB,$03
f5FlipYXDisp:
	db $01,$09,$01
f6FlipYXDisp:
	db $04,$FC,$04
f7FlipYXDisp:
	db $FE,$06
f8FlipYXDisp:
	db $00,$08
f9FlipYXDisp:
	db $FA,$02
f10FlipYXDisp:
	db $FC,$04
f11FlipYXDisp:
	db $FF,$07,$07
f12FlipYXDisp:
	db $FB,$03,$03
f13FlipYXDisp:
	db $03,$FF,$07
f14FlipYXDisp:
	db $FC,$04,$04
f15FlipYXDisp:
	db $03,$03
f16FlipYXDisp:
	db $03,$03
ex1FlipYXDisp:
	db $F8,$08,$F8,$08
ex2FlipYXDisp:
	db $F8,$08,$F8,$08
ex3FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex4FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex5FlipYXDisp:
	db $F8,$08,$F8,$08
ex6FlipYXDisp:
	db $F8,$08,$F8,$08
ex7FlipYXDisp:
	db $F8,$08,$F8,$08
ex8FlipYXDisp:
	db $F8,$08,$F8,$08
ex9FlipYXDisp:
	db $F8,$08,$F8,$08
ex10FlipYXDisp:
	db $F8,$08,$F8,$08
ex11FlipYXDisp:
	db $F8,$08,$F8,$08
ex12FlipYXDisp:
	db $F8,$08,$F8,$08
ex13FlipYXDisp:
	db $F8,$08,$F8,$08
ex14FlipYXDisp:
	db $F8,$08,$F8,$08
ex15FlipYXDisp:
	db $F8,$08,$F8,$08
ex16FlipYXDisp:
	db $F9,$09,$F9,$09
ex17FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex18FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex19FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex20FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex21FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex22FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex23FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex24FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex25FlipYXDisp:
	db $FA,$0A,$FA,$0A
ex26FlipYXDisp:
	db $FC,$0C,$FC,$0C
ex27FlipYXDisp:
	db $00
ex28FlipYXDisp:
	db $00
f1FlipXYXDisp:
	db $FF,$FF
f2FlipXYXDisp:
	db $FE,$FE
f3FlipXYXDisp:
	db $FD,$05
f4FlipXYXDisp:
	db $05,$FD
f5FlipXYXDisp:
	db $FF,$F7,$FF
f6FlipXYXDisp:
	db $FC,$04,$FC
f7FlipXYXDisp:
	db $02,$FA
f8FlipXYXDisp:
	db $00,$F8
f9FlipXYXDisp:
	db $06,$FE
f10FlipXYXDisp:
	db $04,$FC
f11FlipXYXDisp:
	db $01,$F9,$F9
f12FlipXYXDisp:
	db $05,$FD,$FD
f13FlipXYXDisp:
	db $FD,$01,$F9
f14FlipXYXDisp:
	db $04,$FC,$FC
f15FlipXYXDisp:
	db $FD,$FD
f16FlipXYXDisp:
	db $FD,$FD
ex1FlipXYXDisp:
	db $08,$F8,$08,$F8
ex2FlipXYXDisp:
	db $08,$F8,$08,$F8
ex3FlipXYXDisp:
	db $06,$F6,$06,$F6
ex4FlipXYXDisp:
	db $06,$F6,$06,$F6
ex5FlipXYXDisp:
	db $08,$F8,$08,$F8
ex6FlipXYXDisp:
	db $08,$F8,$08,$F8
ex7FlipXYXDisp:
	db $08,$F8,$08,$F8
ex8FlipXYXDisp:
	db $08,$F8,$08,$F8
ex9FlipXYXDisp:
	db $08,$F8,$08,$F8
ex10FlipXYXDisp:
	db $08,$F8,$08,$F8
ex11FlipXYXDisp:
	db $08,$F8,$08,$F8
ex12FlipXYXDisp:
	db $08,$F8,$08,$F8
ex13FlipXYXDisp:
	db $08,$F8,$08,$F8
ex14FlipXYXDisp:
	db $08,$F8,$08,$F8
ex15FlipXYXDisp:
	db $08,$F8,$08,$F8
ex16FlipXYXDisp:
	db $07,$F7,$07,$F7
ex17FlipXYXDisp:
	db $06,$F6,$06,$F6
ex18FlipXYXDisp:
	db $06,$F6,$06,$F6
ex19FlipXYXDisp:
	db $06,$F6,$06,$F6
ex20FlipXYXDisp:
	db $06,$F6,$06,$F6
ex21FlipXYXDisp:
	db $06,$F6,$06,$F6
ex22FlipXYXDisp:
	db $06,$F6,$06,$F6
ex23FlipXYXDisp:
	db $06,$F6,$06,$F6
ex24FlipXYXDisp:
	db $06,$F6,$06,$F6
ex25FlipXYXDisp:
	db $06,$F6,$06,$F6
ex26FlipXYXDisp:
	db $04,$F4,$04,$F4
ex27FlipXYXDisp:
	db $00
ex28FlipXYXDisp:
	db $00


FramesYDisp:
f1yDisp:
	db $F8,$08
f2yDisp:
	db $F8,$08
f3yDisp:
	db $F8,$08
f4yDisp:
	db $08,$F8
f5yDisp:
	db $F8,$F8,$08
f6yDisp:
	db $F8,$08,$08
f7yDisp:
	db $00,$00
f8yDisp:
	db $01,$01
f9yDisp:
	db $02,$02
f10yDisp:
	db $03,$03
f11yDisp:
	db $FB,$FB,$0B
f12yDisp:
	db $FB,$FB,$0B
f13yDisp:
	db $0B,$FB,$FB
f14yDisp:
	db $FB,$FB,$0B
f15yDisp:
	db $FC,$0C
f16yDisp:
	db $FB,$0B
ex1yDisp:
	db $F8,$F8,$08,$08
ex2yDisp:
	db $F8,$F8,$08,$08
ex3yDisp:
	db $FA,$FA,$0A,$0A
ex4yDisp:
	db $FA,$FA,$0A,$0A
ex5yDisp:
	db $FA,$FA,$0A,$0A
ex6yDisp:
	db $FA,$FA,$0A,$0A
ex7yDisp:
	db $F8,$F8,$08,$08
ex8yDisp:
	db $F8,$F8,$08,$08
ex9yDisp:
	db $F8,$F8,$08,$08
ex10yDisp:
	db $F8,$F8,$08,$08
ex11yDisp:
	db $F8,$F8,$08,$08
ex12yDisp:
	db $F8,$F8,$08,$08
ex13yDisp:
	db $F8,$F8,$08,$08
ex14yDisp:
	db $F8,$F8,$08,$08
ex15yDisp:
	db $F8,$F8,$08,$08
ex16yDisp:
	db $F8,$F8,$08,$08
ex17yDisp:
	db $F8,$F8,$08,$08
ex18yDisp:
	db $F8,$F8,$08,$08
ex19yDisp:
	db $F8,$F8,$08,$08
ex20yDisp:
	db $F8,$F8,$08,$08
ex21yDisp:
	db $F8,$F8,$08,$08
ex22yDisp:
	db $F8,$F8,$08,$08
ex23yDisp:
	db $F8,$F8,$08,$08
ex24yDisp:
	db $F8,$F8,$08,$08
ex25yDisp:
	db $F8,$F8,$08,$08
ex26yDisp:
	db $F8,$F8,$08,$08
ex27yDisp:
	db $00
ex28yDisp:
	db $00
f1FlipXyDisp:
	db $F8,$08
f2FlipXyDisp:
	db $F8,$08
f3FlipXyDisp:
	db $F8,$08
f4FlipXyDisp:
	db $08,$F8
f5FlipXyDisp:
	db $F8,$F8,$08
f6FlipXyDisp:
	db $F8,$08,$08
f7FlipXyDisp:
	db $00,$00
f8FlipXyDisp:
	db $01,$01
f9FlipXyDisp:
	db $02,$02
f10FlipXyDisp:
	db $03,$03
f11FlipXyDisp:
	db $FB,$FB,$0B
f12FlipXyDisp:
	db $FB,$FB,$0B
f13FlipXyDisp:
	db $0B,$FB,$FB
f14FlipXyDisp:
	db $FB,$FB,$0B
f15FlipXyDisp:
	db $FC,$0C
f16FlipXyDisp:
	db $FB,$0B
ex1FlipXyDisp:
	db $F8,$F8,$08,$08
ex2FlipXyDisp:
	db $F8,$F8,$08,$08
ex3FlipXyDisp:
	db $FA,$FA,$0A,$0A
ex4FlipXyDisp:
	db $FA,$FA,$0A,$0A
ex5FlipXyDisp:
	db $FA,$FA,$0A,$0A
ex6FlipXyDisp:
	db $FA,$FA,$0A,$0A
ex7FlipXyDisp:
	db $F8,$F8,$08,$08
ex8FlipXyDisp:
	db $F8,$F8,$08,$08
ex9FlipXyDisp:
	db $F8,$F8,$08,$08
ex10FlipXyDisp:
	db $F8,$F8,$08,$08
ex11FlipXyDisp:
	db $F8,$F8,$08,$08
ex12FlipXyDisp:
	db $F8,$F8,$08,$08
ex13FlipXyDisp:
	db $F8,$F8,$08,$08
ex14FlipXyDisp:
	db $F8,$F8,$08,$08
ex15FlipXyDisp:
	db $F8,$F8,$08,$08
ex16FlipXyDisp:
	db $F8,$F8,$08,$08
ex17FlipXyDisp:
	db $F8,$F8,$08,$08
ex18FlipXyDisp:
	db $F8,$F8,$08,$08
ex19FlipXyDisp:
	db $F8,$F8,$08,$08
ex20FlipXyDisp:
	db $F8,$F8,$08,$08
ex21FlipXyDisp:
	db $F8,$F8,$08,$08
ex22FlipXyDisp:
	db $F8,$F8,$08,$08
ex23FlipXyDisp:
	db $F8,$F8,$08,$08
ex24FlipXyDisp:
	db $F8,$F8,$08,$08
ex25FlipXyDisp:
	db $F8,$F8,$08,$08
ex26FlipXyDisp:
	db $F8,$F8,$08,$08
ex27FlipXyDisp:
	db $00
ex28FlipXyDisp:
	db $00
f1FlipYyDisp:
	db $06,$F6
f2FlipYyDisp:
	db $06,$F6
f3FlipYyDisp:
	db $06,$F6
f4FlipYyDisp:
	db $F6,$06
f5FlipYyDisp:
	db $06,$06,$F6
f6FlipYyDisp:
	db $06,$F6,$F6
f7FlipYyDisp:
	db $FE,$FE
f8FlipYyDisp:
	db $FD,$FD
f9FlipYyDisp:
	db $FC,$FC
f10FlipYyDisp:
	db $FB,$FB
f11FlipYyDisp:
	db $03,$03,$F3
f12FlipYyDisp:
	db $03,$03,$F3
f13FlipYyDisp:
	db $F3,$03,$03
f14FlipYyDisp:
	db $03,$03,$F3
f15FlipYyDisp:
	db $02,$F2
f16FlipYyDisp:
	db $03,$F3
ex1FlipYyDisp:
	db $06,$06,$F6,$F6
ex2FlipYyDisp:
	db $06,$06,$F6,$F6
ex3FlipYyDisp:
	db $04,$04,$F4,$F4
ex4FlipYyDisp:
	db $04,$04,$F4,$F4
ex5FlipYyDisp:
	db $04,$04,$F4,$F4
ex6FlipYyDisp:
	db $04,$04,$F4,$F4
ex7FlipYyDisp:
	db $06,$06,$F6,$F6
ex8FlipYyDisp:
	db $06,$06,$F6,$F6
ex9FlipYyDisp:
	db $06,$06,$F6,$F6
ex10FlipYyDisp:
	db $06,$06,$F6,$F6
ex11FlipYyDisp:
	db $06,$06,$F6,$F6
ex12FlipYyDisp:
	db $06,$06,$F6,$F6
ex13FlipYyDisp:
	db $06,$06,$F6,$F6
ex14FlipYyDisp:
	db $06,$06,$F6,$F6
ex15FlipYyDisp:
	db $06,$06,$F6,$F6
ex16FlipYyDisp:
	db $06,$06,$F6,$F6
ex17FlipYyDisp:
	db $06,$06,$F6,$F6
ex18FlipYyDisp:
	db $06,$06,$F6,$F6
ex19FlipYyDisp:
	db $06,$06,$F6,$F6
ex20FlipYyDisp:
	db $06,$06,$F6,$F6
ex21FlipYyDisp:
	db $06,$06,$F6,$F6
ex22FlipYyDisp:
	db $06,$06,$F6,$F6
ex23FlipYyDisp:
	db $06,$06,$F6,$F6
ex24FlipYyDisp:
	db $06,$06,$F6,$F6
ex25FlipYyDisp:
	db $06,$06,$F6,$F6
ex26FlipYyDisp:
	db $06,$06,$F6,$F6
ex27FlipYyDisp:
	db $FE
ex28FlipYyDisp:
	db $FE
f1FlipXYyDisp:
	db $06,$F6
f2FlipXYyDisp:
	db $06,$F6
f3FlipXYyDisp:
	db $06,$F6
f4FlipXYyDisp:
	db $F6,$06
f5FlipXYyDisp:
	db $06,$06,$F6
f6FlipXYyDisp:
	db $06,$F6,$F6
f7FlipXYyDisp:
	db $FE,$FE
f8FlipXYyDisp:
	db $FD,$FD
f9FlipXYyDisp:
	db $FC,$FC
f10FlipXYyDisp:
	db $FB,$FB
f11FlipXYyDisp:
	db $03,$03,$F3
f12FlipXYyDisp:
	db $03,$03,$F3
f13FlipXYyDisp:
	db $F3,$03,$03
f14FlipXYyDisp:
	db $03,$03,$F3
f15FlipXYyDisp:
	db $02,$F2
f16FlipXYyDisp:
	db $03,$F3
ex1FlipXYyDisp:
	db $06,$06,$F6,$F6
ex2FlipXYyDisp:
	db $06,$06,$F6,$F6
ex3FlipXYyDisp:
	db $04,$04,$F4,$F4
ex4FlipXYyDisp:
	db $04,$04,$F4,$F4
ex5FlipXYyDisp:
	db $04,$04,$F4,$F4
ex6FlipXYyDisp:
	db $04,$04,$F4,$F4
ex7FlipXYyDisp:
	db $06,$06,$F6,$F6
ex8FlipXYyDisp:
	db $06,$06,$F6,$F6
ex9FlipXYyDisp:
	db $06,$06,$F6,$F6
ex10FlipXYyDisp:
	db $06,$06,$F6,$F6
ex11FlipXYyDisp:
	db $06,$06,$F6,$F6
ex12FlipXYyDisp:
	db $06,$06,$F6,$F6
ex13FlipXYyDisp:
	db $06,$06,$F6,$F6
ex14FlipXYyDisp:
	db $06,$06,$F6,$F6
ex15FlipXYyDisp:
	db $06,$06,$F6,$F6
ex16FlipXYyDisp:
	db $06,$06,$F6,$F6
ex17FlipXYyDisp:
	db $06,$06,$F6,$F6
ex18FlipXYyDisp:
	db $06,$06,$F6,$F6
ex19FlipXYyDisp:
	db $06,$06,$F6,$F6
ex20FlipXYyDisp:
	db $06,$06,$F6,$F6
ex21FlipXYyDisp:
	db $06,$06,$F6,$F6
ex22FlipXYyDisp:
	db $06,$06,$F6,$F6
ex23FlipXYyDisp:
	db $06,$06,$F6,$F6
ex24FlipXYyDisp:
	db $06,$06,$F6,$F6
ex25FlipXYyDisp:
	db $06,$06,$F6,$F6
ex26FlipXYyDisp:
	db $06,$06,$F6,$F6
ex27FlipXYyDisp:
	db $FE
ex28FlipXYyDisp:
	db $FE


FramesPropertie:
f1Properties:
	db $37,$37
f2Properties:
	db $37,$37
f3Properties:
	db $37,$37
f4Properties:
	db $37,$37
f5Properties:
	db $37,$37,$37
f6Properties:
	db $37,$37,$37
f7Properties:
	db $37,$37
f8Properties:
	db $37,$37
f9Properties:
	db $37,$37
f10Properties:
	db $37,$37
f11Properties:
	db $37,$37,$37
f12Properties:
	db $37,$37,$37
f13Properties:
	db $37,$37,$37
f14Properties:
	db $37,$37,$37
f15Properties:
	db $37,$37
f16Properties:
	db $37,$37
ex1Properties:
	db $39,$39,$B9,$B9
ex2Properties:
	db $39,$39,$B9,$B9
ex3Properties:
	db $39,$39,$39,$39
ex4Properties:
	db $39,$39,$39,$39
ex5Properties:
	db $39,$39,$39,$39
ex6Properties:
	db $39,$39,$39,$39
ex7Properties:
	db $39,$39,$39,$39
ex8Properties:
	db $39,$39,$39,$39
ex9Properties:
	db $39,$39,$39,$39
ex10Properties:
	db $39,$39,$39,$39
ex11Properties:
	db $39,$39,$39,$39
ex12Properties:
	db $39,$39,$39,$39
ex13Properties:
	db $39,$39,$39,$39
ex14Properties:
	db $39,$39,$39,$39
ex15Properties:
	db $39,$39,$39,$39
ex16Properties:
	db $39,$39,$39,$39
ex17Properties:
	db $39,$39,$39,$39
ex18Properties:
	db $39,$39,$39,$39
ex19Properties:
	db $39,$39,$39,$39
ex20Properties:
	db $39,$39,$39,$39
ex21Properties:
	db $39,$39,$39,$39
ex22Properties:
	db $39,$39,$39,$39
ex23Properties:
	db $39,$39,$39,$39
ex24Properties:
	db $39,$39,$39,$39
ex25Properties:
	db $39,$39,$39,$39
ex26Properties:
	db $39,$39,$39,$39
ex27Properties:
	db $39
ex28Properties:
	db $39
f1FlipXProperties:
	db $77,$77
f2FlipXProperties:
	db $77,$77
f3FlipXProperties:
	db $77,$77
f4FlipXProperties:
	db $77,$77
f5FlipXProperties:
	db $77,$77,$77
f6FlipXProperties:
	db $77,$77,$77
f7FlipXProperties:
	db $77,$77
f8FlipXProperties:
	db $77,$77
f9FlipXProperties:
	db $77,$77
f10FlipXProperties:
	db $77,$77
f11FlipXProperties:
	db $77,$77,$77
f12FlipXProperties:
	db $77,$77,$77
f13FlipXProperties:
	db $77,$77,$77
f14FlipXProperties:
	db $77,$77,$77
f15FlipXProperties:
	db $77,$77
f16FlipXProperties:
	db $77,$77
ex1FlipXProperties:
	db $79,$79,$F9,$F9
ex2FlipXProperties:
	db $79,$79,$F9,$F9
ex3FlipXProperties:
	db $79,$79,$79,$79
ex4FlipXProperties:
	db $79,$79,$79,$79
ex5FlipXProperties:
	db $79,$79,$79,$79
ex6FlipXProperties:
	db $79,$79,$79,$79
ex7FlipXProperties:
	db $79,$79,$79,$79
ex8FlipXProperties:
	db $79,$79,$79,$79
ex9FlipXProperties:
	db $79,$79,$79,$79
ex10FlipXProperties:
	db $79,$79,$79,$79
ex11FlipXProperties:
	db $79,$79,$79,$79
ex12FlipXProperties:
	db $79,$79,$79,$79
ex13FlipXProperties:
	db $79,$79,$79,$79
ex14FlipXProperties:
	db $79,$79,$79,$79
ex15FlipXProperties:
	db $79,$79,$79,$79
ex16FlipXProperties:
	db $79,$79,$79,$79
ex17FlipXProperties:
	db $79,$79,$79,$79
ex18FlipXProperties:
	db $79,$79,$79,$79
ex19FlipXProperties:
	db $79,$79,$79,$79
ex20FlipXProperties:
	db $79,$79,$79,$79
ex21FlipXProperties:
	db $79,$79,$79,$79
ex22FlipXProperties:
	db $79,$79,$79,$79
ex23FlipXProperties:
	db $79,$79,$79,$79
ex24FlipXProperties:
	db $79,$79,$79,$79
ex25FlipXProperties:
	db $79,$79,$79,$79
ex26FlipXProperties:
	db $79,$79,$79,$79
ex27FlipXProperties:
	db $79
ex28FlipXProperties:
	db $79
f1FlipYProperties:
	db $B7,$B7
f2FlipYProperties:
	db $B7,$B7
f3FlipYProperties:
	db $B7,$B7
f4FlipYProperties:
	db $B7,$B7
f5FlipYProperties:
	db $B7,$B7,$B7
f6FlipYProperties:
	db $B7,$B7,$B7
f7FlipYProperties:
	db $B7,$B7
f8FlipYProperties:
	db $B7,$B7
f9FlipYProperties:
	db $B7,$B7
f10FlipYProperties:
	db $B7,$B7
f11FlipYProperties:
	db $B7,$B7,$B7
f12FlipYProperties:
	db $B7,$B7,$B7
f13FlipYProperties:
	db $B7,$B7,$B7
f14FlipYProperties:
	db $B7,$B7,$B7
f15FlipYProperties:
	db $B7,$B7
f16FlipYProperties:
	db $B7,$B7
ex1FlipYProperties:
	db $B9,$B9,$39,$39
ex2FlipYProperties:
	db $B9,$B9,$39,$39
ex3FlipYProperties:
	db $B9,$B9,$B9,$B9
ex4FlipYProperties:
	db $B9,$B9,$B9,$B9
ex5FlipYProperties:
	db $B9,$B9,$B9,$B9
ex6FlipYProperties:
	db $B9,$B9,$B9,$B9
ex7FlipYProperties:
	db $B9,$B9,$B9,$B9
ex8FlipYProperties:
	db $B9,$B9,$B9,$B9
ex9FlipYProperties:
	db $B9,$B9,$B9,$B9
ex10FlipYProperties:
	db $B9,$B9,$B9,$B9
ex11FlipYProperties:
	db $B9,$B9,$B9,$B9
ex12FlipYProperties:
	db $B9,$B9,$B9,$B9
ex13FlipYProperties:
	db $B9,$B9,$B9,$B9
ex14FlipYProperties:
	db $B9,$B9,$B9,$B9
ex15FlipYProperties:
	db $B9,$B9,$B9,$B9
ex16FlipYProperties:
	db $B9,$B9,$B9,$B9
ex17FlipYProperties:
	db $B9,$B9,$B9,$B9
ex18FlipYProperties:
	db $B9,$B9,$B9,$B9
ex19FlipYProperties:
	db $B9,$B9,$B9,$B9
ex20FlipYProperties:
	db $B9,$B9,$B9,$B9
ex21FlipYProperties:
	db $B9,$B9,$B9,$B9
ex22FlipYProperties:
	db $B9,$B9,$B9,$B9
ex23FlipYProperties:
	db $B9,$B9,$B9,$B9
ex24FlipYProperties:
	db $B9,$B9,$B9,$B9
ex25FlipYProperties:
	db $B9,$B9,$B9,$B9
ex26FlipYProperties:
	db $B9,$B9,$B9,$B9
ex27FlipYProperties:
	db $B9
ex28FlipYProperties:
	db $B9
f1FlipXYProperties:
	db $F7,$F7
f2FlipXYProperties:
	db $F7,$F7
f3FlipXYProperties:
	db $F7,$F7
f4FlipXYProperties:
	db $F7,$F7
f5FlipXYProperties:
	db $F7,$F7,$F7
f6FlipXYProperties:
	db $F7,$F7,$F7
f7FlipXYProperties:
	db $F7,$F7
f8FlipXYProperties:
	db $F7,$F7
f9FlipXYProperties:
	db $F7,$F7
f10FlipXYProperties:
	db $F7,$F7
f11FlipXYProperties:
	db $F7,$F7,$F7
f12FlipXYProperties:
	db $F7,$F7,$F7
f13FlipXYProperties:
	db $F7,$F7,$F7
f14FlipXYProperties:
	db $F7,$F7,$F7
f15FlipXYProperties:
	db $F7,$F7
f16FlipXYProperties:
	db $F7,$F7
ex1FlipXYProperties:
	db $F9,$F9,$79,$79
ex2FlipXYProperties:
	db $F9,$F9,$79,$79
ex3FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex4FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex5FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex6FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex7FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex8FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex9FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex10FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex11FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex12FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex13FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex14FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex15FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex16FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex17FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex18FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex19FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex20FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex21FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex22FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex23FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex24FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex25FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex26FlipXYProperties:
	db $F9,$F9,$F9,$F9
ex27FlipXYProperties:
	db $F9
ex28FlipXYProperties:
	db $F9


FramesTile:
f1Tiles:
	db $80,$82
f2Tiles:
	db $80,$82
f3Tiles:
	db $80,$82
f4Tiles:
	db $82,$80
f5Tiles:
	db $80,$81,$83
f6Tiles:
	db $80,$82,$83
f7Tiles:
	db $80,$81
f8Tiles:
	db $80,$81
f9Tiles:
	db $82,$83
f10Tiles:
	db $80,$81
f11Tiles:
	db $80,$81,$84
f12Tiles:
	db $82,$83,$80
f13Tiles:
	db $84,$80,$81
f14Tiles:
	db $82,$83,$85
f15Tiles:
	db $80,$82
f16Tiles:
	db $80,$82
ex1Tiles:
	db $80,$82,$80,$82
ex2Tiles:
	db $80,$82,$80,$82
ex3Tiles:
	db $80,$82,$84,$86
ex4Tiles:
	db $80,$82,$84,$86
ex5Tiles:
	db $80,$82,$84,$86
ex6Tiles:
	db $80,$82,$84,$86
ex7Tiles:
	db $80,$82,$84,$86
ex8Tiles:
	db $80,$82,$84,$86
ex9Tiles:
	db $80,$82,$84,$86
ex10Tiles:
	db $80,$82,$84,$86
ex11Tiles:
	db $80,$82,$84,$86
ex12Tiles:
	db $80,$82,$84,$86
ex13Tiles:
	db $80,$82,$84,$86
ex14Tiles:
	db $80,$82,$84,$86
ex15Tiles:
	db $80,$82,$84,$86
ex16Tiles:
	db $80,$82,$84,$86
ex17Tiles:
	db $80,$82,$84,$86
ex18Tiles:
	db $80,$82,$84,$86
ex19Tiles:
	db $80,$82,$84,$86
ex20Tiles:
	db $80,$82,$84,$86
ex21Tiles:
	db $80,$82,$84,$86
ex22Tiles:
	db $80,$82,$84,$86
ex23Tiles:
	db $80,$82,$84,$86
ex24Tiles:
	db $80,$82,$84,$86
ex25Tiles:
	db $80,$82,$84,$86
ex26Tiles:
	db $80,$82,$84,$86
ex27Tiles:
	db $80
ex28Tiles:
	db $80
f1FlipXTiles:
	db $80,$82
f2FlipXTiles:
	db $80,$82
f3FlipXTiles:
	db $80,$82
f4FlipXTiles:
	db $82,$80
f5FlipXTiles:
	db $80,$81,$83
f6FlipXTiles:
	db $80,$82,$83
f7FlipXTiles:
	db $80,$81
f8FlipXTiles:
	db $80,$81
f9FlipXTiles:
	db $82,$83
f10FlipXTiles:
	db $80,$81
f11FlipXTiles:
	db $80,$81,$84
f12FlipXTiles:
	db $82,$83,$80
f13FlipXTiles:
	db $84,$80,$81
f14FlipXTiles:
	db $82,$83,$85
f15FlipXTiles:
	db $80,$82
f16FlipXTiles:
	db $80,$82
ex1FlipXTiles:
	db $80,$82,$80,$82
ex2FlipXTiles:
	db $80,$82,$80,$82
ex3FlipXTiles:
	db $80,$82,$84,$86
ex4FlipXTiles:
	db $80,$82,$84,$86
ex5FlipXTiles:
	db $80,$82,$84,$86
ex6FlipXTiles:
	db $80,$82,$84,$86
ex7FlipXTiles:
	db $80,$82,$84,$86
ex8FlipXTiles:
	db $80,$82,$84,$86
ex9FlipXTiles:
	db $80,$82,$84,$86
ex10FlipXTiles:
	db $80,$82,$84,$86
ex11FlipXTiles:
	db $80,$82,$84,$86
ex12FlipXTiles:
	db $80,$82,$84,$86
ex13FlipXTiles:
	db $80,$82,$84,$86
ex14FlipXTiles:
	db $80,$82,$84,$86
ex15FlipXTiles:
	db $80,$82,$84,$86
ex16FlipXTiles:
	db $80,$82,$84,$86
ex17FlipXTiles:
	db $80,$82,$84,$86
ex18FlipXTiles:
	db $80,$82,$84,$86
ex19FlipXTiles:
	db $80,$82,$84,$86
ex20FlipXTiles:
	db $80,$82,$84,$86
ex21FlipXTiles:
	db $80,$82,$84,$86
ex22FlipXTiles:
	db $80,$82,$84,$86
ex23FlipXTiles:
	db $80,$82,$84,$86
ex24FlipXTiles:
	db $80,$82,$84,$86
ex25FlipXTiles:
	db $80,$82,$84,$86
ex26FlipXTiles:
	db $80,$82,$84,$86
ex27FlipXTiles:
	db $80
ex28FlipXTiles:
	db $80
f1FlipYTiles:
	db $80,$82
f2FlipYTiles:
	db $80,$82
f3FlipYTiles:
	db $80,$82
f4FlipYTiles:
	db $82,$80
f5FlipYTiles:
	db $80,$81,$83
f6FlipYTiles:
	db $80,$82,$83
f7FlipYTiles:
	db $80,$81
f8FlipYTiles:
	db $80,$81
f9FlipYTiles:
	db $82,$83
f10FlipYTiles:
	db $80,$81
f11FlipYTiles:
	db $80,$81,$84
f12FlipYTiles:
	db $82,$83,$80
f13FlipYTiles:
	db $84,$80,$81
f14FlipYTiles:
	db $82,$83,$85
f15FlipYTiles:
	db $80,$82
f16FlipYTiles:
	db $80,$82
ex1FlipYTiles:
	db $80,$82,$80,$82
ex2FlipYTiles:
	db $80,$82,$80,$82
ex3FlipYTiles:
	db $80,$82,$84,$86
ex4FlipYTiles:
	db $80,$82,$84,$86
ex5FlipYTiles:
	db $80,$82,$84,$86
ex6FlipYTiles:
	db $80,$82,$84,$86
ex7FlipYTiles:
	db $80,$82,$84,$86
ex8FlipYTiles:
	db $80,$82,$84,$86
ex9FlipYTiles:
	db $80,$82,$84,$86
ex10FlipYTiles:
	db $80,$82,$84,$86
ex11FlipYTiles:
	db $80,$82,$84,$86
ex12FlipYTiles:
	db $80,$82,$84,$86
ex13FlipYTiles:
	db $80,$82,$84,$86
ex14FlipYTiles:
	db $80,$82,$84,$86
ex15FlipYTiles:
	db $80,$82,$84,$86
ex16FlipYTiles:
	db $80,$82,$84,$86
ex17FlipYTiles:
	db $80,$82,$84,$86
ex18FlipYTiles:
	db $80,$82,$84,$86
ex19FlipYTiles:
	db $80,$82,$84,$86
ex20FlipYTiles:
	db $80,$82,$84,$86
ex21FlipYTiles:
	db $80,$82,$84,$86
ex22FlipYTiles:
	db $80,$82,$84,$86
ex23FlipYTiles:
	db $80,$82,$84,$86
ex24FlipYTiles:
	db $80,$82,$84,$86
ex25FlipYTiles:
	db $80,$82,$84,$86
ex26FlipYTiles:
	db $80,$82,$84,$86
ex27FlipYTiles:
	db $80
ex28FlipYTiles:
	db $80
f1FlipXYTiles:
	db $80,$82
f2FlipXYTiles:
	db $80,$82
f3FlipXYTiles:
	db $80,$82
f4FlipXYTiles:
	db $82,$80
f5FlipXYTiles:
	db $80,$81,$83
f6FlipXYTiles:
	db $80,$82,$83
f7FlipXYTiles:
	db $80,$81
f8FlipXYTiles:
	db $80,$81
f9FlipXYTiles:
	db $82,$83
f10FlipXYTiles:
	db $80,$81
f11FlipXYTiles:
	db $80,$81,$84
f12FlipXYTiles:
	db $82,$83,$80
f13FlipXYTiles:
	db $84,$80,$81
f14FlipXYTiles:
	db $82,$83,$85
f15FlipXYTiles:
	db $80,$82
f16FlipXYTiles:
	db $80,$82
ex1FlipXYTiles:
	db $80,$82,$80,$82
ex2FlipXYTiles:
	db $80,$82,$80,$82
ex3FlipXYTiles:
	db $80,$82,$84,$86
ex4FlipXYTiles:
	db $80,$82,$84,$86
ex5FlipXYTiles:
	db $80,$82,$84,$86
ex6FlipXYTiles:
	db $80,$82,$84,$86
ex7FlipXYTiles:
	db $80,$82,$84,$86
ex8FlipXYTiles:
	db $80,$82,$84,$86
ex9FlipXYTiles:
	db $80,$82,$84,$86
ex10FlipXYTiles:
	db $80,$82,$84,$86
ex11FlipXYTiles:
	db $80,$82,$84,$86
ex12FlipXYTiles:
	db $80,$82,$84,$86
ex13FlipXYTiles:
	db $80,$82,$84,$86
ex14FlipXYTiles:
	db $80,$82,$84,$86
ex15FlipXYTiles:
	db $80,$82,$84,$86
ex16FlipXYTiles:
	db $80,$82,$84,$86
ex17FlipXYTiles:
	db $80,$82,$84,$86
ex18FlipXYTiles:
	db $80,$82,$84,$86
ex19FlipXYTiles:
	db $80,$82,$84,$86
ex20FlipXYTiles:
	db $80,$82,$84,$86
ex21FlipXYTiles:
	db $80,$82,$84,$86
ex22FlipXYTiles:
	db $80,$82,$84,$86
ex23FlipXYTiles:
	db $80,$82,$84,$86
ex24FlipXYTiles:
	db $80,$82,$84,$86
ex25FlipXYTiles:
	db $80,$82,$84,$86
ex26FlipXYTiles:
	db $80,$82,$84,$86
ex27FlipXYTiles:
	db $80
ex28FlipXYTiles:
	db $80


FramesHitboxXDisp:
f1HitboxXDisp:
	dw $0004
f2HitboxXDisp:
	dw $0004
f3HitboxXDisp:
	dw $0004
f4HitboxXDisp:
	dw $0008,$0004
f5HitboxXDisp:
	dw $0008,$0004
f6HitboxXDisp:
	dw $0008,$0000
f7HitboxXDisp:
	dw $0008,$0000
f8HitboxXDisp:
	dw $0008,$0000
f9HitboxXDisp:
	dw $0000
f10HitboxXDisp:
	dw $0000
f11HitboxXDisp:
	dw $0008,$0000
f12HitboxXDisp:
	dw $0008,$0000
f13HitboxXDisp:
	dw $0008,$0000
f14HitboxXDisp:
	dw $0004,$0004
f15HitboxXDisp:
	dw $0004,$0004
f16HitboxXDisp:
	dw $0004,$0008
ex1HitboxXDisp:
	dw $FFFC,$0000
ex2HitboxXDisp:
	dw $FFFC,$0000
ex3HitboxXDisp:
	dw $0000
ex4HitboxXDisp:
	dw $0000
ex5HitboxXDisp:
	dw $FFFC
ex6HitboxXDisp:
	dw $FFFC
ex7HitboxXDisp:
	dw $FFFC
ex8HitboxXDisp:
	dw $FFFC
ex9HitboxXDisp:
	dw $FFFC
ex10HitboxXDisp:
	dw $FFFC
ex11HitboxXDisp:
	dw $FFFC
ex12HitboxXDisp:
	dw $FFFC
ex13HitboxXDisp:
	dw $FFFC
ex14HitboxXDisp:
	dw $0000,$FFFC
ex15HitboxXDisp:
	dw $0000,$FFFC
ex16HitboxXDisp:
	dw $0000
ex17HitboxXDisp:
	dw $0000
ex18HitboxXDisp:
	dw $0000
ex19HitboxXDisp:
	dw $0000
ex20HitboxXDisp:
	dw $0000
ex21HitboxXDisp:
	dw $FFFC
ex22HitboxXDisp:
	dw $FFFF
ex23HitboxXDisp:
	dw $FFFF
ex24HitboxXDisp:
	dw $FFFF
ex25HitboxXDisp:
	dw $FFFF
ex26HitboxXDisp:
	dw $FFFF
ex27HitboxXDisp:
	dw $FFFF
ex28HitboxXDisp:
	dw $FFFF
f1FlipXHitboxXDisp:
	dw $0004
f2FlipXHitboxXDisp:
	dw $0004
f3FlipXHitboxXDisp:
	dw $0004
f4FlipXHitboxXDisp:
	dw $0000,$0008
f5FlipXHitboxXDisp:
	dw $0000,$0008
f6FlipXHitboxXDisp:
	dw $0000,$0008
f7FlipXHitboxXDisp:
	dw $0000,$0008
f8FlipXHitboxXDisp:
	dw $0000,$0008
f9FlipXHitboxXDisp:
	dw $0000
f10FlipXHitboxXDisp:
	dw $0000
f11FlipXHitboxXDisp:
	dw $0000,$0008
f12FlipXHitboxXDisp:
	dw $0000,$0008
f13FlipXHitboxXDisp:
	dw $0000,$0008
f14FlipXHitboxXDisp:
	dw $0000,$0008
f15FlipXHitboxXDisp:
	dw $0000,$0008
f16FlipXHitboxXDisp:
	dw $0008,$0004
ex1FlipXHitboxXDisp:
	dw $FFFC,$0000
ex2FlipXHitboxXDisp:
	dw $FFFC,$0000
ex3FlipXHitboxXDisp:
	dw $0000
ex4FlipXHitboxXDisp:
	dw $0000
ex5FlipXHitboxXDisp:
	dw $FFFC
ex6FlipXHitboxXDisp:
	dw $0000
ex7FlipXHitboxXDisp:
	dw $0000
ex8FlipXHitboxXDisp:
	dw $FFFC
ex9FlipXHitboxXDisp:
	dw $FFFC
ex10FlipXHitboxXDisp:
	dw $FFFC
ex11FlipXHitboxXDisp:
	dw $FFFC
ex12FlipXHitboxXDisp:
	dw $FFFC
ex13FlipXHitboxXDisp:
	dw $0000
ex14FlipXHitboxXDisp:
	dw $0000,$0000
ex15FlipXHitboxXDisp:
	dw $0000,$0000
ex16FlipXHitboxXDisp:
	dw $0000
ex17FlipXHitboxXDisp:
	dw $0000
ex18FlipXHitboxXDisp:
	dw $0000
ex19FlipXHitboxXDisp:
	dw $0000
ex20FlipXHitboxXDisp:
	dw $0000
ex21FlipXHitboxXDisp:
	dw $0000
ex22FlipXHitboxXDisp:
	dw $FFFF
ex23FlipXHitboxXDisp:
	dw $FFFF
ex24FlipXHitboxXDisp:
	dw $FFFF
ex25FlipXHitboxXDisp:
	dw $FFFF
ex26FlipXHitboxXDisp:
	dw $FFFF
ex27FlipXHitboxXDisp:
	dw $FFFF
ex28FlipXHitboxXDisp:
	dw $FFFF
f1FlipYHitboxXDisp:
	dw $0004
f2FlipYHitboxXDisp:
	dw $0004
f3FlipYHitboxXDisp:
	dw $0004
f4FlipYHitboxXDisp:
	dw $0008,$0004
f5FlipYHitboxXDisp:
	dw $0008,$0004
f6FlipYHitboxXDisp:
	dw $0008,$0000
f7FlipYHitboxXDisp:
	dw $0008,$0000
f8FlipYHitboxXDisp:
	dw $0008,$0000
f9FlipYHitboxXDisp:
	dw $0000
f10FlipYHitboxXDisp:
	dw $0000
f11FlipYHitboxXDisp:
	dw $0008,$0000
f12FlipYHitboxXDisp:
	dw $0008,$0000
f13FlipYHitboxXDisp:
	dw $0008,$0000
f14FlipYHitboxXDisp:
	dw $0004,$0004
f15FlipYHitboxXDisp:
	dw $0004,$0004
f16FlipYHitboxXDisp:
	dw $0004,$0008
ex1FlipYHitboxXDisp:
	dw $FFFC,$0000
ex2FlipYHitboxXDisp:
	dw $FFFC,$0000
ex3FlipYHitboxXDisp:
	dw $0000
ex4FlipYHitboxXDisp:
	dw $0000
ex5FlipYHitboxXDisp:
	dw $FFFC
ex6FlipYHitboxXDisp:
	dw $FFFC
ex7FlipYHitboxXDisp:
	dw $FFFC
ex8FlipYHitboxXDisp:
	dw $FFFC
ex9FlipYHitboxXDisp:
	dw $FFFC
ex10FlipYHitboxXDisp:
	dw $FFFC
ex11FlipYHitboxXDisp:
	dw $FFFC
ex12FlipYHitboxXDisp:
	dw $FFFC
ex13FlipYHitboxXDisp:
	dw $FFFC
ex14FlipYHitboxXDisp:
	dw $0000,$FFFC
ex15FlipYHitboxXDisp:
	dw $0000,$FFFC
ex16FlipYHitboxXDisp:
	dw $0000
ex17FlipYHitboxXDisp:
	dw $0000
ex18FlipYHitboxXDisp:
	dw $0000
ex19FlipYHitboxXDisp:
	dw $0000
ex20FlipYHitboxXDisp:
	dw $0000
ex21FlipYHitboxXDisp:
	dw $FFFC
ex22FlipYHitboxXDisp:
	dw $FFFF
ex23FlipYHitboxXDisp:
	dw $FFFF
ex24FlipYHitboxXDisp:
	dw $FFFF
ex25FlipYHitboxXDisp:
	dw $FFFF
ex26FlipYHitboxXDisp:
	dw $FFFF
ex27FlipYHitboxXDisp:
	dw $FFFF
ex28FlipYHitboxXDisp:
	dw $FFFF
f1FlipXYHitboxXDisp:
	dw $0004
f2FlipXYHitboxXDisp:
	dw $0004
f3FlipXYHitboxXDisp:
	dw $0004
f4FlipXYHitboxXDisp:
	dw $0000,$0008
f5FlipXYHitboxXDisp:
	dw $0000,$0008
f6FlipXYHitboxXDisp:
	dw $0000,$0008
f7FlipXYHitboxXDisp:
	dw $0000,$0008
f8FlipXYHitboxXDisp:
	dw $0000,$0008
f9FlipXYHitboxXDisp:
	dw $0000
f10FlipXYHitboxXDisp:
	dw $0000
f11FlipXYHitboxXDisp:
	dw $0000,$0008
f12FlipXYHitboxXDisp:
	dw $0000,$0008
f13FlipXYHitboxXDisp:
	dw $0000,$0008
f14FlipXYHitboxXDisp:
	dw $0000,$0008
f15FlipXYHitboxXDisp:
	dw $0000,$0008
f16FlipXYHitboxXDisp:
	dw $0008,$0004
ex1FlipXYHitboxXDisp:
	dw $FFFC,$0000
ex2FlipXYHitboxXDisp:
	dw $FFFC,$0000
ex3FlipXYHitboxXDisp:
	dw $0000
ex4FlipXYHitboxXDisp:
	dw $0000
ex5FlipXYHitboxXDisp:
	dw $FFFC
ex6FlipXYHitboxXDisp:
	dw $0000
ex7FlipXYHitboxXDisp:
	dw $0000
ex8FlipXYHitboxXDisp:
	dw $FFFC
ex9FlipXYHitboxXDisp:
	dw $FFFC
ex10FlipXYHitboxXDisp:
	dw $FFFC
ex11FlipXYHitboxXDisp:
	dw $FFFC
ex12FlipXYHitboxXDisp:
	dw $FFFC
ex13FlipXYHitboxXDisp:
	dw $0000
ex14FlipXYHitboxXDisp:
	dw $0000,$0000
ex15FlipXYHitboxXDisp:
	dw $0000,$0000
ex16FlipXYHitboxXDisp:
	dw $0000
ex17FlipXYHitboxXDisp:
	dw $0000
ex18FlipXYHitboxXDisp:
	dw $0000
ex19FlipXYHitboxXDisp:
	dw $0000
ex20FlipXYHitboxXDisp:
	dw $0000
ex21FlipXYHitboxXDisp:
	dw $0000
ex22FlipXYHitboxXDisp:
	dw $FFFF
ex23FlipXYHitboxXDisp:
	dw $FFFF
ex24FlipXYHitboxXDisp:
	dw $FFFF
ex25FlipXYHitboxXDisp:
	dw $FFFF
ex26FlipXYHitboxXDisp:
	dw $FFFF
ex27FlipXYHitboxXDisp:
	dw $FFFF
ex28FlipXYHitboxXDisp:
	dw $FFFF


FramesHitboxYDisp:
f1HitboxyDisp:
	dw $FFFC
f2HitboxyDisp:
	dw $FFFC
f3HitboxyDisp:
	dw $FFFC
f4HitboxyDisp:
	dw $FFFC,$0004
f5HitboxyDisp:
	dw $0000,$0008
f6HitboxyDisp:
	dw $0000,$0008
f7HitboxyDisp:
	dw $0000,$0008
f8HitboxyDisp:
	dw $0004,$0008
f9HitboxyDisp:
	dw $0004
f10HitboxyDisp:
	dw $0004
f11HitboxyDisp:
	dw $0004,$0004
f12HitboxyDisp:
	dw $0004,$0004
f13HitboxyDisp:
	dw $0008,$0000
f14HitboxyDisp:
	dw $0008,$0000
f15HitboxyDisp:
	dw $0008,$0000
f16HitboxyDisp:
	dw $FFFC,$0004
ex1HitboxyDisp:
	dw $0000,$FFFC
ex2HitboxyDisp:
	dw $0000,$FFFC
ex3HitboxyDisp:
	dw $FFFC
ex4HitboxyDisp:
	dw $FFFC
ex5HitboxyDisp:
	dw $FFFC
ex6HitboxyDisp:
	dw $FFFC
ex7HitboxyDisp:
	dw $FFFC
ex8HitboxyDisp:
	dw $FFFC
ex9HitboxyDisp:
	dw $FFFC
ex10HitboxyDisp:
	dw $FFFC
ex11HitboxyDisp:
	dw $FFFC
ex12HitboxyDisp:
	dw $FFFC
ex13HitboxyDisp:
	dw $FFFC
ex14HitboxyDisp:
	dw $FFFC,$0000
ex15HitboxyDisp:
	dw $FFFC,$0000
ex16HitboxyDisp:
	dw $FFFC
ex17HitboxyDisp:
	dw $FFFC
ex18HitboxyDisp:
	dw $FFFC
ex19HitboxyDisp:
	dw $0000
ex20HitboxyDisp:
	dw $0000
ex21HitboxyDisp:
	dw $0004
ex22HitboxyDisp:
	dw $FFFF
ex23HitboxyDisp:
	dw $FFFF
ex24HitboxyDisp:
	dw $FFFF
ex25HitboxyDisp:
	dw $FFFF
ex26HitboxyDisp:
	dw $FFFF
ex27HitboxyDisp:
	dw $FFFF
ex28HitboxyDisp:
	dw $FFFF
f1FlipXHitboxyDisp:
	dw $FFFC
f2FlipXHitboxyDisp:
	dw $FFFC
f3FlipXHitboxyDisp:
	dw $FFFC
f4FlipXHitboxyDisp:
	dw $FFFC,$0004
f5FlipXHitboxyDisp:
	dw $0000,$0008
f6FlipXHitboxyDisp:
	dw $0000,$0008
f7FlipXHitboxyDisp:
	dw $0000,$0008
f8FlipXHitboxyDisp:
	dw $0004,$0008
f9FlipXHitboxyDisp:
	dw $0004
f10FlipXHitboxyDisp:
	dw $0004
f11FlipXHitboxyDisp:
	dw $0004,$0004
f12FlipXHitboxyDisp:
	dw $0004,$0004
f13FlipXHitboxyDisp:
	dw $0008,$0000
f14FlipXHitboxyDisp:
	dw $0008,$0000
f15FlipXHitboxyDisp:
	dw $0008,$0000
f16FlipXHitboxyDisp:
	dw $FFFC,$0004
ex1FlipXHitboxyDisp:
	dw $0000,$FFFC
ex2FlipXHitboxyDisp:
	dw $0000,$FFFC
ex3FlipXHitboxyDisp:
	dw $FFFC
ex4FlipXHitboxyDisp:
	dw $FFFC
ex5FlipXHitboxyDisp:
	dw $FFFC
ex6FlipXHitboxyDisp:
	dw $FFFC
ex7FlipXHitboxyDisp:
	dw $FFFC
ex8FlipXHitboxyDisp:
	dw $FFFC
ex9FlipXHitboxyDisp:
	dw $FFFC
ex10FlipXHitboxyDisp:
	dw $FFFC
ex11FlipXHitboxyDisp:
	dw $FFFC
ex12FlipXHitboxyDisp:
	dw $FFFC
ex13FlipXHitboxyDisp:
	dw $FFFC
ex14FlipXHitboxyDisp:
	dw $FFFC,$0000
ex15FlipXHitboxyDisp:
	dw $FFFC,$0000
ex16FlipXHitboxyDisp:
	dw $FFFC
ex17FlipXHitboxyDisp:
	dw $FFFC
ex18FlipXHitboxyDisp:
	dw $FFFC
ex19FlipXHitboxyDisp:
	dw $0000
ex20FlipXHitboxyDisp:
	dw $0000
ex21FlipXHitboxyDisp:
	dw $0004
ex22FlipXHitboxyDisp:
	dw $FFFF
ex23FlipXHitboxyDisp:
	dw $FFFF
ex24FlipXHitboxyDisp:
	dw $FFFF
ex25FlipXHitboxyDisp:
	dw $FFFF
ex26FlipXHitboxyDisp:
	dw $FFFF
ex27FlipXHitboxyDisp:
	dw $FFFF
ex28FlipXHitboxyDisp:
	dw $FFFF
f1FlipYHitboxyDisp:
	dw $FFFE
f2FlipYHitboxyDisp:
	dw $FFFE
f3FlipYHitboxyDisp:
	dw $FFFE
f4FlipYHitboxyDisp:
	dw $0006,$0002
f5FlipYHitboxyDisp:
	dw $0006,$0002
f6FlipYHitboxyDisp:
	dw $0006,$0002
f7FlipYHitboxyDisp:
	dw $0006,$0002
f8FlipYHitboxyDisp:
	dw $0002,$0002
f9FlipYHitboxyDisp:
	dw $0002
f10FlipYHitboxyDisp:
	dw $0002
f11FlipYHitboxyDisp:
	dw $0002,$0006
f12FlipYHitboxyDisp:
	dw $FFFE,$0006
f13FlipYHitboxyDisp:
	dw $FFFE,$0006
f14FlipYHitboxyDisp:
	dw $FFFE,$0006
f15FlipYHitboxyDisp:
	dw $FFFE,$0006
f16FlipYHitboxyDisp:
	dw $FFFE,$FFFE
ex1FlipYHitboxyDisp:
	dw $FFFE,$FFFA
ex2FlipYHitboxyDisp:
	dw $FFFE,$FFFA
ex3FlipYHitboxyDisp:
	dw $FFFA
ex4FlipYHitboxyDisp:
	dw $FFFA
ex5FlipYHitboxyDisp:
	dw $FFFA
ex6FlipYHitboxyDisp:
	dw $FFFA
ex7FlipYHitboxyDisp:
	dw $FFFA
ex8FlipYHitboxyDisp:
	dw $FFFA
ex9FlipYHitboxyDisp:
	dw $FFFA
ex10FlipYHitboxyDisp:
	dw $FFFA
ex11FlipYHitboxyDisp:
	dw $FFFA
ex12FlipYHitboxyDisp:
	dw $FFFA
ex13FlipYHitboxyDisp:
	dw $FFFA
ex14FlipYHitboxyDisp:
	dw $FFFA,$FFFE
ex15FlipYHitboxyDisp:
	dw $FFFA,$FFFE
ex16FlipYHitboxyDisp:
	dw $FFFA
ex17FlipYHitboxyDisp:
	dw $FFFE
ex18FlipYHitboxyDisp:
	dw $FFFE
ex19FlipYHitboxyDisp:
	dw $FFFE
ex20FlipYHitboxyDisp:
	dw $FFFE
ex21FlipYHitboxyDisp:
	dw $FFFE
ex22FlipYHitboxyDisp:
	dw $FFFF
ex23FlipYHitboxyDisp:
	dw $FFFF
ex24FlipYHitboxyDisp:
	dw $FFFF
ex25FlipYHitboxyDisp:
	dw $FFFF
ex26FlipYHitboxyDisp:
	dw $FFFF
ex27FlipYHitboxyDisp:
	dw $FFFF
ex28FlipYHitboxyDisp:
	dw $FFFF
f1FlipXYHitboxyDisp:
	dw $FFFE
f2FlipXYHitboxyDisp:
	dw $FFFE
f3FlipXYHitboxyDisp:
	dw $FFFE
f4FlipXYHitboxyDisp:
	dw $0006,$0002
f5FlipXYHitboxyDisp:
	dw $0006,$0002
f6FlipXYHitboxyDisp:
	dw $0006,$0002
f7FlipXYHitboxyDisp:
	dw $0006,$0002
f8FlipXYHitboxyDisp:
	dw $0002,$0002
f9FlipXYHitboxyDisp:
	dw $0002
f10FlipXYHitboxyDisp:
	dw $0002
f11FlipXYHitboxyDisp:
	dw $0002,$0006
f12FlipXYHitboxyDisp:
	dw $FFFE,$0006
f13FlipXYHitboxyDisp:
	dw $FFFE,$0006
f14FlipXYHitboxyDisp:
	dw $FFFE,$0006
f15FlipXYHitboxyDisp:
	dw $FFFE,$0006
f16FlipXYHitboxyDisp:
	dw $FFFE,$FFFE
ex1FlipXYHitboxyDisp:
	dw $FFFE,$FFFA
ex2FlipXYHitboxyDisp:
	dw $FFFE,$FFFA
ex3FlipXYHitboxyDisp:
	dw $FFFA
ex4FlipXYHitboxyDisp:
	dw $FFFA
ex5FlipXYHitboxyDisp:
	dw $FFFA
ex6FlipXYHitboxyDisp:
	dw $FFFA
ex7FlipXYHitboxyDisp:
	dw $FFFA
ex8FlipXYHitboxyDisp:
	dw $FFFA
ex9FlipXYHitboxyDisp:
	dw $FFFA
ex10FlipXYHitboxyDisp:
	dw $FFFA
ex11FlipXYHitboxyDisp:
	dw $FFFA
ex12FlipXYHitboxyDisp:
	dw $FFFA
ex13FlipXYHitboxyDisp:
	dw $FFFA
ex14FlipXYHitboxyDisp:
	dw $FFFA,$FFFE
ex15FlipXYHitboxyDisp:
	dw $FFFA,$FFFE
ex16FlipXYHitboxyDisp:
	dw $FFFA
ex17FlipXYHitboxyDisp:
	dw $FFFE
ex18FlipXYHitboxyDisp:
	dw $FFFE
ex19FlipXYHitboxyDisp:
	dw $FFFE
ex20FlipXYHitboxyDisp:
	dw $FFFE
ex21FlipXYHitboxyDisp:
	dw $FFFE
ex22FlipXYHitboxyDisp:
	dw $FFFF
ex23FlipXYHitboxyDisp:
	dw $FFFF
ex24FlipXYHitboxyDisp:
	dw $FFFF
ex25FlipXYHitboxyDisp:
	dw $FFFF
ex26FlipXYHitboxyDisp:
	dw $FFFF
ex27FlipXYHitboxyDisp:
	dw $FFFF
ex28FlipXYHitboxyDisp:
	dw $FFFF


FramesHitboxWidth:
f1HitboxWith:
	dw $0008
f2HitboxWith:
	dw $0008
f3HitboxWith:
	dw $0008
f4HitboxWith:
	dw $0008,$0004
f5HitboxWith:
	dw $0008,$0004
f6HitboxWith:
	dw $0008,$0008
f7HitboxWith:
	dw $0008,$0008
f8HitboxWith:
	dw $0008,$0008
f9HitboxWith:
	dw $0010
f10HitboxWith:
	dw $0010
f11HitboxWith:
	dw $0008,$0008
f12HitboxWith:
	dw $0008,$0008
f13HitboxWith:
	dw $0008,$0008
f14HitboxWith:
	dw $000C,$0004
f15HitboxWith:
	dw $000C,$0004
f16HitboxWith:
	dw $0004,$0004
ex1HitboxWith:
	dw $0018,$0010
ex2HitboxWith:
	dw $0018,$0010
ex3HitboxWith:
	dw $0010
ex4HitboxWith:
	dw $0010
ex5HitboxWith:
	dw $0018
ex6HitboxWith:
	dw $0014
ex7HitboxWith:
	dw $0014
ex8HitboxWith:
	dw $0018
ex9HitboxWith:
	dw $0018
ex10HitboxWith:
	dw $0018
ex11HitboxWith:
	dw $0018
ex12HitboxWith:
	dw $0018
ex13HitboxWith:
	dw $0014
ex14HitboxWith:
	dw $0010,$0014
ex15HitboxWith:
	dw $0010,$0014
ex16HitboxWith:
	dw $0010
ex17HitboxWith:
	dw $0010
ex18HitboxWith:
	dw $0010
ex19HitboxWith:
	dw $0010
ex20HitboxWith:
	dw $0010
ex21HitboxWith:
	dw $0014
ex22HitboxWith:
	dw $FFFF
ex23HitboxWith:
	dw $FFFF
ex24HitboxWith:
	dw $FFFF
ex25HitboxWith:
	dw $FFFF
ex26HitboxWith:
	dw $FFFF
ex27HitboxWith:
	dw $FFFF
ex28HitboxWith:
	dw $FFFF
f1FlipXHitboxWith:
	dw $0008
f2FlipXHitboxWith:
	dw $0008
f3FlipXHitboxWith:
	dw $0008
f4FlipXHitboxWith:
	dw $0008,$0004
f5FlipXHitboxWith:
	dw $0008,$0004
f6FlipXHitboxWith:
	dw $0008,$0008
f7FlipXHitboxWith:
	dw $0008,$0008
f8FlipXHitboxWith:
	dw $0008,$0008
f9FlipXHitboxWith:
	dw $0010
f10FlipXHitboxWith:
	dw $0010
f11FlipXHitboxWith:
	dw $0008,$0008
f12FlipXHitboxWith:
	dw $0008,$0008
f13FlipXHitboxWith:
	dw $0008,$0008
f14FlipXHitboxWith:
	dw $000C,$0004
f15FlipXHitboxWith:
	dw $000C,$0004
f16FlipXHitboxWith:
	dw $0004,$0004
ex1FlipXHitboxWith:
	dw $0018,$0010
ex2FlipXHitboxWith:
	dw $0018,$0010
ex3FlipXHitboxWith:
	dw $0010
ex4FlipXHitboxWith:
	dw $0010
ex5FlipXHitboxWith:
	dw $0018
ex6FlipXHitboxWith:
	dw $0014
ex7FlipXHitboxWith:
	dw $0014
ex8FlipXHitboxWith:
	dw $0018
ex9FlipXHitboxWith:
	dw $0018
ex10FlipXHitboxWith:
	dw $0018
ex11FlipXHitboxWith:
	dw $0018
ex12FlipXHitboxWith:
	dw $0018
ex13FlipXHitboxWith:
	dw $0014
ex14FlipXHitboxWith:
	dw $0010,$0014
ex15FlipXHitboxWith:
	dw $0010,$0014
ex16FlipXHitboxWith:
	dw $0010
ex17FlipXHitboxWith:
	dw $0010
ex18FlipXHitboxWith:
	dw $0010
ex19FlipXHitboxWith:
	dw $0010
ex20FlipXHitboxWith:
	dw $0010
ex21FlipXHitboxWith:
	dw $0014
ex22FlipXHitboxWith:
	dw $FFFF
ex23FlipXHitboxWith:
	dw $FFFF
ex24FlipXHitboxWith:
	dw $FFFF
ex25FlipXHitboxWith:
	dw $FFFF
ex26FlipXHitboxWith:
	dw $FFFF
ex27FlipXHitboxWith:
	dw $FFFF
ex28FlipXHitboxWith:
	dw $FFFF
f1FlipYHitboxWith:
	dw $0008
f2FlipYHitboxWith:
	dw $0008
f3FlipYHitboxWith:
	dw $0008
f4FlipYHitboxWith:
	dw $0008,$0004
f5FlipYHitboxWith:
	dw $0008,$0004
f6FlipYHitboxWith:
	dw $0008,$0008
f7FlipYHitboxWith:
	dw $0008,$0008
f8FlipYHitboxWith:
	dw $0008,$0008
f9FlipYHitboxWith:
	dw $0010
f10FlipYHitboxWith:
	dw $0010
f11FlipYHitboxWith:
	dw $0008,$0008
f12FlipYHitboxWith:
	dw $0008,$0008
f13FlipYHitboxWith:
	dw $0008,$0008
f14FlipYHitboxWith:
	dw $000C,$0004
f15FlipYHitboxWith:
	dw $000C,$0004
f16FlipYHitboxWith:
	dw $0004,$0004
ex1FlipYHitboxWith:
	dw $0018,$0010
ex2FlipYHitboxWith:
	dw $0018,$0010
ex3FlipYHitboxWith:
	dw $0010
ex4FlipYHitboxWith:
	dw $0010
ex5FlipYHitboxWith:
	dw $0018
ex6FlipYHitboxWith:
	dw $0014
ex7FlipYHitboxWith:
	dw $0014
ex8FlipYHitboxWith:
	dw $0018
ex9FlipYHitboxWith:
	dw $0018
ex10FlipYHitboxWith:
	dw $0018
ex11FlipYHitboxWith:
	dw $0018
ex12FlipYHitboxWith:
	dw $0018
ex13FlipYHitboxWith:
	dw $0014
ex14FlipYHitboxWith:
	dw $0010,$0014
ex15FlipYHitboxWith:
	dw $0010,$0014
ex16FlipYHitboxWith:
	dw $0010
ex17FlipYHitboxWith:
	dw $0010
ex18FlipYHitboxWith:
	dw $0010
ex19FlipYHitboxWith:
	dw $0010
ex20FlipYHitboxWith:
	dw $0010
ex21FlipYHitboxWith:
	dw $0014
ex22FlipYHitboxWith:
	dw $FFFF
ex23FlipYHitboxWith:
	dw $FFFF
ex24FlipYHitboxWith:
	dw $FFFF
ex25FlipYHitboxWith:
	dw $FFFF
ex26FlipYHitboxWith:
	dw $FFFF
ex27FlipYHitboxWith:
	dw $FFFF
ex28FlipYHitboxWith:
	dw $FFFF
f1FlipXYHitboxWith:
	dw $0008
f2FlipXYHitboxWith:
	dw $0008
f3FlipXYHitboxWith:
	dw $0008
f4FlipXYHitboxWith:
	dw $0008,$0004
f5FlipXYHitboxWith:
	dw $0008,$0004
f6FlipXYHitboxWith:
	dw $0008,$0008
f7FlipXYHitboxWith:
	dw $0008,$0008
f8FlipXYHitboxWith:
	dw $0008,$0008
f9FlipXYHitboxWith:
	dw $0010
f10FlipXYHitboxWith:
	dw $0010
f11FlipXYHitboxWith:
	dw $0008,$0008
f12FlipXYHitboxWith:
	dw $0008,$0008
f13FlipXYHitboxWith:
	dw $0008,$0008
f14FlipXYHitboxWith:
	dw $000C,$0004
f15FlipXYHitboxWith:
	dw $000C,$0004
f16FlipXYHitboxWith:
	dw $0004,$0004
ex1FlipXYHitboxWith:
	dw $0018,$0010
ex2FlipXYHitboxWith:
	dw $0018,$0010
ex3FlipXYHitboxWith:
	dw $0010
ex4FlipXYHitboxWith:
	dw $0010
ex5FlipXYHitboxWith:
	dw $0018
ex6FlipXYHitboxWith:
	dw $0014
ex7FlipXYHitboxWith:
	dw $0014
ex8FlipXYHitboxWith:
	dw $0018
ex9FlipXYHitboxWith:
	dw $0018
ex10FlipXYHitboxWith:
	dw $0018
ex11FlipXYHitboxWith:
	dw $0018
ex12FlipXYHitboxWith:
	dw $0018
ex13FlipXYHitboxWith:
	dw $0014
ex14FlipXYHitboxWith:
	dw $0010,$0014
ex15FlipXYHitboxWith:
	dw $0010,$0014
ex16FlipXYHitboxWith:
	dw $0010
ex17FlipXYHitboxWith:
	dw $0010
ex18FlipXYHitboxWith:
	dw $0010
ex19FlipXYHitboxWith:
	dw $0010
ex20FlipXYHitboxWith:
	dw $0010
ex21FlipXYHitboxWith:
	dw $0014
ex22FlipXYHitboxWith:
	dw $FFFF
ex23FlipXYHitboxWith:
	dw $FFFF
ex24FlipXYHitboxWith:
	dw $FFFF
ex25FlipXYHitboxWith:
	dw $FFFF
ex26FlipXYHitboxWith:
	dw $FFFF
ex27FlipXYHitboxWith:
	dw $FFFF
ex28FlipXYHitboxWith:
	dw $FFFF


FramesHitboxHeigth:
f1HitboxHeigth:
	dw $0014
f2HitboxHeigth:
	dw $0014
f3HitboxHeigth:
	dw $0014
f4HitboxHeigth:
	dw $000C,$0008
f5HitboxHeigth:
	dw $0008,$0004
f6HitboxHeigth:
	dw $0008,$0004
f7HitboxHeigth:
	dw $0008,$0004
f8HitboxHeigth:
	dw $0008,$0004
f9HitboxHeigth:
	dw $0008
f10HitboxHeigth:
	dw $0008
f11HitboxHeigth:
	dw $0008,$0004
f12HitboxHeigth:
	dw $000C,$0004
f13HitboxHeigth:
	dw $0008,$0008
f14HitboxHeigth:
	dw $0008,$0008
f15HitboxHeigth:
	dw $0008,$0008
f16HitboxHeigth:
	dw $0014,$000C
ex1HitboxHeigth:
	dw $0010,$0018
ex2HitboxHeigth:
	dw $0010,$0018
ex3HitboxHeigth:
	dw $0018
ex4HitboxHeigth:
	dw $0018
ex5HitboxHeigth:
	dw $0018
ex6HitboxHeigth:
	dw $0018
ex7HitboxHeigth:
	dw $0018
ex8HitboxHeigth:
	dw $0018
ex9HitboxHeigth:
	dw $0018
ex10HitboxHeigth:
	dw $0018
ex11HitboxHeigth:
	dw $0018
ex12HitboxHeigth:
	dw $0018
ex13HitboxHeigth:
	dw $0018
ex14HitboxHeigth:
	dw $0018,$0010
ex15HitboxHeigth:
	dw $0018,$0010
ex16HitboxHeigth:
	dw $0018
ex17HitboxHeigth:
	dw $0014
ex18HitboxHeigth:
	dw $0014
ex19HitboxHeigth:
	dw $0010
ex20HitboxHeigth:
	dw $0010
ex21HitboxHeigth:
	dw $000C
ex22HitboxHeigth:
	dw $FFFF
ex23HitboxHeigth:
	dw $FFFF
ex24HitboxHeigth:
	dw $FFFF
ex25HitboxHeigth:
	dw $FFFF
ex26HitboxHeigth:
	dw $FFFF
ex27HitboxHeigth:
	dw $FFFF
ex28HitboxHeigth:
	dw $FFFF
f1FlipXHitboxHeigth:
	dw $0014
f2FlipXHitboxHeigth:
	dw $0014
f3FlipXHitboxHeigth:
	dw $0014
f4FlipXHitboxHeigth:
	dw $000C,$0008
f5FlipXHitboxHeigth:
	dw $0008,$0004
f6FlipXHitboxHeigth:
	dw $0008,$0004
f7FlipXHitboxHeigth:
	dw $0008,$0004
f8FlipXHitboxHeigth:
	dw $0008,$0004
f9FlipXHitboxHeigth:
	dw $0008
f10FlipXHitboxHeigth:
	dw $0008
f11FlipXHitboxHeigth:
	dw $0008,$0004
f12FlipXHitboxHeigth:
	dw $000C,$0004
f13FlipXHitboxHeigth:
	dw $0008,$0008
f14FlipXHitboxHeigth:
	dw $0008,$0008
f15FlipXHitboxHeigth:
	dw $0008,$0008
f16FlipXHitboxHeigth:
	dw $0014,$000C
ex1FlipXHitboxHeigth:
	dw $0010,$0018
ex2FlipXHitboxHeigth:
	dw $0010,$0018
ex3FlipXHitboxHeigth:
	dw $0018
ex4FlipXHitboxHeigth:
	dw $0018
ex5FlipXHitboxHeigth:
	dw $0018
ex6FlipXHitboxHeigth:
	dw $0018
ex7FlipXHitboxHeigth:
	dw $0018
ex8FlipXHitboxHeigth:
	dw $0018
ex9FlipXHitboxHeigth:
	dw $0018
ex10FlipXHitboxHeigth:
	dw $0018
ex11FlipXHitboxHeigth:
	dw $0018
ex12FlipXHitboxHeigth:
	dw $0018
ex13FlipXHitboxHeigth:
	dw $0018
ex14FlipXHitboxHeigth:
	dw $0018,$0010
ex15FlipXHitboxHeigth:
	dw $0018,$0010
ex16FlipXHitboxHeigth:
	dw $0018
ex17FlipXHitboxHeigth:
	dw $0014
ex18FlipXHitboxHeigth:
	dw $0014
ex19FlipXHitboxHeigth:
	dw $0010
ex20FlipXHitboxHeigth:
	dw $0010
ex21FlipXHitboxHeigth:
	dw $000C
ex22FlipXHitboxHeigth:
	dw $FFFF
ex23FlipXHitboxHeigth:
	dw $FFFF
ex24FlipXHitboxHeigth:
	dw $FFFF
ex25FlipXHitboxHeigth:
	dw $FFFF
ex26FlipXHitboxHeigth:
	dw $FFFF
ex27FlipXHitboxHeigth:
	dw $FFFF
ex28FlipXHitboxHeigth:
	dw $FFFF
f1FlipYHitboxHeigth:
	dw $0014
f2FlipYHitboxHeigth:
	dw $0014
f3FlipYHitboxHeigth:
	dw $0014
f4FlipYHitboxHeigth:
	dw $000C,$0008
f5FlipYHitboxHeigth:
	dw $0008,$0004
f6FlipYHitboxHeigth:
	dw $0008,$0004
f7FlipYHitboxHeigth:
	dw $0008,$0004
f8FlipYHitboxHeigth:
	dw $0008,$0004
f9FlipYHitboxHeigth:
	dw $0008
f10FlipYHitboxHeigth:
	dw $0008
f11FlipYHitboxHeigth:
	dw $0008,$0004
f12FlipYHitboxHeigth:
	dw $000C,$0004
f13FlipYHitboxHeigth:
	dw $0008,$0008
f14FlipYHitboxHeigth:
	dw $0008,$0008
f15FlipYHitboxHeigth:
	dw $0008,$0008
f16FlipYHitboxHeigth:
	dw $0014,$000C
ex1FlipYHitboxHeigth:
	dw $0010,$0018
ex2FlipYHitboxHeigth:
	dw $0010,$0018
ex3FlipYHitboxHeigth:
	dw $0018
ex4FlipYHitboxHeigth:
	dw $0018
ex5FlipYHitboxHeigth:
	dw $0018
ex6FlipYHitboxHeigth:
	dw $0018
ex7FlipYHitboxHeigth:
	dw $0018
ex8FlipYHitboxHeigth:
	dw $0018
ex9FlipYHitboxHeigth:
	dw $0018
ex10FlipYHitboxHeigth:
	dw $0018
ex11FlipYHitboxHeigth:
	dw $0018
ex12FlipYHitboxHeigth:
	dw $0018
ex13FlipYHitboxHeigth:
	dw $0018
ex14FlipYHitboxHeigth:
	dw $0018,$0010
ex15FlipYHitboxHeigth:
	dw $0018,$0010
ex16FlipYHitboxHeigth:
	dw $0018
ex17FlipYHitboxHeigth:
	dw $0014
ex18FlipYHitboxHeigth:
	dw $0014
ex19FlipYHitboxHeigth:
	dw $0010
ex20FlipYHitboxHeigth:
	dw $0010
ex21FlipYHitboxHeigth:
	dw $000C
ex22FlipYHitboxHeigth:
	dw $FFFF
ex23FlipYHitboxHeigth:
	dw $FFFF
ex24FlipYHitboxHeigth:
	dw $FFFF
ex25FlipYHitboxHeigth:
	dw $FFFF
ex26FlipYHitboxHeigth:
	dw $FFFF
ex27FlipYHitboxHeigth:
	dw $FFFF
ex28FlipYHitboxHeigth:
	dw $FFFF
f1FlipXYHitboxHeigth:
	dw $0014
f2FlipXYHitboxHeigth:
	dw $0014
f3FlipXYHitboxHeigth:
	dw $0014
f4FlipXYHitboxHeigth:
	dw $000C,$0008
f5FlipXYHitboxHeigth:
	dw $0008,$0004
f6FlipXYHitboxHeigth:
	dw $0008,$0004
f7FlipXYHitboxHeigth:
	dw $0008,$0004
f8FlipXYHitboxHeigth:
	dw $0008,$0004
f9FlipXYHitboxHeigth:
	dw $0008
f10FlipXYHitboxHeigth:
	dw $0008
f11FlipXYHitboxHeigth:
	dw $0008,$0004
f12FlipXYHitboxHeigth:
	dw $000C,$0004
f13FlipXYHitboxHeigth:
	dw $0008,$0008
f14FlipXYHitboxHeigth:
	dw $0008,$0008
f15FlipXYHitboxHeigth:
	dw $0008,$0008
f16FlipXYHitboxHeigth:
	dw $0014,$000C
ex1FlipXYHitboxHeigth:
	dw $0010,$0018
ex2FlipXYHitboxHeigth:
	dw $0010,$0018
ex3FlipXYHitboxHeigth:
	dw $0018
ex4FlipXYHitboxHeigth:
	dw $0018
ex5FlipXYHitboxHeigth:
	dw $0018
ex6FlipXYHitboxHeigth:
	dw $0018
ex7FlipXYHitboxHeigth:
	dw $0018
ex8FlipXYHitboxHeigth:
	dw $0018
ex9FlipXYHitboxHeigth:
	dw $0018
ex10FlipXYHitboxHeigth:
	dw $0018
ex11FlipXYHitboxHeigth:
	dw $0018
ex12FlipXYHitboxHeigth:
	dw $0018
ex13FlipXYHitboxHeigth:
	dw $0018
ex14FlipXYHitboxHeigth:
	dw $0018,$0010
ex15FlipXYHitboxHeigth:
	dw $0018,$0010
ex16FlipXYHitboxHeigth:
	dw $0018
ex17FlipXYHitboxHeigth:
	dw $0014
ex18FlipXYHitboxHeigth:
	dw $0014
ex19FlipXYHitboxHeigth:
	dw $0010
ex20FlipXYHitboxHeigth:
	dw $0010
ex21FlipXYHitboxHeigth:
	dw $000C
ex22FlipXYHitboxHeigth:
	dw $FFFF
ex23FlipXYHitboxHeigth:
	dw $FFFF
ex24FlipXYHitboxHeigth:
	dw $FFFF
ex25FlipXYHitboxHeigth:
	dw $FFFF
ex26FlipXYHitboxHeigth:
	dw $FFFF
ex27FlipXYHitboxHeigth:
	dw $FFFF
ex28FlipXYHitboxHeigth:
	dw $FFFF


FramesHitboxAction:
f1HitboxAction:
	dw hurt
f2HitboxAction:
	dw hurt
f3HitboxAction:
	dw hurt
f4HitboxAction:
	dw hurt,hurt
f5HitboxAction:
	dw hurt,hurt
f6HitboxAction:
	dw hurt,hurt
f7HitboxAction:
	dw hurt,hurt
f8HitboxAction:
	dw hurt,hurt
f9HitboxAction:
	dw hurt
f10HitboxAction:
	dw hurt
f11HitboxAction:
	dw hurt,hurt
f12HitboxAction:
	dw hurt,hurt
f13HitboxAction:
	dw hurt,hurt
f14HitboxAction:
	dw hurt,hurt
f15HitboxAction:
	dw hurt,hurt
f16HitboxAction:
	dw hurt,hurt
ex1HitboxAction:
	dw hurt,hurt
ex2HitboxAction:
	dw hurt,hurt
ex3HitboxAction:
	dw hurt
ex4HitboxAction:
	dw hurt
ex5HitboxAction:
	dw hurt
ex6HitboxAction:
	dw hurt
ex7HitboxAction:
	dw hurt
ex8HitboxAction:
	dw hurt
ex9HitboxAction:
	dw hurt
ex10HitboxAction:
	dw hurt
ex11HitboxAction:
	dw hurt
ex12HitboxAction:
	dw hurt
ex13HitboxAction:
	dw hurt
ex14HitboxAction:
	dw hurt,hurt
ex15HitboxAction:
	dw hurt,hurt
ex16HitboxAction:
	dw hurt
ex17HitboxAction:
	dw hurt
ex18HitboxAction:
	dw hurt
ex19HitboxAction:
	dw hurt
ex20HitboxAction:
	dw hurt
ex21HitboxAction:
	dw hurt
ex22HitboxAction:
	dw $FFFF
ex23HitboxAction:
	dw $FFFF
ex24HitboxAction:
	dw $FFFF
ex25HitboxAction:
	dw $FFFF
ex26HitboxAction:
	dw $FFFF
ex27HitboxAction:
	dw $FFFF
ex28HitboxAction:
	dw $FFFF
f1FlipXHitboxAction:
	dw hurt
f2FlipXHitboxAction:
	dw hurt
f3FlipXHitboxAction:
	dw hurt
f4FlipXHitboxAction:
	dw hurt,hurt
f5FlipXHitboxAction:
	dw hurt,hurt
f6FlipXHitboxAction:
	dw hurt,hurt
f7FlipXHitboxAction:
	dw hurt,hurt
f8FlipXHitboxAction:
	dw hurt,hurt
f9FlipXHitboxAction:
	dw hurt
f10FlipXHitboxAction:
	dw hurt
f11FlipXHitboxAction:
	dw hurt,hurt
f12FlipXHitboxAction:
	dw hurt,hurt
f13FlipXHitboxAction:
	dw hurt,hurt
f14FlipXHitboxAction:
	dw hurt,hurt
f15FlipXHitboxAction:
	dw hurt,hurt
f16FlipXHitboxAction:
	dw hurt,hurt
ex1FlipXHitboxAction:
	dw hurt,hurt
ex2FlipXHitboxAction:
	dw hurt,hurt
ex3FlipXHitboxAction:
	dw hurt
ex4FlipXHitboxAction:
	dw hurt
ex5FlipXHitboxAction:
	dw hurt
ex6FlipXHitboxAction:
	dw hurt
ex7FlipXHitboxAction:
	dw hurt
ex8FlipXHitboxAction:
	dw hurt
ex9FlipXHitboxAction:
	dw hurt
ex10FlipXHitboxAction:
	dw hurt
ex11FlipXHitboxAction:
	dw hurt
ex12FlipXHitboxAction:
	dw hurt
ex13FlipXHitboxAction:
	dw hurt
ex14FlipXHitboxAction:
	dw hurt,hurt
ex15FlipXHitboxAction:
	dw hurt,hurt
ex16FlipXHitboxAction:
	dw hurt
ex17FlipXHitboxAction:
	dw hurt
ex18FlipXHitboxAction:
	dw hurt
ex19FlipXHitboxAction:
	dw hurt
ex20FlipXHitboxAction:
	dw hurt
ex21FlipXHitboxAction:
	dw hurt
ex22FlipXHitboxAction:
	dw $FFFF
ex23FlipXHitboxAction:
	dw $FFFF
ex24FlipXHitboxAction:
	dw $FFFF
ex25FlipXHitboxAction:
	dw $FFFF
ex26FlipXHitboxAction:
	dw $FFFF
ex27FlipXHitboxAction:
	dw $FFFF
ex28FlipXHitboxAction:
	dw $FFFF
f1FlipYHitboxAction:
	dw hurt
f2FlipYHitboxAction:
	dw hurt
f3FlipYHitboxAction:
	dw hurt
f4FlipYHitboxAction:
	dw hurt,hurt
f5FlipYHitboxAction:
	dw hurt,hurt
f6FlipYHitboxAction:
	dw hurt,hurt
f7FlipYHitboxAction:
	dw hurt,hurt
f8FlipYHitboxAction:
	dw hurt,hurt
f9FlipYHitboxAction:
	dw hurt
f10FlipYHitboxAction:
	dw hurt
f11FlipYHitboxAction:
	dw hurt,hurt
f12FlipYHitboxAction:
	dw hurt,hurt
f13FlipYHitboxAction:
	dw hurt,hurt
f14FlipYHitboxAction:
	dw hurt,hurt
f15FlipYHitboxAction:
	dw hurt,hurt
f16FlipYHitboxAction:
	dw hurt,hurt
ex1FlipYHitboxAction:
	dw hurt,hurt
ex2FlipYHitboxAction:
	dw hurt,hurt
ex3FlipYHitboxAction:
	dw hurt
ex4FlipYHitboxAction:
	dw hurt
ex5FlipYHitboxAction:
	dw hurt
ex6FlipYHitboxAction:
	dw hurt
ex7FlipYHitboxAction:
	dw hurt
ex8FlipYHitboxAction:
	dw hurt
ex9FlipYHitboxAction:
	dw hurt
ex10FlipYHitboxAction:
	dw hurt
ex11FlipYHitboxAction:
	dw hurt
ex12FlipYHitboxAction:
	dw hurt
ex13FlipYHitboxAction:
	dw hurt
ex14FlipYHitboxAction:
	dw hurt,hurt
ex15FlipYHitboxAction:
	dw hurt,hurt
ex16FlipYHitboxAction:
	dw hurt
ex17FlipYHitboxAction:
	dw hurt
ex18FlipYHitboxAction:
	dw hurt
ex19FlipYHitboxAction:
	dw hurt
ex20FlipYHitboxAction:
	dw hurt
ex21FlipYHitboxAction:
	dw hurt
ex22FlipYHitboxAction:
	dw $FFFF
ex23FlipYHitboxAction:
	dw $FFFF
ex24FlipYHitboxAction:
	dw $FFFF
ex25FlipYHitboxAction:
	dw $FFFF
ex26FlipYHitboxAction:
	dw $FFFF
ex27FlipYHitboxAction:
	dw $FFFF
ex28FlipYHitboxAction:
	dw $FFFF
f1FlipXYHitboxAction:
	dw hurt
f2FlipXYHitboxAction:
	dw hurt
f3FlipXYHitboxAction:
	dw hurt
f4FlipXYHitboxAction:
	dw hurt,hurt
f5FlipXYHitboxAction:
	dw hurt,hurt
f6FlipXYHitboxAction:
	dw hurt,hurt
f7FlipXYHitboxAction:
	dw hurt,hurt
f8FlipXYHitboxAction:
	dw hurt,hurt
f9FlipXYHitboxAction:
	dw hurt
f10FlipXYHitboxAction:
	dw hurt
f11FlipXYHitboxAction:
	dw hurt,hurt
f12FlipXYHitboxAction:
	dw hurt,hurt
f13FlipXYHitboxAction:
	dw hurt,hurt
f14FlipXYHitboxAction:
	dw hurt,hurt
f15FlipXYHitboxAction:
	dw hurt,hurt
f16FlipXYHitboxAction:
	dw hurt,hurt
ex1FlipXYHitboxAction:
	dw hurt,hurt
ex2FlipXYHitboxAction:
	dw hurt,hurt
ex3FlipXYHitboxAction:
	dw hurt
ex4FlipXYHitboxAction:
	dw hurt
ex5FlipXYHitboxAction:
	dw hurt
ex6FlipXYHitboxAction:
	dw hurt
ex7FlipXYHitboxAction:
	dw hurt
ex8FlipXYHitboxAction:
	dw hurt
ex9FlipXYHitboxAction:
	dw hurt
ex10FlipXYHitboxAction:
	dw hurt
ex11FlipXYHitboxAction:
	dw hurt
ex12FlipXYHitboxAction:
	dw hurt
ex13FlipXYHitboxAction:
	dw hurt
ex14FlipXYHitboxAction:
	dw hurt,hurt
ex15FlipXYHitboxAction:
	dw hurt,hurt
ex16FlipXYHitboxAction:
	dw hurt
ex17FlipXYHitboxAction:
	dw hurt
ex18FlipXYHitboxAction:
	dw hurt
ex19FlipXYHitboxAction:
	dw hurt
ex20FlipXYHitboxAction:
	dw hurt
ex21FlipXYHitboxAction:
	dw hurt
ex22FlipXYHitboxAction:
	dw $FFFF
ex23FlipXYHitboxAction:
	dw $FFFF
ex24FlipXYHitboxAction:
	dw $FFFF
ex25FlipXYHitboxAction:
	dw $FFFF
ex26FlipXYHitboxAction:
	dw $FFFF
ex27FlipXYHitboxAction:
	dw $FFFF
ex28FlipXYHitboxAction:
	dw $FFFF


;===================================
;Dynamic Routine
;===================================
VramTable:
	dw $0000,$0100,$0400,$0500,$0800,$0900,$0C00,$0D00,$1000,$1100,$1400,$1500,$1800,$1900,$1C00,$1D00,$2000,$2100,$2400,$2500,$2800,$2900,$2C00,$2D00,$3000,$3100,$3400,$3500,$3800,$3900,$3C00,$3D00,$4000,$4100,$4400,$4500,$4800,$4900,$4C00,$4D00,$5000,$5100,$5400,$5500

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
	
	JSL !DynamicRoutine32Start
	
	LDA !FramePointer
	ASL
	TAY 
	
	PHX
	LDX $3000
	
	PHB
	PLA
	STA !dynSpBnk,x ;set the BNK of the graphics
	STA !dynSpBnk-$04,x
	LDA #$00
	STA !dynSpBnk+$01,x
	STA !dynSpBnk-$03,x

	REP #$20
	
	LDA VramTable,y
	CMP #$FFFF
	BEQ +	
	CLC
	ADC GFXPointer ;get the graphic pointer to the current frame
	STA !dynSpRec,x
	CLC
	ADC #$0200
	STA !dynSpRec-$04,x
	
	LDA #$0100
	STA !dynSpLength,x
	STA !dynSpLength-$04,x
	
	SEP #$20
	
	TXA 
	SEC
	SBC #$04
	STA !nextDynSlot,x
	LDA #$00
	STA !nextDynSlot+$01,x
	LDA #$FF
	STA !nextDynSlot-$04,x
	STA !nextDynSlot-$03,x
	
	SEP #$20
	PLX
	RTS
+
	SEP #$20
	PLX
.ret
	RTS
	
sendSignal:
	LDA !tileRelativePositionNormal,x
	TAY
	
	JSL !Ping32

	RTS

	
adder: db $00,$40,$C0,$20
	
GFXPointer:
dw resource

;fill this with the name of your exgfx (replace "resource.bin" for the name of your graphic.bin)
resource:
incbin sprites\grenade.bin

