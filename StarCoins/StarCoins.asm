header : lorom

incsrc ./StarCoinsDefs.asm

!a		= autoclean

!sa1 = 0
!dp = $0000
!addr = $0000
!bank = $800000
!ram = $7E0000

if read1($00FFD6) == $15
	sfxrom
	!gsu = 1
	!dp = $6000
	!addr = $6000
	!bank = $000000
	!ram = $7E0000
elseif read1($00FFD5) == $23
	sa1rom
	!sa1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!ram = $400000
endif

	if !InstallStatusCounter == 1
org $008FD8			;StatusBarHax
StatusBarHax:	LDX.b	#!MaxStarCoins-$01
.LoopCoins	LDY	#!BlankStatusCoin
		LDA	!LevelCoins
		AND.w	ReverseBits,x
		BEQ	.SkipFirst
		LDY	#!FullStatusCoin
.SkipFirst	TYA	
		STA	!Position|!addr,x
		DEX	
		BPL	.LoopCoins
		RTS	
ReverseBits:	db $01,$02,$04,$08,$10,$20,$40,$80
	endif
org $0096E9			;LevelInit
!a	JSL	LevelInit
	NOP	#2
org $00F2E8			;Midpoint
!a	JSL	MidPoint
	NOP	#2
org $00A1C7			;Overworld hax
	JML	Overworld	;(No autoclean because of sa-1 hijack)
org $00A269			;StartSelect
!a	JML	StartSelect
	NOP	#7
org $05CC84			;CourseClear
!a	JML	CourseClear
	NOP	
org $00C4AE			;KeyHax
!a	JSL	KeyHax
org $00F439			;PipeHax
!a	JSL	PipeHax
	NOP	
org $00EC10			;DoorHax
!a	JSL	DoorHax
	NOP	
org $00F614			;MarioDed
!a	JML	MarioDed

reset bytes

freecode

	if !InitLocation == 1
		print "The Star Coins patch is located at: $",pc
	endif
			
	if !InstallStatusCounter == 0
		ReverseBits:	db $01,$02,$04,$08,$10,$20,$40,$80
	endif

LevelInit:	PHX	
		LDX	$13BF|!addr
		LDA	!PreviousLevel
		STA	$00
		LDA	!PreviousCoinsF
		BEQ	.SameTransLevel
		LDA	!PreviousCoins
		STA	!LevelCoins
		LDA	#$00
		STA	!PreviousCoins
		STA	!PreviousCoinsF
		BRA	.FinishInit
.SameTransLevel	TXA	
		STA	!PreviousLevel
		LDA	$1EA2|!addr,x
		STA	$01
		AND	#$40
		BNE	.MidPoint
		CPX	$00
		BEQ	.SameLevel
.NewLevel	LDA	!PerLevelFlags,x
		STA	!LevelCoins
		STA	!TempCoins
		BRA	.FinishInit
.MidPoint	LDA	!PerMidPointFlags,x
		JSR	SubAddUpMid
		LDA	$00
		STA	!TempCoins
		STA	!LevelCoins
		BRA	.FinishInit
.SameLevel	LDA	!LevelCoins
		STA	!TempCoins
.FinishInit	STZ	$13D5|!addr
		STZ	$13D9|!addr
		PLX	
		RTL	
			
SubAddUpMid:	PHX	
		STA	$00
		LDA	!PerLevelFlags,x
		STA	$01
		LDY	#$00
		LDX	#!MaxStarCoins-$01
.LoopSum	LDA	$01
		AND.l	ReverseBits,x
		STA	$02
		LDA	$00
		AND.l	ReverseBits,x
		BEQ	.NoINY
		AND	$02
		BNE	.NoINY
		INY	
.NoINY		DEX	
		BPL	.LoopSum
		TYA	
		STA	!LevelCoinsNum
		PLX	
		RTS	

CourseClear:	PHX	
		JSR	AddUpCoins
		LDA	#$00
		STA	!TempCoins
		LDA	#$01
		STA	$13D5|!addr
		PLX	
		JML	$05CC89|!bank
			
MidPoint:	PHX	
		LDX	$13BF|!addr
		LDA	!PerMidPointFlags,x
		ORA	!LevelCoins
		STA	!PerMidPointFlags,x
		STA	!TempCoins
		LDA	$1EA2|!addr,x
		ORA	#$40
		STA	$1EA2|!addr,x
		LDA	#$05
		STA	$1DF9|!addr
		PLX	
		RTL	
			
StartSelect:	PHX	
		JSR	AddUpCoins
		PLX	
		LDA	$0DD5|!addr
		BEQ	+
		BPL	++
		LDA	#$80
		JML	$00A27E|!bank
+		JML	$00A270|!bank
++		RTL	
			
Overworld:
if !sa1
		LDA #$41
		STA $3180
		LDA #$82
		STA $3181
		LDA #$04
		STA $3182
		JSR $1E80
else
		JSL	$048241|!bank
endif
		JSR	GetTransLevel
		TAX	
		LDA	$1EA2|!addr,x
		STA	$00
		AND	#$80
		BEQ	.NoMidPoint
		LDA	$00
		AND	#$40
		BEQ	.NoMidPoint
		LDA	!PerMidPointFlags,x
		BRA	.StoreCoins
.NoMidPoint	LDA	!PerLevelFlags,x
		BRA	.StoreCoins
.StoreCoins	STA	!LevelCoins
.FinishOW	JML	$008494|!bank
			
MarioDed:	PHX	
		LDX	$13BF|!addr
		LDA	$1EA2|!addr,x
		AND	#$40
		BEQ	.NoMidPoint
		LDA	!TempCoins
		STA	!LevelCoins
		LDA	!PerMidPointFlags,x
		STA	!TempCoins
		STA	!LevelCoins
		BRA	.Finish
.NoMidPoint	LDA	!PerLevelFlags,x
		STA	!TempCoins
		STA	!LevelCoins
.Finish		LDA	#$00
		STA	!LevelCoinsNum
		PLX	
		LDA	#$09
		STA	$71
		JML	$00F618|!bank
				
KeyHax:		PHX	
		JSR	AddUpCoins
		LDA	#$00
		STA	!TempCoins
		LDA	#$02
		LDY	#$0B
		PLX	
		RTL	
			
DoorHax:	JSR	DumbMove
		LDA	#$0F
		STA	$1DFC|!addr
		RTL	
			
PipeHax:	JSR	DumbMove
		LDA	#$04
		STA	$1DF9|!addr
		RTL	
			
DumbMove:	LDA	#$01
		STA	!PreviousCoinsF
		LDA	!LevelCoins
		STA	!PreviousCoins
		RTS	
			
AddUpCoins:	REP	#$20
		LDA	!LevelCoinsNum
		AND	#$00FF
		CLC	
		ADC	!TotalCoinsNum
		STA	!TotalCoinsNum
		SEP	#$20
		LDA	#$00
		STA	!LevelCoinsNum
SetFlags:	LDX	$13BF|!addr
		LDA	!PerLevelFlags,x
		ORA	!LevelCoins
		STA	!PerLevelFlags,x
.BeatenLevel	RTS	
			
	;from ladida
GetTransLevel:	LDY $0DD6|!addr		;get current player*4
		LDA $1F17|!addr,y		;ow player X position low
		LSR #4
		STA $00
		LDA $1F19|!addr,y		;ow player y position low
		AND #$F0
		ORA $00
		STA $00
		LDA $1F1A|!addr,y		;ow player y position high
		ASL
		ORA $1F18|!addr,y		;ow player x position high
		LDY $0DB3|!addr		;get current player
		LDX $1F11|!addr,y		;get current map
		BEQ +
		CLC : ADC #$04		;if on submap, add $0400
+		STA $01
		REP #$10
		LDX $00
		LDA.l $00D000|!ram,x		;load layer 1 tilemap, and thus current translevel number
		STA $13BF|!addr
		SEP #$10
		RTS
			
if !BytesUsed == 1
	print "Freespace used by the Star Coins patch: ",freespaceuse," bytes."
endif	
		
pushpc
	if !InstallSRAMPlus == 1
		if !sa1
			incsrc bwram_plus.asm
		else
			incsrc sram_plus.asm
		endif
	endif
pullpc
pushpc
	if !InstallMinorSprites == 1
		incsrc MinorExtendedSprites.asm
	endif
pullpc
pushpc
	if !InstallObjectool == 1
		incsrc Objectool.asm
	endif
pullpc