
; ************************************************************************************************************
; ******************************* VGA ************************************************************************
; ************************************************************************************************************
; Video RAM is at $EA0000 to $EBFFFF
; Each row is #512 of VRAM, but only first #320 are used for VGA output (remainder 192 bytes per rowavailable for other uses)
; 256 rows of VRAM, only 240 are used for VGA output (remainder 16 rows available for othre uses)
;
;
.setting "RegA16", true
.setting "RegXY16", true

STR_POST_POWER_ON:	.byte " -rehsd- Dual W65C265S 10 MHz R265Nibbler AVOS 0.04", 0

Init_VGA:
	pha

	lda #$0000  ;done processing pre-defined strings
	sta message_to_process

  stz Str_ptr
  stz Str_ptr+2

	; Set location for new chars from keyboard
	lda #0
	sta char_x_offset
	lda #0
	sta char_vp_x    ;0 to 319
	lda #0
	sta char_vp_y    ;0 to 239
	jsr gfx_SetCharVpByXY

	lda #$FF
	sta char_color

  jsr gfx_ClearScreen

	
	pla
	rts

gfx_ClearScreen:
	; caller guarantees A/X are 16-bit on entry

	pha
	phx
	phy

	lda #$00EA
	sta vidpageVRAM+2
	sta char_vp+2
	lda #$0000
	sta vidpageVRAM
	sta char_vp



	ldy #0				; offset from beginning of VRAM

	lda #0
	sta fill_region_start_x
	lda #0
	sta fill_region_start_y
	lda #319
	sta fill_region_end_x
	;lda #239
	lda #247  ; leaving some extra rows at the bottom for processing before we need to scroll (since we can write to VRAM beyond what is displayed)
	sta fill_region_end_y
	lda #%00000000
	sta fill_region_color
	jsr gfx_FillRegionVRAM

	; Set location for new chars from keyboard
	lda #0
	sta char_x_offset
	lda #0
	sta char_vp_x    ;0 to 319
	lda #0
	sta char_vp_y    ;0 to 239
	jsr gfx_SetCharVpByXY

	lda #$00  ;done processing pre-defined strings
  	sta message_to_process
	
	ply
	plx
	pla
	rts
	
gfx_TestPattern:
	; caller guarantees A/X are 16-bit on entry
	pha
	phx
	phy


    ;set vidpage back to start
    lda #$00EA
    sta vidpageVRAM+2
    lda #$0000
    sta vidpageVRAM

	ldy #0				; offset from beginning of VRAM
	lda #%11111111		; color

  	;draw screen frame
    ;top bar
    lda #0
    sta fill_region_start_x
    lda #0
    sta fill_region_start_y
    lda #319
    sta fill_region_end_x
    lda #2
    sta fill_region_end_y
    lda #%11111111
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    ;bottom bar
    lda #0
    sta fill_region_start_x
    lda #237
    sta fill_region_start_y
    lda #319
    sta fill_region_end_x
    lda #239
    sta fill_region_end_y
    jsr gfx_FillRegionVRAM

    ;left bar
    lda #0
    sta fill_region_start_x
    lda #3
    sta fill_region_start_y
    lda #2
    sta fill_region_end_x
    lda #236
    sta fill_region_end_y
    jsr gfx_FillRegionVRAM

    ;right bar
    lda #317
    sta fill_region_start_x
    lda #3
    sta fill_region_start_y
    lda #319
    sta fill_region_end_x
    lda #236
    sta fill_region_end_y
    jsr gfx_FillRegionVRAM

  	;draw red gradient
    lda #40
    sta fill_region_start_x
    lda #30
    sta fill_region_start_y
    lda #69
    sta fill_region_end_x
    lda #49
    sta fill_region_end_y
    lda #%00000000
    sta fill_region_color
    jsr gfx_FillRegionVRAM
    
    lda #70
    sta fill_region_start_x
    lda #30
    sta fill_region_start_y
    lda #99
    sta fill_region_end_x
    lda #49
    sta fill_region_end_y
    lda #%00100000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #100
    sta fill_region_start_x
    lda #30
    sta fill_region_start_y
    lda #129
    sta fill_region_end_x
    lda #49
    sta fill_region_end_y
    lda #%01000000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #130
    sta fill_region_start_x
    lda #30
    sta fill_region_start_y
    lda #159
    sta fill_region_end_x
    lda #49
    sta fill_region_end_y
    lda #%01100000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #160
    sta fill_region_start_x
    lda #30
    sta fill_region_start_y
    lda #189
    sta fill_region_end_x
    lda #49
    sta fill_region_end_y
    lda #%10000000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #190
    sta fill_region_start_x
    lda #30
    sta fill_region_start_y
    lda #219
    sta fill_region_end_x
    lda #49
    sta fill_region_end_y
    lda #%10100000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #220
    sta fill_region_start_x
    lda #30
    sta fill_region_start_y
    lda #249
    sta fill_region_end_x
    lda #49
    sta fill_region_end_y
    lda #%11000000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #250
    sta fill_region_start_x
    lda #30
    sta fill_region_start_y
    lda #279
    sta fill_region_end_x
    lda #49
    sta fill_region_end_y
    lda #%11100000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

  	;draw green gradient
    lda #40
    sta fill_region_start_x
    lda #60
    sta fill_region_start_y
    lda #69
    sta fill_region_end_x
    lda #79
    sta fill_region_end_y
    lda #%00000000
    sta fill_region_color
    jsr gfx_FillRegionVRAM
    
    lda #70
    sta fill_region_start_x
    lda #60
    sta fill_region_start_y
    lda #99
    sta fill_region_end_x
    lda #79
    sta fill_region_end_y
    lda #%00000100
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #100
    sta fill_region_start_x
    lda #60
    sta fill_region_start_y
    lda #129
    sta fill_region_end_x
    lda #79
    sta fill_region_end_y
    lda #%00001000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #130
    sta fill_region_start_x
    lda #60
    sta fill_region_start_y
    lda #159
    sta fill_region_end_x
    lda #79
    sta fill_region_end_y
    lda #%00001100
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #160
    sta fill_region_start_x
    lda #60
    sta fill_region_start_y
    lda #189
    sta fill_region_end_x
    lda #79
    sta fill_region_end_y
    lda #%00010000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #190
    sta fill_region_start_x
    lda #60
    sta fill_region_start_y
    lda #219
    sta fill_region_end_x
    lda #79
    sta fill_region_end_y
    lda #%00010100
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #220
    sta fill_region_start_x
    lda #60
    sta fill_region_start_y
    lda #249
    sta fill_region_end_x
    lda #79
    sta fill_region_end_y
    lda #%00011000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #250
    sta fill_region_start_x
    lda #60
    sta fill_region_start_y
    lda #279
    sta fill_region_end_x
    lda #79
    sta fill_region_end_y
    lda #%00011100
    sta fill_region_color
    jsr gfx_FillRegionVRAM

  	;draw blue gradient
    lda #40
    sta fill_region_start_x
    lda #90
    sta fill_region_start_y
    lda #99
    sta fill_region_end_x
    lda #109
    sta fill_region_end_y
    lda #%00000000
    sta fill_region_color
    jsr gfx_FillRegionVRAM
    
    lda #100
    sta fill_region_start_x
    lda #90
    sta fill_region_start_y
    lda #159
    sta fill_region_end_x
    lda #109
    sta fill_region_end_y
    lda #%00000001
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #160
    sta fill_region_start_x
    lda #90
    sta fill_region_start_y
    lda #219
    sta fill_region_end_x
    lda #109
    sta fill_region_end_y
    lda #%00000010
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #220
    sta fill_region_start_x
    lda #90
    sta fill_region_start_y
    lda #279
    sta fill_region_end_x
    lda #109
    sta fill_region_end_y
    lda #%00000011
    sta fill_region_color
    jsr gfx_FillRegionVRAM

  	;draw white gradient
    lda #40
    sta fill_region_start_x
    lda #120
    sta fill_region_start_y
    lda #69
    sta fill_region_end_x
    lda #139
    sta fill_region_end_y
    lda #%00000000
    sta fill_region_color
    jsr gfx_FillRegionVRAM
    
    lda #70
    sta fill_region_start_x
    lda #120
    sta fill_region_start_y
    lda #99
    sta fill_region_end_x
    lda #139
    sta fill_region_end_y
    lda #%00100100
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #100
    sta fill_region_start_x
    lda #120
    sta fill_region_start_y
    lda #129
    sta fill_region_end_x
    lda #139
    sta fill_region_end_y
    lda #%01001001
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #130
    sta fill_region_start_x
    lda #120
    sta fill_region_start_y
    lda #159
    sta fill_region_end_x
    lda #139
    sta fill_region_end_y
    lda #%01101101
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #160
    sta fill_region_start_x
    lda #120
    sta fill_region_start_y
    lda #189
    sta fill_region_end_x
    lda #139
    sta fill_region_end_y
    lda #%10010010
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #190
    sta fill_region_start_x
    lda #120
    sta fill_region_start_y
    lda #219
    sta fill_region_end_x
    lda #139
    sta fill_region_end_y
    lda #%10110110
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #220
    sta fill_region_start_x
    lda #120
    sta fill_region_start_y
    lda #249
    sta fill_region_end_x
    lda #139
    sta fill_region_end_y
    lda #%11011011
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #250
    sta fill_region_start_x
    lda #120
    sta fill_region_start_y
    lda #279
    sta fill_region_end_x
    lda #139
    sta fill_region_end_y
    lda #%11111111
    sta fill_region_color
    jsr gfx_FillRegionVRAM

  	;draw color gradient
    ldx #0  ;color
    ldy #32  ;x pos
    colorGradientLoop:
    tya
    sta fill_region_start_x
    sta fill_region_end_x
    lda #150
    sta fill_region_start_y
    lda #169
    sta fill_region_end_y
    txa
    sta fill_region_color
    jsr gfx_FillRegionVRAM
    inx
    iny
    txa
    cmp #256  ;finished with all color options (0-255)
    bne colorGradientLoop    
    
  	;draw corner marks
    ;upper left
    lda #35
    sta fill_region_start_x
    lda #25
    sta fill_region_start_y
    lda #35
    sta fill_region_end_x
    lda #29
    sta fill_region_end_y
    lda #%11111111
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #30
    sta fill_region_start_x
    lda #30
    sta fill_region_start_y
    lda #34
    sta fill_region_end_x
    lda #30
    sta fill_region_end_y
    jsr gfx_FillRegionVRAM

    ;upper right
    lda #279
    sta fill_region_start_x
    lda #25
    sta fill_region_start_y
    lda #279
    sta fill_region_end_x
    lda #29
    sta fill_region_end_y
    lda #%11111111
    sta fill_region_color
    jsr gfx_FillRegionVRAM

    lda #280
    sta fill_region_start_x
    lda #30
    sta fill_region_start_y
    lda #284
    sta fill_region_end_x
    lda #30
    sta fill_region_end_y
    jsr gfx_FillRegionVRAM
  
  	;add labels
    lda #$00
    sta char_x_offset
    
    lda #%11111111
    sta char_color

    lda #58
    sta char_vp_x    ;0 to 319
    lda #10
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #06
    sta message_to_process
    jsr PrintString

    lda #$00
    sta char_x_offset
    lda #120
    sta char_vp_x    ;0 to 319
    lda #51
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #01
    sta message_to_process
    jsr PrintString

    lda #$00
    sta char_x_offset
    lda #120
    sta char_vp_x    ;0 to 319
    lda #81
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #02
    sta message_to_process
    jsr PrintString

    lda #$00
    sta char_x_offset
    lda #120
    sta char_vp_x    ;0 to 319
    lda #111
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #03
    sta message_to_process
    jsr PrintString
    
    lda #$00
    sta char_x_offset
    lda #60
    sta char_vp_x    ;0 to 319
    lda #141
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #04
    sta message_to_process
    jsr PrintString

    lda #$00
    sta char_x_offset
    lda #120
    sta char_vp_x    ;0 to 319
    lda #171
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #05
    sta message_to_process
    jsr PrintString

    lda #$00
    sta char_x_offset
    lda #20
    sta char_vp_x    ;0 to 319
    lda #220
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #07
    sta message_to_process
    jsr PrintString

	lda #$00  ;done processing pre-defined strings
  	sta message_to_process

  	gfxTestDone:

		ply
		plx
		pla
		rts

gfx_FillRegionVRAM:
  ;inputs: fill_region_start_x, fill_region_start_y, fill_region_end_x, fill_region_end_y, fill_region_color
  pha ;a to stack
  phx ;x to stack
  phy ;y to stack
  
  gfx_FillRegionVRAMLoopStart:
    ;start location
    lda fill_region_start_y
    sta jump_to_line_y

    jsr gfx_JumpToLineVRAM

    ldx fill_region_end_x
    inx
    ;stx $53 ; column# end comparison
    stx col_end ; column# end comparison
    
    lda fill_region_end_y
    sec
    sbc fill_region_start_y
    sta rows_remain ; rows remaining
    inc rows_remain ; add one to get count of rows to process

    gfx_FillRegionVRAMLoopYloop:
        ldy fill_region_start_x     ;horizontal pixel location, 0 to 319
        lda fill_region_color
            
        gfx_FillRegionVRAMLoopXloop:
            jsr WriteVidPageVRAM
            iny
            cpy col_end
            beq gfx_FRVLX_done    ;done with this row
            jmp gfx_FillRegionVRAMLoopXloop
        gfx_FRVLX_done:
            ;move on to next row
            dec rows_remain
            beq gfx_FRVLY_done
            lda vidpageVRAM
            clc
            adc #512
            sta vidpageVRAM    
            lda vidpageVRAM+2   ;do not clc... need the carry bit to roll to the second (high) byte
            adc #$00          ;add carry
            sta vidpageVRAM+2                  
            jmp gfx_FillRegionVRAMLoopYloop
        gfx_FRVLY_done:
        
    ;put things back and return to sender

    ply ;stack to y
    plx ;stack to x
    pla ;stack to a
    rts

WriteVidPageVRAM:
  php                     ; Save current A/X/Y sizes and flags
  sep #$20                ; Force 8-bit A for the VRAM write
  .setting "RegA16", false
  
  sta [vidpageVRAM],y     ; Write color to VRAM
  
  plp                     ; Restore original A/X/Y sizes and flags
  rts

gfx_JumpToLineVRAM:
  .setting "RegA16", true
  pha
  phx
  phy

  ; 1. Reset base to $EA:0000
  lda #$00EA
  sta vidpageVRAM+2
  lda #$0000
  sta vidpageVRAM

  lda jump_to_line_y
  and #$00FF              ; Ensure we only have the Y coordinate
  beq @JumpToLineVRAMDone

  ; 2. Limit check
  cmp #$00EF              ; 239
  bpl @setToZero

  ; 3. Direct Math: Y * 512
  ; In binary, Y * 512 is just (Y << 9)
  ; Which is the same as (Y << 8) then (Y << 1)
  
  xba                     ; Swap bytes: $00YY becomes $YY00 (This is Y * 256)
  and #$FF00              ; Clear the low byte
  asl a                   ; Shift left one more: $YY00 * 2 = Y * 512
  
  ; 4. Handle Bank Crossing
  ; If Y was >= 128, (Y * 512) will exceed $FFFF and Carry will be set
  bcc @store
  inc vidpageVRAM+2       ; Roll over to Bank $EB

  @store:
    sta vidpageVRAM

    bra @JumpToLineVRAMDone

  @setToZero:
      stz jump_to_line_y
      ; Result remains $EA:0000

  @JumpToLineVRAMDone:
      ply
      plx
      pla
      rts

gfx_NextVGALineVRAM:
  pha
  ;move the location for writing to the screen down one line
  clc
  lda vidpageVRAM
  adc #512         ;add 512 to move to next row
  sta vidpageVRAM    
  lda vidpageVRAM+2   ;do not clc... need the carry bit to roll to the second (high) byte
  adc #$00          ;add carry
  sta vidpageVRAM+2
  pla
  rts

gfx_SetCharVpByXY:
	;TO DO safety code (keep in bounds)
	pha
	phx
	phy
	;convert x,y position to char_vp and char_vp+2
	;char_vp_x    0 to 319
	;char_vp_y    0 to 239
	;char_vp      512 bytes per row, max of 320 rows -- all zero-based
	
	;reset to default location of 00EA:0000, or pixel 9,0
	lda #$00EA
	sta char_vp+2
	lda #$0000
	sta char_vp

	;for each y, add 512
	ldy char_vp_y
	cpy #0    ;if 0, don't add for y, since top row
	beq addX_step
	y_loop:
		clc
		lda char_vp
		adc #512
		sta char_vp
		lda char_vp+2
		adc #0    ;no clc, to carry to next word
		sta char_vp+2
		dec char_vp_y
		bne y_loop

	;add X
	addX_step:
		clc
		lda char_vp
		adc char_vp_x
		sta char_vp
		lda char_vp+2
		adc #0    ;no clc, to carry to next word
		sta char_vp+2

	ply
	plx
	pla
	rts
	
PrintString:
  stx xtmp   ;store x
  ldx #$00
  stx rows_remain   ;printstring current char tracking

  PrintStringLoop:
    lda message_to_process
      cmp #$00
    beq NoMessage
      cmp #$01
    beq SelectMessage1
      cmp #$02
    beq SelectMessage2
      cmp #$03
    beq SelectMessage3
      cmp #$04
    beq SelectMessage4
      cmp #$05
    beq SelectMessage5
      cmp #$06
    beq SelectMessage6
      cmp #$07
    beq SelectMessage7
      ;if nothing selected correctly at this point, assume message 1
      jmp SelectMessage1

	PrintStringLoopCont:
		bne print_char_vga    ;where to go when there are chars to process
		ldx xtmp   ;set x back to orig value
		rts

;SelectMessge subroutines
    NoMessage:
      ;ldx $40   ;set x back to orig value
      ldx xtmp   ;set x back to orig value
      rts
    SelectMessage1:
      lda message1,x
      AND #$00FF      ; 16-bit adjustment to code
      jmp PrintStringLoopCont
    SelectMessage2:
      lda message2,x
      AND #$00FF      ; 16-bit adjustment to code
      jmp PrintStringLoopCont
    SelectMessage3:
      lda message3,x
      AND #$00FF      ; 16-bit adjustment to code
      jmp PrintStringLoopCont
    SelectMessage4:
      lda message4,x
      AND #$00FF      ; 16-bit adjustment to code
      jmp PrintStringLoopCont
    SelectMessage5:
      lda message5,x
      AND #$00FF      ; 16-bit adjustment to code
      jmp PrintStringLoopCont
    SelectMessage6:
      lda message6,x
      AND #$00FF      ; 16-bit adjustment to code
      jmp PrintStringLoopCont
    SelectMessage7:
      lda message7,x
      AND #$00FF      ; 16-bit adjustment to code
      jmp PrintStringLoopCont

print_hex_vga:
  ;convert scancode/ascii value/other hex to individual chars and display
  ;e.g., scancode = #$12 (left shift) but want to show '0x12' on LCD
  ;accumulator has the value of the scancode

  ;put items on stack, so we can return them
  pha ;a to stack
  phx ;x to stack
  phy ;y to stack

  ;sta $65     ;store A so we can keep using original value
  sta tmpHex
  
  lda #$78    ;'x'
  jsr print_char_vga

  ;high nibble
  lda tmpHex
  and #%11110000
  lsr ;shift high nibble to low nibble
  lsr
  lsr
  lsr
  tay
  lda hexOutLookup, y
  and #$00FF    ;16-bit adjustment
  jsr print_char_vga

  ;low nibble
  lda tmpHex
  and #%00001111
  tay
  lda hexOutLookup, y
  and #$00FF    ;16-bit adjustment
  jsr print_char_vga

  ;return items from stack
  ply ;stack to y
  plx ;stack to x
  pla ;stack to a
  rts

print_char_vga:
  ; TO DO safety code... this function assumes a valid ascii char that is supported
  ; current char is in A(ccumulator)
  ; caller guarantees A/X are 16-bit on entry
  
  sta char_current_val
  lda char_vp+2
  sta vidpageVRAM+2
  lda char_vp
  sta vidpageVRAM
    
  ldy char_x_offset  ;column start
  ;cpy #$012C    ;cols - past this will CRLF
  cpy #312    ;cols - past this will CRLF
  bcc pcv_cont
    ldy char_x_offset
    jsr gfx_CRLF
  pcv_cont:
  sty char_x_offset_orig   ;remember this offset, so we can come back each row

  ldx #$00
  ;stx $52   ;character pixel row loop counter
  stx charPixelRowLoopCounter   ;character pixel row loop counter

  ; https://www.asc.ohio-state.edu/demarneffe.1/LING5050/material/ASCII-Table.png
  
  _nextRow:
    lda char_current_val
    sec
    sbc #$0020  ;translate from ASCII value to address in ROM   ;example: 'a' 0x61 minus 0x20 = 0x41 for location in charmap
    ;multiply by 8 (8 bits per byte)
    asl   ;double
    asl   ;double again
    asl   ;double a third time
    clc
    adc charPixelRowLoopCounter   ;for each loop through rows of pixel, increase this by one, so that following logic fetches the correct char pixel row
    clc
    ;adc #$07 ;advance to the next char
    tax
    lda charmap, x
    AND #$00FF      ; 16-bit adjustment to code
    sta char_from_charmap
    jmp CharMap_Selected

CharMap_Selected:
  charpix_col1:
  ;lda $50   ;stored current char from appropriate charmap
  lda char_from_charmap   ;stored current char from appropriate charmap
  and #PIXEL_COL1   ;look at the first column of the pixel row and see if the pixel should be set
  beq charpix_col2  ;if the first bit is not a 1 go to the next pixel, otherwise, continue and print the pixel
  lda char_color	;load color stored above
  ;sta [vidpage], y ; write A register to address vidpage + y
  jsr WriteVidPageVRAM
  charpix_col2:
  iny   ;shift pixel writing location one to the right
  lda char_from_charmap
  and #PIXEL_COL2
  beq charpix_col3
  lda char_color	;load color stored above
  jsr WriteVidPageVRAM
  charpix_col3:
  iny
  ;lda charmap1, x
  lda char_from_charmap
  and #PIXEL_COL3
  beq charpix_col4
  lda char_color	;load color stored above
  jsr WriteVidPageVRAM
  charpix_col4:
  iny
  lda char_from_charmap
  and #PIXEL_COL4
  beq charpix_col5
  lda char_color	;load color stored above
  jsr WriteVidPageVRAM
  charpix_col5:
  iny
  lda char_from_charmap
  and #PIXEL_COL5
  beq charpix_rowdone
  lda char_color	;load color stored above
  jsr WriteVidPageVRAM
  ;could expand support beyond 5 colums (up to 8, based on charmap)
  charpix_rowdone:
  jsr gfx_NextVGALineVRAM
  ldy char_x_offset_orig   ;back to first column

  ;check if we are through the 7 rows. if so, jump out. otherwise, start next row of font character.
  inc charPixelRowLoopCounter   ;inc row loop counter
  lda charPixelRowLoopCounter
  cmp #$08  ;see if we have made it through all 7 rows
  bne _nextRowJump  ;if we have not processed all 7 rows, branch to repeat. otherwise, go to next line

  ;no more rows to process in this character
  ldx #$00
  stx charPixelRowLoopCounter   ;row loop counter
  jmp NextChar  

  _nextRowJump:
    jmp _nextRow

NextChar:
  ;move the 'cursor' to the right by 6 pixels
  inc char_x_offset
  inc char_x_offset
  inc char_x_offset
  inc char_x_offset
  inc char_x_offset
  inc char_x_offset
  inc rows_remain   ;string char# tracker
  ldx rows_remain
  jmp PrintStringLoop

gfx_CRLF:
  ; Video RAM is at $EA0000 to $EBFFFF
  pha
  ;move the location for writing to the screen down one line
  clc
  lda char_vp
  ;adc #5120         ; 10 rows - add 512 to move to next row (pixel)
  adc #4096          ; 8 rows - add 512 to move to next row (pixel)
  sta char_vp    
  lda char_vp+2   ;do not clc... need the carry bit to roll to the second (high) byte
  adc #0          ;add carry
  sta char_vp+2

  ;lda #$00
  ;sta char_x_offset

  ; Check if we are past the bottom of the screen. If so, shift screen up.
  ; VRAM_BASE = $EA0000
  ; SCROLL_THRESHOLD = $EBD000 (232 rows)

    lda char_vp+2
    cmp #$EB
    bcc no_scroll        ; < $EB0000 → safe
    bne do_scroll        ; > $EB0000 → definitely past threshold

    ; high byte == $EB, compare low word
    lda char_vp
    cmp #$D001
    bcc no_scroll

    do_scroll:
      jsr gfx_scroll_up_8

      ; reset char_vp to last visible row
      lda #$D000
      sta char_vp
      lda #$EB
      sta char_vp+2

      ;lda #$00
      ;sta char_x_offset

    no_scroll:
      lda #$00
      sta char_x_offset
      pla
      rts

gfx_scroll_up_8:
    php
    rep #$30    ; 8-bit A/X/Y
    .setting "RegA16", true
    .setting "RegXY16", true

    pha
    phx
    phy
    phb

    ; A = length-1 for MVN
    ; X = source offset
    ; Y = destination offset

    ; 1) EA1000–EAFFFF → EA0000–EAEFFF  (F000 bytes)
    lda #$EFFF          ; length-1
    ldx #$1000          ; src = EA1000
    ldy #$0000          ; dst = EA0000
    mvn $EA,$EA         ; dest=$EA, src=$EA

    ; 2) EB0000–EB0FFF → EAF000–EAFFFF  (1000 bytes)
    lda #$0FFF          ; length-1
    ldx #$0000          ; src = EB0000
    ldy #$F000          ; dst = EAF000
    mvn $EA,$EB         ; dest=$EA, src=$EB

    ; 3) EB1000–EBDFFF → EB0000–EBCFFF  (E000 bytes)
    lda #$CFFF          ; length-1
    ldx #$1000          ; src = EB1000
    ldy #$0000          ; dst = EB0000
    mvn $EB,$EB         ; dest=$EB, src=$EB

    ; clear bottom char row
    ;ldx #$0FFF
    ldx #$1000
    lda #0
    clear_loop:
        sta $EBD000,x
        dex
        dex
        bpl clear_loop

    plb
    ply
    plx
    pla
    plp
    rts

gfx_TestPattern_Animated_Ship:

  ;ship sprite stored on ROM at ;$00E000 to $00E3FF (without transparency)
  ;VGA is at $EA0000
  php
  rep #$30
  .setting "RegA16", true
  .setting "RegXY16", true

  pha
  phx
  phy
  ;x = source addr, y = dest addr, a = length-1
  ;mvn destBank, sourceBank
  
  lda #0
  sta move_frame_counter
  lda #$7010  ;position at appropriate vertical position
  sta move_dest

  ship_frame_loop:
    lda #31    ;number of bytes per row minus one
    sta move_size
    lda #$E000
    sta move_source
    lda #32   ;number of rows to process
    sta move_counter

    ship_line_loop:
      lda move_size     ;size (64 bytes)
      ldx move_source ;from
      ldy move_dest ;to
      phb
      mvn $EB, $00    ;EB:0000 is bottom half of video frame, 00:E000 is ROM page where this sprite is stored
      plb
      lda move_source
      clc
      adc #32
      sta move_source
      lda move_dest
      clc
      adc #512  ;next row
      sta move_dest
      dec move_counter
      bne ship_line_loop

    jsr ship_delay
    inc move_frame_counter
    lda #$7010
    clc
    adc move_frame_counter
    sta move_dest
    lda move_frame_counter
    cmp #260
    bne ship_frame_loop

  ;clear the final ship
    lda #275
    sta fill_region_start_x
    lda #185
    sta fill_region_start_y
    lda #315
    sta fill_region_end_x
    lda #215
    sta fill_region_end_y
    lda #%00000000
    sta fill_region_color
    jsr gfx_FillRegionVRAM

  out_x:
  ply
  plx
  pla
  plp
  rts

ship_delay:
  pha       		;save current accumulator
  ;lda #$1100 		;counter start - increase number to shorten delay
  lda #$F000 		;counter start - increase number to shorten delay
  Delayloop:
    clc
    adc #01
    bne Delayloop
  pla
  rts

print_string_vga:
  php
  rep #$30
  .setting "RegA16", true
  pha
  phx
  phy
  
  ldy #0

  print_string_vga_loop:
    sep #$20
    .setting "RegA16", false
    lda [Str_ptr],y
    beq print_string_vga_done
    
    rep #$20
    .setting "RegA16", true
    and #$00ff
    phy   ; to do: fix print_char_vga to preserve y
    jsr print_char_vga
    ply
    iny
    bne print_string_vga_loop
    
    inc Str_ptr+1
    bra print_string_vga_loop

  print_string_vga_done:
    rep #$30
    .setting "RegA16", true
    ply
    plx
    pla
    plp
    rts

print_string_vga_power_on:
  lda #0
  sta fill_region_start_x
  sta fill_region_start_y
  lda #319
  sta fill_region_end_x
  lda #7
  sta fill_region_end_y
  lda #%0000000000000011  ; blue
  sta fill_region_color
  jsr gfx_FillRegionVRAM 

  lda #<STR_POST_POWER_ON
  sta Str_ptr
  lda #>STR_POST_POWER_ON
  sta Str_ptr+1
  jsr print_string_vga
  jsr gfx_CRLF

  rts

gfx_DrawRectangle:
  ; inputs: fill_region_start_x, fill_region_start_y, 
  ;         fill_region_end_x, fill_region_end_y, fill_region_color
  pha
  phx
  phy

  ; --- Top Edge ---
  ; (start_x, start_y) to (end_x, start_y)
  lda fill_region_start_x
  sta rect_line_start_x
  lda fill_region_start_y
  sta rect_line_start_y
  lda fill_region_end_x
  sta rect_line_end_x
  lda fill_region_start_y
  sta rect_line_end_y
  jsr gfx_RectangleSide

  ; --- Right Edge ---
  ; (end_x, start_y) to (end_x, end_y)
  lda fill_region_end_x
  sta rect_line_start_x
  lda fill_region_start_y
  sta rect_line_start_y
  lda fill_region_end_x
  sta rect_line_end_x
  lda fill_region_end_y
  sta rect_line_end_y
  jsr gfx_RectangleSide

  ; --- Bottom Edge ---
  ; (end_x, end_y) to (start_x, end_y)
  lda fill_region_end_x
  sta rect_line_start_x
  lda fill_region_end_y
  sta rect_line_start_y
  lda fill_region_start_x
  sta rect_line_end_x
  lda fill_region_end_y
  sta rect_line_end_y
  jsr gfx_RectangleSide

  ; --- Left Edge ---
  ; (start_x, end_y) to (start_x, start_y)
  lda fill_region_start_x
  sta rect_line_start_x
  lda fill_region_end_y
  sta rect_line_start_y
  lda fill_region_start_x
  sta rect_line_end_x
  lda fill_region_start_y
  sta rect_line_end_y
  jsr gfx_RectangleSide

  ply
  plx
  pla
  rts

gfx_RectangleSide:
  ; inputs: 
  ; rect_line_start_x:  .equ  $58
  ; rect_line_start_y:  .equ  $5A
  ; rect_line_end_x:    .equ  $5C
  ; rect_line_end_y:    .equ  $5E
  ; fill_region_color:  (shared)

  pha
  phx
  phy

  ; calculate delta_x = abs(end_x - start_x)
  sec
  lda rect_line_end_x
  sbc rect_line_start_x
  bcs @posdx
  eor #$ffff             ; negate if negative
  inc
 @posdx:
  sta line_delta_x

  ; calculate delta_y = abs(end_y - start_y)
  sec
  lda rect_line_end_y
  sbc rect_line_start_y
  bcs @posdy
  eor #$ffff
  inc
 @posdy:
  sta line_delta_y

  ; determine step direction for X (+1 or -1)
  lda #1
  sta line_step_x
  lda rect_line_end_x
  cmp rect_line_start_x
  bcs @stepxdone
  lda #$ffff
  sta line_step_x
 @stepxdone:

  ; determine step direction for Y (+1 or -1)
  lda #1
  sta line_step_y
  lda rect_line_end_y
  cmp rect_line_start_y
  bcs @stepydone
  lda #$ffff
  sta line_step_y
 @stepydone:

  ; initialize error = delta_x - delta_y
  lda line_delta_x
  sec
  sbc line_delta_y
  sta line_error

 @lineloop:
  ; 1. set up VRAM pointer for current pixel
  lda rect_line_start_y
  sta jump_to_line_y
  jsr gfx_JumpToLineVRAM
  
  ; 2. draw the pixel
  ldy rect_line_start_x
  lda fill_region_color
  jsr WriteVidPageVRAM

  ; 3. check if we reached the end point
  lda rect_line_start_x
  cmp rect_line_end_x
  bne @continue
  lda rect_line_start_y
  cmp rect_line_end_y
  beq @done              ; both X and Y match end point
 @continue:

  ; 4. calculate error2 = error * 2
  lda line_error
  asl
  sta line_error2

  ; --- X Update Check (if e2 > -dy) ---
  lda line_error2
  clc
  adc line_delta_y
  bmi @checky            ; if negative, skip x step
  
  lda line_error
  sec
  sbc line_delta_y
  sta line_error
  lda rect_line_start_x
  clc
  adc line_step_x
  sta rect_line_start_x

 @checky:
  ; --- Y Update Check (if e2 < dx) ---
  lda line_delta_x
  sec
  sbc line_error2
  bmi @nextloop          ; if result is negative, skip y step
  beq @nextloop          ; if zero, skip y step
  
  lda line_error
  clc
  adc line_delta_x
  sta line_error
  lda rect_line_start_y
  clc
  adc line_step_y
  sta rect_line_start_y

 @nextloop:
  jmp @lineloop

 @done:
  ply
  plx
  pla
  rts

gfx_DrawRectangleFilled:
  ;inputs: fill_region_start_x, fill_region_start_y, fill_region_end_x, fill_region_end_y, fill_region_color
  pha ;a to stack
  phx ;x to stack
  phy ;y to stack
  
  @loopstart:
    ;start location
    lda fill_region_start_y
    sta jump_to_line_y

    jsr gfx_JumpToLineVRAM

    ldx fill_region_end_x
    inx
    stx col_end ; column# end comparison
    
    lda fill_region_end_y
    sec
    sbc fill_region_start_y
    sta rows_remain ; rows remaining
    inc rows_remain ; add one to get count of rows to process

    @yloop:
      ldy fill_region_start_x     ;horizontal pixel location, 0 to 319
      lda fill_region_color
            
    @xloop:
      jsr WriteVidPageVRAM
      iny
      cpy col_end
      beq @xdone    ;done with this row
      jmp @xloop
    @xdone:
      ;move on to next row
      dec rows_remain
      beq @ydone
      lda vidpageVRAM
      clc
      adc #512
      sta vidpageVRAM    
      lda vidpageVRAM+2   ;do not clc... need the carry bit to roll to the second (high) byte
      adc #$00          ;add carry
      sta vidpageVRAM+2                  
      jmp @yloop
    @ydone:
        
    ply ;stack to y
    plx ;stack to x
    pla ;stack to a
    rts

gfx_DrawLine:
  ; inputs: fill_region_start_x, fill_region_start_y, 
  ;         fill_region_end_x, fill_region_end_y, fill_region_color
  pha
  phx
  phy

  ; calculate delta_x = abs(end_x - start_x)
  sec
  lda fill_region_end_x
  sbc fill_region_start_x
  bcs @posdx
  eor #$ffff             ; negate if negative
  inc
 @posdx:
  sta line_delta_x

  ; calculate delta_y = abs(end_y - start_y)
  sec
  lda fill_region_end_y
  sbc fill_region_start_y
  bcs @posdy
  eor #$ffff
  inc
 @posdy:
  sta line_delta_y

  ; determine step direction for X (+1 or -1)
  lda #1
  sta line_step_x
  lda fill_region_end_x
  cmp fill_region_start_x
  bcs @stepxdone
  lda #$ffff
  sta line_step_x
 @stepxdone:

  ; determine step direction for Y (+1 or -1)
  lda #1
  sta line_step_y
  lda fill_region_end_y
  cmp fill_region_start_y
  bcs @stepydone
  lda #$ffff
  sta line_step_y
 @stepydone:

  ; initialize error = delta_x - delta_y
  lda line_delta_x
  sec
  sbc line_delta_y
  sta line_error

 @lineloop:
  ; 1. set up VRAM pointer for current pixel
  lda fill_region_start_y
  sta jump_to_line_y
  jsr gfx_JumpToLineVRAM
  
  ; 2. draw the pixel
  ldy fill_region_start_x
  lda fill_region_color
  jsr WriteVidPageVRAM

  ; 3. check if we reached the end point
  lda fill_region_start_x
  cmp fill_region_end_x
  bne @continue
  lda fill_region_start_y
  cmp fill_region_end_y
  beq @done              ; both X and Y match end point
 @continue:

  ; 4. calculate error2 = error * 2
  lda line_error
  asl
  sta line_error2

  ; --- X Update Check (if e2 > -dy) ---
  ; logically: if (e2 + dy) >= 0 then step x
  lda line_error2
  clc
  adc line_delta_y
  bmi @checky            ; if negative, skip x step
  
  lda line_error
  sec
  sbc line_delta_y
  sta line_error
  lda fill_region_start_x
  clc
  adc line_step_x
  sta fill_region_start_x

 @checky:
  ; --- Y Update Check (if e2 < dx) ---
  ; logically: if (dx - e2) > 0 then step y
  lda line_delta_x
  sec
  sbc line_error2
  bmi @nextloop          ; if result is negative, skip y step
  beq @nextloop          ; if zero, skip y step (e2 < dx, not <=)
  
  lda line_error
  clc
  adc line_delta_x
  sta line_error
  lda fill_region_start_y
  clc
  adc line_step_y
  sta fill_region_start_y

 @nextloop:
  jmp @lineloop

 @done:
  ply
  plx
  pla
  rts 

gfx_DrawCircle:
  ; dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, ---, ---, color_lo, color_hi
  ;         fill_region_start_x,  fill_region_start_y, fill_region_end_x, ---, fill_region_color
  pha
  phx
  phy

  ; initialize algorithm: x = 0, y = radius
  stz circle_x
  lda fill_region_end_x
  sta circle_y
  
  ; error = 3 - (radius * 2)
  asl
  eor #$ffff
  inc
  clc
  adc #3
  sta circle_error

 @circleloop:
  ; termination check: if y < x then done
  lda circle_y
  cmp circle_x
  bmi @done

  jsr @drawpoints

  ; update error and coordinates
  lda circle_error
  bmi @errorneg

  ; if error >= 0: y--, error = error + 4 * (x - y) + 10
  lda circle_y
  dec
  sta circle_y
  
  lda circle_x
  sec
  sbc circle_y
  asl
  asl
  clc
  adc #10
  adc circle_error
  sta circle_error
  bra @nextstep

 @errorneg:
  ; if error < 0: error = error + (4 * x) + 6
  lda circle_x
  asl
  asl
  clc
  adc #6
  adc circle_error
  sta circle_error

 @nextstep:
  inc circle_x
  bra @circleloop

 @done:
  ply
  plx
  pla
  rts

 @drawpoints:
  ; --- (center_x +/- circle_x, center_y +/- circle_y) ---
  ; row: start_y + circle_y
  lda fill_region_start_y
  clc
  adc circle_y
  sta jump_to_line_y
  jsr gfx_JumpToLineVRAM
  lda fill_region_start_x
  clc
  adc circle_x
  tay
  lda fill_region_color
  jsr WriteVidPageVRAM
  lda fill_region_start_x
  sec
  sbc circle_x
  tay
  lda fill_region_color
  jsr WriteVidPageVRAM

  ; row: start_y - circle_y
  lda fill_region_start_y
  sec
  sbc circle_y
  sta jump_to_line_y
  jsr gfx_JumpToLineVRAM
  lda fill_region_start_x
  clc
  adc circle_x
  tay
  lda fill_region_color
  jsr WriteVidPageVRAM
  lda fill_region_start_x
  sec
  sbc circle_x
  tay
  lda fill_region_color
  jsr WriteVidPageVRAM

  ; --- (center_x +/- circle_y, center_y +/- circle_x) ---
  ; row: start_y + circle_x
  lda fill_region_start_y
  clc
  adc circle_x
  sta jump_to_line_y
  jsr gfx_JumpToLineVRAM
  lda fill_region_start_x
  clc
  adc circle_y
  tay
  lda fill_region_color
  jsr WriteVidPageVRAM
  lda fill_region_start_x
  sec
  sbc circle_y
  tay
  lda fill_region_color
  jsr WriteVidPageVRAM

  ; row: start_y - circle_x
  lda fill_region_start_y
  sec
  sbc circle_x
  sta jump_to_line_y
  jsr gfx_JumpToLineVRAM
  lda fill_region_start_x
  clc
  adc circle_y
  tay
  lda fill_region_color
  jsr WriteVidPageVRAM
  lda fill_region_start_x
  sec
  sbc circle_y
  tay
  lda fill_region_color
  jsr WriteVidPageVRAM
  rts

gfx_DrawCircleFilled:
  ; dpsram: start_x_lo, start_x_hi, start_y_lo, start_y_hi, width_lo, width_hi, ---, ---, color_lo, color_hi
  ;         fill_region_start_x,  fill_region_start_y, fill_region_end_x, ---, fill_region_color
  ; inputs from SYSCALL_PARAMS: 
  ; start_x_lo, start_y_lo, radius_lo, radius,hi, color_lo
  pha
  phx
  phy

  ; initialize algorithm: x = 0, y = radius
  stz circle_x
  lda fill_region_end_x  ; radius lo in fill_region_end_x for SYSCALL_PARAMS convention
  sta circle_y
  
  ; error = 3 - (radius * 2)
  asl
  eor #$ffff
  inc
  clc
  adc #3
  sta circle_error

  @circleloop:
    ; termination check: if y < x then done
    lda circle_y
    cmp circle_x
    bmi @done

    jsr @drawsegments

    ; update error and coordinates
    lda circle_error
    bmi @errorneg

    ; if error >= 0: y--, error = error + 4 * (x - y) + 10
    lda circle_y
    dec
    sta circle_y
    
    lda circle_x
    sec
    sbc circle_y
    asl
    asl
    clc
    adc #10
    adc circle_error
    sta circle_error
    bra @nextstep

  @errorneg:
    ; if error < 0: error = error + (4 * x) + 6
    lda circle_x
    asl
    asl
    clc
    adc #6
    adc circle_error
    sta circle_error

  @nextstep:
    inc circle_x
    bra @circleloop

  @done:
    ply
    plx
    pla
    rts

  @drawsegments:
    ; row: fill_region_start_y + circle_y
    lda fill_region_start_y
    clc
    adc circle_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM
    lda fill_region_start_x
    sec
    sbc circle_x
    tax                   ; left x
    lda fill_region_start_x
    clc
    adc circle_x
    tay                   ; right x
    jsr @hlinerender

    ; row: fill_region_start_y - circle_y
    lda fill_region_start_y
    sec
    sbc circle_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM
    lda fill_region_start_x
    sec
    sbc circle_x
    tax
    lda fill_region_start_x
    clc
    adc circle_x
    tay
    jsr @hlinerender

    ; row: fill_region_start_y + circle_x
    lda fill_region_start_y
    clc
    adc circle_x
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM
    lda fill_region_start_x
    sec
    sbc circle_y
    tax
    lda fill_region_start_x
    clc
    adc circle_y
    tay
    jsr @hlinerender

    ; row: fill_region_start_y - circle_x
    lda fill_region_start_y
    sec
    sbc circle_x
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM
    lda fill_region_start_x
    sec
    sbc circle_y
    tax
    lda fill_region_start_x
    clc
    adc circle_y
    tay
    jsr @hlinerender
    rts

  @hlinerender:
    ; horizontal span: draw from X to Y
  @hloop:
    phx                   ; save current x
    phy                   ; save target x
    txy                   ; move x to y for WriteVidPageVRAM call
    lda fill_region_color
    jsr WriteVidPageVRAM
    ply                   ; restore target x
    plx                   ; restore current x
    inx
    stx circle_temp_cmp
    cpy circle_temp_cmp
    bpl @hloop
    rts

gfx_DrawPixel:
  ; inputs: fill_region_start_x, fill_region_start_y, fill_region_color
  pha
  phx
  phy

  ; set up the row
  lda fill_region_start_y
  sta jump_to_line_y
  jsr gfx_JumpToLineVRAM

  ; set up the column and color
  ldy fill_region_start_x
  lda fill_region_color
  jsr WriteVidPageVRAM

  @done:
  ply
  plx
  pla
  rts

  gfx_DrawDiamond:
  ; inputs: fill_region_start_x, fill_region_start_y (center)
  ;         fill_region_end_x (radius), fill_region_color
  pha
  phx
  phy

  ; --- Top to Right ---
  lda fill_region_start_x
  sta rect_line_start_x
  lda fill_region_start_y
  sec
  sbc fill_region_end_x
  sta rect_line_start_y
  
  lda fill_region_start_x
  clc
  adc fill_region_end_x
  sta rect_line_end_x
  lda fill_region_start_y
  sta rect_line_end_y
  jsr gfx_RectangleSide

  ; --- Right to Bottom ---
  ; start is already at Right from previous step
  lda rect_line_end_x
  sta rect_line_start_x
  lda rect_line_end_y
  sta rect_line_start_y
  
  lda fill_region_start_x
  sta rect_line_end_x
  lda fill_region_start_y
  clc
  adc fill_region_end_x
  sta rect_line_end_y
  jsr gfx_RectangleSide

  ; --- Bottom to Left ---
  lda rect_line_end_x
  sta rect_line_start_x
  lda rect_line_end_y
  sta rect_line_start_y
  
  lda fill_region_start_x
  sec
  sbc fill_region_end_x
  sta rect_line_end_x
  lda fill_region_start_y
  sta rect_line_end_y
  jsr gfx_RectangleSide

  ; --- Left to Top ---
  lda rect_line_end_x
  sta rect_line_start_x
  lda rect_line_end_y
  sta rect_line_start_y
  
  lda fill_region_start_x
  sta rect_line_end_x
  lda fill_region_start_y
  sec
  sbc fill_region_end_x
  sta rect_line_end_y
  jsr gfx_RectangleSide

  ply
  plx
  pla
  rts

  gfx_DrawDiamondFilled:
  ; inputs: fill_region_start_x, fill_region_start_y (center)
  ;         fill_region_end_x (radius), fill_region_color
  pha
  phx
  phy

  stz diamond_cur_offset     ; horizontal offset from center starts at 0
  
  ; start at top tip: y = center_y - radius
  lda fill_region_start_y
  sec
  sbc fill_region_end_x
  sta diamond_cur_y

  ; number of rows to process is (radius * 2) + 1
  lda fill_region_end_x
  asl
  inc
  sta diamond_row_count

 @rowloop:
  ; 1. Jump to the VRAM line
  lda diamond_cur_y
  sta jump_to_line_y
  jsr gfx_JumpToLineVRAM

  ; 2. Calculate span: (center_x - offset) to (center_x + offset)
  lda fill_region_start_x
  sec
  sbc diamond_cur_offset
  tax                        ; start x
  
  lda fill_region_start_x
  clc
  adc diamond_cur_offset
  tay                        ; end x
  
  jsr @hlinerender

  ; 3. Update offset
  ; if y < center_y, increment offset. else decrement.
  lda diamond_cur_y
  cmp fill_region_start_y
  bpl @decrement

  inc diamond_cur_offset
  bra @nextrow

 @decrement:
  dec diamond_cur_offset

 @nextrow:
  inc diamond_cur_y
  dec diamond_row_count
  bne @rowloop

  ply
  plx
  pla
  rts

 @hlinerender:
  ; same helper as your circle routine
 @hloop:
  phx
  phy
  txy
  lda fill_region_color
  jsr WriteVidPageVRAM
  ply
  plx
  inx
  stx circle_temp_cmp
  cpy circle_temp_cmp
  bpl @hloop
  rts

sprite_table_8:
  .byte $00, $00, $45, $00    ; ID 0: $450000 - Mouse cursor
  .byte $40, $00, $45, $00    ; ID 1: $450040 - Shooter crosshair

sprite_table_32:
  .byte $00, $00, $46, $00    ; ID 0: $060000   ; ship

sprite_table_16:
  ; --- Mario Left (IDs 0-5) ---
  .byte $00, $08, $46, $00    ; ID 0: $060800
  .byte $00, $09, $46, $00    ; ID 1: $060900
  .byte $00, $0A, $46, $00    ; ID 2: $060A00
  .byte $00, $0B, $46, $00    ; ID 3: $060B00
  .byte $00, $0C, $46, $00    ; ID 4: $060C00
  .byte $00, $0D, $46, $00    ; ID 5: $060D00

  ; --- Mario Right (IDs 6-11) ---
  .byte $00, $0E, $46, $00    ; ID 6: $060E00
  .byte $00, $0F, $46, $00    ; ID 7: $060F00
  .byte $00, $10, $46, $00    ; ID 8: $061000
  .byte $00, $11, $46, $00    ; ID 9: $061100
  .byte $00, $12, $46, $00    ; ID 10: $061200
  .byte $00, $13, $46, $00    ; ID 11: $061300

gfx_DrawSprite16:
  ;; gfx_DrawSprite16
  ;; Inputs: sprite_x, sprite_y, sprite_id
  ;; Table: sprite_table_16 (4 bytes per entry)
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true

    pha
    phx
    phy

    ; 1. Back up current VRAM pointer
    lda vidpageVRAM + 2
    pha
    lda vidpageVRAM
    pha

    ; 2. Lookup ROM Source Address
    lda sprite_id
    and #$00FF
    asl a
    asl a
    tax

    lda sprite_table_16,x
    sta ptrsrc
    lda sprite_table_16+2,x
    sta ptrsrc+2

    ; 3. Set VRAM start line
    lda sprite_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM

    ; 4. Draw Loop
    ldx #0                  ; Row counter
  @rowloop:
      phx                     ; Save row counter
      ldx #0                  ; Column counter (ROM index)

  @pixelloop:
      sep #$20
      .setting "RegA16", false
      
      txy
      lda [ptrsrc],y          ; Read pixel from ROM (Bank:ptrsrc + Y)
      
      cmp #$24                ; Transparency check
      beq @skippixel

      pha                     ; Save color
      rep #$20
      .setting "RegA16", true
      tya                     ; A = current ROM column (0-15)
      clc
      adc sprite_x            ; A = absolute horizontal VRAM offset
      tay                     ; Y = VRAM offset for call
      sep #$20
      .setting "RegA16", false

      pla                     ; Restore color
      
      jsr WriteVidPageVRAM

  @skippixel:
      inx                     ; Advance ROM index
      cpx #16
      bne @pixelloop

      ; 5. Advance to next line
      rep #$20
      .setting "RegA16", true

      lda ptrsrc
      clc
      adc #16
      sta ptrsrc

      lda vidpageVRAM
      clc
      adc #512                ; System stride
      sta vidpageVRAM
      lda vidpageVRAM+2
      adc #0
      sta vidpageVRAM+2

      plx                     ; Restore row counter
      inx
      cpx #16
      bne @rowloop

  @exit:
      rep #$30
      .setting "RegA16", true
      .setting "RegXY16", true

      ; 6. Restore original VRAM pointer
      pla
      sta vidpageVRAM
      pla
      sta vidpageVRAM + 2

      ply
      plx
      pla
      plp
      rts
      
gfx_DrawSprite32:
  ;; gfx_DrawSprite32
  ;; Inputs: sprite_x, sprite_y, sprite_id
  ;; Table: sprite_table_32 (4 bytes per entry)
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true

    pha
    phx
    phy

    ; 1. Back up current VRAM pointer
    lda vidpageVRAM + 2
    pha
    lda vidpageVRAM
    pha

    ; 2. Lookup ROM Source Address
    lda sprite_id
    and #$00FF
    asl a
    asl a
    tax

    lda sprite_table_32,x
    sta ptrsrc
    lda sprite_table_32+2,x
    sta ptrsrc+2

    ; 3. Set VRAM start line
    lda sprite_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM

    ; 4. Draw Loop
    ldx #0                  ; Row counter
  @rowloop:
      phx                     ; Save row counter
      ldx #0                  ; Column counter (ROM index)

  @pixelloop:
      sep #$20
      .setting "RegA16", false
      
      txy
      lda [ptrsrc],y          ; Read pixel from ROM (Bank:ptrsrc + Y)
      
      cmp #$24                ; Transparency check
      beq @skippixel

      pha                     ; Save color
      rep #$20
      .setting "RegA16", true
      tya                     ; A = current ROM column (0-31)
      clc
      adc sprite_x            ; A = absolute horizontal VRAM offset
      tay                     ; Y = VRAM offset for call
      sep #$20
      .setting "RegA16", false

      pla                     ; Restore color
      
      jsr WriteVidPageVRAM

  @skippixel:
      inx                     ; Advance ROM index
      cpx #32                 ; 32 pixels wide
      bne @pixelloop

      ; 5. Advance to next line
      rep #$20
      .setting "RegA16", true

      lda ptrsrc
      clc
      adc #32                 ; 32 bytes per row in ROM
      sta ptrsrc

      lda vidpageVRAM
      clc
      adc #512                ; System stride
      sta vidpageVRAM
      lda vidpageVRAM+2
      adc #0
      sta vidpageVRAM+2

      plx                     ; Restore row counter
      inx
      cpx #32                 ; 32 rows high
      bne @rowloop

  @exit:
      rep #$30
      .setting "RegA16", true
      .setting "RegXY16", true

      ; 6. Restore original VRAM pointer
      pla
      sta vidpageVRAM
      pla
      sta vidpageVRAM + 2

      ply
      plx
      pla
      plp
      rts

gfx_BackupTile32:
    php
    rep #$30
    pha
    phx
    phy
    phb

    ; Save original vidpageVRAM (bank and offset)
    lda vidpageVRAM+2
    pha
    lda vidpageVRAM
    pha

    ; Position vidpageVRAM to starting line first
    lda sprite_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM      ; sets vidpageVRAM and vidpageVRAM+2 (EA/EB)

    ; NOW sync DBR to current VRAM bank
    sep #$20
    lda vidpageVRAM+2
    pha
    plb
    rep #$20

    ldx #0
  @rowloopb32:
      phx

      ; ptrvram = vidpageVRAM + sprite_x
      lda vidpageVRAM
      clc
      adc sprite_x
      sta ptrvram

      ; ptrdest = vidpageVRAM + $0400 (same bank via DBR)
      lda vidpageVRAM
      clc
      adc #0400
      sta ptrdest

      ldy #0
  @pixloopb32:
      lda (ptrvram),y
      sta (ptrdest),y
      iny
      iny
      cpy #32
      bne @pixloopb32

      ; advance to next VRAM line
      lda vidpageVRAM
      clc
      adc #512
      sta vidpageVRAM
      bcc @novincb32
      inc vidpageVRAM+2
      sep #$20
      lda vidpageVRAM+2
      pha
      plb
      rep #$20
  @novincb32:
      plx
      inx
      cpx #32
      bne @rowloopb32

      ; restore original vidpageVRAM
      pla
      sta vidpageVRAM
      pla
      sta vidpageVRAM+2
      plb
      ply
      plx
      pla
      plp
      rts

gfx_RestoreTile32:
    php
    rep #$30
    pha
    phx
    phy
    phb

    ; Save original vidpageVRAM (bank and offset)
    lda vidpageVRAM+2
    pha
    lda vidpageVRAM
    pha

    ; Position vidpageVRAM to starting line first
    lda sprite_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM      ; sets vidpageVRAM and vidpageVRAM+2 (EA/EB)

    ; NOW sync DBR to current VRAM bank
    sep #$20
    lda vidpageVRAM+2
    pha
    plb
    rep #$20

    ldx #0
  @rowloopr32:
      phx

      ; ptrsrc  = vidpageVRAM + $0400 (backup area)
      lda vidpageVRAM
      clc
      adc #0400
      sta ptrsrc

      ; ptrdest = vidpageVRAM + sprite_x
      lda vidpageVRAM
      clc
      adc sprite_x
      sta ptrdest

      ldy #0
  @pixloopr32:
      lda (ptrsrc),y
      sta (ptrdest),y
      iny
      iny
      cpy #32
      bne @pixloopr32

      ; advance to next VRAM line
      lda vidpageVRAM
      clc
      adc #512
      sta vidpageVRAM
      bcc @novincr32
      inc vidpageVRAM+2
      sep #$20
      lda vidpageVRAM+2
      pha
      plb
      rep #$20
  @novincr32:
      plx
      inx
      cpx #32
      bne @rowloopr32

      ; restore original vidpageVRAM
      pla
      sta vidpageVRAM
      pla
      sta vidpageVRAM+2
      plb
      ply
      plx
      pla
      plp
      rts

gfx_BackupTile16:
    php
    rep #$30
    pha
    phx
    phy
    phb

    ; Save original vidpageVRAM (bank and offset)
    lda vidpageVRAM+2
    pha
    lda vidpageVRAM
    pha

    ; Position vidpageVRAM to starting line first
    lda sprite_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM      ; sets vidpageVRAM and vidpageVRAM+2 (EA/EB)

    ; NOW sync DBR to current VRAM bank
    sep #$20
    lda vidpageVRAM+2
    pha
    plb
    rep #$20

    ldx #0
  @rowloopb16:
      phx

      ; ptrvram = vidpageVRAM + sprite_x
      lda vidpageVRAM
      clc
      adc sprite_x
      sta ptrvram

      ; ptrdest = vidpageVRAM + $0448 (backup area)
      lda vidpageVRAM
      clc
      adc #0448
      sta ptrdest

      ldy #0
  @pixloopb16:
      lda (ptrvram),y
      sta (ptrdest),y
      iny
      iny
      cpy #16
      bne @pixloopb16

      ; advance to next VRAM line
      lda vidpageVRAM
      clc
      adc #512
      sta vidpageVRAM
      bcc @novincb16
      inc vidpageVRAM+2
      sep #$20
      lda vidpageVRAM+2
      pha
      plb
      rep #$20
  @novincb16:
      plx
      inx
      cpx #16
      bne @rowloopb16

      ; restore original vidpageVRAM
      pla
      sta vidpageVRAM
      pla
      sta vidpageVRAM+2
      plb
      ply
      plx
      pla
      plp
      rts

gfx_RestoreTile16:
    php
    rep #$30
    pha
    phx
    phy
    phb

    ; Save original vidpageVRAM (bank and offset)
    lda vidpageVRAM+2
    pha
    lda vidpageVRAM
    pha

    ; Position vidpageVRAM to starting line first
    lda sprite_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM      ; sets vidpageVRAM and vidpageVRAM+2 (EA/EB)

    ; NOW sync DBR to current VRAM bank
    sep #$20
    lda vidpageVRAM+2
    pha
    plb
    rep #$20

    ldx #0
  @rowloopr16:
      phx

      ; ptrsrc  = vidpageVRAM + $0448 (backup area)
      lda vidpageVRAM
      clc
      adc #0448
      sta ptrsrc

      ; ptrdest = vidpageVRAM + sprite_x
      lda vidpageVRAM
      clc
      adc sprite_x
      sta ptrdest

      ldy #0
  @pixloopr16:
      lda (ptrsrc),y
      sta (ptrdest),y
      iny
      iny
      cpy #16
      bne @pixloopr16

      ; advance to next VRAM line
      lda vidpageVRAM
      clc
      adc #512
      sta vidpageVRAM
      bcc @novincr16
      inc vidpageVRAM+2
      sep #$20
      lda vidpageVRAM+2
      pha
      plb
      rep #$20
  @novincr16:
      plx
      inx
      cpx #16
      bne @rowloopr16

      ; restore original vidpageVRAM
      pla
      sta vidpageVRAM
      pla
      sta vidpageVRAM+2
      plb
      ply
      plx
      pla
      plp
      rts

gfx_DrawSprite8:
    php
    rep #$30
    .setting "RegA16", true
    .setting "RegXY16", true

    pha
    phx
    phy

    ; 1. Back up current VRAM pointer
    lda vidpageVRAM + 2
    pha
    lda vidpageVRAM
    pha

    ; 2. Lookup ROM Source Address (Matches your established pattern)
    lda sprite_id
    and #$00FF
    asl a
    asl a
    tax

    lda sprite_table_8,x
    sta ptrsrc
    lda sprite_table_8+2,x
    sta ptrsrc+2

    ; 3. Set VRAM start line
    lda sprite_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM

    ; 4. Draw Loop
    ldx #0                  ; Row counter
  @rowloop8:
      phx                     ; Save row counter
      ldx #0                  ; Column counter (ROM index)

  @pixloop8:
      sep #$20
      .setting "RegA16", false
      
      txy
      lda [ptrsrc],y          ; Read pixel from ROM
      
      cmp #$24                ; Transparency check
      beq @skippixel

      pha                     ; Save color
      rep #$20
      .setting "RegA16", true
      tya                     ; A = current ROM column (0-7)
      clc
      adc sprite_x            ; A = absolute horizontal VRAM offset
      tay                     ; Y = VRAM offset for call
      sep #$20
      .setting "RegA16", false

      pla                     ; Restore color
      jsr WriteVidPageVRAM

  @skippixel:
      inx                     ; Advance ROM index
      cpx #8
      bne @pixloop8

      ; 5. Advance to next line
      rep #$20
      .setting "RegA16", true

      lda ptrsrc
      clc
      adc #8                  ; 8 bytes per row in ROM
      sta ptrsrc

      lda vidpageVRAM
      clc
      adc #512                ; System stride
      sta vidpageVRAM
      lda vidpageVRAM+2
      adc #0
      sta vidpageVRAM+2

      plx                     ; Restore row counter
      inx
      cpx #8
      bne @rowloop8

  @exit8:
      rep #$30
      .setting "RegA16", true
      .setting "RegXY16", true

      ; 6. Restore original VRAM pointer
      pla
      sta vidpageVRAM
      pla
      sta vidpageVRAM + 2

      ply
      plx
      pla
      plp
      rts

gfx_BackupTile8:
    php
    rep #$30
    pha
    phx
    phy
    phb

    ; 1. Back up original VRAM pointer
    lda vidpageVRAM+2
    pha
    lda vidpageVRAM
    pha

    ; 2. Position vidpageVRAM to the correct start of line
    lda sprite_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM

    ; 3. Match DBR to VRAM bank
    sep #$20
    lda vidpageVRAM+2
    pha
    plb
    rep #$20

    ldx #0                  ; Row counter
  @rowloopb8:
      phx
      
      ; ptrvram = Start of line + X Offset (Source)
      lda vidpageVRAM
      clc
      adc sprite_x
      sta ptrvram
      
      ; ptrdest = Start of line + Backup Offset (Destination)
      lda vidpageVRAM
      clc
      adc #0480
      sta ptrdest

      ldy #0
  @pixloopb8:
      lda (ptrvram),y          ; Copying 16-bits (2 pixels) at a time
      sta (ptrdest),y
      iny
      iny
      cpy #8                   ; 8 pixels total
      bne @pixloopb8

      ; Advance VRAM to next line start
      lda vidpageVRAM
      clc
      adc #512
      sta vidpageVRAM
      bcc @novincb8
      inc vidpageVRAM+2
      sep #$20
      lda vidpageVRAM+2
      pha
      plb
      rep #$20
  @novincb8:
      plx
      inx
      cpx #8
      bne @rowloopb8

      ; 5. Restore original state
      rep #$30
      pla
      sta vidpageVRAM
      pla
      sta vidpageVRAM+2
      plb
      ply
      plx
      pla
      plp
      rts

gfx_RestoreTile8:
    php
    rep #$30
    pha
    phx
    phy
    phb
    
    ; Back up original VRAM pointer
    lda vidpageVRAM+2
    pha
    lda vidpageVRAM
    pha

    ; Position vidpageVRAM to the correct start of line
    lda sprite_y
    sta jump_to_line_y
    jsr gfx_JumpToLineVRAM

    ; Match DBR to VRAM bank
    sep #$20
    lda vidpageVRAM+2
    pha
    plb
    rep #$20

    ldx #0                  ; Row counter
  @rowloopr8:
      phx
      
      ; ptrsrc = Start of line + Backup Offset
      lda vidpageVRAM
      clc
      adc #0480
      sta ptrsrc
      
      ; ptrdest = Start of line + X Offset
      lda vidpageVRAM
      clc
      adc sprite_x
      sta ptrdest

      ldy #0
  @pixloopr8:
      lda (ptrsrc),y          ; Copying 16-bits (2 pixels) at a time
      sta (ptrdest),y
      iny
      iny
      cpy #8                  ; 8 pixels total
      bne @pixloopr8

      ; 4. Advance VRAM to next line start
      lda vidpageVRAM
      clc
      adc #512
      sta vidpageVRAM
      bcc @novincr8
      inc vidpageVRAM+2
      sep #$20
      lda vidpageVRAM+2
      pha
      plb
      rep #$20
  @novincr8:
      plx
      inx
      cpx #8
      bne @rowloopr8

      ; 5. Restore original state
      rep #$30
      pla
      sta vidpageVRAM
      pla
      sta vidpageVRAM+2
      plb
      ply
      plx
      pla
      plp
      rts

