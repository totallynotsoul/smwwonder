; Block specific defines
!SoundEffect = $02			; Set to zero to play no sound effect
!APUPort = $1DFC|!addr		; Refer to the RAM Map or AMK for more information

!bounce_num			= $03	; See RAM $1699 for more details. If set to 0, the block changes into the Map16 tile directly
!bounce_direction	= $00	; Should be generally $00
!bounce_block		= $0D	; See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $08	; YXPPCCCT properties

; If !bounce_block is $FF.
!bounce_Map16 = $0132		; Changes into the Map16 tile directly (also used if !bounce_num is 0x00)
!bounce_tile = $2A			; The tile number (low byte) if BBU is enabled

!item_memory_dependent = 1	; Makes the block stay collected
!invisible_block = 0		; Not solid, doesn't detect sprites, can only be hit from below
!activate_per_spin_jump = 1	; Activateable with a spin jump (doesn't work if invisible)
; 0 for false, 1 for true


; Placed there for technical reasons
incsrc question_block_base.asm


; Spawn specific defines
!Sprite = $75				; sprite number
!IsCustom = CLC	 			; CLC for normal, SEC custom sprite
!State = $08				; $08 for normal, $09 for carryable sprites
!1540_val = $3E				; If you use powerups, this should be $3E
							; Carryable sprites use it as the stun timer

!ExtraByte1 = $00			; First extra byte
!ExtraByte2 = $00			; Second extra byte
!ExtraByte3 = $00			; Third extra byte
!ExtraByte4 = $00			; Fourth extra byte

!XPlacement = $00			; Remember: $01-$7F moves the sprite to the right and $80-$FF to the left.
!YPlacement = $00			; Remember: $01-$7F moves the sprite to the bottom and $80-$FF to the top.


; Code stuff
SpawnThing:
	LDA #!Sprite
	!IsCustom

	%spawn_sprite_block()
	TAX
	if !XPlacement
		LDA #!XPlacement
		STA $00
	else
		STZ $00
	endif
	if !YPlacement
		LDA #!YPlacement
		STA $01
	else
		STZ $01
	endif
	TXA
	%move_spawn_relative()

	LDA #!State
	STA !14C8,x
	LDA #!1540_val
	STA !1540,x
	LDA #$D0
	STA !AA,x
	LDA #$2C
	STA !154C,x

	LDA #!ExtraByte1
	STA !extra_byte_1,x
	LDA #!ExtraByte2
	STA !extra_byte_2,x
	LDA #!ExtraByte3
	STA !extra_byte_3,x
	LDA #!ExtraByte4
	STA !extra_byte_4,x

	LDA !190F,x
	BPL .Return
	LDA #$10
	STA !15AC,x

.Return:
RTS

print "A question mark block which spawns sprite $",hex(!Sprite),"."