;Poplin shop from SMB Wonder by Soul
;Defines
!ItemStop = $18F6|!addr ;used to prevent item code from triggering before being purchased (1byte)
!ItemSelected = $0F63|!addr ;used to store the selected items (2byte)
!CooldownRAM = $0F64|!addr
!Items = 3
;load code
;start of main code
init:
LDA #$01
STA !ItemSelected
RTL
main:
LDA #$FF
STA $18BD|!addr ;we do a little bit of stunning
LDA #$7F
STA $78 ;makes mario invisible
STZ !CooldownRAM
LDA $16
AND #$02
BNE .moveL
LDA $16
AND #$01
BNE .moveR
LDA $17
;     axlr----
AND #%10000000
BNE .buyitem
RTL
.buyitem
LDA !ItemSelected
ASL
TAX
JMP (.list-$02,x)
RTL
.moveL
LDA !ItemSelected
CMP #$01
BEQ .return
DEC !ItemSelected
jsl sound
RTL
.moveR
LDA !ItemSelected
CMP #$!Items
BEQ .return
INC !ItemSelected
jsl sound
RTL
.return
RTL
.list:
dw oneup
dw fiveup
dw return
return:
  RTL
.list:
;dw StandeeSurprise ;not used yet
;start of pointers
WonderSeed:
RTL
oneup:
LDA #$08
JSL $02ACE5|!addr
RTL
fiveup:
LDA #$0B
JSL $02ACE5|!addr
RTL
SpringFeetBadge:
RTL
sound:
LDA #$06
STA $1DFC|!addr
RTL