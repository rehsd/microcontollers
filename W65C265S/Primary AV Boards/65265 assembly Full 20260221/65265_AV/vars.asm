
	; ********** VGA ****************************************************************
		vidpageVRAM 				= $10	; 4 bytes - pointer - current VRAM location
		color                   	= $14	; 2
		row                     	= $16	; 2
		fill_region_start_x     	= $18	; 2     ;Horizontal pixel position, 0 to 319
		fill_region_start_y     	= $1A	; 2     ;Vertical pixel position,   0 to 239
		fill_region_end_x       	= $1C	; 2     ;Horizontal pixel position, 0 to 319
		fill_region_end_y       	= $1E	; 2     ;Vertical pixel position,   0 to 239
		fill_region_color       	= $20	; 2     ;Color for fill,            0 to 255  
		jump_to_line_y          	= $22	; 2     ;Line to jump to,           0 to 239
		col_end                 	= $24	; 2     ;Used in FillRegion to track end column for fill
		rows_remain             	= $26	; 2     ;Used in FillRegion to track number of rows to process
		char_color              	= $28	; 2
		char_y_offset           	= $2A	; 2
		char_y_offset_orig      	= $2C	; 2
		charPixelRowLoopCounter 	= $2E	; 2     ;character pixel row loop counter
		char_current_val        	= $30	; 2
		char_from_charmap       	= $32	; 2     ;stored current char from appropriate charmap
		char_vp_x               	= $34	; 2
		char_vp_y               	= $36	; 2
		message_to_process      	= $38	; 2
		xtmp						= $3A	; 2                    
		tmpHex						= $3C	; 2
		move_size               	= $3E	; 2
		move_source             	= $40	; 2
		move_dest               	= $42	; 2
		move_counter            	= $44	; 2
		move_frame_counter      	= $46	; 2
		char_vp						= $48	; 4
	; ********** /VGA ***************************************************************




		Str_ptr			    = $50   	; 	2		; pointer to a string


	; ********** Extended SRAM POST Test ************************************************
		TestBankPointer    = $60       ; 4 bytes (Address Low, High, Bank) - really only need 3 bytes
		TestBank           = $64       ; 2 byte (counter) - really only need 1 byte
		TestPattern        = $66       ; 2 bytes (The pattern being tested)



	; Div32by16 (ToneGen.asm)
	FreqVal                 = $70   ;.BLKB	2
	Dividend  			    = $72   ;.BLKB	4
	Divisor   				= $76   ;.BLKB	2
	Remainder 				= $78   ;.BLKB	2

	
	; ********** ILI LCD ************************************************************
		ili_setaddrwindow_startX	= $80	;		.BLKB 2
		ili_setaddrwindow_startY	= $82	;	.BLKB 2
		ili_setaddrwindow_endX		= $84	;	.BLKB 2
		ili_setaddrwindow_endY		= $86	;	.BLKB 2
		ili_color					= $88	;	.BLKB 2
		ili_VIA1_PORTB_SHADOW 		= $8A	;	.BLKB 2
		ili_rect_width				= $8C	;	.BLKB 2
		ili_rect_height				= $8E	; 	.BLKB 2

		ili_ship_sprite_x          	= $90	; 	.BLKB 2    ; top-left X of ship
		ili_ship_sprite_y          	= $92	;;.BLKB 2    ; top-left Y of ship

		ili_ship_cur_x             	= $94	;.BLKB 2    ; current X inside row loop
		ili_ship_cur_y             	= $96	;.BLKB 2    ; current Y inside row loop

		ili_ship_move_source       	= $98	;.BLKB 2    ; pointer into ROM sprite data
		ili_ship_row_count         	= $9A	;.BLKB 2    ; 32 rows
		ili_ship_col_count         	= $9C	;.BLKB 2    ; 32 columns

		ili_ship_sprite_byte       	= $9E	;.BLKB 2    ; current sprite byte
		ili_ship_rgb332_tmp			= $A0	;.BLKB 2	
		ili_ship_rgb565_tmp			= $A2	;.BLKB 2	

		ili_char_color              = $A4	;	.BLKB 2
		ili_current_x               = $A6	;   .BLKB 2
		ili_current_y               = $A8	;   .BLKB 2
		ili_char_ptr_l              = $AA	;   .BLKB 2
		ili_char_ptr_h              = $AC	;   .BLKB 2
		ili_temp_math               = $AE	;   .BLKB 2
		ili_temp_byte               = $B0	;   .BLKB 2
		ili_offset_x                = $B2	;   .BLKB 2
		ili_offset_y                = $B4	;= $50	;   .BLKB 2

	; ********** /ILI LCD ***********************************************************

		; --- New Command Buffer ---
		cmd_buffer      = $0200         ; 64-byte command string
		cmd_index       = $0240         ; current length of command

	sysptr = $1000
	sysroutine = $1004
