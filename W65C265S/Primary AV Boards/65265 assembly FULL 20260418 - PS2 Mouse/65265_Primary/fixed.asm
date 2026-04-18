// in vars.asm:         hex_entry_ptr:      = $B2       ; 3 bytes (24-bit entry point)
.setting "RegA16", true
.setting "RegXY16", true
.setting "HandleLongBranch", true

; reserve space used by the '265 registers at $00DF00-$00DFFF
; warn on build if previous code overlaps
.if * > $DF00
  .error "Flash Overlap: Code reached {hex(*)}, exceeding $DEFF limit!"
.endif
.org $00DF00
.ds $0100, $FF  ; define storage for 256 bytes used for on-chip registers

.org $00E000
AppLoaderC:

    //php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    cld                             ; Clear decimal mode for C
    phb                             ; Save Shell Bank
    phd                             ; Save Shell DP ($4000)

    ; Save Shell Stack Pointer to Bank 0 absolute address
    tsx
    txa
    sta $070000+SHELL_STACK_SAVE

    ; Setup App Environment
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                             ; Data Bank 0
    rep #$20
    .setting "RegA16", true

    lda #$0000                      ; Switch to Direct Page xxx
    tcd   

    
    lda #$0000               ; addr bank     always 0 in my setup
    sta hex_entry_ptr+2
    lda $0FEE               ; Loads 0x0FEE (PCL) and 0x0FEF (PCH) into A
    sta hex_entry_ptr       ; Stores them to the low 16 bits of the pointer
    jml [hex_entry_ptr]

