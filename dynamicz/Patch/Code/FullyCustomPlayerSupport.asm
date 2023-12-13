customPlayer:

	LDA $0100|!base2
	CMP !lastLevelMode
	BNE +++

	LDA !marioCustomGFXBnk
	STA $04
	CMP !optimizer4
	BNE ++
	
	REP #$20
	LDA !marioCustomGFXRec
	CMP !optimizer5
	BNE +
	RTS
+	
	STA !optimizer5
	STA $02
	
	LDA #$6000              ; \ Set Address for VRAM Read/Write to x6000 
	STA $2116               ; / ; Address for VRAM Read/Write (Low Byte)
	
	LDA #$0400
	STA $05
	
	STY $420B
	RTS
++
	STA !optimizer4
	REP #$20
	
	LDA #$6000              ; \ Set Address for VRAM Read/Write to x6000 
	STA $2116               ; / ; Address for VRAM Read/Write (Low Byte)
	
	LDA !marioCustomGFXRec
	STA !optimizer5
	STA $02
	
	LDA #$0400
	STA $05
	
	STY $420B
	
	RTS
+++
	STA !lastLevelMode
	
	LDA !marioCustomGFXBnk
	STA !optimizer4
	REP #$20
	
	LDA #$6000              ; \ Set Address for VRAM Read/Write to x6000 
	STA $2116               ; / ; Address for VRAM Read/Write (Low Byte)
	
	LDA !marioCustomGFXRec
	STA !optimizer5
	STA $02
	
	LDA #$0400
	STA $05
	
	STY $420B
	
	RTS