	LONGI	ON
	LONGA	ON

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

		    jsr send_pib

	

			;rep #$30		; 16-bit A/X/Y
			;jsr print_char_vga
			;sep #$30		; 8-bit A/X/Y

			bra key_out

		do_clear_screen:
			jsr lcd_clear
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
		stz KeyBuf_Head
		stz KeyBuf_Tail
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


; ************************************************************************************************************
; ******************************* 1602 LCD & PS2 Keyboard ****************************************************
; ************************************************************************************************************
	LONGA OFF
	LONGI OFF

	lcd_wait:
		pha
		lda #%11110000  ; LCD data is input
		sta >VIA0_DDRB
	lcdbusy:
		lda #RW
		sta >VIA0_PORTB
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


    Init_VIA0:
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
