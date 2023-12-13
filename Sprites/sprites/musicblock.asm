!Tile = $88 ; The graphics to use
!Velocity = -100 ; The velocity to give Mario

Palettes:
    db %00111000 ; Red
    db %00111010 ; Green
    db %00110110 ; Blue
    db %00110100 ; Yellow

print "MAIN ",pc
print "INIT ",pc
PHB : PHK : PLB
	JSR MainCode
	PLB
RTL

MainCode:
	LDA $9D			        ; Check if sprites should be frozen
	BNE +

    JSL $01B44F|!BankB      ; Solid sprite routine! Sorry, other sprites...

	JSL $01A7DC|!BankB		; Check for contact
	BCS +

	STZ !14C8,x		; Remove sprite

    LDA !E4,x                      ;Sprite Xpos Low Byte (table)
    STA $9A                        ;Block creation: X position (low)
    LDA !14E0,x                    ;Sprite Xpos High Byte (table)
    STA $9B                        ;Block creation: X position (high)
    LDA !D8,x                      ;Sprite Ypos Low Byte (table)
    STA $98                        ;Block creation: Y position (low)
    LDA !14D4,x                    ;Sprite Ypos High Byte (table)
    STA $99                        ;Block creation: Y position (high)

    LDA #$00
    STA $1933

    LDA !extra_byte_3,X
    XBA
    LDA !extra_byte_2,X
    REP #$20
    %ChangeMap16()
    SEP #$20

    LDA $7D
    BPL ++

    ; Set Mario's velocity high
    LDA #!Velocity
    STA $7D

    ; Play spring sound
    LDA #$08
    STA $1DFC|!Base2

    JMP ++

  + ; Graphics here

    LDA !extra_byte_1,X
    TAY
    LDA Palettes,Y
	ORA $64
    STA $05

	%GetDrawInfo()

	LDA $00
	STA $0300|!Base2,y	; X position
	LDA $01
	STA $0301|!Base2,y	; Y position
	LDA #!Tile
	STA $0302|!Base2,y	; Tile number

    LDA $05
	STA $0303|!Base2,y	; Properties

	LDA #$00	; Tile to draw - 1
	LDY #$02	; 16x16 sprite
	JSL $01B7B3|!BankB

 ++ RTS
