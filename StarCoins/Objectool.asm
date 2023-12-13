;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ObjecTool v. 0.4, by imamelia
;;
;; This patch allows you to insert custom extended objects (they will go in as
;; objects 02-0F and 98-FF).  It also enables you to insert custom NORMAL objects
;; for object 2D, which has been expanded to 5 bytes through Lunar Magic 1.8.
;;
;; Credit to 1024 (aka 0x400) for the original ObjecTool.
;;
;; RAM addresses to know:
;;
;; $57 - The position of an object within the subscreen.  Usually used to index [$6B] and [$6E].
;; $59 - The settings byte for normal objects; the object number for extended objects.
;; $5A - The object number for normal objects.
;; $58 - Unused in the original SMW; I used it as the *second* settings byte for normal objects.
;; [$6B] - 24-bit pointer to the low byte of the Map16 tile at the position of the object that is currently being
;;	processed.  It should be indexed by $57: [$6B],y, where Y = the contents of $57.
;; [$6E] - 24-bit pointer to the high byte of the Map16 tile at the position of the object that is currently being
;;	processed.  It should be indexed by $57: [$6E],y, where Y = the contents of $57.
;; $1931 - The object tileset.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lorom

!sa1 = 0
!gsu = 0
!dp = $0000
!addr = $0000
!bank = $800000

if read1($00FFD6) == $15
	sfxrom
	!gsu = 1
	!dp = $6000
	!addr = $6000
	!bank = $000000
elseif read1($00FFD5) == $23
	sa1rom
	!sa1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
endif

incsrc ./StarCoinsDefs.asm

org $0DA106|!bank		; x6A306 (hijack extended object loading routine)
autoclean JML NewExObjects		; E2 30 A5 59       

org $0DA415|!bank		; x6A615 (hijack normal object loading routine)
autoclean JML NewNormObjects	; E2 30 AD 31 19
NOP			;

freecode

if !InitLocation == 1
	print "Objectool code is located at: $",pc
endif

NewExObjects:	;

SEP #$30		; restore hijacked code
LDA $59		; and load extended object number (was done in the original code anyway)
CMP #$10		; if the extended object number is less than 10...
BCC ObjRt00to0F	; then check to see if it is 02-0F
CMP #$98		; if the extended object number is equal to or greater than 98...
BCS ObjRt98toFF	; then it is a custom extended object

NotCustomE:	;
JML $0DA10A|!bank	;

ObjRt00to0F:	;

CMP #$02		; if the extended object number is less then 02...
BCC NotCustomE	; then it isn't a custom one either

ObjRt02to0F:	;

PHB		;
PHK		;
PLB		; change the data bank
JSR ExObjs02to0F	; execute code for extended objects 02-0F
PLB		;
ReturnCustomE:	;
JML $0DA53C|!bank	; jump to an RTS in bank 0D

ObjRt98toFF:	;

PHB		;
PHK		;
PLB		; change the data bank
JSR ExObjs98toFF	; execute code for extended objects 98-FF
PLB		;
BRA ReturnCustomE	;

ExObjs02to0F:	;

TAX		; extended object number into X (not necessary, but done in the original)
DEC		;
DEC		; decrement the extended object number by 2
JSL $0086DF|!bank	; 16-bit pointer subroutine

incsrc custobjptrs1.asm

ExObjs98toFF:	;

TAX		; extended object number into X (not necessary, but done in the original)
SEC		;
SBC #$98		; subtract 98 from the extended object number
JSL $0086DF|!bank	; 16-bit pointer subroutine

incsrc custobjptrs2.asm

NewNormObjects:	;

SEP #$30		;
LDA $5A		; check the object number
CMP #$2D	; if it is equal to 2D...
BEQ CustNormObjRt	; then it is a custom normal object

NotCustomN:	;
LDA $1931|!addr	; hijacked code
JML $0DA41A|!bank	;

CustNormObjRt:	;

LDY #$00		; start Y at 00
LDA [$65],y	; this should point to the next byte
STA $5A		; the first new settings byte is the new object number
INY		; increment Y to get to the next byte
LDA [$65],y	;
STA $58		; the second new settings byte
INY		; increment Y again...
TYA		;
CLC		;
ADC $65		; add 2 to $65 so that the pointer is in the right place,
STA $65		; since this is a 5-byte object (and SMW's code expects them to be 3 bytes)
LDA $66		; if the last byte overflowed...
ADC #$00	; add 1 to it
STA $66		;

PHB		;
PHK		;
PLB		; change the data bank
JSR Object2DRt	; execute codes for custom normal objects
PLB		;
ReturnCustomN:	;
JML $0DA53C|!bank	; jump to an RTS in bank 0D

Object2DRt:	;

LDA $5A		; object number
TAX		; also goes into X
JSL $0086DF|!bank	; pointer routine

incsrc custobjptrs3.asm

incsrc custobjcode.asm

if !BytesUsed == 1
	print "Freespace used by Objectool: ",freespaceuse," bytes."
endif