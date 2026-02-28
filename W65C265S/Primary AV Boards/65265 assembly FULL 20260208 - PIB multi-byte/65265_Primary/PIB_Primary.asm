
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
PIIB        = %00000100    ; P42
PIWEB       = %00001000    ; P43
PICSB       = %00010000    ; P44

NPIIB       = %11111011    ; clear bit 2
NPICSB      = %11101111    ; clear bit 4

; ******** PIB REGISTERS ****************************************************
PIBFR       = $DF78
PIBER       = $DF79
; !! below registers not relevant on the master -- just on the slave
;PIR3        EQU $DF7B
;PIR4        EQU $DF7C
;... up to PIR7

PIRS7   = %11100000    ; PIR7 value for mailbox slot selection
PIRS6   = %11000000    ; PIR6 value for mailbox slot selection
PIRS5   = %10100000    ; PIR5 value for mailbox slot selection
PIRS4   = %10000000    ; PIR4 value for mailbox slot selection
PIRS3   = %01100000    ; PIR3 value for mailbox slot selection
PIRS2   = %01000000    ; PIR2 value for mailbox slot selection

.include "../Common/PIB_Commands.asm"

.setting "RegA16", true
.setting "RegXY16", true

; ******** PORT REGISTERS ***************************************************
; These are already set in 65265_Primary.asm
;   PD4  = Port 4 Data Register
;   PD5  = Port 5 Data Register
;   PDD4 = Port 4 Direction Register
;   PDD5 = Port 5 Direction Register
; ******** INITIALIZATION ***************************************************

Init_PIB_master:
    php
    sep #$20
    .setting "RegA16", false
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
    .setting "RegA16", true
    rts

send_pib:
    ; A has byte to be sent to slave
    ; X has index of PIR mailbox number to use (2-7)

    ; ******** SEND BYTE TO SLAVE (manual handshake) ********
    ; Protocol:
    ;   1) Put data on PD5
    ;   2) Pull PICSB low (P44)
    ;   3) Pull PIIB low (P42)
    ;   4) Wait for PIWEB low (slave ACK) (P43)
    ;   5) Release PICSB high
    ;   6) Release PIIB high
    ;   7) Wait for PIWEB high (slave release)
    php
    sep #$20            ; 8-bit A
    rep #$10            ; 16-bit X/Y
    .setting "RegA16", false
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
    and #%00011111       ; clear PIRS value bits
    ;ora #PIRS7          ; can use PIR2 to PIR7. Auto-handshake support for PIR3 and PIR7 on slave (if enabled on slave).
    ora PIB_masks,x
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

PIB_masks:
    .byte 0, 0          ; offsets 0 and 1 (unused)
    .byte %01000000     ; 2: PIRS2
    .byte %01100000     ; 3: PIRS3 (Auto-handshake, if slave-enabled)
    .byte %10000000     ; 4: PIRS4
    .byte %10100000     ; 5: PIRS5
    .byte %11000000     ; 6: PIRS6
    .byte %11100000     ; 7: PIRS7 (Auto-handshake, if slave-enabled)        

; *************** PIB Commands **********************************************

pib_print_char:
    ; A has char to print

    ;                           CMD_hi+CMD_lo         Param1     Param2      Param3      Param4     Notes
    ; PIB_CMD_PRINT_CHAR        .equ  $0000           ; ascii         -           -           - 

    php
    sep #$30		; 8-bit A/X/Y
    .setting "RegA16", false
    .setting "RegXY16", false
    phx
    pha	; remember char

    ; set the command (0-65535)
    ldx #PIB_CMD_HI         ; PIRS2
    lda #>PIB_CMD_PRINT_CHAR
    jsr send_pib

    ldx #PIB_CMD_LO         ; PIRS3
    lda #<PIB_CMD_PRINT_CHAR
    jsr send_pib

    ; set param 1
    ; ldx #PIB_CMD_PARAM1   ; PIRS4
    ; lda #0
    ; jsr send_pib

    ; set param 2
    ; ldx #PIB_CMD_PARAM2   ; PIRS5
    ; lda #0
    ; jsr send_pib

    ; set param 3
    ; ldx #PIB_CMD_PARAM3   ; PIRS6
    ; lda #0
    ; jsr send_pib

    ; set param 4 (triggers slave interrupt)
    ldx #PIB_CMD_PARAM4     ; PIRS7
    pla ; get char back
    jsr send_pib                        


    plx
    plp
    rts

pib_clear_screen:
    php
    sep #$30		; 8-bit A/X/Y
    .setting "RegA16", false
    .setting "RegXY16", false
    phx
    pha

    ; set the command (0-65535)
    ldx #PIB_CMD_HI         ; PIRS2
    lda #>PIB_CMD_CLEAR_SCREEN
    jsr send_pib

    ldx #PIB_CMD_LO         ; PIRS3
    lda #<PIB_CMD_CLEAR_SCREEN
    jsr send_pib

    ; set param 1
    ; ldx #PIB_CMD_PARAM1   ; PIRS4
    ; lda #0
    ; jsr send_pib

    ; set param 2
    ; ldx #PIB_CMD_PARAM2   ; PIRS5
    ; lda #0
    ; jsr send_pib

    ; set param 3
    ; ldx #PIB_CMD_PARAM3   ; PIRS6
    ; lda #0
    ; jsr send_pib

    ; set param 4 (triggers slave interrupt)
    ldx #PIB_CMD_PARAM4     ; PIRS7
    lda #0
    jsr send_pib                        

    pla
    plx
    plp
    rts

pib_draw_rectangle:
    ;Before calling, write to dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, height_lo, height_hi, color_lo, color_hi, filled
    php
    sep #$30		; 8-bit A/X/Y
    .setting "RegA16", false
    .setting "RegXY16", false
    phx
    pha

    ; set the command (0-65535)
    ldx #PIB_CMD_HI         ; PIRS2
    lda #>PIB_CMD_DRAW_RECT
    jsr send_pib

    ldx #PIB_CMD_LO         ; PIRS3
    lda #<PIB_CMD_DRAW_RECT
    jsr send_pib

    ; set param 1
    ; ldx #PIB_CMD_PARAM1   ; PIRS4
    ; lda #0
    ; jsr send_pib

    ; set param 2
    ; ldx #PIB_CMD_PARAM2   ; PIRS5
    ; lda #0
    ; jsr send_pib

    ; set param 3
    ; ldx #PIB_CMD_PARAM3   ; PIRS6
    ; lda #0
    ; jsr send_pib

    ; set param 4 (triggers slave interrupt)
    ldx #PIB_CMD_PARAM4     ; PIRS7
    lda #0
    jsr send_pib                        

    pla
    plx
    plp
    rts    

; *************** /PIB Commands *********************************************