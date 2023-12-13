db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

incsrc	StarCoinsDefs.asm

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
		ORA	#$02
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
		REP	#$20
		LDY	#$06
MakingLoop1:	LDA.w	Tabla,y
		PHP	
		REP	#$10
		TAX	
		%change_map16()
		PLP	
		LDA	$98
		SEC	
		SBC	TileShiftY-$02,y
		STA	$98
		LDA	$9A
		SEC	
		SBC	TileShiftX-$02,y
		STA	$9A
		DEY	#2
		BPL	MakingLoop1
		SEP	#$20
		PLB	
		PLY	
SpriteV:		
SpriteH:		
MarioCape:		
MarioFireball:	RTL	
			
Tabla:			dw !BlankTileUpRight,!BlankTileUpLeft,!BlankTileDownRight,!BlankTileDownLeft
TileShiftX:		dw $FFF0,$0010,$FFF0,$0000
TileShiftY:		dw $0000,$0010,$0000,$0000