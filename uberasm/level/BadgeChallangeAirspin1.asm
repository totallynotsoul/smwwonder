!BadgeChallangeFlag = $1696|!addr ;flag to start badge challange and use below ram as badge
!BadgeChallangeBadgeRAM = $1864|!addr
init:
LDA.b #$51	; \ layer 3 tilemap
STA.w $2109	; / 64x32
STZ $24		; \ reset layer 3
STZ $25		; / Vscroll values
rtl
main:
lda #$01
sta !BadgeChallangeFlag
lda #$08
sta !BadgeChallangeBadgeRAM
rtl