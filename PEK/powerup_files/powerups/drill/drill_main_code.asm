!ButtonToDrill = $08
!FREERAM_BURROWED = $1E00|!addr
;##################################################################################################
;# Powerup: Drill Mario
;# Author: Soul & yoshifanatic1
;# Description: Default powerup $01 for Mario. Behaves exactly like the original game.
;#
;# This code is run every frame when Mario has this powerup.
LDA $18
CMP #$08
STA
	rts
.return
rts