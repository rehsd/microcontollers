.setting "RegA16", true
.setting "RegXY16", true

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
        
; OS commands
cmd_cls:        .byte "cls"         ,0
cmd_dir:        .byte "dir"         ,0
cmd_hello:      .byte "hello"       ,0
cmd_help:       .byte "help"        ,0
cmd_ver:        .byte "ver"         ,0