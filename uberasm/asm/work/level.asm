!level	= $010B|!addr	;Patches rely on this, changing this is bad. Don't.

ORG $05D8B7
	BRA +
	NOP #3		;the levelnum patch goes here in many ROMs, just skip over it
+
	REP #$30
	LDA $0E		
	STA !level
	ASL		
	CLC		
	ADC $0E		
	TAY		
	LDA.w $E000,Y
	STA $65		
	LDA.w $E001,Y
	STA $66		
	LDA.w $E600,Y
	STA $68		
	LDA.w $E601,Y
	STA $69		
	BRA +
ORG $05D8E0
	+

ORG $00A242
	autoclean JML main
	NOP
	
ORG $00A295
	NOP #4

ORG $00A5EE
        autoclean JML init

freecode

;Editing or moving these tables breaks things. don't.
db "uber"
level_asm_table:
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl $129732
dl null_pointer
dl $129732
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl $12E015
dl $129732
dl $168126
dl $129732
dl $12EEFC
dl null_pointer
dl $12F127
dl $119B42
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer

level_init_table:
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl $129712
dl null_pointer
dl $129712
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl $12DFF5
dl $129712
dl $168029
dl $129712
dl $12EEF6
dl null_pointer
dl $12F107
dl $119B38
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer

level_nmi_table:
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl $168005
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer

level_load_table:
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl $12DFEB
dl null_pointer
dl $168000
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer
dl null_pointer

db "tool"

main:
	PHB
	LDA $13D4|!addr
	BNE +
	JSL $7F8000
+
	REP #$30
	LDA !level
	ASL
	ADC !level
	TAX
	LDA.l level_asm_table,x
	STA $00
	LDA.l level_asm_table+1,x
	JSL run_code		
	PLB
	
	LDA $13D4|!addr
	BEQ +
	JML $00A25B|!bank
+	
	JML $00A28A|!bank

init:
	PHB
	LDA !level
	ASL
	ADC !level
	TAX
	LDA.l level_init_table,x
	STA $00
	LDA.l level_init_table+1,x
	JSL run_code
	PLB
	
        PHK
        PEA.w .return-1
        PEA $84CE
        JML $00919B|!bank
.return
	JML $00A5F3|!bank
	
run_code:
	STA $01
	PHA
	PLB
	PLB
	SEP #$30
	JML [!dp]
	
null_pointer:
	RTL
