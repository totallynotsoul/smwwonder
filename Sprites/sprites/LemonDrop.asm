; YI Lemon Drop by Yoshifanatic
; This is the yellow slime enemy that Salvo spawns during its fight.
; Before inserting, set !Define_SMW_NorSprXXX_LemonDrop in SalvoTheSlimeDefines.asm to the sprite ID you intend on inserting this sprite as. 
; In addition, put SalvoTheSlimeDefines.asm into the PIXI folder and, if using the Yoshi Player Patch, SpriteDefines.asm alongside it.

incsrc "../SalvoTheSlimeDefines.asm"

print "INIT ",pc
	LDY.b #$06																			;\ If the extra bit is set, spawn it in as a variant that will summon Salvo.
	LDA.l !RAM_SMW_PIXI_NorSpr_SprExtraBits,x										;| Otherwise, spawn this sprite act as a generator for lemon drops
	AND.b #$04																			;|
	BNE.b +																			;|
	JSR.w BackupXYPosition															;| Backup the X/Y position of the sprite.
if !Define_SMW_NorSprXXX_SalvoTheSlime_DebugDisplay == 1								;|
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x												;| Make this sprite use a different palette row if it's set to be a spawner.
	AND.b #$F1																			;| This is to help distinguish this spawner from the lemon drops it spawns when debugging is on.
	ORA.b #$0C																			;|
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x												;|
endif																					;|
	LDA.b #$30																			;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer,x						;|
	LDY.b #$0E																			;|
+:																						;|
	TYA																					;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								;/
	RTL																					; Return

MainStates:
	dw State00_HangFromCeiling
	dw State01_FallFromCeiling
	dw State02_MovingAround
	dw State03_SteppedOn
	dw State04_PopIntoGoo
	dw State05_RecoverAfterBeingSpatOut
	dw State06_CutsceneHangFromCeiling
	dw State07_CutsceneFallFromCeiling
	dw State08_CutsceneWaitForKamekMagic
	dw State09_CutsceneJumpTowardCeiling
	dw State0A_CutsceneWaitBeforeSummoningSalvo
	dw State0B_SpatOut
	dw State0C_KnockedBack
	dw State0D_LemonDropSpawnerCheckForCeiling
	dw State0E_LemonDropSpawnerCheckTileBelowCeiling

print "MAIN ",pc
	PHB																					;\ Bank wrapper that sets up the DBR to the current bank for easier access to ROM/RAM in tables in this sprite's code.
	PHK																					;|
	PLB																					;|
	JSR.w Sub																			;|
	PLB																					;|
	RTL																					;/

Sub:
	JSR.w GFXRt																		; Draw this sprite's graphics
	LDA.b !RAM_SMW_Flag_SpritesLocked												;\ If the screen is not frozen, process the rest of the sprite code.
	BEQ.b .CodeCanRun																	;|
.Return:																				;| Otherwise, return.
	RTS																					;/

.CodeCanRun:
	LDA.b #$00																			;\ Check to see if the sprite is far offscreen, and despawn it if so.
	%SubOffScreen()																		;/
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x											;\ If the sprite is currently not alive, return.
	CMP.b #!Define_SMW_NorSprStatus08_Normal											;|
	BCC.b .Return																		;/
	BEQ.b +																			; If it is alive, branch.
	SEC																					;\ Otherwise, if the sprite is not in the stunned/kicked state (ie. If it was spat out by Yoshi), return
	SBC.b #!Define_SMW_NorSprStatus09_Stunned											;|
	CMP.b #(!Define_SMW_NorSprStatus0A_Kicked-!Define_SMW_NorSprStatus09_Stunned)+$01	;|
	BCS.b .Return																		;/
	LDA.b #$0B																			;\ Otherwise, set the sprite in the "spat out" state.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								;/ Note that this sprite is set to act like normal sprite 80 (key), because it's stunned/kicked state doesn't cause issues before this code executes.
	LDA.b #!Define_SMW_NorSprStatus08_Normal											;\ Set the sprite status to normal so it's no longer considered in the stunned/kicked state.
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x											;/
	JSR.w DisablePlayerContact														; Prevent the player and Yoshi from interacting with the sprite.
	RTS																					; Return

+:
	LDY.b #$01																			;\ Make the sprite invulnerable to other sprites based on the state of !1564.
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x								;| This code is technically meant for the YPP patch to prevent Yoshi's eggs from immediately destroying the lemon drops spawned when Salvo takes damage.
	BEQ.b +																			;| But, it might be useful in other situations.
	DEY																					;|
+:																						;|
	LDA.w !RAM_SMW_NorSpr_PropertyBits167A,x										;|
	AND.b #!Define_SMW_NorSpr_167AProp_InvincibleToMostThings^$FF						;|
	ORA.w .InvulnerableFlagTable,y													;|
	STA.w !RAM_SMW_NorSpr_PropertyBits167A,x										;/
	LDA.w !RAM_SMW_NorSpr_YSpeed,x													;\ Increase the sprite's Y speed up to 4 pixels a frame downwards.
	CMP.b #$40																			;|
	BCS.b +																			;|
	;CLC																				;|
	ADC.w !RAM_SMW_NorSprXXX_LemonDrop_YAcceleration,x							;|
	STA.w !RAM_SMW_NorSpr_YSpeed,x													;/
+:
	TXY																					; Preserve X by putting it into Y
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								;\ Get the sprite's state, then jump to the routine corresponding to that state.
	ASL																					;|
	TAX																					;|
	JSR.w (MainStates,x)																;/
	JSR.w CheckForPlayerCollision													; Check for Mario collision
	JSR.w CheckForSpriteCollision													; Normal sprite to Normal sprite collision
	RTS																					; Return

.InvulnerableFlagTable:
	db !Define_SMW_NorSpr_167AProp_InvincibleToMostThings,$00

CheckForPlayerCollision:
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_SpatOutBounceCounter,x					;\ If the sprite is currently bouncing, return.
	BNE.b .Return																		;/
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								;\ If the sprite is in state 03 (Stepped On) or 04 (pop into goo), return
	SEC																					;|
	SBC.b #$03																			;|
	CMP.b #$02																			;|
	BCC.b .Return																		;/
	JSL.l $01A7DC|!bank																;\ Check for Mario to normal sprite collision. If no collision detected, return
	BCC.b .Return																		;/
	%SubVertPos()																		; Otherwise, get Mario's position relative to the sprite's
	LDY.b #$E0																			;\ If Mario's riding Yoshi, use a different offset for the upcoming check.
	LDA.w !RAM_SMW_Player_RidingYoshiFlag											;|
	BEQ.b +																			;|
	LDY.b #$D0																			;/
+:																						;
	CPY.b !RAM_SMW_Misc_ScratchRAM0F												;\ If Mario is above the sprite, branch.
	BCC.b .MarioWins																	;/
.SpriteWins:																			;
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_DisableMarioContactTimer,x				;\ Otherwise, is the sprite currently intangible?
	ORA.w !RAM_SMW_NorSpr_OnYoshisTongue,x											;| If so, return.
	BNE.b .Return																		;/
	LDA.w !RAM_SMW_Timer_StarPower													;\ Does Mario have star power? If not, branch.
	BEQ.b .HurtMario																	;/
	PHB																					;\ Otherwise, star kill the sprite.
	PEA.w ($01A847|!bank)>>8															;|
	PLB																					;|
	PLB																					;|
	PHK																					;|
	PEA.w .Return1-$01																;|
	PEA.w ($0180CA-$01)|!bank															;|
	JML.l $01A847|!bank																;|
.Return1:																				;|
	PLB																					;/
	RTS

.HurtMario:
	JSL.l $00F5B7|!bank																; Hurt Mario
.Return:																				;
	RTS																					; Return

.MarioWins:
	LDA.b !RAM_SMW_Player_YSpeed														;\ Is Mario moving upwards? If so, return.
	BMI.b .Return																		;/
	LDA.b !RAM_SMW_Player_InAirFlag													;\ Is Mario in the air? If not, check if the sprite should hurt Mario
	BEQ.b .SpriteWins																	;/
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x									;\ Is the sprite on the ground? If not, return
	AND.b #$04																			;|
	BEQ.b .Return																		;/
if !Define_SMW_NorSprXXX_SalvoTheSlime_YoshiPlayerPatchInstalled == 1					;\
	STZ.w !FREERAM7																	;| Cancel Yoshi's ground pound and flutter jump (if YPP is installed)
	STZ.w !FREERAM8																	;|
	STZ.w !FREERAM31																	;|
	STZ.w !FREERAM33																	;|
	STZ.w !FREERAM34																	;|
endif																					;/
	STZ.w !RAM_SMW_Player_SpinJumpFlag												; Cancel Mario's spin jump
	JSR.w StunPlayer																	; Stun Mario so he can't move
	STZ.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						; Reset the sprite's animation index so it will display the first frame of the squish animation.
	STZ.w !RAM_SMW_NorSpr_XSpeed,x													; Reset the sprite's X speed
	LDA.b #$04																			;\ Set the timer for the first frame of the squish animation.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;/
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							; Set the animation frame to the first squish frame.
	LDA.b #$03																			;\ Set the sprite to be in the squished state
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								;/
	RTS																					; Return

CheckForSpriteCollision:
	JSL.l $03B69F|!bank																; Get the hitbox of this sprite
	LDY.b #!Define_SMW_MaxNormalSpriteSlot												; Store the number of normal sprite slots into X.
-:
	PHX																					; Preserve the current sprite's index.
	CPY.w !RAM_SMW_NorSpr_CurrentSlotID												;\ If the slot being check is the current sprite, branch.
	BEQ.b .NoContact																	;/
	LDA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x								;\ If the current and checked sprites are invulnerable to sprite contact, branch.
	ORA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,y								;|
	BNE.b .NoContact																	;/
	TYX																					; Put the checked sprite slot's index into X
	JSL.l $03B6E5|!bank																; Get the hitbox of the other sprite
	JSL.l $03B72B|!bank																;\ Check for contact. If the sprite's aren't touching, check the next sprite
	BCC.b .NoContact																	;/
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y											;\ Otherwise, if the sprite is not in the normal state, branch.
	CMP.b #!Define_SMW_NorSprStatus08_Normal											;|
	BNE.b ++																			;/
	LDA.l !RAM_SMW_PIXI_NorSpr_SprExtraBits,x										;\ If the sprite is not custom, branch.
	AND.b #$08																			;|
	BEQ.b .NoContact																	;/
	LDA.l !RAM_SMW_PIXI_NorSpr_CustomSpriteID,x									;\ If the sprite is not the lemon drop, branch.
	CMP.b #!Define_SMW_NorSprXXX_LemonDrop												;|
	BNE.b .NoContact																	;/
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID												; Get the current sprite's slot index
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								;\ If the current sprite's state is 04 (explode into goo), branch
	CMP.b #$04																			;|
	BEQ.b .KnockbackOtherLemonDrops													;/
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,y								;\ Otherwise, If the checked sprite has not been spat out by Yoshi, branch.
	CMP.b #$0B																			;|
	BNE.b .NoContact																	;/
	JSR.w .KillSprite																	;\ Kill both the current and checked sprite
	TYX																					;|
	JSR.w .KillSprite																	;/
	PLX																					;\ Exit the loop early, because the current sprite is dead now.
	RTS																					;/
	
.KnockbackOtherLemonDrops:
	LDA.b #$0C																			;\ Otherwise, set the nearby lemon drop to be in the spat out state to knock them back.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,y								;/
	LDA.w !RAM_SMW_NorSpr_XPosLo,x													;\ Get the relative position of the current sprite and the sprite being checked, and set X based on the direction.
	LDX.b #$00																			;|
	SEC																					;|
	SBC.w !RAM_SMW_NorSpr_XPosLo,y													;|
	BPL.b +																			;|
	INX																					;/
+:																						;
	LDA.w .KnockbackXSpeed,x															;\ Set the x speed of the checked sprite to move it away from the current sprite.
	STA.w !RAM_SMW_NorSpr_XSpeed,y													;/
	LDA.b #$D0																			;\ Set the y speed of the checked sprite to bounce it upward.
	STA.w !RAM_SMW_NorSpr_YSpeed,y													;/
	BRA.b .NextSlot																	; Check the next sprite slot
																						;
++:																						;
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked											;\ If the checked sprite is not in the kicked state, branch.
	BNE.b .NoContact																	;/
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID												; Get the current sprite's slot index
	JSR.w .KillSprite																	; Kill the current sprite
.NextSlot:																				;
.NoContact:																			;
	PLX																					; Otherwise, restore the sprite index.
	DEY																					;\ Decrement the sprite slot index.
	BMI.b +																			;| If not every slot has been checked, check the next slot.
	JMP.w -																			;/

+:																						;
	RTS																					; Otherwise, return.

.KillSprite:
	PHB																					;\ Otherwise, kill the sprite.
	PEA.w ($01A64A|!bank)>>8															;|
	PLB																					;|
	PLB																					;|
	PHK																					;|
	PEA.w ..Return-$01																;|
	PEA.w ($0180CA-$01)|!bank															;|
	JML.l $01A64A|!bank																;|
..Return:																				;|
	PLB																					;/
	RTS																					; Return

.KnockbackXSpeed:
	db $E0,$20

StunPlayer:
	STZ.b !RAM_SMW_IO_ControllerHold1												;\ Clear all button inputs
	STZ.b !RAM_SMW_IO_ControllerPress1												;|
	STZ.b !RAM_SMW_IO_ControllerHold2												;|
	STZ.b !RAM_SMW_IO_ControllerPress2												;/
	LDA.b #$02																			;\ Prevent Mario from doing anything while the sprite is being stepped on.
	STA.w !RAM_SMW_Timer_StunPlayer													;/
	STZ.b !RAM_SMW_Player_XSpeed														;\ Kill Mario's momentum
	STZ.b !RAM_SMW_Player_YSpeed														;/
DisablePlayerContact:																	;
	LDA.b #$02																			;\ Disable contact with the sprite so Yoshi doesn't get scared when this sprite pops.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_DisableMarioContactTimer,x				;|
	STA.w !RAM_SMW_NorSpr_OnYoshisTongue,x											;/
	RTS																					; Return

State06_CutsceneHangFromCeiling:
	LDA.b #$01																			;\ Prevent the player from moving.
	STA.w !RAM_SMW_Player_FreezePlayerFlag											;/
State00_HangFromCeiling:																;
	TYX																					; Restore the current sprite slot index.
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;\ Wait a bit before displaying the next animation frame.
	BNE.b .Return																		;/
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;\ Increment the animation index
	LDY.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;| If the animation hasn't finished yet, display the next frame.
	CPY.b #$05																			;|
	BNE.b .DisplayNextFrame															;/
	LDA.b #$04																			;\ Otherwise, make the sprite subject to gravity.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_YAcceleration,x							;/
	STZ.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;\ Reset the animation index and timer for the next state
	STZ.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;/
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								; Set the sprite state to "fall from ceiling".
	RTS																					; Return

.DisplayNextFrame:
	LDA.w .AnimationFrame-$01,y														;\ Otherwise, display the next animation frame
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;|
	LDA.w .AnimationTimer-$01,y														;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;|
.Return:																				;/
	RTS																					; Return

.AnimationFrame:
	db $08,$09,$00,$01

.AnimationTimer:
	db $10,$06,$05,$04

State01_FallFromCeiling:
State07_CutsceneFallFromCeiling:
	TYX																					; Restore the current sprite slot index.
	JSL.l $01802A|!bank																; Update sprite position (with gravity)
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x									;\ If the sprite is not on the ground yet, return.
	AND.b #$04																			;|
	BEQ.b .Return																		;/
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;\ Wait a bit before displaying the next animation frame.
	BNE.b .Return																		;/
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						; Increment the animation index
	LDY.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;\ Display the next animation frame
	LDA.w .AnimationFrame-$01,y														;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;|
	LDA.w .AnimationTimer-$01,y														;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;/
	CPY.b #$02																			;\ If the 3rd frame of the landing animation is not displaying, branch
	BNE.b +																			;|
	LDA.b #!Define_SMW_Sound1DF9_Swim													;| Otherwise, play the swim sound.
	STA.w !RAM_SMW_IO_SoundCh1														;/
	RTS																					; Return

+:
	CPY.b #$09																			;\ If the animation hasn't finished yet, return
	BMI.b .Return																		;/
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer,x						; Otherwise, store the animation frame timer into the phase timer to make the sprite wait.
	%SubHorzPos()																		;\ Make the sprite face towards Mario
	TYA																					;|
	STA.w !RAM_SMW_NorSpr_FacingDirection,x										;/
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								; Set the sprite to either be in state 02 (moving around) or 08 (wait for Kamek).
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								;\ If the state is the latter one, return.
	CMP.b #$08																			;|
	BNE.b .Return																		;/
	LDA.b #$07																			;\ Otherwise, set the animation frame index for the moving around state.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;/
.Return:																				;
	RTS																					; Return

.AnimationFrame:
	db $01,$04,$05,$06,$01,$00,$02,$00,$01

.AnimationTimer:
	db $02,$02,$02,$02,$02,$02,$04,$02,$30

State02_MovingAround:
	TYX																					; Restore the current sprite slot index.
	JSL.l $01802A|!bank																; Update sprite position (with gravity)
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x									;\ If the sprite is touching a wall, flip it's facing direction.
	AND.b #$03																			;|
	BEQ.b .NotTouchingWall															;|
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x										;|
	EOR.b #$01																			;|
	STA.w !RAM_SMW_NorSpr_FacingDirection,x										;/
.NotTouchingWall:																		;
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer,x						;\ If the sprite is waiting, return.
	BNE.b .Return																		;/
	STZ.w !RAM_SMW_NorSprXXX_LemonDrop_SpatOutBounceCounter,x					; Clear the bounce counter
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x									;\ If the sprite is not on the ground, return.
	AND.b #$04																			;|
	BEQ.b .Return																		;/
	LDY.w !RAM_SMW_NorSpr_FacingDirection,x										;\ Otherwise, make the sprite move in the direction it's facing.
	LDA.w .XSpeed,y																	;|
	STA.w !RAM_SMW_NorSpr_XSpeed,x													;/
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;\ Wait a bit before displaying the next animation frame
	BNE.b .Return																		;/
	LDA.b #$04																			;\ Otherwise, display the next animation frame
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;|
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;|
	INC																					;|
	AND.b #$03																			;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;/
.Return:																				;
	RTS																					; Return

.XSpeed:
	db $04,$FC

State03_SteppedOn:
	TYX																					; Restore the current sprite slot index.
	JSR.w StunPlayer																	; Keep Mario stunned
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;\ Wait a bit before displaying the next animation frame
	BNE.b .AdjustPlayerYPosition														;/
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;\ Increment the animation index twice
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;|
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;| If the animation hasn't finished yet, display the next frame.
	CMP.b #$06																			;|
	BMI.b .DisplayNextFrame															;/
	LDA.b #$03																			;\ Otherwise, make the sprite wait a few frames in its next state
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer,x						;/
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								; Set the sprite into the state where it pops
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,x										;\ Change the sprite hitbox to a larger one that will be used to affect nearby lemon drops.
	AND.b #$C0																			;|
	ORA.b #$1F																			;|
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x										;/
	RTS																					; Return

.DisplayNextFrame:
	LDA.b #$04																			;\ Display the next animation frame
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;|
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;/
.AdjustPlayerYPosition:																;
	LDA.b !RAM_SMW_Player_BlockedFlags												;\ If Mario is on the ground, return
	AND.b #$04																			;|
	BNE.b .Return																		;/
	LDY.b #$00																			;\ If Mario is riding Yoshi, use a different value for an upcoming equation.
	LDA.w !RAM_SMW_Player_RidingYoshiFlag											;|
	BEQ.b +																			;|
	LDY.b #$10																			;|
+:																						;|
	STY.b !RAM_SMW_Misc_ScratchRAM0E												;|
	STZ.b !RAM_SMW_Misc_ScratchRAM0F												;/
	LDY.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;\ Set Mario to be above the sprite, based on its current animation frame.
	LDA.w !RAM_SMW_NorSpr_YPosHi,x													;|
	XBA																					;|
	LDA.w !RAM_SMW_NorSpr_YPosLo,x													;|
	REP.b #$20																			;|
	SEC																					;|
	SBC.w .YOffset,y																	;|
	SBC.b !RAM_SMW_Misc_ScratchRAM0E												;|
	STA.b !RAM_SMW_Player_YPosLo														;|
	SEP.b #$20																			;/
	STZ.b !RAM_SMW_Player_YSpeed														; Reset Mario's Y speed.
.Return:
	RTS

.YOffset:
	dw $001A,$0018,$0014

State04_PopIntoGoo:
	TYX																					; Restore the current sprite slot index.
	JSR.w StunPlayer																	; Keep Mario stunned
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer,x						;\ If the sprite has yet to pop, return
	BNE.b .Return																		;/
	LDA.b #!Define_SMW_Sound1DF9_SpinJumpKill											;\ Otherwise, play the spin jump kill sound
	STA.w !RAM_SMW_IO_SoundCh1														;/
	STZ.b !RAM_SMW_Misc_ScratchRAM00												;\ Spawn a smoke sprite at the sprite's position.
	STZ.b !RAM_SMW_Misc_ScratchRAM01												;|
	LDA.b #$1B																			;|
	STA.b !RAM_SMW_Misc_ScratchRAM02												;|
	LDA.b #$01																			;|
	%SpawnSmoke()																		;|
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x											;/
.Return:																				;
	RTS																					; Return

State05_RecoverAfterBeingSpatOut:
	TYX																					; Restore the current sprite slot index.
	STZ.w !RAM_SMW_NorSpr_OnYoshisTongue,x											; Make the sprite able to interact with Yoshi again.
	STZ.w !RAM_SMW_NorSprXXX_LemonDrop_SpatOutBounceCounter,x					; Clear the bounce counter
	STZ.w !RAM_SMW_NorSpr_YSpeed,x													; Clear its Y speed to fix a weird bug where it can sometimes phase through the floor.
	JSL.l $01802A|!bank																; Update sprite position (with gravity)
	LDA.b #$01																			;\ Set the animation frame to one of the moving ones.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;/
	INC																					;\ Set the sprite state to 02 (moving around)
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								;/
	LDA.b #$30																			;\ Make the sprite wait a bit before moving
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer,x						;/
	%SubHorzPos()																		;\ Make the sprite face Mario
	TYA																					;|
	STA.w !RAM_SMW_NorSpr_FacingDirection,x										;/
	RTS																					; Return

State08_CutsceneWaitForKamekMagic:
	TYX																					; Restore the current sprite slot index.
if !Define_SMW_NorSprXXX_SalvoTheSlime_LemonDropWaitsForMagic == 1						;\ If Kamek isn't done spreading magic, return
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_KamekMagicDoneFlag,x						;|
	BPL.b .Return																		;|
endif																					;/
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;\ Wait a bit before displaying the next animation frame
	BNE.b .Return																		;/
	DEC.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;\ Decrement the animation index
	BPL.b .DisplayNextFrame															;/ If the animation hasn't finished yet, display the next frame.
	LDA.b #$02																			;\ Otherwise, set the animation frame to one of the moving ones.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;/
	LDA.b #$A0																			;\ Make the sprite jump with a fixed Y speed
	STA.w !RAM_SMW_NorSpr_YSpeed,x													;|
	STZ.w !RAM_SMW_NorSprXXX_LemonDrop_YAcceleration,x							;/
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								; Make the sprite enter the "jump towards ceiling" state
	LDA.b #!Define_SMW_Sound1DFC_Springboard											;\ Play the springboard sound
	STA.w !RAM_SMW_IO_SoundCh3														;/
	RTS																					; Return

.DisplayNextFrame:
	LDY.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;\ Otherwise, display the next animation frame
	LDA.w .AnimationFrame,y															;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;|
	LDA.b #$02																			;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;/
.Return:																				;
	RTS																					; Return

.AnimationFrame:
	db $04,$05,$06,$05,$04,$00,$02

State09_CutsceneJumpTowardCeiling:
	TYX																					; Restore the current sprite slot index.
	JSL.l $01801A|!bank																; Update sprite position (without gravity)
	JSL.l $019138|!bank																; Check for block collision.
	LDA.w !RAM_SMW_NorSpr_YSpeed,x													;\
	BEQ.b .OnCeiling																	;/
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x									;\ If the sprite hasn't touched the ceiling yet, return
	AND.b #$08																			;|
	BEQ.b .Return																		;/
	LDA.w !RAM_SMW_NorSpr_YPosLo,x													;\ Snap the sprite to be on the ceiling
	CLC																					;|
	ADC.b #$08																			;|
	AND.b #$F0																			;|
	STA.w !RAM_SMW_NorSpr_YPosLo,x													;/
	STZ.w !RAM_SMW_NorSpr_YSpeed,x													; Clear the sprite's Y speed.
	RTS																					; Return

.OnCeiling:
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;\ Otherwise, wait a bit before displaying the next animation frame
	BNE.b .Return																		;/
	DEC.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;\ Decrement the animation index
	BPL.b .DisplayNextFrame															;/ If the animation hasn't finished yet, display the next frame.
	LDA.b #$20																			;\ Otherwise, make the sprite wait a bit before summoning Salvo
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer,x						;/
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								; Then make the sprite wait for Salvo.
	RTS																					; Return

.DisplayNextFrame:
	LDY.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex,x						;\ Otherwise, display the next animation frame
	LDA.w .AnimationFrame,y															;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;|
	LDA.w .AnimationTimer,y															;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,x						;/
.Return:																				;
	RTS																					; Return

.AnimationFrame:
	db $07,$08

.AnimationTimer:
	db $08,$10

State0A_CutsceneWaitBeforeSummoningSalvo:
	TYX																					; Restore the current sprite slot index.
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer,x						;\ Wait a bit before summoning Salvo
	BNE.b .Return																		;/
	STZ.w !RAM_SMW_NorSpr_CurrentStatus,x											; Otherwise, despawn this sprite
	LDA.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState05_OozeFromCeiling				;\ Set Salvo to ooze from the ceiling
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState							;/
	LDA.b #!Define_SMW_NorSprXXX_SalvoTheSlime_BossMusic								;\ Make the boss music play.
	STA.w !RAM_SMW_IO_MusicCh1														;/
.Return:																				;
	RTS																					; Return

State0B_SpatOut:
State0C_KnockedBack:
	TYX																					; Restore the current sprite slot index.
	JSL.l $01802A|!bank																; Update sprite position (with gravity)
	LDA.b #$04																			;\ Make the sprite subject to gravity.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_YAcceleration,x							;/
	JSR.w DisablePlayerContact														; Prevent the player and Yoshi from interacting with the sprite.
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x									;\ If the sprite is not touching a wall, branch
	AND.b #$03																			;|
	BEQ.b .NotTouchingWall															;/
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x										;\ Otherwise, flip the sprite's direction, then invert and divide it's X speed by 2.
	EOR.b #$01																			;|
	STA.w !RAM_SMW_NorSpr_FacingDirection,x										;|
	LDA.w !RAM_SMW_NorSpr_XSpeed,x													;|
	CMP.b #$80																			;|
	ROR																					;|
	EOR.b #$FF																			;|
	INC																					;|
	STA.w !RAM_SMW_NorSpr_XSpeed,x													;/
.NotTouchingWall:																		;
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x									;\ If the sprite is touching the ceiling, set its Y speed to 00.
	AND.b #$08																			;|
	BEQ.b .NotTouchingCeiling														;|
	STZ.w !RAM_SMW_NorSpr_YSpeed,x													;/
.NotTouchingCeiling:																	;
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x									;\ If the sprite is not on the ground, return
	AND.b #$04																			;|
	BEQ.b .NotTouchingFloor															;/
	LDA.b #!Define_SMW_Sound1DF9_HitHead												;\ Otherwise, play the hit head sound
	STA.w !RAM_SMW_IO_SoundCh1														;/
	LDY.w !RAM_SMW_NorSprXXX_LemonDrop_SpatOutBounceCounter,x					;\ Load, then increment the bounce counter
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_SpatOutBounceCounter,x					;/
	LDA.w .YSpeed,y																	;\ Use the bounce counter to set the sprite's Y speed
	STA.w !RAM_SMW_NorSpr_YSpeed,x													;/
	CPY.b #$04																			;\ Has the sprite bounced 3 times? If not, return.
	BCC.b .DontRecoverYet																;/
	LDA.b #$05																			;\ Otherwise, set the sprite to be in the recovery state
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								;/
	STZ.w !RAM_SMW_NorSpr_XSpeed,x													; Set the sprite's X speed to 0.
.DontRecoverYet:
.NotTouchingFloor:
	RTS																					; Return

.YSpeed:
	db $D8,$DC,$E0,$F0

State0D_LemonDropSpawnerCheckForCeiling:
	TYX																					; Restore the current sprite slot index.
	JSR.w DisablePlayerContact														; Prevent the player and Yoshi from interacting with the sprite.
	JSR.w RestoreXYPosition															; Reset the sprite's position, so it can despawn correctly.
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer,x						;\ Wait before spawning a new lemon drop
	BNE.b ++																			;/
	JSL.l $01ACF9|!bank																; Get another random number
	CMP.b #$D1																			;\ If that number is greater than D1 (ie. At or below the bottom tile of the screen), return.
	BCS.b ++																			;/
	;CLC																				;\ Move the sprite to be at a random block's Y position on screen.
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo										;|
	AND.b #$F0																			;|
	STA.w !RAM_SMW_NorSpr_YPosLo,x													;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosHi										;|
	ADC.b #$00																			;|
	STA.w !RAM_SMW_NorSpr_YPosHi,x													;/
	JSL.l $01ACF9|!bank																; Get yet another random number
	CLC																					;\ Move the sprite to be at a random block's X position on screen.
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo										;|
	AND.b #$F0																			;|
	STA.w !RAM_SMW_NorSpr_XPosLo,x													;|
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosHi										;|
	ADC.b #$00																			;|
	STA.w !RAM_SMW_NorSpr_XPosHi,x													;/
	JSL.l $019138|!bank																; Check for block collision
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x									;\ If the sprite is not inside a wall, return
	AND.b #$0F																			;| This should rule out every tile on map16 page 00.
	BEQ.b ++																			;/
	LDY.b #$0E																			; Otherwise, prepare for an upcoming loop
-:																						;
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo							;\ Is the tile one of several whitelisted ceiling tiles?
	CMP.w .CeilingTiles,y																;| If so, branch.
	BEQ.b +																			;/
	DEY																					; Otherwise, have all the whitelisted tiles been checked? If not, loop.
	BPL.b -																			;
	RTS																					; Return

+:
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting										;\ Otherwise, if the tile set is the castle, branch.
	CMP.b #$01																			;|
	BEQ.b .NotSolidDirt																;/
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo							;\ Is the tile ID #$0165? If so branch.
	CMP.b #$65																			;| If the castle tile set, this is the lower right corner of the stone block, but in the underground tile set, this is the solid dirt tile.
	BEQ.b ++																			;/ This check is to prevent the latter from being considered a ceiling tile.
.NotSolidDirt:																		;
	LDA.w !RAM_SMW_NorSpr_YPosLo,x													;\ Move the sprite down 1 tile so on the next frame, this sprite can see if it's inside a ceiling now.
	CLC																					;|
	ADC.b #$10																			;|
	STA.w !RAM_SMW_NorSpr_YPosLo,x													;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x													;|
	ADC.b #$00																			;|
	STA.w !RAM_SMW_NorSpr_YPosHi,x													;/
	INC.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								; Increment the sprite state.
++:																						;
	RTS																					; Return

.CeilingTiles:
	db $0130,$014D,$014E,$014F,$013C,$013E,$013F,$0168
	db $0169,$0144,$0133,$0134,$0163,$0164,$0165

State0E_LemonDropSpawnerCheckTileBelowCeiling:
	TYX																					; Restore the current sprite slot index.
	JSR.w DisablePlayerContact														; Prevent the player and Yoshi from interacting with the sprite.
	DEC.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								; Decrement the sprite state, in order to check for a valid tile the next frame.
	JSL.l $019138|!bank																; Check for block collision
	LDA.w !RAM_SMW_NorSpr_LevelCollisionFlags,x									;\ If the sprite is inside a wall, return
	AND.b #$0F																			;|
	BNE.b +																			;/
	STZ.b !RAM_SMW_Misc_ScratchRAM00												;\ Otherwise, spawn a lemon drop on the ceiling.
	LDA.b #$0F																			;|
	STA.b !RAM_SMW_Misc_ScratchRAM01												;|
	STZ.b !RAM_SMW_Misc_ScratchRAM02												;|
	STZ.b !RAM_SMW_Misc_ScratchRAM03												;|
	SEC																					;|
	LDA.b #!Define_SMW_NorSprXXX_LemonDrop												;|
	%SpawnSprite()																		;|
	BCS.b +																			;/
	LDA.b !RAM_SMW_Misc_RandomByte2													;\ Make the newly spawned sprite wait a random amount of time before falling
	AND.b #$7F																			;|
	ORA.b #$40																			;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer,y						;/
	LDA.b #!Define_SMW_NorSprStatus08_Normal											;\ Set the new sprite status to normal so it's state won't get overwritten by the init routine.
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y											;/
	LDA.b #$07																			;\ Set the new sprite to display the hang from ceiling frame.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,y							;/
	JSL.l $01ACF9|!bank																;\ Get a random number, then store it into the phase timer.
	ORA.b #$20																			;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer,x						;/
+:																						;
	RTS																					; Return

BackupXYPosition:
	LDA.w !RAM_SMW_NorSpr_XPosLo,x													;\ Backup the X/Y position of the sprite, so it will despawn properly.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_BackupOfXPosLo,x							;|
	LDA.w !RAM_SMW_NorSpr_XPosHi,x													;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_BackupOfXPosHi,x							;|
	LDA.w !RAM_SMW_NorSpr_YPosLo,x													;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_BackupOfYPosLo,x							;|
	LDA.w !RAM_SMW_NorSpr_YPosHi,x													;|
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_BackupOfYPosHi,x							;/
	RTS																					; Return

RestoreXYPosition:
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_BackupOfXPosLo,x							;\ Restore the X/Y position of the sprite, so it will despawn properly.
	STA.w !RAM_SMW_NorSpr_XPosLo,x													;|
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_BackupOfXPosHi,x							;|
	STA.w !RAM_SMW_NorSpr_XPosHi,x													;|
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_BackupOfYPosLo,x							;|
	STA.w !RAM_SMW_NorSpr_YPosLo,x													;|
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_BackupOfYPosHi,x							;|
	STA.w !RAM_SMW_NorSpr_YPosHi,x													;/
-:																						;
	RTS																					; Return

GFXRt:
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x								;\ If the sprite is acting like a generator or waiting to summon Salvo, return
	CMP.b #$0A																			;|
	BEQ.b -																			;|
if !Define_SMW_NorSprXXX_SalvoTheSlime_DebugDisplay == 1								;|
	CMP.b #$0D																			;|
	BCS.b -																			;/
endif
	%GetDrawInfo()																		; Call the Get Draw info routine to get its on screen position, OAM index, and to set its off screen flags.
	PHX																					; Preserve the current sprite slot index.
	LDA.b #$FF																			;\ Set the number of tiles drawn to 0 (-1, since it will always be incremented at least once in the following routine).
	STA.b !RAM_SMW_Misc_ScratchRAM03												;/
	LDA.w !RAM_SMW_NorSpr_YXPPCCCT,x												;\ Store the sprite's YXPPCCCT properties into scratch RAM
	STA.b !RAM_SMW_Misc_ScratchRAM04												;/
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,x							;\ Store the animation frame X 2 into scratch RAM
	ASL																					;|
	STA.b !RAM_SMW_Misc_ScratchRAM05												;/
	LDA.w !RAM_SMW_NorSpr_FacingDirection,x										;\ Store the facing direction into X and double its value into scratch RAM
	TAX																					;|
	ASL																					;|
	STA.b !RAM_SMW_Misc_ScratchRAM02												;/
	LDA.w Flip,x																		;\ Use the facing direction to update the X bit of the stored YXPPCCCT properties.
	ORA.b !RAM_SMW_Misc_ScratchRAM04												;|
	STA.b !RAM_SMW_Misc_ScratchRAM04												;/
	LDX.b #$01																			; Begin drawing up to 2 tiles by setting the X index
-:
	PHX																					; Preserve the loop index
	TXA																					;\ Add the current animation frame to X
	CLC																					;|
	ADC.b !RAM_SMW_Misc_ScratchRAM05												;|
	TAX																					;/
	LDA.w Tiles,x																		;\ If the current tile is invalid, branch
	CMP.b #$FF																			;|
	BEQ.b ++																			;/
	STA.w SMW_OAMBuffer[$40].Tile,y													; Otherwise, store the tile number to the OAM buffer
	LDA.b !RAM_SMW_Misc_ScratchRAM04												;\ Load the sprite's YXPPCCCT properties into A
	EOR.w Prop,x																		;| Flip the tile if necessary
	ORA.b !RAM_SMW_Sprites_TilePriority												;| Store the PP bits into A
	STA.w SMW_OAMBuffer[$40].Prop,y													;/ Store the property byte into the OAM buffer
	PHX																					; Preserve the current table index 
	TXA																					;\ Add the current animation frame's value again and facing direction into X
	ADC.b !RAM_SMW_Misc_ScratchRAM05												;| This is because the next table's entries are twice as large as the others.
	ADC.b !RAM_SMW_Misc_ScratchRAM02												;|
	TAX																					;/
	LDA.b !RAM_SMW_Misc_ScratchRAM00												;\ Store the on screen X position of the tile into the OAM buffer
	CLC																					;|
	ADC.w XDisp,x																		;|
	STA.w SMW_OAMBuffer[$40].XDisp,y												;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01												;\ Store the on screen Y position of the tile into the OAM buffer
	STA.w SMW_OAMBuffer[$40].YDisp,y												;/
	PLX																					; Restore the current table index
	PHY																					; Preserve the OAM index
	TYA																					;\ Divide the OAM index by 4, since the next OAM table is smaller than the other one.
	LSR																					;|
	LSR																					;|
	TAY																					;/
	LDA.w TileSize,x																	;\ Store the tile size to the second OAM buffer
	STA.w SMW_OAMTileSizeBuffer[$40].Slot,y										;/
	PLY																					; Restore the OAM index
	INY																					;\ Increment the OAM index for the next tile
	INY																					;|
	INY																					;|
	INY																					;/
	INC.b !RAM_SMW_Misc_ScratchRAM03												; Increment the number of tiles drawn.
++:																						;
	PLX																					; Restore the loop index
	DEX																					;\ Have all the sprite been drawn? If not, loop
	BPL.b -																			;/
	PLX																					; Otherwise, restore the current sprite slot index
	LDY.b #$FF																			;\ Call the Finish OAM write routine in order to set the high X bit of the tiles.
	LDA.b !RAM_SMW_Misc_ScratchRAM03												;| Since the tile size is varable for this sprite, there is no need to set the tile size in this routine.
	JSL.l $01B7B3|!bank																;/
	RTS																					; Return

XDisp:
	db $00,$00					;\ Move 1
	db $00,$00					;/
	db $00,$00					;\ Move 2
	db $00,$00					;/
	db $00,$00					;\ Move 3
	db $00,$00					;/
	db $00,$00					;\ Move 4
	db $00,$00					;/
	db $FB,$05					;\ Squish 1
	db $05,$FB					;/
	db $F9,$07					;\ Squish 2
	db $07,$F9					;/
	db $F8,$08					;\ Squish 3
	db $08,$F8					;/
	db $08,$00					;\ Drop from ceiling 1
	db $00,$08					;/
	db $08,$00					;\ Drop from ceiling 2
	db $00,$08					;/
	db $08,$00					;\ Drop from ceiling 3
	db $00,$08					;/

Tiles:
	db $FF,$06					; Move 1
	db $FF,$08					; Move 2
	db $FF,$0A					; Move 3
	db $FF,$08					; Move 4
	db $03,$03					; Squish 1
	db $03,$03					; Squish 2
	db $03,$03					; Squish 3
	db $05,$05					; Drop from ceiling 1
	db $15,$15					; Drop from ceiling 2
	db $FF,$0A					; Drop from ceiling 3

Prop:
	db $FF,$00					; Move 1
	db $FF,$00					; Move 2
	db $FF,$00					; Move 3
	db $FF,$00					; Move 4
	db $40,$00					; Squish 1
	db $40,$00					; Squish 2
	db $40,$00					; Squish 3
	db $00,$40					; Drop from ceiling 1
	db $00,$40					; Drop from ceiling 2
	db $FF,$80					; Drop from ceiling 3

Flip:
	db $40,$00

TileSize:
	db $FF,$02					; Move 1
	db $FF,$02					; Move 2
	db $FF,$02					; Move 3
	db $FF,$02					; Move 4
	db $02,$02					; Squish 1
	db $02,$02					; Squish 2
	db $02,$02					; Squish 3
	db $00,$00					; Drop from ceiling 1
	db $00,$00					; Drop from ceiling 2
	db $FF,$02					; Drop from ceiling 3
