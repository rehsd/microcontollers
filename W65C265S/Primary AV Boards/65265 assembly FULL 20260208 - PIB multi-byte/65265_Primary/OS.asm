.setting "RegA16", true
.setting "RegXY16", true
.setting "HandleLongBranch", true

execute_command:
    php
    rep #$30
    pha

    ; --- check if index is zero (no chars entered) ---
    lda cmd_index
    beq execute_command_done_noColorChange

    ; --- setup pointer to bank 0 where cmd_buffer lives ---
    lda #cmd_buffer
    sta Str_ptr
    
    sep #$20
    .setting "RegA16", false
    lda #$00
    sta Str_ptr+2           ; force bank 0
    
    rep #$20
    .setting "RegA16", true
    
    lda ili_char_color
    pha ; save current char color
    lda #%0000011111100000
    sta ili_char_color

    ; check for "cls"
    lda #cmd_cls
    sta Str_ptr
    jsr compare_cmd
    beq do_cls
    
    ; check for "dir"
    lda #cmd_dir
    sta Str_ptr
    jsr compare_cmd
    beq do_dir

    ; check for "ver"
    lda #cmd_ver
    sta Str_ptr
    jsr compare_cmd
    beq do_ver

    ; check for "help"
    lda #cmd_help
    sta Str_ptr
    jsr compare_cmd
    beq do_help

    ; check for "hello"
    lda #cmd_hello
    sta Str_ptr
    jsr compare_cmd
    beq do_hello

    ; check for "app1"
    lda #cmd_app1
    sta Str_ptr
    jsr compare_cmd
    beq do_app1

    ; check for "rectangles"
    lda #cmd_rectangles
    sta Str_ptr
    jsr compare_cmd
    beq do_rectangles

    ; no match
    jsr ILI_New_Line
    lda ili_char_color
    pha ; save char color
    lda #%1111100000000000            ; red color in RGB565
    sta ili_char_color
    lda #<STR_CMD_INVALID
    sta Str_ptr
    lda #>STR_CMD_INVALID
    sta Str_ptr+1
    jsr ILI_Puts
    pla ; restore char color
    sta ili_char_color

    bra execute_command_done

    do_cls:
        ;lda #'c'
        ;jsr ILI_Print_Char
        jsr ILI_Clear_Screen
        lda #0
        sta ili_current_x
        sta ili_current_y
        bra execute_command_done

    do_dir:
        ;lda #'d'
        ;jsr ILI_Print_Char
        jsr ILI_New_Line
        lda ili_char_color
        pha ; save char color
        lda #%1111111111100000            ; yellow color in RGB565
        sta ili_char_color
        lda #<STR_CMD_NOFILES
        sta Str_ptr
        lda #>STR_CMD_NOFILES
        sta Str_ptr+1
        jsr ILI_Puts
        pla ; restore char color
        sta ili_char_color
        bra execute_command_done

    do_ver:
        jsr ILI_New_Line
        lda ili_char_color
        pha ; save char color
        lda #%1110011100011100
        sta ili_char_color
        lda #<STR_CMD_VER
        sta Str_ptr
        lda #>STR_CMD_VER
        sta Str_ptr+1
        jsr ILI_Puts
        pla ; restore char color
        sta ili_char_color
        bra execute_command_done   

    do_help:
        jsr ILI_New_Line
        lda ili_char_color
        pha ; save char color
        lda #%1110000000011100
        sta ili_char_color
        lda #<STR_CMD_HELP
        sta Str_ptr
        lda #>STR_CMD_HELP
        sta Str_ptr+1
        jsr ILI_Puts
        pla ; restore char color
        sta ili_char_color
        bra execute_command_done    

    do_hello:     
		jsr SP0256_Init
        ;jsr SP0256_SpeakStringTest
        jsr ILI_New_Line
        jsr ILI_New_Line
        jsr SP0256_Hello
        bra execute_command_done   

    do_app1:
        ; run an app from the secondary flash
        jsl $401000   ; temporary - hardcoded address of the app - will make dynamic later
        bra execute_command_done   

    // do_rectangles:
    //         ;*Write to dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, height_lo, height_hi, color_lo, color_hi, filled

    //         ; TO DO: Add loop of randomized rectangles

    //         lda #160        ; $00a0
    //         sta $F00000     ; start_x
    //         lda #100        ; $0064
    //         sta $F00002     ; start_y
    //         lda #50         ; $0032
    //         sta $F00004     ; width
    //         lda #30         ;$001e
    //         sta $F00006     ; height
    //         lda #$FFFF
    //         sta $F00008     ; color (white)
    //         lda #1
    //         sta $F0000A     ; filled
    //         jsr pib_draw_rectangle

    //         bra execute_command_done

    do_rectangles:
        ldx #1000          ; draw 1000 random rectangles

        rect_loop:
            phx            ; save loop counter to stack
            ldx #3
            jsr Delay_ms     ; delay between rectangles so we can see them being drawn - maybe change to a GPIO signal to AV later for better timing control
            ; -------------------------
            ; random start_x (0..319)
            ; -------------------------
            lda #319
            jsr RAND_RANGE
            sta $F00000

            ; -------------------------
            ; random start_y (0..239)
            ; -------------------------
            lda #239
            jsr RAND_RANGE
            sta $F00002

            ; -------------------------
            ; random width (5..20)
            ; -------------------------
            lda #15
            jsr RAND_RANGE
            clc
            adc #5
            sta $F00004

            ; -------------------------
            ; random height (5..20)
            ; -------------------------
            lda #15
            jsr RAND_RANGE
            clc
            adc #5
            sta $F00006

            ; -------------------------
            ; random color (0..255)
            ; -------------------------
            lda #$00FF
            jsr RAND_RANGE
            sta $F00008

            ; filled = 1
            lda #1
            sta $F0000A

            ; draw it
            jsr pib_draw_rectangle

            plx            ; restore loop counter
            dex
            bne rect_loop

            bra execute_command_done

    execute_command_done:
        pla ; restore char color
        sta ili_char_color
    execute_command_done_noColorChange:
        jsr ILI_New_Line
        lda #'>'
        jsr ILI_Print_Char    

        pla
        plp
        rts

compare_cmd:
    ldy #0
    compare_loop:
        sep #$20
        .setting "RegA16", false
        lda [Str_ptr],y
        sta ili_temp_math
        lda cmd_buffer,y
        cmp ili_temp_math
        bne compare_fail
        cmp #0
        beq compare_match
        iny
        bra compare_loop
    compare_match:
        rep #$20
        .setting "RegA16", true
        lda #0
        rts
    compare_fail:
        rep #$20
        .setting "RegA16", true
        lda #1
        rts

OS_ILI_PrintChar:
    ;php
    ;sep #$20
    ;.setting "RegA16", false
    ;lda #'$'
    jsr ILI_Print_Char
    ;plp
    rtl

; OS commands
cmd_cls:            .byte "cls"         ,0
cmd_dir:            .byte "dir"         ,0
cmd_hello:          .byte "hello"       ,0
cmd_help:           .byte "help"        ,0
cmd_ver:            .byte "ver"         ,0
cmd_app1:           .byte "app1"        ,0
cmd_rectangles:     .byte "rectangles"  ,0
