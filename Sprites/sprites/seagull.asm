; Cluster Seagull by Darolac

; defines

!Tile1 = $8A	; tile numbers
!Tile2 = $9A

!Size = $00	; size of the tile. 8x8 by default

!Prop = $08	; properties of the seagull

!Speed = $01 ; speed of the seagull 

; tables

Speed:
db !Speed,-!Speed

Tiles:

db !Tile1,!Tile2

Initialphase:
db $0A,$05,$08,$01,$0D

print "MAIN ",pc
Main:

LDA #$01
STA $1E2A|!Base2,y

LDA $9D				; \ Don't move if sprites are supposed to be frozen.
BNE Nomovement		; /

LDA $1E8E|!Base2,y
BNE +
LDA Initialphase,y
STA $1E52|!Base2,y
LDA #$01
STA $1E8E|!Base2,y
+

LDA $14
AND #$01
BEQ Nomovement

LDA $1E52|!Base2,y
CLC
ADC #$01
STA $1E52|!Base2,y
LDA $1E52|!Base2,y
CMP #$10
BNE Noturn
LDA #$00
STA $1E52|!Base2,y
LDA $1E66|!Base2,y
EOR #$01
STA $1E66|!Base2,y
Noturn:
LDX $1E66|!Base2,y
LDA $1E16|!Base2,y
CLC
ADC Speed,x
STA $1E16|!Base2,y

Nomovement:                  ; OAM routine starts here.

JSR GFX ; graphics routine.
RTL

GFX:
JSR FindOAM
LDA $1E02|!Base2,y			; \ Copy Y position relative to screen Y to OAM Y.
SEC                             ;  |
SBC $1C				;  |
STA $0301|!Base2,x			; /
LDA $1E16|!Base2,y			; \ Copy X position relative to screen X to OAM X.
SEC				;  |
SBC $1A				;  |
STA $0300|!Base2,x			; /

PHX
LDA $14
LSR #3
AND #$01
TAX
LDA Tiles,x
PLX
STA $0302|!Base2,x                     ; /
LDA #!Prop
STA $0303|!Base2,x
PHX
TXA
LSR
LSR
TAX
LDA #!Size
STA $0420|!Base2,x
PLX
LDA $18BF|!Base2
ORA $1493|!Base2
BEQ +            ; Change BEQ to BRA if you don't want it to disappear at generator 2, sprite D2.
LDA $0301|!Base2,x
CMP #$F0                                    	; As soon as the sprite is off-screen...
BCC +
LDA #$00					; Kill it.
STA $1892|!Base2,y					;

+  RTS

FindOAM:

LDX #$10
-
LDA $0301|!Base2,x
CMP #$F0
BEQ .found
INX #4 
CPX #$FC
BEQ .none_found
BRA -
.none_found
PLA
PLA
.found
RTS