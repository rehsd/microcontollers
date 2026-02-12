.setting "RegA16", true
.setting "RegXY16", true
    
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


