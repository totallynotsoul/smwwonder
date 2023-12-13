
db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioBelow:
MarioAbove:
MarioSide:
	REP #$20
	INC $0EFB|!dp
	SEP #$20
	LDA #$01				; \ Play the "coin" sound effect.
	STA $1DFC|!addr			; /
	%glitter()				; > Create glitter effect.
	%erase_block()			; > Erase the block.
    RTL

SpriteV:
SpriteH:
Cape:
Fireball:
MarioCorner:
MarioBody:
MarioHead:
WallFeet:
WallBody:
    RTL




print "A small purple coin."