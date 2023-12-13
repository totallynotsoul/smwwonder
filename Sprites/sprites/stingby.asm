;~@sa1 <-- DO NOT REMOVE THIS LINE!
;;;;;;;;;;;;;;;;
;stingby by tsutarja
;;;;;;;;;;;;;;;;

Xspdpeace: db $10,$F0
frm1:  db $00,$01				;pacific frame table
frm2:  db $02,$03				;angry 	   ^     ^

Xspd:		db $1E,$E2
Xaccel:		db $02,$FE

Yspd:		db $08,$F7		;NOTE: Those are for both pacific and angry states.
Yaccel:		db $01,$FF		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print "INIT ", pc
	JSR SUB_HORZ_POS
	TYA
	STA $3334,x
	STZ $D8,x
	LDA #$40
	STA $33FA,x		;time between turnarounds (peace)
	RTL

print "MAIN ", pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL

Return:
	RTS

Run:
        JSR Graphics
	LDA $3242,x		;If the sprite is dead..
	CMP #$08
	BNE Return		;..return
	LDA $9D
	BNE Return		;Also return if sprites are locked.
	JSR SUB_OFF_SCREEN_X0
        JSL $018022
        JSL $01801A
	JSL $01A7DC
	LDA $D8,x
	BEQ .peace
	JSR SpdChase
	LDA $14
	LSR
	AND #$01
	TAY
	LDA frm2,y
	STA $329A,X
	JSR SUB_HORZ_POS
	TYA
	STA $3334,x
	RTS

.peace
LDA #$30
STA $00
JSR Proximity
BNE .hostile
LDY $3334,x
LDA Xspdpeace,y
STA $B6,x
JSR Spd
LDA $14
LSR
AND #$01
TAY
LDA frm1,y
STA $329A,X
LDA $33FA,x
BNE .return
LDA $3334,x
EOR #$01
STA $3334,x
LDA #$40
STA $33FA,x
.return
RTS

.hostile
INC $D8,x
RTS

Spd:
LDA $74F4,x
AND #$01
TAY
LDA $9E,x
CLC
ADC Yaccel,y
STA $9E,x
CMP Yspd,y
BNE .nochange
INC $74F4,x
.nochange
rts

SpdChase:
    LDA $14
    AND #$03
    BNE Return22
    JSR SUB_HORZ_POS
    LDA $B6,x		  
    CMP Xspd,y       
    BEQ MaxXSpeedReached
    CLC                   
    ADC Xaccel,y
    STA $B6,x
MaxXSpeedReached:
    JSR SUB_VERT_POS           
    LDA $9E,x
    CMP Yspd,y
    BEQ Return22
    CLC 
    ADC Yaccel,y
    STA $9E,x
Return22:
    RTS

DirFix: db $FF,$00

Proximity:
	LDA $322C,x		;\
	SEC				; |
	SBC $94			; |
	PHA				; |
	JSR SUB_HORZ_POS	; | Check sprite range ..
	PLA				; |
	EOR DirFix,y		; |
	CMP $00			; | If Range > !Temp return.
	BCC +			; | If in RANGE.. branch.
	LDA #$00
	RTS				;/
+	LDA #$01
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;graphics
PROPERTIES:
    db $45,$05

TILEMAP:
    db $8D,$8C,$9C,$9D
    db $BD,$BC,$CC,$CD
    db $8D,$EE,$9C,$9D
    db $BD,$EC,$CC,$CD
    
YDISP:           
    db $FC,$FC,$04,$04
    
XDISP:
    db $04,$FC,$FC,$04
XDISP2:
    db $FC,$04,$04,$FC

Graphics:
    JSR GET_DRAW_INFO

    LDA $3334,x
    STA $02  

    LDA $329A,X
    ASL #2
    STA $03
    
    PHX		
    LDX #$03		
Loop:		
    LDA $00		
    PHX
    LDX $02
    BNE .thisp
    PLX
    CLC		
    ADC XDISP2,x
    JMP .thisp2	
.thisp
    PLX
    CLC		
    ADC XDISP,x	
.thisp2
    STA $6300,y
    	
    LDA $01		
    CLC		
    ADC YDISP,x	
    STA $6301,y
    	
    PHX		
    TXA		
    CLC		
    ADC $03		
    TAX		
    LDA TILEMAP,x	
    STA $6302,y	
    
    PHX
    LDX $02
    LDA PROPERTIES,x
    ORA $64
    STA $6303,y  
    PLX

    INY #4
    PLX
    DEX
    BPL Loop
    PLX
    LDY #$02
    LDA #$03
    JSL $01B7B3
    RTS

;=================;
;SUB_HORZ_POS
;=================;

SUB_HORZ_POS:
	LDY #$00
	LDA $D1
	SEC
	SBC $322C,x
	STA $0F
	LDA $D2
	SBC $326E,x
	BPL SPR_L16
	INY
SPR_L16:
	RTS

;=================;
;SUB_VERT_POS
;=================;

SUB_VERT_POS:
	LDY #$00
	LDA $D3
	SEC
	SBC $3216,x
	STA $0F
	LDA $D4
	SBC $3258,x
	BPL SPR_L11
	INY
SPR_L11:
	RTS

;=================;
;SUB_OFF_SCREEN
;=================;

SPR_T12:
	db $40,$B0
SPR_T13:
	db $01,$FF
SPR_T14:
	db $30,$C0,$A0,$C0,$A0,$F0,$60,$90
	db $30,$C0,$A0,$80,$A0,$40,$60,$B0
SPR_T15:
	db $01,$FF,$01,$FF,$01,$FF,$01,$FF
	db $01,$FF,$01,$FF,$01,$00,$01,$FF

SUB_OFF_SCREEN_X1:
	LDA #$02
	BRA STORE_03
SUB_OFF_SCREEN_X2:
	LDA #$04
	BRA STORE_03
SUB_OFF_SCREEN_X3:
	LDA #$06
	BRA STORE_03
SUB_OFF_SCREEN_X4:
	LDA #$08
	BRA STORE_03
SUB_OFF_SCREEN_X5:
	LDA #$0A
	BRA STORE_03
SUB_OFF_SCREEN_X6:
	LDA #$0C
	BRA STORE_03
SUB_OFF_SCREEN_X7:
	LDA #$0E
STORE_03:
	STA $03
	BRA START_SUB
SUB_OFF_SCREEN_X0:
	STZ $03

START_SUB:
	JSR SUB_IS_OFF_SCREEN
	BEQ RETURN_35
	LDA $5B
	AND #$01
	BNE VERTICAL_LEVEL
	LDA $3216,x
	CLC
	ADC #$50
	LDA $3258,x
	ADC #$00
	CMP #$02
	BPL ERASE_SPRITE
	LDA $7616,x
	AND #$04
	BNE RETURN_35
	LDA $13
	AND #$01
	ORA $03
	STA $01
	TAY
	LDA $1A
	CLC
	ADC SPR_T14,y
	ROL $00
	CMP $322C,x
	PHP
	LDA $1B
	LSR $00
	ADC SPR_T15,y
	PLP
	SBC $326E,x
	STA $00
	LSR $01
	BCC SPR_L31
	EOR #$80
	STA $00
SPR_L31:
	LDA $00
	BPL RETURN_35
	ERASE_SPRITE:
	LDA $3242,x
	CMP #$08
	BCC KILL_SPRITE
	LDY $7578,x
	CPY #$FF
	BEQ KILL_SPRITE
	LDA #$00
	PHX
	TYX
	STA $418A00,x
	PLX        
KILL_SPRITE:
	STZ $3242,x
RETURN_35:
	RTS

VERTICAL_LEVEL:
	LDA $7616,x
	AND #$04
	BNE RETURN_35
	LDA $13
	LSR A
	BCS RETURN_35
	LDA $322C,x
	CMP #$00
	LDA $326E,x
	SBC #$00
	CMP #$02
	BCS ERASE_SPRITE
	LDA $13
	LSR A
	AND #$01
	STA $01
	TAY
	LDA $1C
	CLC
	ADC SPR_T12,y
	ROL $00
	CMP $3216,x
	PHP
	LDA $301D
	LSR $00
	ADC SPR_T13,y
	PLP
	SBC $3258,x
	STA $00
	LDY $01
	BEQ SPR_L38
	EOR #$80
	STA $00
SPR_L38:
	LDA $00
	BPL RETURN_35
	BMI ERASE_SPRITE

SUB_IS_OFF_SCREEN:
	LDA $3376,x
	ORA $7642,x
	RTS

;================;
;GET_DRAW_INFO
;================;

SPR_T1:
	db $0C,$1C
SPR_T2:
	db $01,$02

GET_DRAW_INFO:
	STZ $7642,x
	STZ $3376,x
	LDA $322C,x
	CMP $1A
	LDA $326E,x
	SBC $1B
	BEQ ON_SCREEN_X
	INC $3376,x

ON_SCREEN_X:
	LDA $326E,x
	XBA
	LDA $322C,x
	REP #$20
	SEC
	SBC $1A
	CLC
	ADC.w #$0040
	CMP.w #$0180
	SEP #$20
	ROL A
	AND #$01
	STA $7536,x
	BNE INVALID

	LDY #$00
	LDA $75EA,x
	AND #$20
	BEQ ON_SCREEN_LOOP
	INY
ON_SCREEN_LOOP:
	LDA $3216,x
	CLC
	ADC SPR_T1,y
	PHP
	CMP $1C
	ROL $00
	PLP
	LDA $3258,x
	ADC #$00
	LSR $00
	SBC $1D
	BEQ ON_SCREEN_Y
	LDA $7642,x
	ORA SPR_T2,y
	STA $7642,x
ON_SCREEN_Y:
	DEY
	BPL ON_SCREEN_LOOP
	LDY $33A2,x
	LDA $322C,x
	SEC
	SBC $1A
	STA $00
	LDA $3216,x
	SEC
	SBC $1C
	STA $01
	RTS

INVALID:
	PLA
	PLA
	RTS
;endregion