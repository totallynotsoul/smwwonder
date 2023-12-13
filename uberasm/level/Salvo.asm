; YI Salvo the Slime by Yoshifanatic
; This is a recreation of the 2nd boss fight in YI.
; To set this up:
;- Put the ExGFX into the ExGraphics folder, and insert them into your ROM.
;- Insert the provided map16 file to insert the background tiles used for rendering Salvo.
;- Insert the provided .mwl file to get the background tilemap you'll need for rendering Salvo.
;- Open SalvoTheSlimeDefines.asm, then set the "EyesOfSalvoTheSlime", "LemonDrop", and "SlimeBall" defines to the sprite ID you intend on inserting them as (cluster sprite ID in the case of the slime ball).
;- If you're using the "Yoshi Player Patch", set !Define_SMW_NorSprXXX_SalvoTheSlime_YoshiPlayerPatchInstalled to 1.
;- Put a copy of SalvoTheSlimeDefines.asm into UberASM's folder, and PIXI's folder.
;- Put this file in the level folder.
;- If using the Yoshi Player Patch, put "SpriteDefines.asm" inside the UberASM folder and inside PIXI's folder.
;
;Notes:
;- You can't use layer 3 with the orignal status bar, because the timing of the HDMA will mess with the value on the bus during the IRQ that sets the layer 3 position below the status bar.
;- This resource can be used either with or without the SA-1 patch. However without it, Salvo will not distort horizontally in order to save on processing time.
;- In YI, Salvo was hardcoded to spawn at a specific X/Y position. However, Salvo is set to spawn 8.5 tiles to the right and 2 tiles down from the current screen position.

incsrc "../SalvoTheSlimeDefines.asm"
load:
LDA $FF
STA $18BB|!addr
macro SetOffsetForDebugCollisionPointTile(TileAndProp, HitBoxTableOffset)
	LDA.w #<TileAndProp>
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenYPosLo
	CLC
	ADC.w HitboxPointYOffset+<HitBoxTableOffset>
	AND.w #$FFF0
	TAX
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenXPosLo
	CLC
	ADC.w HitboxPointXOffset+<HitBoxTableOffset>
	AND.w #$FFF0
	JSR.w SetXYPosOfDebugTile
endmacro

macro CalculateSigned16By16BitWholeNumberMultiplication()
if !sa1 == 1
	STZ.w !REGISTER_SA1_ArithmeticType
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo
	NOP
	LDA.w !REGISTER_SA1_ArithmeticResultMidLo
	STA.b !RAM_SMW_Misc_ScratchRAM0E
else
	SEP.b #$20
	STA.w !REGISTER_Mode7MatrixParameterA
	XBA
	STA.w !REGISTER_Mode7MatrixParameterA
	SEC
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	BPL.b ++
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	BMI.b +
	ASL
	CLC
+:
	STA.w !REGISTER_Mode7MatrixParameterB
	REP.b #$20
	LDA.w !REGISTER_PPUMultiplicationProductMid
	BCS.b +
	LSR
+:
	BRA.b +++

++:
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	BPL.b +
	LSR
	CLC
+:
	STA.w !REGISTER_Mode7MatrixParameterB
	REP.b #$20
	LDA.w !REGISTER_PPUMultiplicationProductMid
	BCS.b +
	ASL
+:
+++:
	STA.b !RAM_SMW_Misc_ScratchRAM0E
endif
endmacro

NMI:
	REP.b #$10																	; Set X/Y to be 16-bit
	LDX.w !RAM_SMW_Mirror_MainScreenLayers									;\ SMW is stupid and doesn't write to these registers during V-Blank for some reason.
	STX.w !REGISTER_MainScreenLayers											;/ This is necessary so Salvo can change its layer priority.
	LDX.w #Layer2VerticalPosHDMATable1										;\ Change the HDMA source based on whether the current frame count is even or odd.
	LDY.w #Layer2HorizontalPosHDMATable1									;| Salvo needs to be double buffered to prevent visual glitches.
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BufferToUse+$01				;| This must be done during V-Blank while HDMA is currently not rendering.
	AND.b #$04																	;|
	BNE.b +																	;|
	LDX.w #Layer2VerticalPosHDMATable2										;|
	LDY.w #Layer2HorizontalPosHDMATable2									;|
+:																				;|
	STX.w HDMA[!Define_SMW_NorSprXXX_SalvoTheSlime_YPosHDMAChannel].SourceLo	;|
	STY.w HDMA[!Define_SMW_NorSprXXX_SalvoTheSlime_XPosHDMAChannel].SourceLo	;/
	SEP.b #$10																	; Set X/Y to be 8-bit
	RTL																			; Return

Init:
	REP.b #$20
	JSR.w InitializePolygonalLayerHDMA
	LDA.w #(!REGISTER_BG2HorizScrollOffset&$0000FF<<8)+$42
	STA.w HDMA[!Define_SMW_NorSprXXX_SalvoTheSlime_XPosHDMAChannel].Parameters
	LDA.w #(!REGISTER_BG2VertScrollOffset&$0000FF<<8)+$42
	STA.w HDMA[!Define_SMW_NorSprXXX_SalvoTheSlime_YPosHDMAChannel].Parameters
	LDA.w #Layer2HorizontalPosHDMATable1
	STA.w HDMA[!Define_SMW_NorSprXXX_SalvoTheSlime_XPosHDMAChannel].SourceLo
	LDA.w #Layer2VerticalPosHDMATable1
	STA.w HDMA[!Define_SMW_NorSprXXX_SalvoTheSlime_YPosHDMAChannel].SourceLo
	LDY.b #Layer2HorizontalPosHDMATable1>>16
	STY.w HDMA[!Define_SMW_NorSprXXX_SalvoTheSlime_XPosHDMAChannel].SourceBank
	STY.w HDMA[!Define_SMW_NorSprXXX_SalvoTheSlime_YPosHDMAChannel].SourceBank
	LDY.b #!RAM_SMW_Global_Layer2YPosHDMATable1>>16
	STY.w HDMA[!Define_SMW_NorSprXXX_SalvoTheSlime_XPosHDMAChannel].IndirectSourceBank
	STY.w HDMA[!Define_SMW_NorSprXXX_SalvoTheSlime_YPosHDMAChannel].IndirectSourceBank
	LDY.b #($01<<!Define_SMW_NorSprXXX_SalvoTheSlime_XPosHDMAChannel)|($01<<!Define_SMW_NorSprXXX_SalvoTheSlime_YPosHDMAChannel)
	STY.w !RAM_SMW_Mirror_HDMAEnable
	LDX.b #(!RAM_SMW_NorSprXXX_SalvoTheSlime_FreezePlayerFlag-!RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset)&$FE
-:
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset,x
	DEX
	DEX
	BNE.b -
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	CLC
	ADC.w #$0088
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialXPos
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset+$20
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	DEC
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialYPos
	LDA.w #!Define_SMW_NorSprXXX_SalvoTheSlime_FloorYPos
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_FloorYPosLo
	;INC.w !RAM_YI_NorSpr02D_SalvoTheSlime_TouchedBoxFlag
	;LDA.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState05_OozeFromCeiling
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	JSR.w SpawnEyes
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CLC
	ADC.w #$0018
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScalingOfCeilingOoze
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InverseOfMinVerticalScaling
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnGroundFlag
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveOffset
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
	LDA.w #$0100
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveFrequency
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MovementCounter
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TookDamageFlag
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	LDA.w #$B000
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashTimer
	LDA.w #$00E0
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScaling
	LDA.w #$0001
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_IntroAnimationState
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeExplodingState
	LDA.w #$0003
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YAcceleration
	LDA.w #$0100
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxYSpeed
	LDA.w #$00C0
	STA.w !RAM_SMW_Misc_Layer2YPosLo
	SEP.b #$20
	INC.w !RAM_SMW_Flag_RunClusterSprites
	RTL

Layer2VerticalPosHDMATable1:
	db $F1 : dw !RAM_SMW_Global_Layer2YPosHDMATable1
	db $F1 : dw !RAM_SMW_Global_Layer2YPosHDMATable1+(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)+$01
	db $00

Layer2HorizontalPosHDMATable1:
	db $F1 : dw !RAM_SMW_Global_Layer2XPosHDMATable1
	db $F1 : dw !RAM_SMW_Global_Layer2XPosHDMATable1+(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)+$01
	db $00

Layer2VerticalPosHDMATable2:
	db $F1 : dw !RAM_SMW_Global_Layer2YPosHDMATable2
	db $F1 : dw !RAM_SMW_Global_Layer2YPosHDMATable2+(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)+$01
	db $00

Layer2HorizontalPosHDMATable2:
	db $F1 : dw !RAM_SMW_Global_Layer2XPosHDMATable2
	db $F1 : dw !RAM_SMW_Global_Layer2XPosHDMATable2+(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)+$01
	db $00

InitializePolygonalLayerHDMA:
	REP.b #$10
	PHB
	LDA.w #!RAM_SMW_Global_Layer2YPosHDMATable1>>8
	PHA
	PLB
	PLB
	LDY.w #!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount-$02
	LDA.w #$FF00
-:
	STA.w !RAM_SMW_Global_Layer2YPosHDMATable1,y
	STA.w !RAM_SMW_Global_Layer2XPosHDMATable1,y
	STA.w !RAM_SMW_Global_Layer2YPosHDMATable2,y
	STA.w !RAM_SMW_Global_Layer2XPosHDMATable2,y
	;DEC
	DEY
	DEY
	BPL.b -
	SEP.b #$10
	LDY.b #($01<<!Define_SMW_NorSprXXX_SalvoTheSlime_XPosHDMAChannel)|($01<<!Define_SMW_NorSprXXX_SalvoTheSlime_YPosHDMAChannel)
	TYA
	TRB.w !RAM_SMW_Mirror_HDMAEnable
	PLB
	RTS

Main:
	LDA.b !RAM_SMW_Flag_SpritesLocked
	ORA.w !RAM_SMW_Flag_Pause
	BNE.b SalvoInactive
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	BEQ.b SalvoInactive
if !sa1 == 1
	REP.b #$20
	LDA.w #SA1
	STA.w !RAM_SMW_SA1_SA1CPUPtrLo
	SEP.b #$20
	LDA.b #SA1>>16
	STA.w !RAM_SMW_SA1_SA1CPUPtrBank
	JSR.w !RAM_SMW_SA1_InvokeSA1CPURt		; Invoke SA-1 and wait to finish.
	RTL

SA1:
endif
	PHB
	PHK
	PLB
	REP.b #$20
	JSR.w Sub
if !Define_SMW_NorSprXXX_SalvoTheSlime_DebugDisplay == 1
	JSR.w DisplayDebugSprites
endif
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_16BitPlayerXSpeed
	LSR
	LSR
	LSR
	LSR
	SEP.b #$30
	STA.b !RAM_SMW_Player_XSpeed
	PLB
SalvoInactive:
	RTL

if !Define_SMW_NorSprXXX_SalvoTheSlime_DebugDisplay == 1
DisplayDebugSprites:
	REP.b #$10
-:
	LDA.w #$343D
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenYPosLo
	SEC
	SBC.w #$0004
	TAX
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenXPosLo
	SEC
	SBC.w #$0004
	LDY.w #$0000
	JSR.w SetXYPosOfDebugTile
	%SetOffsetForDebugCollisionPointTile($383D, $00)
	%SetOffsetForDebugCollisionPointTile($383D, $02)
	%SetOffsetForDebugCollisionPointTile($383D, $04)
	%SetOffsetForDebugCollisionPointTile($383D, $06)
	%SetOffsetForDebugCollisionPointTile($363D, $08)
	%SetOffsetForDebugCollisionPointTile($363D, $0A)
	%SetOffsetForDebugCollisionPointTile($363D, $0C)
	%SetOffsetForDebugCollisionPointTile($363D, $0E)
	STZ.w SMW_OAMTileSizeBuffer[$00].Slot
	STZ.w SMW_OAMTileSizeBuffer[$02].Slot
	STZ.w SMW_OAMTileSizeBuffer[$04].Slot
	STZ.w SMW_OAMTileSizeBuffer[$06].Slot
	STZ.w SMW_OAMTileSizeBuffer[$08].Slot
	SEP.b #$10
	RTS

SetXYPosOfDebugTile:
	CLC
	ADC.w #$0004
	PHA
	CLC
	ADC.w #$0010
	CMP.w #$0110
	PLA
	BCC.b +
	BRA.b ++

+:
	STA.w SMW_OAMBuffer[$00].XDisp,y
	TXA
	CLC
	ADC.w #$0004
	PHA
	CLC
	ADC.w #$0010
	CMP.w #$0100
	PLA
	BCC.b +
++:
	LDA.w #$00F0
+:
	STA.w SMW_OAMBuffer[$00].YDisp,y
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	STA.w SMW_OAMBuffer[$00].Tile,y
	INY
	INY
	INY
	INY
	RTS
endif

DATA_0683AE:
	dw MainState0E_Inactive
	dw MainState00_Jumping
	dw MainState01_Unknown
	dw MainState02_Chase
	dw MainState03_WiggleDefense
	dw MainState04_Unknown
	dw MainState05_OozeFromCeiling
	dw MainState06_HopAfterOozing
	dw MainState07_Grow
	dw MainState08_WaitAfterGrowing
	dw MainState09_DeadInit
	dw MainState0A_DeadShrinking
	dw MainState0B_WaitBeforeExploding
	dw MainState0C_ChangeFromBoxToSlime
	dw MainState0D_MorphFromBoxToSlime

Sub:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	BEQ.b +
	DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
+:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeSpawningLemonDropTimer
	BEQ.b +
	DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeSpawningLemonDropTimer
+:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashAnimationTimer
	BEQ.b +
	DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashAnimationTimer
+:
	REP.b #$10
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XAcceleration
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxXSpeed
	CPY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	BPL.b +
	EOR.w #$FFFF
	INC
+:
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	PHA
	AND.w #$00FF
	XBA
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SubXPos-$01
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SubXPos-$01
	PLA
	AND.w #$FF00
	BPL.b +
	ORA.w #$00FF
+:
	XBA
	PHP
	PHA
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	PHA
	LDY.w #$0000
	SEC
	SBC.b !RAM_SMW_Player_XPosLo
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XDistanceFromMario
	BPL.b +
	INY
	INY
+:
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HorizontalDirectionRelativeToMario
	PLA
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenXPosLo
	PLA
	PLP
	ADC.w #$0000
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPixelsMovedLo
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YAcceleration
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxYSpeed
	CPY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	BPL.b +
	EOR.w #$FFFF
	INC
+:
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	PHA
	AND.w #$00FF
	XBA
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SubYPos-$01
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SubYPos-$01
	PLA
	AND.w #$FF00
	BPL.b +
	ORA.w #$00FF
+:
	XBA
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	PHA
	LDY.w #$0000
	SEC
	SBC.b !RAM_SMW_Player_YPosLo
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YDistanceFromMario
	BPL.b +
	INY
	INY
+:
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalDirectionRelativeToMario
	PLA
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenYPosLo
	SEP.b #$10
	LDA.b !RAM_SMW_Player_XSpeed
	AND.w #$00FF
	LDY.b !RAM_SMW_Player_XSpeed
	BPL.b +
	ORA.w #$0F00
+:
	ASL
	ASL
	ASL
	ASL
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_16BitPlayerXSpeed

	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo+$01
	TYA
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScaling
	%CalculateSigned16By16BitWholeNumberMultiplication()
if !sa1 == 1
	LDA.w #$0180
	%CalculateSigned16By16BitWholeNumberMultiplication()
else
	SEP.b #$20
	STA.w !REGISTER_Mode7MatrixParameterA
	XBA
	STA.w !REGISTER_Mode7MatrixParameterA
	LDA.b #$18
	STA.w !REGISTER_Mode7MatrixParameterB
	REP.b #$20
	LDA.w !REGISTER_PPUMultiplicationProductMid
	ASL
	ASL
	ASL
	ASL
endif
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_EyeYPositionOffset
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0C_ChangeFromBoxToSlime
	BPL.b CODE_068402
	JSR.w DrawSalvo
	JSR.w HandleCeilingAndFloorCollision
CODE_068402:
	JSR.w HandleWallCollision
	;LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpawnedFromBoxFlag
	;BEQ.b CODE_068417
	;LDY.w !MEXRAM_YI_Player_CurrentStateLo
	;CPY.b #!Define_YI_PlayerState06
	;BNE.b CODE_068417
	;LDA.w #$0215
	;STA.w !RAM_SMW_Mirror_MainScreenLayers
;CODE_068417:
	;JSL.l CODE_03AF23
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0C_ChangeFromBoxToSlime
	BEQ.b CODE_06842B
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0D_MorphFromBoxToSlime
	BEQ.b CODE_068428
	JSR.w HandleSpriteCollision
CODE_068428:
	JSR.w HandlePlayerCollision
CODE_06842B:
	JSR.w HandleDeathAnimation
	TXY
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	ASL
	TAX
	JSR.w (DATA_0683AE,x)
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashTimer
	BEQ.b CODE_06843E
	DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashTimer
CODE_06843E:
	JMP.w SpawnEmergencyLemonDrop

DrawSalvo:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState05_OozeFromCeiling
	BEQ.b CODE_068452
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0B_WaitBeforeExploding
	BNE.b CODE_068464
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeExplodingState
	BEQ.b CODE_068464
MainState0E_Inactive:
	RTS

CODE_068452:										; Note: Apparently, Salvo uses the Y position of a falling ambient sprite to handle the position of the ooze.
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM600E
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6010
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteIndexOfPositionControllerSprite
	SEP.b #$20
	LDA.w !RAM_SMW_NorSpr_YPosHi,y
	XBA
	LDA.w !RAM_SMW_NorSpr_YPosLo,y
	REP.b #$20
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	BRA.b CODE_0684AA

CODE_068464:										; Note: Otherwise, it uses a table from the eye sprite.
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteIndexOfPositionControllerSprite
	SEP.b #$20
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YPosRelativeToBody,y
	XBA
	LDA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_XPosRelativeToBody,y
	REP.b #$20
	PHA
	AND.w #$00FF
	TAY
	BPL.b CODE_068474
	ORA.w #$FF00
CODE_068474:
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM600E
	PLA
	AND.w #$FF00
	BPL.b CODE_068480
	ORA.w #$00FF
CODE_068480:
	XBA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0028
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_EyeYPositionOffset
	%CalculateSigned16By16BitWholeNumberMultiplication()							;|
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM0E
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset
endif
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6010
	LDA.w #$0000
CODE_0684AA:
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset
endif
	STA.b !R2
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScalingOfCeilingOoze
	SEC
	SBC.w #$0008
	STA.b !R3
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo+$01
	TYA
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w #$02C0
	SEC
	SBC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScaling
	%CalculateSigned16By16BitWholeNumberMultiplication()							;|
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6004
	JSR.w ProcessSalvoHDMAAndCollision
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BufferToUse
	EOR.w #$0400
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BufferToUse
	;REP.b #$10
	;JSL.l YI_SetupDMATransferToWRAM_FixedSize	: dl !RAM_YI_Global_HDMABuffer01,!EXRAM_YI_Global_HDMADoubleBuffer01 : dw $0348
	;SEP.b #$30
	LDA.w !RAM_SMW_Mirror_MainScreenLayers
	AND.w #$0404
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CMP.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState05_OozeFromCeiling
	SEP.b #$20
	BNE.b CODE_06853C
	;LDA.b #$08
	;TRB.b !RAM_SMW_Mirror_BGModeAndTileSizeSetting
	LDY.b #$13
	LDA.b #$00
	BRA.b CODE_06854B

CODE_06853C:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpawnedFromBoxFlag
	BEQ.b CODE_068547
	LDY.b #$10
	LDA.b #$03
	BRA.b CODE_06854B

CODE_068547:
	LDY.b #$12
	LDA.b #$01
CODE_06854B:
	ORA.b !RAM_SMW_Misc_ScratchRAM0F
	STA.w !RAM_SMW_Mirror_SubScreenLayers
	TYA
	ORA.b !RAM_SMW_Misc_ScratchRAM0E	
	STA.w !RAM_SMW_Mirror_MainScreenLayers
	LDA.b #$02
	STA.b !RAM_SMW_Mirror_ColorMathInitialSettings
	LDA.b #$20
	STA.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
	REP.b #$20
	JSR.w HandleHurtFlash
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6020
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TopOfSalvosHeadYPos
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState05_OozeFromCeiling
	BEQ.b CODE_068590
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteIndexOfPositionControllerSprite
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6010
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	SEC
	SBC.w #$0010
	PHA
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM600E
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	SEP.b #$20
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	XBA
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	PLA
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	PLA
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	REP.b #$20
CODE_068590:
	RTS

HandleHurtFlash:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpawnedFromBoxFlag
	BEQ.b CODE_0685E0
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashTimer
	BEQ.b CODE_0685BE
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashAnimationTimer
	BNE.b CODE_0685DF
	LDA.w #$0004
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashAnimationTimer
	LDA.w SMW_CopyOfPaletteMirror[$01].LowByte
	EOR.w #$FFFF
	STA.w SMW_CopyOfPaletteMirror[$01].LowByte
	LDA.w SMW_CopyOfPaletteMirror[$02].LowByte
	EOR.w #$FFFF
	BRA.b CODE_0685CC

CODE_0685BE:
	LDA.w #$637D
	STA.w SMW_CopyOfPaletteMirror[$01].LowByte
	LDA.w #$4A75
CODE_0685CC:
	STA.w SMW_CopyOfPaletteMirror[$02].LowByte
	LDA.w #$0000
	STA.w SMW_CopyOfPaletteMirror[$03].LowByte
CODE_0685DF:
	RTS

CODE_0685E0:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashTimer
	BEQ.b CODE_068603
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashAnimationTimer
	BNE.b CODE_068603
	LDA.w #$0004
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashAnimationTimer
	LDX.b #$1C
CODE_0685F2:
	LDA.l DATA_5FA56E,x
	STA.w SMW_CopyOfPaletteMirror[$01].LowByte,x
	STA.w SMW_CopyOfPaletteMirror[$11].LowByte,x
	DEX
	DEX
	BNE.b CODE_0685F2
	BRA.b CODE_068621

CODE_068603:
	LDX.b #$1C
CODE_068605:
	LDA.l DATA_5FE9C6,x
	STA.w SMW_CopyOfPaletteMirror[$01].LowByte,x
	LDA.l DATA_5FE9E2,x
	STA.w SMW_CopyOfPaletteMirror[$11].LowByte,x
	DEX
	DEX
	BNE.b CODE_068605
CODE_068621:
	LDA.w #$3040
	STA.w SMW_CopyOfPaletteMirror[$00].LowByte
	STZ.w SMW_CopyOfPaletteMirror[$21].LowByte
	LDY.b #$03
	STY.w !RAM_SMW_Palettes_PaletteUploadTableIndex
	RTS

HandleWallCollision:
;$068622
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_IntroAnimationState
	BNE.b CODE_068631
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState04_Unknown
	BEQ.b CODE_068631
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState03_WiggleDefense
	BPL.b CODE_06866D
CODE_068631:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	AND.w #$000C
	BEQ.b CODE_06866D
	CMP.w #$000C
	BEQ.b CODE_06866D
	AND.w #$0008
	LSR
	LSR
	DEC
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	SEC
	SBC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPixelsMovedLo
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InAirXSpeed
	EOR.w #$FFFF
	INC
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InAirXSpeed
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	EOR.w #$FFFF
	INC
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxXSpeed
	EOR.w #$FFFF
	INC
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxXSpeed
CODE_06866D:
	RTS

HandleDeathAnimation:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo+$01
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_SmallestSizeBeforeDeath>>8
	BCS.b CODE_0686C0
	;LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpawnedFromBoxFlag
	;BNE.b CODE_068683
	;LDY.w !RAM_YI_Player_DisableStarTimerFlag
	;BNE.b CODE_068683
	;JSL.l CODE_02A982
;CODE_068683:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	AND.w #$0001
	BEQ.b CODE_0686C0
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState09_DeadInit
	BEQ.b CODE_0686C0
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0A_DeadShrinking
	BEQ.b CODE_0686C0
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0B_WaitBeforeExploding
	BEQ.b CODE_0686C0
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XAcceleration
	LDA.w #$0040
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	LDA.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0A_DeadShrinking
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpawnedFromBoxFlag
	BNE.b CODE_0686C0
	DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	SEP.b #$20
	JSL.l $03A6C8|!bank													; Kill off all non-boss sprites.

	LDY.b #!Define_SMW_MaxNormalSpriteSlot
-:
	LDA.w !RAM_SMW_NorSpr_SpriteID,y
	CMP.b #!Define_SMW_SpriteID_NorSpr035_Yoshi
	BNE.b +
	LDA.b #!Define_SMW_NorSprStatus08_Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #$00
	STA.w !RAM_SMW_NorSpr_SpinJumpKillTimer,y
+:
	DEY
	BPL.b -
	REP.b #$20
	LDY.b #$FF
	STY.w !RAM_SMW_IO_MusicCh1
CODE_0686C0:
	RTS

SpawnEmergencyLemonDrop:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpawnedFromBoxFlag
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_IntroAnimationState
	BNE.b CODE_06871D
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0E_Inactive
	BEQ.b CODE_06871D
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState09_DeadInit
	BPL.b CODE_06871D
	LDX.b #!Define_SMW_NorSprXXX_LemonDrop
	LDY.b #!Define_SMW_NorSprXXX_LemonDrop+$01
	JSR.w CheckForSpecificNormalSprites
	BNE.b CODE_06871D
if !Define_SMW_NorSprXXX_SalvoTheSlime_YoshiPlayerPatchInstalled == 1
	LDA.w !FREERAM2														;\ If Yoshi has any eggs, return
	BNE.b CODE_06871D														;/
	LDX.b #!EggSprite_
	LDY.b #!EggSprite_+$01
	JSR.w CheckForSpecificNormalSprites
	BNE.b CODE_06871D
endif
	JSR.w SpawnLemonDrops
	SEP.b #$20
	LDA.b #$00
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,y
	STA.w !RAM_SMW_NorSpr_XSpeed,y
	STA.w !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #!Define_SMW_NorSprStatus08_Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.w !RAM_SMW_Misc_RandomByte1
	AND.b #$E0
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialXPos
	STA.w !RAM_SMW_NorSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialXPos+$01
	STA.w !RAM_SMW_NorSpr_XPosHi,y
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialYPos
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialYPos+$01
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	LDA.b #$07																			;\ Set the new sprite to display the hang from ceiling frame.
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame,y							;/
	REP.b #$20
CODE_06871D:
	RTS

CheckForSpecificNormalSprites:
	STX.b !RAM_SMW_Misc_ScratchRAM0C
	STY.b !RAM_SMW_Misc_ScratchRAM0E
	STZ.b !RAM_SMW_Misc_ScratchRAM0A
	LDX.b #!Define_SMW_MaxNormalSpriteSlot
-:
	LDY.w !RAM_SMW_NorSpr_CurrentStatus,x
	CPY.b #!Define_SMW_NorSprStatus08_Normal
	BNE.b +
	LDA.l !RAM_SMW_PIXI_NorSpr_SprExtraBits,x
	AND.w #$0008
	BEQ.b +
	LDA.l !RAM_SMW_PIXI_NorSpr_CustomSpriteID,x
	TAY
	CPY.b !RAM_SMW_Misc_ScratchRAM0C
	BCC.b +
	CPY.b !RAM_SMW_Misc_ScratchRAM0E
	BCS.b +
	INC.b !RAM_SMW_Misc_ScratchRAM0A
+:
	DEX
	BPL.b -
	LDY.b !RAM_SMW_Misc_ScratchRAM0A
	RTS

DATA_06871E:
	dw $FFFD,$FFFE

HandleCeilingAndFloorCollision:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState05_OozeFromCeiling
	BNE.b CODE_06872C
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	RTS

CODE_06872C:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed+$01
	BMI.b CODE_068747
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_FloorYPosLo
	BMI.b CODE_068747
	CMP.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	BPL.b CODE_068747
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	ORA.w #$0001
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
CODE_068747:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BounceOffCeilingFlag
	BNE.b CODE_06877D
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	LDY.b #$00
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	BPL.b CODE_068755
	INY
	INY
CODE_068755:
	LDA.w DATA_06871E,y
	AND.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	AND.w #$0003
	BEQ.b CODE_068796
	AND.w #$0002
	BEQ.b CODE_06878A
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TopOfSalvosHeadYPos
	SEC
	SBC.w #$0004
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CeilingYPosLo
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	EOR.w #$FFFF
	INC
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CMP.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState06_HopAfterOozing
	BEQ.b +
	LDA.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState00_Jumping
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
+:
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YAcceleration
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BounceOffCeilingFlag
CODE_06877D:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CeilingYPosLo
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	SEC
	SBC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TopOfSalvosHeadYPos
	BRA.b CODE_068793

CODE_06878A:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	AND.w #$FFF0
	ORA.w #$0001
CODE_068793:
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
CODE_068796:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	AND.w #$0030
	LSR
	LSR
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	RTS

HandleSpriteCollision:
;$0687A5
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SlotOfSpriteBeingCollidedWith
	BMI.b CODE_0687E8
	LDX.w !RAM_SMW_NorSpr_CurrentStatus,y
	CPX.b #!Define_SMW_NorSprStatus08_Normal
	BCC.b CODE_0687E8
	CPY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SlotIndexOfSpriteBeingTouched
	BEQ.b CODE_0687C5
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SlotIndexOfSpriteBeingTouched
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LemonDropSpawnFrameCounter
CODE_0687C5:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo
	CMP.w #!Define_SMW_NorSprXXX_SalvoTheSlime_SmallestSizeBeforeDeath
	BCC.b CODE_0687E3
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CMP.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState03_WiggleDefense
	BEQ.b CODE_0687E3
	CMP.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState09_DeadInit
	BEQ.b CODE_0687E3
	CMP.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0A_DeadShrinking
	BEQ.b CODE_0687E3
	CMP.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0B_WaitBeforeExploding
	BNE.b SpawnLemonDropsWhenHurt
CODE_0687E3:
	SEP.b #$20
	LDA.b #!Define_SMW_NorSprStatus04_SpinJumpKill
	STA.w !RAM_SMW_NorSpr_CurrentStatus,y
	LDA.b #$1F
	STA.w !RAM_SMW_NorSpr_SpinJumpKillTimer,y
	LDA.b #!Define_SMW_Sound1DF9_SpinJumpKill
	STA.w !RAM_SMW_IO_SoundCh1
	JSL.l $07FC3B|!bank										; Spawn spin jump stars routine.
	REP.b #$20
CODE_0687E8:
	LDY.b #$FF
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SlotIndexOfSpriteBeingTouched
	RTS

SpawnLemonDropsWhenHurt:
	LDA.w #$0020
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashTimer
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeSpawningLemonDropTimer
	BNE.b CODE_0687E8
	SEP.b #$20
	LDA.w !RAM_SMW_NorSpr_XPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.w !RAM_SMW_NorSpr_YPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_YPosHi,y
	STA.b !RAM_SMW_Misc_ScratchRAM03
	LDA.b #!Define_SMW_Sound1DF9_Swim
	STA.w !RAM_SMW_IO_SoundCh1
	REP.b #$20
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LemonDropSpawnFrameCounter
	AND.w #$0003
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpawnedFromBoxFlag
	BNE.b CODE_06886C
	LDX.b #!Define_SMW_NorSprXXX_LemonDrop
	LDY.b #!Define_SMW_NorSprXXX_LemonDrop+$01
	JSR.w CheckForSpecificNormalSprites
if !sa1 == 1
	CPY.b #$06
else
	CPY.b #$02
endif
	BPL.b CODE_06886C
	JSR.w SpawnLemonDrops
	BRA.b CODE_068879

CODE_06886C:
	LDA.w !RAM_SMW_Misc_RandomByte1
	AND.w #$000E
	TAY
	LDA.w DATA_068BFB,y
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_Misc_RandomByte2
	AND.w #$0006
	TAY
	LDA.w DATA_068C03,y
	STA.b !RAM_SMW_Misc_ScratchRAM06
	JSR.w SpawnSlimeBalls
CODE_068879:
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LemonDropSpawnFrameCounter
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TookDamageFlag
	BNE.b CODE_0688E3
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TookDamageFlag
	LDY.b #$02
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState02_Chase
	BNE.b CODE_0688CF
	LDA.w #$0003
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MovementCounter
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XAcceleration
CODE_0688CF:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	EOR.w #$FFFF
	INC
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxXSpeed
	EOR.w #$FFFF
	INC
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxXSpeed
CODE_0688E3:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_DamageTaken
	CMP.w #!Define_SMW_NorSprXXX_SalvoTheSlime_SmallestSizeBeforeDeath
	BCS.b CODE_0688F2
	LDA.w #!Define_SMW_NorSprXXX_SalvoTheSlime_SmallestSizeBeforeDeath-$01
CODE_0688F2:
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo
	LDY.b #$02
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	CMP.w #$0040
	BPL.b CODE_068900
	LDY.b #$01
CODE_068900:
	TYA
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeSpawningLemonDropTimer
CODE_068904:
	RTS

DATA_068905:
	dw $0080,$FF80

HandlePlayerCollision:
;$068909
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM601A
	BEQ.b CODE_068904
	LDY.b #$00
	STY.w !RAM_SMW_Player_SpinJumpFlag
if !Define_SMW_NorSprXXX_SalvoTheSlime_YoshiPlayerPatchInstalled == 1
	STY.w !FREERAM31															; Cancel Yoshi's ground pound
endif
	BIT.w #$0001
	BEQ.b CODE_06891B
	BIT.w #$000E
	BEQ.b CODE_068953
CODE_06891B:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HorizontalDirectionRelativeToMario
	LDA.w DATA_068905,y
	SEC
	SBC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XDistanceFromMario
	CMP.w #$8000
	ROR
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState09_DeadInit
	BEQ.b CODE_068953
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0A_DeadShrinking
	BEQ.b CODE_068953
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0B_WaitBeforeExploding
	BEQ.b CODE_068953
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_16BitPlayerXSpeed
	PHA
	CLC
	ADC.w #$0400
	CMP.w #$0800
	BCS.b CODE_068952
	PLA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_16BitPlayerXSpeed
	BRA.b CODE_068953

CODE_068952:
	PLA
CODE_068953:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM601A
	BIT.w #$0001
	BEQ.b CODE_068964
	LDY.b !RAM_SMW_Player_YSpeed
	BMI.b CODE_068964
	TYA
	LSR
	TAY
	STY.b !RAM_SMW_Player_YSpeed
CODE_068964:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalDirectionRelativeToMario
	LDA.w DATA_068905,y
	SEC
	SBC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YDistanceFromMario
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Player_YSpeed
	AND.w #$00FF
	XBA
	BPL.b +
	ORA.w #$FF00
+:
	XBA
	PHA
	CLC
	ADC.w #$0020
	CMP.w #$0040
	BCS.b CODE_068997
	PLA
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.w #$0080
	CMP.w #$8000
	ROR
	CMP.w #$8000
	ROR
	TAY
	STY.b !RAM_SMW_Player_YSpeed
	BPL.b CODE_068998
	LDY.b #$0B
	STY.b !RAM_SMW_Player_InAirFlag
if !Define_SMW_NorSprXXX_SalvoTheSlime_YoshiPlayerPatchInstalled == 1
	LDY.b #$01													;\ Make Yoshi get a boosted flutter jump.
	STY.w !FREERAM8											;/
endif
	RTS

CODE_068997:
	PLA
CODE_068998:
	RTS

MainState00_Jumping:
MainState04_Unknown:
MainState06_HopAfterOozing:
	JSR.w UpdatePosition
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
	BEQ.b CODE_0689AC
	BMI.b CODE_0689A9
	DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
	BRA.b CODE_0689AC

CODE_0689A9:
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
CODE_0689AC:
	RTS

DATA_0689AD:
	dw $0100,$FF00

MainState01_Unknown:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_IntroAnimationState
	BNE.b CODE_0689D8
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	BEQ.b CODE_0689E5
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo+$01
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_SmallestSizeBeforeDeath>>8
	BCC.b CODE_0689D8
	BIT.w #$0001
	BNE.b CODE_0689D9
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XAcceleration
	LDA.w #$0002
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaveDirection
	LDY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState03_WiggleDefense
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
CODE_0689D8:
	RTS

CODE_0689D9:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	AND.w #$0002
	TAY
	LDA.w DATA_0689AD,y
	BRA.b CODE_068A1E

CODE_0689E5:
if !sa1 == 1
	LDA.w #$00C0
else
	LDA.w #$0060
endif
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HorizontalDirectionRelativeToMario
	BNE.b CODE_0689F1
	EOR.w #$FFFF
	INC
CODE_0689F1:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XDistanceFromMario
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	AND.w #$000C
	BEQ.b CODE_068A10
	SEC
	SBC.w #$0006
	EOR.b !RAM_SMW_Misc_ScratchRAM02
	BMI.b CODE_068A10
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	EOR.w #$FFFF
	INC
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_068A10:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TookDamageFlag
	BEQ.b CODE_068A1E
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TookDamageFlag
	EOR.w #$FFFF
	INC
CODE_068A1E:
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo+$01
	TYA
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w #$0200
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	%CalculateSigned16By16BitWholeNumberMultiplication()							;|
if !sa1 == 1
else
	ASL
endif
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxXSpeed
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	BEQ.b CODE_068A4F
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	LDY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState04_Unknown
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	BRA.b CODE_068A7D

CODE_068A4F:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XDistanceFromMario
	CLC
	ADC.w #$0080
	CMP.w #$0100
	BCS.b CODE_068A7B
	LDA.w !RAM_SMW_Misc_RandomByte1
	BIT.w #$0003
	BEQ.b CODE_068A7B
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MovementCounter
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
	LDA.w #$0010
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XAcceleration
	LDA.w #$0100
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxVerticalScale
	LDY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState02_Chase
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	RTS

CODE_068A7B:
	LDA.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState00_Jumping
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
CODE_068A7D:
	LDA.w #$0400
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxVerticalScale
	LDA.w #$FCE0
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InverseOfMinVerticalScaling
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxXSpeed
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InAirXSpeed
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XAcceleration
	RTS

MainState02_Chase:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxVerticalScale
	CMP.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	BNE.b CODE_068AA7
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxXSpeed
	BMI.b CODE_068AAC
CODE_068AA2:
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
	BRA.b CODE_068AAF

CODE_068AA7:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxXSpeed
	BMI.b CODE_068AA2
CODE_068AAC:
	DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
CODE_068AAF:
	JSR.w CODE_06914C
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo+$01
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_SmallestSizeBeforeDeath>>8
	BCC.b CODE_068AF9
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SlotOfSpriteBeingCollidedWith
	BMI.b CODE_068AF9
	LDA.w !RAM_SMW_NorSpr_XSpeed,y
	AND.w #$00FF
	LDX.w !RAM_SMW_NorSpr_XSpeed,y
	BPL.b +
	ORA.w #$0F00
+:
	ASL
	ASL
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteHitboxXPosLo
	SEC
	SBC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenXPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	CLC
	ADC.w #$0080
	CMP.w #$0100
	BCS.b CODE_068AF9
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	EOR.b !RAM_SMW_Misc_ScratchRAM02
	BPL.b CODE_068AF9
	LDA.w #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState01_Unknown
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	BMI.b CODE_068AF9
	LDA.w #$0003
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	RTS

CODE_068AF9:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	BIT.w #$000C
	BEQ.b CODE_068B07
	LDA.w #$0003
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MovementCounter
CODE_068B07:
	RTS

MainState03_WiggleDefense:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaveDirection
	BNE.b CODE_068B22
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
	BMI.b CODE_068B17
	DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
	RTS

CODE_068B17:
	LDY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState01_Unknown
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	RTS

CODE_068B22:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaveDirection
	BIT.w #$0001
	BNE.b CODE_068B3B
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveFrequency
	CLC
	ADC.w #$0040
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveFrequency
	CMP.w #$0800
	BNE.b CODE_068B4D
	BRA.b CODE_068B4A

CODE_068B3B:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveFrequency
	SEC
	SBC.w #$0040
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveFrequency
	CMP.w #$0100
	BNE.b CODE_068B4D
CODE_068B4A:
	DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaveDirection
CODE_068B4D:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
	CMP.w #$0008
	BCS.b CODE_068B58
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
CODE_068B58:
	RTS

MainState05_OozeFromCeiling:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteIndexOfPositionControllerSprite
	SEP.b #$20
	LDA.w !RAM_SMW_NorSpr_YPosHi,y
	XBA
	LDA.w !RAM_SMW_NorSpr_YPosLo,y
	REP.b #$20
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM00
	CMP.w #$004A
	BMI.b CODE_068B90
	CMP.w #$004E
	BPL.b CODE_068B7C
	LDA.w #$0018
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YAcceleration
	LDA.w #$0080
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxYSpeed
	BRA.b CODE_068B90

CODE_068B7C:
	LDA.w #$000C
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YAcceleration
	LDA.w #$0400
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxYSpeed
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteIndexOfPositionControllerSprite
	LDA.w #$0001
	STA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_CurrentState,y
	SEP.b #$20
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	SEC
	SBC.b #$38
	STA.w !RAM_SMW_NorSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosHi
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,y
	REP.b #$20
CODE_068B90:
	JSR.w UpdatePosition
	RTS

MainState07_Grow:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	BNE.b CODE_068BAC
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo
	CLC
	ADC.w #$0240
	BMI.b CODE_068BA6
	LDA.w #$FFFF
CODE_068BA6:
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo
	JSR.w UpdatePosition
CODE_068BAC:
	RTS

MainState08_WaitAfterGrowing:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	BNE.b CODE_068BBD
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_IntroAnimationState
	STZ.w !RAM_SMW_Player_FreezePlayerFlag
	LDY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState01_Unknown
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
CODE_068BBD:
	RTS

DATA_068BBE:
	dw $0001,$0002

DATA_068BC2:
	dw $0100,$FF00

MainState09_DeadInit:
	LDY.b #$00
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XDistanceFromMario
	CLC
	ADC.w #$0050
	CMP.w #$00A0
	BCS.b CODE_068BDB
	STZ.b !RAM_SMW_IO_ControllerHold1
	INC.w !RAM_SMW_Player_FreezePlayerFlag
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	RTS

CODE_068BDB:
	BPL.b CODE_068BDF
	INY
	INY
CODE_068BDF:
	LDA.w DATA_068BBE,y
	STA.b !RAM_SMW_IO_ControllerHold1
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_16BitPlayerXSpeed
	SEC
	SBC.w DATA_068BC2,y
	EOR.w DATA_068BC2,y
	BMI.b CODE_068BFA
	LDA.w DATA_068BC2,y
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_16BitPlayerXSpeed
CODE_068BFA:
	RTS

DATA_068BFB:
	dw $0008,$0010,$0020,$0040

DATA_068C03:
	dw $FFF8,$FFF0,$FFE0,$FFC0

MainState0A_DeadShrinking:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	BNE.b CODE_068C72
	LDA.w #$0002
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	LDA.w !RAM_SMW_Misc_RandomByte1
	AND.w #$000E
	TAY
	LDA.w DATA_068BFB,y
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.w !RAM_SMW_Misc_RandomByte2
	AND.w #$0006
	TAY
	LDA.w DATA_068C03,y
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.w !RAM_SMW_Misc_RandomByte1
	AND.w #$000F
	SEC
	SBC.w #$0008
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	SEC
	SBC.w #$0004
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDY.b #!Define_SMW_Sound1DF9_Swim
	STY.w !RAM_SMW_IO_SoundCh1
	JSR.w SpawnSlimeBalls
CODE_068C72:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo
	SEC
	SBC.w #$0020
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo
	CMP.w #$2000
	BCS.b CODE_068C89
	LDA.w #$0040
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
CODE_068C89:
	RTS

MainState0B_WaitBeforeExploding:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	BNE.b CODE_068C89
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeExplodingState
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeExplodingState
	CPY.b #$01
	BEQ.b CODE_068CBF
	CPY.b #$02
	BEQ.b CODE_068CA6
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	RTS

CODE_068CA6:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	SEC
	SBC.w #$0010
	STA.b !RAM_SMW_Misc_ScratchRAM02
	;JSL.l CODE_02E1A3
	LDA.w #$00C0
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	RTS

CODE_068CBF:
	LDX.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteIndexOfPositionControllerSprite
	SEP.b #$20
	LDA.b #!Define_SMW_NorSprStatus04_SpinJumpKill
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b #$1F
	STA.w !RAM_SMW_NorSpr_SpinJumpKillTimer,x
	LDA.b #!Define_SMW_Sound1DF9_SpinJumpKill
	STA.w !RAM_SMW_IO_SoundCh1
	JSL.l $07FC3B|!bank										; Spawn spin jump stars routine.
	REP.b #$20
	JSR.w InitializePolygonalLayerHDMA
	;REP.b #$10
	;JSL.l YI_SetupDMATransferToWRAM_FixedSize	: dl !RAM_YI_Global_HDMABuffer01,!EXRAM_YI_Global_HDMADoubleBuffer01 : dw $0348
	;SEP.b #$10
	;LDX.b !MEXRAM_YI_Level_NorSpr_CurrentlyProcessedSpriteLo-$7960
	LDA.w #$0002	
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpawnedFromBoxFlag
	BEQ.b CODE_068D64
	RTS
	;LDA.w #!Define_YI_NorSpr027_Key
	;JSL.l YI_NormalSpriteSpawningRoutines_SpawnInInitState
	;LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteIndexOfPositionControllerSprite
	;TAX
	;LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	;STA.w !RAM_SMW_NorSpr_XPosLo,y
	;LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	;STA.w !RAM_SMW_NorSpr_YPosLo,y
	;LDA.w #$FB00
	;STA.w !MEXRAM_YI_Level_NorSpr_YSpeedLo,y
	;LDA.w #$0001
	;STA.w !MEXRAM_YI_Level_NorSpr_CollisionState,y
	;LDA.w $1092
	;STA.w !MEXRAM_YI_Level_NorSpr_GenericTable701900,y
	;LDA.w $1094
	;STA.w !MEXRAM_YI_Level_NorSpr_GenericTable701902,y
	;LDA.w #$0215
	;STA.w !RAM_SMW_Mirror_MainScreenLayers
	;LDX.b !MEXRAM_YI_Level_NorSpr_CurrentlyProcessedSpriteLo-$7960
	;PLA
	;JML.l CODE_03A32E

CODE_068D64:
	SEP.b #$20
	STZ.w !RAM_SMW_Player_FreezePlayerFlag
	INC.w !RAM_SMW_Misc_CurrentlyActiveBossEndCutscene
	DEC.w !RAM_SMW_Timer_EndLevel
	LDA.b #!Define_SMW_NorSprXXX_SalvoTheSlime_BossClearMusic
	STA.w !RAM_SMW_IO_MusicCh1
	REP.b #$20
	LDY.b #$00																;\ Prevent the fade out from corrupting the palette.
	STY.w !RAM_SMW_Palettes_PaletteUploadTableIndex					;/
	LDY.b #$3E																;\ Restore the palette for the fade-out effect.
-:																			;|
	LDA.w !RAM_SMW_Palettes_PaletteMirror,y							;|
	STA.w !RAM_SMW_Palettes_CopyOfPaletteMirror,y						;|
	DEY																		;|
	DEY																		;|
	BPL.b -																;/
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	RTS

MainState0C_ChangeFromBoxToSlime:
	;LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	;BNE.b CODE_068D7F
	;DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InverseOfMinVerticalScaling
	;BEQ.b CODE_068D7A
	;LDA.w #$0008
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	;JSR.w HandleBoxToSlimePaletteFade
	;RTS

;CODE_068D7A:
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BoxToBlobTransitionIndex
	;INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
;CODE_068D7F:
	RTS

;DATA_068D80:
	;dw $B200,$B20A,$B30F,$B412,$B517,$B71B,$BA21,$BF28
	;dw $C52F,$C932,$CC33,$CF35,$D438,$D838,$DB39,$DC3A
	;dw $E03A,$E13B,$E83B,$EA3A,$EC39,$EF38,$F136,$F531
	;dw $F72D,$FA27,$FB25,$FC1F,$FE19,$FF15,$FF0E,$000E
	;dw $0000,$00F1,$FFF1,$FFEB,$FEE7,$FCE0,$FBDB,$FAD9
	;dw $F7D3,$F5CF,$F1CA,$EFC8,$ECC7,$EAC6,$E8C5,$E1C5
	;dw $E0C6,$DCC6,$DBC7,$D8C8,$D4C8,$CFCB,$CCCD,$C9CE
	;dw $C5D2,$BFD8,$BADF,$B7E5,$B5E9,$B4EE,$B3F1,$B2F6

;DATA_068E00:
	;dw $C100,$C106,$C10C,$C112,$C118,$C11E,$C124,$C12A
	;dw $C12F,$C52F,$C92F,$CD2F,$D12F,$D52F,$D92F,$DD2F
	;dw $E12F,$E52F,$E92F,$ED2F,$F12F,$F52F,$F92F,$FD2F
	;dw $002F,$002A,$0024,$001E,$0018,$0012,$000C,$0006
	;dw $0000,$00FA,$00F4,$00EE,$00E8,$00E2,$00DC,$00D6
	;dw $00D0,$FDD0,$F9D0,$F5D0,$F1D0,$EDD0,$E9D0,$E5D0
	;dw $E1D0,$DDD0,$D9D0,$D5D0,$D1D0,$CDD0,$C9D0,$C5D0
	;dw $C1D0,$C1D6,$C1DC,$C1E2,$C1E8,$C1EE,$C1F4,$C1FA

MainState0D_MorphFromBoxToSlime:
	RTS
	;LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BoxToBlobTransitionIndex
	;BEQ.b CODE_068E89
	;JMP.w CODE_068F82

;CODE_068E89:
	;PHA
	;LDA.w #$0000
	;JSL.l CODE_0681A6
	;LDA.b !RAM_SMW_Misc_ScratchRAM04
	;LDX.b #$00
;CODE_068E95:
	;STA.w !RAM_YI_NorSpr02D_SalvoTheSlime_ClearedBoxTilemap,x
	;INX
	;INX
	;CPX.b #$20
	;BNE.b CODE_068E95
	;LDA.w !RAM_YI_NorSpr02D_SalvoTheSlime_BoxFadeVRAMAddress
	;STA.b !RAM_SMW_Misc_ScratchRAM00
	;LDA.w #$0008
	;STA.b !RAM_SMW_Misc_ScratchRAM02
	;PHB
	;SEP.b #$20
	;LDA.b #!RAM_YI_Global_VRAMDMATransferTable_FinalIndexLo>>16
	;PHA
	;PLB
	;REP.b #$30
	;LDX.w #!RAM_YI_Global_VRAMDMATransferTable_FinalIndexLo
	;INX
	;INX
;CODE_068EB6:
	;LDA.b !RAM_SMW_Misc_ScratchRAM00
	;STA.w $0000,x
	;LDA.w #$0180
	;STA.w $0002,x
	;LDA.w #!REGISTER_WriteToVRAMPortLo&$0000FF
	;STA.w $0004,x
	;LDA.w #$001096
	;STA.w $0005,x
	;LDA.w #$001096>>16
	;STA.w $0007,x
	;LDA.w #$0018
	;STA.w $0008,x
	;TXA
	;CLC
	;ADC.w #$000C
	;STA.w $000A,x
	;TAX
	;DEC.b !RAM_SMW_Misc_ScratchRAM02
	;BEQ.b CODE_068EF0
	;LDA.b !RAM_SMW_Misc_ScratchRAM00
	;CLC
	;ADC.w #$0020
	;STA.b !RAM_SMW_Misc_ScratchRAM00
	;BRA.b CODE_068EB6

;CODE_068EF0:
	;TXA
	;STA.w !RAM_YI_Global_VRAMDMATransferTable_FinalIndexLo
	;PLB
	;LDX.b !MEXRAM_YI_Level_NorSpr_CurrentlyProcessedSpriteLo-$7960
	;LDA.w #$0004
	;STA.b !RAM_SMW_Misc_ScratchRAM0A
	;LDA.w !RAM_YI_NorSpr02D_SalvoTheSlime_BoxFadeVRAMAddress
	;SEC
	;SBC.w #$6800
	;STA.b !RAM_SMW_Misc_ScratchRAM00
	;STA.b !RAM_SMW_Misc_ScratchRAM08
	;LDA.w !MEXRAM_YI_Level_NorSpr_OnScreenYPosLo,x
	;SEC
	;SBC.w #$0040
;CODE_068F0E:
	;STA.b !RAM_SMW_Misc_ScratchRAM0E
	;CMP.w #$0100
	;BCS.b CODE_068F47
	;LDY.w #$0006
	;LDX.b !MEXRAM_YI_Level_NorSpr_CurrentlyProcessedSpriteLo-$7960
	;LDA.w !MEXRAM_YI_Level_NorSpr_OnScreenXPosLo,x
	;SEC
	;SBC.w #$0028
;CODE_068F21:
	;STA.b !RAM_SMW_Misc_ScratchRAM0C
	;CMP.w #$0130
	;BCS.b CODE_068F3A
	;LDA.b !RAM_SMW_Misc_ScratchRAM00
	;BIT.w #$0400
	;BEQ.b CODE_068F32
	;EOR.w #$0420
;CODE_068F32:
	;TAX
	;LDA.w #$0000
	;STA.l !EXRAM_YI_Level_CurrentlyLoadedMap16,x
;CODE_068F3A:
	;LDA.b !RAM_SMW_Misc_ScratchRAM0C
	;CLC
	;ADC.w #$0010
	;INC.b !RAM_SMW_Misc_ScratchRAM00
	;INC.b !RAM_SMW_Misc_ScratchRAM00
	;DEY
	;BNE.b CODE_068F21
;CODE_068F47:
	;LDA.b !RAM_SMW_Misc_ScratchRAM08
	;CLC
	;ADC.w #$0040
	;STA.b !RAM_SMW_Misc_ScratchRAM00
	;STA.b !RAM_SMW_Misc_ScratchRAM08
	;LDA.b !RAM_SMW_Misc_ScratchRAM0E
	;CLC
	;ADC.w #$0010
	;DEC.b !RAM_SMW_Misc_ScratchRAM0A
	;BNE.b CODE_068F0E
	;LDA.w #$0004
	;STA.b !RAM_SMW_Misc_ScratchRAM00
	;LDX.w !RAM_YI_NorSpr02D_SalvoTheSlime_BoxLevelDataIndex
;CODE_068F63:
	;PHX
	;LDY.w #$0006
;CODE_068F67:
	;LDA.w #$0000
	;STA.l !RAM_YI_Level_LevelDataBuffer,x
	;INX
	;INX
	;DEY
	;BNE.b CODE_068F67
	;PLA
	;CLC
	;ADC.w #$0020
	;TAX
	;DEC.b !RAM_SMW_Misc_ScratchRAM00
	;BNE.b CODE_068F63
	;SEP.b #$10
	;LDX.b !MEXRAM_YI_Level_NorSpr_CurrentlyProcessedSpriteLo-$7960
	;PLA
;CODE_068F82:
	;CMP.w #$0100
	;BMI.b CODE_068FF0
	;LDA.w #$0010
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YAcceleration
	;LDA.w #$0400
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxYSpeed
	;INC.w !RAM_YI_NorSpr02D_SalvoTheSlime_TouchedBoxFlag
	;LDA.w #$00A0
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScaling
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxVerticalScale
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TouchedCeilingFlag
	;LDY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState01_Unknown
	;STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InverseOfMinVerticalScaling
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnGroundFlag
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveOffset
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
	;LDA.w #$0100
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveFrequency
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MovementCounter
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TookDamageFlag
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	;LDA.w #$E000
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashTimer
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScalingOfCeilingOoze
	;LDA.w #$FFFF
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_FloorYPosLo
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TopOfSalvosHeadYPos
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BounceOffCeilingFlag
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_IntroAnimationState
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeExplodingState
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialYPos
	;STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BoxToBlobTransitionIndex
	;JMP.w SpawnEyes

;CODE_068FF0:
	;LDA.w #DATA_068E00
	;STA.w !REGISTER_SuperFX_R1_PLOTXCoordinateLo
	;LDA.w #DATA_068D80
	;STA.w !REGISTER_SuperFX_R2_PLOTYCoordinateLo
	;LDA.w #DATA_068D80>>16
	;STA.w !REGISTER_SuperFX_R0_DefaultSourceOrDestinationLo
	;LDA.w #$0040
	;STA.w !REGISTER_SuperFX_R3_GeneralPurposeLo
	;LDA.w #$0021
	;STA.w !REGISTER_SuperFX_R4_LMULTResultLo
	;LDA.w #$449E
	;STA.w !REGISTER_SuperFX_R5_GeneralPurpose2Lo
	;LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BoxToBlobTransitionIndex
	;STA.w !REGISTER_SuperFX_R6_MultiplierLo
	;LDA.w !MEXRAM_YI_Level_NorSpr_OnScreenXPosLo,x
	;CLC
	;ADC.w #$0008
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6040
	;LDA.w !MEXRAM_YI_Level_NorSpr_OnScreenYPosLo,x
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6042
	;LDX.b #FXCODE_08E93B>>16
	;LDA.w #FXCODE_08E93B
	;JSL.l !RAM_YI_Global_BeginSuperFXProcessingRt
	;JSL.l YI_SetupDMATransferToWRAM_FixedSize	: dl !RAM_YI_Global_HDMABuffer01,!EXRAM_YI_Global_HDMADoubleBuffer01 : dw $0348
	;LDX.b #FXCODE_0A8390>>16
	;LDA.w #FXCODE_0A8390
	;JSL.l !RAM_YI_Global_BeginSuperFXProcessingRt
	;SEP.b #$30
	;LDY.b #$10
	;LDA.b #$07
	;STY.w !RAM_SMW_Mirror_MainScreenLayers
	;STA.w !RAM_SMW_Mirror_SubScreenLayers
	;LDA.b #$02
	;STA.b !RAM_SMW_Mirror_ColorMathInitialSettings
	;LDA.b #$20
	;STA.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
	;LDA.b #$18
	;TSB.w !RAM_SMW_Global_HDMAEnable
	;REP.b #$20
	;LDA.w #$637D
	;STA.l SMW_CopyOfPaletteMirror[$01].LowByte
	;LDA.w #$4A75
	;STA.l SMW_CopyOfPaletteMirror[$02].LowByte
	;LDA.w #$0000
	;STA.l SMW_CopyOfPaletteMirror[$03].LowByte
	;LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BoxToBlobTransitionIndex
	;CLC
	;ADC.w #$0008
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BoxToBlobTransitionIndex
	;RTS

SpawnEyes:
	PHP
	SEP.b #$20
	JSL.l $02A9DE|!bank
	BMI.b CODE_0690D1
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteIndexOfPositionControllerSprite
	TYX
	LDA.b #!Define_SMW_NorSprXXX_EyesOfSalvoTheSlime
	STA.l !RAM_SMW_PIXI_NorSpr_CustomSpriteID,x
	LDA.b #!Define_SMW_NorSprStatus08_Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	STA.w !RAM_SMW_NorSpr_XPosLo,x
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosHi
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	SEC
	SBC.b #$06
	STA.w !RAM_SMW_NorSpr_YPosLo,x
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosHi
	SBC.b #$00
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSL.l $07F7D2|!bank
if read1($0187A7) == $5C
	JSL.l $0187A7|!bank
else
	error "You need to insert the Salvo Eye sprite with PIXI before inserting this UberASM code!"
endif
	LDA.b #$02
	STA.w !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_AnimationFrame,x
	LDA.b #$08
	STA.l !RAM_SMW_PIXI_NorSpr_SprExtraBits,x
	STZ.b !RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_CurrentState,x
CODE_0690D1:
	PLP
	RTS

;HandleBoxToSlimePaletteFade:
	;REP.b #$10
	;LDX.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BoxFadePaletteIndex
	;LDA.l DATA_5FA1A8,x
	;STA.l SMW_CopyOfPaletteMirror[$0C].LowByte
	;STA.l YI_Global_BackupPaletteMirror1[$0C].LowByte
	;LDA.l DATA_5FA1A8+$02,x
	;STA.l SMW_CopyOfPaletteMirror[$0D].LowByte
	;STA.l YI_Global_BackupPaletteMirror1[$0D].LowByte
	;LDA.l DATA_5FA1A8+$04,x
	;STA.l SMW_CopyOfPaletteMirror[$0E].LowByte
	;STA.l YI_Global_BackupPaletteMirror1[$0E].LowByte
	;LDA.l DATA_5FA1A8+$06,x
	;STA.l SMW_CopyOfPaletteMirror[$0F].LowByte
	;STA.l YI_Global_BackupPaletteMirror1[$0F].LowByte
	;TXA
	;CLC
	;ADC.w #$0008
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BoxFadePaletteIndex
	;SEP.b #$10
	;RTS

UpdatePosition:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BounceOffCeilingFlag
	BEQ.b CODE_06911E
	LDA.w #$0002
	BRA.b CODE_069129

CODE_06911E:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	AND.w #$0003
	BEQ.b CODE_06915A
	AND.w #$0002
CODE_069129:
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TouchedCeilingFlag
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnGroundFlag
	BNE.b CODE_06914C
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnGroundFlag
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InAirXSpeed
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	BMI.b CODE_069146
	EOR.w #$FFFF
	INC
CODE_069146:
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	JSR.w HandleBouncing
CODE_06914C:
	JSR.w HandleHorizontalStretching
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	BPL.b CODE_06916C
	EOR.w #$FFFF
	INC
	BRA.b CODE_06916C

CODE_06915A:
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TouchedCeilingFlag
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnGroundFlag
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	BPL.b CODE_06916C
	EOR.w #$FFFF
	INC
CODE_06916C:
	LSR
	LSR
	LSR
	CLC
	ADC.w #$00A0
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScaling
	RTS

HandleBouncing:
if !sa1 == 1
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w #$FF50
	%CalculateSigned16By16BitWholeNumberMultiplication()							;|
else
	SEP.b #$20
	STA.w !REGISTER_Mode7MatrixParameterA
	XBA
	STA.w !REGISTER_Mode7MatrixParameterA
	LDA.b #$A0
	STA.w !REGISTER_Mode7MatrixParameterB
	REP.b #$20
	LDA.w !REGISTER_PPUMultiplicationProductMid
	ASL
endif
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxVerticalScale
	EOR.w #$FFFF
	INC
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InverseOfMinVerticalScaling
	RTS

DATA_06919A:
	dw $00C0,$FF40

HandleHorizontalStretching:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState02_Chase
	BEQ.b CODE_0691AD
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState04_Unknown
	BNE.b CODE_0691B2
	LDA.w #$4000
	BRA.b CODE_0691DD

CODE_0691AD:
	LDA.w #$0A00
	BRA.b CODE_0691DD

CODE_0691B2:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo+$01
	TYA
	SEC
	SBC.w #$0100
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w #$D000
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag
	BEQ.b CODE_0691BD
	LDA.w #$CC00
CODE_0691BD:
	%CalculateSigned16By16BitWholeNumberMultiplication()							;|
	CLC
	ADC.w #$2000
CODE_0691DD:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	BPL.b CODE_0691E8
	EOR.w #$FFFF
	INC
CODE_0691E8:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM00
	ASL
	AND.w #$FF00
	XBA
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxVerticalScale
	CMP.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	BMI.b CODE_069237
	CMP.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	BEQ.b CODE_06922E
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState02_Chase
	BEQ.b CODE_069218
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InverseOfMinVerticalScaling
	BEQ.b CODE_069213
	SEC
	ROR
	CMP.w #$FFE0
	BCC.b CODE_069213
	LDA.w #$0000
CODE_069213:
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InverseOfMinVerticalScaling
	BRA.b CODE_069229

CODE_069218:
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MovementCounter
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MovementCounter
	CMP.w #$0004
	BNE.b CODE_069229
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XAcceleration
	DEC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	RTS

CODE_069229:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxVerticalScale
CODE_06922E:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0E
	JMP.w CODE_0692B3

CODE_069237:
	CMP.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	BEQ.b CODE_06923F
	JMP.w CODE_0692AD

CODE_06923F:
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState02_Chase
	BEQ.b CODE_06925B
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	BEQ.b CODE_06925B
	LSR
	CMP.w #$0020
	BCS.b CODE_069253
	LDA.w #$0000
CODE_069253:
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	LDA.w #$01D0
	BRA.b CODE_06925E

CODE_06925B:
	LDA.w #$0600
CODE_06925E:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	BMI.b CODE_0692A8
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_TouchedCeilingFlag
	BNE.b CODE_069284
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState07_Grow
	BEQ.b CODE_0692A8
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_IntroAnimationState
	BEQ.b CODE_06927C
	DEY
	BNE.b CODE_06927C
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_IntroAnimationState
	ASL
CODE_06927C:
	CMP.b !RAM_SMW_Misc_ScratchRAM00
	BCC.b CODE_0692A8
	EOR.w #$FFFF
	INC
CODE_069284:
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	LDY.b #!Define_SMW_Sound1DF9_FlyWithCape
	STY.w !RAM_SMW_IO_SoundCh1
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InAirXSpeed
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	STZ.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BounceOffCeilingFlag
	LDA.w #$0010
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YAcceleration
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_IntroAnimationState
	BEQ.b CODE_0692E4
	LDA.w #$00C0
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
CODE_0692A8:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InverseOfMinVerticalScaling
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MaxVerticalScale
CODE_0692AD:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	SEC
	SBC.b !RAM_SMW_Misc_ScratchRAM0E
CODE_0692B3:
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_InverseOfMinVerticalScaling
	BNE.b CODE_0692E4
	LDY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState06_HopAfterOozing
	BNE.b CODE_0692D3
	LDA.w #$FE00
	JSR.w HandleBouncing
	LDA.w #$0020
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	RTS

CODE_0692D3:
	CPY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState07_Grow
	BNE.b CODE_0692E0
	LDA.w #$0040
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer
	INC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
	RTS

CODE_0692E0:
	LDY.b #!Define_SMW_NorSprXXX_SalvoTheSlime_MainState01_Unknown
	STY.w !RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState
CODE_0692E4:
	RTS

DATA_5FA56E:
	dw $6BFF,$03FF,$03FF,$03FF,$03FF,$03FF,$03FF,$03FF
	dw $03FF,$03FF,$03FF,$03FF,$03FF,$03FF,$03FF,$03FF

DATA_5FE9C6:
	dw $43F8,$0000,$53B8,$5BDB,$67FD,$6FFF,$7FFF,$7FFF
	dw $77FF,$6BFF,$67FE,$63FD,$5FFC,$5BFA

DATA_5FE9E2:
	dw $57F9,$0000,$2525,$2D86,$31E7,$3648,$3A8C,$3ED0
	dw $4312,$4354,$4775,$4B96,$4FB7,$53D8,$57F9

SpawnSlimeBalls:
	SEP.b #$20
if !sa1 == 1
	LDY.b #$13
else
	LDY.b #$09
endif
-:
	LDA.w !RAM_SMW_ClusterSpr_SpriteID,y
	BEQ.b +
	DEY
	BPL.b -
-:
	REP.b #$20
	RTS

+:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_ClusterSpr_XPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_ClusterSpr_XPosHi,y
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_ClusterSpr_YPosLo,y
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_ClusterSpr_YPosHi,y
	LDA.b #!Define_SMW_ClusterSprXX_SlimeBall
	STA.w !RAM_SMW_ClusterSpr_SpriteID,y
if !sa1 == 1
	LDA.b #$30
else
	LDA.b #$20
endif
	STA.w !RAM_SMW_ClusterSprXX_SlimeBall_DespawnTimer,y
	LDA.b #$00
	STA.w !RAM_SMW_ClusterSprXX_SlimeBall_AnimationFrame,y
	LDA.b #$10
	STA.w !RAM_SMW_ClusterSprXX_SlimeBall_AnimationFrameCounter,y
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !RAM_SMW_ClusterSprXX_SlimeBall_XSpeed,y
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.w !RAM_SMW_ClusterSprXX_SlimeBall_YSpeed,y
	BRA.b -

SpawnLemonDrops:
	PHP
	SEP.b #$20
	JSL.l $02A9DE|!bank
	BMI.b .NoSlotsAvailable
	TYX
	LDA.b #!Define_SMW_NorSprXXX_LemonDrop
	STA.l !RAM_SMW_PIXI_NorSpr_CustomSpriteID,x
	LDA.b #!Define_SMW_NorSprStatus08_Normal
	STA.w !RAM_SMW_NorSpr_CurrentStatus,x
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.w !RAM_SMW_NorSpr_XPosLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	STA.w !RAM_SMW_NorSpr_XPosHi,x
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	STA.w !RAM_SMW_NorSpr_YPosLo,x
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_NorSpr_YPosHi,x
	JSL.l $07F7D2|!bank
if read1($0187A7) == $5C
	JSL.l $0187A7|!bank
endif
	LDA.b #$08
	STA.l !RAM_SMW_PIXI_NorSpr_SprExtraBits,x
	LDA.w !RAM_SMW_Misc_RandomByte1
	PHA
	AND.b #$1F
	SEC
	SBC.b #$10
	STA.w !RAM_SMW_NorSpr_XSpeed,x
	BPL.b .CODE_0688A1
	INC.w !RAM_SMW_NorSpr_FacingDirection,x
.CODE_0688A1:
	PLA
	XBA
	AND.b #$3F
	EOR.b #$FF
	INC
	STA.w !RAM_SMW_NorSpr_YSpeed,x
	LDA.b #$02
	STA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x
	LDA.b #$08
	STA.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x
.NoSlotsAvailable:
	PLP
	RTS

;---------------------------------------------------------------------------

ProcessSalvoHDMAAndCollision:
	REP.b #$10
	LDY.w #$0000
	LDA.w SalvoBaseShape,y
	AND.w #$00FF
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6020
	XBA
	STA.b !R7
	LDA.w #(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)
	STA.b !R9
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenYPosLo
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset
endif
	STA.b !R1
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_EyeYPositionOffset
	ASL
	TAX
	LDA.l DivisionLookupTable,x
	STA.b !R8
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6022
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenXPosLo
	CLC
	ADC.w #$0008
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6024
	CLC
	ADC.w #$0060
	CMP.w #$01C0
	BCC.b CODE_0A820E
	LDA.w #$0180
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6024
	LDX.b !R1
	JMP.w CODE_0A82FC

CODE_0A820E:
	LDA.w #!RAM_SMW_Global_Layer2YPosHDMATable1+!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount
	CLC
	ADC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BufferToUse
	TAX
	LDA.w #(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)-$01
	SEC
	SBC.b !R1
	BPL.b CODE_0A8223
	EOR.w #$FFFF
	INC
	STA.b !R0
if !sa1 == 1
	STZ.w !REGISTER_SA1_ArithmeticType
	LDA.b !R8
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo
	LDA.b !R0
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo
else
	LDA.b !R8
	SEP.b #$20
	STA.w !REGISTER_Mode7MatrixParameterA
	XBA
	STA.w !REGISTER_Mode7MatrixParameterA
	LDA.b !R0+$01
	STA.w !REGISTER_Mode7MatrixParameterB
	REP.b #$20
endif
	LDA.b !R7
	SEC
if !sa1 == 1
	SBC.w !REGISTER_SA1_ArithmeticResultLo
else
	SBC.w !REGISTER_PPUMultiplicationProductLo
endif
	STA.b !R7
	BRA.b CODE_0A8242

CODE_0A8223:
	CMP.w #(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)-$01
	BMI.b CODE_0A822D
	LDA.w #(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)-$01
CODE_0A822D:
	INC
	STA.b !R6
	TAY
	LDA.b !R9
	SEC
	SBC.b !R6
	STA.b !R9
	LDA.w #$FF1E
-:
	STA.l !RAM_SMW_Global_Layer2YPosHDMATable1&$FF0000,x
	DEX
	DEX
	INC
	DEY
	BNE.b -
	CMP.w #$0000
	BNE.b CODE_0A8242
	JMP.w CODE_0A82FC

CODE_0A8242:
	LDA.b !R9
	SEC
	SBC.b !R2
	INC
	STA.b !R6
if !sa1 == 1
else
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6004
	SEP.b #$20
	STA.w !REGISTER_Mode7MatrixParameterA
	XBA
	STA.w !REGISTER_Mode7MatrixParameterA
	REP.b #$20
endif
-:
	LDA.b !R7
	SEC
	SBC.b !R8
	BMI.b CODE_0A8270
	STA.b !R7
	AND.w #$FF00
	XBA
	TAY
if !sa1 == 1
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6004
	STZ.w !REGISTER_SA1_ArithmeticType
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo
	LDA.w SalvoBaseShape,y
	AND.w #$FF00
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo
	LDA.w !REGISTER_SA1_ArithmeticResultMid
else
	LDA.w SalvoBaseShape+$01,y
	STA.w !REGISTER_Mode7MatrixParameterB
	LDA.w !REGISTER_PPUMultiplicationProductMid
endif
	INC
	LSR
	SEC
	SBC.b !R9
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset
endif
	STA.l !RAM_SMW_Global_Layer2YPosHDMATable1&$FF0000,x
	DEX
	DEX
	DEC.b !R9
	DEC.b !R6
	BNE.b -
if !sa1 == 1
	LDA.w !REGISTER_SA1_ArithmeticResultMid
else
	LDA.w !REGISTER_PPUMultiplicationProductMid
endif
	INC
	LSR
	STA.b !R5
	LDA.b !R9
	BPL.b CODE_0A8289
	JMP.w CODE_0A82FC

CODE_0A8270:
	LDA.b !R9
	PHA
	SEC
	SBC.b !R6
	STA.b !R9
	LDY.b !R6
	PLA
	EOR.w #$FFFF
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset
endif
-:
	STA.l !RAM_SMW_Global_Layer2YPosHDMATable1&$FF0000,x
	DEX
	DEX
	INC
	DEY
	BNE.b -
	CMP.w #$0000
	BNE.b CODE_0A8286
	JMP.w CODE_0A82FC

CODE_0A8286:
	STZ.b !R5
CODE_0A8289:
	LDA.b !R2
	SEC
	SBC.b !R3
	STA.b !R0
	BPL.b CODE_0A8291
	EOR.w #$FFFF
	INC
CODE_0A8291:
	CMP.w #$0022
	BCC.b CODE_0A829F
	LDA.w #$0022
CODE_0A829F:
	CMP.b !R9
	BCC.b CODE_0A82A6
	LDA.b !R9
CODE_0A82A6:
	INC
	STA.b !R6
	TAY
	LDA.w DATA_0A866F,y
	AND.w #$00FF
	STA.b !R4
	LDA.b !R5
	SEC
	SBC.b !R4
	STA.b !R5
	DEY
	LDA.b !R0
	BPL.b CODE_0A82BF
	INY
	INY
	LDA.w #$0023
	SEC
	SBC.b !R6
	BNE.b CODE_0A82DF
	DEY
	BRA.b CODE_0A82DE

CODE_0A82BF:
-:
	LDA.w DATA_0A866F,y
	AND.w #$00FF
	DEY
	CLC
	ADC.b !R5
	BPL.b CODE_0A82C9
	LDA.w #$FFFF
CODE_0A82C9:
	SEC
	SBC.b !R9
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset
endif
	STA.l !RAM_SMW_Global_Layer2YPosHDMATable1&$FF0000,x
	DEX
	DEX
	DEC.b !R9
	DEC.b !R6
	BNE.b -
	INY
	LDA.b !R9
	BMI.b CODE_0A82FC
	LDA.w #$0023
	CMP.b !R9
	BCC.b CODE_0A82DE
	LDA.b !R9
CODE_0A82DE:
	INC
CODE_0A82DF:
	STA.b !R6
-:
	LDA.w DATA_0A866F,y
	AND.w #$00FF
	INY
	CLC
	ADC.b !R5
	BPL.b CODE_0A82E8
	LDA.w #$FFFF
CODE_0A82E8:
	SEC
	SBC.b !R9
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset
endif
	STA.l !RAM_SMW_Global_Layer2YPosHDMATable1&$FF0000,x
	DEX
	DEX
	DEC.b !R9
	DEC.b !R6
	BNE.b -
	INC.b !R9
	BMI.b CODE_0A82FC
	LDY.b !R9
-:
	INC
	STA.l !RAM_SMW_Global_Layer2YPosHDMATable1&$FF0000,x
	DEX
	DEX
	DEY
	BNE.b -
CODE_0A82FC:
if !sa1 == 1
	STZ.w !REGISTER_SA1_ArithmeticType
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_EyeYPositionOffset
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6020
	XBA
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo
	LDA.w !REGISTER_SA1_ArithmeticResultMid
else
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_EyeYPositionOffset
	SEP.b #$20
	STA.w !REGISTER_Mode7MatrixParameterA
	XBA
	STA.w !REGISTER_Mode7MatrixParameterA
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6020+$01
	STA.w !REGISTER_Mode7MatrixParameterB
	REP.b #$20
	LDA.w !REGISTER_PPUMultiplicationProductMid
endif
	STA.b !R6
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenYPosLo
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset
endif
	STA.b !R9
	ASL
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BufferToUse
	TAX
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveOffset
	XBA
	STA.b !R2
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6022
if !sa1 == 1
	STZ.w !REGISTER_SA1_ArithmeticType
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveFrequency
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo
	LDA.w !REGISTER_SA1_ArithmeticResultMidLo
	STA.b !R3
else
	;SEP.b #$20
	;STA.w !REGISTER_Mode7MatrixParameterA
	;XBA
	;STA.w !REGISTER_Mode7MatrixParameterA
	;LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveFrequency
	;STA.w !REGISTER_Mode7MatrixParameterB
	;REP.b #$20
	;LDA.w !REGISTER_PPUMultiplicationProductMid
	;STA.b !R3
endif
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude
if !sa1 == 1
	STZ.w !REGISTER_SA1_ArithmeticType
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6004
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo
	LDA.w !REGISTER_SA1_ArithmeticResultLo
	STA.b !R4
else
	;SEP.b #$20
	;STA.w !REGISTER_Mode7MatrixParameterA
	;XBA
	;STA.w !REGISTER_Mode7MatrixParameterA
	;LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6004+$01
	;STA.w !REGISTER_Mode7MatrixParameterB
	;LDA.w !REGISTER_PPUMultiplicationProductLo
	;STA.w !REGISTER_Mode7MatrixParameterA
	;LDA.w !REGISTER_PPUMultiplicationProductMid
	;STA.w !REGISTER_Mode7MatrixParameterA
	;REP.b #$20
endif
	LDA.w #$0080
	SEC
	SBC.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6024
	STA.b !R5
	LDA.b !R9
	STA.b !R7
-:
	LDA.b !R7
if !sa1 == 1
	BMI.b CODE_0A8360
	CMP.w #(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)+$01
	BCS.b CODE_0A835A
	LDA.b !R2+$01
	AND.w #$00FF
	ASL
	TAY
	STZ.w !REGISTER_SA1_ArithmeticType
	LDA.b !R4
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo
	LDA.w SineValueTable,y
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo
	LDA.w !REGISTER_SA1_ArithmeticResultMid
	;CLC
	ADC.b !R5
	STA.l !RAM_SMW_Global_Layer2XPosHDMATable1,x
	INY
	INY
CODE_0A835A:
	LDA.b !R2
	CLC
	ADC.b !R3
	STA.b !R2
else
	CMP.w #(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)+$02
	BCS.b CODE_0A8360
	LDA.b !R5
	STA.l !RAM_SMW_Global_Layer2XPosHDMATable1,x
CODE_0A835A:
endif
	DEX
	DEX
	DEC.b !R7
	DEC.b !R6
	BNE.b -
CODE_0A8360:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6004
if !sa1 == 1
	STZ.w !REGISTER_SA1_ArithmeticType
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM600E
	XBA
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo
	LDA.w !REGISTER_SA1_ArithmeticResultMid
else
	SEP.b #$20
	STA.w !REGISTER_Mode7MatrixParameterA
	XBA
	STA.w !REGISTER_Mode7MatrixParameterA
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM600E
	STA.w !REGISTER_Mode7MatrixParameterB
	REP.b #$20
	LDA.w !REGISTER_PPUMultiplicationProductMid
endif
	ADC.w #$0000
	STA.b !R2
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_EyeYPositionOffset
if !sa1 == 1
	STZ.w !REGISTER_SA1_ArithmeticType
	STA.w !REGISTER_SA1_MultiplicandOrDividendLo
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6010
	XBA
	STA.w !REGISTER_SA1_MultiplierOrDivisorLo
	LDA.w !REGISTER_SA1_ArithmeticResultMid
else
	SEP.b #$20
	STA.w !REGISTER_Mode7MatrixParameterA
	XBA
	STA.w !REGISTER_Mode7MatrixParameterA
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6010
	STA.w !REGISTER_Mode7MatrixParameterB
	REP.b #$20
	LDA.w !REGISTER_PPUMultiplicationProductMid
endif
	ADC.w #$0000
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6010
	CLC
	ADC.b !R9
	STA.b !R1
	CMP.w #(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)+$01
	LDA.w #$0000
	BCS.b CODE_0A8386
	LDA.b !R1
	ASL
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BufferToUse
	TAX
	LDA.l !RAM_SMW_Global_Layer2XPosHDMATable1,x
	SEC
	SBC.b !R5
	EOR.w #$FFFF
	INC
CODE_0A8386:
	CLC
	ADC.b !R2
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM600E
	JSR.w CheckForPolygonalObjectCollision
	SEP.b #$10
	RTS

DATA_0A85F0:
	db $02,$04,$0E,$04,$02,$14,$0E,$14,$08,$20
	db $02,$12,$0E,$12,$02,$14,$0E,$14,$08,$20

SalvoBaseShape:
	db (SalvoBaseShape_End-SalvoBaseShape)-$01
	db $00,$16,$1F,$26,$2C,$31,$36,$3A,$3D,$41,$44,$47,$4A,$4D,$4F,$52
	db $54,$56,$58,$5B,$5C,$5E,$60,$62,$63,$65,$66,$68,$69,$6B,$6C,$6D
	db $6E,$6F,$71,$72,$73,$74,$74,$75,$76,$77,$78,$78,$79,$7A,$7A,$7B
	db $7B,$7C,$7C,$7D,$7D,$7E,$7E,$7E,$7E,$7F,$7F,$7F,$7F,$7F,$7F,$7F
	db $7F,$7F,$7F,$7E,$7E,$7D,$7C,$7B,$7A,$79,$78,$76,$74,$73,$71,$6E
	db $6C,$69,$66,$63,$60,$5C,$58,$54,$4F,$4A,$44,$3D,$36,$2C,$1F,$00
.End:

DATA_0A866F:
	db $00,$00,$00,$00,$01,$02,$03,$04,$06,$08,$0A,$0C,$0E,$10,$13,$16
	db $19,$1C,$20,$24,$28,$2C,$30,$34,$39,$3E,$43,$48,$4E,$54,$5A,$60
	db $66,$6C,$73,$7A

if !sa1 == 1
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
endif

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

CheckForPolygonalObjectCollision:
	JSR.w CheckForPlayerCollision
	JSR.w CheckForSpriteCollision
	JSR.w CheckForTileCollision
	RTS

HitboxPointYOffset:
	dw $0000					; Bottom Left (Vertical)
	dw $0000					; Bottom Right (Vertical)
	dw $FFB8					; Top Left (Vertical)
	dw $FFB8					; Top Right (Vertical)
	dw $FFF0					; Bottom Left (Horizontal)
	dw $FFF0					; Bottom Right (Horizontal)
	dw $FFC8					; Top Left (Horizontal)
	dw $FFC8					; Top Right (Horizontal)

HitboxPointXOffset:
	dw $FFE0					; Bottom Left (Vertical)
	dw $0020					; Bottom Right (Vertical)
	dw $FFE0					; Top Left (Vertical)
	dw $0020					; Top Right (Vertical)
	dw $FFD0					; Bottom Left (Horizontal)
	dw $0030					; Bottom Right (Horizontal)
	dw $FFD0					; Top Left (Horizontal)
	dw $0030					; Top Right (Horizontal)

CheckForTileCollision:
	STZ.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b !RAM_SMW_Counter_GlobalFrames
	;LSR
	;BCC.b .Layer1Collision
	;INC.b !RAM_SMW_Misc_ScratchRAM0E
.Layer1Collision:
	LDY.w #$000A
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	BPL.b +
	LDY.w #$0008
+:
	JSR.w ProcessACollisionPoint
	JSR.w ProcessHorizontalBlockCollision
	BCS.b .SolidBlockHorizontallyTouched
	LDY.w #$000E
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	BPL.b +
	LDY.w #$000C
+:
	JSR.w ProcessACollisionPoint
	JSR.w ProcessHorizontalBlockCollision
.SolidBlockHorizontallyTouched:
	LDY.w #$0000
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	BPL.b +
	LDY.w #$0004
+:
	JSR.w ProcessACollisionPoint
	JSR.w ProcessVerticalBlockCollision
	BCS.b .SolidBlockVerticallyTouched
	LDY.w #$0002
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	BPL.b +
	LDY.w #$0006
+:
	JSR.w ProcessACollisionPoint
	JMP.w ProcessVerticalBlockCollision

.SolidBlockVerticallyTouched:
	RTS

ProcessACollisionPoint:
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	AND.w #$00FF
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	INC
	AND.b !RAM_SMW_Misc_ScratchRAM0C
	BEQ.b CODE_0295AE
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	CLC
	ADC.w HitboxPointYOffset,y
	AND.w #$FFF0
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Blocks_YPosLo
	LDA.b !RAM_SMW_Misc_ScreensInLvl-$01
	AND.w #$FF00
	CMP.b !RAM_SMW_Blocks_YPosLo
	BCC.b Return0295AD
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	CLC
	ADC.w HitboxPointXOffset,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Blocks_XPosLo
	CMP.w #$0200
	BCS.b Return0295AD
	SEP.b #$30
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l $00BA80|!bank,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	BEQ.b CODE_029596
	LDA.l $00BA8E|!bank,x
CODE_029596:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM05
	LDA.l $00BABC|!bank,x
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	BEQ.b CODE_0295A7
	LDA.l $00BACA|!bank,x
CODE_0295A7:
	ADC.b !RAM_SMW_Misc_ScratchRAM01
	STA.b !RAM_SMW_Misc_ScratchRAM06
	BRA.b CODE_02960D

Return0295AD:
	SEP.b #$30
	RTS

CODE_0295AE:
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo
	CLC
	ADC.w HitboxPointYOffset,y
	AND.w #$FFF0
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Blocks_YPosLo
if !LM_CustomLevelDimensionsHack == 1
	CMP.w !RAM_SMW_LM_Misc_LevelScreenSizeLo
else
	CMP.w #$0200
endif
	BCS.b Return0295AD
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo
	CLC
	ADC.w HitboxPointXOffset,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Blocks_XPosLo
	LDA.b !RAM_SMW_Misc_ScreensInLvl-$01
	AND.w #$FF00
	CMP.b !RAM_SMW_Blocks_XPosLo
	BCC.b Return0295AD
	SEP.b #$30
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	LSR
	LSR
	LSR
	LSR
	ORA.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDX.b !RAM_SMW_Misc_ScratchRAM01
if !LM_CustomLevelDimensionsHack == 1
	LDA.l !RAM_SMW_LM_Misc_8BitL1LevelScreenPosLoPtrs,x
else
	LDA.l $00BA60|!bank,x
endif
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	BEQ.b CODE_0295F8
if !LM_CustomLevelDimensionsHack == 1
	LDA.l !RAM_SMW_LM_Misc_8BitL2LevelScreenPosLoPtrs,x
else
	LDA.l $00BA70|!bank,x
endif
CODE_0295F8:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.b !RAM_SMW_Misc_ScratchRAM05
if !LM_CustomLevelDimensionsHack == 1
	LDA.l !RAM_SMW_LM_Misc_8BitL1LevelScreenPosHiPtrs,x
else
	LDA.l $00BA9C|!bank,x
endif
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	BEQ.b CODE_029609
if !LM_CustomLevelDimensionsHack == 1
	LDA.l !RAM_SMW_LM_Misc_8BitL2LevelScreenPosHiPtrs,x
else
	LDA.l $00BAAC|!bank,x
endif
CODE_029609:
	ADC.b !RAM_SMW_Misc_ScratchRAM03
	STA.b !RAM_SMW_Misc_ScratchRAM06
CODE_02960D:
	LDA.b #!RAM_SMW_Blocks_Map16TableLo>>16
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	INC.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b [!RAM_SMW_Misc_ScratchRAM05]
if !LM_CustomBlocksHack == 1
	PHK
	PEA.w .Return-1 
	PEA.w ($06F602-$01)|!bank
	JML.l $06F608|!bank
.Return:
else
	JSL.l $00F545|!bank
endif
	RTS

ProcessHorizontalBlockCollision:
	CMP.b #$00
	BEQ.b +++
	LDX.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	LDA.w SolidBlocks,x
	REP.b #$30
	BEQ.b +++
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	BPL.b +
	EOR.w #$FFFF
	INC
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed
	LDA.w #$0008
	BRA.b ++

+:
	LDA.w #$0004
++:
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	SEC
	RTS

+++:
	REP.b #$31
	LDA.w #$000C
	TRB.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	RTS

ProcessVerticalBlockCollision:
	CMP.b #$00
	BEQ.b +++
	LDX.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	LDA.w SolidBlocks,x
	REP.b #$30
	BEQ.b +++
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed
	BPL.b +
	LDA.w #$0002
	BRA.b ++

+:
	LDA.w #$0001
++:
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	SEC
	RTS

+++:
	REP.b #$31
	LDA.w #$0003
	TRB.w !RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags
	RTS

SolidBlocks:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Tiles 100 - 10F
	db $00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; Tiles 110 - 11F
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; Tiles 120 - 12F
	db $01,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; Tiles 130 - 13F
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; Tiles 140 - 14F
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; Tiles 150 - 15F
	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00	; Tiles 160 - 16F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Tiles 170 - 17F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Tiles 180 - 18F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Tiles 190 - 19F
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Tiles 1A0 - 1AF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Tiles 1B0 - 1BF
	db $00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00	; Tiles 1C0 - 1CF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Tiles 1D0 - 1DF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01	; Tiles 1E0 - 1EF
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Tiles 1F0 - 1FF

CheckForSpriteCollision:
	SEP.b #$10
	LDY.b #!sprite_slots-$01
CODE_0A83BC:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,y
	AND.w #$00FF
	SEC
	SBC.w #!Define_SMW_NorSprStatus09_Stunned
	CMP.w #(!Define_SMW_NorSprStatus0A_Kicked-!Define_SMW_NorSprStatus09_Stunned)+$01
	BCC.b +++
	CMP.w #!Define_SMW_NorSprStatus08_Normal-!Define_SMW_NorSprStatus09_Stunned
	BNE.b ++
	TYX
	LDA.l !RAM_SMW_PIXI_NorSpr_SprExtraBits,x
	AND.w #$0008
	BEQ.b ++
	LDA.l !RAM_SMW_PIXI_NorSpr_CustomSpriteID,x
	AND.w #$00FF
	CMP.w #!Define_SMW_NorSprXXX_LemonDrop
	BNE.b +
	LDA.w !RAM_SMW_NorSprXXX_LemonDrop_CurrentState,x
	AND.w #$00FF
	SEC
	SBC.w #$000B
	CMP.w #$0002
	BCC.b +++
	BRA.b ++

+:
if !Define_SMW_NorSprXXX_SalvoTheSlime_YoshiPlayerPatchInstalled == 1
	CMP.w #!EggSprite_
	BEQ.b +++
endif
++:
	JMP.w CODE_0A8400

+++:
	SEP.b #$20
	LDA.w !RAM_SMW_NorSpr_PropertyBits1662,y
	AND.b #!Define_SMW_NorSpr_1662Prop_SpriteClipping
	TAX
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.l $03B5A8|!bank,x										; Clipping Width
	LSR
	CLC
	ADC.l $03B56C|!bank,x										; Clipping X offset
	BPL.b +
	DEC.b !RAM_SMW_Misc_ScratchRAM0F
+:
	CLC
	ADC.w !RAM_SMW_NorSpr_XPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.w !RAM_SMW_NorSpr_XPosHi,y
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	STA.b !RAM_SMW_Misc_ScratchRAM01
	STZ.b !RAM_SMW_Misc_ScratchRAM0F
	LDA.l $03B620|!bank,x										; Clipping height
	LSR
	CLC
	ADC.l $03B5E4|!bank,x										; Clipping Y offset
	BPL.b +
	DEC.b !RAM_SMW_Misc_ScratchRAM0F
+:
	CLC
	ADC.w !RAM_SMW_NorSpr_YPosLo,y
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr_YPosHi,y
	ADC.b !RAM_SMW_Misc_ScratchRAM0F
	STA.b !RAM_SMW_Misc_ScratchRAM03
	REP.b #$20

	LDA.b !RAM_SMW_Misc_ScratchRAM00
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !R4
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteHitboxXPosLo
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenXPosLo
	SEC
	SBC.b !R4
	ADC.w #$0038
	CMP.w #$0070
	BCS.b CODE_0A8400
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	SEC
	SBC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset
endif
	CMP.w #(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)+$01
	BCS.b CODE_0A8400
	STA.b !R9
	ASL
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BufferToUse
	TAX
	LDA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenYPosLo
	SEC
	SBC.b !R9
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteHitboxYPosLo
	ADC.w #$0008
	CMP.w #$0068
	BCS.b CODE_0A8400
	LDA.l !RAM_SMW_Global_Layer2YPosHDMATable1,x
	;CLC
	ADC.b !R9
	CLC
	ADC.w #$0009
	AND.w #$00FF
	STA.b !R8
	LDA.w #$0080
	SEC
	SBC.l !RAM_SMW_Global_Layer2XPosHDMATable1,x
	SEC
	SBC.b !R4
	BPL.b CODE_0A83FB
	EOR.w #$FFFF
	INC
CODE_0A83FB:
	ASL
	CMP.b !R8
	BCC.b CODE_0A8412
CODE_0A8400:
	DEY
	BMI.b CODE_0A8412
	JMP.w CODE_0A83BC

CODE_0A8412:
	REP.b #$10
	TYA
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_SlotOfSpriteBeingCollidedWith
	RTS

CheckForPlayerCollision:
	LDY.w #$0000
	LDA.b !RAM_SMW_Player_DuckingFlag
	AND.w #$00FF
	BNE.b CODE_0A8509
	LDA.b !RAM_SMW_Player_CurrentPowerUp
	ORA.w !RAM_SMW_Player_RidingYoshiFlag
	AND.w #$00FF
	BNE.b CODE_0A850B
CODE_0A8509:
	TYA
	CLC
	ADC.w #$000A
	TAY
CODE_0A850B:
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	LDA.b !RAM_SMW_Player_OnScreenPosYLo
	SEC
	SBC.w #!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset
	STA.b !R2
endif
	STZ.b !R7
	LDA.w #$0005
	STA.b !R6
CODE_0A8528:
	ASL.b !R7
	LDA.w DATA_0A85F0,y
	AND.w #$00FF
	XBA
	BPL.b +
	ORA.w #$00FF
+:
	XBA
	INY
	CLC
	ADC.b !RAM_SMW_Player_OnScreenPosXLo
	STA.b !R4
	LDA.w DATA_0A85F0,y
	AND.w #$00FF
	XBA
	BPL.b +
	ORA.w #$00FF
+:
	XBA
	INY
	CLC
if !Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset != $0000
	ADC.b !R2
else
	ADC.b !RAM_SMW_Player_OnScreenPosYLo
endif
	CMP.w #(!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount/$02)+$01
	BCS.b CODE_0A8552
	STA.b !R9
	ASL
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BufferToUse
	TAX
	LDA.l !RAM_SMW_Global_Layer2YPosHDMATable1,x
	CLC
	ADC.b !R9
	CLC
	ADC.w #$0009
	AND.w #$00FF
	STA.b !R8
	LDA.w #$0080
	SEC
	SBC.l !RAM_SMW_Global_Layer2XPosHDMATable1,x
	SEC
	SBC.b !R4
	BPL.b CODE_0A854C
	EOR.w #$FFFF
	INC
CODE_0A854C:
	ASL
	CMP.b !R8
	BCS.b CODE_0A8552
	INC.b !R7														; Note: Collision established
CODE_0A8552:
	DEC.b !R6
	BNE.b CODE_0A8528
	LDA.b !R7
	STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM601A
	LSR
	BCS.b +
	RTS

+:
	STZ.b !R1
CODE_0A855E:
	DEC.b !R9
	BMI.b CODE_0A8582
	LDA.b !R1
	CLC
	ADC.w #$000A
	BMI.b CODE_0A8582
	LDA.b !R9
	ASL
	ORA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_BufferToUse
	TAX
	LDA.l !RAM_SMW_Global_Layer2YPosHDMATable1,x
	CLC
	ADC.b !R9
	CLC
	ADC.w #$0009
	AND.w #$00FF
	STA.b !R8
	LDA.w #$0080
	SEC
	SBC.l !RAM_SMW_Global_Layer2XPosHDMATable1,x
	SEC
	SBC.b !R4
	STA.b !R2
	BPL.b CODE_0A857D
	EOR.w #$FFFF
	INC
CODE_0A857D:
	ASL
	DEC.b !R1
	CMP.b !R8
	BCC.b CODE_0A855E
CODE_0A8582:
	LDA.b !R1
	;STA.w !RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM601C
CODE_0A85DF:
	RTS

;---------------------------------------------------------------------------
