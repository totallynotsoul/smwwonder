;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; ScrollHDMA main and init code
;
; After decompressing the table, jump to
; ScrollHDMA_init and ScrollHDMA_main in the init and
; main code of the inserted code, respectively. Keep in
; mind that both codes have their own inputs.
;
; Input (init):
;	A (8-bit): Bank of the HDMA table buffer
;	X (16-bit): Address of the red-green table buffer
;	Y (16-bit): Address of the blue table buffer
;
; Input (main):
;	A (16-bit): The gradient's offset
;	$00 (16-bit): Address of the red-green table buffer
;	$02 (16-bit): Address of the blue table buffer
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FreeRAM_RG_Ptr = $7F0000	;\ Must be in the same bank.
!FreeRAM_B_Ptr = $7F0007	;/

!EnableFailsafe = 0
!EnableSA1Boost = 1			; If using SA-1: Boosts the level loading. Decompression table must be in BW-RAM. 

init:
	STA $4337	;\ Set the bank of the value tables
	STA $4347	;/
	
	!EnableBoosting #= !EnableSA1Boost*!sa1
	if !EnableBoosting
	print "Enable boosting."
		STX $03
		STY $05
		STA $8E
		%invoke_sa1(DecompressGradient)
	else
		JSL DecompressGradient
	endif

	LDX #$3242
	STX $4330
	LDX #$3240
	STX $4340
	LDX.w #!FreeRAM_RG_Ptr
	STX $4332	; Red-green table
	LDX.w #!FreeRAM_B_Ptr
	STX $4342	; Blue table
	LDA.b #!FreeRAM_RG_Ptr>>16
	STA $4334	; RAM bank
	STA $4344	; RAM bank

	SEP #$30
	LDX #$05
-	LDA.l InitHDMA,x
	STA !FreeRAM_RG_Ptr,x
	STA !FreeRAM_B_Ptr,x
	DEX
	BPL -

	LDA #$18
	TSB $0D9F|!addr
RTL

main:
	PHA
	ASL
	CLC : ADC $00
	STA !FreeRAM_RG_Ptr+1
	CLC : ADC #$00E0
	STA !FreeRAM_RG_Ptr+4
	PLA
	CLC : ADC $02
	STA !FreeRAM_B_Ptr+1
	CLC : ADC #$0070
	STA !FreeRAM_B_Ptr+4
	SEP #$20
RTL

; Don't change!
InitHDMA:
db $F0 : dw $0000
db $F0 : dw $0000
; db $00	; We already cover the whole screen, no termination byte needed.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; DecompressGradient
;
; Decompresses an HDMA gradient table into a
; scrollable HDMA table. The output table is index by
; HDMA indirect table.
; db $ll,$rr,$gg,$bb
; with $ll being the amount rows, $rr the red colour,
; $gg the green colour and $bb the blue colour.
;
; You can enable a failsafe where the HDMA won't scroll
;
; Input:
;	$00-$02: 24-Pointer to the compressed HDMA gradient
;	$0E: Height of the scroll HDMA (if desired)
;	A: Bank of the decompression tables
;	X: 16-Pointer to the red-green HDMA table
;	Y: 16-Pointer to the blue HDMA table
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Failsafe = "if !EnableFailsafe : "

DecompressGradient:
print "DecompressGradient: $",pc
	PHB
if !EnableBoosting
	LDA $8E
	PHA
	PLB
	REP #$10
else
	PHA
	PLB
	STX $03
	STY $05
endif
	LDY #$FFFF
!Failsafe	LDX $0E

.NextRow
	INY
	LDA [$00],y
	BNE .GoOn
.Return
if !EnableBoosting
	SEP #$30
endif
	PLB
RTL

.GoOn
	STA $0F
	INY
	LDA [$00],y
	STA $0C
	INY
	LDA [$00],y
	STA $0D
	INY
	LDA [$00],y
	STA $0E

..Loop
	LDA $0E
	STA ($05)
	REP #$20
	LDA $0C
	STA ($03)
	INC $03
	INC $03
	INC $05
	SEP #$20

!Failsafe	DEX
!Failsafe	BMI .Return
	DEC $0F
	BNE ..Loop
	BRA .NextRow
