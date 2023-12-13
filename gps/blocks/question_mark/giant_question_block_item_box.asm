; Block specific defines
!SoundEffect = $0B			; Set to zero to play no sound effect
!APUPort = $1DFC|!addr		; Refer to the RAM Map or AMK for more information

!Map16 = $072E				; The Map16 tile the block turns into (top left corner)

!shake_timer = $00			; How long the ground is shaking

!item_memory_dependent = 0	; Makes the block stay collected
!invisible_block = 0		; Not solid, doesn't detect sprites, can only be hit from below
; 0 for false, 1 for true


; Placed there for technical reasons
incsrc giant_question_block_base.asm


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
	print "Sets the item box item to $",hex(!Sprite),"."
else
	print "Puts sprite $",hex(!Sprite)," into the item box."
endif
