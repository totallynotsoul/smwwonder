; YI Salvo the Slime's Eyes by Yoshifanatic
; This is the eye sprite that draws onto Salvo the Slime.
; It also functions as a positional controller for the ceiling ooze animation, which was originally a separate sprite in YI.
; Before inserting, set !Define_SMW_NorSprXXX_EyesOfSalvoTheSlime in SalvoTheSlimeDefines.asm to the sprite ID you intend on inserting this sprite as. 
; In addition, put SalvoTheSlimeDefines.asm into the PIXI folder and, if using the Yoshi Player Patch, SpriteDefines.asm alongside it.
;
; Notes:
; 

incsrc "../SalvoTheSlimeDefines.asm"

print "INIT ",pc
	RTL

print "MAIN ",pc
	PHB																					;\ Bank wrapper that sets up the DBR to the current bank for easier access to ROM/RAM in tables in this sprite's code.
	PHK																					;|
	PLB																					;|
	JSR.w Sub																			;|
	PLB																					;/
	RTL																					; Return
																						;
Sub:																					;
	TXY																					; Preserve X by putting it into Y
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_CurrentState,x					;\ Get the sprite's state, then jump to the routine corresponding to that state.
	ASL																					;|
	TAX																					;|
	JSR.w (.StatePtrs,x)																;/
-:																						;
	RTS																					; Return

.StatePtrs:
	dw State00_CeilingOozeController
	dw State01_Eyes

State00_CeilingOozeController:
	TYX																					; Restore the current sprite slot index.
	LDA.b !RAM_SMW_Flag_SpritesLocked												;\ If the screen is not frozen, process the rest of the sprite code.
	BNE.b -																			;/
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState							;\ If Salvo is not active, return
	BEQ.b -																			;/
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YAcceleration,x					;\ Increase the sprite's Y acceleration up to 4 pixels a frame downwards.
	CMP.b #$40																			;|
	BCS.b +																			;|
	;CLC																				;|
	ADC.b #$02																			;|
	STA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YAcceleration,x					;/
+:																						;
	CLC																					;\ Update the sprite's Y position
	ADC.w !RAM_SMW_NorSpr_SubYPos,x													;| This code does it in a more fine grained way than what SMW does.
	STA.w !RAM_SMW_NorSpr_SubYPos,x													;| YI's speeds can be 16x more precice and 16x faster than SMW's.
	LDA.w !RAM_SMW_NorSpr_YPosLo,x													;| And this was important, because not doing it this way would cause fun(tm) things to happen.
	ADC.b #$00																			;| If you don't know what I mean by that, if this sprite ends up below Salvo's position, an index overflow occurs that overwrites an entire RAM bank.
	STA.w !RAM_SMW_NorSpr_YPosLo,x													;| Plus, the animation wouldn't look as accurate if I made this work more like SMW anyway.
	LDA.w !RAM_SMW_NorSpr_YPosHi,x													;|
	ADC.b #$00																			;|
	STA.w !RAM_SMW_NorSpr_YPosHi,x													;/
	RTS																					; Return

State01_Eyes:
	TYX																					; Restore the current sprite slot index.
	JSR.w GFXRt																		; Draw this sprite's graphics
	LDA.b !RAM_SMW_Flag_SpritesLocked												;\ If the screen is not frozen, process the rest of the sprite code.
	BEQ.b +																			;/
	RTS																					; Otherwise, return

+:
	JSL.l $01ACF9|!bank																; Get a random number
	JSR.w UpdateEyePosition															; Handle adjusting the X/Y position relative to the body.
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_BlinkingTimer,x					;\ Wait a bit before displaying the next animation frame.
	BNE.b .Return																		;/
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_BlinkingAnimationIndex,x		;\ If the animation index is 00, branch.
	BEQ.b .GetNewAnimationIndex														;/
	BIT.b #$01																			;\ If the animation frame index is odd, branch
	BNE.b .IncrementFrame																;/
	DEC.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_AnimationFrame,x				;\ Otherwise, decrement the animation frame
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_AnimationFrame,x				;/
	BNE.b .DontDecrementBlinkingIndex												;\ If the animation frame is 00, decrement the blinking index.
	BRA.b .DecrementBlinkingIndex													;/ Otherwise, branch.

.IncrementFrame:
	INC.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_AnimationFrame,x				;\ Increment the animation frame
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_AnimationFrame,x				;|
	CMP.b #$02																			;\ If the animation frame is 02, decrement the blinking index.
	BNE.b .DontDecrementBlinkingIndex												;/ Otherwise, branch.
.DecrementBlinkingIndex:																;
	DEC.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_BlinkingAnimationIndex,x		; Decrement the blinking index to change how the animation frame will be handled next frame.
.DontDecrementBlinkingIndex:															;
	LDA.b #$04																			;\ Set the timer for displaying the next frame.
	STA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_BlinkingTimer,x					;/
	RTS																					; Return
																						;
.GetNewAnimationIndex:																;
	LDA.w !RAM_SMW_Misc_RandomByte1													;\ ~62.5% of the time, Salvo will not blink again.
	BIT.b #$1F																			;|
	BNE.b .Return																		;/
	LDA.b #$04																			;\ Otherwise, make Salvo blink
	STA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_BlinkingAnimationIndex,x		;/
.Return:																				;
	RTS																					; Return

UpdateEyePosition:
	JSR.w CalculateEyeTrackingPosition												; Calculate where the eyes should be.
	SEP.b #$30																			;
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID												; Restore the current sprite slot index
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_XPosRelativeToBody,x			;\ If the X position of the eyes and the location they should be at are the same, branch.
	CMP.b !RAM_SMW_Misc_ScratchRAM02												;|
	BEQ.b .HandleYposNext																;/
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_XPosRelativeToBody,x			;\ Otherwise, move the eyes left/right based on where they should be.
	BMI.b +																			;|
	LDA.b !RAM_SMW_Misc_ScratchRAM02												;|
	BMI.b ++																			;|
	CMP.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_XPosRelativeToBody,x			;|
	BCC.b ++																			;|
-:																						;|
	INC.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_XPosRelativeToBody,x			;|
	BRA.b .HandleYposNext																;|
																						;|
+:																						;|
	LDA.b !RAM_SMW_Misc_ScratchRAM02												;|
	BPL.b -																			;|
	CMP.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_XPosRelativeToBody,x			;|
	BCS.b -																			;|
++:																						;|
	DEC.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_XPosRelativeToBody,x			;|
.HandleYposNext:																		;\ If the Y position of the eyes and the location they should be at are the same, branch.
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YPosRelativeToBody,x			;|
	CMP.b !RAM_SMW_Misc_ScratchRAM04												;|
	BEQ.b .Return																		;/
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YPosRelativeToBody,x			;\ Otherwise, move the eyes up/down based on where they should be.
	BMI.b +																			;|
	LDA.b !RAM_SMW_Misc_ScratchRAM04												;|
	BMI.b ++																			;|
	CMP.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YPosRelativeToBody,x			;|
	BCC.b ++																			;|
-:																						;|
	INC.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YPosRelativeToBody,x			;|
	BRA.b .Return																		;|
																						;|
+:																						;|
	LDA.b !RAM_SMW_Misc_ScratchRAM04												;|
	BEQ.b .Return																		;|
	BPL.b -																			;|
	CMP.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YPosRelativeToBody,x			;|
	BCS.b -																			;|
++:																						;|
	DEC.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YPosRelativeToBody,x			;|
.Return:																				;/
	RTS																					; Return

;---------------------------------------------------------------------------

GFXRt:
	LDA.b #$00																			;\ Draw 4 8x8 tiles in a square routine.
	JSL.l $018042|!bank																;/
	LDY.w !RAM_SMW_NorSpr_OAMIndex,x												; Get the OAM index for this sprite
	PHX																					; Preserve the current sprite slot index
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_AnimationFrame,x				;\ Double this sprite's animation frame to use as an index.
	ASL																					;|
	TAX																					;/
	LDA.w .Tiles+$01,x																;\ Overwrite the garbage tiles IDs put into the OAM buffer by the SMW routine above with the eye tiles.
	STA.w SMW_OAMBuffer[$40].Tile,y													;|
	STA.w SMW_OAMBuffer[$41].Tile,y													;|
	LDA.w .Tiles,x																		;|
	STA.w SMW_OAMBuffer[$42].Tile,y													;|
	STA.w SMW_OAMBuffer[$43].Tile,y													;/
	CPX.b #$00																			;\ If the current animation frame is not the fully closed eyes frame, branch.
	BNE.b .NotBlinkingFrame															;/
	LDA.b #$F0																			;\ Get rid of two of four the tiles drawn by the above routine, since this frame only needs two tiles.
	STA.w SMW_OAMBuffer[$42].YDisp,y												;|
	STA.w SMW_OAMBuffer[$43].YDisp,y												;/
.NotBlinkingFrame:																	;
	PLX																					; Restore the current sprite slot index
	RTS																					; Return

.Tiles:
	db $1F,$1F						; Eyes closed
	db $0E,$1E						; Eyes half open
	db $0D,$1D						; Eyes open

;---------------------------------------------------------------------------

; SuperFX routine, converted into ASM the SNES CPU can understand.

CalculateEyeTrackingPosition:
	LDY.b #$01																			; Initialize the index for DATA_0BB800
	LDA.w !RAM_SMW_NorSpr_XPosHi,x													;\ Get the X distance between the eyes and Mario.
	XBA																					;| Note that YI does this the opposite way from SMW!
	LDA.w !RAM_SMW_NorSpr_XPosLo,x													;| SMW subtracts the player position from the sprite's position in SubHorzPos, while this code does it YI's way.
	REP.b #$20																			;|
	SEC																					;|
	SBC.b !RAM_SMW_Player_XPosLo														;|
	BPL.b +																			;|
	LDY.b #$05																			;| Make the index for DATA_0BB800 #$04
	EOR.w #$FFFF																		;| And get the absolute value of the X distance between Mario and the eyes.
	INC																					;|
+:																						;|
	STA.b !RAM_SMW_Misc_ScratchRAM02												;/
	SEP.b #$21																			;\ Get the Y distance between the eyes and Mario.
	LDA.w !RAM_SMW_NorSpr_YPosHi,x													;| Same deal as the X distance
	XBA																					;|
	LDA.w !RAM_SMW_NorSpr_YPosLo,x													;|
	REP.b #$30																			;|
	;SEC																				;|
	SBC.b !RAM_SMW_Player_YPosLo														;|
	BPL.b +																			;|
	INY																					;| Increment the index for DATA_0BB800 by 2.
	INY																					;|
	EOR.w #$FFFF																		;| Get the absolute value of the Y distance between Mario and the eyes.
	INC																					;/
+:																						;
	CMP.b !RAM_SMW_Misc_ScratchRAM02												;\ If the absolute value of the Y distance is greater than the X distance, branch.
	BPL.b +																			;/
	DEY																					; Decrement the index for DATA_0BB800
	TAX																					;\ Swap the Y distance for the X distance for an upcoming multiplication.
	LDA.b !RAM_SMW_Misc_ScratchRAM02												;|
	STX.b !RAM_SMW_Misc_ScratchRAM02												;/
+:																						;
	ASL																					;\ Use the X/Y distance as an index for a division lookup table
	TAX																					;/ This table is basically the equivalent of doing $10000/x.
	LDA.w DivisionLookupTable,x														;\ Multiply the absolute value of the X/Y distance by the reciprocal of the other.
if !sa1 == 1																			;| Then, get the integer portion of the result.
	STZ.w !REGISTER_SA1_ArithmeticType													;|
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo										;|
	LDA.b !RAM_SMW_Misc_ScratchRAM02												;|
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo											;|
	LDA.w !REGISTER_SA1_ArithmeticResultMidLo											;|
else																					;|
	SEP.b #$20																			;|
	STA.w !REGISTER_Mode7MatrixParameterA												;|
	XBA																					;|
	STA.w !REGISTER_Mode7MatrixParameterA												;|
	LDA.b !RAM_SMW_Misc_ScratchRAM02												;|
	STA.w !REGISTER_Mode7MatrixParameterB												;|
	REP.b #$20																			;|
	LDA.w !REGISTER_PPUMultiplicationProductMid											;|
endif																					;|
	XBA																					;| Swap the low and high byte of the result, then double it.
	ASL																					;/
	CMP.w #$0200																		;\ If the result is greater than or equal to #$0200, cap it to #$01FE
	BCC.b +																			;|
	LDA.w #$01FE																		;|
+:																						;/
	PHA																					; Preserve the result.
	TYA																					;\ Double the index for DATA_0BB800
	ASL																					;|
	TAY																					;/
	LDA.w DATA_0BB800,y																;\ Double the value gotten from DATA_0BB800 to get the true offset and to put a flag into the carry flag.
	ASL																					;|
	STA.b !RAM_SMW_Misc_ScratchRAM00												;/
	PLY																					; Restore the previously stored result to use as an index for DATA_0BB810.
	LDA.w DATA_0BB810,y																;\ Load an offset that will be used for a couple trigonometry tables.
	BCC.b +																			;| Invert this value if the previously doubled result set the carry flag.
	EOR.w #$FFFF																		;|
	INC																					;|
	CLC																					;|
+:																						;|
	ADC.b !RAM_SMW_Misc_ScratchRAM00												;|
	AND.w #$01FE																		;|
																						;| End of the translated SuperFX Rt
	TAX																					;/
	LDA.l CosineValueTable,x															;\ Multiply the cosine value read by #$10 to get the 8-bit X position of where the eyes should be.
if !SA1 = 1																			;|
	STZ.w !REGISTER_SA1_ArithmeticType													;|
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo										;|
	LDA.w #$0010																		;|
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo											;|
	LDA.w !REGISTER_SA1_ArithmeticResultMidLo											;|
	SEP.b #$20																			;|
else																					;|
	SEP.b #$20																			;|
	STA.w !REGISTER_Mode7MatrixParameterA												;|
	XBA																					;|
	STA.w !REGISTER_Mode7MatrixParameterA												;|
	LDA.b #$10																			;|
	STA.w !REGISTER_Mode7MatrixParameterB												;|
	LDA.w !REGISTER_PPUMultiplicationProductMid											;|
endif																					;|
	STA.b !RAM_SMW_Misc_ScratchRAM02												;/
	BPL.b +																			;\ If the 8-bit result is negative, set the high byte accordingly.
	LDA.b #$FF																			;|
	BRA.b ++																			;|
																						;|
+:																						;|
	LDA.b #$00																			;|
++:																						;|
	STA.b !RAM_SMW_Misc_ScratchRAM03												;/
	REP.b #$20																			;
	LDA.l SineValueTable,x															;\ Multiply the sine value read by #$10 to get the 8-bit Y position of where the eyes should be.
if !SA1 = 1																			;|
	STZ.w !REGISTER_SA1_ArithmeticType													;|
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo										;|
	LDA.w #$0010																		;|
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo											;|
	LDA.w !REGISTER_SA1_ArithmeticResultMidLo											;|
	SEP.b #$20																			;|
else																					;|
	SEP.b #$20																			;|
	STA.w !REGISTER_Mode7MatrixParameterA												;|
	XBA																					;|
	STA.w !REGISTER_Mode7MatrixParameterA												;|
	LDA.b #$10																			;|
	STA.w !REGISTER_Mode7MatrixParameterB												;|
	LDA.w !REGISTER_PPUMultiplicationProductMid											;|
endif																					;|
	STA.b !RAM_SMW_Misc_ScratchRAM04												;/
	BPL.b +																			;\ If the 8-bit result is negative, set the high byte accordingly.
	LDA.b #$FF																			;|
	BRA.b ++																			;|
																						;|
+:																						;|
	LDA.b #$00																			;|
++:																						;|
	STA.b !RAM_SMW_Misc_ScratchRAM05												;/
	RTS																					; Return

DATA_0BB800:
	dw $8080,$0040,$0080,$80C0
	dw $0000,$8040,$8100,$00C0

DATA_0BB810:
	dw $0000,$0000,$0000,$0000,$0000,$0002,$0002,$0002
	dw $0002,$0002,$0002,$0002,$0004,$0004,$0004,$0004
	dw $0004,$0004,$0006,$0006,$0006,$0006,$0006,$0006
	dw $0008,$0008,$0008,$0008,$0008,$0008,$000A,$000A
	dw $000A,$000A,$000A,$000A,$000A,$000C,$000C,$000C
	dw $000C,$000C,$000C,$000E,$000E,$000E,$000E,$000E
	dw $000E,$000E,$0010,$0010,$0010,$0010,$0010,$0010
	dw $0012,$0012,$0012,$0012,$0012,$0012,$0012,$0014
	dw $0014,$0014,$0014,$0014,$0014,$0014,$0016,$0016
	dw $0016,$0016,$0016,$0016,$0018,$0018,$0018,$0018
	dw $0018,$0018,$0018,$001A,$001A,$001A,$001A,$001A
	dw $001A,$001A,$001C,$001C,$001C,$001C,$001C,$001C
	dw $001C,$001E,$001E,$001E,$001E,$001E,$001E,$001E
	dw $001E,$0020,$0020,$0020,$0020,$0020,$0020,$0020
	dw $0022,$0022,$0022,$0022,$0022,$0022,$0022,$0022
	dw $0024,$0024,$0024,$0024,$0024,$0024,$0024,$0026
	dw $0026,$0026,$0026,$0026,$0026,$0026,$0026,$0028
	dw $0028,$0028,$0028,$0028,$0028,$0028,$0028,$002A
	dw $002A,$002A,$002A,$002A,$002A,$002A,$002A,$002A
	dw $002C,$002C,$002C,$002C,$002C,$002C,$002C,$002C
	dw $002E,$002E,$002E,$002E,$002E,$002E,$002E,$002E
	dw $002E,$0030,$0030,$0030,$0030,$0030,$0030,$0030
	dw $0030,$0030,$0032,$0032,$0032,$0032,$0032,$0032
	dw $0032,$0032,$0032,$0032,$0034,$0034,$0034,$0034
	dw $0034,$0034,$0034,$0034,$0034,$0034,$0036,$0036
	dw $0036,$0036,$0036,$0036,$0036,$0036,$0036,$0036
	dw $0038,$0038,$0038,$0038,$0038,$0038,$0038,$0038
	dw $0038,$0038,$0038,$003A,$003A,$003A,$003A,$003A
	dw $003A,$003A,$003A,$003A,$003A,$003A,$003C,$003C
	dw $003C,$003C,$003C,$003C,$003C,$003C,$003C,$003C
	dw $003C,$003E,$003E,$003E,$003E,$003E,$003E,$003E
	dw $003E,$003E,$003E,$003E,$003E,$0040,$0040,$0040
	dw $0040

DivisionLookupTable:										; These are the results for $10000/x.
	dw $FFFF,$FFFF,$8000,$5555,$4000,$3333,$2AAA,$2492
	dw $2000,$1C71,$1999,$1745,$1555,$13B1,$1249,$1111
	dw $1000,$0F0F,$0E38,$0D79,$0CCC,$0C30,$0BA2,$0B21
	dw $0AAA,$0A3D,$09D8,$097B,$0924,$08D3,$0888,$0842
	dw $0800,$07C1,$0787,$0750,$071C,$06EB,$06BC,$0690
	dw $0666,$063E,$0618,$05F4,$05D1,$05B0,$0590,$0572
	dw $0555,$0539,$051E,$0505,$04EC,$04D4,$04BD,$04A7
	dw $0492,$047D,$0469,$0456,$0444,$0432,$0421,$0410
	dw $0400,$03F0,$03E0,$03D2,$03C3,$03B5,$03A8,$039B
	dw $038E,$0381,$0375,$0369,$035E,$0353,$0348,$033D
	dw $0333,$0329,$031F,$0315,$030C,$0303,$02FA,$02F1
	dw $02E8,$02E0,$02D8,$02D0,$02C8,$02C0,$02B9,$02B1
	dw $02AA,$02A3,$029C,$0295,$028F,$0288,$0282,$027C
	dw $0276,$0270,$026A,$0264,$025E,$0259,$0253,$024E
	dw $0249,$0243,$023E,$0239,$0234,$0230,$022B,$0226
	dw $0222,$021D,$0219,$0214,$0210,$020C,$0208,$0204
	dw $0200,$01FC,$01F8,$01F4,$01F0,$01EC,$01E9,$01E5
	dw $01E1,$01DE,$01DA,$01D7,$01D4,$01D0,$01CD,$01CA
	dw $01C7,$01C3,$01C0,$01BD,$01BA,$01B7,$01B4,$01B2
	dw $01AF,$01AC,$01A9,$01A6,$01A4,$01A1,$019E,$019C
	dw $0199,$0197,$0194,$0192,$018F,$018D,$018A,$0188
	dw $0186,$0183,$0181,$017F,$017D,$017A,$0178,$0176
	dw $0174,$0172,$0170,$016E,$016C,$016A,$0168,$0166
	dw $0164,$0162,$0160,$015E,$015C,$015A,$0158,$0157
	dw $0155,$0153,$0151,$0150,$014E,$014C,$014A,$0149
	dw $0147,$0146,$0144,$0142,$0141,$013F,$013E,$013C
	dw $013B,$0139,$0138,$0136,$0135,$0133,$0132,$0130
	dw $012F,$012E,$012C,$012B,$0129,$0128,$0127,$0125
	dw $0124,$0123,$0121,$0120,$011F,$011E,$011C,$011B
	dw $011A,$0119,$0118,$0116,$0115,$0114,$0113,$0112
	dw $0111,$010F,$010E,$010D,$010C,$010B,$010A,$0109
	dw $0108,$0107,$0106,$0105,$0104,$0103,$0102,$0101
	dw $0100,$00FF,$00FE,$00FD,$00FC,$00FB,$00FA,$00F9
	dw $00F8,$00F7,$00F6,$00F5,$00F4,$00F3,$00F2,$00F1
	dw $00F0,$00F0,$00EF,$00EE,$00ED,$00EC,$00EB,$00EA
	dw $00EA,$00E9,$00E8,$00E7,$00E6,$00E5,$00E5,$00E4
	dw $00E3,$00E2,$00E1,$00E1,$00E0,$00DF,$00DE,$00DE
	dw $00DD,$00DC,$00DB,$00DB,$00DA,$00D9,$00D9,$00D8
	dw $00D7,$00D6,$00D6,$00D5,$00D4,$00D4,$00D3,$00D2
	dw $00D2,$00D1,$00D0,$00D0,$00CF,$00CE,$00CE,$00CD
	dw $00CC,$00CC,$00CB,$00CA,$00CA,$00C9,$00C9,$00C8
	dw $00C7,$00C7,$00C6,$00C5,$00C5,$00C4,$00C4,$00C3
	dw $00C3,$00C2,$00C1,$00C1,$00C0,$00C0,$00BF,$00BF
	dw $00BE,$00BD,$00BD,$00BC,$00BC,$00BB,$00BB,$00BA
	dw $00BA,$00B9,$00B9,$00B8,$00B8,$00B7,$00B7,$00B6
	dw $00B6,$00B5,$00B5,$00B4,$00B4,$00B3,$00B3,$00B2
	dw $00B2,$00B1,$00B1,$00B0,$00B0,$00AF,$00AF,$00AE
	dw $00AE,$00AD,$00AD,$00AC,$00AC,$00AC,$00AB,$00AB
	dw $00AA,$00AA,$00A9,$00A9,$00A8,$00A8,$00A8,$00A7
	dw $00A7,$00A6,$00A6,$00A5,$00A5,$00A5,$00A4,$00A4
	dw $00A3,$00A3,$00A3,$00A2,$00A2,$00A1,$00A1,$00A1
	dw $00A0,$00A0,$009F,$009F,$009F,$009E,$009E,$009D
	dw $009D,$009D,$009C,$009C,$009C,$009B,$009B,$009A
	dw $009A,$009A,$0099,$0099,$0099,$0098,$0098,$0098
	dw $0097,$0097,$0097,$0096,$0096,$0095,$0095,$0095
	dw $0094,$0094,$0094,$0093,$0093,$0093,$0092,$0092
	dw $0092,$0091,$0091,$0091,$0090,$0090,$0090,$0090
	dw $008F,$008F,$008F,$008E,$008E,$008E,$008D,$008D
	dw $008D,$008C,$008C,$008C,$008C,$008B,$008B,$008B
	dw $008A,$008A,$008A,$0089,$0089,$0089,$0089,$0088
	dw $0088,$0088,$0087,$0087,$0087,$0087,$0086,$0086
	dw $0086,$0086,$0085,$0085,$0085,$0084,$0084,$0084
	dw $0084,$0083,$0083,$0083,$0083,$0082,$0082,$0082
	dw $0082,$0081,$0081,$0081,$0081,$0080,$0080,$0080
	dw $0080

CosineValueTable:
	dw $0100,$0100,$0100,$00FF,$00FF,$00FE,$00FD,$00FC
	dw $00FB,$00FA,$00F8,$00F7,$00F5,$00F3,$00F1,$00EF
	dw $00ED,$00EA,$00E7,$00E5,$00E2,$00DF,$00DC,$00D8
	dw $00D5,$00D1,$00CE,$00CA,$00C6,$00C2,$00BE,$00B9
	dw $00B5,$00B1,$00AC,$00A7,$00A2,$009D,$0098,$0093
	dw $008E,$0089,$0084,$007E,$0079,$0073,$006D,$0068
	dw $0062,$005C,$0056,$0050,$004A,$0044,$003E,$0038
	dw $0032,$002C,$0026,$001F,$0019,$0013,$000D,$0006

SineValueTable:
	dw $0000,$FFFA,$FFF3,$FFED,$FFE7,$FFE1,$FFDA,$FFD4
	dw $FFCE,$FFC8,$FFC2,$FFBC,$FFB6,$FFB0,$FFAA,$FFA4
	dw $FF9E,$FF98,$FF93,$FF8D,$FF87,$FF82,$FF7C,$FF77
	dw $FF72,$FF6D,$FF68,$FF63,$FF5E,$FF59,$FF54,$FF4F
	dw $FF4B,$FF47,$FF42,$FF3E,$FF3A,$FF36,$FF32,$FF2F
	dw $FF2B,$FF28,$FF24,$FF21,$FF1E,$FF1B,$FF19,$FF16
	dw $FF13,$FF11,$FF0F,$FF0D,$FF0B,$FF09,$FF08,$FF06
	dw $FF05,$FF04,$FF03,$FF02,$FF01,$FF01,$FF00,$FF00
	dw $FF00,$FF00,$FF00,$FF01,$FF01,$FF02,$FF03,$FF04
	dw $FF05,$FF06,$FF08,$FF09,$FF0B,$FF0D,$FF0F,$FF11
	dw $FF13,$FF16,$FF19,$FF1B,$FF1E,$FF21,$FF24,$FF28
	dw $FF2B,$FF2F,$FF32,$FF36,$FF3A,$FF3E,$FF42,$FF47
	dw $FF4B,$FF4F,$FF54,$FF59,$FF5E,$FF63,$FF68,$FF6D
	dw $FF72,$FF77,$FF7C,$FF82,$FF87,$FF8D,$FF93,$FF98
	dw $FF9E,$FFA4,$FFAA,$FFB0,$FFB6,$FFBC,$FFC2,$FFC8
	dw $FFCE,$FFD4,$FFDA,$FFE1,$FFE7,$FFED,$FFF3,$FFFA
	dw $0000,$0006,$000D,$0013,$0019,$001F,$0026,$002C
	dw $0032,$0038,$003E,$0044,$004A,$0050,$0056,$005C
	dw $0062,$0068,$006D,$0073,$0079,$007E,$0084,$0089
	dw $008E,$0093,$0098,$009D,$00A2,$00A7,$00AC,$00B1
	dw $00B5,$00B9,$00BE,$00C2,$00C6,$00CA,$00CE,$00D1
	dw $00D5,$00D8,$00DC,$00DF,$00E2,$00E5,$00E7,$00EA
	dw $00ED,$00EF,$00F1,$00F3,$00F5,$00F7,$00F8,$00FA
	dw $00FB,$00FC,$00FD,$00FE,$00FF,$00FF,$0100,$0100
	dw $0100,$0100,$0100,$00FF,$00FF,$00FE,$00FD,$00FC
	dw $00FB,$00FA,$00F8,$00F7,$00F5,$00F3,$00F1,$00EF
	dw $00ED,$00EA,$00E7,$00E5,$00E2,$00DF,$00DC,$00D8
	dw $00D5,$00D1,$00CE,$00CA,$00C6,$00C2,$00BE,$00B9
	dw $00B5,$00B1,$00AC,$00A7,$00A2,$009D,$0098,$0093
	dw $008E,$0089,$0084,$007E,$0079,$0073,$006D,$0068
	dw $0062,$005C,$0056,$0050,$004A,$0044,$003E,$0038
	dw $0032,$002C,$0026,$001F,$0019,$0013,$000D,$0006

;---------------------------------------------------------------------------
