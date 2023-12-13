;##################################################################################################
;# YI's Kamek magic effect
;#    made by lx5 as a (public) commissioned work
;#    version 1.0
;#
;# Attempt at recreating YI's Kamek magic effect on SMW. Comes with 12 different colors
;# and a simple to use API.
;# 
;# Requires using Layer 3, it's also compatible with the original status bar.
;# 
;# Available colors:
;#  - Red [1,0,0]
;#  - Blue [0,0,1]
;#  - Green [0,1,0]
;#  - Yellow [0,1,1]
;#  - Pink [1,0,1]
;#  - Cyan [0,1,1]
;#  - Orange [1, 0.5, 0]
;#  - Purple [0.5, 0, 1]
;#  - White [1,1,1]
;#  - Red (alternate) [1, 0.25, 0.25]
;#  - Blue (alternate) [0.25, 0.25, 1]
;#  - Green (alternate) [0.5, 1, 0.25]

;#########################################################################
;# Customization
;# Please keep those defines the same across your resources

;# Enable debug features
;# Lets you control gradient effects by pressing L/R
;# Also gives you a visualizer of the current color & direction
!__enable_debug #= 0

;# Disable SMW status bar compatibility
;# Turns off color math HDMA, thus freeing channel 3 for other HDMA effects
!__disable_status_bar_compat #= 0

;##################
;# RAM defines

;# Misc RAM
;# 16 bytes
!kamek_ram = $7F9FF0

;# HDMA RAM buffer for the layer 3 y position
;# Needs around 568 bytes
!hdma_y_position_table = $7FA000

;# VWF Dialogues RAM
!varram	= $702000

;# Same as above, but they're for SA-1
!kamek_ram_sa1 = $404000
!hdma_y_position_table_sa1 = $404010
!varram_sa1	= $419000

;#########################################################################
;# Internal stuff, do not touch

if !sa1 == 1
    !kamek_ram = !kamek_ram_sa1
    !hdma_y_position_table = !hdma_y_position_table_sa1
    !varram	= !varram_sa1
endif

!layer_3_y_pos = !kamek_ram+$00
!gradient_y_pos = !kamek_ram+$02
!magic_state = !kamek_ram+$04
!magic_direction = !kamek_ram+$05
!magic_color = !kamek_ram+$06
!magic_color_ptr = !kamek_ram+$07
!magic_delay = !kamek_ram+$09
!magic_nmi_codes = !kamek_ram+$0A
!palette_color_index = !kamek_ram+$0B
!palette_color_dest = !kamek_ram+$0C
!kamek_previous_level = !kamek_ram+$0D
!kamek_cutscene_mode = !kamek_ram+$0E
!kamek_cutscene_end_flag = !kamek_ram+$0F

;#########################################################################
;# Reset routine

reset:
    lda #$00
    sta !layer_3_y_pos
    sta !gradient_y_pos
    sta !magic_state
    sta !magic_direction
    sta !magic_color
    sta !magic_delay
    sta !magic_nmi_codes
    sta !kamek_previous_level
    sta !kamek_cutscene_mode
    sta !kamek_cutscene_end_flag
    rtl 

;#########################################################################
;# Init routine, also entry point for "init" labels in levels

nmi:
    lda !magic_nmi_codes
    asl 
    tax 
    jmp (.ptrs,x)

.ptrs
    dw .nothing
    dw .setup_regs
    dw .setup_tilemap
    dw .palette_cycle
    dw .restore_colors

.palette_cycle
    lda !palette_color_dest
    tay 
    lda !palette_color_index
    inc 
    sta !palette_color_index
    lsr #2
    rep #$20
    and #$000F
    asl 
    adc #.colors
	sta $4322
	sty $2121
	lda #$001E
	sta $4325
	lda #$2200
	sta $4320
	ldy #.colors>>16
	sty $4324
	ldy #$04
	sty $420B
    sep #$20
.nothing
    rtl 

    ; Located at $3FE9A8 in YI
    ; Also doubled to make it easier to index with pal & $0F
.colors
    dw $7FFF,$43FF,$435F,$42BF,$421F,$621F,$7E1F,$7E1A,$7E15,$7E10,$7EB0,$7F50,$7FF0,$63F0,$43F0,$43F8
    dw $7FFF,$43FF,$435F,$42BF,$421F,$621F,$7E1F,$7E1A,$7E15,$7E10,$7EB0,$7F50,$7FF0,$63F0,$43F0,$43F8

.restore_colors
    lda !palette_color_dest
    tay 
    rep #$20
	sty $2121
    and #$00FF
    asl 
    adc #$0703
	sta $4322
	lda #$001E
	sta $4325
	lda #$2200
	sta $4320
if !sa1 == 1
    ldy #$40
else
	ldy #$7E
endif
	sty $4324
	ldy #$04
	sty $420B
    sep #$20
    lda #$00
    sta !magic_nmi_codes
    rtl 

.setup_tilemap
    lda #$80
    sta $2115
    lda.b #kamek_tilemap>>16
    sta $4324
    rep #$20
    lda #$1801
    sta $4320
    lda.w #kamek_tilemap+$800
    sta $4322
    lda #$0800
    sta $4325
    lda #$5000+$400
    sta $2116
    sep #$20
    lda #$04
    sta $420B
    lda #$00
    sta !magic_nmi_codes
    rtl 

.setup_regs
    ;# setup main screen regs
           ;---o4321
    lda.b #%00011011
    sta $212C
    sta $212E

    ;# setup sub screen regs
           ;---o4321
    lda.b #%00000100
    sta $212D
    sta $212F

    ;# force layer 3 priority
    lda $3E
    ora #$08
    sta $3E
    sta $2105

    ;# Set window settings
           ;ABCDabcd
    lda.b #%00000000
    sta $41
    sta $2123
           ;ABCDabcd
    lda.b #%10001000
    sta $42
    sta $2124
           ;ABCDabcd
    lda.b #%00000000
    sta $43
    sta $2125
           ;44332211
    lda.b #%00000000
    sta $212A
           ;----ccoo
    lda.b #%00000000
    sta $212B

    ;# Set color math settings
           ;shbo4321
    lda.b #%00110011
    sta $40
           ;ccmm--sd
    lda.b #%00100010
    sta $44

    ;# Activate HDMA channels
    if !__disable_status_bar_compat == 0
             ;76543210
        lda #%01111000
    else 
             ;76543210
        lda #%01110000
    endif
    tsb $0D9F|!addr

    lda #$80
    sta $2115
    lda.b #kamek_tilemap>>16
    sta $4324
    rep #$20
    lda #$1801
    sta $4320
    lda.w #kamek_tilemap+$0140
    sta $4322
    lda.w #$0800-$0140
    sta $4325
    lda #$50A0
    sta $2116
    sep #$20
    lda #$04
    sta $420B
    lda #$02
    sta !magic_nmi_codes
    rtl

init:
    rep #$30
    lda #$1202
    sta $4360           ; Channel 6 - Layer 3 Y pos HDMA
    lda #$2801
    sta $4350           ; Channel 5 - Window #2 HDMA
    lda #$2103
    sta $4340           ; Channel 4 - CGRAM HDMA
    if !__disable_status_bar_compat == 0
        lda #$2C04
        sta $4330           ; Channel 3 - Color math HDMA
    endif
    lda.w #!hdma_y_position_table
    sta $4362
    lda.w #magic_window_rtl
    sta $4352
    lda.w #magic_color_gradient_red
    sta $4342
    sta !magic_color_ptr
    if !__disable_status_bar_compat == 0
        lda.w #magic_color_math
        sta $4332
    endif
    lda #$0000
    sta !layer_3_y_pos
    sta !gradient_y_pos
    sep #$20
    sta !magic_state
    sta !magic_color
    sta !magic_direction
    sta !magic_nmi_codes
    sta !kamek_cutscene_mode
    sta !palette_color_index
    sta !kamek_cutscene_end_flag
    lda.b #!hdma_y_position_table>>16
    sta $4364
    lda.b #magic_window>>16
    sta $4354
    lda.b #magic_color_gradient>>16
    sta $4344
    if !__disable_status_bar_compat == 0
        lda.b #magic_color_math>>16
        sta $4334
    endif

    ;# Hardcode status bar area to not get affected by Layer 3 Y pos HDMA
    lda #$25
    sta !hdma_y_position_table+$00
    lda #$00
    sta !hdma_y_position_table+$01
    sta !hdma_y_position_table+$02

    ;# Build table Layer 3 Y pos HDMA table on init
    ldx #$0003
    ldy #$0000
    lda #$01
.loop 
    sta !hdma_y_position_table+$00,x
    inx #3
    iny #2
    cpy.w #($E0-$25)*2
    bne .loop
    sep #$10
    lda #$00
    sta !hdma_y_position_table+$00,x

;#########################################################################
;# Main routine, also entry point for "main" labels in levels

main:
    phb
    phk 
    plb
    if !__enable_debug == 1
        jsr manual_control
    endif
    ;# Handle control disable
    jsr disable_controls

    ;# Call the primary logic routine for the effect
    jsr magic_logic
    if !__enable_debug == 1
        jsr ui_debug
    endif

    ;# Update CGRAM HDMA pointer based on its Y position
    lda !gradient_y_pos+$00
    sta $211b
    lda !gradient_y_pos+$01
    sta $211b               ; 
    lda #$05
    sta $211c
    rep #$30
    lda $2134
    clc
    adc !magic_color_ptr
    sta $4342

    ;# Prepare for calculating the Layer 3 Y pos HDMA table in RAM
    ;# For the stretch effect we will apply the following function to
    ;# each scanline:
    ;#      f(x) = 1 - sqrt(1 - x**2)
    ;# Function taken from: https://easings.net/en#easeInCirc
    ;#
    ;# Of course we're not doing the calcs for each line, we're just
    ;# using precalculated and offsets values that were carefully
    ;# selected to replicate the effect the best I could:
    ;#      f(x) = 45 + ($10000 - sqrt($10000 - x**2)) >> 9

if !sa1 == 0
        lda !layer_3_y_pos      ; speeeeeed
        sta $00
        ldx #$0003
        ldy #$0000
    .loop
        lda $00
        sec   
        sbc magic_scanlines,y
        and #$01FF              ; this might not be needed...
        sta !hdma_y_position_table+$01,x
        inx #3
        iny #2
        cpy.w #($E0-$25)*2      ; leave out $25 scanlines that the status bar took
        bne .loop
        sep #$30
        plb 
        rtl 
else
        sep #$30
        %invoke_sa1(.sa1_hdma)
        plb 
        rtl 

    .sa1_hdma
        phb
        phk
        plb 
        rep #$30
        lda !layer_3_y_pos      ; speeeeeed
        sta $00
        ldx #$0003
        ldy #$0000
    ..loop
        lda $00
        sec   
        sbc magic_scanlines,y
        and #$01FF              ; this might not be needed...
        sta !hdma_y_position_table+$01,x
        inx #3
        iny #2
        cpy.w #($E0-$25)*2      ; leave out $25 scanlines that the status bar took
        bne ..loop
        sep #$30
        plb 
        rtl 
endif


;#########################################################################
;# Disables controls for cutscenes

disable_controls:
    lda !kamek_cutscene_mode
    beq .nope
    stz $15
    stz $16
    stz $17
    stz $18
.nope
    rts

;#########################################################################
;# Logic behind the magic effect
;# In short, a state machine was used to determine when it should
;# run and in which direction it should go
;# It requires activation from outside, so you'd need a helper resource
;# to trigger the magic effect
;# To trigger the effect just store $01 to !magic_state and the
;# effect will play

magic_logic:
    lda !magic_state
    asl 
    tax 
    jmp (.ptrs,x)

.ptrs
    dw .wait            ;# $00 - Wait for input
    dw .init            ;# $01 - Initialization
    dw .move_down       ;# $02 - Movement
    dw .reset           ;# $03 - Reset -> Wait for input

.wait 
    rts 

.init
    lda !magic_delay
    beq ..do
    dec 
    sta !magic_delay
    rts
..do
    ;# Setup indexes for later usage
    lda !magic_direction
    asl 
    tay 
    lda !magic_color
    asl 
    tax 
    rep #$20

    ;# Store new magic effect color
    lda.l magic_color_gradient,x
    sta !magic_color_ptr

    ;# Store new window shape
    lda magic_window,y
    sta $4352

    ;# Shift the layer 3 image accordingly
    lda magic_x_offset,y
    sta $22

    ;# Set up initial values for both the gradient and the layer 3
    lda #$00B4
    sta !layer_3_y_pos
    lda #$00E0
    sta !gradient_y_pos
    sep #$20

    ;# Jump to next state
    lda #$02
    sta !magic_state
    rts 

.move_down
    ;# This routine decreases the gradient & layer 3 Y positions by 1
    ;# per frame
    ;# When the layer 3 Y position is lower than $0050, the gradient
    ;# will scroll down faster so the effect ends quicker
    rep #$20
    ldy #$00
    ldx #$00
    lda !layer_3_y_pos
    dec 
    cmp #$0050
    bcc + 
    iny 
+   
    cmp #$0000
    bmi +
    sta !layer_3_y_pos
+   
-   
    lda !gradient_y_pos
    dec 
    bmi +
    sta !gradient_y_pos
    iny 
    cpy #$01
    beq -
+   
    sep #$20
    cpy #$00
    bne ..return
    ;# After processing the logic and both things are at their lowest positions
    ;# jump to the reset state
    lda #$03
    sta !magic_state
..return
    rts 

.reset
    ;# Reset to wait for input
    lda #$00
    sta !magic_state
    rts 

;#########################################################################
;# Debug codes

if !__enable_debug == 1
    ui_debug:
        lda !magic_color
        asl 
        tax 
        lda !magic_direction
        asl 
        tay 
        lda .col_tiles,x
        sta $0F06
        lda .col_tiles+1,x
        sta $0F07
        lda .direction,y
        sta $0F21
        lda .direction+1,y
        sta $0F22
        rts 

    .col_tiles
        db $1B,$0E;"re"
        db $0B,$15;"bl"
        db $10,$1B;"gr"
        db $22,$0E;"ye"
        db $16,$0A;"ma"
        db $0C,$22;"cy"
        db $18,$1B;"or"
        db $19,$1E;"pu"
        db $20,$11;"wh"
        db $1B,$02;"r2"
        db $0B,$02;"b2"
        db $10,$02;"gr"

    .direction
        db $15,$0E;"le"
        db $1B,$12;"ri"

    manual_control:
        lda $16
        and #$04
        beq .no_down
        lda !magic_color
        dec 
        bmi .activate
        sta !magic_color
        bra .activate
    .no_down
        lda $16
        and #$08
        beq .no_up
        lda !magic_color
        inc 
        cmp.b #((magic_color_gradient_end-magic_color_gradient)/2)
        bcs .activate
        sta !magic_color
    .no_up
    .activate 
        lda $18
        and #$20
        bne .activate_left
        lda $18
        and #$10
        bne .activate_right
        rts 
    .activate_right
        lda #$01
        sta !magic_direction
        lda #$01
        sta !magic_state
        rts 
    .activate_left
        lda #$00
        sta !magic_direction
        lda #$01
        sta !magic_state
        rts
endif

;#########################################################################
;# CGRAM HDMA tables

magic_color_gradient:
    dw .red
    dw .blue
    dw .green
    dw .yellow
    dw .pink
    dw .cyan
    dw .orange
    dw .purple
    dw .white
    dw .red_2
    dw .blue_2
    dw .green_2
.end

.red
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 013 : db $01,$00,$0D,$01,$00
    rep 010 : db $01,$00,$0D,$02,$00
    rep 007 : db $01,$00,$0D,$03,$00
    rep 007 : db $01,$00,$0D,$04,$00
    rep 006 : db $01,$00,$0D,$05,$00
    rep 006 : db $01,$00,$0D,$06,$00
    rep 005 : db $01,$00,$0D,$07,$00
    rep 005 : db $01,$00,$0D,$08,$00
    rep 005 : db $01,$00,$0D,$09,$00
    rep 005 : db $01,$00,$0D,$0A,$00
    rep 005 : db $01,$00,$0D,$0B,$00
    rep 004 : db $01,$00,$0D,$0C,$00
    rep 005 : db $01,$00,$0D,$0D,$00
    rep 004 : db $01,$00,$0D,$0E,$00
    rep 005 : db $01,$00,$0D,$0F,$00
    rep 005 : db $01,$00,$0D,$10,$00
    rep 004 : db $01,$00,$0D,$11,$00
    rep 005 : db $01,$00,$0D,$12,$00
    rep 004 : db $01,$00,$0D,$13,$00
    rep 005 : db $01,$00,$0D,$14,$00
    rep 005 : db $01,$00,$0D,$15,$00
    rep 005 : db $01,$00,$0D,$16,$00
    rep 005 : db $01,$00,$0D,$17,$00
    rep 005 : db $01,$00,$0D,$18,$00
    rep 006 : db $01,$00,$0D,$19,$00
    rep 006 : db $01,$00,$0D,$1A,$00
    rep 007 : db $01,$00,$0D,$1B,$00
    rep 007 : db $01,$00,$0D,$1C,$00
    rep 010 : db $01,$00,$0D,$1D,$00
    rep 013 : db $01,$00,$0D,$1E,$00
    rep 018 : db $01,$00,$0D,$1F,$00
              db $00
.blue
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 013 : db $01,$00,$0D,$00,$04
    rep 009 : db $01,$00,$0D,$00,$08
    rep 008 : db $01,$00,$0D,$00,$0C
    rep 007 : db $01,$00,$0D,$00,$10
    rep 006 : db $01,$00,$0D,$00,$14
    rep 006 : db $01,$00,$0D,$00,$18
    rep 005 : db $01,$00,$0D,$00,$1C
    rep 005 : db $01,$00,$0D,$00,$20
    rep 005 : db $01,$00,$0D,$00,$24
    rep 005 : db $01,$00,$0D,$00,$28
    rep 004 : db $01,$00,$0D,$00,$2C
    rep 005 : db $01,$00,$0D,$00,$30
    rep 005 : db $01,$00,$0D,$00,$34
    rep 004 : db $01,$00,$0D,$00,$38
    rep 005 : db $01,$00,$0D,$00,$3C
    rep 004 : db $01,$00,$0D,$00,$40
    rep 004 : db $01,$00,$0D,$00,$44
    rep 005 : db $01,$00,$0D,$00,$48
    rep 005 : db $01,$00,$0D,$00,$4C
    rep 004 : db $01,$00,$0D,$00,$50
    rep 005 : db $01,$00,$0D,$00,$54
    rep 005 : db $01,$00,$0D,$00,$58
    rep 005 : db $01,$00,$0D,$00,$5C
    rep 005 : db $01,$00,$0D,$00,$60
    rep 006 : db $01,$00,$0D,$00,$64
    rep 006 : db $01,$00,$0D,$00,$68
    rep 007 : db $01,$00,$0D,$00,$6C
    rep 008 : db $01,$00,$0D,$00,$70
    rep 009 : db $01,$00,$0D,$00,$74
    rep 013 : db $01,$00,$0D,$00,$78
    rep 019 : db $01,$00,$0D,$00,$7C
              db $00
.green
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 013 : db $01,$00,$0D,$20,$00
    rep 010 : db $01,$00,$0D,$40,$00
    rep 007 : db $01,$00,$0D,$60,$00
    rep 007 : db $01,$00,$0D,$80,$00
    rep 006 : db $01,$00,$0D,$A0,$00
    rep 006 : db $01,$00,$0D,$C0,$00
    rep 005 : db $01,$00,$0D,$E0,$00
    rep 005 : db $01,$00,$0D,$00,$01
    rep 005 : db $01,$00,$0D,$20,$01
    rep 005 : db $01,$00,$0D,$40,$01
    rep 005 : db $01,$00,$0D,$60,$01
    rep 004 : db $01,$00,$0D,$80,$01
    rep 005 : db $01,$00,$0D,$A0,$01
    rep 004 : db $01,$00,$0D,$C0,$01
    rep 005 : db $01,$00,$0D,$E0,$01
    rep 005 : db $01,$00,$0D,$00,$02
    rep 004 : db $01,$00,$0D,$20,$02
    rep 005 : db $01,$00,$0D,$40,$02
    rep 004 : db $01,$00,$0D,$60,$02
    rep 005 : db $01,$00,$0D,$80,$02
    rep 005 : db $01,$00,$0D,$A0,$02
    rep 005 : db $01,$00,$0D,$C0,$02
    rep 005 : db $01,$00,$0D,$E0,$02
    rep 005 : db $01,$00,$0D,$00,$03
    rep 006 : db $01,$00,$0D,$20,$03
    rep 006 : db $01,$00,$0D,$40,$03
    rep 007 : db $01,$00,$0D,$60,$03
    rep 007 : db $01,$00,$0D,$80,$03
    rep 010 : db $01,$00,$0D,$A0,$03
    rep 013 : db $01,$00,$0D,$C0,$03
    rep 018 : db $01,$00,$0D,$E0,$03
              db $00
.yellow
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 013 : db $01,$00,$0D,$21,$00
    rep 010 : db $01,$00,$0D,$42,$00
    rep 007 : db $01,$00,$0D,$63,$00
    rep 007 : db $01,$00,$0D,$84,$00
    rep 006 : db $01,$00,$0D,$A5,$00
    rep 006 : db $01,$00,$0D,$C6,$00
    rep 005 : db $01,$00,$0D,$E7,$00
    rep 005 : db $01,$00,$0D,$08,$01
    rep 005 : db $01,$00,$0D,$29,$01
    rep 005 : db $01,$00,$0D,$4A,$01
    rep 005 : db $01,$00,$0D,$6B,$01
    rep 004 : db $01,$00,$0D,$8C,$01
    rep 005 : db $01,$00,$0D,$AD,$01
    rep 004 : db $01,$00,$0D,$CE,$01
    rep 005 : db $01,$00,$0D,$EF,$01
    rep 005 : db $01,$00,$0D,$10,$02
    rep 004 : db $01,$00,$0D,$31,$02
    rep 005 : db $01,$00,$0D,$52,$02
    rep 004 : db $01,$00,$0D,$73,$02
    rep 005 : db $01,$00,$0D,$94,$02
    rep 005 : db $01,$00,$0D,$B5,$02
    rep 005 : db $01,$00,$0D,$D6,$02
    rep 005 : db $01,$00,$0D,$F7,$02
    rep 005 : db $01,$00,$0D,$18,$03
    rep 006 : db $01,$00,$0D,$39,$03
    rep 006 : db $01,$00,$0D,$5A,$03
    rep 007 : db $01,$00,$0D,$7B,$03
    rep 007 : db $01,$00,$0D,$9C,$03
    rep 010 : db $01,$00,$0D,$BD,$03
    rep 013 : db $01,$00,$0D,$DE,$03
    rep 018 : db $01,$00,$0D,$FF,$03
              db $00
.pink
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 013 : db $01,$00,$0D,$01,$04
    rep 009 : db $01,$00,$0D,$02,$08
    rep 008 : db $01,$00,$0D,$03,$0C
    rep 007 : db $01,$00,$0D,$04,$10
    rep 006 : db $01,$00,$0D,$05,$14
    rep 006 : db $01,$00,$0D,$06,$18
    rep 005 : db $01,$00,$0D,$07,$1C
    rep 005 : db $01,$00,$0D,$08,$20
    rep 005 : db $01,$00,$0D,$09,$24
    rep 005 : db $01,$00,$0D,$0A,$28
    rep 004 : db $01,$00,$0D,$0B,$2C
    rep 005 : db $01,$00,$0D,$0C,$30
    rep 005 : db $01,$00,$0D,$0D,$34
    rep 004 : db $01,$00,$0D,$0E,$38
    rep 005 : db $01,$00,$0D,$0F,$3C
    rep 004 : db $01,$00,$0D,$10,$40
    rep 004 : db $01,$00,$0D,$11,$44
    rep 005 : db $01,$00,$0D,$12,$48
    rep 005 : db $01,$00,$0D,$13,$4C
    rep 004 : db $01,$00,$0D,$14,$50
    rep 005 : db $01,$00,$0D,$15,$54
    rep 005 : db $01,$00,$0D,$16,$58
    rep 005 : db $01,$00,$0D,$17,$5C
    rep 005 : db $01,$00,$0D,$18,$60
    rep 006 : db $01,$00,$0D,$19,$64
    rep 006 : db $01,$00,$0D,$1A,$68
    rep 007 : db $01,$00,$0D,$1B,$6C
    rep 008 : db $01,$00,$0D,$1C,$70
    rep 009 : db $01,$00,$0D,$1D,$74
    rep 013 : db $01,$00,$0D,$1E,$78
    rep 019 : db $01,$00,$0D,$1F,$7C
              db $00
.cyan
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 013 : db $01,$00,$0D,$20,$04
    rep 009 : db $01,$00,$0D,$40,$08
    rep 008 : db $01,$00,$0D,$60,$0C
    rep 007 : db $01,$00,$0D,$80,$10
    rep 006 : db $01,$00,$0D,$A0,$14
    rep 006 : db $01,$00,$0D,$C0,$18
    rep 005 : db $01,$00,$0D,$E0,$1C
    rep 005 : db $01,$00,$0D,$00,$21
    rep 005 : db $01,$00,$0D,$20,$25
    rep 005 : db $01,$00,$0D,$40,$29
    rep 004 : db $01,$00,$0D,$60,$2D
    rep 005 : db $01,$00,$0D,$80,$31
    rep 005 : db $01,$00,$0D,$A0,$35
    rep 004 : db $01,$00,$0D,$C0,$39
    rep 005 : db $01,$00,$0D,$E0,$3D
    rep 004 : db $01,$00,$0D,$00,$42
    rep 004 : db $01,$00,$0D,$20,$46
    rep 005 : db $01,$00,$0D,$40,$4A
    rep 005 : db $01,$00,$0D,$60,$4E
    rep 004 : db $01,$00,$0D,$80,$52
    rep 005 : db $01,$00,$0D,$A0,$56
    rep 005 : db $01,$00,$0D,$C0,$5A
    rep 005 : db $01,$00,$0D,$E0,$5E
    rep 005 : db $01,$00,$0D,$00,$63
    rep 006 : db $01,$00,$0D,$20,$67
    rep 006 : db $01,$00,$0D,$40,$6B
    rep 007 : db $01,$00,$0D,$60,$6F
    rep 008 : db $01,$00,$0D,$80,$73
    rep 009 : db $01,$00,$0D,$A0,$77
    rep 013 : db $01,$00,$0D,$C0,$7B
    rep 019 : db $01,$00,$0D,$E0,$7F
              db $00
.orange
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 008 : db $01,$00,$0D,$01,$00
    rep 005 : db $01,$00,$0D,$21,$00
    rep 005 : db $01,$00,$0D,$22,$00
    rep 005 : db $01,$00,$0D,$22,$04
    rep 004 : db $01,$00,$0D,$23,$04
    rep 003 : db $01,$00,$0D,$43,$04
    rep 007 : db $01,$00,$0D,$44,$04
    rep 003 : db $01,$00,$0D,$45,$04
    rep 003 : db $01,$00,$0D,$65,$04
    rep 003 : db $01,$00,$0D,$66,$04
    rep 003 : db $01,$00,$0D,$66,$08
    rep 003 : db $01,$00,$0D,$67,$08
    rep 002 : db $01,$00,$0D,$87,$08
    rep 005 : db $01,$00,$0D,$88,$08
    rep 003 : db $01,$00,$0D,$89,$08
    rep 002 : db $01,$00,$0D,$A9,$08
    rep 003 : db $01,$00,$0D,$AA,$08
    rep 002 : db $01,$00,$0D,$AA,$0C
    rep 002 : db $01,$00,$0D,$AB,$0C
    rep 003 : db $01,$00,$0D,$CB,$0C
    rep 004 : db $01,$00,$0D,$CC,$0C
    rep 003 : db $01,$00,$0D,$CD,$0C
    rep 002 : db $01,$00,$0D,$ED,$0C
    rep 002 : db $01,$00,$0D,$EE,$0C
    rep 002 : db $01,$00,$0D,$EE,$10
    rep 003 : db $01,$00,$0D,$EF,$10
    rep 002 : db $01,$00,$0D,$0F,$11
    rep 005 : db $01,$00,$0D,$10,$11
    rep 002 : db $01,$00,$0D,$11,$11
    rep 002 : db $01,$00,$0D,$31,$11
    rep 002 : db $01,$00,$0D,$32,$11
    rep 003 : db $01,$00,$0D,$32,$15
    rep 002 : db $01,$00,$0D,$33,$15
    rep 002 : db $01,$00,$0D,$53,$15
    rep 005 : db $01,$00,$0D,$54,$15
    rep 002 : db $01,$00,$0D,$55,$15
    rep 003 : db $01,$00,$0D,$75,$15
    rep 002 : db $01,$00,$0D,$76,$15
    rep 003 : db $01,$00,$0D,$76,$19
    rep 002 : db $01,$00,$0D,$77,$19
    rep 003 : db $01,$00,$0D,$97,$19
    rep 005 : db $01,$00,$0D,$98,$19
    rep 003 : db $01,$00,$0D,$99,$19
    rep 003 : db $01,$00,$0D,$B9,$19
    rep 003 : db $01,$00,$0D,$BA,$19
    rep 003 : db $01,$00,$0D,$BA,$1D
    rep 003 : db $01,$00,$0D,$BB,$1D
    rep 004 : db $01,$00,$0D,$DB,$1D
    rep 007 : db $01,$00,$0D,$DC,$1D
    rep 005 : db $01,$00,$0D,$DD,$1D
    rep 005 : db $01,$00,$0D,$FD,$1D
    rep 005 : db $01,$00,$0D,$FE,$1D
    rep 008 : db $01,$00,$0D,$FE,$21
    rep 018 : db $01,$00,$0D,$FF,$21
              db $00

.purple
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 008 : db $01,$00,$0D,$00,$04
    rep 005 : db $01,$00,$0D,$01,$04
    rep 005 : db $01,$00,$0D,$01,$08
    rep 005 : db $01,$00,$0D,$21,$08
    rep 004 : db $01,$00,$0D,$21,$0C
    rep 003 : db $01,$00,$0D,$22,$0C
    rep 007 : db $01,$00,$0D,$22,$10
    rep 003 : db $01,$00,$0D,$22,$14
    rep 003 : db $01,$00,$0D,$23,$14
    rep 003 : db $01,$00,$0D,$23,$18
    rep 003 : db $01,$00,$0D,$43,$18
    rep 003 : db $01,$00,$0D,$43,$1C
    rep 002 : db $01,$00,$0D,$44,$1C
    rep 005 : db $01,$00,$0D,$44,$20
    rep 003 : db $01,$00,$0D,$44,$24
    rep 002 : db $01,$00,$0D,$45,$24
    rep 003 : db $01,$00,$0D,$45,$28
    rep 002 : db $01,$00,$0D,$65,$28
    rep 002 : db $01,$00,$0D,$65,$2C
    rep 003 : db $01,$00,$0D,$66,$2C
    rep 004 : db $01,$00,$0D,$66,$30
    rep 003 : db $01,$00,$0D,$66,$34
    rep 002 : db $01,$00,$0D,$67,$34
    rep 002 : db $01,$00,$0D,$67,$38
    rep 002 : db $01,$00,$0D,$87,$38
    rep 003 : db $01,$00,$0D,$87,$3C
    rep 002 : db $01,$00,$0D,$88,$3C
    rep 005 : db $01,$00,$0D,$88,$40
    rep 002 : db $01,$00,$0D,$88,$44
    rep 002 : db $01,$00,$0D,$89,$44
    rep 002 : db $01,$00,$0D,$89,$48
    rep 003 : db $01,$00,$0D,$A9,$48
    rep 002 : db $01,$00,$0D,$A9,$4C
    rep 002 : db $01,$00,$0D,$AA,$4C
    rep 005 : db $01,$00,$0D,$AA,$50
    rep 002 : db $01,$00,$0D,$AA,$54
    rep 003 : db $01,$00,$0D,$AB,$54
    rep 002 : db $01,$00,$0D,$AB,$58
    rep 003 : db $01,$00,$0D,$CB,$58
    rep 002 : db $01,$00,$0D,$CB,$5C
    rep 003 : db $01,$00,$0D,$CC,$5C
    rep 005 : db $01,$00,$0D,$CC,$60
    rep 003 : db $01,$00,$0D,$CC,$64
    rep 003 : db $01,$00,$0D,$CD,$64
    rep 003 : db $01,$00,$0D,$CD,$68
    rep 003 : db $01,$00,$0D,$ED,$68
    rep 003 : db $01,$00,$0D,$ED,$6C
    rep 004 : db $01,$00,$0D,$EE,$6C
    rep 007 : db $01,$00,$0D,$EE,$70
    rep 005 : db $01,$00,$0D,$EE,$74
    rep 005 : db $01,$00,$0D,$EF,$74
    rep 005 : db $01,$00,$0D,$EF,$78
    rep 008 : db $01,$00,$0D,$0F,$79
    rep 018 : db $01,$00,$0D,$0F,$7D
              db $00
.white
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 013 : db $01,$00,$0D,$21,$04
    rep 010 : db $01,$00,$0D,$42,$08
    rep 007 : db $01,$00,$0D,$63,$0C
    rep 007 : db $01,$00,$0D,$84,$10
    rep 006 : db $01,$00,$0D,$A5,$14
    rep 006 : db $01,$00,$0D,$C6,$18
    rep 005 : db $01,$00,$0D,$E7,$1C
    rep 005 : db $01,$00,$0D,$08,$21
    rep 005 : db $01,$00,$0D,$29,$25
    rep 005 : db $01,$00,$0D,$4A,$29
    rep 005 : db $01,$00,$0D,$6B,$2D
    rep 004 : db $01,$00,$0D,$8C,$31
    rep 005 : db $01,$00,$0D,$AD,$35
    rep 004 : db $01,$00,$0D,$CE,$39
    rep 005 : db $01,$00,$0D,$EF,$3D
    rep 005 : db $01,$00,$0D,$10,$42
    rep 004 : db $01,$00,$0D,$31,$46
    rep 005 : db $01,$00,$0D,$52,$4A
    rep 004 : db $01,$00,$0D,$73,$4E
    rep 005 : db $01,$00,$0D,$94,$52
    rep 005 : db $01,$00,$0D,$B5,$56
    rep 005 : db $01,$00,$0D,$D6,$5A
    rep 005 : db $01,$00,$0D,$F7,$5E
    rep 005 : db $01,$00,$0D,$18,$63
    rep 006 : db $01,$00,$0D,$39,$67
    rep 006 : db $01,$00,$0D,$5A,$6B
    rep 007 : db $01,$00,$0D,$7B,$6F
    rep 007 : db $01,$00,$0D,$9C,$73
    rep 010 : db $01,$00,$0D,$BD,$77
    rep 013 : db $01,$00,$0D,$DE,$7B
    rep 018 : db $01,$00,$0D,$FF,$7F
              db $00

.red_2
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 013 : db $01,$00,$0D,$01,$00
    rep 005 : db $01,$00,$0D,$02,$00
    rep 005 : db $01,$00,$0D,$22,$04
    rep 007 : db $01,$00,$0D,$23,$04
    rep 007 : db $01,$00,$0D,$24,$04
    rep 006 : db $01,$00,$0D,$25,$04
    rep 003 : db $01,$00,$0D,$26,$04
    rep 003 : db $01,$00,$0D,$46,$08
    rep 005 : db $01,$00,$0D,$47,$08
    rep 005 : db $01,$00,$0D,$48,$08
    rep 005 : db $01,$00,$0D,$49,$08
    rep 003 : db $01,$00,$0D,$4A,$08
    rep 002 : db $01,$00,$0D,$6A,$0C
    rep 005 : db $01,$00,$0D,$6B,$0C
    rep 004 : db $01,$00,$0D,$6C,$0C
    rep 005 : db $01,$00,$0D,$6D,$0C
    rep 002 : db $01,$00,$0D,$6E,$0C
    rep 002 : db $01,$00,$0D,$8E,$10
    rep 005 : db $01,$00,$0D,$8F,$10
    rep 005 : db $01,$00,$0D,$90,$10
    rep 004 : db $01,$00,$0D,$91,$10
    rep 002 : db $01,$00,$0D,$92,$10
    rep 003 : db $01,$00,$0D,$B2,$14
    rep 004 : db $01,$00,$0D,$B3,$14
    rep 005 : db $01,$00,$0D,$B4,$14
    rep 005 : db $01,$00,$0D,$B5,$14
    rep 002 : db $01,$00,$0D,$B6,$14
    rep 003 : db $01,$00,$0D,$D6,$18
    rep 005 : db $01,$00,$0D,$D7,$18
    rep 005 : db $01,$00,$0D,$D8,$18
    rep 006 : db $01,$00,$0D,$D9,$18
    rep 003 : db $01,$00,$0D,$DA,$18
    rep 003 : db $01,$00,$0D,$FA,$1C
    rep 007 : db $01,$00,$0D,$FB,$1C
    rep 007 : db $01,$00,$0D,$FC,$1C
    rep 010 : db $01,$00,$0D,$FD,$1C
    rep 005 : db $01,$00,$0D,$FE,$1C
    rep 008 : db $01,$00,$0D,$1E,$21
    rep 018 : db $01,$00,$0D,$1F,$21
              db $00

.blue_2
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 008 : db $01,$00,$0D,$00,$04
    rep 005 : db $01,$00,$0D,$20,$04
    rep 010 : db $01,$00,$0D,$20,$08
    rep 004 : db $01,$00,$0D,$20,$0C
    rep 003 : db $01,$00,$0D,$40,$0C
    rep 007 : db $01,$00,$0D,$40,$10
    rep 003 : db $01,$00,$0D,$40,$14
    rep 003 : db $01,$00,$0D,$60,$14
    rep 006 : db $01,$00,$0D,$60,$18
    rep 003 : db $01,$00,$0D,$60,$1C
    rep 002 : db $01,$00,$0D,$80,$1C
    rep 005 : db $01,$00,$0D,$80,$20
    rep 003 : db $01,$00,$0D,$80,$24
    rep 002 : db $01,$00,$0D,$A0,$24
    rep 005 : db $01,$00,$0D,$A0,$28
    rep 002 : db $01,$00,$0D,$A0,$2C
    rep 003 : db $01,$00,$0D,$C0,$2C
    rep 004 : db $01,$00,$0D,$C0,$30
    rep 003 : db $01,$00,$0D,$C0,$34
    rep 002 : db $01,$00,$0D,$E0,$34
    rep 004 : db $01,$00,$0D,$E0,$38
    rep 003 : db $01,$00,$0D,$E0,$3C
    rep 002 : db $01,$00,$0D,$00,$3D
    rep 005 : db $01,$00,$0D,$00,$41
    rep 002 : db $01,$00,$0D,$00,$45
    rep 002 : db $01,$00,$0D,$20,$45
    rep 005 : db $01,$00,$0D,$20,$49
    rep 002 : db $01,$00,$0D,$20,$4D
    rep 002 : db $01,$00,$0D,$40,$4D
    rep 005 : db $01,$00,$0D,$40,$51
    rep 002 : db $01,$00,$0D,$40,$55
    rep 003 : db $01,$00,$0D,$60,$55
    rep 005 : db $01,$00,$0D,$60,$59
    rep 002 : db $01,$00,$0D,$60,$5D
    rep 003 : db $01,$00,$0D,$80,$5D
    rep 005 : db $01,$00,$0D,$80,$61
    rep 003 : db $01,$00,$0D,$80,$65
    rep 003 : db $01,$00,$0D,$A0,$65
    rep 006 : db $01,$00,$0D,$A0,$69
    rep 003 : db $01,$00,$0D,$A0,$6D
    rep 004 : db $01,$00,$0D,$C0,$6D
    rep 007 : db $01,$00,$0D,$C0,$71
    rep 005 : db $01,$00,$0D,$C0,$75
    rep 005 : db $01,$00,$0D,$E0,$75
    rep 013 : db $01,$00,$0D,$E0,$79
    rep 017 : db $01,$00,$0D,$E0,$7D
              db $01,$00,$0D,$00,$7E
              db $00

.green_2
    rep 128 : db $01,$00,$0D,$00,$00
    rep 118 : db $01,$00,$0D,$00,$00
    rep 008 : db $01,$00,$0D,$20,$00
    rep 005 : db $01,$00,$0D,$21,$00
    rep 005 : db $01,$00,$0D,$41,$00
    rep 005 : db $01,$00,$0D,$41,$04
    rep 004 : db $01,$00,$0D,$61,$04
    rep 003 : db $01,$00,$0D,$62,$04
    rep 007 : db $01,$00,$0D,$82,$04
    rep 003 : db $01,$00,$0D,$A2,$04
    rep 003 : db $01,$00,$0D,$A3,$04
    rep 003 : db $01,$00,$0D,$C3,$04
    rep 003 : db $01,$00,$0D,$C3,$08
    rep 003 : db $01,$00,$0D,$E3,$08
    rep 002 : db $01,$00,$0D,$E4,$08
    rep 005 : db $01,$00,$0D,$04,$09
    rep 003 : db $01,$00,$0D,$24,$09
    rep 002 : db $01,$00,$0D,$25,$09
    rep 003 : db $01,$00,$0D,$45,$09
    rep 002 : db $01,$00,$0D,$45,$0D
    rep 002 : db $01,$00,$0D,$65,$0D
    rep 003 : db $01,$00,$0D,$66,$0D
    rep 004 : db $01,$00,$0D,$86,$0D
    rep 003 : db $01,$00,$0D,$A6,$0D
    rep 002 : db $01,$00,$0D,$A7,$0D
    rep 002 : db $01,$00,$0D,$C7,$0D
    rep 002 : db $01,$00,$0D,$C7,$11
    rep 003 : db $01,$00,$0D,$E7,$11
    rep 002 : db $01,$00,$0D,$E8,$11
    rep 005 : db $01,$00,$0D,$08,$12
    rep 002 : db $01,$00,$0D,$28,$12
    rep 002 : db $01,$00,$0D,$29,$12
    rep 002 : db $01,$00,$0D,$49,$12
    rep 003 : db $01,$00,$0D,$49,$16
    rep 002 : db $01,$00,$0D,$69,$16
    rep 002 : db $01,$00,$0D,$6A,$16
    rep 005 : db $01,$00,$0D,$8A,$16
    rep 002 : db $01,$00,$0D,$AA,$16
    rep 003 : db $01,$00,$0D,$AB,$16
    rep 002 : db $01,$00,$0D,$CB,$16
    rep 003 : db $01,$00,$0D,$CB,$1A
    rep 002 : db $01,$00,$0D,$EB,$1A
    rep 003 : db $01,$00,$0D,$EC,$1A
    rep 005 : db $01,$00,$0D,$0C,$1B
    rep 003 : db $01,$00,$0D,$2C,$1B
    rep 003 : db $01,$00,$0D,$2D,$1B
    rep 003 : db $01,$00,$0D,$4D,$1B
    rep 003 : db $01,$00,$0D,$4D,$1F
    rep 003 : db $01,$00,$0D,$6D,$1F
    rep 004 : db $01,$00,$0D,$6E,$1F
    rep 007 : db $01,$00,$0D,$8E,$1F
    rep 005 : db $01,$00,$0D,$AE,$1F
    rep 005 : db $01,$00,$0D,$AF,$1F
    rep 005 : db $01,$00,$0D,$CF,$1F
    rep 008 : db $01,$00,$0D,$CF,$23
    rep 018 : db $01,$00,$0D,$EF,$23
              db $00

;#########################################################################
;# Windowing HDMA tables

magic_window:
    dw .ltr
    dw .rtl

.ltr
   db $25 : db $FF, $00      ; 
   db $05 : db $00, $FF      ; 
   db $01 : db $00, $FC      ; 
   db $01 : db $00, $F3      ; 
   db $01 : db $00, $EA      ; 
   db $01 : db $00, $E1      ; 
   db $01 : db $00, $D8      ; 
   db $01 : db $00, $CE      ; 
   db $01 : db $00, $C5      ; 
   db $01 : db $00, $BC      ; 
   db $01 : db $00, $B3      ; 
   db $01 : db $00, $AA      ; 
   db $01 : db $00, $A1      ; 
   db $01 : db $00, $98      ; 
   db $01 : db $00, $8F      ; 
   db $01 : db $00, $86      ; 
   db $01 : db $00, $7C      ; 
   db $01 : db $00, $73      ; 
   db $01 : db $00, $6A      ; 
   db $01 : db $00, $61      ; 
   db $01 : db $00, $58      ; 
   db $01 : db $00, $4F      ; 
   db $01 : db $00, $46      ; 
   db $01 : db $00, $3D      ; 
   db $01 : db $00, $34      ; 
   db $01 : db $00, $2A      ; 
   db $01 : db $00, $21      ; 
   db $01 : db $00, $10      ; 
   db $01 : db $00, $0F      ; 
   db $01 : db $00, $06      ; 
   db $80 : db $FF, $00      ; dw $0D00
   db $1A : db $FF, $00      ; 
   db $00                    ; 

.rtl
   db $25 : db $FF, $00      ; 
   db $05 : db $00, $FF      ; 
   db $01 : db $04, $FF      ; 
   db $01 : db $0D, $FF      ; 
   db $01 : db $16, $FF      ; 
   db $01 : db $1F, $FF      ; 
   db $01 : db $28, $FF      ; 
   db $01 : db $32, $FF      ; 
   db $01 : db $3B, $FF      ; 
   db $01 : db $44, $FF      ; 
   db $01 : db $4D, $FF      ; 
   db $01 : db $56, $FF      ; 
   db $01 : db $5F, $FF      ; 
   db $01 : db $68, $FF      ; 
   db $01 : db $71, $FF      ; 
   db $01 : db $7A, $FF      ; 
   db $01 : db $84, $FF      ; 
   db $01 : db $8D, $FF      ; 
   db $01 : db $96, $FF      ; 
   db $01 : db $9F, $FF      ; 
   db $01 : db $A8, $FF      ; 
   db $01 : db $B1, $FF      ; 
   db $01 : db $BA, $FF      ; 
   db $01 : db $C3, $FF      ; 
   db $01 : db $CC, $FF      ; 
   db $01 : db $D6, $FF      ; 
   db $01 : db $DF, $FF      ; 
   db $01 : db $E8, $FF      ; 
   db $01 : db $F1, $FF      ; 
   db $01 : db $FA, $FF      ; 
   db $80 : db $FF, $00      ; dw $0D00
   db $1A : db $FF, $00      ; 
   db $00                    ; 

;#########################################################################
;# Layer 3 X offsets

magic_x_offset:
    dw $0100
    dw $0000


;#########################################################################
;# Precalculated Layer 3 Y position offsets

math round off
;187
magic_scanlines:
    !o #= 45
    !i #= 0+!o
    while !i < 187+!o
        dw ((!i*($10000-sqrt($10000-!i**2)))>>9)
        !i #= !i+1
    endif

;#########################################################################
;# Color math HDMA tables

if !__disable_status_bar_compat == 0
    magic_color_math:
        db $25 : db %00011111,%00000000,%00011111,%00000000
        db $80 : db %00011011,%00000100,%00011011,%00000100
        db $00
endif

;#########################################################################
;# Tilemap

%prot_file("library/kamek_layer_3_tilemap.bin", kamek_tilemap)