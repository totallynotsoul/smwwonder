;##################################################################################################
;# Powerup: Lankario (AKA Lankio AKA Weird Mario)
;# Author: Nintendo (Original), SubconsciousEye (Port)
;# Description: The Weird Mushroom Powerup from Super Mario Maker.
;#
;# This code is run every frame when Mario has this powerup.
    
.mainmain
    lda !player_in_yoshi
    bne .rtrn
if !lankario_useAltHorzPhysics == !yes
    lda !player_in_water
    bne SwimPhysicsMain
    jsr HorzPhysicsMain
endif
    jmp GravityPhysicsMain      ; ends in rts
.rtrn
    rts


if !lankario_useAltHorzPhysics == !yes
SwimPhysicsMain:
    lda $08
    sta !player_x_speed_sub
    lda $09
    sta !player_x_speed

    lda !player_holding
    beq .notitem
.hasitem
    ldy #$80
    lda $15
    and.b #$03
    bne .itemspeed
    lda !player_direction
    bra .normalspeed
.notitem
    lda !player_crouching
    bne .decel
    lda $15
    and #$03
    beq .decel
.normalspeed
    ldy #$78
.itemspeed
    sty $00
    and #$01
    sta !player_direction
    pha
    asl #2
    tax
    pla
    ora $00
    ldy $1403|!addr     ; tide
    beq .notide
    clc : adc #$04
.notide
    tay
    lda !player_in_air
    beq .calcspeed
    iny #2
.calcspeed
    jmp HorzPhysicsMain_checkspeed
.decel
    ldy #$00
    tyx
    lda $1403|!addr
    beq .calcdecel
    ldx #$1E
    lda !player_in_air
    bne .calcdecel
    inx #2
.calcdecel
    jmp HorzPhysicsMain_swimdecel
endif



;##################################################################################################
;# Various Data and Subroutines
;# Credit to Thomas/Kaizoman666 for the disassembly most of this is based on.
;# Credit to Lui37 for the Luigi Physics values (mostly for the Horizontal Physics)

if !lankario_useAltHorzPhysics == !yes
NormDecel:                      ;$00D2CD    | Decelerations for Mario when not giving any inputs or at max speed.
    dw -$0099, $0099                ; First two are standard speeds (right, left). The latter ones are when on slopes (in the order of $13E1).
    dw -$0100, $0100,-$0100, $0100  ; For slopes, the two values are different.
    dw -$0180, $00C0,-$00C0, $0180  ;  One value is when moving faster than the slope's autoslide speed (so slow down).
    dw -$0200, $0040,-$0040, $0200  ;  The other is when moving slower than that (so speed up).
    dw -$0200, $0040,-$0200, $0040  ; ("autoslide speed" refers to the values in $00D5C9)
    dw -$0040, $0200,-$0040, $0200
    dw -$0400,-$0100, $0100, $0400
    dw -$0099, $0099,-$0099, $0099

SlipDecel:                      ;$00D309    | Decelerations for Mario when not giving any inputs or at max speed, in slippery levels.
    dw -$0013, $0013                ; Same order as above.
    dw -$0013, $0013,-$0013, $0013  ; Gradual Left; Gradual Right
    dw -$0026, $0013,-$0013, $0026  ; Normal Left; Normal Right
    dw -$004C, $0013,-$0013, $004C  ; Steep Left; Steep Right
    dw -$004C, $0013,-$004C, $0013  ; Conveyor Left Up; Down
    dw -$0013, $004C,-$0013, $004C  ; Conveyor Right Up; Down
    dw -$0133,-$004C, $004C, $0133  ; Very Steep Left; Right
    dw -$0099, $0099,-$0099, $0099  ; Flying Left; Flying Right

NormAccel:                      ;$00D345    | Accelerations for Mario. Walk/run, for left then right.
    dw -$0180,-$0180, $0180, $0180  ; 00 - Flat (and water)
    dw -$0180,-$0180, $0180, $0180  ; 08 - Gradual left
    dw -$0180,-$0180, $0180, $0180  ; 10 - Gradual right
    dw -$0180,-$0180, $0140, $0140  ; 18 - Normal left
    dw -$0140,-$0140, $0180, $0180  ; 20 - Normal right
    dw -$0180,-$0180, $0100, $0100  ; 28 - Steep left
    dw -$0100,-$0100, $0180, $0180  ; 30 - Steep right
    dw -$0180,-$0180, $0100, $0100  ; 38 - Conveyor left, up
    dw -$0180,-$0180, $0100, $0100  ; 40 - Conveyor left, down
    dw -$0100,-$0100, $0180, $0180  ; 48 - Conveyor right, up
    dw -$0100,-$0100, $0180, $0180  ; 50 - Conveyor right, down
    dw -$0400,-$0400,-$0300,-$0300  ; 58 - Very steep left
    dw  $0300, $0300, $0400, $0400  ; 60 - Very steep right
    dw -$0400,-$0400, $0600, $0600  ; 68 - Flying left (right = > + B)
    dw -$0600,-$0600, $0400, $0400  ; 70 - Flying right (left = < + B)
    dw -$0080, $0080                ; 78 - Sliding - Gradual
    dw -$0100, $0100                ; 7C - Sliding - Normal
    dw -$0180, $0180                ; 80 - Sliding - Steep
    dw -$0180,-$0180                ; 84 - Sliding - Conveyor left
    dw  $0180, $0180                ; 88 - Sliding - Conveyor right
    dw -$0180, $0280                ; 8C - Sliding - Very steep
    dw -$0140,-$0280, $0140, $0280  ; 90 - Decelerating - Flat
    dw -$0280,-$0500, $0280, $0500  ; 98 - Decelerating - Gradual left
    dw -$0280,-$0500, $0280, $0500  ; A0 - Decelerating - Gradual right
    dw -$02C0,-$0580, $0240, $0480  ; A8 - Decelerating - Normal left
    dw -$0240,-$0480, $02C0, $0580  ; B0 - Decelerating - Normal right
    dw -$0300,-$0600, $0200, $0400  ; B8 - Decelerating - Steep left
    dw -$0200,-$0400, $0300, $0600  ; C0 - Decelerating - Steep right
    dw -$0300,-$0600, $0200, $0400  ; C8 - Decelerating - Conveyor left, up
    dw -$0300,-$0600, $0200, $0400  ; D0 - Decelerating - Conveyor left, down
    dw -$0200,-$0400, $0300, $0600  ; D8 - Decelerating - Conveyor right, up
    dw -$0200,-$0400, $0300, $0600  ; E0 - Decelerating - Conveyor right, down
    dw -$0300,-$0600,-$0300,-$0600  ; E8 - Decelerating - Very steep left
    dw  $0300, $0600, $0300, $0600  ; F0 - Decelerating - Very steep right

SlipAccel:                      ;$00D43D    | Accerations in slippery levels while on the ground. Same order as above.
    dw -$0080,-$0180, $0080, $0180  ; 00 - Flat (and water)
    dw -$0080,-$0180, $0080, $0180  ; 08 - Gradual left
    dw -$0080,-$0180, $0080, $0180  ; 10 - Gradual right
    dw -$0180,-$0180, $0080, $0140  ; 18 - Normal left
    dw -$0080,-$0140, $0180, $0180  ; 20 - Normal right
    dw -$0180,-$0180, $0080, $0100  ; 28 - Steep left
    dw -$0080,-$0100, $0180, $0180  ; 30 - Steep right
    dw -$0180,-$0180, $0080, $0100  ; 38 - Conveyor left, up
    dw -$0180,-$0180, $0080, $0100  ; 40 - Conveyor left, down
    dw -$0080,-$0100, $0180, $0180  ; 48 - Conveyor right, up
    dw -$0080,-$0100, $0180, $0180  ; 50 - Conveyor right, down
    dw -$0400,-$0400,-$0300,-$0300  ; 58 - Very steep left
    dw  $0300, $0300, $0400, $0400  ; 60 - Very steep right
    dw -$0400,-$0400, $0080, $0080  ; 68 - Unused (would be flying, but you're in air...)
    dw -$0080,-$0080, $0400, $0400  ; 70 - Unused (would be flying, but you're in air...)
    dw -$0080, $0080                ; 78 - Sliding - Gradual
    dw -$0100, $0100                ; 7C - Sliding - Normal
    dw -$0180, $0180                ; 80 - Sliding - Steep
    dw -$0180,-$0180                ; 84 - Sliding - Conveyor left
    dw  $0180, $0180                ; 88 - Sliding - Conveyor right
    dw -$0180, $0280                ; 8C - Sliding - Very steep
    dw -$0020,-$0140, $0020, $0140  ; 90 - Decelerating - Flat
    dw -$0020,-$0140, $0020, $0140  ; 98 - Decelerating - Gradual left
    dw -$0020,-$0140, $0020, $0140  ; A0 - Decelerating - Gradual right
    dw -$0040,-$0160, $0020, $0120  ; A8 - Decelerating - Normal left
    dw -$0020,-$0120, $0040, $0160  ; B0 - Decelerating - Normal right
    dw -$0180,-$0180, $0020, $0100  ; B8 - Decelerating - Steep left
    dw -$0020,-$0100, $0180, $0180  ; C0 - Decelerating - Steep right
    dw -$0180,-$0180, $0020, $0100  ; C8 - Decelerating - Conveyor left, up
    dw -$0180,-$0180, $0020, $0100  ; D0 - Decelerating - Conveyor left, down
    dw -$0020,-$0100, $0180, $0180  ; D8 - Decelerating - Conveyor right, up
    dw -$0020,-$0100, $0180, $0180  ; E0 - Decelerating - Conveyor right, down
    dw -$0180,-$0180,-$0180,-$0180  ; E8 - Decelerating - Very steep left
    dw  $0180, $0180, $0180, $0180  ; F0 - Decelerating - Very steep right


    ; Side note about the below table:
    ; "Fast run" is used when Mario is moving faster than #$23 (the value at $00D723) and either on the ground or being shot out of a pipe.

MaxSpeeds:                      ;$00D535    | Maximum Mario X speeds. Each set is left/right in the order walk, run, fast run, sprint.
    db -$14, $14,-$24, $24,-$24, $24,-$30, $30  ; 00 - Flat
    db -$14, $14,-$24, $24,-$24, $24,-$30, $30  ; 08 - Gradual left
    db -$14, $14,-$24, $24,-$24, $24,-$30, $30  ; 10 - Gradual right
    db -$18, $12,-$24, $20,-$24, $20,-$30, $2C  ; 18 - Normal left
    db -$12, $18,-$20, $24,-$20, $24,-$2C, $30  ; 20 - Normal right
    db -$24, $10,-$24, $1C,-$24, $1C,-$30, $28  ; 28 - Steep left
    db -$10, $24,-$1C, $24,-$1C, $24,-$28, $30  ; 30 - Steep right
    db -$24, $10,-$24, $1C,-$24, $1C,-$30, $28  ; 38 - Conveyor left, up
    db -$24, $10,-$24, $1C,-$24, $1C,-$30, $28  ; 40 - Conveyor left, down
    db -$10, $24,-$1C, $24,-$1C, $24,-$28, $30  ; 48 - Conveyor right, up
    db -$10, $24,-$1C, $24,-$1C, $24,-$28, $30  ; 50 - Conveyor right, down
    db -$24,-$10,-$24,-$08,-$24,-$08,-$30,-$04  ; 58 - Very steep left
    db  $10, $24, $08, $24, $08, $24, $04, $30  ; 60 - Very steep right
    db -$30, $08,-$30, $08,-$30, $08,-$30, $08  ; 68 - Flying left (right = > + B) - first set is no X/Y, second is with X/Y, rest unused
    db -$08, $30,-$08, $30,-$08, $30,-$08, $30  ; 70 - Flying right (left = < + B) - first set is no X/Y, second is with X/Y, rest unused
;    db -$08, $08,-$10, $10,-$0C, $04,-$18, $08  ; 78 - Water (ground, swimming, tide ground, tide swimming)
;    db -$10, $10,-$20, $20,-$14, $0C,-$28, $18  ; 80 - Water with item (ground, swimming, tide ground, tide swimming)
    db -$0C, $0C,-$14, $14,-$10, $08,-$1C, $0C  ; 78 - Water (ground, swimming, tide ground, tide swimming)
    db -$14, $14,-$28, $28,-$18, $10,-$30, $20  ; 80 - Water with item (ground, swimming, tide ground, tide swimming)
    db -$28, $28                                ; 88 - Sliding on each slope. In the same order as 08-60.
    db -$2C, $2C
    db -$30, $30
    db -$30,-$30
    db  $30, $30
    db -$20, $20

AutoSlides:                 ;$00D5C9    | How fast Mario autoslides on various slope tiles, when not holding any buttons.
    dw  $0000               ; Flat
    dw  $0000, $0000        ; Gradual
    dw  $0000, $0000        ; Normal
    dw -$1000, $1000        ; Steep
    dw  $0000, $0000        ; Conveyor left
    dw  $0000, $0000        ; Conveyor right
    dw -$2000, $2000        ; Very steep
    dw  $0000, $0000        ; Unused (?)
    dw -$1000,-$0800        ; Tides (swimming, on ground)

HorzPhysicsMain:
    lda !player_in_air
    bne .checkslide
    lda !player_crouching
    beq .checkslide
    lda !player_x_speed
    beq .accelredirect
    lda !level_slippery_flag
    bne .accelredirect
    jsr SpawnSkidDust
    jmp .handleaccel
.checkslide
    lda !player_sliding
    bmi .capeslide
    lda $15
    and #$03
    bne .noslide
    lda !player_sliding
    beq .accelredirect
.capeslide
    jsr SpawnSkidDust
    lda !player_in_slope
    beq .accelredirect
    ldy #$00
    jsr HandleDashMeter
    lda $13E1|!addr
    lsr #2
    tay
    adc #$76
    tax
    tya
    lsr
    adc #$87
    tay
    jmp .checkspeed

.accelredirect
    jmp .handleaccel

.noslide
    stz !player_sliding
    and #$01
    ldy !player_direction
    cmp !player_direction
    beq .directionbackup
    ldy !player_holding
    beq .storedirection
    ldy $1499|!addr
    bne .directionbackup
    ldy #$08
    sty $1499|!addr
.storedirection
    sta !player_direction
.directionbackup
    sta $01
    asl #2
    ora $13E1|!addr
    tax
    lda !player_x_speed
    beq .prepdashcalc
    eor.w NormAccel+1,x
    bpl .prepdashcalc
    lda $14A1|!addr
    bne .prepdashcalc
    lda !level_slippery_flag
    bne .decelindex
    lda #$0D
    sta $13DD|!addr
    jsr SpawnSkidDust
.decelindex
    txa
    clc
    adc #$90
    tax
.prepdashcalc
    ldy #$00
    bit $15
    bvc .calcdash
    inx #2
    iny
    lda !player_x_speed
    bpl +
    eor #$FF
    inc
+   cmp #$23
    bmi .calcdash
    lda !player_in_air
    bne ..inair
    lda #$10
    sta !player_airwalk_timer
    bra ..adjustindex
..inair
    cmp #$0C
    bne .calcdash
..adjustindex:
    iny
.calcdash
    jsr HandleDashMeter
    tya
    asl
    ora $13E1|!addr
    ora $01
    tay
.checkspeed
    lda !player_x_speed
    sec
    sbc.w MaxSpeeds,y
    beq .handleaccel_index
    eor.w MaxSpeeds,y
    bpl .handleaccel_index
    rep #$20
    lda.w NormAccel,x
    ldy !level_slippery_flag
    beq ..normalaccel
    ldy !player_in_air
    bne ..normalaccel
    lda.w SlipAccel,x
..normalaccel
    clc
    adc !player_x_speed_16
    bra .storexaccel

.handleaccel:
    ldy #$00
    jsr HandleDashMeter
    lda !player_in_air
    bne .return
..index
    lda $13E1|!addr
    lsr
    tay
    lsr
    tax
.swimdecel
    lda !player_x_speed
    sec
    sbc.w AutoSlides+1,x
    bpl +
    iny #2
+   lda $1493|!addr
    ora !player_in_air
    rep #$20
    bne .normaldecel
    lda.w SlipDecel,y
    bit !level_slippery_flag-1
    bmi .notslipdecel
.normaldecel
    lda.w NormDecel,y
.notslipdecel
    clc
    adc !player_x_speed_16
    sta !player_x_speed_16
    sec
    sbc.w AutoSlides,x
    eor.w NormDecel,y
    bmi +
    lda.w AutoSlides,x
.storexaccel
    sta !player_x_speed_16
+   sep #$20
.return
    rts


HandleDashMeter:
    lda !player_dash_timer
    clc
    adc.w PMeterAddition,y
    bpl +
    lda #$00
+   cmp #$70
    bcc +
    iny
    lda #$70
+   sta !player_dash_timer
    rts

PMeterAddition:
    db -$01,-$01, $02

SpawnSkidDust:
    lda $13
    and #$03
    ora !player_in_air
    ora $7F
    ora $81
    ora $9D
    bne .return
    lda $15
    and #$04
    beq +
    lda !player_x_speed
    clc
    adc #$08
    cmp #$10
    bcc .return
+   ldy #$03
-   lda !smoke_num,y
    beq .spawn
    dey
    bne -
.return
    rts

.spawn
    lda #$03
    sta !smoke_num,y
    lda !player_x_low
    adc #$04
    sta !smoke_x_low,y
    lda !player_y_low
    adc #$1A
    phx
    ldx !player_in_yoshi
    beq +
    adc #$10
+   sta !smoke_y_low,y
    plx
    lda #$13
    sta !smoke_timer,y
    rts
endif

GravitySpeeds:
.normalgrav
    dw ((read1($00D7A5+0)<<8)&$FF00)*!lankario_gravity_fall_rate
    dw ((read1($00D7A5+0)<<8)&$FF00)*!lankario_gravity_rise_rate
.holdingjump
    dw ((read1($00D7A5+1)<<8)&$FF00)*!lankario_gravity_fall_rate
    dw ((read1($00D7A5+1)<<8)&$FF00)*!lankario_gravity_rise_rate

MaxFall:
.normalgrav
    dw (read1($00D7AF+0)<<8)&$FF00
    dw (read1($00D7AF+0)<<8)&$FF00
.holdingjump
    dw (read1($00D7AF+1)<<8)&$FF00
    dw (read1($00D7AF+1)<<8)&$FF00

GravityPhysicsMain:
    lda $15
    rol
    lda !player_y_speed
    rol #2
    asl
    and #$06
    tay
    rep #$20
    lda !player_y_speed_16
    bmi .calcgrav
    cmp.w MaxFall,y
    bcc .notmaxfall
    lda.w MaxFall,y
.notmaxfall
    ldx !player_in_air
    beq .calcgrav
    cpx.b #$0B
    bne .calcgrav
    ldx.b #$24
    stx !player_in_air
.calcgrav
    clc
    adc.w GravitySpeeds,y
    sta !player_y_speed_16
    sep #$20
    rts
