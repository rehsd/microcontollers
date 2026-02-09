	LONGA ON
	LONGI ON
    
	Delay_ms:
		; x as number of milliseconds (approximate), given 10 Mhz PHI2
		; caller guarantees X/Y are 16-bit on entry
		php                 ; save P
		sei                 ; disable interrupts while P is on stack
		phx                 ; save X (16-bit)
		phy                 ; save Y (16-bit)
    	rep #$10            ; ensure X/Y are 16-bit

		DL_outer:
			ldy #$0880		; approximate, adjust as needed for timing
		DL_inner:
			dey
			bne DL_inner
			dex
			bne DL_outer

			ply                 ; restore Y
			plx                 ; restore X
			plp                 ; restore P (restores I and original M/X)
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
