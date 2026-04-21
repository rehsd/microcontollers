
; PB7: Mouse Clock (Input)
; PB6: Mouse Data  (Input)
; ... available ...
; PB2: NES Data    (Input)
; PB1: NES Clock   (Output)
; PB0: NES Latch   (Output)
	
.setting "HandleLongBranch", true
.setting "RegA16", true
.setting "RegXY16", true

NES_LATCH .equ %00000001
NES_CLOCK .equ %00000010
NES_DATA  .equ %00000100

; --- Initialization and Host-to-Device Write ---

init_mouse:
	; caller sets A8, XY16
	; php
	sep #$20
	.setting "RegA16", false
	lda #%00000000          ; Ensure PORTB bits are 0
	sta VIA2_PORTB
	lda #%00000000          ; Set DDR to input initially
	sta VIA2_DDRB
	lda #$f4                ; Command: Enable Data Reporting
	jsr mouse_write_byte
	; plp
	rts

mouse_write_byte:
	sta temp_val            ; Store byte to send
	stz parity_count
	; 1. Inhibit mouse / Request to send
	lda VIA2_DDRB
	ora #%10000000          ; PB7=output (Clock low)
	sta VIA2_DDRB
	jsr delay_100us         ; Hold clock low for > 100us
	lda VIA2_DDRB
	ora #%01000000          ; PB6=output (Data low)
	sta VIA2_DDRB
	; 2. Release clock
	lda VIA2_DDRB
	and #%01111111          ; PB7=input (Clock high)
	sta VIA2_DDRB
	; 3. Send 8 data bits
	ldy #$00

	send_loop:
		jsr wait_clk_low
		lda temp_val
		lsr
		sta temp_val
		bcc bit_low
	bit_high:
		inc parity_count
		lda VIA2_DDRB
		and #%10111111          ; PB6=input (Data high)
		bra bit_done
	bit_low:
		lda VIA2_DDRB
		ora #%01000000          ; PB6=output (Data low)
	bit_done:
		sta VIA2_DDRB
		jsr wait_clk_high
		iny
		cpy #$08
		bne send_loop
		; 4. Send Parity (Odd)
		jsr wait_clk_low
		lda parity_count
		and #$01
		bne parity_low          ; If odd 1s, parity bit is 0
	parity_high:
		lda VIA2_DDRB
		and #%10111111          ; PB6=input
		bra send_parity
	parity_low:
		lda VIA2_DDRB
		ora #%01000000          ; PB6=output
	send_parity:
		sta VIA2_DDRB
		jsr wait_clk_high
		; 5. Send Stop bit
		jsr wait_clk_low
		lda VIA2_DDRB
		and #%10111111          ; PB6=input (High)
		sta VIA2_DDRB
		jsr wait_clk_high
		; 6. Acknowledge phase
		jsr wait_clk_low
	ack_wait:
		lda VIA2_PORTB
		and #%01000000          ; Wait for mouse to pull Data low
		bne ack_wait
		jsr wait_clk_high
		rts

; --- Helper Routines ---

	wait_clk_low:
		lda VIA2_PORTB
		asl                     ; Check PB7 (Clock)
		bcs wait_clk_low
		rts

	wait_clk_high:
		lda VIA2_PORTB
		asl                     ; Check PB7 (Clock)
		bcc wait_clk_high
		rts

	delay_100us:
		phx
		ldx #$0064              ; Approx count for 100us at your clock speed
	delay_loop:
		dex
		bne delay_loop
		plx
		rts
		
Init_Mouse_Gamepad:
	
	; Set(1)/Clear(0)|Timer1|Timer2|CB1|CB2|ShiftReg|CA1|CA2
	
	php                     ; save processor status (includes M/X flags)
	rep #$30                ; ensure 16-bit for predictable stacking
	.setting "RegA16", true
	.setting "RegXY16", true
	
	pha
	phb
	sep #$20                ; switch to 8-bit for VIA hardware regs
	.setting "RegA16", false
	
	jsr init_mouse

	lda #%00000011          ; 0=input, 1=output
	sta VIA2_DDRB           ; Set all pins on port A to input

	rep #$30                ; back to 16-bit to restore
	.setting "RegA16", true
	.setting "RegXY16", true
	plb
	pla
	plp                     ; restore original M/X flags and interrupt state
	rts
