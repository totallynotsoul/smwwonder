;#########################################################
;################ Mario Palette ##########################
;#########################################################
marioPalette:
	LDA $0D84|!base2
	BNE +
	RTS
+
	LDA !marioPal
	BNE +

	REP #$20
	LDA $0D82|!base2
	STA $02
	SEP #$20
	STZ $0004|!base1
	LDY #$00
	LDX #$86
-
	STX $2121
	
	LDA [$02],y
	STA $2122
	INY
	LDA [$02],y
	STA $2122
	INY
	INX
	CPX #$90
	BCC -
	
	RTS
+
	LDY #$8F
	LDX #$09
-
	STY $2121
	
	LDA !marioPalLow,x
	STA $2122
	LDA !marioPalHigh,x
	STA $2122
	DEY
	DEX
	BPL -
	RTS