; Block specific defines
!SoundEffect = $02			; Set to zero to play no sound effect
!APUPort = $1DFC|!addr		; Refer to the RAM Map or AMK for more information

!Map16 = $072E				; The Map16 tile the block turns into (top left corner)

!shake_timer = $00			; How long the ground is shaking

!item_memory_dependent = 0	; Makes the block stay collected
!invisible_block = 0		; Not solid, doesn't detect sprites, can only be hit from below
; 0 for false, 1 for true


; Placed there for technical reasons
incsrc giant_question_block_base.asm


; Spawn specific defines
!XPlacement = $08			; Remember: $01-$7F moves the coin to the right and $80-$FF to the left.
!YPlacement = $F0			; Remember: $01-$7F moves the coin to the bottom and $80-$FF to the top.


; Code stuff
SpawnThing:
	LDX #$03
-	LDA $17D0|!addr,x
	BEQ .found_free
	DEX
	BPL -
	DEC $1865|!addr
	BPL .dont_reset
	LDA #$03
	STA $1865|!addr
.dont_reset
	LDX $1865|!addr
.found_free
	JSL $05B34A|!bank
	INC $17D0|!addr,x
	LDA $9A
	AND #$F0
	CLC : ADC #!XPlacement
	STA $17E0|!addr,x
	LDA $9B
if !XPlacement < $80
	ADC #$00
else
	SBC #$00
endif
	STA $17EC|!addr,x
	LDA $98
	AND #$F0
	CLC : ADC #!YPlacement
	STA $17D4|!addr,x
	LDA $99
if !YPlacement < $80
	ADC #$00
else
	SBC #$00
endif
	STA $17E8|!addr,x
	LDA $1933|!addr
	STA $17E4|!addr,x
	LDA #$D0
	STA $17D8|!addr,x

.Return:
RTS

print "A giant question mark block with a coin inside."