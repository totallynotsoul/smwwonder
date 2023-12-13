!Number = 0	;which trigger to use. Valid numbers are 0-1F

print "Enables the one shot trigger !Number "

db $42
JMP Code : JMP Code : JMP Code : JMP Skip : JMP Skip : JMP Skip : JMP Skip
JMP Code : JMP Code : JMP Code

!Add #= ($!Number&$18)>>$3
!Number #= $!Number-($!Number&$18)

Code:
    LDA #$26
    STA $1DFC|!addr
	LDA $7FC0F8+!Add
	ORA #$01<<$!Number
	STA $7FC0F8+!Add
Skip:
	RTL