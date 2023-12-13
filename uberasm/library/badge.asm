;Badges
;From SMW Wonder
;By Soul
;Badge code by various authors
;;;;;;;;;;;;;
;Do not edit
!yes = $01
!no = $00
;;;;;;;;;;;;;
;Defines
!BadgeRAMSaved = $1F2B|!addr ;has to be saved to sram (6F2B on sa1 for debugging)
!DoubleBoostBadges = !no ;allows you to use one action / challange badge and an extra boost badge
!ExtraBoostBadgeRAM = $1F2C|!addr ;only used if !DoubleBoostBadges is set to !yes
!BadgeRAMStop = $18F6|!addr ;set to 1 to stop badges from working
!InvisibilityFlag = $0F63|!addr
!BadgeChallangeFlag = $1696|!addr ;flag to start badge challange and use below ram as badge
!BadgeChallangeBadgeRAM = $1864|!addr
;badges which run code on load
load:
LDA !BadgeRAMStop
CMP #$00
BNE return
LDA !BadgeRAMSaved
CMP #$00
BEQ return
ASL
TAX
JMP (.BadgeRoutinePtrs-$02,x)
;Feel free to add more badges by using CMP and BEQ
RTL
load_BadgeRoutinePtrs:
  dw return
  dw return
  dw return
  dw return
  dw return
  dw return
  dw return
  dw return
  dw AutoMushroomLoad
  dw AutoFlowerLoad
  dw return
  dw return

LoadBC:
LDA !BadgeChallangeBadgeRAM
ASL
TAX
JMP (load_BadgeRoutinePtrs-$02,x)
;Feel free to add more badges by using CMP and BEQ
RTL
;badges which run code on main
main:
LDA !BadgeChallangeFlag
CMP #$01
BEQ MainBC
LDA !BadgeRAMStop
CMP #$00
BNE return
LDA !BadgeRAMSaved
CMP #$00
BEQ return
ASL
TAX
JMP (.BadgeRoutinePtrs-$02,x)
;Feel free to add more badges by using CMP and BEQ
RTL
return:
  RTL
main_BadgeRoutinePtrs:
  dw ParaCap
  dw FloatHiJump
  dw return
  dw return
  dw return
  dw return
  dw return
  dw BoostSpin
  dw AutoMushroom
  dw AutoFlower
  dw SoundOff
  dw SpringFeet
  dw Invisibility
  dw JetRun
MainBC:
LDA !BadgeChallangeBadgeRAM
ASL
TAX
JMP (main_BadgeRoutinePtrs-$02,x)
;Base defines
!FreeRAM1 = $0F63|!addr
!FreeRAM2 = $0F64|!addr
!FreeRAM3 = $0F65|!addr
;Badge Code Defines
;;;;;;;;;;;;;;;;;
;Air Spin Defines
!Freeram_SpinTimer	= $0F63|!addr
!AllowSpinAfterSpin	= 0		
!Freeram_JumpTypSav	= $0F64|!addr	
!AirSpinLast		= $10		
!AirspinRecoilLast	= $0F		
!AJJumpBoostType	= 0		
!Yspeed			= $C0		
!AirSpinSFXNumb		= $04		
!AirSpinSFXRam		= $1DFC		
;;;;;;;;;;;;;;;;;;;
;Jet Run Defines
!HeldDownDisabler15 = %00001100
!NewlyPressedDisabler16 = %00001100     
!HeldDownDisabler17 = %00000000
!NewlyPressedDisabler18 = %00000000
!Speed = $30
!Speed2 = $D0
;;;;;;;;;;;;;;;;;;;
;Invisibility Defines
;;;;;;;;;;;;;;;;;;;
!InvisibilityFlag = $0F63|!addr
;;;;;;;;;;;;;;;
;Load badge code
;;;;;;;;;;;;;;;
Invisibility:
LDA #$7F
STA $78
LDA #$01
STA !InvisibilityFlag
AutoMushroom:
LDA $0F63|!addr
CMP #$01
BEQ .return
LDA #$01
STA $19
STA $0F63|!addr
.return
RTL
AutoMushroomLoad:
LDA #$01
STA $0F63|!addr
RTL
AutoFlower:
LDA $0F63|!addr
CMP #$01
BEQ .return
LDA #$03
STA $19
LDA #$01
STA $0F63|!addr
.return
RTL
AutoFlowerLoad:
LDA #$01
STA $0F63|!addr
RTL
;Main Badge Code
!ParaCapCounter = $1F3B|!addr
!ParaCapState = $1908|!addr
!ParaCapYSpeed = #$18
ParaCap:
LDA $72
CMP #$00
BEQ .ground ;is player in air
LDA $17
;     axlr----
AND #%00100000
BNE .continue
STZ !ParaCapState
RTL
.return:
RTL
.continue
LDA $72
CMP #$0B
BEQ .return
INC !ParaCapCounter
LDA !ParaCapCounter
CMP #$A0
BCS .FallingDown
LDA !ParaCapYSpeed
STA $7D
LDA #$01
STA !ParaCapState
LDA #$30
STA $13E0|!addr
LDA !ParaCapState
CMP #$01
BEQ .height
.ground
STZ !FreeRAM1
STZ !ParaCapState
STZ !ParaCapCounter
RTL
.height
LDA !FreeRAM1
CMP #$01
BNE .return
LDA #$01
STA !FreeRAM1
LDA #$90
STA $7D
LDA #$02
STA !ParaCapState
RTL
.FallingDown
LDA $7D
CMP #$30
BEQ .return
INC $7D
FloatHiJump:
	LDA $77
	AND #$04
	BNE .return
	BIT $15
	BPL .return
	PHX
	LDA $19
	AND #$03
	ASL
	TAX
	DEC $7D
	PLX
.return
	RTL
Table:
	db $00,$00,$00,$01,$01,$02,$01,$01
JetRun:
	LDA $15
	AND #~!HeldDownDisabler15
	STA $15

	LDA $16
	AND #~!NewlyPressedDisabler16
	STA $16

	LDA $17
	AND #~!HeldDownDisabler17
	STA $17

	LDA $18
	AND #~!NewlyPressedDisabler18
	STA $18
	LDA $76
	CMP #$00
	BEQ .Left
    LDA $77
    AND.b #(((1+1)%2)+1)
    bne .nospd
    LDA.b #!Speed
	STA $7B
.nospd
RTL
.Left:
    LDA $77
    AND.b #(((0+1)%2)+1)
    bne .nospd
    LDA.b #!Speed2
	STA $7B
RiseWallJump:
RTL
CrouchHiJump:
RTL
BoostSpin:
	.Airspin
	..SpinTimer
	LDA $9D			;\If frozen, don't decrement.
	ORA $13D4+!addr		;|
	BNE ..Return		;/
	LDA !Freeram_SpinTimer	;\If timer clear, don't decrement
	BEQ ...NoDecrement	;/
	DEC			;
	CMP #!AirspinRecoilLast
	BNE ...Decrement 
		PHA
		LDA !Freeram_JumpTypSav ;\Revert to last jump type. 
		STA $140D+!addr		;/
		PLA
	...Decrement
	STA !Freeram_SpinTimer	;>Decrement timer

	...NoDecrement
	...DontSetPose
	..AirSpinMain
	LDA $72
CMP #$00
BEQ .ResetValues
	LDA $75			;>If water
	ORA $1407+!addr		;>or cape flying
	ORA !FreeRAM1	;>Or freeram
	ORA $140D+!addr		;>If prior spinjumping,
	BNE ..Return		;>Then don't allow.	
	LDA !Freeram_SpinTimer	;\Player cannot spin if already spinning OR in recoil
	BNE ..Return		;/
	LDA $77			;\Being On the floor
	AND.b #%00000010	;/
	BNE ..Return		;>If on floor, return
	LDA $18			;\If not pressing spinjump return
;	AND #%00100000
	BPL ..Return		;/

	...BoostPlayer
	if !AJJumpBoostType == 0
		LDA #!Yspeed	;\Ajust Y speed
		STA $7D
	else
		LDA $7D
		SEC
		SBC.b #!Yspeed-3
		STA $7D
	endif

	;Note to self: Timer values have 2 ranges: 0 to !AirspinRecoilLast-1 is when the player cannot airspin,
	;while !AirspinRecoilLast to !AirSpinLast is the spinning pose.

	LDA.b #!AirspinRecoilLast+!AirSpinLast	;\This is so that the amount of time of airspin last is always the same
	STA !Freeram_SpinTimer			;/when changing the recoillast.

	if !AirSpinSFXNumb != 0
		LDA #$01
	STA !FreeRAM1
		LDA #!AirSpinSFXNumb			;\SFX
		STA !AirSpinSFXRam+!addr		;/
	endif
		LDA $140D+!addr		;\Save jump type
		STA !Freeram_JumpTypSav	;/
	LDA #$01		;\Spinjump
	STA $140D+!addr		;/
	..Return
	RTL
		.ResetValues
	STZ !FreeRAM1
	RTL
SoundOff: 
LDA #$2F ;needs custom sfx
STA $1DF9|!addr
RTL
SpringFeet:
LDA $13EF|!addr
ORA $1471|!addr
BEQ .return
STZ $140D|!addr
LDA #$A0    ;Jump height
STA $7D
LDA #$01
RTL
.return
RTL