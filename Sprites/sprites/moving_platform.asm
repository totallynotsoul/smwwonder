;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SMB3 Brown Platform (V 1.1)
;;by RealLink
;;
;;This platform will start to move right when Mario steps on it
;;
;;Based on:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SMB3 Moving Cloud, by Mirumo
;;
;;Extra Bit: YES
;;Clear	:Use first property byte for X speed
;;Set	:use second property byte for X speed
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Print "MAIN ",pc                                    
	PHB                     ; \
	PHK                     ;  | main sprite function, just calls local subroutine
	PLB                     ;  |
	JSR SPRITE_CODE_START   ;  |
	PLB                     ;  |
Print "INIT ",pc	    ;  | And init, which does nothing.
	RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    

RETURN:
	RTS

SPRITE_CODE_START:
	JSR SPRITE_GRAPHICS     ; graphics routine
	LDA !14C8,x             ; \ 
	EOR #$08                ;  | if status != 8, return
	ORA $9D                 ; \ if sprites locked, return
	BNE RETURN              ; /
	%SubOffScreen()         ; handle off screen situation
	JSL $018022|!BankB      ; Update x position, no gravity
	LDA !sprite_x_high,x
	PHA
	LDA !sprite_x_low,x
	PHA
	%SubHorzPos()
	CPY #$01
	BEQ +
	REP #$21
	LDA $01,S
	ADC #$007A
	CMP $94
	SEP #$20
	BCC.b +
	LDA $94
	STA !sprite_x_low,x
	LDA $95
	STA !sprite_x_high,x
+
	JSL $01B44F|!BankB	     ; Load invisible solid block routine.
	BCC RETURN2
	LDA $1471|!Base2
	BEQ RETURN2
	LDA #$18
	STA !1540,x
	LDA !7FAB10,x
	AND #$04
	BNE AnotherProp
	LDA !extra_prop_1,x
	BRA Meh

AnotherProp:
	LDA !extra_prop_2,x
Meh:
	STA !B6,x
	JSR RIDE
RETURN2:
	LDA $01,S
	STA !sprite_x_low,x
	LDA $02,S
	STA !sprite_x_high,x
	LDA !7FAB10,x
	AND #$04
	BNE LeftSideCollision
	LDA !sprite_x_low,x
	CLC
	ADC	#$80
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	ADC #$00
	STA !sprite_x_high,x
LeftSideCollision:
	LDA !sprite_x_low,x
	STA $9A
	LDA !sprite_x_high,x
	STA $9B
	LDA !sprite_y_low,x
	STA $98
	LDA !sprite_y_high,x
	STA $99
	STZ $1933|!Base2
	%GetMap16()			     ; Check for collision with a level tile.
	REP #$20
	CMP #$0580				; Map16 tile ID that makes the sprite stop
	SEP #$20
	BNE +
	STZ !B6,x
+:
	PLA
	STA !sprite_x_low,x
	PLA
	STA !sprite_x_high,x
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RIDE:               
	LDY #$00                ; \ 
	LDA $1491|!Base2        ;  | $1491 == 01 or FF, depending on direction
	BPL LABEL9              ;  | set mario's new x position
	DEY                     ;  |
LABEL9:
	CLC                     ;  |
	ADC $94                 ;  |
	STA $94                 ;  |
	TYA                     ;  |
	ADC $95                 ;  |
	STA $95                 ; /
RETURN_24:
	RTS                     ;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FallingPlatDispX:
	db $00,$10,$20,$30,$40,$50,$60,$70
	db $00,$10,$20,$30,$40,$50,$60,$70

FallingPlatDispY:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $10,$10,$10,$10,$10,$10,$10,$10

FallingPlatTiles:
	db $C0,$C2,$C2,$C2,$C2,$C2,$C2,$C4
	db $E0,$E2,$E2,$E2,$E2,$E2,$E2,$E4

FallingPlatPriority:
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $10,$10,$10,$10,$10,$10,$10,$10

SPRITE_GRAPHICS:
    %GetDrawInfo()
	PHX                       
	LDA !15F6,X   
	STA $02
	LDX #$0F               
CODE_038498:
	LDA $00                   
	CLC                       
	ADC FallingPlatDispX,X  
	STA $0300|!Base2,Y         
	LDA $01
	CLC                       
	ADC FallingPlatDispY,X 	
	STA $0301|!Base2,Y         
	LDA FallingPlatTiles,X  
	STA $0302|!Base2,Y          
	LDA FallingPlatPriority,x
	CMP #$FF
	BNE +
	LDA $64
+:
	ORA $02                              
	STA $0303|!Base2,Y          
	INY                       
	INY                       
	INY                       
	INY                       
	DEX                       
	BPL CODE_038498           
	PLX                       
	LDY #$02                
	LDA #$10
	JSL $01B7B3|!BankB     
	RTS                       ; Return 