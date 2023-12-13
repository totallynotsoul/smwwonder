;; TransparencyFix v1.0.2

;; - restores layer 3 transparency tile afterwards if overwritten in a level that doesn't show layer 3
;; - kills HDMA effects, so you can HDMA to $212C/2D (might also help a few other things)
;; - useful for making layer 3 BGs show up behind layer 2 without affecting the status bar
;; - normally, the HDMA effect would persist even during teleporting/dying and cause an artifact onscreen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $009750
autoclean	JML FadeOutHijack			; same as Mode7 Game Over hijack
									; COMMENT THIS JML OUT (with a ; ) IF YOU USE THE Mode7 Game Over patch!!!
org $009691
		JML FadeOutHijack2		; teleport hijack

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

freecode
FadeOutHijack:
		PHK							; \
		PEA.w .Ret1-1				;  | Roy's code
		PEA $84CE					;  | from his
		JML $0085FA|!FastROM		;  | mode 7
.Ret1
		PHK							;  | game-over
		PEA.w .Ret2-1				;  | patch
		PEA $84CE					;  |
		JML $00A82D|!FastROM		; /
.Ret2
		JSR ClearStuff				; main
		JML $0093CA|!FastROM		; return to SMW code

FadeOutHijack2:
		JSR ClearStuff				; main
		LDA.w $1425|!Base2		; \
		BNE .JMLTo0096A8			;  | hijacked code
		JML $009696|!FastROM		;  | (sort of)
.JMLTo0096A8
	JML $0096A8|!FastROM			; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearStuff:
		STZ $0D9F|!Base2			; kill HDMA effects
		REP #%00100000				; 16-bit A
		LDA.w #$47E0				; \ start VRAM
		STA.w $2116				; / address
		STZ $2118					; \
		STZ $2118					;  | Zeroes.
		STZ $2118					;  | Zeroes everywhere.
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					;  |
		STZ $2118					; /
		SEP #%00100000				; 8-bit A
		RTS
