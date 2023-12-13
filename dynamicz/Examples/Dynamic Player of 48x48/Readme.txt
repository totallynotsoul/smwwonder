Put this:

incsrc header.asm

;Point to the current frame
!FramePointer = $0F5E

;Point to the current frame on the animation
!AnFramePointer = $0F5F

;Point to the current animation
!AnPointer = $1510,x

;Time for the next frame change
!AnimationTimer = $0F60

!GlobalFlipper = $76

!LocalFlipper = $0F61

After LOROM on the uber asm patch

Also put header.asm on the same folder of uber asm