; File: ShadowVectors.asm

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

			title  "ShadowVectors.asm"
			sttl

;***************************************************************************
;                               Local Constants
;***************************************************************************
;
;	VIA_BASE:	equ	$f0
;	VIA_BASE:	equ	$7FC0		;; base address of VIA port on SXB
;; IO Ports 
	PCS7: 			equ $DF27 ;; Port 7 Chip Select
	PDD6: 			equ $DF26 ;; Port 6 Data Direction Register
	PDD5: 			equ $DF25 ;; Port 5 Data Direction Register
	PDD4: 			equ $DF24 ;; Port 4 Data Direction Register
	PDD3:			equ $DF07	;; Port 3 Data Direction Register
	PDD2:			equ $DF06	;; Port 2 Data Direction Register
	PDD1:			equ $DF05	;; Port 1 Data Direction Register
	PDD0:			equ $DF04	;; Port 0 Data Direction Register
	PD7:  			equ $DF23 ;; Port 7 Data Register
	PD6:  			equ $DF22 ;; Port 6 Data Register
	PD5:  			equ $DF21 ;; Port 5 Data Register
	PD4:  			equ $DF20 ;; Port 4 Data Register
	PD3:			equ $DF03 ;; Port 3 Data Register
	PD2:			equ $DF02 ;; Port 2 Data Register
	PD1:			equ $DF01 ;; Port 1 Data Register
	PD0:			equ $DF00 ;; Port 0 Data Register
  
;; Control and Status Register Memory Map
	UIER:  			equ $DF49 ;; UART Interrupt Enable Register
	UIFR:  			equ $DF48 ;; UART Interrupt Flag Register
	EIER:  			equ $DF47 ;; Edge Interrupt Enable Register
	TIER:  			equ $DF46 ;; Timer Interrupt Enable Register
	EIFR:  			equ $DF45 ;; Edge Interrupt Flag Register
	TIFR:  			equ $DF44 ;; Timer Interrupt Flag Register
	TER:  			equ $DF43 ;; Timer Enable Register
	TCR:  			equ $DF42 ;; Timer Control Register
	SSCR:  			equ $DF41 ;; System Speed Control Register
	BCR:  			equ $DF40 ;; Bus Control Register

;; On Chip RAM
  OCRAM_BASE: equ $DF80 ;; RAM Registers
  
;; Emulation Mode Vector Table
	IRQBRK:			equ $FFFE ;; BRK - Software Interrupt
	IRQRES:			equ $FFFC ;; RES - "REStart" Interrupt  
	IRQNMI:			equ $FFFA ;; Non-Maskable Interrupt
	IABORT:			equ $FFF8 ;; ABORT Interrupt          
	;IRQRVD:		equ $FFF6 ;; Reserved
	IRQCOP:			equ $FFF4 ;; COP Software Interrupt
	;IRQRVD:		equ $FFF2 ;; Reserved  
	;IRQRVD:		equ $FFF0 ;; Reserved 
	IRQ:  			equ $FFDE  ;; IRQ Level Interrupt
	IRQPIB:			equ $FFDC  ;; PIB Interrupt 
	IRNE66:			equ $FFDA  ;; Negative Edge Interrupt on P66
	IRNE64:			equ $FFD8	 ;; Negative Edge Interrupt on P64
	IRPE62:			equ $FFD6	 ;; Positive Edge Interrupt on P62 for PWM
	IRPE60:			equ $FFD4	 ;; Positive Edge Interrupt on P60
	IRNE57:			equ $FFD2  ;; Negative Edge Interrupt on P57
	IRPE56:			equ $FFD0	 ;; Positive Edge Interrupt on P56
	IRQT7:  		equ $FFCE	 ;; Timer 7 Interrupt 
	IRQT6:  		equ $FFCC	 ;; Timer 6 Interrupt 
	IRQT5:  		equ $FFCA	 ;; Timer 5 Interrupt 
	IRQT4:  		equ $FFC8	 ;; Timer 4 Interrupt 
	IRQT3:  		equ $FFC6	 ;; Timer 3 Interrupt 
	IRQT2:  		equ $FFC4	 ;; Timer 2 Interrupt 
	IRQT1:  		equ $FFC2	 ;; Timer 1 Interrupt 
	IRQT0:  		equ $FFC0	 ;; Timer 0 Interrupt 


;		CHIP	65C02
		LONGI	OFF
		LONGA	OFF

	.sttl "W65C265S Shadow Vectors"
	.page
;***************************************************************************
;***************************************************************************
;                    W65C265S_Demo Code Section
;***************************************************************************
;***************************************************************************

	org	$2000

	START:
		;Initialize the stack 
		sei
		cld					
		ldx	#$ff
		txs
		
		lda #%00000001				
		sta PDD6				; Bit0 output, others, including Bit4 (NE64) input

		lda #%00000000
		sta PD6

		lda #%00000000
		sta PDD4				; Port 4 all inputs (IRQB on P41)


		; ORG $00:0100
		;UBRK      DS 4         ;USER BREAK						0100
		;UNMI      DS 4         ;USER NMI VECTOR				0104	
		;UNIRQ     DS 4         ;USER IRQ VECTOR				0108 ***
		;COPIRQ    DS 4         ;USER CO-PROCESSOR IRQ			010C	
		;IABORT    DS 4         ;USER ABORT POINTER				0110
		;PIBIRQ    DS 4         ;PERIPHERAL INTERFACE IRQ		0114
		;EDGEIRQS  DS 4         ;ALL EDGE IRQS					0118 ***
		;UNIRQT7   DS 4         ;USER TIMER 7 IRQ				011C	
		;UNIRQT2   DS 4         ;USER TIMER 2 IRQ				0120
		;UNIRQT1   DS 4         ;USER TIMER 1 IRQ				0124	
		;UNIRQT0   DS 4         ;USER TIMER 0 IRQ				0128
		;USER_CMD  DS 4         ;USER COMMAND					012C
		;URESTART  DS 4         ;USER PWR UP RESTART VECT		0130
		;UALRMIRQ  DS 4         ;USER --ALARM WAKEUP CALL		0134

		;this works for IRQB (P41)
        lda #$4C            ; JMP Opcode
        sta $0108           ; Store at UNIRQ
        lda #<IRQHandler_IRQB
        sta $0109           ; Address Low
        lda #>IRQHandler_IRQB
        sta $010A           ; Address High

		;this works for NE64 *if* IRQB (above) is also setup (cascade of some sort?)
        lda #$4C            ; JMP Opcode
        sta $0118           ; Store at EDGEIRQS
        lda #<IRQHandler_NE64
        sta $0119           ; Address Low
        lda #>IRQHandler_NE64
        sta $011A           ; Address High


		lda #%10010000		; IRQB, NE64
		sta EIER
		lda #%11111111		
		sta EIFR		; clear flag register
		cli
		
		rts

	;MAIN:
	;	bra MAIN
		

	Delay_ms:
		LONGI ON
		; x as number of milliseconds (approximate), given 8 Mhz PHI2
		; caller guarantees x/y are 16-bit

		php                 ; save P
		sei                 ; disable interrupts while P is on stack
		phx                 ; save X (16-bit)
		phy                 ; save Y (16-bit)

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
			LONGI OFF
			rts

;;-------------------------------------------------------------------------
;; FUNCTION NAME	: Event Hander re-vectors
;;------------------:------------------------------------------------------
	IRQHandler:
		pha

		pla
		rti
		
	IRQHandler_IRQB:
		LONGI ON
    	rep #$10            ; ensure X/Y are 16-bit
		pha

		; **** flash twice for IRQB *****

		lda #%00000001				
		sta PD6

		ldx #255;
		jsr Delay_ms

		lda #%00000000
		sta PD6

		ldx #255;
		jsr Delay_ms

		lda #%00000001
		sta PD6

		lda #%11111111
        sta EIFR            ; Clear Edge Flags

		ldx #255;
		jsr Delay_ms

		lda #%00000000
		sta PD6

		pla
		sep #$10            ; back to 8-bit X/Y
		LONGI OFF
		rti

	IRQHandler_NE64:
		LONGI ON
		rep #$10            ; ensure X/Y are 16-bit
		pha

		; **** flash three times for NE64 *****

		lda #%00000001				
		sta PD6

		ldx #255;
		jsr Delay_ms

		lda #%00000000
		sta PD6

		ldx #255;
		jsr Delay_ms

		lda #%00000001
		sta PD6

		ldx #255;
		jsr Delay_ms

		lda #%00000000
		sta PD6

		ldx #255;
		jsr Delay_ms

		lda #%00000001
		sta PD6

		ldx #255;
		jsr Delay_ms

		lda #%00000000
		sta PD6

		lda #%11111111
        sta EIFR            ; Clear Edge Flags

		pla
		sep #$10            ; back to 8-bit X/Y
		LONGI OFF
		rti


badVec:		; $FFE0 - IRQRVD2(134)
	php
	pha
	lda #$FF
				;clear Irq
	pla
	plp
	rti

;;-----------------------------
;;
;;		Reset and Interrupt Vectors (define for 265, 816/02 are subsets)
;;
;;-----------------------------

Shadow_VECTORS	SECTION OFFSET $7EE0
					;65C816 Interrupt Vectors
					;Status bit E = 0 (Native mode, 16 bit mode)
		dw	badVec		; $FFE0 - IRQRVD4(816)
		dw	badVec		; $FFE2 - IRQRVD5(816)
		dw	badVec		; $FFE4 - COP(816)
		dw	badVec		; $FFE6 - BRK(816)
		dw	badVec		; $FFE8 - ABORT(816)
		dw	badVec		; $FFEA - NMI(816)
		dw	badVec		; $FFEC - IRQRVD(816)
		dw	badVec		; $FFEE - IRQ(816)
					;Status bit E = 1 (Emulation mode, 8 bit mode)
		dw	badVec		; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
		dw	badVec		; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
		dw	badVec		; $FFF4 - COP(8 bit Emulation)
		dw	badVec		; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
		dw	badVec		; $FFF8 - ABORT(8 bit Emulation)

					; Common 8 bit Vectors for all CPUs
		dw	badVec		; $FFFA -  NMIRQ (ALL)
		dw	START		; $FFFC -  RESET (ALL)
		dw	IRQHandler	; $FFFE -  IRQBRK (ALL)
		
	ends
	
vectors	SECTION OFFSET $FFE0
					;65C816 Interrupt Vectors
					;Status bit E = 0 (Native mode, 16 bit mode)
		dw	badVec		; $FFE0 - IRQRVD4(816)
		dw	badVec		; $FFE2 - IRQRVD5(816)
		dw	badVec		; $FFE4 - COP(816)
		dw	badVec		; $FFE6 - BRK(816)
		dw	badVec		; $FFE8 - ABORT(816)
		dw	badVec		; $FFEA - NMI(816)
		dw	badVec		; $FFEC - IRQRVD(816)
		dw	badVec		; $FFEE - IRQ(816)
					;Status bit E = 1 (Emulation mode, 8 bit mode)
		dw	badVec		; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
		dw	badVec		; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
		dw	badVec		; $FFF4 - COP(8 bit Emulation)
		dw	badVec		; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
		dw	badVec		; $FFF8 - ABORT(8 bit Emulation)

					; Common 8 bit Vectors for all CPUs
		dw	badVec		; $FFFA -  NMIRQ (ALL)
		dw	START		; $FFFC -  RESET (ALL)
		dw	IRQHandler	; $FFFE -  IRQBRK (ALL)
		
		ends
	        end