; File: 1602_LCD_PS2KBD.asm
; 12/10/2025

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
pdd4;****************************************************************************

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
  
  TIFR:  			equ $DF44 ;; Timer Interrupt Flag Register
  TER:  			equ $DF43 ;; Timer Enable Register
  TCR:  			equ $DF42 ;; Timer Control Register
  SSCR:  			equ $DF41 ;; System Speed Control Register
  BCR:  			equ $DF40 ;; Bus Control Register

;; Timer Register Memory Map
  T7CH:				equ $DF6F ;; Timer 7 Counter High
  T7CL:				equ $DF6E ;; Timer 7 Counter Low
  T6CH:				equ $DF6D ;; Timer 6 Counter High
  T6CL:				equ $DF6C ;; Timer 6 Counter Low
  T5CH:				equ $DF6B ;; Timer 5 Counter High
  T5CL:				equ $DF6A ;; Timer 5 Counter Low
  T4CH:				equ $DF69 ;; Timer 4 Counter High
  T4CL:				equ $DF68 ;; Timer 4 Counter Low
  T3CH:				equ $DF67 ;; Timer 3 Counter High
  T3CL:				equ $DF66 ;; Timer 3 Counter Low
  T2CH:				equ $DF65 ;; Timer 2 Counter High
  T2CL:				equ $DF64 ;; Timer 2 Counter Low
  T1CH:				equ $DF63 ;; Timer 1 Counter High 
  T1CL:				equ $DF62 ;; Timer 1 Counter Low
  T0CH:				equ $DF61 ;; Timer 0 Counter High 
  T0CL:				equ $DF60 ;; Timer 0 Counter Low

;;  Latches  
  T7LH:				equ $DF5F ;; Timer 7 Latch High
  T7LL:				equ $DF5E ;; Timer 7 Latch Low  
  T6LH:				equ $DF5F ;; Timer 6 Latch High   
  T6LL:				equ $DF5E ;; Timer 6 Latch Low    
  T5LH:				equ $DF5F ;; Timer 5 Latch High 
  T5LL:				equ $DF5E ;; Timer 5 Latch Low  
  T4LH:				equ $DF5F ;; Timer 4 Latch High 
  T4LL:				equ $DF5E ;; Timer 4 Latch Low  
  T3LH:				equ $DF5F ;; Timer 3 Latch High 
  T3LL:				equ $DF5E ;; Timer 3 Latch Low  
  T2LH:				equ $DF5F ;; Timer 2 Latch High 
  T2LL:				equ $DF5E ;; Timer 2 Latch Low  
  T1LH:				equ $DF5F ;; Timer 1 Latch High 
  T1LL:				equ $DF5E ;; Timer 1 Latch Low  
  T0LH:				equ $DF5F ;; Timer 0 Latch High 
  T0LL:				equ $DF5E ;; Timer 0 Latch Low  

;; On Chip RAM
  OCRAM_BASE: equ $DF80 ;; RAM Registers
  
;; Emulation Mode Vector Table
  IRQBRK:			equ $FFFE 	 ;; BRK - Software Interrupt
  IRQRES:			equ $FFFC 	 ;; RES - "REStart" Interrupt  
  IRQNMI:			equ $FFFA 	 ;; Non-Maskable Interrupt
  IABORT:			equ $FFF8 	 ;; ABORT Interrupt          
; IRQRVD:			equ $FFF6 	 ;; Reserved
  IRQCOP:			equ $FFF4 	 ;; COP Software Interrupt
; IRQRVD:			equ $FFF2 	 ;; Reserved  
; IRQRVD:			equ $FFF0    ;; Reserved 
  IRQ:  			equ $FFDE    ;; IRQ Level Interrupt
  IRQPIB:			equ $FFDC    ;; PIB Interrupt 
  IRNE66:			equ $FFDA  	 ;; Negative Edge Interrupt on P66
  IRNE64:			equ $FFD8	 ;; Negative Edge Interrupt on P64	 *************************************
  IRPE62:			equ $FFD6	 ;; Positive Edge Interrupt on P62 for PWM
  IRPE60:			equ $FFD4	 ;; Positive Edge Interrupt on P60 
  IRNE57:			equ $FFD2  	 ;; Negative Edge Interrupt on P57
  IRPE56:			equ $FFD0	 ;; Positive Edge Interrupt on P56
  IRQT7:  			equ $FFCE	 ;; Timer 7 Interrupt 
  IRQT6:  			equ $FFCC	 ;; Timer 6 Interrupt 
  IRQT5:  			equ $FFCA	 ;; Timer 5 Interrupt 
  IRQT4:  			equ $FFC8	 ;; Timer 4 Interrupt 
  IRQT3:  			equ $FFC6	 ;; Timer 3 Interrupt 
  IRQT2:  			equ $FFC4	 ;; Timer 2 Interrupt 
  IRQT1:  			equ $FFC2	 ;; Timer 1 Interrupt 
  IRQT0:  			equ $FFC0	 ;; Timer 0 Interrupt 

  IRQHandlerBank: EQU $00	; IRQHandler / $10000   ; divide by 65536 to get bank

; 1602 LCD
  E:   			equ %01000000
  RW:  			equ %00100000
  RS:  			equ %00010000

; debug
  LEDSTATE:  	equ $2000

	
;		CHIP	65C02
		LONGI	OFF
		LONGA	OFF

	.sttl "W65C265S Demo Code"
	.page
;***************************************************************************
;***************************************************************************
;                    Code Section
;***************************************************************************
;***************************************************************************

		;org	$2000
		
		org		$8000
		db 		"WDC"

	START:
		;the monitor rom should be in native mode (per easysxb m,x values) when jumping to this - need to verify

		;Initialize the stack --assuming processor emulation mode (used in sample code from WDC)
		sei
		cld					
		ldx	#$ff
		txs

		;temporary
		lda #$00
		sta UIER    ; disable all UART interrupts
		sta TIER    ; disable all timer interrupts
		sta EIER    ; disable all edge interrupts

		;temporary
		lda #$FF
		sta UIFR    ; clear all UART flags (write‑1‑to‑clear)
		sta TIFR    ; clear all timer flags
		sta EIFR    ; clear all edge flags
		
		lda #$00	; disable PIB
		sta PIBER

		;lda PDD4 ; 0 bits are input	;using PD46 for oscilliscope debug output, same for PD47 (pseudo LED)
		lda #%11000000	
		sta PDD4

		lda PCS7		; onboard LED pin (P72 / CS2B) set to output
		ora #%00000100
		sta PCS7
		lda #0			
		sta LEDSTATE	; to track LED state

		jsr p46_toggle

		jsr LCD_Setup

		jsr p46_toggle

		jsr Init_Interrupt

		;temporary
		lda #$FF
		sta EIFR    	; clear all edge flags
		cli 			; interrupt enable

		;jsr p46_toggle

		jsr led_on

		;fall into main

	MAIN:

		jsr p46_toggle

		; loop here, waiting for keyboard input
		bra MAIN
		
	LCD_Setup:
		pha
		jsr lcd_init
		
		lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font     ;See page 24 of HD44780.pdf
		jsr lcd_instruction
		;call again for higher clock speed setup
		lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font     ;See page 24 of HD44780.pdf
		jsr lcd_instruction
		
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

		; Enable edge interrupt
		;lda EIER
		;ora #NE64ENABLE		; enable edge interrupts
		lda #NE64ENABLE		;temporary - focus on just enabling this single edge interrupt and disabling others
		sta EIER

		; BCR3 has to be set for shadow vector table???
        lda BCR
		ora #%10000000		; enable global interrupts (external ROM?)
		;ora #%00001000		; enable shadow vectors	-- NOT USING
		sta BCR

		; setup shadow vectors
			; NE64 shadow vector is at $7ED8 EMULATION MODE		;; see shadow at end of file
			;lda #<IRQHandler
			;sta $7ED8
			;lda #>IRQHandler
			;sta $7ED9
		
			; NE64 shadow vector is at $7E98 NATIVE MODE	;; see shadow at end of file
			; this shouldn't be needed, but also shouldn't hurt to have here
			;lda #<IRQHandler
			;sta $7E98
			;lda #>IRQHandler
			;sta $7E99

			; IRQ shadow vector is at $7EDE EMULATION MODE
			;lda #<IRQHandler
			;sta $7EDE
			;lda #>IRQHandler
			;sta $7EDF
			
			; IRQ shadow vector is at $7E9E NATIVE MODE
			;lda #<IRQHandler
			;sta $7E9E
			;lda #>IRQHandler
			;sta $7E9F

			; IRQBRK shadow vector is at $7FFE	;; see shadow at end of file
			;lda #<IRQHandler
			;sta $7FFE
			;lda #>IRQHandler
			;sta $7FFF

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

	  
	  org $9100		; for debugging to have consistent addresses of these routines
;;-------------------------------------------------------------------------
;; FUNCTION NAME	: Event Hander re-vectors
;;------------------:------------------------------------------------------
	IRQHandler:
        pha                 ; save A

		jsr led_toggle

		lda #'$'
		jsr print_char_lcd

        lda #NE64ENABLE
        sta EIFR            ; clear NE64 flag
        pla                 ; restore A
		rti


	badVec:		; $FFE0 - IRQRVD2(134)
        pha                 ; save A

		;jsr led_toggle

        ;lda #NE64ENABLE
        ;sta EIFR            ; clear NE64 flag
		
        pla                 ; restore A
		rti

		
;;-----------------------------
;;
;;		Reset and Interrupt Vectors (define for 265, 816/02 are subsets)
;;
;;-----------------------------

;Shadow_VECTORS_NATIVE	SECTION OFFSET $7E90		; or set in code - interrupt init
;					;port edge interrupts - NATIVE MODE (should these work?)
;		dw IRQHandler ; PE56
;		dw IRQHandler ; PE57
;		dw IRQHandler ; PE60
;		dw IRQHandler ; PE63
;		dw IRQHandler ; NE64		; 7E98   *******************
;		dw IRQHandler ; NE66
;		dw IRQHandler ; PIB
;		dw IRQHandler ; IRQ
;	ends

;Shadow_VECTORS_EMUL	SECTION OFFSET $7ED0		; or set in code - interrupt init
;					;port edge interrupts - EMULATION MODE (should these work?)
;		dw IRQHandler ; PE56
;		dw IRQHandler ; PE57
;		dw IRQHandler ; PE60
;		dw IRQHandler ; PE63
;		dw IRQHandler ; NE64		; 7ED8   *******************
;		dw IRQHandler ; NE66
;		dw IRQHandler ; PIB
;		dw IRQHandler ; IRQ
;	ends
					
;Shadow_VECTORS_std	SECTION OFFSET $7EE0
;					;65C816 Interrupt Vectors
;					;Status bit E = 0 (Native mode, 16 bit mode)
;		dw	badVec		; $FFE0 - IRQRVD4(816)
;		dw	badVec		; $FFE2 - IRQRVD5(816)
;		dw	badVec		; $FFE4 - COP(816)
;		dw	badVec		; $FFE6 - BRK(816)
;		dw	badVec		; $FFE8 - ABORT(816)
;		dw	badVec		; $FFEA - NMI(816)
;		dw	badVec		; $FFEC - IRQRVD(816)
;		dw	IRQHandler		; $FFEE - IRQ(816)
;					;Status bit E = 1 (Emulation mode, 8 bit mode)
;		dw	badVec		; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
;		dw	badVec		; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
;		dw	badVec		; $FFF4 - COP(8 bit Emulation)
;		dw	badVec		; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
;		dw	badVec		; $FFF8 - ABORT(8 bit Emulation)
;
;					; Common 8 bit Vectors for all CPUs
;		dw	badVec		; $FFFA -  NMIRQ (ALL)
;		dw	START		; $FFFC -  RESET (ALL)
;		dw	IRQHandler	; $FFFE -  IRQBRK (ALL)
;		
;	ends


;no external ROM installed, so these are not needed?
vectors_NE64_1	SECTION OFFSET $FF98
;					;65C816 Interrupt Vectors
;					;Status bit E = 0 (Native mode, 16 bit mode)
		dw	IRQHandler	; $FF98 - ABORT(816)		; NE64 native '265 overlay?
	ends

;no external ROM installed, so these are not needed?
vectors_NE64_2	SECTION OFFSET $FFB8
;					;65C816 Interrupt Vectors
;					;Status bit E = 0 (Native mode, 16 bit mode)
		dw	IRQHandler	; $FFB8 - ABORT(816)		; NE64 native '265 overlay?
	ends

;no external ROM installed, so these are not needed?
vectors_NE64_3	SECTION OFFSET $FFD8
;					;65C816 Interrupt Vectors
;					;Status bit E = 0 (Native mode, 16 bit mode)
		dw	IRQHandler	; $FFD8 - ABORT(816)		; NE64 native '265 overlay?
	ends

;no external ROM installed, so these are not needed?
vectors_std	SECTION OFFSET $FFE0
;					;65C816 Interrupt Vectors
;					;Status bit E = 0 (Native mode, 16 bit mode)
		dw	badVec		; $FFE0 - IRQRVD4(816)
		dw	badVec		; $FFE2 - IRQRVD5(816)
		dw	badVec		; $FFE4 - COP(816)
		dw	badVec		; $FFE6 - BRK(816)
		dw	IRQHandler	; $FFE8 - ABORT(816)		; NE64 native '265 overlay?
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
