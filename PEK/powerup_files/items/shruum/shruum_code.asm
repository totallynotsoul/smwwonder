;##################################################################################################
;# Item: Weird Mushroom
;# Author: Nintendo
;# Description: Default powerup item for Weird Mario (Lankario).

;################################################
;# Init code for this item

.init
    jsr ..goal
    inc !C2,x
;	jsl find_and_queue_gfx
    jml item_return


;################################################
;# Code for initializing the sprite when carrying an item through the goal tape

..goal
    lda #!shruum_acts_like
    sta !9E,x
    jsl init_sprite_tables
    lda.b #!shruum_sprite_prop
    sta !15F6,x
    rts


;################################################
;# Main code for this item

.main
;	phy
;	phk
;	pea.w ..checkgfx-1
;	pea.w $80c9				; bank1 rtl
    lda #$01
    pha 
    plb 
    jml $01C371|!bank       ; while this may look dumb and slow, it allows easy editing if needed
;..checkgfx
;	lda #!shruum_dss_page
;	xba
;	lda #!shruum_dss_id
;	jsl find_and_queue_gfx
;	bcs ..found
;	lda #$f0 : sta $0301|!addr,y
;	ply
;	jml $018c51				; bank 1 rts
;..found
;	lda !dss_tile_buffer
;	sta $0302|!addr,y
;	lda $0303|!addr,y
;	and #$f0
;	ora #!shruum_sprite_prop
;	sta $0303|!addr,y
;	ply
;	jml $018c51				; bank 1 rts