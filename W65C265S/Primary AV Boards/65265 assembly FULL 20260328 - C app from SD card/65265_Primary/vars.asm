
	sig_ptr = $10	; 3         ; 24-bit pointer storage for COP
	sig_val = $13	; 1         ; 8-bit command storage
	tmp 	= $14	; 4         ; temporary storage for COP operand address calculation

	; ********** PS/2 KEYBOARD *******************************************************
		PS2_DataByte        = $20       ; 	2 		; working byte (pseudo shift register)
		KeyBuf_Head     	= $22       ; 	2		; write location
		KeyBuf_Tail     	= $24       ; 	2		; read location
		kb_flags			= $26   	; 	2		; PS2 keyboard flags (down, shift, ...)
		Str_ptr			    = $28   	; 	2		; pointer to a string
		KeyBuf          	= $2A       ; 	32  	; 16‑word ring buffer
	; ********** /PS/2 KEYBOARD ******************************************************

		SP0256_StringPtr	= $2C		;	4		; holds current allophone pointer to be sent to SP0256 - only need 3 bytes

	; ********** Extended SRAM POST Test ************************************************
		TestBankPointer:    = $30       ; 4 bytes (Address Low, High, Bank) - really only need 3 bytes
		TestBank:           = $34       ; 2 byte (counter) - really only need 1 byte
		TestPattern:        = $36       ; 2 bytes (The pattern being tested)

	; ************************************
		;spi_state			= $38		; 1 byte to hold state of SPI lines (clock, miso, cs)
		SDCard_Command_Address	= $38 	; 2 bytes for pointer
		SPI_Timer               = $3A	; 2 bytes for delay timer
		SDCard_Buffer_Ptr 		= $3C	; 2 bytes for pointer to RAM buffer
		SDCard_ReadCounter		= $3E	; 2 bytes for counting bytes read from SD card		


	; Div32by16 (ToneGen.asm)
	FreqVal                 = $40   ;.BLKB	2
	Dividend  			    = $42   ;.BLKB	4
	Divisor   				= $46   ;.BLKB	2
	Remainder 				= $48   ;.BLKB	2

	TempCalcs				= $4A	; 6 bytes
		RTC_HRS .equ $4A
		RTC_MIN .equ $4B
		RTC_SEC .equ $4C
		RTC_DAY   .equ $4D
		RTC_MONTH .equ $4E
		RTC_YEAR  .equ $4F

	
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

	; ********** Randomizer ********************************************************
		RNG_SEED    		= $90       ; 16-bit seed
		RNG_MAX     		= $94       ; holds incoming max
		temp_rng			= $96		; 2 bytes

	; ********** /Randomizer ********************************************************

	; ********** Hex loader ********************************************************
		; used in secondary ROM
		hex_target_bank:	= $A0		; 2 byte
		hex_ptr_addr:   	= $A2		; 2 bytes
		hex_ptr_bank:   	= $A4		; 2 byte
		hex_temp_byte:  	= $A6		; 2 byte
		hex_byte_count: 	= $A8		; 2 byte
		hex_record_type:	= $AA		; 2 byte
		hex_addr_hi:    	= $AC		; 2 byte
		hex_addr_lo:    	= $AE		; 2 byte
		hex_checksum:		= $B0		; 2 byte
        hex_entry_ptr:      = $B2       ; 3 bytes (24-bit entry point)
	; ********** /Hex loader *******************************************************


		; --- New Command Buffer ---
		cmd_buffer      = $0200         ; 64-byte command string
		cmd_index       = $0240         ; current length of command


	OS_STACK_SAVE  		= $0E00			; 4 bytes used in secondary ROM
	SHELL_STACK_SAVE  	= $0E04			; 4 bytes used in C shell

	;SYSCALL_PARAMS   = $0F00		; this is in ./Common/COP_Commands.asm

	sysptr = $1000
	sysroutine = $1004

	SD_Sector_Data = $1200	; 512 bytes for SD card sector data (to $13FF)
	SD_LBA = $1400			; 4 bytes for LBA address to read/write on SD card
	SD_cmd_buffer     = $1404   ; 6 bytes for the active command



; DON'T GO PAST $17FF !!! The Shell starts with $1800.