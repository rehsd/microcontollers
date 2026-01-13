
; File: 65265_AV.asm
; 09 January 2026

; ************** CONFIG****************************************
; WDC W65C265SXB with 3.6864 MHz PHI2
; No external VIA, keyboard, LCD
;
; *************************************************************

; ************** TO DO ****************************************
; Check monitor ROM version
; Connect external LED to P64 & P65 for main loop monitoring
; Direction set of ports 4 and 5
; Connect PIB signals to breadboard with resistors
; 8-bit A for PIB routines
;
; *************************************************************

; ********** IMPORTANT NOTES **********************************
; -Default is native mode, 16-bit A/X/Y. 
;  All routines should assume this and maintain on return.
; -Assembled with WDC816AS from WDC Tools
; *************************************************************


     PW 128         ;Page Width (# of char/line) 
     PL 60          ;Page Length for HP Laser
     INCLIST ON     ;Add Include files in Listing

				;*********************************************
				;Test for Valid Processor defined in -D option
				;*********************************************
	IF	USING_816
	ELSE
		EXIT         "Not Valid Processor: Use -DUSING_02, etc. ! ! ! ! ! ! ! ! ! ! ! !"
	ENDIF

;****************************************************************************
;****************************************************************************
; End of testing for proper Command line Options for Assembly of this program
;****************************************************************************
;****************************************************************************

			title  "1602_LCD_PS2KBD.asm"
			sttl


; bgnpkhdr
;***************************************************************************
;  FILE_NAME: 1602_LCD_PS2KBD.asm
;
;  TITLE: W65C265S_LCD_KBD_TEST
;
;  DESCRIPTION: Test of 1602 LCD and PS2/2 keyboard on 65265 board
;
;
;
;  DEFINED FUNCTIONS:
;          badVec
;                   - Process a Bad Interrupt Vector - Hang!
;
;  AUTHOR: rehsd
;
;  CREATION DATE: December 6, 2025
;
;  REVISION HISTORY
;     Name           Date         Description
;     ------------   ----------   ------------------------------------------------
;     rehsd		  	 12/06/2025   1.00 Initial
;
;
; NOTE:
;    Change the lines for each version - current version is 1.00
;    See - 
;         title  "1602 LCD demo for 65265 board"
;
;
;***************************************************************************
;endpkhdr

;***************************************************************************
;                               Local Constants
;***************************************************************************

;; IO Ports 
  PCS7: 			equ $DF27 ;; Port 7 Chip Select

  PDD6: 			equ $DF26 ;; Port 6 Data Direction Register
  PDD5: 			equ $DF25 ;; Port 5 Data Direction Register
  PDD4: 			equ $DF24 ;; Port 4 Data Direction Register
  PDD3:				equ $DF07 ;; Port 3 Data Direction Register
  PDD2:				equ $DF06 ;; Port 2 Data Direction Register
  PDD1:				equ $DF05 ;; Port 1 Data Direction Register
  PDD0:				equ $DF04 ;; Port 0 Data Direction Register

  ; PIBER:			equ $DF79 ;; parallel port interface

  PD7:  			equ $DF23 ;; Port 7 Data Register
  PD6:  			equ $DF22 ;; Port 6 Data Register
  PD5:  			equ $DF21 ;; Port 5 Data Register
  PD4:  			equ $DF20 ;; Port 4 Data Register
  PD3:				equ $DF03 ;; Port 3 Data Register
  PD2:				equ $DF02 ;; Port 2 Data Register
  PD1:				equ $DF01 ;; Port 1 Data Register
  PD0:				equ $DF00 ;; Port 0 Data Register
  
;; Control and Status Register Memory Map
  TIER:  			equ $DF46 ;; Timer Interrupt Enable Register
  TIFR:  			equ $DF44 ;; Timer Interrupt Flag Register
  TER:  			equ $DF43 ;; Timer Enable Register
  TCR:  			equ $DF42 ;; Timer Control Register
  SSCR:  			equ $DF41 ;; System Speed Control Register
  BCR:  			equ $DF40 ;; Bus Control Register
  EIER:  			equ $DF47 ;; Edge Interrupt Enable Register		!!!!!!!!!!!!!!!!!!!!!! data sheet pg 14, Monitor ROM code, sample projects
  EIFR:  			equ $DF45 ;; Edge Interrupt Flag Register		data sheet pg 14, Monitor ROM code, sample projects
  ;EIER:  			equ $DF45 ;; Edge Interrupt Enable Register		data sheet pg 24 - likely incorrect
  ;EIFR:  			equ $DF47 ;; Edge Interrupt Flag Register		data sheet pg 25 - likely incorrect

  PE56ENABLE:  		equ %00000001		;$01
  NE57ENABLE:  		equ %00000010		;$02
  PE60ENABLE:  		equ %00000100		;$04
  PWMENABLE:   		equ %00001000		;$08
  NE64ENABLE:  		equ %00010000		;$10	;*****************************************
  NE66ENABLE:  		equ %00100000		;$20
  PIBIRQENABLE:		equ %01000000		;$40
  IRQENABLE:		equ %10000000		;$80

;; On Chip RAM
  OCRAM_BASE: equ $DF80 ;; RAM Registers
  
  IRQHandlerBank: EQU $00	; IRQHandler / $10000   ; divide by 65536 to get bank

; 1602 LCD
  E:   			equ %01000000
  RW:  			equ %00100000
  RS:  			equ %00010000

; PS/2 Keyboard
  KBD_READY:	equ %00000001
  RELEASE:		equ %00000010
  SHIFT:        equ %00000100

  	;************************* VIAs *************************************
    ;VIA Registers
    VIA_PORTB: 		equ $00		; Port B data register
    VIA_PORTA: 		equ $01		; Port A data register
    VIA_DDRB:  		equ $02		; Port B data direction register
    VIA_DDRA:  		equ $03		; Port A data direction register
    VIA_T1C_L: 		equ $04		; T1 low-order latches (write) / counter
    VIA_T1C_H: 		equ $05		; T1 high-order counter
    VIA_T1L_L: 		equ $06		; T1 low-order latches
    VIA_T1L_H: 		equ $07		; T1 high-order latches
    VIA_T2C_L: 		equ $08		; T2 low-order latches (write) / counter
    VIA_T2C_H: 		equ $09		; T1 high-order counter
    VIA_SR:    		equ $0A		; Shift register
    VIA_ACR:   		equ $0B		; Auxiliary control register
    VIA_PCR:   		equ $0C		; Peripheral control register
    VIA_IFR:   		equ $0D		; Interrupt flag register
    VIA_IER:   		equ $0E		; Interrupt enable register
	VIA_PORTA_NH:	equ $0F		; Port A data register without handshake

    ;VIA0 Address - %11000000:00000000:00000000 - $C0:0000
    VIA0_ADDR:  	equ $C00000
    VIA0_PORTB: 	equ $C00000		; VIA1_ADDR + VIA_PORTB
    VIA0_PORTA: 	equ $C00001		; VIA1_ADDR + VIA_PORTA
    VIA0_DDRB:  	equ $C00002		; VIA1_ADDR + VIA_DDRB
    VIA0_DDRA:  	equ $C00003		; VIA1_ADDR + VIA_DDRA
	VIA0_T1CL:  	equ $C00004		; VIA1_ADDR + VIA_T1C_L
	VIA0_T1CH:  	equ $C00005		; VIA1_ADDR + VIA_T1C_H
	VIA0_T1LL:  	equ $C00006		; VIA1_ADDR + VIA_T1L_L
	VIA0_T1LH:  	equ $C00007		; VIA1_ADDR + VIA_T1L_H
	VIA0_T2CL:  	equ $C00008		; VIA1_ADDR + VIA_T2C_L
	VIA0_T2CH:  	equ $C00009		; VIA1_ADDR + VIA_T2C_H
	VIA0_SR:    	equ $C0000A		; VIA1_ADDR + VIA_SR
	VIA0_ACR:   	equ $C0000B		; VIA1_ADDR + VIA_ACR
	VIA0_PCR:   	equ $C0000C		; VIA1_ADDR + VIA_PCR
    VIA0_IFR:   	equ $C0000D		; VIA1_ADDR + VIA_IFR
    VIA0_IER:   	equ $C0000E		; VIA1_ADDR + VIA_IER

	;VIA1 Address - %11010000:00000000:00000000 - $D0:0000
    ;VIA1_ADDR:  	equ $D00000
    ;VIA1_PORTB: 	equ $D00000		; VIA2_ADDR + VIA_PORTB
    ;VIA1_PORTA: 	equ $D00001		; VIA2_ADDR + VIA_PORTA
    ;VIA1_DDRB:  	equ $D00002		; VIA2_ADDR + VIA_DDRB
    ;VIA1_DDRA:  	equ $D00003		; VIA2_ADDR + VIA_DDRA
    ;VIA1_IFR:   	equ $D0000D		; VIA2_ADDR + VIA_IFR
    ;VIA1_IER:   	equ $D0000E		; VIA2_ADDR + VIA_IER
	;************************* /VIAs *************************************

	;************************* VGA ***************************************
	VRAM_ADDR_BASE: equ $EA0000
	VRAM_ADDR_MAX:	equ $EBFFFF
	
	;ASCII_CHARMAP	equ %11100000
    PIXEL_COL1:     equ %10000000
    PIXEL_COL2:     equ %01000000
    PIXEL_COL3:     equ %00100000
    PIXEL_COL4:     equ %00010000
    PIXEL_COL5:     equ %00001000
	;************************* /VGA ***************************************


  	;************************* UART3 *************************************
	ACSR3:			equ $DF76    	; UART3 control/status
	ARTD3:			equ $DF77     	; UART3 data register (read=RX, write=TX)

	UIER:  			equ $DF49 		; UART Interrupt Enable Register
	UIFR:  			equ $DF48 		; UART Interrupt Flag Register		!!!!!!!!!!!!!!!!!!!!!! data sheet pg 27 lists $DF47! so many problems with the data sheet!
	; UIFR bits: 					; data sheet pg 27
	U3RF:			equ %01000000	; receive full
	U3TF:			equ %10000000	; transmit full ??? seems to be, but documentation isn't consistent

	; Timer 3 Registers (for baud rate)
	T3LL:			equ $DF56     	; Timer 3 low latch
	T3LH:			equ $DF57     	; Timer 3 high latch
  	;************************* /UART3 ************************************


	LONGI	ON
	LONGA	ON

	.sttl "W65C265S Demo Code"
	.page

;***************************************************************************
;                    Code Section
;***************************************************************************
; $0000:003F 	'265 critical pointers 							- stay out
; $0040:00BF	Mensch monitor RAM								- stay out
; $00C0:01BF	** Available internal user RAM
; $01C0:01FF	Mensch monitor stack space in internal RAM		- stay out
; $0200:7FFF	** External user memory


DIRECTPAGE SECTION 	; OFFSET $0000	; can't use OFFSET here!
	ORG $00C0		; $00C0:01BF internal user RAM
	vidpageVRAM: 			.BLKB 	4		; pointer - current VRAM location
	char_vp:                .BLKB 	4     	; pointer - position for character to be drawn
	PS2_BitIndex:    		.BLKB 	2 		; 0..10
	PS2_DataByte:    		.BLKB 	2 		; working byte (pseudo shift register)
	KeyBuf_Head:     		.BLKB 	2		; write location
	KeyBuf_Tail:     		.BLKB 	2		; read location
	TempBit:	     		.BLKB 	2		; PS2 keyboard shifting support
	TempScan:    			.BLKB 	2		; PS2 keyboard shifting support
	kb_flags:				.BLKB 	2		; PS2 keyboard flags (down, shift, ...)
	Str_ptr:				.BLKB 	2		; pointer to a string
	KeyBuf:          		.BLKB 	32  	; 16‑word ring buffer


	; ********** VGA ****************************************************************
		color:                   	.BLKB 2
		row:                     	.BLKB 2
		fill_region_start_x:     	.BLKB 2     ;Horizontal pixel position, 0 to 319
		fill_region_start_y:     	.BLKB 2     ;Vertical pixel position,   0 to 239
		fill_region_end_x:       	.BLKB 2     ;Horizontal pixel position, 0 to 319
		fill_region_end_y:       	.BLKB 2     ;Vertical pixel position,   0 to 239
		fill_region_color:       	.BLKB 2     ;Color for fill,            0 to 255  
		jump_to_line_y:          	.BLKB 2     ;Line to jump to,           0 to 239
		col_end:                 	.BLKB 2     ;Used in FillRegion to track end column for fill
		rows_remain:             	.BLKB 2     ;Used in FillRegion to track number of rows to process
		char_color:              	.BLKB 2
		char_y_offset:           	.BLKB 2
		char_y_offset_orig:      	.BLKB 2
		charPixelRowLoopCounter: 	.BLKB 2     ;character pixel row loop counter
		char_current_val:        	.BLKB 2
		char_from_charmap:       	.BLKB 2     ;stored current char from appropriate charmap
		char_vp_x:               	.BLKB 2
    	char_vp_y:               	.BLKB 2
		message_to_process:      	.BLKB 2
		xtmp:						.BLKB 2                    
		tmpHex:						.BLKB 2
		move_size:               	.BLKB 2
    	move_source:             	.BLKB 2
    	move_dest:               	.BLKB 2
    	move_counter:            	.BLKB 2
    	move_frame_counter:      	.BLKB 2
	; ********** /VGA ***************************************************************


	; ********** ILI LCD ************************************************************
		ili_setaddrwindow_startX:		.BLKB 2
		ili_setaddrwindow_startY:		.BLKB 2
		ili_setaddrwindow_endX:			.BLKB 2
		ili_setaddrwindow_endY:			.BLKB 2
		ili_color:						.BLKB 2
		ili_VIA2_PORTB_SHADOW: 			.BLKB 2
		ili_rect_width:					.BLKB 2
		ili_rect_height:				.BLKB 2
	
		ili_ship_sprite_x:          	.BLKB 2    ; top-left X of ship
		ili_ship_sprite_y:          	.BLKB 2    ; top-left Y of ship

		ili_ship_cur_x:             	.BLKB 2    ; current X inside row loop
		ili_ship_cur_y:             	.BLKB 2    ; current Y inside row loop

		ili_ship_move_source:       	.BLKB 2    ; pointer into ROM sprite data
		ili_ship_row_count:         	.BLKB 2    ; 32 rows
		ili_ship_col_count:         	.BLKB 2    ; 32 columns

		ili_ship_sprite_byte:       	.BLKB 2    ; current sprite byte
		ili_ship_rgb332_tmp:			.BLKB 2	
		ili_ship_rgb565_tmp:			.BLKB 2	

	; ********** /ILI LCD ***********************************************************

	ends

VARS SECTION OFFSET $0200
	ends


CODESECT SECTION OFFSET $18000	
		; the system will actually see this as $8000
		db 		"WDC"		; monitor ROM will jump to $8004
		db		#$00		; filler

	START:
		;the monitor rom should be in native mode before getting here

		sei				; turn off interrupts globally

		clc
		xce        		; force native mode, in case not already in native
		rep #$30      	; 16-bit registers, indexers

		cld				; clear decimal mode

    ;lda #$01
    ;sta PIBER

		jsr Configure_MCU
		
		jsr led_on_CS2B			; onboard LED

		; delay to let things settle (e.g., UART)
		ldx #1000			; works well at 8 MHz
		jsr Delay_ms

		jsr Init_UART3


	    jsr init_slave_pib

		
		;jsr Init_VGA
		;jsr gfx_ClearScreen
		;jsr gfx_TestPattern
		;jsr gfx_TestPattern_Animated_Ship
		;jsr ILI_Init
		;jsr ILI_Test_Pattern
		;jsr ILI_Animated_Ship
		

		cli 			; interrupt enable

		;fall into main

	MAIN:

		jsr p63_toggle

		main_cont:
			bra MAIN
	
	Configure_MCU:
		; Configure MPU basics, assuming coming from WDC Mensch monitor with external ROM jump ('WDC') on startup
		
		pha
		sep #$20		; 8-bit A
		LONGA OFF
		
		LDA #$C9     ;11001001		ENABLE EXT ROM, NMI, ICE & EXT BUS
		STA BCR
		LDA #$BB     ;10111011		ENABLE CS7, CS5, CS4, CS3, CS1, & CS0
		STA PCS7

		; MPU boots to internal clock, switch to FCLK input
		lda #%11111011		; set everything to use FCLK full speed - see pg. 237 of '265 datasheet
		sta SSCR
		
		lda #$00
		sta UIER    ; disable all UART interrupts
		sta TIER    ; disable all timer interrupts
		sta EIER    ; disable all edge interrupts

		lda #$FF
		sta UIFR    ; clear all UART flags (write‑1‑to‑clear)
		sta TIFR    ; clear all timer flags
		sta EIFR    ; clear all edge flags

		; Configure NE64 and IRQB interrupts
			 ;lda EIER
			 ;ora #NE64ENABLE		; enable edge interrupts
			 ;ora #IRQENABLE		; enable IRQB
			 ;ora #PIBIRQENABLE		; enable PIB IRQ (P42)
			lda #%01010000
			 sta EIER


		; debug LEDs
		;lda PDD6          ; pd63 and pd65 for LED outputs, pd64 for PIB interrupt input
		;ora #%00101000
		lda #%00101000
		sta PDD6

		LONGA ON
		rep #$20	; 16-bit A
		pla
		rts

	HALT:
		jsr p63_toggle	; debug signal to verify with oscilliscope that main is loop (and to check the speed of loop)

		jmp HALT

	Init_UART3:
		; caller guarantees A/X are 16-bit on entry
		pha
		sep #$20	; 8-bit A
		LONGA OFF

		; Use Timer 3 for UART3
		lda TCR
		and #%01111111      ; TCR7 = 0 → Timer 3
		sta TCR

		; 115200 bps @ 3.6864 MHz
		LDA #0
		STA T3LH
		LDA #1
		STA T3LL

		; Enable Timer 3
		lda TER
		ora #%00001000      ; TER3 = 1
		sta TER

		; UART3: 8-bit, no parity, RX+TX enable
		lda #%00100101
		sta ACSR3		; 8-bit, no parity, RX enable, TX enable

		; Enable UART3 RX interrupt (UIER bit 6)
		lda UIER
		ora #%01000000      ; set U3RE
		sta UIER

		lda #<STR_INIT_COMPLETE
		sta Str_ptr
		lda #>STR_INIT_COMPLETE
		sta Str_ptr+1
		jsr uart3_puts

		LONGA ON
		rep #$20	; 16-bit A
		pla
		rts

	uart3_tx:
		; caller guarantees A is 8-bit on entry
		LONGA OFF
		pha                 ; save the byte to send
		TX_WAIT:
			lda UIFR
			and #U3TF			; !!! no such way to check transmit full?! see pg. 27 of datasheet -- or is %1000000 TF and data sheet is incorrect?
			beq TX_WAIT
			pla                 ; restore the byte to send
			sta ARTD3
			LONGA ON
			rts

	print_char_serial:
		; caller guarantees A is 8-bit on entry
		jsr uart3_tx
		rts

	Delay_ms:
		; x as number of milliseconds (approximate), given 8 Mhz PHI2
		; caller guarantees A/X are 16-bit on entry
		php                 ; save P
		sei                 ; disable interrupts while P is on stack
		phx                 ; save X (16-bit)
		phy                 ; save Y (16-bit)
    	rep #$10            ; ensure X/Y are 16-bit

		DL_outer:
			ldy #$0c00          ; inner = 65306 decimal (0xFFEA)
		DL_inner:
			dey
			bne DL_inner
			dex
			bne DL_outer

			ply                 ; restore Y
			plx                 ; restore X
			plp                 ; restore P (restores I and original M/X)
			rts

	crlf_serial:
		; caller guarantees A is 8-bit on entry
		pha
		LONGA OFF
		lda #$0d        ; CR
		jsr uart3_tx

		lda #$0a        ; LF
		jsr uart3_tx
		LONGA ON
		pla
		rts

	print_hex_serial:
		; ---------------------------------------------------------
		; hexprint
		;   in:   a = byte to print
		;   out:  sends two ascii hex chars via uart3_tx
		;   uses: a, x
		;   preserves cpu mode
		; ---------------------------------------------------------
		php
		sep #$20        ; force 8-bit a
		LONGA OFF

		phx
		pha


		tax             ; save original byte in x

		; ----- high nibble -----
		txa             ; restore original byte
		lsr a
		lsr a
		lsr a
		lsr a
		jsr nibble_to_ascii
		jsr uart3_tx

		; ----- low nibble -----
		txa             ; restore original byte
		and #$0f
		jsr nibble_to_ascii
		jsr uart3_tx

		pla
		plx
		plp
		rts

	nibble_to_ascii:
		; ---------------------------------------------------------
		; nibble_to_ascii
		;   in:  a = 0..15
		;   out: a = ascii '0'..'9' or 'a'..'f'
		; ---------------------------------------------------------
		cmp #10
		bcc nta_digit

		; a >= 10 → 'a'..'f'
		clc                 ; ensure no +1 from carry
		adc #$57            ; 'a' - 10
		rts

		nta_digit:
			clc
			adc #$30            ; '0'
			rts

	uart3_puts:
		;---------------------------------------
		; Send zero-terminated string at (PTR)
		;---------------------------------------
		; caller guarantees A is 8-bit on entry
		pha
		phy
		LONGA OFF
		ldy #0              ; index into string

		puts_loop:
			lda (Str_ptr),Y         ; get next character
			beq puts_done       ; zero terminator ends string

			jsr uart3_tx        ; send it
			iny                 ; next char
			bne puts_loop       ; continue until Y wraps (unlikely)

			; If Y wrapped, bump high byte of pointer
			inc Str_ptr+1
			bra puts_loop

		puts_done:
			LONGA ON
			ply
			pla
			rts

	uart3_puts_crlf:
		jsr uart3_puts
		lda #$0D
		jsr uart3_tx
		lda #$0A
		jsr uart3_tx
		rts

	Init_VIA:
		; Jan 6, 2026 - PIB setup
		; VIA0 - keyboard & 1602 LCD
		pha
		sep #$20		; 8-bit A
		LONGA OFF

		; VIA0	; PS/2 keyboard input & 1602 LCD output
		; Set(1)/Clear(0)|Timer1|Timer2|CB1|CB2|ShiftReg|CA1|CA2


		; Clear Timer 1
		lda >VIA0_T1CL

		; Clear Timer 2
		lda >VIA0_T2CL

		; Clear edge interrupts
		lda >VIA0_PORTA
		lda >VIA0_PORTB

		; Clear Port A/B edge interrupts
		
		lda >VIA0_PORTA
		nop nop nop nop
		lda >VIA0_PORTB
		nop nop nop nop

		; Set CA1 to positive (rising) edge
		; lda  VIA0_PCR
		lda #%00000001      ; set bit 0 = 1 → CA1 positive edge
		sta  >VIA0_PCR
		nop nop nop nop
		
		lda #%01111111	        ; Disable all interrupts
		sta >VIA0_IER			; Write to interrupt enable register
		lda #%10000010			; Enable CA1 interrupt	
		sta >VIA0_IER			; Write to interrupt enable register
		nop nop nop nop

		lda #%00000000          ; 0=input, 1=output
		sta >VIA0_DDRA          ; Set all pins on port B to input
		nop nop nop nop
		lda #%11111111          ; 0=input, 1=output
		sta >VIA0_DDRB          ; Set all pins on port B to output
		nop nop nop nop

		
		;lda #%10101010
		;sta >VIA2_PORTA
		;sta >VIA2_PORTB

		LONGA ON
		rep #$20		; 16-bit A
		pla
		rts

	key_pressed:
		php
		sep #$30		; 8-bit A/X/Y
		LONGA	OFF
		LONGI	OFF

		phx
		phy
		pha

		lda KeyBuf_Tail
		tax
		lda KeyBuf, x
		
		; -----------------------------
		; ESCAPE KEY CHECK
		; -----------------------------
		cmp #$1B               	; ESC = ASCII 27
		beq do_clear_screen
			; otherwise print normally
			jsr print_char_lcd
	
			;rep #$30		; 16-bit A/X/Y
			;jsr print_char_vga
			;sep #$30		; 8-bit A/X/Y

			bra key_out

		do_clear_screen:
			jsr lcd_clear
        	
			;rep #$30		; 16-bit A/X/Y
			;jsr gfx_ClearScreen
			;sep #$30		; 8-bit A/X/Y
        	
			bra key_out

		key_out:
			jsr keyboard_inc_rptr

			LONGA ON
			LONGI ON
			;rep #$30		; 16-bit A/X/Y
			pla
			ply
			plx
			plp
			rts

	Init_Keyboard:
		; caller guarantees A/X are 16-bit on entry
		stz PS2_BitIndex
		stz PS2_DataByte
		stz KeyBuf_Head
		stz KeyBuf_Tail
		stz TempBit
		stz TempScan
		stz kb_flags

		ldx #0
        lda #$0000
		clear_keybuf:
			sta KeyBuf,x
			inx
			inx
			cpx #32
			bne clear_keybuf


		rts

	Init_LCD:
		pha
		sep #$30		; 8-bit A/X/Y
		LONGA OFF
		LONGI OFF

		jsr lcd_init
		jsr lcd_init	; multiple calls helps on cold start vs. reset
		jsr lcd_init
		
		lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font     ;See page 24 of HD44780.pdf
		jsr lcd_instruction
		;call again for higher clock speed setup
		;lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font     ;See page 24 of HD44780.pdf
		;jsr lcd_instruction

		nop nop nop nop

		lda #%00001110 ; Display on; cursor on; blink off
		jsr lcd_instruction
		
		lda #%00000110 ; Increment and shift cursor; don't shift display
		jsr lcd_instruction
		
		lda #%00000001 ; Clear display
		jsr lcd_instruction


		; temp - second time for cold power on improvement - testing
		lda #%00001110 ; Display on; cursor on; blink off
		jsr lcd_instruction
		lda #%00000001 ; Clear display
		jsr lcd_instruction

		LONGA ON
		LONGI ON
		rep #$30		; 16-bit A/X/Y
		pla
		rts
		
	led_on_CS2B:
		; turn on P72 (CS2B) LED
		; caller guarantees A/X are 16-bit on entry

		pha
		sep #$20		; 8-bit A
		LONGA OFF

		lda PD7
		and #%11111011   ; clear bit 2 (active-low → ON)
		sta PD7

		LONGA ON
		rep #$20		; 16-bit A

		pla
		rts

	led_off:
		pha
		lda PD7
		ora #%00000100   ; set bit 2 (active-low → OFF)
		sta PD7
		pla
		rts	




	p63_toggle:
		php
		sep #$20		; 8-bit A
		LONGA OFF
		pha

		lda PD6
		eor #%00001000
		sta PD6

		pla
		plp
		LONGA ON
		rts

	p65_toggle:
		php
		sep #$20		; 8-bit A
		LONGA OFF
		pha

		lda PD6
		eor #%00100000
		sta PD6

		pla
		plp
		LONGA ON
		rts

; ************************************************************************************************************
; ******************************* 1602 LCD & PS2 Keyboard ****************************************************
; ************************************************************************************************************
	LONGA OFF
	LONGI OFF

	lcd_wait:
		pha
		lda #%11110000  ; LCD data is input
		sta >VIA0_DDRB ; was PDD5
	lcdbusy:
		lda #RW
		sta >VIA0_PORTB ; was PD5	
		lda #(RW|E)                           
		sta >VIA0_PORTB	
		lda >VIA0_PORTB			; Read high nibble
		pha             ; and put on stack since it has the busy flag
		lda #RW
		sta >VIA0_PORTB			
		lda #(RW|E)
		sta >VIA0_PORTB			
		lda >VIA0_PORTB			; Read low nibble   
		pla             ; Get high nibble off stack
		and #%00001000                            
		bne lcdbusy                              
		lda #RW
		sta >VIA0_PORTB			
		lda #%11111111  
		sta >VIA0_DDRB	; LCD data is output	
		pla
		rts
		
	lcd_init:
		; caller guarantees A/X are 8-bit on entry
		pha
		lda #%00000010 	; Set 4-bit mode
		sta >VIA0_PORTB
		ora #E
		sta >VIA0_PORTB
		and #%00001111
		sta >VIA0_PORTB
		pla
		rts

	lcd_instruction:
		; caller guarantees A/X are 8-bit on entry
		jsr lcd_wait
		pha
		lsr
		lsr
		lsr
		lsr            	; Send high 4 bits
		sta >VIA0_PORTB			
		ora #E         	; Set E bit to send instruction
		sta >VIA0_PORTB			
		eor #E         	; Clear E bit
		sta >VIA0_PORTB			
		pla
		and #%00001111 	; Send low 4 bits
		sta >VIA0_PORTB			
		ora #E         	; Set E bit to send instruction
		sta >VIA0_PORTB			
		eor #E          ; Clear E bit
		sta >VIA0_PORTB			
		rts
	
	lcd_clear:
		pha
		lda #%00000001 		; Clear display
		jsr lcd_instruction
		pla
		rts
		
	lcd_line2:
		pha
		lda #%10101000 		; put cursor at position 40
		jsr lcd_instruction
		pla
		rts

	print_char_lcd:
		php
		sep #$30		; 8-bit A/X/Y
		pha

		jsr lcd_wait
		pha                                      
		lsr
		lsr
		lsr
		lsr             ; Send high 4 bits
		ora #RS         ; Set RS
		sta >VIA0_PORTB			
		ora #E          ; Set E bit to send instruction
		sta >VIA0_PORTB			
		eor #E          ; Clear E bit
		sta >VIA0_PORTB			
		pla
		pha
		and #%00001111  ; Send low 4 bits
		ora #RS         ; Set RS
		sta >VIA0_PORTB			
		ora #E          ; Set E bit to send instruction
		sta >VIA0_PORTB			
		eor #E          ; Clear E bit
		sta >VIA0_PORTB	
		pla	

		;rep #$30		; 16-bit A/X/Y
		pla
		plp
		rts



push_key:
	; A has ascii code of key
	; caller guarantees A/X are 8-bit on entry
	phx
  	ldx KeyBuf_Head
  	sta KeyBuf, x
  	jsr keyboard_inc_wptr
	plx
  	rts

keyboard_inc_rptr:
	; caller guarantees A/X are 8-bit on entry
	pha
	;sta TempScan            		; save caller A
	lda KeyBuf_Tail
	cmp #15
	bne KIR_DO_INC
	lda #0
	sta KeyBuf_Tail
	sta KeyBuf_Tail+1
	bra KIR_DONE

	KIR_DO_INC:
			lda KeyBuf_Tail
			clc
			adc #1
			sta KeyBuf_Tail
			lda #0
			sta KeyBuf_Tail+1

	KIR_DONE:
			pla
			;lda TempScan            ; restore caller A
			rts

keyboard_inc_wptr:
	; caller guarantees A/X are 8-bit on entry
	pha
	;sta TempScan            		; save caller A
	lda KeyBuf_Head
	cmp #15
	bne KIW_DO_INC
	lda #0
	sta KeyBuf_Head
	sta KeyBuf_Head+1
	bra KIW_DONE

	KIW_DO_INC:
			lda KeyBuf_Head
			clc
			adc #1
			sta KeyBuf_Head
			lda #0
			sta KeyBuf_Head+1

	KIW_DONE:
			;lda TempScan            ; restore caller A
			pla
			rts


	LONGA ON
	LONGI ON

; ************************************************************************************************************
; ******************************* /1602 LCD & PS2 Keyboard****************************************************
; ************************************************************************************************************


	;.include "ILI9486.asm"
	.include "PIB_AV.asm"


	; ********** INTERRUPT HANDLERS ************************

	read_key:
		; caller guarantees A/X are 8-bit on entry
		LONGA OFF
		LONGI OFF

		lda PS2_DataByte		; bits already read, full data byte ready	
		cmp #$F0        		; if releasing a key
		beq key_release 		; set the releasing bit
		cmp #$12       			; left shift
		beq shift_down
		cmp #$59       			; right shift
		beq shift_down 
		;cmp #$76				; escape key
		;beq esc
		cmp #$5A				; enter
		beq enter
			; the key isn't one of the special keys above, so proceed with the follow 'else'
			lda kb_flags
			and #SHIFT
			bne Shifted
				; not shifted, continue here
				lda PS2_DataByte
				tax
				lda keymap, x
				jsr push_key		; Push completed byte into buffer
				bra IRQB_Out
			Shifted:
				lda PS2_DataByte
				tax
				lda keymap_shifted, x
				jsr push_key		; Push completed byte into buffer
				bra IRQB_Out
	shift_up:
		lda kb_flags
		eor #SHIFT
		sta kb_flags
		bra IRQB_Out
	shift_down:
		lda kb_flags
		ora #SHIFT
		sta kb_flags
		bra IRQB_Out
	enter:
		jsr lcd_line2
		;rep #$30		; 16-bit
		;jsr gfx_CRLF
		;sep #$30		; 8-bit
		bra IRQB_Out
	key_release:
		lda kb_flags
		ora #RELEASE
		sta kb_flags
		lda kb_flags
		bra IRQB_Out
	LONGA ON
	LONGI ON
		
	
	VIA0_IRQ_Handler:
		; caller guarantees A is 8-bit on entry
		LONGA OFF

		; lda #'>'
		; jsr print_char_serial

		lda >VIA0_PORTA
		sta PS2_DataByte
		; jsr print_hex_serial

		; rep #$20	; 16-bit A
		; jsr p47_toggle
		; sep #$20	; 8-bit A

		lda kb_flags
			AND #RELEASE   ; check if we're releasing a key
			beq read_key   ; otherwise, read the key
				lda kb_flags
				eor #RELEASE   ; flip the releasing bit
				sta kb_flags

				lda PS2_DataByte
				cmp #$12       		; left shift
				beq shift_up
					cmp #$59       	; right shift
					beq shift_up 
		
		bra IRQB_Out

	IRQHandler_IRQB:
        php
		sep #$20
		LONGA OFF
		pha                ; save A

		; do something...
		lda #'Q'
    	jsr print_char_serial

		IRQB_Out:	


		LONGA ON
			pla
			plp		; return to original 16-bit A or 8-bit A state based on caller
			rti

	IRQHandler_UART3_RECV:
		; to do: convert this to 16-bit code
		php
		pha
		phx
		phy
		sep #$20		; 8-bit A
		LONGA OFF

		lda ARTD3          ; UART3 receive data register
		cmp #'h'
		beq DoHelp
		cmp #'H'
		beq DoHelp
		bra Done

		DoHelp:
			lda #<STR_SERIAL_HELP
			sta Str_ptr
			lda #>STR_SERIAL_HELP
			sta Str_ptr+1
			jsr uart3_puts

		Done:

			LONGA ON
			ply
			plx
			pla
			plp
			rti

	IRQHandler:		; $FFE0
		php
		pha                 ; save A

		; shouldn't ever get here...
		;jsr led_toggle
		;lda #'%'
		;jsr print_char_lcd

		; just clear all flags - temporary
		lda #$FF
		sta EIFR
		sta UIFR
		sta TIFR

		pla                 ; restore A
		plp
		rti

	badVec:		; $FFE0 - IRQRVD2(134)
		; to do... add something to log unhandled interrupts
		php
		pha                 ; save A

		; shouldn't ever get here...
		lda #'^'
		jsr print_char_lcd

		; just clear all flags - temporary
		lda #$FF
		sta EIFR
		sta UIFR
		sta TIFR

		pla                 ; restore A
		plp
		rti	ends

IRQHandler_IRQNE64:

    php
    sep #$20           ; 8-bit A
    LONGA OFF
    pha                ; save A


    lda PD5
    jsr print_char_serial

    ; assert PIWEB low
    lda PD4
    and NPIWEB
    sta PD4


    ; wait for PICSB high
    ne64_wait_picsb_high:
        lda PD4
        and #PICSB
        beq ne64_wait_picsb_high

    ; wait for PIIB high
    ne64_wait_piib_high:
        lda PD4
        and #PIIB
        beq ne64_wait_piib_high

        ; release PIWEB high
        lda PD4
        ora #PIWEB
        sta PD4

    ; clear NE64 interrupt source
    lda #NE64ENABLE
    sta EIFR


        pla
        plp		; return to original 16-bit A or 8-bit A state based on caller
        rti
		
ROM_DATA	SECTION


	; ********** STRING DATA *******************************
	STR_INIT_COMPLETE:		.byte 13, 10, "Initialization complete!", 13, 10, "rehsd W65C265S @ 3.6864 MHz - AV MCU", 13, 10,"Welcome!", 0
	STR_PRINT_REG_A:		.byte "Reg A current value (8-bit): $", 0
	STR_SERIAL_HELP:		.byte 	13, 10, "** rehsd 65265 monitor stub **", 13, 10, "   H: Help", 13, 10, "   M: Modify a byte (future)", 13, 10, "   D: Dump a byte (future)", 13, 10, 0

	message1:   .byte "Red 0-7 (3 bits)", 0
	message2:   .byte "Green 0-7 (3 bits)", 0
	message3:   .byte "Blue 0-3 (2 bits)", 0
	message4:   .byte "White (mix of bits per column above)", 0
	message5:   .byte "RGB 0-255 (8 bits)", 0
	message6:   .byte "Dynamically-generated Test Pattern", 0
	message7:   .byte "320x240x1B (RRRGGGBB)  -- 5x7 fixed width font", 0

	hexOutLookup: .byte "0123456789ABCDEF"

	;*********** PS/2 keyboard scan codes -- Set 2 or 3 **********
	keymap:
	.byte "????????????? `?"          ; 00-0F
	.byte "?????q1???zsaw2?"          ; 10-1F
	.byte "?cxde43?? vftr5?"          ; 20-2F
	.byte "?nbhgy6???mju78?"          ; 30-3F
	.byte "?,kio09??./l;p-?"          ; 40-4F
	.byte "??'?[=????",$0a,"]?",$5c,"??"    ; 50-5F     orig:"??'?[=????",$0a,"]?\??"   '\' causes issue with retro assembler - swapped out with hex value 5c
	.byte "?????????1?47???"          ; 60-6F0
	.byte "0.2568",$1b,"??+3-*9??"    ; 70-7F
	.byte "????????????????"          ; 80-8F
	.byte "????????????????"          ; 90-9F
	.byte "????????????????"          ; A0-AF
	.byte "????????????????"          ; B0-BF
	.byte "????????????????"          ; C0-CF
	.byte "????????????????"          ; D0-DF
	.byte "????????????????"          ; E0-EF
	.byte "????????????????"          ; F0-FF
	keymap_shifted:
	.byte "????????????? ~?"          ; 00-0F
	.byte "?????Q!???ZSAW@?"          ; 10-1F
	.byte "?CXDE#$?? VFTR%?"          ; 20-2F
	.byte "?NBHGY^???MJU&*?"          ; 30-3F
	.byte "?<KIO)(??>?L:P_?"          ; 40-4F
	.byte "??",$22,"?{+?????}?|??"          ; 50-5F      orig:"??"?{+?????}?|??"  ;nested quote - compiler doesn't like - swapped out with hex value 22
	.byte "?????????1?47???"          ; 60-6F
	.byte "0.2568???+3-*9??"          ; 70-7F
	.byte "????????????????"          ; 80-8F
	.byte "????????????????"          ; 90-9F
	.byte "????????????????"          ; A0-AF
	.byte "????????????????"          ; B0-BF
	.byte "????????????????"          ; C0-CF
	.byte "????????????????"          ; D0-DF
	.byte "????????????????"          ; E0-EF
	.byte "????????????????"          ; F0-FF

	.include "romData.asm"

	ends



;;-----------------------------
;;
;;		Reset and Interrupt Vectors (define for 265, 816/02 are subsets)
;;		Native mode vectors: see page 10 if the W65C265S datasheet
;;-----------------------------

vIRQNE64	SECTION OFFSET $1FF98	; actually FF98			** NATIVE mode **
	dw	IRQHandler_IRQNE64				; $FF98 - IRNE64 - NE64 Edge Interrupt
	ends

vIRQPIB	SECTION OFFSET $1FF9C	; actually FF9C			** NATIVE mode **
	dw	IRQHandler_IRQPIB				; $FF9C - IRQ PIB
	ends

vIRQB	SECTION OFFSET $1FF9E	; actually FF9E			** NATIVE mode **
	dw	IRQHandler_IRQB				; $FF9E - IRQ Level Interrupt
	ends

vUART3_RECV	SECTION OFFSET $1FFAC	; actually FFAC		** NATIVE mode **
	dw	IRQHandler_UART3_RECV		; $FFAC - UART 3 receive
	ends

vSTD	SECTION OFFSET $1FFE0	; actdually FFE0
;					;65C816 Interrupt Vectors
;					;Status bit E = 0 (Native mode, 16 bit mode)
	dw	badVec		; $FFE0 - IRQRVD4(816)
	dw	badVec		; $FFE2 - IRQRVD5(816)
	dw	badVec		; $FFE4 - COP(816)
	dw	badVec		; $FFE6 - BRK(816)
	dw	badVec		; $FFE8 - ABORT(816)		; NE64 native '265 overlay?
	dw	badVec		; $FFEA - NMI(816)
	dw	badVec		; $FFEC - IRQRVD(816)
	dw	badVec		; $FFEE - IRQ(816)
;					;Status bit E = 1 (Emulation mode, 8 bit mode)
	dw	badVec		; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
	dw	badVec		; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
	dw	badVec		; $FFF4 - COP(8 bit Emulation)
	dw	badVec		; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
	dw	badVec		; $FFF8 - ABORT(8 bit Emulation)
;
;					; Common 8 bit Vectors for all CPUs
	dw	badVec		; $FFFA -  NMIRQ (ALL)
	dw	START		; $FFFC -  RESET (ALL)
	dw	IRQHandler	; $FFFE -  IRQBRK (ALL)
;		
	ends
		end 


; *********** MISC NOTES *******************************************
; WDC816AS assembler notes
; 	Caution: 'POINTER + #' does not work -- must use 'POINTER+#'.
;			Example: vidpageVRAM+2
;	Caution: mvn seems to expect parameters backwards from my other assembler
;			Other: 			mvn target, source
;			WDC816AS: 		mvn source, target