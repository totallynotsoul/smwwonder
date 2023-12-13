;##################################################################################################
;# Powerup: Lankario (AKA Lankio AKA Weird Mario)
;# Author: Nintendo (Original), SubconsciousEye (Port)
;# Description: The Weird Mushroom Powerup from Super Mario Maker.
;# 
;# This code will handle any extra animations or poses Mario will have when using this powerup.

.imagemain
    lda !player_in_yoshi
    bne .yoshi
.notyoshi
    lda !player_in_air
    beq .rtrn
    xba
    lda !player_climbing
    ora !player_crouching
    ora !player_wallrunning
    ora !player_spinjump
    ora !player_sliding
    ora $13F3|!addr     ; p-balloon
    ora $1891|!addr     ; p-balloon
	ora $1499|!addr     ; holding turn
    bne .rtrn
    ldy #$00
    lda !player_in_water
    bne .water
.outwater
    xba                 ; !player_in_air
    ldx !player_holding
    beq .notcarry
    iny #2
    cmp #$0C
    beq +
    bra .carryjoin
.notcarry
    cmp #$0C
    beq .rtrn
.carryjoin
    cmp #$0B
    bne +
    iny
+   lda.w ScuttlePose,y
.storepose
    sta !player_pose_num
.rtrn
    rts
.water
    lda !player_holding
    beq +
    iny
+   xba                 ; !player_in_air
    stz !player_shoot_pose_timer
    lda !player_animation_timer
    bne .rtrn
    lda.w SwimIdlePose,y
    bra .storepose
.yoshi
    lda !player_pose_num
    sec : sbc #$20
    cmp #$02
    bcs .rtrn
    tay
    lda.w YoshiPoseFix,y
    bra .storepose

SwimIdlePose:
.noitem
    db $4C
.item
    db $4E

ScuttlePose:
.noitem
..fall
    db $4A
..rise
    db $48
.item
..fall
    db $47
..rise
    db $47

YoshiPoseFix:
.normal
    db $50
.turning
    db $51
