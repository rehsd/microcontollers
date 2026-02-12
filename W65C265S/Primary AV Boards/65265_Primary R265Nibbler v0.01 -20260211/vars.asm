	;vidpageVRAM             = $0064         ; 4 bytes
	;char_vp:                .BLKB 	4     	; pointer - position for character to be drawn

	; ********** PS/2 KEYBOARD *******************************************************
		PS2_DataByte        = $20       ; 	2 		; working byte (pseudo shift register)
		KeyBuf_Head     	= $22       ; 	2		; write location
		KeyBuf_Tail     	= $24       ; 	2		; read location
		kb_flags			= $26   	; 	2		; PS2 keyboard flags (down, shift, ...)
		Str_ptr			    = $28   	; 	2		; pointer to a string
		KeyBuf          	= $2A       ;B 	32  	; 16‑word ring buffer



	; ********** /PS/2 KEYBOARD ******************************************************

	; Div32by16 (ToneGen.asm)
	FreqVal                 = $40   ;.BLKB	2
	Dividend  			    = $42   ;.BLKB	4
	Divisor   				= $46   ;.BLKB	2
	Remainder 				= $48   ;.BLKB	2

	
	; ********** ILI LCD ************************************************************
		ili_setaddrwindow_startX	= $50	;		.BLKB 2
		ili_setaddrwindow_startY	= $52	;	.BLKB 2
		ili_setaddrwindow_endX		= $54	;	.BLKB 2
		ili_setaddrwindow_endY		= $56	;	.BLKB 2
		ili_color					= $58	;	.BLKB 2
		ili_VIA1_PORTB_SHADOW 		= $5A	;	.BLKB 2
		ili_rect_width				= $5C	;	.BLKB 2
		ili_rect_height				= $5E	; 	.BLKB 2

		ili_ship_sprite_x          	= $60	; 	.BLKB 2    ; top-left X of ship
		ili_ship_sprite_y          	= $62	;;.BLKB 2    ; top-left Y of ship

		ili_ship_cur_x             	= $64	;.BLKB 2    ; current X inside row loop
		ili_ship_cur_y             	= $66	;.BLKB 2    ; current Y inside row loop

		ili_ship_move_source       	= $68	;.BLKB 2    ; pointer into ROM sprite data
		ili_ship_row_count         	= $6A	;.BLKB 2    ; 32 rows
		ili_ship_col_count         	= $6C	;.BLKB 2    ; 32 columns

		ili_ship_sprite_byte       	= $6E	;.BLKB 2    ; current sprite byte
		ili_ship_rgb332_tmp			= $70	;.BLKB 2	
		ili_ship_rgb565_tmp			= $72	;.BLKB 2	

		ili_char_color              = $74	;	.BLKB 2
		ili_current_x               = $76	;   .BLKB 2
		ili_current_y               = $78	;   .BLKB 2
		ili_char_ptr_l              = $7A	;   .BLKB 2
		ili_char_ptr_h              = $7C	;   .BLKB 2
		ili_temp_math               = $7E	;   .BLKB 2
		ili_temp_byte               = $80	;   .BLKB 2
		ili_offset_x                = $82	;   .BLKB 2
		ili_offset_y                = $84	;= $50	;   .BLKB 2

	; ********** /ILI LCD ***********************************************************

		; --- New Command Buffer ---
		cmd_buffer      = $0200         ; 64-byte command string
		cmd_index       = $0240         ; current length of command