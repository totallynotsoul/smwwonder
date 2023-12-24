!PROPRAM = $06

print "INIT ",pc
RTL

print "MAIN ",pc
PHB
PHK
PLB
JSR Run
PLB
RTL

Run:
%GetDrawInfo()
JSR GFX			;draw sprite       
RTS
;=====

TILEMAP:	db $CA,$CC
db $EA,$EC

XDISP:	db $00,$10
db $00,$10

YDISP:	db $00,$00
db $10,$10

GFX:
LDA !157C,x	;direction...
STA $03

LDA !15F6,x	;properties...
STA !PROPRAM

LDX #$00	;reset OAM

OAM_LOOP:
LDA $00
CLC
ADC XDISP,x
STA $0300|!Base2,y	

LDA $01
CLC
ADC YDISP,x
STA $0301|!Base2,y	

LDA TILEMAP,x
STA $0302|!Base2,y	

LDA !PROPRAM
ORA $64
STA $0303|!Base2,y	

INY #4
INX
CPX #$04	;4 tiles
BNE OAM_LOOP

LDX $15E9|!Base2	;restore sprite index
LDY #$02	;16x16
LDA #$03        ;4 tiles
JSL $01B7B3|!BankB	;reserve

RTS

