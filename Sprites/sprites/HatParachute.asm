
!DespawnSpriteFlag = !1528

print "INIT ",pc
	RTL																					; End sprite init code execution

print "MAIN ",pc
	PHB																					;\ Bank wrapper, used to ensure that absolute address tables will address from the bank this sprite is inserted in.
	PHK																					;|
	PLB																					;|
	JSR.w Sub																			;|
	PLB																					;/
	RTL																					; End sprite main code execution

Sub:
LDA $1908|!addr
CMP #$00
BEQ +
	JSR.w GFXRt																		; Draw the sprite
	LDA.b $9D																			;\ Is the game paused? If so, return
	BNE.b +																			;/ 
+:																						;|
	RTS																					;/

GFXRt:
	LDA.b $D1																			;\ Stick the sprite to Mario
	STA.w !sprite_x_low,x																;|
	LDA.b $D2																			;|
	STA.w !sprite_x_high,x															;|
	LDA.b $D3																			;|
	STA.w !sprite_y_low,x																;|
	LDA.b $D4																			;|
	STA.w !sprite_y_high,x															;/
	%GetDrawInfo()																		; Call the Get Draw info routine to get its on screen position, OAM index, and to set its off screen flags.
	PHX																					; Preserve the current sprite slot index.
	LDX.b $76																			;\ Use the facing direction to store the flip direction
	LDA.w Flip,x																		;|
	STA.b $04																			;/
	TXA																					;\ Double the player facing direction for the X disp index
	ASL																					;|
	INC																					;|
	STA.b $02																			;/
	LDA.b $19																			;\ If Mario is small, store 01 into the Y disp index
	BEQ.b +																			;|
	LDA.b #$02																			;| Otherwise, store 03
+:																						;|
	INC																					;|
	STA.b $06																			;/
	LDX.b #$01																			; Begin drawing up to 2 tiles by setting the X index
-:																						;
	PHX																					; Preserve the loop index
	LDA.w Tiles,x																		;\ Store the tile number to the OAM buffer
	STA.w $0302|!Base2,y																;/ 
	LDA.b $04																			;\ Load the sprite's facing directio into A
	EOR.w Prop,x																		;| Set the palette bits
	ORA.b $64																			;| Set the layer priority bits
	STA.w $0303|!Base2,y																;/ Store the property byte into the OAM buffer
	PHX																					; Preserve the current table index 
	LDX.b $02																			;
	LDA.b $00																			;\ Store the on screen X position of the tile into the OAM buffer
	CLC																					;|
	ADC.w XDisp,x																		;|
	STA.w $0300|!Base2,y																;/
	LDX.b $06																			;
	LDA.b $01																			;\ Store the on screen Y position of the tile into the OAM buffer
	CLC																					;|
	ADC.w YDisp,x																		;|
	STA.w $0301|!Base2,y																;/
	PLX																					; Restore the current table index
	PHY																					; Preserve the OAM index
	TYA																					;\ Divide the OAM index by 4, since the next OAM table is smaller than the other one.
	LSR																					;|
	LSR																					;|
	TAY																					;/
	LDA.w TileSize,x																	;\ Store the tile size to the second OAM buffer
	STA.w $0460|!Base2,y																;/
	PLY																					; Restore the OAM index
	INY																					;\ Increment the OAM index for the next tile
	INY																					;|
	INY																					;|
	INY																					;/
++:																						;
	PLX																					; Restore the loop index
	DEC.b $02																			;\ Decrement the X/Y disp index
	DEC.b $06																			;/
	DEX																					;\ Have all the sprite been drawn? If not, loop
	BPL.b -																			;/
	PLX																					; Otherwise, restore the current sprite slot index
	LDY.b #$FF																			;\ Call the Finish OAM write routine in order to set the high X bit of the tiles.
	LDA.b #$01																			;| Set the number of tiles drawn to 2.
	JSL.l $01B7B3|!bank																;/
	RTS																					; Return

XDisp:
	db $F8,$08
	db $08,$F8

YDisp:
	db $08,$08
	db $F8,$F8

Tiles:
	db $42,$40

Prop:
	db $08,$08

Flip:
	db $40,$00

TileSize:
	db $02,$02


