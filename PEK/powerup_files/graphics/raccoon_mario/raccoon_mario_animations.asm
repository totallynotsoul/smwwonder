;##################################################################################################
;# GFX set: Raccoon Mario
;# Author: Nintendo (Original), SubconsciousEye (Re-Code)
;# Description: Default set for Raccoon Mario.
;#
;# ;# Pointers to smooth animation data
;# Format: XX YY
;#  - XX: Pose number
;#  - YY: Amount of frames the pose will be shown (minus 1)
;#        $FF = Show this frame forever (end of animation)
;#        $FE = Loop the animation
;#        $FD = Jump to animation index $XX

.index                      ; player_pose_num
    db $00                  ; [00]      Idle
    db $00,$00              ; [01-02]   Walking
    db $00                  ; [03]      Looking Up
    db $00,$00,$00          ; [04-06]   Running
    db $00                  ; [07]      Idle, holding an item
    db $00,$00              ; [08-09]   Walking, holding an item; second byte is also used for Jumping/Falling
    db $00                  ; [0A]      Looking up, holding an item
    db $00                  ; [0B]      Jumping
    db $00                  ; [0C]      Jumping, max speed
    db $00                  ; [0D]      Skidding
    db $00                  ; [0E]      Kicking item
    db $00                  ; [0F]      Looking to camera; spinjump pose, going into a pipe pose
    db $00                  ; [10]      Diagonal
    db $00,$00,$00          ; [11-13]   Running up wall
    db $00                  ; [14]      Victory pose, on Yoshi
    db $00                  ; [15]      Climbing
    db $00,$00              ; [16-17]   Swimming Idle; second byte is used for holding an item
    db $00,$00              ; [18-19]   Swimming #1; second byte is used for holding an item
    db $00,$00              ; [1A-1B]   Swimming #2; second byte is used for holding an item
    db $00                  ; [1C]      Sliding
    db $00                  ; [1D]      Crouching, holding an item
    db $00                  ; [1E]      Punching a net
    db $00                  ; [1F]      Swinging on net, showing back
    db $00                  ; [20]      Mounted on Yoshi; Swinging on net, side
    db $00                  ; [21]      Turning around on Yoshi, facing camera; Swinging on net, facing camera; Going into a pipe on Yoshi
    db $00                  ; [22]      Climbing, facing camera
    db $00                  ; [23]      Punching a net, facing camera
    db $00                  ; [24]      Falling
    db $00                  ; [25]      Showing back; spinjump pose
    db $00                  ; [26]      Victory pose
    db $00,$00              ; [27-28]   Commanding Yoshi
    db $00                  ; [29]      Going into a pipe on Yoshi (Weird Crouch)
    db $00,$00              ; [2A-2B]   Flying with cape
    db $00                  ; [2C]      Slide with cape while flying
    db $00,$00,$00          ; [2D-2F]   Dive with cape
    db $00,$00              ; [30-31]   Burned, cutscene poses
    db $00                  ; [32]      Looking in front, cutscene pose
    db $00,$00              ; [33-34]   Looking at the distance, cutscene pose
    db $00,$00,$00          ; [35-37]   Using a hammer, cutscene pose
    db $00,$00              ; [38-39]   Using a mop, cutscene pose
    db $00,$00              ; [3A-3B]   Using a hammer, cutscene pose, most likely unused
    db $00                  ; [3C]      Crouching
    db $00                  ; [3D]      Shrinking/Growing
    db $00                  ; [3E]      Dead
    db $00                  ; [3F]      Shooting fireball
    db $00,$00              ; [40-41]   Unused
    db $00                  ; [42]      Using P-Balloon (Small Mario, Unused)
    db $00                  ; [43]      Using P-Balloon (Non-Small Mario, Used)
    db $00,$00,$00          ; [44-46]   Copy of the spinjump poses (Non-Small Forms); Last byte is also a part of the Shrinking/Growing animation
    db $01                  ; [47]      Backwards Somersault, Used to transition into Cape Flight
    db $02,$03              ; [48-49]   Tail Thwack, Ground; Left, Right
    db $04,$05              ; [4A-4B]   Tail Thwack, Air; Left, Right
    db $06,$07              ; [4C-4D]   Tail Thwack, Swim; Left, Right
    db $02,$03              ; [4E-4F]   Tail Thwack, Global; Left, Right
    db $00,$00,$00,$00      ; [50-53]   Backwards Somersault, Actual Frames


.animations                 ; extended_anim_num
    dw ..somersault         ; [01]
    dw ..thwack_grnd_l      ; [02]
    dw ..thwack_grnd_r      ; [03]
    dw ..thwack_air_l       ; [04]
    dw ..thwack_air_r       ; [05]
    dw ..thwack_swim_l      ; [06]
    dw ..thwack_swim_r      ; [07]

;############################
;# Smooth animations for Backwards Somersault

..somersault
    db $29,$02
    db $3A,$02
    db $3D,$02
    db $3E,$02
    db $2C,$02
    db $2C,$FF

;############################
;# Smooth animations for Tail Thwack, Left

..thwack_grnd_l             ; extended_anim_index
    db $00,$02
    db $25,$04
    db $00,$04
    db $0F,$04
    db $00,$04
    db $00,$FF

..thwack_air_l
    db $24,$02
    db $25,$04
    db $24,$04
    db $0F,$04
    db $24,$04
    db $24,$FF

..thwack_swim_l
    db $00,$02
    db $25,$04
    db $00,$04
    db $0F,$04
    db $00,$04
    db $16,$FF

;############################
;# Smooth animations for Tail Thwack, Right

..thwack_grnd_r
    db $00,$02
    db $0F,$04
    db $00,$04
    db $25,$04
    db $00,$04
    db $00,$FF

..thwack_air_r
    db $24,$02
    db $0F,$04
    db $24,$04
    db $25,$04
    db $24,$04
    db $24,$FF

..thwack_swim_r
    db $00,$02
    db $0F,$04
    db $00,$04
    db $25,$04
    db $00,$04
    db $16,$FF
