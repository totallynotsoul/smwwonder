;====================================================
; Even More Nintendo Presents Logo Expansion
; a.k.a. 128x128 Nintendo Presents Logo patch
; by KevinM
;
; To use it, make the image you want in two ExGFX files, then insert
; them with LM (with numbers in 00-FF) and apply the patch.
;
; Optionally, you can load a custom palette: export the palette file
; from LM or other editors, making sure you set the file to "Mario World
; Custom Palette File (*.mw3)" in the file type dropdown. If the file
; is 514 bytes, then you did it correctly. Pay attention that the back area
; color will be used as well for the background, so you usually want it black.
; After exporting the palette, put it in the same folder as this file,
; then change the defines below (!custom_palette to 1, !palette_name to your file name).
;
; If you want to set a different palette row for each tile, set !props_per_tile
; to 1 and edit the .tile_palette below. Otherwise, the palette defined in !props
; will be used for every tile.
;
; The sample files provided contain the DKC expand image.
;====================================================

; How long the Nintendo Presents is shown.
!intro_time = $40

; What GFX files to use (must be between $00 and $FF!).
!gfx1 = $FE
!gfx2 = $FF

; Set to 1 to load a custom palette for the logo.
!custom_palette = 1

; The name of the palette file (only used if !custom_palette = 1).
!palette_name = "logo.mw3"

; Position and YXPPCCCT properties of the logo on the screen.
; Make sure !props ends with 1 (uses second page aka SP3-SP4).
!x_pos = $40
!y_pos = $30
!props = $31

; By default, all tiles will use the same palette row (set in !props).
; If you want more control, set this to 1 and you can set a different palette
; for each tile. To edit it, look at the .tile_palette table below.
!props_per_tile = 0

if read1($00FFD5) == $23
    sa1rom
    !sa1  = 1
    !dp   = $3000
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1  = 0
    !dp   = $0000
    !addr = $0000
    !bank = $800000
endif

function pal(x) = (!props&$F1)|((x-8)<<1)

org $00939A
    ; Setup the GFX loop.
    lda.b #!x_pos : sta $00
    lda.b #!y_pos : sta $01
    stz $02
    ldy #$00
    ldx #$00

    ; Draw all the tiles.
    autoclean jsl draw_loop

    ; Now set the tiles size.
    rep #$20
    lda #$AAAA
    ldy #$0E
-   sta $0400|!addr,y
    dey #2 : bpl -
    sep #$20
    bra +

warnpc $0093C0

org $0093C0
    +

org $00A9C7
    autoclean jml load_gfx

if !custom_palette
    org $0093D4
        autoclean jml load_palette
else
if read1($0093D4) == $5C
    autoclean read3($0093D4+1)

    org $0093D4
        stz $192E|!addr
        jsr $ABED
endif
endif

org $0093C6
    db !intro_time

freecode

draw_loop:
; Set the DBR so loading from the palette table is faster.
if !props_per_tile
    phb : phk : plb
endif

-
    ; Store the current tile to OAM.
    lda $00 : sta $0200|!addr,y
    lda $01 : sta $0201|!addr,y
    lda $02 : sta $0202|!addr,y

if !props_per_tile
    lda.w .tile_palette,x
    inx
else
    lda.b #!props
endif
    sta $0203|!addr,y

    ; Go to the next slot.
    iny #4

    ; Set the next tile's number.
    lda $02 : inc #2 : sta $02
    bit #$10 : beq +
    clc : adc #$10 : sta $02
+
    ; Set the next tile's position.
    lda $00 : clc : adc #$10 : sta $00
    lda $02 : and #$0F : bne +
    lda.b #!x_pos : sta $00
    lda $01 : clc : adc #$10 : sta $01
+
    ; Loop until we've drawn 64 tiles.
    lda $02 : bne -

if !props_per_tile
    plb
endif
    rtl

if !props_per_tile

; Here you can set the palette for each tile (only if !props_per_tile = 1).
; Just use pal(X), with X going from $8 to $F (uses sprite palettes).
.tile_palette:
    db pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8) ; Tiles 00-0E
    db pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8) ; Tiles 20-2E
    db pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8) ; Tiles 40-4E
    db pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8) ; Tiles 60-6E
    db pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8) ; Tiles $80-$8E
    db pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8) ; Tiles A0-AE
    db pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8) ; Tiles C0-CE
    db pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8),pal($8) ; Tiles E0-EE

endif

load_gfx:
    ; If not the logo gamemode, skip
    ; (this also runs during the credits).
    lda $0100|!addr : bne .orig

.ok:
    ; Upload the first file.
    lda #$70 : sta $2117
    ldy.b #!gfx1
    phk
    pea.w (+)-1
    pea.w $0084CF-1
    jml $00AA6B|!bank
+
    ; Upload the second file
    ; (by jumping back to the upload GFX routine).
    stz $2116
    lda #$78 : sta $2117
    ldy.b #!gfx2
    jml $00A9CE|!bank

.orig:
    ; Restore original code and jump back.
    lda #$60 : sta $2117
    jml $00A9CC|!bank

if !custom_palette

; We upload the palette directly to VRAM (except default color).
load_palette:
    ; If not the logo gamemode, skip
    ; (this also runs during the Mario Start/Game Over screens).
    lda $0100|!addr : beq .ok
.orig:
    ; Restore original code and return.
    stz $192E|!addr
    phk
    pea.w (+)-1
    pea.w $0084CF-1
    jml $00ABED|!bank
+   jml $0093DA|!bank

.ok:
    ; Upload to the start of CGRAM.
    stz $2121
    
    rep #$20

    ; Upload to $2122, increment mode, one register write once.
    lda #$2200 : sta $4320

    ; Set source address.
    lda.w #.palette : sta $4322
    ldx.b #.palette>>16 : stx $4324

    ; Set size (512 bytes).
    lda #$0200 : sta $4325

    ; Start DMA.
    ldx #$04 : stx $420B

    ; Now set the default color.
    lda.l .palette+$0200 : sta $0701|!addr
    sep #$20
    jml $0093E3|!bank

.palette:
    incbin !palette_name

endif
