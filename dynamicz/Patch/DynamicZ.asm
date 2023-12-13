
incsrc header.asm

incsrc Hijacks/RequireHijacks.asm

if !MarioGFXChangeSupport || !MarioPaletteChangeSupport || !FullyCustomPlayerSupport
incsrc Hijacks/MarioHijacks.asm
endif

if !Mode50moreSupport
incsrc Hijacks/Mode50moreHijacks.asm
endif

org !Freespace|!base3

db "ST","AR"				;
dw Fin-Inicio-$01			;Rats tag
dw Fin-Inicio-$01^$FFFF		;

Inicio:

JML reserveNormalSlot80|!base3
JML reserveExtendedSlot80|!base3
JML reserveClusterSlot80|!base3
JML reserveNormalSlot64|!base3
JML reserveExtendedSlot64|!base3
JML reserveClusterSlot64|!base3
JML reserveNormalSlot48|!base3
JML reserveExtendedSlot48|!base3
JML reserveClusterSlot48|!base3
JML reserveNormalSlot32|!base3
JML reserveExtendedSlot32|!base3
JML reserveClusterSlot32|!base3
JML hidestatusBar|!base3
JML GET_DRAW_INFO|!base3
JML SUB_OFF_SCREEN_X0|!base3
JML SUB_OFF_SCREEN_X1|!base3
JML SUB_OFF_SCREEN_X2|!base3
JML SUB_OFF_SCREEN_X3|!base3
JML SUB_OFF_SCREEN_X4|!base3
JML SUB_OFF_SCREEN_X5|!base3
JML SUB_OFF_SCREEN_X6|!base3
JML SUB_OFF_SCREEN_X7|!base3
JML DynamicRoutine80Start|!base3
JML DynamicRoutine64Start|!base3
JML DynamicRoutine48Start|!base3
JML DynamicRoutine32Start|!base3
JML Ping80|!base3
JML Ping64|!base3
JML Ping48|!base3
JML Ping32|!base3


;#########################################################
;################ Dynamic Z Main Routine #################
;#########################################################

;Dynamic Z Main Routine
DynamicZ:
	PHB
	PHK
	PLB
	
	PHP
	PHD
	
	LDA !DTimer
	AND #$01
	ASL
	TAX
	
if !Mode50moreSupport
	LDA !mode50
	BEQ +
	
	INX
	INX
	INX
	INX
+
endif

	REP #$20

	LDA #$4300
	TCD ;direct page = 4300 for speed
	LDA #$1801              
	STA $00               ;parameter of DMA
	
	LDY #$01 ;DMA activate
	LDX #$80                
	STX $2115
	
	LDX $0100|!base2
	CPX #$14
	BEQ .dzStart
	
	CPX #$0E
	BEQ .dzStart
	
	CPX #$0D
	BEQ .dzStart
	
	CPX #$07
	BEQ .dzStart
	
	CPX #$18
	BCS .dzStart
	BRA .retDZPre
.dzStart

if !MarioGFXChangeSupport || !MarioPaletteChangeSupport || !FullyCustomPlayerSupport
	JSR marioGFX
endif

if !UseDMAMirror
	LDX !DMAmirror
	BEQ +
	STX $420B ;start DMA
+
endif

if !DynamicSpriteSupport60FPS
	LDX !SLOTSUSED
	BEQ .dynzSpSupp
	
.retrodsx
	JSR retroDSX
	JMP .retDZ
.dynzSpSupp
endif

if !DynamicSpriteSupport30FPS
	JSR dynamicSprites
endif

if !GFXChangeSupport
	JSR ExGfxChange
endif

	JMP .retDZ	
.retDZPre
	SEP #$20
	LDA #$00
	STA !mode50

if !GFXChangeSupport
	STA !GFXNumber
endif

if !PaletteChangeSupport
	STA !paletteNumber
endif

	STA !marioNormalCustomGFXOn
	STA !marioPal
	STA !marioCustomGFXOn

if !DynamicSpriteSupport30FPS
	LDA #$FF
	STA !firstSlot
endif
	REP #$20
	LDA #$FFFF

if !DynamicSpriteSupport30FPS
	STA !nextDynSlot
	STA !nextDynSlot+$02
	STA !nextDynSlot+$04
	STA !nextDynSlot+$06
	STA !nextDynSlot+$08
	STA !nextDynSlot+$0A
	STA !nextDynSlot+$0C
	STA !nextDynSlot+$0E
	STA !nextDynSlot+$10
	STA !nextDynSlot+$12
	STA !nextDynSlot+$14
	STA !nextDynSlot+$16
	STA !nextDynSlot+$18
	STA !nextDynSlot+$1A
	STA !nextDynSlot+$1C
	STA !nextDynSlot+$1E
	STA !nextDynSlot+$20
	STA !nextDynSlot+$22
	STA !nextDynSlot+$24
	STA !nextDynSlot+$26
	STA !nextDynSlot+$28
	STA !nextDynSlot+$2A
	STA !nextDynSlot+$2C
	STA !nextDynSlot+$2E
	STA !dynSiganls1
	STA !dynSiganls2
endif

if !SemiDynamicSpriteSupport
	STA !SemiDynamicSlots
	STA !SemiDynamicSlots+$02
endif

if !MarioGFXChangeSupport || !MarioPaletteChangeSupport || !FullyCustomPlayerSupport
	STA $0D85+$06|!base2
	STA $0D85+$08|!base2
	STA !optimizer2+$06
	STA !optimizer2+$08
	STA $0D8F+$06|!base2
	STA $0D8F+$08|!base2
	STA !optimizer3+$06
	STA !optimizer3+$08
endif
	
.retDZ	

	LDA #$2100
	TCD
	SEP #$20

if !PaletteChangeSupport 
	JSR paletteChange
endif

	PLD

if !MarioGFXChangeSupport || !MarioPaletteChangeSupport || !FullyCustomPlayerSupport
	JSR marioPalette
endif
	
.settings

if !DynamicSpriteSupport30FPS
	LDA !DTimer
	INC A
	STA !DTimer
endif
	
	LDA #$00
	STA !marioPal
	STA !marioCustomGFXOn

if !DynamicSpriteSupport60FPS
	STA !SLOTSUSED	
endif

if !UseDMAMirror
	STA !DMAmirror
endif

if !DynamicSpriteSupport30FPS
	LDA #$FF
	STA !firstSlot
	STA !firstSlot+$01
	
	LDA !dynSiganls1
	AND #$AA
	LSR
	STA $00 ;0x0x0x0x
	LDA !dynSiganls1
	AND #$55 ;0y0y0y0y
	STA $01

	ORA $00 ;0xoy0xoy0xoy0xoy
	ASL ;xoy0xoy0xoy0xoy0
	STA $02

	LDA $01
	EOR #$55 ;0~y0~y0~y0~y
	ORA $00 ;0xo~y0xo~y0xo~y0xo~y
	ORA $02 ;xoyxo~yxoyxo~yxoyxo~yxoyxo~y
	STA !dynSiganls1
	
	LDA !dynSiganls2
	AND #$AA
	LSR
	STA $00 ;0x0x0x0x
	LDA !dynSiganls2
	AND #$55 ;0y0y0y0y
	STA $01

	ORA $00 ;0xoy0xoy0xoy0xoy
	ASL ;xoy0xoy0xoy0xoy0
	STA $02

	LDA $01
	EOR #$55 ;0~y0~y0~y0~y
	ORA $00 ;0xo~y0xo~y0xo~y0xo~y
	ORA $02 ;xoyxo~yxoyxo~yxoyxo~yxoyxo~y
	STA !dynSiganls2
endif
	
if !DynamicSpriteSupport30FPS && !Mode50moreSupport
	LDA !mode50
	BEQ +
	
	LDA !dynSiganls3
	AND #$AA
	LSR
	STA $00 ;0x0x0x0x
	LDA !dynSiganls3
	AND #$55 ;0y0y0y0y
	STA $01

	ORA $00 ;0xoy0xoy0xoy0xoy
	ASL ;xoy0xoy0xoy0xoy0
	STA $02

	LDA $01
	EOR #$55 ;0~y0~y0~y0~y
	ORA $00 ;0xo~y0xo~y0xo~y0xo~y
	ORA $02 ;xoyxo~yxoyxo~yxoyxo~yxoyxo~y
	STA !dynSiganls3
	
+
endif

if !DynamicSpriteSupport30FPS
	LDA #$FF
	STA !lastSender
endif

	PLP
	PLB
	RTL

DZHijack3:
	JSL DynamicZ
	PHK
	PEA.w .jslrtsreturn-1
	PEA.w $0084CF-1 ; varies per bank, must point to RTL-1 in the same bank as the JML target (example: $0084CF-1)
	JML $0085D2|!base3
.jslrtsreturn
	PHK
	PEA.w .jslrtsreturn2-1
	PEA.w $0084CF-1 ; varies per bank, must point to RTL-1 in the same bank as the JML target (example: $0084CF-1)
	JML $008449|!base3
.jslrtsreturn2
	JML $008243|!base3

DZHijack4:
	JSL DynamicZ
	BIT.W $0D9B
	BVS +
	JML $0082E8|!base3
+	
	JML $0082DF|!base3

signal: db $01,$02,$02	

if !DynamicSpriteSupport60FPS
incsrc Code/DynamicSpriteSupport60FPS.asm
endif

if !DynamicSpriteSupport30FPS
incsrc Code/DynamicSpriteSupport30FPS.asm
endif

if !GFXChangeSupport
incsrc Code/EXGFXChangeSupport.asm
endif

if !FullyCustomPlayerSupport
incsrc Code/FullyCustomPlayerSupport.asm
endif


if !MarioGFXChangeSupport || !MarioPaletteChangeSupport || !FullyCustomPlayerSupport
incsrc Code/MarioDMAOptimized.asm
incsrc Code/PlayerGFXOption.asm
incsrc Code/MarioPaletteChangeSupport.asm
incsrc Code/MarioGFXChangeSupport.asm
endif

if !Mode50moreSupport
incsrc Code/Mode50moreSupport.asm
endif

if !PaletteChangeSupport
incsrc Code/PaletteChangeSupport.asm
endif

incsrc Code/DZSharedSubRoutines.asm

Fin:
print "This Patch uses: ", bytes," bytes."