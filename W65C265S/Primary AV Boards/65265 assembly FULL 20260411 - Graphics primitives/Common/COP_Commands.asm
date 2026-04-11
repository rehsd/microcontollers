.setting "HandleLongBranch", true
.setting "RegA16", true
.setting "RegXY16", true


; "Signatures 00-7F may be user defined, while signatures 80-FF are reserved for instructions on future microprocessors." 65816 datashet

; SYSCALL_PARAMS   = $0F00

; Parameter data is placed in SYSCALL_PARAMS   = $0F00 (up to 256 bytes)
;                                 COP #         byte0       byte1       byte2       byte3      ...
COP_CMD_NONE                .equ  $00  
COP_CMD_PRINT_CHAR          .equ  $01       ;   ascii
COP_CMD_NEWLINE             .equ  $02
COP_CMD_DEBUG_MARK          .equ  $03
COP_CMD_DEBUG_MARK2         .equ  $04
COP_CMD_C_RETURN            .equ  $05
COP_CMD_DRAW_RECTANGLE      .equ  $06
COP_CMD_DRAW_CIRCLE         .equ  $07
COP_CMD_DRAW_LINE           .equ  $08
COP_CMD_DRAW_PIXEL          .equ  $09
COP_CMD_SET_CHAR_XY         .equ  $0A
COP_CMD_SDCARD_READ_SECTOR  .equ  $0B       ;   lba0        lba1        lba_2       lba_3       ; for now, shared RAM buffer TO FILL at $1200 (512 bytes)
COP_CMD_SDCARD_WRITE_SECTOR .equ  $0C       ;   lba0        lba1        lba_2       lba_3       ; for now, shared RAM buffer TO READ at $1200 (512 bytes)
COP_CMD_SDCARD_INIT         .equ  $0D
COP_CMD_GET_DATE_TIME       .equ  $0E       ; returns a byte for each: year, month, day, hour, minute, second in SYSCALL_PARAMS
COP_CMD_CAPP_RETURN         .equ  $0F
COP_CMD_GET_KBD_CHAR        .equ  $10       ; returns ascii code of key pressed in byte0, or 0 if no key pressed
COP_CMD_CLEAR_SCREEN        .equ  $11
COP_CMD_PRINT_CHAR_SERIAL   .equ  $12
COP_CMD_NEWLINE_SERIAL      .equ  $13
COP_CMD_INIT_C_APP          .equ  $14       ; for now, just sets up the entry point and jumps to it, but could be used for more complex initialization in the future
COD_CMD_SET_DATE_TIME       .equ  $15       ; expects a byte for each: year, month, day, hour, minute, second in SYSCALL_PARAMS
COP_CMD_DRAW_DIAMOND        .equ  $16       
COP_CMD_SET_CHAR_COLOR      .equ  $17       ; color_lo    color_hi
COP_CMD_DRAW_SPRITE_32      .equ  $18       ; x_lo, x_hi, y_hi, y_hi, sprite_id_lo, sprite_id_hi
COP_CMD_DRAW_SPRITE_16      .equ  $19       ; x_lo, x_hi, y_hi, y_hi, sprite_id_lo, sprite_id_hi
COP_CMD_TILE_BACKUP_32      .equ  $1A       ; x_lo, x_hi, y_hi, y_hi; saves 32x32 tile to shared RAM at $07:1000
COP_CMD_TILE_BACKUP_16      .equ  $1B       ; x_lo, x_hi, y_hi, y_hi; saves 16x16 tile to shared RAM at $07:1100
COP_CMD_TILE_RESTORE_32     .equ  $1C       ; x_lo, x_hi, y_hi, y_hi; restores 32x32 tile from shared RAM at $07:1000
COP_CMD_TILE_RESTORE_16     .equ  $1D       ; x_lo, x_hi, y_hi, y_hi; restores 16x16 tile from shared RAM at $07:1100