if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
else
    lorom
    !addr = $0000
endif

org $0081AF
    BRA + 
    NOP 
+

org $0082B0
    LDA.W $0D9F|!addr
    STA.W $420C
    LDA.W $0DAE|!addr
    STA.W $2100

org $008283
    LDY.W $0D9F|!addr
    STY.W $420C
    LDY.W $0DAE|!addr
    STY.W $2100

org $00834B
    LDA.W $0D9F|!addr
    STA.W $420C
    LDA.W $0DAE|!addr
    STA.W $2100