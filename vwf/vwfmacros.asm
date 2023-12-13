


; General stuff

function vwf_get_color_index_2bpp(palette, id) = (palette*4)+id

; RPG Hacker: This exists as a define, because regular space in all tables is defined as FFFE.
; If we pass that to %vwf_char() macro, we would get garbage in 16-Bit mode, rather than escaping a space.
!vwf_nbsp_char = $00FE


macro vwf_generate_command_table(command)
	if !vwf_bit_mode == VWF_BitMode.8Bit
		db <command>
	elseif !vwf_bit_mode == VWF_BitMode.16Bit
		dw $FF00|<command>
	endif
endmacro


macro vwf_generate_text_table(text)
	if !vwf_bit_mode == VWF_BitMode.8Bit
		db "<text>"
	elseif !vwf_bit_mode == VWF_BitMode.16Bit
		dw "<text>"
	endif
endmacro



; Enums

macro vwf_define_enums(prefix)
	%define_enum(<prefix>AddressSize, 8Bit, 16Bit)
	%define_enum(<prefix>BoxAnimation, None, SoE, SoM, MMZ, Instant)
	; RPG Hacker: Seems I never implemented right-aligned text for some reason, and we can't easily
	; implement it into VWF Patch 1.3 without breaking header binary compatibility, because only a
	; single bit is reserved for this setting. However, once 1.3 has been out for a while and everyone
	; has switched to using the macro system, binary compatibility no longer matters as much, so we can
	; decide to add right-aligned text to version 1.4 or later if we desire.
	%define_enum(<prefix>TextAlignment, Left, Centered)
	%define_enum(<prefix>AutoWait, None, WaitForA)
	%define_enum(<prefix>ExitToOwMode, NoExit, PrimaryExit, SecondaryExit)
	
	%define_enum_with_values(<prefix>ColorID, Text, 2, Outline, 3)
	
	struct WaitFrames extends <prefix>AutoWait
		!temp_i #= 1
		while !temp_i < $FF
			.!temp_i: skip 1
		
			!temp_i #= !temp_i+1
		endwhile
		undef "temp_i"
	endstruct
	
	!enum_<prefix>AutoWait_last #= <prefix>AutoWait.WaitFrames.254
endmacro

%vwf_define_enums("VWF_")
	
if !vwf_enable_short_aliases != false
	%vwf_define_enums("")
endif



; Resource management macros

macro vwf_first_bank()
	freedata
	!vwf_prev_freespace:
endmacro

macro vwf_next_bank()
	freedata : prot !vwf_prev_freespace
	!vwf_prev_freespace += a
	!vwf_prev_freespace:
endmacro

macro vwf_add_font(gfx_file, width_table_file, character_table_file)
	%vwf_next_bank()

	Font!vwf_num_fonts:
	incbin "<gfx_file>"
	.Width
	incsrc "<width_table_file>"

	; RPG Hacker: Hack: If we define another font, increase the maximum for our setter.
	!vwf_header_argument_0_maximum #= !vwf_num_fonts
	!{vwf_font_!{vwf_num_fonts}_table_file} := <character_table_file>
	
	!vwf_num_fonts #= !vwf_num_fonts+1
endmacro

macro vwf_add_messages(messages_file, table_file)
	%vwf_text_start(<table_file>)
	
	incsrc "<messages_file>"
	
	%vwf_text_end()
endmacro

macro vwf_generate_pointers()
FontTable:
	!temp_i #= 0
	while !temp_i < !vwf_num_fonts
		dl Font!{temp_i},Font!{temp_i}_Width
		!temp_i #= !temp_i+1
	endwhile
	undef "temp_i"
	
FontDigitsTable:
	pushtable

	!temp_i #= 0
	while !temp_i < !vwf_num_fonts
		incsrc "!{vwf_font_!{temp_i}_table_file}"
		%vwf_generate_text_table("0123456789ABCDEF")
		!temp_i #= !temp_i+1
	endwhile
	undef "temp_i"
	
	pulltable

Pointers:
	!temp_i #= 0
	!temp_num_gaps #= 0
	while !temp_i < !vwf_highest_message_id
		if defined("vwf_message_!{temp_i}_defined")
			if !{vwf_message_!{temp_i}_has_header}
				dl !{vwf_message_!{temp_i}_label}
			else
				!vwf_last_fallback_label := !{vwf_message_!{temp_i}_fallback_label}
				dl !vwf_last_fallback_label
			endif
		else
			; RPG Hacker: If it's a gap, use whatever was the last fallback label we found.
			; If there is none, just pad with magic hex. It will likely lead to a crash if
			; someone attempts to open the message, but at least we should be able to find
			; it in the ROM and know what's going on.
			if defined("vwf_last_fallback_label")
				dl !vwf_last_fallback_label
			else
				dl $000BAD
			endif
			!temp_num_gaps #= !temp_num_gaps+1
		endif
	
		!temp_i #= !temp_i+1
	endwhile
	undef "temp_i"
PointersEnd:
	
	if !temp_num_gaps >= 50
		warn "Found !temp_num_gaps gaps in message IDs. Gaps in message IDs waste freespace, so it's recommended to avoid excessive usage of them."
	endif
	undef "temp_num_gaps"

TextMacroPointers:
	!temp_i #= 0
	while !temp_i < !vwf_num_text_macros
		dl TextMacro!temp_i
		!temp_i #= !temp_i+1
	endwhile
	undef "temp_i"
	
TextMacroGroupPointers:
	!temp_i #= 0
	while !temp_i < !vwf_num_text_macro_groups
		dl TextMacroGroup!temp_i
		!temp_i #= !temp_i+1
	endwhile
	undef "temp_i"	
	
	!temp_i #= 0
	while !temp_i < !vwf_num_text_macro_groups
		TextMacroGroup!temp_i:		
			!temp_name := !{vwf_text_macro_group_!{temp_i}_name}
			
			!{vwf_text_macro_group_!{temp_name}_sequence}
			
			undef "temp_name"
		!temp_i #= !temp_i+1
	endwhile
	undef "temp_i"
endmacro



; Text file macros

macro vwf_text_start(table_file)
	%vwf_next_bank()	
	
	pushtable
	cleartable
	incsrc "<table_file>"
	
	!vwf_current_message_name = ""
	!vwf_current_message_asm_name = ""
	!vwf_current_message_id = $10000
	!vwf_header_present = false
	!vwf_current_text_file_id #= !vwf_num_text_files
	
	assert !vwf_num_fonts > 0, "Must add at least a single font before starting a text file."
	
	%vwf_define_invalid_message_handlers(!vwf_current_text_file_id)
	
	TextFile!vwf_num_text_files:
	!vwf_num_text_files #= !vwf_num_text_files+1
endmacro

macro vwf_text_end()
	if !vwf_current_message_id != $10000
		error "A %vwf_message_start() (message !vwf_current_message_id) seems to be missing a %vwf_message_end()."		
	elseif defined("vwf_current_text_macro_group")
		error "A %vwf_start_text_macro_group() (group '!vwf_current_text_macro_group') seems to be missing a %vwf_end_text_macro_group()."	
	else		
		!vwf_current_message_name = ""
		!vwf_current_message_asm_name = ""
		!vwf_current_message_id = $10000
		!vwf_header_present = false
		!vwf_current_text_file_id = -1
		
		pulltable
	endif
endmacro

macro vwf_define_invalid_message_handlers(text_file_id)		
	!vwf_defining_internal_message = true
	
	!temp_message_id #= ((<text_file_id>+1)*10000)+1
	
	
	%vwf_message_start(!temp_message_id)
	!temp_message_id #= !temp_message_id+1
	
	HandleUndefinedMessage!vwf_num_text_files:
		%vwf_header(vwf_x_pos(1), vwf_y_pos(1), vwf_width(14), vwf_height(3), vwf_freeze_game(true), vwf_text_speed(0), vwf_auto_wait(VWF_AutoWait.WaitForA), vwf_enable_skipping(false), vwf_enable_message_asm(false))
		
		%vwf_text("Message ") : %vwf_hex(!vwf_message+1) : %vwf_hex(!vwf_message) : %vwf_text(" isn't defined. Please contact the hack author to report this oversight.")
		%vwf_wait_for_a()
	
	%vwf_message_end()
	
	
	%vwf_message_start(!temp_message_id)
	!temp_message_id #= !temp_message_id+1
	
	HandleTextMacroBufferOverflow!vwf_num_text_files:
		%vwf_header(vwf_x_pos(1), vwf_y_pos(1), vwf_width(14), vwf_height(3), vwf_freeze_game(true), vwf_text_speed(0), vwf_auto_wait(VWF_AutoWait.WaitForA), vwf_enable_skipping(false), vwf_enable_message_asm(false))
		
	HandleTextMacroBufferOverflow!{vwf_num_text_files}_Content:
		%vwf_clear() : %vwf_text("Text macro buffer overflow while calling AddToBufferedTextMacro. This is a bug, please contact the hack author.")
		%vwf_wait_for_a()
	
	%vwf_message_end()
	
	
	%vwf_message_start(!temp_message_id)
	!temp_message_id #= !temp_message_id+1
	
	HandleTextMacroIdOverflow!vwf_num_text_files:
		%vwf_header(vwf_x_pos(1), vwf_y_pos(1), vwf_width(14), vwf_height(3), vwf_freeze_game(true), vwf_text_speed(0), vwf_auto_wait(VWF_AutoWait.WaitForA), vwf_enable_skipping(false), vwf_enable_message_asm(false))
		
	HandleTextMacroIdOverflow!{vwf_num_text_files}_Content:
		%vwf_clear() : %vwf_text("Trying to use too many buffered text macros. This is a bug, please contact the hack author.")
		%vwf_wait_for_a()
	
	%vwf_message_end()
	
	
	undef "temp_message_id"
	undef "vwf_defining_internal_message"	
endmacro



; Message header macros

macro vwf_message_start(id)
	if !vwf_current_message_id != $10000
		error "A %vwf_message_start() (message !vwf_current_message_id) seems to be missing a %vwf_message_end()."
	elseif defined("vwf_message_<id>_defined")
		error "Message ID <id> used multiple times. Please make sure every message ID is unique."
	elseif not(defined("vwf_defining_internal_message")) && $<id> > $FFFF
		error "Message IDs must be between 0000 and FFFF (current: <id>)."
	else
		!vwf_current_message_name = "Message<id>"		
		!vwf_current_message_asm_name = "MessageASM<id>"
		!vwf_current_message_id = $<id>
		!vwf_header_present = false
			
		!temp_id_num #= !vwf_current_message_id
		!temp_text_id_num #= !vwf_num_text_files-1
		!{vwf_message_!{temp_id_num}_defined} = true
		!{vwf_message_!{temp_id_num}_label} := !vwf_current_message_name
		!{vwf_message_!{temp_id_num}_has_header} = false
		
		if not(defined("vwf_defining_internal_message"))
			!vwf_num_messages #= !vwf_num_messages+1
			!{vwf_message_!{temp_id_num}_fallback_label} := HandleUndefinedMessage!temp_text_id_num
			
			!vwf_last_fallback_label := !{vwf_message_!{temp_id_num}_fallback_label}
			
			if $<id> > !vwf_highest_message_id
				!vwf_highest_message_id #= $<id>
			endif
		endif
		
		undef "temp_id_num"
		undef "temp_text_id_num"
	endif
endmacro

macro vwf_message_end()
	if !vwf_current_message_id == $10000
		error "You must call %vwf_message_start() before calling %vwf_message_end()."
	else
		if !vwf_header_present != false
			; RPG Hacker: vwf_message_end() includes a %vwf_close() by default, because every message needs one.
			; This will also prevent the message box from messing up if someone forgets it, and it allows us to
			; define a default skip location.			
			if !vwf_message_skip_enabled != false && !vwf_message_skip_location_default != false
				.SkipLocation:
			endif
			
			%vwf_close()
		else
			; RPG Hacker: If we don't have at least a header, don't add this fallback. This is likely an empty message,
			; and we don't want to waste a few bytes of freespace for every empty message. This should hopefully just
			; fall through to whatever %vwf_header() or %vwf_text_start() is being called next.
			!vwf_current_message_name:
		endif
			
		!vwf_current_message_name = ""
		!vwf_current_message_id = $10000
		!vwf_header_present = false
	endif
endmacro

macro vwf_register_text_macro(name, ...)
	if defined("vwf_text_macro_<name>_defined")
		error "%vwf_register_text_macro(): Text macro redefinition: <name>"
	elseif defined("vwf_inside_text_macro")
		error "%vwf_register_text_macro(): Can't register a text macro from within another one."
	elseif !vwf_current_message_id != $10000
		error "%vwf_register_text_macro(): Can't register a text macro from within a message."
	else

	TextMacro!vwf_num_text_macros:
		!vwf_inside_text_macro = true
		
		; RPG Hacker: Weird name, because inner commands might use !temp_i.
		!temp_tm_i #= 0
		while !temp_tm_i < sizeof(...)
			<...[!temp_tm_i]>
			!temp_tm_i #= !temp_tm_i+1
		endwhile
		undef "temp_tm_i"
	
		%vwf_text_macro_end()
		undef "vwf_inside_text_macro"
		
		!vwf_text_macro_<name>_defined = true
		!vwf_text_macro_<name>_id #= !vwf_num_text_macros
		; RPG Hacker: +!vwf_num_reserved_text_macros, because we are skipping the reserved macros in the table.
		if !vwf_bit_mode == VWF_BitMode.8Bit
			!vwf_text_macro_<name>_sequence := "db $E8 : dw !vwf_num_text_macros+!vwf_num_reserved_text_macros"
		else
			!vwf_text_macro_<name>_sequence := "dw $FFE8 : dw !vwf_num_text_macros+!vwf_num_reserved_text_macros"
		endif
		
		!vwf_num_text_macros #= !vwf_num_text_macros+1
	endif
endmacro

macro vwf_start_text_macro_group(name)
	if defined("vwf_current_text_macro_group")
		error "Can't start a new text macro group without closing the previous one."
	elseif defined("vwf_text_macro_group_<name>_defined")
		error "A text macro group called '<name>' already exists."
	else
		!vwf_current_text_macro_group := <name>
		!{vwf_text_macro_group_!{vwf_num_text_macro_groups}_name} := <name>
		!vwf_text_macro_group_<name>_defined := true
		!vwf_text_macro_group_<name>_id #= !vwf_num_text_macro_groups
		!vwf_text_macro_group_<name>_size #= 0
		!vwf_text_macro_group_<name>_sequence := ""
		
		!vwf_num_text_macro_groups #= !vwf_num_text_macro_groups+1
	endif
endmacro

macro vwf_add_text_macro_to_group(macro_name)
	if not(defined("vwf_current_text_macro_group"))
		error "%vwf_add_text_macro_to_group() can only be called from within a text macro group (i.e. between %vwf_start_text_macro_group() and %vwf_end_text_macro_group())."
	elseif not(defined("vwf_text_macro_<macro_name>_defined"))
		error "%vwf_add_text_macro_to_group(): Couldn't find text macro ""<macro_name>""."
	else
		!temp_name := !vwf_current_text_macro_group
		
		if !{vwf_text_macro_group_!{temp_name}_size} == 0
			!{vwf_text_macro_group_!{temp_name}_sequence} := "dw !vwf_text_macro_<macro_name>_id"
		else
			!{vwf_text_macro_group_!{temp_name}_sequence} += ",!vwf_text_macro_<macro_name>_id"
			!{vwf_text_macro_group_!{temp_name}_sequence} := !{vwf_text_macro_group_!{temp_name}_sequence}
		endif
		
		!{vwf_text_macro_group_!{temp_name}_size} #= !{vwf_text_macro_group_!{temp_name}_size}+1
		undef "temp_name"
	endif
endmacro

macro vwf_end_text_macro_group()
	if not(defined("vwf_current_text_macro_group"))
		error "Can't call %vwf_end_text_macro_group() without calling %vwf_start_text_macro_group() first."
	else
		undef "vwf_current_text_macro_group"
	endif
endmacro


macro vwf_inline(...)
	if defined("vwf_inside_text_macro") || !vwf_current_message_id != $10000
		error "%vwf_inline(): Can't be called from within a message, a text macro or another inline block."
	else
		?TextBlock:
			dw ?.End-?.Begin
		?.Begin
			!vwf_inside_text_macro = true
			
			; RPG Hacker: Weird name, because inner commands might use !temp_i.
			!temp_tm_i #= 0
			while !temp_tm_i < sizeof(...)
				<...[!temp_tm_i]>
				!temp_tm_i #= !temp_tm_i+1
			endwhile
			undef "temp_tm_i"
		
			undef "vwf_inside_text_macro"		
		?.End
	endif
endmacro


; RPG Hacker: A lot of macro wizardry following below. I know this is all quite nasty, unintuitive
; and hard to read. The TL;DR about what I'm doing here is that I'm abusing macros to define a few
; helper functions that simulate dictionaries from traditional programming languages. I'm then using
; these "dictionaries" to implement the logic for the parsing of my generic headers.
!vwf_header_num_setters = 0

macro vwf_set_header_arg_property(arg_id, property_name, value)
	!vwf_header_argument_<arg_id>_<property_name> := <value>
endmacro

macro vwf_define_header_setter_generic(name, is_hex, minimum, maximum)
	%vwf_set_header_arg_property(!vwf_header_num_setters, "name", <name>)	
	
	%vwf_set_header_arg_property(!vwf_header_num_setters, "index", !vwf_header_num_setters)
	%vwf_set_header_arg_property(!vwf_header_num_setters, "type", 0)
	%vwf_set_header_arg_property(!vwf_header_num_setters, "is_hex", <is_hex>)
	%vwf_set_header_arg_property(!vwf_header_num_setters, "minimum", <minimum>)
	%vwf_set_header_arg_property(!vwf_header_num_setters, "maximum", <maximum>)
	
	function vwf_<name>(value) = (!vwf_header_num_setters<<24)|value
	
	if !vwf_enable_short_aliases != false
		function <name>(value) = vwf_<name>(value)
	endif
	
	!vwf_header_num_setters #= !vwf_header_num_setters+1
endmacro

macro vwf_define_header_setter_sound(name)
	%vwf_set_header_arg_property(!vwf_header_num_setters, "name", <name>)
	
	%vwf_set_header_arg_property(!vwf_header_num_setters, "index", !vwf_header_num_setters)
	%vwf_set_header_arg_property(!vwf_header_num_setters, "type", 1)
	
	function vwf_<name>(sound_bank, sound_id) = (!vwf_header_num_setters<<24)|((sound_id&$FF)<<16)|(sound_bank&$FFFF)
	
	if !vwf_enable_short_aliases != false
		function <name>(sound_bank, sound_id) = vwf_<name>(sound_bank, sound_id)
	endif
	
	!vwf_header_num_setters #= !vwf_header_num_setters+1
endmacro


macro vwf_get_header_arg_name(out_var, arg_id)
	!<out_var> := !vwf_header_argument_<arg_id>_name
endmacro

macro vwf_reset_header_arg_to_default(arg_id, name)
	if !vwf_header_argument_<arg_id>_type == 0
		; Generic value
		!vwf_header_argument_<name>_value #= !vwf_default_<name>
	elseif !vwf_header_argument_<arg_id>_type == 1
		; Sound ID + Bank
		!vwf_header_argument_<name>_id #= !vwf_default_<name>_id
		!vwf_header_argument_<name>_bank #= !vwf_default_<name>_bank
	else
		error "Header function ""vwf_<name>()"" has an unknown type, indicating a bug in the patch."
	endif
endmacro

macro vwf_clear_header_argument(arg_id)
	%vwf_get_header_arg_name("temp_name", <arg_id>)
	
	%vwf_reset_header_arg_to_default(<arg_id>, !temp_name)
	undef "temp_name"
	
	!vwf_header_argument_<arg_id>_set #= false
endmacro

macro vwf_clear_header_arguments()
	!temp_i #= 0
	while !temp_i < !vwf_header_num_setters		
		%vwf_clear_header_argument(!temp_i)
		
		!temp_i #= !temp_i+1
	endwhile
	undef "temp_i"
endmacro


macro vwf_verify_header_argument_value(arg_id, name, value, display_name)
	if !vwf_header_argument_<arg_id>_type == 0
		; Generic value
		if !vwf_header_argument_<arg_id>_is_hex == false
			!vwf_set_generic_extra_char = ""
			!vwf_set_generic_value_output = dec(<value>)
		else
			!vwf_set_generic_extra_char = "$"
			!vwf_set_generic_value_output = hex(<value>)
		endif
	
		if <value> < !vwf_header_argument_<arg_id>_minimum || <value> > !vwf_header_argument_<arg_id>_maximum
			error "<display_name>: Invalid value: !vwf_set_generic_extra_char",!vwf_set_generic_value_output,", should be between !vwf_header_argument_<arg_id>_minimum and !vwf_header_argument_<arg_id>_maximum."
		else
			!vwf_header_argument_<name>_value #= <value>
		endif	
	elseif !vwf_header_argument_<arg_id>_type == 1
		; Sound ID + Bank
		!temp_sound_id #= (<value>>>16)%$FF
		!temp_bank #= <value>&$FFFF
		
		if !temp_bank < $1DF9 || !temp_bank > $1DFC
			error "<display_name>: Invalid sound bank address: $",hex(!temp_bank),", should be between $1DF9 and $1DFC."
		else
			; RPG Hacker: Should consider promoting this to an error, because I honestly can't think of ANY
			; scenario where allowing $1DFB could actually work. However, the original manual only mentioned
			; that using this value was "not recommended", so for the sake of backwards-compatibility, I will
			; keep it like this for the time being.
			if !temp_bank == $1DFB
				warn "<display_name>: Using $1DFB as a sound bank. This might produce some undesired effects."
			endif
			
			; RPG Hacker: We could also check if the respective sound ID is in-bound here. However, Addmusic
			; does technically allow us to define custom sound effects, so I decided against it (even though
			; nearly no hacks actually make use of this).
	
			!vwf_header_argument_<name>_id #= !temp_sound_id
			!vwf_header_argument_<name>_bank #= !temp_bank
		endif
		undef "temp_sound_id"
		undef "temp_bank"
	else
		error "Header property <arg_id> (set via ""<display_name>"") has an unknown type, indicating a bug in the patch."
	endif
endmacro

macro vwf_verify_header_argument(arg_id, name, value)
	if !vwf_header_argument_<arg_id>_set != false
		error "vwf_<name>() set multiple times in one header."
	endif
	
	%vwf_verify_header_argument_value(<arg_id>, <name>, <value>, "vwf_<name>()")
	
	!vwf_header_argument_<arg_id>_set #= true
endmacro

macro vwf_extract_header_agrument(packed_value)
	; RPG Hacker: This initialization is here so that if the #= below fails (which will happen,
	; for example, on passing an undefined function), we run into the if below and print an error
	; that's actually meaningful to the average user, rather than a bunch of nonsense.
	!temp_function_value = $FFFFFFFF

	; RPG Hacker: Really, the only reason I pre-process this arg into a define is because Asar
	; produces pretty weird error messages otherwise for functions that aren't found. Honestly,
	; that might just be another bug in Asar itself, though.
	!temp_function_value #= <packed_value>
	
	!temp_id #= (!temp_function_value>>24)&$FF
	!temp_value #= !temp_function_value&$FFFFFF
	undef "temp_function_value"
	
	if !temp_id < 0 || !temp_id > !vwf_header_num_setters
		error "Failed to parse header option type from value: <packed_value>"
	else
		%vwf_get_header_arg_name("temp_name", !temp_id)
		
		%vwf_verify_header_argument(!temp_id, !temp_name, !temp_value)
	endif
	undef "temp_id"
	undef "temp_value"
endmacro


macro vwf_verfiy_default_arguments()
	!temp_i #= 0
	while !temp_i < !vwf_header_num_setters
		%vwf_get_header_arg_name("temp_name", !temp_i)
		
		!temp_arg_type #= !{vwf_header_argument_!{temp_i}_type}
		if !temp_arg_type == 0
			!temp_define_name := vwf_default_!{temp_name}
			
			!temp_value #= !{!{temp_define_name}}
			
			!temp_packed_value #= vwf_!temp_name(!temp_value)&$FFFFFF
			
			undef "temp_value"
		elseif !temp_arg_type == 1			
			!temp_id_define_name := vwf_default_!{temp_name}_id
			!temp_bank_define_name := vwf_default_!{temp_name}_bank
			
			; RPG Hacker: Uses name of the _bank define, because that's currently the only thing that
			; can actually have an invalid value - so it makes sense if we use it for printing errors.
			!temp_define_name := !temp_bank_define_name
			
			!temp_id_value #= !{!{temp_id_define_name}}
			!temp_bank_value #= !{!{temp_bank_define_name}}
			
			!temp_packed_value #= vwf_!temp_name(!temp_bank_value, !temp_id_value)&$FFFFFF
			
			undef "temp_id_value"
			undef "temp_bank_value"
		else
			error "Header property !temp_i (set while parsing defaults) has an unknown type, indicating a bug in the patch."
		endif
		
		; RPG Hacker: I know this looks silly af, but the triple backslashes are actually necessary.
		; Using only one backslash here makes Asar try to resolve the define once inside the macro...
		!temp_printable_name = "\\\!!{temp_define_name}"
		%vwf_verify_header_argument_value(!temp_i, !temp_name, !temp_packed_value, !temp_printable_name)
		undef "temp_define_name"
		undef "temp_packed_value"
		
		!temp_i #= !temp_i+1
	endwhile
	undef "temp_i"
endmacro


; RPG Hacker: This currently needs to be the first setter defined,
; due to a hack in %vwf_add_font().
%vwf_define_header_setter_generic("font", false, 0, !vwf_num_fonts-1)

%vwf_define_header_setter_generic("x_pos", false, 0, 28)
%vwf_define_header_setter_generic("y_pos", false, 0, 24)
%vwf_define_header_setter_generic("width", false, 1, 15)
%vwf_define_header_setter_generic("height", false, 1, 13)

%vwf_define_header_setter_generic("box_animation", false, !enum_VWF_BoxAnimation_first, !enum_VWF_BoxAnimation_last)
%vwf_define_header_setter_generic("text_palette", true, $00, $07)
%vwf_define_header_setter_generic("text_color", true, rgb_15(0,0,0), rgb_15(31,31,31))
%vwf_define_header_setter_generic("outline_color", true, rgb_15(0,0,0), rgb_15(31,31,31))

%vwf_define_header_setter_generic("space_width", false, 0, 16)
%vwf_define_header_setter_generic("text_margin", false, 0, 7)
%vwf_define_header_setter_generic("text_alignment", false, !enum_VWF_TextAlignment_first, !enum_VWF_TextAlignment_last)

%vwf_define_header_setter_generic("freeze_game", false, false, true)
%vwf_define_header_setter_generic("text_speed", false, 0, 63)
%vwf_define_header_setter_generic("auto_wait", false, !enum_VWF_AutoWait_first, !enum_VWF_AutoWait_last)
%vwf_define_header_setter_generic("button_speedup", false, false, true)
%vwf_define_header_setter_generic("enable_skipping", false, false, true)

%vwf_define_header_setter_generic("enable_sfx", false, false, true)
%vwf_define_header_setter_sound("letter_sound")
%vwf_define_header_setter_sound("wait_sound")
%vwf_define_header_setter_sound("cursor_sound")
%vwf_define_header_setter_sound("continue_sound")

%vwf_define_header_setter_generic("enable_message_asm", false, false, true)


macro vwf_header(...)
	if !vwf_current_message_id == $10000
		error "You must call %vwf_message_start() before calling %vwf_header()."
	else
		!temp_id_num #= !vwf_current_message_id
		!{vwf_message_!{temp_id_num}_has_header} = true
		undef "temp_id_num"
	
	!vwf_current_message_name:
	
		%vwf_clear_header_arguments()
		
		!temp_i #= 0
		while !temp_i < sizeof(...)
			%vwf_extract_header_agrument(<...[!temp_i]>)
			!temp_i #= !temp_i+1
		endwhile
		undef "temp_i"
			
		!vwf_header_present = true
		
		
		; RPG Hacker: We could do some more validation on header arguments here.
		; For example: Verify that the X/Y pos is valid against the chosen width/height.
		; That way, we could remove a lot of the runtime-side checks.
		; However, for now, I'm leaving things as they are.
		; I don't want too end up rewriting absolutely everything.		
		
		
		; Header format:
		
		; db $aa
		; $aa:    Font number
		if !vwf_bit_mode == VWF_BitMode.8Bit
			db !vwf_header_argument_font_value
		endif
		
		; db %aaaaabbb,%bbccccdd,%ddeeeeff,%ffgggggg
		; %aaaaa:  Text box X pos
		; %bbbbb:  Text box Y pos
		; %cccc:   Text box width
		; %dddd:   Text box height
		; %eeee:   Text margin (free space at left and right edge of text box) in pixels
		; %ffff:   Width of a space in pixels
		; %gggggg: Text speed (number of frames between letters)		
		db (!vwf_header_argument_x_pos_value<<3)|(!vwf_header_argument_y_pos_value>>2)
		db (!vwf_header_argument_y_pos_value<<6)|(!vwf_header_argument_width_value<<2)|(!vwf_header_argument_height_value>>2)
		db (!vwf_header_argument_height_value<<6)|(!vwf_header_argument_text_margin_value<<2)|(!vwf_header_argument_space_width_value>>2)
		db (!vwf_header_argument_space_width_value<<6)|!vwf_header_argument_text_speed_value
		
		; db $aa,%bbbb--cd
		; $aa:     Auto wait options
		; %bbbb:   Text box creation animation
		; %c:      Enable message box skip
		; %d:      Enable MessageASM
		db !vwf_header_argument_auto_wait_value
		db (!vwf_header_argument_box_animation_value<<4)|(!vwf_header_argument_enable_skipping_value<<1)|!vwf_header_argument_enable_message_asm_value
		
		; dw $aaaa,$bbbb
		; $aaaa    Text palette's third color (text color)
		; $bbbb    Text palette's fourth color (outlines color)
		dw !vwf_header_argument_text_color_value
		dw !vwf_header_argument_outline_color_value
		
		; db %abbbcd-e
		; %a:      Freeze gameplay
		; %bbb:    Text palette number
		; %c:      Text alignment (left/centered)
		; %d:      Allow button speedup
		; %e:      Disable all sound effects
		db (!vwf_header_argument_freeze_game_value<<7)|(!vwf_header_argument_text_palette_value<<4)|(!vwf_header_argument_text_alignment_value<<3)\
			|(!vwf_header_argument_button_speedup_value<<2)|not(!vwf_header_argument_enable_sfx_value)
		
		; db %aabbccdd   (skip if sounds disabled)
		; %aa      Letter sound bank (-$1DF9)
		; %bb      Wait for A button sound bank (-$1DF9)
		; %cc      Cursor sound bank (-$1DF9)
		; %dd      Continue sound bank (-$1DF9)
		if !vwf_header_argument_enable_sfx_value
			db ((!vwf_header_argument_letter_sound_bank-$1DF9)<<6)|((!vwf_header_argument_wait_sound_bank-$1DF9)<<4)\
				|((!vwf_header_argument_cursor_sound_bank-$1DF9)<<2)|(!vwf_header_argument_continue_sound_bank-$1DF9)
		endif
		
		; db $aa,$bb,$cc,$dd   (skip if sounds disabled)
		; $aa      Letter sound ID
		; $bb      Wait for A button sound ID
		; $cc      Cursor sound ID
		; $dd      Continue sound ID
		if !vwf_header_argument_enable_sfx_value
			db !vwf_header_argument_letter_sound_id
			db !vwf_header_argument_wait_sound_id
			db !vwf_header_argument_cursor_sound_id
			db !vwf_header_argument_continue_sound_id
		endif
		
		; dl $aaaaaa   (skip if message skip disabled)
		; $aaaaaa: Message skip location
		if !vwf_header_argument_enable_skipping_value
			dl .SkipLocation
			!vwf_message_skip_enabled = true
			!vwf_message_skip_location_default = true
		else
			!vwf_message_skip_enabled = false
			!vwf_message_skip_location_default = false
		endif
		
		; dl $aaaaaa   (skip if MessageASM disabled)
		; $aaaaaa: MessageASM location
		if !vwf_header_argument_enable_message_asm_value
			dl !vwf_current_message_asm_name
		endif
	endif
endmacro



; Message command macros

macro vwf_print_message_command_error()
	error "Message content macros can only be called inside a message body (i.e. after a call to %vwf_header() and before a call to %vwf_message_end()) or text macro."
endmacro

!vwf_message_command_error_condition = "not(defined(""vwf_inside_text_macro"")) && or(equal(!vwf_current_message_id,$10000),equal(!vwf_header_present,false))"

macro vwf_char(value)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		if !vwf_bit_mode == VWF_BitMode.8Bit
			if <value> >= !vwf_lowest_reserved_hex&$FF
				db $F4
			endif
			db <value>
		else
			if <value> >= !vwf_lowest_reserved_hex
				dw $FFF4
			endif
			dw <value>
		endif
	endif
endmacro

macro vwf_non_breaking_space()
	%vwf_char(!vwf_nbsp_char)
endmacro

; RPG Hacker: TODO: Ideally, this macro should prevent anything contained
; in the string to be evaluated as commands (except for spaces). However,
; this would require iterating over the input string, which is something
; not currently supported by Asar whatsoever.
macro vwf_text(text)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_text_table("<text>")
	endif
endmacro

macro vwf_set_skip_location()
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif !vwf_message_skip_enabled == false
		warn "Calling %vwf_set_skip_location() for a message that has skipping disabled. You might have forgotten to enable skipping in the header."
	elseif !vwf_message_skip_location_default == false
		error "Calling %vwf_set_skip_location() multiple times for one message."
	else
		!vwf_message_skip_location_default = false
		.SkipLocation
	endif
endmacro

macro vwf_close()
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_command_table($FF)
	endif
endmacro

; RPG Hacker: Should never really be needed, but why not.
macro vwf_space()
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_command_table($FE)
	endif
endmacro

macro vwf_line_break()
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_command_table($FD)
	endif
endmacro

macro vwf_display_message(message_id, ...)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		!temp_show_close_animation = false
		!temp_show_open_animation = false
		
		if sizeof(...) > 0
			!temp_show_close_animation = <...[0]>
		endif
		
		if sizeof(...) > 1
			!temp_show_open_animation = <...[1]>
		endif
		
		if !temp_show_close_animation != true && !temp_show_close_animation != false
			error "%vwf_display_message(): ""show_close_animation"" must be either true or false."
		endif
		
		if !temp_show_open_animation != true && !temp_show_open_animation != false
			error "%vwf_display_message(): ""show_open_animation"" must be either true or false."
		endif
		
		%vwf_generate_command_table($FC)
		
		if !temp_show_open_animation == false && !temp_show_close_animation == false
			; RPG Hacker: Legacy format. This branch should be removed once
			; we get rid of the backwards-compatibility hack.
			dw $<message_id>
		else
			; RPG Hacker: For backwards compatibility, we use a magic hex
			; to determine if this is a new format command.
			; Once version 1.3 has been out for a considerable amount of time,
			; we can remove this.
			dw $FFFF
			dw $<message_id>
			db !temp_show_open_animation|(!temp_show_close_animation<<1)
		endif
		
		undef "temp_show_close_animation"
		undef "temp_show_open_animation"
	endif
endmacro

macro vwf_set_text_pointer(pointer)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_command_table($FB)
		dl <pointer>
	endif
endmacro

macro vwf_wait_for_a()
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_command_table($FA)
	endif
endmacro

macro vwf_wait_frames(num_frames)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif <num_frames> < $00 || <num_frames> > $FF	
		error "%vwf_wait_frames() only supports values between ",dec($00)," and ",dec($FF)," (current: ",dec(<num_frames>),")."
	else
		%vwf_generate_command_table($F9)
		db <num_frames>
	endif
endmacro

macro vwf_set_text_speed(text_speed)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif <text_speed> < $00 || <text_speed> > $FF	
		error "%vwf_set_text_speed() only supports values between ",dec($00)," and ",dec($FF)," (current: ",dec(<text_speed>),")."
	else
		%vwf_generate_command_table($F8)
		db <text_speed>
	endif
endmacro

macro vwf_decimal(address, ...)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		!temp_address_size = VWF_AddressSize.8Bit
		!temp_leading_zeroes = false
		
		if sizeof(...) > 0
			!temp_address_size = <...[0]>
		endif
		
		if sizeof(...) > 1
			!temp_leading_zeroes = <...[1]>
		endif
		
		if !temp_address_size < !enum_VWF_AddressSize_first || !temp_address_size > !enum_VWF_AddressSize_last
			error "%vwf_decimal(): ""address_size"" must be a value between ""!enum_VWF_AddressSize_first"" and ""!enum_VWF_AddressSize_last""."
		endif
		
		if !temp_leading_zeroes != true && !temp_leading_zeroes != false
			error "%vwf_decimal(): ""leading_zeroes"" must be either true or false"
		endif
	
		%vwf_generate_command_table($F7)
		dl <address>
		; RPG Hacker: For some reason, I decided to reverse the "leading zeroes" bit back when I wrote the patch...
		; What a sussy baka.
		db (!temp_address_size<<4)|not(!temp_leading_zeroes)
		
		undef "temp_address_size"
		undef "temp_leading_zeroes"
	endif
endmacro

macro vwf_hex(address)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_command_table($F6)
		dl <address>
	endif
endmacro

macro vwf_char_at_address(address)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_command_table($F5)
		dl <address>
	endif
endmacro

macro vwf_set_text_palette(palette)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif <palette> < 0 || <palette> > 7	
		error "%vwf_set_text_palette() only supports values between 0 and 7 (current: <palette>)."
	else
		%vwf_generate_command_table($F3)
		db <palette>
	endif
endmacro

macro vwf_set_font(font)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif <font> < 0 || <font> > !vwf_num_fonts-1
		error "%vwf_set_font() only supports values between 0 and ",dec(!vwf_num_fonts-1)," (current: ",dec(<font>),")."
	else
		; RPG Hacker: Changing fonts does nothing in 16-Bit mode.
		if !vwf_bit_mode == VWF_BitMode.8Bit
			%vwf_generate_command_table($F2)
			db <font>
		endif
	endif
endmacro

macro vwf_execute_subroutine(address)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_command_table($F1)
		dl <address>
	endif
endmacro

macro vwf_wrap(...)
	; RPG Hacker: Inner commands might use !temp_i, so, uuh...
	; Let's just use a different name here.
	!temp_very_secure_i #= 0
	while !temp_very_secure_i < sizeof(...)
		<...[!temp_very_secure_i]>
	
		!temp_very_secure_i #= !temp_very_secure_i+1
	endwhile
	undef "temp_very_secure_i"
endmacro

macro vwf_display_options(label_prefix, ...)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif sizeof(...) == 0
		error "%vwf_display_options() needs at least a single option."
	elseif sizeof(...) > 13
		error "%vwf_display_options() supports only up to 13 options (current: ",dec(sizeof(...)),")."
	elseif !vwf_default_cursor_space < 0 || !vwf_default_cursor_space > 7
		error "\!vwf_default_cursor_space must be a value between 0 and 7 (curent: ",dec(!vwf_default_cursor_space),")."
	else
		%vwf_generate_command_table($F0)
		db (sizeof(...)<<4)|!vwf_default_cursor_space
		if !vwf_bit_mode == VWF_BitMode.8Bit
			db !vwf_default_cursor_char
		elseif !vwf_bit_mode == VWF_BitMode.16Bit
			dw !vwf_default_cursor_char
		endif
		
		!temp_i #= 0
		while !temp_i < sizeof(...)
			dl .<label_prefix>!temp_i
		
			!temp_i #= !temp_i+1
		endwhile
		undef "temp_i"
		
		; RPG Hacker: Inner commands might use !temp_i, so, uuh...
		; Let's just use a different name here.
		!temp_secure_i #= 0
		while !temp_secure_i < sizeof(...)
			<...[!temp_secure_i]>
			
			%vwf_line_break()
		
			!temp_secure_i #= !temp_secure_i+1
		endwhile
		undef "temp_secure_i"
	endif
endmacro

macro vwf_set_option_location(label_prefix, id)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		!temp_i #= <id>
		.<label_prefix>!temp_i:
		undef "temp_i"
	endif
endmacro

macro vwf_setup_teleport_to_level(destination_level, is_midway)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif or(less(<destination_level>, $000), greater(<destination_level>, $1FF))
		error "%vwf_setup_teleport_to_level(): destination_level must be a number between $000 and $1FF (current: $",hex(<destination_level>),")."
	elseif <is_midway> != true && <is_midway> != false
		error "%vwf_setup_teleport_to_level(): is_midway needs to be either true or false."
	else
		%vwf_generate_command_table($EF)
		dw <destination_level>
		db (<is_midway><<3)|(0<<1)
	endif
endmacro

macro vwf_setup_teleport_to_secondary_entrance(destination_entrance, is_water_level)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif or(less(<destination_entrance>, $0000), greater(<destination_entrance>, $1FFF))
		error "%vwf_setup_teleport_to_secondary_entrance(): destination_entrance must be a number between $0000 and $1FFF (current: $",hex(<destination_entrance>),")."
	elseif <is_water_level> != true && <is_water_level> != false
		error "%vwf_setup_teleport_to_secondary_entrance(): is_water_level needs to be either true or false."
	else
		%vwf_generate_command_table($EF)
		dw <destination_entrance>
		db (<is_water_level><<3)|(1<<1)
	endif
endmacro

macro vwf_setup_exit_to_overworld(mode)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif <mode> < !enum_VWF_ExitToOwMode_first || <mode> > !enum_VWF_ExitToOwMode_last
		error "%vwf_setup_exit_to_overworld(): ""mode"" must be a value between ""!enum_VWF_ExitToOwMode_first"" and ""!enum_VWF_ExitToOwMode_last""."
	else		
		%vwf_generate_command_table($E6)
		db <mode>
	endif
endmacro

macro vwf_change_colors(palette_start, ...)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif <palette_start> < $00 || <palette_start> > $FF
		error "%vwf_change_colors(): palette_start must be a number between $00 and $FF (current: $",hex(<palette_start>),")."
	elseif sizeof(...) < 1
		error "%vwf_change_colors() needs at least a single color."
	elseif sizeof(...)+<palette_start> > $100
		error "%vwf_change_colors(): can only provide up to ",dec($100-<palette_start>)," colors from palette start position $",hex(<palette_start>),". Current: ",dec(sizeof(...)),"."
	else		
		!temp_i #= 0
		while !temp_i < sizeof(...)
			%vwf_generate_command_table($EE)
			
			if <...[!temp_i]> < $0000 || <...[!temp_i]> > $7FFF
				error "%vwf_change_colors(): colors must be numbers between $0000 and $7FFF. Please use the rgb_15() function. (Current at ",dec(!temp_i),": $",hex(<...[!temp_i]>),")."
			endif
			
			db <palette_start>+!temp_i
			dw <...[!temp_i]>
		
			!temp_i #= !temp_i+1
		endwhile
		undef "temp_i"
	endif
endmacro

; This macro is just a neat little shortcut that does multiple things at once.
macro vwf_set_text_color(palette_no, text_color)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif <palette_no> < $00 || <palette_no> > $07
		error "%vwf_set_text_color(): palette_no must be a number between $00 and $07 (current: $",hex(<palette_no>),")."
	elseif <text_color> < $0000 || <text_color> > $7FFF
		error "%vwf_set_text_color(): text_color must be a number between $0000 and $7FFF. Please use the rgb_15() function. (current: $",hex(<text_color>),")."
	else
		%vwf_change_colors(vwf_get_color_index_2bpp(<palette_no>, VWF_ColorID.Text), <text_color>, rgb_15(0, 0, 0))
		%vwf_set_text_palette(<palette_no>)
	endif
endmacro

macro vwf_clear()
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_command_table($ED)
	endif
endmacro

macro vwf_play_bgm(bgm_id)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif <bgm_id> < $00 || <bgm_id> > $FF
		error "%vwf_play_bgm() only supports values between $00 and $FF (current: $",hex(<bgm_id>),")."
	else
		%vwf_generate_command_table($EC)
		db <bgm_id>
	endif
endmacro

macro vwf_freeze()
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	else
		%vwf_generate_command_table($EB)
	endif
endmacro

macro vwf_char_offset(offset)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif <offset> < $0000 || <offset> > $FFFF
		error "%vwf_char_offset() only supports values between $0000 and $FFFF (current: $",hex(<offset>),")."
	else
		%vwf_generate_command_table($EA)		
		if !vwf_bit_mode == VWF_BitMode.8Bit
			db <offset>
		elseif !vwf_bit_mode == VWF_BitMode.16Bit
			dw <offset>
		endif
	endif
endmacro

macro vwf_execute_text_macro_by_indexed_group(group_name, index)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif not(defined("vwf_text_macro_group_<group_name>_defined"))
		error "%vwf_execute_text_macro_by_group(): Couldn't find text macro group ""<group_name>""."
	else
		%vwf_generate_command_table($E9)
		
		dl <index>
		db !vwf_text_macro_group_<group_name>_id
	endif
endmacro

macro vwf_execute_text_macro(name)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif not(defined("vwf_text_macro_<name>_defined"))
		error "%vwf_execute_text_macro(): Couldn't find text macro ""<name>""."
	else
		!vwf_text_macro_<name>_sequence
	endif
endmacro

macro vwf_execute_buffered_text_macro(id)
	if !vwf_message_command_error_condition
		%vwf_print_message_command_error()
	elseif <id> >= !vwf_num_reserved_text_macros || <id> < 0
		error "%vwf_execute_buffered_text_macro(): ID for buffered text macros must be a value between 0 and ",dec(!vwf_num_reserved_text_macros-1),". Current: ",dec(<id>)
	else
		%vwf_generate_command_table($E8)
		dw <id>
	endif
endmacro

; RPG Hacker: This one is for internal purposes only. End users should never have a reason to use this.
macro vwf_text_macro_end()
	if not(defined("vwf_inside_text_macro"))
		error "%vwf_text_macro_end() is intended for internal purposes only and should be called automatically by %vwf_register_text_macro()."
	else
		%vwf_generate_command_table($E7)
	endif
endmacro



; Define short aliases only if the user opted in for them.
; This is in case someone wants to include this patch from within another one. These short defines
; might easily cause a conflict, so we give the user the ability to disable them.
if !vwf_enable_short_aliases != false
	!text = %vwf_text
	!str = %vwf_text
	
	!char = %vwf_char
	!chr = %vwf_char
	!ram_char = %vwf_char_at_address
	!ram_chr = %vwf_char_at_address
	!char_offset = %vwf_char_offset
	!chr_offset = %vwf_char_offset
	
	!nbsp = %vwf_non_breaking_space()
	
	!n = %vwf_line_break()
	!lf = %vwf_line_break()
	!break = %vwf_line_break()
	!new_line = %vwf_line_break()
	
	!sp = %vwf_space()
	!space = %vwf_space()
	
	!clear = %vwf_clear()
	!skip_loc = %vwf_set_skip_location()
	!close = %vwf_close()
	
	!press_a = %vwf_wait_for_a()
	!wait_frames = %vwf_wait_frames
	!set_speed = %vwf_set_text_speed
	
	!freeze = %vwf_freeze()
	!halt = %vwf_freeze()
	!jump = %vwf_set_text_pointer	
	!open_message = %vwf_display_message
	
	!font = %vwf_set_font
	!edit_pal = %vwf_change_colors
	!set_pal = %vwf_set_text_palette
	!set_color = %vwf_set_text_color
	!reset_color = %vwf_set_text_palette(!vwf_default_text_palette)
	
	!text_color_0 = "vwf_get_color_index_2bpp($00, VWF_ColorID.Text)"
	!text_color_1 = "vwf_get_color_index_2bpp($01, VWF_ColorID.Text)"
	!text_color_2 = "vwf_get_color_index_2bpp($02, VWF_ColorID.Text)"
	!text_color_3 = "vwf_get_color_index_2bpp($03, VWF_ColorID.Text)"
	!text_color_4 = "vwf_get_color_index_2bpp($04, VWF_ColorID.Text)"
	!text_color_5 = "vwf_get_color_index_2bpp($05, VWF_ColorID.Text)"
	!text_color_6 = "vwf_get_color_index_2bpp($06, VWF_ColorID.Text)"
	!text_color_7 = "vwf_get_color_index_2bpp($07, VWF_ColorID.Text)"
	
	!outline_color_0 = "vwf_get_color_index_2bpp($00, VWF_ColorID.Outline)"
	!outline_color_1 = "vwf_get_color_index_2bpp($01, VWF_ColorID.Outline)"
	!outline_color_2 = "vwf_get_color_index_2bpp($02, VWF_ColorID.Outline)"
	!outline_color_3 = "vwf_get_color_index_2bpp($03, VWF_ColorID.Outline)"
	!outline_color_4 = "vwf_get_color_index_2bpp($04, VWF_ColorID.Outline)"
	!outline_color_5 = "vwf_get_color_index_2bpp($05, VWF_ColorID.Outline)"
	!outline_color_6 = "vwf_get_color_index_2bpp($06, VWF_ColorID.Outline)"
	!outline_color_7 = "vwf_get_color_index_2bpp($07, VWF_ColorID.Outline)"
	
	!dec = %vwf_decimal
	!hex = %vwf_hex
	
	!play_bgm = %vwf_play_bgm
	!teleport_to_level = %vwf_setup_teleport_to_level
	!teleport_to_secondary = %vwf_setup_teleport_to_secondary_entrance
	!exit_to_ow = %vwf_setup_exit_to_overworld
	
	!options = %vwf_display_options
	!opt_loc = %vwf_set_option_location
	
	!execute = %vwf_execute_subroutine
	!exec = %vwf_execute_subroutine
	
	!macro = %vwf_execute_text_macro
	!macro_group = %vwf_execute_text_macro_by_indexed_group
	!macro_buf = %vwf_execute_buffered_text_macro
endif



; Macros solely for backwards compatibility.
; All of these are really no longer needed and should disappear at some point.
macro nextbank(freespace)
	warn "%nextbank() macro is deprecated and will disappear in a future version. Please use %vwf_add_font() or %vwf_add_messages() instead."
	%vwf_next_bank()
endmacro


macro binary(identifier, data)
	warn "%binary() macro is deprecated and will disappear in a future version. Please use %vwf_add_font() or %vwf_add_messages() instead."
	<identifier>:
	incbin "<data>"
endmacro


macro source(identifier, data)
	warn "%source() macro is deprecated and will disappear in a future version. Please use %vwf_add_font() or %vwf_add_messages() instead."
	<identifier>:
	incsrc "<data>"
endmacro

macro textstart()
	warn "%textstart() macro is deprecated and will disappear in a future version. Please use %vwf_add_messages() instead."
	%vwf_text_start("data/fonts/vwftable.asm")
endmacro

macro textend()
	warn "%textend() macro is deprecated and will disappear in a future version. Please use %vwf_add_messages() instead."
	%vwf_text_end()
endmacro
