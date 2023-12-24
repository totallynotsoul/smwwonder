;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generic ExGFX Uploader v1.2
; coded by edit1754
;
; This patch can be used to upload layer 3 tilemaps, since ExGFX files are compressed
; with a format (LZ2 or LZ3) that's far more space-efficient than stripe image.
; (I may release a tutorial on how to do this).
;
; The maximum size of an ExGFX file is 0x1B00 (6912) bytes due to decompression buffer size.
; If you need to upload a larger chunk of data, split it up into multiple ExGFX files.
;
; The format of the tables is as follows:
; - The 'Pointers' table contains local addresses to individual "GFX set" tables.
; - They default to $0000. Any value $0000-$7FFF means there is no pointer assigned.
; - To assign a "GFX Set" table to a certain level, replace '$0000' with the table's label.
; - GFX set tables consist of multiple double-word rows (dw $xxxx,$xxxx)
; - The first $xxxx is the VRAM address divided by 2. To upload to $7000, enter $3800
; - The second $xxxx is the ExGFX file number. To upload ExGFX233, enter $0233.
; - Each table is terminated by 'dw $FFFF' or any value $8000-$FFFF ($FFFF is by convention)
; - The ending line can be omitted in order to include the next table's graphics as well.
;   (this can be used as a space-saving technique)
; - Multple levels can share the same GFX Set table.
;
; UPDATE 1.1.1: now restores compatiblity with ExGFX80-FF in LM1.7
; - if you need to use genericuploader.asm for a LM1.6 ROM for whatever reason,
;   find: $0FF94F and replace with $0FF1DD
;   find: $0FF950 and replace with $0FF1DE
;
; UPDATE 1.1.2: no longer integrates LC_LZ2 optimization patch
; - also moved restored hijack to REVERT_genericuploader.asm
;   (APPLY THIS TO YOUR ROM FIRST IF YOU USED A VERSION BEFORE v1.1!!)
;
; UPDATE 1.2: new more efficient table format.
;
; **THIS PATCH WILL NOT WORK PROPERLY UNTIL YOU DO THE FOLLOWING**
; - In Lunar Magic 1.82+, under the Options menu, select 'Compression Options'
; - Select either "LC_LZ2 - Optimized for Speed" or "LC_LZ3 - Better Compression"
; - This is because the optimized decompression routines store the size of decompressed
;   data into a RAM address so that it can be determined when uploading to VRAM.
; - Otherwise, the patch will copy the wrong amount of data to the VRAM.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Code
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

		!LMVersion = 333
		!FreeRAM1 = $0F3A|!Base2	; 2 bytes	\ change if you have an
		!FreeRAM2 = $0F3C|!Base2	; 2 bytes	/ ASM hack that uses them
		!GFXBuffer = $7EAD00	; GFX Decompression buffer. Generally, leave this alone.
		!LevelNum = $010B|!Base2

Init:
		LDA.b #$80						; \ hijacked
		STA.w $2115					; / code
		LDA.b $71						; \  return if
		CMP.b #$0A						;  | Mario is in a
		BEQ .Return					; /  no-Yoshi intro
		LDA $0100|!Base2				; \
		CMP.b #$12						;  | only if at
		BEQ .InLevel					;  | beginning of
		CMP.b #$0C						;  | level or overworld
		BEQ .InOW						;  |
		CMP #$04						;  |
		BNE .Return					; /
		BRA .InLevel
	
.InOW:
		PHB : PHK : PLB				; back up B, K -> B
		REP #%00110000					; 16-bit A/X/Y

		LDA.w $1F11|!Base2			; \
		ASL								;  | Get pointer to
		TAY								;  | graphics set table
		LDA.w Pointers2,y				;  | if it exists.
		BPL +							; /  Otherwise return.
		BRA.b ++

.InLevel
		PHB : PHK : PLB				; back up B, K -> B
		REP #%00110000					; 16-bit A/X/Y

		LDA.w !LevelNum				; \
		ASL								;  | Get pointer to
		TAY								;  | graphics set table
		LDA.w Pointers,y				;  | if it exists.
		BPL +							;  | Otherwise return.
++
		TAY								; /

-		LDX.w $0000,y					; Get VRAM Address
		BMI +							; $8000+ means get out of here; we're done.
		LDA.w $0002,y					; Get ExGFX File Number
		JSR UploadGFXFile				; Upload
		INY #4							; Next entry index
		BRA -							; loop
+
		SEP #%00110000					; 8-bit A/X/Y
		PLB								; restore B

.Return
		RTL

UploadGFXFile:
		PHY								; back up Y
		PHX								; back up X
		CMP.w #$0032					; \ < 32, use code
		BCC .GFX00to31					; / for GFX 00-31
		CMP.w #$0080					; \ still < 80,
		BCC .UploadReturn				; / return
		CMP.w #$0100					; \ > 100, use code
		BCS .ExGFX100toFFF			; / for 100-FFF
.GFX80toFF
		AND.w #$007F					; reset most significant bit
		STA.b $8A						; \
		ASL A							;  | multiply by 3 using
		CLC								;  | shift-add method
		ADC.b $8A						; /
		TAY								; -> Y
		LDA.l $0FF94F|!FastROM		; \
		STA.b $06						;  | $0FF94F-$0FF950 contains the pointer
		LDA.l $0FF950|!FastROM		;  | for the ExGFX table for 80-FF
		STA.b $07						; /
		BRA .FinishDecomp				; branch to next step

.UploadReturn
		PLX
		PLY
		RTS

.GFX00to31
		TAX								; ExGFX file -> X
		LDA.l $00B992|!FastROM,x		; \
		STA $8A						;  | copy ExGFX
		LDA.l $00B9C4|!FastROM,x		;  | pointer to
		STA $8B						;  | $8A-$8C
		LDA.l $00B9F6|!FastROM,x		;  |
		STA $8C						; /
		BRA .FinishDecomp2			; branch to next step

.ExGFX100toFFF
		;SEC							; \ subtract #$100
		SBC.w #$0100					; / SEC commented out because the BCS that branches here would only branch if the carry flag were already set
		STA.b $8A						; \
		ASL A							;  | multiply result
		CLC								;  | by 3 to get
		ADC.b $8A						;  | index
		TAY								; /
		LDA.l $0FF873|!FastROM		; \
		STA.b $06						;  | $0FF873-$0FF875 contans the pointer
		LDA.l $0FF874|!FastROM		;  | for the ExGFX table for 100-FFF
		STA.b $07						; /
.FinishDecomp
		LDA.b [$06],y					; \ Get low byte.
		STA.b $8A						; / and high byte
		INC.b $06						; Increase pointer position by 1.
		BNE .NoCrossBank				; \
		SEP #%00100000					;  | allow bank crossing
		INC $08						;  | (not sure if this is necessary here)
		REP #%00100000					; /
.NoCrossBank
		LDA.b [$06],y					; \ Get the high byte (again)
		STA.b $8B						; / and bank byte.
.FinishDecomp2
		LDA.w #!GFXBuffer				; \ GFX buffer low
		STA.b $00						; / and high byte
		SEP #%00100000					; 8-bit A
		LDA.b #!GFXBuffer>>16			; \ GFX buffer
		STA.b $02						; / bank byte
		PHK								; \
		PEA.w .Ret1-1					;  | local JSL to LZ2 routine
		PEA $84CE						;  | (afterwards A/X/Y all 8-bit)
		JML $00B8DC|!FastROM			; /
.Ret1
		REP.b #%00010000				; 16-bit X/Y
		PLX								; \ restore X, X is the
		STX.w $2116					; / VRAM destination
		LDA.b #%00000001				; \ control
		STA.w $4300					; / register
		LDA.b #$18						; \ dma to
		STA.w $4301					; / [21]18
		LDX.w #!GFXBuffer				; \
		STX.w $4302					;  | source
		LDA.b #!GFXBuffer>>16			;  | of data
		STA.w $4304					; /
		LDX.b $8D						; \ size of decompressed
		STX.w $4305					; / GFX File
		LDA.b #%00000001				; \ start DMA
		STA.w $420B					; / transfer
		REP #%00100000					; 16-bit A
		PLY								; restore Y
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Level Pointers - Point to sets of graphics files to upload
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Pointers:
.L000           dw $0000
.L001           dw $0000
.L002           dw $0000
.L003           dw $0000
.L004           dw $0000
.L005           dw $0000
.L006           dw $0000
.L007           dw $0000
.L008           dw $0000
.L009           dw $0000
.L00A           dw $0000
.L00B           dw $0000
.L00C           dw $0000
.L00D           dw $0000
.L00E           dw $0000
.L00F           dw $0000
.L010           dw $0000
.L011           dw $0000
.L012           dw $0000
.L013           dw $0000
.L014           dw $0000
.L015           dw $0000
.L016           dw $0000
.L017           dw $0000
.L018           dw $0000
.L019           dw $0000
.L01A           dw $0000
.L01B           dw $0000
.L01C           dw $0000
.L01D           dw $0000
.L01E           dw $0000
.L01F           dw $0000
.L020           dw $0000
.L021           dw $0000
.L022           dw $0000
.L023           dw $0000
.L024           dw $0000
.L025           dw $0000
.L026           dw $0000
.L027           dw $0000
.L028           dw $0000
.L029           dw $0000
.L02A           dw $0000
.L02B           dw $0000
.L02C           dw $0000
.L02D           dw $0000
.L02E           dw $0000
.L02F           dw $0000
.L030           dw $0000
.L031           dw $0000
.L032           dw $0000
.L033           dw $0000
.L034           dw $0000
.L035           dw $0000
.L036           dw $0000
.L037           dw $0000
.L038           dw $0000
.L039           dw $0000
.L03A           dw $0000
.L03B           dw $0000
.L03C           dw $0000
.L03D           dw $0000
.L03E           dw $0000
.L03F           dw $0000
.L040           dw $0000
.L041           dw $0000
.L042           dw $0000
.L043           dw $0000
.L044           dw $0000
.L045           dw $0000
.L046           dw $0000
.L047           dw $0000
.L048           dw $0000
.L049           dw $0000
.L04A           dw $0000
.L04B           dw $0000
.L04C           dw $0000
.L04D           dw $0000
.L04E           dw $0000
.L04F           dw $0000
.L050           dw $0000
.L051           dw $0000
.L052           dw $0000
.L053           dw $0000
.L054           dw $0000
.L055           dw $0000
.L056           dw $0000
.L057           dw $0000
.L058           dw $0000
.L059           dw $0000
.L05A           dw $0000
.L05B           dw $0000
.L05C           dw $0000
.L05D           dw $0000
.L05E           dw $0000
.L05F           dw $0000
.L060           dw $0000
.L061           dw $0000
.L062           dw $0000
.L063           dw $0000
.L064           dw $0000
.L065           dw $0000
.L066           dw $0000
.L067           dw $0000
.L068           dw $0000
.L069           dw $0000
.L06A           dw $0000
.L06B           dw $0000
.L06C           dw $0000
.L06D           dw $0000
.L06E           dw $0000
.L06F           dw $0000
.L070           dw $0000
.L071           dw $0000
.L072           dw $0000
.L073           dw $0000
.L074           dw $0000
.L075           dw $0000
.L076           dw $0000
.L077           dw $0000
.L078           dw $0000
.L079           dw $0000
.L07A           dw $0000
.L07B           dw $0000
.L07C           dw $0000
.L07D           dw $0000
.L07E           dw $0000
.L07F           dw $0000
.L080           dw $0000
.L081           dw $0000
.L082           dw $0000
.L083           dw $0000
.L084           dw $0000
.L085           dw $0000
.L086           dw $0000
.L087           dw $0000
.L088           dw $0000
.L089           dw $0000
.L08A           dw $0000
.L08B           dw $0000
.L08C           dw $0000
.L08D           dw $0000
.L08E           dw $0000
.L08F           dw $0000
.L090           dw $0000
.L091           dw $0000
.L092           dw $0000
.L093           dw $0000
.L094           dw $0000
.L095           dw $0000
.L096           dw $0000
.L097           dw $0000
.L098           dw $0000
.L099           dw $0000
.L09A           dw $0000
.L09B           dw $0000
.L09C           dw $0000
.L09D           dw $0000
.L09E           dw $0000
.L09F           dw $0000
.L0A0           dw $0000
.L0A1           dw $0000
.L0A2           dw $0000
.L0A3           dw $0000
.L0A4           dw $0000
.L0A5           dw $0000
.L0A6           dw $0000
.L0A7           dw $0000
.L0A8           dw $0000
.L0A9           dw $0000
.L0AA           dw $0000
.L0AB           dw $0000
.L0AC           dw $0000
.L0AD           dw $0000
.L0AE           dw $0000
.L0AF           dw $0000
.L0B0           dw $0000
.L0B1           dw $0000
.L0B2           dw $0000
.L0B3           dw $0000
.L0B4           dw $0000
.L0B5           dw $0000
.L0B6           dw $0000
.L0B7           dw $0000
.L0B8           dw $0000
.L0B9           dw $0000
.L0BA           dw $0000
.L0BB           dw $0000
.L0BC           dw $0000
.L0BD           dw $0000
.L0BE           dw $0000
.L0BF           dw $0000
.L0C0           dw $0000
.L0C1           dw $0000
.L0C2           dw $0000
.L0C3           dw $0000
.L0C4           dw $0000
.L0C5           dw $0000
.L0C6           dw $0000
.L0C7           dw $0000
.L0C8           dw $0000
.L0C9           dw $0000
.L0CA           dw $0000
.L0CB           dw $0000
.L0CC           dw $0000
.L0CD           dw $0000
.L0CE           dw $0000
.L0CF           dw $0000
.L0D0           dw $0000
.L0D1           dw $0000
.L0D2           dw $0000
.L0D3           dw $0000
.L0D4           dw $0000
.L0D5           dw $0000
.L0D6           dw $0000
.L0D7           dw $0000
.L0D8           dw $0000
.L0D9           dw $0000
.L0DA           dw $0000
.L0DB           dw $0000
.L0DC           dw $0000
.L0DD           dw $0000
.L0DE           dw $0000
.L0DF           dw $0000
.L0E0           dw $0000
.L0E1           dw $0000
.L0E2           dw $0000
.L0E3           dw $0000
.L0E4           dw $0000
.L0E5           dw $0000
.L0E6           dw $0000
.L0E7           dw $0000
.L0E8           dw $0000
.L0E9           dw $0000
.L0EA           dw $0000
.L0EB           dw $0000
.L0EC           dw $0000
.L0ED           dw $0000
.L0EE           dw $0000
.L0EF           dw $0000
.L0F0           dw $0000
.L0F1           dw $0000
.L0F2           dw $0000
.L0F3           dw $0000
.L0F4           dw $0000
.L0F5           dw $0000
.L0F6           dw $0000
.L0F7           dw $0000
.L0F8           dw $0000
.L0F9           dw $0000
.L0FA           dw $0000
.L0FB           dw $0000
.L0FC           dw $0000
.L0FD           dw $0000
.L0FE           dw $0000
.L0FF           dw $0000
.L100           dw $0000
.L101           dw $0000
.L102           dw $0000
.L103           dw $0000
.L104           dw $0000
.L105           dw $0000
.L106           dw $0000
.L107           dw $0000
.L108           dw $0000
.L109           dw $0000
.L10A           dw $0000
.L10B           dw $0000
.L10C           dw $0000
.L10D           dw $0000
.L10E           dw $0000
.L10F           dw $0000
.L110           dw $0000
.L111           dw $0000
.L112           dw $0000
.L113           dw $0000
.L114           dw $0000
.L115           dw $0000
.L116           dw $0000
.L117           dw $0000
.L118           dw $0000
.L119           dw $0000
.L11A           dw $0000
.L11B           dw $0000
.L11C           dw $0000
.L11D           dw $0000
.L11E           dw $0000
.L11F           dw $0000
.L120           dw $0000
.L121           dw $0000
.L122           dw $0000
.L123           dw $0000
.L124           dw $0000
.L125           dw $0000
.L126           dw $0000
.L127           dw $0000
.L128           dw $0000
.L129           dw $0000
.L12A           dw $0000
.L12B           dw $0000
.L12C           dw $0000
.L12D           dw $0000
.L12E           dw $0000
.L12F           dw $0000
.L130           dw $0000
.L131           dw $0000
.L132           dw $0000
.L133           dw $0000
.L134           dw $0000
.L135           dw $0000
.L136           dw $0000
.L137           dw $0000
.L138           dw $0000
.L139           dw $0000
.L13A           dw $0000
.L13B           dw $0000
.L13C           dw $0000
.L13D           dw $0000
.L13E           dw $0000
.L13F           dw $0000
.L140           dw $0000
.L141           dw $0000
.L142           dw $0000
.L143           dw $0000
.L144           dw $0000
.L145           dw $0000
.L146           dw $0000
.L147           dw $0000
.L148           dw $0000
.L149           dw $0000
.L14A           dw $0000
.L14B           dw $0000
.L14C           dw $0000
.L14D           dw $0000
.L14E           dw $0000
.L14F           dw $0000
.L150           dw $0000
.L151           dw $0000
.L152           dw $0000
.L153           dw $0000
.L154           dw $0000
.L155           dw $0000
.L156           dw $0000
.L157           dw $0000
.L158           dw $0000
.L159           dw $0000
.L15A           dw $0000
.L15B           dw $0000
.L15C           dw $0000
.L15D           dw $0000
.L15E           dw $0000
.L15F           dw $0000
.L160           dw $0000
.L161           dw $0000
.L162           dw $0000
.L163           dw $0000
.L164           dw $0000
.L165           dw $0000
.L166           dw $0000
.L167           dw $0000
.L168           dw $0000
.L169           dw $0000
.L16A           dw $0000
.L16B           dw $0000
.L16C           dw $0000
.L16D           dw $0000
.L16E           dw $0000
.L16F           dw $0000
.L170           dw $0000
.L171           dw $0000
.L172           dw $0000
.L173           dw $0000
.L174           dw $0000
.L175           dw $0000
.L176           dw $0000
.L177           dw $0000
.L178           dw $0000
.L179           dw $0000
.L17A           dw $0000
.L17B           dw $0000
.L17C           dw $0000
.L17D           dw $0000
.L17E           dw $0000
.L17F           dw $0000
.L180           dw $0000
.L181           dw $0000
.L182           dw $0000
.L183           dw $0000
.L184           dw $0000
.L185           dw $0000
.L186           dw $0000
.L187           dw $0000
.L188           dw $0000
.L189           dw $0000
.L18A           dw $0000
.L18B           dw $0000
.L18C           dw $0000
.L18D           dw $0000
.L18E           dw $0000
.L18F           dw $0000
.L190           dw $0000
.L191           dw $0000
.L192           dw $0000
.L193           dw $0000
.L194           dw $0000
.L195           dw $0000
.L196           dw $0000
.L197           dw $0000
.L198           dw $0000
.L199           dw $0000
.L19A           dw $0000
.L19B           dw $0000
.L19C           dw $0000
.L19D           dw $0000
.L19E           dw $0000
.L19F           dw $0000
.L1A0           dw $0000
.L1A1           dw $0000
.L1A2           dw $0000
.L1A3           dw $0000
.L1A4           dw $0000
.L1A5           dw $0000
.L1A6           dw $0000
.L1A7           dw $0000
.L1A8           dw $0000
.L1A9           dw $0000
.L1AA           dw $0000
.L1AB           dw $0000
.L1AC           dw $0000
.L1AD           dw $0000
.L1AE           dw $0000
.L1AF           dw $0000
.L1B0           dw $0000
.L1B1           dw $0000
.L1B2           dw $0000
.L1B3           dw $0000
.L1B4           dw $0000
.L1B5           dw $0000
.L1B6           dw $0000
.L1B7           dw $0000
.L1B8           dw $0000
.L1B9           dw $0000
.L1BA           dw $0000
.L1BB           dw $0000
.L1BC           dw $0000
.L1BD           dw $0000
.L1BE           dw $0000
.L1BF           dw $0000
.L1C0           dw $0000
.L1C1           dw $0000
.L1C2           dw $0000
.L1C3           dw $0000
.L1C4           dw $0000
.L1C5           dw $0000
.L1C6           dw $0000
.L1C7           dw $0000
.L1C8           dw $0000
.L1C9           dw $0000
.L1CA           dw $0000
.L1CB           dw $0000
.L1CC           dw $0000
.L1CD           dw $0000
.L1CE           dw $0000
.L1CF           dw $0000
.L1D0           dw $0000
.L1D1           dw $0000
.L1D2           dw $0000
.L1D3           dw $0000
.L1D4           dw $0000
.L1D5           dw $0000
.L1D6           dw $0000
.L1D7           dw $0000
.L1D8           dw $0000
.L1D9           dw $0000
.L1DA           dw $0000
.L1DB           dw $0000
.L1DC           dw $0000
.L1DD           dw $0000
.L1DE           dw $0000
.L1DF           dw $0000
.L1E0           dw $0000
.L1E1           dw $0000
.L1E2           dw $0000
.L1E3           dw $0000
.L1E4           dw $0000
.L1E5           dw $0000
.L1E6           dw $0000
.L1E7           dw $0000
.L1E8           dw $0000
.L1E9           dw $0000
.L1EA           dw $0000
.L1EB           dw $0000
.L1EC           dw $0000
.L1ED           dw $0000
.L1EE           dw $0000
.L1EF           dw $0000
.L1F0           dw $0000
.L1F1           dw $0000
.L1F2           dw $0000
.L1F3           dw $0000
.L1F4           dw $0000
.L1F5           dw $0000
.L1F6           dw $0000
.L1F7           dw $0000
.L1F8           dw $0000
.L1F9           dw $0000
.L1FA           dw $0000
.L1FB           dw $0000
.L1FC           dw $0000
.L1FD           dw $0000
.L1FE           dw $0000
.L1FF           dw $0000

Pointers2:
.MainMap			dw $0000
.YoshisIsland		dw $0000
.VanillaDome		dw $0000
.ForestOfIllusion	dw $0000
.ValleyOfBowser	dw $0000
.SpecialWorld		dw $0000
.StarWorld			dw $0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GFX Tables - Sets of graphic files to upload, indexed by the pointer tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;GFXSetExample:				; Example. Place this at the level(s) you want to upload to, in the level table above.
;		dw $3000,$0200		; Example. Uploads ExGFX 200 to VRAM Address $6000 ($3000 * 2)
;		dw $3800,$0201		; Example. Uploads ExGFX 200 to VRAM Address $6000 ($3000 * 2)
;		dw $FFFF		; Example. Terminates the table.
OW1:
		dw $3800,$00B2		; Example. Uploads ExGFX 200 to VRAM Address $6000 ($3000 * 2)
		dw $FFFF