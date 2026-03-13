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


; ---------------------------------------------------------
; RAND_RANGE
; ---------------------------------------------------------
RAND_RANGE:
        rep #$20
        .setting "RegA16", true
        sta RNG_MAX
    rand_retry:
        lda RNG_SEED
        beq rand_seed_init
        ; --- Xorshift Algorithm ---
        sta temp_rng        ; save for shift logic
        asl a               ; a << 7
        asl a
        asl a
        asl a
        asl a
        asl a
        asl a
        eor temp_rng        ; a ^= (a << 7)
        sta temp_rng
        lsr a               ; a >> 9
        lsr a
        lsr a
        lsr a
        lsr a
        lsr a
        lsr a
        lsr a
        lsr a
        eor temp_rng        ; a ^= (a >> 9)
        sta temp_rng
        asl a               ; a << 8
        asl a
        asl a
        asl a
        asl a
        asl a
        asl a
        asl a
        eor temp_rng        ; a ^= (a << 8)
        sta RNG_SEED        ; save new seed
        ; --- Masking ---
        and #$01ff          ; mask to 511
    rand_check:
        cmp RNG_MAX
        bcs rand_retry
        rts
    rand_seed_init:
        lda #$abcd          ; non-zero start
        sta RNG_SEED
        bra rand_retry


; =============================================================================
; get_ascii_from_bcd_hi
; Input:  A = BCD byte (e.g., $26)
; Output: A = ASCII character for tens digit (e.g., '2' / $32)
; =============================================================================
get_ascii_from_bcd_hi:
    lsr a
    lsr a
    lsr a
    lsr a               ; Move high nibble to low nibble
    clc
    adc #$30            ; Convert to ASCII '0'-'9'
    rts

; =============================================================================
; get_ascii_from_bcd_lo
; Input:  A = BCD byte (e.g., $26)
; Output: A = ASCII character for ones digit (e.g., '6' / $36)
; =============================================================================
get_ascii_from_bcd_lo:
    and #$0F            ; Mask out the high nibble
    clc
    adc #$30            ; Convert to ASCII '0'-'9'
    rts


