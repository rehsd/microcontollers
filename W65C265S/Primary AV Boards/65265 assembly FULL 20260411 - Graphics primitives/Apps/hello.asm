SYSCALL_PARAMS   = $0F00

.setting "RegA16", true
.setting "RegXY16", true

; MyCode.65816.asm
.org $030000
APP_START:
    // pha
    lda #'H'
    sta $000F00
    cop 1
    lda #'e'
    sta $000F00
    cop 1
    lda #'l'
    sta $000F00
    cop 1
    lda #'l'
    sta $000F00
    cop 1
    lda #'o'
    sta $000F00
    cop 1
    lda #'!'
    sta $000F00
    cop 1

    rtl