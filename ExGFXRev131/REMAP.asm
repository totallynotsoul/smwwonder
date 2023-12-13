;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LM1.7x Tilemap Remapper Patch v1.2.2 (for LM1.91+)
; coded by edit1754
;
; must be patched to a LM1.7+ edited ROM
;
; Allows you to remap the layer 1 and 2 tilemaps in the VRAM
; Allows you to directly swap layer 1 and 2 right as they get uploaded
; Allows you to disable uploading tiles to certain layers
;  - useful if you want to upload tilemaps yourself with your own code (ex: bypassing BG map16)
;
; To change the VRAM address for a certain layer for a certain level, find
; the level's entry in the correct table. This number is the high byte of
; one-half of the starting VRAM address.
;
; To swap layers 1 and 2, enable the first flag in the Extra Flags table
; for your level. So %0000 -> %0001
;
; To disable L1_Load/L1_Gameplay, enable the second flag in the Extra Flags table
; for your level. So %0000 -> %0010
;
; To disable L2_Load/L2_Gameplay, enable the third flag in the Extra Flags table
; for your level. So %0000 -> %0100
;
; To force layer priority in the FG, enable the fourth flag in the Extra Flags table
; for your level. So %0000 -> %1000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	!SA1ROM = 1
	if read1($00FFD7) == $0D
		fullsa1rom
	else
		sa1rom
	endif
	!Base1 = $3000
	!Base2 = $6000
	!FastROM = $000000
	!StripeImageDMA1 = $0020
	!StripeImageDMA2 = %00000100
else
	!SA1ROM = 0
	!Base1 = $0000
	!Base2 = $0000
	!FastROM = $800000
	!StripeImageDMA1 = $0010
	!StripeImageDMA2 = %00000010
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Things you can change
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!LMVersion = 340
		!FreeRAM1 = $0F3A|!Base2	; 2 bytes	\ change if you have an
		!FreeRAM2 = $0F3C|!Base2	; 2 bytes	/ ASM hack that uses them
		!GFXBuffer = $7EAD00	; GFX Decompression buffer. Generally, leave this alone.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Things you probably shouldn't change
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!LevelNum = $010B|!Base2
		!GFXBuffer = $7EAD00	; GFX Decompression buffer. Generally, leave this alone.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; levelnum.ips (disassembly) - credit goes to BMF for this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($0081E2) != $5C
	error "You need to install Lunar Magic's VRAM patch before you can install this patch!"
endif
if read1($0FFFEB) == $01
elseif read1($0FFFEB) == $02
else
	error "You need to install the LC_LZ2 (Optimized for Speed) or LC_LZ3 (Better Compression) patches in Lunar Magic before you can install this patch!"
endif


ORG $05D8B9
		JSR LevelNumCode

ORG $05DC46
LevelNumCode:
		LDA.b $0E  			; Load level number, 1st part of hijacked code
		STA.w !LevelNum		; Store it in free RAM
		ASL A    				; 2nd part of hijacked code
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hijacks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc "VRAMPatchHijacks.asm"
incsrc "transparencyfix.asm"
incsrc "genericuploader.asm"

org !Hijack1
autoclean	JML SetUpScreen_Hijack
		NOP #6

org $00871E
		JML NewStripeImageRoutine_Start

org !Hijack2
		JML NewStripeImageRoutine_BackFrom

org !Hijack3
		JML NewStripeImageRoutine_BackFrom

org !Hijack4
		JML NewStripeImageRoutine_BackFrom

org !Hijack4
		JML NewStripeImageRoutine_BackFrom

org !Hijack33
		JML NewStripeImageRoutine_BackFrom

org !Hijack5
		ORA.w !FreeRAM1		; .commitl1

org !Hijack6
		ORA.w !FreeRAM2		; .commitl2

org !Hijack7
		JML L1Load_Hijack	; L1Load
		NOP

org !Hijack8
		JML L2Load_Hijack	; L2Load
		NOP

org !Hijack9
		JSL L1Gameplay_Hijack	; L1GameplayX
		NOP

org !Hijack10
		JSL L1Gameplay_Hijack	; L1GameplayY
		NOP

org !Hijack11
		JSL L2Gameplay_Hijack	; L2GameplayX
		NOP

org !Hijack12
		JSL L2Gameplay_Hijack	; L2GameplayY
		NOP

org !Hijack13
 		ORA.w !FreeRAM1

org !Hijack14
		AND.w #$7C1F		; increase range

org !Hijack15
		ORA.w !FreeRAM2

org !Hijack16
		ORA.w !FreeRAM1

org !Hijack17
		ORA.w !FreeRAM1

org !Hijack18
		ORA.w !FreeRAM1

org !Hijack19
		AND.w #$7C1F		; increase range

org !Hijack20
		ORA.w !FreeRAM1

org !Hijack21
		ORA.w !FreeRAM2

org !Hijack22
		ORA.w !FreeRAM2

org !Hijack23
		ORA.w !FreeRAM2

org !Hijack24
		ORA.w !FreeRAM2

org !Hijack25
		ORA.w !FreeRAM2

org !Hijack26
		ORA.w !FreeRAM2

if !LMVersion >= 333
else
org !Hijack27
		ORA.w !FreeRAM2
endif

org $008270
		JSL ScrollSwap
		NOP
		
org !Hijack28
		JML VerticalWriterL1_Hijack
		;NOP #2
		
org !Hijack29
		JSL HorizontalWriterL1_Hijack
		NOP #2

org !Hijack30
		JSL HorizontalWriterL1_Hijack
 		NOP #2
		
org !Hijack31
		JSL HorizontalWriterFullL1_Hijack
		NOP #2
		
org !Hijack32
		JSL HorizontalWriterFullL1_Hijack
		NOP #2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

freecode
AllowedModes:
		db $00,$00,$00,$01,$01,$01,$01,$01
		db $01,$01,$01,$01,$00,$00,$00,$00
		db $00,$01,$01,$01,$01,$00,$00,$00
		db $00,$00,$00,$00,$00

SetUpScreen_Hijack:
		PHB : PHK : PLB			; back up DB, current bank -> DB
		REP #%00010000				; 16-bit XY
		LDX.w !LevelNum			; level number -> X
		LDA.w ExtraFlags,x		; \  reverse tilemap
		AND.b #%00000001			;  | addresses if
		BNE SetUpScrn_Swap		; /  flag is set
		LDA.w Layer1VRAM,x		; get layer 1 tilemap address
		ORA.b #%00000001			; make tilemap 64 tiles wide
		STA.w $2107				; store to $2107 (layer 1 tilemap register)
		LDA.w Layer2VRAM,x		; get layer 2 tilemap address
		ORA.b #%00000001			; make tilemap 64 tiles wide
		STA.w $2108				; store to $2108 (layer 2 tilemap register)
		SEP #%00010000				; 8-bit XY
		PLB							; restore DB
		JML !JMLLoc1				; jump back to custom screen setup subroutine

SetUpScrn_Swap:
		LDA.w Layer2VRAM,x		; get layer *2* tilemap address
		ORA.b #%00000001			; make tilemap 64 tiles wide
		STA.w $2107				; store to $2107 (layer 1 tilemap register)
		LDA.w Layer1VRAM,x		; get layer *1* tilemap address
		ORA.b #%00000001			; make tilemap 64 tiles wide
		STA.w $2108				; store to $2108 (layer 2 tilemap register)
		SEP #%00010000				; 8-bit XY
		PLB							; restore DB
		JML !JMLLoc1				; jump back to custom screen setup subroutine

L1Load_Hijack:
		SEP #%00100000				; 8-bit A
		REP #%00010000				; 16-bit X/Y
		LDX.w !LevelNum			; level number -> X
		PHB : PHK : PLB			; back up DB, current bank -> DB
		LDA.w ExtraFlags,x		; \
		AND.b #%00000010			;  | check if disabled
		BNE Cancel_L1_L2_Load		; /
		STZ.w !FreeRAM1			; \
		LDA.w Layer1VRAM,x		;  | layer 1 tilemap address 
		STA.w !FreeRAM1+1			; /
		PLB							; restore DB
		SEP #%00110000				; \ hijacked
		LDX.w $0100|!Base2		; / code
		JML !JMLLoc2				; go back

L2Load_Hijack:
		SEP #%00100000				; 8-bit A
		REP #%00010000				; 16-bit X/Y
		LDX.w !LevelNum			; level number -> X
		PHB : PHK : PLB			; back up DB, current bank -> DB
		LDA.w ExtraFlags,x		; \
		AND.b #%00000100			;  | check if disabled
		BNE Cancel_L1_L2_Load		; /
		STZ.w !FreeRAM2			; \
		LDA.w Layer2VRAM,x		;  | layer 2 tilemap address
		STA.w !FreeRAM2+1			; /
		PLB							; restore DB
		SEP #%00110000				; \ hijacked
		LDX.w $0100|!Base2		; / code
		JML !JMLLoc4				; go back

Cancel_L1_L2_Load:
		PLB
		SEP #%00110000
		RTL

L1Gameplay_Hijack:
		SEP #%00100000				; 8-bit A
		REP #%00010000				; 16-bit X/Y
		LDX.w !LevelNum			; level number -> X
		PHB : PHK : PLB			; back up DB, current bank -> DB
		LDA.w ExtraFlags,x		; \
		AND.b #%00000010			;  | check if disabled
		BNE Cancel_L1_L2_GP		; /
		STZ.w !FreeRAM1			; \
		LDA.w Layer1VRAM,x		;  | layer 1 tilemap address
		STA.w !FreeRAM1+1			; /
		PLB							; restore DB
		SEP #%00110000				; \ hijacked
		LDA.w $1925|!Base2		; / code
		RTL

L2Gameplay_Hijack:
		SEP #%00100000				; 8-bit A
		REP #%00010000				; 16-bit X/Y
		LDX.w !LevelNum			; level number -> X
		PHB : PHK : PLB			; back up DB, current bank -> DB
		LDA.w ExtraFlags,x		; \
		AND.b #%00000100			;  | check if disabled
		BNE Cancel_L1_L2_GP		; /
		STZ.w !FreeRAM2			; \
		LDA.w Layer2VRAM,x		;  | layer 2 tilemap address
		STA.w !FreeRAM2+1			; /
		PLB							; restore DB
		SEP #%00110000				; \ hijacked
		LDA.w $1925|!Base2		; / code
		RTL

Cancel_L1_L2_GP:
		PLB
		PLA
		PLA
		PLA
		SEP #%00110000
		RTL

ScrollSwap:
		LDA.b $21					; \ hijacked
		STA.w $2110				; / code
		PHB							; Back up DB
		PHK : PLB					; B -> DB
		LDY.w $0100|!Base2		; \
		LDA.w AllowedModes,y		;  | Allowed game mode?
		BNE .CustScrollChk		; /
		PLB							; restore DB
		RTL
.CustScrollChk
		REP #%00010000				; 16-bit XY
		LDY.w !LevelNum			; level number -> X
		LDA.w ExtraFlags,y		; get extra flags
		PLB							; restore DB
		SEP #%00010000				; 8-bit XY
		AND.b #%00000001			; \ if first flag set then
		BNE .CustomScroll			; / rewrite scrroll registers
		RTL
.CustomScroll
		LDA.b $1A					; \
		STA.w $210F				;  | layer 1
		LDA.b $1B					;  | scroll data
		STA.w $210F				;  | into layer 2
		LDA.b $1C					;  | scroll regs
		;CLC							;  |
		;ADC.w $1888|!Base2		;  |
		STA.w $2110				;  |
		LDA.b $1D					;  |
		;ADC.w $1898|!Base2		;  |
		STA.w $2110				; /
		LDA.b $1E					; \
		STA.w $210D				;  | layer 2
		LDA.b $1F					;  | scroll data
		STA.w $210D				;  | into layer 1
		LDA.b $20					;  | scroll regs
		STA.w $210E				;  |
		LDA.b $21					;  |
		STA.w $210E				; /
		RTL

VerticalWriterL1_Hijack:
		PHK							; \
		PEA.w .Ret1-1				;  | Hijacked code
		PEA.w !PEALoc1-1			;  | (JSR's turned
		JML !JMLLoc5				;  | into local JSL's)
.Ret1
		PHK							;  |
		PEA.w .Ret2-1				;  |
		PEA.w !PEALoc1-1			;  |
		JML !JMLLoc6				; /
.Ret2
		PHY							; backup Y
		REP #%00010000				; 16-bit X/Y
		LDY.w !LevelNum			; level number -> X
		PHB : PHK : PLB			; back up DB, current bank -> DB
		LDA.w ExtraFlags,y		; get extra flags
		PLB							; restore DB
		SEP #%00010000				; 8-bit X/Y
		PLY							; restore Y
		AND.w #%00001000			; check if priority-force bit set (.w because 16-bit)
		BEQ .Return				; if not, then return
		JSR L1yBufferPriority		; force priority
.Return
		JML !JMLLoc7				; go back
		
HorizontalWriterL1_Hijack:
		PHK							; \
		PEA.w .Ret1-1				;  | Hijacked code
		PEA.w !PEALoc1-1			;  | (JSR's turned
		JML !JMLLoc8				;  | into local JSL's)
.Ret1
		PHK							;  |
		PEA.w .Ret2-1				;  |
		PEA.w !PEALoc1-1			;  |
		JML !JMLLoc9				; /
.Ret2
		PHY							; backup Y
		REP #%00010000				; 16-bit X/Y
		LDY.w !LevelNum			; level number -> X
		PHB : PHK : PLB			; back up DB, current bank -> DB
		LDA.w ExtraFlags,y		; get extra flags
		PLB							; restore DB
		SEP #%00010000				; 8-bit X/Y
		PLY							; restore Y
		AND.w #%00001000			; check if priority-force bit set (.w because 16-bit)
		BEQ .Return				; if not, then return
		JSR L1xBufferPriority		; force priority
.Return
		RTL
		
HorizontalWriterFullL1_Hijack:
		PHK							; \
		PEA.w .Ret1-1				;  | Hijacked code
		PEA.w !PEALoc1-1			;  | (JSR's turned
		JML !JMLLoc10				;  | into local JSL's)
.Ret1
		PHK							;  |
		PEA.w .Ret2-1				;  |
		PEA.w !PEALoc1-1			;  |
		JML !JMLLoc9				; /
.Ret2
		PHY							; backup Y
		REP #%00010000				; 16-bit X/Y
		LDY.w !LevelNum			; level number -> X
		PHB : PHK : PLB			; back up DB, current bank -> DB
		LDA.w ExtraFlags,y		; get extra flags
		PLB							; restore DB
		SEP #%00010000				; 8-bit X/Y
		PLY							; restore Y
		AND.w #%00001000			; check if priority-force bit set (.w because 16-bit)
		BEQ .Return				; if not, then return
		JSR L1xBufferPriority		; force priority
.Return
		RTL

L1yBufferPriority:
		PHB
		LDX.b #$7F
		PHX
		PLB
		LDA.w #$2000
		TSB.w $820B
		TSB.w $820D
		TSB.w $820F
		TSB.w $8211
		TSB.w $8213
		TSB.w $8215
		TSB.w $8217
		TSB.w $8219
		TSB.w $821B
		TSB.w $821D
		TSB.w $821F
		TSB.w $8221
		TSB.w $8223
		TSB.w $8225
		TSB.w $8227
		TSB.w $8229
		TSB.w $822B
		TSB.w $822D
		TSB.w $822F
		TSB.w $8231
		TSB.w $8233
		TSB.w $8235
		TSB.w $8237
		TSB.w $8239
		TSB.w $823B
		TSB.w $823D
		TSB.w $823F
		TSB.w $8241
		TSB.w $8243
		TSB.w $8245
		TSB.w $8247
		TSB.w $8249
		TSB.w $824B
		TSB.w $824D
		TSB.w $824F
		TSB.w $8251
		TSB.w $8253
		TSB.w $8255
		TSB.w $8257
		TSB.w $8259
		TSB.w $825B
		TSB.w $825D
		TSB.w $825F
		TSB.w $8261
		TSB.w $8263
		TSB.w $8265
		TSB.w $8267
		TSB.w $8269
		TSB.w $826B
		TSB.w $826D
		TSB.w $826F
		TSB.w $8271
		TSB.w $8273
		TSB.w $8275
		TSB.w $8277
		TSB.w $8279
		TSB.w $827B
		TSB.w $827D
		TSB.w $827F
		TSB.w $8281
		TSB.w $8283
		TSB.w $8285
		TSB.w $8287
		TSB.w $8289
		PLB
		RTS
		
L1xBufferPriority:
		LDA.w #$2000
		TSB.w $1BE6|!Base2
		TSB.w $1BE8|!Base2
		TSB.w $1BEA|!Base2
		TSB.w $1BEC|!Base2
		TSB.w $1BEE|!Base2
		TSB.w $1BF0|!Base2
		TSB.w $1BF2|!Base2
		TSB.w $1BF4|!Base2
		TSB.w $1BF6|!Base2
		TSB.w $1BF8|!Base2
		TSB.w $1BFA|!Base2
		TSB.w $1BFC|!Base2
		TSB.w $1BFE|!Base2
		TSB.w $1C00|!Base2
		TSB.w $1C02|!Base2
		TSB.w $1C04|!Base2
		TSB.w $1C06|!Base2
		TSB.w $1C08|!Base2
		TSB.w $1C0A|!Base2
		TSB.w $1C0C|!Base2
		TSB.w $1C0E|!Base2
		TSB.w $1C10|!Base2
		TSB.w $1C12|!Base2
		TSB.w $1C14|!Base2
		TSB.w $1C16|!Base2
		TSB.w $1C18|!Base2
		TSB.w $1C1A|!Base2
		TSB.w $1C1C|!Base2
		TSB.w $1C1E|!Base2
		TSB.w $1C20|!Base2
		TSB.w $1C22|!Base2
		TSB.w $1C24|!Base2
		TSB.w $1C26|!Base2
		TSB.w $1C28|!Base2
		TSB.w $1C2A|!Base2
		TSB.w $1C2C|!Base2
		TSB.w $1C2E|!Base2
		TSB.w $1C30|!Base2
		TSB.w $1C32|!Base2
		TSB.w $1C34|!Base2
		TSB.w $1C36|!Base2
		TSB.w $1C38|!Base2
		TSB.w $1C3A|!Base2
		TSB.w $1C3C|!Base2
		TSB.w $1C3E|!Base2
		TSB.w $1C40|!Base2
		TSB.w $1C42|!Base2
		TSB.w $1C44|!Base2
		TSB.w $1C46|!Base2
		TSB.w $1C48|!Base2
		TSB.w $1C4A|!Base2
		TSB.w $1C4C|!Base2
		TSB.w $1C4E|!Base2
		TSB.w $1C50|!Base2
		TSB.w $1C52|!Base2
		TSB.w $1C54|!Base2
		TSB.w $1C56|!Base2
		TSB.w $1C58|!Base2
		TSB.w $1C5A|!Base2
		TSB.w $1C5C|!Base2
		TSB.w $1C5E|!Base2
		TSB.w $1C60|!Base2
		TSB.w $1C62|!Base2
		TSB.w $1C64|!Base2
		TSB.w $1C66|!Base2
		TSB.w $1C68|!Base2
		TSB.w $1C6A|!Base2
		TSB.w $1C6C|!Base2
		TSB.w $1C6E|!Base2
		TSB.w $1C70|!Base2
		TSB.w $1C72|!Base2
		TSB.w $1C74|!Base2
		TSB.w $1C76|!Base2
		TSB.w $1C78|!Base2
		TSB.w $1C7A|!Base2
		TSB.w $1C7C|!Base2
		TSB.w $1C7E|!Base2
		TSB.w $1C80|!Base2
		TSB.w $1C82|!Base2
		TSB.w $1C84|!Base2
		TSB.w $1C86|!Base2
		TSB.w $1C88|!Base2
		TSB.w $1C8A|!Base2
		TSB.w $1C8C|!Base2
		TSB.w $1C8E|!Base2
		TSB.w $1C90|!Base2
		TSB.w $1C92|!Base2
		TSB.w $1C94|!Base2
		TSB.w $1C96|!Base2
		TSB.w $1C98|!Base2
		TSB.w $1C9A|!Base2
		TSB.w $1C9C|!Base2
		TSB.w $1C9E|!Base2
		TSB.w $1CA0|!Base2
		TSB.w $1CA2|!Base2
		TSB.w $1CA4|!Base2
		TSB.w $1CA6|!Base2
		TSB.w $1CA8|!Base2
		TSB.w $1CAA|!Base2
		TSB.w $1CAC|!Base2
		TSB.w $1CAE|!Base2
		TSB.w $1CB0|!Base2
		TSB.w $1CB2|!Base2
		TSB.w $1CB4|!Base2
		TSB.w $1CB6|!Base2
		TSB.w $1CB8|!Base2
		TSB.w $1CBA|!Base2
		TSB.w $1CBC|!Base2
		TSB.w $1CBE|!Base2
		TSB.w $1CC0|!Base2
		TSB.w $1CC2|!Base2
		TSB.w $1CC4|!Base2
		TSB.w $1CC6|!Base2
		TSB.w $1CC8|!Base2
		TSB.w $1CCA|!Base2
		TSB.w $1CCC|!Base2
		TSB.w $1CCE|!Base2
		TSB.w $1CD0|!Base2
		TSB.w $1CD2|!Base2
		TSB.w $1CD4|!Base2
		TSB.w $1CD6|!Base2
		TSB.w $1CD8|!Base2
		TSB.w $1CDA|!Base2
		TSB.w $1CDC|!Base2
		TSB.w $1CDE|!Base2
		TSB.w $1CE0|!Base2
		TSB.w $1CE2|!Base2
		TSB.w $1CE4|!Base2
		RTS


NewStripeImageRoutine:
.Return
		SEP #%00110000
		JML $008438|!FastROM			; JML to a "Reliable" RTS in bank $00

.Start
		REP #%00010000					; X/Y is 16-bit (A is 8-bit from before)
		STA.w $4304|!StripeImageDMA1	; A -> Address Bank

		PHB								; Backup DB
		PHK : PLB						; B -> DB

		LDX.w !LevelNum				; level number -> X
		STZ.w !FreeRAM1				; \
		LDA.w Layer1VRAM,x			;  | layer 1 tilemap address
		STA.w !FreeRAM1+1				; /
		STZ.w !FreeRAM2				; \
		LDA.w Layer2VRAM,x			;  | layer 2 tilemap address
		STA.w !FreeRAM2+1				; /

		STZ.b $0D						; \
		LDY.w $0100|!Base2			;  | $0D will be set
		LDA.w AllowedModes,y			;  | if force priority
		BEQ +							;  |
		LDY.w !LevelNum				;  |
		LDA.w ExtraFlags,y			;  |
		AND.b #%00001000				;  |
		BEQ +							;  |
		INC.b $0D						; /
+
		PLB								; Restore DB

		LDY.w #$0000					; Stripe index <- 0

.Loop
		LDA.b [$00],y					; First header byte
		BMI .Return					; if EOF bit set, return ;;IN ORIGINAL ROUTINE, structured w/ BPL
		STA.b $04						; -> $04
		INY								; index++

		LDA.b [$00],y					; Second header byte
		STA.b $03						; -> $03 (so $03-$04 is header bytes 2,1 - endian swap - contains address)
		INY								; index++

		LDA.b #$18						; \ DMA to $[21]18 (VRAM)
		STA.w $4301|!StripeImageDMA1	; / ;;IN ORIGINAL ROUTINE, was after ROL $07, moved to preserve A

		LDA.b [$00],y					; Third header byte
		STZ.b $07						; \					;possibly use STZ somewhere else?
		ASL								;  | direction bit -> $07 (%00000001)
		ROL $07						; /
		AND.b #%10000000				; Since this is ASL'd, the RLE bit is %10000000
		STA.b $05						; RLE bit -> %10000000 $05 ($05 is just used for a BEQ/BNE check)
		STZ.b $06						; The BEQ/BNE check will be done in 16-bit mode later, so account for that

		BPL +							; if RLE is unset, then A would be 0. Keep it that way.
		LDA.b #%00001000				; Case RLE set: A <- %00001000 (enable inc/dec)
+		ORA.b #%00000001				; Afterwards in either case, set bit %00000001 (DMA transfer type)
		STA.w $4300|!StripeImageDMA1	; This is used for the DMA parameters.

		JML !JMLLoc3					; LM1.7 Stripe Hijack (the return JML is redirected near top of file)
.BackFrom
		STA.w $2116					; $2116 (Address for VRAM R/W address)

		LDA.b [$00],y					; Third (again) and Fourth header bytes (contain length-1)
		XBA								; Endian swap
		AND.w #$3FFF					; Erase RLE bits and Directional bits
		INC								; length-1 ++
		STA $4305|!StripeImageDMA1	; # of bytes to transfer (DMA)
		TAX								; Length -> X (for later)

		INY #2							; index += 2
		TYA								; index -> A
		CLC								; \ add stripe start address
		ADC.b $00						; /
		STA.w $4302|!StripeImageDMA1	; Source address for DMA

		LDA.b $05						; \ RLE or Regular?
		BEQ .Regular        			; /

.Rle
		LDA.b $0D						; \  Skip priority force
		AND.w #$00FF					;  | if not enabled
		BEQ +							; /

		LDA.b $03						; \
		SEC								;  | return if not
		SBC.w !FreeRAM1				;  | writing to
		CMP.w #$1000					;  | layer 1
		BCS +							; /

		LDA.w #$2000					; \
		ORA.b [$00],y					;  | force priority
		STA.b [$00],y					; /

+		SEP #%00100000					; A is 8-bit (X/Y is 16-bit from before)
		LDA.b $07						; $07 contains VRAM Inc value (determines direction)
		STA.w $2115					; VRAM address increment value

		LDA.b #!StripeImageDMA2		; \ DMA Channel index 1
		STA.w $420B					; / Start transfer

		LDA.b #$19						; \ DMA to $[21]19 (VRAM byte 2)
		STA.w $4301|!StripeImageDMA1	; /

		REP.b #%00100001				; A is 16-bit (X/Y is 16-it from before) - AND set carry flag
		LDA.b $03						; $03 contains VRAM R/W address
		STA.w $2116					; $2116 (Address for VRAM R/W address)

		TYA								; index -> A
		ADC.b $00						; add stripe start address (Carry flag set by REP above)
		INC								; +1 because this is the next byte of the two to repeat
		STA.w $4302|!StripeImageDMA1	; Source address for DMA

		STX.w $4305|!StripeImageDMA1	; Number of bytes to transfer (Stored in X from before)

		LDX.w #$0002					; 2 bytes for transfer since it's RLE (wait, what does this really do?)

		;BRA +							; skip the non-RLE priority force

.Regular
		LDA.b $0D						; \  Skip priority force
		AND.w #$00FF					;  | if not enabled
		BEQ +							; /

		LDA.b $03						; \
		SEC								;  | return if not
		SBC.w !FreeRAM1				;  | writing to
		CMP.w #$1000					;  | layer 1
		BCS +							; /

		PHY								; backup Y
		PHX								; backup X
		TXA								; \
		LSR								;  | X contains number of bytes, /2 for # tiles
		DEC								;  | - 1 for loop
		TAX								; /
.PrLoop
		LDA.w #$2000					; \
		ORA.b [$00],y					;  | force priority
		STA.b [$00],y					; /
		INY								; \ next tile
		INY								; / index
		DEX								; next tile
		BPL .PrLoop					; loop
		PLX								; restore X
		PLY								; restore Y

+		STX.b $03						; X, Number of bytes to transfer, goes to $03
		TYA								; index -> A
		CLC								; \ A (index)
		ADC.b $03						; / += #bytes to transfer
		TAY								; new value -> index (to skip ahead of all the data)

		SEP #%00100000					; A is 8-bit (X/Y is 16-bit from before)
		LDA.b $07						; $07 contains VRAM Inc value (determines direction)
		ORA.b #%10000000				; Set bit 7
		STA.w $2115					; VRAM address increment value

		LDA.b #!StripeImageDMA2		; \ DMA Channel index 1
		STA.w $420B					; / Start transfer

		JMP .Loop						; Loop back and check

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Level Tables - high bytes of starting VRAM addresses for Layers 1 and 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Layer1VRAM:
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 000-00F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 010-01F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 020-02F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 030-03F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 040-04F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 050-05F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 060-06F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 070-07F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 080-08F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 090-09F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 0A0-0AF
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 0B0-0BF
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 0C0-0CF
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 0D0-0DF
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 0E0-0EF
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 0F0-0FF
		db $30,$30,$30,$30,$30,$48,$48,$48,$48,$48,$30,$30,$48,$48,$30,$30	; Levels 100-10F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 110-11F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 120-12F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 130-13F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 140-14F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 150-15F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 160-16F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 170-17F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 180-18F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 190-19F
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 1A0-1AF
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 1B0-1BF
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 1C0-1CF
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 1D0-1DF
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 1E0-1EF
		db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30	; Levels 1F0-1FF

Layer2VRAM:
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 000-00F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 010-01F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 020-02F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 030-03F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 040-04F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 050-05F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 060-06F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 070-07F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 080-08F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 090-09F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 0A0-0AF
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 0B0-0BF
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 0C0-0CF
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 0D0-0DF
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 0E0-0EF
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 0F0-0FF
		db $38,$38,$38,$38,$38,$58,$58,$58,$58,$58,$38,$38,$58,$58,$38,$38	; Levels 100-10F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 110-11F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 120-12F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 130-13F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 140-14F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 150-15F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 160-16F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 170-17F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 180-18F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 190-19F
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 1A0-1AF
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 1B0-1BF
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 1C0-1CF
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 1D0-1DF
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 1E0-1EF
		db $38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38,$38	; Levels 1F0-1FF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Extra Flag table - first bit is swap layers, 2nd bit is disable layer 1 upload, 3rd bit is disable layer 2 upload, 4th bit is force L1 priority
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ExtraFlags:
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 000-00F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 010-01F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 020-02F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 030-03F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 040-04F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 050-05F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 060-06F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 070-07F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 080-08F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 090-09F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 0A0-0AF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 0B0-0BF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 0C0-0CF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 0D0-0DF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 0E0-0EF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 0F0-0FF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 100-10F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 110-11F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 120-12F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 130-13F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 140-14F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 150-15F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 160-16F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 170-17F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 180-18F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 190-19F
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 1A0-1AF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 1B0-1BF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 1C0-1CF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 1D0-1DF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 1E0-1EF
		db %0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000,%0000	; Levels 1F0-1FF
