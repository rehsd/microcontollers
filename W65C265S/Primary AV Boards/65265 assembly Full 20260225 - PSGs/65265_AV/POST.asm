; Test routines assume incoming 16-bit A/X/Y
; and use carry flag for returning status.
; Cannot plp and impact carry flag on routine exit.

.setting "RegA16", true
.setting "RegXY16", true

Run_POST_Tests:

    ; Extended SRAM test
        ;lda #$FFFF              ; white
        ;sta ili_char_color          
        ;lda #<POST_EXTSRAM
        ;sta Str_ptr
        ;lda #>POST_EXTSRAM
        ;sta Str_ptr+1
        ;jsr ILI_Puts

        jsr Test_Extended_SRAM
        ;lda #300
        ;sta ili_current_x

        bcs @fail_sram        ; C=1 → failure
            jsr POST_Test_Pass
            bra @after_sram

        @fail_sram:
            jsr POST_Test_Fail

        @after_sram:
            ;jsr ILI_New_Line
            ; continue to next POST test..

   ; Dual-port SRAM test
        ;lda #$FFFF              ; white
        ;sta ili_char_color          
        ;lda #<POST_DUALPORT_SRAM
        ;sta Str_ptr
        ;lda #>POST_DUALPORT_SRAM
        ;sta Str_ptr+1
        ;jsr ILI_Puts

        ;jsr Test_DualPort_SRAM
        ;lda #300
        ;sta ili_current_x

        ;bcs @fail_dpsram        ; C=1 → failure
        ;    jsr POST_Test_Pass
        ;    bra @after_dpsram

        ;@fail_dpsram:
        ;    jsr POST_Test_Fail

        ;@after_dpsram:
        ;    jsr ILI_New_Line
        ;    ; continue to next POST test..

   ; Secondary Flash
        ;lda #$FFFF              ; white
        ;sta ili_char_color          
        ;lda #<POST_SECONDARY_FLASH
        ;sta Str_ptr
        ;lda #>POST_SECONDARY_FLASH
        ;sta Str_ptr+1
        ;jsr ILI_Puts

        ldx #2000
        jsr Delay_ms
        jsr Test_Secondary_Flash
        ;lda #300
        ;sta ili_current_x

        bcs @fail_flash        ; C=1 → failure
            jsr POST_Test_Pass
            bra @after_flash

        @fail_flash:
            jsr POST_Test_Fail

        @after_flash:
            ;jsr ILI_New_Line
            ; continue to next POST test..

    ; Done
        ;lda #$FFFF              ; white
        ;sta ili_char_color 

        rts

Test_Extended_SRAM:
    ;	$01:0000 to $07:FFFF	CS5B				512 KB external SRAM
    ;php
    phb
    phy
    phx
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true

    lda #$0001
    sta TestBank
        
    @NextBank:
        lda #$0000
        sta TestBankPointer
        sep #$20
        .setting "RegA16", false
        lda TestBank
        sta TestBankPointer+2
        
        ;clc
        ;adc #$30  ; convert to ascii
        ;jsr ILI_Print_Char


        rep #$20
        .setting "RegA16", true
        lda #$00AA
        sta TestPattern
        ldy #$0000
    @WriteAA:
        lda TestPattern
        sta [TestBankPointer],y
        iny
        iny
        bne @WriteAA
        ldy #$0000
    @VerifyAA:
        lda TestPattern
        cmp [TestBankPointer],y
        bne @MemFail
        iny
        iny
        bne @VerifyAA
        lda #$0055
        sta TestPattern
        ldy #$0000
    @Write55:
        lda TestPattern
        sta [TestBankPointer],y
        iny
        iny
        bne @Write55
        ldy #$0000
    @Verify55:
        lda TestPattern
        cmp [TestBankPointer],y
        bne @MemFail
        iny
        iny
        bne @Verify55
        inc TestBank
        lda TestBank
        cmp #$0008
        bne @NextBank
        clc
        bra @TestDone
    @MemFail:
        sec
    @TestDone:
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        plx
        ply
        plb
        ;plp
        rts

Test_DualPort_SRAM:
    ;php
    phb
    phy
    phx

    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true

    ; Build pointer to F0:0000
    lda #$0000
    sta TestBankPointer

    ; CPU → 8-bit A
    ; Assembler → 8-bit A
    sep #$20
    .setting "RegA16", false

    lda #$F0
    sta TestBankPointer+2

    ; CPU → 16-bit A
    ; Assembler → 16-bit A
    rep #$20
    .setting "RegA16", true

    ; Pass 1: write AA
    lda #$00AA
    sta TestPattern

    ldy #$0000
    @WriteAA:
        lda TestPattern
        sta [TestBankPointer],y
        iny
        iny
        cpy #$0800
        bne @WriteAA

        ; Verify AA
        ldy #$0000
    @VerifyAA:
        lda TestPattern
        cmp [TestBankPointer],y
        bne @MemFail
        iny
        iny
        cpy #$0800
        bne @VerifyAA

        ; Pass 2: write 55
        lda #$0055
        sta TestPattern

        ldy #$0000
    @Write55:
        lda TestPattern
        sta [TestBankPointer],y
        iny
        iny
        cpy #$0800
        bne @Write55

        ; Verify 55
        ldy #$0000
    @Verify55:
        lda TestPattern
        cmp [TestBankPointer],y
        bne @MemFail
        iny
        iny
        cpy #$0800
        bne @Verify55

        clc
        bra @TestDone

    @MemFail:
        sec

    @TestDone:
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true

        plx
        ply
        plb
        ;plp
        rts

Test_Secondary_Flash:
    ;php
    phb
    phy
    phx
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    ; --- check first 6 bytes ($40:0000) ---
    lda #$0000
    sta TestBankPointer
    sep #$20
    .setting "RegA16", false
    lda #$40
    sta TestBankPointer+2
    rep #$20
    .setting "RegA16", true
    lda [TestBankPointer]       ; 're'
    cmp #$6572
    bne @flash_fail
    ldy #$0002
    lda [TestBankPointer],y     ; 'hs'
    cmp #$7368
    bne @flash_fail
    ldy #$0004
    lda [TestBankPointer],y     ; 'd!'
    cmp #$2164                  ; '!' = $21, 'd' = $64
    bne @flash_fail
    ; --- check last 6 bytes ($47:FFFA) ---
    lda #$fffa                  ; $ffff - 5 = $fffa
    sta TestBankPointer
    sep #$20
    .setting "RegA16", false
    lda #$47
    sta TestBankPointer+2
    rep #$20
    .setting "RegA16", true
    lda [TestBankPointer]       ; 're'
    cmp #$6572
    bne @flash_fail
    ldy #$0002
    lda [TestBankPointer],y     ; 'hs'
    cmp #$7368
    bne @flash_fail
    ldy #$0004
    lda [TestBankPointer],y     ; 'd!'
    cmp #$2164
    bne @flash_fail
    clc
    bra @flash_done

    @flash_fail:
        sec
    @flash_done:
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        plx
        ply
        plb
        ;plp
        rts

POST_Test_Pass:
    jsr play_tone_test_pass
    rts

    ;lda ili_char_color
    ;pha                         ; save char color
    ;lda #%0000011111100000      ; green
    ;sta ili_char_color
    ;lda #<POST_PASS
    ;sta Str_ptr
    ;lda #>POST_PASS
    ;sta Str_ptr+1
    ;jsr ILI_Puts
    ;pla
    ;sta ili_char_color          ; restore char color
    ;rts

POST_Test_Fail:
    jsr play_tone_test_fail
    rts

    ;lda ili_char_color
    ;pha                         ; save char color
    ;lda #%1111100000000000           ; red
    ;sta ili_char_color
    ;lda #<POST_FAIL
    ;sta Str_ptr
    ;lda #>POST_FAIL
    ;sta Str_ptr+1
    ;jsr ILI_Puts
    ;pla
    ;sta ili_char_color          ; restore char color
    ;rts