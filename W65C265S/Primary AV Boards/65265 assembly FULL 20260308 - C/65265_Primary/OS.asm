.setting "RegA16", true
.setting "RegXY16", true
.setting "HandleLongBranch", true

execute_command:
    php
    rep #$30
    pha     ; 1

    ; --- check if index is zero (no chars entered) ---
    lda cmd_index
    beq do_enter_only

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
    pha ; save current char color -2
    lda #%0000011111100000
    sta ili_char_color

    ldx #0
    next_cmd:
        lda CommandTable,x
        beq no_match
        sta Str_ptr
        jsr compare_cmd
        beq found
        inx
        inx
        inx
        inx
        bra next_cmd

    found:
        lda CommandTable+2,x
        jmp (CommandTable+2,x)

    no_match:
        jsr ILI_New_Line
        
        jsr pib_newline
        ;ldx #20
        ;jsr Delay_ms

        lda ili_char_color
        pha ; save char color  -3
        lda #%1111100000000000            ; red color in RGB565
        sta ili_char_color
        
        lda #<STR_CMD_INVALID
        sta Str_ptr
        lda #>STR_CMD_INVALID
        sta Str_ptr+1
        jsr ILI_Puts
        
        lda #<STR_CMD_INVALID
        sta Str_ptr
        lda #>STR_CMD_INVALID
        sta Str_ptr+1
        jsr pib_puts
        
        pla ; restore char color
        sta ili_char_color

        jsr pib_newline
        ;ldx #20
        ;jsr Delay_ms
        
        jsr ILI_New_Line

        lda #'>'
        jsr ILI_Print_Char  
        jsr pib_print_char

        bra execute_command_done
        
    do_enter_only:
        jsr pib_newline
        ;ldx #20
        ;jsr Delay_ms

        jsr ILI_New_Line

        lda #'>'
        jsr ILI_Print_Char  
        jsr pib_print_char

        bra execute_command_done_noColorChange

    do_cls:
        jsr pib_clear_screen
        jsr ILI_New_Line
        lda #'>'
        jsr ILI_Print_Char  
        jsr pib_print_char  

        bra execute_command_done

    do_cls_ili:
        jsr ILI_Clear_Screen
        lda #0
        sta ili_current_x
        sta ili_current_y
        jsr pib_newline
        lda #'>'
        jsr ILI_Print_Char  
        jsr pib_print_char  

        bra execute_command_done

    do_dir:
        jsr pib_newline
        ;ldx #20
        ;jsr Delay_ms

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

        lda #<STR_CMD_NOFILES
        sta Str_ptr
        lda #>STR_CMD_NOFILES
        sta Str_ptr+1
        jsr pib_puts

        pla ; restore char color
        sta ili_char_color
        bra do_newline

    do_ver:
        jsr pib_newline
        ;ldx #20
        ;jsr Delay_ms

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

        lda #<STR_CMD_VER
        sta Str_ptr
        lda #>STR_CMD_VER
        sta Str_ptr+1
        jsr pib_puts

        pla ; restore char color
        sta ili_char_color
        bra do_newline   

    do_help:
        jsr pib_newline
        ;ldx #20
        ;jsr Delay_ms

        ;jsr ILI_New_Line
        ;lda ili_char_color
        ;pha ; save char color
        ;lda #%1110000000011100
        ;sta ili_char_color
        ;lda #<STR_CMD_HELP
        ;sta Str_ptr
        ;lda #>STR_CMD_HELP
        ;sta Str_ptr+1
        ;jsr ILI_Puts

        lda #<STR_CMD_HELP_1
        sta Str_ptr
        lda #>STR_CMD_HELP_1
        sta Str_ptr+1
        jsr pib_puts

        jsr pib_newline

        lda #<STR_CMD_HELP_2
        sta Str_ptr
        lda #>STR_CMD_HELP_2
        sta Str_ptr+1
        jsr pib_puts


        ;pla ; restore char color
        ;sta ili_char_color
        bra do_newline    

    do_hello:     
		jsr SP0256_Init
        ;jsr SP0256_SpeakStringTest
        jsr ILI_New_Line
        jsr ILI_New_Line
        jsr SP0256_Hello
        bra do_newline   

    do_app1:
        ; run an app from the secondary flash
        jsl $401000   ; temporary - hardcoded address of the app - will make dynamic later
        bra do_newline   

    do_app2:
        ; run an app from the secondary flash
        jsl $402000   ; temporary - hardcoded address of the app - will make dynamic later
        bra do_newline

    do_app3:
        ; run an app from the secondary flash
        jsl $402E00   ; temporary - hardcoded address of the app - will make dynamic later
        bra do_newline

    do_rectangles:
        ldx #1000          ; draw 1000 random rectangles

        rect_loop:
            phx            ; save loop counter to stack
            ldx #1
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

            bra do_newline

    do_newline:
        jsr pib_newline
        ;ldx #20
        ;jsr Delay_ms

        ;jsr ILI_New_Line

        lda #'>'
        ;jsr ILI_Print_Char  
        jsr pib_print_char          

        bra execute_command_done

    execute_command_done:
        pla ; restore char color
        sta ili_char_color
    
    execute_command_done_noColorChange:
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

; OS commands - compare strings
cmd_cls:            .byte "cls"         ,0
cmd_cls_ili:        .byte "cls_ili"     ,0
cmd_dir:            .byte "dir"         ,0
cmd_hello:          .byte "hello"       ,0
cmd_help:           .byte "help"        ,0
cmd_ver:            .byte "ver"         ,0
cmd_app1:           .byte "app1"        ,0
cmd_rectangles:     .byte "rectangles"  ,0
cmd_app2:           .byte "app2"        ,0
cmd_app3:           .byte "app3"        ,0

CommandTable:
    .word cmd_cls,        do_cls
    .word cmd_cls_ili,    do_cls_ili
    .word cmd_dir,        do_dir
    .word cmd_ver,        do_ver
    .word cmd_help,       do_help
    .word cmd_hello,      do_hello
    .word cmd_app1,       do_app1
    .word cmd_rectangles, do_rectangles
    .word cmd_app2,       do_app2
    .word cmd_app3,       do_app3
    .word 0,              0