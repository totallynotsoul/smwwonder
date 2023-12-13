;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wall Kick by MarioE
; UberASM version by KevinM (v1.1)
;
; Allows Mario to perform a wall kick by sliding along a wall and pressing the
; B button.
; This is essentially the same code as the "Wall Kick" patch (with some improvements),
; but it must be inserted with UberASMTool, so you can have it only on certain levels
; (if you insert it as level ASM).
;
; It uses $0DC3, $0DC4 and $0DC5 as free ram.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!require_powerup	= !false	; Whether or not wall jumping requires a powerup.
!AllowSpinJump 		= $01  		; Allow spinjumping off walls $00 - No, $01 - Yes
!AllowWhileSpinning	= !true		; If true, Mario can slide on a wall and wall jump even when he's spin jumping
!AllowFromSameDirection = !true		; False = as the original patch.
					; True = after kicking a wall, Mario can kick again from the same wall/another wall facing the same direction.

!no_back_time		= $10		; The time to disable moving back after a wall kick. The smaller the value, the higher the control of the player over Mario's movement while wall jumping, but it also makes it harder to do big wall jumps.
!kick_x_speed		= $20		; The wall kick X speed.
!kick_y_speed		= $B8		; The wall kick Y speed.
!slide_accel		= $04		; The sliding acceleration.
!slide_speed		= $24		; The sliding speed.

!SpinJumpSFX 		= $04	; Spin jump sound effect. 1DFC
!SpinJumpSFXPort	= $1DFC
!JumpSFX 		= $01	; Regular jump sound effect. 1DFA
!JumpSFXPort		= $1DFA
!WallSFX		= $01	; Sound effect to make when jumping off of a wall. 1DF9
!WallSFXPort		= $1DF9

; Change these if there's a free ram conflict with another patch.
!flags			= $0DC3|!addr	; The wallkick flags. (RAM)
!no_back_timer		= $0DC4|!addr	; The timer for not moving back. (RAM)
!temp_y_spd		= $0DC5|!addr	; The temporary Y speed. (RAM)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!false	= 0	; Don't change these.
!true	= 1

main:
		STZ $1888|!addr
		STZ $1889|!addr
		
		LDA $77
		AND #$04
		BEQ .in_air
		
		STZ !flags
		RTL
		
	.in_air	LDA !flags
		AND #$03
		BNE .slide
		
		LDA !no_back_timer
		BEQ +
		
		DEC !no_back_timer
		LDA !flags
		LSR
		LSR
		TRB $15
		TRB $16
		
	+	LDA $7D
		BMI .return	
if !require_powerup
		LDA $19
		BEQ .return
endif	
		LDA $71
		ORA $73
		ORA $74
		ORA $75
		ORA $1407|!addr
	if !AllowWhileSpinning == !false
		ORA $140D|!addr
	endif
		ORA $1470|!addr
		ORA $1493|!addr
		ORA $187A|!addr
		BNE .return
		LDA $7E
		CMP #$0B
		BCC .return
		CMP #$E6
		BCS .return
		LDA !flags
		LSR
		LSR
	if !AllowFromSameDirection == !false
		AND $77
		BNE .return
	endif
		LDA $15
		AND #$03
		CMP #$03
		BEQ .return
		LDA $15
		AND $77
		BEQ .return
		
		STA !flags
		LDA $7D
		STA !temp_y_spd
	.return	RTL

	.stop	STZ !flags
		RTL
	
	.slide	LDA $71
		ORA $75
		ORA $1470|!addr
		ORA $187A|!addr
		BNE .stop
		LDA $7B
		CLC
		ADC #$07
		CMP #$0F
		BCS .stop
		LDA $15
		AND #$03
		CMP #$03
		BEQ .stop
		LDA $15
		AND !flags
		BEQ .stop
		
		LDA #$40
		TRB $15
		TRB $16
		
		LDA !flags
		DEC
		STA $76
		
		LDA $16
		BMI .kick
    if !AllowSpinJump	
        LDA $18
        BMI .spinjump
    endif
		
		LDA $14
		AND #$07
		BNE ++
		
		LDX $76
		LDY #$03
	-	LDA $17C0|!addr,y
		BNE +
		
		LDA #$03
		STA $17C0|!addr,y
		LDA $94
		CLC
		ADC.l smoke_x_offsets,x
		STA $17C8|!addr,y
		LDA $96
		CLC
		ADC #$10
		STA $17C4|!addr,y
		LDA #$13
		STA $17CC|!addr,y
		BRA ++
		
	+	DEY
		BPL -

	++	LDA #$0D
		STA $13E0|!addr
		
		LDA !temp_y_spd
		CLC
		ADC #!slide_accel
		STA $7D
		STA !temp_y_spd
		BMI .return2
		CMP #!slide_speed
		BCC .return2
		LDA #!slide_speed
		STA $7D
		STA !temp_y_spd
.return2
		RTL
  if !AllowSpinJump	
    .spinjump
      INC $140D|!addr
      LDA #!SpinJumpSFX
      STA !SpinJumpSFXPort|!addr
      BRA +++
  endif
 
	.kick
    LDA #!JumpSFX
		STA !JumpSFXPort|!addr
	+++	INC $1406|!addr
	        LDA #!WallSFX
		STA !WallSFXPort|!addr
		
		
		LDA #$0B
		STA $72
		LDA #!kick_y_speed
		STA $7D
		
		LDX $76
		LDA.l wall_kick_x_speeds,x
		STA $7B
		
		LDA !flags
		TRB $15
		TRB $16
		ASL
		ASL
		STA !flags
		
		LDA #!no_back_time
		STA !no_back_timer
		
		LDY #$03
	-	LDA $17C0|!addr,y
		BNE +
		
		INC
		STA $17C0|!addr,y
		LDA $94
		STA $17C8|!addr,y
		LDA $96
		CLC
		ADC #$10
		STA $17C4|!addr,y
		LDA #$10
		STA $17CC|!addr,y
		RTL
		
	+	DEY
		BPL -
		RTL

smoke_x_offsets:
		db $0C,$FE

wall_kick_x_speeds:
		db !kick_x_speed^$FF+1,!kick_x_speed
