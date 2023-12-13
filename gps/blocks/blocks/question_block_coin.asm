!SoundEffect = $02			; Set to zero to play no sound effect
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
!XPlacement = $00			; Remember: $01-$7F moves the coin to the right and $80-$FF to the left.
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

print "A question mark block which contains a coin."