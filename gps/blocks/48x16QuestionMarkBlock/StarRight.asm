;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 48x16 question mark block by EternityLarva
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!false = 0   ;\don't change value
!true  = 1   ;/

print "48x16 question mark block a star and two coins inside"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; spawn item config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $0  : coin
; $74 : mushroom
; $75 : flower
; $77 : cape
; $76 : star
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!small_item = $76
!small_custom = !false

!big_item = $76
!big_custom = !false

!star_item = $76
!star_custom = !false

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; block config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 0:left block
; 1:middle block
; 2:right block
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!block_pos = 2                 ;block config 0-2


db $42
JMP MarioBelow : JMP MarioAbove : JMP Return
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP Return
JMP Return : JMP Return : JMP Return

MarioAbove:
LDA $1869|!addr
CMP #$00
BNE MarioCape

MarioBelow:
	LDA $7D         ;\
	BPL Return      ;|mario jump up
	JMP MarioCape   ;/

SpriteV:
	LDA !14C8,x     ;\
	CMP #$09        ;|
	BNE Return      ;|sprite carryable
	LDA !AA,x       ;|
	BMI +           ;|
	RTL             ;/

SpriteH:
	LDA !14C8,x     ;\
	CMP #$0A        ;|sprite kicked
	BEQ +           ;|
Return:             ;|
	RTL             ;/
+
	%sprite_block_position()

MarioCape:          ; cape attack

incsrc "48x16QuestionMarkBlockMain.asm"