;	$40:0000 to $47:FFFF	CS6B				512 KB external flash (secondary)
;   physically $00:0000 to $07:FFFF in the secondary flash chip, but mapped into CPU address space at $40:0000 to $47:FFFF

; Variable to hold OS stack pointer
OS_STACK_SAVE = $0E00

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

.org $002E00            ; really $002E00 + $40:0000 = $40:2E00 in app address space (secondary flash)
AppLoader_App3:

   rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    phb
    phd
    tsx
    stx os_stack_save

    ; --- COPY BANK 00 ENTRY CODE ---
    sep #$20
    .setting "RegA16", false
    lda #$40
    pha
    plb                         ; Source bank $40

    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    ldx #app_blob_init_start    ; Source offset in flash
    ldy #$4004                  ; Destination in Bank 00 RAM
    lda #(app_blob_init_end-app_blob_init_start-1)
    mvn $00,$40                 ; Copy entry/CRT to Bank 00

    ; --- COPY BANK 06 APP CODE ---
    ldx #app_blob_start         ; Source offset in flash
    ldy #$0000                  ; Destination in Bank 06 RAM
    lda #(app_blob_end-app_blob_start-1)
    mvn $06,$40                 ; Copy main app to Bank 06

    ; --- PREPARE C CONTEXT ---
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                         ; Data Bank 0 for C app

    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    lda #$2000                  ; Match APP_ZP/registers
    tcd                         ; Set C Direct Page

    ; **********************************************
    ; **********************************************
        jsl $00491b             ; Call C app_entry (start of app.raw). Get from listing: __program_start = (e.g., 004028)
        bra AppLoader_Return
    ; **********************************************
    ; **********************************************

    ; --- RESTORE OS CONTEXT ---
    .org $002F00        ; really $002F00 + $40:0000 = $40:2F00 in app address space (secondary flash)
    AppLoader_Return:
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        lda #$0000
        tcd                         ; Restore OS Direct Page

        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb                         ; Restore Data Bank 0

        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        ldx os_stack_save
        txs
        pld
        plb
        rtl

.org $003000    ; really $003000 + $40:0000 = $40:3000 in app address space (secondary flash)
App3:
    app_blob_init_start:
        .incbin "../src/debug/build/app.raw"
    app_blob_init_end:
    app_blob_start:
        .incbin "../src/debug/build/APP_RAM_CODE.raw"
    app_blob_end:






.org $07FFE0    ; really $47FFE0
call_os_jsl:
    jml [sysptr]

.org $07FFFA
    .byte 		"rehsd!"