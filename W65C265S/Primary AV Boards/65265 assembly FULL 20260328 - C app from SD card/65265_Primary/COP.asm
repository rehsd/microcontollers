; =============================================================================
; OS INTERFACE METHOD COMPARISON
; =============================================================================
; Feature            | Jump Table (JSR/JSL)       | COP (Software Interrupt)
; -------------------|----------------------------|----------------------------
; Execution Speed    | FAST: Direct branch logic  | SLOW: Hardware/IRQ overhead
; Code Density       | BULKY: Needs setup code    | COMPACT: 2-byte instruction
; Parameter Passing  | EASY: Uses registers       | COMPLEX: Mailbox or Stack
; Abstraction        | LOW: Needs fixed address   | HIGH: Vector-based isolation
; State Management   | MANUAL: User saves regs    | AUTO: Hardware saves PBR/PC
; Architecture Style | Functional Library         | Modern System Call (Kernel)
; =============================================================================
;
; App1:   ; JSR/JSL Approach
;	jsr App_Init
;	ldx #SYS_ILI_PrintChar
;	lda #'T'
;	jsr os_jsr
;
; App2:   ; COP Approach
;	lda #'T'
;	sta SYSCALL_PARAMS
;	cop COP_CMD_PRINT_CHAR
;
; =============================================================================
; ANALYSIS:
; App1 is better for high-throughput tasks like drawing pixels or characters
; where the cycle-count of the "hop" matters. App2 is better for high-level
; OS tasks (File I/O, Tasking) where code cleanliness and binary compatibility 
; across different OS versions are prioritized over raw speed.
; =============================================================================

.setting "HandleLongBranch", true
.setting "RegA16", true
.setting "RegXY16", true

.include "../Common/COP_Commands.asm"

cop_handler:
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    pha
    phx
    phy
    phb
    tdc                         ; Read caller's Direct Page
    pha                         ; Save it on stack
    lda #$0000
    tcd                         ; Set DP to $0000 for OS
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                         ; Set DBR to $00 for table
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    tsx
    lda $0c,x                   ; PC (shifted by pha D)
    dec
    sta <tmp
    sep #$20
    .setting "RegA16", false
    lda $0e,x                   ; PBR (shifted by pha D)
    sta <tmp+2
    stz <tmp+3
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    lda [<tmp]
    and #$00ff
    asl
    tax
    pea return_from_table-1
    jmp (sys_jump_table,x)

return_from_table:
    rep #$30                    ; Ensure 16-bit for D pull
    .setting "RegA16", true
    pla                         ; Pull caller's D
    tcd                         ; Restore it
    plb
    ply
    plx
    pla
    plp                         ; Pull the PHP from start of handler
    rti			

dump_cop_context:
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    pha
    phx
    phy
    tsx
    lda $12,x
    sec
    sbc #5
    sta tmp
    sep #$20
    .setting "RegA16", false
    lda $14,x
    sta tmp+2
    rep #$20
    .setting "RegA16", true
    ldx #0
    mem_loop:
        lda [tmp]
        and #$00ff
        jsr print_hex_serial
        lda #$0020
        jsr print_char_serial
        lda tmp
        clc
        adc #1
        sta tmp
        inx
        cpx #9
        bne mem_loop
    ply
    plx
    pla
    plp
    rts

jump_to_table:
    jmp (sys_jump_table,x)

sys_jump_table:
.word COP_none                  ; address for cop #$00
.word COP_print_char            ; address for cop #$01
.word COP_newline               ; address for cop #$02
.word COP_debug_mark            ; address for cop #$03      ;+
.word COP_debug_mark2           ; address for cop #$04      ;$
.word COP_c_return              ; address for cop #$05      ; Return to '265 from C app
.word COP_draw_rectangle        ; address for cop #$06      ; Draw rectangle (parameters in dpsram)
.word COP_draw_circle           ; address for cop #$07      ; Draw circle (parameters in dpsram)
.word COP_draw_line             ; address for cop #$08      ; Draw line (parameters in dpsram)
.word COP_draw_pixel            ; address for cop #$09      ; Draw pixel (parameters in dpsram)
.word COP_set_char_xy           ; address for cop #$0A      ; Set text cursor position (parameters in dpsram)  
.word COP_sdcard_read_sector    ; address for cop #$0B      ; SD Card read sector
.word COP_sdcard_write_sector   ; address for cop #$0C      ; SD Card write sector
.word COP_sdcard_init           ; address for cop #$0D      ; SD Card initialize
.word COP_get_date_time         ; address for cop #$0E      ; Get date/time
.word COP_cApp_return           ; address for cop #$0F      ; Return to Shell from C app

; COP support commands
    COP_none:
        rts

    COP_print_char:
        php
        ; force 16-bit to ensure we save the full registers
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        pha
        phx
        phy
        phb
        
        ; switch to 8-bit for the serial routine and bank setup
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb
        
        ; load the character from the syscall area
        lda SYSCALL_PARAMS
        jsr pib_print_char
        
        ; restore 16-bit mode to safely pull the saved context
        rep #$30
        .setting "RegA16", true
        plb
        ply
        plx
        pla
        plp
        rts

    COP_newline:
        php
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        pha
        phx
        phy
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb
        jsr pib_newline
        rep #$30
        .setting "RegA16", true
        plb
        ply
        plx
        pla
        plp
        rts

    COP_debug_mark:
        php
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        pha
        phx
        phy
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb
        lda #'+'
        jsr pib_print_char
        rep #$30
        .setting "RegA16", true
        plb
        ply
        plx
        pla
        plp
        rts

    COP_debug_mark2:
        php
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb
        
        lda #'$'
        jsr pib_print_char
        
        plb
        plp
        rts    

    COP_c_return:
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true

        ; wait for any outstanding PIB command to finish before returning to the loader
        sep #$20		; 8-bit A
        .setting "RegA16", false
        jsr pib_busy_wait
        rep #$20        ; 16-bit A
        .setting "RegA16", true

        ldx os_stack_save       ; Restore the OS stack pointer we saved in the loader
        txs
        
        ; Jump directly to the "Restore OS Context" part of AppLoader
        jml $402F00    ;AppLoader_Return

    copy_12_bytes_COP_to_PIB:
        ; used to copy 12 bytes of parameters from the COP parameter area to the PIB parameter area for easier access by the OS
        pha

        lda SYSCALL_PARAMS
        sta $F00000

        lda SYSCALL_PARAMS+2
        sta $F00002

        lda SYSCALL_PARAMS+4
        sta $F00004

        lda SYSCALL_PARAMS+6
        sta $F00006

        lda SYSCALL_PARAMS+8
        sta $F00008

        lda SYSCALL_PARAMS+10
        sta $F0000A

        pla
        rts

    COP_draw_rectangle:
        php
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb
        
        ;Before calling, write to dpsram ($F00000): start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, height_lo, height_hi, color_lo, color_hi, filled
        ;jsr copy_12_bytes_COP_to_PIB

        rep #$30            ; Ensure 16-bit for the copy
        .setting "RegA16", true
        .setting "RegXY16", true
            
        jsr copy_12_bytes_COP_to_PIB

        jsr pib_draw_rectangle  
        
        plb
        plp
        rts   

    COP_draw_circle:
        rts

    COP_draw_line:
        rts

    COP_draw_pixel:
        rts

    COP_set_char_xy:
        rts

    COP_sdcard_read_sector:
        php
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        ;pha
        phx
        phy
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb
        rep #$30
        .setting "RegA16", true
        ldx SYSCALL_PARAMS      ; low 16 bits
        ldy SYSCALL_PARAMS+2    ; high 16 bits
        jsr sdcard_set_lba
        jsr sdcard_read_sector
        sta $0FFE               ; Store the status byte for C to read
        plb
        ply
        plx
        ;pla
        plp
        rts

    COP_sdcard_write_sector:
        php
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        ;pha
        phx
        phy
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb
        rep #$30
        .setting "RegA16", true
        ldx SYSCALL_PARAMS      ; low 16 bits
        ldy SYSCALL_PARAMS+2    ; high 16 bits
        jsr sdcard_set_lba
        jsr sdcard_write_sector
        sta $0FFE               ; Store the status byte for C to read
        plb
        ply
        plx
        ;pla
        plp
        rts

    COP_sdcard_init:
        php
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        ;pha
        phx
        phy
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb
        
        rep #$30
        .setting "RegA16", true
        jsr sdcard_init
        sta $0FFE               ; Store the status byte for C to read
        
        plb
        ply
        plx
        ;pla
        plp
        rts       

    COP_get_date_time:
        php
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        pha
        phx
        phy
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb
        jsr rtc_get_date
        jsr rtc_get_time
        lda RTC_YEAR
        sta SYSCALL_PARAMS + 0
        lda RTC_MONTH
        sta SYSCALL_PARAMS + 1
        lda RTC_DAY
        sta SYSCALL_PARAMS + 2
        lda RTC_HRS
        sta SYSCALL_PARAMS + 3
        lda RTC_MIN
        sta SYSCALL_PARAMS + 4
        lda RTC_SEC
        sta SYSCALL_PARAMS + 5
        rep #$30
        .setting "RegA16", true
        plb
        ply
        plx
        pla
        plp
        rts

    COP_cApp_return:

        php
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb
        
        lda #'+'
        jsr pib_print_char
        
        plb
        plp

        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true

        ldx SHELL_STACK_SAVE       ; Restore the shell stack pointer we saved in the loader
        txs

        ; Jump directly to the "Restore OS Context" part of AppLoader
        jml $00E800    ; AppLoaderC_Return     
