!GraphicsToChange = #$0000 ;Here you must put the position into the VRAM that you will change, Look the Tutorial

GraphicChange:

	LDA !GFXNumber
	CMP #$0A
	BCC +
	RTS
+
	INC A
	STA !GFXNumber
	DEC A
	ASL
	TAX

	PHB
	PLA
	STA !GFXBnk,x
	LDA #$00
	STA !GFXBnk+$01,x

	REP #$20
	LDA GFXPointer
	STA !GFXRec,x

	LDA #$0800
	STA !GFXLenght,x

	LDA !GraphicsToChange
	STA !GFXVram,x

	SEP #$20
	RTS

GFXPointer:
dw resource

resource:
incbin AnyGFXOf2kb.bin ;replace this for your GFX name	