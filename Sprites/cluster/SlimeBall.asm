; YI Slime Ball by Yoshifanatic
; This is the slime ball sprite that Salvo spawns when taking damage.
; Before inserting, set !Define_SMW_ClusterSprXX_SlimeBall in SalvoTheSlimeDefines.asm to the sprite ID you intend on inserting this sprite as. 
; In addition, put SalvoTheSlimeDefines.asm into the PIXI folder and, if using the Yoshi Player Patch, SpriteDefines.asm alongside it.
;
; Notes:
;- The original sprite animated when colliding with the ground, but I opted not to do that since SMW cluster sprites don't have level tile collision (the 1up doesn't count, since that use a hardcoded Y position as the "floor").

incsrc "../SalvoTheSlimeDefines.asm"

print "MAIN ",pc
	PHB																					;\ Bank wrapper that sets up the DBR to the current bank for easier access to ROM/RAM in tables in this sprite's code.
	PHK																					;|
	PLB																					;|
	TYX																					;| Also, transfer Y into X, since having the sprite slot in X allows for calling SMW routines that expect it to be in X.
	JSR.w Sub																			;|
	TXY																					;|
	PLB																					;/
	RTL																					; Return

Sub:
	JSR.w GFXRt																		; Draw this sprite's graphics
	LDA.b !RAM_SMW_Flag_SpritesLocked												;\ If the screen is not frozen, process the rest of the sprite code.
	BNE.b +																			;/
	DEC.w !RAM_SMW_ClusterSprXX_SlimeBall_DespawnTimer,x							;\ Decrement the despawn timer.
	BNE.b ++																			;| If it's 00, despawn the sprite. 
	STZ.w !RAM_SMW_ClusterSpr_SpriteID,x											;/
+:																						;
	RTS																					; Return
																						;
++:																						;
	LDA.w !RAM_SMW_ClusterSprXX_SlimeBall_YSpeed,x									;\ Increase the sprite's Y speed up to 2 pixels a frame downwards.					
	BMI.b +																			;|
	CMP.b #$20																			;|
	BCS.b ++																			;|
+:																						;|
	LDA.b #$02																			;| Accelerate the sprite by 2 subpixels per frame.
	CLC																					;|
	ADC.w !RAM_SMW_ClusterSprXX_SlimeBall_YSpeed,x									;|
	STA.w !RAM_SMW_ClusterSprXX_SlimeBall_YSpeed,x									;/
++:																						;\ Update the sprite's Y position
	PHK																					;|
	PEA.w .Return1-$01																;|
	PEA.w ($02B889|!bank)-$01															;|
	JML.l $02FFA3|!bank																;| 
.Return1:																				;/
	PHK																					;\ Update the sprite's X position
	PEA.w .Return2-$01																;|
	PEA.w ($02B889|!bank)-$01															;|
	JML.l $02FF98|!bank																;|
.Return2:																				;/
	DEC.w !RAM_SMW_ClusterSprXX_SlimeBall_AnimationFrameCounter,x				;\ Wait a bit before displaying the next animation frame.
	BNE.b +																			;/
	LDA.b #$07																			;\ Make the next animation frame take 7 frames to display.
	STA.w !RAM_SMW_ClusterSprXX_SlimeBall_AnimationFrameCounter,x				;/
	LDA.w !RAM_SMW_ClusterSprXX_SlimeBall_AnimationFrame,x						;\ Increment the animation frame until it shows the last one.
	CMP.b #$03																			;|
	BCS.b +																			;|
	INC.w !RAM_SMW_ClusterSprXX_SlimeBall_AnimationFrame,x						;/
+:																						;
	RTS																					; Return

-:
	STZ.w !RAM_SMW_ClusterSpr_SpriteID,x											;\ Despawn the sprite, then return.
	RTS																					;/

GFXRt:
	LDA.l $02FF50|!bank,x																;\ Load a cluster sprite OAM indexes into Y
	TAY																					;/
	LDA.w !RAM_SMW_ClusterSpr_XPosHi,x												;\ Get the on screen X position of the sprite.
	XBA																					;|
	LDA.w !RAM_SMW_ClusterSpr_XPosLo,x												;|
	REP.b #$20																			;|
	SEC																					;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo										;|
	CMP.w #$0100																		;| If the tile is off screen, despawn it.
	SEP.b #$20																			;|
	BCS.b -																			;/
	STA.w $0200|!addr,y																; Otherwise, store the on screen X position of the tile to the OAM buffer.
	LDA.w !RAM_SMW_ClusterSpr_YPosHi,x												;\ Get the on screen Y position of the sprite.
	XBA																					;|
	LDA.w !RAM_SMW_ClusterSpr_YPosLo,x												;|
	REP.b #$20																			;|
	SEC																					;|
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo										;|
	CMP.w #$00F0																		;| If the tile is off screen, despawn it
	SEP.b #$20																			;|
	BCS.b -																			;/
	STA.w $0201|!addr,y																; Otherwise, store the on screen Y position of the tile to the OAM buffer.
	PHX																					; Preserve the current sprite slot index
	LDA.w !RAM_SMW_ClusterSprXX_SlimeBall_AnimationFrame,x						;\ Load the current animation frame into X to use as an index
	TAX																					;/
	LDA.w .Tiles,x																		;\ Store the tile number to the OAM buffer
	STA.w $0202|!addr,y																;/
	LDA.b #$0F																			;\ Store the property byte into the OAM buffer
	ORA.b !RAM_SMW_Sprites_TilePriority												;|
	STA.w $0203|!addr,y																;/
	TYA																					;\ Divide the OAM index by 4, since the next OAM table is smaller than the other one.
	LSR																					;|
	LSR																					;|
	TAY																					;/
	LDA.w .TileSize,x																	;\ Store the tile size to the second OAM buffer
	STA.w $0420|!addr,y																;/
	PLX																					; Restore the current sprite slot index
	RTS																					; Return

.Tiles:
	db $00,$12,$0C,$1C

.TileSize:
	db $02,$00,$00,$00
