nmi:
;LDA $18BB|!addr
;MP #$FF
;BEQ DoNothing
jml dynamic_spriteset_queue
DoNothing:
RTL
Main:
jsl GroundPound_main
jsl badge_main
jsl wall_kick_main
;Flower coin code
;RAM 1F2C and 1F2D
LDA $0EF9|!dp
CMP #$0A
BEQ .increment
RTL
.increment
STZ $0EF9|!dp
INC $0EFB|!dp
RTL
load:
LDA #$00
STA $1869|!addr
jsl badge_load
RTL