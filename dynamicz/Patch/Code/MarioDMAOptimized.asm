normalPlayer:
if !Mode50moreSupport
	LDA !mode50 ;if mode50 not 0 then no yoshi or podoboos
	BEQ +
	
	LDA #$06
	STA $0D84|!base2
	JMP .go6
+
endif

	LDA $0D84|!base2
	CMP #$0A
	BCS +
	CMP #$06
	BEQ .go6
	JMP ++
+

	REP #$20
	LDA $0D85+$08|!base2
	CMP #$7D00+$0800
	BCC .dec1
	CMP #$7D00+$10C0
	BCS .dec1
	BRA ++ ; if slot 08 = invalid then don't load
.dec1
	LDA $0D8F+$08|!base2
	CMP #$7D00+$0A00
	BCC .dec2
	CMP #$7D00+$12C0
	BCS .dec2
	BRA ++ ; if slot 08 = invalid then don't load
.dec2
	
	LDX $0D84|!base2
	DEX
	DEX
	STX $0D84|!base2
	
	LDA $0D85+$06|!base2
	CMP #$7D00+$0800
	BCC .dec3
	CMP #$7D00+$10C0
	BCS .dec3
	BRA ++ ; if slot 06 = invalid && and slot 08 = invalid then don't load slot 06
.dec3
	LDA $0D8F+$06|!base2
	CMP #$7D00+$0A00
	BCC .dec4
	CMP #$7D00+$12C0
	BCS .dec4
	BRA ++ ; if slot 06 = invalid && and slot 08 = invalid then don't load slot 06
.dec4
	LDX $0D84|!base2
	DEX
	DEX
	STX $0D84|!base2
	
.go6
	LDX $0019|!base1
	CPX #$02
	BEQ ++ ; if slot 06 = invalid && and slot 08 = invalid && don't cape then don't load slot $04
	
	LDX $0D84|!base2
	DEX
	DEX
	STX $0D84|!base2
	
++
	SEP #$20
	LDA $0100|!base2
	CMP !lastLevelMode
	BEQ +
	JMP .CompleteDMA ; if levelmode changed then make the complete DMA routine
+
	LDA !marioNormalCustomGFXBnkReal               
	CMP !optimizer6
	BEQ +
	JMP .ignoreBank ; if bank changed then make the complete DMA routine
+
	STA $04               ; / ; A Address Bank

	REP #$20                  ; 16 bit A ; Accum (16 bit)          

	LDA #$67F0              
	STA $2116               ; Address for VRAM Read/Write (Low Byte)
	
	LDA $0D99|!base2
	CMP !optimizer
	BEQ .dma1 ; if $0D99 didn't change then don't load
	STA !optimizer 
	STA $02               ; A Address (Low Byte)

	LDA #$0020              ; \ x20 bytes will be transferred 
	STA $05               ; / ; Number Bytes to Transfer (Low Byte) (DMA)
	
	STY $420B               ; Transfer ; Regular DMA Channel Enable
	
.dma1
	LDA #$6000              ; \ Set Address for VRAM Read/Write to x6000 
	STA $2116               ; / ; Address for VRAM Read/Write (Low Byte)
	
	LDX #$00  
	
-	
	LDA $0D85|!base2,X             ; \ Get address of graphics to copy 
	CMP !optimizer2,x
	BNE + ; if $0D85,X didn't change then doesn't load
	LDA $2116
	CLC
	ADC #$0020
	STA $2116
	BRA .next1
+
	STA !optimizer2,x
	STA $02               ; / ; A Address (Low Byte)
	
	LDA #$0040              ; \ x40 bytes will be transferred 
	STA $05               ; / ; Number Bytes to Transfer (Low Byte) (DMA)
	
	STY $420B               ; / ; Regular DMA Channel Enable
.next1
	INX                       ; \ Move to next address 
	INX                       ; /  
	CPX #$06
	BCC +
	PHX
	LDX #$7E
	STX $04
	PLX
+
	CPX $0D84|!base2               ; \ Repeat last segment while X<$0D84 
	BCC -           ; /
	
	LDA !marioNormalCustomGFXBnkReal
	STX $04
	
	LDA #$6100              ; \ Set Address for VRAM Read/Write to x6100 
	STA $2116               ; / ; Address for VRAM Read/Write (Low Byte)
	
	LDX #$00   
	
-        
	LDA $0D8F|!base2,X             ; \ Get address of graphics to copy 
	CMP !optimizer3,x
	BNE + ; if $0D8F,X didn't change then doesn't load
	LDA $2116
	CLC
	ADC #$0020
	STA $2116
	BRA .next2
+
	STA !optimizer3,x
	STA $02               ; / ; A Address (Low Byte)
	
	LDA #$0040              ; \ x40 bytes will be transferred 
	STA $05               ; / ; Number Bytes to Transfer (Low Byte) (DMA)
	
	STY $420B               ; / ; Regular DMA Channel Enable
.next2
	INX                       ; \ Move to next address 
	INX                       ; /  
	CPX #$06
	BCC +
	PHX
	LDX #$7E
	STX $04
	PLX
+
	CPX $0D84|!base2               ; \ Repeat last segment while X<$0D84 
	BCC -           ; /  
	
RTS                       ; Return 	

.CompleteDMA
	STA !lastLevelMode
	LDA !marioNormalCustomGFXBnkReal               ; \ Set bank to x7E
.ignoreBank	
	STA !optimizer6
	STA $04               ; / ; A Address Bank
	
	REP #$20                  ; 16 bit A ; Accum (16 bit)          

	LDA #$67F0              
	STA $2116               ; Address for VRAM Read/Write (Low Byte)
	
	LDA $0D99|!base2
	STA !optimizer
	STA $02               ; A Address (Low Byte)

	LDA #$0020              ; \ x20 bytes will be transferred 
	STA $05               ; / ; Number Bytes to Transfer (Low Byte) (DMA)
	
	STY $420B               ; Transfer ; Regular DMA Channel Enable
	
	LDA #$6000              ; \ Set Address for VRAM Read/Write to x6000 
	STA $2116               ; / ; Address for VRAM Read/Write (Low Byte)
	
	LDX #$00  
	
-	
	LDA $0D85|!base2,X             ; \ Get address of graphics to copy 
	STA !optimizer2,x
	STA $02               ; / ; A Address (Low Byte)
	
	LDA #$0040              ; \ x40 bytes will be transferred 
	STA $05               ; / ; Number Bytes to Transfer (Low Byte) (DMA)
	
	STY $420B               ; / ; Regular DMA Channel Enable
	INX                       ; \ Move to next address 
	INX                       ; /  
	CPX #$06
	BCC +
	PHX
	LDX #$7E
	STX $04
	PLX
+
	CPX $0D84|!base2               ; \ Repeat last segment while X<$0D84 
	BCC -           ; /  
	
	LDA #$6100              ; \ Set Address for VRAM Read/Write to x6100 
	STA $2116               ; / ; Address for VRAM Read/Write (Low Byte)
	
	LDX #$00   
	
-        
	LDA $0D8F|!base2,X             ; \ Get address of graphics to copy 
	STA !optimizer3,x
	STA $02               ; / ; A Address (Low Byte)
	
	LDA #$0040              ; \ x40 bytes will be transferred 
	STA $05               ; / ; Number Bytes to Transfer (Low Byte) (DMA)
	
	STY $420B               ; / ; Regular DMA Channel Enable
	INX                       ; \ Move to next address 
	INX                       ; / 
	CPX #$06
	BCC +
	PHX
	LDX #$7E
	STX $04
	PLX
+	
	CPX $0D84|!base2               ; \ Repeat last segment while X<$0D84 
	BCC -           ; /  
	
RTS                       ; Return 


MarioGFXDMA:

;Tile 1
	LDA #$67F0              
	STA $2116               ; Address for VRAM Read/Write (Low Byte)
	LDA $0D99|!base2               
	STA $02               ; A Address (Low Byte)
	LDX #$7E                ; \ Set bank to x7E 
	STX $04               ; / ; A Address Bank
	LDA #$0020              ; \ x20 bytes will be transferred 
	STA $05               ; / ; Number Bytes to Transfer (Low Byte) (DMA)
	STY $420B               ; Transfer ; Regular DMA Channel Enable

;First Row
	LDA #$6000              ; \ Set Address for VRAM Read/Write to x6000 
	STA $2116               ; / ; Address for VRAM Read/Write (Low Byte)
	LDX #$00                
-
	LDA $0D85|!base2,x        ; \ Get address of graphics to copy 
	STA $02                   ; / ; A Address (Low Byte)
	LDA #$0040                ; \ x40 bytes will be transferred 
	STA $05                   ; / ; Number Bytes to Transfer (Low Byte) (DMA)
	STY $420B                 ; / ; Regular DMA Channel Enable
	INX                       ; \ Move to next address 
	INX                       ; /  
	CPX $0D84|!base2          ; \ Repeat last segment while X<$0D84 
	BCC -			          ; /  

;Second Row
	LDA #$6100              ; \ Set Address for VRAM Read/Write to x6100 
	STA $2116               ; / ; Address for VRAM Read/Write (Low Byte)
	LDX #$00                
-
	LDA $0D8F|!base2,x        ; \ Get address of graphics to copy 
	STA $02                   ; / ; A Address (Low Byte)
	LDA #$0040                ; \ x40 bytes will be transferred 
	STA $05                   ; / ; Number Bytes to Transfer (Low Byte) (DMA)
	STY $420B                 ; / ; Regular DMA Channel Enable
	INX                       ; \ Move to next address 
	INX                       ; /  
	CPX $0D84|!base2          ; \ Repeat last segment while X<$0D84 
	BCC -			          ; /  
	
	RTS                       ; Return 