.setting "RegA16", true
.setting "RegXY16", true
    
Init_UART3:
	; caller guarantees A/X are 16-bit on entry
	pha
	sep #$20	; 8-bit A
	.setting "RegA16", false

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

	.setting "RegA16", true
	rep #$20	; 16-bit A
	pla
	rts

uart3_tx:
	; protects stack if called from 16-bit sections
	php
	sep #$20
	.setting "RegA16", false
	pha                 ; save the byte to send
	TX_WAIT:
		lda UIFR
		and #U3TF 
		beq TX_WAIT
		pla                 ; restore the byte to send
		sta ARTD3
	plp                 ; restore original mode
	.setting "RegA16", true
	rts


print_char_serial:
	php
	sep #$20		
	.setting "RegA16", false
	jsr uart3_tx
	plp                     ; restore 16-bit mode
	rts

crlf_serial:
	; caller guarantees A is 8-bit on entry
	pha
	.setting "RegA16", false
	lda #$0d        ; CR
	jsr uart3_tx

	lda #$0a        ; LF
	jsr uart3_tx
	.setting "RegA16", true
	pla
	rts

; ---------------------------------------------------------
; print_hex_serial
; Prints the byte in A as two lowercase hex characters.
; Safe regardless of caller A width because we force 8-bit
; BEFORE any PHA.
; ---------------------------------------------------------

print_hex_serial:
	php                 ; save caller status (always 1 byte)

	sep #$20            ; FORCE A = 8-bit BEFORE ANY PHA
	.setting "RegA16", false

	pha                 ; save original byte (now guaranteed 1 byte)

	; ----- high nibble -----
	lsr a
	lsr a
	lsr a
	lsr a
	jsr nibble_to_ascii
	jsr uart3_tx

	; ----- low nibble -----
	pla                 ; restore original byte
	pha                 ; save again for cleanup
	and #$0f
	jsr nibble_to_ascii
	jsr uart3_tx

	pla                 ; final cleanup
	plp                 ; restore caller status
	rts

; ---------------------------------------------------------
; nibble_to_ascii
; in:  A = 0–15
; out: A = ASCII '0'..'9' or 'a'..'f'
; ---------------------------------------------------------

nibble_to_ascii:
	and #$0f
	cmp #$0a
	bcc digit

	; A >= 10 → 'a'..'f'
	clc
	adc #$57        ; 'a' - 10 = $61 - $0A = $57
	rts

digit:
	clc
	adc #$30        ; '0'
	rts



print_hex16_serial:
    ; ---------------------------------------------------------
    ; in:   a = 16-bit value to print (e.g., $1234)
    ; preserves: cpu mode and all registers
    ; ---------------------------------------------------------
    php             ; save original caller status (m/x flags)
    pha             ; save the original 16-bit value
    rep #$30        ; force 16-bit a, x, y for the math

    ; --- print high byte ---
    xba             ; swap: a now holds $3412, lower 8-bit is $12
    sep #$20        ; drop to 8-bit a to satisfy print_hex_serial
    .setting "RegA16", false
    jsr print_hex_serial

    ; --- print low byte ---
    rep #$20        ; back to 16-bit to use xba again
    .setting "RegA16", true
    xba             ; swap: a now holds $1234, lower 8-bit is $34
    sep #$20        ; drop to 8-bit a for the call
    .setting "RegA16", false
    jsr print_hex_serial

    ; --- formatting ---
    ; jsr crlf_serial

    ; --- cleanup ---
    rep #$20        ; 16-bit mode to properly pull 16-bit 'a'
    .setting "RegA16", true
    pla             ; restore original 16-bit value
    plp             ; restore original cpu mode
    rts

uart3_puts:
	;---------------------------------------
	; Send zero-terminated string at (PTR)
	;---------------------------------------
	; caller guarantees A is 8-bit on entry
	pha
	phy
	.setting "RegA16", false
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
		.setting "RegA16", true
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


