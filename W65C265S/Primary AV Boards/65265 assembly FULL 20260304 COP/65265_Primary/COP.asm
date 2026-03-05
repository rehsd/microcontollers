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
    ; ==========================================================
    ; Stack Frame at TSX (16-bit mode):
    ; ==========================================================
    ; Offset | Size | Contents
    ; -------|------|-------------------------------------------
    ;  $00,x |  --  | (Stack Pointer points here)
    ;  $01,x |  2   | Saved Y Register (High/Low)
    ;  $03,x |  2   | Saved X Register (High/Low)
    ;  $05,x |  2   | Saved A Register (High/Low)
    ;  $07,x |  1   | Saved P Register (Status from PHP)
    ;  $08,x |  1   | Hardware Saved P (Status from COP)
    ;  $09,x |  2   | Hardware Saved PC (Program Counter)
    ;  $0b,x |  1   | Hardware Saved PBR (Program Bank)
    ; ==========================================================

    php					        
    rep #$30				    ; 16-bit A
    .setting "RegA16", true
    .setting "RegXY16", true
    pha					        
    phx					        
    phy					        

    tsx					        ; move stack pointer to X
    lda $09,x				    ; load PCL/PCH from hardware stack frame
    sec					        ; set carry for subtraction
    sbc #1					    ; point to COP signature byte
    sta tmp					    ; store address low in direct page
    lda $0b,x				    ; load PBR (bank) from hardware stack
    sta tmp+2				    ; store bank in direct page pointer
    lda [tmp]				    ; fetch the actual signature byte
    and #$00ff				    ; isolate signature value
    asl					        ; multiply by 2 for word-table index
    tax					        ; move index to X
    pea return_from_table-1		; push return address for RTS to find
    jmp (sys_jump_table,x)		; jump to routine via vector table
    
    return_from_table:
        ; jsr dump_cop_context	; call memory dump routine
        ply					
        plx					
        pla					
        plp					
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

; COP support commands
    COP_none:
        rts

    COP_print_char:
        lda SYSCALL_PARAMS
        jsr pib_print_char
        rts

    COP_newline:
        jsr pib_newline
        rts