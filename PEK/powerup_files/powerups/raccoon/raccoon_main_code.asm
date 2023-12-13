;##################################################################################################
;# Powerup: Cape Mario
;# Author: Nintendo
;# Description: Default powerup $02 for Mario. Behaves exactly like in the original game.
;#
;# This code is run every frame when Mario has this powerup.

.mainmain
	jsr TailThwack
	lda $1407|!addr
	ora !player_in_water
	bne .finish
	lda !player_in_air
	beq .notair
	jsr FlightSwap
	
	jmp TailFlight
.notair
	lda #$03
	sta !player_physics_flags
.finish
	rts


TailThwack:
	lda !raccoon_tail_flag
	bmi .attackphase
	
.checkbutton
	bit $16				; checks if x/y pressed
	bvc .return0
		
	lda !player_crouching
	ora !player_climbing
	ora !player_in_yoshi
	ora !player_spinjump
	ora !player_sliding
	ora !player_crouching_yoshi
	ora !player_wallrunning
	ora !player_carrying
	ora !player_holding
	ora $1407|!addr
	bne .return0
	
;	lda.b #!raccoon_spin_frames
;	sta !cape_spin_timer
	lda.b #!raccoon_spin_frames
	sta !raccoon_thwack_timer
	lda #!raccoon_spin_sfx
	sta !raccoon_spin_sfx_port|!addr
	
	stz !player_crouching
	lda #$80
	ora !player_direction
	sta !raccoon_tail_flag
.return0
	rts

.attackphase
;	lda !player_extended_anim_num
	lda !raccoon_thwack_timer
	bne .active
;	lda !player_extended_anim_pose
;	sta !player_pose_num
	lda #$00
	sta !raccoon_tail_flag
	rts

.active
;	lda !player_extended_anim_index
;	lsr
	lsr #2
	bcc .notcenter
	rep #$20
	lda !player_x_pos
	bra .storetailx
.notcenter
;	eor !player_extended_anim_num
	lda !player_direction
;	lsr
;	eor !raccoon_tail_flag
	asl : and #$02
	tay
	rep #$21
	lda !player_x_pos
	adc.w .tail_xofs,y
.storetailx
	sta !cape_interaction_x_pos
	lda !player_y_pos
	clc : adc #$0014
	sta !cape_interaction_y_pos
	sep #$20
	lda #$01
	sta !cape_interaction_flag
	rts

.tail
..xofs
	dw $0006,-$0006

FlightSwap:
	lda $3fdead
	lda !raccoon_freeflight
	bne .continue
	lda !player_takeoff_timer
	beq .return0
	lda $15 : and #$48 : cmp #$48
	bne .return0
	lda $16 : bpl .return0
	stz !player_y_speed
	lda #$03
	sta !player_physics_flags
	sta !raccoon_freeflight
.return0
	rts
.continue
	lda !player_extended_anim_num
	bne .return0
	lda !player_extended_anim_pose
	sta !player_pose_num
	lda #$00
	sta !player_physics_flags
	sta !raccoon_freeflight
	sta $1409|!addr
	sta $14a4|!addr
	lda $3fdead
	lda #$02
	sta $1408|!addr
	sta $1407|!addr
	rts

TailFlight:
	lda $3fdead
	lda !player_in_air
	cmp #$0c : bne +
	ldy #$01
	cpy !player_takeoff_timer
	bcc .flying
	inc !player_takeoff_timer
+	ldy #$00
;	lda #$02 : ldy #$01
;	ldx $14a5|!addr : bne .applyspeed-1
;	ldx $15 : bpl .noflight
;	lda !raccoon_flight_timer
;	bne .flying
;	lda !player_takeoff_timer
;	cmp #$50
;	bne .return
;	lda #!raccoon_max_fly_time
;	sta !raccoon_flight_timer
.flying
	lda #$01
	sta $18F6|!addr ;prevent badge actions
;	lda !player_y_speed
;	bmi .applyspeed
	lda $14a5|!addr
	bne .applyspeed
	lda $15
;	bpl .applyspeed
	bpl .nolimit
	lda #$10
	sta $14a5|!addr
;	dey
.applyspeed
	lda !player_y_speed
	bpl .falling
	ldx.w .speed,y
	bpl .nolimit
	cmp.w .speed,y
	bcc .nolimit
.falling
	lda #$00
	sta $18F6|!addr ;allow badge actions
	lda.w .speed,y
	cmp !player_y_speed
	beq .storey
	bmi .storey
.nolimit
	ldy #$01
	lda $15
	bmi .maxfall
	ldy #$00
.maxfall
	lda !player_y_speed
	bmi .applygrav
	cmp.w .fallmax,y
	bcc .fallswitch
	lda.w .fallmax,y
.fallswitch
	ldx !player_in_air
	beq .applygrav
	cpx #$0B
	bne .applygrav
	ldx #$24
	stx !player_in_air
.applygrav
	clc
	adc.w .gravity,y
.storey
	sta !player_y_speed
;	lda #$03			; override gravity
.noflight
;	sta !player_physics_flags
.return
	rts

.speed
..hover
	db  $10
..flight
	db -$10
.fallmax
	db  $40,$40
.gravity
..noab
	db $06
..abheld
	db $03

;;TODO: $149f - cape takeoff timer
;;TODO: $14a4 - cape flight stage switch timer
;;TODO: $14a5 - cape hover timer
;;TODO: $1407 - cape flight stage, should be h03 when we begin
;;TODO: $1408 - cape flight stage switch index, h02
;;TODO: $1409 - cape flight stage aircatch, check disasm for values, hF8
;;TODO: $13e9 - +/- 4, x-offset
;;TODO: $13eb - + 20 (h14), y-offset
;;TODO: !player_extended_anim_index starts at 0 for the first anim pose
;;TODO: !player_extended_anim_num is set to 0 when the anim ends
;;TODO: grab !player_extended_anim_pose to store to !player_pose_num at anim end
;;NEW TODO: !raccoon_spoof_timer for !player_takeoff_timer spoofer, the spoof timer
;;           should take precedent before the actual takeoff timer decrements
;;NEW TODO: Actually fix up the FlightSwap Animation stuff