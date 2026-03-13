; RTC uses DS3234 & supports SPI modes 1 or 2 (not 0 or 4). See https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html for modes.
; RTC details: https://www.sparkfun.com/products/10160, https://www.sparkfun.com/datasheets/BreakoutBoards/DS3234.pdf

; all code in this module is assumed to use 8-bit A, 16-bit X/Y
.setting "RegA16", false
.setting "RegXY16", true

SPI_MISO            .equ %00000001          ; INPUT
SPI_MOSI            .equ %00000010
SPI_SCK             .equ %00000100
SPI_MISO_SDCARD     .equ %00001000          ; INPUT
SPI_CS3             .equ %00010000
SPI_CS2             .equ %00100000
SPI_CS1_SDCARD      .equ %01000000
SPI_CS0_RTC         .equ %10000000

; CS bits are 1 (inactive), SCK is 0 (low), MOSI is 1 (high/idle)
//SPI_CS_IDLE  .equ (SPI_MISO_SDCARD|SPI_CS3|SPI_CS2|SPI_CS1_SDCARD|SPI_CS0_RTC|SPI_MOSI)
SPI_CS_IDLE  .equ (SPI_CS3|SPI_CS2|SPI_CS1_SDCARD|SPI_CS0_RTC|SPI_MOSI)

; =============================================================================
; SPI MODES
; =============================================================================
; Mode | CPOL | CPHA | Clock Idle | Data Sampled (Latched) On:
; -----------------------------------------------------------------------------
;  0   |  0   |  0   |    Low     | Leading Edge (Rising: Low  -> High)
;  1   |  0   |  1   |    Low     | Trailing Edge (Falling: High -> Low)
;  2   |  1   |  0   |    High    | Leading Edge (Falling: High -> Low)
;  3   |  1   |  1   |    High    | Trailing Edge (Rising: Low  -> High)
; -----------------------------------------------------------------------------
; Mode 0: Used by most SD Cards.
; Mode 1: Common for RTCs (e.g., DS1306/DS3234).
; =============================================================================

Init_SPI:
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true
    ;pha

    lda #%01111111
    sta VIA2_IER    ; disable all interrupts
    lda #%11110110  
    sta VIA2_DDRA   ; all output except miso (x2)
    lda #SPI_CS_IDLE
    sta VIA2_PORTA  ; set all CS high (inactive)

    ;pla
    plp
    rts

rtc_get_time:
	; addr 0x02 = hours
	; addr 0x01 = minutes
	; addr 0x00 = seconds

    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true

    lda #SPI_CS_IDLE
    and #~SPI_CS0_RTC       ; CS low
    sta VIA2_PORTA

    lda #$00     ; addr - seconds
    jsr spi_rtc_writebyte
    jsr spi_rtc_readbyte
    sta RTC_SEC
    jsr spi_rtc_readbyte    ; minutes
    sta RTC_MIN
    jsr spi_rtc_readbyte    ; hours
    sta RTC_HRS

    lda #SPI_CS_IDLE
    sta VIA2_PORTA

    ; **** print it *****
        ; --- Print Hours ---
            lda RTC_HRS
            lsr a
            lsr a
            lsr a
            lsr a               ; Tens
            clc
            adc #$30
            jsr pib_print_char
            
            lda RTC_HRS
            and #$0F            ; Ones
            clc
            adc #$30
            jsr pib_print_char

            lda #':'
            jsr pib_print_char

            ; --- Print Minutes ---
            lda RTC_MIN
            lsr a
            lsr a
            lsr a
            lsr a               ; Tens
            clc
            adc #$30
            jsr pib_print_char
            
            lda RTC_MIN
            and #$0F            ; Ones
            clc
            adc #$30
            jsr pib_print_char

            lda #':'
            jsr pib_print_char

            ; --- Print Seconds ---
            lda RTC_SEC
            lsr a
            lsr a
            lsr a
            lsr a               ; Tens
            clc
            adc #$30
            jsr pib_print_char
            
            lda RTC_SEC
            and #$0F            ; Ones
            clc
            adc #$30
            jsr pib_print_char

    plp
    rts

rtc_set_time:
	; addr 0x82 = hours
	; addr 0x81 = minutes
	; addr 0x80 = seconds
    
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true

    lda #SPI_CS_IDLE
    and #~SPI_CS0_RTC       ; CS low
    sta VIA2_PORTA

    lda #$80     ; addr - seconddss
    jsr spi_rtc_writebyte
    lda #$00    ; xx:xx:00
    jsr spi_rtc_writebyte
    lda #$23    ; xx:18:xx
    jsr spi_rtc_writebyte
    lda #$20    ; 20:xx:xx
    jsr spi_rtc_writebyte


    lda #SPI_CS_IDLE
    sta VIA2_PORTA

    plp
    rts

rtc_get_date:
	; addr 0x06 = year
	; addr 0x05 = month
	; addr 0x04 = day of month

    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true

    lda #SPI_CS_IDLE
    and #~SPI_CS0_RTC       ; CS low
    sta VIA2_PORTA

    lda #$04     ; addr
    jsr spi_rtc_writebyte
    jsr spi_rtc_readbyte
    sta RTC_DAY
    jsr spi_rtc_readbyte
    sta RTC_MONTH
    jsr spi_rtc_readbyte
    sta RTC_YEAR
    lda #SPI_CS_IDLE
    sta VIA2_PORTA

    lda #SPI_CS_IDLE
    sta VIA2_PORTA


    ; ******* print it *****

            ; --- Print Month ---
            lda RTC_MONTH
            lsr a
            lsr a
            lsr a
            lsr a
            clc
            adc #$30
            jsr pib_print_char
            
            lda RTC_MONTH
            and #$0F
            clc
            adc #$30
            jsr pib_print_char

            lda #'/'
            jsr pib_print_char

        ; --- Print Day ---
            lda RTC_DAY
            lsr a
            lsr a
            lsr a
            lsr a               ; Tens
            clc
            adc #$30
            jsr pib_print_char
            
            lda RTC_DAY
            and #$0F            ; Ones
            clc
            adc #$30
            jsr pib_print_char

            lda #'/'
            jsr pib_print_char

            ; --- Print Year ---
            lda #'2'
            jsr pib_print_char
            lda #'0'
            jsr pib_print_char

            lda RTC_YEAR
            lsr a
            lsr a
            lsr a
            lsr a
            clc
            adc #$30
            jsr pib_print_char
            
            lda RTC_YEAR
            and #$0F
            clc
            adc #$30
            jsr pib_print_char

    plp
    rts

rtc_set_date:
	; addr 0x86 = year
	; addr 0x85 = month
	; addr 0x84 = day of month

    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true

    lda #SPI_CS_IDLE
    and #~SPI_CS0_RTC       ; CS low
    sta VIA2_PORTA

    lda #$84     ; addr - day of month
    jsr spi_rtc_writebyte
    lda #$12    ; 12th
    jsr spi_rtc_writebyte

    lda #$03    ; March
    jsr spi_rtc_writebyte   ; addr - month

    lda #$26 ; 2026
    jsr spi_rtc_writebyte   ; addr - year

    lda #SPI_CS_IDLE
    sta VIA2_PORTA

    plp
    rts

rtc_get_temperature:
    ; addr 0x12 = temp lsb
    ; addr 0x11 = temp msb
    
    php
    sep #$20    ; 8-bit A
    rep #$10    ; 16-bit X/Y
    .setting "RegA16", false
    .setting "RegXY16", true

    lda #SPI_CS_IDLE
    and #~SPI_CS0_RTC       ; CS low
    sta VIA2_PORTA

    lda #$11     ; addr
    jsr spi_rtc_writebyte
    jsr spi_rtc_readbyte
    pha

    lda #SPI_CS_IDLE
    sta VIA2_PORTA
    
    pla
    jsr print_hex_serial

    ;jsr spi_rtc_readbyte   ; lsb
    ;jsr print_hex_serial

    ; --- Binary to BCD Conversion ---
    ldx #0                  ; Tens
    gt_sub_ten:
        cmp #10
        bcc gt_done_ten
        sec
        sbc #10
        inx
        bra gt_sub_ten
    gt_done_ten:
        ; A = Ones, X = Tens
        sta TempCalcs                 ; temporary storage
        txa
        asl
        asl
        asl
        asl
        ora TempCalcs
        sta TempCalcs
        
    ; --- Print Tens ---
        lsr a
        lsr a
        lsr a
        lsr a               ; Extract High Nibble
        clc
        adc #$30            ; Convert to ASCII
        jsr pib_print_char

        ; --- Print Ones ---
        lda TempCalcs
        and #$0F            ; Extract Low Nibble
        clc
        adc #$30            ; Convert to ASCII
        jsr pib_print_char

        lda #'C'
        jsr pib_print_char
            
        plp
        rts


spi_rtc_writebyte:
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true

    ldx #8                      ; send 8 bits
    rtc_wb_loop:
        asl                         ; shift next bit into carry
        tay                         ; save remaining bits for later
        bcc rtc_wb_sendbit
            lda VIA2_PORTA
            
            ora #SPI_MOSI
            bra rtc_wb_cont
        rtc_wb_sendbit:
            lda VIA2_PORTA 

            and #~SPI_MOSI
        rtc_wb_cont:
            sta VIA2_PORTA              ; clock high

            ora #SPI_SCK                ; prepare to raise SCK
            sta VIA2_PORTA              ; clock high

            and #~SPI_SCK               ; prepare to lower SCK
            sta VIA2_PORTA              ; clock low (falling edge latches data)
            
            tya                         ; restore bits
            dex
            bne rtc_wb_loop

    plp
    rts

spi_rtc_readbyte:
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true

    ldx #8                      ; we'll read 8 bits
    ldy #0                      ; initialize result register

    rtc_rb_loop:
        lda VIA2_PORTA

        ora #SPI_MOSI               ; keep MOSI high (standard for reads), SCK low
        and #~SPI_SCK                ; clock low
        sta VIA2_PORTA
        
        ora #SPI_SCK              ; clock high (falling edge)
        sta VIA2_PORTA
        
        and #~SPI_SCK               ; clock low
        sta VIA2_PORTA

        lda VIA2_PORTA                   ; read next bit

        and #SPI_MISO
       
        clc
        beq rtc_rb_notset
        sec
    rtc_rb_notset:
        tya                         ; get partial result
        rol                         ; rotate carry bit in
        tay  
                               ; save back to Y
        dex
        bne rtc_rb_loop
    
    tya                         ; return result in A
    plp
    rts



// spi_sdcard_writebyte:
//   ; Tick the clock 8 times with descending bits on MOSI
//   ; SD communication is mostly half-duplex so we ignore anything it sends back here
//     ldx #8                      ; send 8 bits
//     writebyte_loop:
//     asl                         ; shift next bit into carry
//     tay                         ; save remaining bits for later
//     lda #0
//     bcc sendbit                ; if carry clear, don't set MOSI for this bit
//     ora #SPI_MOSI

//     sendbit:
//         sta VIA2_PORTA                   ; set MOSI (or not) first with SCK low
//         eor #SPI_SCK
//         sta VIA2_PORTA                   ; raise SCK keeping MOSI the same, to send the bit
//         tya                         ; restore remaining bits to send
//         dex
//         bne writebyte_loop                   ; loop if there are more bits to send
//     rts


// spi_sdcard_readbyte:
//   ; Enable the card and tick the clock 8 times with MOSI high, 
//   ; capturing bits from MISO and returning them

//     ldx #8                      ; we'll read 8 bits
//     readByteLoop:
//         lda #SPI_MOSI                ; enable card (CS low), set MOSI (resting state), SCK low
//         sta VIA2_PORTA
//         lda #(SPI_MOSI | SPI_SCK)       ; toggle the clock high
//         sta VIA2_PORTA

//         lda VIA2_PORTA                   ; read next bit
//         and #SPI_MISO

//         clc                         ; default to clearing the bottom bit
//         beq readByteBitNotSet              ; unless MISO was set
//         sec                         ; in which case get ready to set the bottom bit
//     readByteBitNotSet:
//         tya                         ; transfer partial result from Y
//         rol                         ; rotate carry bit into read result
//         tay                         ; save partial result back to Y

//         dex                         ; decrement counter
//         bne readByteLoop                   ; loop if we need to read more bits
//   rts