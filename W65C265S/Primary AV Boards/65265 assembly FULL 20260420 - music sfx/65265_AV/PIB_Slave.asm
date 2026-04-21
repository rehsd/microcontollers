
; Core PIB control and data registers
PIBFR              .equ $DF78       ; PIB flag register
PIBER              .equ $DF79       ; PIB enable register
PIR2               .equ $DF7A       ; CMD_hi
PIR3               .equ $DF7B       ; CMD_lo
PIR4               .equ $DF7C       ; Param1
PIR5               .equ $DF7D       ; Param2
PIR6               .equ $DF7E       ; Param3
PIR7               .equ $DF7F       ; Param4

;  PIBIRQENABLE:		equ %01000000		;$40

;--------------------------------------------------
; Port 4 Bit Masks (PIB Control — P42–P47)
;--------------------------------------------------
PIIB        .equ %00000100    ; P42 — Data Ready / STB       (master->slave)
PIWEB       .equ %00001000    ; P43 — Write Strobe / ACK     (slave->master)
PICSB       .equ %00010000    ; P44 — Chip Select B

PIRS7   .equ %11100000    ; PIR7 value for mailbox slot selection
PIRS6   .equ %11000000    ; PIR6 value for mailbox slot selection
PIRS5   .equ %10100000    ; PIR5 value for mailbox slot selection
PIRS4   .equ %10000000    ; PIR4 value for mailbox slot selection
PIRS3   .equ %01100000    ; PIR3 value for mailbox slot selection
PIRS2   .equ %01000000    ; PIR2 value for mailbox slot selection

.include "../Common/PIB_Commands.asm"


.setting "RegA16", false
.setting "RegXY16", true
.setting "HandleLongBranch", true


;==================================================
; Slave PIB init
;  - PD5: data bus, all inputs
;  - PD4: PIWEB output, others input
;  - PIB: automatic handshake mode, IRQ on PIIB via EIER/IRQPIB
;==================================================
Init_PIB_slave:

    sep #$20
    .setting "RegA16", false

    ; PD5 = inputs (slave only reads data)
    lda #%00000000
    sta PDD5                ; pd5 = inputs

    ; PD4:
    ;   P42 (PIIB)      = input  (from master)
    ;   P43 (PIWEB)     = output (to master)
    ;   P44 (PICSB)     = input  (from master)
    ;   P45–P47 (PIRS)  = inputs
    lda PDD4
    ora #PIWEB              ; set PIWEB as output, preserve others
    sta PDD4

    ;--------------------------------------------------
    ;   PIBER7 = Enable Automatic Handshake Input Data in PIR7 Interrupt (slave settable)
    ;   PIBER6 = Enable Automatic Handshake Output Data in PIR7 Interrupt (master settable)
    ;   PIBER5 = Enable Manual Handshake from Host (slave settable)
    ;   PIBER4 = Enable Manual Handshake from Processor (master settable)
    ;   PIBER3 = Enable Automatic Handshake Input Data in PIR3 Interrupt (slave settable)
    ;   PIBER2 = Enable Automatic Handshake Output Data in PIR3 Interrupt (master settable)
    ;   PIBER1 = Enable RDB and WRB (slave settable)
    ;   PIBER0 = Enable PIB
    ;--------------------------------------------------
    ;lda #%10001001

    
    ; can fill PIRS2-6, followed by 7 to trigger slave interrupt (6 bytes of data total)
    lda #%10000001  ; enable PIB and automatic handshake for PIR7
    sta PIBER

    ; Idle: PIWEB high
    ;lda PD4
    ;ora #PIWEB
    ;sta PD4

    ; Enable PIB edge interrupt (PIIB) so IRQPIB vector fires
    lda EIER
    ora #PIBIRQENABLE       ; enable PIB edge source
    sta EIER

    rep #$20
    .setting "RegA16", true
    rts

IRQHandler_IRQPIB:

    php
    sep #$20           ; 8-bit A
    .setting "RegA16", false
    pha                ; save A

    ; Read PIBFR to determine which PIR caused the interrupt, check bits and branch accordingly
    ; Only PIR7 is enabled for now, so we know it's PIR7 that caused the interrupt. Skipping PIR3/PIR7 check.

    ;lda PIR2   ; CMD_hi - reserved for future expansion
    lda PIR_CMD_LO   ; CMD_lo

    cmp #PIB_CMD_PRINT_CHAR
    bne @notprintchar
    jmp pib_print_char
    @notprintchar:

        cmp #PIB_CMD_DRAW_RECT
        bne @notdrawrect
        jmp pib_draw_rect
    @notdrawrect:

        cmp #PIB_CMD_NEWLINE
        bne @notnewline
        jmp pib_newline
    @notnewline:

        cmp #PIB_CMD_SET_CHAR_XY
        bne @notsetcharxy
        jmp pib_set_char_xy
    @notsetcharxy:

        cmp #PIB_CMD_SET_CHAR_COLOR
        bne @notsetcharcolor
        jmp pib_set_char_color
    @notsetcharcolor:

        cmp #PIB_CMD_DRAW_LINE
        bne @notdrawline
        jmp pib_draw_draw_line
    @notdrawline:

        cmp #PIB_CMD_DRAW_CIRCLE
        bne @notdrawcircle
        jmp pib_draw_circle
    @notdrawcircle:

        cmp #PIB_CMD_DRAW_PIXEL
        bne @notdrawpixel
        jmp pib_draw_pixel
    @notdrawpixel:

        cmp #PIB_CMD_DRAW_DIAMOND
        bne @notdrawdiamond
        jmp pib_draw_diamond
    @notdrawdiamond:

        cmp #PIB_CMD_CLEAR_SCREEN
        bne @notclearscreen
        jmp pib_clear_screen
    @notclearscreen:

        cmp #PIB_CMD_DRAW_SPRITE_32
        bne @notsprite32
        jmp pib_draw_sprite_32
    @notsprite32:

        cmp #PIB_CMD_DRAW_SPRITE_16
        bne @notsprite16
        jmp pib_draw_sprite_16
    @notsprite16:

        cmp #PIB_CMD_TILE_BACKUP_32
        bne @notbackup32
        jmp pib_tile_backup_32
    @notbackup32:

        cmp #PIB_CMD_TILE_BACKUP_16
        bne @notbackup16
        jmp pib_tile_backup_16
    @notbackup16:

        cmp #PIB_CMD_TILE_RESTORE_32
        bne @notrestore32
        jmp pib_tile_restore_32
    @notrestore32:

        cmp #PIB_CMD_TILE_RESTORE_16
        bne @notrestore16
        jmp pib_tile_restore_16
    @notrestore16:

        cmp #PIB_CMD_DRAW_SPRITE_8
        bne @notsprite8
        jmp pib_draw_sprite_8
    @notsprite8:

        cmp #PIB_CMD_TILE_BACKUP_8
        bne @notbackup8
        jmp pib_tile_backup_8
    @notbackup8:

        cmp #PIB_CMD_TILE_RESTORE_8
        bne @notrestore8
        jmp pib_tile_restore_8
    @notrestore8:

        cmp #PIB_CMD_PLAY_MUSIC
        bne @notplaymusic
        jmp pib_play_music
    @notplaymusic:

        cmp #PIB_CMD_PLAY_SFX
        bne @notplaysfx
        jmp pib_play_sfx
    @notplaysfx:

    bra IRQHandler_IRQPIB_out   ; unrecognized command    

pib_unset_busy:
    ;lda $F00700
    ;jsr print_hex_serial
    ;lda #'>' 
    ;jsr print_char_serial

    @RetryWrite:    ; in case the write fails (dp sram conflict?)
        lda #0
        sta $F00700

        lda $F00700
        cmp #1
        bne @Done          ; exit if NOT 1

        ; value was 1 → print it before retrying
        ;jsr print_hex_serial
        bra @RetryWrite

    @Done:
        ;jsr print_hex_serial
        rts

pib_print_char
    lda PIR_PARAM4   ; ascii char to print (this read clears the interrupt)
    ;jsr print_char_serial

    rep #$20    ; 16-bit A
    .setting "RegA16", true
    jsr print_char_vga
    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_clear_screen:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    rep #$20    ; 16-bit A
    .setting "RegA16", true
    jsr Init_VGA
    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_newline:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    rep #$20    ; 16-bit A
    .setting "RegA16", true
    jsr gfx_CRLF
    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

IRQHandler_IRQPIB_out:
    jsr pib_unset_busy
    pla
    plp		; return to original 16-bit A or 8-bit A state based on caller
    .setting "RegA16", true
    rti

pib_draw_rect:
    ; dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, height_lo, height_hi, color_lo, color_hi, filled

    lda PIR_PARAM4   ; (this read clears the interrupt)

    ;jsr crlf_serial

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta fill_region_start_x
    ;jsr print_hex16_serial

    lda $F00002
    sta fill_region_start_y
    ;jsr print_hex16_serial

    lda $F00004
    clc
    adc $F00000
    sta fill_region_end_x
    ;jsr print_hex16_serial

    lda $F00006
    clc
    adc $F00002
    sta fill_region_end_y
    ;jsr print_hex16_serial

    lda $F00008
    sta fill_region_color
    ;jsr print_hex16_serial

    ; to do: support 'filled' param - for now, always filled
    lda $F0000A
    and #$00FF      ; filled is in low byte only - high byte isn't guaranteed to be 0
    bne @drawfilled    ; If not zero, branch to the filled routine
        
        jsr gfx_DrawRectangle
        bra @done
        
    @drawfilled:
        jsr gfx_DrawRectangleFilled

    @done:

    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_draw_draw_line:
    ; dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, end_x_lo, end_x_hi, end_y_lo, end_y_hi, color_lo, color_hi

    lda PIR_PARAM4   ; (this read clears the interrupt)

    ;jsr crlf_serial

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta fill_region_start_x
    ;jsr print_hex16_serial

    lda $F00002
    sta fill_region_start_y
    ;jsr print_hex16_serial

    lda $F00004
    ;clc
    ;adc $F00000
    sta fill_region_end_x
    ;jsr print_hex16_serial

    lda $F00006
    ;clc
    ;adc $F00002
    sta fill_region_end_y
    ;jsr print_hex16_serial

    lda $F00008
    sta fill_region_color
    ;jsr print_hex16_serial

    jsr gfx_DrawLine

    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_draw_circle:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    ;jsr crlf_serial

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta fill_region_start_x
    ;jsr print_hex16_serial

    lda $F00002
    sta fill_region_start_y
    ;jsr print_hex16_serial

    lda $F00004
    sta fill_region_end_x       ; for circles, used for radius
    ;jsr print_hex16_serial

    ;lda $F00006
    ;sta fill_region_end_y       ; for circles, not used
    ;jsr print_hex16_serial

    lda $F00008
    sta fill_region_color
    ;jsr print_hex16_serial

    ; to do: support 'filled' param - for now, always filled
    lda $F0000A
    and #$00FF      ; filled is in low byte only - high byte isn't guaranteed to be 0
    bne @drawfilled    ; If not zero, branch to the filled routine
        
        jsr gfx_DrawCircle
        bra @done
        
    @drawfilled:
        jsr gfx_DrawCircleFilled

    @done:

    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_draw_pixel:
    ; dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, height_lo, height_hi, color_lo, color_hi, filled

    lda PIR_PARAM4   ; (this read clears the interrupt)

    ;jsr crlf_serial

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta fill_region_start_x
    ;jsr print_hex16_serial

    lda $F00002
    sta fill_region_start_y
    ;jsr print_hex16_serial

    lda $F00004
    clc
    adc $F00000
    sta fill_region_end_x
    ;jsr print_hex16_serial

    lda $F00006
    clc
    adc $F00002
    sta fill_region_end_y
    ;jsr print_hex16_serial

    lda $F00008
    sta fill_region_color
    ;jsr print_hex16_serial

    jsr gfx_DrawPixel

    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_draw_diamond:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    ;jsr crlf_serial

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta fill_region_start_x
    ;jsr print_hex16_serial

    lda $F00002
    sta fill_region_start_y
    ;jsr print_hex16_serial

    lda $F00004
    sta fill_region_end_x       ; for diamonds, used for radius
    ;jsr print_hex16_serial

    ;lda $F00006
    ;sta fill_region_end_y       ; for diamonds, not used
    ;jsr print_hex16_serial

    lda $F00008
    sta fill_region_color
    ;jsr print_hex16_serial

    ; to do: support 'filled' param - for now, always filled
    lda $F0000A
    and #$00FF      ; filled is in low byte only - high byte isn't guaranteed to be 0
    bne @drawfilled    ; If not zero, branch to the filled routine
        
        jsr gfx_DrawDiamond
        bra @done
        
    @drawfilled:
        jsr gfx_DrawDiamondFilled

    @done:

    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_set_char_xy:
   ; dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, height_lo, height_hi, color_lo, color_hi, filled
	;char_vp_x    0 to 319
	;char_vp_y    0 to 239
    lda PIR_PARAM4   ; (this read clears the interrupt)

    ;jsr crlf_serial

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta char_vp_x

    lda $F00002
    sta char_vp_y

	lda #0
	sta char_x_offset
    
    jsr gfx_SetCharVpByXY

    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_set_char_color:
   ; dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, height_lo, height_hi, color_lo, color_hi, filled
    lda PIR_PARAM4   ; (this read clears the interrupt)

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta char_color

    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_draw_sprite_32:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta sprite_x

    lda $F00002
    sta sprite_y

    lda $F00004
    sta sprite_id

    jsr gfx_DrawSprite32

    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_draw_sprite_16:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta sprite_x

    lda $F00002
    sta sprite_y

    lda $F00004
    sta sprite_id

    jsr gfx_DrawSprite16
    
    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_tile_backup_32:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta sprite_x

    lda $F00002
    sta sprite_y

    jsr gfx_BackupTile32
    
    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_tile_backup_16:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta sprite_x

    lda $F00002
    sta sprite_y

    jsr gfx_BackupTile16
    
    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_tile_restore_32:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta sprite_x

    lda $F00002
    sta sprite_y

    jsr gfx_RestoreTile32
    
    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_tile_restore_16:
    lda PIR_PARAM4   ; (this read clears the interrupt)

    rep #$20    ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta sprite_x

    lda $F00002
    sta sprite_y

    jsr gfx_RestoreTile16
    
    sep #$20           ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out    

pib_draw_sprite_8:
    lda PIR_PARAM4      ; (this read clears the interrupt)

    rep #$20            ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta sprite_x

    lda $F00002
    sta sprite_y

    lda $F00004
    sta sprite_id

    jsr gfx_DrawSprite8
    
    sep #$20            ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_tile_backup_8:
    lda PIR_PARAM4      ; (this read clears the interrupt)

    rep #$20            ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta sprite_x

    lda $F00002
    sta sprite_y

    jsr gfx_BackupTile8
    
    sep #$20            ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out

pib_tile_restore_8:
    lda PIR_PARAM4      ; (this read clears the interrupt)

    rep #$20            ; 16-bit A
    .setting "RegA16", true

    lda $F00000
    sta sprite_x

    lda $F00002
    sta sprite_y

    jsr gfx_RestoreTile8
    
    sep #$20            ; 8-bit A
    .setting "RegA16", false

    bra IRQHandler_IRQPIB_out
    
pib_play_music:
    lda PIR_PARAM4          ; Clear the interrupt

    rep #$30                ; 16-bit A, 16-bit X/Y
    .setting "RegA16", true
    .setting "RegXY16", true

    ; 1. Get Music ID from PIB and find table offset
    lda $F00000             ; ID sent by Master
    and #$00FF              ; Safety mask
    asl a                   ; ID * 2
    asl a                   ; ID * 4 (Each table entry is 4 bytes)
    tax

    ; 2. Load address from table into storage
    lda music_table,x
    sta Music_ID_Lo         ; Store 16-bit offset
    
    lda music_table+2,x
    sta Music_ID_Hi         ; Store 16-bit bank/high word

    ; 3. Prepare parameters for Start_Music
    ; Expected: X = 16-bit Offset, A = 8-bit Bank
    ldx Music_ID_Lo         ; X = Offset (e.g., MUSIC_TETRIS_TRIPLE)
    
    lda Music_ID_Hi         ; Get bank word
    sep #$20                ; 8-bit A
    .setting "RegA16", false
    ; A now holds the bank byte

    ; 4. Initialize engine state
    jsr Start_Music

    bra IRQHandler_IRQPIB_out
    
pib_play_sfx:
    lda PIR_PARAM4          ; Clear the interrupt

    rep #$30                ; 16-bit A, 16-bit X/Y
    .setting "RegA16", true
    .setting "RegXY16", true

    ; 1. Get Music ID from PIB and find table offset
    lda $F00000             ; ID sent by Master
    and #$00FF              ; Safety mask
    asl a                   ; ID * 2
    asl a                   ; ID * 4 (Each table entry is 4 bytes)
    tax

    ; 2. Load address from table into storage
    lda sfx_table,x
    sta sfx_ID_Lo         ; Store 16-bit offset
    
    lda sfx_table+2,x
    sta sfx_ID_Hi         ; Store 16-bit bank/high word

    ; 3. Prepare parameters for Start_Music
    ; Expected: X = 16-bit Offset, A = 8-bit Bank
    ldx sfx_ID_Lo         ; X = Offset (e.g., MUSIC_TETRIS_TRIPLE)
    
    lda sfx_ID_Hi         ; Get bank word
    sep #$20                ; 8-bit A
    .setting "RegA16", false
    ; A now holds the bank byte

    ; 4. Initialize engine state
    jsr Start_SFX

    bra IRQHandler_IRQPIB_out

