
!Define_SMW_NorSprXXX_SalvoTheSlime_SmallestSizeBeforeDeath = $4C00						; The size Salvo needs to be in order to be considered dead
!Define_SMW_NorSprXXX_SalvoTheSlime_XPosHDMAChannel = $03									; The HDMA channel used for the X position of Salvo's scanlines.
!Define_SMW_NorSprXXX_SalvoTheSlime_YPosHDMAChannel = $04									; The HDMA channel used for the Y position of Salvo's scanlines.
!Define_SMW_NorSprXXX_SalvoTheSlime_ScanlineCount = $01C2									; The vertical resolution of the screen plus 1, times 2. Ex. ($E0+$01)*$02, since the screen is $E0/224 scanlines tall.
!Define_SMW_NorSprXXX_SalvoTheSlime_TopOfScreenOffset = $0000								; If you've reduced the vertical resolution by blanking out scanlines at the top of the screen, set this to a non-zero value to offset where Salvo is drawn down to the first visisble scanline.
!Define_SMW_NorSprXXX_SalvoTheSlime_FloorYPos = $FFFF										; If this is set to a positive number, Salvo will be prevented from going lower than this value. Set to $8000-$FFFF to disable this functionality.
!Define_SMW_NorSprXXX_SalvoTheSlime_DamageTaken = $0300									; How much of Salvo's body size it loses when taking damage.
!Define_SMW_NorSprXXX_SalvoTheSlime_BossMusic = $16											; The song to play when Salvo begins to ooze from the ceiling.
!Define_SMW_NorSprXXX_SalvoTheSlime_BossClearMusic = $04									; The song to play when Salvo is defeated.
!Define_SMW_NorSprXXX_SalvoTheSlime_YoshiPlayerPatchInstalled = 0							; Set this to 1 if the "Yoshi Player Patch" is installed in the ROM. This will allow Salvo to be able to detect being hit by eggs and modify some RAM addresses used by this patch.
!Define_SMW_NorSprXXX_SalvoTheSlime_LemonDropWaitsForMagic = 0								; Set this to 1 and lemon drops that act as a Salvo summoner will wait for a cutscene object (ex. Kamek from YI) to change its state to begin summoning Salvo.
!Define_SMW_NorSprXXX_SalvoTheSlime_DebugDisplay = 0										; Set this to 1 and Salvo's on screen position and collision points will be displayed on screen.

!Define_SMW_NorSprXXX_EyesOfSalvoTheSlime = $07												; The normal sprite ID of the Salvo eye sprite inserted with PIXI
!Define_SMW_NorSprXXX_LemonDrop = $08														; The normal sprite ID of the lemon drop sprite inserted with PIXI

!Define_SMW_ClusterSprXX_SlimeBall = $00													; The cluster sprite ID of the slime ball sprite inserted with PIXI

!RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset = $000AF6|!addr

!RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_CurrentState = !C2
!RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_XPosRelativeToBody = !151C
!RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YPosRelativeToBody = !1528
!RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_BlinkingTimer = !154C
!RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_BlinkingAnimationIndex = !1570
!RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_AnimationFrame = !1602
!RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_YAcceleration = !160E

!RAM_SMW_NorSprXXX_LemonDrop_CurrentState = !C2
!RAM_SMW_NorSprXXX_LemonDrop_YAcceleration = !1504
	!RAM_SMW_NorSprXXX_LemonDrop_BackupOfYPosLo = !1504
!RAM_SMW_NorSprXXX_LemonDrop_BackupOfYPosHi = !1510
!RAM_SMW_NorSprXXX_LemonDrop_BackupOfXPosLo = !151C
!RAM_SMW_NorSprXXX_LemonDrop_SpatOutBounceCounter = !1528
	!RAM_SMW_NorSprXXX_LemonDrop_BackupOfXPosHi = !1528
!RAM_SMW_NorSprXXX_LemonDrop_CurrentPhaseTimer = !1540
!RAM_SMW_NorSprXXX_LemonDrop_DisableMarioContactTimer = !154C
!RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameTimer = !1558
!RAM_SMW_NorSprXXX_LemonDrop_AnimationFrameIndex = !1570
!RAM_SMW_NorSprXXX_LemonDrop_AnimationFrame = !1602
!RAM_SMW_NorSprXXX_LemonDrop_KamekMagicDoneFlag = !187B

!RAM_SMW_ClusterSprXX_SlimeBall_DespawnTimer = $000F4A|!addr
!RAM_SMW_ClusterSprXX_SlimeBall_AnimationFrameCounter = $000F72|!addr
!RAM_SMW_ClusterSprXX_SlimeBall_AnimationFrame = $000F9A|!addr
!RAM_SMW_ClusterSprXX_SlimeBall_YSpeed = $001E52|!addr
!RAM_SMW_ClusterSprXX_SlimeBall_XSpeed = $001E66|!addr

if !sa1 == 1
!RAM_SMW_Global_Layer2YPosHDMATable1 = $418AFF
!RAM_SMW_Global_Layer2XPosHDMATable1 = $418CFF
!RAM_SMW_Global_Layer2YPosHDMATable2 = $418EFF
!RAM_SMW_Global_Layer2XPosHDMATable2 = $4190FF
else
!RAM_SMW_Global_Layer2YPosHDMATable1 = $7F8600
!RAM_SMW_Global_Layer2XPosHDMATable1 = $7F8800
!RAM_SMW_Global_Layer2YPosHDMATable2 = $7F8A00
!RAM_SMW_Global_Layer2XPosHDMATable2 = $7F8C00
endif

!RAM_SMW_NorSprXXX_SalvoTheSlime_TouchedBoxFlag = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$00
!RAM_SMW_NorSprXXX_SalvoTheSlime_DropFromCeilingFlag = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$02
!RAM_SMW_NorSprXXX_SalvoTheSlime_MinVerticalScaling = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$04
!RAM_SMW_NorSprXXX_SalvoTheSlime_InverseOfMinVerticalScaling = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$06
!RAM_SMW_NorSprXXX_SalvoTheSlime_OnGroundFlag = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$08
!RAM_SMW_NorSprXXX_SalvoTheSlime_ScalingOfCeilingOoze = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$0A
!RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveOffset = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$0C
!RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveAmplitude = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$0E
!RAM_SMW_NorSprXXX_SalvoTheSlime_WobbleWaveFrequency = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$10
!RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashTimer = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$12
!RAM_SMW_NorSprXXX_SalvoTheSlime_MovementCounter = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$14
	!RAM_SMW_NorSprXXX_SalvoTheSlime_WaveDirection = !RAM_SMW_NorSprXXX_SalvoTheSlime_MovementCounter
!RAM_SMW_NorSprXXX_SalvoTheSlime_BoxToBlobTransitionIndex = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$16
!RAM_SMW_NorSprXXX_SalvoTheSlime_BounceOffCeilingFlag = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$18
!RAM_SMW_NorSprXXX_SalvoTheSlime_CeilingYPosLo = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$1A
!RAM_SMW_NorSprXXX_SalvoTheSlime_InitialYPos = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$1C
!RAM_SMW_NorSprXXX_SalvoTheSlime_SizeLo = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$1E
!RAM_SMW_NorSprXXX_SalvoTheSlime_EyeYPositionOffset = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$20
!RAM_SMW_NorSprXXX_SalvoTheSlime_BoxFadePaletteIndex = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$22
!RAM_SMW_NorSprXXX_SalvoTheSlime_BoxFadeVRAMByte1 = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$24
!RAM_SMW_NorSprXXX_SalvoTheSlime_BoxFadeVRAMByte2 = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$26
!RAM_SMW_NorSprXXX_SalvoTheSlime_IntroAnimationState = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$28
!RAM_SMW_NorSprXXX_SalvoTheSlime_TookDamageFlag = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$2A
!RAM_SMW_NorSprXXX_SalvoTheSlime_WiggleAtNextOpportunityFlag = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$2C
!RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeExplodingState = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$2E
!RAM_SMW_NorSprXXX_SalvoTheSlime_FloorYPosLo = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$30
!RAM_SMW_NorSprXXX_SalvoTheSlime_BoxFadeVRAMAddress = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$32
!RAM_SMW_NorSprXXX_SalvoTheSlime_BoxLevelDataIndex = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$34
!RAM_SMW_NorSprXXX_SalvoTheSlime_SpawnedFromBoxFlag = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$36
!RAM_SMW_NorSprXXX_SalvoTheSlime_LemonDropSpawnFrameCounter = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$38
!RAM_SMW_NorSprXXX_SalvoTheSlime_SlotIndexOfSpriteBeingTouched = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$3A
!RAM_SMW_NorSprXXX_SalvoTheSlime_InAirXSpeed = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$3C
!RAM_SMW_NorSprXXX_SalvoTheSlime_SubXPos = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$3E
!RAM_SMW_NorSprXXX_SalvoTheSlime_XPosLo = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$3F
!RAM_SMW_NorSprXXX_SalvoTheSlime_XPosHi = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$40
!RAM_SMW_NorSprXXX_SalvoTheSlime_SubYPos = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$41
!RAM_SMW_NorSprXXX_SalvoTheSlime_YPosLo = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$42
!RAM_SMW_NorSprXXX_SalvoTheSlime_YPosHi = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$43
!RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScaling = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$45
!RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenXPos = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$47
!RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenYPos = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$49
!RAM_SMW_NorSprXXX_SalvoTheSlime_MaxXSpeed = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$4B
!RAM_SMW_NorSprXXX_SalvoTheSlime_MaxYSpeed = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$4D
!RAM_SMW_NorSprXXX_SalvoTheSlime_XSpeed = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$4F
!RAM_SMW_NorSprXXX_SalvoTheSlime_YSpeed = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$51
!RAM_SMW_NorSprXXX_SalvoTheSlime_XAcceleration = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$53
!RAM_SMW_NorSprXXX_SalvoTheSlime_YAcceleration = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$55
!RAM_SMW_NorSprXXX_SalvoTheSlime_LevelCollisionFlags = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$57
!RAM_SMW_NorSprXXX_SalvoTheSlime_TopOfSalvosHeadYPos = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$59
!RAM_SMW_NorSprXXX_SalvoTheSlime_MaxVerticalScale = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$5B
!RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalScalingSpeed = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$5D
!RAM_SMW_NorSprXXX_SalvoTheSlime_TouchedCeilingFlag = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$5F
!RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6004 = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$61
!RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM600E = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$63
!RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6010 = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$65
!RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM601A = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$67
!RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM601C = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$69
!RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6020 = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$6B
!RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6022 = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$6D
!RAM_SMW_NorSprXXX_SalvoTheSlime_ScratchRAM6024 = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$6F
!RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentState = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$71
!RAM_SMW_NorSprXXX_SalvoTheSlime_CurrentPhaseTimer = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$73
!RAM_SMW_NorSprXXX_SalvoTheSlime_WaitBeforeSpawningLemonDropTimer = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$75
!RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteIndexOfPositionControllerSprite = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$77
!RAM_SMW_NorSprXXX_SalvoTheSlime_HurtFlashAnimationTimer = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$79
!RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenXPosLo = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$7B
!RAM_SMW_NorSprXXX_SalvoTheSlime_OnScreenYPosLo = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$7D
!RAM_SMW_NorSprXXX_SalvoTheSlime_XPixelsMovedLo = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$7F
!RAM_SMW_NorSprXXX_SalvoTheSlime_HorizontalDirectionRelativeToMario = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$81
!RAM_SMW_NorSprXXX_SalvoTheSlime_VerticalDirectionRelativeToMario = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$83
!RAM_SMW_NorSprXXX_SalvoTheSlime_XDistanceFromMario = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$85
!RAM_SMW_NorSprXXX_SalvoTheSlime_YDistanceFromMario = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$87
!RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteHitboxXPosLo = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$89
!RAM_SMW_NorSprXXX_SalvoTheSlime_SpriteHitboxYPosLo = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$8B
!RAM_SMW_NorSprXXX_SalvoTheSlime_16BitPlayerXSpeed = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$8D
!RAM_SMW_NorSprXXX_SalvoTheSlime_SlotOfSpriteBeingCollidedWith = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$8F
!RAM_SMW_NorSprXXX_SalvoTheSlime_FreezePlayerFlag = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$91
!RAM_SMW_NorSprXXX_SalvoTheSlime_InitialXPos = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$93
!RAM_SMW_NorSprXXX_SalvoTheSlime_BufferToUse = !RAM_SMW_NorSprXXX_SalvoTheSlime_InitialRAMOffset+$95

!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0E_Inactive = $00
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState00_Jumping = $01
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState01_Unknown = $02
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState02_Chase = $03
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState03_WiggleDefense = $04
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState04_Unknown = $05
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState05_OozeFromCeiling = $06
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState06_HopAfterOozing = $07
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState07_Grow = $08
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState08_WaitAfterGrowing = $09
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState09_DeadInit = $0A
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0A_DeadShrinking = $0B
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0B_WaitBeforeExploding = $0C
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0C_ChangeFromBoxToSlime = $0D
!Define_SMW_NorSprXXX_SalvoTheSlime_MainState0D_MorphFromBoxToSlime = $0E

; These defines define various SNES registers, SA-1 pack RAM addresses, and SMW RAM addresses. Do not edit these unless absolutely necessary!
!RAM_SMW_Misc_ScratchRAM00 = $000000|!dp
!RAM_SMW_Misc_ScratchRAM01 = $000001|!dp
!RAM_SMW_Misc_ScratchRAM02 = $000002|!dp
!RAM_SMW_Misc_ScratchRAM03 = $000003|!dp
!RAM_SMW_Misc_ScratchRAM04 = $000004|!dp
!RAM_SMW_Misc_ScratchRAM05 = $000005|!dp
!RAM_SMW_Misc_ScratchRAM06 = $000006|!dp
!RAM_SMW_Misc_ScratchRAM07 = $000007|!dp
!RAM_SMW_Misc_ScratchRAM08 = $000008|!dp
!RAM_SMW_Misc_ScratchRAM09 = $000009|!dp
!RAM_SMW_Misc_ScratchRAM0A = $00000A|!dp
!RAM_SMW_Misc_ScratchRAM0B = $00000B|!dp
!RAM_SMW_Misc_ScratchRAM0C = $00000C|!dp
!RAM_SMW_Misc_ScratchRAM0D = $00000D|!dp
!RAM_SMW_Misc_ScratchRAM0E = $00000E|!dp
!RAM_SMW_Misc_ScratchRAM0F = $00000F|!dp
!RAM_SMW_Counter_GlobalFrames = $000013|!dp
!RAM_SMW_Counter_LocalFrames = $000014|!dp
!RAM_SMW_IO_ControllerHold1 = $000015|!dp
!RAM_SMW_IO_ControllerPress1 = $000016|!dp
!RAM_SMW_IO_ControllerHold2 = $000017|!dp
!RAM_SMW_IO_ControllerPress2 = $000018|!dp
!RAM_SMW_Player_CurrentPowerUp = $000019|!dp
!RAM_SMW_Mirror_CurrentLayer1XPosLo = $00001A|!dp
!RAM_SMW_Mirror_CurrentLayer1XPosHi = $00001B|!dp
!RAM_SMW_Mirror_CurrentLayer1YPosLo = $00001C|!dp
!RAM_SMW_Mirror_CurrentLayer1YPosHi = $00001D|!dp
!RAM_SMW_Mirror_BGModeAndTileSizeSetting = $00003E|!dp
!RAM_SMW_Mirror_ColorMathSelectAndEnable = $000040|!dp
!RAM_SMW_Mirror_BG1And2WindowMaskSettings = $000041|!dp
!RAM_SMW_Mirror_BG3And4WindowMaskSettings = $000042|!dp
!RAM_SMW_Mirror_ObjectAndColorWindowSettings = $000043|!dp
!RAM_SMW_Mirror_ColorMathInitialSettings = $000044|!dp
!RAM_SMW_Misc_LevelLayoutFlags = $00005B|!dp
!RAM_SMW_Misc_ScreensInLvl = $00005D|!dp
!RAM_SMW_Sprites_TilePriority = $000064|!dp
!RAM_SMW_Player_CurrentState = $000071|!dp
!RAM_SMW_Player_InAirFlag = $000072|!dp
!RAM_SMW_Player_DuckingFlag = $000073|!dp
!RAM_SMW_Player_FacingDirection = $000076|!dp
!RAM_SMW_Player_BlockedFlags = $000077|!dp
!RAM_SMW_Player_XSpeed = $00007B|!dp
!RAM_SMW_Player_YSpeed = $00007D|!dp
!RAM_SMW_Player_OnScreenPosXLo = $00007E|!dp
!RAM_SMW_Player_OnScreenPosYLo = $000080|!dp
!RAM_SMW_Player_XPosLo = $000094|!dp
!RAM_SMW_Player_YPosLo = $000096|!dp
!RAM_SMW_Blocks_YPosLo = $000098|!dp
!RAM_SMW_Blocks_XPosLo = $00009A|!dp
!RAM_SMW_Flag_SpritesLocked = $00009D|!dp
!RAM_SMW_NorSpr_SpriteID = !sprite_num
!RAM_SMW_NorSpr_YSpeed = !sprite_speed_y
!RAM_SMW_NorSpr_XSpeed = !sprite_speed_x
!RAM_SMW_NorSpr_YPosLo = !sprite_y_low
!RAM_SMW_NorSpr_XPosLo = !sprite_x_low
!RAM_SMW_IO_OAMBuffer = $000200|!addr
!RAM_SMW_Sprites_OAMTileSizeBuffer = $000420|!addr
!RAM_SMW_Palettes_PaletteUploadTableIndex = $000680|!addr
!RAM_SMW_Palettes_PaletteMirror = $000703|!addr
!RAM_SMW_Palettes_CopyOfPaletteMirror = $000905|!addr
!RAM_SMW_Mirror_MainScreenLayers = $000D9D|!addr
!RAM_SMW_Mirror_SubScreenLayers = $000D9E|!addr
!RAM_SMW_Mirror_HDMAEnable = $000D9F|!addr
!RAM_SMW_Misc_CurrentlyActiveBossEndCutscene = $0013C6|!addr
!RAM_SMW_Flag_Pause = $0013D4|!addr
!RAM_SMW_Player_FreezePlayerFlag = $0013FB|!addr
!RAM_SMW_Player_SpinJumpFlag = $00140D|!addr
!RAM_SMW_Misc_Layer2XPosLo = $001466|!addr
!RAM_SMW_Misc_Layer2XPosHi = !RAM_SMW_Misc_Layer2XPosLo+$01
!RAM_SMW_Misc_Layer2YPosLo = $001468|!addr
!RAM_SMW_Misc_Layer2YPosHi = !RAM_SMW_Misc_Layer2YPosLo+$01
!RAM_SMW_Misc_RandomByte1 = $00148D|!addr
!RAM_SMW_Misc_RandomByte2 = !RAM_SMW_Misc_RandomByte1+$01
!RAM_SMW_Timer_StarPower = $001490|!addr
!RAM_SMW_Timer_EndLevel = $001493|!addr
!RAM_SMW_Timer_PlayerHurt = $001497|!addr
!RAM_SMW_NorSpr_CurrentStatus = !sprite_status
!RAM_SMW_NorSpr_YPosHi = !sprite_y_high
!RAM_SMW_NorSpr_XPosHi = !sprite_x_high
!RAM_SMW_NorSpr_SubYPos = !sprite_speed_y_frac
!RAM_SMW_NorSpr_SubXPos = !sprite_speed_x_frac
!RAM_SMW_NorSpr_SpinJumpKillTimer = !1540
!RAM_SMW_NorSpr_DecrementingTable7E1564 = !1564
!RAM_SMW_NorSpr_FacingDirection = !157C
!RAM_SMW_NorSpr_LevelCollisionFlags = !sprite_blocked_status
!RAM_SMW_NorSpr_OnYoshisTongue = !15D0
!RAM_SMW_NorSpr_CurrentSlotID = $0015E9|!addr
!RAM_SMW_NorSpr_OAMIndex = !sprite_oam_index
!RAM_SMW_NorSpr_YXPPCCCT = !sprite_oam_properties
!RAM_SMW_NorSprXXX_EyesOfSalvoTheSlime_AnimationFrame = !1602
!RAM_SMW_NorSpr_PropertyBits1662 = !1662
!RAM_SMW_NorSpr_PropertyBits167A = !167A
!RAM_SMW_NorSpr_PropertyBits1686 = !1686
!RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo = $001693|!addr
!RAM_SMW_Player_RidingYoshiFlag = $00187A|!addr
!RAM_SMW_ClusterSpr_SpriteID = $001892|!addr
!RAM_SMW_Flag_RunClusterSprites = $0018B8|!addr
!RAM_SMW_Timer_StunPlayer = $0018BD|!addr
!RAM_SMW_Player_StarKillCount = $0018D2|!addr
!RAM_SMW_Misc_LevelTilesetSetting = $001931|!addr
!RAM_SMW_IO_SoundCh1 = $001DF9|!addr
!RAM_SMW_IO_SoundCh2 = $001DFA|!addr
!RAM_SMW_IO_MusicCh1 = $001DFB|!addr
!RAM_SMW_IO_SoundCh3 = $001DFC|!addr
!RAM_SMW_ClusterSpr_YPosLo = $001E02|!addr
!RAM_SMW_ClusterSpr_XPosLo = $001E16|!addr
!RAM_SMW_ClusterSpr_YPosHi = $001E2A|!addr
!RAM_SMW_ClusterSpr_XPosHi = $001E3E|!addr
!RAM_SMW_PIXI_NorSpr_SprExtraBits = !extra_bits
!RAM_SMW_PIXI_NorSpr_CustomSpriteID = !new_sprite_num

!RAM_SMW_SA1_InvokeSA1CPURt = $001E80
!RAM_SMW_SA1_SA1CPUPtrLo = $003180
!RAM_SMW_SA1_SA1CPUPtrHi = !RAM_SMW_SA1_SA1CPUPtrLo+$01
!RAM_SMW_SA1_SA1CPUPtrBank = !RAM_SMW_SA1_SA1CPUPtrLo+$02

!LM_CustomLevelDimensionsHack = 0
!LM_CustomBlocksHack = 0
if read3($0295ED)&$7FFFFF != $00BA60
	!LM_CustomLevelDimensionsHack = 1
	!RAM_SMW_LM_Misc_8BitL1LevelScreenPosLoPtrs = $000CB6|!addr
	!RAM_SMW_LM_Misc_8BitL2LevelScreenPosLoPtrs = $000CC6|!addr
	!RAM_SMW_LM_Misc_8BitL1LevelScreenPosHiPtrs = $000CD6|!addr
	!RAM_SMW_LM_Misc_8BitL2LevelScreenPosHiPtrs = $000CE6|!addr
	!RAM_SMW_LM_Misc_LevelScreenSizeLo = $0013D7|!addr
	!RAM_SMW_LM_Misc_LevelScreenSizeHi = !RAM_SMW_LM_Misc_LevelScreenSizeLo+$01
endif
if read3($00F4DE)&$7FFFFF != $00F545
	!LM_CustomBlocksHack = 1
endif

struct SMW_CopyOfPaletteMirror !RAM_SMW_Palettes_CopyOfPaletteMirror
	.LowByte: skip $01
	.HighByte: skip $01
endstruct align $02

struct SMW_OAMBuffer !RAM_SMW_IO_OAMBuffer
	.XDisp: skip $01
	.YDisp: skip $01
	.Tile: skip $01
	.Prop: skip $01
endstruct align $04

struct SMW_OAMTileSizeBuffer !RAM_SMW_Sprites_OAMTileSizeBuffer
	.Slot: skip $01
endstruct

struct HDMA $004300
	.Parameters: skip $01
	.Destination: skip $01
	.SourceLo: skip $01
	.SourceHi: skip $01
	.SourceBank: skip $01
	.IndirectSourceLo: skip $01
	.IndirectSourceHi: skip $01
	.IndirectSourceBank: skip $01
	.TableSourceLo: skip $01
	.TableSourceHi: skip $01
	.LineCount: skip $01
endstruct align $10

!REGISTER_BG2HorizScrollOffset = $00210F
!REGISTER_BG2VertScrollOffset = $002110
!REGISTER_Mode7MatrixParameterA = $00211B
!REGISTER_Mode7MatrixParameterB = $00211C
!REGISTER_MainScreenLayers = $00212C
!REGISTER_SubScreenLayers = $00212D
!REGISTER_PPUMultiplicationProductLo = $002134
!REGISTER_PPUMultiplicationProductMid = $002135
!REGISTER_PPUMultiplicationProductHi = $002136

if !sa1 == 1
	!REGISTER_SA1_ArithmeticType = $002250
	!REGISTER_SA1_MultiplicandOrDividendLo = $002251
	!REGISTER_SA1_MultiplicandOrDividendHi = $002252
	!REGISTER_SA1_MultiplierOrDivisorLo = $002253
	!REGISTER_SA1_MultiplierOrDivisorHi = $002254
	!REGISTER_SA1_ArithmeticResultLo = $002306
	!REGISTER_SA1_ArithmeticResultMidLo = $002307
	!REGISTER_SA1_ArithmeticResultMid = $002308
	!REGISTER_SA1_ArithmeticResultMidHi = $002309
	!REGISTER_SA1_ArithmeticResultHi = $00230A
	!RAM_SMW_Blocks_Map16TableLo = $40C800
	!Define_SMW_MaxNormalSpriteSlot = $15
	!Base1 = $3000
	!Base2 = $6000
else
	!RAM_SMW_Blocks_Map16TableLo = $7EC800
	!Define_SMW_MaxNormalSpriteSlot = $0B
	!Base1 = $0000
	!Base2 = $0000
endif

!R0 = $00
!R1 = $02
!R2 = $04
!R3 = $06
!R4 = $08
!R5 = $0A
!R6 = $0C
!R7 = $0E
!R8 = $6B
!R9 = $6D

if !Define_SMW_NorSprXXX_SalvoTheSlime_YoshiPlayerPatchInstalled == 1
	incsrc "SpriteDefines.asm"
endif

!Define_SMW_Sound1DF9_HitHead = $01
!Define_SMW_Sound1DF9_SpinJumpKill = $08
!Define_SMW_Sound1DF9_FlyWithCape = $09
!Define_SMW_Sound1DF9_Swim = $0E
!Define_SMW_Sound1DF9_Stomp1 = $13
!Define_SMW_Sound1DF9_Stomp2 = $14
!Define_SMW_Sound1DF9_Stomp3 = $15
!Define_SMW_Sound1DF9_Stomp4 = $16
!Define_SMW_Sound1DF9_Stomp5 = $17
!Define_SMW_Sound1DF9_Stomp6 = $18
!Define_SMW_Sound1DF9_Stomp7 = $19
!Define_SMW_Sound1DFC_Springboard = $08

!Define_SMW_NorSpr_1662Prop_SpriteClipping = $3F
!Define_SMW_NorSpr_167AProp_InvincibleToMostThings = $02
!Define_SMW_NorSpr_1686Prop_DisableSpriteClipping = $08

!Define_SMW_NorSprStatus01_Init = $01
!Define_SMW_NorSprStatus02_Dead = $02
!Define_SMW_NorSprStatus04_SpinJumpKill = $04
!Define_SMW_NorSprStatus08_Normal = $08
!Define_SMW_NorSprStatus09_Stunned = $09
!Define_SMW_NorSprStatus0A_Kicked = $0A

!Define_SMW_SpriteID_NorSpr035_Yoshi = $35
