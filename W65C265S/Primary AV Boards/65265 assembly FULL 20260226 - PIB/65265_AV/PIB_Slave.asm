
; Core PIB control and data registers
PIBFR              .equ $DF78       ; PIB flag register
PIBER              .equ $DF79       ; PIB enable register
PIR2               .equ $DF7A
PIR3               .equ $DF7B       ; PIB read register, bit 3
PIR4               .equ $DF7C
PIR5               .equ $DF7D
PIR6               .equ $DF7E
PIR7               .equ $DF7F

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


.setting "RegA16", false
.setting "RegXY16", false

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
    lda #%10001001
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

    ; Read PIBFR to determine which PIR caused the interrupt
    ; lda PIBFR   
    ; check bits and branch accordingly

    ; assuming only PIR7 for now
    lda PIR7           ; reading the PIR clears the interrupt for that PIR
    jsr print_char_serial

    pla
    plp		; return to original 16-bit A or 8-bit A state based on caller
    .setting "RegA16", true
    rti


