	LONGI	ON
	LONGA	ON
    
	Init_UART3:
		; caller guarantees A/X are 16-bit on entry
		pha
		sep #$20	; 8-bit A
		LONGA OFF

		; Use Timer 3 for UART3
		lda TCR
		and #%01111111      ; TCR7 = 0 → Timer 3
		sta TCR

		; Load Timer 3 for 9600 bps with 6 MHz clock
		;lda #0
		;sta T3LH
		;lda #38
		;sta T3LL

		; ≈125000 baud @ 6 MHz
		;LDA #0
		;STA T3LH
		;LDA #2
		;STA T3LL

		; ≈125000 baud @ 8 MHz
		;LDA #0
		;STA T3LH
		;LDA #3
		;STA T3LL

		; ≈125000 baud @ 10 MHz
		LDA #0
		STA T3LH
		LDA #4
		STA T3LL

		; ≈57600 baud @ 12 MHz
		;LDA #0
		;STA T3LH
		;LDA #12
		;STA T3LL

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

		;jsr crlf_serial

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