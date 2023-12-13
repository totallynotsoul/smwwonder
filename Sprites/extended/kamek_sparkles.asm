print "MAIN", pc
    lda $9D
    bne graphics
    inc !extended_x_high,x
    lda !extended_x_high,x
    and #$07
    bne graphics
    lda !extended_y_low,x
    clc 
    adc #$08
    sta !extended_y_low,x
    lda !extended_y_high,x
    adc #$00
    sta !extended_y_high,x
graphics:
    lda !extended_timer,x
    lsr #3
    sta $03
    lda !extended_x_high,x
    lsr #2
    and #$01
    sta $02
    lda !extended_y_low,x
    sec 
    sbc $1C
    cmp #$F8
    bcs .kill
    sta $01
    lda !extended_x_low,x
    sec 
    sbc $1A
    sta $00
    phx
    ldy #$F4
    ldx #$04
.loop
    cpx #$04
    bne .cont
    lda $02
    lsr
    bcc .next
.cont
    jsr find_oam
    bcc .abort
    lda $00
    sta $0200|!addr,y 
    lda $01
    clc 
    adc .y_disp-1,x
    sta $0201|!addr,y
    phx 
    txa 
    asl 
    ora $02
    tax 
    lda.w .tiles-2,x
    sta $0202|!addr,y
    lda $64
    ora #$01
    sta $0203|!addr,y
    tya 
    lsr #2 
    tax
    stz $0420|!addr,x
    plx 
.next
    dey #4
    dex 
    cpx $03
    bne .loop
.abort
    plx
    rtl 
.kill
    stz !extended_num,x
    rtl 

.y_disp
    db $E8,$F0,$F8,$00
.tiles
    db $EF,$FF
    db $EE,$FE
    db $EF,$FE
    db $EF,$FF
    
    db $FF,$EF
    db $FE,$EF
    db $FE,$EE
    db $FF,$EF

find_oam:
    lda #$F0
.loop
    cmp $0201|!addr,y
    beq .break
    dey #4
    beq .stop
    bra .loop
.stop
    clc 
    rts 
.break
    sec 
    rts

    