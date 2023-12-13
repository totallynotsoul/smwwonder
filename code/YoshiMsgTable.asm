; Edit the tables below with the values you want.

@includefrom "YoshiMsgPatch.asm"

;==================================================================================================================;
; Per-level behavior of Yoshi's rescue message.                                                                    ;
;   !NoMsg  = never show Yoshi message.                                                                            ;
;   !NoMsg = show Yoshi's message if the "Yoshi saved for the first time" flag is not set, and then set the flag. ;
;   !YesMsg = always show Yoshi's message.                                                                         ;
;==================================================================================================================;
YoshiMessageBehavior:
!NoMsg  ;level 000 (Keep it at this value!)
!NoMsg ;level 001
!NoMsg ;level 002
!NoMsg ;level 003
!NoMsg ;level 004
!NoMsg ;level 005
!NoMsg ;level 006
!NoMsg ;level 007
!NoMsg ;level 008
!NoMsg ;level 009
!NoMsg ;level 00A
!NoMsg ;level 00B
!NoMsg ;level 00C
!NoMsg ;level 00D
!NoMsg ;level 00E
!NoMsg ;level 00F
!NoMsg ;level 010
!NoMsg ;level 011
!NoMsg ;level 012
!NoMsg ;level 013
!NoMsg ;level 014
!NoMsg ;level 015
!NoMsg ;level 016
!NoMsg ;level 017
!NoMsg ;level 018
!NoMsg ;level 019
!NoMsg ;level 01A
!NoMsg ;level 01B
!NoMsg ;level 01C
!NoMsg ;level 01D
!NoMsg ;level 01E
!NoMsg ;level 01F
!NoMsg ;level 020
!NoMsg ;level 021
!NoMsg ;level 022
!NoMsg ;level 023
!NoMsg ;level 024
!NoMsg ;level 101
!NoMsg ;level 102
!NoMsg ;level 103
!NoMsg ;level 104
!NoMsg ;level 105 (You might want to edit this.)
!NoMsg ;level 106
!NoMsg ;level 107
!NoMsg ;level 108
!NoMsg ;level 109
!NoMsg ;level 10A
!NoMsg ;level 10B
!NoMsg ;level 10C
!NoMsg ;level 10D
!NoMsg ;level 10E
!NoMsg ;level 10F
!NoMsg ;level 110
!NoMsg ;level 111
!NoMsg ;level 112
!NoMsg ;level 113
!NoMsg ;level 114
!NoMsg ;level 115
!NoMsg ;level 116
!NoMsg ;level 117
!NoMsg ;level 118
!NoMsg ;level 119
!NoMsg ;level 11A
!NoMsg ;level 11B
!NoMsg ;level 11C
!NoMsg ;level 11D
!NoMsg ;level 11E
!NoMsg ;level 11F
!NoMsg ;level 120
!NoMsg ;level 121
!NoMsg ;level 122
!NoMsg ;level 123
!NoMsg ;level 124
!NoMsg ;level 125
!NoMsg ;level 126
!NoMsg ;level 127
!NoMsg ;level 128
!NoMsg ;level 129
!NoMsg ;level 12A
!NoMsg ;level 12B
!NoMsg ;level 12C
!NoMsg ;level 12D
!NoMsg ;level 12E
!NoMsg ;level 12F
!NoMsg ;level 130
!NoMsg ;level 131
!NoMsg ;level 132
!NoMsg ;level 133
!NoMsg ;level 134
!NoMsg ;level 135
!NoMsg ;level 136
!NoMsg ;level 137
!NoMsg ;level 138
!NoMsg ;level 139
!NoMsg ;level 13A
!NoMsg ;level 13B

;================================================================================================;
; What message to display per-level.                                                             ;
;   $00 = no message.                                                                            ;
;   $01 = level message 1.                                                                       ;
;   $02 = level message 2.                                                                       ;
;   $FF = vanilla Yoshi's rescue message (000-2 message in LM's menu).                           ;
; Note that you can also use values from $03 to $FE: they'll load messages from the next levels. ;
; For example, using $03 for level 105 will load message 1 of level 106.                         ;
;================================================================================================;
MessageToShow:
db $00  ;level 000 (Keep it at this value!)
db $FF  ;level 001
db $FF  ;level 002
db $FF  ;level 003
db $FF  ;level 004
db $FF  ;level 005
db $FF  ;level 006
db $FF  ;level 007
db $FF  ;level 008
db $FF  ;level 009
db $FF  ;level 00A
db $FF  ;level 00B
db $FF  ;level 00C
db $FF  ;level 00D
db $FF  ;level 00E
db $FF  ;level 00F
db $FF  ;level 010
db $FF  ;level 011
db $FF  ;level 012
db $FF  ;level 013
db $FF  ;level 014
db $FF  ;level 015
db $FF  ;level 016
db $FF  ;level 017
db $FF  ;level 018
db $FF  ;level 019
db $FF  ;level 01A
db $FF  ;level 01B
db $FF  ;level 01C
db $FF  ;level 01D
db $FF  ;level 01E
db $FF  ;level 01F
db $FF  ;level 020
db $FF  ;level 021
db $FF  ;level 022
db $FF  ;level 023
db $FF  ;level 024
db $FF  ;level 101
db $FF  ;level 102
db $FF  ;level 103
db $FF  ;level 104
db $01  ;level 105 (You might want to edit this.)
db $FF  ;level 106
db $FF  ;level 107
db $FF  ;level 108
db $FF  ;level 109
db $FF  ;level 10A
db $FF  ;level 10B
db $FF  ;level 10C
db $FF  ;level 10D
db $FF  ;level 10E
db $FF  ;level 10F
db $FF  ;level 110
db $FF  ;level 111
db $FF  ;level 112
db $FF  ;level 113
db $FF  ;level 114
db $FF  ;level 115
db $FF  ;level 116
db $FF  ;level 117
db $FF  ;level 118
db $FF  ;level 119
db $FF  ;level 11A
db $FF  ;level 11B
db $FF  ;level 11C
db $FF  ;level 11D
db $FF  ;level 11E
db $FF  ;level 11F
db $FF  ;level 120
db $FF  ;level 121
db $FF  ;level 122
db $FF  ;level 123
db $FF  ;level 124
db $FF  ;level 125
db $FF  ;level 126
db $FF  ;level 127
db $FF  ;level 128
db $FF  ;level 129
db $FF  ;level 12A
db $FF  ;level 12B
db $FF  ;level 12C
db $FF  ;level 12D
db $FF  ;level 12E
db $FF  ;level 12F
db $FF  ;level 130
db $FF  ;level 131
db $FF  ;level 132
db $FF  ;level 133
db $FF  ;level 134
db $FF  ;level 135
db $FF  ;level 136
db $FF  ;level 137
db $FF  ;level 138
db $FF  ;level 139
db $FF  ;level 13A
db $FF  ;level 13B
