;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 48x16 question mark block by EternityLarva
; ver 1.3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!BoundSprite = $01              ;bound custom sprite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; block config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Map16_left   = $301   ;map16 brown block left
!Map16_center = $302   ;map16 brown block center
!Map16_right  = $303   ;map16 brown block right

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	JSR side_coins
	JSR gen_bound
	
	LDA $1490               ;if mario has invisible
	BEQ +
	if !star_item == $0
		JSR gen_coin
	elseif !star_item != $0
		LDA #!star_item
		if !star_custom == !false
			CLC
		else
			SEC
		endif
		JSR gen_item
	endif

	BRA ++
+
	LDA $19                 ;if not small
	BEQ +
	if !big_item == $0
		JSR gen_coin
	elseif !big_item != $0
		LDA #!big_item
		if !big_custom == !false
			CLC
		else
			SEC
		endif
		JSR gen_item
	endif
	BRA ++
+                            ;if small
	if !small_item == $0
		JSR gen_coin
	elseif !small_item != $0
		LDA #!small_item
		if !small_custom == !false
			CLC
		else
			SEC
		endif
		JSR gen_item
	endif
++

	JSR kill_enemy

	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gen_bound:
	LDA $98      ;\
	PHA          ;|
	LDA $99      ;|
	PHA          ;|block info push
	LDA $9A      ;|
	PHA          ;|
	LDA $9B      ;|
	PHA          ;/
	PHX
	
	SEC
	LDA #!BoundSprite
	%spawn_sprite()
	BCC +
	JSR spawn_failed
	PLX
	PLA          ;\
	STA $9B      ;|
	PLA          ;|
	STA $9A      ;|block info pull
	PLA          ;|
	STA $99      ;|
	PLA          ;|
	STA $98      ;/
	RTS
+
	TAX
	LDA $98
	AND #$F0
	STA !D8,x
	LDA $99
	STA !14D4,x
	LDA $9A
	AND #$F0
	if !block_pos == 0
		CLC
		ADC #$10
	endif
	if !block_pos == 2
		SEC
		SBC #$10
	endif
	STA !E4,x
	LDA $9B
	if !block_pos == 0
		ADC #$00
	endif
	if !block_pos == 2
	SBC #$00
		endif
	STA !14E0,x
	
	PLX
	PLA          ;\
	STA $9B      ;|
	PLA          ;|
	STA $9A      ;|block info pull
	PLA          ;|
	STA $99      ;|
	PLA          ;|
	STA $98      ;/
	JSR erase_question
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spawn_failed:
	LDA $98      ;\
	PHA          ;|
	LDA $99      ;|
	PHA          ;|block info push
	LDA $9A      ;|
	PHA          ;|
	LDA $9B      ;|
	PHA          ;/

	PHX
	if !block_pos == 2
		LDA $9A
		SEC
		SBC #$20
		STA $9A
		LDA $9B
		SBC #$00
		STA $9B
	endif
	if !block_pos == 1
		LDA $9A
		SEC
		SBC #$10
		STA $9A
		LDA $9B
		SBC #$00
		STA $9B
	endif

	REP #$10
	LDX #!Map16_left
	%change_map16()
	SEP #$10

	REP #$20
	LDA $9A
	CLC
	ADC #$0010
	STA $9A
	SEP #$20
	
	REP #$10
	LDX #!Map16_center
	%change_map16()
	SEP #$10
	
	REP #$20
	LDA $9A
	CLC
	ADC #$0010
	STA $9A
	SEP #$20
	
	REP #$10
	LDX #!Map16_right
	%change_map16()
	SEP #$10
	PLX
	
	PLA          ;\
	STA $9B      ;|
	PLA          ;|
	STA $9A      ;|block info pull
	PLA          ;|
	STA $99      ;|
	PLA          ;|
	STA $98      ;/
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
side_coins:
	STZ $00
	if !block_pos == 0
		STZ $01
		JSR coin_effect
		LDA #$20
		STA $01
		JSR coin_effect
	endif
	if !block_pos == 1
		LDA #$F0
		STA $01
		JSR coin_effect
		LDA #$10
		STA $01
		JSR coin_effect
	endif
	if !block_pos == 2
		LDA #$E0
		STA $01
		JSR coin_effect
		STZ $01
		JSR coin_effect
	endif

	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
erase_question:
	RTS
	LDA $98      ;\
	PHA          ;|
	LDA $99      ;|
	PHA          ;|block info push
	LDA $9A      ;|
	PHA          ;|
	LDA $9B      ;|
	PHA          ;/
	
	if !block_pos == 2
		LDA $9A
		SEC
		SBC #$20
		STA $9A
		LDA $9B
		SBC #$00
		STA $9B
	endif
	
	if !block_pos == 1
		LDA $9A
		SEC
		SBC #$10
		STA $9A
		LDA $9B
		SBC #$00
		STA $9B
	endif

	REP #$10
	LDX #$0152
	%change_map16()
	SEP #$10

	PHY
	REP #$30
	LDY #$0002
-
	PHP
	PHY
	SEP #$30
	LDA $5B
	AND #$01
	BEQ +
	LDA $99
	LDY $9B
	STY $99
	STA $9B
+
	REP #$30
	PLY
	PLP
	LDA $9A
	CLC
	ADC #$0010
	STA $9A
	PHY
	SEP #$30
	
	REP #$10
	LDX #$0152
	%change_map16()
	SEP #$10
	
	REP #$30
	PLY
	DEY
	DEY
	BPL -
	SEP #$30
	PLY
	
	PLA          ;\
	STA $9B      ;|
	PLA          ;|
	STA $9A      ;|block info pull
	PLA          ;|
	STA $99      ;|
	PLA          ;|
	STA $98      ;/
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
coin_effect:
	LDA $98      ;\
	PHA          ;|
	LDA $99      ;|
	PHA          ;|block info push
	LDA $9A      ;|
	PHA          ;|
	LDA $9B      ;|
	PHA          ;/
	
	LDA $00
	BMI +
	LDA $98      ;\
	AND #$F0     ;|
	CLC          ;|
	ADC $00      ;|set Y position
	STA $98      ;|
	LDA $99      ;|
	ADC #$00     ;|
	STA $99      ;/
	BRA ++
+
	EOR #$FF
	INC A
	STA $01
	LDA $98      ;\
	AND #$F0     ;|
	SEC          ;|
	SBC $00      ;|set Y position
	STA $98      ;|
	LDA $99      ;|
	SBC #$00     ;|
	STA $99      ;/
++
	LDA $01
	BMI +
	LDA $9A      ;\
	AND #$F0     ;|
	CLC          ;|
	ADC $01      ;|set X position
	STA $9A      ;|
	LDA $9B      ;|
	ADC #$00     ;|
	STA $9B      ;/
	BRA ++
+
	EOR #$FF
	INC A
	STA $01
	LDA $9A      ;\
	AND #$F0     ;|
	SEC          ;|
	SBC $01      ;|set X position
	STA $9A      ;|
	LDA $9B      ;|
	SBC #$00     ;|
	STA $9B      ;/
++
	JSL $02889D  ; coin effect subroutine

	PLA          ;\
	STA $9B      ;|
	PLA          ;|
	STA $9A      ;|block info pull
	PLA          ;|
	STA $99      ;|
	PLA          ;|
	STA $98      ;/
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gen_coin:
	STZ $00

	if !block_pos == 0
		LDA #$10
		STA $01
		JSR coin_effect
	endif
	
	if !block_pos == 1
		STZ $01
		JSR coin_effect
	endif
	
	if !block_pos == 2
		LDA #$F0
		STA $01
		JSR coin_effect
	endif
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gen_item:
	%spawn_sprite()
	BCS +
	JSR move_spawn
+
	LDA #$02
	STA $1DFC
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
move_spawn:
	if !block_pos == 0
		JSR move_spawn_right
	endif
	if !block_pos == 1
		%move_spawn_into_block()
	endif
	if !block_pos == 2
		JSR move_spawn_left
	endif
	
	INC !15A0,x
	LDA #$08
	STA !14C8,x
	LDA #$3E
	STA !1540,x
	LDA #$D0 
	STA !AA,x
	LDA #$2C 
	STA !154C,x 
	LDA !190F,x
	BPL +
	LDA #$10
	STA !15AC,x 
+
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
move_spawn_right:
	PHX
	TAX
	LDA $98
	AND #$F0
	STA !D8,x
	LDA $99
	STA !14D4,x
	LDA $9A
	AND #$F0
	CLC
	ADC #$10
	STA !E4,x
	LDA $9B
	ADC #$00
	STA !14E0,x
	PLX
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
move_spawn_left:
	PHX
	TAX
	LDA $98
	AND #$F0
	STA !D8,x
	LDA $99
	STA !14D4,x
	LDA $9A
	AND #$F0
	SEC
	SBC #$10
	STA !E4,x
	LDA $9B
	SBC #$00
	STA !14E0,x
	PLX
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
kill_enemy:
	LDA $98      ;\
	PHA          ;|
	LDA $99      ;|
	PHA          ;|block info push
	LDA $9A      ;|
	PHA          ;|
	LDA $9B      ;|
	PHA          ;/
	
	LDA $98
	AND #$F0
	STA $98
	LDA $9A
	AND #$F0
	STA $9A
	%kill_sprite()
	
	if !block_pos == 0
		LDA $9A
		CLC
		ADC #$10
		STA $9A
		LDA $9B
		ADC #$00
		STA $9B
		%kill_sprite()
		LDA $9A
		CLC
		ADC #$10
		STA $9A
		LDA $9B
		ADC #$00
		STA $9B
		%kill_sprite()
	endif
	if !block_pos == 1
		LDA $9A
		SEC
		SBC #$10
		STA $9A
		LDA $9B
		SBC #$00
		STA $9B
		%kill_sprite()
		LDA $9A
		CLC
		ADC #$20
		STA $9A
		LDA $9B
		ADC #$00
		STA $9B
		%kill_sprite()
	endif
	if !block_pos == 2
		LDA $9A
		SEC
		SBC #$10
		STA $9A
		LDA $9B
		SBC #$00
		STA $9B
		%kill_sprite()
		LDA $9A
		SEC
		SBC #$10
		STA $9A
		LDA $9B
		SBC #$00
		STA $9B
		%kill_sprite()
	endif

	%give_points()
	
	PLA          ;\
	STA $9B      ;|
	PLA          ;|
	STA $9A      ;|block info pull
	PLA          ;|
	STA $99      ;|
	PLA          ;|
	STA $98      ;/
	RTS