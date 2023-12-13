;##################################################################################################
;# Powerup: Cape Mario
;# Author: Nintendo
;# Description: Default powerup $02 for Mario. Behaves exactly like in the original game.

;################################################
;# General behavior

;# Enable spinjumping with this powerup.
!cape_can_spinjump = !yes

;# Enable climbing with this powerup.
!cape_can_climb = !yes

;# Enable crouching with this powerup.
!cape_can_crouch = !yes

;# Enable sliding with this powerup.
!cape_can_slide = !yes

;# Enable carrying items with this powerup.
!cape_can_carry_items = !yes

;# Enable riding Yoshi with this powerup.
!cape_can_ride_yoshi = !yes

;# Enable easier Yoshi flight with this powerup.
!cape_easy_yoshi_flight = !yes


;################################################
;# Powerdown

;# Which animation will be used when being hurt
;# Available:
;#   - "shrink": Plays the powerup shrinking animation
;#   - "palette": Cycles through some palettes
;#   - "smoke": Leaves a smoke particle while making the player invisible
;# Note that if this powerup uses custom code and not macros this setting will be ignored.
!cape_powerdown_action = "shrink"

;# Which powerup number the player will have after being hurt
!cape_powerdown_power_num = $00

;# SFX number & port when getting hurt while using this powerup
!cape_powerdown_sfx_num = $04
!cape_powerdown_sfx_port = $1DF9


;################################################
;# Item ID

;# Item ID associated to this powerup.
!cape_item_id = $03


;################################################
;# Graphics/Player image

;# Player 1's graphics index for this powerup.
!cape_p1_gfx_index = $01

;# Player 2's graphics index for this powerup.
!cape_p2_gfx_index = $01

;# Player 1's EXTRA graphics index for this powerup.
!cape_p1_extra_gfx_index = $02

;# Player 2's EXTRA graphics index for this powerup.
!cape_p2_extra_gfx_index = $02


;################################################
;# Player palette

;# Player 1's palette index
!cape_p1_palette_index = $FF

;# Player 2's palette index
!cape_p2_palette_index = $04


;################################################
;# Cape behavior

;# How many frames the player will be spinning upon pressing X/Y
!cape_spin_frames = 18

;# Sound effect for the spinning attack.
!cape_spin_sfx = $04

;# Port for the sound effect above.
!cape_spin_sfx_port = $1DFC


;################################################
;# Graphical options

;# Determines the Y displacement where the water splash will appear in relation to the player
;# This is affected by collision data
!cape_water_y_disp = $0010

;# Same as above, but when the player is riding Yoshi
!cape_water_y_disp_on_yoshi = $0004


;################################################
;# Hitbox, interaction & collision options

;# Player's hitbox X displacement from player's origin
!cape_hitbox_x_disp = $0002

;# Player's hitbox width
!cape_hitbox_width = $0C

;# Player's hitbox Y displacement from player's origin
!cape_hitbox_y_disp = $0006

;# Player's hitbox height
!cape_hitbox_height = $1A

;# Player's hitbox Y displacement from player's origin while crouching
!cape_hitbox_y_disp_crouching = $0014

;# Player's hitbox height while crouching
!cape_hitbox_height_crouching = $0C

;# Player's hitbox Y displacement from player's origin while mounted on Yoshi
!cape_hitbox_y_disp_on_yoshi = $0010

;# Player's hitbox height while mounted on Yoshi
!cape_hitbox_height_on_yoshi = $0020

;# Player's hitbox Y displacement from player's origin while crouching and mounted on Yoshi
!cape_hitbox_y_disp_crouching_on_yoshi = $0018

;# Player's hitbox height while crouching and mounted on Yoshi
!cape_hitbox_height_crouching_on_yoshi = $18


;################################################
;# Mandatory macro (do not touch).

%setup_general_defines(!cape_powerup_num)