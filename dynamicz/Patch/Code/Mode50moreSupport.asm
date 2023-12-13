;#########################################################
;################# Mode 50% more DMA #####################
;#########################################################
;################### Kill status Bar #####################
killStatus1:
	LDA !mode50
	BEQ +
	STZ $0DC2|!base2
	JML $008E1E|!base3
+
	LDA $1493|!base2
	ORA $9D
	JML $008E1F|!base3
	
killStatus2:
	LDA !mode50
	BEQ +
	JML $008DB0|!base3
+
	STZ $2115
	LDA #$42
	JML $008DB1|!base3
	
killStatus3:
	LDA !mode50
	BNE +
	LDY #$24
	LDA $4211
	JML $008297|!base3
+
	LDA #$00
	STA !mode50 
	PHB : PHK : PLB
	LDA #$00
	STA !mode50
	LDX $0100|!base2
	LDA .allowedModes,x
	BNE .disableIRQ

.defaultIRQ
	PLB
	LDY #$00
	LDA $4211
	JML $008297|!base3

.disableIRQ
	PLB
	LDY #$E0
	LDA $4211
	STY $4209
	STZ $420A
	LDA $0DAE|!base2
	STA $2100
	LDA $0D9F|!base2
	STA $420C
	JML $008394|!base3

.allowedModes
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$01,$00,$00,$00,$01
	db $00,$00,$01,$01,$01,$01,$00,$00
	db $00,$00,$00,$00,$00
	
;################ SP1 Animated Tiles ####################
SP1DMA:
	LDA !mode50
	BEQ +
	JML $00A442|!base3
+
	REP #$20 
	LDY #$80
	STY $2115
	JML $00A445|!base3
	
;#################### kill E3 DMA ########################
killE3:
	LDA !mode50
	BEQ +
	JML $00A50C|!base3
+
	REP #$10
	LDA #$80
	STA $2115
	JML $00A4EA|!base3
	
;################ kill F0 DMA routine ####################
killF0:
	SEP #$20
	LDA !mode50
	BEQ +
	JML $00A435|!base3
+
	REP #$20
	LDA $0D76|!base2
	STA $4322
	JML $00A3F6|!base3
	
hideStatus:
	LDA !mode50
	BNE +
	LDA #$80
	STA $2115 
	JML $008D04|!base3
+
	JML $008D03|!base3