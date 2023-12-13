;;;;;;;;;;;;;;;;;; DSX Macros ;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;
;; Macro borrowed (and slightly modified) from SA-1 patch
;;;;;;;;;;;;;

; A is 16-bit, Y is 8-bit.
macro transferslot(slot, bytes, shift)
	LDA #($7C00+(<slot>*256)+<shift>)	; \ VRAM address + line*slot
	STA $2116							; /
	LDA #((!DSXBUFFER&65535)+(<slot>*512)+(<shift>*2))	;\ Set Buffer location
	STA $02												; /
	LDA #<bytes>										; \ Set bytes to transfer
	STA $05												; /
	STY $420B											; Run DMA.
endmacro

retroDSX:
	ldy #$80
	sty $2115
	lda #$1801
	sta $00
	ldy.b #!DSXBUFFER/65536
	sty $04
	ldy #$01
	
	txa
	asl
	tax			;upload gfx
	jsr (dsx_modes-$02,x)
	dey
	sty !SLOTSUSED
Return:		
	rts 

dsx_modes:
	dw .transfer_one
	dw .transfer_two
	dw .transfer_three
	dw .transfer_four

.transfer_one		;transfer a 32x32 square (one slot)
	%transferslot(0, $0080, $C0)
	%transferslot(1, $0080, $C0)	
	%transferslot(2, $0080, $C0)
	%transferslot(3, $0080, $C0)
	rts
.transfer_two		;transfer a 64x32 rectangle (two slots)
	%transferslot(0, $0100|!base2, $80)
	%transferslot(1, $0100|!base2, $80)	
	%transferslot(2, $0100|!base2, $80)
	%transferslot(3, $0100|!base2, $80)
	rts
.transfer_three		;transfer a 96x32 rectangle (three slots)
	%transferslot(0, $0180, $40)
	%transferslot(1, $0180, $40)	
	%transferslot(2, $0180, $40)
	%transferslot(3, $0180, $40)
	rts
.transfer_four		;transfer a 128x32 rectangle (four slots)
	%transferslot(0, $0800, $00)
	rts