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
!XPlacement = $08		; Remember: $01-$7F moves the egg to the right and $80-$FF to the left.
!YPlacement = $00		; Remember: $01-$7F moves the egg to the bottom and $80-$FF to the top.

!RAM = $19	; This determines which item it spawns whether it is to the zero or not.
		; See the RAM map for more details

; The first argument is if Mario is small, the second for big
SpriteNumber:
db $74,$75

EggColour:
db $05,$09
; $01 for palette 8
; $03 for palette 9
; $05 for yellow
; $07 for blue
; $09 for red
; $0B for green
; $0D for palette E
; $0F for palette F

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
	LDY #$00
	LDA !RAM
	BEQ +
	LDY #$01
+	LDA SpriteNumber,y
	STA	!151C,x
	LDA	!15F6,x
	AND	#$F1
	ORA	EggColour,y
	STA	!15F6,x
	%move_spawn_into_block()
.Return:
RTS

print "A giant question mark block which spawns by default a mushroom if Mario is small, else a fire flower. Both appear in an egg."