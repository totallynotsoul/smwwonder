; Basic bounce block
;   by lx5, modified by spooonsss
; For Pixi v1.40, on SA-1, download bugfix file for pixi/routines/bounce/GetDrawInfo.asm
;   https://github.com/JackTheSpades/SpriteToolSuperDelux/blob/master/routines/Bounce/GetDrawInfo.asm
;
; If spawning this using GPS v1.4.4 %spawn_bounce_sprite(), change the 3 defines starting with !RAM_BounceMap16Low to match pixi's asm/sa1def.asm
;   (on SA-1, starting with !RAM_BounceMap16Low_SA1)
; GPS/defines.asm:
; !RAM_BounceMap16Low = $16C1|!addr
; !RAM_BounceMap16High = $1968|!addr
; !RAM_BounceTileTbl = $196C|!addr
; ; These are the SA-1 defines to the above bounce block sprite defines.
; !RAM_BounceMap16Low_SA1 = $16C1|!addr
; !RAM_BounceMap16High_SA1 = $1968|!addr
; !RAM_BounceTileTbl_SA1 = $196C|!addr
;
;   (though !RAM_BounceTileTbl isn't read by this bounce block)

!tile_number = $A6 ; turnblock

; !tile_number = $2A ; ? block
; !tile_number = $2E ; anon block
; !tile_number = $16B ; note block

!palette = 1 ; gray
; !palette = 2 ; yellow

!EraseCoinAbove = 1

assert !palette < 8
assert !tile_number < $200

print "MAIN", pc
    LDA.b #$20|(!palette<<1)|select(greaterequal(!tile_number, $100), 1, 0) ; yxppccct properties
    STA !bounce_properties,x
    LDA.b #!tile_number
    ;LDA !bounce_table_3,x
    %BounceGenericDraw()
    LDA $9D
    BNE not_done
init:
    LDA !bounce_init,x
    BNE no_init
    INC !bounce_init,x
if !EraseCoinAbove
    %EraseCoinAbove()
endif
    %InvisibleMap16()
    %SetMarioSpeed()
no_init:
    %UpdatePos()
    %BounceSetSpeed()
    LDA !bounce_timer,x
    BNE not_done
    ; %RevertMap16() - can't use this, it only accepts $9C values
    %BounceSetupMap16()
    LDA !bounce_map16_high,x
    XBA
    LDA !bounce_map16_low,x
    REP #$20
    %ChangeMap16()
    SEP #$20
    STZ !bounce_num,x
not_done:
    RTL
