
; Core PIB control and data registers
PIBFR              .equ $DF78       ; PIB flag register
PIBER              .equ $DF79       ; PIB enable register
PIR2               .equ $DF7A       ; CMD_hi
PIR3               .equ $DF7B       ; CMD_lo
PIR4               .equ $DF7C       ; Param1
PIR5               .equ $DF7D       ; Param2
PIR6               .equ $DF7E       ; Param3
PIR7               .equ $DF7F       ; Param4

;  PIBIRQENABLE:		equ %01000000		;$40

;--------------------------------------------------
; Port 4 Bit Masks (PIB Control — P42–P47)
;--------------------------------------------------
PIIB        .equ %00000100    ; P42 — Data Ready / STB       (master->slave)
PIWEB       .equ %00001000    ; P43 — Write Strobe / ACK     (slave->master)
PICSB       .equ %00010000    ; P44 — Chip Select B

PIRS7   .equ %11100000    ; PIR7 value for mailbox slot selection
PIRS6   .equ %11000000    ; PIR6 value for mailbox slot selection
PIRS5   .equ %10100000    ; PIR5 value for mailbox slot selection
PIRS4   .equ %10000000    ; PIR4 value for mailbox slot selection
PIRS3   .equ %01100000    ; PIR3 value for mailbox slot selection
PIRS2   .equ %01000000    ; PIR2 value for mailbox slot selection

.include "../Common/PIB_Commands.asm"


.setting "RegA16", false
.setting "RegXY16", true
.setting "HandleLongBranch", true


;==================================================
; Slave PIB init
;  - PD5: data bus, all inputs
;  - PD4: PIWEB output, others input
;  - PIB: automatic handshake mode, IRQ on PIIB via EIER/IRQPIB
;==================================================
Init_PIB_slave:

    sep #$20
    .setting "RegA16", false

    ; PD5 = inputs (slave only reads data)
    lda #%00000000
    sta PDD5                ; pd5 = inputs

    ; PD4:
    ;   P42 (PIIB)      = input  (from master)
    ;   P43 (PIWEB)     = output (to master)
    ;   P44 (PICSB)     = input  (from master)
    ;   P45–P47 (PIRS)  = inputs
    lda PDD4
    ora #PIWEB              ; set PIWEB as output, preserve others
    sta PDD4

    ;--------------------------------------------------
    ;   PIBER7 = Enable Automatic Handshake Input Data in PIR7 Interrupt (slave settable)
    ;   PIBER6 = Enable Automatic Handshake Output Data in PIR7 Interrupt (master settable)
    ;   PIBER5 = Enable Manual Handshake from Host (slave settable)
    ;   PIBER4 = Enable Manual Handshake from Processor (master settable)
    ;   PIBER3 = Enable Automatic Handshake Input Data in PIR3 Interrupt (slave settable)
    ;   PIBER2 = Enable Automatic Handshake Output Data in PIR3 Interrupt (master settable)
    ;   PIBER1 = Enable RDB and WRB (slave settable)
    ;   PIBER0 = Enable PIB
    ;--------------------------------------------------
    ;lda #%10001001

    
    ; can fill PIRS2-6, followed by 7 to trigger slave interrupt (6 bytes of data total)
    lda #%10000001  ; enable PIB and automatic handshake for PIR7
    sta PIBER

    ; Idle: PIWEB high
    ;lda PD4
    ;ora #PIWEB
    ;sta PD4

    ; Enable PIB edge interrupt (PIIB) so IRQPIB vector fires
    lda EIER
    ora #PIBIRQENABLE       ; enable PIB edge source
    sta EIER

    rep #$20
    .setting "RegA16", true
    rts

IRQHandler_IRQPIB:

    php
    sep #$20           ; 8-bit A
    .setting "RegA16", false
    pha                ; save A

    ; Read PIBFR to determine which PIR caused the interrupt, check bits and branch accordingly
    ; Only PIR7 is enabled for now, so we know it's PIR7 that caused the interrupt. Skipping PIR3/PIR7 check.

    ;lda PIR2   ; CMD_hi - reserved for future expansion
    lda PIR_CMD_LO   ; CMD_lo

    cmp #PIB_CMD_PRINT_CHAR
    beq pib_print_char

    cmp #PIB_CMD_CLEAR_SCREEN
    beq pib_clear_screen

    cmp #PIB_CMD_DRAW_RECT
    beq pib_draw_rect

    bra IRQHandler_IRQPIB_out   ; unrecognized command

pib_print_char
    lda PIR_PARAM4   ; ascii char to print (this read clears the interrupt)
    jsr print_char_serial

    rep #$20    ; 16-bit A
    .setting "RegA16", true
    jsr print_char_vga
    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_clear_screen:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    rep #$20    ; 16-bit A
    .setting "RegA16", true
    jsr Init_VGA
    lda #'>'
    jsr print_char_vga    
    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_draw_rect:
    ; dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, height_lo, height_hi, color_lo, color_hi, filled


    lda PIR_PARAM4   ; (this read clears the interrupt)

    jsr crlf_serial

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    ;lda #'%'
    ;jsr print_char_vga  


    lda $F00000
    sta fill_region_start_x
    jsr print_hex16_serial

    lda $F00002
    sta fill_region_start_y
    jsr print_hex16_serial

    lda $F00004
    clc
    adc $F00000
    sta fill_region_end_x
    jsr print_hex16_serial

    lda $F00006
    clc
    adc $F00002
    sta fill_region_end_y
    jsr print_hex16_serial

    lda $F00008
    sta fill_region_color
    jsr print_hex16_serial

    ; to do: support 'filled' param - for now, always filled
    jsr gfx_FillRegionVRAM  

    ;lda #'&'
    ;jsr print_char_vga  


    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

IRQHandler_IRQPIB_out:
    pla
    plp		; return to original 16-bit A or 8-bit A state based on caller
    .setting "RegA16", true
    rti
