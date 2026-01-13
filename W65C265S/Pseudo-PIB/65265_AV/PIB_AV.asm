; ******** NOTES *************************************************************
; Do not write to PDD4 once PIB is initialized!
; ******** /NOTES ************************************************************


; Core PIB control and data registers
PIBFR:              equ $DF78       ; PIB flag register
PIBER:              equ $DF79       ; PIB enable register

; PIR2:               equ $DF7A
PIR3:               equ $DF7B       ; PIB read register, bit 3
PIR4:               equ $DF7C
; PIR5:               equ $DF7D
; PIR6:               equ $DF7E
; PIR7:               equ $DF7F

;  PIBIRQENABLE:		equ %01000000		;$40


;--------------------------------------------------
; Port 4 Bit Masks (PIB Control — P42–P47)
;--------------------------------------------------
PIIB        EQU %00000100    ; P42 — Data Ready / STB       (master->slave)
PIWEB       EQU %00001000    ; P43 — Write Strobe / ACK     (slave->master)
PICSB       EQU %00010000    ; P44 — Chip Select B
PIRS0       EQU %00100000    ; P45 — Register Select 0
PIRS1       EQU %01000000    ; P46 — Register Select 1
PIRS2       EQU %10000000    ; P47 — Register Select 2

NPIIB       EQU %11111011    ; bit 2 = 0, others = 1
NPIWEB      EQU %11110111    ; bit 3 = 0, others = 1

    LONGA OFF
    LONGI OFF


;==================================================
; Slave PIB init
;  - PD5: data bus, all inputs
;  - PD4: PIWEB output, others input
;  - PIB: manual handshake mode, IRQ on PIIB via EIER/IRQPIB
;==================================================
init_slave_pib:

    sep #$20
    LONGA OFF

    ; PD5 = inputs (slave only reads data)
    lda #%00000000
    sta PDD5                ; pd5 = inputs

    ; PD4:
    ;   P42 (PIIB)  = input  (from master)
    ;   P43 (PIWEB) = output (to master)
    ;   P44 (PICSB) = input  (from master)
    ;   P45–P47     = inputs
    ;
    ; Read-modify-write so we only force PIWEB to output and
    ; leave P44_AMS / P43_FA15-related bits otherwise untouched.
    ;lda PDD4
    ;ora #PIWEB              ; set PIWEB as output, preserve others
    lda #%00001000
    sta PDD4

    ; Clear PIB flags
    ;lda #$FF
    ;sta PIBFR

    ; Manual handshake mode to match master:
    ;   bit0 = 1  (enable PIB)
    ;   bit4 = 1  (manual handshake from processor)
    ;   bit5 = 1  (manual handshake from host)
    ;   others = 0
    ;
    ;   %00110001 = $31
    ;lda #%00110000
    lda #0
    sta PIBER

    ; Idle: PIWEB high
    lda PD4
    ora #PIWEB
    sta PD4

    ; Enable PIB edge interrupt (PIIB) so IRQPIB vector fires
    ;lda EIER
    ;ora #PIBIRQENABLE       ; enable PIB edge source
    ;ora #NE64ENABLE         ; enable NE64 edge source
    ;sta EIER

    rep #$20
    LONGA ON
    rts

    
; ISR to receive data from master PIB
; - Detects PICSB/PIWEB
; - Latches the byte into PIR4
; - Asserts IRQB
; - Waits for the ISR to read PIR4
; - Automatically pulses P42 (PIREB) to acknowledge
; - Clears busy

IRQHandler_IRQPIB:

    php
    sep #$20           ; 8-bit A
    LONGA OFF
    pha                ; save A


    lda PD5

    ; assert PIWEB low
    lda PD4
    and NPIWEB
    sta PD4

    lda #'P'
    jsr print_char_serial

    ; wait for PICSB high
    pib_wait_picsb_high:
        lda PD4
        and #PICSB
        beq pib_wait_picsb_high

    ; wait for PIIB high
    pib_wait_piib_high:
        lda PD4
        and #PIIB
        beq pib_wait_piib_high

        ; release PIWEB high
        lda PD4
        ora #PIWEB
        sta PD4

    ; clear PIB interrupt source
    lda #PIBIRQENABLE
    sta PIBFR

    pla
    plp		; return to original 16-bit A or 8-bit A state based on caller
    rti


    LONGA ON
    LONGI ON        