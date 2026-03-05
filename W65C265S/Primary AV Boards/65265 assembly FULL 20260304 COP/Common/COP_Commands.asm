
; "Signatures 00-7F may be user defined, while signatures 80-FF are reserved for instructions on future microprocessors." 65816 datashet

SYSCALL_PARAMS   = $0F00

; Parameter data is placed in SYSCALL_PARAMS   = $0F00 (up to 256 bytes)
;                                 COP #         byte0       byte1       byte2       byte3      ...
COP_CMD_NONE                .equ  $00  
COP_CMD_PRINT_CHAR          .equ  $01       ;   ascii
COP_CMD_NEWLINE             .equ  $02
