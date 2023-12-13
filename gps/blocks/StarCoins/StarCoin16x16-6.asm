db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

incsrc ./StarCoinsDefs.asm

MarioBelow:		
MarioAbove:		
MarioSide:		
TopCorner:		
BodyInside:		
HeadInside:	PHY	
		PHB	
		PHK	
		PLB	
		LDA	!LevelCoins
		ORA	#$06
		STA	!LevelCoins
		LDA	#!StarCoinSFXNumber
		STA	!StarCoinSFXPort|!addr
	if !UseNewSparkleEffect == 1
		%spawn_star_coin_special_sparkle()
	else		
		PHK	
		PEA.w	.endglitter-1
		PEA.w	$0084CF|!bank-1
		JML	$00FD5A|!bank
.endglitter		
	endif		
	if !GivePoints == 1
		%star_coin_give_points()
		%spawn_score_sprite()
	endif		
		LDA	!LevelCoinsNum
		INC	A
		STA	!LevelCoinsNum
		PHP	
		REP	#$10
		LDX.w	#!BlankTile16x16
		%change_map16()
		PLP	
		PLB	
		PLY	
SpriteV:		
SpriteH:		
MarioCape:		
MarioFireball:	RTL	