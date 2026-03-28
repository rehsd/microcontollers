
; "Signatures 00-7F may be user defined, while signatures 80-FF are reserved for instructions on future microprocessors." 65816 datashet

SYSCALL_PARAMS   = $0F00

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