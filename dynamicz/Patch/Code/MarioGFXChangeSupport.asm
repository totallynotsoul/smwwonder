;#########################################################
;#################  Mario GFX Change ####################
;#########################################################
marioGFXSetter:
	LDA !marioNormalCustomGFXOn
	BNE +
	
	LDA #$7E
	STA !marioNormalCustomGFXBnkReal
	
	REP #$20
	LDA #$2000
	STA !marioNormalCustomGFXRecReal
	BRA ++
+
	LDA #$00
	STA !marioNormalCustomGFXOn
	LDA !marioNormalCustomGFXBnk
	STA !marioNormalCustomGFXBnkReal
	REP #$20                  ; Accum (16 bit) 
	LDA !marioNormalCustomGFXRec
	STA !marioNormalCustomGFXRecReal
++
	LDX #$00                
	LDA $09                   
	ORA #$0800              
	CMP $09                   
	BEQ +        
	CLC                       
+
	AND #$F700              
	ROR                       
	LSR                       
	ADC !marioNormalCustomGFXRecReal             
	STA $0D85|!base2
	
	CLC                       
	ADC #$0200              
	STA $0D8F|!base2
	LDX #$00                
	LDA $0A                   
	ORA #$0800              
	CMP $0A                   
	BEQ +           
	CLC
+	
	AND #$F700              
	ROR                       
	LSR                       
	ADC !marioNormalCustomGFXRecReal              
	STA $0D87|!base2
	
	CLC                       
	ADC #$0200              
	STA $0D91|!base2
	LDA $0B                   
	AND #$FF00              
	LSR                       
	LSR                       
	LSR                       
	ADC !marioNormalCustomGFXRecReal             
	STA $0D89|!base2
	
	CLC                       
	ADC #$0200              
	STA $0D93|!base2
	LDA $0C                   
	AND #$FF00              
	LSR                       
	LSR                       
	LSR                       
	ADC !marioNormalCustomGFXRecReal             
	STA $0D99|!base2
	
	SEP #$20                  ; Accum (8 bit) 
	
	LDA #$0A                
	STA $0D84|!base2
	JML $00F63A|!base3