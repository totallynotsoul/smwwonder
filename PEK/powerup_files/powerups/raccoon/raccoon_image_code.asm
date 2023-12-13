;##################################################################################################
;# Powerup: Cape Mario
;# Author: Nintendo
;# Description: Default powerup $02 for Mario. Behaves exactly like in the original game.
;# 
;# This code will handle any extra animations or poses Mario will have when using this powerup.

.extra_tile_player
	lda.b #!raccoon_p2_extra_gfx_index
	ldy !player_num
	bne ..player_2
	lda.b #!raccoon_p1_extra_gfx_index
..player_2 
	sta !player_graphics_extra_index
	lda #$01
	sta !player_extra_tile_settings

;lda !player_extended_anim_num
;bne .statictail

.tailthwack
	lda !raccoon_tail_flag
	bpl .nothwack
;	lda !player_pose_num
;	cmp #$48 : bcs +
	lda $3fdead
	lda !raccoon_thwack_timer
	beq .statictail
	;;TODO: local-state posing
;	lda #$4e : ora !raccoon_tail_flag
;	and #$7f
;	sta !player_pose_num
;+	lda !player_extended_anim_index
;	lsr
	lsr #3
	bcc .notcenter
	xba
	lda #$10
	tsb $78
	xba
.notcenter
;	eor !player_extended_anim_num
	tay
	eor !raccoon_tail_flag
	rol : and #$03
	tax
	lda .thwackpose,x
	sta !player_pose_num
	tya
	eor !raccoon_tail_flag
	and #$01 : sta !player_direction
	lda #$02
	sta !player_extra_tile_frame
	lsr
	sta !player_walk_pose
	bra .nohide

.nothwack
	lda !raccoon_freeflight
	beq .statictail
	lda !player_pose_num
	cmp #$47 : bne +
	lda #$47 : sta !player_pose_num
+	lda #$0a : sta !player_extra_tile_frame
	bra .masktile

.dynamictile
	lda !player_in_air
	beq .notair
	lda $3fdead
;	lda !player_dash_timer
;	cmp #$70-2
;	bcc +
;	lda #$02 : bra ++
;+	lda $14a5|!addr
	lda $14a5|!addr
;	ora !player_takeoff_timer
	bne .notair
	lda #$00
	ldy !player_y_speed
	bmi ++ : lda #$04
++	sta !player_extra_tile_frame
	bra .nohide
.notair
	lda $13df|!addr : and #$03
	tax
	lda .dynamictail,x
	sta !player_extra_tile_frame
	bra .nohide

.statictail
	lda $3fdead
    ldx !player_pose_num
    lda .raccoon_tail,x
    sta !player_extra_tile_frame
;	bit #$c0
;	bmi +
;	bvc .dynamictile
;+	
	cmp #$40
	beq .dynamictile
	asl
    bcc .nohide
.masktile
    lda #$10        ;\ mask away
    tsb $78         ;/ extra tile
.nohide
    rep #$20
    lda #$0011
    sta !player_extra_tile_offset_y
    lda !player_direction
    asl : tax
	lda .facing,x
    sta !player_extra_tile_offset_x
    sep #$20
	
	rts

    lda $1891|!addr ; p-balloon
    ora !player_in_yoshi
    ora !player_spinjump
    ora !player_sliding
    ora !player_in_water
    ora !player_crouching
    bne +
;   lda !player_in_air
;   beq +
;    lda !bunny_states
;    beq +
;    stz !player_airwalk_timer
;    lda !bunny_hover_timer
;    and !bunny_ear_flap
;    bne +
    lda !player_extra_tile_frame
    inc #2
    sta !player_extra_tile_frame

+   rts

.raccoon_tail
    db $40                  ; [00]      Idle
    db $40,$40              ; [01-02]   Walking
    db $00                  ; [03]      Looking Up
    db $02,$02,$02          ; [04-06]   Running
    db $40                  ; [07]      Idle, holding an item
    db $40,$40              ; [08-09]   Walking, holding an item; second byte is also used for Jumping/Falling
    db $00                  ; [0A]      Looking up, holding an item
    db $40                  ; [0B]      Jumping
    db $40                  ; [0C]      Jumping, max speed
    db $80                  ; [0D]      Skidding
    db $00                  ; [0E]      Kicking item
    db $80                  ; [0F]      Looking to camera; spinjump pose, going into a pipe pose
    db $80                  ; [10]      Diagonal
    db $08,$08,$08          ; [11-13]   Running up wall
    db $00                  ; [14]      Victory pose, on Yoshi
    db $80                  ; [15]      Climbing
    db $04,$04              ; [16-17]   Swimming Idle; second byte is used for holding an item
    db $04,$04              ; [18-19]   Swimming #1; second byte is used for holding an item
    db $04,$04              ; [1A-1B]   Swimming #2; second byte is used for holding an item
    db $04                  ; [1C]      Sliding
    db $40                  ; [1D]      Crouching, holding an item
    db $80                  ; [1E]      Punching a net
    db $80                  ; [1F]      Swinging on net, showing back
    db $40                  ; [20]      Mounted on Yoshi; Swinging on net, side
    db $00                  ; [21]      Turning around on Yoshi, facing camera; Swinging on net, facing camera; Going into a pipe on Yoshi
    db $80                  ; [22]      Climbing, facing camera
    db $80                  ; [23]      Punching a net, facing camera
    db $40                  ; [24]      Falling
    db $80                  ; [25]      Showing back; spinjump pose
    db $40                  ; [26]      Victory pose
    db $40,$40              ; [27-28]   Commanding Yoshi
    db $80                  ; [29]      Going into a pipe on Yoshi (Weird Crouch)
    db $80,$80              ; [2A-2B]   Flying with cape
    db $80                  ; [2C]      Slide with cape while flying
    db $80,$80,$80          ; [2D-2F]   Dive with cape
    db $0e,$0e              ; [30-31]   Burned, cutscene poses
    db $80                  ; [32]      Looking in front, cutscene pose
    db $00,$00              ; [33-34]   Looking at the distance, cutscene pose
    db $40,$40,$40          ; [35-37]   Using a hammer, cutscene pose
    db $80,$80              ; [38-39]   Using a mop, cutscene pose
    db $80,$80              ; [3A-3B]   Using a hammer, cutscene pose, most likely unused
    db $40                  ; [3C]      Crouching
    db $80                  ; [3D]      Shrinking/Growing
    db $80                  ; [3E]      Dead
    db $80                  ; [3F]      Shooting fireball
    db $80,$80              ; [40-41]   Unused
    db $80                  ; [42]      Using P-Balloon (Small Mario, Unused)
    db $80                  ; [43]      Using P-Balloon (Non-Small Mario, Used)
    db $80,$80,$00          ; [44-46]   Copy of the spinjump poses (Non-Small Forms); Last byte is also a part of the Shrinking/Growing animation
    db $80                  ; [47]      Backwards Somersault, Used to transition into Cape Flight
    db $02,$02              ; [48-49]   Tail Thwack, Ground; Left, Right
    db $02,$02              ; [4A-4B]   Tail Thwack, Air; Left, Right
    db $02,$02              ; [4C-4D]   Tail Thwack, Swim; Left, Right
    db $02,$02              ; [4E-4F]   Tail Thwack, Global; Left, Right
    db $80,$80,$80,$80      ; [50-53]   Backwards Somersault, Actual Frames

.dynamictail
	db $00,$02,$04,$06
.facing
	dw $000c,-$000c
.thwackpose
	db $00,$25,$00,$0f
