; File: 65265_AV.asm
; 20 February 2026

; ************** RECENT UPDATES ****************************************
; 	-POST tests for extended SRAM (secondary 512 KB), dual-port SRAM (2K),
;		and secondary flash (512 KB))
;	-Default to 0xFF fill for unused ROM space to speed up flash programming
;
; ************** /RECENT UPDATES ****************************************

; ************** TO DO ****************************************
	; Update this documentation for the AV (copied from Primary)
	; Reserve DF00:DFFF as it's reserved by the '265
	; 8-bit A for PIB routines
	; refactor lda, ora, sta sequences to lda, tsb (and similar for and to trb)
	; change = to .equ in EQUs.asm for consistency with vars.asm and to prevent accidental redefinition
; *************** /TO DO ***************************************

; ************** CONFIG ****************************************
	; WDC W65C265SXB with 10.0 MHz PHI2
	; 32 KB external SRAM, 32 KB external flash ROM (x4, selectable)
	; 512 KB external SRAM, 512 KB external flash ROM
	; 2 KB dual-port SRAM for PIB
	; VIA0: PSGs
	; VGA
; *************** /CONFIG **************************************

; *************** MEMORY MAP **********************************
	; 	$F0:0800 to $FF:FFFF	CS7B				** UNUSED **
	; 	$F0:0000 to $F0:07FF	CS7B GAL			2 KB dual-port SRAM for PIB
	; 	$EC:0010 to $EF:FFFF	CS7B				** UNUSED **
	; 	$EA:0000 to $EB:FFFF	CS7B GAL			VGA VRAM
	; 	$E0:0000 to $E9:FFFF	CS7B GAL			** UNUSED **
	; 	$D0:0010 to $DF:FFFF	CS7B				** UNUSED **
	; 	$D0:0000 to $D0:000F	CS7B GAL			** UNUSED **
	; 	$C0:0010 to $CF:FFFF	CS7B				** UNUSED **
	; 	$C0:0000 to $C0:000F	CS7B GAL			VIA0 (PSGs)
	;
	;	$48:0000 to $BF:FFFF	CS6B				** UNUSED **
	;	$40:0000 to $47:FFFF	CS6B				512 KB external flash (secondary)
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

.org $000000
.fill $20000, $FF   ; fill unused space with 0xFF - much faster flash programming

.org $0000          ;wasted portion of ROM
    .word $ABCD     ;need something to write at $00 -- wasting first 32K of ROM and using addresses for RAM
                    ;if starting with .org $8000, assembler ends up writing it to $0000, which won't work
.org $8000          ;start of usable ROM

	.byte 		"WDC"		; monitor ROM will jump to $8004
	.byte		$00			; filler byte

	; the Mensch monitor will jump to $8004 on startup, so start code here
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

		jsr Init_VGA
		jsr gfx_ClearScreen

		; delay to let things settle (e.g., PS/2 keyboard reset, UART)
		ldx #2000			; works well at 10 MHz
		jsr Delay_ms


		jsr Init_UART3

		jsr Init_PIB_slave

		;jsr play_tone_startup_complete
		;jsr Play_Midi_Sequence
		;jsr Play_Midi_Sequence2

		;lda #$8934
		;jsr print_hex16_serial

		; *** POST TESTS ***
		jsr Run_POST_Tests



		jsr gfx_TestPattern
		jsr gfx_TestPattern_Animated_Ship

		jsr Init_Sound
	    ;jsr PlayTestChords
	    jsr PlayWindowsStartSound


		
		jsr play_tone_startup_complete

		cli 			; interrupt enable

		; fall into main

	MAIN265:

		jsr p64_toggle

		main_cont:
			bra MAIN265
	
	Configure_MCU:
		; Configure MCU basics, assuming coming from WDC Mensch monitor with external ROM jump ('WDC') on startup
		
		pha
		sep #$20		; 8-bit A
		.setting "RegA16", false

		
		LDA #%11001001	; ENABLE EXT ROM, NMIB, EMULATION MODE, EXT BUS		(BCR4 is watchdog - currently off)
		STA BCR
		LDA #%11111111  ; ENABLE CS7B, CS6B CS5B, CS4B, CS3B, CS2B, CS1, CS0B
		STA PCS7

		; MCU boots to slow clock, switch to FCLK input
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

		lda PDD6
		;ora #%00110001		; diag LED, diag LED, AV reset
		ora #%00010000		; diag LED P64
		sta PDD6

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

	.include "POST.asm"
	.include "ToneGen.asm"
	.include "UART.asm"
	.include "Util_Functions.asm"
	.include "Misc.asm"
	;.include "OS.asm"
	.include "VGA.asm"
	.include "sound.asm"
	.include "PIB_slave.asm"


	; ********** INTERRUPT HANDLERS ************************

	

.setting "RegA16", true
.setting "RegXY16", true
		
	VIA0_IRQ_Handler:
		; caller guarantees A is 8-bit on entry
		.setting "RegA16", false

		
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

		; just clear all flags - temporary
		lda #$FF
		sta EIFR
		sta UIFR
		sta TIFR

		pla                 ; restore A
		plp
		rti


.include "ROM_Data.asm"



	
.org $F000
	.byte		$00			; OS Version major
	.byte		$00			; OS Version minor
	.byte 		$01			; build number
	
	SysCallTable:
		;.dword OS_somefunc

.org $00F200
	CallOS:
    	; x = SysCallTable index
		; a = param 1

        rep #$30	; 16-bit A/X/Y
		pha			; remember param 1 (A)
		txa
        asl a          ; index * 2
        asl a          ; index * 4
        tax

        lda SysCallTable, x
        sta sysroutine
		sep #$20	; 8-bit A
		.setting "RegA16", false
		
        lda SysCallTable+2, x
        sta sysroutine+2
        ; ignore SysCallTable+3 (always 0)
		rep #$20
		.setting "RegA16", true

		pla			; restore param 1 (A)
        jml [sysroutine]      ; jump to OS routine (must rtl)


;;-----------------------------
;;	Reset and Interrupt Vectors (define for 265, 816/02 are subsets)
;;	Native mode vectors: see page 10 if the W65C265S datasheet
;;-----------------------------

.org $FF9C
	.word	IRQHandler_IRQPIB			; $FF9C - IRQ PIB

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