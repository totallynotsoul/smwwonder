;kuribo shoe WIP
;by smkdan


;!GFXFile1 = $0764
;!GFXFile2 = $0764
!MARIOHEADSMALL = $C0
!MARIOHEADBIG = $84
!DIR = $03
!PROPRAM = $06
!TEMP = $09

;some definitions
!COUNTER = !1602	;the counter

!GOOMBAX = !1570		;goomba x displacement
!GOOMBAY = !1504	;goomba y displacement

!POWERUP = !1602	;powerup state

;states
!IDLESHOW = $00		;idling with face showing
	!IDLESHOWTIME = $30
	!IDLESHOWTIME2 = $01
!SINK = $01		;sinking to prepare for jump
	!SINKTIME = $10
!JUMPING = $02		;in the air
!RISE = $03		;rising after the jump

;misc
!JUMPYSPD = $50		;change these if you please
!JUMPYSPD2 = $40
!JUMPXSPD = $0C
!JUMPXSPD2 = $12

!INITY = $F8

;sound effect
!SHOELOSTSFX = $0F	;play what when shoe is lost? I forgot the # used in SMB3, but I know it's in the game
!SHOELOSTSFXPORT = $1DF9|!Base2
!SHOEMOUNTSFX = $02	;play when shoe is mounted
!SHOEMOUNTSFXPORT = $1DF9|!Base2

;statuses
!STATE = !C2		;states, with the following masks
	!M_ACTIVE = $01		;has mario touched the shoe and become powered up?
	!M_AIRBOOST = $02	;has mario spent his mid-air boost?
	!M_CAPED = $04		;was mario caped before touching?
	!M_FIRE = $08		;was mario with fire before touching?
	!M_LOST = $10		;shoe lost? (falling off screen)
	!M_LOSING = $20		;set after 1 frame of lost

!MARIOTILE = !1570	;tile to draw for Mario's head

;other stuff
!MARIOHEADBLANK = $82
!GOOMBAFRAME = $AE	;16x16 goomba frame
!GOOMBAPROP = $04	;goomba frame properties

!YSPDBOUNCE = $24

SHOEFRAME:
	db $AA,$AC	;two shoe frames


;SPRITES THAT INTERACT AS NORMAL APPEAR AS 01
MarioSprInteract:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00	;$00-$0F
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00	;$10-$1F
	db $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01	;$20-$2F
	db $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00	;$30-$3F
	db $00, $01, $01, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00	;$40-$4F
	db $00, $00, $00, $01, $00, $00, $00, $00, $00, $01, $01, $00, $00, $00, $00, $00	;$50-$5F
	db $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $00, $00	;$60-$6F
	db $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01	;$70-$7F
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01	;$80-$8F
	db $00, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00	;$90-$9F
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00	;$A0-$AF
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00	;$B0-$BF
	db $00, $01, $00, $00, $00, $00, $00, $01, $01, $00, $00, $00, $00, $00, $00, $00	;$C0-$CF
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00	;$D0-$DF
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00	;$E0-$EF
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00	;$F0-$FF

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpriteMain
	PLB
	RTL

print "INIT ",pc
    LDA !extra_byte_1,x
    AND #$02
    BEQ OccupiedShoe
    INC !1FD6,x
OccupiedShoe:
;	LDA.b #!GFXFile1
;	STA !RAM_SprGFXFiles,x
;	LDA.b #!GFXFile1>>8
;	STA !RAM_SprGFXFiles+(!SprSize),x
;	LDA.b #!GFXFile2
;	STA !RAM_SprGFXFiles+(!SprSize*2),x
;	LDA.b #!GFXFile2>>8
;	STA !RAM_SprGFXFiles+(!SprSize*3),x
	LDA !1FD6,x
	BNE InitPowerup
	LDA #!IDLESHOWTIME	;initialise timer
	STA !COUNTER,x		;new counter
	STA !151C,x
	LDA #!JUMPYSPD
	EOR #$FF
	INC A
	STA !1528,x
	LDA #!JUMPXSPD
	STA !1534,x
	LDA #!INITY		;set initial GOOMBAY
	STA !GOOMBAY,x
	LDA !extra_byte_1,x
	AND #$01
	BEQ NoExtraBit
	LDA #$09
	STA !15F6,x
	LDA #!IDLESHOWTIME2
	STA !COUNTER,x
	STA !151C,x
	LDA #!JUMPYSPD2
	EOR #$FF
	INC A
	STA !1528,x
	LDA #!JUMPXSPD2
	STA !1534,x
NoExtraBit:
	%FacePlayer()
	RTL

InitPowerup:
	STZ !sprite_tweaker_1656,x
	LDA #$83
	STA !sprite_tweaker_167a,x
	LDA #$19
	STA !sprite_tweaker_1686,x
	LDA #$04
	STA !sprite_tweaker_190f,x
	LDA #$02
	STA !extra_prop_2,x
	LDA #!MARIOHEADBLANK	;draw nothing where mario's head will be at start
	STA !MARIOTILE,x
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine for the shoe-wearing Goomba
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SpriteMain:
	LDA #$00
	%SubOffScreen()
	%GetDrawInfo()
;	JSL !GetExtraDrawInfo2
	LDA !1FD6,x
	BEQ Main1
	JMP Main2
Main1:
	JSR GFX1			;draw sprite

	LDA !sprite_status,x		;check for falling
	CMP #$02
	BNE NoFall

	LDA !STATE,x	;check state high bit
	BMI NoFall
	ASL
	BMI NoFall

	JSR SetupCustom	;jump to generate shoe
	LDA #$80
	STA !STATE,x	;set high bit state to say it's already done

	LDA !sprite_tweaker_1662,x	;no object interaction
	ORA #$80
	STA !sprite_tweaker_1662,x

NoFall:
	LDA !sprite_status,x		;status check
	EOR #$08          	 
	ORA $9D			;locked sprites?
	BNE Return
	LDA !15D0,x		;yoshi eating?
	BNE Return

	JSL $01802A|!BankB		;update speed
	JSL $01A7DC|!BankB		;mario interact
	LDA !sprite_status,x
	CMP #$08
	BEQ NotDead
	LDA #$40
	STA !STATE,x
	LDA #$0F
	STA !sprite_num,x
	JSL $07F7D2|!BankB
	RTS
NotDead:

	LDA !STATE,x	;load state
	ASL A		;x2 into jump table
	TAX
	JSR (JumpTable,x)

Return:
	RTS        

;=====
	
JumpTable:
	dw IdleShow
	dw Sink
	dw Jumping
	dw Rise

;=====

IdleShow:
	LDX $15E9|!Base2
	DEC !COUNTER,x	;update counters
	BNE KeepShowing

	LDA #!SINK	;update to sink
	STA !STATE,x

KeepShowing:
	RTS

Sink:
	LDX $15E9|!Base2
	
	LDA $14		;only update every 2nd frame
	LSR A
	BCC KeepSinking

	INC !GOOMBAY,x	;sink
	LDA !GOOMBAY,x	;test
	BNE KeepSinking

;jump
	LDA !1528,x	;set yjump speed
	STA !sprite_speed_y,x	;yspd

	%FacePlayer()

	LDA !1534,x	;set xjump speed
	LDY !157C,x	;test direction
	BEQ JumpRight

	EOR #$FF	;two's complement
	INC A
JumpRight:
	STA !sprite_speed_x,x	;xspd
	LDA #!JUMPING	;go into jump state
	STA !STATE,x


KeepSinking:
	RTS

Jumping:
	LDX $15E9|!Base2

	LDA !1588,x	;check if on ground yet
	BIT #$04
	BEQ InAir

;landed
	STZ !sprite_speed_x,x	;on ground, no xspd

	LDA #!RISE	;set rise status
	STA !STATE,x
InAir:
	LDA !1588,x	;if touching wall..
	BIT #$03
	BEQ NoWall

	LDA !sprite_speed_x,x	;invert xspd
	EOR #$FF
	INC A
	STA !sprite_speed_x,x

	LDA !157C,x	;and also direction
	EOR #$01
	STA !157C,x
NoWall:
	LDA !1588,x	;if touching ceiling...
	BIT #$08
	BEQ NoCeiling

	LDA !sprite_speed_y,x	;invert yspd
	EOR #$FF
	INC A
	STA !sprite_speed_y,x
NoCeiling:
	RTS

Rise:
	LDX $15E9|!Base2

	LDA $14		;rise every 2nd frame
	LSR A
	BCC KeepRising

	DEC !GOOMBAY,x	;rise again
	LDA !GOOMBAY,x	;test
	CMP #!INITY	;at original yet?
	BNE KeepRising

;risen
	LDA #!IDLESHOW	;back to idle show
	STA !STATE,x
	LDA !151C,x
	STA !COUNTER,x

KeepRising:
	RTS
	
;=====

PowerUp:
	LDA #$80	;set to always call main with no default handling
	STA !extra_prop_2,x

	INC !GOOMBAX,x
	INC !GOOMBAY,x

	STZ !sprite_speed_y,x
	STZ !sprite_speed_x,x
	RTS
			
;=====

GFX1:
	LDA !sprite_status,x	;if spin jumping / dead
	BEQ ReturnG
	CMP #$04
	BEQ ReturnG

	LDA !sprite_status,x
	CMP #$02
	BNE NoFallG

NoFallG:
	LDA !15F6,x	;properties...
	STA !PROPRAM

	LDA !157C,x	;direction...
	BNE FaceLeft
	LDA #$40	;set xflip
	TSB !PROPRAM

FaceLeft:
	LDA !sprite_status,x	;is dieing?
	CMP #$02
	BNE NoFlip

	STZ !GOOMBAX,x	;hide goomba
	STZ !GOOMBAY,x
	LDA #$80	;set yflip
	TSB !PROPRAM

	BRA DrawGoomba	;only draw goomba

;draw shoe
NoFlip:
	LDA $00		;xpos
	STA $0300|!Base2,y
	LDA $01		;ypos
	STA $0301|!Base2,y
	LDA $14		;framecounter for frame index
	LSR A
	LSR A
	LSR A		;every x frame
	AND #$01	;2 frames
	TAX
	LDA SHOEFRAME,x
;	ORA $02
	STA $0302|!Base2,y	;chr
	LDA !PROPRAM
	ORA $64
	STA $0303|!Base2,y	;properties

	LDX $15E9|!Base2	;restore sprite index

DrawGoomba:
	LDA $00		;xpos plus xdisp
	CLC
	ADC !GOOMBAX,x
	STA $0304|!Base2,y
	LDA $01		;ypos plus ydisp
	CLC
	ADC !GOOMBAY,x
	STA $0305|!Base2,y
	LDA #!GOOMBAFRAME
;	ORA $02
	STA $0306|!Base2,y	;chr
	LDA !PROPRAM
	AND #$81	;keep page bit and flip
	ORA #!GOOMBAPROP
	ORA $64
	STA $0307|!Base2,y
	
	LDY #$02	;16x16
	LDA #$01	;2 tiles
	%FinishOAMWrite()

ReturnG:
	RTS

;======

SetupCustom:
	JSL $02A9E4|!BankB		;grab free sprite slot
	BMI ReturnGen		;return if none left before anything else...

	LDA #$01
	STA !sprite_status,y		;normal status, run init routine

	LDA !15F6,x
	STA $8A

	LDA !new_sprite_num,x
;set positions accordingly		
;restore gen sprite index
	PHX		;preserve sprite
	TYX		;new sprite slot into X
	STA !new_sprite_num,x
	JSL $07F7D2|!BankB	;create sprite
	JSL $0187A7|!BankB
        LDA #$88	;set as custom sprite
        STA !extra_bits,x
	PLX		;restore sprite
	LDA $8A
	STA !15F6,y

	LDA !sprite_x_low,x	;copy positions
	STA !sprite_x_low,y
	LDA !sprite_x_high,x
	STA !sprite_x_high,y
	
	LDA !sprite_y_low,x
	STA !sprite_y_low,y
	LDA !sprite_y_high,x
	STA !sprite_y_high,y

	LDA !157C,x	;copy direction
	STA !157C,y
	LDA #$01
	STA !1FD6,y

ReturnGen:
	RTS			;return

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine for the shoe
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Main2:
	JSR GFX			;draw sprite

	LDA !STATE,x	;don't kill if it's lost
	BIT #!M_LOST
	BNE MarioNotDead

	LDA $71		;test mario animation
	CMP #$09
	BNE MarioNotDead

	STZ !sprite_status,x	;mario died, get rid of shoe

MarioNotDead:
	JSR HandleAni

	LDA !sprite_status,x
	EOR #$08          	          
	ORA $9D		;locked sprites?
	BNE Return2

	LDA !STATE,x	;test if mario has touched it yet
	BIT #!M_ACTIVE
	BNE PowerupActive

;inactive powerup
	BIT #!M_LOST	;is lost?
	BEQ NotLost

;lost
	BIT #!M_LOSING	;already ran lost code?
	BNE Speed	;just run speed code then

	JSR HandleLostShoe	;code related to losing shoe

	BRA Speed	;update speed

NotLost:
	JSL $01A7DC|!BankB	;mario interact
	BCC NoMario

	LDA #!M_ACTIVE	;set active powerup
	ORA !STATE,x
	STA !STATE,x

	LDA #!SHOEMOUNTSFX	;play mounting sound
	STA !SHOEMOUNTSFXPORT

	JSR HandleCape	;handle cape if needed
	JSR HandleFire	;handle fire if needed

	RTS

NoMario:
	STZ !sprite_speed_x,x	;no speed while stationary
Speed:
	JSL $01802A|!BankB	;update the speed
Return2:
	RTS        

;=====



PowerupActive:
	JSR FixInteraction
	JSR CopyPositions
	JSR GFXSetup
	JSR MarioMotion

	JSR HandleCape
	JSR HandleFire

	JSR SpriteInteract

	JMP MaskSound
	

;=====

HandleAni:
	LDA !STATE,x	;test for lost
	BIT #!M_LOST
	BNE .Return	;return if shoe is lost
	BIT #!M_ACTIVE
	BEQ .Return

	LDA #$FF	;hide all mario
	STA $78

	LDA $71		;animation
	CMP #$01	;01 = dieing
	BEQ .MushUpDown
	CMP #$02	;02 = growing
	BEQ .MushUpDown
	CMP #$03	;03 = cape powerup
	BEQ .Test	;show nothing
	CMP #$04	;04 = fire powerup
	BEQ .Test	;show nothing
	CMP #$05	;door/pipe exit
	BEQ .KillSelf
	CMP #$06	;pipe exit
	BEQ .KillSelf

	STZ $78		;cancel hiding

	RTS		;return if neither of these

.MushUpDown
	LDY #!MARIOHEADSMALL
	LDA $13		;frame counter not tied to pause
	LSR A
	LSR A
	BIT #$01
	BNE .ShowSmall
	LDY #!MARIOHEADBIG

.ShowSmall
	TYA
	STA !MARIOTILE,x	;head to show as mario tile

.Test
	JSR TestFireUp	;handle both cases of powerup replacement
	JMP TestFlowerUp

.Return
	RTS

.KillSelf
	JMP HandleLostShoe

;=====

TestFlowerUp:
	LDA !STATE,x	;already have cape?
	BIT #!M_CAPED
	CLC		;clc on no cape
	BEQ .Return	;test fire otherwise

	LDA $0DC2|!Base2
	CMP #$05
	BCS .Return
	CMP #$03
	BEQ .Return

	LDA #$04	;set cape to item
	STA $0DC2|!Base2

	SEC		;sec on cape

.Return
	RTS

;=====

TestFireUp:
	LDA !STATE,x	;already have fire?
	BIT #!M_FIRE
	CLC		;clc on no fire
	BEQ .Return

	LDA $0DC2|!Base2
	CMP #$05
	BCS .Return
	CMP #$03
	BEQ .Return

	LDA #$02	;set fire to item
	STA $0DC2|!Base2

	SEC		;sec on fire
.Return
	RTS

;=====

HandleCape:
	LDA $19		;test for cape powerup
	CMP #$02
	BNE .NoCape

	LDA #!M_CAPED	;set caped flag
	ORA !STATE,x
	STA !STATE,x

	LDA #$01	;set normal big mario state
	STA $19

	LDA #!M_FIRE	;clear fire flag because the powerup is not cape
	EOR #$FF
	AND !STATE,x
	STA !STATE,x	;new state without cape flag

.NoCape	
	RTS

;=====

HandleFire:
	LDA $19		;test for fire
	CMP #$03
	BNE .NoFire

	LDA #!M_FIRE	;set fire flag
	ORA !STATE,x
	STA !STATE,x

	LDA #$01	;set big mario
	STA $19

	LDA #!M_CAPED	;clear cape flag because the powerup is not cape
	EOR #$FF
	AND !STATE,x
	STA !STATE,x	;new state without cape flag

.NoFire
	RTS

;=====

HandleLostShoe:
	LDA #!MARIOHEADBLANK	;don't draw mario's head
	STA !MARIOTILE,x

	LDA #$C0	;set lost speed
	STA !sprite_speed_y,x

	LDA !STATE,x	;set losing bit
	ORA #!M_LOSING
	STA !STATE,x

	LDA !sprite_tweaker_1686,x	;no object interaction, just fall offscreen
	ORA #$80
	STA !sprite_tweaker_1686,x
	
	LDY #$00	;reset loop index
	LDA #$00	;value to store
.Loop
	STA !154C,y	;zero disable interaction flag
	INY		;next sprite
	CPY #$0C	;12 sprites
	BNE .Loop

	LDA #$30	;hurtmario sets invincibility timer to 30
	STA $1497|!Base2

	LDA !STATE,x	;test flowerup
	BIT #!M_FIRE
	BEQ .NoFire

	LDA #$03	;set fire
	STA $19

	RTS

.NoFire
	BIT #!M_CAPED	;test cape
	BEQ .NoCape

	LDA #$02	;set cape
	STA $19

.NoCape
	RTS

;=====
;SUBS
;=====

FixInteraction:
	LDA #$FF	;no block interaction
	STA $1497|!Base2

	STZ $140D|!Base2

	LDX #$00	;set cape interaction disable + scenery to fool sprite thing
.Loop
	LDA !extra_bits,x	;test if it's a custom sprite
	BIT #$08
	BNE .Custom

;standard
	LDY !sprite_num,x	;load sprite #
	LDA MarioSprInteract,y
	EOR #$01	;invert
	ASL A
	BRA .Store
.Custom
	LDA !extra_prop_2,x	;load sprite # custom
	AND #$02
	EOR #$02	;invert
.Store		;it's a counter, so x2
	STA !154C,x	;store to disbale interaction flag
;	LDA #$01
	STA !1FE2,x
	INX		;next sprite
	CPX #$0C	;all 12
	BNE .Loop

	LDX $15E9|!Base2	;restore sprite

	RTS
;=====

CopyPositions:
	LDA $94
	STA !sprite_x_low,x
	LDA $95
	STA !sprite_x_high,x
	LDA $96
	CLC
	ADC #$10	;16px below
	STA !sprite_y_low,x
	LDA $97
	ADC #$00	;carry
	STA !sprite_y_high,x

	RTS		
;=====

GFXSetup:
	LDA #$FF	;hide all mario
	STA $78

	LDA !STATE,x	;check for cape or flower power up
	BIT #!M_CAPED	;cape?
	BNE .Caped
	BIT #!M_FIRE	;fire?
	BNE .Fire

	LDA $19		;neither, load normal powerup
	BRA .SetPal

.Caped
	LDA #$02	;cape power
	BRA .SetPal
.Fire
	LDA #$03	;fire power
.SetPal
	ASL A		;as it was in all.log
	ORA $0DB3|!Base2	;player
	ASL A
	PHX
	TAX
	REP #$20
	LDA.l $00E2A2|!BankB,x
	PLX	
	STA $0D82|!Base2	;set palette address
	SEP #$20

	
	LDA #!MARIOHEADBLANK	;value to store if ducking
	LDY $73			;load ducking flag
	BNE .Store

	LDY #!MARIOHEADSMALL
	LDA $19			;test powerup
	BEQ .SmallMario
	LDY #!MARIOHEADBIG
.SmallMario
	TYA
.Store
	STA !MARIOTILE,x	;store head tile


	LDA $15		;load pad data
	BIT #$01	;right?
	BNE Right
	BIT #$02
	BEQ NeitherLR
	LDA #$01	;set direction
	STA !157C,x
	RTS

Right:
	STZ !157C,x	;set direction

NeitherLR:
	RTS

;=====

MarioMotion:
	LDA $77		;test if mario is on ground
	BIT #$04
	BEQ InAir2
	BRA NoBoost	;go to ground section

InAir2:
	LDA !STATE,x	;has air boost already been spent?
	BIT #!M_AIRBOOST
	BNE NoBounce

	LDA $16		;test A and B
	ORA $18
	BIT #$80
	BEQ NoBounce
Boost:
	JSL $01AA33|!BankB	;boost speed
	LDA !STATE,x
	ORA #!M_AIRBOOST
	STA !STATE,x
	RTS

NoBoost:
	LDA $16		;test B and A
	ORA $18
	BIT #$80
	BNE Boost

	LDA $15		;test L or R
	BIT #$03
	BEQ NoBounce

;bounce it
	LDA #!YSPDBOUNCE
	EOR #$FF
	INC A
	STA $7D		;mario yspd

	LDA #!M_AIRBOOST
	EOR #$FF
	AND !STATE,x
	STA !STATE,x


NoBounce:
	RTS

;=====

SpriteInteract:
	LDA !new_sprite_num,x
	STA $8A
	LDX #$00	;reset loop index
.Loop
	CPX $15E9|!Base2	;skip self
	BEQ .NextSprite

	LDA !sprite_status,x	;only if sprite isn't dead
	BEQ .NextSprite
	CMP #$04	;and not dieing
	BEQ .NextSprite

	LDA !extra_bits,x	;standard or custom?
	BIT #$08
	BNE .Custom

;standard
	LDY !sprite_num,x	;load sprite #
	LDA MarioSprInteract,y
	BRA .Test
.Custom
	LDA !new_sprite_num,x	;load sprite # custom
	CMP $8A		;compare to shoe that generated (possibly)
	BNE .NotShoe

	LDA !sprite_status,x	;is falling?
	CMP #$02
	BEQ .NextSprite	;ignore dieing generator sprite

.NotShoe
	LDA !extra_prop_2,x
	AND #$02
.Test
	BNE .NextSprite	;01 means don't try clipping test for hurt / kill
	
	TXY		;sprite X->Y
	PHX
	LDX $15E9|!Base2	;sprite index in X
	JSR ClipTest	;do clipping
	PLX
	BCS .Return	;clipped = return
	
.NextSprite
	INX		;next sprite
	CPX #$0C	;12 sprites
	BNE .Loop

.Return
	LDX $15E9|!Base2	;restore sprite index
	RTS

;=====

ClipTest:
	JSL $03B69F|!BankB	;clipA
	PHX
	TYX
	JSL $03B6E5|!BankB	;clipB
	PLX
	JSL $03B72B|!BankB		;check contact between A and B
	BCC .ClippingReturn	;no contact = don't set

	REP #$20	;adjust Y position
	LDA $96
	PHA
	CLC
	ADC.w #$0010	;16px adjust, BROKEN, DOES NOTHING OR KILLS UNWANTEDLY
	STA $96
	SEP #$20

	PHX
	PHY
	TYX
	%SubVertPos()
	PLY
	PLX

	REP #$20	;restore Yposition
	PLA
	STA $96
	SEP #$20

	;BCC .ClippingReturn

	LDA !sprite_status,y	;stunned = kill
	CMP #$09
	BEQ .Kill

	LDA $7D		;test mario's Yspd
	BMI .Lose
	BEQ .Lose
	CMP #$10	;even on ground, there's a slight yspeed downward
	BCC .Lose
	BPL .Kill	;kill if falling

.Lose
	PHX
	LDX $15E9|!Base2
	LDA #!M_ACTIVE	;clear active mask
	EOR #$FF
	AND !STATE,x
	ORA #!M_LOST	;set shoe lost
	STA !STATE,x
	PLX
	
	LDA #!SHOELOSTSFX	;play shoe lost sound
	STA !SHOELOSTSFXPORT

	CLC

	RTS

.Kill
	LDA !sprite_tweaker_1656,y
	AND #$10
	BNE .Kill2
	LDA #$02
	STA $1DF9|!Base2
	JSL $01AA33|!BankB
	JSL $01AB99|!BankB
	RTS
.Kill2
	JSR SUB_STOMP_PTS	;give points
	LDA !sprite_tweaker_1656,y		;set cloud of smoke dissappear
	ORA #$80
	STA !sprite_tweaker_1656,y

	LDA #$02	;falling
	STA !sprite_status,y
	
	JSL $01AA33|!BankB	;boost speed

	SEC		;set carry = processed

.ClippingReturn
	RTS

;=====

MaskSound:
	LDA $1DFA|!Base2	;test for mario jump
	CMP #$01
	BNE TryN1
	STZ $1DFA|!Base2	;wipe jump

TryN1:
	LDA $1DF9|!Base2	;test for cape swipe
	CMP #$0F
	BNE TryN2
	STZ $1DF9|!Base2
TryN2:
	LDA $1DFC|!Base2	;test for spin jump
	CMP #$04
	BNE TryN3
	STZ $1DFC|!Base2

TryN3:
	RTS

;=====

GFX:
	LDA !15F6,x	;properties...
	STA !PROPRAM

	LDA !157C,x	;direction...
	BNE NoFlip2

	LDA #$40	;set mirror
	TSB !PROPRAM

NoFlip2:
	LDA $00		;xpos
	STA $0300|!Base2,y
	LDA $01		;ypos
	STA $0301|!Base2,y
	LDA $14		;frame count to figure out shoe frame
	LSR A
	LSR A
	LSR A
	AND #$01
	TAX
	LDA SHOEFRAME,x
;	ORA $02
	STA $0302|!Base2,y
	LDA !PROPRAM	;properties
	ORA $64
	STA $0303|!Base2,y

	LDX $15E9|!Base2	;restore sprite

;draw mario head
	LDA $00		;same xpos
	STA $0304|!Base2,y

	LDA $01		;sub 16px from ypos
	SEC
	SBC #$10
	STA $0305|!Base2,y
	LDA !MARIOTILE,x
	CMP #!MARIOHEADBLANK
	BNE NoHide
	LDA #$F0
	STA $0305|!Base2,y
NoHide:

	LDA !MARIOTILE,x	;set tile to mario's head / cap
;	ORA $02
	STA $0306|!Base2,y

	LDA $0313|!Base2	;grab palette
	AND #$0E
	PHY
	LDY !157C,x	;test directions
	BNE DrawLeft
	ORA #$40	;set flip
DrawLeft:
	ORA $64
	PLY
	STA $0307|!Base2,y	;copy to sprite properties

	LDX $15E9|!Base2	;restore sprite index

	LDY #$02	;16x16
	LDA #$01	;2 tiles
	%FinishOAMWrite()

	RTS

;=================
;BORROWED ROUTINES
;=================

STAR_SOUNDS:         
	db $00,$13,$14,$15,$16,$17,$18,$19

;POINTS
;======

SUB_STOMP_PTS:       PHY                     ; 
                    LDA $1697|!Base2               ; \
                    CLC                     ;  } 
                    ADC !1626,x             ; / some enemies give higher pts/1ups quicker??
                    INC $1697|!Base2               ; increase consecutive enemies stomped
                    TAY                     ;
                    INY                     ;
                    CPY #$08                ; \ if consecutive enemies stomped >= 8 ...
                    BCS NO_SOUND            ; /    ... don't play sound 
                    LDA STAR_SOUNDS,y             ; \ play sound effect
                    STA $1DF9|!Base2               ; /   
NO_SOUND:            TYA                     ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET            ;  |
                    LDA #$08                ; /
NO_RESET:            JSL $02ACE5|!BankB             ; give mario points
                    PLY                     ;
                    RTS                     ; return