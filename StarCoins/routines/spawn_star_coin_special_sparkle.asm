		PHX	
		PHY	
		LDA	#$0F
		TRB	$98
		TRB	$9A
		LDX	#$03
		LDY	#$0B
.code02866A	LDA	$17F0|!addr,y
		BEQ	.code02867F
.code02866F	DEY	
		BPL	.code02866A
		DEC	$185D|!addr
		BPL	.code02867C
		LDA	#$0B
		STA	$185D|!addr
.code02867C	LDY	$185D|!addr
.code02867F	LDA	#$0C
		STA	$17F0|!addr,y
		LDA	$9A
		STA	$1808|!addr,y
		LDA	$9B
		STA	$18EA|!addr,y
		LDA	$98
		STA	$17FC|!addr,y
		LDA	$99
		STA	$1814|!addr,y
		LDA.l	.YVel,x
		STA	$1820|!addr,y
		LDA.l	.XVel,x
		STA	$182C|!addr,y
		LDA.l	.Time,x
		STA	$1850|!addr,y
		DEX	
		BPL	.code02866F
		PLY	
		PLX	
		RTL	
.YVel		db $CE,$C0,$C0,$CE
.XVel		db $E6,$0E,$F2,$1A
.Time		db $28,$38,$38,$28