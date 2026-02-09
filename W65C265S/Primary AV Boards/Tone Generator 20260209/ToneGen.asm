	; TG0 on pin 94 of QFP-100 - using a piezoelectric speaker through a 2N3904 (see schematic)
	; TG1 on pin 95 of QFP-100 - not currently used
    ; BCR1 enables TG0
    ; BCR2 enables TG1
    ; TG0 uses Timer T5
    ; TG1 uses Timer T6
    ; Mensch monitor TG code at https://github.com/WesternDesignCenter/W65C265S-Internal-ROM-Monitor/blob/main/R_TONES.ASM


    LONGI	ON
	LONGA	ON
    
play_tone_startup_start:
        ; caller guarantees A/X are 16-bit on entry
    pha
    phx
    
    ; using middle A (A4) = 440 Hz = MIDI note 69 (#MIDI_A4) = timer value 0x058B
    ; play the note three times, with a short delay between each, using different methods to set the frequency each time

    ; set frequency using direct timer value, then delay, then disable
    lda #$058B          ; 16-bit timer value - higher value results in lower frequency
    ldx #100            ; number of milliseconds to play tone
    jsr TG0_play_tone    ; set frequency, delay, and start playing
    jsr TG0_disable      ; stop playing

    ldx #50         
    jsr Delay_ms        ; no sound delay between tones

    ; set frequency using Get_TimerVal16_FromFreq with frequency in Hz, then delay, then disable
    lda #440            ; target frequency
    jsr Get_TimerVal16_FromFreq     ; convert frequency to timer value
    ldx #50
    jsr TG0_play_tone    ; change frequency, delay
    jsr TG0_disable      ; stop playing

    ldx #50         
    jsr Delay_ms            ; no sound delay between tones

    ; set frequency using Get_TimerVal16_FromMidi with MIDI note number, then delay, then disable
    lda #MIDI_A4            ; MIDI note number (69)
    jsr Get_TimerVal16_FromMidi     ; convert Midi note to timer value
    ldx #50
    jsr TG0_play_tone       ; change frequency, delay
    jsr TG0_disable         ; stop playing

    plx
    pla
    rts

play_tone_startup_complete:
    ; caller guarantees A/X are 16-bit on entry
    
    pha
    phx
    
    lda #$02FF          ; 16-bit timer value - higher value results in lower frequency
    ldx #100            ; number of milliseconds to play tone
    jsr TG0_play_tone    ; set frequency, delay, and start playing

    lda #$01FF
    ldx #100
    jsr TG0_switch_tone  ; change frequency, delay

    lda #$00FF
    ldx #200
    jsr TG0_switch_tone  ; change frequency, delay

    jsr TG0_disable      ; stop playing

    plx
    pla
    rts

TG0_enable:
    sep #$20        ; 8-bit A
    LONGA OFF

    lda #%00100000
    tsb TER		; enable timer 5 which is used by TG0 (265 datasheet page 20)
    lda #%00000010
    tsb BCR		; enable TG0 (265 datasheet page 17)
    
    LONGA ON
    rep #$20		; 16-bit A

    rts

TG0_disable:
    sep #$20        ; 8-bit A
    LONGA OFF
    
    lda #%00000010
    trb BCR		; disable TG0 (265 datasheet page 17)
    lda #%00100000
    trb TER		; disable timer 5 (265 datasheet page 20)

    LONGA ON
    rep #$20		; 16-bit A

    rts

TG0_play_tone:
    ; caller guarantees A/X are 16-bit on entry
    ; A as 16-bit timer value - a higher value will result in a lower frequency
    ; X as number of milliseconds to play tone (approximate), given 10 Mhz PHI2

    sta T5CL        ; 16-bit store, which writes the high byte to T5CH
    jsr TG0_enable
    jsr Delay_ms    ; delay in ms stored in X

    rts

TG0_switch_tone:
    ; caller guarantees A/X are 16-bit on entry
    ; A as 16-bit timer value - higher value results in lower frequency
    ; X as number of milliseconds to play tone (approximate), given 10 Mhz PHI2

    sta T5CL   
    jsr Delay_ms    ; delay in ms stored in X

    rts

Get_TimerVal16_FromFreq:
    ; A = desired frequency (16-bit)
    ; Returns A = timer value N = (625000 / F) - 1
    ; Based on 10 MHz PHI2 clock
    ; See '265 datasheet page 35 for timer frequency calculation
    
    ; Save frequency (the divisor)
    sta Divisor

    ; Load 625000 into 32-bit dividend
    lda  #$8968        ; Correct low 16 bits
    sta  Dividend
    lda  #$0009        ; High 16 bits
    sta  Dividend+2


    jsr  Div32by16     ; quotient = Dividend / Divisor

    ; quotient is now in Dividend (low 16 bits)
    lda  Dividend
    dec                ; subtract 1 → final timer value
    rts

Get_TimerVal16_FromMidi:
    ; A = desired MIDI note number (0..127) - can use MIDI_ equs
    ; Returns A = timer value N for given MIDI note
    ; Uses FreqTable (integer Hz values)

    asl                 ; ×2 for word index
    tax                 ; X = index into FreqTable

    lda FreqTable,x     ; load 16-bit frequency
    jsr Get_TimerVal16_FromFreq
    ; A now holds timer value

    rts

Play_Midi_Sequence:
    ; could make this dynamic by passing in a pointer to the song data
    phx
    phy
    ldy #0              ; Start at the beginning of the table

    NextNote:
        lda SongData,y    ; Load MIDI note number
        cmp #$FFFF          ; Is it the end of the song?
        beq SongDone        ; Yes, exit

        ; --- Check for Rest ($0000) ---
        cmp #$0000          ; Is this a rest?
        beq HandleRest      ; If so, skip the noise

        ; --- Play Actual Note ---
        jsr Get_TimerVal16_FromMidi  ; Convert MIDI to timer value
        
        ; Get duration from next word
        phy                 ; Save Y because we need to look ahead
        iny
        iny                 
        ldx SongData,y    ; Load duration into X
        ply                 ; Restore Y
        
        jsr TG0_play_tone   ; Start tone and delay
        jsr TG0_disable     ; Stop tone
        bra MoveToNext

    HandleRest:
        ; Get duration from next word
        phy
        iny
        iny
        ldx SongData,y    ; Load duration into X
        ply
        
        jsr Delay_ms        ; Just wait, don't enable the speaker

    MoveToNext:
        ; Always small silence (10ms) to separate notes
        ldx #10
        jsr Delay_ms        ;

        iny
        iny                 ; Skip note
        iny
        iny                 ; Skip duration
        bra NextNote

    SongDone:
        ply
        plx
        rts
        
Play_Midi_Sequence2:
    ; could make this dynamic by passing in a pointer to the song data
    phx
    phy
    ldy #0              ; Start at the beginning of the table

    NextNote2:
        lda SongData2,y    ; Load MIDI note number
        cmp #$FFFF          ; Is it the end of the song?
        beq SongDone2        ; Yes, exit

        ; --- Check for Rest ($0000) ---
        cmp #$0000          ; Is this a rest?
        beq HandleRest2      ; If so, skip the noise

        ; --- Play Actual Note ---
        jsr Get_TimerVal16_FromMidi  ; Convert MIDI to timer value
        
        ; Get duration from next word
        phy                 ; Save Y because we need to look ahead
        iny
        iny                 
        ldx SongData2,y    ; Load duration into X
        ply                 ; Restore Y
        
        jsr TG0_play_tone   ; Start tone and delay
        jsr TG0_disable     ; Stop tone
        bra MoveToNext2

    HandleRest2:
        ; Get duration from next word
        phy
        iny
        iny
        ldx SongData2,y    ; Load duration into X
        ply
        
        jsr Delay_ms        ; Just wait, don't enable the speaker

    MoveToNext2:
        ; Always small silence (10ms) to separate notes
        ldx #10
        jsr Delay_ms        ;

        iny
        iny                 ; Skip note
        iny
        iny                 ; Skip duration
        bra NextNote2

    SongDone2:
        ply
        plx
        rts
 
 Div32by16:
    ; Dividend (4 bytes), Divisor (2 bytes), Remainder (2 bytes)
    stz  Remainder     ; clear remainder
    ldx  #32           ; 32 bits to process

    DivLoop:
        ; Shift 32-bit Dividend and 16-bit Remainder left as one unit
        asl  Dividend      ; Shift low word
        rol  Dividend+2    ; Shift high word (receives carry bit from low Word)
        rol  Remainder     ; Shift remainder (receives carry bit from high Word)

        ; Try subtracting
        lda  Remainder
        cmp  Divisor
        bcc  NoSubtract    ; If Remainder < Divisor, skip

        sbc  Divisor       ; Subtract Divisor (Carry is already set)
        sta  Remainder
        inc  Dividend      ; Set the quotient bit in the Dividend

    NoSubtract:
        dex
        bne  DivLoop
        rts

; MIDI note numbers (0..127) for reference
    MIDI_REST:   equ     $0000
    MIDI_END:    equ     $FFFF

    MIDI_C0:     equ     12
    MIDI_Cs0:    equ     13
    MIDI_Db0:    equ     13
    MIDI_D0:     equ     14
    MIDI_Ds0:    equ     15
    MIDI_Eb0:    equ     15
    MIDI_E0:     equ     16
    MIDI_F0:     equ     17
    MIDI_Fs0:    equ     18
    MIDI_Gb0:    equ     18
    MIDI_G0:     equ     19
    MIDI_Gs0:    equ     20
    MIDI_Ab0:    equ     20
    MIDI_A0:     equ     21
    MIDI_As0:    equ     22
    MIDI_Bb0:    equ     22
    MIDI_B0:     equ     23

    MIDI_C1:     equ     24
    MIDI_Cs1:    equ     25
    MIDI_Db1:    equ     25
    MIDI_D1:     equ     26
    MIDI_Ds1:    equ     27
    MIDI_Eb1:    equ     27
    MIDI_E1:     equ     28
    MIDI_F1:     equ     29
    MIDI_Fs1:    equ     30
    MIDI_Gb1:    equ     30
    MIDI_G1:     equ     31
    MIDI_Gs1:    equ     32
    MIDI_Ab1:    equ     32
    MIDI_A1:     equ     33
    MIDI_As1:    equ     34
    MIDI_Bb1:    equ     34
    MIDI_B1:     equ     35

    MIDI_C2:     equ     36
    MIDI_Cs2:    equ     37
    MIDI_Db2:    equ     37
    MIDI_D2:     equ     38
    MIDI_Ds2:    equ     39
    MIDI_Eb2:    equ     39
    MIDI_E2:     equ     40
    MIDI_F2:     equ     41
    MIDI_Fs2:    equ     42
    MIDI_Gb2:    equ     42
    MIDI_G2:     equ     43
    MIDI_Gs2:    equ     44
    MIDI_Ab2:    equ     44
    MIDI_A2:     equ     45
    MIDI_As2:    equ     46
    MIDI_Bb2:    equ     46
    MIDI_B2:     equ     47

    MIDI_C3:     equ     48
    MIDI_Cs3:    equ     49
    MIDI_Db3:    equ     49
    MIDI_D3:     equ     50
    MIDI_Ds3:    equ     51
    MIDI_Eb3:    equ     51
    MIDI_E3:     equ     52
    MIDI_F3:     equ     53
    MIDI_Fs3:    equ     54
    MIDI_Gb3:    equ     54
    MIDI_G3:     equ     55
    MIDI_Gs3:    equ     56
    MIDI_Ab3:    equ     56
    MIDI_A3:     equ     57
    MIDI_As3:    equ     58
    MIDI_Bb3:    equ     58
    MIDI_B3:     equ     59

    MIDI_C4:     equ     60
    MIDI_Cs4:    equ     61
    MIDI_Db4:    equ     61
    MIDI_D4:     equ     62
    MIDI_Ds4:    equ     63
    MIDI_Eb4:    equ     63
    MIDI_E4:     equ     64
    MIDI_F4:     equ     65
    MIDI_Fs4:    equ     66
    MIDI_Gb4:    equ     66
    MIDI_G4:     equ     67
    MIDI_Gs4:    equ     68
    MIDI_Ab4:    equ     68
    MIDI_A4:     equ     69
    MIDI_As4:    equ     70
    MIDI_Bb4:    equ     70
    MIDI_B4:     equ     71

    MIDI_C5:     equ     72
    MIDI_Cs5:    equ     73
    MIDI_Db5:    equ     73
    MIDI_D5:     equ     74
    MIDI_Ds5:    equ     75
    MIDI_Eb5:    equ     75
    MIDI_E5:     equ     76
    MIDI_F5:     equ     77
    MIDI_Fs5:    equ     78
    MIDI_Gb5:    equ     78
    MIDI_G5:     equ     79
    MIDI_Gs5:    equ     80
    MIDI_Ab5:    equ     80
    MIDI_A5:     equ     81
    MIDI_As5:    equ     82
    MIDI_Bb5:    equ     82
    MIDI_B5:     equ     83

    MIDI_C6:     equ     84
    MIDI_Cs6:    equ     85
    MIDI_Db6:    equ     85
    MIDI_D6:     equ     86
    MIDI_Ds6:    equ     87
    MIDI_Eb6:    equ     87
    MIDI_E6:     equ     88
    MIDI_F6:     equ     89
    MIDI_Fs6:    equ     90
    MIDI_Gb6:    equ     90
    MIDI_G6:     equ     91
    MIDI_Gs6:    equ     92
    MIDI_Ab6:    equ     92
    MIDI_A6:     equ     93
    MIDI_As6:    equ     94
    MIDI_Bb6:    equ     94
    MIDI_B6:     equ     95

    MIDI_C7:     equ     96
    MIDI_Cs7:    equ     97
    MIDI_Db7:    equ     97
    MIDI_D7:     equ     98
    MIDI_Ds7:    equ     99
    MIDI_Eb7:    equ     99
    MIDI_E7:     equ    100
    MIDI_F7:     equ    101
    MIDI_Fs7:    equ    102
    MIDI_Gb7:    equ    102
    MIDI_G7:     equ    103
    MIDI_Gs7:    equ    104
    MIDI_Ab7:    equ    104
    MIDI_A7:     equ    105
    MIDI_As7:    equ    106
    MIDI_Bb7:    equ    106
    MIDI_B7:     equ    107

    MIDI_C8:     equ    108
    MIDI_Cs8:    equ    109
    MIDI_Db8:    equ    109
    MIDI_D8:     equ    110
    MIDI_Ds8:    equ    111
    MIDI_Eb8:    equ    111
    MIDI_E8:     equ    112
    MIDI_F8:     equ    113
    MIDI_Fs8:    equ    114
    MIDI_Gb8:    equ    114
    MIDI_G8:     equ    115
    MIDI_Gs8:    equ    116
    MIDI_Ab8:    equ    116
    MIDI_A8:     equ    117
    MIDI_As8:    equ    118
    MIDI_Bb8:    equ    118
    MIDI_B8:     equ    119

    MIDI_C9:     equ    120
    MIDI_Cs9:    equ    121
    MIDI_Db9:    equ    121
    MIDI_D9:     equ    122
    MIDI_Ds9:    equ    123
    MIDI_Eb9:    equ    123
    MIDI_E9:     equ    124
    MIDI_F9:     equ    125
    MIDI_Fs9:    equ    126
    MIDI_Gb9:    equ    126
    MIDI_G9:     equ    127

; MIDI note number to integer frequency (Hz)
    FreqTable:
    ; frequency values for MIDI notes 0..127, calculated as round(440 * 2^((n-69)/12)) for n=0..127
    .word 8,   9,   9,  10,  10,  11,  12,  12
    .word 13,  14,  15,  15,  16,  17,  18,  19
    .word 21,  22,  23,  25,  26,  28,  29,  31
    .word 33,  35,  37,  39,  41,  44,  46,  49
    .word 52,  55,  58,  62,  65,  69,  73,  78
    .word 82,  87,  92,  98, 103, 110, 116, 123
    .word 130, 138, 146, 155, 164, 174, 185, 196
    .word 207, 220, 233, 246, 261, 277, 293, 311
    .word 329, 349, 369, 392, 415, 440, 466, 493
    .word 523, 554, 587, 622, 659, 698, 739, 783
    .word 830, 880, 932, 987,1046,1108,1174,1244
    .word 1318,1396,1479,1567,1661,1760,1864,1975
    .word 2093,2217,2349,2489,2637,2793,2959,3135
    .word 3322,3520,3729,3951,4186,4434,4698,4978
    .word 5274,5587,5919,6271,6644,7040,7458,7902
    .word 8372,8869,9397,9956,10548,11175,11839,12543

SongData:
    ; --- Mario ---
    .word MIDI_E5, 125    ; Note, Duration
    .word MIDI_E5, 125
    .word MIDI_REST, 125  ; Rest
    .word MIDI_E5, 125
    .word MIDI_REST, 125  ; Rest
    .word MIDI_C5, 125
    .word MIDI_E5, 125
    .word MIDI_REST, 125  ; Rest
    .word MIDI_G5, 250
    .word MIDI_REST, 250  ; Rest
    .word MIDI_G4, 250
    .word MIDI_REST, 250  ; Rest

    ; --- Section A ---
    .word MIDI_C5, 250
    .word MIDI_REST, 125
    .word MIDI_G4, 250
    .word MIDI_REST, 125
    .word MIDI_E4, 250
    .word MIDI_REST, 125
    .word MIDI_A4, 250
    .word MIDI_B4, 250
    .word MIDI_As4, 125
    .word MIDI_A4, 250
    
    .word MIDI_G4, 160
    .word MIDI_E5, 160
    .word MIDI_G5, 160
    .word MIDI_A5, 250
    .word MIDI_F5, 125
    .word MIDI_G5, 125
    .word MIDI_REST, 125
    .word MIDI_E5, 250
    .word MIDI_C5, 125
    .word MIDI_D5, 125
    .word MIDI_B4, 250
    .word MIDI_REST, 125

    ; --- Section B ---
    .word MIDI_REST, 250
    .word MIDI_G5, 125
    .word MIDI_Fs5, 125
    .word MIDI_F5, 125
    .word MIDI_Ds5, 250
    .word MIDI_E5, 250
    .word MIDI_REST, 125
    .word MIDI_Gs4, 125
    .word MIDI_A4, 125
    .word MIDI_C5, 125
    .word MIDI_REST, 125
    .word MIDI_A4, 125
    .word MIDI_C5, 125
    .word MIDI_D5, 125

    .word MIDI_REST, 250
    .word MIDI_G5, 125
    .word MIDI_Fs5, 125
    .word MIDI_F5, 125
    .word MIDI_Ds5, 250
    .word MIDI_E5, 250
    .word MIDI_REST, 125
    .word MIDI_C6, 250
    .word MIDI_C6, 125
    .word MIDI_C6, 250
    
    .word MIDI_END        ; End of song marker

SongData2:
    ; Monkey Island - Opening Theme
    ; --- Phrase 1 ---
    .word MIDI_G4,  200
    .word MIDI_C5,  200
    .word MIDI_D5,  200
    .word MIDI_Eb5, 400
    .word MIDI_REST, 100
    .word MIDI_Eb5, 150
    .word MIDI_F5,  150
    .word MIDI_D5,  600
    
    .word MIDI_REST, 100
    .word MIDI_F4,  200
    .word MIDI_Bb4, 200
    .word MIDI_C5,  200
    .word MIDI_D5,  400
    .word MIDI_REST, 100
    .word MIDI_D5,  150
    .word MIDI_Eb5, 150
    .word MIDI_C5,  600

    ; --- Phrase 2 (The "Bouncy" part) ---
    .word MIDI_REST, 200
    .word MIDI_G4,  200
    .word MIDI_C5,  200
    .word MIDI_D5,  200
    .word MIDI_Eb5, 300
    .word MIDI_D5,  150
    .word MIDI_C5,  150
    .word MIDI_D5,  600
    
    .word MIDI_REST, 100
    .word MIDI_G5,  400   ; High note jump!
    .word MIDI_F5,  200
    .word MIDI_Eb5, 200
    .word MIDI_D5,  200
    .word MIDI_C5,  200
    .word MIDI_B4,  400
    .word MIDI_C5,  800

    .word MIDI_END        ; $FFFF