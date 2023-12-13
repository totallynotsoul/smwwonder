; Block specific defines
!SoundEffect = $0B			; Set to zero to play no sound effect
!APUPort = $1DFC|!addr		; Refer to the RAM Map or AMK for more information

!bounce_num			= $03	; See RAM $1699 for more details. If set to 0, the block changes into the Map16 tile directly
!bounce_direction	= $00	; Should be generally $00
!bounce_block		= $0D	; See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $00	; YXPPCCCT properties

; If !bounce_block is $FF.
!bounce_Map16 = $0132		; Changes into the Map16 tile directly (also used if !bounce_num is 0x00)
!bounce_tile = $2A			; The tile number (low byte) if BBU is enabled

!item_memory_dependent = 0	; Makes the block stay collected
!invisible_block = 0		; Not solid, doesn't detect sprites, can only be hit from below
!activate_per_spin_jump = 0	; Activateable with a spin jump (doesn't work if invisible)
; 0 for false, 1 for true


; Placed there for technical reasons
incsrc question_block_base.asm


; Spawn specific defines
!UseItemBoxSpecial	= 0	; 1 = true, 0 = false, anything else is bad

!Sprite = $74	; This depends whether you use the item box special or not
				; If you don't use it, it simply is the $9E (sprite number) value.
				; If you do use it, however, the value is stored into $0DC2 directly.


; Code stuff
SpawnThing:
	LDA.b #!Sprite-($73*(1-!UseItemBoxSpecial))	; Shift offset
	STA $0DC2|!addr

.Return:
RTS

if !UseItemBoxSpecial
	print "A question mark block which sets the item box item to $",hex(!Sprite),"."
else
	print "A question mark block which puts sprite $",hex(!Sprite)," into the item box."
endif
