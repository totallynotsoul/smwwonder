;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 48x16 Question Mark Block - Bound Sprite by EternityLarva
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	!Map16_left   = $300   ;map16 brown block left
	!Map16_center = $301   ;map16 brown block center
	!Map16_right  = $302   ;map16 brown block right

	!tile_left    = $A2     ;sprite tile question left
	!tile_center  = $86     ;sprite tile question center
	!tile_right   = $A4     ;sprite tile question right

	!Tile_info    = $30     ;YXPPCCCT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Start
	PLB
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Return:
	RTS
Start:
	JSR SUB_GFX
	LDA !14C8,x
	CMP #$08
	BNE Return
	LDA $9D
	BNE Return
	%SubOffScreen()

	LDA !1558,x
	CMP #$01
	BEQ +
	BCS Return
	LDA #$09
	STA !1558,x
	LDA !D8,x
	STA $98
	LDA !14D4,x
	STA $99
	LDA !E4,x
	SEC
	SBC #$10
	STA $9A
	LDA !14E0,x
	SBC #$00
	STA $9B
	
	PHY
	LDY #$02
-
	PHP
	REP #$30
	LDA.w #$0152
	%ChangeMap16()
	PLP
	LDA $9A
	CLC
	ADC #$10
	STA $9A
	LDA $9B
	ADC #$00
	STA $9B
	DEY
	BPL -
	PLY
	RTS
+
	LDA !D8,x
	STA $98
	LDA !14D4,x
	STA $99
	LDA !E4,x
	SEC
	SBC #$10
	STA $9A
	LDA !14E0,x
	SBC #$00
	STA $9B
	PHP
	REP #$30
	LDA.w #!Map16_left
	%ChangeMap16()
	PLP

	LDA !D8,x
	STA $98
	LDA !14D4,x
	STA $99
	LDA !E4,x
	STA $9A
	LDA !14E0,x
	STA $9B
	PHP
	REP #$30
	LDA.w #!Map16_center
	%ChangeMap16()
	PLP
	
	LDA !D8,x
	STA $98
	LDA !14D4,x
	STA $99
	LDA !E4,x
	CLC
	ADC #$10
	STA $9A
	LDA !14E0,x
	ADC #$00
	STA $9B
	PHP
	REP #$30
	LDA.w #!Map16_right
	%ChangeMap16()
	PLP
	STZ !14C8,x
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
animation: db $00,$FE,$FC,$FA,$F8,$F8,$FA,$FC,$FE,$00
Xpos:      db $F0,$00,$10
Tile:      db !tile_left,!tile_center,!tile_right

SUB_GFX:
	%GetDrawInfo()
	LDA !1558,x
	STA $02
	LDA !15F6,x
	STA $03

	PHX
	LDX #$02
-
	LDA Xpos,x
	CLC
	ADC $00
	STA $0300|!Base2,y

	PHX
	LDA $02
	TAX
	LDA animation,x
	CLC
	ADC $01
	STA $0301|!Base2,y
	PLX
	
	LDA Tile,x
	STA $0302|!Base2,y
	
	LDA #!Tile_info
	ORA $64
	STA $0303|!Base2,y
	INY
	INY
	INY
	INY
	DEX
	BPL -

	PLX
	LDY #$02
	LDA #$02
	JSL $01B7B3
	RTS