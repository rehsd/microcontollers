; to do list:
; -use a pointer going into SP0256_SpeakString instead of hardcoding checks for specific phrases (would allow more phrases to be added without code changes)

; SP0256-AL2 Speech Synthesizer Control
; W65C265 with W65C22S (VIA2) controlling SP0256-AL2 speech synthesizer with 74HC595 shift register for Data byte
;
; http://www.bitsavers.org/components/gi/speech/General_Instrument_-_SP0256A-AL2_datasheet_(Radio_Shack_276-1784)_-_Apr1984.pdf
;
; PB7 → SP0256 LRQ (input)          ;256 pin 9
; PB6 → spare (set as intput)
; PB5 → spare (set as intput)
; PB4 → SP0256 RESET                '595 pin 10  -and- '0256 pin 9
; PB3 → SP0256 ALD                  ;256 pin 20
; PB2 → 74HC595 LATCH RCLK          '595 pin 12
; PB1 → 74HC595 SHIFT CLK           '595 pin 11
; PB0 → 74HC595 DATA                '595 pin 14


; Bit masks
PB_ALD      = %00001000      ; PB3
PB_RESET    = %00010000      ; PB4
PB_LRQ      = %10000000      ; PB7 (input)

.setting "RegA16", true
.setting "RegXY16", true

SP0256_Init:
    ; caller guarantees 16-bit A/X/Y

    sep #$20    ; 8-bit A
    .setting "RegA16", false
    

    ; Configure VIA2 Port B: PB0-PB4 as outputs, PB5-PB7 as inputs
    lda #%00011111          ; 0=input, 1=output
    sta VIA2_DDRB

    ; assert reset (active low)
    lda VIA2_PORTB
    and #~PB_RESET
    sta VIA2_PORTB

    jsr sp256_short_delay
    jsr sp256_short_delay
    jsr sp256_short_delay

    ; release reset
    lda VIA2_PORTB
    ora #PB_RESET
    sta VIA2_PORTB

    ; ensure ALD is high (idle)
    lda VIA2_PORTB
    ora #PB_ALD
    sta VIA2_PORTB

    wait_lrq:
        nop
        nop
        nop
        nop
        lda VIA2_PORTB
        and #PB_LRQ
        beq wait_lrq

        rep #$20    ; 16-bit A
        .setting "RegA16", true

        rts

SP0256_Send_Allophone:
    ;php
    ;sep #$20    ; 8-bit A
    .setting "RegA16", false

    tay             ; Y = allophone byte

    ; wait for LRQ = 0 (ready)
    @wait_lrq1:
        lda VIA2_PORTB
        and #PB_LRQ
        bne @wait_lrq1

        ; shift out 8 bits MSB→LSB into 74HC595
        ldx #8

    @shift_loop:
        ; clear PB0 (DATA = 0)
        lda VIA2_PORTB
        and #%11111110
        sta VIA2_PORTB

        ; test MSB of Y
        tya
        and #%10000000
        beq @bit_zero

    @bit_one:
        ; set PB0 = 1
        lda VIA2_PORTB
        ora #%00000001
        sta VIA2_PORTB
        nop
        nop
        nop
        nop

        bra @clock_bit

    @bit_zero:
        ; PB0 already 0
        nop
        nop
        nop
        nop
        nop


    @clock_bit:
        ; pulse SHIFT CLK (PB1)
        lda VIA2_PORTB
        ora #%00000010      ; PB1 = 1
        sta VIA2_PORTB
        nop
        nop
        nop
        nop

        lda VIA2_PORTB
        and #%11111101      ; PB1 = 0
        sta VIA2_PORTB

        ; shift Y left
        tya
        asl
        tay

        dex
        bne @shift_loop

        ; pulse LATCH (PB2)
        nop
        nop
        nop
        nop
        lda VIA2_PORTB
        ora #%00000100          ; PB2 = 1
        sta VIA2_PORTB
        nop
        nop
        nop
        nop

        lda VIA2_PORTB
        and #%11111011          ; PB2 = 0
        sta VIA2_PORTB
        nop
        nop
        nop
        nop

        ; pulse ALD (PB3)
        lda VIA2_PORTB
        and #~PB_ALD            ; PB3 = 0
        sta VIA2_PORTB
        nop
        nop
        nop
        nop

        lda VIA2_PORTB
        ora #PB_ALD             ; PB3 = 1
        sta VIA2_PORTB
        nop
        nop
        nop
        nop

        ; wait for LRQ = 0 again
        @wait_lrq2:
            nop
            nop
            nop
            nop
            lda VIA2_PORTB
            and #PB_LRQ
            bne @wait_lrq2

            ; restore 8/16-bit A
            ;plp
            rts

SP0256_Hello:
    .setting "RegA16", true
    .setting "RegXY16", true
    
    lda #<STR_SPEECH_HELLO
    sta Str_ptr
    lda #>STR_SPEECH_HELLO
    sta Str_ptr+1
    jsr ILI_Puts
    jsr ILI_New_Line

    ldx #PHRASE_HELLO
    jsr SP0256_SpeakString
    ldx #1000
    jsr Delay_ms
    
    lda #<STR_SPEECH_IAM
    sta Str_ptr
    lda #>STR_SPEECH_IAM
    sta Str_ptr+1
    jsr ILI_Puts
    jsr ILI_New_Line

    ldx #PHRASE_IAM
    jsr SP0256_SpeakString
    ldx #1000
    jsr Delay_ms
    
    lda #<STR_SPEECH_SHALL_WE
    sta Str_ptr
    lda #>STR_SPEECH_SHALL_WE
    sta Str_ptr+1
    jsr ILI_Puts
    jsr ILI_New_Line
    
    ldx #PHRASE_SHALLWE
    jsr SP0256_SpeakString
    ldx #1000
    jsr Delay_ms
    rts

SP0256_SpeakString:
    ; Caller guarantees 16-bit A/X/Y

    .setting "RegA16", true
    .setting "RegXY16", true
    cpx #PHRASE_HELLO
    bne @check_iam
        ldx #SP0256_HELLO_RICH
        bra @do_speak
    @check_iam:
        cpx #PHRASE_IAM
        bne @check_shallwe
        ldx #SP0256_I_AM_R265NIBBLER
        bra @do_speak
    @check_shallwe:
        cpx #PHRASE_SHALLWE
        bne @done
        ldx #SP0256_SHALL_WE_PLAY_A_GAME
    @do_speak:
        sep #$20
        .setting "RegA16", false
        ldy #0
    @next:
        lda $0000,x
        cmp #$FF
        beq @exit_8
        phy
        phx
        jsr SP0256_Send_Allophone
        jsr sp256_short_delay
        plx
        ply
        inx
        bra @next
    @exit_8:
        rep #$20
        .setting "RegA16", true
    @done:
        rts

sp256_short_delay:
    ; caller guarantees 8-bit A, 16-bit X/Y (only called internally)
    .setting "RegA16", false

    ldy #$ff
    @d1:
        ldx #$ff
    @d2:
        dex
        bne @d2
        dey
        bne @d1

        .setting "RegA16", true

        rts

SP0256_PHRASES:
    PHRASE_HELLO    = 1
    PHRASE_IAM      = 2
    PHRASE_SHALLWE  = 3

SP0256_HELLO_RICH:
    .byte ALLO_HH1, ALLO_EH, ALLO_LL, ALLO_OW
    .byte ALLO_PA3
    .byte ALLO_RR2, ALLO_IH, ALLO_CH
    .byte ALLO_PA4
    .byte ALLO_END

SP0256_I_AM_R265NIBBLER:
    .byte ALLO_AY                           ; I
    .byte ALLO_PA1
    .byte ALLO_AE, ALLO_MM, ALLO_AX        ; am
    .byte ALLO_PA4
    .byte ALLO_AR                           ; R
    .byte ALLO_PA2
    .byte ALLO_TT2, ALLO_UW1                ; two
    .byte ALLO_PA2
    .byte ALLO_SS, ALLO_IH, ALLO_KK2, ALLO_SS, ALLO_TT2, ALLO_IY   ; sixty
    .byte ALLO_PA2
    .byte ALLO_FF, ALLO_AY, ALLO_VV                               ; five
    .byte ALLO_PA2
    .byte ALLO_NN2, ALLO_IH, ALLO_BB1, ALLO_LL, ALLO_ER1          ; nibbler
    .byte ALLO_PA4
    .byte ALLO_END

SP0256_SHALL_WE_PLAY_A_GAME:
    .byte ALLO_SH, ALLO_AE, ALLO_LL
    .byte ALLO_PA2
    .byte ALLO_WW, ALLO_IY
    .byte ALLO_PA2
    .byte ALLO_PP, ALLO_LL, ALLO_EY
    .byte ALLO_PA2
    .byte ALLO_AX
    .byte ALLO_PA1
    .byte ALLO_GG1, ALLO_PA1, ALLO_EY, ALLO_MM, ALLO_AX
    .byte ALLO_PA4
    .byte ALLO_END

SP0256_ALLPHONES:
    ; SP0256A-AL2 Allophone Codes (from datasheet, plus 0xFF = end of string)  
    ALLO_END        = $FF    ; End of string (not an actual allophone)  
    ALLO_PA1        = 0     ; PAUSE 10ms
    ALLO_PA2        = 1     ; PAUSE 30ms
    ALLO_PA3        = 2     ; PAUSE 50ms
    ALLO_PA4        = 3     ; PAUSE 100ms
    ALLO_PA5        = 4     ; PAUSE 200ms
    ALLO_OY         = 5     ; Boy
    ALLO_AY         = 6     ; Sky
    ALLO_EH         = 7     ; End
    ALLO_KK3        = 8     ; Comb
    ALLO_PP         = 9     ; Pow
    ALLO_JH         = 10    ; Dodge
    ALLO_NN1        = 11    ; Thin
    ALLO_IH         = 12    ; Sit
    ALLO_TT2        = 13    ; To
    ALLO_RR1        = 14    ; Rural
    ALLO_AX         = 15    ; Succeed
    ALLO_MM         = 16    ; Milk
    ALLO_TT1        = 17    ; Part
    ALLO_DH1        = 18    ; They
    ALLO_IY         = 19    ; See
    ALLO_EY         = 20    ; Beige
    ALLO_DD1        = 21    ; Could
    ALLO_UW1        = 22    ; To
    ALLO_AO         = 23    ; Aught
    ALLO_AA         = 24    ; Hot
    ALLO_YY2        = 25    ; Yes
    ALLO_AE         = 26    ; Hat
    ALLO_HH1        = 27    ; He
    ALLO_BB1        = 28    ; Business
    ALLO_TH         = 29    ; Thin
    ALLO_UH         = 30    ; Book
    ALLO_UW2        = 31    ; Food
    ALLO_AW         = 32    ; Out
    ALLO_DD2        = 33    ; Do
    ALLO_GG3        = 34    ; Wig
    ALLO_VV         = 35    ; Vest
    ALLO_GG1        = 36    ; Got
    ALLO_SH         = 37    ; Ship
    ALLO_ZH         = 38    ; Azure
    ALLO_RR2        = 39    ; Brain
    ALLO_FF         = 40    ; Food
    ALLO_KK2        = 41    ; Sky
    ALLO_KK1        = 42    ; Can't
    ALLO_ZZ         = 43    ; Zoo
    ALLO_NG         = 44    ; Anchor
    ALLO_LL         = 45    ; Lake
    ALLO_WW         = 46    ; Wool
    ALLO_XR         = 47    ; Repair
    ALLO_WH         = 48    ; Whig
    ALLO_YY1        = 49    ; Yes
    ALLO_CH         = 50    ; Church
    ALLO_ER1        = 51    ; Fir
    ALLO_ER2        = 52    ; Fir
    ALLO_OW         = 53    ; Beau
    ALLO_DH2        = 54    ; The
    ALLO_SS         = 55    ; Vest
    ALLO_NN2        = 56    ; No
    ALLO_HH2        = 57    ; Hoe
    ALLO_OR         = 58    ; Store
    ALLO_AR         = 59    ; Alarm
    ALLO_YR         = 60    ; Clear
    ALLO_GG2        = 61    ; Guest
    ALLO_EL         = 62    ; Saddle
    ALLO_BB2        = 63    ; Business