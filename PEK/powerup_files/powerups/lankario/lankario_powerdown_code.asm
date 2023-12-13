;##################################################################################################
;# Powerup: Lankario (AKA Lankio AKA Weird Mario)
;# Author: Nintendo (Original), SubconsciousEye (Port)
;# Description: The Weird Mushroom Powerup from Super Mario Maker.
;#
;# This code will once run whenever Mario gets hurt while using this powerup.
;#
;# Note: In order to use this code, set the powerdown effect to Custom in the defs file.
	
lda #%00000010
sta !player_physics_flags
    %powerdown_!{lankario_powerdown_action}(!lankario_powerdown_power_num, !lankario_powerdown_sfx_num, !lankario_powerdown_sfx_port)
    rts