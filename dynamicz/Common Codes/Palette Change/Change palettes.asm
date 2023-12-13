ColorDestiny:	db $xx,$xx,$xx,$xx,$xx,$xx… ;replace this table
ColorLowByte:	db $xx,$xx,$xx,$xx,$xx,$xx… ;replace this table
ColorHihByte:	db $xx,$xx,$xx,$xx,$xx,$xx… ;replace this table
PaletteChange:

	LDA !paletteNumber
	STA $00
	CLC
	ADC #$numberOfColors-1 ;putthe number of colors that you will change-1
	CMP #$80
	BCC +
	RTS
+
	STA !paletteNumber
	DEC A
	TAX
	LDY #$numberOfColors-1 ;putthe number of colors that you will change-1
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
