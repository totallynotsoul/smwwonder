;##################################################################################################
;# YI Kamek - For cutscenes
;#    made by lx5 as a (public) commissioned work
;#    version 1.0
;# 
;# Attempt at recreating YI's Kamek cutscene, including effects that Kamek applies into the
;# battlefield (minus Super FX stuff)
;#
;# It's partially commented... too lazy to finish the comments.

;#########################################################################
;# Extra byte information
;# 
;# Extra byte 1: Settings
;#               Format: kmsp-vcd
;#               d = Initial direction
;#                   0 = left
;#                   1 = right
;#               c = Show message(s) once
;#                   0 = Yes
;#                   1 = No
;#               v = Use VWF messages instead of SMW messages
;#                   0 = No
;#                   1 = Yes
;#               p = Change sprite palette with rainbow effect
;#                   0 = No
;#                   1 = Yes
;#               s = Only perform a single magic wave
;#                   0 = No
;#                   1 = Yes
;#               m = Start in cutscene mode
;#                   This setting bypasses the proximity check and activates
;#                   Kamek right away.
;#                   0 = Yes
;#                   1 = No
;#               k = Keep cutscene mode after Kamek disappears
;#                   0 = No
;#                   1 = Yes
;# 
;# Extra byte 2: Magic color for waves
;#               Format: xxxxyyyy
;#               xxxx = Wave 1
;#               yyyy = Wave 2
;#               0 = Red [1,0,0]
;#               1 = Blue [0,0,1]
;#               2 = Green [0,1,0]
;#               3 = Yellow [0,1,1]
;#               4 = Pink [1,0,1]
;#               5 = Cyan [0,1,1]
;#               6 = Orange [1, 0.5, 0]
;#               7 = Purple [0.5, 0, 1]
;#               8 = White [1,1,1]
;#               9 = Red (alternate) [1, 0.25, 0.25]
;#               A = Blue (alternate) [0.25, 0.25, 1]
;#               B = Green (alternate) [0.5, 1, 0.25]
;#               C-F = Randomly select a color from the valid colors.
;#                     Randomness of the colors vary according to the game's
;#                     RNG system and when this sprite runs its code.
;#                     If used in a level where the sprite runs first, it's
;#                     possible that the colors don't feel very random
;#                     ESPECIALLY if you're using retry system and make
;#                     the RNG seed reset every time the level is loaded.
;# 
;# Extra byte 3: Horizontal range to trigger Kamek
;# Extra byte 4: Vertical range to trigger Kamek
;#               Both options start from the center of the sprite
;#               The value is used as a displacement on both sides
;#               meaning that if you use 20, it'll check 0x20 pixels
;#               on the left and 0x20 pixels on the right.
;# 
;# Extra byte 5: Palette row that will receive the rainbow effect
;#               applied to it.
;#               0 = Palette 8
;#               1 = Palette 9
;#               2 = Palette A
;#               3 = Palette B
;#               4 = Palette C
;#               5 = Palette D
;#               6 = Palette E
;#               7 = Palette F
;#               FF = No palette will be affected
;# 
;# Extra byte 6: Music number for the boss music.
;#                00 will use the define under customization.
;#                FF will keep the same song playing.
;# 
;# Extra byte 7: Message 1 ID
;# Extra byte 8: Message 2 ID
;# Extra byte 9: Message 3 ID
;# Extra byte 10: Message 4 ID
;#               Format: mlllllll
;#               m = Message number
;#                   0 = Message #1 from level
;#                   1 = Message #2 from level
;#               lllllll = Level number in $13BF format
;#               If FF the messages will stop appearing.

;#########################################################################
;# Customization

;# SFX used for the "sprinkle magic" effect
!sprinkle_effect_sfx = $1C
!sprinkle_effect_port = $1DF9

;# Extended sprite number used for the falling sparkles during
;# the "sprinkle magic" effect
!sparkle_ext_sprite_num = $00

;# Music that will play once the cutscene ends
;# This can be overriden with extra bytes.
!boss_music = $05

;##################
;# RAM defines

;# Misc RAM
;# 16 bytes
!kamek_ram = $7F9FF0

;# HDMA RAM buffer for the layer 3 y position
;# Needs around 568 bytes
!hdma_y_position_table = $7FA000

;# VWF Dialogues RAM
!varram	= $702000

;# Same as above, but they're for SA-1
!kamek_ram_sa1 = $404000
!hdma_y_position_table_sa1 = $404010
!varram_sa1	= $419000

;#########################################################################
;# Internal stuff, do not touch

if !sa1 == 1
    !kamek_ram = !kamek_ram_sa1
    !hdma_y_position_table = !hdma_y_position_table_sa1
    !varram	= !varram_sa1
endif

!layer_3_y_pos = !kamek_ram+$00
!gradient_y_pos = !kamek_ram+$02
!magic_state = !kamek_ram+$04
!magic_direction = !kamek_ram+$05
!magic_color = !kamek_ram+$06
!magic_color_ptr = !kamek_ram+$07
!magic_delay = !kamek_ram+$09
!magic_nmi_codes = !kamek_ram+$0A
!palette_color_index = !kamek_ram+$0B
!palette_color_dest = !kamek_ram+$0C
!kamek_previous_level = !kamek_ram+$0D
!kamek_cutscene_mode = !kamek_ram+$0E
!kamek_cutscene_end_flag = !kamek_ram+$0F

!sprite_x_lo = !E4
!sprite_x_hi = !14E0
!sprite_y_lo = !D8
!sprite_y_hi = !14D4

!sprite_x_speed = !B6
!sprite_y_speed = !AA

!sprite_status = !14C8

!sprite_blocked = !1588

!sprite_animation_timer = !1570
!sprite_animation_frame = !160E
!sprite_direction = !157C

!sprite_timer = !1540

!sprite_offscreen_horz = !15C4
!sprite_offscreen_vert = !186C

!sprite_state = !C2
!sprite_direction_bak = !1528
!sprite_sparkle_timer = !1528
!sprite_message_remaining = !1528
!sprite_level_bak = !151C

!sprite_flags = !7FAB1C

!update_sprite_x_pos        = $018022
!update_sprite_y_pos        = $01801A
!execute_pointer            = $0086DF
!get_random                 = $01ACF9

macro read_ex_byte(num)
    ldy.b #<num>-1
    lda [$8A],y
endmacro 

;#########################################################################

print "INIT", pc
    jsr setup_ex_bytes
    %read_ex_byte(1)
    and #$01
    sta !sprite_direction,x
    lda $13BF|!addr
    sta !sprite_level_bak,x
.set_cutscene_mode
    %read_ex_byte(1)
    and #$40
    bne ..nope
    lda #$01
    sta !kamek_cutscene_mode
..nope
    rtl 

;#########################################################################

print "MAIN", pc
    phb
    phk 
    plb
    jsr setup_ex_bytes
    lda !14C8,x
    cmp #$08
    bcc gfx_only
    jsr main
gfx_only: 
    lda !sprite_state,x
    beq not_gfx
    jsr graphics
not_gfx:
    plb
    rtl

;#########################################################################

main:
    lda !sprite_state,x
    jsl !execute_pointer
    dw detect_player        ; $00
    dw go_on_screen         ; $01
    dw talking              ; $02
    dw show_message         ; $03
    dw go_off_screen        ; $04
    dw prepare_magic        ; $05
    dw sprinkle_magic       ; $06
    dw prepare_magic        ; $07
    dw sprinkle_magic       ; $08
    dw disappear            ; $09
    dw init_off_screen      ; $0A

;#########################################################################

detect_player:
    ;# Check if the player should start in cutscene mode and Kamek should
    ;# appear on screen as soon the level is loaded.
    ;# Kamek will only appear once the player is touching the ground
    ;# regardless of the force cutscene bit.
    ;# That's YI's behavior anyway.
.check_force_cutscene_mode
    %read_ex_byte(1)
    and #$40
    bne ..nope
    jmp .set_cutscene_mode
..nope
    ;# Check horizontal range between Kamek's center and the player's
    ;# center.
    ;# The extra byte information is used for both sides, meaning that
    ;# it will test for the px specified on the left and the right
    ;# at the same time.
.check_horz 
    %read_ex_byte(3)
    sta $00
    stz $01
    asl 
    adc #$10        ; extra lenght to account for player's width
    sta $02
    lda #$00
    adc #$00
    sta $03
    lda !sprite_x_hi,x
    xba 
    lda !sprite_x_lo,x
    rep #$20
    clc 
    adc #$0008      ; adjust for center
    sec 
    sbc $94         ; substract mario pos
    clc 
    adc $00         ; check if in range
    cmp $02
    sep #$20
    bcs .out_of_range

    ;# Check vertical range between Kamek's center and the player's
    ;# center.
    ;# The extra byte information is used for both sides, meaning that
    ;# it will test for the px specified on the left and the right
    ;# at the same time.
.check_vert
    %read_ex_byte(4)
    sta $00
    stz $01
    asl 
    sta $02
    lda #$00
    adc #$00
    sta $03
    lda !sprite_y_hi,x
    xba 
    lda !sprite_y_lo,x
    rep #$20
    sec 
    sbc $94
    sbc #$0014
    clc 
    adc #$0008
    adc $00
    cmp $02
    sep #$20
    bcc .set_cutscene_mode
.out_of_range
    rts 

    ;# Sets cutscene mode (disables controls)
.set_cutscene_mode
    lda #$01
    sta !kamek_cutscene_mode

    ;# Checks if the player is on the ground to start playing the cutscene
.check_ground
    lda $77
    and #$04
    bne ..in_ground
..in_air
    rts 
..in_ground
    
    ;# Check whether Kamek should talk again after talking once
    ;# This is how it works on YI, can be disabled.
.check_message

    ;bra .skip_talking

    %read_ex_byte(1)
    and #$02
    bne .show_message
    lda !kamek_previous_level
    cmp $13BF|!addr
    bne .show_message

.skip_talking
    ;# Skip the talking portion of the cutscene and jump into a prep
    ;# phase for the flying across the screen and throw magic powder
    ;# phase.
    lda #$0A
    sta !sprite_state,x
    lda #$20
    sta !sprite_timer,x
    lda !sprite_direction,x
    sta !sprite_direction_bak,x
    bra .go_off_screen

    ;# If Kamek has to show a message (already shown or YI's behavior
    ;# disabled), prepare the flag to skip the message the next time
    ;# the player finds Kamek on the same level and jump to the next
    ;# state which will be Kamek coming into the screen and talking.
.show_message
    lda $13BF|!addr
    sta !kamek_previous_level
    inc !sprite_state,x 
    lda #$20
    sta !sprite_timer,x

    ;# Set Kamek to be offscreen depending on the initial direction
    ;# set via Extra Bytes, so Kamek will never appear at the start
    ;# of the cutscene.
.go_off_screen
    ldy !sprite_direction,x
    lda $1A
    clc 
    adc .x_disp_lo,y
    sta !sprite_x_lo,x
    lda $1B
    adc .x_disp_hi,y
    sta !sprite_x_hi,x
    lda $1C
    clc 
    adc #$40
    sta !sprite_y_lo,x
    lda $1D
    adc #$00
    sta !sprite_y_hi,x
    rts 

.x_disp_lo
    db $14,$DC
.x_disp_hi
    db $01,$FF

;#########################################################################

go_on_screen:
    ;# If you somehow enter this mode without controls disabled
    ;# then force them to be disabled.
    lda #$01
    sta !kamek_cutscene_mode

    ;# Check if this phase timer is done or not
    lda !sprite_timer,x
    bne .moving

    ;# Change into the next phase, also set a specific animation
    ;# time to slightly match the original animation of Kamek talking
.next
    inc !sprite_state,x
    lda #$68
    sta !sprite_timer,x
    lda #$09
    sta !sprite_animation_timer,x
    rts 

    ;# Check if the sprite should start braking
.moving 
    ldy !sprite_direction,x
    cmp #$15
    bcs .regular

    ;# Start braking
    lda !sprite_x_speed,x
    clc 
    adc .x_accel,y
    sta !sprite_x_speed,x
    jsl !update_sprite_x_pos
    jsl !update_sprite_y_pos
    stz !sprite_animation_frame,x
.not_braking
    rts 

    ;# Keep sprite moving into the scene
.regular
    lda .x_speed,y
    sta !sprite_x_speed,x
    lda #$04
    sta !sprite_y_speed,x
    jsl !update_sprite_x_pos
    jsl !update_sprite_y_pos
    lda #$01
    sta !sprite_animation_frame,x
    rts 

.x_speed
    db $D0,$30
.x_accel
    db $03,$FD

;#########################################################################

talking:
    ;# Force animation frame so Kamek stays still
    lda #$01
    sta !sprite_animation_frame,x

    ;# Check if the phase timer has run out
    lda !sprite_timer,x
    bne .keep

    ;# Change into the next phase, also force an animation frame and
    ;# stop all of its speeds
.done
    inc !sprite_state,x
    lda #$03
    sta !sprite_animation_frame,x
    stz !sprite_x_speed,x
    stz !sprite_y_speed,x
    stz !sprite_message_remaining,x
    rts 

    ;# Make the sprite do a wave motion without moving horizontally
.keep
    lsr #3
    and #$07
    tay 
    lda .y_speeds,y
    sta !sprite_y_speed,x
    stz !sprite_x_speed,x
    jsl !update_sprite_x_pos
    jsl !update_sprite_y_pos

    ;# Do talking animations after some time has passed
    lda !sprite_timer,x
    cmp #$80
    bcs +
    inc !sprite_animation_timer,x
    lda !sprite_animation_timer,x
    and #$0F
    tay 
    lda .frames,y
    sta !sprite_animation_frame,x
+   
    rts

.y_speeds
    db $F6,$FC,$00,$04,$0A,$04,$00,$FC
.frames
    db $02,$02
    db $03,$03,$03,$03,$03,$03
    db $02,$02
    db $01,$01,$01,$01,$01,$01

;#########################################################################

show_message:
    %read_ex_byte($01)
    and #$04
    beq .original
.vwf 
    lda #$01
    sta !kamek_cutscene_mode
    lda !varram
    bne ..playing
    inc !sprite_message_remaining,x
    lda !sprite_message_remaining,x
    cmp #$02
    bcs .done
    lda #$01
    sta !varram
    %read_ex_byte($07)
    sta !varram+$02
    %read_ex_byte($08)
    sta !varram+$01
..playing
    lda #$00
    sta !kamek_cutscene_mode
    rts 

.original
    ;# Only attempt to show a message if one is not playing.
    lda $1426|!addr
    bne .ret

    ;# Message is not playing, show the next message in queue
    ;# If the message is FF or four messages have been shown the queue
    ;# will end.
    lda #$06
    clc 
    adc !sprite_message_remaining,x
    tay
    inc !sprite_message_remaining,x
    lda !sprite_message_remaining,x
    cmp #$06
    bcs .done
    lda [$8A],y
    cmp #$FF
    bne .valid

    ;# No more messages in queue, proceed to change phase.
    ;# Also restore the OW level number.
.done
    inc !sprite_state,x
    lda #$40
    sta !sprite_timer,x
    lda !sprite_direction,x
    sta !sprite_direction_bak,x
    eor #$01
    tay 
    lda .x_speeds,y
    sta !sprite_x_speed,x
    lda !sprite_level_bak,x
    sta $13BF|!addr
.ret
    rts 

    ;# Do operations to determine which message ID will be shown
.valid
    rol #2
    and #$01
    inc 
    sta $1426|!addr
    lda [$8A],y
    and #$7F
    sta $13BF|!addr
    rts 

.x_speeds
    db $10,$F0

;#########################################################################

go_off_screen:
    ;# Check if it's time to change phases
    lda !sprite_timer,x
    bne .not_done

    ;# Time's up, change to the next phase.
    ;# Also restore the actual direction of the sprite, load the layer 3
    ;# tilemap used for the effect and setup everything else related.
    inc !sprite_state,x
    lda !sprite_direction_bak,x
    sta !sprite_direction,x
    lda #$01
    sta !magic_nmi_codes
    rts 

    ;# Handle Kamek going away from the screen from the side he spawned
.not_done
    ldy !sprite_direction_bak,x
    lda !sprite_x_speed,x
    clc 
    adc .x_accel,y
    sta !sprite_x_speed,x
    jsl !update_sprite_x_pos
    jsl !update_sprite_y_pos

    ;# Handle animations
    ;# very ugly
    lda !sprite_timer,x
    tay 
    lda !sprite_direction_bak,x
    eor .direction,y
    sta !sprite_direction,x
    lda .frames,y
    sta !sprite_animation_frame,x
    rts 


.x_accel
    db $02,$FE

.direction
    db $01,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01,$01
    db $01,$01,$01,$01,$01
    db $00,$00,$00,$00
    db $00,$00,$00
    db $00,$00

.frames
    db $04,$04,$04,$05
    db $05,$05,$05,$04,$04,$04,$04
    db $05,$05,$05,$05,$04,$04,$04,$04
    db $05,$05,$05,$05,$04,$04,$04,$04
    db $05,$05,$05,$05,$04,$04,$04,$04
    db $05,$05,$05,$05,$04,$04,$04,$04
    db $05,$05,$05,$05,$04,$04,$04,$04
    db $06,$06,$06,$06,$06
    db $06,$06,$06,$06
    db $01,$01,$01
    db $02,$02


;#########################################################################

prepare_magic:
    ;# Wait for the timer to run out to actually prepare stuff
    ;# This was done so delays can be applied
    lda !sprite_timer,x
    beq .prepare
    rts 

    ;# Setup everything related for the next phase:
    ;# - Set a timer to enable the palette cycling effect
    ;# - Set the sprite to a hardcoded coordinates outside of the screen
    ;# - Set sprite's initial X speed
    ;# - Read the effect's colors and initiate the layer 3 effect
.prepare
    jsl !get_random
    lda $148D|!addr
    and #$07
    clc 
    adc #$07
    sta !sprite_sparkle_timer,x
    lda #$50
    sta !sprite_timer,x
    ldy !sprite_direction,x
    lda $1A
    clc 
    adc .x_disp_lo,y
    sta !sprite_x_lo,x
    lda $1B
    adc .x_disp_hi,y
    sta !sprite_x_hi,x
    lda $1C
    clc 
    adc #$38
    sta !sprite_y_lo,x
    lda $1D
    adc #$00
    sta !sprite_y_hi,x
    lda .x_speeds,y
    sta !sprite_x_speed,x
    %read_ex_byte($02)
    ldy.w !sprite_state,x
    cpy #$05
    bne .second_pass
    lsr #4
.second_pass
    and #$0F
    cmp #$0C
    bcc .store_color
    lda #$0B
    %Random()
.store_color
    sta !magic_color
    lda !sprite_direction,x
    eor #$01
    sta !magic_direction
    lda #$01
    sta !magic_state
    lda #$0E
    sta !magic_delay
    inc !sprite_state,x
    rts

.x_disp_lo
    db $14,$F0
.x_disp_hi
    db $01,$FF
.x_speeds
    db $D0,$30

;#########################################################################

sprinkle_magic:
    jsr spawn_sparkles
    lda !sprite_timer,x
    bne .no_palette_cycling
    %read_ex_byte($05)
    cmp #$FF
    beq .no_palette_cycling
    and #$07
    asl #4
    ora #$80
    inc 
    sta !palette_color_dest
    lda #$03
    sta !magic_nmi_codes
.no_palette_cycling
    inc !sprite_animation_timer,x
    lda !sprite_animation_timer,x
    lsr #2
    and #$01
    tay 
    lda .frames,y
    sta !sprite_animation_frame,x
    lda !sprite_offscreen_horz,x
    bne .no_sfx
    lda !sprite_animation_timer,x
    and #$07
    bne .no_sfx
    lda.b #!sprinkle_effect_sfx
    sta !sprinkle_effect_port|!addr
.no_sfx
    ldy !sprite_direction,x
    lda !sprite_x_speed,x
    cmp .max_x_speed,y
    beq .skip
    clc 
    adc .accel_x,y
    sta !sprite_x_speed,x
.skip
    lda #$FA
    sta !sprite_y_speed,x
    jsl !update_sprite_x_pos
    jsl !update_sprite_y_pos
    lda !magic_state
    cmp #$03
    bne .not_done
    %read_ex_byte($01)
    and #$20
    beq .double
    lda #$08
    sta !sprite_state,x
.double
    inc !sprite_state,x
.single
    lda #$20
    ldy !sprite_state,x
    cpy #$09
    bne .not_end
    lda #$80
.not_end
    sta !sprite_timer,x
    lda !sprite_direction,x
    eor #$01
    sta !sprite_direction,x
.not_done
    rts 
    
.frames
    db $05,$04
.accel_x
    db $FE,$02
.max_x_speed
    db $AC,$54

spawn_sparkles:
    lda !sprite_sparkle_timer,x
    beq .spawn
    dec !sprite_sparkle_timer,x
    rts 
.spawn
    jsl !get_random
    lda $148D|!addr
    and #$03
    clc 
    adc #$07
    sta !sprite_sparkle_timer,x
    lda !sprite_offscreen_horz,x
    ora !sprite_offscreen_vert,x
    bne .abort
    jsl !get_random
    lda $148D|!addr
    and #$0F
    clc 
    adc #$09
    sta $01
    stz $00
    stz $02
    stz $03
    lda.b #!sparkle_ext_sprite_num+!ExtendedOffset
    %SpawnExtended()
    bcs .abort
    lda #$00
    sta !extended_x_high,y
    lda #$1F
    sta !extended_timer,y
.abort 
    rts

;#########################################################################

init_off_screen:
    lda !sprite_timer,x
    bne .not_done
    lda #$05
    sta !sprite_state,x
    lda !sprite_direction_bak,x
    sta !sprite_direction,x
    lda #$01
    sta !magic_nmi_codes
.not_done
    rts 


;#########################################################################

disappear:
    lda !sprite_timer,x
    beq .kill
    rts 
.kill
    lda #$01
    sta !kamek_cutscene_end_flag
    stz !sprite_status,x
    %read_ex_byte($01)
    bmi .keep_mode 
    lda #$00
    sta !kamek_cutscene_mode
.keep_mode
    %read_ex_byte($06)
    beq .read_define
    cmp #$FF
    beq .keep_song
    sta $1DFB|!addr
    bra .keep_song
.read_define
    lda.b #!boss_music
    sta $1DFB|!addr
.keep_song
    lda #$00
    sta !magic_state
    sta !magic_color
    sta !magic_direction
    lda #$04
    sta !magic_nmi_codes
    rts 

;#########################################################################

setup_ex_bytes:
    lda !extra_byte_1,x
    sta $8A
    lda !extra_byte_2,x
    sta $8B
    lda !extra_byte_3,x
    sta $8C 
    rts 

;#########################################################################

graphics:
    ;# Do not show invalid frames.
    ;# Also multiply frame number by 8.
    lda !sprite_animation_frame,x
    cmp #$07
    bcc .valid
    rts 
.valid 
    asl #3
    sta $02

    ;# Prepare YXPPCCCT info
    lda !sprite_direction,x
    beq .no_x
    lda #$40
.no_x
    ora !15F6,x
    ora $64
    sta $03

    ;# Call GetDrawInfo
    %GetDrawInfo()

    ;# Run GFX routine, should be pretty standard.
    ;# Loops 7 times.
    ldx #$00
.draw_loop
    phx 
    lda $01,s
    clc 
    adc $02
    tax 
    lda .tiles,x
    sta $0302|!addr,y
    lda $03
    eor .props,x
    sta $0303|!addr,y
    lda .x_disp_left,x
    sta $04
    lda $03
    and #$40
    beq ..no_x_flip
    lda .x_disp_right,x
    sta $04
..no_x_flip
    lda $00
    clc 
    adc $04
    sta $0300|!addr,y
    lda $01
    clc 
    adc .y_disp,x
    sta $0301|!addr,y
    phy 
    tya 
    lsr #2
    tay 
    lda .sizes,x
    sta $0460|!addr,y
    ply 
    plx 
    iny #4
    inx 
    cpx #$07
    bcc .draw_loop
    ldx $15E9|!addr
    ldy #$FF
    lda #$06
    %FinishOAMWrite()
    rts 

.x_disp_left
    ..frame_braking
        db $0D      ; hand (8x8)
        db $FE      ; gorro (8x8)
        db $F1      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $F6      ; cabeza (16x16)
        db $00      ; patas (8x8)
        db $05      ; escoba (16x16)
        db $FF      ; filler
    ..frame_still
        db $F8      ; hand (8x8)
        db $FC      ; gorro (8x8)
        db $F0      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $F4      ; cabeza (16x16)
        db $0A      ; escoba (16x16)
        db $01      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_1
        db $F5      ; cara (16x16)
        db $F0      ; nariz (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $0A      ; escoba (16x16)
        db $F1      ; mano (16x16)
        db $F0      ; cara 2 (16x16)
        db $01      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_2
        db $F6      ; cara (16x16)
        db $F1      ; nariz (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $0A      ; escoba (16x16)
        db $F0      ; mano (16x16)
        db $F0      ; cara 2 (16x16)
        db $01      ; patas (8x8)
        db $FF      ; filler
    ..frame_flying_1
        db $F8      ; mano (8x8)
        db $02      ; gorro (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $F0      ; cara (16x16)
        db $F4      ; cabeza (16x16)
        db $06      ; patas (8x8)
        db $0D      ; escoba (16x16)
        db $FF      ; filler
    ..frame_flying_2
        db $F8      ; mano (8x8)
        db $02      ; gorro (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $F0      ; cara (16x16)
        db $F4      ; cabeza (16x16)
        db $06      ; patas (8x8)
        db $0D      ; escoba (16x16)
        db $FF      ; filler
    ..frame_turning
        db $0C      ; escoba (8x8)
        db $05      ; gorro (8x8)
        db $F8      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $FD      ; cabeza (16x16)
        db $01      ; patas (8x8)
        db $04      ; escoba (16x16)
        db $FF      ; filler

.x_disp_right
    ..frame_braking
        db $FB      ; hand (8x8)
        db $0A      ; gorro (8x8)
        db $0F      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $0A      ; cabeza (16x16)
        db $00      ; patas (8x8)
        db $FB      ; escoba (16x16)
        db $FF      ; filler
    ..frame_still
        db $10      ; hand (8x8)
        db $0C      ; gorro (8x8)
        db $10      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $0C      ; cabeza (16x16)
        db $F6      ; escoba (16x16)
        db $07      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_1
        db $0B      ; cara (16x16)
        db $18      ; nariz (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $F6      ; escoba (16x16)
        db $0F      ; mano (16x16)
        db $10      ; cara 2 (16x16)
        db $07      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_2
        db $0A      ; cara (16x16)
        db $17      ; nariz (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $F6      ; escoba (16x16)
        db $10      ; mano (16x16)
        db $10      ; cara 2 (16x16)
        db $07      ; patas (8x8)
        db $FF      ; filler
    ..frame_flying_1
        db $10      ; mano (8x8)
        db $06      ; gorro (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $10      ; cara (16x16)
        db $0C      ; cabeza (16x16)
        db $02      ; patas (8x8)
        db $F3      ; escoba (16x16)
        db $FF      ; filler
    ..frame_flying_2
        db $10      ; mano (8x8)
        db $06      ; gorro (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $10      ; cara (16x16)
        db $0C      ; cabeza (16x16)
        db $02      ; patas (8x8)
        db $F3      ; escoba (16x16)
        db $FF      ; filler
    ..frame_turning
        db $FC      ; escoba (8x8)
        db $03      ; gorro (8x8)
        db $08      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $03      ; cabeza (16x16)
        db $07      ; patas (8x8)
        db $FC      ; escoba (16x16)
        db $FF      ; filler

.y_disp
    ..frame_braking
        db $11      ; hand (8x8)
        db $F5      ; gorro (8x8)
        db $FF      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $F8      ; cabeza (16x16)
        db $0D      ; patas (8x8)
        db $09      ; escoba (16x16)
        db $FF      ; filler
    ..frame_still
        db $08      ; hand (8x8)
        db $F5      ; gorro (8x8)
        db $00      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $F8      ; cabeza (16x16)
        db $06      ; escoba (16x16)
        db $0C      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_1
        db $F6      ; cara (16x16)
        db $FA      ; nariz (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $06      ; escoba (16x16)
        db $FC      ; mano (16x16)
        db $00      ; cara 2 (16x16)
        db $0C      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_2
        db $F5      ; cara (16x16)
        db $F9      ; nariz (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $06      ; escoba (16x16)
        db $FE      ; mano (16x16)
        db $00      ; cara 2 (16x16)
        db $0C      ; patas (8x8)
        db $FF      ; filler
    ..frame_flying_1
        db $08      ; mano (8x8)
        db $F8      ; gorro (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $00      ; cara (16x16)
        db $F8      ; cabeza (16x16)
        db $0A      ; patas (8x8)
        db $04      ; escoba (16x16)
        db $FF      ; filler
    ..frame_flying_2
        db $08      ; mano (8x8)
        db $F8      ; gorro (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $00      ; cara (16x16)
        db $F8      ; cabeza (16x16)
        db $0A      ; patas (8x8)
        db $04      ; escoba (16x16)
        db $FF      ; filler
    ..frame_turning
        db $13      ; escoba (8x8)
        db $F5      ; gorro (8x8)
        db $FF      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $F8      ; cabeza (16x16)
        db $0D      ; patas (8x8)
        db $0B      ; escoba (16x16)
        db $FF      ; filler

.tiles
    ..frame_braking
        db $ED      ; hand (8x8)
        db $B1      ; gorro (8x8)
        db $CD      ; cara (16x16)
        db $C2      ; cuerpo (16x16) [origen]
        db $A0      ; cabeza (16x16)
        db $DC      ; patas (8x8)
        db $EC      ; escoba (16x16)
        db $FF      ; filler
    ..frame_still
        db $CC      ; hand (8x8)
        db $B1      ; gorro (8x8)
        db $C0      ; cara (16x16)
        db $C2      ; cuerpo (16x16) [origen]
        db $A0      ; cabeza (16x16)
        db $EC      ; escoba (16x16)
        db $DC      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_1
        db $A4      ; cara (16x16)
        db $C0      ; nariz (8x8)
        db $C2      ; cuerpo (16x16) [origen]
        db $EC      ; escoba (16x16)
        db $C4      ; mano (16x16)
        db $C0      ; cara 2 (16x16)
        db $DC      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_2
        db $A4      ; cara (16x16)
        db $C0      ; nariz (8x8)
        db $C2      ; cuerpo (16x16) [origen]
        db $EC      ; escoba (16x16)
        db $C4      ; mano (16x16)
        db $C0      ; cara 2 (16x16)
        db $DC      ; patas (8x8)
        db $FF      ; filler
    ..frame_flying_1
        db $CC      ; mano (8x8)
        db $B0      ; gorro (8x8)
        db $C2      ; cuerpo (16x16) [origen]
        db $C0      ; cara (16x16)
        db $A0      ; cabeza (16x16)
        db $DC      ; patas (8x8)
        db $EC      ; escoba (16x16)
        db $FF      ; filler
    ..frame_flying_2
        db $CC      ; mano (8x8)
        db $B0      ; gorro (8x8)
        db $C2      ; cuerpo (16x16) [origen]
        db $C0      ; cara (16x16)
        db $A0      ; cabeza (16x16)
        db $DC      ; patas (8x8)
        db $EC      ; escoba (16x16)
        db $FF      ; filler
    ..frame_turning
        db $ED      ; escoba (8x8)
        db $B1      ; gorro (8x8)
        db $CD      ; cara (16x16)
        db $CE      ; cuerpo (16x16) [origen]
        db $A0      ; cabeza (16x16)
        db $DC      ; patas (8x8)
        db $EC      ; escoba (16x16)
        db $FF      ; filler

.props
    ..frame_braking
        db $80      ; hand (8x8)
        db $00      ; gorro (8x8)
        db $00      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $00      ; cabeza (16x16)
        db $00      ; patas (8x8)
        db $80      ; escoba (16x16)
        db $FF      ; filler
    ..frame_still
        db $00      ; hand (8x8)
        db $00      ; gorro (8x8)
        db $00      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $00      ; cabeza (16x16)
        db $00      ; escoba (16x16)
        db $00      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_1
        db $00      ; cara (16x16)
        db $00      ; nariz (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $00      ; escoba (16x16)
        db $00      ; mano (16x16)
        db $00      ; cara 2 (16x16)
        db $00      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_2
        db $00      ; cara (16x16)
        db $00      ; nariz (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $00      ; escoba (16x16)
        db $80      ; mano (16x16)
        db $00      ; cara 2 (16x16)
        db $00      ; patas (8x8)
        db $FF      ; filler
    ..frame_flying_1
        db $00      ; mano (8x8)
        db $40      ; gorro (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $00      ; cara (16x16)
        db $00      ; cabeza (16x16)
        db $00      ; patas (8x8)
        db $00      ; escoba (16x16)
        db $FF      ; filler
    ..frame_flying_2
        db $00      ; mano (8x8)
        db $40      ; gorro (8x8)
        db $00      ; cuerpo (16x16) [origen]
        db $00      ; cara (16x16)
        db $00      ; cabeza (16x16)
        db $00      ; patas (8x8)
        db $80      ; escoba (16x16)
        db $FF      ; filler
    ..frame_turning
        db $80      ; escoba (8x8)
        db $00      ; gorro (8x8)
        db $00      ; cara (16x16)
        db $00      ; cuerpo (16x16) [origen]
        db $00      ; cabeza (16x16)
        db $00      ; patas (8x8)
        db $80      ; escoba (16x16)
        db $FF      ; filler

.sizes
    ..frame_braking
        db $00      ; hand (8x8)
        db $00      ; gorro (8x8)
        db $02      ; cara (16x16)
        db $02      ; cuerpo (16x16) [origen]
        db $02      ; cabeza (16x16)
        db $00      ; patas (8x8)
        db $02      ; escoba (16x16)
        db $FF      ; filler
    ..frame_still
        db $00      ; hand (8x8)
        db $00      ; gorro (8x8)
        db $02      ; cara (16x16)
        db $02      ; cuerpo (16x16) [origen]
        db $02      ; cabeza (16x16)
        db $02      ; escoba (16x16)
        db $00      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_1
        db $02      ; cara (16x16)
        db $00      ; nariz (8x8)
        db $02      ; cuerpo (16x16) [origen]
        db $02      ; escoba (16x16)
        db $02      ; mano (16x16)
        db $02      ; cara 2 (16x16)
        db $00      ; patas (8x8)
        db $FF      ; filler
    ..frame_yapping_2
        db $02      ; cara (16x16)
        db $00      ; nariz (8x8)
        db $02      ; cuerpo (16x16) [origen]
        db $02      ; escoba (16x16)
        db $02      ; mano (16x16)
        db $02      ; cara 2 (16x16)
        db $00      ; patas (8x8)
        db $FF      ; filler
    ..frame_flying_1
        db $00      ; mano (8x8)
        db $00      ; gorro (8x8)
        db $02      ; cuerpo (16x16) [origen]
        db $02      ; cara (16x16)
        db $02      ; cabeza (16x16)
        db $00      ; patas (8x8)
        db $02      ; escoba (16x16)
        db $FF      ; filler
    ..frame_flying_2
        db $00      ; mano (8x8)
        db $00      ; gorro (8x8)
        db $02      ; cuerpo (16x16) [origen]
        db $02      ; cara (16x16)
        db $02      ; cabeza (16x16)
        db $00      ; patas (8x8)
        db $02      ; escoba (16x16)
        db $FF      ; filler
    ..frame_turning
        db $00      ; escoba (8x8)
        db $00      ; gorro (8x8)
        db $02      ; cara (16x16)
        db $02      ; cuerpo (16x16) [origen]
        db $02      ; cabeza (16x16)
        db $00      ; patas (8x8)
        db $02      ; escoba (16x16)
        db $FF      ; filler

