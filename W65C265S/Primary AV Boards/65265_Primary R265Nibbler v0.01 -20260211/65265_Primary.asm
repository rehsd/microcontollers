; File: 65265_PRIMARY.asm
; 11 February 2026

; ************** TO DO ****************************************
	; Reserve DF00:DFFF as it's reserved by the '265
	; 8-bit A for PIB routines
	; refactor lda, ora, sta sequences to lda, tsb (and similar for and to trb)
	;
; *************** /TO DO ***************************************

; ************** CONFIG ****************************************
	; WDC W65C265SXB with 10.0 MHz PHI2
	; 32 KB external SRAM, 32 KB external flash ROM (x4, selectable)
	; 512 KB external SRAM, 512 KB external flash ROM
	; 2 KB dual-port SRAM for PIB
	; VIA0: PS/2 keyboard, 1602 LCD
	; VIA1: TFT LCD (ILI9341)
	; VIA2: SPI (RTC, SD card)
; *************** /CONFIG **************************************

; *************** MEMORY MAP **********************************
	; 	$F0:0800 to $FF:FFFF	CS7B				** UNUSED **
	; 	$F0:0000 to $F0:07FF	CS7B GAL			2 KB dual-port SRAM for PIB
	; 	$E0:0010 to $EF:FFFF	CS7B				** UNUSED **
	; 	$E0:0000 to $E0:000F	CS7B GAL			VIA2 (SPI)
	; 	$D0:0010 to $DF:FFFF	CS7B				** UNUSED **
	; 	$D0:0000 to $D0:000F	CS7B GAL			VIA1 (TFT LCD)
	; 	$C0:0010 to $CF:FFFF	CS7B				** UNUSED **
	; 	$C0:0000 to $C0:000F	CS7B GAL			VIA0 (KBD, 1602 LCD)
	;
	;	$48:0000 to $BF:FFFF	CS6B				** UNUSED **
	;	$40:0000 to $47:FFFF	CS6B				512 KB external flash
	;
	;	$08:0000 to $3F:FFFF	CS5B				** UNUSED **
	;	$01:0000 to $07:FFFF	CS5B				512 KB external SRAM (full address space not usable)
	;
	;	$00:8000 to $00:FFFF	CS4B				32 KB external flash ($00:DF00 to $00:DFFF reserved for '265 internal use)
	;
	;	$00:0000 to $00:7FFF	CS3B				32 KB external SRAM
	;
	;	$00:FF00 to $00:FFFF    CS2B				On‑Chip Interrupt Vectors
	;	$00:E000 to $00:FEFF    CS2B				On‑Chip ROM
	;	$00:DF80 to $00:DFBF    CS2B				On‑Chip RAM
	;	$00:DF70 to $00:DF7F    CS2B				On‑Chip Comm. Registers
	;	$00:DF50 to $00:DF6F    CS2B				On‑Chip Timer Registers
	;	$00:DF40 to $00:DF4F    CS2B				On‑Chip Control Registers
	;	$00:DF20 to $00:DF27    CS2B				On‑Chip I/O Registers
	;	$00:DF00 to $00:DF07    CS2B				On‑Chip I/O Registers
	;	$00:0000 to $00:01FF    CS2B				On‑Chip RAM
	;
	;	$00:DFC0 to $00:DFFF    CS1B				External Chip Select 1 (P71)
	;
	;	$00:DF00 to $00:DF1F    CS0B				External Chip Select 0 (P70)
; *************** /MEMORY MAP *********************************

; ********** IMPORTANT NOTES **********************************
	; Default is native mode, 16-bit A/X/Y. 
	; 		All routines should assume this and maintain on return.
	; Assembled with Retro Assember
; ********** /IMPORTANT NOTES *********************************

; *********** MISC NOTES *******************************************
; *********** /MISC NOTES *******************************************

MyCode.65816.asm
.setting "HandleLongBranch", true
.setting "RegA16", true
.setting "RegXY16", true
.include "EQUs.asm"
.include "vars.asm"


;***************************************************************************
;                    Code Section
;***************************************************************************
; $DF00 to $DFFF 	Reserved for '265 internal use
; $01C0 to $01FF	Mensch monitor stack space in internal RAM		- stay out
; $00C0 to $01BF	Available internal user RAM
; $0040 to $00BF	Mensch monitor RAM								- stay out
; $0000 to $003F 	'265 critical pointers 							- stay out
;***************************************************************************


.org $0000          ;wasted portion of ROM
    .word $ABCD     ;need something to write at $00 -- wasting first 32K of ROM and using addresses for RAM
                    ;if starting with .org $8000, assembler ends up writing it to $0000, which won't work
.org $8000          ;start of usable ROM

	.byte 		"WDC"		; monitor ROM will jump to $8004
	.byte		$00		; filler

	START265:
		; Should be in native mode before getting here (from Mensch monitor ROM)

		sei				; turn off interrupts globally
		cld				; clear decimal mode
		clc
		xce        		; force native mode, in case not already in native
		rep #$30      	; 16-bit registers, indexers
		lda #$0000
        tcd				; set direct page to 0, so we can use zero page addressing for our variables
		jsr Configure_MCU
		lda #$7FFE
		tcs               ;move stack pointer to #$7FFF

		jsr play_tone_startup_start

		; delay to let things settle (e.g., PS/2 keyboard reset, UART)
		ldx #1000			; works well at 8 MHz
		jsr Delay_ms

		jsr Init_VIA0
		jsr Init_Keyboard
		jsr Init_LCD
		jsr Init_LCD
	
		jsr ILI_Init
		;jsr ILI_Test_Pattern
		;jsr ILI_Animated_Ship		

		jsr Init_UART3

	    jsr init_master_pib

		; uncomment the following block once AV board is connected
		; let AV complete startup - maybe change to a GPIO signal of some sort later
		; ldx #5000			; works well at 8 MHz
		; ldx #1000			; works well at 8 MHz
		; jsr Delay_ms

		cli 			; interrupt enable

		jsr play_tone_startup_complete
		;jsr Play_Midi_Sequence
		;jsr Play_Midi_Sequence2

		lda #$ffff
		sta ili_color
		sta ili_char_color
		
		lda #$0000
		sta ili_current_x
		lda #$0010
		sta ili_current_y

		;lda #$8934
		;jsr print_hex16_serial


		lda #'>'
		jsr ILI_Print_Char


		; fall into main

	MAIN265:

		jsr p64_toggle

		sei
		lda KeyBuf_Tail
		cmp KeyBuf_Head
		cli                   ;Clear Interrupt Disable
		beq main_cont		  ;if no keys, continue with main_cont, otherwise, go to key_pressed
			jsr key_pressed

		main_cont:
			bra MAIN265
	
	Configure_MCU:
		; Configure MPU basics, assuming coming from WDC Mensch monitor with external ROM jump ('WDC') on startup
		
		pha
		sep #$20		; 8-bit A
		.setting "RegA16", false

		
		LDA #%11001001	; ENABLE EXT ROM, NMIB, EMULATION MODE, EXT BUS		(BCR4 is watchdog - currently off)
		STA BCR
		LDA #%11111111  ; ENABLE CS7B, CS6B CS5B, CS4B, CS3B, CS2B, CS1, CS0B
		STA PCS7

		; MPU boots to internal clock, switch to FCLK input
		lda #%11111011		; set everything to use FCLK full speed - see pg. 237 of '265 datasheet
		sta SSCR
		
		lda #$00
		sta UIER    ; disable all UART interrupts
		sta TIER    ; disable all timer interrupts
		sta EIER    ; disable all edge interrupts

		lda #$FF
		sta UIFR    ; clear all UART flags (write‑1‑to‑clear)
		sta TIFR    ; clear all timer flags
		sta EIFR    ; clear all edge flags

		;lda #$00	; disable PIB
		;sta PIBER

		; **** PIB stuff *****
		lda PDD6
		ora #%00110001		; diag LED, diag LED, AV reset
		sta PDD6

		lda PD6
		and #%11111110		; pull AV reset low. after pib is running on primary, let this line up.
		sta PD6
		; **** /PIB stuff *****

		; Configure NE64 and IRQB interrupts
		lda EIER
		;ora #NE64ENABLE		; enable edge interrupts
		ora #IRQENABLE		; enable IRQB
		sta EIER

		.setting "RegA16", true

		rep #$20	; 16-bit A
		pla
		rts

	HALT265:
		jsr p64_toggle	; debug signal to verify with oscilliscope that main is loop (and to check the speed of loop)
		jmp HALT265

	.include "ToneGen.asm"
	.include "UART.asm"
	.include "Util_Functions.asm"
	.include "PS2_Keyboard_1602_LCD.asm"
	.include "Misc.asm"
	.include "ILI9486.asm"
	.include "PIB_Primary.asm"
	.include "OS.asm "
	


	; ********** INTERRUPT HANDLERS ************************

	read_key:
		; caller guarantees A/X are 8-bit on entry
		.setting "RegA16", false
		.setting "RegXY16", false

		lda PS2_DataByte		; bits already read, full data byte ready	
		cmp #$F0        		; if releasing a key
		beq key_release 		; set the releasing bit
		cmp #$12       			; left shift
		beq shift_down
		cmp #$59       			; right shift
		beq shift_down 
		;cmp #$76				; escape key
		;beq esc
		cmp #$5A				; enter
		beq enter
			; the key isn't one of the special keys above, so proceed with the follow 'else'
			lda kb_flags
			and #SHIFT
			bne Shifted
				; not shifted, continue here
				lda PS2_DataByte
				tax
				lda keymap, x
				jsr push_key		; Push completed byte into buffer
				bra IRQB_Out
			Shifted:
				lda PS2_DataByte
				tax
				lda keymap_shifted, x
				jsr push_key		; Push completed byte into buffer
				bra IRQB_Out
	shift_up:
		lda kb_flags
		eor #SHIFT
		sta kb_flags
		bra IRQB_Out
	shift_down:
		lda kb_flags
		ora #SHIFT
		sta kb_flags
		bra IRQB_Out
	enter:
		lda #$0D
		jsr push_key
		bra IRQB_Out

	key_release:
		lda kb_flags
		ora #RELEASE
		sta kb_flags
		lda kb_flags
		bra IRQB_Out

.setting "RegA16", true
.setting "RegXY16", true
		
	VIA0_IRQ_Handler:
		; caller guarantees A is 8-bit on entry
		.setting "RegA16", false


		; lda #'>'
		; jsr print_char_serial

		lda VIA0_PORTA
		sta PS2_DataByte
		; jsr print_hex_serial

		lda kb_flags
			AND #RELEASE   ; check if we're releasing a key
			beq read_key   ; otherwise, read the key
				lda kb_flags
				eor #RELEASE   ; flip the releasing bit
				sta kb_flags

				lda PS2_DataByte
				cmp #$12       		; left shift
				beq shift_up
					cmp #$59       	; right shift
					beq shift_up 
		
		bra IRQB_Out

	IRQHandler_IRQB:
        php
		sep #$20

		.setting "RegA16", false

		pha                ; save A

		; lda #':'
		; jsr print_char_serial

		; check interrupts in order of priority
		lda  VIA0_IFR		        ; Check status register for VIA0        ; PS/2 keyboard, Timer1
		and #%00000010				; indicates an interrupt on this VIA. 	Interrupt|T1_timeout|T2_timeout|CB1|CB2|Shift|CA1|CA2
		; bne  IRQHandler_Keyboard	; Branch if VIA0 is interrupt source
		beq IRQB_Out          ; if zero, skip handler
    	jmp VIA0_IRQ_Handler

		IRQB_Out:	

		.setting "RegA16", true

			pla
			plp		; return to original 16-bit A or 8-bit A state based on caller
			rti

	IRQHandler_UART3_RECV:
		; to do: convert this to 16-bit code
		php
		pha
		phx
		phy
		sep #$20		; 8-bit A
		.setting "RegA16", false
		lda ARTD3          ; UART3 receive data register
		cmp #'h'
		beq DoHelp
		cmp #'H'
		beq DoHelp
		bra rcvDone

		DoHelp:
			lda #<STR_SERIAL_HELP
			sta Str_ptr
			lda #>STR_SERIAL_HELP
			sta Str_ptr+1
			jsr uart3_puts

		rcvDone:

			
		.setting "RegA16", true
			
			ply
			plx
			pla
			plp
			rti

	IRQHandler:		; $FFE0
		php
		pha                 ; save A

		; shouldn't ever get here...

		; just clear all flags - temporary
		lda #$FF
		sta EIFR
		sta UIFR
		sta TIFR

		pla                 ; restore A
		plp
		rti

	badVec:		; $FFE0 - IRQRVD2(134)
		; to do... add something to log unhandled interrupts
		php
		pha                 ; save A

		; shouldn't ever get here...
		lda #'^'
		jsr print_char_lcd

		; just clear all flags - temporary
		lda #$FF
		sta EIFR
		sta UIFR
		sta TIFR

		pla                 ; restore A
		plp
		rti


.include "ROM_Data.asm"


;;-----------------------------
;;	Reset and Interrupt Vectors (define for 265, 816/02 are subsets)
;;	Native mode vectors: see page 10 if the W65C265S datasheet
;;-----------------------------

.org $FF9E
	.word	IRQHandler_IRQB				; $FF9E - IRQ Level Interrupt

.org $FFAC
	.word	IRQHandler_UART3_RECV		; $FFAC - UART 3 receive

.org $FFE0
;					;65C816 Interrupt Vectors
;					;Status bit E = 0 (Native mode, 16 bit mode)
	.word	badVec		; $FFE0 - IRQRVD4(816)
	.word	badVec		; $FFE2 - IRQRVD5(816)
	.word	badVec		; $FFE4 - COP(816)
	.word	badVec		; $FFE6 - BRK(816)
	.word	badVec		; $FFE8 - ABORT(816)		; NE64 native '265 overlay?
	.word	badVec		; $FFEA - NMI(816)
	.word	badVec		; $FFEC - IRQRVD(816)
	.word	badVec		; $FFEE - IRQ(816)
;					;Status bit E = 1 (Emulation mode, 8 bit mode)
	.word	badVec		; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
	.word	badVec		; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
	.word	badVec		; $FFF4 - COP(8 bit Emulation)
	.word	badVec		; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
	.word	badVec		; $FFF8 - ABORT(8 bit Emulation)
;
;					; Common 8 bit Vectors for all CPUs
	.word	badVec		; $FFFA -  NMIRQ (ALL)
	.word	START265		; $FFFC -  RESET (ALL)
	.word	IRQHandler	; $FFFE -  IRQBRK (ALL)
;		