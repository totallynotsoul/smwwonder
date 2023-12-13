;Ground Pound UberASM
;this one gives ground pound ability that acts the same as yellow yoshi + shell/yoshi + yellow shell.

;button used to do ground pound. list:
;!Up
;!Down
;!L		;\L trigger
;!R		;/R trigger, not left/right D-pad direction
;!A
;!B
!Button = !R

;Button used to cancel out of ground pound
!CancelButton = !Up

;Frame used during ground pound
!GroundPndFrame = $1C		;

!GroundPndSpeed = $40		;downward speed during ground pound
!MaxSpeed = $50			;Smibbix: Maybe there could be a couple options like having Mario also fall a little quicker when holding down, to give a cool heavy effect.
				;if less than !GroundPndSpeed or !CancelButton is down, this won't work.

!GroundPndAirStay = $10		;how long stay in air before dropping
!GroundPoundDelay = $0A		;how long player is unable to activate ground pound again after cancelling

!GroundPndStartSound = $23
!GroundPndStartBank = $1DF9|!addr

!GroundPndFlag = $1869|!addr	;also acts like speed container for faster fall. RAM reusin' rules
!GroundPndTimer = $186A|!addr	;how long to stay in air after pressing trigger button. also used for delay before player can re-activate ground pound again.

incsrc ../GroundPoundSrc.asm

NoPoundAndDelay:
STZ !GroundPndTimer

NoPound:
STZ !GroundPndFlag		;disable ground pound (branch out of bounds edition).
RTL

main:
LDA $9D				;freeze flag (hurt, pickup power-up, growing yoshi, etc.)
LDA $13D4|!addr			;no pause
ORA $1426|!addr			;no message box (which stops action)
BNE .Re

LDA $74				;no climbing
ORA $1407|!addr			;no flying
ORA $75				;can't ground pound underwater
ORA $1470|!addr			;\not when carrying an item
ORA $148F|!addr			;/
ORA $187A|!addr			;not when riding a yoshi (don't feel like offsetting position + yellow shell/yoshi shenanigans)
ORA $1493|!addr			;not when goal
BNE NoPound			;reset ground pound state if any of this is true

LDA $71				;check various player animations, like death, entering level via pipe, door, and etc.
BNE NoPound 			;

LDA !GroundPndFlag		;
BNE .GroundPoundin		;

LDA $72				;can only ground pound when in air
BEQ NoPoundAndDelay		;

LDA !GroundPndTimer		;delay
BNE .ReTimer			;

LDA !ControllerTrigger		;check for controller input that triggers ground pound
AND #!ButtonTrigger		;
BEQ .Re				;

LDA #!GroundPndAirStay		;
STA !GroundPndTimer		;set short timer to stay in air

if !MaxSpeed > !GroundPndSpeed && !CancelButton != !Down
  LDA #!GroundPndSpeed
  STA !GroundPndFlag		;
else
  INC !GroundPndFlag		;
endif

STZ $140D|!addr			;disable spinjump
STZ $73				;no duck jump
LDA #$24
STA $72					;break sprint jump state
STZ $13E4|!addr			;something about run-jumping
STZ $14A6|!addr			;no cape swinging allowed
JSR DisableSomeButtons		;frame perfect cape swing

LDA #!GroundPndStartSound	;play sound
STA !GroundPndStartBank		;

STZ $7D				;no Y Spd

.Re
RTL				;

.ReTimer
DEC !GroundPndTimer		;
RTL				;

.GroundPoundin
STZ $7B				;no X Spd

JSR DisableSomeButtons		;no X/Y and left/right input

LDA #!GroundPndFrame		;set ground pound frame
STA $13E0|!addr			;

LDA !GroundPndTimer		;stay in air for a little bit
BEQ .Move			;untill timer is zero
DEC !GroundPndTimer		;tick timer

LDA $7D				;chuck and disco shell
BMI .NoPoundAndDelay		;

STZ $7D				;
BRA .CheckGround		;fix ground rising up thing

.Move
LDA !CancelControllerTrigger	;can cancel out with a button
AND #!CancelButtonTrigger	;
BNE .NoPoundAndDelay		;

.Checks
LDA $7D				;if we stomped something or gained upward speed in any way...
BMI .NoPoundAndDelay		;stop ground pound

if !MaxSpeed > !GroundPndSpeed && !CancelButton != !Down
  ;LDA !GroundPndTimer
  ;BNE .CheckGround

  LDA $15
  AND #$04
  BNE .MoveFaster

;natural force's at work.
  DEC !GroundPndFlag
  LDA !GroundPndFlag
  CMP #!GroundPndSpeed
  BCS .Skip			;keep speed consistent

  LDA #!GroundPndSpeed		;set downward speed
  STA !GroundPndFlag		;
  BRA .Skip

.MoveFaster
  LDA !GroundPndFlag
  CMP #!MaxSpeed
  BCS .Skip

  INC !GroundPndFlag

.Skip
LDA !GroundPndFlag
STA $7D

else
  ;LDA !GroundPndTimer
  ;BNE .CheckGround

  LDA #!GroundPndSpeed
  STA $7D				;
endif

.CheckGround
LDA $77				;check if we touch a ground
AND #$04			;
BEQ .Re				;
LDA #$09
STA $1DFC|!addr


.NoPoundAndDelay
STZ !GroundPndFlag		;disable ground pound.

LDA #!GroundPoundDelay
STA !GroundPndTimer
RTL

;.NoPoundNoRunFrame
;STZ $13E4|!addr		;doesn't fix run-jumping frame.
;LDA #$24			;run jump cancel
;STA $13E0|!addr		;(graphical)
;BRA .NoPoundAndDelay		;

DisableSomeButtons:
LDA #$43			;disable left and right direction buttons
TRB $16				;
TRB $15				;can't hold X/Y (to make sure player doesn't grab anything during ground pound and cancel it)
RTS