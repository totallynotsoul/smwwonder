	org $008E1A
	JML killStatus1|!base3
	RTS

	org $008DAC
	JML killStatus2|!base3
	RTS

	org $008CFF
	JML hideStatus|!base3
	RTS


	org $008292
	JML killStatus3|!base3
	NOP

	org $00A43E
	JML SP1DMA|!base3
	RTS
	NOP
	NOP

	org $00A4E3
	JML killE3|!base3
	RTS
	NOP
	NOP
	org $00A3F0
	JML killF0|!base3
	NOP
	NOP