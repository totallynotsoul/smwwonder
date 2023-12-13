On the header you will find this:

;#########################################################
;################ Dynamic Z Options ######################
;#########################################################

;Next use Hijacks: $00823D and $0082DA
;No patches uses thats hijacks.
;This hijacks are required always

!DynamicSpriteSupport30FPS = !true
!DynamicSpriteSupport60FPS = !true
!GFXChangeSupport = !true
!SemiDynamicSpriteSupport = !true
!PaletteChangeSupport = !true

;Very situational option, basically you can set parameters
;of DMA transfer from other code like a uberasm and it will
;start the transfer during nmi, not very usefull, but maybe
;someone need it.
!UseDMAMirror = !false

;Next use Hijacks: $00F636 and $00A300
;Possible incompatibilities with patches that change the GFX of mario.
;Patches with possible incompatibilities: 32x32 Mario Tiles, LX5's Custom Powerups.

!MarioGFXChangeSupport = !false
!MarioPaletteChangeSupport = !false
!FullyCustomPlayerSupport = !false

;Next use Hijacks: $008E1A, $008DAC, $008CFF, $008292, $00A43E, $00A4E3 and $00A3F0
;Possible incompatibilities with patches that changes status bar or change 
;default Not-Mario/Yoshi DMA from smw.

!Mode50moreSupport = !false

;#########################################################
;################ END of Dynamic Z Options ###############
;#########################################################

If you put !true, then you will enable that option. If you put !false that option will be disable.

Caution!!!

Reinsert the patch with less options enables than before could produce errors sometimes.
You only can Reinsert the patch with the same options or more.

Recommendation:

If you dont use any patch like 32x32 Mario Tiles, LX5's Custom Powerups or others patchs that changes stuff of 
mario graphic routine, then i recommend you select:

!MarioGFXChangeSupport and !MarioPaletteChangeSupport

Because the patch optimize the graphic routine of mario, yoshi and podoboos to only refresh their graphics only when 
is neccesary, and probably you will have less lag on the game, also if you dont use yoshi or podoboos, you will have
extra tiles on SP1 (06, 07, 08, 09, 16, 17, 18 and 19). 

