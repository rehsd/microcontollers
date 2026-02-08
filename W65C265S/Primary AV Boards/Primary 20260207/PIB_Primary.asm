
; ******* PINS ***************************************************************
; P40 NMIB - not used
; P41 IRQB - not used
;
; MASTER        <>      SLAVE
; ======                ======
; P4[7:0]               P4[7:0]
; P5[7:0]               P5[7:0]
; ****************************************************************************

; ******** NOTES *************************************************************
; Master = Host
; Slave  = Processor
; The 65265 appears to support PIB as a slave only.
; It does not have on-chip hardware support for PIB master.
; Master signaling must be with PIB disabled, and done manually.
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
; !! below registers not relevant on the master -- just on the slave
;PIR3        EQU $DF7B
;PIR4        EQU $DF7C
;... up to PIR7

PIRS7   EQU %11100000    ; PIR7 value for mailbox slot selection
PIRS6   EQU %11000000    ; PIR6 value for mailbox slot selection
PIRS5   EQU %10100000    ; PIR5 value for mailbox slot selection
PIRS4   EQU %10000000    ; PIR4 value for mailbox slot selection
PIRS3   EQU %01100000    ; PIR3 value for mailbox slot selection
PIRS2   EQU %01000000    ; PIR2 value for mailbox slot selection

    LONGA ON
    LONGI ON

; ******** PORT REGISTERS ***************************************************
; These are already set in 65265_Primary.asm
;   PD4  = Port 4 Data Register
;   PD5  = Port 5 Data Register
;   PDD4 = Port 4 Direction Register
;   PDD5 = Port 5 Direction Register
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
    ; Clear PIB flags ? not needed
    ;--------------------------------------------------
    ;lda #%11111111
    ;sta PIBFR

    lda #0      ; disable PIB on the master -- it's not supported -- only has slave support
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
    ; 2) Select mailbox (PIR)
    ; 3) Assert PICSB low
    ; 4) Assert PIIB low
    ;--------------------------------------------------
    lda PD4
    ora #PIRS7          ; can use PIR2 to PIR7. Auto-handshake support for PIR3 and PIR7 on slave.
    sta PD4             ; this sta might not be necessary
    and #%11101011      ; clear PICSB (bit4) and PIIB (bit2)
    sta PD4

    ;--------------------------------------------------
    ; 5) Wait for PIWEB low (slave ACK)
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


    pla
    plp     ; back to original 8 or 16-bit
    rts