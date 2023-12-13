; Block specific defines
!SoundEffect = $02			; Set to zero to play no sound effect
!APUPort = $1DFC|!addr		; Refer to the RAM Map or AMK for more information

!Map16 = $072E				; The Map16 tile the block turns into (top left corner)

!shake_timer = $3E			; How long the ground is shaking

!item_memory_dependent = 0	; Makes the block stay collected
!invisible_block = 0		; Not solid, doesn't detect sprites, can only be hit from below
; 0 for false, 1 for true


; Placed there for technical reasons
incsrc giant_question_block_base.asm


; Spawn specific defines
!egg_color		= $0B	; $01 for palette 8
						; $03 for palette 9
						; $05 for yellow
						; $07 for blue
						; $09 for red
						; $0B for green
						; $0D for palette E
						; $0F for palette F
						; Note: This value also affects the yoshi color!
				
!egg_sprite		= $35	; Sprite that will come from the egg
				
!egg_1up		= $78	; Sprite that will spawn if there is a yoshi. By default, 1up.
						; Note: This value WON'T be used if you aren't spawning Yoshi from an egg.

!XPlacement = $08		; Remember: $01-$7F moves the egg to the right and $80-$FF to the left.
!YPlacement = $00		; Remember: $01-$7F moves the egg to the bottom and $80-$FF to the top.

; Code stuff
SpawnThing:
	JSL $02A9E4|!bank
	BMI .Return
	TYX
	STX $185E|!addr
	LDA #$2C
	STA !9E,x
	JSL $07F7D2|!bank

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

	LDA #$09
	STA !14C8,x
	LDA #$D0
	STA !AA,x
	LDA #$2C
	STA !154C,x

	LDA !190F,x
	BPL +
	LDA #$10
	STA !15AC,x
+
; Copied and modified from LX5's egg blocks
if !egg_sprite == $2D || !egg_sprite == $35
	LDY	#$0B
.loop
	LDA	!14C8,y
	CMP	#$08
	BCC	.next_slot
	LDA	!9E,y
	CMP	#$2D
	BNE	.next_slot
	LDA	#!egg_1up
	BRA	.found_and_store
.next_slot
	DEY	
	BPL	.loop
	LDA	#!egg_sprite
	LDY	$18E2|!addr
	BEQ	.found_and_store
	LDA	#!egg_1up
.found_and_store
else
	LDA	#!egg_sprite
endif
	STA	!151C,x
	LDA	!15F6,x
	AND	#$F1
	ORA	#!egg_color
	STA	!15F6,x
.Return:
RTS


if !egg_sprite == $2D || !egg_sprite == $35
print "A giant question mark block which spawns sprite $",hex(!egg_1up)," if Yoshi exists, else $",hex(!egg_sprite),"."
else
print "A giant question mark block which spawns sprite $",hex(!egg_sprite)," in an egg."
endif
