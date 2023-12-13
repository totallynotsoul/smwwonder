; Cluster sprite spawner for seagull cluster sprite.
; Cluster sprite number from list.txt is set in the CFG file as extra property byte 1.
; Adapted from Ladida's clusterspawn.

; Amount of sprites to spawn, -1. It should be 04 or lower.
!Count = $04

; Initial X and Y position table of sprites, relative to screen border.
; Format: $xy
InitXY:
    db $13,$42,$84,$A1,$E4

print "INIT ",pc
    PHB : PHK : PLB

    LDY #!Count
-   LDA !extra_prop_1,x    ; \ set cluster sprite number
    CLC                    ; |
    ADC #!ClusterOffset    ; | add offset due to original cluster sprites.
    STA !cluster_num,y     ; /

    LDA InitXY,y           ; \ Initial X and Y position of each sprite.
    PHA                    ; | Is relative to screen border.
    AND #$F0               ; |
    STA !cluster_x_low,y   ; |
    PLA                    ; |
    ASL #4                 ; |
    STA !cluster_y_low,y   ; /

    DEY                    ; \ Loop until all slots are done.
    BPL -                  ; /

    LDA #$01               ; \ Run cluster sprite routine.
    STA $18B8|!Base2       ; /

    PLB                    ; restore bank
    RTL                    ; Return.

print "MAIN ",pc
    STZ !14C8,x      ; \ self destruct
    RTL              ; /
