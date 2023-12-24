;-------------------------------
;                               
;      o----------------o       
;      |                |       
;      |                |       
;      |                |       
;      |                |       
;      |                |       
;      |            [=======]   
;      |                        
;      |                        
;  [=======]                    
;            by shadow mistress 
;-------------------------------
; Ex1: platform width (00-03)
;-------------------------------
; Ex2: platform link tag (00-FF)
;
; the link tag is how a platform
; determines the other one
; connected to it.
;
;-------------------------------

!tile_left = $C2
!tile_middle = $C3
!tile_right = $C4

!topleft_map16 = $1200
!topright_map16 = $1202

!rope_map16 = $1210
!half_rope_map16 = $1220

;-------------------------------
; init
;-------------------------------
print "INIT ",pc
	RTL
;-------------------------------
; main
;-------------------------------
print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR sprite
	PLB
	RTL
;-------------------------------
; sprite
;-------------------------------
clip_table:
	db $1D,$04,$33,$05
xpos_table:
	db $08,$10,$18,$20
rope_table:
	dw !rope_map16
	dw !half_rope_map16
	dw $0025
	dw !half_rope_map16
return2:
	RTS
sprite:
	JSR gfx
	LDA $9D
	BNE return2
	%SubOffScreen()
	
	LDA !C2,x
	BPL +
	JSL $01802A|!BankB
	JMP label02
+
	LDA $14
	AND #$01
	BEQ ++
	LDA !sprite_speed_y,x
	BEQ ++
	BPL +
	INC A
	STA !sprite_speed_y,x
	BRA ++
+
	DEC A
	STA !sprite_speed_y,x
	STZ !C2,x
++
	LDA !sprite_speed_y,x
	BNE +
	JMP skip_block
+
	LDA !sprite_y_low,x
	STA $98
	LDA !sprite_y_high,x
	STA $99
	LDA !sprite_x_low,x
	STA $9A
	LDA !sprite_x_high,x
	STA $9B
	STZ $1933|!Base2
	
	LDY #$00
	LDA !sprite_y_low,x
	AND #$0F
	CMP #$08
	BCS +
	INY
	INY
+
	LDA !sprite_speed_y,x
	BPL +
	INY #4
	LDA $98
	CLC
	ADC #$08
	STA $98
	LDA $99
	ADC #$00
	STA $99
+
	PHY
	REP #$20
	LDA $98
	SEC
	SBC #$000A
	STA $98
	%GetMap16()
	PHA
	LDA $98
	CLC
	ADC #$000A
	STA $98
	PLA
	CMP #!topleft_map16
	BEQ +
	CMP #!topright_map16
	BNE ++
+
	SEP #$20
	LDA !sprite_speed_y,x
	BPL ++
	STZ !sprite_speed_y,x
	INC !C2,x
	
if !sa1
	LDY #!SprSize
-
	STY $00
	CPX $00
	BEQ +
	LDA !new_sprite_num,x
	CMP !new_sprite_num,y
	BNE +
	LDA !extra_byte_2,x
	CMP !extra_byte_2,y
	BNE +
	LDA #$00
	STA !sprite_speed_y,y
+
	DEY
	BPL -
else
	TXY
	LDA !new_sprite_num,x : STA $00
	LDA !extra_byte_2,x   : STA $01
	
	LDX #!SprSize
-
	STX $02
	CPY $02
	BEQ +
	LDA $00
	CMP !new_sprite_num,x
	BNE +
	LDA $01
	CMP !extra_byte_2,x
	BNE +
	LDA #$00
	STA !sprite_speed_y,x
+
	DEX
	BPL -
	LDX $15E9|!addr
endif
++
	PLY
	REP #$20
	LDA rope_table,y
	%ChangeMap16()
	SEP #$20
skip_block:
	
	JSL $01801A|!BankB
	JSL $018022|!BankB
	
label02:
	LDA !extra_byte_1,x
	TAY
	
	LDA !sprite_x_low,x
	PHA
	SEC
	SBC xpos_table,y
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	PHA
	SBC #$00
	STA !sprite_x_high,x
	
	LDA clip_table,y
	STA !1662,x
	JSL $01B44F|!BankB
	BCC ++
	LDA !C2,x
	BMI ++
	
	LDA !sprite_speed_y,x
	INC A
	CMP #$20
	BPL +
	STA !sprite_speed_y,x
+
if !sa1
	LDY #!SprSize
-
	STY $00
	CPX $00
	BEQ +
	LDA !new_sprite_num,x
	CMP !new_sprite_num,y
	BNE +
	LDA !extra_byte_2,x
	CMP !extra_byte_2,y
	BNE +
	
	LDA !C2,y
	CMP #$08
	BCC label01
	LDA #$AA
	STA !C2,x
	STA !C2,y
	LDA #$04
	JSL $02ACE5|!BankB
label01:
	LDA !sprite_speed_y,y
	DEC A
	CMP #$E0
	BMI +
	STA !sprite_speed_y,y
+
	DEY
	BPL -
else
	TXY
	LDA !new_sprite_num,x : STA $00
	LDA !extra_byte_2,x   : STA $01
	
	LDX #!SprSize
-
	STX $02
	CPY $02
	BEQ +
	LDA $00
	CMP !new_sprite_num,x
	BNE +
	LDA $01
	CMP !extra_byte_2,x
	BNE +
	
	LDA !C2,x
	CMP #$08
	BCC label01
	LDA #$AA
	STA !C2,y
	STA !C2,x
	LDA #$04
	JSL $02ACE5|!BankB
label01:
	LDA !sprite_speed_y,x
	DEC A
	CMP #$E0
	BMI +
	STA !sprite_speed_y,x
+
	DEX
	BPL -
	LDX $15E9|!addr
endif
++
	PLA
	STA !sprite_x_high,x
	PLA
	STA !sprite_x_low,x
	
return:
	RTS
;-------------------------------
; sub gfx
;-------------------------------
start_table:
	db $F8,$F0,$E8,$E0
gfx:
	%GetDrawInfo()
	
	LDA !sprite_oam_properties,x
	STA $04
	
	LDA !extra_byte_1,x
	PHA
	INC A
	STA $02
	
	PLA
	PHX
	TAX
	LDA start_table,x
	STA $03
	
	
	LDX $02
-
	LDA $00
	CLC
	ADC $03
	STA $0300|!Base2,y
	LDA $01
	DEC
	STA $0301|!Base2,y
	LDA #!tile_middle
	CPX $02
	BNE +
	LDA #!tile_left
+
	CPX #$00
	BNE +
	LDA #!tile_right
+
	STA $0302|!Base2,y
	LDA $04
	ORA $64
	STA $0303|!Base2,y
	LDA $03
	CLC
	ADC #$10
	STA $03
	
	INY #4
	DEX
	BPL -

	PLX
	LDY #$02
	LDA $02
	%FinishOAMWrite()
	RTS