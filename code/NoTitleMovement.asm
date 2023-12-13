; Removes title screen movement
; By DiscoTheBat, LM stuff by Erik557

	!addr = $0000
if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
elseif read1($00FFD5) == $23
	sa1rom
	!addr = $6000
endif

org $009C1F          ;\ nuke movement data
       pad $009C64   ;/

if read1($009C6F) == $22    ; this nukes a nice lm hijack
       autoclean read3(read3($009C70)+35)-2      ; get rid of the moves
       autoclean read3($009C70)                  ; get rid of custom code

       org $009C6F                               ; restore
              LDX $1DF4|!addr
              DEC $1DF5|!addr
              BNE +
              LDA $9C20,x
              STA $1DF5|!addr
              INX
              INX
              STX $1DF4|!addr
              +
endif

org $009C82
       NOP           ;\ removes title screen movement
       LDA #$00      ;/

org $009C87          
       BRA $06       ; title screen never loops

