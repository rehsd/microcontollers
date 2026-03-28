;
;   VIA0    -Port B used for PSG0-1 control
;           -Port A used for common data to both PSGs
;
;   2 MHz oscillator used for PSGs
;   10 MHz used for sound card core

.setting "RegA16", false
.setting "RegXY16", false
.setting "HandleLongBranch", true

Init_Sound:
    sep #$30	; 8-bit A/X/Y
    lda #$00
    ;sta audio_data_to_write
    ;sta SND_MUSIC_PLAYING
    ;sta SND_ABORT_MUSIC

    lda #$FF        ; set VIA ports to output
    sta VIA0_DDRA
    sta VIA0_DDRB

    lda #<SND_RESET
    sta TUNE_PTR_LO
    lda #>SND_RESET
    sta TUNE_PTR_HI

    jsr PSG0_PlayTune
    jsr PSG1_PlayTune



    rep #$30	; 16-bit A/X/Y

    rts

PlayFromROM:
    ;load the data from ROM in variables


    ; **** OLD 65816 sound card code, where ROM was connected to PSG I/O ports
        ;PSG6 IOA0-IOA7 + IOB0-IOB7     --> ROM A0-A15
        ;PSG5 IOA0-IOA2                 --> ROM A16-A18
        ;PSG5 IOB0-IOB7                 --> ROM D0-D7

        ;PSG6 Register 7 = EnableB      --bit7=IOB (IN low Out high) - set *high* so we can write out ROM address on PSG:B    11000000=0xC0
        ;                               --bit6=IOA (IN low Out high) - set *high* so we can write out ROM address on PSG:A
        ;PSG5 Register 7 = EnableB      --bit7=IOB (IN low Out high) - set *low* so we can read ROM data on PSG:B             01000000=0x40
        ;                               --bit6=IOA (IN low Out high) - set *high* so we can write out ROM address on PSG:A

        ;PSG6 Register 14 = PSG I/O Port A    --write address of ROM  to access
        ;PSG6 Register 15 = PSG I/O Port B    --write address of ROM  to access
        ;PSG5 Register 14 = PSG I/O Port A    --write address of ROM  to access
        ;PSG5 Register 15 = PSG I/O Port B    --read data from ROM at supplied ROM address

    pha ;a to stack
    phx ;x to stack
    phy ;y to stack

    lda #1
    sta SND_MUSIC_PLAYING

    ;update to read 64 bytes and store in vars, then repeat until FF is read
    
        ;lda #$0E    ;Register = I/O port A - write ROM address to be read 
        ;jsr PSG0_setreg
        ;lda #$00    ;start at beginning of ROM
        ;jsr PSG0_writedata
        ;lda #$0F    ;Register = I/O port B - read address at previously specified ROM address
        ;jsr PSG0_setreg
        ;jsr PSG0_readdata    ;result in A register
        ;jsr print_hex_lcd  ;show it on LCD
    
    ;loop through memory and write to variables
    ;last byte of 64 of end marker (FF if no more data for this item)
    ;start at TonePeriodCourseLA and +1 each iteration

    ;lda #$07    ;Register = Enable
    ;jsr PSG0_setreg
    ;lda #%11111000    ;B out (high), A out (high), noise disabled, tone enabled = 01000000=40
    ;jsr PSG0_writedata

    ;lda #$07    ;Register = Enable
    ;jsr PSG1_setreg
    ;lda #%01111000    ;B in (low), A out (high), noise disabled, tone enabled = 01000000=40
    ;jsr PSG1_writedata

    ;ldx #$00
    ;lda #$00
    //sta Sound_ROW   ;start at row 0
    //sta SND_ROM_POS
    //sta SND_ROM_POS2
    //sta SND_ROM_POS3

    ;for now, not using top three bits of ROM address, write all 0's to these bits in the address - will add this support later
    ;lda #$0E        ;Register = I/O port A - write ROM address to be read 
    ;jsr AY5_setreg  ;writes A register, which starts at 0 for this loop (i.e., the beginning of the ROM)
    ;lda #0                      
    ;jsr AY5_writedata

    // ;for now, not using next eight bits down ROM address, write all 0's to these bits in the address - will add this support later
    // lda #$0F        ;Register = I/O port B - write ROM address to be read 
    // jsr AY6_setreg  ;writes A register, which starts at 0 for this loop (i.e., the beginning of the ROM)
    // lda #0
    // jsr AY6_writedata

    PlayFromROMLoop:
        ;lda #%00000001 ; Clear display
        ;jsr lcd_instruction

        ;for initial testing, only using bottom eight bits of ROM address
        // lda #$0E        ;Register = I/O port A - write ROM address to be read 
        // jsr AY6_setreg  ;writes A register, which starts at 0 for this loop (i.e., the beginning of the ROM)
        // txa ;use x as counter to iterate through ROM
        // clc
        // adc Sound_ROW   ;starts at 0, will increment if more than one sound row
        // jsr print_hex_lcd       ;*************** row ****************************
        // jsr AY6_writedata

        // lda #$0F    ;Register = I/O port B - read address at previously specified ROM address
        // jsr AY5_setreg
        // jsr AY5_readdata    ;result in A register
        
        jsr GetNextValueFromROM

        cmp #$1C  ;file separator
        beq PlayFromROM_Done    ;if we hit a file separator, we're done reading the file

        cmp #$1D    ;PSG (AY) selector
        beq SetPSG

        ;Process supported PSG commands
        cmp #$00    ;ChA tone period - fine tune
        beq SetPSGRegister
        cmp #$01    ;ChA tone period - course tune
        beq SetPSGRegister
        cmp #$02    ;ChB tone period - fine tune
        beq SetPSGRegister
        cmp #$03    ;ChB tone period - course tune
        beq SetPSGRegister
        cmp #$04    ;ChC tone period - fine tune
        beq SetPSGRegister
        cmp #$05    ;ChC tone period - course tune
        beq SetPSGRegister
        cmp #$08    ;ChA amplitude
        beq SetPSGRegister
        cmp #$09    ;ChB amplitude
        beq SetPSGRegister
        cmp #$0A    ;ChC amplitude
        beq SetPSGRegister

        cmp #$11    ;Delay
        beq SetDelay

        ;Check if the song should continue, or if it should be stopped
        lda SND_ABORT_MUSIC
        cmp #1
        beq PlayFromROM_Done

        bra PlayFromROMLoop

    PlayFromROM_Done:
        stz SND_ABORT_MUSIC
        stz SND_MUSIC_PLAYING
        ;*************** sound off ***************
        lda #<SND_OFF_ALL
        sta TUNE_PTR_LO
        lda #>SND_OFF_ALL
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune

        ply ;stack to y
        plx ;stack to x
        pla ;stack to a
    rts

SetPSG:
    ;read next byte to get the value
    ;jsr PrintString_Music_SetPSG
    //jsr SPI_SDCard_ReceiveByte  ;we are in the 0x1D CMD already - next byte is the PSG number (1-4). 1=Left A,B,C. 3=Left D,E,F. 2=Right A,B,C. 4=Right D,E,F.
    jsr GetNextValueFromROM
    sta SND_PSG
    ;jsr print_hex_FPGA
    jmp PlayFromROMLoop

SetPSGRegister:
    sta SND_CMD
    jsr GetNextValueFromROM
    sta SND_VAL
    lda SND_PSG
    cmp #$01
    beq SetPSG0
    cmp #$02
    beq SetPSG1
    ;shouldn't get to this
    jmp PlayFromROMLoop

GetNextValueFromROM:
    
    ;lda #$0E            ;Register = I/O port A - write ROM address to be read 
    ;jsr AY5_setreg      ;writes A register, which starts at 0 for this loop (i.e., the beginning of the ROM)
    ;lda SND_ROM_POS3
    ;jsr AY5_writedata

    ;lda #$0F            ;Register = I/O port B - write ROM address to be read 
    ;jsr AY6_setreg      ;writes A register, which starts at 0 for this loop (i.e., the beginning of the ROM)
    ;lda SND_ROM_POS2
    ;jsr AY6_writedata

    ;lda #$0E            ;Register = I/O port A - write ROM address to be read 
    ;jsr AY6_setreg      ;writes A register, which starts at 0 for this loop (i.e., the beginning of the ROM)
    ;lda SND_ROM_POS
    ;jsr AY6_writedata

    ;lda #$0F            ;Register = I/O port B - read address at previously specified ROM address
    ;jsr AY5_setreg
    ;jsr AY5_readdata    ;result in A register

    ;increment the read position, using three bytes to track address    
    inc SND_ROM_POS
    bne gnv_out
    inc SND_ROM_POS2
    bne gnv_out
    inc SND_ROM_POS3

    gnv_out:
    rts

SetPSG0:
    lda SND_CMD
    jsr PSG0_setreg
    lda SND_VAL
    jsr PSG0_writedata        
    jmp PlayFromROMLoop

SetPSG1:
    lda SND_CMD
    jsr PSG1_setreg
    lda SND_VAL
    jsr PSG1_writedata
    jmp PlayFromROMLoop

SetDelay:
    jsr GetNextValueFromROM
    cmp #$01
    beq SoundTick
    cmp #$02
    beq SoundTickHalf
    cmp #$03
    beq SoundTickQuarter
    cmp #$00
    beq SoundTickMinimal
    jmp PlayFromROMLoop

SoundTick:
    jsr ToneDelay3000
    jsr ToneDelay3000
    jsr ToneDelay3000
    jsr ToneDelay3000
    jsr ToneDelay3000
    jsr ToneDelay3000
    jsr ToneDelay3000
    jsr ToneDelay3000
    jmp PlayFromROMLoop

SoundTickHalf:
    jsr ToneDelay3000
    jsr ToneDelay3000
    jsr ToneDelay3000
    jsr ToneDelay3000
    jmp PlayFromROMLoop

SoundTickQuarter:
    jsr ToneDelay3000
    jsr ToneDelay3000
    jmp PlayFromROMLoop

SoundTickMinimal:
    jsr ToneDelay
    jmp PlayFromROMLoop

;The following PSgx sections could be consolidated and more dynamic, using parameters to specify PSG and bank.
;PSG0 play:
    PSG0_PlayTune:
        ldy #0
    PSG0_play_loop:
        lda (TUNE_PTR_LO), Y
        cmp #$FF
        bne PSG0_play_next
        rts
    PSG0_play_next:
        jsr PSG0_setreg
        iny
        lda (TUNE_PTR_LO), Y         ;y+1, so this is TUNE_PTR_HIGH
        cmp #$FF
        bne PSG0_play_next2
        rts
    PSG0_play_next2:
        jsr PSG0_writedata
        iny
        jmp PSG0_play_loop
        rts
    PSG0_setreg:
        jsr PSG0_inactive     ; NACT
        sta VIA0_PORTA
        jsr PSG0_latch        ; INTAK
        jsr PSG0_inactive     ; NACT
        rts
    PSG0_writedata:
        jsr PSG0_inactive     ; NACT
        sta VIA0_PORTA
        jsr PSG0_write           ; DWS
        jsr PSG0_inactive
        rts
    PSG0_inactive:        ; NACT
        ; BDIR  LOW
        ; BC1   LOW
        pha
        lda #0     ;A9 high to disable AY -- when adding second AY, will need to set its A9 low (on different port)
        sta VIA0_PORTB
        pla
        rts
    PSG0_latch:           ; INTAK
        ; BDIR  HIGH
        ; BC1   HIGH
        pha
        lda #(PSG0_BDIR | PSG0_BC1);  AY_A9_B low to enable AY -- when adding second AY, will need to set its A9 high here to disable it (on different port)
        sta VIA0_PORTB
        pla
        rts
    PSG0_write:           ; DWS
        ; BDIR  HIGH
        ; BC1   LOW
        pha
        lda #(PSG0_BDIR) ;AY_A9_B low to enable AY -- when adding second AY, will need to set its A9 high here to disable it (on different port)
        sta VIA0_PORTB
        pla
        rts
    PSG0_readdata:
        jsr PSG0_inactive
        lda #$00    ;Read
        sta VIA0_DDRA
        jsr PSG0_read
        lda VIA0_PORTA          ;value retrieved from PSG
        pha
        lda #$FF                ;Write
        sta VIA0_DDRA
        pla
        jsr PSG0_inactive
        plx
        rts
    PSG0_read:           ; DTB
        ; BDIR  LOW
        ; BC1   HIGH
        pha
        lda #(PSG0_BC1)
        sta VIA0_PORTB
        pla
        rts
;PSG1 play:
    PSG1_PlayTune:
        ldy #0
    PSG1_play_loop:
        lda (TUNE_PTR_LO), Y
        cmp #$FF
        bne PSG1_play_next
        rts
    PSG1_play_next:
        jsr PSG1_setreg
        iny
        lda (TUNE_PTR_LO), Y
        cmp #$FF
        bne PSG1_play_next2
        rts
    PSG1_play_next2:
        jsr PSG1_writedata
        iny
        jmp PSG1_play_loop
        rts
    PSG1_setreg:
        jsr PSG1_inactive     ; NACT
        sta VIA0_PORTA
        jsr PSG1_latch        ; INTAK
        jsr PSG1_inactive     ; NACT
        rts
    PSG1_writedata:
        jsr PSG1_inactive     ; NACT
        sta VIA0_PORTA
        jsr PSG1_write           ; DWS
        jsr PSG1_inactive
        rts
    PSG1_inactive:        ; NACT
        ; BDIR  LOW
        ; BC1   LOW
        pha
        lda #0     ;A9 high to disable AY -- when adding second AY, will need to set its A9 low (on different port)
        sta VIA0_PORTB
        pla         
        rts
    PSG1_latch:           ; INTAK
        ; BDIR  HIGH
        ; BC1   HIGH
        pha   
        lda #(PSG1_BDIR | PSG1_BC1);  AY_A9_B low to enable AY -- when adding second AY, will need to set its A9 high here to disable it (on different port)
        sta VIA0_PORTB
        pla         
        rts
    PSG1_write:           ; DWS
        ; BDIR  HIGH
        ; BC1   LOW
        pha         
        lda #(PSG1_BDIR) ;AY_A9_B low to enable AY -- when adding second AY, will need to set its A9 high here to disable it (on different port)
        sta VIA0_PORTB
        pla         
        rts
    PSG1_readdata:
        jsr PSG1_inactive
        lda #$00    ;Read
        sta VIA0_DDRA
        jsr PSG1_read
        lda VIA0_PORTA
        pha
        lda #$FF    ;Write
        sta VIA0_DDRA
        pla
        jsr PSG1_inactive
        rts
    PSG1_read:           ; DTB
        ; BDIR  LOW
        ; BC1   HIGH
        pha
        lda #(PSG1_BC1)
        sta VIA0_PORTB
        pla
        rts

ToneDelay:
    pha       ;save current accumulator
    .setting "RegA16", true
    rep #$20            ;set acumulator to 16-bit

    // lda toneDelayDuration	;counter start - increase number to shorten delay
    lda #$F000
    ToneDelayLoop:
        clc
        adc #01
        bne ToneDelayLoop
    .setting "RegA16", false
    sep #$20
    pla
    rts

ToneDelay3000:
    pha       ;save current accumulator
    .setting "RegA16", true
    rep #$20            ;set acumulator to 16-bit

    // lda toneDelayDuration	;counter start - increase number to shorten delay
    lda #$6000        ;Win login, Dream
    
    //lda #$AA00        ;Mario
    //lda #$BA00        ;Mario

    //lda #$C700          ;Monkey Island
    //lda #$B000          ;Star Trek Into Darkess, Zelda
    ToneDelay3000Loop:
        clc
        adc #01
        bne ToneDelay3000Loop
    .setting "RegA16", false
    sep #$20
    pla
    rts

ToneDelayLongFFF0:
    pha       ;save current accumulator
    .setting "RegA16", true
    rep #$20            ;set acumulator to 16-bit

    // lda toneDelayDuration	;counter start - increase number to shorten delay
    lda #$FFF0
    sta $41       ; store high byte
    ToneDelayFFF0Loop:
        clc
        adc #1
        bne ToneDelayFFF0Loop
        clc
        inc $41
        bne ToneDelayFFF0Loop
        
    .setting "RegA16", false
    sep #$20
    pla
    rts

PlayTest:
    lda #$FF    ;write (out) for all VIAs
    sta VIA0_DDRA
    sta VIA0_DDRB

    lda #<SND_RESET
    sta TUNE_PTR_LO
    lda #>SND_RESET
    sta TUNE_PTR_HI
    jsr PSG0_PlayTune
    jsr PSG1_PlayTune
    
    lda #<SND_TONE_F6_A
    sta TUNE_PTR_LO
    lda #>SND_TONE_F6_A
    sta TUNE_PTR_HI
    jsr PSG0_PlayTune
    jsr ToneDelayLongFFF0
    jsr ToneDelayLongFFF0

    lda #<SND_TONE_G5_A
    sta TUNE_PTR_LO
    lda #>SND_TONE_G5_A
    sta TUNE_PTR_HI
    jsr PSG1_PlayTune
    jsr ToneDelayLongFFF0
    jsr ToneDelayLongFFF0    

    lda #<SND_OFF_ALL
    sta TUNE_PTR_LO
    lda #>SND_OFF_ALL
    sta TUNE_PTR_HI
    jsr PSG0_PlayTune
    jsr PSG1_PlayTune

    rts

PlayWindowsStartSound:
    sep #$30	; 8-bit A/X/Y
    
    lda #$FF    ;write
    sta VIA0_DDRA
    sta VIA0_DDRB

    lda #<SND_RESET
    sta TUNE_PTR_LO
    lda #>SND_RESET
    sta TUNE_PTR_HI
    jsr PSG0_PlayTune
    jsr PSG1_PlayTune

    ;*************** sound to AY1_2 (SND_TONE_E6_FLAT_A) ***************
        lda #<SND_TONE_E6_FLAT_A
        sta TUNE_PTR_LO
        lda #>SND_TONE_E6_FLAT_A
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** sound to AY1_2 (SND_TONE_F1_C) ***************
        lda #<SND_TONE_F1_C
        sta TUNE_PTR_LO
        lda #>SND_TONE_F1_C
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** delay 3 ticks ***************
        
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000

    ;*************** sound to AY1_2 (SND_OFF_A) ***************
        lda #<SND_OFF_A
        sta TUNE_PTR_LO
        lda #>SND_OFF_A
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** sound to AY1_2 (SND_TONE_E5_FLAT_A) ***************
        lda #<SND_TONE_E5_FLAT_A
        sta TUNE_PTR_LO
        lda #>SND_TONE_E5_FLAT_A
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** delay 2 ticks ***************
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000

    ;*************** sound to AY1_2 (SND_TONE_B6_FLAT_A) ***************
        lda #<SND_TONE_B6_FLAT_A
        sta TUNE_PTR_LO
        lda #>SND_TONE_B6_FLAT_A
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** delay 3 ticks ***************
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000

    ;*************** sound to AY1_2 (SND_OFF_ALL) ***************
        lda #<SND_OFF_ALL
        sta TUNE_PTR_LO
        lda #>SND_OFF_ALL
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** sound to AY1_2 (SND_TONE_A6_FLAT_A) ***************
        lda #<SND_TONE_A6_FLAT_A
        sta TUNE_PTR_LO
        lda #>SND_TONE_A6_FLAT_A
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** sound to AY1_2 (SND_OFF_C) ***************
        lda #<SND_OFF_C
        sta TUNE_PTR_LO
        lda #>SND_OFF_C
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** sound to AY1_2 (SND_TONE_A2_FLAT_C) ***************
        lda #<SND_TONE_A2_FLAT_C
        sta TUNE_PTR_LO
        lda #>SND_TONE_A2_FLAT_C
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** delay 5 ticks ***************
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000

    ;*************** sound to AY1_2 (SND_OFF_A) ***************
        lda #<SND_OFF_A
        sta TUNE_PTR_LO
        lda #>SND_OFF_A
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune    
        jsr PSG1_PlayTune
    ;*************** sound to AY1_2 (SND_TONE_E6_FLAT_A) ***************
        lda #<SND_TONE_E6_FLAT_A
        sta TUNE_PTR_LO
        lda #>SND_TONE_E6_FLAT_A
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** delay 3 ticks ***************
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000

    ;*************** sound to AY1_2 (SND_OFF_ALL) ***************
        lda #<SND_OFF_ALL
        sta TUNE_PTR_LO
        lda #>SND_OFF_ALL
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** sound to AY1_2 (SND_TONE_B6_FLAT_A) ***************
        lda #<SND_TONE_B6_FLAT_A
        sta TUNE_PTR_LO
        lda #>SND_TONE_B6_FLAT_A
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** sound to AY1_2 (SND_TONE_E3_FLAT_B) ***************
        lda #<SND_TONE_E3_FLAT_B
        sta TUNE_PTR_LO
        lda #>SND_TONE_E3_FLAT_B
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** sound to AY1_2 (SND_TONE_B3_FLAT_C) ***************
        lda #<SND_TONE_B3_FLAT_C
        sta TUNE_PTR_LO
        lda #>SND_TONE_B3_FLAT_C
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune
    ;*************** delay 8 ticks ***************
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000
        jsr ToneDelay3000

    ;*************** sound to AY1_2_3_4 (off) ***************
        lda #<SND_OFF_ALL
        sta TUNE_PTR_LO
        lda #>SND_OFF_ALL
        sta TUNE_PTR_HI
        jsr PSG0_PlayTune
        jsr PSG1_PlayTune

        rep #$30	; 16-bit A/X/Y

    rts

PlayTestChords:
    sep #$30	; 8-bit A/X/Y

    lda #$FF    ;write (out) for all VIAs
    sta VIA0_DDRA
    sta VIA0_DDRB

    lda #<SND_RESET
    sta TUNE_PTR_LO
    lda #>SND_RESET
    sta TUNE_PTR_HI
    jsr PSG0_PlayTune
    jsr PSG1_PlayTune
    

    lda #<SND_TONE_F6_A
    sta TUNE_PTR_LO
    lda #>SND_TONE_F6_A
    sta TUNE_PTR_HI
    jsr PSG0_PlayTune
    jsr ToneDelayLongFFF0
    jsr ToneDelayLongFFF0

    lda #<SND_TONE_D6_B
    sta TUNE_PTR_LO
    lda #>SND_TONE_D6_B
    sta TUNE_PTR_HI
    jsr PSG0_PlayTune
    jsr ToneDelayLongFFF0
    jsr ToneDelayLongFFF0

    lda #<SND_TONE_A5_SHARP_C
    sta TUNE_PTR_LO
    lda #>SND_TONE_A5_SHARP_C
    sta TUNE_PTR_HI
    jsr PSG0_PlayTune
    jsr ToneDelayLongFFF0
    jsr ToneDelayLongFFF0

    lda #<SND_TONE_G5_A
    sta TUNE_PTR_LO
    lda #>SND_TONE_G5_A
    sta TUNE_PTR_HI
    jsr PSG1_PlayTune
    jsr ToneDelayLongFFF0
    jsr ToneDelayLongFFF0

    lda #<SND_TONE_E5_B
    sta TUNE_PTR_LO
    lda #>SND_TONE_E5_B
    sta TUNE_PTR_HI
    jsr PSG1_PlayTune
    jsr ToneDelayLongFFF0
    jsr ToneDelayLongFFF0

    lda #<SND_TONE_C5_C
    sta TUNE_PTR_LO
    lda #>SND_TONE_C5_C
    sta TUNE_PTR_HI
    jsr PSG1_PlayTune
    jsr ToneDelayLongFFF0
    jsr ToneDelayLongFFF0

    lda #<SND_OFF_ALL
    sta TUNE_PTR_LO
    lda #>SND_OFF_ALL
    sta TUNE_PTR_HI
    jsr PSG0_PlayTune
    jsr PSG1_PlayTune

    jsr ToneDelayLongFFF0
    jsr ToneDelayLongFFF0

    rep #$30	; 16-bit A/X/Y

    rts

SND_RESET:
    .BYTE $00, $00           ;ChanA tone period fine tune
    .BYTE $01, $00           ;ChanA tone period coarse tune
    .BYTE $02, $00           ;ChanB tone period fine tune      
    .BYTE $03, $00           ;ChanB tone period coarse tune
    .BYTE $04, $00           ;ChanC tone period fine tune  
    .BYTE $05, $00           ;ChanC tone period coarse tune
    .BYTE $06, $00           ;Noise Period
    .BYTE $07, $38           ;EnableB        ;all channels enabled, IO set to read for both ports
    .BYTE $08, $0F           ;ChanA amplitude    0F = fixed, max
    .BYTE $09, $0F           ;ChanB amplitude
    .BYTE $0A, $0F           ;ChanC amplitude
    .BYTE $0B, $00           ;Envelope period fine tune
    .BYTE $0C, $00           ;Envelope period coarse tune
    .BYTE $0D, $00           ;Envelope shape cycle
    ;.BYTE $0E, $00           ;IO Port A
    ;.BYTE $0F, $00           ;IO Port B
    .BYTE $FF, $FF           ; EOF

SND_OFF_ALL:
    .BYTE $08, $00           ;ChanA amplitude    0F = fixed, max
    .BYTE $09, $00           ;ChanB amplitude
    .BYTE $0A, $00           ;ChanC amplitude
    .BYTE $FF, $FF                ; EOF

SND_OFF_A:
    .BYTE $08, $00           ;ChanA amplitude    0F = fixed, max
    .BYTE $FF, $FF           ; EOF

SND_OFF_B:
    .BYTE $09, $00           ;ChanB amplitude
    .BYTE $FF, $FF           ; EOF

SND_OFF_C:
    .BYTE $0A, $00           ;ChanC amplitude
    .BYTE $FF, $FF           ; EOF

;Chords
    SND_TONE_F6_A:
        .BYTE $00, $59
        .BYTE $01, $00
        .BYTE $08, $0F           ;ChanA amplitude    0F = fixed, max
        .BYTE $FF, $FF
    SND_TONE_D6_B:
        .BYTE $02, $6A
        .BYTE $03, $00
        .BYTE $09, $0F           ;ChanB amplitude
        .BYTE $FF, $FF    
    SND_TONE_A5_SHARP_C:
        .BYTE $04, $86
        .BYTE $05, $00
        .BYTE $0A, $0F           ;ChanC amplitude
        .BYTE $FF, $FF
    SND_TONE_G5_A:
        .BYTE $00, $9F
        .BYTE $01, $00
        .BYTE $08, $0F           ;ChanA amplitude    0F = fixed, max
        .BYTE $FF, $FF
    SND_TONE_E5_B:
        .BYTE $02, $BD
        .BYTE $03, $00
        .BYTE $09, $0F           ;ChanB amplitude
        .BYTE $FF, $FF    
    SND_TONE_C5_C:
        .BYTE $04, $EE
        .BYTE $05, $00
        .BYTE $0A, $0F           ;ChanC amplitude
        .BYTE $FF, $FF
    SND_TONE_F4_A:
        .BYTE $00, $65
        .BYTE $01, $01
        .BYTE $08, $0F           ;ChanA amplitude    0F = fixed, max
        .BYTE $FF, $FF
    SND_TONE_D4_B:
        .BYTE $02, $A9
        .BYTE $09, $0F           ;ChanB amplitude
        .BYTE $03, $01
        .BYTE $FF, $FF    
    SND_TONE_A3_SHARP_C:
        .BYTE $04, $18
        .BYTE $05, $02
        .BYTE $0A, $0F           ;ChanC amplitude
        .BYTE $FF, $FF
    SND_TONE_G3_A:
        .BYTE $00, $7D
        .BYTE $01, $02
        .BYTE $08, $0F           ;ChanA amplitude    0F = fixed, max
        .BYTE $FF, $FF
    SND_TONE_E3_B:
        .BYTE $02, $F6
        .BYTE $03, $02
        .BYTE $09, $0F           ;ChanB amplitude
        .BYTE $FF, $FF    
    SND_TONE_C3_C:
        .BYTE $04, $BB
        .BYTE $05, $03
        .BYTE $0A, $0F           ;ChanC amplitude
        .BYTE $FF, $FF

;Win95 Start
    SND_TONE_B6_FLAT_A:
        .BYTE $00, $43           ;ChanA tone period fine tune
        .BYTE $01, $00           ;ChanA tone period coarse tune
        .BYTE $08, $0F           ;ChanA amplitude    0F = fixed, max
        .BYTE $FF, $FF                ; EOF
    SND_TONE_A6_FLAT_A:
        .BYTE $00, $4B           ;ChanA tone period fine tune
        .BYTE $01, $00           ;ChanA tone period coarse tune
        .BYTE $08, $0F           ;ChanA amplitude    0F = fixed, max
        .BYTE $FF, $FF           ; EOF
    SND_TONE_E6_FLAT_A:
        .BYTE $00, $64           ;ChanA tone period fine tune
        .BYTE $01, $00           ;ChanA tone period coarse tune
        .BYTE $08, $0F           ;ChanA amplitude    0F = fixed, max
        .BYTE $FF, $FF           ; EOF
    SND_TONE_E5_FLAT_A:
        .BYTE $00, $C8           ;ChanA tone period fine tune
        .BYTE $01, $00           ;ChanA tone period coarse tune
        .BYTE $08, $0F           ;ChanA amplitude    0F = fixed, max
        .BYTE $FF, $FF           ; EOF
    SND_TONE_B3_FLAT_C:
        .BYTE $04, $18           ;ChanC tone period fine tune  
        .BYTE $05, $02           ;ChanC tone period coarse tune
        .BYTE $0A, $0F           ;ChanC amplitude
        .BYTE $FF, $FF           ; EOF
    SND_TONE_E3_FLAT_B:
        .BYTE $02, $23           ;ChanB tone period fine tune      
        .BYTE $03, $03           ;ChanB tone period coarse tune
        .BYTE $09, $0F           ;ChanB amplitude
        .BYTE $FF, $FF           ; EOF
    SND_TONE_A2_FLAT_C:
        .BYTE $04, $B3           ;ChanA tone period fine tune
        .BYTE $05, $04           ;ChanA tone period coarse tune
        .BYTE $0A, $0F           ;ChanC amplitude    0F = fixed, max
        .BYTE $FF, $FF           ; EOF
    SND_TONE_F1_C:
        .BYTE $04, $2F           ;ChanC tone period fine tune  
        .BYTE $05, $0B           ;ChanC tone period coarse tune
        .BYTE $0A, $0F           ;ChanC amplitude
        .BYTE $FF, $FF           ; EOF