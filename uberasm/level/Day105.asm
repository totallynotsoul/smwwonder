!FreeRAM_GradBank = $41		;\
!FreeRAM_RedGreen = $1343	; | Just to note: These all belong together. That means, these addresses aren't supposed to be converted if you use SA-1
!FreeRAM_Blue = $1943		;/

!Layer = 1			; The layer in which the HDMA is rooted.
!Offset = $0000		; How much is the table shifted
!ScrollFactor = 0	; The division is exponential, using 2 as its base.
!Number = 1	;which trigger to use. Valid numbers are 0-1F
!Add #= ($!Number&$18)>>$3
!Number #= $!Number-($!Number&$18)
load:
	LDA $7FC0F8+!Add
	ORA #$01<<$!Number
	STA $7FC0F8+!Add
init:
LDA.b #$51	; \ layer 3 tilemap
STA.w $2109	; / 64x32
STZ $24		; \ reset layer 3
STZ $25		; / Vscroll values
	REP #$10
	LDX.w #Gradient
	STX $00
	LDA.b #Gradient>>16
	STA $02
	LDA.b #!FreeRAM_GradBank
	LDX.w #!FreeRAM_RedGreen
	LDY.w #!FreeRAM_Blue

	JSL ScrollHDMA_init
main:
	REP #$20

	LDA #!FreeRAM_RedGreen
	STA $00
	LDA #!FreeRAM_Blue
	STA $02

	LDA $1C+((!Layer-1)<<2)
	CLC : ADC.w #!Offset
	LSR #!ScrollFactor
	JML ScrollHDMA_main

Gradient:
db $07,$2A,$50,$9B
db $01,$2B,$50,$9B
db $18,$2B,$51,$9B
db $0C,$2C,$51,$9B
db $0C,$2C,$52,$9B
db $17,$2D,$52,$9C
db $01,$2D,$53,$9C
db $18,$2E,$53,$9C
db $0A,$2F,$53,$9C
db $0E,$2F,$54,$9D
db $16,$30,$54,$9D
db $03,$30,$55,$9D
db $14,$31,$55,$9D
db $04,$31,$55,$9E
db $08,$32,$55,$9E
db $10,$32,$56,$9E
db $13,$33,$56,$9E
db $02,$32,$56,$9E
db $01,$32,$55,$9E
db $09,$32,$55,$9D
db $04,$31,$54,$9D
db $07,$31,$54,$9C
db $01,$31,$53,$9C
db $06,$30,$53,$9C
db $03,$30,$53,$9B
db $03,$30,$52,$9B
db $07,$2F,$52,$9B
db $01,$2F,$52,$9A
db $04,$2F,$51,$9A
db $06,$2E,$51,$9A
db $03,$2E,$50,$9A
db $03,$2E,$50,$99
db $05,$2D,$50,$99
db $05,$2D,$4F,$99
db $02,$2D,$4F,$98
db $03,$2C,$4F,$98
db $09,$2C,$4E,$98
db $02,$2B,$4E,$97
db $0A,$2B,$4D,$97
db $01,$2A,$4C,$97
db $0A,$2A,$4C,$96
db $01,$2A,$4B,$96
db $03,$29,$4B,$96
db $06,$29,$4B,$95
db $03,$29,$4A,$95
db $04,$28,$4A,$95
db $04,$28,$4A,$94
db $04,$28,$49,$94
db $06,$27,$49,$94
db $06,$27,$48,$93
db $05,$26,$48,$93
db $02,$26,$47,$93
db $04,$26,$47,$92
db $04,$25,$47,$92
db $06,$25,$46,$92
db $02,$25,$46,$91
db $03,$24,$46,$91
db $08,$24,$45,$91
db $01,$24,$45,$90
db $01,$23,$45,$90
db $0B,$23,$44,$90
db $01,$22,$43,$90
db $04,$22,$43,$8F
db $00