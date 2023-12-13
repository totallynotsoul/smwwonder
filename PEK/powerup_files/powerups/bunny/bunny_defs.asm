;##################################################################################################
;# Powerup: Bunny Mario
;# Author: Nintendo (Original), SubconsciousEye (Port)
;# Description: The Super Carrot Powerup from Super Mario Land 2, with near-accurate behavior.

;################################################
;# General behavior

;# Enable spinjumping with this powerup.
!bunny_can_spinjump = !no

;# Enable climbing with this powerup.
!bunny_can_climb = !yes

;# Enable crouching with this powerup.
!bunny_can_crouch = !yes

;# Enable sliding with this powerup.
!bunny_can_slide = !yes

;# Enable carrying items with this powerup.
!bunny_can_carry_items = !yes

;# Enable riding Yoshi with this powerup.
!bunny_can_ride_yoshi = !yes

;# Enable easier Yoshi flight with this powerup.
!bunny_easy_yoshi_flight = !yes


;################################################
;# Powerdown

;# Which animation will be used when being hurt
;# Available:
;#   - "shrink": Plays the powerup shrinking animation
;#   - "palette": Cycles through some palettes
;#   - "smoke": Leaves a smoke particle while making the player invisible
;# Note that if this powerup uses custom code and not macros this setting will be ignored.
!bunny_powerdown_action = "shrink"

;# Which powerup number the player will have after being hurt
!bunny_powerdown_power_num = $00

;# SFX number & port when getting hurt while using this powerup
!bunny_powerdown_sfx_num = $04
!bunny_powerdown_sfx_port = $1DF9|!addr


;################################################
;# Item ID

;# Item ID associated to this powerup.
!bunny_item_id = $06


;################################################
;# Graphics/Player image

;# Player 1's graphics index for this powerup.
!bunny_p1_gfx_index = $09

;# Player 2's graphics index for this powerup.
!bunny_p2_gfx_index = $09

;# Player 1's EXTRA graphics index for this powerup.
!bunny_p1_extra_gfx_index = $09

;# Player 2's EXTRA graphics index for this powerup.
!bunny_p2_extra_gfx_index = $09


;################################################
;# Player palette

;# Player 1's palette index
!bunny_p1_palette_index = $FF

;# Player 2's palette index
!bunny_p2_palette_index = $04


;################################################
;# Graphical options

;# Determines the Y displacement where the water splash will appear in relation to the player
;# This is affected by collision data
!bunny_water_y_disp = $0010

;# Same as above, but when the player is riding Yoshi
!bunny_water_y_disp_on_yoshi = $0004


;################################################
;# Hitbox, interaction & collision options

;# Player's hitbox X displacement from player's origin
!bunny_hitbox_x_disp = $0002

;# Player's hitbox width
!bunny_hitbox_width = $0C

;# Player's hitbox Y displacement from player's origin
!bunny_hitbox_y_disp = $0006

;# Player's hitbox height
!bunny_hitbox_height = $1A

;# Player's hitbox Y displacement from player's origin while crouching
!bunny_hitbox_y_disp_crouching = $0014

;# Player's hitbox height while crouching
!bunny_hitbox_height_crouching = $0C

;# Player's hitbox Y displacement from player's origin while mounted on Yoshi
!bunny_hitbox_y_disp_on_yoshi = $0010

;# Player's hitbox height while mounted on Yoshi
!bunny_hitbox_height_on_yoshi = $0020

;# Player's hitbox Y displacement from player's origin while crouching and mounted on Yoshi
!bunny_hitbox_y_disp_crouching_on_yoshi = $0018

;# Player's hitbox height while crouching and mounted on Yoshi
!bunny_hitbox_height_crouching_on_yoshi = $18


;################################################
;# Powerup-specific customization

;# Hover Mode Defines
!bunny_hover_timer = !player_powerup_timer
!bunny_states = !player_powerup_states
!bunny_backup_y_speed = !player_powerup_misc0
!bunny_backup_x_speed = !player_powerup_misc1

;# Number of frames to wait for hover.
!bunny_hover_frames = #$0c	;0c

;# Bit to determine the ear "flap" frames.
!bunny_ear_flap = #$04	;08 timer

;# SFX number & port for ears "flap"
!bunny_ear_sfx_num = #$21
!bunny_ear_sfx_port = $1DFC|!addr


;# SFX number & port for auto-hop on land.
!bunny_jump_sfx_num = #$35
!bunny_jump_sfx_port = $1DFC|!addr

;# SFX number & port for auto-hop in water.
!bunny_swim_sfx_num = #$0E
!bunny_swim_sfx_port = $1DF9|!addr

;# Custom Sounds Option
;#  if set to !no, it'll use vanilla sounds.
!bunny_useCustomSounds = !no

if !bunny_useCustomSounds == !no
    !bunny_jump_sfx_num := read1($00D65F|!bank)
    !bunny_jump_sfx_port := read2($00D661|!bank)
    !bunny_swim_sfx_num := read1($00DAAA|!bank)
    !bunny_swim_sfx_port := read2($00DAAC|!bank)
endif


;# Auto-Hop Land Speed Options

;# Use vanilla's jump speeds?
;#  not recommended in case you happen to be moving too fast.
!bunny_useOrigJumpSpeeds = !no

;# Calculate values from vanilla's jump speeds?
;#  this is handled weirdly, and may be removed in future versions.
!bunny_calcFromOrigJumpSpeeds = !no

;# Default Physics Flags (Powerup Give Transition)
!bunny_physicsflags = %00000010


;#######################
;# Mandatory macro (do not touch).

%setup_general_defines(!bunny_powerup_num)