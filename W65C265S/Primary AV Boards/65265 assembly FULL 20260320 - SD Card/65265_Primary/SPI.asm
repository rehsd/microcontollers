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

SPI_SDCard_SendCommand:

    lda VIA2_PORTA           ; pull CS low to begin command
    and #~SPI_CS1_SDCARD
    sta VIA2_PORTA

    ldy #0
    lda (SDCard_Command_Address),y    ; command byte
    jsr spi_sdcard_writebyte
    ldy #1
    lda (SDCard_Command_Address),y    ; data 1
    jsr spi_sdcard_writebyte
    ldy #2
    lda (SDCard_Command_Address),y    ; data 2
    jsr spi_sdcard_writebyte
    ldy #3
    lda (SDCard_Command_Address),y    ; data 3
    jsr spi_sdcard_writebyte
    ldy #4
    lda (SDCard_Command_Address),y    ; data 4
    jsr spi_sdcard_writebyte
    ldy #5
    lda (SDCard_Command_Address),y    ; crc
    jsr spi_sdcard_writebyte

    jsr SPI_WaitResult
    pha

    ; End command

    jsr spi_sdcard_readbyte ; extra 8 clocks for the card to finish

    lda #SPI_CS_IDLE   ; set CS high again
    sta VIA2_PORTA

    pla   ; restore result code
    rts

SPI_SDCard_SendCommand_NoCSToggle:

    ;lda VIA2_PORTA           ; pull CS low to begin command
    ;and #~SPI_CS1_SDCARD
    ;sta VIA2_PORTA

    ldy #0
    lda (SDCard_Command_Address),y    ; command byte
    jsr spi_sdcard_writebyte
    ldy #1
    lda (SDCard_Command_Address),y    ; data 1
    jsr spi_sdcard_writebyte
    ldy #2
    lda (SDCard_Command_Address),y    ; data 2
    jsr spi_sdcard_writebyte
    ldy #3
    lda (SDCard_Command_Address),y    ; data 3
    jsr spi_sdcard_writebyte
    ldy #4
    lda (SDCard_Command_Address),y    ; data 4
    jsr spi_sdcard_writebyte
    ldy #5
    lda (SDCard_Command_Address),y    ; crc
    jsr spi_sdcard_writebyte

    jsr SPI_WaitResult
    pha

    ; End command

    jsr spi_sdcard_readbyte ; extra 8 clocks for the card to finish

    ;lda #SPI_CS_IDLE   ; set CS high again
    ;sta VIA2_PORTA

    pla   ; restore result code
    rts    

SPI_WaitResult:
  ; Wait for the SD card to return something other than $ff
  ; lda #'w'
  ; jsr print_char_serial
  
  jsr spi_sdcard_readbyte
  cmp #$ff
  beq SPI_WaitResult
  rts

spi_sdcard_writebyte:
    ; mode 0
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true
    phx
    phy

    ldx #8                      ; send 8 bits
    sd_wb_loop:
        asl                         ; shift next bit into carry
        tay                         ; save remaining bits for later
        bcc sd_wb_sendzero
        lda VIA2_PORTA
        ora #SPI_MOSI               ; set mosi high
        bra sd_wb_clock
    sd_wb_sendzero:
        lda VIA2_PORTA
        and #~SPI_MOSI              ; set mosi low
    sd_wb_clock:
        sta VIA2_PORTA              ; apply mosi with sck low (mode 0)
        ora #SPI_SCK                ; prepare to raise sck
        sta VIA2_PORTA              ; sck high (sd card samples here)
        and #~SPI_SCK               ; prepare to lower sck
        sta VIA2_PORTA              ; sck low
        tya                         ; restore bits
        dex
        bne sd_wb_loop

        ply
        plx
        plp
        rts

spi_sdcard_readbyte:
    ; mode 0
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true
    phx
    phy

    ldx #8                      ; read 8 bits
    ldy #0                      ; result container
    sd_rb_loop:
        lda VIA2_PORTA
        ora #SPI_MOSI               ; mosi high during reads
        and #~SPI_SCK               ; ensure sck low
        sta VIA2_PORTA
        ora #SPI_SCK                ; sck high
        sta VIA2_PORTA              ; data is valid on rising edge
        lda VIA2_PORTA              ; read port
        and #SPI_MISO_SDCARD        ; check sd miso bit
        clc
        beq sd_rb_shift
        sec
    sd_rb_shift:
        tya                         ; get result
        rol                         ; shift bit in
        tay                         ; save result
        lda VIA2_PORTA
        and #~SPI_SCK               ; sck back to low
        sta VIA2_PORTA
        dex
        bne sd_rb_loop

        tya                         ; return byte in a
        ply
        plx
        plp
        rts

SPI_SDCard_SendCommand12:
    ;.cmd12 ; STOP_TRANSMISSION
    lda #<cmd12_bytes
    sta SDCard_Command_Address
    lda #>cmd12_bytes
    sta SDCard_Command_Address+1
    jsr SPI_SDCard_SendCommand
    rts  

SPI_SDCard_SendCommand17:
    ;.cmd17 ; READ_SINGLE_BLOCK
    lda #<cmd17_bytes
    sta SDCard_Command_Address
    lda #>cmd17_bytes
    sta SDCard_Command_Address+1
    jsr prep_ram_command    ; insert LBA
    jsr SPI_SDCard_SendCommand_NoCSToggle
    rts

SPI_SDCard_SendCommand18:
    ;.cmd18 ; READ_MULTIPLE_BLOCK
    lda #<cmd18_bytes
    sta SDCard_Command_Address
    lda #>cmd18_bytes
    sta SDCard_Command_Address+1
    jsr prep_ram_command
    jsr SPI_SDCard_SendCommand_NoCSToggle
    rts

SPI_SDCard_SendCommand24:
    ;.cmd24 ; WRITE_BLOCK
    lda #<cmd24_bytes
    sta SDCard_Command_Address
    lda #>cmd24_bytes
    sta SDCard_Command_Address+1
    jsr prep_ram_command
    jsr SPI_SDCard_SendCommand_NoCSToggle
    rts

Init_Failure:
    lda #'X'
    jsr print_char_serial
    stp     //just give up and quit :)

;Command sequences
    cmd0_bytes:    ;0x40 + command number   ; GO_IDLE_STATE
    .byte $40, $00, $00, $00, $00, $95
    cmd1_bytes:                             ; SEND_OP_COND              (legacy)
    .byte $41, $00, $00, $00, $00, $F9
    cmd8_bytes:                             ; SEND_IF_COND
    .byte $48, $00, $00, $01, $aa, $87
    cmd12_bytes:                            ; STOP_TRANSMISSION
    .byte $4C, $00, $00, $00, $00, $61    
    cmd13_bytes:                            ; GET_STATUS
    .byte $4D, $00, $00, $00, $00, $FF
    cmd17_bytes:                            ; READ_SINGLE_BLOCK
    .byte $51, $00, $00, $00, $00, $FF
    cmd18_bytes:                            ; READ_MULTIPLE_BLOCK
    .byte $52, $00, $00, $00, $00, $E1
    cmd24_bytes:                            ; WRITE_BLOCK
    .byte $58, $00, $00, $00, $00, $FF
    cmd41_bytes:                            ; SD_SEND_OP_COND           (modern)
    .byte $69, $40, $00, $00, $00, $77
    cmd55_bytes:                            ; APP_CMD
    .byte $77, $00, $00, $00, $00, $65


; ****************************************************************************
; COP interface
; ****************************************************************************
test_sdcard_full:
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true

    ; --- Buffer for write data --- var @ $1200
    lda #$00
    sta SDCard_Buffer_Ptr
    lda #$12
    sta SDCard_Buffer_Ptr+1

    jsr sdcard_init

    ; Set LBA sector to write to for testing
    ldx #$0010              ; low 16 bits
    ldy #$0000              ; high 16 bits
    ; DF8475800 offset 
    ; ldx #$23AC            ; low 16 bits
    ; ldy #$06FC            ; high 16 bits
    jsr sdcard_set_lba

    ; Fill write buffer with test pattern ($00,$01,$02,$03,...)
    ldy #0
    test_fill_loop:
        tya
        sta (SDCard_Buffer_Ptr),y
        iny
        cpy #512
        bne test_fill_loop

    ; Write buffer to SDCard
    lda #'W'
    jsr print_char_serial
    jsr sdcard_write_sector
    cmp #0
    beq test_write_ok
    jsr print_hex_serial    ; print error code
    bra test_fail

    test_write_ok:
        ; Clear the buffer so we know the read is real
        lda #'x'
        jsr print_char_serial
        ldy #0
        lda #$00
        test_clear_loop:
            sta (SDCard_Buffer_Ptr),y
            iny
            cpy #512
            bne test_clear_loop

        ; Read sector back from SDCard
        lda #'R'
        jsr print_char_serial
        jsr sdcard_read_sector
        cmp #0
        beq test_read_ok
        jsr print_hex_serial    ; if error, print error code
        bra test_fail

    test_read_ok:
        ; Verify the data (first 16 bytes)
        lda #'V'
        jsr print_char_serial        
        ldy #0
    test_verify_loop:
        tya                     ; check against the pattern we wrote
        cmp (SDCard_Buffer_Ptr),y
        bne test_data_mismatch
        iny
        cpy #16
        bne test_verify_loop

        ; Success!
        lda #'$'
        jsr print_char_serial
        plp
        rts

    test_data_mismatch:
        lda #'M'                ; M for Mismatch
        jsr print_char_serial
        lda (SDCard_Buffer_Ptr),y
        jsr print_hex_serial    ; show what we actually got
        bra test_fail

    test_fail:
        lda #'X'
        jsr print_char_serial
        plp
        rts
        
sdcard_init:
    ; already done in Init_SPI (set idle)
        ; lda #(SPI_CS | SPI_SCK | SPI_MOSI)      ;SPI_MISO is input
        ; sta VIA2_DDRA  ;control

    ; drop clock low
    ; lda #(SPI_CS | SPI_MOSI)

    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true

    jsr print_newline_serial
    lda #'}'
    jsr print_char_serial

    lda #SPI_CS_IDLE
    and #~SPI_SCK               ; SCK low
    sta VIA2_PORTA

    ldx #160                    ; 80 full clock cycles to give card time to initiatlize

    cop_init_loop:
        eor #SPI_SCK
        sta VIA2_PORTA
        dex
        bne cop_init_loop

    cop_try00:                  ; GO_IDLE_STATE
        lda #$00                     ; debug output
        jsr print_hex_serial
        jsr print_newline_serial
        lda #<cmd0_bytes
        sta SDCard_Command_Address
        lda #>cmd0_bytes
        sta SDCard_Command_Address+1
        jsr SPI_SDCard_SendCommand
        ; Expect status response $01 (not initialized)
        cmp #$01
        bne cop_try00

    cop_try08:                  ; SEND_IF_COND
        lda #$08                      ; debug output
        jsr print_hex_serial       
        jsr print_newline_serial
        lda #<cmd8_bytes
        sta SDCard_Command_Address
        lda #>cmd8_bytes
        sta SDCard_Command_Address+1
        jsr SPI_SDCard_SendCommand
        ; Expect status response $01 (not initialized)
        cmp #$01
        bne cop_try08

        jsr spi_sdcard_readbyte
        jsr spi_sdcard_readbyte
        jsr spi_sdcard_readbyte
        jsr spi_sdcard_readbyte

    cop_try55:                  ; APP_CMD
        ldx #10
        jsr delay_ms

        lda #$55                    ; debug output
        jsr print_hex_serial 
        jsr print_newline_serial
        lda #<cmd55_bytes
        sta SDCard_Command_Address
        lda #>cmd55_bytes
        sta SDCard_Command_Address+1
        jsr SPI_SDCard_SendCommand
        ; Expect status response $01 (not initialized)
        cmp #$01
        bne cop_try55

    cop_try41:                  ; SD_SEND_OP_COND
        lda #$41                    ; debug output
        jsr print_hex_serial
        jsr print_newline_serial
        lda #<cmd41_bytes
        sta SDCard_Command_Address
        lda #>cmd41_bytes
        sta SDCard_Command_Address+1
        jsr SPI_SDCard_SendCommand
        ; Expect status response $00 (initialized)
        cmp #$00
        bne cop_try55
    
    ;init complete  
    lda #'.'
    jsr print_char_serial
    plp  
    rts

sdcard_read_sector:
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true

    lda VIA2_PORTA
    and #~SPI_CS1_SDCARD
    sta VIA2_PORTA

    jsr SPI_SDCard_SendCommand17
    cmp #$00        ; command accepted?
    beq rs_wait_token
    plp             ; exit with error in A
    rts

    rs_wait_token:
        ;lda VIA2_PORTA
        ;and #~SPI_CS1_SDCARD ; re-assert cs
        ;sta VIA2_PORTA
    rs_token_loop:
        jsr spi_sdcard_readbyte
        cmp #$FE        ; look for data start token
        beq rs_do_read
        cmp #$FF        ; still busy?
        beq rs_token_loop
        bra rs_fail     ; got an actual error token
    rs_do_read:
        ldx #512        ; 16-bit counter
        ldy #0          ; 16-bit offset
    rs_loop:
        jsr spi_sdcard_readbyte
        ; jsr print_hex_serial            ; ***** temp *****
        sta (SDCard_Buffer_Ptr),y
        iny
        dex
        bne rs_loop
        jsr spi_sdcard_readbyte ; skip crc byte 1
        jsr spi_sdcard_readbyte ; skip crc byte 2
        lda #0          ; success code
        bra rs_exit
    rs_fail:
        pha             ; save error code
        lda #SPI_CS_IDLE
        sta VIA2_PORTA
        pla             ; restore error code
        plp
        rts
    rs_exit:
        pha
        jsr spi_sdcard_readbyte ; 8 extra clocks
        lda #SPI_CS_IDLE
        sta VIA2_PORTA
        pla             ; restore success (0)
        plp
        rts

sdcard_write_sector:
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true
    
    lda VIA2_PORTA
    and #~SPI_CS1_SDCARD
    sta VIA2_PORTA

    jsr SPI_SDCard_SendCommand24
    cmp #$00        ; command accepted?
    beq ws_start
    plp             ; exit with error in A
    rts

    ws_start:
        // lda VIA2_PORTA
        // and #~SPI_CS1_SDCARD ; keep cs low
        // sta VIA2_PORTA

        lda #$ff        ; one dummy byte
        jsr spi_sdcard_writebyte
        lda #$fe        ; send data start token
        jsr spi_sdcard_writebyte
        ldx #512        ; 16-bit counter
        ldy #0          ; 16-bit offset
    ws_loop:
        lda (SDCard_Buffer_Ptr),y
        jsr spi_sdcard_writebyte
        iny
        dex
        bne ws_loop
        lda #$ff        ; send dummy crc 1
        jsr spi_sdcard_writebyte
        lda #$ff        ; send dummy crc 2
        jsr spi_sdcard_writebyte
        jsr spi_sdcard_readbyte ; get data response
        and #$1f        ; mask status bits
        cmp #$05        ; 00101 = accepted
        beq ws_busy_wait
        lda #$01        ; error: write rejected
        bra ws_exit
    ws_busy_wait:
        jsr spi_sdcard_readbyte
        cmp #$ff        ; card pulls miso low while busy
        bne ws_busy_wait
        lda #0          ; success
    ws_exit:
        pha
        jsr spi_sdcard_readbyte ; 8 extra clocks
        lda #SPI_CS_IDLE
        sta VIA2_PORTA
        pla             ; restore status
        plp
        rts
                
sdcard_set_lba:
    ; Input: X = bits 15-0, Y = bits 31-16
    php
    rep #$30                    ; 16-bit A, 16-bit X/Y
    .setting "RegA16", true
    .setting "RegXY16", true

    ; --- Process High 16 (Y) ---
    tya                         ; A = bits 31-16
    xba                         ; A = bits 16-31 (swapped)
    sep #$20                    ; 8-bit A for storing
    .setting "RegA16", false
    sta SD_LBA                  ; Store bits 31-24
    rep #$20                    ; 16-bit A again
    .setting "RegA16", true
    tya                         ; A = bits 31-16
    sep #$20                    ; 8-bit A
    .setting "RegA16", false
    sta SD_LBA+1                ; Store bits 23-16

    ; --- Process Low 16 (X) ---
    rep #$20                    ; 16-bit A
    .setting "RegA16", true
    txa                         ; A = bits 15-0
    xba                         ; A = bits 0-15 (swapped)
    sep #$20                    ; 8-bit A
    .setting "RegA16", false
    sta SD_LBA+2                ; Store bits 15-8
    rep #$20                    ; 16-bit A
    .setting "RegA16", true
    txa                         ; A = bits 15-0
    sep #$20                    ; 8-bit A
    .setting "RegA16", false
    sta SD_LBA+3                ; Store bits 7-0

    plp
    rts

prep_ram_command:
    ; This routine copies the command template from ROM to RAM, 
    ; injects the LBA into the appropriate bytes, and then redirects 
    ; the command pointer to the RAM buffer for sending.
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true

    ldy #0

    prc_copy_loop:
        lda (SDCard_Command_Address),y
        sta SD_cmd_buffer,y
        iny
        cpy #6
        bne prc_copy_loop

        ; --- Inject LBA into bytes 1-4 of the buffer ---
        lda SD_LBA
        sta SD_cmd_buffer+1
        lda SD_LBA+1
        sta SD_cmd_buffer+2
        lda SD_LBA+2
        sta SD_cmd_buffer+3
        lda SD_LBA+3
        sta SD_cmd_buffer+4

        ; --- Redirect pointer to the RAM buffer ---
        lda #<SD_cmd_buffer
        sta SDCard_Command_Address
        lda #>SD_cmd_buffer
        sta SDCard_Command_Address+1

        plp
        rts



; ****************************************************************************
; UNUSED
; ****************************************************************************
sdcard_xfer:
    ; Not currently usd
    ; SPI mode 0
    ; This could be used to replace spi_sdcard_writebyte and spi_sdcard_readbyte (consolidated)
    ; Instead of jsr spi_sdcard_writebyte, use jsr sdcard_xfer
    ; Instead of jsr spi_sdcard_readbyte, use lda #$ff jsr sdcard_xfer
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true
    ldx #8

    sdcard_xfer_loop:
        asl
        tay
        bcc sdcard_xfer_sendzero
        lda VIA2_PORTA
        ora #SPI_MOSI
        bra sdcard_xfer_clock
    sdcard_xfer_sendzero:
        lda VIA2_PORTA
        and #~SPI_MOSI
    sdcard_xfer_clock:
        sta VIA2_PORTA
        ora #SPI_SCK
        sta VIA2_PORTA
        lda VIA2_PORTA
        and #SPI_MISO_SDCARD
        clc
        beq sdcard_xfer_shift
        sec
    sdcard_xfer_shift:
        tya
        rol
        tay
        lda VIA2_PORTA
        and #~SPI_SCK
        sta VIA2_PORTA
        tya
        dex
        bne sdcard_xfer_loop
        plp
        rts

sdcard_get_status:
    ; Not currently usd
    php
    sep #$20
    rep #$10
    .setting "RegA16", false
    .setting "RegXY16", true
    lda #<cmd13_bytes
    sta SDCard_Command_Address
    lda #>cmd13_bytes
    sta SDCard_Command_Address+1
    jsr SPI_SDCard_SendCommand
    pha
    jsr spi_sdcard_readbyte
    ; jsr spi_sdcard_readbyte
    tax
    pla
    plp
    rts
