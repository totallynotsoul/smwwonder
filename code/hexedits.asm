;SMW Wonder Hexedits / Debug Codes

org $CC84 ;Free-Roaming Mode
	db $f0 ;Enable
	;db $80 ;Disable
org $00CDFC ;no l+r scroll
    db $80
org $02AF13 
LDA.b #$5F
org $05DBF2
    rtl
org $048010 ; $048006+(($XX-$40)*$02), 'XX' = original tile number for frame of animation (tile 45)
dw $B560 ; dw $AD00+($XX*$20), 'XX' = new tile number for same frame of animation (tile 43)

org $048012 ; tile 46
dw $B540 ; tile 42

org $048014 ; tile 47
dw $B520 ; tile 41

;second cloud animation
org $048016 ; tile 48
dw $B580 ; tile 44

org $048018 ; tile 49
dw $B560 ; tile 43

org $04801A ; tile 4A
dw $B540 ; tile 42

org $04801C ; tile 4B
dw $B520 ; tile 41

org $04801E ; tile 4C
dw $B500 ; tile 40

org $048020 ; tile 4D
dw $B520 ; tile 41

org $048022 ; tile 4E
dw $B540 ; tile 42

org $048024 ; tile 4F
dw $B560 ; tile 43

;big star

org $048040 ; tile 5D
dw $B860 ; tile 5B

org $048042 ; tile 5E
dw $B840 ; tile 5A

org $048044 ; tile 5F
dw $B820 ; tile 59

;small star 1

org $048050 ; tile 65
dw $B960 ; tile 63

org $048052 ; tile 66
dw $B940 ; tile 62

org $048054 ; tile 67
dw $B920 ; tile 61

;small star 2
org $048072 ; tile 76
dw $BB60 ; tile 73

org $048074 ; tile 77
dw $BB40 ; tile 72

;small star 3
org $048076 ; tile 78
dw $BBA0 ; tile 75

org $04807C ; tile 7B
dw $BB00 ; tile 70

org $048080 ; tile 7D
dw $BC40 ; tile 7A

org $048082 ; tile 7E
dw $BC20 ; tile 79
; width of door enterable region of the door (up to 0x10, default 0x08) 
org $00F44B : db $10

; offset of door enterable region, which is half of above (default 0x04)
org $00F447 : db $05 
org $02CAFA
	db $4B,$0B
org $0096A6 ;nuke mario start
db $80,$03
org $05828B ;moar slopes
LDA.w #$E55E
org $01D6FA ;lineguide fix
    db $00

org $01D701
    db $00
org $009436
    db $4C,$17,$94

org $009AAD
    db $4C,$C0,$9A ;nuke ts circle fade
org $009F67 ;get rid of mosaic effect
    db $00