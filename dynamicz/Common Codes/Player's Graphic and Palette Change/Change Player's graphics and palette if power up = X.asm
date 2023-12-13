!bnk = #$30; Here put the first 2 digits of the FreeSpace on the patch
!sourcePlus8 = #$8008; Here put the last 8 digits+8 of the FreeSpace on the patch
!powerupId = #$03; Id of the powerUp

ChangePlayerGraphics:

	LDA $19
	CMP !powerupId
	BEQ +
	RTS
+

	LDA #$01
	STA !marioNormalCustomGFXOn

	LDA !bnk
	STA !marioNormalCustomGFXBnk

	REP #$20
	LDA !sourcePlus8
	STA !marioNormalCustomGFXRec
	SEP #$20
	RTS
	
;-------------86..87..88..89..8A..8B..8C..8D..8E..8f
;Fill these tables with the colors.
ColorLow: db $xx,$xx,$xx,$xx,$xx,$xx,$xx,$xx,$xx,$xx
ColorHih: db $xx,$xx,$xx,$xx,$xx,$xx,$xx,$xx,$xx,$xx

ChangeMarioPal:
	LDA $19
	CMP !powerupId
	BEQ +
	RTS
+

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

