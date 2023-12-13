;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Extended Puff Of Smoke Sprite Dissasembly
; This is a disassembly of extended sprite 01 in SMW, Puff Of Smoke.
;
; Of course, since it's SMW, rushed and unoptimized game we all know and love 
; I optimized some code for this sprite.
;
; By RussianMan
; Credit is unnecessary.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OAM_Pointer:
db $90,$94,$98,$9C,$A0,$A4,$A8,$AC	;Common OAM pointers for Extended sprites	

OAM_Pointer_9A:
db $05,$03				;Pointers used if sprite's in slots 9 and A

Mode7_OAM_Pointer:
db $02,$02,$02,$02,$02,$02,$F8,$FC	;Used in mode 7 battles (not reznor and Iggy/Larry)
db $A0,$A4

DustCloudTiles:			;Tiles
db $66,$64,$60,$62		;

DustCloudProps:			;Properties for each tile
db $00,$40,$C0,$80		;YXPPCCCT

Print "MAIN ",pc
LDA #$00
%ExtendedSpeed()
LDA $176F|!Base2,x		;If it's animation timer is 0
;BEQ CODE_02A344		;Killing process
BNE NoKill			;Otherwise show smoke animation

Kill:
STZ $170B|!Base2,x		;And since it's a custom extended sprite, we don't have to follow jumps and kill it right here
RTL				;

NoKill:	
LDA $140F|!Base2		;Check if in reznor's boss battle
BNE .Skip			;
LDA $0D9B|!Base2		;Or if not in mode 7 place
BPL .Skip			;Skip some code
AND #$40			;Then it checks if it's Mode 7 Koopalings (but not Iggy or Larry!) or if it's a Bowser.
BNE AlterGFX			;Diffrent GFX routine then

.Skip

LDY OAM_Pointer,X		;Load some pointers
CPX #$08			;If it's in slot that is lower than 8
BCC GFX				;(which is most likely)
LDY OAM_Pointer_9A,X		;Yes, it can use slots that are normally preserved by fireballs. 
				;That's why you can't shoot fireballs when 2 of those are on screen in Iggy/Larry's Boss Battle
				;They apprear when you hit koopalings with fire.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Graphics Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GFX:

LDA $171F|!Base2,x		;It's %SubOffScreen + %GetDrawInfo + Extended Sprite = %ExtendedGetDrawInfo. Yay.
SEC				;
SBC $1A				;
CMP #$F8			;
BCS Kill			;Kill if OffScreen Horizontally
STA $0200|!Base2,y		;Else store to GFX tile position

LDA $1715|!Base2,x		;Do same for Y
SEC				;
SBC $1C				;
CMP #$F0			;
BCS Kill			;
STA $0201|!Base2,y		;GFX tile's Y position

LDA $176F|!Base2,x		;Depending on timer (which is set when spawning extended sprite with normal one)
LSR #2				;
TAX				;
LDA DustCloudTiles,x		;It'll load tiles.
STA $0202|!Base2,y		;and store it

LDA $14				;Load frame counter
LSR #2				;
AND #$03			;
TAX				;
LDA DustCloudProps,X 		;
ORA $64				;
STA $0203|!Base2,y		;
TYA				;
LSR #2				;
TAY				;
LDA #$02			;
STA $0420|!Base2,y		;Take a good care of tiles size
LDX $15E9|!Base2		;
RTL				;

;This is alternate GFX routine for most Mode 7 battles, only diffrences are that it loads diffent OAM pointers
;And that $15E9 and $0420 are swapped (I mean operations with them, not adresses themselfs).

;I'll comment out most of this except of table, then I'll branch back to main one
;Because it seems like a pointless waste of space.

AlterGFX:
LDY Mode7_OAM_Pointer,x		;Diffrent table
BRA GFX				;

;LDA $171F|!Base2,y		;%ExtendedGetDrawInfo but without it.
;SEC				;Again
;SBC $1A			;
;CMP #$F8			;
;BCS Kill			;
;STA $0200|!Base2,y		;

;LDA $1715|!Base2,y		;
;SEC				;
;SBC $1C			;
;CMP #$F0			;
;BCS Kill			;
;STA $0201|!Base2,y		;

;LDA $176F|!Base2,x		;
;LSR #2				;
;TAX				;
;LDA DustCloudTiles,X		;
;STA $0202|!Base2,y		;

;LDA $14
;LSR #2				;
;AND #$03			;
;TAX				;
;LDA DustCloudProps,X 		;
;ORA $64			;
;STA $0203|!Base2,y		;

;LDX $15E9|!Base2		;And 15E9 and Tile Size are swapped
;TYA				;
;LSR #2				;IDK Nintendo
;TAY				;
;LDA #$02			;
;STA $0420|!Base2,y		;
;RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CODE_02A211 - erases extended sprite;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;In inefficient way.

;CODE_02A3AE:		;This sprite have a whole 2 JMPs to the routine! 
;JMP KillExtended	;

;CODE_02A344:		;
;JMP KillExtended	;

;KillExtended:		;CODE_02A211
;LDA #$00              	;Y'know, there are a lot of room for optimizations nintendo
;STA $170B|!Base2,X   	;How's about to use STZ $170B,x for example?
;Return02A216:		;
;RTS			;