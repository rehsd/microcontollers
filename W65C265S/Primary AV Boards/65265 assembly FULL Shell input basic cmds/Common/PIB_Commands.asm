.setting "HandleLongBranch", true
.setting "RegA16", true
.setting "RegXY16", true

; Dual-port SRAM at $F0:0000 to $F0:07FF
;       $F0:0000 to $F0:00FF for general PIB parameter data
;       TO DO: Implement ring buffer and alloc/dealloc commands for more complex data storage

; PIR2      PIR3    PIR4    PIR5    PIR6    PIR7
; CMD_hi    CMD_lo  Param1  Param2  Param3  Param4

PIB_CMD_HI      .equ $02
PIB_CMD_LO      .equ $03
PIB_CMD_PARAM1  .equ $04
PIB_CMD_PARAM2  .equ $05
PIB_CMD_PARAM3  .equ $06
PIB_CMD_PARAM4  .equ $07

PIR_CMD_HI      .equ $DF7A       ; CMD_hi
PIR_CMD_LO      .equ $DF7B       ; CMD_lo
PIR_PARAM1      .equ $DF7C       ; Param1
PIR_PARAM2      .equ $DF7D       ; Param2
PIR_PARAM3      .equ $DF7E       ; Param3
PIR_PARAM4      .equ $DF7F       ; Param4

;                           CMD_hi+CMD_lo         Param1        Param2      Param3      Param4      Notes
PIB_CMD_PRINT_CHAR          .equ  $0000         ; -             -           -           ascii
PIB_CMD_CLEAR_SCREEN        .equ  $0001         ; -             -           -           -
PIB_CMD_SET_CHAR_COLOR      .equ  $0002         ; -             -           color_lo    color_hi
PIB_CMD_SET_DRAW_COLOR      .equ  $0003         ; -             -           color_lo    color_hi
PIB_CMD_DRAW_RECT           .equ  $0004         ; -             -           -           -           *Read from dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, height_lo, height_hi, color_lo, color_hi, filled
PIB_CMD_DRAW_CIRCLE         .equ  $0005         ; -             -           -           -           *Read from dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, radius_lo, radius_hi, color_lo, color_hi, filled
PIB_CMD_DRAW_LINE           .equ  $0006         ; -             -           -           -           *Read from dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, end_x_lo, end_x_hi, end_y_lo, end_y_hi, color_lo, color_hi
PIB_CMD_DRAW_PIXEL          .equ  $0007         ; -             -           -           -           *Read from dpsram: x_lo, x_hi, y_hi, y_hi, color_lo, color_hi
PIB_CMD_NEWLINE             .equ  $0008         ; -             -           -           -           -


PIB_masks:
    .byte 0, 0          ; offsets 0 and 1 (unused)
    .byte %01000000     ; 2: PIRS2
    .byte %01100000     ; 3: PIRS3 (Auto-handshake, if slave-enabled)
    .byte %10000000     ; 4: PIRS4
    .byte %10100000     ; 5: PIRS5
    .byte %11000000     ; 6: PIRS6
    .byte %11100000     ; 7: PIRS7 (Auto-handshake, if slave-enabled)    