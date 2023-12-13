speed:
    dw -$0040,$0040

; How fast the speed increases in each phase (going up, going down)
; The two values should be equal (but opposite) or the camera will
; drift away after enough cycles.
acceleration:
    dw -$0001,$0001

; Addresses defines
!phase_addr    = $1443|!addr
!position_addr = $1464|!addr
!speed_addr    = $1448|!addr
!fraction_addr = $1450|!addr
nmi:
    jml dynamic_spriteset_queue
init:
	REP #$20
	LDA #$3200
	STA $4330
	LDA #.RedTable
	STA $4332
	LDY.b #.RedTable>>16
	STY $4334
	LDA #$3200
	STA $4340
	LDA #.GreenTable
	STA $4342
	LDY.b #.GreenTable>>16
	STY $4344
	LDA #$3200
	STA $4350
	LDA #.BlueTable
	STA $4352
	LDY.b #.BlueTable>>16
	STY $4354
	SEP #$20
	LDA #$38
	TSB $0D9F|!addr
    stz $1412|!addr
    rep #$20
    stz !phase_addr
    stz !speed_addr
    stz !fraction_addr
    sep #$20
    rtl

main:
LDA #$FF				; \ Hide the player's graphics.
STA $78					; /
    lda $9D : ora $13D4|!addr : bne .return
    lda $71 : cmp #$0A : beq .return
.run:
    lda !phase_addr : and #$01 : asl : tax
    rep #$20
    lda !speed_addr : clc : adc acceleration,x : sta !speed_addr
    sec : sbc speed,x : beq +
    eor speed,x : bmi +
    lda speed,x : sta !speed_addr
    inc !phase_addr
    stz !fraction_addr
+   lda !fraction_addr : and #$00FF
    clc : adc !speed_addr : sta !fraction_addr
    and #$FF00
    bpl +
    ora #$00FF
+   xba
    clc : adc !position_addr : sta !position_addr
    sep #$20
.return:
    rtl

init_RedTable:           ; 
   db $08 : db $20   ; 
   db $07 : db $21   ; 
   db $08 : db $22   ; 
   db $07 : db $23   ; 
   db $07 : db $24   ; 
   db $07 : db $25   ; 
   db $07 : db $26   ; 
   db $08 : db $27   ; 
   db $07 : db $28   ; 
   db $07 : db $29   ; 
   db $07 : db $2A   ; 
   db $08 : db $2B   ; 
   db $07 : db $2C   ; 
   db $07 : db $2D   ; 
   db $07 : db $2E   ; 
   db $08 : db $2F   ; 
   db $07 : db $30   ; 
   db $07 : db $31   ; 
   db $07 : db $32   ; 
   db $07 : db $33   ; 
   db $07 : db $34   ; 
   db $08 : db $35   ; 
   db $07 : db $36   ; 
   db $07 : db $37   ; 
   db $07 : db $38   ; 
   db $08 : db $39   ; 
   db $07 : db $3A   ; 
   db $07 : db $3B   ; 
   db $07 : db $3C   ; 
   db $08 : db $3D   ; 
   db $06 : db $3E   ; 
   db $00            ; 

init_GreenTable:         ; 
   db $14 : db $4B   ; 
   db $16 : db $4C   ; 
   db $15 : db $4D   ; 
   db $15 : db $4E   ; 
   db $17 : db $4F   ; 
   db $13 : db $50   ; 
   db $17 : db $51   ; 
   db $16 : db $52   ; 
   db $15 : db $53   ; 
   db $15 : db $54   ; 
   db $0B : db $55   ; 
   db $00            ; 

init_BlueTable:          ; 
   db $03 : db $9F   ; 
   db $20 : db $9E   ; 
   db $1E : db $9D   ; 
   db $20 : db $9C   ; 
   db $1D : db $9B   ; 
   db $1F : db $9A   ; 
   db $20 : db $99   ; 
   db $1F : db $98   ; 
   db $04 : db $97   ; 
   db $00            ; 