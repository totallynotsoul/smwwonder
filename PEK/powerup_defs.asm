include 
!dss_id_shruum = $00
!dss_id_carrot = $00
!item_05_dss_id = $00
!item_06_dss_id = $00
;##################################################################################################
;# Customization

;################################################
;# Option helper
;# You shouldn't touch these

; Used for options below.
!yes = 1
!no = 0


;################################################
;# Readme confirmation

;# Set it to !yes to be able to insert the patch. 
;# I hope you did read the readme & wiki.

!i_read_the_readme = !yes



;################################################
;#  DEBUG

;# Enables debugging features:
;#  - Change player poses with UP/DOWN
!ENABLE_POSE_DEBUG = !no

;# Prints extra information in the console
!ENABLE_VERBOSE = !yes



;################################################
;# Paths
;# Working directory at this point is at ./powerup_files/
;# Do not include a slash (/) at the end

;# Sets up a default path for the powerup_defs.asm file
!powerup_files_path ?= "./powerup_files"

;# This is included in case someone wants to change the location of the list file
!powerup_list_path ?= "../powerup_list.asm"

;# This is included in case someone wants to change the location of the list file
!gfx_list_path ?= "../graphics_list.asm"

;# This is included in case someone wants to change the location of the list file
!item_list_path ?= "../item_list.asm"

;# DSS defines for easy usage in powerup items
!dss_defines_file_path ?= "../sprites/asm/ExtraDefines/dynamic_spritesets_defines.asm"

;# PIXI defines for easy usage in powerup items
!pixi_defines_file_path ?= "../sprites/asm/sa1def.asm"



;################################################
;# Free RAM blocks

;# Free BW-RAM used in SA-1 ROMs. Needs at least 480 consecutive bytes.
!powerup_ram_block = $404000    



;################################################
;# Miscelaneous customization

;# Color number of where the player palette will START being uploaded to
!palette_transfer_start    = $86

;# Color number of where the player palette will END being uploaded to
!palette_transfer_end = $8F

;# Enables clearing $7E2000, clearing Mario GFX from there completely... except for some graphics
!clear_7E2000 = !no


!dma_channel = 2

;################################################
;# Item box global configuration

;# Disables the item box
!disable_item_box = !no

;# Play the Item Box drop sound effect    
!item_box_drop_sfx = $0C
!item_box_drop_port = $1DFC

;# Sound effect for "put powerup in item box" action
!powerup_in_item_box_sfx = $0B
!powerup_in_item_box_port = $1DFC


;# X position of the item in the Item Box
!item_box_item_x_pos = $78

;# Y position of the item in the Item Box
!item_box_item_y_pos = $0F

;# X position where the item falling from the Item Box will spawn
!item_box_spawn_x_pos = $78 

;# Y position where the item falling from the Item Box will spawn
!item_box_spawn_y_pos = $20
                    
;# If enabled, the reserve item will NOT drop if you get hurt. Using SELECT still drops tie item.
!disable_drop_item = !no

;# If enabled, the item will always drop when Mario gets hurt regardless of his status.
;# NOTE: !disable_drop_item needs to be enabled in order to get this one to work.
!drop_item_if_big = !yes


;################################################
;# Collected items global configuration
;# These settings are only used for the default configuration
;# Most items only use these when they're collected and the player already has
;# the powerup associated to said item.

;# SFX number that will play when the player collects an item
!default_collected_sfx_num = $0A
!default_collected_sfx_port = $1DF9

;# Enables items to give points
!default_can_give_points = !yes

;# Points that will be given when collecting this item
;# Valid values: https://smwc.me/m/smw/rom/02ACE5
!default_collected_points = $04


;##################################################################################################
;# Macros & global defines.
;# Nothing past this point should be modified at all unless you know what you're doing.

;#########################################################################
;# Macros

	!_error_detected = 0
	!_warn_detected = 0
    incsrc "!powerup_files_path/weird_macros.asm"
    incsrc "!powerup_files_path/list_parser.asm"

;################################################
;# Setup for powerups defines.
;# Input:
;#    <num> - Powerup number to process
;#        
;# Output:
;#         A bunch of defines with generic names to make everything work automatically

macro setup_general_defines(num)
    !_name := !powerup_<num>_internal_name

    !powerup_<num>_p1_gfx_index := !{!{_name}_p1_gfx_index}
    !powerup_<num>_p1_extra_gfx_index := !{!{_name}_p1_extra_gfx_index}
    !powerup_<num>_p1_palette_index := !{!{_name}_p1_palette_index}
    !powerup_<num>_p2_gfx_index := !{!{_name}_p2_gfx_index}
    !powerup_<num>_p2_extra_gfx_index := !{!{_name}_p2_extra_gfx_index}
    !powerup_<num>_p2_palette_index := !{!{_name}_p2_palette_index}
    
    !powerup_<num>_can_spinjump := !{!{_name}_can_spinjump}
    !powerup_<num>_can_slide := !{!{_name}_can_slide}
    !powerup_<num>_can_crouch := !{!{_name}_can_crouch}
    !powerup_<num>_can_climb := !{!{_name}_can_climb}
    !powerup_<num>_can_carry_items := !{!{_name}_can_carry_items}
    !powerup_<num>_can_ride_yoshi := !{!{_name}_can_ride_yoshi}
    
    !powerup_<num>_easy_yoshi_flight := !{!{_name}_easy_yoshi_flight}

    !powerup_<num>_item_id := !{!{_name}_item_id}

    !powerup_<num>_water_y_disp := !{!{_name}_water_y_disp}
    !powerup_<num>_water_y_disp_on_yoshi := !{!{_name}_water_y_disp_on_yoshi}

    !powerup_<num>_hitbox_x_disp := !{!{_name}_hitbox_x_disp}
    !powerup_<num>_hitbox_y_disp := !{!{_name}_hitbox_y_disp}
    !powerup_<num>_hitbox_y_disp_crouching := !{!{_name}_hitbox_y_disp_crouching}
    !powerup_<num>_hitbox_y_disp_on_yoshi := !{!{_name}_hitbox_y_disp_on_yoshi}
    !powerup_<num>_hitbox_y_disp_crouching_on_yoshi := !{!{_name}_hitbox_y_disp_crouching_on_yoshi}
    !powerup_<num>_hitbox_width := !{!{_name}_hitbox_width}
    !powerup_<num>_hitbox_height := !{!{_name}_hitbox_height}
    !powerup_<num>_hitbox_height_crouching := !{!{_name}_hitbox_height_crouching}
    !powerup_<num>_hitbox_height_on_yoshi := !{!{_name}_hitbox_height_on_yoshi}
    !powerup_<num>_hitbox_height_crouching_on_yoshi := !{!{_name}_hitbox_height_crouching_on_yoshi}
endmacro

macro setup_general_gfx_defines(num)
    !_name := !gfx_<num>_internal_name

    !gfx_<num>_walk_frames := !{!{_name}_walk_frames}
endmacro

macro setup_general_item_defines(num)
    !_name := !item_<num>_internal_name

    !item_<num>_sprite_prop := !{!{_name}_sprite_prop}&$0F
    !item_<num>_dss_id := !{!{_name}_dss_id}
    !item_<num>_dss_page := !{!{_name}_dss_page}&$01

    !item_<num>_overwrite_item_box := !{!{_name}_overwrite_item_box}&$01
    !item_<num>_put_in_box := !{!{_name}_put_in_box}&$01
endmacro

;################################################
;# Insert engine
;# Includes an asm file and calculates its insert size

macro insert_file(file_path)
    if !_error_detected != 1
        if !ENABLE_VERBOSE
            print "Processed: !powerup_files_path/<file_path>"
            print "Location: $", pc
        endif
        incsrc "!powerup_files_path/<file_path>"
        if !ENABLE_VERBOSE
            print "Modified bytes: ", bytes," bytes."
            print ""
        endif
    endif
endmacro


;################################################
;# Build SA-1 defines

macro define_sprite_table_powerups(name, addr, addr_sa1)
	if !SA1 == 0
		!<name> ?= <addr>
	else
		!<name> ?= <addr_sa1>
	endif
endmacro

macro define_base2_address_powerups(name, addr)
	if !SA1 == 0
		!<name> ?= <addr>
	else
		!<name> ?= <addr>|!Base2
	endif
endmacro


;############################################################
;# DSS inclusion

!_external_call ?= 0
if !_error_detected == 0
    if read3($01DF78) != $535344
        !_error_msg = "DSS isn't present on the ROM. Please insert DSS before the Powerup expansion kit."
        !_error_detected = 1
    else
        if read2($01DF7B) < 0200
            !_error_msg = "DSS versions prior to 2.00 aren't supported by the Powerup expansion kit."
            !_error_detected = 1
        else
            if not(canreadfile1("!dss_defines_file_path", 0))
                !_error_msg = "DSS' defines file can't be read. Please check if the \!dss_defines_file_path is properly set up."
                !_error_detected = 1
            else
                incsrc "!dss_defines_file_path"
                if !_external_call == 0
                    incsrc "!pixi_defines_file_path"
                endif
            endif
        endif
    endif
    if !_error_detected == 1
        print "!!!!! ERROR !!!!!"
        print "!_error_msg"
        print ""
    endif
endif

;################################################
;# Powerup specific defines

    if !_error_detected == 0
        !i #= 0
        while !i < !max_powerup_num
            %internal_number_to_string(!i)
            if not(stringsequal("!{powerup_!{_num}_path}", "0"))
                incsrc "!powerup_files_path/!{powerup_!{_num}_path}/!{powerup_!{_num}_internal_name}_defs.asm"
            endif
            !i #= !i+1
        endif
        !i #= 0
        while !i < !max_gfx_num
            %internal_number_to_string(!i)
            if not(stringsequal("!{gfx_!{_num}_path}", "0"))
                incsrc "!powerup_files_path/!{gfx_!{_num}_path}/!{gfx_!{_num}_internal_name}_defs.asm"
            endif
            !i #= !i+1
        endif
        !i #= 0
        while !i < !max_item_num
            %internal_number_to_string(!i)
            if not(stringsequal("!{item_!{_num}_path}", "0"))
                incsrc "!powerup_files_path/!{item_!{_num}_path}/!{item_!{_num}_internal_name}_defs.asm"
            endif
            !i #= !i+1
        endif
    endif

;################################################
;# Internal defines
;# Nothing from here should be changed unless you remapped these RAMs to somewhere else.

!player_x_pos                   = $94
!player_x_low                   = $94
!player_x_high                  = $95
!player_y_pos                   = $96
!player_y_low                   = $96
!player_y_high                  = $97
!player_x_speed                 = $7B
!player_y_speed                 = $7D
!player_x_speed_sub             = $7A
!player_y_speed_sub             = $7C
!player_x_speed_16              = !player_x_speed_sub
!player_y_speed_16              = !player_y_speed_sub

!player_powerup                 = $19
!player_num                     = $0DB3|!addr
!player_powerup_timer           = $14A8|!addr ; Unused in SMW
!player_powerup_flags           = $18CA|!addr
!player_powerup_states          = !player_powerup_flags
!player_powerup_misc0           = $18CB|!addr
!player_powerup_misc1           = $18CC|!addr

!player_in_air                  = $72
!player_blocked_status          = $77
!player_in_ground               = $13EF|!addr
!player_climbing                = $74
!player_crouching               = $73
!player_crouching_yoshi         = $18DC|!addr
!player_in_water                = $75
!player_in_yoshi                = $187A|!addr
!player_wallrunning             = $13E3|!addr
!player_in_slope                = $13EE|!addr
!player_spinjump                = $140D|!addr
!player_sliding                 = $13ED|!addr
!player_holding                 = $148F|!addr
!player_carrying                = $1470|!addr
!player_disable_collision       = $185C|!addr
!player_stomp_count             = $18D2|!addr
!player_frozen                  = $13FB|!addr

!player_item_box_2              = $0DBC|!addr
!player_item_box                = $0DC2|!addr
!player_coins                   = $0DBF|!addr
!player_lives                   = $0DBE|!addr

!player_layer                   = $13F9|!addr
!player_behind                  = !player_layer

!player_direction               = $76
!player_pose_num                = $13E0|!addr
!player_walk_pose               = $13DB|!addr
!player_cape_pose_num           = $13DF|!addr
!player_extra_tile_num          = !player_cape_pose_num
!player_previous_pose_num       = $18C5|!addr
!player_extended_anim_index     = $18C6|!addr
!player_extended_anim_num       = $18C7|!addr
!player_extended_anim_pose      = $18C8|!addr
!player_extended_anim_timer     = $18C9|!addr

!player_invulnerability_timer   = $1497|!addr
!player_flash_timer             = !player_invulnerability_timer
!player_spinjump_timer          = $13E2|!addr
!player_star_timer              = $1490|!addr
!player_dash_timer              = $13E4|!addr
!player_takeoff_timer           = $149F|!addr
!player_shoot_pose_timer        = $149C|!addr
!player_animation_timer         = $1496|!addr
!player_airwalk_timer           = $14A0|!addr ; ???

!cape_interaction_flag          = $13E8|!addr
!cape_interaction_x_pos         = $13E9|!addr
!cape_interaction_y_pos         = $13EB|!addr
!cape_spin_timer                = $14A6|!addr

;################################################
;# Level RAM addresses

!level_water_flag               = $85
!level_slippery_flag            = $86
!level_on_off                   = $14AF|!addr

;################################################
;# Item sprite tables & RAM addresses

;#######################
;# Sprite tables

!item_falling                   = !1534
!item_direction                 = !157C
!item_berry_flag                = !160E
!item_roulette_flag             = !151C

;################################################
;# Free RAM allocation
;# Everything is handled automatically.

!player_graphics_index          = !powerup_ram_block
!player_graphics_pointer        = !player_graphics_index+1
!player_graphics_bypass         = !player_graphics_pointer+3
!player_graphics_extra_index    = !player_graphics_bypass+1
!player_graphics_disp_settings  = !player_graphics_extra_index+1
!player_graphics_x_disp         = !player_graphics_disp_settings+1
!player_graphics_y_disp         = !player_graphics_x_disp+256

!player_palette_pointer         = !player_graphics_y_disp+256
!player_palette_bypass          = !player_palette_pointer+3
!player_palette_index           = !player_palette_bypass+1

!player_extra_tile_settings     = !player_palette_index+1
!player_extra_tile_offset_x     = !player_extra_tile_settings+1
!player_extra_tile_offset_y     = !player_extra_tile_offset_x+2
!player_extra_tile_frame        = !player_extra_tile_offset_y+2

!player_hitbox_flag             = !player_extra_tile_frame+2
!player_hitbox_width            = !player_hitbox_flag+1
!player_hitbox_height           = !player_hitbox_width+1
!player_hitbox_disp_x           = !player_hitbox_height+1
!player_hitbox_disp_y           = !player_hitbox_disp_x+1

!player_collision_flag          = !player_hitbox_disp_y+1
!player_collision_index         = !player_collision_flag+1
!player_collision_pointer_x     = !player_collision_index+1
!player_collision_pointer_y     = !player_collision_pointer_x+3
!player_collision_data_x        = !player_collision_pointer_y+3
!player_collision_data_y        = !player_collision_data_x+128

!player_toggle_crouch           = !player_collision_data_y+128
!player_toggle_slide            = !player_toggle_crouch+1
!player_toggle_spinjump         = !player_toggle_slide+1
!player_toggle_climbing         = !player_toggle_spinjump+1
!player_toggle_carry            = !player_toggle_climbing+1
!player_toggle_ride_yoshi       = !player_toggle_carry+1
!player_toggle_easy_yoshiflight = !player_toggle_ride_yoshi+1
!player_toggle_extended_hurt    = !player_toggle_easy_yoshiflight+1

!player_physics_flags           = !player_toggle_extended_hurt+1

!player_disable_itembox         = !player_physics_flags+1

!player_backup_blocked_status   = !player_disable_itembox+1
!player_backup_slippery_status  = !player_backup_blocked_status+1
!player_backup_direction        = !player_backup_slippery_status+1

!mask_controller_15             = !player_backup_direction+1
!mask_controller_17             = !mask_controller_15+1

!player_animation_ram           = !mask_controller_17+1

!debug_ram                      = !player_animation_ram+$40

!extra_sprite_ram               = !SprSize*4
!extra_extended_ram             = !Extendedsize*5

!extended_gfx                   = !extra_extended_ram+(!ExtendedSize*0)
!extended_flags                 = !extra_extended_ram+(!ExtendedSize*1)
!extended_dir                   = !extra_extended_ram+(!ExtendedSize*2)
!extended_prev                  = !extra_extended_ram+(!ExtendedSize*3)
!extended_index                 = !extra_extended_ram+(!ExtendedSize*4)
