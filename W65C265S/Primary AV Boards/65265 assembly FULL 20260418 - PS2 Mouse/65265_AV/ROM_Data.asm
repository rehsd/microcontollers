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


