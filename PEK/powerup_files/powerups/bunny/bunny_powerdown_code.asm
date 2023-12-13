;##################################################################################################
;# Powerup: Bunny Mario
;# Author: Nintendo (Original), SubconsciousEye (Port)
;# Description: The Super Carrot Powerup from Super Mario Land 2, with near-accurate behavior.
;#
;# This code will once run whenever Mario gets hurt while using this powerup.
;#
;# Note: In order to use this code, set the powerdown effect to Custom in the defs file.
lda #%00000010
sta !player_physics_flags
    %powerdown_!{bunny_powerdown_action}(!bunny_powerdown_power_num, !bunny_powerdown_sfx_num, !bunny_powerdown_sfx_port)
    rts