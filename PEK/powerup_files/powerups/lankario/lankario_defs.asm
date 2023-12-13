;##################################################################################################
;# Powerup: Lankario (AKA Lankio AKA Weird Mario)
;# Author: Nintendo (Original), SubconsciousEye (Port)
;# Description: The Weird Mushroom Powerup from Super Mario Maker.

;################################################
;# General behavior

;# Enable spinjumping with this powerup.
!lankario_can_spinjump = !yes

;# Enable climbing with this powerup.
!lankario_can_climb = !yes

;# Enable crouching with this powerup.
!lankario_can_crouch = !yes

;# Enable sliding with this powerup.
!lankario_can_slide = !yes

;# Enable carrying items with this powerup.
!lankario_can_carry_items = !yes

;# Enable riding Yoshi with this powerup.
!lankario_can_ride_yoshi = !yes

;# Enable easier Yoshi flight with this powerup.
!lankario_easy_yoshi_flight = !no


;################################################
;# Powerdown

;# Which animation will be used when being hurt
;# Available:
;#   - "shrink": Plays the powerup shrinking animation
;#   - "palette": Cycles through some palettes
;#   - "smoke": Leaves a smoke particle while making the player invisible
;# Note that if this powerup uses custom code and not macros this setting will be ignored.
!lankario_powerdown_action = "shrink"

;# Which powerup number the player will have after being hurt
!lankario_powerdown_power_num = $00

;# SFX number & port when getting hurt while using this powerup
!lankario_powerdown_sfx_num = $04
!lankario_powerdown_sfx_port = $1DF9|!addr


;################################################
;# Item ID

;# Item ID associated to this powerup.
!lankario_item_id = $05


;################################################
;# Graphics/Player image

;# Player 1's graphics index for this powerup.
!lankario_p1_gfx_index = $08

;# Player 2's graphics index for this powerup.
!lankario_p2_gfx_index = $08

;# Player 1's EXTRA graphics index for this powerup.
!lankario_p1_extra_gfx_index = $08

;# Player 2's EXTRA graphics index for this powerup.
!lankario_p2_extra_gfx_index = $08


;################################################
;# Player palette

;# Player 1's palette index
!lankario_p1_palette_index = $FF

;# Player 2's palette index
!lankario_p2_palette_index = $04


;################################################
;# Graphical options

;# Determines the Y displacement where the water splash will appear in relation to the player
;# This is affected by collision data
!lankario_water_y_disp = $0010

;# Same as above, but when the player is riding Yoshi
!lankario_water_y_disp_on_yoshi = $0004


;################################################
;# Hitbox, interaction & collision options

;# Player's hitbox X displacement from player's origin
!lankario_hitbox_x_disp = $0002

;# Player's hitbox width
!lankario_hitbox_width = $0C

;# Player's hitbox Y displacement from player's origin
!lankario_hitbox_y_disp = $0006

;# Player's hitbox height
!lankario_hitbox_height = $1A

;# Player's hitbox Y displacement from player's origin while crouching
!lankario_hitbox_y_disp_crouching = $0014

;# Player's hitbox height while crouching
!lankario_hitbox_height_crouching = $0C

;# Player's hitbox Y displacement from player's origin while mounted on Yoshi
!lankario_hitbox_y_disp_on_yoshi = $0010

;# Player's hitbox height while mounted on Yoshi
!lankario_hitbox_height_on_yoshi = $0020

;# Player's hitbox Y displacement from player's origin while crouching and mounted on Yoshi
!lankario_hitbox_y_disp_crouching_on_yoshi = $0018

;# Player's hitbox height while crouching and mounted on Yoshi
!lankario_hitbox_height_crouching_on_yoshi = $18


;################################################
;# Powerup-specific customization

;# General Defines
!lankario_timer = !player_powerup_timer
!lankario_backup_y_speed = !player_powerup_states
!lankario_backup_x_speed = !player_powerup_misc0

;# Gravity "Multipliers" used to mod the original
;#  rise is when y-speed is negative.
!lankario_gravity_rise_rate = 28/32
!lankario_gravity_fall_rate = 1/2


;# Use alternate horizontal physics?
;#  setting this will adjust the movement physics.
;#  (this is akin to Luigi's physics from SMA2:SMW, assuming you didn't change the data values)
;# Note that this doesn't affect swimming.
!lankario_useAltHorzPhysics = !yes

;# Default Physics Flags (Powerup Give Transition)
if !lankario_useAltHorzPhysics == !yes
    !lankario_physicsflags = %01000011
else
    !lankario_physicsflags = %00000011
endif


;#######################
;# Mandatory macro (do not touch).

%setup_general_defines(!lankario_powerup_num)