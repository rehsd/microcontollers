;	$40:0000 to $47:FFFF	CS6B				512 KB external flash (secondary)
;   phsyically $00:0000 to $07:FFFF in the secondary flash chip, but mapped into CPU address space at $40:0000 to $47:FFFF

.setting "HandleLongBranch", true
.setting "RegA16", true
.setting "RegXY16", true

.include "../Common/COP_Commands.asm"


MyCode.65816.asm
.org $000000
.fill $80000, $FF   ; fill unused space with 0xFF - much faster flash programming


.org $000000
    .byte 		"rehsd!"

    ; OS call helper
        CALL_OS_ADDR = $00F200
        sysptr = $001000   ; address on OS RAM

    ; SysCallTable:  ; table of OS routine addresses (24-bit)
        SYS_ILI_PrintChar = 0
        ; room more more


.org $001000    ; really $001000 + $40:0000 = $40:1000 in app address space (secondary flash)
App1:   ; called at $40:1000
	
    rep #$30      	; 16-bit registers, indexers
    
    jsr App_Init

    ldx #SYS_ILI_PrintChar  ; command for OS to process
    lda #'T'                ; param 1
    jsr os_jsr

    lda #'e'
    jsr os_jsr

    lda #'s'
    jsr os_jsr

    lda #'t'
    jsr os_jsr

    rtl

App_Init:
    ; load 24-bit address of OS syscall into pointer
    sep #$20    ; 8-bit A
    .setting "RegA16", false
    lda #(CALL_OS_ADDR & $ff)
    sta sysptr
    lda #((CALL_OS_ADDR >> 8) & $ff)
    sta sysptr+1
    lda #((CALL_OS_ADDR >> 16) & $ff)
    sta sysptr+2
    rep #$20    ; 16-bit A
    .setting "RegA16", true
    rts

os_jsr:
    ; routine for a friendlier call (less efficient)
    ; there has to be a better way to do a jsl to a friendly name (equ, etc.),
    ; but both assemblers treat as 2-byte instead of 3-byte
    phx ; in case OS trashes x
    pha
    jsl $47FFE0
    pla
    plx
    rts

.org $002000    ; really $002000 + $40:0000 = $40:2000 in app address space (secondary flash)
App2:   ; called at $40:2000
    ; to do - stack management

    cop COP_CMD_NEWLINE

    lda #'H'
    sta SYSCALL_PARAMS
    cop COP_CMD_PRINT_CHAR

    lda #'e'
    sta SYSCALL_PARAMS
    cop COP_CMD_PRINT_CHAR

    lda #'l'
    sta SYSCALL_PARAMS
    cop COP_CMD_PRINT_CHAR

    lda #'l'
    sta SYSCALL_PARAMS
    cop COP_CMD_PRINT_CHAR

    lda #'o'
    sta SYSCALL_PARAMS
    cop COP_CMD_PRINT_CHAR

    lda #'!'
    sta SYSCALL_PARAMS
    cop COP_CMD_PRINT_CHAR

    rtl

.org $07FFE0    ; really $47FFE0
call_os_jsl:
    jml [sysptr]

.org $07FFFA
    .byte 		"rehsd!"