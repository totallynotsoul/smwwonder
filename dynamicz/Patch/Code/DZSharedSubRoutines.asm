;#########################################################
;##################### routines ##########################
;#########################################################

;					 $00,$08,$20,$28,$40,$48,$60,$68
sendSignals801:		db $00,$00,$F0,$F0,$F0,$F0,$F0,$F0
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $00,$00,$00,$00,$00,$00,$00,$00
					
;					 $00,$08,$20,$28,$40,$48,$60,$68
sendSignals802:		db $0F,$0F,$00,$00,$00,$00,$00,$00
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
					
;					   $00,$08,$20,$28,$40,$48,$60,$68
getSignals801:		db $02,$02,$01,$01,$01,$01,$01,$01
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $02,$02,$02,$02,$02,$02,$02,$02
					
;					   $00,$08,$20,$28,$40,$48,$60,$68
getSignals802:		db $01,$01,$00,$00,$00,$00,$00,$00
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $01,$01,$01,$01,$01,$01,$01,$01
					
;					   $00,$08,$20,$28,$40,$48,$60,$68
slotUsed80:			db $2E,$2E,$16,$16,$16,$16,$16,$16
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $2E,$2E,$2E,$2E,$2E,$2E,$2E,$2E

DynamicRoutine80Start:
	PHX 
	
	PHB
	PHK
	PLB
	
	LDA getSignals801,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals801,y
	STA !dynSiganls1,x
	
	LDA getSignals802,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals802,y
	STA !dynSiganls1,x
	
	LDA slotUsed80,y
	STA $00
	PLB
	
	LDA !lastSender
	BMI +
	TAX

	LDA $00
	STA !nextDynSlot,x
	LDA #$00
	STA !nextDynSlot+$01,x
	
+
	LDA $00
	STA !lastSender

	LDA !firstSlot
	BPL +
	LDA $00
	STA !firstSlot
	LDA #$00
	STA !firstSlot+$01
+
	
	PLX

	RTL
	
Ping80:

	PHX 
	
	PHB
	PHK
	PLB
	
	LDA getSignals801,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals801,y
	STA !dynSiganls1,x
	
	LDA getSignals802,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals802,y
	STA !dynSiganls1,x
	PLB
	PLX
	RTL

reserveNormalSlot80:

	JSR reserveSlot80
	LDA $00
	STA !tileRelativePositionNormal,x
	RTL
	
reserveExtendedSlot80:

	JSR reserveSlot80
	LDA $00
	STA !tileRelativePositionExtended,x
	RTL
	
reserveClusterSlot80:

	JSR reserveSlot80
	LDA $00
	TYX
	STA !tileRelativePositionCluster,x
	RTL

reserveSlot80:

	LDA !mode50
	BEQ .ret
	
	LDA !dynSiganls3
	CMP #$FF
	BNE +
	
	LDA !dynSiganls2
	AND #$F0
	CMP #$F0
	BNE +
	
	LDA #$00
	STA !dynSiganls3
	
	LDA !dynSiganls2
	AND #$0F
	STA !dynSiganls2
	
	LDA #$0C
	STA $00
	RTS
	
+
	LDA !dynSiganls2
	AND #$0F
	CMP #$0F
	BNE .ret
	
	LDA !dynSiganls1
	CMP #$FF
	BNE .ret
	
	LDA !dynSiganls2
	AND #$F0
	STA !dynSiganls2
	
	LDA #$00
	STA !dynSiganls1
	
	LDA #$02
	STA $00
	RTS
	
.ret
	LDA #$FF
	STA $00
	RTS
	
;					 $00,$08,$20,$28,$40,$48,$60,$68
sendSignals641:		db $00,$00,$F0,$F0,$00,$00,$00,$00
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $00,$00,$00,$00,$00,$00,$F0,$F0
					
;					 $00,$08,$20,$28,$40,$48,$60,$68
sendSignals642:		db $00,$00,$0F,$0F,$00,$00,$00,$00
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $00,$00,$00,$00,$00,$00,$0F,$0F
					
;					   $00,$08,$20,$28,$40,$48,$60,$68
getSignals641:		db $01,$01,$01,$01,$00,$00,$00,$00
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $02,$02,$02,$02,$02,$02,$02,$02
					
;					   $00,$08,$20,$28,$40,$48,$60,$68
getSignals642:		db $01,$01,$00,$00,$00,$00,$00,$00
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $02,$02,$02,$02,$02,$02,$01,$01
					
;					   $00,$08,$20,$28,$40,$48,$60,$68
slotUsed64:			db $1E,$1E,$16,$16,$0E,$0E,$0E,$0E
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $2E,$2E,$2E,$2E,$2E,$2E,$26,$26
	
DynamicRoutine64Start:
	PHX 
	
	PHB
	PHK
	PLB
	
	LDA getSignals641,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals641,y
	STA !dynSiganls1,x
	
	LDA getSignals642,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals642,y
	STA !dynSiganls1,x
	
	LDA slotUsed64,y
	STA $00
	PLB
	
	LDA !lastSender
	BMI +
	TAX

	LDA $00
	STA !nextDynSlot,x
	LDA #$00
	STA !nextDynSlot+$01,x
	
+
	LDA $00
	STA !lastSender

	LDA !firstSlot
	BPL +
	LDA $00
	STA !firstSlot
	LDA #$00
	STA !firstSlot+$01
+
	
	PLX

	RTL
	
Ping64:
	PHX 
	
	PHB
	PHK
	PLB
	
	LDA getSignals641,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals641,y
	STA !dynSiganls1,x
	
	LDA getSignals642,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals642,y
	STA !dynSiganls1,x
	PLB
	PLX
	RTL

reserveNormalSlot64:

	JSR reserveSlot64
	LDA $00
	STA !tileRelativePositionNormal,x
	RTL
	
reserveExtendedSlot64:

	JSR reserveSlot64
	LDA $00
	STA !tileRelativePositionExtended,x
	RTL
	
reserveClusterSlot64:

	JSR reserveSlot64
	LDA $00
	TYX
	STA !tileRelativePositionCluster,x
	RTL

reserveSlot64:

	LDA !mode50
	BNE ++
	
	LDA !dynSiganls2
	CMP #$FF
	BNE +
	
	LDA #$00
	STA !dynSiganls2
	STA $00
	RTS
	
+
	LDA !dynSiganls1
	CMP #$FF
	BNE +
	
	LDA #$00
	STA !dynSiganls1
	
	LDA #$04
	STA $00
	RTS
+
	LDA #$FF
	STA $00
	RTS
++
	
	LDA !dynSiganls3
	CMP #$FF
	BNE +
	
	LDA #$00
	STA !dynSiganls3
	
	LDA #$0C
	STA $00
	RTS
	
+
	LDA !dynSiganls3
	AND #$0F
	CMP #$0F
	BNE +

	LDA !dynSiganls2
	AND #$F0
	CMP #$F0
	BNE +
	
	LDA !dynSiganls3
	AND #$F0
	STA !dynSiganls3
	
	LDA !dynSiganls2
	AND #$0F
	STA !dynSiganls2
	
	LDA #$0E
	STA $00
	RTS
	
+
	LDA !dynSiganls2
	AND #$0F
	CMP #$0F
	BNE +

	LDA !dynSiganls1
	AND #$F0
	CMP #$F0
	BNE +
	
	LDA !dynSiganls2
	AND #$F0
	STA !dynSiganls2
	
	LDA !dynSiganls1
	AND #$0F
	STA !dynSiganls1
	
	LDA #$02
	STA $00
	RTS
	
+	
	LDA !dynSiganls1
	CMP #$FF
	BNE +
	
	LDA #$00
	STA !dynSiganls1
	
	LDA #$04
	STA $00
	RTS	
	
+
	LDA #$FF
	STA $00
	RTS

;					 $00,$08,$20,$28,$40,$48,$60,$68
sendSignals48:		db $0F,$0F,$F0,$F0,$0F,$0F,$F0,$F0
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $0F,$0F,$F0,$F0,$0F,$0F,$F0,$F0
					
;					   $00,$08,$20,$28,$40,$48,$60,$68
getSignals48:		db $01,$01,$01,$01,$00,$00,$00,$00
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $02,$02,$02,$02,$02,$02,$02,$02
					
;					   $00,$08,$20,$28,$40,$48,$60,$68
slotUsed48:			db $1E,$1E,$16,$16,$0E,$0E,$06,$06
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $2E,$2E,$2E,$2E,$2E,$2E,$26,$26
					
DynamicRoutine48Start:

	PHX 
	
	PHB
	PHK
	PLB
	
	LDA getSignals48,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals48,y
	STA !dynSiganls1,x
	
	LDA slotUsed48,y
	STA $00
	PLB
	
	LDA !lastSender
	BMI +
	TAX

	LDA $00
	STA !nextDynSlot,x
	LDA #$00
	STA !nextDynSlot+$01,x
	
+
	LDA $00
	STA !lastSender

	LDA !firstSlot
	BPL +
	LDA $00
	STA !firstSlot
	LDA #$00
	STA !firstSlot+$01
+
	
	PLX

	RTL

Ping48:
	PHX 
	
	PHB
	PHK
	PLB
	
	LDA getSignals48,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals48,y
	STA !dynSiganls1,x
	PLB
	PLX
	RTL
	
reserveNormalSlot48:

	JSR reserveSlot48
	LDA $00
	STA !tileRelativePositionNormal,x
	RTL
	
reserveExtendedSlot48:

	JSR reserveSlot48
	LDA $00
	STA !tileRelativePositionExtended,x
	RTL
	
reserveClusterSlot48:

	JSR reserveSlot48
	LDA $00
	TYX
	STA !tileRelativePositionCluster,x
	RTL

reserveSlot48:

	LDA !mode50
	BEQ ++
	
	LDA !dynSiganls3
	AND #$F0
	CMP #$F0
	BNE +
	
	LDA !dynSiganls3
	AND #$0F
	STA !dynSiganls3
	
	LDA #$0C
	STA $00
	RTS
	
+
	LDA !dynSiganls3
	AND #$0F
	CMP #$0F
	BNE ++
	
	LDA !dynSiganls3
	AND #$F0
	STA !dynSiganls3
	
	LDA #$0E
	STA $00
	RTS

++
	LDA !dynSiganls2
	AND #$F0
	CMP #$F0
	BEQ +
	
	LDA !dynSiganls2
	AND #$0F
	CMP #$0F
	BNE ++
	
	LDA !dynSiganls2
	AND #$F0
	STA !dynSiganls2
	
	LDA #$02
	STA $00
	
	RTS
+

	LDA !dynSiganls2
	AND #$0F
	STA !dynSiganls2
	
	LDA #$00
	STA $00
	RTS
++
	LDA !dynSiganls1
	AND #$F0
	CMP #$F0
	BEQ +
	
	LDA !dynSiganls1
	AND #$0F
	CMP #$0F
	BNE ++
	
	LDA !dynSiganls1
	AND #$F0
	STA !dynSiganls1
	
	LDA #$06
	STA $00
	RTS
+

	LDA !dynSiganls1
	AND #$0F
	STA !dynSiganls1
	
	LDA #$04
	STA $00
	RTS
++
	LDA #$FF
	STA $00
	RTS
	
reserveNormalSlot32:

	JSR reserveSlot32
	LDA $00
	STA !tileRelativePositionNormal,x

	RTL
	
reserveExtendedSlot32:

	JSR reserveSlot32
	LDA $00
	STA !tileRelativePositionExtended,x
	RTL
	
reserveClusterSlot32:

	JSR reserveSlot32
	LDA $00
	TYX
	STA !tileRelativePositionCluster,x
	RTL
	
reserveSlot32:

	LDA !mode50
	BEQ ++
	
	LDA !dynSiganls3
	AND #$C0
	CMP #$C0
	BNE +
	
	LDA !dynSiganls3
	AND #$3F
	STA !dynSiganls3
	
	LDA #$0C
	STA $00
	RTS
+
	LDA !dynSiganls3
	AND #$30
	CMP #$30
	BNE +
	
	LDA !dynSiganls3
	AND #$CF
	STA !dynSiganls3
	
	LDA #$0D
	STA $00
	RTS
+
	LDA !dynSiganls3
	AND #$0C
	CMP #$0C
	BNE +
	
	LDA !dynSiganls3
	AND #$F3
	STA !dynSiganls3
	
	LDA #$0E
	STA $00
	RTS
+
	LDA !dynSiganls3
	AND #$03
	CMP #$03
	BNE ++

	LDA !dynSiganls3
	AND #$FC
	STA !dynSiganls3
	
	LDA #$0F
	STA $00
	RTS
++
	
	LDA !dynSiganls2
	AND #$C0
	CMP #$C0
	BNE +
	
	LDA !dynSiganls2
	AND #$3F
	STA !dynSiganls2
	
	LDA #$00
	STA $00
	RTS
+
	LDA !dynSiganls2
	AND #$30
	CMP #$30
	BNE +
	
	LDA !dynSiganls2
	AND #$CF
	STA !dynSiganls2
	
	LDA #$01
	STA $00
	RTS
+
	LDA !dynSiganls2
	AND #$0C
	CMP #$0C
	BNE +
	
	LDA !dynSiganls2
	AND #$F3
	STA !dynSiganls2
	
	LDA #$02
	STA $00
	RTS
+
	LDA !dynSiganls2
	AND #$03
	CMP #$03
	BNE ++

	LDA !dynSiganls2
	AND #$FC
	STA !dynSiganls2
	
	LDA #$03
	STA $00
	RTS
++
	
	LDA !dynSiganls1
	AND #$C0
	CMP #$C0
	BNE +
	
	LDA !dynSiganls1
	AND #$3F
	STA !dynSiganls1
	
	LDA #$04
	STA $00
	RTS
+
	LDA !dynSiganls1
	AND #$30
	CMP #$30
	BNE +
	
	LDA !dynSiganls1
	AND #$CF
	STA !dynSiganls1
	
	LDA #$05
	STA $00
	RTS
+
	LDA !dynSiganls1
	AND #$0C
	CMP #$0C
	BNE +
	
	LDA !dynSiganls1
	AND #$F3
	STA !dynSiganls1
	
	LDA #$06
	STA $00
	RTS
+
	LDA !dynSiganls1
	AND #$03
	CMP #$03
	BNE ++

	LDA !dynSiganls1
	AND #$FC
	STA !dynSiganls1
	
	LDA #$07
	STA $00
	RTS
++
	LDA #$FF
	STA $00
	RTS

;					   $00,$08,$20,$28,$40,$48,$60,$68
sendSignals32:		db $3F,$CF,$F3,$FC,$3F,$CF,$F3,$FC
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $3F,$CF,$F3,$FC,$3F,$CF,$F3,$FC
					
;					   $00,$08,$20,$28,$40,$48,$60,$68
getSignals32:		db $01,$01,$01,$01,$00,$00,$00,$00
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $02,$02,$02,$02,$02,$02,$02,$02
					
;					   $00,$08,$20,$28,$40,$48,$60,$68
slotUsed32:			db $1E,$1C,$16,$14,$0E,$0C,$06,$04
;					   $80,$88,$A0,$A8,$C0,$C8,$E0,$E8
					db $2E,$2E,$2E,$2E,$2E,$2C,$26,$24
	
DynamicRoutine32Start:

	PHX 
	
	PHB
	PHK
	PLB
	
	LDA getSignals32,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals32,y
	STA !dynSiganls1,x
	
	LDA slotUsed32,y
	STA $00
	
	PLB
	
	LDA !lastSender
	BMI +
	TAX

	LDA $00
	STA !nextDynSlot,x
	LDA #$00
	STA !nextDynSlot+$01,x
	
+
	LDA $00
	SEC
	SBC #$04
	STA !lastSender

	LDA !firstSlot
	BPL +
	LDA $00
	STA !firstSlot
	LDA #$00
	STA !firstSlot+$01
+
	
	PLX

	RTL

Ping32:
	PHX 
	
	PHB
	PHK
	PLB
	
	LDA getSignals32,y
	TAX
	
	LDA !dynSiganls1,x
	AND sendSignals32,y
	STA !dynSiganls1,x
	PLB
	PLX
	RTL

hidestatusBar:

	LDY #$36
	LDA #$FC
.loop
	STA $0EF9|!base2,y
	DEY
	BPL .loop
	
	REP #$30
	LDA $7F837B
	TAX

	LDA #$2E50		;first two digit = position
	STA $7F837D,x
	INX
	INX

	LDA #$0700
	STA $7F837D,x
	INX
	INX

	LDA #$00FC		;xx39, xx = tile properties.
	STA $7F837D,x
	INX
	INX
	
	LDA #$00FC		;xx39, xx = tile properties.
	STA $7F837D,x
	INX
	INX
	
	LDA #$00FC		;xx39, xx = tile properties.
	STA $7F837D,x
	INX
	INX
	
	LDA #$00FC		;xx39, xx = tile properties.
	STA $7F837D,x
	INX
	INX
	
	LDA #$8E50		;first two digit = position
	STA $7F837D,x
	INX
	INX

	LDA #$0700
	STA $7F837D,x
	INX
	INX

	LDA #$00FC		;xx39, xx = tile properties.
	STA $7F837D,x
	INX
	INX
	
	LDA #$00FC		;xx39, xx = tile properties.
	STA $7F837D,x
	INX
	INX
	
	LDA #$00FC		;xx39, xx = tile properties.
	STA $7F837D,x
	INX
	INX
	
	LDA #$00FC		;xx39, xx = tile properties.
	STA $7F837D,x
	INX
	INX

	LDA #$FFFF
	STA $7F837D,x
	
	TXA
	STA $7F837B
	SEP #$30
	RTL

graphicRoutine:
RTL

SPR_T1:	db $0C,$1C
SPR_T2:	db $01,$02

GET_DRAW_INFO:  
	PHB
	PHK
	PLB
	JSR GDI
	PLB
	RTL

GDI:
	STZ $06
	STZ !186C,x             ; reset sprite offscreen flag, vertical
	STZ !15A0,x             ; reset sprite offscreen flag, horizontal
	LDA !E4,x               ; \
	CMP $1A                 ;  | set horizontal offscreen if necessary
	LDA !14E0,x             ;  |
	SBC $1B                 ;  |
	BEQ ON_SCREEN_X         ;  |
	INC !15A0,x             ; /

ON_SCREEN_X:
	LDA !14E0,x             ; \
	XBA                     ;  |
	LDA !E4,x               ;  |
	REP #$20                ;  |
	SEC                     ;  |
	SBC $1A                 ;  | mark sprite invalid if far enough off screen
	CLC                     ;  |
	ADC #$0040            ;  |
	CMP #$0180            ;  |
	SEP #$20                ;  |
	ROL A                   ;  |
	AND #$01                ;  |
	STA !15C4,x             ; / 
	BNE INVALID             ; 

	LDY #$00                ; \ set up loop:
	LDA !1662,x             ;  | 
	AND #$20                ;  | if not smushed (1662 & 0x20), go through loop twice
	BEQ ON_SCREEN_LOOP      ;  | else, go through loop once
	INY                     ; / 

ON_SCREEN_LOOP:
	LDA !D8,x               ; \ 
	CLC                     ;  | set vertical offscreen if necessary
	ADC SPR_T1,y            ;  |
	PHP                     ;  |
	CMP $1C                 ;  | (vert screen boundry)
	ROL $00                 ;  |
	PLP                     ;  |
	LDA !14D4,x             ;  | 
	ADC #$00                ;  |
	LSR $00                 ;  |
	SBC $1D                 ;  |
	BEQ ON_SCREEN_Y         ;  |
	LDA !186C,x             ;  | (vert offscreen)
	ORA SPR_T2,y            ;  |
	STA !186C,x             ;  |
ON_SCREEN_Y:				;  |
	DEY                     ;  |
	BPL ON_SCREEN_LOOP      ; /

	LDY !15EA,x             ; get offset to sprite OAM
	LDA !E4,x               ; \ 
	SEC                     ;  | 
	SBC $1A                 ;  | $00 = sprite x position relative to screen boarder
	STA $00                 ; / 
	LDA !D8,x               ; \ 
	SEC                     ;  | 
	SBC $1C                 ;  | $01 = sprite y position relative to screen boarder
	STA $01                 ; / 
	RTS                     ; return

INVALID:
	LDA #$01
	STA $06                    ;  |    ...(not just this subroutine)
	RTS                     ; /	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $B85D - off screen processing code - shared
; sprites enter at different points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPR_T12:
	db $40,$B0
SPR_T13:
	db $01,$FF
SPR_T14:
	db $30,$C0,$A0,$C0,$A0,$F0,$60,$90		;bank 1 sizes
	db $30,$C0,$A0,$80,$A0,$40,$60,$B0		;bank 3 sizes
SPR_T15:
	db $01,$FF,$01,$FF,$01,$FF,$01,$FF		;bank 1 sizes
	db $01,$FF,$01,$FF,$01,$00,$01,$FF		;bank 3 sizes

SUB_OFF_SCREEN_X1: 
	LDA #$02                ; \ entry point of routine determines value of $03
	BRA PRESTART_SUB
SUB_OFF_SCREEN_X2: 
	LDA #$04                ; \ entry point of routine determines value of $03
	BRA PRESTART_SUB
SUB_OFF_SCREEN_X3: 
	LDA #$06                ; \ entry point of routine determines value of $03
	BRA PRESTART_SUB
SUB_OFF_SCREEN_X4: 
	LDA #$08                ; \ entry point of routine determines value of $03
	BRA PRESTART_SUB
SUB_OFF_SCREEN_X5: 
	LDA #$0A                ; \ entry point of routine determines value of $03
	BRA PRESTART_SUB
SUB_OFF_SCREEN_X6: 
	LDA #$0C                ; \ entry point of routine determines value of $03
	BRA PRESTART_SUB
SUB_OFF_SCREEN_X7: 
	LDA #$0E                ; \ entry point of routine determines value of $03
	BRA PRESTART_SUB
SUB_OFF_SCREEN_X0: 
	LDA #$00                ; \ entry point of routine determines value of $03
	
PRESTART_SUB:
	PHB
	PHK
	PLB
	STA $03            ;  | (table entry to use on horizontal levels)
	JSR START_SUB
	PLB
	RTL

START_SUB:
	JSR SUB_IS_OFF_SCREEN   ; \ if sprite is not off screen, return
	BEQ RETURN_35           ; /
	LDA $5B                 ; \  goto VERTICAL_LEVEL if vertical level
	AND #$01                ; |
	BNE VERTICAL_LEVEL      ; /     
	LDA !D8,x               ; \
	CLC                     ; | 
	ADC #$50                ; | if the sprite has gone off the bottom of the level...
	LDA !14D4,x             ; | (if adding 0x50 to the sprite y position would make the high byte >= 2)
	ADC #$00                ; | 
	CMP #$02                ; | 
	BPL ERASE_SPRITE        ; /    ...erase the sprite
	LDA !167A,x             ; \ if "process offscreen" flag is set, return
	AND #$04                ; |
	BNE RETURN_35           ; /
	LDA $13                 ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0756 VC:176 00 FL:205
	AND #$01                ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0780 VC:176 00 FL:205
	ORA $03                 ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0796 VC:176 00 FL:205
	STA $01                 ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0820 VC:176 00 FL:205
	TAY                     ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0844 VC:176 00 FL:205
	LDA $1A                 ;A:8A01 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizcHC:0858 VC:176 00 FL:205
	CLC                     ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0882 VC:176 00 FL:205
	ADC SPR_T14,y           ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZcHC:0896 VC:176 00 FL:205
	ROL $00                 ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizcHC:0928 VC:176 00 FL:205
	CMP !E4,x               ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizCHC:0966 VC:176 00 FL:205
	PHP                     ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:0996 VC:176 00 FL:205
	LDA $1B                 ;A:8AC0 X:0009 Y:0001 D:0000 DB:01 S:01F0 P:envMXdizCHC:1018 VC:176 00 FL:205
	LSR $00                 ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F0 P:envMXdiZCHC:1042 VC:176 00 FL:205
	ADC SPR_T15,y           ;A:8A00 X:0009 Y:0001 D:0000 DB:01 S:01F0 P:envMXdizcHC:1080 VC:176 00 FL:205
	PLP                     ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F0 P:eNvMXdizcHC:1112 VC:176 00 FL:205
	SBC !14E0,x             ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1140 VC:176 00 FL:205
	STA $00                 ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizCHC:1172 VC:176 00 FL:205
	LSR $01                 ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:eNvMXdizCHC:1196 VC:176 00 FL:205
	BCC SPR_L31             ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZCHC:1234 VC:176 00 FL:205
	EOR #$80                ;A:8AFF X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdiZCHC:1250 VC:176 00 FL:205
	STA $00                 ;A:8A7F X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1266 VC:176 00 FL:205
SPR_L31:
	LDA $00                 ;A:8A7F X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1290 VC:176 00 FL:205
	BPL RETURN_35           ;A:8A7F X:0009 Y:0001 D:0000 DB:01 S:01F1 P:envMXdizCHC:1314 VC:176 00 FL:205
ERASE_SPRITE:
	LDA !14C8,x             ; \ if sprite status < 8, permanently erase sprite
	CMP #$08                ; |
	BCC KILL_SPRITE         ; /    
	LDY !161A,x             ;A:FF08 X:0007 Y:0001 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1108 VC:059 00 FL:2878
	CPY #$FF                ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdiZCHC:1140 VC:059 00 FL:2878
	BEQ KILL_SPRITE         ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdizcHC:1156 VC:059 00 FL:2878
	LDA #$00                ;A:FF08 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdizcHC:1172 VC:059 00 FL:2878
if read1($00FFD5) != $23
	STA $1938,y             ;A:FF00 X:0007 Y:0000 D:0000 DB:01 S:01F3 P:envMXdiZcHC:1188 VC:059 00 FL:2878
else
	PHX
	TYX
	STA $418A00,x
	PLX
endif

KILL_SPRITE:
	STZ !14C8,x             ; erase sprite
RETURN_35:
	RTS                     ; return

VERTICAL_LEVEL:
	LDA !167A,x             ; \ if "process offscreen" flag is set, return
	AND #$04                ; |
	BNE RETURN_35           ; /
	LDA $13                 ; \
	LSR A                   ; | 
	BCS RETURN_35           ; /
	LDA !E4,x               ; \ 
	CMP #$00                ;  | if the sprite has gone off the side of the level...
	LDA !14E0,x             ;  |
	SBC #$00                ;  |
	CMP #$02                ;  |
	BCS ERASE_SPRITE        ; /  ...erase the sprite
	LDA $13                 ;A:0000 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:1218 VC:250 00 FL:5379
	LSR A                   ;A:0016 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1242 VC:250 00 FL:5379
	AND #$01                ;A:000B X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1256 VC:250 00 FL:5379
	STA $01                 ;A:0001 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1272 VC:250 00 FL:5379
	TAY                     ;A:0001 X:0009 Y:00E4 D:0000 DB:01 S:01F3 P:envMXdizcHC:1296 VC:250 00 FL:5379
	LDA $1C                 ;A:001A X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0052 VC:251 00 FL:5379
	CLC                     ;A:00BD X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0076 VC:251 00 FL:5379
	ADC SPR_T12,y           ;A:00BD X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0090 VC:251 00 FL:5379
	ROL $00                 ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F3 P:enVMXdizCHC:0122 VC:251 00 FL:5379
	CMP !D8,x               ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNVMXdizcHC:0160 VC:251 00 FL:5379
	PHP                     ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNVMXdizcHC:0190 VC:251 00 FL:5379
	LDA $001D|!base1        ;A:006D X:0009 Y:0001 D:0000 DB:01 S:01F2 P:eNVMXdizcHC:0212 VC:251 00 FL:5379
	LSR $00                 ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F2 P:enVMXdiZcHC:0244 VC:251 00 FL:5379
	ADC SPR_T13,y           ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F2 P:enVMXdizCHC:0282 VC:251 00 FL:5379
	PLP                     ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F2 P:envMXdiZCHC:0314 VC:251 00 FL:5379
	SBC !14D4,x             ;A:0000 X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNVMXdizcHC:0342 VC:251 00 FL:5379
	STA $00                 ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0374 VC:251 00 FL:5379
	LDY $01                 ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0398 VC:251 00 FL:5379
	BEQ SPR_L38             ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0422 VC:251 00 FL:5379
	EOR #$80                ;A:00FF X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0438 VC:251 00 FL:5379
	STA $00                 ;A:007F X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0454 VC:251 00 FL:5379
SPR_L38:
	LDA $00                 ;A:007F X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0478 VC:251 00 FL:5379
	BPL RETURN_35           ;A:007F X:0009 Y:0001 D:0000 DB:01 S:01F3 P:envMXdizcHC:0502 VC:251 00 FL:5379
	BMI ERASE_SPRITE        ;A:8AFF X:0002 Y:0000 D:0000 DB:01 S:01F3 P:eNvMXdizcHC:0704 VC:184 00 FL:5490

SUB_IS_OFF_SCREEN:
	LDA !15A0,x             ; \ if sprite is on screen, accumulator = 0 
	ORA !186C,x             ; |  
	RTS                     ; / 