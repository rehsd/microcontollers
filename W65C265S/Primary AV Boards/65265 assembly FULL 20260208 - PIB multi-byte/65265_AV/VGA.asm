
; ************************************************************************************************************
; ******************************* VGA ************************************************************************
; ************************************************************************************************************
; Video RAM is at $EA0000 to $EBFFFF
; Each row is #512 of VRAM, but only first 320 are used for VGA output (remainder available for other uses)
; 256 rows of VRAM, only 240 are used for VGA output (remainder available for othre uses)
;
;

.setting "RegA16", true
.setting "RegXY16", true

Init_VGA:
	pha

	lda #$0000  ;done processing pre-defined strings
	sta message_to_process

  stz Str_ptr
  stz Str_ptr+2

	; Set location for new chars from keyboard
	lda #0
	sta char_y_offset
	lda #4
	sta char_vp_x    ;0 to 319
	lda #4
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
	lda #239
	sta fill_region_end_y
	lda #%00000000
	sta fill_region_color
	jsr gfx_FillRegionVRAM

	; Set location for new chars from keyboard
	lda #0
	sta char_y_offset
	lda #4
	sta char_vp_x    ;0 to 319
	lda #4
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
    sta char_y_offset
    
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
    sta char_y_offset
    lda #120
    sta char_vp_x    ;0 to 319
    lda #51
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #01
    sta message_to_process
    jsr PrintString

    lda #$00
    sta char_y_offset
    lda #120
    sta char_vp_x    ;0 to 319
    lda #81
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #02
    sta message_to_process
    jsr PrintString

    lda #$00
    sta char_y_offset
    lda #120
    sta char_vp_x    ;0 to 319
    lda #111
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #03
    sta message_to_process
    jsr PrintString
    
    lda #$00
    sta char_y_offset
    lda #60
    sta char_vp_x    ;0 to 319
    lda #141
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #04
    sta message_to_process
    jsr PrintString

    lda #$00
    sta char_y_offset
    lda #120
    sta char_vp_x    ;0 to 319
    lda #171
    sta char_vp_y    ;0 to 239
    jsr gfx_SetCharVpByXY
    lda #05
    sta message_to_process
    jsr PrintString

    lda #$00
    sta char_y_offset
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
  .setting "RegA16", false
  pha
  sep #$20            	; set acumulator to 8-bit
  
  sta [vidpageVRAM],y	; write A register (color) to address vidpage + y
  
  ;alternate approach
  ;tyx
  ;sta $EA0000, x			; write A register (color) to address vidpage + y


	;jsr hexprint_serial	; temporary
	;lda #'@'
	;jsr uart3_tx
	;tya
	;jsr hexprint_serial	
	;lda #'+'
	;jsr uart3_tx
	;lda vidpageVRAM+3
	;jsr hexprint_serial	
	;lda vidpageVRAM+2
	;jsr hexprint_serial	
	;lda #':'
	;jsr uart3_tx
	;lda vidpageVRAM+1
	;jsr hexprint_serial	
	;lda vidpageVRAM+0
	;jsr hexprint_serial	
	;jsr crlf
  
  .setting "RegA16", true
  rep #$20            ;set acumulator to 16-bit
  pla
  rts

gfx_JumpToLineVRAM:
    pha
    phx
    phy

    ;set vidpage back to start
    lda #$00EA
    sta vidpageVRAM+2
    lda #$0000
    sta vidpageVRAM

    ldx jump_to_line_y
    ;if jump_to_line_y is 0, we are done
    cpx #$0000
    beq gfx_JumpToLineVRAMDone

    ;Verify jump_to_line_y does not exceed 239
    cpx #$00EF    ;239
    bpl setToZero   ;probably should set to 239, but using 0 to make it more obvious if this is encountered (something else would need to be fixed)
    bra gfx_JumpToLineVRAMLoop
    
    setToZero:
      stz jump_to_line_y
      ldx jump_to_line_y
      bra gfx_JumpToLineVRAMDone

    gfx_JumpToLineVRAMLoop:
    jsr gfx_NextVGALineVRAM     ;there has to be a better way that to call this loop -- more of a direct calculation -- TBD
    dex
    bne gfx_JumpToLineVRAMLoop
    
    gfx_JumpToLineVRAMDone:

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
  ; jsr print_char_lcd	; send char to LCD to confirm
  lda char_vp+2
  sta vidpageVRAM+2
  lda char_vp
  sta vidpageVRAM
    
  ldy char_y_offset  ;column start
  ;cpy #$012C    ;cols - past this will CRLF
  cpy #$0132    ;cols - past this will CRLF
  bcc pcv_cont
    jsr gfx_CRLF
  pcv_cont:
  sty char_y_offset_orig   ;remember this offset, so we can come back each row

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
  ldy char_y_offset_orig   ;back to first column

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
  inc char_y_offset
  inc char_y_offset
  inc char_y_offset
  inc char_y_offset
  inc char_y_offset
  inc char_y_offset
  inc rows_remain   ;string char# tracker
  ldx rows_remain
  jmp PrintStringLoop

gfx_CRLF:
  pha
  ;move the location for writing to the screen down one line
  clc
  lda char_vp
  adc #5120         ;add 512 to move to next row (pixel)
  sta char_vp    
  lda char_vp+2   ;do not clc... need the carry bit to roll to the second (high) byte
  adc #0          ;add carry
  sta char_vp+2

  lda #$00
  sta char_y_offset

  pla
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
  lda #<STR_POST_POWER_ON
  sta Str_ptr
  lda #>STR_POST_POWER_ON
  sta Str_ptr+1
  jsr print_string_vga
  jsr gfx_CRLF
  rts

STR_POST_POWER_ON:	.byte "*** rehsd dual W65C265S @ 10 MHz ***", 0
