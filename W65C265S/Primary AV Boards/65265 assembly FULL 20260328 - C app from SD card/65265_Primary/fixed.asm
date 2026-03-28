// in vars.asm:         hex_entry_ptr:      = $B2       ; 3 bytes (24-bit entry point)
.setting "RegA16", true
.setting "RegXY16", true
.setting "HandleLongBranch", true

.org $00E000
ShellLoaderC:
    lda #'='
    jsr print_char_serial

    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    cld                             ; Clear decimal mode for C
    phb                             ; Save Shell Bank
    phd                             ; Save Shell DP ($4000)

    ; Setup App Environment
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                             ; Data Bank 0
    rep #$30
    .setting "RegA16", true

    lda #'#'
    jsr print_char_serial                    

    lda #$0000                      ; Switch to Direct Page xxx
    tcd   

    ; Save Shell Stack Pointer to Bank 0 absolute address
    tsx
    stx SHELL_STACK_SAVE

    ; --- restore OS stack bank into B ---
    lda #$00
    pha
    plb

    ; --- restore OS stack pointer ---
    ldx os_stack_save  ; value saved earlier with TSX/STA
    txs                ; S := X (stack pointer restored)

    // ; Prepare return address for the App's RTL
    pea (AppLoaderC_Return-1) & $ffff
    pea (AppLoaderC_Return-1) >> 16
    
    lda #$0000               ; addr bank     always 0 in my setup
    sta hex_entry_ptr+2
    lda $0FEE               ; Loads 0x0FEE (PCL) and 0x0FEF (PCH) into A
    sta hex_entry_ptr       ; Stores them to the low 16 bits of the pointer
    jml [hex_entry_ptr]


    lda #'@'
    jsr print_char_serial     

    bra AppLoaderC_Return

.org $00E800
AppLoaderC_Return:
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true

    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb 
    
    rep #$30
    .setting "RegA16", true
    
    lda #'<'
    jsr print_char_serial   

    ; Restore Shell Stack Pointer from Bank 0
    ldx SHELL_STACK_SAVE
    txs

    ; Restore DP and Bank
    pld             ; Restore Shell Direct Page ($4000)
    plb             ; Restore Shell Data Bank
    
    ; Final Return to C
    plp             ; Restore status register (including interrupt state)
    rtl             ; Return to run_gfxTest()