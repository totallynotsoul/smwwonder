;##################################################################################################
;# Powerup: Bunny Mario
;# Author: Nintendo (Original), SubconsciousEye (Port)
;# Description: The Super Carrot Powerup from Super Mario Land 2, with near-accurate behavior.
;# 
;# This code will handle any extra animations or poses Mario will have when using this powerup.

.extra_tile_player
	lda.b #!bunny_p2_extra_gfx_index
	ldy !player_num
	bne ..player_2
	lda.b #!bunny_p1_extra_gfx_index
..player_2 
	sta !player_graphics_extra_index
	lda #$01
	sta !player_extra_tile_settings

    ldx !player_pose_num
    lda .bunny_ears,x
    sta !player_extra_tile_frame
    bpl .nohide
    lda #$10        ;\ mask away
    tsb $78         ;/ extra tile
.nohide
    rep #$20
    lda #$FFF9
    sta !player_extra_tile_offset_y
    lda #$0000
    sta !player_extra_tile_offset_x
    sep #$20

    lda $1891|!addr ; p-balloon
    ora !player_in_yoshi
    ora !player_spinjump
    ora !player_sliding
    ora !player_in_water
    ora !player_crouching
    bne +
;   lda !player_in_air
;   beq +
    lda !bunny_states
    beq +
    stz !player_airwalk_timer
    lda !bunny_hover_timer
    and !bunny_ear_flap
    bne +
    lda !player_extra_tile_frame
    inc #2
    sta !player_extra_tile_frame

+   rts

.bunny_ears
    db $00                  ; [00]      Idle
    db $00,$02              ; [01-02]   Walking
    db $80                  ; [03]      Looking Up
    db $00,$00,$00          ; [04-07]   Running
    db $00                  ; [07]      Idle, holding an item
    db $00,$00              ; [08-09]   Walking, holding an item; second byte is also used for Jumping/Falling
    db $80                  ; [0A]      Looking up, holding an item
    db $04                  ; [0B]      Jumping
    db $00                  ; [0C]      Jumping, max speed
    db $06                  ; [0D]      Skidding
    db $00                  ; [0E]      Kicking item
    db $08                  ; [0F]      Looking to camera; spinjump pose, going into a pipe pose
    db $80                  ; [10]      Diagonal
    db $80,$80,$80          ; [11-13]   Running up wall
    db $0A                  ; [14]      Victory pose, on Yoshi
    db $0C                  ; [15]      Climbing
    db $02,$02              ; [16-17]   Swimming Idle; second byte is used for holding an item
    db $02,$02              ; [18-19]   Swimming #1; second byte is used for holding an item
    db $02,$02              ; [1A-1B]   Swimming #2; second byte is used for holding an item
    db $00                  ; [1C]      Sliding
    db $80                  ; [1D]      Crouching, holding an item
    db $0E                  ; [1E]      Punching a net
    db $20                  ; [1F]      Swinging on net, showing back
    db $22                  ; [20]      Mounted on Yoshi; Swinging on net, side
    db $00                  ; [21]      Turning around on Yoshi, facing camera; Swinging on net, facing camera; Going into a pipe on Yoshi
    db $26                  ; [22]      Climbing, facing camera
    db $28                  ; [23]      Punching a net, facing camera
    db $2A                  ; [24]      Falling
    db $2E                  ; [25]      Showing back; spinjump pose
    db $40                  ; [26]      Victory pose
    db $42,$44              ; [27-28]   Commanding Yoshi
    db $80                  ; [29]      Going into a pipe on Yoshi (Weird Crouch)
    db $80,$80              ; [2A-2B]   Flying with cape
    db $80                  ; [2C]      Slide with cape while flying
    db $80,$80,$80          ; [2D-2F]   Dive with cape
    db $46,$46              ; [30-31]   Burned, cutscene poses
    db $48                  ; [32]      Looking in front, cutscene pose
    db $80,$4A              ; [33-34]   Looking at the distance, cutscene pose
    db $80,$80,$80          ; [35-37]   Using a hammer, cutscene pose
    db $80,$2E              ; [38-39]   Using a mop, cutscene pose
    db $08,$4C              ; [3A-3B]   Using a hammer, cutscene pose, most likely unused
    db $80                  ; [3C]      Crouching
    db $80                  ; [3D]      Shrinking/Growing
    db $80                  ; [3E]      Dead
    db $00                  ; [3F]      Shooting fireball
    db $80,$80              ; [40-41]   Unused
    db $80                  ; [42]      Using P-Balloon (Small Mario, Unused)
    db $4C                  ; [43]      Using P-Balloon (Non-Small Mario, Used)
    db $2E,$08,$00          ; [44-46]   Copy of the spinjump poses (Non-Small Forms); Last byte is also a part of the Shrinking/Growing animation
