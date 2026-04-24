.setting "HandleLongBranch", true
.setting "RegA16", true
.setting "RegXY16", true

; To do - 	Move items out of ZP that don't need to be there. Reserve ZP for operations that require it
;			or benefit (performance)from the lower instruction cycles.
;

; ======== OPERATING SYSTEM ZERO PAGE VARIABLES ==== 0000:00FF =====================================
	; ********** COPROCESSOR COP ******************** **************************************
		
		; unused $00 to $0F

		sig_ptr 					.equ 	$10		; 3 bytes         	; 24-bit pointer storage for COP
		; unused byte
		sig_val 					.equ 	$14		; 1 byte        	; 8-bit command storage
		; unused byte
		tmp 						.equ	$16		; 4 bytes         	; temporary storage for COP operand address calculation
		
		; unused $1A to $1F

	; ********** SPI **********************************************************************
		SDCard_Command_Address		.equ 	$40 	; 2 bytes 			; Pointer to Command
		SPI_Timer               	.equ 	$42		; 2 bytes 			; Delay timer
		SDCard_Buffer_Ptr 			.equ 	$44		; 2 bytes 			; Pointer to RAM buffer
		SDCard_ReadCounter			.equ 	$46		; 2 bytes 			; Counting bytes read from SD card		

	; ********** TEMP CALCS ****************************************************************
		TempCalcs					.equ	$48		; 6 bytes
		; unused 2 bytes
	
	; ********** ILI LCD ************************************************************
		ili_setaddrwindow_startX	.equ 	$50		; 2 bytes
		ili_setaddrwindow_startY	.equ 	$52		; 2 bytes
		ili_setaddrwindow_endX		.equ 	$54		; 2 bytes
		ili_setaddrwindow_endY		.equ 	$56		; 2 bytes
		ili_color					.equ 	$58		; 2 bytes
		ili_VIA1_PORTB_SHADOW 		.equ 	$5A		; 2 bytes
		ili_rect_width				.equ 	$5C		; 2 bytes
		ili_rect_height				.equ 	$5E		; 2 bytes
		ili_ship_sprite_x          	.equ 	$60		; 2 bytes    		; top-left X of ship
		ili_ship_sprite_y          	.equ 	$62		; 2 bytes   		; top-left Y of ship
		ili_ship_cur_x             	.equ 	$64		; 2 bytes    		; current X inside row loop
		ili_ship_cur_y             	.equ 	$66		; 2 bytes    		; current Y inside row loop
		ili_ship_move_source       	.equ 	$68		; 2 bytes    		; pointer into ROM sprite data
		ili_ship_row_count         	.equ 	$6A		; 2 bytes    		; 32 rows
		ili_ship_col_count         	.equ 	$6C		; 2 bytes    		; 32 columns
		ili_ship_sprite_byte       	.equ 	$6E		; 2 bytes    		; current sprite byte
		ili_ship_rgb332_tmp			.equ 	$70		; 2 bytes	
		ili_ship_rgb565_tmp			.equ 	$72		; 2 bytes	
		ili_char_color              .equ 	$74		; 2 bytes
		ili_current_x               .equ 	$76		; 2 bytes
		ili_current_y               .equ 	$78		; 2 bytes
		ili_char_ptr_l              .equ 	$7A		; 2 bytes
		ili_char_ptr_h              .equ 	$7C		; 2 bytes
		ili_temp_math               .equ 	$7E		; 2 bytes
		ili_temp_byte               .equ 	$80		; 2 bytes
		ili_offset_x                .equ 	$82		; 2 bytes
		ili_offset_y                .equ 	$84		; 2 bytes

		; unused 10 bytes

	; ********** Randomizer ********************************************************
		RNG_SEED    				.equ 	$90     ; 2 bytes			; seed
		RNG_MAX     				.equ 	$92     ; 2 bytes			; holds incoming max
		temp_rng					.equ 	$94		; 2 bytes

	; ********** TONE GENERATOR ********************************************************

		; Div32by16 (ToneGen.asm)
		FreqVal                 	.equ 	$96   	; 2 bytes
		Dividend  			    	.equ 	$98   	; 2 bytes
		Divisor   					.equ 	$9C   	; 2 bytes
		Remainder 					.equ 	$9E   	; 2 bytes

	; ********** Hex loader ********************************************************
		; used in secondary ROM
		hex_target_bank:			.equ	$A0		; 2 byte
		hex_ptr_addr:   			.equ	$A2		; 2 bytes
		hex_ptr_bank:   			.equ	$A4		; 2 byte
		hex_temp_byte:  			.equ	$A6		; 2 byte
		hex_byte_count: 			.equ	$A8		; 2 byte
		hex_record_type:			.equ	$AA		; 2 byte
		hex_addr_hi:    			.equ	$AC		; 2 byte
		hex_addr_lo:    			.equ	$AE		; 2 byte
		hex_checksum:				.equ	$B0		; 2 byte
        hex_entry_ptr:      		.equ 	$B2     ; 3 bytes 			; 24-bit entry point

		; unused 1 byte

	; ********** SPEECH ********************************************************

		SP0256_StringPtr			.equ 	$B6		; 4					; current allophone pointer to be sent to SP0256 - only need 3 bytes

	

		; unused 6 bytes

	; ********** Extended SRAM POST Test ************************************************
		TestBankPointer:    		.equ 	$C0     ; 4 bytes 		; Address Low, High, Bank - really only need 3 bytes
		TestBank:           		.equ 	$C4     ; 2 byte 			; Counter - really only need 1 byte
		TestPattern:        		.equ 	$C6     ; 2 bytes 		; Pattern being tested

	; ********** RTC DATE TIME ************************************************
		
		RTC_HRS 					.equ 	$C8		; 1 byte
		RTC_MIN 					.equ 	$C9		; 1 byte
		RTC_SEC 					.equ 	$CA		; 1 byte
		RTC_DAY  					.equ 	$CB		; 1 byte
		RTC_MONTH 					.equ 	$CC		; 1 byte
		RTC_YEAR  					.equ 	$CD		; 1 byte

		; unused 2 bytes

	; ********** PS/2 KEYBOARD *************************************************************
		PS2_DataByte    			.equ    $D0   	; 2 				; working byte (pseudo shift register)
		KeyBuf_Head     			.equ	$D2   	; 2					; write location
		KeyBuf_Tail     			.equ	$D4   	; 2					; read location
		kb_flags					.equ	$D6   	; 2					; PS2 keyboard flags (down, shift, ...)
		Str_ptr						.equ    $D8   	; 2					; pointer to a string

		; unused 6 bytes

		KeyBuf          			.equ	$E0   	; 32  				; ring buffer $E0-$FF
										   ;$F0

	; ********** MOUSE *******************************************************************
		temp_val					.equ	$F0		; 1 byte
		parity_count				.equ	$F1		; 1 byte
		temp_mouse_byte				.equ	$F2		; 1 byte
		mouse_state					.equ	$F3		; 1 byte
		mouse_buffer				.equ	$F4		; 3 bytes

	; ********** COMMAND BUFFER ************************************************

		cmd_buffer      			.equ 	$0200   ; 64     			; 64-byte command string (OS)
		cmd_index       			.equ 	$0240   ;      				; current length of command

		OS_STACK_SAVE  				.equ 	$0E00	; 4 bytes 			; used in secondary ROM
		; SHELL_STACK_SAVE  			.equ 	$0E04	; 4 bytes 			; used in C shell

							; 256 bytes 0f00-0FFF used for SYSCALL PARAMS in secondary ROM
		;SYSCALL_PARAMS   .equ $0F00		; this is in ./Common/COP_Commands.asm
		SYSCALL_PARAMS   			.equ 	$0F00

		sysptr 						.equ 	$1000
		sysroutine 					.equ 	$1004

		SD_Sector_Data 				.equ 	$1200	; 512 bytes for SD card sector data (to $13FF)
		SD_LBA 						.equ 	$1400	; 4 bytes for LBA address to read/write on SD card
		SD_cmd_buffer     			.equ 	$1404   ; 6 bytes for the active command

		Copy_Temp_Buffer			.equ 	$1500	; 512 bytes for temporary buffer during file copy operations (to $16FF)


; DON'T GO PAST $17FF !!! The Shell starts with $1800.
; For $Dxxx registers, see EQUs.asm


; ********* 07:0000 *************************
SHELL_STACK_SAVE  					.equ 	$0000	; 4 bytes 			; used in C shell (higher bank)

TILE_SAVE_32						.equ 	$1000	; 1024 bytes 			; used in tile saving (through $07:13FF)
TILE_SAVE_16						.equ 	$1100	; 256 bytes 			; used in tile saving (through $07:14FF)

