;##################################################################################################
;# Powerup: Lankario (AKA Lankio AKA Weird Mario)
;# Author: Nintendo (Original), SubconsciousEye (Port)
;# Description: The Weird Mushroom Powerup from Super Mario Maker.
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
    db $03                  ; [47]      Dummy scuttle frame, holding an item; Used to initiate animation
    db $01,$00              ; [48-49]   Part of scuttle frames, rising jump (0B)
    db $02,$00              ; [4A-4B]   Part of scuttle frames, falling (24)
    db $04,$00              ; [4C-4D]   Part of Swimming Idle Animation
    db $05,$00              ; [4E-4F]   Part of Swimming Idle Animation, holding an item
    db $00,$00              ; [50-51]   Yoshi Rider Poses (Separate from Climbing)

.animations                 ; extended_anim_num
    dw ..jumping            ; [01]
    dw ..falling            ; [02]
    dw ..carrying           ; [03]
    dw ..swimming           ; [04]
    dw ..swimming_carry     ; [05]

;############################
;# Smooth animation for jumping

..jumping                   ; extended_anim_index
    db $48,$02
    db $49,$02
    db $48,$02
    db $0B,$02
    db $00,$FE

;############################
;# Smooth animation for falling

..falling
    db $4A,$02
    db $4B,$02
    db $4A,$02
    db $24,$02
    db $00,$FE
    
;############################
;# Smooth animation for carrying (air)

..carrying
    db $08,$02
    db $07,$02
    db $08,$02
    db $09,$02
    db $00,$FE

;############################
;# Smooth animation for swimming idle

..swimming
    db $4C,$02
    db $4D,$02
    db $00,$FE

;############################
;# Smooth animation for swimming idle (carry)

..swimming_carry
    db $4E,$02
    db $4F,$02
    db $00,$FE
