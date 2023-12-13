;====================================================================================;
; Customized Yoshi Message Patch by Alcaro                                           ;
;                                                                                    ;
; This patch allows more flexibility on when the Yoshi Rescued messages will appear, ;
; and what these messages will say on a per-level basis.                             ;
;                                                                                    ;
; Edit the tables in "YoshiMsgTable.asm" file, then patch this file with asar        ;
; (DON'T patch the other file!!).                                                    ;
;====================================================================================;

if read1($00FFD5) == $23
    sa1rom
    !addr = $6000
    !bank = $000000
else
    lorom
    !addr = $0000
    !bank = $800000
endif

org $01EC29
    autoclean jml Main

org $03BB90
    ldy $1426|!addr
    cpy #$FF            ; Change Yoshi message handler

freedata

Main:
    phx
    ldx $13BF|!addr
    lda.l YoshiMessageBehavior,x
    beq .ReturnZero
    dec
    bne .Yes
    lda $0EF8|!addr
    bne .Return
    inc $0EF8|!addr
.Yes
    lda.l MessageToShow,x
    sta $1426|!addr
.Return
    lda #$00
.ReturnZero
    plx
    jml $01EC41|!bank

!NoMsg  = "db $00"  ; Never show a message.
!OneMsg = "db $01"  ; Show a message if $0EF8 is not set, and set it.
!YesMsg = "db $02"  ; Always show a message. Does not set $0EF8.

incsrc "YoshiMsgTable.asm"
