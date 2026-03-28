;	$40:0000 to $47:FFFF	CS6B				512 KB external flash (secondary)
;   physically $00:0000 to $07:FFFF in the secondary flash chip, but mapped into CPU address space at $40:0000 to $47:FFFF

; Variable to hold OS stack pointer
OS_STACK_SAVE  		= $0E00			; 4 bytes used in secondary ROM
SHELL_STACK_SAVE  	= $0E04			; 4 bytes used in C shell

; ********** Hex loader ********************************************************
    hex_target_bank:	= $A0		; 2 byte
    hex_ptr_addr:   	= $A2		; 2 bytes
    hex_ptr_bank:   	= $A4		; 2 byte
    hex_temp_byte:  	= $A6		; 2 byte
    hex_byte_count: 	= $A8		; 2 byte
    hex_record_type:	= $AA		; 2 byte
    hex_addr_hi:    	= $AC		; 2 byte
    hex_addr_lo:    	= $AE		; 2 byte
    hex_checksum:		= $B0		; 2 byte
    hex_entry_ptr:      = $B2       ; 3 bytes (24-bit entry point)
; ********** /Hex loader *******************************************************

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

.org $002E00            ; $40:2E00 in app address space (secondary flash)
ShellLoader:
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    cld                             ; ensure decimal mode is off
    phb
    phd
    tsx
    stx OS_STACK_SAVE

    ; --- Initialize Hex Loader State ---
    lda #$0000
    sta hex_entry_ptr
    sta hex_entry_ptr+1
    stz hex_entry_ptr+2             ; initialize bank to 0
    stz hex_target_bank
    
    ; Initialize source pointer to $40:shell_hex_start
    lda #shell_hex_start
    sta hex_ptr_addr
    sep #$20
    .setting "RegA16", false
    lda #$40
    sta hex_ptr_bank
    rep #$20
    .setting "RegA16", true

    hex_line_loop:
        sep #$20
        .setting "RegA16", false
        
        lda [hex_ptr_addr]          ; read char from flash
        jsr hex_inc_ptr             ; increment 24-bit pointer
        cmp #':'                    ; find start of record
        bne hex_line_loop           
        
        jsr hex_get_byte            ; read byte count
        sta hex_byte_count
        
        jsr hex_get_byte            ; read address high
        sta hex_addr_hi
        jsr hex_get_byte            ; read address low
        sta hex_addr_lo
        
        jsr hex_get_byte            ; read record type
        sta hex_record_type
        
        lda hex_record_type
        beq hex_type_data           ; type 00: data
        cmp #$01
        beq hex_done                ; type 01: EOF
        cmp #$04
        beq hex_type_ext_addr       ; type 04: ext linear address
        cmp #$05
        beq hex_type_start_addr     ; type 05: start linear address
        bra hex_skip_record

    hex_type_start_addr:
        jsr hex_get_byte            ; ignore bits 31-24
        jsr hex_get_byte            ; bank (bits 23-16)
        sta hex_entry_ptr+2
        jsr hex_get_byte            ; addr high
        sta hex_entry_ptr+1
        jsr hex_get_byte            ; addr low
        sta hex_entry_ptr
        bra hex_skip_done

    hex_type_ext_addr:
        jsr hex_get_byte            ; ignore upper byte
        jsr hex_get_byte            ; bank byte
        sta hex_target_bank
        bra hex_skip_done

    hex_type_data:
        rep #$30
        .setting "RegA16", true
        lda hex_addr_hi             ; merge hi/lo into Y
        and #$00ff
        xba
        ora hex_addr_lo
        and #$ffff
        tay                         ; Y = destination offset
        
        sep #$20
        .setting "RegA16", false
        lda hex_target_bank
        pha
        plb                         ; set target bank

    hex_data_loop:
        lda hex_byte_count
        beq hex_data_done
        jsr hex_get_byte
        
        ; --- Snooping for Reset Vector ($00:FFFC) ---
        pha                         ; save the byte just read
        lda hex_target_bank
        bne hex_write_to_ram        ; only check for vectors in bank 0
        
        cpy #$fffc
        beq hex_capture_lo
        cpy #$fffd
        beq hex_capture_hi

    hex_write_to_ram:
        pla                         ; restore byte
        sta $0000, y                ; write to RAM
        bra hex_next_data

    hex_capture_lo:
        pla                         ; restore byte
        sta hex_entry_ptr           ; snoop vector low byte
        bra hex_next_data

    hex_capture_hi:
        pla                         ; restore byte
        sta hex_entry_ptr+1         ; snoop vector high byte

    hex_next_data:
        iny
        dec hex_byte_count
        bra hex_data_loop

    hex_data_done:
        lda #$00
        pha
        plb                         ; restore OS bank 0
        bra hex_skip_done

    hex_skip_record:
        lda hex_byte_count
        beq hex_skip_done
    hex_skip_loop:
        jsr hex_get_byte            
        dec hex_byte_count
        bne hex_skip_loop

    hex_skip_done:
        jsr hex_get_byte            ; consume checksum
        bra hex_line_loop

    hex_done:
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true

        lda hex_entry_ptr           ; check if we snooped a vector
        ora hex_entry_ptr+1
        bne call_shell
        
        ; to do - error message that entry point not identified, cannot jump to shell
        bra call_shell

    call_shell:
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb                         ; data bank 0

        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        lda #$4000                  ; set C direct page
        tcd                               

        pea (ShellLoader_Return-1) >> 16
        pea (ShellLoader_Return-1) & $ffff
        jml [hex_entry_ptr]

    .org $002F00
    ShellLoader_Return:
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        lda #$0000
        tcd                         ; restore OS direct page
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb                         ; restore data bank 0
        rep #$30
        .setting "RegA16", true
        ldx OS_STACK_SAVE
        txs
        pld
        plb
        rtl

    ; --- Helper Routines ---

    hex_get_byte:
        lda [hex_ptr_addr]
        jsr hex_inc_ptr
        jsr hex_to_nibble
        asl a
        asl a
        asl a
        asl a
        sta hex_temp_byte
        lda [hex_ptr_addr]
        jsr hex_inc_ptr
        jsr hex_to_nibble
        ora hex_temp_byte
        rts

    hex_inc_ptr:
        rep #$20
        .setting "RegA16", true
        inc hex_ptr_addr
        bne hex_inc_ptr_done
        sep #$20
        .setting "RegA16", false
        inc hex_ptr_bank
        rep #$20
        .setting "RegA16", true
    hex_inc_ptr_done:
        sep #$20
        .setting "RegA16", false
        rts

    hex_to_nibble:
        cmp #$3a
        bcc hex_is_digit
        sbc #$07
    hex_is_digit:
        and #$0f
        rts

.org $003000    ; really $003000 + $40:0000 = $40:3000 in app address space (secondary flash)
ShellHex:
    shell_hex_start:
        .incbin "../src/shell/build/shell.hex"
    shell_hex_end:

.org $07FFE0    ; really $47FFE0
call_os_jsl:
    jml [sysptr]

.org $07FFFA
    .byte 		"rehsd!"