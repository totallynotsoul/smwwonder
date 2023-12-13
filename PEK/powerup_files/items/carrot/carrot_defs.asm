;##################################################################################################
;# Item: Super Carrot
;# Author: Nintendo
;# Description: Default powerup item for Bunny Mario.

;################################################
;# Properties

;# YXPPCCCT properties for this item. Only the CCCT portion is used.
!carrot_sprite_prop = $0B

;# Acts like setting for the item. Similar to custom sprites.
;# Might not affect the actual behavior of the item.
;# This should be between $74 and $78.
!carrot_acts_like = $75


;################################################
;# Collected behavior

;# Powerup number that the item will give the player when collected
;# $FF means that it won't give a powerup
!carrot_powerup_num = !bunny_powerup_num

;# SFX number that will play when the player collects this item
!carrot_collected_sfx_num = $0D
!carrot_collected_sfx_port = $1DF9

;# Enables this item to give points
!carrot_can_give_points = !yes

;# Points that will be given when collecting this item
;# Valid values: https://smwc.me/m/smw/rom/02ACE5
!carrot_collected_points = $04

;# Enables this item freezing the screen when playing an animation
!carrot_freeze_screen = !yes

;# Default Physics Flags during transition
!carrot_physicsflags = !bunny_physicsflags


;################################################
;# DSS Settings

;# DSS ExGFX ID of this item
!carrot_dss_id = !dss_id_carrot

;# DSS ExGFX Page of this item
!carrot_dss_page = $00


;################################################
;# Item box settings

;# Item overwrites whatever is inside the item box when collected
!carrot_overwrite_item_box = !yes

;# Item can be put in the item box
!carrot_put_in_box = !yes

;# SFX that will play when this item puts another item in the item box
!carrot_item_box_sfx_num = !powerup_in_item_box_sfx
!carrot_item_box_sfx_port = !powerup_in_item_box_port


;#######################
;# Mandatory macro (do not touch).

%setup_general_item_defines(!carrot_item_num)