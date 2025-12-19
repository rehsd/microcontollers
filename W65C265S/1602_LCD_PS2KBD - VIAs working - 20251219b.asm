; ************** TO DO ****************************************
;
; -Lots of cleanup for 8bit vs 16 bit A, X Registers
; -Expand keyboard functionality (non-ascii keys)
; -Filter out of first PS2 key on power on / reset (hardware reset circuit causes a spurious interrupt)
;
; *************************************************************

; File: 1602_LCD_PS2KBD.asm
; 12/15/2025

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
  PDD3:				equ $DF07	;; Port 3 Data Direction Register
  PDD2:				equ $DF06	;; Port 2 Data Direction Register
  PDD1:				equ $DF05	;; Port 1 Data Direction Register
  PDD0:				equ $DF04	;; Port 0 Data Direction Register

  PIBER:			equ $DF79 ;; parallel port interface

  PD7:  			equ $DF23 ;; Port 7 Data Register
  PD6:  			equ $DF22 ;; Port 6 Data Register
  PD5:  			equ $DF21 ;; Port 5 Data Register
  PD4:  			equ $DF20 ;; Port 4 Data Register
  PD3:				equ $DF03 ;; Port 3 Data Register
  PD2:				equ $DF02 ;; Port 2 Data Register
  PD1:				equ $DF01 ;; Port 1 Data Register
  PD0:				equ $DF00 ;; Port 0 Data Register
  
;; Control and Status Register Memory Map
  UIER:  			equ $DF49 ;; UART Interrupt Enable Register
  UIFR:  			equ $DF48 ;; UART Interrupt Flag Register
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
  ACSR2:			equ $DF74 ;; UART 2 Control/Status Register

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

    ;VIA1 Address - %11000000:00000000:00000000 - $C0:0000
    VIA1_ADDR:  	equ $C00000
    VIA1_PORTB: 	equ $C00000		; VIA1_ADDR + VIA_PORTB
    VIA1_PORTA: 	equ $C00001		; VIA1_ADDR + VIA_PORTA
    VIA1_DDRB:  	equ $C00002		; VIA1_ADDR + VIA_DDRB
    VIA1_DDRA:  	equ $C00003		; VIA1_ADDR + VIA_DDRA
    VIA1_IFR:   	equ $C0000D		; VIA1_ADDR + VIA_IFR
    VIA1_IER:   	equ $C0000E		; VIA1_ADDR + VIA_IER

	;VIA2 Address - %11010000:00000000:00000000 - $D0:0000
    VIA2_ADDR:  	equ $D00000
    VIA2_PORTB: 	equ $D00000		; VIA2_ADDR + VIA_PORTB
    VIA2_PORTA: 	equ $D00001		; VIA2_ADDR + VIA_PORTA
    VIA2_DDRB:  	equ $D00002		; VIA2_ADDR + VIA_DDRB
    VIA2_DDRA:  	equ $D00003		; VIA2_ADDR + VIA_DDRA
    VIA2_IFR:   	equ $D0000D		; VIA2_ADDR + VIA_IFR
    VIA2_IER:   	equ $D0000E		; VIA2_ADDR + VIA_IER

	;************************* /VIAs *************************************

	
;		CHIP	65C02
		LONGI	OFF
		LONGA	OFF

	.sttl "W65C265S Demo Code"
	.page

;***************************************************************************
;                    Code Section
;***************************************************************************

ZEROPAGE SECTION OFFSET $0020
	PS2_BitIndex:    .BLKB 	2 ; 0..10
	PS2_DataByte:    .BLKB 	2  ; working byte (pseudo shift register)

	KeyBuf:          .BLKB 	16  ; 16‑byte ring buffer
	KeyBuf_Head:     .BLKB 	2	
	KeyBuf_Tail:     .BLKB 	2
	
	TempBit:	     .BLKB 	2
	TempScan:    	.BLKB 2

	kb_flags:		.BLKB 1
	ends

VARS SECTION OFFSET $0200
	bargraph1:		.BLKB 1
	bargraph2:		.BLKB 1
	bargraph3:		.BLKB 1
	bargraph4:		.BLKB 1
	ends

CODESECT SECTION OFFSET $18000	
		; the system will actually see this as $8000
		db 		"WDC"		; monitor ROM will jump to $8004
		db		#$00		; filler

	START:
		;the monitor rom should be in native mode (per easysxb m,x values) when jumping to this - need to verify
		;Initialize the stack --assuming processor emulation mode (used in sample code from WDC)
		sei
		;cld					; monitor startup should already have '265 in native mode, with decimal mode and stack setup complete
		;ldx	#$ff
		;txs

		sep #$30				; temporary: 8-bit registerse and indexers (A, X, Y, etc.)

		;lda #$00
		;pha
		;plb			; bank 0 - should already be that

		; enable external RAM (onboard cache)
		LDA #$FF
		STA PD7
		
		LDA #$C9     ;11001001		ENABLE EXT ROM, NMI, ICE & EXT BUS
		STA BCR
		LDA #$BB     ;10111011		ENABLE CS7, CS5, CS4, CS3, CS1 & CS0
		STA PCS7

		lda #$00
		sta UIER    ; disable all UART interrupts
		sta TIER    ; disable all timer interrupts
		sta EIER    ; disable all edge interrupts

		lda #$FF
		sta UIFR    ; clear all UART flags (write‑1‑to‑clear)
		sta TIFR    ; clear all timer flags
		sta EIFR    ; clear all edge flags

		; boots to internal clock
		; switch to FCLK input
		lda #%11111011		; set everything to use FCLK full speed - see pg. 237 of '265 datasheet
		sta SSCR

		lda #$00	; disable PIB
		sta PIBER

		;lda PDD4 ; 0 bits are input	;using PD46 for oscilliscope debug output, same for PD47 (pseudo LED)
		lda #%11000000	
		sta PDD4

		jsr Init_Interrupt
		jsr Init_Keyboard
		jsr Init_VIA

		jsr led_on			; onboard LED
		jsr led_toggle		; offboard LED

		;temporary
		lda #$FF
		sta EIFR    	; clear all edge flags
		cli 			; interrupt enable

		jsr Init_LCD

		;fall into main

	MAIN:

		jsr p46_toggle	; debug signal to verify with oscilliscope that main is loop (and to check the speed of loop)

		sei
		lda KeyBuf_Tail
		cmp KeyBuf_Head
		cli                   ;Clear Interrupt Disable
		beq main_cont		  ;if no keys, continue with main_cont, otherwise, go to key_pressed
			jsr key_pressed

		main_cont:
			bra MAIN

	Init_VIA:
		pha
		
		; VIA1
		; Set(1)/Clear(0)|Timer1|Timer2|CB1|CB2|ShiftReg|CA1|CA2
		lda #%01111111	     	; Disable all interrupts
		sta >VIA1_IER			; Write to interrupt enable register
		lda #%10000010			; Enable CA1 interrupt
		sta >VIA1_IER			; Write to interrupt enable register

		lda #%11111111          ; 0=input, 1=output
		sta >VIA1_DDRA          ; Set all pins on port A to output
		sta >VIA1_DDRB          ; Set all pins on port B to output
		lda #%00000001
		sta >VIA1_PORTA
		lda #%10000000
		sta >VIA1_PORTB

		; VIA2
		; Set(1)/Clear(0)|Timer1|Timer2|CB1|CB2|ShiftReg|CA1|CA2
		lda #%01111111	        ; Disable all interrupts
		sta >VIA2_IER			; Write to interrupt enable register

		lda #%11111111          ; 0=input, 1=output
		sta >VIA2_DDRA          ; Set all pins on port A to output
		sta >VIA2_DDRB          ; Set all pins on port B to output
		lda #%10000000
		sta >VIA2_PORTA
		lda #%00000001
		sta >VIA2_PORTB
		
		pla
		rts

	update_VIA_output:
		pha

		sta >VIA1_PORTA			; this will be ignored after the VIA1 interrupt is triggered
		sta >VIA2_PORTA
		eor #%11111111
		sta >VIA1_PORTB			; this will be ignored after the VIA1 interrupt is triggered
		sta >VIA2_PORTB

		pla
		rts

	key_pressed:
		pha

		; ignore first char (from keyboard hardware reset)
		lda kb_flags
		AND #KBD_READY
		beq kbd_setready
			lda KeyBuf_Tail
			tax
			lda KeyBuf, x
			jsr update_VIA_output	;temp
			jsr print_char_lcd
			bra key_out

		kbd_setready:
			lda kb_flags
			ORA #KBD_READY
			sta kb_flags
			; fall into key_out

		key_out:
			jsr keyboard_inc_rptr
			pla
			rts

	Init_Keyboard:
		stz PS2_BitIndex
		stz PS2_DataByte
		stz KeyBuf_Head
		stz KeyBuf_Head+1
		stz KeyBuf_Tail
		stz KeyBuf_Tail+1
		stz kb_flags
		rts

	Init_LCD:
		pha
		jsr lcd_init
		
		lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font     ;See page 24 of HD44780.pdf
		jsr lcd_instruction
		;call again for higher clock speed setup
		;lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font     ;See page 24 of HD44780.pdf
		;jsr lcd_instruction
		
		lda #%00001110 ; Display on; cursor on; blink off
		jsr lcd_instruction
		
		lda #%00000110 ; Increment and shift cursor; don't shift display
		jsr lcd_instruction
		
		lda #%00000001 ; Clear display
		jsr lcd_instruction
		
		pla
		rts

	Init_Interrupt:
		pha

		; Configure bits as input
		; PD62 - PS2 Data
		; PD64 - PS2 Clock

		lda PDD6
		and #%11101011	; 0 bits are input
		sta PDD6

		; Enable interrupts
		lda EIER
		ora #NE64ENABLE		; enable edge interrupts
		ora #IRQENABLE		; enable IRQB
		sta EIER

		pla
		rts
		
	led_on:
		pha
		lda PD7
		and #%11111011   ; clear bit 2 (active-low → ON)
		sta PD7
		pla
		rts

	led_off:
		pha
		lda PD7
		ora #%00000100   ; set bit 2 (active-low → OFF)
		sta PD7
		pla
		rts	

	led_toggle:
		; DON'T USE P72 (CS2B) onboard LED!
		pha
		lda PD4
		eor #%10000000   ; flip bit 7
		sta PD4
		pla
		rts

	p46_toggle:
		; debug view on oscilliscope (MAIN loop)
		pha
		lda PD4
		eor #%01000000
		sta PD4
		pla
		rts

;;-------------------------------------------------------------------------
;; FUNCTIONS for 1602 LCD
;;-------------------------------------------------------------------------

	lcd_wait:
		pha
		lda #%11110000  ; LCD data is input
		sta PDD5
	lcdbusy:
		lda #RW
		sta PD5	
		lda #(RW|E)                           
		sta PD5	
		lda PD5			; Read high nibble
		pha             ; and put on stack since it has the busy flag
		lda #RW
		sta PD5			
		lda #(RW|E)
		sta PD5			
		lda PD5			; Read low nibble   
		pla             ; Get high nibble off stack
		and #%00001000                            
		bne lcdbusy                              
		lda #RW
		sta PD5			
		lda #%11111111  
		sta PDD5		
		pla
		rts
		
	lcd_init:
		pha
		lda #%00000010 	; Set 4-bit mode
		sta PD5
		ora #E
		sta PD5
		and #%00001111
		sta PD5
		pla
		rts

	lcd_instruction:
		jsr lcd_wait
		pha
		lsr
		lsr
		lsr
		lsr            	; Send high 4 bits
		sta PD5			
		ora #E         	; Set E bit to send instruction
		sta PD5			
		eor #E         	; Clear E bit
		sta PD5			
		pla
		and #%00001111 	; Send low 4 bits
		sta PD5			
		ora #E         	; Set E bit to send instruction
		sta PD5			
		eor #E          ; Clear E bit
		sta PD5			
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
		jsr lcd_wait
		pha                                      
		lsr
		lsr
		lsr
		lsr             ; Send high 4 bits
		ora #RS         ; Set RS
		sta PD5			
		ora #E          ; Set E bit to send instruction
		sta PD5			
		eor #E          ; Clear E bit
		sta PD5			
		pla
		pha
		and #%00001111  ; Send low 4 bits
		ora #RS         ; Set RS
		sta PD5			
		ora #E          ; Set E bit to send instruction
		sta PD5			
		eor #E          ; Clear E bit
		sta PD5			
		pla
		rts


;PS/2 keyboard scan codes -- Set 2 or 3
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

push_key:
	; A has ascii code of key
  	ldx KeyBuf_Head
  	sta KeyBuf, x
  	jsr keyboard_inc_wptr
  	rts

keyboard_inc_rptr:
	sta TempScan            		; save caller A
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

	KIR_DONE:
			lda TempScan            ; restore caller A
			rts

keyboard_inc_wptr:
	sta TempScan            		; save caller A
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

	KIW_DONE:
			lda TempScan            ; restore caller A
			rts


IRQHandler_Keyboard:
		pha
        ;phx
		txa
		pha

        ; ---- Read PS/2 data bit ----
        lda PD6
        and #%00000100

        beq bit0
        	lda #1
			bit0:
				sta TempBit

				; ---- Load and increment bit index ----
				ldx PS2_BitIndex
				inx
				stx PS2_BitIndex

				; ---- Ignore start bit (bit 0) ----
				cpx #1
				bcc exitISR

				; ---- Capture data bits 1..8 ----
				cpx #10
				bcs skipData

				; Shift right
				lda PS2_DataByte
				lsr
				sta PS2_DataByte

				; Insert new bit into bit 0
				lda TempBit
				beq exitISR
				lda PS2_DataByte
				ora #%10000000
				sta PS2_DataByte
				bra exitISR

			skipData:
				; ---- After stop bit (bit 10), byte is complete ----
				cpx #11
				bne exitISR

					; *********** have complete keycode here ****************

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
							bra kbd_hndlr_out

				kbd_hndlr_out:
					; Reset for next frame
					stz PS2_BitIndex
					stz PS2_DataByte

			exitISR:
				lda #NE64ENABLE
				sta EIFR

				;plx
				pla
				tax
				pla
				rti

	read_key:
		lda PS2_DataByte		; bits already read, full data byte ready	
		cmp #$F0        		; if releasing a key
		beq key_release 		; set the releasing bit
		cmp #$12       			; left shift
		beq shift_down
		cmp #$59       			; right shift
		beq shift_down 
		cmp #$76				; escape key
		beq esc
		cmp #$5A				; enter
		beq enter

			lda kb_flags
			and #SHIFT
			bne Shifted
				lda PS2_DataByte
				tax
				lda keymap, x
				jsr push_key		; Push completed byte into buffer
				bra kbd_hndlr_out
			Shifted:
				lda PS2_DataByte
				tax
				lda keymap_shifted, x
				jsr push_key		; Push completed byte into buffer
				bra kbd_hndlr_out
	shift_up:
		lda kb_flags
		eor #SHIFT
		sta kb_flags
		bra kbd_hndlr_out
	shift_down:
		lda kb_flags
		ora #SHIFT
		sta kb_flags
		bra kbd_hndlr_out
	esc:
		jsr lcd_clear
		bra kbd_hndlr_out
	enter:
		jsr lcd_line2
		bra kbd_hndlr_out
	key_release:
		lda kb_flags
		ora #RELEASE
		sta kb_flags
		lda kb_flags
		bra kbd_hndlr_out
		
	VIA1_IRQ_Handler:
		; check interrupt source on VIA IER (Interrupt|T1_timeout|T2_timeout|CB1|CB2|Shift|CA1|CA2)
		; could branch based on which pin
		; lda VIA1_IFR
		; and #%00000010	;CA1
		; bne ...

		; VIA1 - change PortA pin direction to input
		lda #%00000000          ; 0=input, 1=output
		sta >VIA1_DDRA           ; Set all pins on port A to output
		sta >VIA1_DDRB           ; Set all pins on port B to output

		; reading the register for the associated port will clear the interrupt
		lda >VIA1_PORTA
		sta >VIA2_PORTA
		lda >VIA1_PORTB		
		sta >VIA2_PORTB

		bra irq_done 	  ; or for now, could fall into irq_done

	VIA2_IRQ_Handler:
		; check interrupt source on VIA IER (Interrupt|T1_timeout|T2_timeout|CB1|CB2|Shift|CA1|CA2)
		; could branch based on which pin
		; lda VIA2_IFR
		; and #%00000010	;CA1
		; bne ...

		; reading the register for PortA will clear the interrupt
		lda >VIA2_PORTA
		lda >VIA2_PORTB

		bra irq_done 	  ; or for now, could fall into irq_done

	irq_done:
		; just clear all flags - temporary
		; lda #$FF
		; sta EIFR
		; sta UIFR
		; sta TIFR

        pla                 ; restore A
		rti

	IRQHandler_IRQB:
        pha                 ; save A

		; temporary
		jsr led_toggle
		lda #'+'
		jsr print_char_lcd

		; check interrupts in order of priority
		lda  >VIA1_IFR		        ; Check status register for VIA1        ; PS/2 keyboard, Timer1
		and #%10000000				; indicates an interrupt on this VIA. 	Interrupt|T1_timeout|T2_timeout|CB1|CB2|Shift|CA1|CA2
		bne  VIA1_IRQ_Handler		; Branch if VIA1 is interrupt source

		lda  >VIA2_IFR		        ; Check status register for VIA3        ; USB mouse
		and #%10000000				; indicates an interrupt on this VIA 	Interrupt|T1_timeout|T2_timeout|CB1|CB2|Shift|CA1|CA2
		bne  VIA2_IRQ_Handler		; Branch if VIA3 is interrupt source
		
		; some other interrupt
		bra irq_done				; nothing above caught the interrupt - must be something else

	IRQHandler:		; $FFE0
			pha                 ; save A

			; shouldn't ever get here...
			jsr led_toggle
			lda #'%'
			jsr print_char_lcd

			; just clear all flags - temporary
			lda #$FF
			sta EIFR
			sta UIFR
			sta TIFR

			pla                 ; restore A
			rti

	badVec:		; $FFE0 - IRQRVD2(134)
        pha                 ; save A

		; just clear all flags - temporary
		lda #$FF
		sta EIFR
		sta UIFR
		sta TIFR
		
        pla                 ; restore A
		rti

	ends

;;-----------------------------
;;
;;		Reset and Interrupt Vectors (define for 265, 816/02 are subsets)
;;		Native mode vectors: see page 10 if the W65C265S datasheet
;;-----------------------------



vect_kbd	SECTION OFFSET $1FF98	; actually FF98 		** NATIVE mode **
	dw	IRQHandler_Keyboard			; $FF98 - NE64 native
	ends

vect_IRQB	SECTION OFFSET $1FF9E	; actually FF9E			** NATIVE mode **
	dw	IRQHandler_IRQB				; $FF9E - IRQ Level Interrupt
	ends

vect_std	SECTION OFFSET $1FFE0	; actdually FFE0
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
