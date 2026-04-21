

; ********** STRING DATA *******************************
	STR_INIT_COMPLETE:		.byte 13, 10, "Initialization complete!", 13, 10, "rehsd W65C265S @ 10 MHz, VGA, PSGs - AV MCU", 13, 10,"Welcome!", 0
	STR_PRINT_REG_A:		.byte "Reg A current value (8-bit): $", 0
	STR_SERIAL_HELP:		.byte 13, 10, "** rehsd 65265 monitor stub **", 13, 10, "   H: Help", 13, 10, "   M: Modify a byte (future)", 13, 10, "   D: Dump a byte (future)", 13, 10, 0
    STR_CMD_INVALID:        .byte "Invalid command!", 0
    STR_CMD_NOFILES:        .byte "No files found.", 0
    STR_CMD_VER:            .byte "R265Nibbler v0.01", 0
    STR_CMD_HELP:           .byte "Available commands: cls, dir, hello, help, ver, app1", 0

    STR_SPEECH_HELLO:       .byte "Hello, Rich.", 0
    STR_SPEECH_IAM:         .byte "I am R265Nibbler.", 0
    STR_SPEECH_SHALL_WE:    .byte "Shall we play a game?", 0

    
    POST_EXTSRAM:           .byte "Extended SRAM test... ", 0
    POST_DUALPORT_SRAM:     .byte "Dual-port SRAM test...", 0
    POST_SECONDARY_FLASH:   .byte "Secondary Flash test...", 0
    POST_PASS:              .byte "PASS", 0
    POST_FAIL:              .byte "FAIL", 0

	message1:   .byte "Red 0-7 (3 bits)", 0
	message2:   .byte "Green 0-7 (3 bits)", 0
	message3:   .byte "Blue 0-3 (2 bits)", 0
	message4:   .byte "White (mix of bits per column above)", 0
	message5:   .byte "RGB 0-255 (8 bits)", 0
	message6:   .byte "Dynamically-generated Test Pattern", 0
	message7:   .byte "320x240x1B (RRRGGGBB)  -- 5x7 fixed width font", 0

	hexOutLookup: .byte "0123456789ABCDEF"

	;*********** PS/2 keyboard scan codes -- Set 2 or 3 **********
	keymap:
	.byte "????????????? `?"          ; 00-0F
	.byte "?????q1???zsaw2?"          ; 10-1F
	.byte "?cxde43?? vftr5?"          ; 20-2F
	.byte "?nbhgy6???mju78?"          ; 30-3F
	.byte "?,kio09??./l;p-?"          ; 40-4F
	.byte "??'?[=????",$0a,"]?",$5c,"??"    ; 50-5F     orig:"??'?[=????",$0a,"]?\??"   '\' causes issue with retro assembler - swapped out with hex value 5c
	.byte "?????????1?47???"          ; 60-6F0
	.byte "0.2568",$1b,"??+3-*9??"    ; 70-7F
	.byte "????????????????"          ; 80-8F
	.byte "????????????????"          ; 90-9F
	.byte "????????????????"          ; A0-AF
	.byte "????????????????"          ; B0-BF
	.byte "????????????????"          ; C0-CF
	.byte "????????????????"          ; D0-DF
	.byte "????????????????"          ; E0-EF
	.byte "????????????????"          ; F0-FF
	keymap_shifted:
	.byte "????????????? ~?"          ; 00-0F
	.byte "?????Q!???ZSAW@?"          ; 10-1F
	.byte "?CXDE#$?? VFTR%?"          ; 20-2F
	.byte "?NBHGY^???MJU&*?"          ; 30-3F
	.byte "?<KIO)(??>?L:P_?"          ; 40-4F
	.byte "??",$22,"?{+?????}?|??"          ; 50-5F      orig:"??"?{+?????}?|??"  ;nested quote - compiler doesn't like - swapped out with hex value 22
	.byte "?????????1?47???"          ; 60-6F
	.byte "0.2568???+3-*9??"          ; 70-7F
	.byte "????????????????"          ; 80-8F
	.byte "????????????????"          ; 90-9F
	.byte "????????????????"          ; A0-AF
	.byte "????????????????"          ; B0-BF
	.byte "????????????????"          ; C0-CF
	.byte "????????????????"          ; D0-DF
	.byte "????????????????"          ; E0-EF
	.byte "????????????????"          ; F0-FF
    
;Char pixel data
  ; Represent a 5x7 font (35 points/bits of data required)
  ; Store each character graphic as 8 bytes. This will waste 3 bits per byte (last three bits of seven bytes/rows) and one entire empty byte (row 8)
  ;                                          This extra room could be used to add support for font sizes up to 8x8 pixels per character.
  ; The first 5 bits of each byte will represent the pixels for a single row of the character. Last three bits of each row as zeros.
  ; Example - '8':
  ;  ***            = %01110000
  ; *   *           = %10001000
  ; *   *           = %10001000
  ;  ***            = %01110000
  ; *   *           = %10001000
  ; *   *           = %10001000
  ;  ***            = %01110000
  ; -empty-         = %00000000
  ; To reference, start at memory address for .org below.
;.org $010000
charmap:   ;ASCII 0x20 to 0x7F
  ;Each character will consume 8 bytes of data (for the 8 potential rows of pixel data)
  ;char:SPACE ascii:0x20      charmap_location:0x00
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
  ;char:!     ascii:0x21      charmap_location:0x08 (increase by 8 bits/rows per char)
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00000000
      .byte %00100000
      .byte %00000000
  ;char:'"'     ascii:0x22      charmap_location:0x10
      .byte %01010000
      .byte %01010000
      .byte %01010000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
  ;char:'#'     ascii:0x23      charmap_location:0x18
      .byte %01010000
      .byte %01010000
      .byte %11111000
      .byte %01010000
      .byte %11111000
      .byte %01010000
      .byte %01010000
      .byte %00000000
  ;char:$     ascii:0x24      charmap_location:0x20
      .byte %00100000
      .byte %01111000
      .byte %10100000
      .byte %01110000
      .byte %00101000
      .byte %11110000
      .byte %00100000
      .byte %00000000
  ;char:%     ascii:0x25      charmap_location:0x28
      .byte %11000000
      .byte %11001000
      .byte %00010000
      .byte %00100000
      .byte %01000000
      .byte %10011000
      .byte %00011000
      .byte %00000000
  ;char:&     ascii:0x26      charmap_location:0x30
      .byte %01100000
      .byte %10010000
      .byte %10100000
      .byte %01000000
      .byte %10101000
      .byte %10010000
      .byte %01101000
      .byte %00000000
  ;char:''     ascii:0x27      charmap_location:0x38
      .byte %00100000
      .byte %00100000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
  ;char:(     ascii:0x28      charmap_location:0x40
      .byte %00010000
      .byte %00100000
      .byte %01000000
      .byte %01000000
      .byte %01000000
      .byte %00100000
      .byte %00010000
      .byte %00000000
  ;char:)     ascii:0x29      charmap_location:0x48
      .byte %01000000
      .byte %00100000
      .byte %00010000
      .byte %00010000
      .byte %00010000
      .byte %00100000
      .byte %01000000
      .byte %00000000
  ;char:*     ascii:0x2A      charmap_location:0x50
      .byte %00000000
      .byte %00100000
      .byte %10101000
      .byte %01110000
      .byte %10101000
      .byte %00100000
      .byte %00000000
      .byte %00000000
  ;char:+     ascii:0x2B      charmap_location:0x58
      .byte %00000000
      .byte %00100000
      .byte %00100000
      .byte %11111000
      .byte %00100000
      .byte %00100000
      .byte %00000000
      .byte %00000000
  ;char:,     ascii:0x2C      charmap_location:0x60
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00110000
      .byte %00010000
      .byte %00100000
      .byte %00000000
  ;char:-     ascii:0x2D      charmap_location:0x68
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %11111000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
  ;char:.     ascii:0x2E      charmap_location:0x70
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %01100000
      .byte %01100000
      .byte %00000000
  ;char:/     ascii:0x2F      charmap_location:0x78
      .byte %00000000
      .byte %00001000
      .byte %00010000
      .byte %00100000
      .byte %01000000
      .byte %10000000
      .byte %00000000
      .byte %00000000
  ;char:0     ascii:0x30      charmap_location:0x80
      .byte %01110000
      .byte %10001000
      .byte %10011000
      .byte %10101000
      .byte %11001000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:1     ascii:0x31      charmap_location:0x88
      .byte %00100000
      .byte %01100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %01110000
      .byte %00000000
  ;char:2     ascii:0x32      charmap_location:0x90
      .byte %01110000
      .byte %10001000
      .byte %00001000
      .byte %00110000
      .byte %01000000
      .byte %10000000
      .byte %11111000
      .byte %00000000
  ;char:3     ascii:0x33      charmap_location:0x98
      .byte %01110000
      .byte %10001000
      .byte %00001000
      .byte %00110000
      .byte %00001000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:4     ascii:0x34      charmap_location:0xA0
      .byte %00010000
      .byte %00110000
      .byte %01010000
      .byte %10010000
      .byte %11111000
      .byte %00010000
      .byte %00010000
      .byte %00000000
  ;char:5     ascii:0x35      charmap_location:0xA8
      .byte %11111000
      .byte %10000000
      .byte %11110000
      .byte %00001000
      .byte %00001000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:6     ascii:0x36      charmap_location:0xB0
      .byte %00110000
      .byte %01000000
      .byte %10000000
      .byte %11110000
      .byte %10001000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:7     ascii:0x37      charmap_location:0xB8
      .byte %11111000
      .byte %00001000
      .byte %00010000
      .byte %00100000
      .byte %01000000
      .byte %01000000
      .byte %01000000
      .byte %00000000
  ;char:8     ascii:0x38      charmap_location:0xC0
      .byte %01110000
      .byte %10001000
      .byte %10001000
      .byte %01110000
      .byte %10001000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:9     ascii:0x39      charmap_location:0xC8
      .byte %01110000
      .byte %10001000
      .byte %10001000
      .byte %01111000
      .byte %00001000
      .byte %00010000
      .byte %01100000
      .byte %00000000
  ;char:':'     ascii:0x3A      charmap_location:0xD0
      .byte %00000000
      .byte %01100000
      .byte %01100000
      .byte %00000000
      .byte %01100000
      .byte %01100000
      .byte %00000000
      .byte %00000000
  ;char:;     ascii:0x3B      charmap_location:0xD8
      .byte %00000000
      .byte %01100000
      .byte %01100000
      .byte %00000000
      .byte %01100000
      .byte %00100000
      .byte %01000000
      .byte %00000000
  ;char:<     ascii:0x3C      charmap_location:0xE0
      .byte %00010000
      .byte %00100000
      .byte %01000000
      .byte %10000000
      .byte %01000000
      .byte %00100000
      .byte %00010000
      .byte %00000000
  ;char:=     ascii:0x3D      charmap_location:0xE8
      .byte %00000000
      .byte %00000000
      .byte %11111000
      .byte %00000000
      .byte %11111000
      .byte %00000000
      .byte %00000000
      .byte %00000000
  ;char:>     ascii:0x3E      charmap_location:0xF0
      .byte %01000000
      .byte %00100000
      .byte %00010000
      .byte %00001000
      .byte %00010000
      .byte %00100000
      .byte %01000000
      .byte %00000000
  ;char:?     ascii:0x3F      charmap_location:0xF8
      .byte %01110000
      .byte %10001000
      .byte %00001000
      .byte %00010000
      .byte %00100000
      .byte %00000000
      .byte %00100000
      .byte %00000000
  ;char:'@'     ascii:0x40      charmap_location:0x00
      .byte %01110000
      .byte %10001000
      .byte %00001000
      .byte %01101000
      .byte %10101000
      .byte %10101000
      .byte %01110000
      .byte %00000000
  ;char:A     ascii:0x41      charmap_location:0x08
      .byte %00100000
      .byte %01010000
      .byte %10001000
      .byte %10001000
      .byte %11111000
      .byte %10001000
      .byte %10001000
      .byte %00000000
  ;char:B     ascii:0x42      charmap_location:0x10
      .byte %11110000
      .byte %01001000
      .byte %01001000
      .byte %01110000
      .byte %01001000
      .byte %01001000
      .byte %11110000
      .byte %00000000
  ;char:C     ascii:0x43      charmap_location:0x18
      .byte %01110000
      .byte %10001000
      .byte %10000000
      .byte %10000000
      .byte %10000000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:D     ascii:0x44      charmap_location:0x20
      .byte %11110000
      .byte %01001000
      .byte %01001000
      .byte %01001000
      .byte %01001000
      .byte %01001000
      .byte %11110000
      .byte %00000000
  ;char:E     ascii:0x45      charmap_location:0x28
      .byte %11111000
      .byte %10000000
      .byte %10000000
      .byte %11110000
      .byte %10000000
      .byte %10000000
      .byte %11111000
      .byte %00000000
  ;char:F     ascii:0x46      charmap_location:0x30
      .byte %11111000
      .byte %10000000
      .byte %10000000
      .byte %11110000
      .byte %10000000
      .byte %10000000
      .byte %10000000
      .byte %00000000
  ;char:G     ascii:0x47      charmap_location:0x38
      .byte %01110000
      .byte %10001000
      .byte %10000000
      .byte %10011000
      .byte %10001000
      .byte %10001000
      .byte %01111000
      .byte %00000000
  ;char:H     ascii:0x48      charmap_location:0x40
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %11111000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %00000000
  ;char:I     ascii:0x49      charmap_location:0x48
      .byte %01110000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %01110000
      .byte %00000000
  ;char:J     ascii:0x4A      charmap_location:0x50
      .byte %00111000
      .byte %00010000
      .byte %00010000
      .byte %00010000
      .byte %00010000
      .byte %10010000
      .byte %01100000
      .byte %00000000
  ;char:K     ascii:0x4B      charmap_location:0x58
      .byte %10001000
      .byte %10010000
      .byte %10100000
      .byte %11000000
      .byte %10100000
      .byte %10010000
      .byte %10001000
      .byte %00000000
  ;char:L     ascii:0x4C      charmap_location:0x60
      .byte %10000000
      .byte %10000000
      .byte %10000000
      .byte %10000000
      .byte %10000000
      .byte %10000000
      .byte %11111000
      .byte %00000000
  ;char:M     ascii:0x4D      charmap_location:0x68
      .byte %10001000
      .byte %11011000
      .byte %10101000
      .byte %10101000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %00000000
  ;char:N     ascii:0x4E      charmap_location:0x70
      .byte %10001000
      .byte %10001000
      .byte %11001000
      .byte %10101000
      .byte %10011000
      .byte %10001000
      .byte %10001000
      .byte %00000000
  ;char:O     ascii:0x4F      charmap_location:0x78
      .byte %01110000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:P     ascii:0x50      charmap_location:0x80
      .byte %11110000
      .byte %10001000
      .byte %10001000
      .byte %11110000
      .byte %10000000
      .byte %10000000
      .byte %10000000
      .byte %00000000
  ;char:Q     ascii:0x51      charmap_location:0x88
      .byte %01110000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10101000
      .byte %10010000
      .byte %01101000
      .byte %00000000
  ;char:R     ascii:0x52      charmap_location:0x90
      .byte %11110000
      .byte %10001000
      .byte %10001000
      .byte %11110000
      .byte %10100000
      .byte %10010000
      .byte %10001000
      .byte %00000000
  ;char:S     ascii:0x53     charmap_location:0x98
      .byte %01110000
      .byte %10001000
      .byte %10000000
      .byte %01110000
      .byte %00001000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:T     ascii:0x54      charmap_location:0xA0
      .byte %11111000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00000000
  ;char:U     ascii:0x55      charmap_location:0xA8
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:V     ascii:0x56      charmap_location:0xB0
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %01010000
      .byte %00100000
      .byte %00000000
  ;char:W     ascii:0x57      charmap_location:0xB8
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10101000
      .byte %10101000
      .byte %10101000
      .byte %01010000
      .byte %00000000
  ;char:X     ascii:0x58      charmap_location:0xC0
      .byte %10001000
      .byte %10001000
      .byte %01010000
      .byte %00100000
      .byte %01010000
      .byte %10001000
      .byte %10001000
      .byte %00000000
  ;char:Y     ascii:0x59      charmap_location:0xC8
      .byte %10001000
      .byte %10001000
      .byte %01010000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00000000
  ;char:Z     ascii:0x5A      charmap_location:0xD0
      .byte %11111000
      .byte %00001000
      .byte %00010000
      .byte %00100000
      .byte %01000000
      .byte %10000000
      .byte %11111000
      .byte %00000000
  ;char:[     ascii:0x5B      charmap_location:0xD8
      .byte %01110000
      .byte %01000000
      .byte %01000000
      .byte %01000000
      .byte %01000000
      .byte %01000000
      .byte %01110000
      .byte %00000000
  ;char:\     ascii:0x5C      charmap_location:0xE0
      .byte %00000000
      .byte %10000000
      .byte %01000000
      .byte %00100000
      .byte %00010000
      .byte %00001000
      .byte %00000000
      .byte %00000000
  ;char:]     ascii:0x5D      charmap_location:0xE8
      .byte %01110000
      .byte %00010000
      .byte %00010000
      .byte %00010000
      .byte %00010000
      .byte %00010000
      .byte %01110000
      .byte %00000000
  ;char:^     ascii:0x5E      charmap_location:0xF0
      .byte %00100000
      .byte %01010000
      .byte %10001000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
  ;char:_     ascii:0x5F      charmap_location:0xF8
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %11111000
      .byte %00000000
  ;char:`     ascii:0x60      charmap_location:0x00
      .byte %10000000
      .byte %01000000
      .byte %00100000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %00000000
  ;char:a     ascii:0x61      charmap_location:0x08
      .byte %00000000
      .byte %00000000
      .byte %01110000
      .byte %00001000
      .byte %01111000
      .byte %10001000
      .byte %01111000
      .byte %00000000
  ;char:b     ascii:0x62      charmap_location:0x10
      .byte %10000000
      .byte %10000000
      .byte %10110000
      .byte %11001000
      .byte %10001000
      .byte %10001000
      .byte %11110000
      .byte %00000000
  ;char:c     ascii:0x63      charmap_location:0x18
      .byte %00000000
      .byte %00000000
      .byte %01110000
      .byte %10000000
      .byte %10000000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:d     ascii:0x64      charmap_location:0x20
      .byte %00001000
      .byte %00001000
      .byte %01101000
      .byte %10011000
      .byte %10001000
      .byte %10001000
      .byte %01111000
      .byte %00000000
  ;char:e     ascii:0x65      charmap_location:0x28
      .byte %00000000
      .byte %00000000
      .byte %01110000
      .byte %10001000
      .byte %11111000
      .byte %10000000
      .byte %01110000
      .byte %00000000
  ;char:f     ascii:0x66      charmap_location:0x30
      .byte %00110000
      .byte %01001000
      .byte %01000000
      .byte %11100000
      .byte %01000000
      .byte %01000000
      .byte %01000000
      .byte %00000000
  ;char:g     ascii:0x67      charmap_location:0x38
      .byte %00000000
      .byte %00000000
      .byte %01111000
      .byte %10001000
      .byte %01111000
      .byte %00001000
      .byte %01110000
      .byte %00000000
  ;char:h     ascii:0x68      charmap_location:0x40
      .byte %10000000
      .byte %10000000
      .byte %10110000
      .byte %11001000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %00000000
  ;char:i     ascii:0x69      charmap_location:0x48
      .byte %00100000
      .byte %00000000
      .byte %00100000
      .byte %01100000
      .byte %00100000
      .byte %00100000
      .byte %01110000
      .byte %00000000
  ;char:j     ascii:0x6A      charmap_location:0x50
      .byte %00010000
      .byte %00000000
      .byte %00110000
      .byte %00010000
      .byte %00010000
      .byte %10010000
      .byte %01100000
      .byte %00000000
  ;char:k     ascii:0x6B      charmap_location:0x58
      .byte %10000000
      .byte %10000000
      .byte %10010000
      .byte %10100000
      .byte %11000000
      .byte %10100000
      .byte %10010000
      .byte %00000000
  ;char:l     ascii:0x6C      charmap_location:0x60
      .byte %01100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %01110000
      .byte %00000000
  ;char:m     ascii:0x6D      charmap_location:0x68
      .byte %00000000
      .byte %00000000
      .byte %11010000
      .byte %10101000
      .byte %10101000
      .byte %10101000
      .byte %10101000
      .byte %00000000
  ;char:n     ascii:0x6E      charmap_location:0x70
      .byte %00000000
      .byte %00000000
      .byte %10110000
      .byte %11001000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %00000000
  ;char:o     ascii:0x6F      charmap_location:0x78
      .byte %00000000
      .byte %00000000
      .byte %01110000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %01110000
      .byte %00000000
  ;char:p     ascii:0x70      charmap_location:0x80
      .byte %00000000
      .byte %00000000
      .byte %11110000
      .byte %10001000
      .byte %11110000
      .byte %10000000
      .byte %10000000
      .byte %00000000
  ;char:q     ascii:0x71      charmap_location:0x88
      .byte %00000000
      .byte %00000000
      .byte %01101000
      .byte %10011000
      .byte %01111000
      .byte %00001000
      .byte %00001000
      .byte %00000000
  ;char:r     ascii:0x72      charmap_location:0x90
      .byte %00000000
      .byte %00000000
      .byte %10110000
      .byte %11001000
      .byte %10000000
      .byte %10000000
      .byte %10000000
      .byte %00000000
  ;char:s     ascii:0x73     charmap_location:0x98
      .byte %00000000
      .byte %00000000
      .byte %01110000
      .byte %10000000
      .byte %01110000
      .byte %00001000
      .byte %11110000
      .byte %00000000
  ;char:t     ascii:0x74      charmap_location:0xA0
      .byte %01000000
      .byte %01000000
      .byte %11100000
      .byte %01000000
      .byte %01000000
      .byte %01001000
      .byte %00110000
      .byte %00000000
  ;char:u     ascii:0x75      charmap_location:0xA8
      .byte %00000000
      .byte %00000000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10011000
      .byte %01101000
      .byte %00000000
  ;char:v     ascii:0x76      charmap_location:0xB0
      .byte %00000000
      .byte %00000000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %01010000
      .byte %00100000
      .byte %00000000
  ;char:w     ascii:0x77      charmap_location:0xB8
      .byte %00000000
      .byte %00000000
      .byte %10001000
      .byte %10001000
      .byte %10001000
      .byte %10101000
      .byte %01010000
      .byte %00000000
  ;char:x     ascii:0x78      charmap_location:0xC0
      .byte %00000000
      .byte %00000000
      .byte %10001000
      .byte %01010000
      .byte %00100000
      .byte %01010000
      .byte %10001000
      .byte %00000000
  ;char:y     ascii:0x79      charmap_location:0xC8
      .byte %00000000
      .byte %00000000
      .byte %10001000
      .byte %10001000
      .byte %01111000
      .byte %00001000
      .byte %01110000
      .byte %00000000
  ;char:z     ascii:0x7A      charmap_location:0xD0
      .byte %00000000
      .byte %00000000
      .byte %11111000
      .byte %00010000
      .byte %00100000
      .byte %01000000
      .byte %11111000
      .byte %00000000
  ;char:{     ascii:0x7B      charmap_location:0xD8
      .byte %00100000
      .byte %01000000
      .byte %01000000
      .byte %10000000
      .byte %01000000
      .byte %01000000
      .byte %00100000
      .byte %00000000
  ;char:|     ascii:0x7C      charmap_location:0xE0
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00100000
      .byte %00000000
  ;char:}     ascii:0x7D      charmap_location:0xE8
      .byte %00100000
      .byte %00010000
      .byte %00010000
      .byte %00001000
      .byte %00010000
      .byte %00010000
      .byte %00100000
      .byte %00000000
  ;char:~     ascii:0x7E      charmap_location:0xF0
      .byte %00000000
      .byte %00000000
      .byte %00000000
      .byte %01101000
      .byte %10010000
      .byte %00000000
      .byte %00000000
      .byte %00000000


; Super Mario Bros. Overworld Theme - Tempo Corrected
MUSIC_MARIO_THEME:
    
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38

    ; --- Intro (Keep as is since tempo is okay) ---
    .byte $00,$05,$01,$03,$02,$05,$03,$03,$10,$05,$11,$03 
    .byte $08,$0F,$09,$0F,$18,$0B 
    .byte $88             ; wait 8
    .byte $08,$00,$09,$00,$18,$00 
    .byte $82             ; wait 2
    .byte $08,$0F,$09,$0F,$18,$0B 
    .byte $88             ; wait 8
    .byte $08,$00,$09,$00,$18,$00 
    .byte $88             ; wait 8
    .byte $08,$0F,$09,$0F,$18,$0B 
    .byte $88             ; wait 8
    .byte $08,$00,$09,$00,$18,$00 
    .byte $82             ; wait 2
    .byte $00,$D0,$01,$03,$10,$D0,$11,$03 
    .byte $08,$0F,$18,$0B 
    .byte $88             ; wait 8
    .byte $00,$05,$01,$03,$10,$05,$11,$03 
    .byte $08,$0F,$18,$0B 
    .byte $90             ; wait 16
    .byte $00,$8B,$01,$02,$10,$8B,$11,$02 
    .byte $08,$0F,$18,$0B 
    .byte $98             ; wait 24
    .byte $00,$16,$01,$05,$10,$16,$11,$05 
    .byte $08,$0F,$18,$0B 
    .byte $98             ; wait 24

    ; --- Main Theme Section A (Slowed Down 4x) ---
    ; Note: C4
    .byte $00,$D0,$01,$03,$10,$D0,$11,$03 
    .byte $08,$0F,$18,$0B
    .byte $B0             ; wait 48 (Quarter Note)
    
    ; Note: G3
    .byte $00,$16,$01,$05,$10,$16,$11,$05
    .byte $B0             ; wait 48
    
    ; Note: E3
    .byte $00,$46,$01,$06,$10,$46,$11,$06
    .byte $B0             ; wait 48
    
    ; Note: A3
    .byte $00,$EE,$01,$04,$10,$EE,$11,$04
    .byte $A0             ; wait 32
    
    ; Note: B3
    .byte $00,$BE,$01,$04,$10,$BE,$11,$04
    .byte $A0             ; wait 32
    
    ; Note: A#3
    .byte $00,$D5,$01,$04,$10,$D5,$11,$04
    .byte $A0             ; wait 32
    
    ; Note: A3
    .byte $00,$EE,$01,$04,$10,$EE,$11,$04
    .byte $A0             ; wait 32

    ; --- Triplets (Adjusted) ---
    ; G3
    .byte $00,$16,$01,$05,$10,$16,$11,$05
    .byte $98             ; wait 24
    ; E4
    .byte $00,$05,$01,$03,$10,$05,$11,$03
    .byte $98             ; wait 24
    ; G4
    .byte $00,$8B,$01,$02,$10,$8B,$11,$02
    .byte $98             ; wait 24
    ; A4
    .byte $00,$76,$01,$02,$10,$76,$11,$02
    .byte $B0             ; wait 48

    ; F4
    .byte $00,$E9,$01,$02,$10,$E9,$11,$02
    .byte $98             ; wait 24
    ; G4
    .byte $00,$8B,$01,$02,$10,$8B,$11,$02
    .byte $98             ; wait 24
    
    .byte $B0             ; Final long delay

    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 
        
; Legend of Zelda - Overworld Theme (30 Second Extended Data)
; PSG0 = Melody/Harmony, PSG1 = Bass
; Tuned for 60Hz Heartbeat (Timer $A2C2, Prescale Divide-by-4)
MUSIC_ZELDA_THEME:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38

    ; --- INTRO FANFARE ---
    .byte $00, $EE, $01, $01, $02, $EE, $01, $10, $BA, $11, $03 
    .byte $08, $0F, $09, $0F, $18, $0B
    .byte $B0            ; wait 48
    .byte $00, $1D, $01, $03, $02, $1D, $01, $10, $EE, $11, $01 
    .byte $90            ; wait 16
    .byte $00, $EE, $01, $01, $02, $EE, $01
    .byte $8C            ; wait 12
    .byte $00, $EE, $01, $01, $82 ; wait 2
    .byte $00, $62, $01, $02, $82 ; wait 2
    .byte $00, $D3, $01, $02, $82 ; wait 2

    ; --- MAIN THEME (LOOP 1) ---
    .byte $00, $EE, $01, $01, $10, $BA, $11, $03, $08, $0F, $18, $0B
    .byte $B0            ; wait 48
    .byte $00, $1D, $01, $03, $10, $EE, $11, $01 
    .byte $90            ; wait 16
    .byte $00, $EE, $01, $01, $10, $BA, $11, $03
    .byte $88            ; wait 8
    .byte $00, $EE, $01, $01, $01, $D0, $01, $03 
    .byte $84            ; wait 4
    .byte $00, $B4, $01, $01, $01, $9D, $01, $03 
    .byte $84            ; wait 4
    .byte $00, $9D, $01, $03, $10, $75, $11, $02
    .byte $B0            ; wait 48
    .byte $00, $64, $01, $03, $10, $1D, $01, $03
    .byte $90            ; wait 16
    .byte $00, $2D, $01, $03, $10, $D3, $11, $02
    .byte $88            ; wait 8
    .byte $00, $05, $01, $03                  
    .byte $84            ; wait 4
    .byte $00, $CB, $01, $02                  
    .byte $84            ; wait 4
    .byte $00, $CB, $01, $02, $10, $BA, $11, $03
    .byte $B0            ; wait 48

    ; --- MAIN THEME (LOOP 2) ---
    .byte $00, $EE, $01, $01, $10, $BA, $11, $03
    .byte $B0            ; wait 48
    .byte $00, $1D, $01, $03, $10, $EE, $11, $01 
    .byte $90            ; wait 16
    .byte $00, $EE, $01, $01, $10, $BA, $11, $03
    .byte $88            ; wait 8
    .byte $00, $EE, $01, $01, $01, $D0, $01, $03 
    .byte $84            ; wait 4
    .byte $00, $B4, $01, $01, $01, $9D, $01, $03 
    .byte $84            ; wait 4
    .byte $00, $9D, $01, $03, $10, $75, $11, $02
    .byte $B0            ; wait 48
    .byte $00, $64, $01, $03, $10, $1D, $01, $03
    .byte $90            ; wait 16
    .byte $00, $2D, $01, $03, $10, $D3, $11, $02
    .byte $88            ; wait 8
    .byte $00, $05, $01, $03                  
    .byte $84            ; wait 4
    .byte $00, $CB, $01, $02                  
    .byte $84            ; wait 4
    .byte $00, $CB, $01, $02, $10, $BA, $11, $03
    .byte $B0            ; wait 48

    ; --- MAIN THEME (LOOP 3) ---
    .byte $00, $EE, $01, $01, $10, $BA, $11, $03
    .byte $B0            ; wait 48
    .byte $00, $1D, $01, $03, $10, $EE, $11, $01 
    .byte $90            ; wait 16
    .byte $00, $EE, $01, $01, $10, $BA, $11, $03
    .byte $88            ; wait 8
    .byte $00, $EE, $01, $01, $01, $D0, $01, $03 
    .byte $84            ; wait 4
    .byte $00, $B4, $01, $01, $01, $9D, $01, $03 
    .byte $84            ; wait 4
    .byte $00, $9D, $01, $03, $10, $75, $11, $02
    .byte $B0            ; wait 48
    .byte $00, $64, $01, $03, $10, $1D, $01, $03
    .byte $90            ; wait 16
    .byte $00, $2D, $01, $03, $10, $D3, $11, $02
    .byte $88            ; wait 8
    .byte $00, $05, $01, $03                  
    .byte $84            ; wait 4
    .byte $00, $CB, $01, $02                  
    .byte $84            ; wait 4
    .byte $00, $CB, $01, $02, $10, $BA, $11, $03
    .byte $B0            ; wait 48

    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 


; Castlevania: Vampire Killer - 60 Second Full Data
; PSG0: Channels A/B (Lead), Channel C (Harmony)
; PSG1: Channel A/B (Doubled Bass)
MUSIC_VAMPIRE_KILLER:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38

    ; --- INTRO (The Climb) ---
    .byte $08,$0F,$09,$0F,$0A,$0B,$18,$0D,$19,$0D ; Set initial volumes
    .byte $00,$9D,$01,$03, $10,$23,$11,$03         ; Eb4 + E3 Bass
    .byte $84            ; wait 4
    .byte $00,$64,$01,$03, $10,$23,$11,$03         ; F4
    .byte $84            ; wait 4
    .byte $00,$2D,$01,$03, $10,$23,$11,$03         ; Gb4
    .byte $84            ; wait 4
    .byte $00,$05,$01,$03, $10,$23,$11,$03         ; Ab4
    .byte $84            ; wait 4

    ; --- MAIN THEME (LOOP 1) ---
    .byte $00,$CB,$01,$02, $02,$05,$03,$03, $10,$9D,$11,$03 ; Bb4 + E4 + Eb3
    .byte $88            ; wait 8
    .byte $00,$CB,$01,$02, $10,$9D,$11,$03 
    .byte $88            ; wait 8
    .byte $00,$CB,$01,$02, $10,$9D,$11,$03 
    .byte $88            ; wait 8
    .byte $00,$64,$01,$03, $10,$64,$11,$03                   ; F4 + F3
    .byte $84            ; wait 4
    .byte $00,$8B,$01,$02, $10,$8B,$11,$02                   ; G4 + G3
    .byte $84            ; wait 4
    .byte $00,$05,$01,$03, $10,$05,$11,$03                   ; Ab4
    .byte $88            ; wait 8
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$64,$01,$03, $10,$64,$11,$03 
    .byte $84            ; wait 4
    .byte $00,$2D,$01,$03, $10,$2D,$11,$03 
    .byte $84            ; wait 4

    ; --- MAIN THEME (LOOP 2) ---
    .byte $00,$CB,$01,$02, $02,$05,$03,$03, $10,$9D,$11,$03
    .byte $88            ; wait 8
    .byte $00,$CB,$01,$02, $10,$9D,$11,$03 
    .byte $88            ; wait 8
    .byte $00,$CB,$01,$02, $10,$9D,$11,$03 
    .byte $88            ; wait 8
    .byte $00,$64,$01,$03, $10,$64,$11,$03
    .byte $84            ; wait 4
    .byte $00,$8B,$01,$02, $10,$8B,$11,$02
    .byte $84            ; wait 4
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$64,$01,$03, $10,$64,$11,$03 
    .byte $84            ; wait 4
    .byte $00,$2D,$01,$03, $10,$2D,$11,$03 
    .byte $84            ; wait 4

    ; --- ARPEGGIO BRIDGE ---
    .byte $00,$CB,$01,$02, $02,$05,$03,$03, $10,$9D,$11,$03
    .byte $84            ; wait 4
    .byte $00,$05,$01,$03, $02,$CB,$01,$02, $10,$9D,$11,$03
    .byte $84            ; wait 4
    .byte $00,$CB,$01,$02, $02,$05,$03,$03, $10,$9D,$11,$03
    .byte $84            ; wait 4
    .byte $00,$CB,$01,$02, $10,$64,$11,$03 
    .byte $84            ; wait 4

    ; --- MAIN THEME (LOOP 3) ---
    .byte $00,$CB,$01,$02, $02,$05,$03,$03, $10,$9D,$11,$03
    .byte $88            ; wait 8
    .byte $00,$CB,$01,$02, $10,$9D,$11,$03 
    .byte $88            ; wait 8
    .byte $00,$CB,$01,$02, $10,$9D,$11,$03 
    .byte $88            ; wait 8
    .byte $00,$64,$01,$03, $10,$64,$11,$03
    .byte $84            ; wait 4
    .byte $00,$8B,$01,$02, $10,$8B,$11,$02
    .byte $84            ; wait 4
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$64,$01,$03, $10,$64,$11,$03 
    .byte $84            ; wait 4
    .byte $00,$2D,$01,$03, $10,$2D,$11,$03 
    .byte $84            ; wait 4

    ; --- MAIN THEME (LOOP 4) ---
    .byte $00,$CB,$01,$02, $02,$05,$03,$03, $10,$9D,$11,$03
    .byte $88            ; wait 8
    .byte $00,$CB,$01,$02, $10,$9D,$11,$03 
    .byte $88            ; wait 8
    .byte $00,$CB,$01,$02, $10,$9D,$11,$03 
    .byte $88            ; wait 8
    .byte $00,$64,$01,$03, $10,$64,$11,$03
    .byte $84            ; wait 4
    .byte $00,$8B,$01,$02, $10,$8B,$11,$02
    .byte $84            ; wait 4
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$05,$01,$03, $10,$05,$11,$03
    .byte $88            ; wait 8
    .byte $00,$64,$01,$03, $10,$64,$11,$03 
    .byte $84            ; wait 4
    .byte $00,$2D,$01,$03, $10,$2D,$11,$03 
    .byte $84            ; wait 4

    ; --- REPEAT INTRO CLIMB TO END ---
    .byte $00,$9D,$01,$03, $10,$23,$11,$03
    .byte $84            ; wait 4
    .byte $00,$64,$01,$03, $10,$23,$11,$03
    .byte $84            ; wait 4
    .byte $00,$2D,$01,$03, $10,$23,$11,$03
    .byte $84            ; wait 4
    .byte $00,$05,$01,$03, $10,$23,$11,$03
    .byte $84            ; wait 4

    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 



; Tetris (Korobeiniki) - Full 60-Second Data
; PSG0: Channels A/B (Lead/Harmony)
; PSG1: Channel A (Walking Bass)
; Tuned for 60Hz Heartbeat (Timer $A2C2, Prescale Divide-by-4)
MUSIC_TETRIS_THEME:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38

    ; --- SECTION A (Loop 1) ---
    ; E5, B4, C5, D5, C5, B4, A4
    .byte $00,$05,$01,$01, $10,$23,$11,$03, $08,$0F,$18,$0B 
    .byte $90            ; wait 16
    .byte $00,$1E,$01,$02, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$9D,$01,$01, $10,$EE,$11,$01 
    .byte $90            ; wait 16
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$1E,$01,$02, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$76,$01,$02, $10,$75,$11,$02 
    .byte $90            ; wait 16

    ; A4, C5, E5, D5, C5, B4
    .byte $00,$76,$01,$02, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$05,$01,$01, $10,$05,$11,$03 
    .byte $90            ; wait 16
    .byte $00,$9D,$01,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$1E,$01,$02, $10,$1E,$11,$02 
    .byte $90            ; wait 16

    ; --- SECTION B (The "Climb") ---
    ; C5, D5, E5, C5, A4, A4
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01 
    .byte $90            ; wait 16
    .byte $00,$9D,$01,$01, $10,$EE,$11,$01 
    .byte $90            ; wait 16
    .byte $00,$05,$01,$01, $10,$05,$11,$03 
    .byte $90            ; wait 16
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01 
    .byte $90            ; wait 16
    .byte $00,$76,$01,$02, $10,$75,$11,$02 
    .byte $90            ; wait 16
    .byte $00,$76,$01,$02, $10,$75,$11,$02 
    .byte $90            ; wait 16

    ; --- SECTION A (Loop 2 - Harmonized) ---
    .byte $00,$05,$01,$01, $02,$23,$03,$01, $10,$23,$11,$03 
    .byte $90            ; wait 16
    .byte $00,$1E,$01,$02, $02,$D0,$03,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$D0,$01,$01, $02,$EE,$03,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$9D,$01,$01, $02,$D0,$03,$01, $10,$EE,$11,$01 
    .byte $90            ; wait 16
    .byte $00,$D0,$01,$01, $02,$EE,$03,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$1E,$01,$02, $02,$D0,$03,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$76,$01,$02, $02,$76,$03,$02, $10,$75,$11,$02 
    .byte $90            ; wait 16

    ; --- THE "LONG" TAIL (Fills time to 60s) ---
    .byte $00,$05,$01,$01, $10,$05,$11,$03 
    .byte $B0            ; wait 48
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01 
    .byte $B0            ; wait 48
    .byte $00,$05,$01,$01, $10,$05,$11,$03 
    .byte $B0            ; wait 48
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01 
    .byte $B0            ; wait 48
    .byte $00,$76,$01,$02, $10,$75,$11,$02 
    .byte $B0            ; wait 48
    .byte $00,$76,$01,$02, $10,$75,$11,$02 
    .byte $B0            ; wait 48
    
    ; --- REPEAT SECTION A ---
    .byte $00,$05,$01,$01, $10,$23,$11,$03 
    .byte $90            ; wait 16
    .byte $00,$1E,$01,$02, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$9D,$01,$01, $10,$EE,$11,$01 
    .byte $90            ; wait 16
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$1E,$01,$02, $10,$EE,$11,$01 
    .byte $88            ; wait 8
    .byte $00,$76,$01,$02, $10,$75,$11,$02 
    .byte $90            ; wait 16

    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 

        
; Tetris (Korobeiniki) - Massive 9-Block Extended Data
; PSG0: Lead/Harmony | PSG1: Walking Bass
; Heartbeat: 60Hz (Timer $A2C2, Prescale Divide-by-4)
MUSIC_TETRIS_TRIPLE:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38

    ; --- INITIALIZATION ---
    .byte $08,$0F,$09,$0F,$0A,$0B,$18,$0B 

    ; --- [BLOCK 1 & 2] STANDARD THEME ---
    .byte $00,$05,$01,$01, $10,$23,$11,$03, $A0 
    .byte $00,$1E,$01,$02, $10,$EE,$11,$01, $90 
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01, $90 
    .byte $00,$9D,$01,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01, $90 
    .byte $00,$1E,$01,$02, $10,$EE,$11,$01, $90 
    .byte $00,$76,$01,$02, $10,$75,$11,$02, $A0 
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$9D,$01,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$05,$01,$01, $10,$05,$11,$03, $A0 
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$76,$01,$02, $10,$75,$11,$02, $C0 

    ; --- [BLOCK 3 & 4] HARMONIZED VARIATION ---
    .byte $00,$05,$01,$01, $02,$23,$03,$01, $10,$23,$11,$03, $A0 
    .byte $00,$1E,$01,$02, $02,$D0,$03,$01, $10,$EE,$11,$01, $90 
    .byte $00,$D0,$01,$01, $02,$EE,$03,$01, $10,$EE,$11,$01, $90 
    .byte $00,$9D,$01,$01, $02,$D0,$03,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01, $90 
    .byte $00,$1E,$01,$02, $10,$EE,$11,$01, $90 
    .byte $00,$76,$01,$02, $10,$75,$11,$02, $A0 
    .byte $00,$D0,$01,$01, $02,$EE,$03,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$9D,$01,$01, $02,$D0,$03,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$05,$01,$01, $02,$D0,$03,$01, $10,$05,$11,$03, $A0 
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$76,$01,$02, $10,$75,$11,$02, $C0 

    ; --- [BLOCK 5] BASS SOLO (MELODY QUITE) ---
    .byte $08,$04, $09,$04, $18,$0F 
    .byte $10,$23,$11,$03, $A0 
    .byte $10,$EE,$11,$01, $A0 
    .byte $10,$EE,$11,$01, $A0 
    .byte $10,$75,$11,$02, $A0 
    .byte $10,$EE,$11,$01, $A0 
    .byte $10,$1E,$11,$02, $A0 
    .byte $10,$05,$11,$03, $C0 

    ; --- [BLOCK 6 & 7] HIGH OCTAVE REPRISE ---
    .byte $08,$0F, $09,$0F, $18,$0B 
    .byte $00,$82,$01,$00, $10,$23,$11,$03, $A0 ; High E6
    .byte $00,$0F,$01,$01, $10,$EE,$11,$01, $90 ; High B5
    .byte $00,$E8,$01,$00, $10,$EE,$11,$01, $90 ; High C6
    .byte $00,$CE,$01,$00, $10,$EE,$11,$01, $A0 ; High D6
    .byte $00,$E8,$01,$00, $10,$EE,$11,$01, $90 
    .byte $00,$0F,$01,$01, $10,$EE,$11,$01, $90 
    .byte $00,$3B,$01,$01, $10,$75,$11,$02, $A0 
    .byte $00,$E8,$01,$00, $10,$EE,$11,$01, $A0 
    .byte $00,$CE,$01,$00, $10,$EE,$11,$01, $A0 
    .byte $00,$82,$01,$00, $10,$05,$11,$03, $A0 
    .byte $00,$E8,$01,$00, $10,$EE,$11,$01, $A0 
    .byte $00,$3B,$01,$01, $10,$75,$11,$02, $C0 

    ; --- [BLOCK 8 & 9] FINAL REPETITION ---
    .byte $00,$05,$01,$01, $10,$23,$11,$03, $A0 
    .byte $00,$1E,$01,$02, $10,$EE,$11,$01, $90 
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01, $90 
    .byte $00,$9D,$01,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01, $90 
    .byte $00,$1E,$01,$02, $10,$EE,$11,$01, $90 
    .byte $00,$76,$01,$02, $10,$75,$11,$02, $A0 
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$9D,$01,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$05,$01,$01, $10,$05,$11,$03, $A0 
    .byte $00,$D0,$01,$01, $10,$EE,$11,$01, $A0 
    .byte $00,$76,$01,$02, $10,$75,$11,$02, $C0 

    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 


; Mario Jump Sound Effect
; Targets PSG1 (Registers $10-$1D)
SFX_MARIO_JUMP:
    .BYTE $12, $80       ; psg1-b period low
    .BYTE $13, $01       ; psg1-b period high ($0180)
    .BYTE $19, $0F       ; psg1-b volume (max)
    .BYTE $17, $F5       ; mixer: enable psg1-b tone (noise off)
    .BYTE $81            ; wait 1 tick
    .BYTE $12, $60       ; sweep up
    .BYTE $81            ; wait 1 tick
    .BYTE $12, $40       
    .BYTE $81            ; wait 1 tick
    .BYTE $12, $20       
    .BYTE $81            ; wait 1 tick
    .BYTE $12, $10       ; high chirp
    .BYTE $19, $08       ; drop volume
    .BYTE $82            ; wait 2 ticks
    .BYTE $19, $00       ; silence
    .BYTE $17, $FF       ; disable all psg1 channels
    .BYTE $FF            ; end of sfx

SFX_COIN:
    .byte $08,$0F           ; Chan A Max Volume
    .byte $00,$BC,$01,$00   ; Note 1 (B5)
    .byte $85               ; Wait 5 ticks
    .byte $00,$5C,$01,$00   ; Note 2 (E6)
    .byte $95               ; Wait 21 ticks (Sustain)
    .byte $08,$00           ; Silence
    .byte $FF

SFX_FIREBALL:
    .byte $08,$0F           ; Chan A Max Volume
    .byte $00,$20,$01,$01   ; Starting pitch
    .byte $81               ; Wait 1
    .byte $00,$80,$01,$00   
    .byte $81               ; Wait 1
    .byte $00,$40,$01,$00   
    .byte $81               ; Wait 1
    .byte $00,$20,$01,$00   
    .byte $82               ; Wait 2
    .byte $08,$00           ; Silence
    .byte $FF

SFX_EXPLODE:
    .byte $07,$30           ; Enable Noise on Chan A (Binary %00110000)
    .byte $08,$0F           ; Max Volume
    .byte $06,$1F           ; Low rumble noise
    .byte $84               ; Wait 4
    .byte $06,$0F           ; Mid noise
    .byte $84               ; Wait 4
    .byte $06,$05           ; High hiss
    .byte $84               ; Wait 4
    .byte $08,$00           ; Silence
    .byte $07,$38           ; Restore Mixer (Noise Off)
    .byte $FF 

SFX_POWERUP:
    .byte $08,$0F
    .byte $00,$D0,$01,$03   ; C4
    .byte $82
    .byte $00,$05,$01,$03   ; E4
    .byte $82
    .byte $00,$8B,$01,$02   ; G4
    .byte $82
    .byte $00,$D0,$01,$01   ; C5
    .byte $82
    .byte $00,$05,$01,$01   ; E5
    .byte $82
    .byte $00,$8B,$01,$00   ; G5
    .byte $86
    .byte $08,$00
    .byte $FF

MUSIC_HALLOWEEN:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38

  
    ; --- The Loop ---
    .byte $00,$4D,$01,$00  ; PSG0 ChA: C#6
    .byte $10,$20,$11,$01  ; PSG1 ChA: C#4 (Drone)
    .byte $08,$0F,$18,$0A  ; Set Volumes
    .byte $86              ; wait 6
    
    .byte $00,$16,$01,$01  ; PSG0: F#5
    .byte $86              ; wait 6
    
    .byte $00,$16,$01,$01  ; PSG0: F#5
    .byte $86              ; wait 6
    
    .byte $00,$4D,$01,$00  ; PSG0: C#6
    .byte $86              ; wait 6
    
    .byte $00,$16,$01,$01  ; PSG0: F#5
    .byte $86              ; wait 6
    
    .byte $00,$16,$01,$01  ; PSG0: F#5
    .byte $86              ; wait 6
    
    .byte $00,$4D,$01,$00  ; PSG0: C#6
    .byte $86              ; wait 6
    
    .byte $00,$16,$01,$01  ; PSG0: F#5
    .byte $86              ; wait 6
    
    .byte $00,$52,$01,$00  ; PSG0: D6
    .byte $86              ; wait 6
    
    .byte $00,$16,$01,$01  ; PSG0: F#5
    .byte $86              ; wait 6

    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 


MUSIC_STRANGER_THINGS:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38


    
    ; --- Arpeggio ---
    .byte $10,$2D,$11,$0B  ; PSG1: G2 (Deep Bass)
    .byte $18,$0A           ; Bass Volume
    
    .byte $00,$D0,$01,$03  ; PSG0: C4
    .byte $08,$0F           ; Lead Volume
    .byte $88              ; wait 8
    
    .byte $00,$05,$01,$03  ; PSG0: E4
    .byte $88              ; wait 8
    
    .byte $00,$8B,$01,$02  ; PSG0: G4
    .byte $88              ; wait 8
    
    .byte $00,$BE,$01,$04  ; PSG0: B3
    .byte $88              ; wait 8
    
    .byte $00,$D0,$01,$01  ; PSG0: C5
    .byte $88              ; wait 8
    
    .byte $00,$BE,$01,$04  ; PSG0: B3
    .byte $88              ; wait 8
    
    .byte $00,$8B,$01,$02  ; PSG0: G4
    .byte $88              ; wait 8
    
    .byte $00,$05,$01,$03  ; PSG0: E4
    .byte $88              ; wait 8

    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 


MUSIC_DREAM_COLLAPSING:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38


    ; --- MEASURE 1: G Minor Pattern ---
    ; Ticks 1-3
    .byte $00,$8B,$01,$02  ; PSG0 ChA: G4
    .byte $10,$2D,$11,$0B  ; PSG1 ChA: G2
    .byte $14,$5A,$15,$16  ; PSG1 ChC: G1
    .byte $98              ; wait 24 (3 ticks)
    
    ; Tick 4
    .byte $00,$D0,$01,$03  ; PSG0 ChA: D4
    .byte $88              ; wait 8
    
    ; Ticks 5-6
    .byte $00,$8B,$01,$02  ; PSG0 ChA: G4
    .byte $90              ; wait 16 (2 ticks)
    
    ; Tick 7
    .byte $00,$D0,$01,$03  ; PSG0 ChA: D4
    .byte $88              ; wait 8

    ; Ticks 8-9
    .byte $00,$8B,$01,$02  ; PSG0 ChA: G4
    .byte $90              ; wait 16 (2 ticks)

    ; Tick 10
    .byte $00,$D0,$01,$03  ; PSG0 ChA: D4
    .byte $88              ; wait 8

    ; Ticks 11-12
    .byte $00,$8B,$01,$02  ; PSG0 ChA: G4
    .byte $88              ; wait 8
    .byte $00,$D0,$01,$03  ; PSG0 ChA: D4
    .byte $88              ; wait 8

    ; --- MEASURE 2: F# / A# Pattern ---
    ; Tick 1
    .byte $00,$9D,$01,$02  ; PSG0 ChA: F#4
    .byte $10,$67,$11,$09  ; PSG1 ChA: A#2
    .byte $14,$CE,$15,$12  ; PSG1 ChC: A#1
    .byte $88              ; wait 8

    ; Tick 2
    .byte $00,$4D,$01,$05  ; PSG0 ChA: C#4
    .byte $88              ; wait 8

    ; Repeat similar timing for Measure 2...
    .byte $00,$9D,$01,$02  ; F#4
    .byte $90              ; wait 16
    .byte $00,$4D,$01,$05  ; C#4
    .byte $88              ; wait 8
    .byte $00,$9D,$01,$02  ; F#4
    .byte $90              ; wait 16
    .byte $00,$4D,$01,$05  ; C#4
    .byte $88              ; wait 8
    .byte $00,$9D,$01,$02  ; F#4
    .byte $88              ; wait 8
    .byte $00,$4D,$01,$05  ; C#4
    .byte $88              ; wait 8

    ; --- MEASURE 3: G / D# Pattern ---
    .byte $00,$8B,$01,$02  ; PSG0 ChA: G4
    .byte $10,$11,$11,$08  ; PSG1 ChA: D#3
    .byte $14,$22,$15,$10  ; PSG1 ChC: D#2
    .byte $88              ; wait 8
    .byte $00,$67,$01,$04  ; A#3
    .byte $88              ; wait 8
    ; (Continues alternating G4 and A#3 with bass held)
    .byte $00,$8B,$01,$02  ; wait/hold logic applied
    .byte $90
    .byte $00,$67,$01,$04
    .byte $88
    .byte $00,$8B,$01,$02
    .byte $90
    .byte $00,$67,$01,$04
    .byte $88
    .byte $00,$8B,$01,$02
    .byte $88
    .byte $00,$67,$01,$04
    .byte $88

    ; --- MEASURE 4: F# / B Pattern ---
    .byte $00,$9D,$01,$02  ; PSG0 ChA: F#4
    .byte $10,$BE,$11,$08  ; PSG1 ChA: B2
    .byte $14,$7D,$15,$11  ; PSG1 ChC: B1
    .byte $88              ; wait 8
    .byte $00,$7D,$01,$04  ; B3
    .byte $88              ; wait 8
    ; (Continues alternating F#4 and B3 with bass held)
    .byte $00,$9D,$01,$02
    .byte $90
    .byte $00,$7D,$01,$04
    .byte $88
    .byte $00,$9D,$01,$02
    .byte $90
    .byte $00,$7D,$01,$04
    .byte $88
    .byte $00,$9D,$01,$02
    .byte $88
    .byte $00,$7D,$01,$04
    .byte $88

    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 


MUSIC_MONKEY_ISLAND:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38


    .byte $08               ; PSG0 ChA Volume
    .byte $00               ; Off
    .byte $09               ; PSG0 ChB Volume
    .byte $00               ; Off
    .byte $0a               ; PSG0 ChC Volume
    .byte $00               ; Off
    .byte $18               ; PSG1 ChA Volume
    .byte $00               ; Off
    .byte $19               ; PSG1 ChB Volume
    .byte $00               ; Off
    .byte $14               ; PSG1 ChC Fine
    .byte $19
    .byte $15               ; PSG1 ChC Coarse
    .byte $0c
    .byte $1a               ; PSG1 ChC Volume
    .byte $0f               ; Full
    .byte $88               ; Wait
    .byte $14               ; PSG1 ChC Fine
    .byte $19
    .byte $15               ; PSG1 ChC Coarse
    .byte $0c
    .byte $88               ; Wait
    .byte $12               ; PSG1 ChB Fine
    .byte $13
    .byte $13               ; PSG1 ChB Coarse
    .byte $08
    .byte $19               ; PSG1 ChB Volume
    .byte $0f               ; Full
    .byte $1a               ; PSG1 ChC Volume
    .byte $00               ; Off
    .byte $88               ; Wait
    .byte $12               ; PSG1 ChB Fine
    .byte $13
    .byte $13               ; PSG1 ChB Coarse
    .byte $08
    .byte $88               ; Wait
    .byte $10               ; PSG1 ChA Fine
    .byte $0c
    .byte $11               ; PSG1 ChA Coarse
    .byte $06
    .byte $18               ; PSG1 ChA Volume
    .byte $0f               ; Full
    .byte $19               ; PSG1 ChB Volume
    .byte $00               ; Off
    .byte $88               ; Wait
    .byte $10               ; PSG1 ChA Fine
    .byte $0c
    .byte $11               ; PSG1 ChA Coarse
    .byte $06
    .byte $88               ; Wait
    .byte $10               ; PSG1 ChA Fine
    .byte $63
    .byte $11               ; PSG1 ChA Coarse
    .byte $05
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $18               ; PSG1 ChA Volume
    .byte $00               ; Off
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $10               ; PSG1 ChA Fine
    .byte $63
    .byte $11               ; PSG1 ChA Coarse
    .byte $05
    .byte $18               ; PSG1 ChA Volume
    .byte $0f               ; Full
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $10               ; PSG1 ChA Fine
    .byte $63
    .byte $11               ; PSG1 ChA Coarse
    .byte $05
    .byte $88               ; Wait
    .byte $18               ; PSG1 ChA Volume
    .byte $00               ; Off
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $88               ; Wait
    .byte $00               ; PSG0 ChA Fine
    .byte $c2
    .byte $01               ; PSG0 ChA Coarse
    .byte $00
    .byte $08               ; PSG0 ChA Volume
    .byte $0f               ; Full
    .byte $02               ; PSG0 ChB Fine
    .byte $83
    .byte $03               ; PSG0 ChB Coarse
    .byte $01
    .byte $09               ; PSG0 ChB Volume
    .byte $0f               ; Full
    .byte $88               ; Wait
    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 


MUSIC_STAR_TREK:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38

    .byte $00               ; PSG0 ChA Fine
    .byte $b3
    .byte $01               ; PSG0 ChA Coarse
    .byte $01
    .byte $08               ; PSG0 ChA Volume
    .byte $0f
    .byte $02               ; PSG0 ChB Fine
    .byte $44
    .byte $03               ; PSG0 ChB Coarse
    .byte $02
    .byte $09               ; PSG0 ChB Volume
    .byte $0f
    .byte $04               ; PSG0 ChC Fine
    .byte $65
    .byte $05               ; PSG0 ChC Coarse
    .byte $03
    .byte $0a               ; PSG0 ChC Volume
    .byte $0f
    .byte $10               ; PSG1 ChA Fine
    .byte $b6
    .byte $11               ; PSG1 ChA Coarse
    .byte $05
    .byte $18               ; PSG1 ChA Volume
    .byte $0f
    .byte $12               ; PSG1 ChB Fine
    .byte $10
    .byte $13               ; PSG1 ChB Coarse
    .byte $09
    .byte $19               ; PSG1 ChB Volume
    .byte $0f
    .byte $14               ; PSG1 ChC Fine
    .byte $94
    .byte $15               ; PSG1 ChC Coarse
    .byte $0d
    .byte $1a               ; PSG1 ChC Volume
    .byte $0f
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $00               ; PSG0 ChA Fine update
    .byte $b3
    .byte $01
    .byte $01
    .byte $02               ; PSG0 ChB Fine update
    .byte $44
    .byte $03
    .byte $02
    .byte $04               ; PSG0 ChC Fine update
    .byte $65
    .byte $05
    .byte $03
    .byte $88               ; wait
    .byte $00
    .byte $83
    .byte $01
    .byte $01
    .byte $02
    .byte $06
    .byte $03
    .byte $03
    .byte $0a               ; Volume Off
    .byte $00
    .byte $88               ; wait
    .byte $00
    .byte $83
    .byte $01
    .byte $01
    .byte $02
    .byte $06
    .byte $03
    .byte $03
    .byte $88               ; wait
    .byte $08               ; Multiple Volumes Off
    .byte $00
    .byte $09
    .byte $00
    .byte $18
    .byte $00
    .byte $19
    .byte $00
    .byte $1a
    .byte $00
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $88               ; wait
    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 


MUSIC_ZELDA:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38

    .byte $00               ; PSG0 ChA Fine
    .byte $44
    .byte $01               ; PSG0 ChA Coarse
    .byte $02
    .byte $08               ; PSG0 ChA Volume
    .byte $0f               ; On
    .byte $09               ; PSG0 ChB Volume
    .byte $00               ; Off
    .byte $0a               ; PSG0 ChC Volume
    .byte $00               ; Off
    .byte $18               ; PSG1 ChA Volume
    .byte $00               ; Off
    .byte $12               ; PSG1 ChB Fine
    .byte $88
    .byte $13               ; PSG1 ChB Coarse
    .byte $04
    .byte $19               ; PSG1 ChB Volume
    .byte $0f               ; On
    .byte $14               ; PSG1 ChC Fine
    .byte $0c
    .byte $15               ; PSG1 ChC Coarse
    .byte $06
    .byte $1a               ; PSG1 ChC Volume
    .byte $0f               ; On
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $12               ; Update Pitch PSG1 ChB
    .byte $88
    .byte $13
    .byte $04
    .byte $14               ; Update Pitch PSG1 ChC
    .byte $0c
    .byte $15
    .byte $06
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $00               ; Update Pitch PSG0 ChA
    .byte $44
    .byte $01
    .byte $02
    .byte $12               ; Update Pitch PSG1 ChB
    .byte $88
    .byte $13
    .byte $04
    .byte $14               ; Update Pitch PSG1 ChC
    .byte $0c
    .byte $15
    .byte $06
    .byte $88               ; wait
    .byte $08               ; Kill Volumes
    .byte $00
    .byte $19
    .byte $00
    .byte $1a
    .byte $00
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $88               ; wait
    .byte $88               ; wait
    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 


MUSIC_DRAGONBORN:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38

    .byte $00,$b3           ; Ch1 Period Fine
    .byte $01,$01           ; Ch1 Period Coarse
    .byte $08,$0f           ; Ch1 Volume
    .byte $02,$65           ; Ch2 Period Fine
    .byte $03,$03           ; Ch2 Period Coarse
    .byte $09,$0f           ; Ch2 Volume
    .byte $0a,$00           ; Ch3 Volume 0
    .byte $18,$00           ; Ch4 Volume 0
    .byte $19,$00           ; Ch5 Volume 0
    .byte $1a,$00           ; Ch6 Volume 0
    .byte $88               ; wait 8
    .byte $00,$cc           ; Ch1 Period Fine
    .byte $01,$01           ; Ch1 Period Coarse
    .byte $02,$99           ; Ch2 Period Fine
    .byte $03,$03           ; Ch2 Period Coarse
    .byte $88               ; wait 8
    .byte $08,$00           ; Ch1 Vol 0
    .byte $09,$00           ; Ch2 Vol 0
    .byte $88               ; wait 8
    .byte $88               ; wait 8
    .byte $88               ; wait 8
    .byte $88               ; wait 8
    .byte $88               ; wait 8
    .byte $88               ; wait 8
    .byte $88               ; wait 8
    .byte $88               ; wait 8
    .byte $88               ; wait 8
    .byte $88               ; wait 8
    .byte $00,$b3           ; Ch1 Period Fine
    .byte $01,$01           ; Ch1 Period Coarse
    .byte $08,$0f           ; Ch1 Volume
    .byte $02,$65           ; Ch2 Period Fine
    .byte $03,$03           ; Ch2 Period Coarse
    .byte $09,$0f           ; Ch2 Volume
    .byte $04,$09           ; Ch3 Period Fine
    .byte $05,$04           ; Ch3 Period Coarse
    .byte $0a,$0f           ; Ch3 Volume
    .byte $10,$63           ; Ch4 Period Fine
    .byte $11,$05           ; Ch4 Period Coarse
    .byte $18,$0f           ; Ch4 Volume
    .byte $12,$ca           ; Ch5 Period Fine
    .byte $13,$06           ; Ch5 Period Coarse
    .byte $19,$0f           ; Ch5 Volume
    .byte $14,$13           ; Ch6 Period Fine
    .byte $15,$08           ; Ch6 Period Coarse
    .byte $1a,$0f           ; Ch6 Volume
    .byte $88               ; wait 8
    .byte $00,$b3           ; Ch1 update
    .byte $01,$01
    .byte $02,$65
    .byte $03,$03
    .byte $04,$09
    .byte $05,$04
    .byte $10,$63
    .byte $11,$05
    .byte $12,$ca
    .byte $13,$06
    .byte $14,$13
    .byte $15,$08
    .byte $88               ; wait 8
    .byte $0a,$00           ; Ch3 off
    .byte $18,$00           ; Ch4 off
    .byte $12,$13           ; Ch5 shift
    .byte $13,$08
    .byte $14,$26           ; Ch6 shift
    .byte $15,$00
    .byte $88               ; wait 8
    .byte $00,$b3           ; Ch1 update
    .byte $01,$01
    .byte $02,$65
    .byte $03,$03
    .byte $88               ; wait 8
    .byte $00,$b3
    .byte $01,$01
    .byte $02,$65
    .byte $03,$03
    .byte $88               ; wait 8
    .byte $00,$cc
    .byte $01,$01
    .byte $02,$06
    .byte $03,$03
    .byte $12,$13
    .byte $13,$08
    .byte $14,$26
    .byte $15,$00
    .byte $88               ; wait 8
    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 


MUSIC_MARIO_REMIX:
    ; --- PSG0 Initialization ---
    .byte $07, $38           ; Register 7 = %00111000 (Tones A,B,C ON; Noise OFF)
    ; --- PSG1 Initialization ---
    .byte $17, $38           ; Register 17 (PSG1 Reg 7) = $38

    .byte $07,$38
    .byte $17,$38
    .byte $27,$38
    .byte $37,$38
    .byte $00,$83
    .byte $01,$01
    .byte $08,$0F
    .byte $02,$00
    .byte $03,$00
    .byte $09,$0F
    .byte $04,$00
    .byte $05,$00
    .byte $0A,$0F
    .byte $10,$00
    .byte $11,$00
    .byte $18,$0F
    .byte $12,$00
    .byte $13,$00
    .byte $19,$0F
    .byte $14,$00
    .byte $15,$00
    .byte $1A,$0F
    .byte $20,$00
    .byte $21,$00
    .byte $28,$0F
    .byte $22,$00
    .byte $23,$00
    .byte $29,$0F
    .byte $24,$00
    .byte $25,$00
    .byte $2A,$0F
    .byte $30,$00
    .byte $31,$00
    .byte $38,$0F
    .byte $32,$00
    .byte $33,$00
    .byte $39,$0F
    .byte $34,$00
    .byte $35,$00
    .byte $3A,$0F
    .byte $88
    .byte $02,$00
    .byte $03,$00
    .byte $09,$0F
    .byte $04,$00
    .byte $05,$00
    .byte $0A,$0F
    .byte $10,$00
    .byte $11,$00
    .byte $18,$0F
    .byte $12,$00
    .byte $13,$00
    .byte $19,$0F
    .byte $14,$00
    .byte $15,$00
    .byte $1A,$0F
    .byte $20,$00
    .byte $21,$00
    .byte $28,$0F
    .byte $22,$00
    .byte $23,$00
    .byte $29,$0F
    .byte $24,$00
    .byte $25,$00
    .byte $2A,$0F
    .byte $30,$00
    .byte $31,$00
    .byte $38,$0F
    .byte $32,$00
    .byte $33,$00
    .byte $39,$0F
    .byte $34,$00
    .byte $35,$00
    .byte $3A,$0F
    .byte $88
    .byte $00,$83
    .byte $01,$01
    .byte $08,$0F
    .byte $02,$00
    .byte $03,$00
    .byte $09,$0F
    .byte $04,$00
    .byte $05,$00
    .byte $0A,$0F
    .byte $10,$00
    .byte $11,$00
    .byte $18,$0F
    .byte $12,$00
    .byte $13,$00
    .byte $19,$0F
    .byte $14,$00
    .byte $15,$00
    .byte $1A,$0F
    .byte $20,$00
    .byte $21,$00
    .byte $28,$0F
    .byte $22,$00
    .byte $23,$00
    ; end --> silence
    .byte $08,$00,$09,$00,$0A,$00,$18,$00,$19,$00,$1A,$00
    .byte $FF,$FF 
             

SFX_MARIO_JUMP_2:
    .byte $02, $80       ; PSG1 Channel B Fine
    .byte $03, $01       ; PSG1 Channel B Coarse
    .byte $09, $0F       ; PSG1 Channel B Volume
    .byte $07, $FD       ; Mixer: Enable B Tone only (%11111101)
    .byte $81            
    .byte $02, $60       ; Sweep
    .byte $81
    ; ... (rest of sweep)
    .byte $09, $00       ; Silence Channel B
    .byte $07, $FF       ; Disable all PSG1
    .byte $FF

SFX_COIN_2:
    .byte $0A, $0F       ; Channel C Max Volume
    .byte $07, $FB       ; Mixer: Enable C Tone only (%11111011)
    .byte $04, $BC       ; Note 1 Fine
    .byte $05, $01       ; Note 1 Coarse
    .byte $85
    .byte $04, $5C       ; Note 2 Fine
    .byte $05, $01       ; Note 2 Coarse
    .byte $95
    .byte $0A, $00       ; Silence C
    .byte $07, $FF       ; Disable all
    .byte $FF

SFX_FIREBALL_2:
    .byte $07,$FD           ; Mixer: Enable Tone B (%11111101)
    .byte $09,$0F           ; Chan B Max Volume
    .byte $02,$20           ; Pitch Fine
    .byte $03,$01           ; Pitch Coarse
    .byte $81               ; wait 1
    .byte $02,$80
    .byte $03,$00           
    .byte $81               ; wait 1
    .byte $02,$40
    .byte $03,$00           
    .byte $81               ; wait 1
    .byte $02,$20
    .byte $03,$00           
    .byte $82               ; wait 2
    .byte $09,$00           ; Silence B
    .byte $07,$FF           ; Mixer: All Off
    .byte $FF

SFX_EXPLODE_2:
    .byte $07,$D7           ; Enable Noise on Chan B (%11010111)
    .byte $09,$0F           ; Chan B Max Volume
    .byte $06,$1F           ; Low rumble noise
    .byte $84               ; wait 4
    .byte $06,$0F           ; Mid noise
    .byte $84               ; wait 4
    .byte $06,$05           ; High hiss
    .byte $84               ; wait 4
    .byte $09,$00           ; Silence B
    .byte $07,$FF           ; Restore Mixer (All Off)
    .byte $FF 

SFX_POWERUP_2:
    .byte $07,$FB           ; Mixer: Enable Tone C (%11111011)
    .byte $0A,$0F           ; Chan C Max Volume
    .byte $04,$D0           ; C4 Fine
    .byte $05,$03           ; C4 Coarse
    .byte $82               ; wait 2
    .byte $04,$05           ; E4
    .byte $05,$03
    .byte $82               ; wait 2
    .byte $04,$8B           ; G4
    .byte $05,$02
    .byte $82               ; wait 2
    .byte $04,$D0           ; C5
    .byte $05,$01
    .byte $82               ; wait 2
    .byte $04,$05           ; E5
    .byte $05,$01
    .byte $82               ; wait 2
    .byte $04,$8B           ; G5
    .byte $05,$00
    .byte $86               ; wait 6
    .byte $0A,$00           ; Silence C
    .byte $07,$FF           ; Mixer: All Off
    .byte $FF

