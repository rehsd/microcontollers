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
.word COP_none              ; address for cop #$00
.word COP_print_char        ; address for cop #$01
.word COP_newline           ; address for cop #$02
.word COP_debug_mark        ; address for cop #$03      ;+
.word COP_debug_mark2       ; address for cop #$04      ;$
.word COP_c_return          ; address for cop #$05      ; Return to '265 from C app

; COP support commands
    COP_none:
        rts

    COP_print_char:
        php
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb                         ; Force Bank 0 to find serial routines
        
        lda SYSCALL_PARAMS
        jsr pib_print_char
        
        plb
        plp
        rts  

    COP_newline:
        php
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb                         ; Force Bank 0 to find serial routines
        
        jsr pib_newline
        
        plb
        plp
        rts  

    COP_debug_mark:
        php
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb                         ; Force Bank 0 to find serial routines
        
        lda #'+'
        jsr pib_print_char
        
        plb
        plp
        rts

    COP_debug_mark2:
        php
        phb
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb                         ; Force Bank 0 to find serial routines
        
        lda #'$'
        jsr pib_print_char
        
        plb
        plp
        rts    

    COP_c_return:
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true

        ldx os_stack_save       ; Restore the OS stack pointer we saved in the loader
        txs
        
        ; Jump directly to the "Restore OS Context" part of AppLoader
        jml $402F00    ;AppLoader_Return