; ************* TO DO ********************************************************
; -test without ili_VIA1_PORTB_SHADOW, reading port directly
; -
; ****************************************************************************

; Using 16-bit Accumulator and Indexer by default


; DIYables 3.5 Inch Color TFT LCD Display Screen Module, 320x480, Non-Touch for Arduino Uno and Mega
; ILI9486 8-Bit Parallel Interface
; https://diyables.io/products/3.5-inch-color-tft-lcd-display-screen-module-320x480-non-touch-for-arduino-uno-and-mega-ili9486-8-bit-parallel-interface
; https://www.displayfuture.com/Display/datasheet/controller/ILI9486L.pdf

; Connecting to second VIA (VIA1) using port A for data and port B for control.
; VIA PortA[7:0] = ILI_Data[7:0]
; VIA PortB0 = ILI_RD
; VIA PortB1 = ILI_WR
; VIA PortB2 = ILI_CD
; VIA PortB3 = ILI_CS
; VIA PortB4 = ILI_RESET

; VIA is initialized in the main assembly file (65265_Primary.asm)
;   equs copied below for reference
; 	 VIA1 Address - %11010000:00000000:00000000 - $D0:0000
;    VIA1_ADDR:  	equ $D00000
;    VIA1_PORTB: 	equ $D00000
;    VIA1_PORTA: 	equ $D00001
;    VIA1_DDRB:  	equ $D00002
;    VIA1_DDRA:  	equ $D00003
;

ILI_RD:         equ     %00000001       ; read strobe - active low
ILI_WR:         equ     %00000010       ; write strobe - active low
ILI_CD:         equ     %00000100       ; command / data select - 0 = Command, 1 = Data
ILI_CS:         equ     %00001000       ; chip select - active low
ILI_RESET:      equ     %00010000       ; 0 = reset active, 1 = normal operation

    LONGA ON
    LONGI ON

ILI_Init:
    ; caller guarantees A/X/Y are 16-bit on entry

    stz ili_setaddrwindow_startX        ; 16-bit
    stz ili_setaddrwindow_startY        ; 16-bit
    stz ili_setaddrwindow_endX          ; 16-bit
    stz ili_setaddrwindow_endY          ; 16-bit
    stz ili_VIA1_PORTB_SHADOW           ; 16-bit (only need LSB though)
    stz ili_rect_height
    stz ili_rect_width
    stz ili_color

    sep #$20		; 8-bit A
    LONGA OFF

    ; Interrupts are disabled in the main ASM

    ; Set VIA ports to output
    lda #%11111111          ; 0=input, 1=output
    sta >VIA1_DDRA          ; Set all pins on port A to output
    sta >VIA1_DDRB          ; Set all pins on port B to output
    
    ; Set RD high and CS low
    ;lda >VIA1_PORTB
	;ora #ILI_RD             ; RD high
    ;ora #ILI_WR             ; WR high
    ;and #(.NOT.ILI_CS)      ; CS low
    lda #%00010011          ; highest 3 bits not used, RESET high, CS low, CD low, WR high, RD high
    sta ili_VIA1_PORTB_SHADOW
    sta >VIA1_PORTB 


    jsr ILI_Reset_Toggle

    lda #$11                    ; sleep out
    jsr ILI_Write_Command

    ldx #200        ; 120+ ms
    jsr Delay_ms

    lda #$d0                    ; power setting
    jsr ILI_Write_Command
    lda #$07                    ; VRH (VREG1OUT voltage setting)
    jsr ILI_Write_Data_Byte
    lda #$42                    ; BT (Boosting factor / step‑up control)
    jsr ILI_Write_Data_Byte
    lda #$18                    ; VC (VCOM voltage setting)
    jsr ILI_Write_Data_Byte

    lda #$d1                    ; VCOM control
    jsr ILI_Write_Command
    lda #$00                    ; VCOMH (VCOM high voltage setting)
    jsr ILI_Write_Data_Byte
    lda #$07                    ; VCOM amplitude / VCOMAC
    jsr ILI_Write_Data_Byte
    lda #$10                    ; VCOM offset / fine tuning
    jsr ILI_Write_Data_Byte


    lda #$36                    ; memory access control
    jsr ILI_Write_Command
    ;lda #$48                    ; MX, BGR (see info below)    01001000
    lda #$e8                    ; 
    jsr ILI_Write_Data_Byte
                                ; $48 = %01001000
                                ;        ||||||||
                                ;        |||||||+-- bit0 = 0 (reserved)
                                ;        ||||||+--- bit1 = 0 (reserved)
                                ;        |||||+---- bit2 = 0 (MH)
                                ;        ||||+----- bit3 = 1 (BGR)
                                ;        |||+------ bit4 = 0 (ML)
                                ;        ||+------- bit5 = 0 (MV)
                                ;        |+-------- bit6 = 1 (MX)
                                ;        +--------- bit7 = 0 (MY)

    lda #$3a                    ; interface pixel format
    jsr ILI_Write_Command
    lda #$55                    ; 16 bits per pixel     RGB565
    jsr ILI_Write_Data_Byte


    lda #$c5                    ; frame rate control
    jsr ILI_Write_Command
    lda #$10                    ; moderate frame rate
    jsr ILI_Write_Data_Byte

    lda #$c8                    ; gamma adjustment with 12-byte gamma curve (panel specific)
    jsr ILI_Write_Command
    lda #$00                    ; KP0   Darkest blacks / near‑black slope
    jsr ILI_Write_Data_Byte
    lda #$32                    ; KP1   Low‑level brightness shaping
    jsr ILI_Write_Data_Byte
    lda #$36                    ; KP2   Low‑level brightness shaping
    jsr ILI_Write_Data_Byte
    lda #$45                    ; KP3   Midtone shaping
    jsr ILI_Write_Data_Byte
    lda #$06                    ; KP4   Mid‑high transition
    jsr ILI_Write_Data_Byte
    lda #$16                    ; KP5   Highlight shaping
    jsr ILI_Write_Data_Byte
    lda #$37                    ; RP0   Red channel curve point
    jsr ILI_Write_Data_Byte
    lda #$75                    ; RP1   Red highlight shaping
    jsr ILI_Write_Data_Byte
    lda #$77                    ; VP0   Green channel curve point
    jsr ILI_Write_Data_Byte
    lda #$54                    ; VP1   Green highlight shaping
    jsr ILI_Write_Data_Byte
    lda #$0c                    ; BP0   Blue channel curve point
    jsr ILI_Write_Data_Byte
    lda #$00                    ; BP1   Blue highlight shaping
    jsr ILI_Write_Data_Byte

    lda #$13                    ; normal display mode
    jsr ILI_Write_Command

    lda #$29                    ; display on
    jsr ILI_Write_Command

    ldx #100         ; 50+ ms
    jsr Delay_ms
  
    rep #$20        ; 16-bit A
    LONGA ON

    jsr ILI_Clear_Screen

    rts

ILI_Reset_Toggle:
    ; caller guarantees A is 8-bit and X is 16-bit on entry
    LONGA OFF

    ; take reset low, hold, take high, hold

    lda ili_VIA1_PORTB_SHADOW
    ; and #(.NOT.ILI_RESET)   ; Reset low
    and #%11101111   ; Reset low
    sta ili_VIA1_PORTB_SHADOW
    sta >VIA1_PORTB


    ; while A is 8-bit, X is 16-bit
    ldx #30         ; 20+ ms
    jsr Delay_ms

    ora #ILI_RESET          ; Reset high
    sta ili_VIA1_PORTB_SHADOW
    sta >VIA1_PORTB


    ldx #200        ; 120+ ms
    jsr Delay_ms

    rts

ILI_Write_Command:
    ; caller guarantees A is 8-bit on entry
    ; A has command

    LONGA OFF

    pha                     ; save command
    lda ili_VIA1_PORTB_SHADOW
    ; and #(.NOT.ILI_CD)      ; CD low
    and #%11111011
    sta ili_VIA1_PORTB_SHADOW
    sta >VIA1_PORTB
    pla                     ; retrive command

    sta >VIA1_PORTA         ; put the data on the data bus to the ILI
    jsr ILI_Pulse_WR

    rts

ILI_Write_Data_Byte:
    ; caller guarantees A is 8-bit on entry
    ; A has data

    LONGA OFF

    pha                     ; save data
    lda ili_VIA1_PORTB_SHADOW
	ora #ILI_CD             ; CD high
    sta ili_VIA1_PORTB_SHADOW
    sta >VIA1_PORTB    
    pla                     ; retrive data

    sta >VIA1_PORTA         ; put the data on the data bus to the ILI
    jsr ILI_Pulse_WR

    rts

ILI_Pulse_WR:
    ; caller guarantees A is 8-bit on entry

    LONGA OFF
    pha
    lda ili_VIA1_PORTB_SHADOW
    ;and #(.NOT.ILI_WR)      ; WR low
    and #%11111101
    sta ili_VIA1_PORTB_SHADOW
    sta >VIA1_PORTB

	ora #ILI_WR             ; WR high
    sta ili_VIA1_PORTB_SHADOW
    sta >VIA1_PORTB 

    pla
    rts

ILI_Draw_Pixel:
    ; caller guarantees A is 16-bit on entry
    ; ili_color is 16-bit color
    ; ili_setaddrwindow_startX (16-bit) & ili_setaddrwindow_startY (16-bit) for pixel location

    ; ***! BUG in my code -start x,y cannot be equal to end x,y

    LONGA ON

    ;lda ili_setaddrwindow_startX
    ;sta ili_setaddrwindow_endX
    ;lda ili_setaddrwindow_startY
    ;sta ili_setaddrwindow_endY
    jsr ILI_Set_Address_Window

	sep #$20		; 8-bit A
    LONGA OFF
    
    lda ili_color+1
    jsr ILI_Write_Data_Byte
    lda ili_color
    jsr ILI_Write_Data_Byte

    rep #$20		; 16-bit A
    LONGA ON

    rts

ILI_Clear_Screen:
    ; caller guarantees A is 16-bit on entry

    LONGA ON            ; 16-bit A

    lda #0
    sta ili_setaddrwindow_startX
    sta ili_setaddrwindow_startY

    lda #479
    sta ili_setaddrwindow_endX

    lda #319
    sta ili_setaddrwindow_endY

    jsr ILI_Set_Address_Window

    sep #$20            ; 8-bit A
    LONGA OFF
    
    ldy #320            ; # rows

    RowLoop:
        ldx #480        ; # columns

        PixelLoop:
            lda #0      ; black $0000
            jsr ILI_Write_Data_Byte
            jsr ILI_Write_Data_Byte

            dex
            bne PixelLoop

                dey
                bne RowLoop

        rep #$20
        LONGA ON

        rts

ILI_Test_Pattern:
    ; caller guarantees A is 16-bit on entry
    LONGA ON

    ; red rectangle
    lda #20
    sta ili_setaddrwindow_startX
    lda #20
    sta ili_setaddrwindow_startY
    lda #460
    sta ili_setaddrwindow_endX
    lda #40
    sta ili_setaddrwindow_endY
    lda #%1111100000000000			; pixel color RGB565
    sta ili_color
    jsr ILI_Draw_Rectangle

    ; green rectangle
    lda #20
    sta ili_setaddrwindow_startX
    lda #50
    sta ili_setaddrwindow_startY
    lda #460
    sta ili_setaddrwindow_endX
    lda #70
    sta ili_setaddrwindow_endY
    lda #%0000011111100000			; pixel color RGB565
    sta ili_color
    jsr ILI_Draw_Rectangle

    ; blue rectangle
    lda #20
    sta ili_setaddrwindow_startX
    lda #80
    sta ili_setaddrwindow_startY
    lda #460
    sta ili_setaddrwindow_endX
    lda #100
    sta ili_setaddrwindow_endY
    lda #%0000000000011111			; pixel color RGB565
    sta ili_color
    jsr ILI_Draw_Rectangle

    ; white rectangle
    lda #20
    sta ili_setaddrwindow_startX
    lda #110
    sta ili_setaddrwindow_startY
    lda #460
    sta ili_setaddrwindow_endX
    lda #130
    sta ili_setaddrwindow_endY
    lda #%1111111111111111			; pixel color RGB565
    sta ili_color
    jsr ILI_Draw_Rectangle

ILI_Draw_Rectangle:
    ; caller guarantees A is 16-bit on entry
    
    ; These should be filled prior to calling routine:
    ;   ili_setaddrwindow_startX
    ;   ili_setaddrwindow_startY
    ;   ili_setaddrwindow_endX
    ;   ili_setaddrwindow_endY
    ;   ili_color (16-bit RGB565)

    LONGA ON                        ; 16-bit A

    jsr ILI_Set_Address_Window

    ; calculate width & height
    lda ili_setaddrwindow_endX
    sec
    sbc ili_setaddrwindow_startX
    inc
    sta ili_rect_width                  ; 16-bit

    lda ili_setaddrwindow_endY
    sec
    sbc ili_setaddrwindow_startY
    inc
    sta ili_rect_height                 ; 16-bit

    sep #$20
    LONGA OFF

    ldy ili_rect_height

    ilidr_RowLoop:
        ldx ili_rect_width

        ilidr_PixelLoop:
            ; write one pixel (2 bytes)
            lda ili_color+1             ; high byte
            jsr ILI_Write_Data_Byte
            lda ili_color               ; low byte
            jsr ILI_Write_Data_Byte

            dex
            bne ilidr_PixelLoop

            dey
            bne ilidr_RowLoop

            rep #$20
            LONGA ON

            rts

ILI_Animated_Ship:
    ; caller guarantees A is 16-bit on entry
    LONGA ON
    LONGI ON

    ; starting position
    lda #0
    sta ili_ship_sprite_x

    lda #180
    sta ili_ship_sprite_y

    ship_anim_loop:

        ; draw one frame at current X,Y
        jsr ILI_Draw_Ship_Once

        ; move X by +3
        lda ili_ship_sprite_x
        clc
        adc #3
        sta ili_ship_sprite_x

        ; stop when X >= 440   (40 px short of right edge)
        cmp #440
        bcc ship_anim_loop     ; loop while X < 440

        ; Draw black 32x32 rectangle over final ship position
        ; startX = final ship X
        lda ili_ship_sprite_x
        sta ili_setaddrwindow_startX

        ; startY = final ship Y
        lda ili_ship_sprite_y
        sta ili_setaddrwindow_startY

        ; endX = startX + 31
        lda ili_ship_sprite_x
        clc
        adc #31
        sta ili_setaddrwindow_endX

        ; endY = startY + 31
        lda ili_ship_sprite_y
        clc
        adc #31
        sta ili_setaddrwindow_endY

        ; black RGB565 = 0x0000
        lda #$0000
        sta ili_color

        jsr ILI_Draw_Rectangle

        rts

ILI_Draw_Ship_Once:
    ; caller guarantees A is 16-bit on entry

    LONGA ON
    LONGI ON

    pha
    phx
    phy

    ; --------------------------------------------------------
    ; Set 32x32 window
    ; --------------------------------------------------------
    lda ili_ship_sprite_x
    sta ili_setaddrwindow_startX
    clc
    adc #31
    sta ili_setaddrwindow_endX

    lda ili_ship_sprite_y
    sta ili_setaddrwindow_startY
    clc
    adc #31
    sta ili_setaddrwindow_endY

    jsr ILI_Set_Address_Window     ; sends CASET + PASET

    ; --------------------------------------------------------
    ; Stream 1024 bytes of sprite data
    ; --------------------------------------------------------
    ldx #0                      ; X = pixel index 0..1023

    ship_stream_loop:

        ; --------------------------------------------------------
        ; Load RGB332 sprite byte
        ; --------------------------------------------------------
        sep #$20
        LONGA OFF

        lda $E000, X             ; read sprite byte

        ; no color mapping -- just slam RGB332 into RGB565 high byte and again into low byte
        jsr ILI_Write_Data_Byte    ; high byte first
        jsr ILI_Write_Data_Byte

        ; --------------------------------------------------------
        ; Next pixel
        ; --------------------------------------------------------
        inx
        cpx #1024
        bne ship_stream_loop

        rep #$20
        LONGA ON

        ply
        plx
        pla
        rts

ILI_Write_Data_Word:
    ; caller guarantees A/X/Y are 16-bit on entry
    ; Writes the same 16-bit color pixel X*Y times
    ; A has 16-bit color data
    ; X is number pixels wide
    ; Y is number pixels tall
    
    LONGA ON
    LONGI ON    

    pha                     ; save color


	sep #$20		        ; 8-bit A   
    LONGA OFF 
    lda ili_VIA1_PORTB_SHADOW
	ora #ILI_CD             ; CD high
    sta ili_VIA1_PORTB_SHADOW
    sta >VIA1_PORTB    
    rep #$20		        ; 16-bit A
    LONGA ON
    pla                     ; retrive color
    pha                     ; save color again

    Outer_Loop:             ; Y loop (height)
        phx                 ; save width counter

    Inner_Loop:             ; X loop (width)
        pla                 ; get color
        pha                 ; keep it on stack

        ; --- send high byte ---
        xba
	    sep #$20		    ; 8-bit A    
        LONGA OFF
        sta >VIA1_PORTA     ; put data on the data base to the ILI
        jsr ILI_Pulse_WR
        rep #$20		    ; 16-bit A
        LONGA ON

        ; --- send low byte ---
        xba
	    sep #$20		    ; 8-bit A    
        LONGA OFF
        sta >VIA1_PORTA     ; put data on the data base to the ILI
        jsr ILI_Pulse_WR
        rep #$20		    ; 16-bit A
        LONGA ON
        dex
        bne Inner_Loop

        plx                 ; restore width
        dey
        bne Outer_Loop

        pla                 ; final pop of color
        rts

ILI_Set_Address_Window:
    ; caller guarantees A is 16-bit on entry

    ; ili_setaddrwindow_startX (16-bit)
	; ili_setaddrwindow_startY (16-bit)
	; ili_setaddrwindow_endX (16-bit)
	; ili_setaddrwindow_endY (16-bit)
    
    sep #$20		; 8-bit A
    LONGA OFF

    lda #$2a                            ; Column Address Set (CASET) - horizontal drawing range
    jsr ILI_Write_Command

    lda ili_setaddrwindow_startX+1       ; high byte
    jsr ILI_Write_Data_Byte
    lda ili_setaddrwindow_startX       ; low byte
    jsr ILI_Write_Data_Byte

    lda ili_setaddrwindow_endX+1         ; high byte
    jsr ILI_Write_Data_Byte
    lda ili_setaddrwindow_endX         ; low byte
    jsr ILI_Write_Data_Byte

    lda #$2b                            ; Row Address Set (PASET) - vertical drawing range
    jsr ILI_Write_Command

    lda ili_setaddrwindow_startY+1       ; high byte
    jsr ILI_Write_Data_Byte
    lda ili_setaddrwindow_startY       ; low byte
    jsr ILI_Write_Data_Byte

    lda ili_setaddrwindow_endY+1         ; high byte
    jsr ILI_Write_Data_Byte
    lda ili_setaddrwindow_endY         ; low byte
    jsr ILI_Write_Data_Byte

    lda #$2c
    jsr ILI_Write_Command
    
    ; *** DUMMY WRITE - not needed for this ILI? ***
    lda #$00
    jsr ILI_Write_Data_Byte
    lda #$00
    jsr ILI_Write_Data_Byte


    rep #$20		; 16-bit A
    LONGA ON


    rts


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LONGA ON
    LONGI ON