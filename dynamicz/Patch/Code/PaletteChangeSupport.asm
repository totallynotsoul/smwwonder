;#########################################################
;################ Palette Change #########################
;#########################################################
paletteChange:
	
	LDA !paletteNumber
	BNE +
	RTS
+
	CMP #$81
	BCC +
	LDA #$80
	STA !paletteNumber
+
	DEC A
	TAX
	DEX
-
	LDA !paletteDestiny,x
	STA $21
	LDA !paletteLow,x
	STA $22
	LDA !paletteHigh,x
	STA $22
	DEX
	BPL -

	LDA #$00
	STA !paletteNumber
RTS