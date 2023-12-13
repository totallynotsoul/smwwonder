incsrc ../blocks/StarCoinsDefs.asm		;Change 'blocks' to 'sprites' when pasting into PIXI's routines folder!

		PHX	
		PHY	
		LDA	!LevelCoins
		STA	$00
		LDY	#$FF
		LDX	#!MaxStarCoins-$01
.LoopSum	LDA	$00
		AND.l	ReverseBits,x
		BEQ	.NoINY
		INY	
.NoINY		DEX	
		BPL	.LoopSum
		TYX	
		LDA.l	PointsTab,x
		PLY	
		PLX	
		RTL	

ReverseBits:	db $01,$02,$04,$08,$10,$20,$40,$80
PointsTab:	db !FirstPoints,!SecondPoints,!ThirdPoints,!FourthPoints
		db !FifthPoints,!SixthPoints,!SeventhPoints,!EighthPoints