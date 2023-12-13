db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

!MusicBlockSprite = $00
!Map16Page = $05

Map16Table:
    db $60 ; 1 should be Red
    db $61 ; 2 should be Green
    db $62 ; 3 should be Blue
    db $63 ; 4 should be Yellow

MarioBelow:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
SpriteH:
SpriteV:
MarioCape:
MarioFireball:
    RTL

MarioAbove:
    LDA $04
    CMP #!Map16Page
    BNE Return

    LDX #$03
  - LDA Map16Table,X
    CMP $03
    BEQ +
    DEX
    BMI Return
    JMP -

  + STX $05
    LDA #!MusicBlockSprite
    SEC
    %spawn_sprite()

    TAX

    LDA $05
    STA !extra_byte_1,X

    LDA $03
    STA !extra_byte_2,X

    LDA $04
    STA !extra_byte_3,X

    STZ $00
    LDA #$01
    STA $01

    TXA

    %move_spawn_relative()
    BCS Return
    %erase_block()
Return:
    RTL

print "A music block, like from Super Mario Bros Wonder."
