BunnyState:
  LD A, (CurrentPowerup)
  CP $02
  JR NZ, BunnyStateReturn
  LD A, ($A287)
  AND A
  JR NZ, BunnyStateReturn
  LD A, (VerticalSpeedIndex)
  CP $48
  JR NC, BunnyStateReturn
  LDH A, (ControllerPress)
  BIT 0, A
  JR NZ, EnableHover
  LD A, (BunnyAir)
  AND A
  JR Z, BunnyStateReturn
  LD A, (MarioOnGround)
  AND A
  JR NZ, BunnyStateReturn
  LDH A, (ControllerHold)
  BIT 0, A
  JR Z, BunnyStateReturn
  LD A, (BunnyStateTimer)
  INC A
  LD (BunnyStateTimer), A
  CP $0C
  JR C, BunnyStateReturn
  XOR A
  LD (BunnyStateTimer), A
  JR BunnyVarsSet
EnableHover:
  LD A, $FF
  LD (BunnyAir), A
BunnyVarsSet:
  LD A, $08
  LD (BunnyHoverTimer), A
  LD A, $18
  LD (VerticalSpeedIndex), A
  LD A, $06
  LD (SoundEffect), A
BunnyStateReturn:
  RET
