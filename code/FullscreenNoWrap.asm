; Fullscreen Overworld by Yoshifanatic
; This is an edit of the Widescreen Overworld patch by Medic that expands the view of the overworld vertically as well.
; However, because of the limited size of the submap tilemaps, it was necessary to sacrifice the submaps so they act as a second main map.

lorom

if read1($00FFD5) == $23
	!SA1 = 1
	sa1rom
else
	!SA1 = 0
endif

if !SA1
	; SA-1 base addresses
	!Base1 = $3000
	!Base2 = $6000
else
	; Non SA-1 base addresses
	!Base1 = $0000
	!Base2 = $0000
endif

org $049858									;\ Enable scrolling on the submaps
	NOP #2										;/

org $04837B									;\ Enable free camera scrolling on the submaps
	NOP #2										;/

org $048264									;\ Disable the overworld border player
	JSR.w $0485A7
	;NOP #3									;|
												;|
org $048EE8									;|
	;NOP #3
	JSR.w $0485A4								;/

org $0485A9									;\ Draw the overworld player sprite far off screen.
	LDA.w #$EEEE								;| The reason for doing this instead of just not drawing it altogether is because...
												;/ ... it causes an issue where the sideways walking frames of the overworld player glitch up.

org $0485E8									;\ Disable the overworld border box around the player sprite.
	RTS											;/


org $00A155									;\ Disable the overworld border
	NOP #2										;/ LM's layer 3 feature can be used for overworld layer 3 instead.

org $048E88									;\ Disable the layer 3 level names on the overworld border.
	NOP #3										;|
												;|
org $049550									;|
	NOP #3										;/

org $04DB78									;\ Make the submap transition effect span the full screen height
	LDY.b #$E8									;|
												;|
org $04DB81									;|
	STA ($04A0-$02)|!Base2,y					;|
	STA ($04A0+$D8)|!Base2,x					;/

org $048221
	dw $0000,$0101,$0000,$0101				; Adjust the left/right boundary for free scrolling.
	dw $0000,$0118,$FFFF,$0118				; Adjust the top/bottom boundary as well.

org $049860
	JML FixScroll

org $049418									;\ Adjust the top/right/bottom boundary of the camera scroll.
	dw $FFFF,$0100								;/
	dw $0117

org $04DB08									;\ Fix the window HDMA bounds
	dw $F800,$F808								;/

org $04DB0E									;\ Fix the window HDMA bounds
	dw $7F00									;/

org $049630
	LDA #$7F00									; Extend HDMA to fill the screen

org $00A06B									; Initial X position of the camera for each submap.
	dw $0000		; Main Map
	dw $FFF0		; Yoshi's Island
	dw $FFF0		; Vanilla Dome
	dw $FFF0		; Forest of Illusion
	dw $00F0		; Valley of Bowser
	dw $00F0		; Special World
	dw $00F0		; Star World

org $00A079									; Initial Y position of the camera for each submap.
	dw $0000		; Main Map
	dw $0000		; Yoshi's Island
	dw $0080		; Vanilla Dome
	dw $0120		; Forest of Illusion
	dw $0000		; Valley of Bowser
	dw $0080		; Special World
	dw $0120		; Star World

org $049A0C									; Camera X/Y position when entering each submap from a path transition.
	dw $FFF0,$0000		; Yoshi's Island
	dw $FFF0,$0080		; Vanilla Dome
	dw $FFF0,$0117		; Forest of Illusion
	dw $00F0,$0000		; Valley of Bowser
	dw $00F0,$0080		; Special World
	dw $00F0,$0117		; Star World

;org $049291									;\ Uncomment this to enable walking on unrevealed paths.
	;JMP $92B2									;/ 

org $04FB4C
	ADC #$0060 									;ADC #$0020 This extends the boundaries where the OW cloud can spawn
	CMP #$0180 									;CMP #$0140
	BCS $09 										;BCS $09

org $04F78E
	SBC #$0040										; This makes sure the OW cloud don't spawn onscreen halfway

org $04DBD7
	JSL FixHDMA									;Turn Off HDMA after fade...
	NOP #2

org $04FB11
	JML CheckDouble

org $04FB1A
	JML CheckYPosOfSprite

org $04FB2A
autoclean JML Code

org $04863C										;\ Prevent the overworld player from disappearing when touching the left edge of the screen.
	;b0 0f											;|
	NOP #2											;|
													;|
org $048662										;|
	NOP #2											;/

org $0486E1
	JSL FixMario
	NOP #20

org $04876E
	JSL FixLuigi
	NOP #20

org $04FA3E
	JML IWillFixThatFish

freecode
Code:	;Make sure the sprites do not disappear halfway on the left border!
	ROL
	ASL
	PHX
	LDX $01
	CPX #$FF
	BNE +
	PHA
	LDX $0DDE|!Base2
	LDA $0DE5|!Base2,x
	CMP #$07
	BEQ IsSmoke
	PLA
	ORA #$01
+:
-:
	PLX
	AND #$03
	JML $04FB2E

IsSmoke:
	PLA : LDA #$01
	BRA -

CheckDouble:
	LDA $01
	BNE +
-
	JML $04FB15

+
	CMP #$FF
	BEQ -
	JML $04FB36

CheckYPosOfSprite:
	PHP
	REP #$21
	LDA $02
	ADC #$0010
	CMP #$0100
	BCC.b +
	LDA #$00F0
	STA $02
+:
	PLP
	JML $04FB1E
	
FixMario:
	PHB
	PHK
	PLB
	JSR ActualCode
	PLB
	RTL

ActualCode:
	LDX $0DB3|!Base2
	LDA $0DBA|!Base2,x
	BEQ +
	LDA $0DD6|!Base2
	LSR
	TAX
	LDA $1F13|!Base2,x
	TAX
+:
	REP #$30	
	PHX			
	LDX $0DD6|!Base2
	LDA $1F17|!Base2,x
	PLX
	SEC : SBC $1A
	PHA : PHA : PHA
	SEC : SBC Table1,x
	CMP #$00FF
	JSR LoadValue
	STA $0447|!Base2				;Reg Mario/Yoshi
	STA $0449|!Base2
	REP #$20
	PLA
	SEC : SBC Table2,x
	CMP #$00FF
	JSR LoadValue
	STA $0448|!Base2				;Right, Reg Mario/Yoshi
	STA $044A|!Base2
	REP #$20
	PLA
	SEC : SBC #$0008
	CMP #$00FF
	JSR LoadValue
	STA $044B|!Base2				;Yoshi
	STA $044D|!Base2
	REP #$20
	PLA
	CMP #$00FF
	JSR LoadValue
	STA $044C|!Base2				;Yoshi
	STA $044E|!Base2
	RTS

Table1:
	dw $0008,$0008,$0001,$0010,$0008,$0008,$0008,$0008,$0008,$0008,$0008,$0008	;Left: Front of Mario's Head

Table2:
	dw $0000,$0000,$FFF8,$0008,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;Left: Back of Mario's Head

LoadValue:
	SEP #$30
	BCC +
	LDA #$01
	RTS

+:
	LDA #$00
	RTS

FixLuigi:
	PHB
	PHK
	PLB
	JSR ActualCode2
	PLB
	RTL

ActualCode2:
	REP #$30				;Left Tiles
	LDA $0DD6|!Base2
	EOR #$0004				;the OTHER player.
	TAX
	LDA $1F17|!Base2,x
	SEC : SBC $1A
	PHA
	SEC : SBC #$0008
	CMP #$00FF
	JSR LoadValue
	STA $044F|!Base2
	STA $0451|!Base2
	STA $0453|!Base2
	STA $0455|!Base2
	REP #$20
	PLA
	CMP #$00FF
	JSR LoadValue
	STA $0450|!Base2
	STA $0452|!Base2
	STA $0453|!Base2
	STA $0456|!Base2
	RTS

FixHDMA:
	LDY $0DB3|!Base2
	STZ $41
	STZ $42
	STZ $43
	RTL

IWillFixThatFish:	;...but not yet. Just hide it while the arrows are up for now. 
	LDA $13D4|!Base2			;It's up to you to make sure you don't place it in a spot where it can otherwise glitch.
	BNE +				;ALSO couldn't fix the yellow ! blocks, maybe some other time...
	LDA $0DF5|!Base2,x
	BNE ++
	JML $04FA43

++:
	JML $04FA83

+:
	JML $04FA82

FixScroll:
	SEC : SBC #$0080 : PHP
	CPY #$0000
	BNE ++
	CMP #$0000
	BNE +
-:
	LDA #$0000
	PLP
	JML $049878

+:
	BMI -
	PLP
	JML $049870 		;$11,$01,

++:;$EF,$FF
	PLP
	JML $049864
