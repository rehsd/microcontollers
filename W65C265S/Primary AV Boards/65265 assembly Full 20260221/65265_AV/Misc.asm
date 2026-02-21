.setting "RegA16", true
.setting "RegXY16", true


	led_on_CS2B:
		; turn on P72 (CS2B) LED
		; caller guarantees A/X are 16-bit on entry

		pha
		sep #$20		; 8-bit A
		.setting "RegA16", false

		lda PD7
		and #%11111011   ; clear bit 2 (active-low → ON)
		sta PD7

		.setting "RegA16", true
		rep #$20		; 16-bit A

		pla
		rts

	led_off:
		pha
		lda PD7
		ora #%00000100   ; set bit 2 (active-low → OFF)
		sta PD7
		pla
		rts	

	p64_toggle:
		php
		sep #$20		; 8-bit A
		.setting "RegA16", false

		pha

		lda PD6
		eor #%00010000
		sta PD6

		pla
		plp
		.setting "RegA16", true
		rts

	p65_toggle:
		php
		sep #$20		; 8-bit A
		.setting "RegA16", false

		pha

		lda PD6
		eor #%00100000
		sta PD6

		pla
		plp
		.setting "RegA16", true
		rts
