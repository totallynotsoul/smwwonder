;#########################################################
;################ ExGFX Change ###########################
;#########################################################

maxLengh: dw $0801,$0C01

ExGfxChange:
	SEP #$20
	
if !Mode50moreSupport
	LDA !mode50
	ASL
	TAX
	REP #$20
	LDA maxLengh,x
	STA $0002|!base1
	SEP #$20
endif
	
	LDA !GFXNumber ;load the number of gfx changes on X
	BNE +
	REP #$20
	RTS
+
	CMP #$0B
	BCC +
	LDA #$0A
	STA !GFXNumber
+
	DEC A
	ASL
	TAX
	
	REP #$20
	LDA #$0000
	STA $0000|!base1
	
.loop
	LDA !GFXBnk,x
	STA $04
	
	LDA !GFXLenght,x
	STA $05
	CLC
	ADC $0000|!base1
	CMP $0002|!base1
	STA $0000|!base1
	BCS +
	
	LDA !GFXRec,x
	STA $02
	
	LDA !GFXVram,x
	STA $2116
	
	LDY #$01
	STY $420B
	
	DEX
	DEX
	BPL .loop
+
	SEP #$20
	TXA
	LSR
	INC A
	STA !GFXNumber
	CMP #$0B
	BCC .ret
	LDA #$00
	STA !GFXNumber
.ret
	REP #$20
	RTS