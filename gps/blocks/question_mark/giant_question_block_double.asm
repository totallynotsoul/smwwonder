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
!RAM = $19	; This determines which item it spawns whether it is to the zero or not.
			; See the RAM map for more details

; The first argument is if Mario is small, the second for big
SpriteNumber:
db $74,$75

IsCustom:
db $00,$00	; $00 (or any other even number) for normal, $01 (or any other odd number) for custom

State:
db $08,$08	; Should be either $08 or $09

RAM_1540_vals:
db $3E,$3E	; If you use powerups, this should be $3E
			; Carryable sprites uses it as the stun timer

XPlacement:
db $08,$08	; Remember: $01-$7F moves the sprite to the right and $80-$FF to the left.

YPlacement:
db $00,$00	; Remember: $01-$7F moves the sprite to the bottom and $80-$FF to the top.

ExtraByte1:
db $00,$00	; First extra byte (only applyable if extra bytes are enabled)

ExtraByte2:
db $00,$00	; Second extra byte

ExtraByte3:
db $00,$00	; Third extra byte

ExtraByte4:
db $00,$00	; Fourth extra byte

SpawnThing:
	LDY #$00
	LDA !RAM
	BEQ +
	LDY #$01
+	LDA IsCustom,y
	LSR
	LDA SpriteNumber,y
	PHY
	%spawn_sprite_block()
	TAX
	PLY
	LDA XPlacement,y
	STA $00
	LDA YPlacement,y
	STA $01
	TXA
	%move_spawn_relative()

	LDA State,y
	STA !14C8,x
	LDA RAM_1540_vals,y
	STA !1540,x
	LDA #$D0
	STA !AA,x
	LDA #$2C
	STA !154C,x

	LDA ExtraByte1,y
	STA !extra_byte_1,x
	LDA ExtraByte2,y
	STA !extra_byte_2,x
	LDA ExtraByte3,y
	STA !extra_byte_3,x
	LDA ExtraByte4,y
	STA !extra_byte_4,x

	LDA !190F,x
	BPL .Return
	LDA #$10
	STA !15AC,x

.Return:
RTS

print "A giant question mark block which spawns a fire flower when the player is big, otherwise a mushroom."