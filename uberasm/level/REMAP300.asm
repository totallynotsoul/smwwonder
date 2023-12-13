init:
LDA.b #$51	; \ layer 3 tilemap
STA.w $2109	; / 64x32
STZ $24		; \ reset layer 3
STZ $25		; / Vscroll values
RTL