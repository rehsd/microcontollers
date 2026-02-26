	; TG0 on pin 94 of QFP-100 - using a piezoelectric speaker through a 2N3904 (see schematic)
	; TG1 on pin 95 of QFP-100 - not currently used
    ; BCR1 enables TG0
    ; BCR2 enables TG1
    ; TG0 uses Timer T5
    ; TG1 uses Timer T6
    ; Mensch monitor TG code at https://github.com/WesternDesignCenter/W65C265S-Internal-ROM-Monitor/blob/main/R_TONES.ASM


.setting "RegA16", true
.setting "RegXY16", true
    
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

play_tone_test_pass:
    ; caller guarantees A/X are 16-bit on entry
    
    pha
    phx
    
    lda #$0500          ; 16-bit timer value - higher value results in lower frequency
    ldx #200            ; number of milliseconds to play tone
    jsr TG0_play_tone    ; set frequency, delay, and start playing


    lda #$0300
    ldx #400
    jsr TG0_switch_tone  ; change frequency, delay

    jsr TG0_disable      ; stop playing

    plx
    pla
    rts

play_tone_test_fail:
    ; caller guarantees A/X are 16-bit on entry
    
    pha
    phx
    
    lda #$0500          ; 16-bit timer value - higher value results in lower frequency
    ldx #200            ; number of milliseconds to play tone
    jsr TG0_play_tone    ; set frequency, delay, and start playing


    lda #$0700
    ldx #400
    jsr TG0_switch_tone  ; change frequency, delay

    jsr TG0_disable      ; stop playing

    plx
    pla
    rts
TG0_enable:
    sep #$20        ; 8-bit A

    .setting "RegA16", false


    lda #%00100000
    tsb TER		; enable timer 5 which is used by TG0 (265 datasheet page 20)
    lda #%00000010
    tsb BCR		; enable TG0 (265 datasheet page 17)
    
    .setting "RegA16", true
    rep #$20		; 16-bit A

    rts

TG0_disable:
    sep #$20        ; 8-bit A
    .setting "RegA16", false
    
    lda #%00000010
    trb BCR		; disable TG0 (265 datasheet page 17)
    lda #%00100000
    trb TER		; disable timer 5 (265 datasheet page 20)

    .setting "RegA16", true
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
    MIDI_REST   =     $0000
    MIDI_END    =     $FFFF

    MIDI_C0     =     12
    MIDI_Cs0    =     13
    MIDI_Db0    =     13
    MIDI_D0     =     14
    MIDI_Ds0    =     15
    MIDI_Eb0    =     15
    MIDI_E0     =     16
    MIDI_F0     =     17
    MIDI_Fs0    =     18
    MIDI_Gb0    =     18
    MIDI_G0     =     19
    MIDI_Gs0    =     20
    MIDI_Ab0    =     20
    MIDI_A0     =     21
    MIDI_As0    =     22
    MIDI_Bb0    =     22
    MIDI_B0     =     23

    MIDI_C1     =     24
    MIDI_Cs1    =     25
    MIDI_Db1    =     25
    MIDI_D1     =     26
    MIDI_Ds1    =     27
    MIDI_Eb1    =     27
    MIDI_E1     =     28
    MIDI_F1     =     29
    MIDI_Fs1    =     30
    MIDI_Gb1    =     30
    MIDI_G1     =     31
    MIDI_Gs1    =     32
    MIDI_Ab1    =     32
    MIDI_A1     =     33
    MIDI_As1    =     34
    MIDI_Bb1    =     34
    MIDI_B1     =     35

    MIDI_C2     =     36
    MIDI_Cs2    =     37
    MIDI_Db2    =     37
    MIDI_D2     =     38
    MIDI_Ds2    =     39
    MIDI_Eb2    =     39
    MIDI_E2     =     40
    MIDI_F2     =     41
    MIDI_Fs2    =     42
    MIDI_Gb2    =     42
    MIDI_G2     =     43
    MIDI_Gs2    =     44
    MIDI_Ab2    =     44
    MIDI_A2     =     45
    MIDI_As2    =     46
    MIDI_Bb2    =     46
    MIDI_B2     =     47

    MIDI_C3     =     48
    MIDI_Cs3    =     49
    MIDI_Db3    =     49
    MIDI_D3     =     50
    MIDI_Ds3    =     51
    MIDI_Eb3    =     51
    MIDI_E3     =     52
    MIDI_F3     =     53
    MIDI_Fs3    =     54
    MIDI_Gb3    =     54
    MIDI_G3     =     55
    MIDI_Gs3    =     56
    MIDI_Ab3    =     56
    MIDI_A3     =     57
    MIDI_As3    =     58
    MIDI_Bb3    =     58
    MIDI_B3     =     59

    MIDI_C4     =     60
    MIDI_Cs4    =     61
    MIDI_Db4    =     61
    MIDI_D4     =     62
    MIDI_Ds4    =     63
    MIDI_Eb4    =     63
    MIDI_E4     =     64
    MIDI_F4     =     65
    MIDI_Fs4    =     66
    MIDI_Gb4    =     66
    MIDI_G4     =     67
    MIDI_Gs4    =     68
    MIDI_Ab4    =     68
    MIDI_A4     =     69
    MIDI_As4    =     70
    MIDI_Bb4    =     70
    MIDI_B4     =     71

    MIDI_C5     =     72
    MIDI_Cs5    =     73
    MIDI_Db5    =     73
    MIDI_D5     =     74
    MIDI_Ds5    =     75
    MIDI_Eb5    =     75
    MIDI_E5     =     76
    MIDI_F5     =     77
    MIDI_Fs5    =     78
    MIDI_Gb5    =     78
    MIDI_G5     =     79
    MIDI_Gs5    =     80
    MIDI_Ab5    =     80
    MIDI_A5     =     81
    MIDI_As5    =     82
    MIDI_Bb5    =     82
    MIDI_B5     =     83

    MIDI_C6     =     84
    MIDI_Cs6    =     85
    MIDI_Db6    =     85
    MIDI_D6     =     86
    MIDI_Ds6    =     87
    MIDI_Eb6    =     87
    MIDI_E6     =     88
    MIDI_F6     =     89
    MIDI_Fs6    =     90
    MIDI_Gb6    =     90
    MIDI_G6     =     91
    MIDI_Gs6    =     92
    MIDI_Ab6    =     92
    MIDI_A6     =     93
    MIDI_As6    =     94
    MIDI_Bb6    =     94
    MIDI_B6     =     95

    MIDI_C7     =     96
    MIDI_Cs7    =     97
    MIDI_Db7    =     97
    MIDI_D7     =     98
    MIDI_Ds7    =     99
    MIDI_Eb7    =     99
    MIDI_E7     =    100
    MIDI_F7     =    101
    MIDI_Fs7    =    102
    MIDI_Gb7    =    102
    MIDI_G7     =    103
    MIDI_Gs7    =    104
    MIDI_Ab7    =    104
    MIDI_A7     =    105
    MIDI_As7    =    106
    MIDI_Bb7    =    106
    MIDI_B7     =    107

    MIDI_C8     =    108
    MIDI_Cs8    =    109
    MIDI_Db8    =    109
    MIDI_D8     =    110
    MIDI_Ds8    =    111
    MIDI_Eb8    =    111
    MIDI_E8     =    112
    MIDI_F8     =    113
    MIDI_Fs8    =    114
    MIDI_Gb8    =    114
    MIDI_G8     =    115
    MIDI_Gs8    =    116
    MIDI_Ab8    =    116
    MIDI_A8     =    117
    MIDI_As8    =    118
    MIDI_Bb8    =    118
    MIDI_B8     =    119

    MIDI_C9     =    120
    MIDI_Cs9    =    121
    MIDI_Db9    =    121
    MIDI_D9     =    122
    MIDI_Ds9    =    123
    MIDI_Eb9    =    123
    MIDI_E9     =    124
    MIDI_F9     =    125
    MIDI_Fs9    =    126
    MIDI_Gb9    =    126
    MIDI_G9     =    127

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