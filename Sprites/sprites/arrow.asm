!ItemSelected = $0F63|!addr
!Tile = $C0	;tile used for the cursor.
print "MAIN ",pc
PHB
PHK
PLB
JSR SpriteCode
PLB
print "INIT ",pc
RTL
SpriteCode:
LDA !extra_byte_1,x
STA $0F65|!addr
LDA !ItemSelected
CMP $0F65|!addr
BEQ draw
RTS
draw:
JSR DrawGraphics	;draw graphics subroutine.
DrawGraphics:
!XDisp = $02		;tile X displacement.
!YDisp = $02		;tile Y displacement.

%GetDrawInfo()

LDA $00			;get sprite X-pos from scratch RAM
CLC			;clear carry
ADC #!XDisp		;add X displacement
STA $0200|!Base2,y	;store to OAM.

LDA $01			;get sprite Y-pos from scratch RAM
CLC			;clear carry
ADC #!YDisp		;add Y displacement
STA $0201|!Base2,y	;store to OAM.
LDA #!Tile	;load tile value (normal cursor)
BRA ++			;and branch ahead.
++
STA $0202|!Base2,y	;store to OAM.

LDA !15F6,x		;load palette/properties from CFG
ORA $64			;set priority bits from level
STA $0203|!Base2,y	;store to OAM.

PHY			;preserve Y
TYA			;transfer Y to A
LSR #2			;divide by 2 twice
TAY			;transfer A to Y
LDA #$02		;load value (tile is set to 16x16)
ORA !15A0,x		;horizontal offscreen flag
STA $0420|!Base2,y	;store to OAM (new Y index).
PLY			;restore Y
RTS			;return.