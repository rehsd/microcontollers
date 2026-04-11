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
.word COP_get_kbd_char          ; address for cop #$10      ; Get keyboard character
.word COP_clear_screen          ; address for cop #$11      ; Clear the VGA screen
.word COP_print_char_serial     ; address for cop #$12      ; Print char to serial port (for debugging)
.word COP_newline_serial        ; address for cop #$13      ; Newline to serial port (for debugging)
.word COP_init_C_app            ; address for cop #$14      ; Initialization routine for C apps (if needed)
.word COP_set_date_time         ; address for cop #$15      ; Set date/time (parameters in dpsram) - year, month, day, hour, minute, second
.word COP_draw_diamond          ; address for cop #$16      ; Draw diamond (parameters in dpsram)
.word COP_set_char_color        ; address for cop #$17      ; Set text color (parameters in dpsram) - color_lo, color_hi
.word COP_draw_sprite_32        ; address for cop #$18      ; Draw 32x32 sprite (parameters in dpsram) - x_lo, x_hi, y_lo, y_hi, sprite_id_lo, sprite_id_hi
.word COP_draw_sprite_16        ; address for cop #$19      ; Draw 16x16 sprite (parameters in dpsram) - x_lo, x_hi, y_lo, y_hi, sprite_id_lo, sprite_id_hi
.word COP_backup_tile_32        ; address for cop #$1A      ; Backup 32x32 tile (parameters in dpsram) - x_lo, x_hi, y_lo, y_hi; saves to shared RAM at $07:1000
.word COP_backup_tile_16        ; address for cop #$1B      ; Backup 16x16 tile (parameters in dpsram) - x_lo, x_hi, y_lo, y_hi; saves to shared RAM at $07:1100
.word COP_restore_tile_32       ; address for cop #$1C      ; Restore 32x32 tile (parameters in dpsram) - x_lo, x_hi, y_lo, y_hi; restores from shared RAM at $07:1000
.word COP_restore_tile_16       ; address for cop #$1D      ; Restore 16x16 tile (parameters in dpsram) - x_lo, x_hi, y_lo, y_hi; restores from shared RAM at $07:1100


; COP support commands
COP_none:
    rts

COP_print_char:
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    pha                             ; Save A (16-bit)
    phx                             ; Save X (16-bit)
    phy                             ; Save Y (16-bit)
    phb                             ; Save Bank (1 byte)
    phd                             ; Save Direct Page (2 bytes)

    lda #$0000
    tcd                             ; Force D=0
    
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                             ; Force DB=0
    
    lda SYSCALL_PARAMS              ; Get char
    
    cmp #$0D                        ; Check for CR (Carriage Return)
    beq printchar_is_newline
    cmp #$0A                        ; Check for LF (Line Feed)
    beq printchar_ignore_char         ; If it's LF, we ignore it (assuming CR handles the move)
    
    jsr pib_print_char              ; Not a newline, print it
    bra printchar_done

    printchar_is_newline:
        jsr pib_newline                 ; Perform newline logic

    printchar_ignore_char:
    printchar_done:
        rep #$30
        .setting "RegA16", true
        pld                             ; Restore DP
        plb                             ; Restore Bank
        ply                             ; Restore Y
        plx                             ; Restore X
        pla                             ; Restore A
        plp                             ; Restore Flags
        rts

COP_newline:
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    pha                             ; Save A (16-bit)
    phx                             ; Save X (16-bit)
    phy                             ; Save Y (16-bit)
    phb                             ; Save caller Bank (1 byte)
    phd                             ; Save caller DP (2 bytes)

    lda #$0000
    tcd                             ; Direct Page = 0
    
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha                             ; Push 1 byte
    plb                             ; Pull 1 byte (DBR = 0)
    
    jsr pib_newline
    
    rep #$30
    .setting "RegA16", true
    pld                             ; Pull 2 bytes (DP restored)
    plb                             ; Pull 1 byte (Bank restored)
    ply                             ; Pull 2 bytes (Y restored)
    plx                             ; Pull 2 bytes (X restored)
    pla                             ; Pull 2 bytes (A restored)
    plp                             ; Pull 1 byte (Flags restored)
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
    plb                         ; Switch to Bank 0
    
    lda #'+'
    jsr pib_print_char
    
    rep #$30
    .setting "RegA16", true
    plb                         ; Restore original Bank
    ply
    plx
    pla
    plp
    rts

COP_debug_mark2:
    php
    rep #$30
    .setting "RegA16", true
    pha                         ; Save A even if you don't save X/Y
    phb
    
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb
    
    lda #'$'
    jsr pib_print_char
    
    rep #$30
    .setting "RegA16", true
    plb
    pla
    plp
    rts   

COP_c_return:
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true

    ; 1. Wait for PIB (Hardware cleanup)
    sep #$20
    .setting "RegA16", false
    jsr pib_busy_wait
    
    ; 2. Clear Hardware Latch (Keyboard cleanup)
    lda $E001               ; Read PORTA to clear VIA0 IRQ line
    
    ; 3. Reset the Stack (Stack cleanup)
    ; This "forgets" the 4-byte COP frame and the C stack
    rep #$30
    .setting "RegA16", true
    ldx OS_STACK_SAVE
    txs
    
    ; 4. Restore OS Context (Mirror of $2E00 Entry)
    ; Entry: phb, phd. Pull: pld, plb.
    pld                     ; Pull 16-bit Direct Page
    sep #$20
    .setting "RegA16", false
    plb                     ; Pull 8-bit Data Bank
    
    ; 5. Force System Defaults (Absolute Safety)
    lda #$00
    pha
    plb                     ; Ensure Bank 0
    rep #$30
    .setting "RegA16", true
    lda #$0000
    tcd                     ; Ensure DP 0
    
    ; 6. THE FIX: Open the Gate
    ; This replaces the 'rti' functionality for the 'I' bit
    cli                     
    
    ; 7. Exit
    ; This returns to the original caller of ShellLoader
    rtl

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

COP_sdcard_read_sector:
            php
            rep #$30
            .setting "RegA16", true
            .setting "RegXY16", true
            pha                     ; Save A (16-bit)
            phx                     ; Save X (16-bit)
            phy                     ; Save Y (16-bit)
            phb                     ; Save caller's Bank (1 byte)
            phd                     ; Save caller's DP (2 bytes)

            lda #$0000
            tcd                     ; D=0
            
            sep #$20
            .setting "RegA16", false
            lda #$00
            pha
            plb                     ; DB=0 (Temporary bank switch)
            
            rep #$30                ; 16-bit for LBA
            .setting "RegA16", true
            ldx SYSCALL_PARAMS
            ldy SYSCALL_PARAMS+2
            jsr sdcard_set_lba
            
            sep #$20                ; 8-bit for read
            .setting "RegA16", false
            jsr sdcard_read_sector
            sta $0FFE
            
            rep #$30
            .setting "RegA16", true
            pld                     ; Restore DP (2 bytes)
            plb                     ; Restore Bank (1 byte)
            ply                     ; Restore Y (2 bytes)
            plx                     ; Restore X (2 bytes)
            pla                     ; Restore A (2 bytes)
            plp                     ; Restore Flags (1 byte)
            rts
            
COP_sdcard_write_sector:
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    pha                         ; Save A
    phx                         ; Save X
    phy                         ; Save Y
    phb                         ; Save caller's Bank (1 byte)
    phd                         ; Save caller's DP (2 bytes)

    lda #$0000
    tcd                         ; Direct Page = 0
    
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                         ; Set DBR = 0
    
    rep #$30                    ; 16-bit for LBA parameters
    .setting "RegA16", true
    ldx SYSCALL_PARAMS
    ldy SYSCALL_PARAMS+2
    jsr sdcard_set_lba
    
    sep #$20                    ; 8-bit for write and status
    .setting "RegA16", false
    jsr sdcard_write_sector
    sta $0FFE
    
    rep #$30
    .setting "RegA16", true
    pld                         ; Restore DP
    plb                         ; Restore Bank
    ply                         ; Restore Y
    plx                         ; Restore X
    pla                         ; Restore A
    plp                         ; Restore Flags
    rts

COP_sdcard_init:
        php
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        
        pha                     ; Save A (16-bit)
        phx                     ; Save X (16-bit)
        phy                     ; Save Y (16-bit)
        phb                     ; Save Bank (1 byte)
        phd                     ; Save Direct Page (2 bytes)

        lda #$0000
        tcd                     ; Force D=0
        
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha
        plb                     ; DBR = 0 (This pha is matched by this plb)

        jsr sdcard_init
        sta $0FFE               ; Store status for C
        
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        
        pld                     ; Restore caller's D (2 bytes)
        plb                     ; Restore caller's B (1 byte)
        ply                     ; Restore caller's Y (2 bytes)
        plx                     ; Restore caller's X (2 bytes)
        pla                     ; Restore caller's A (2 bytes)
        plp                     ; Restore caller's Flags
        rts

COP_get_date_time:
        php
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true
        pha                             ; Save A (16-bit)
        phx                             ; Save X (16-bit)
        phy                             ; Save Y (16-bit)
        phb                             ; Save caller Bank (1 byte)
        phd                             ; Save caller DP (2 bytes)

        lda #$0000
        tcd                             ; Force D=0 for OS variables
        
        sep #$20
        .setting "RegA16", false
        lda #$00
        pha                             ; Push 1 byte
        plb                             ; Pull 1 byte (DBR = 0)
        
        ; Call internal RTC routines
        jsr rtc_get_date
        jsr rtc_get_time
        
        ; Map RTC values to the syscall parameter mailbox
        ; Assuming RTC variables and SYSCALL_PARAMS are in Bank 0
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
        
        ; Restore context
        rep #$30
        .setting "RegA16", true
        pld                             ; Restore caller DP
        plb                             ; Restore caller Bank
        ply                             ; Restore caller Y
        plx                             ; Restore caller X
        pla                             ; Restore caller A
        plp                             ; Restore caller Flags
        rts

    COP_cApp_return:
        rep #$30
        .setting "RegA16", true
        .setting "RegXY16", true

        ; 1. Wait for PIB (Hardware cleanup)
        sep #$20
        .setting "RegA16", false
        jsr pib_busy_wait
        
        ; 2. Clear Hardware Latch (Keyboard cleanup)
        lda $E001               ; Read PORTA to clear VIA0 IRQ line
        
        ; 3. Reset the Stack (Stack cleanup)
        ; This "forgets" the 4-byte COP frame and the C stack
        rep #$30
        .setting "RegA16", true
        lda $070000+SHELL_STACK_SAVE
        tax
        txs
        
        ; 4. Restore OS Context (Mirror of $2E00 Entry)
        ; Entry: phb, phd. Pull: pld, plb.
        pld                     ; Pull 16-bit Direct Page
        sep #$20
        .setting "RegA16", false
        plb                     ; Pull 8-bit Data Bank
        
        ; 5. Force System Defaults (Absolute Safety)
        lda #$00
        pha
        plb                     ; Ensure Bank 0
        rep #$30
        .setting "RegA16", true
        lda #$4000
        tcd                     ; Ensure DP 0
        
        ; 6. THE FIX: Open the Gate
        ; This replaces the 'rti' functionality for the 'I' bit
        cli                     
        
        ; 7. Exit
        ; This returns to the original caller of ShellLoader
        rtl

    COP_get_kbd_char:
        php
        rep #$30                ; 16-bit for safe context preservation
        .setting "RegA16", true
        .setting "RegXY16", true
        
        pha                     ; Save A (16-bit)
        phx                     ; Save X (16-bit)
        phy                     ; Save Y (16-bit)
        phb                     ; Save Bank (Pushes 1 byte, SP-1)
        phd                     ; Save Direct Page (2 bytes, SP-2)

        lda #$0000
        tcd                     ; Force D=0 for OS variables
        
        sep #$20                ; 8-bit for Bank setup
        .setting "RegA16", false
        lda #$00
        pha
        plb                     ; Force DB=0

        ; --- Atomic Comparison ---
        sei                     ; Disable ISRs while checking/moving pointers
        rep #$20
        .setting "RegA16", true
        
        lda KeyBuf_Head
        cmp KeyBuf_Tail
        beq cop_kbd_char_no_key ; If Head == Tail, buffer is empty

        ; --- Key Found ---
        lda KeyBuf_Tail
        and #$001F              ; Mask to 32-byte boundary
        tax                     ; X = index
        
        sep #$20                ; 8-bit to read the character
        .setting "RegA16", false
        lda KeyBuf, x           ; Get char from buffer
        sta $0FFE               ; Store result for C code

        rep #$20                ; 16-bit to increment tail
        .setting "RegA16", true
        lda KeyBuf_Tail
        inc a                   ; Increment accumulator
        and #$001F              ; Wrap at 32
        sta KeyBuf_Tail         ; Commit back to memory
        
        cli                     ; Safe to re-enable interrupts
        bra cop_kbd_char_done

        cop_kbd_char_no_key:
                cli                     ; Re-enable interrupts
                sep #$20                ; 8-bit to clear result
                .setting "RegA16", false
                stz $0FFE               ; Return 0 if no key

        cop_kbd_char_done:
                ; --- Balanced Stack Pull ---
                rep #$30                ; Return to 16-bit for ALL pulls
                .setting "RegA16", true
                .setting "RegXY16", true
                
                pld                     ; Restore Direct Page
                plb                     ; Restore Bank (Matches 16-bit push state)
                ply                     ; Restore Y
                plx                     ; Restore X
                pla                     ; Restore A
                plp                     ; Restore Flags (Re-enables interrupts if they were on)
                rts

COP_clear_screen:
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    
    pha                             ; Save A (16-bit)
    phx                             ; Save X (16-bit)
    phy                             ; Save Y (16-bit)
    phb                             ; Save caller Bank (1 byte)
    phd                             ; Save caller Direct Page (2 bytes)

    lda #$0000
    tcd                             ; Force D=0 for OS internal calls
    
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha                             ; Push 1 byte
    plb                             ; Pull 1 byte (DBR = 0)
    
    jsr pib_clear_screen            ; Execute the hardware clear
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    
    pld                             ; Restore caller DP
    plb                             ; Restore caller Bank
    ply                             ; Restore caller Y
    plx                             ; Restore caller X
    pla                             ; Restore caller A
    plp                             ; Restore caller Flags
    rts

COP_print_char_serial:
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    pha                             ; Save A (16-bit)
    phx                             ; Save X (16-bit)
    phy                             ; Save Y (16-bit)
    phb                             ; Save Bank (1 byte)
    phd                             ; Save Direct Page (2 bytes)

    lda #$0000
    tcd                             ; Force D=0
    
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                             ; Force DB=0 (using a temporary push/pull)
    
    lda SYSCALL_PARAMS              ; Get char
    jsr print_char_serial
    
    rep #$30
    .setting "RegA16", true
    pld                             ; Restore DP
    plb                             ; Restore Bank (PLB is always 1 byte)
    ply                             ; Restore Y
    plx                             ; Restore X
    pla                             ; Restore A (Pulls 2 bytes because RegA16 is true)
    plp                             ; Restore Flags
    rts

COP_newline_serial:
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    pha                             ; Save A (16-bit)
    phx                             ; Save X (16-bit)
    phy                             ; Save Y (16-bit)
    phb                             ; Save caller Bank (1 byte)
    phd                             ; Save caller DP (2 bytes)

    lda #$0000
    tcd                             ; Direct Page = 0
    
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha                             ; Push 1 byte
    plb                             ; Pull 1 byte (DBR = 0)
    
    jsr print_newline_serial
    
    rep #$30
    .setting "RegA16", true
    pld                             ; Pull 2 bytes (DP restored)
    plb                             ; Pull 1 byte (Bank restored)
    ply                             ; Pull 2 bytes (Y restored)
    plx                             ; Pull 2 bytes (X restored)
    pla                             ; Pull 2 bytes (A restored)
    plp                             ; Pull 1 byte (Flags restored)
    rts

COP_init_C_app:
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
    plb                         ; Switch to Bank 0
    
    // lda #'+'
    // jsr pib_print_char
    
    rep #$30
    .setting "RegA16", true
    plb                         ; Restore original Bank
    ply
    plx
    pla
    plp
    rts

COP_set_date_time:
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    pha
    phx
    phy
    phb
    phd

    lda #$0000
    tcd                     ; Set Direct Page to 0
    
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                     ; Set Data Bank to 0

    ; Now call your updated routines
    jsr rtc_set_time
    jsr rtc_set_date

    rep #$30
    .setting "RegA16", true
    pld                     ; Restore Direct Page (Pull 2 bytes)
    plb                     ; Restore Bank (Pull 1 byte)
    ply                     ; Restore Y
    plx                     ; Restore X
    pla                     ; Restore A
    plp                     ; Restore Flags
    rts

COP_draw_rectangle:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_draw_rectangle  
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_draw_circle:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_draw_circle 
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_draw_line:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_draw_line  
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_draw_pixel:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_draw_pixel  
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_draw_diamond:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_draw_diamond
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_set_char_xy:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_set_char_xy
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_set_char_color:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_set_char_color
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_draw_sprite_32:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_draw_sprite_32
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_draw_sprite_16:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_draw_sprite_16
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_backup_tile_32:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_backup_tile_32
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_backup_tile_16:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_backup_tile_16
    
    plb                 ; Pull original caller's bank
    plp
    rts         

COP_restore_tile_32:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_restore_tile_32
    
    plb                 ; Pull original caller's bank
    plp
    rts 

COP_restore_tile_16:
    php
    phb
    sep #$20
    .setting "RegA16", false
    lda #$00
    pha
    plb                 ; DBR = 0. This PHA is matched by this PLB.
    
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true
    jsr copy_12_bytes_COP_to_PIB
    jsr pib_restore_tile_16
    
    plb                 ; Pull original caller's bank
    plp
    rts           
    