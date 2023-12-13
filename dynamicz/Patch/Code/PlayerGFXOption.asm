;#########################################################
;############# Mario GFX Routine Selection################
;#########################################################
marioGFX:

	SEP #$20

if !FullyCustomPlayerSupport
	LDA !marioCustomGFXOn
	BEQ .normalGFX
	
	JSR customPlayer
	
	RTS
	
.normalGFX
endif

	JSR normalPlayer

	RTS