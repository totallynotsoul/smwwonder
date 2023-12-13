;##################################################################################################
;# Item: Super Carrot
;# Author: Nintendo
;# Description: Default powerup item for Bunny Mario.

;################################################
;# Collected item routine
;# Runs whenever the player touches the powerup item

.collected
    lda.b #!carrot_powerup_num
    cmp !player_powerup
    bne ..not_same
    jmp do_nothing
..not_same
    sta !player_powerup
    if !carrot_collected_sfx_num != $00
        lda.b #!carrot_collected_sfx_num
        sta.w !carrot_collected_sfx_port|!addr
    endif
    lda #$04
    sta $71
    if !carrot_can_give_points == !yes
        lda.b #!carrot_collected_points
        ldy !item_falling,x
        bne ..from_item_box
        jsl give_points
    ..from_item_box
    endif
    jsl $01C5AE|!bank
    if !carrot_freeze_screen == !yes
        sta $9D
    endif
    lda #!carrot_physicsflags
    sta !player_physics_flags
    rts

;################################################
;# Put in item box logic
;# Runs when the player touches a powerup item

.item_box
    lda.w ..item_id,y
    beq ..nope
    sta !player_item_box
    if !carrot_item_box_sfx_num != $00
        lda.b #!carrot_item_box_sfx_num
        sta.w !carrot_item_box_sfx_port|!addr
    endif
..nope
    rts 

..item_id
    !i #= 0
    while !i < !max_powerup_num
        %internal_number_to_string(!i)
        if not(stringsequal("!{powerup_!{_num}_path}", "0"))
            db !{powerup_!{_num}_item_id}+1
        else
            db $00
        endif
        !i #= !i+1
    endif


;################################################
;# Put in item box logic
;# Runs when the player touches a powerup item

.item_box_drop
    jsr spawn_item
    inc !item_falling,x
    rts 


;################################################
;# Routine to instantly give a powerup without any animation/effect

.quick
    lda.b #!carrot_powerup_num
    sta !player_powerup
    lda #!carrot_physicsflags
    sta !player_physics_flags
    rtl