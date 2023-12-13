; MaxTile shared routines
maxtile_flush_nmstl			= $0084A8
maxtile_get_sprite_slot		= $0084AC
maxtile_get_slot			= $0084B0
maxtile_finish_oam			= $0084B4

; MaxTile pointers
!maxtile_mirror_max        	= $6180
!maxtile_mirror_high       	= $6190
!maxtile_mirror_normal     	= $61A0
!maxtile_mirror_low        	= $61B0

; We are using MaxTile "direct mode" here, check the documentation
; for more information.

; Basically these are the trunk tiles, the "thick" ones are just repeated.
; This is the vertical pattern of the tiles and they are repeated until the
; pillar is drawn.

thick_tree_1:
	db $C6,$E6
thick_tree_2:
	db $C8,$E8
medium_tree:
	db $AA,$CA
thin_tree:
	db $AA,$CA
tree_layer_1:
	dw $0000+$0055-$0008 : dw thin_tree
	dw $00AB+$0055-$0008 : dw thin_tree
	dw $FFFF
	
tree_layer_2:
	dw $0080-$0010 : dw thick_tree_1
	dw $FFFF
	
tree_layer_3:
	dw $0080-$0010 : dw thick_tree_1
	dw $0090-$0010 : dw thick_tree_2
	dw $FFFF


!FreeRAM_GradBank = $7F		;\
!FreeRAM_RedGreen = $1343	; | Just to note: These all belong together. That means, these addresses aren't supposed to be converted if you use SA-1
!FreeRAM_Blue = $1943		;/

!Layer = 1			; The layer in which the HDMA is rooted.
!Offset = $0000		; How much is the table shifted
!ScrollFactor = 0	; The division is exponential, using 2 as its base.

init:
LDA.b #$51	; \ layer 3 tilemap
STA.w $2109	; / 64x32
STZ $24		; \ reset layer 3
STZ $25		; / Vscroll values
	REP #$10
	LDX.w #Gradient
	STX $00
	LDA.b #Gradient>>16
	STA $02

	LDA.b #!FreeRAM_GradBank
	LDX.w #!FreeRAM_RedGreen
	LDY.w #!FreeRAM_Blue

	JSL ScrollHDMA_init
main:
	%invoke_sa1(sa1_main)
	rtl
	REP #$20

	LDA #!FreeRAM_RedGreen
	STA $00
	LDA #!FreeRAM_Blue
	STA $02

	LDA $1C+((!Layer-1)<<2)
	CLC : ADC.w #!Offset
	LSR #!ScrollFactor
	JML ScrollHDMA_main

Gradient:
db $07,$2A,$50,$9B
db $01,$2B,$50,$9B
db $18,$2B,$51,$9B
db $0C,$2C,$51,$9B
db $0C,$2C,$52,$9B
db $17,$2D,$52,$9C
db $01,$2D,$53,$9C
db $18,$2E,$53,$9C
db $0A,$2F,$53,$9C
db $0E,$2F,$54,$9D
db $16,$30,$54,$9D
db $03,$30,$55,$9D
db $14,$31,$55,$9D
db $04,$31,$55,$9E
db $08,$32,$55,$9E
db $10,$32,$56,$9E
db $13,$33,$56,$9E
db $02,$32,$56,$9E
db $01,$32,$55,$9E
db $09,$32,$55,$9D
db $04,$31,$54,$9D
db $07,$31,$54,$9C
db $01,$31,$53,$9C
db $06,$30,$53,$9C
db $03,$30,$53,$9B
db $03,$30,$52,$9B
db $07,$2F,$52,$9B
db $01,$2F,$52,$9A
db $04,$2F,$51,$9A
db $06,$2E,$51,$9A
db $03,$2E,$50,$9A
db $03,$2E,$50,$99
db $05,$2D,$50,$99
db $05,$2D,$4F,$99
db $02,$2D,$4F,$98
db $03,$2C,$4F,$98
db $09,$2C,$4E,$98
db $02,$2B,$4E,$97
db $0A,$2B,$4D,$97
db $01,$2A,$4C,$97
db $0A,$2A,$4C,$96
db $01,$2A,$4B,$96
db $03,$29,$4B,$96
db $06,$29,$4B,$95
db $03,$29,$4A,$95
db $04,$28,$4A,$95
db $04,$28,$4A,$94
db $04,$28,$49,$94
db $06,$27,$49,$94
db $06,$27,$48,$93
db $05,$26,$48,$93
db $02,$26,$47,$93
db $04,$26,$47,$92
db $04,$25,$47,$92
db $06,$25,$46,$92
db $02,$25,$46,$91
db $03,$24,$46,$91
db $08,$24,$45,$91
db $01,$24,$45,$90
db $01,$23,$45,$90
db $0B,$23,$44,$90
db $01,$22,$43,$90
db $04,$22,$43,$8F
db $00

; This is the routine that renders a "pillar", it takes a pattern
; and the x/y positions and draw a pillar on the screen.

; $00-$01 = x pos
; $02-$03 = tape
; $04-$05 = tape size
; $06 = current y pos
; $08 = layer y pos
; $0a = layer x pos
; $0c = maxtile buffer
; $0e = maxtile prop buffer
render_pillar:
	rep #$20
	lda $00
	and #$01ff
	cmp #$0100
	bcc .ok
	cmp #$01f0
	bcs .ok
	sep #$20
	rts

.ok
	sep #$20
	
	lda.b #~$1f
	trb $08
	
	stz $06
	ldy #$0000

.loop
	ldx $0c
	lda $00
	sta $400000,x
	lda $06
	sec
	sbc $08
	sta $400001,x
	lda ($02),y
	sta $400002,x
	lda.b #%00111100
	sta $400003,x
	dex #4
	stx $0c
	
	iny
	cpy $04
	bcc +
	ldy #$0000
+
	
	ldx $0e
	lda $01
	and #$01
	ora #$02
	sta $400000,x
	dex
	stx $0e
	
	lda $06
	clc
	adc #$10
	sta $06
	cmp #$e0
	bcc .loop
	
	rts
	
; This is responsible for drawing a virtual layer, the only thing needed is to set
; your scroll value ($0A) and the pointer to the layer (Y register)

render_layer:
	ldx $0000,y
	bmi .end
	rep #$20
	txa
	sec
	sbc $0a
	sta $00
	sep #$20
	ldx $0002,y
	stx $02
	phy
	jsr render_pillar
	ply
	iny #4
	bra render_layer
.end
	rts
	
; This basically gets the current MaxTile pointer, sets up the scrolling values
; and calls the render layers routines.
sa1_main:
	phb
	phk
	plb
	
	rep #$10
	; configure maxtile
	; unsafe: use the pointers without checking if there's slots free.
	ldx !maxtile_mirror_max+0
	stx $0c
	ldx !maxtile_mirror_max+2
	stx $0e
	
	ldx $1c
	stx $08
	
	; for now everything is two tiles
	ldy #$0002
	sty $04
	
	; calculate scroll: $0A = ($1A + $1A/8)
	rep #$20
	lda $1a
	lsr
	lsr
	lsr
	clc
	adc $1a
	sta $0a
	sep #$20
	
	; render virtual layer 1
	ldy #tree_layer_1
	jsr render_layer
	
	; calculate scroll: $0A = ($1A + $1A/4)
	rep #$20
	lda $1a
	lsr
	lsr
	clc
	adc $1a
	sta $0a
	sep #$20
	
	; render virtual layer 2
	ldy #tree_layer_2
	jsr render_layer
	
	; calculate scroll: $0A = ($1A + $1A/2)
	rep #$20
	lda $1a
	lsr
	clc
	adc $1a
	sta $0a
	sep #$20
	
	; render virtual layer 3
	ldy #tree_layer_3
	jsr render_layer

	; finish maxtile
	; store the new pointer, so MaxTile acknowledge the new tiles.
	ldx $0c
	stx !maxtile_mirror_max+0
	ldx $0e
	stx !maxtile_mirror_max+2
	sep #$10

	plb
	rtl