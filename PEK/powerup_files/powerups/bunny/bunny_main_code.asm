;##################################################################################################
;# Powerup: Bunny Mario
;# Author: Nintendo (Original), SubconsciousEye (Port)
;# Description: The Super Carrot Powerup from Super Mario Land 2, with near-accurate behavior.
;#
;# This code is run every frame when Mario has this powerup.
    
.mainmain
	lda !player_in_water
	beq .notwater
	jmp AutoHopWater
.notwater
	jsr AutoHopLand_main
	bra BunBun
-	rts


BunBun:
.check_hover
	lda !bunny_states	;is the order a rabbit?
	beq .hover_off : bra .hover_on
.hover_off
	lda #$00
	sta $18F6|!addr ;allow badge actions
	lda $16 : bpl -		;return if not recently tapping B button
	lda #$01 : sta !bunny_states
	stz !player_spinjump : stz !player_crouching
.hover_set
	lda !bunny_ear_sfx_num : sta !bunny_ear_sfx_port
	lda !bunny_hover_frames : sta !bunny_hover_timer
	lda #$03 : sta !player_physics_flags
	stz !player_y_speed
	rts
.hover_on
	lda #$01
	sta $18F6|!addr ;prevent badge actions
	lda $16			;check player recently tapping B button
	bmi .hover_set	;branch if true (reset timer and stuff)
	lda !bunny_hover_timer
	bne ..still_hover
..maybe_hover
	lda $15			;check player holding B button
	bmi .hover_set	;branch if false (turn off hover mode)
	lda #$00 : sta !bunny_states
	rts
..still_hover
	cmp !bunny_ear_flap
	bcs +
	lda !bunny_hover_timer
	sta !player_y_speed
	lda #$02 : sta !player_physics_flags
+	rts


AutoHopWater:
	lda !player_in_air
	bne .nohop
	lda $1471|!addr
	cmp #$02
	beq .nohop
	lda !player_blocked_status
	and #$08
	bne .nohop
	lda $15
	bpl .nohop
	and #$0C
	lsr #2
	tax
	lda.l $00D984|!bank,x
	sta !player_y_speed
	lda #$0B
	sta !player_in_air
	lda !bunny_swim_sfx_num
	sta !bunny_swim_sfx_port
	stz !player_animation_timer
.nohop
	lda #$00
	sta !bunny_states
	sta !bunny_hover_timer
	lda #$02 : sta !player_physics_flags
	rts


AutoHopLand:
.nohop0
	lda #$00
	sta !bunny_states
	sta !bunny_hover_timer
.return
	rts
.main
	lda !player_in_air
	bne .return
	lda $1471|!addr
	cmp #$02
	beq .nohop
	lda !player_blocked_status
	and #$08
	bne .nohop
	lda $15
	bpl .nohop
	lda $17
	bmi .nohop
	
	lda !player_x_speed
	bpl +
	eor #$ff : inc
+	lsr #2
if !bunny_useOrigJumpSpeeds
	and #$fe
	tax
	lda.l $00D2BD|!bank,x
else
	lsr
	tax
	lda.w .AutoHopSpeeds,x
endif
	sta !player_y_speed
	lda !bunny_jump_sfx_num
	sta !bunny_jump_sfx_port
	
;;;;;
;; Stolen bits from $00D668-$00D681
;;  sets correct in-air state and timers
;;;;;
	
	lda #$0B
	ldy !player_dash_timer
	cpy #$70
	bcc ++
	lda !player_takeoff_timer
	bne +
	lda #$50
	sta !player_takeoff_timer
+	lda #$0C
++	sta !player_in_air
	stz !player_sliding
	
;;;;;
;; Back to our code
;;;;;
	
	stz !player_airwalk_timer
	stz !player_spinjump
.nohop
	lda #$00
	sta !bunny_states
	sta !bunny_hover_timer
	lda #$02 : sta !player_physics_flags
	pla : pla
	rts

if !bunny_useOrigJumpSpeeds == !no
.AutoHopSpeeds
if !bunny_calcFromOrigJumpSpeeds
;;; TODO: Maybe remove this and just let
;;;  the user define it themselves?
;;; Alternatively, convert to weird foreach/while loop?
.0
	db read1($00D2BD+$0)
.1
	db read1($00D2BD+$2)
.2
	db read1($00D2BD+$4)
.3
	db read1($00D2BD+$6)
.4
	db read1($00D2BD+$8)
.5
	db read1($00D2BD+$A)
.6
	db read1($00D2BD+$C)
.7
	db read1($00D2BD+$E)
.8
	db (read1(.7)-(read1(.1)-read1(.2)))
.9
	db (read1(.8)-(read1(.0)-read1(.1)))
.A
	db (read1(.9)-(read1(.1)-read1(.2)))
.B
	db (read1(.A)-(read1(.0)-read1(.1)))
.C
	db (read1(.B)-(read1(.1)-read1(.2)))
.D
	db (read1(.C)-(read1(.0)-read1(.1)))
.E
	db (read1(.D)-(read1(.1)-read1(.2)))
.F
	db (read1(.E)-(read1(.0)-read1(.1)))
else
	db $B0		; X Speed 00-07/FF-F9
	db $AE		; X Speed 08-0F/F8-F1
	db $AB		; X Speed 10-17/F0-E9
	db $A9		; X Speed 18-1F/E8-E1
	db $A6		; X Speed 20-27/E0-D9
	db $A4		; X Speed 28-2F/D8-D1
	db $A1		; X Speed 30-37/D0-C9
	db $9F		; X Speed 38-3F/C8-C1
; the following are newly added values not in the original game
; mostly to "complete" the table and prevent weirdness
	db $9C		; X Speed 40-47/C0-B9
	db $9A		; X Speed 48-4F/B8-B1
	db $97		; X Speed 50-57/B0-A9
	db $95		; X Speed 58-5F/A8-A1
	db $92		; X Speed 60-67/A0-99
	db $90		; X Speed 68-6F/98-91
	db $8D		; X Speed 70-77/90-89
	db $8B		; X Speed 78-7F/88-81
	db $88		; X Speed 80 (lol)
endif

endif
