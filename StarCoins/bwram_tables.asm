;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This file is where you put the BW-RAM addresses that will be saved
;; to BW-RAM and their default values.
;; 
;; How to add a BW-RAM address to save.
;; 1) Select which things you want to save in a save file, for example,
;; Mario and Luigi coins, lives, powerup, item box and yoshi color.
;; 
;; 2) Go to bw_ram_table and add the BW-RAM address AND the amount of
;; bytes to save:
;;
;;		dl $400DB4 : dw $000A
;; 
;; Like SRAM Plus, you need to be sure that those RAM addresses aren't
;; cleared automatically when loading a save file.
;; 
;; 3) Then go to bw_ram_defaults and put the default values of your
;; BW-RAM address when loading a new file. Make sure that the default
;; values are in the same order as bw_ram_table to not get weird values
;; when loading a save file.
;; 
;; There is a maximum amount of bytes that you can save per save file
;; and that value is 2370 bytes.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bw_ram_table:
		dl !FreeRAM : dw $00C8
		dl $3019   : dw $0001 ;Mario's Powerup
                dl $400DB9 : dw $0001 ;Luigi's Powerup
                dl $400DC2 : dw $0001 ;Mario's Item Box
                dl $400DBD : dw $0001 ;Luigi's Item Box
                dl $400DBE : dw $0001 ;Mario's Lives
                dl $400DB5 : dw $0001 ;Luigi's Lives
                dl $4013C7 : dw $0001 ;Mario's Yoshi Color
                dl $400DBB : dw $0001 ;Luigi's Yoshi Color
                dl $400DBF : dw $0001 ;Mario's Coins
                dl $400DB7 : dw $0001 ;Luigi's Coins
                dl $400F34 : dw $0003 ;Mario's Score
                dl $400F37 : dw $0003 ;Luigi's Score
                dl $400F48 : dw $0001 ;Mario's Bonus
                dl $400F49 : dw $0001 ;Luigi's Bonus
                dl $400DC1 : dw $0001 ;Yoshi Overworld
                dl $401F2F : dw $000C ;Yoshi Coin Collected
		dl $406000 : dw $0060
.end
		
bw_ram_defaults:
		fillbyte $00 : fill 8			; NSMB Coins, misc stuff.
		fillbyte $00 : fill 96			; NSMB Coins, flags.
		fillbyte $00 : fill 96			; NSMB Coins, midpoint flags.
                db $00,$00,$00,$00,$04,$04,$00,$00
                db $00,$00,$00,$00,$00,$00,$00,$00
                db $00,$00,$00,$00,$00,$00,$00,$00
                db $00,$00,$00,$00,$00,$00,$00
		fillbyte $00 : fill $0060