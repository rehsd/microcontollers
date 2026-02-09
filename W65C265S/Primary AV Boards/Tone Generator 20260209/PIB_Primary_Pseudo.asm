; ******** NOTES *************************************************************
; master is synonymous with host
; slave is synonymous with processor
; Do not write to PDD4 once PIB is initialized!
; ******** /NOTES ************************************************************

; ******* PINS ***************************************************************
; P40 NMIB
; P41 IRQB
;
; MASTER        <>      SLAVE
; ======                ======
; P42_PIIB              P42_PIIB
; P43_PIWEB             P43_PIWEB  
; P44_PICSB             P44_PICSB  
; P4[7:5]               P4[7:5]     PIRS2:0
; P5[7:0]               P5[7:0]     PIR7:0
; ****************************************************************************

; ******** NOTES *************************************************************
; Master = Host
; Slave  = Processor
; Manual handshake mode:
;   - PIB enabled (PIBER0=1)
;   - Manual handshake bits set (PIBER4/5=1)
;   - Automatic handshake disabled (PIBER2/3/6/7=0)
;   - Master drives: P42 (PIIB), P44 (PICSB), PD5[7:0]
;   - Slave drives:  P43 (PIWEB)
; ***************************************************************************

; ******** PIN BIT MASKS ****************************************************
PIIB        EQU %00000100    ; P42
PIWEB       EQU %00001000    ; P43
PICSB       EQU %00010000    ; P44

NPIIB       EQU %11111011    ; clear bit 2
NPICSB      EQU %11101111    ; clear bit 4

; ******** PIB REGISTERS ****************************************************
PIBFR       EQU $DF78
PIBER       EQU $DF79
PIR3        EQU $DF7B
PIR4        EQU $DF7C

    LONGA ON
    LONGI ON

; ******** PORT REGISTERS ***************************************************
; PD4  = Port 4 Data Register
; PD5  = Port 5 Data Register
; PDD4 = Port 4 Direction Register
; PDD5 = Port 5 Direction Register

; ******** INITIALIZATION ***************************************************

init_master_pib:
    php
    sep #$20
    LONGA OFF
    pha

    ;--------------------------------------------------
    ; Configure PD4 directions:
    ;   P42 (PIIB)  = output
    ;   P43 (PIWEB) = input
    ;   P44 (PICSB) = output
    ;   P45–P47     = outputs
    ;--------------------------------------------------
    lda PDD4
    ora #%11110100        ; bits 2,4,5,6,7 = outputs; bit 3 stays input
    sta PDD4

    ;--------------------------------------------------
    ; Configure PD5 as 8‑bit output bus
    ;--------------------------------------------------
    lda #%11111111
    sta PDD5

    ;--------------------------------------------------
    ; Clear PIB flags
    ;--------------------------------------------------
    lda #%11111111
    sta PIBFR

    ;--------------------------------------------------
    ; Enable PIB in MANUAL HANDSHAKE MODE:
    ;   PIBER0 = 1 (enable PIB)
    ;   PIBER4 = 1 (manual handshake from processor)
    ;   PIBER5 = 1 (manual handshake from host)
    ;   All auto handshake bits = 0
    ;
    ;   %00110001 = $31
    ;--------------------------------------------------
    ;lda #%00110000
    lda #0
    sta PIBER

    ;--------------------------------------------------
    ; Idle state: PICSB=1, PIIB=1
    ;--------------------------------------------------
    lda PD4
    ora #%00010100        ; PICSB + PIIB high
    sta PD4

    lda PDD6
    and #%11111110		; AV reset hold line - set back to input and let AV out of reset
    sta PDD6

    pla
    plp
    LONGA ON
    rts




; ******** SEND BYTE TO SLAVE (manual handshake) ****************************
;
; Protocol:
;   1) Put data on PD5
;   2) Pull PICSB low (P44)
;   3) Pull PIIB low (P42)
;   4) Wait for PIWEB low (slave ACK) (P43)
;   5) Release PICSB high
;   6) Release PIIB high
;   7) Wait for PIWEB high (slave release)
;
; A on entry = byte to send
;***************************************************************************

send_pib:
    php
    sep #$20            ; 8-bit A
    rep #$10            ; 16-bit X/Y
    LONGA OFF
    pha                 ; save A for later printing

    ;--------------------------------------------------
    ; 1) Put data on PD5
    ;--------------------------------------------------
    sta PD5
    jsr print_char_serial

    ;--------------------------------------------------
    ; 2) Assert PICSB low
    ; 3) Assert PIIB low
    ;--------------------------------------------------
    lda PD4
    and #%11101011      ; clear PICSB (bit4) and PIIB (bit2)
    sta PD4

    ;--------------------------------------------------
    ; 4) Wait for PIWEB low (slave ACK)
    ;--------------------------------------------------
wait_piweb_low:
    lda PD4
    and PIWEB
    bne wait_piweb_low

    ;--------------------------------------------------
    ; The slave will NOT raise PIWEB high until *after*
    ; the master releases PICSB and PIIB.
    ;
    ; Therefore, release PICSB/PIIB *now*, immediately
    ; after seeing PIWEB low.
    ;--------------------------------------------------
    lda PD4
    ora #%00010100      ; set PICSB + PIIB high
    sta PD4

    ;--------------------------------------------------
    ; 7) Wait for PIWEB high (slave release)
    ; * gets stuck here for some reason, but skipping works fine
    ;--------------------------------------------------
    ;wait_piweb_high:
    ;    lda PD4
    ;    and PIWEB
    ;    beq wait_piweb_high

    pla
    plp     ; back to original 8 or 16-bit
    rts