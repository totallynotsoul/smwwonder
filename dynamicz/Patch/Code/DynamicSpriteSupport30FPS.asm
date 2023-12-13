;#########################################################
;################ Dynamic Sprites ########################
;#########################################################
;Dynamic Sprites routine
vramSlayer:	dw $7F80,$7F00,$7E80,$7E00,$7D80,$7D00,$7C80,$7C00
			dw $7B80,$7B00,$7A80,$7A00,$7980,$7900,$7880,$7800
			dw $7780,$7700,$7680,$7600,$7580,$7500,$7480,$7400
dynamicSprites:	
	
	LDA !firstSlot
	BMI .ret
	REP #$10
	TAX
.loop
	
	LDA vramSlayer,x
	STA $2116
	
	LDA !dynSpRec,x
	STA $02
	
	LDA !dynSpBnk,x	
	STA $04
	
	LDA !dynSpLength,x
	STA $05
	
	SEP #$10
	STY $420B
	REP #$10
	
	LDA !nextDynSlot,x
	PHA
	LDA #$FFFF
	STA !nextDynSlot,x
	PLX
	
	BPL .loop
+
	SEP #$10
.ret
	RTS