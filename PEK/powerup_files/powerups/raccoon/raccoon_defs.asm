;##################################################################################################
;# Powerup: Cape Mario
;# Author: Nintendo
;# Description: Default powerup $02 for Mario. Behaves exactly like in the original game.

;################################################
;# General behavior

;# Enable spinjumping with this powerup.
!raccoon_can_spinjump = !yes

;# Enable climbing with this powerup.
!raccoon_can_climb = !yes

;# Enable crouching with this powerup.
!raccoon_can_crouch = !yes

;# Enable sliding with this powerup.
!raccoon_can_slide = !yes

;# Enable carrying items with this powerup.
!raccoon_can_carry_items = !yes

;# Enable riding Yoshi with this powerup.
!raccoon_can_ride_yoshi = !yes

;# Enable easier Yoshi flight with this powerup.
!raccoon_easy_yoshi_flight = !yes


;################################################
;# Powerdown

;# Which animation will be used when being hurt
;# Available:
;#   - "shrink": Plays the powerup shrinking animation
;#   - "palette": Cycles through some palettes
;#   - "smoke": Leaves a smoke particle while making the player invisible
;# Note that if this powerup uses custom code and not macros this setting will be ignored.
!raccoon_powerdown_action = "shrink"

;# Which powerup number the player will have after being hurt
!raccoon_powerdown_power_num = $00

;# SFX number & port when getting hurt while using this powerup
!raccoon_powerdown_sfx_num = $04
!raccoon_powerdown_sfx_port = $1DF9


;################################################
;# Item ID

;# Item ID associated to this powerup.
!raccoon_item_id = $ff ;07


;################################################
;# Graphics/Player image

;# Player 1's graphics index for this powerup.
!raccoon_p1_gfx_index = $05

;# Player 2's graphics index for this powerup.
!raccoon_p2_gfx_index = $05

;# Player 1's EXTRA graphics index for this powerup.
!raccoon_p1_extra_gfx_index = $05

;# Player 2's EXTRA graphics index for this powerup.
!raccoon_p2_extra_gfx_index = $05


;################################################
;# Player palette

;# Player 1's palette index
!raccoon_p1_palette_index = $05

;# Player 2's palette index
!raccoon_p2_palette_index = $04


;################################################
;# Cape behavior

;# How many frames the player will be spinning upon pressing X/Y
!raccoon_spin_frames = 18

;# Sound effect for the spinning attack.
!raccoon_spin_sfx = $04

;# Port for the sound effect above.
!raccoon_spin_sfx_port = $1DFC


;################################################
;# Graphical options

;# Determines the Y displacement where the water splash will appear in relation to the player
;# This is affected by collision data
!raccoon_water_y_disp = $0010

;# Same as above, but when the player is riding Yoshi
!raccoon_water_y_disp_on_yoshi = $0004


;################################################
;# Hitbox, interaction & collision options

;# Player's hitbox X displacement from player's origin
!raccoon_hitbox_x_disp = $0002

;# Player's hitbox width
!raccoon_hitbox_width = $0C

;# Player's hitbox Y displacement from player's origin
!raccoon_hitbox_y_disp = $0006

;# Player's hitbox height
!raccoon_hitbox_height = $1A

;# Player's hitbox Y displacement from player's origin while crouching
!raccoon_hitbox_y_disp_crouching = $0014

;# Player's hitbox height while crouching
!raccoon_hitbox_height_crouching = $0C

;# Player's hitbox Y displacement from player's origin while mounted on Yoshi
!raccoon_hitbox_y_disp_on_yoshi = $0010

;# Player's hitbox height while mounted on Yoshi
!raccoon_hitbox_height_on_yoshi = $0020

;# Player's hitbox Y displacement from player's origin while crouching and mounted on Yoshi
!raccoon_hitbox_y_disp_crouching_on_yoshi = $0018

;# Player's hitbox height while crouching and mounted on Yoshi
!raccoon_hitbox_height_crouching_on_yoshi = $18


;################################################
;# Powerup-specific customization

;# Hover Mode Defines
!raccoon_thwack_timer = !player_powerup_timer
!raccoon_tail_flag = !player_powerup_states
!raccoon_freeflight = !player_powerup_misc0
!raccoon_spoof_timer = !player_powerup_misc1

;# Default Physics Flags (Powerup Give Transition)
!raccoon_physicsflags = %00000011


;################################################
;# Mandatory macro (do not touch).

%setup_general_defines(!raccoon_powerup_num)