; =============================================================================
; HARDWARE: Dual YM2149 (or AY-3-8910/8913) Programmable Sound Generators (PSG)
;           Interfaced with VIA 6522
; =============================================================================
; DESCRIPTION:
;   This file contains the core Audio Engine
;   It manages concurrent Background Music (BGM) and Sound Effects (SFX)
;   processing by communicating with two PSG chips.
;
; KEY FEATURES:
;   - Multi-Channel Support: Drives two PSG chips for a total of 6 voices.
;   - BGM Engine: Reads music data structures to play polyphonic tracks.
;   - SFX Engine: Provides high-priority sound effect triggers on top of music.
;   - Register Protection: Designed for compatibility with C-language callers
;     ensuring processor state (P), data bank (B), and direct page (D) 
;     preservation where necessary.
;
; INTERFACE:
;   - Init_Audio_Engine: Resets PSG registers and clears internal play flags.
;   - Music_Update: To be called by Timer 0 IRQ to process the next frame of music data.
;   - SFX_Update: Processes active sound effect envelopes and timers.
;
; TABLES:
;   - music_table: Pointers to XM/MIDI-converted song data.
;   - sfx_table:   Pointers to sound effect definitions (Jump, Coin, etc.).
; =============================================================================


Init_Audio_Engine:
    php
    sep #$30            ; 8-bit A/X/Y
    .setting "RegA16", false
    .setting "RegXY16", false

    ; 1. Stop engines and clear flags
    stz Music_Active    ; $AC
    stz SFX_Active      ; $AD
    stz Music_Wait      ; $A3
    stz SFX_Wait        ; $A7
    stz Audio_Prescale  ; $AE

    ; 2. Set VIA Data Direction
    lda #$ff
    sta VIA0_DDRA       
    sta VIA0_DDRB       

    ; 3. FULL SILENCE RESET (Registers 0-6 and 11-15)
    ldx #0
  @clear_loop:
    txa
    jsr PSG0_setreg
    jsr PSG1_setreg
    lda #0
    jsr PSG0_writedata
    jsr PSG1_writedata
    inx
    cpx #16
    bne @clear_loop

    ; 4. INITIALIZATION VALUES
    ; Match Register 7 ($38 = Tone A, B, C Enabled)
    lda #$07
    jsr PSG0_setreg
    jsr PSG1_setreg
    lda #$38
    jsr PSG0_writedata
    jsr PSG1_writedata

    ; Match Registers 8, 9, 10 ($0F = Max Fixed Volume)
    ldx #$08
  @vol_init:
    txa
    jsr PSG0_setreg
    jsr PSG1_setreg
    lda #$0F
    jsr PSG0_writedata
    jsr PSG1_writedata
    inx
    cpx #$0B            ; Loop through $08, $09, $0A
    bne @vol_init

    ; 5. Set Timer Mode (ACR)
    lda #$40            ; T1 Continuous
    sta VIA0_ACR

    ; 6. Enable the Interrupt (IER)
    lda #$c0            
    sta VIA0_IER

    ; 7. Load and START the timer ($A2C2) - ~88 Hz with 10 MHz PHI2
    lda #$C2
    sta VIA0_T1CL
    lda #$A2
    sta VIA0_T1CH

    plp
    rts

Audio_ISR:
    ; Called via JSR from the main IRQB handler
    ; Registers and Direct Page are already saved by the caller

    ; sep #$20 is handled by caller
    .setting "RegA16", false
    .setting "RegXY16", true

    ; Frequency Prescaler (~22 Hz)
    inc Audio_Prescale  
    lda Audio_Prescale
    and #$03            ; Mask for bits 0 and 1 (counts 0, 1, 2, 3)
    sta Audio_Prescale  ; SAVE it back so it stays within 0-3
    bne audio_isr_done  ; If not 0, skip music logic (runs 1 out of 4 times)

    ; --- Check Music ---
    lda Music_Active    ; Use flag instead of bank
    beq check_sfx       ; skip if no music playing
    
    lda Music_Wait
    beq music_update
    dec Music_Wait
    bra check_sfx
    
    music_update:
        jsr music_step
            
    check_sfx:
        ; --- Check Sound Effects ---
        lda SFX_Active      ; Use flag instead of bank
        beq audio_isr_done  ; skip if no sfx playing
            
        lda SFX_Wait
        beq sfx_update
        dec SFX_Wait
        bra audio_isr_done

    sfx_update:
        jsr sfx_step
            
    audio_isr_done:
        rts

music_step:
        ldy #0              ; Start at beginning of current pointer
    m_loop:
        lda [Music_PTR_LO], y
        cmp #$ff            ; End of Tune?
        beq m_stop
        
        cmp #$80            ; Is it a wait command ($80-$FE)?
        bcs m_delay         ; If so, branch to delay logic
        
        ; --- It's a register write ---
        sta SND_CMD         ; Store register index
        iny
        lda [Music_PTR_LO], y ; Load the DATA value
        sta SND_VAL         ; Store for debugging
        
        ; A contains the data value; call dispatcher
        jsr m_dispatch      
        
        iny                 ; Move to next command pair
        bra m_loop

    m_delay:
        and #$7f            ; Strip the high bit (e.g., $86 becomes 6)
        sta Music_Wait      ; Set the wait counter
        iny                 ; Advance Y past the delay byte
        bra m_update_ptr    ; Finalize pointer and EXIT

    m_stop:
        stz Music_Active
        stz Music_Wait
        ; Optional: insert silence routine here
        rts                 ; Pointer doesn't matter if Active=0

    m_update_ptr:
        ; This is critical: Update the 16-bit pointer so the 
        ; NEXT interrupt starts exactly where we left off.
        tya                 ; Number of bytes processed
        clc
        adc Music_PTR_LO
        sta Music_PTR_LO
        bcc m_done
        inc Music_PTR_HI
    m_done:
        rts

m_dispatch:
    lda SND_CMD
    cmp #$10            ; If register is $10 or higher, it's for PSG1
    bcs m_to_psg1
    
    ; --- PSG0 Handling ---
    jsr PSG0_setreg     ; Original routine: Latch the address in A
    lda SND_VAL
    jsr PSG0_writedata  ; Original routine: Write the data in A
    rts

m_to_psg1:
    and #$0f            ; Strip the $10 offset to get the 4-bit register index
    jsr PSG1_setreg     ; Original routine: Latch the address in A
    lda SND_VAL
    jsr PSG1_writedata  ; Original routine: Write the data in A
    rts

sfx_step:
    ; ****** SFX Stream Processor *******
    ldy #$00
    s_loop:
        lda [SFX_PTR_LO], y
        cmp #$ff            ; End of SFX?
        beq s_stop
        cmp #$80            ; Delay command?
        bcs s_delay
        
        sta SND_CMD         ; Store register address
        iny
        lda [SFX_PTR_LO], y
        sta SND_VAL         ; Store register value
        jsr s_dispatch
        iny
        bra s_loop

    s_delay:
        and #$7f
        sta SFX_Wait
        iny                 ; Move past the delay byte
        ; Fall through to pointer update

    s_update_ptr:
        tya                 ; Y = total bytes processed
        clc
        adc SFX_PTR_LO
        sta SFX_PTR_LO
        bcc s_done
        inc SFX_PTR_HI
        bne s_done
        inc SFX_PTR_Bank    ; Handle 64KB boundary crossing
    s_done:
        rts

    s_stop:
    stz SFX_Active      ; Stop the SFX engine
    bra s_update_ptr    ; Final pointer update

s_dispatch:             ; SFX always targets PSG1
    lda SND_CMD
    and #$0f            ; Ensure we only have the 4-bit register index
    jsr PSG1_setreg
    lda SND_VAL
    jsr PSG1_writedata
    rts

;PSG0 play:
    PSG0_PlayTune:
        ldy #0
    PSG0_play_loop:
        lda (TUNE_PTR_LO), Y
        cmp #$FF
        bne PSG0_play_next
        rts
    PSG0_play_next:
        jsr PSG0_setreg
        iny
        lda (TUNE_PTR_LO), Y         ;y+1, so this is TUNE_PTR_HIGH
        cmp #$FF
        bne PSG0_play_next2
        rts
    PSG0_play_next2:
        jsr PSG0_writedata
        iny
        jmp PSG0_play_loop
        rts
    PSG0_setreg:
        jsr PSG0_inactive     ; NACT
        sta VIA0_PORTA
        jsr PSG0_latch        ; INTAK
        jsr PSG0_inactive     ; NACT
        rts
    PSG0_writedata:
        jsr PSG0_inactive     ; NACT
        sta VIA0_PORTA
        jsr PSG0_write           ; DWS
        jsr PSG0_inactive
        rts
    PSG0_inactive:        ; NACT
        ; BDIR  LOW
        ; BC1   LOW
        pha
        lda #0     ;A9 high to disable AY -- when adding second AY, will need to set its A9 low (on different port)
        sta VIA0_PORTB
        pla
        rts
    PSG0_latch:           ; INTAK
        ; BDIR  HIGH
        ; BC1   HIGH
        pha
        lda #(PSG0_BDIR | PSG0_BC1);  AY_A9_B low to enable AY -- when adding second AY, will need to set its A9 high here to disable it (on different port)
        sta VIA0_PORTB
        pla
        rts
    PSG0_write:           ; DWS
        ; BDIR  HIGH
        ; BC1   LOW
        pha
        lda #(PSG0_BDIR) ;AY_A9_B low to enable AY -- when adding second AY, will need to set its A9 high here to disable it (on different port)
        sta VIA0_PORTB
        pla
        rts
    PSG0_readdata:
        jsr PSG0_inactive
        lda #$00    ;Read
        sta VIA0_DDRA
        jsr PSG0_read
        lda VIA0_PORTA          ;value retrieved from PSG
        pha
        lda #$FF                ;Write
        sta VIA0_DDRA
        pla
        jsr PSG0_inactive
        plx
        rts
    PSG0_read:           ; DTB
        ; BDIR  LOW
        ; BC1   HIGH
        pha
        lda #(PSG0_BC1)
        sta VIA0_PORTB
        pla
        rts
;PSG1 play:
    PSG1_PlayTune:
        ldy #0
    PSG1_play_loop:
        lda (TUNE_PTR_LO), Y
        cmp #$FF
        bne PSG1_play_next
        rts
    PSG1_play_next:
        jsr PSG1_setreg
        iny
        lda (TUNE_PTR_LO), Y
        cmp #$FF
        bne PSG1_play_next2
        rts
    PSG1_play_next2:
        jsr PSG1_writedata
        iny
        jmp PSG1_play_loop
        rts
    PSG1_setreg:
        jsr PSG1_inactive     ; NACT
        sta VIA0_PORTA
        jsr PSG1_latch        ; INTAK
        jsr PSG1_inactive     ; NACT
        rts
    PSG1_writedata:
        jsr PSG1_inactive     ; NACT
        sta VIA0_PORTA
        jsr PSG1_write           ; DWS
        jsr PSG1_inactive
        rts
    PSG1_inactive:        ; NACT
        ; BDIR  LOW
        ; BC1   LOW
        pha
        lda #0     ;A9 high to disable AY -- when adding second AY, will need to set its A9 low (on different port)
        sta VIA0_PORTB
        pla         
        rts
    PSG1_latch:           ; INTAK
        ; BDIR  HIGH
        ; BC1   HIGH
        pha   
        lda #(PSG1_BDIR | PSG1_BC1);  AY_A9_B low to enable AY -- when adding second AY, will need to set its A9 high here to disable it (on different port)
        sta VIA0_PORTB
        pla         
        rts
    PSG1_write:           ; DWS
        ; BDIR  HIGH
        ; BC1   LOW
        pha         
        lda #(PSG1_BDIR) ;AY_A9_B low to enable AY -- when adding second AY, will need to set its A9 high here to disable it (on different port)
        sta VIA0_PORTB
        pla         
        rts
    PSG1_readdata:
        jsr PSG1_inactive
        lda #$00    ;Read
        sta VIA0_DDRA
        jsr PSG1_read
        lda VIA0_PORTA
        pha
        lda #$FF    ;Write
        sta VIA0_DDRA
        pla
        jsr PSG1_inactive
        rts
    PSG1_read:           ; DTB
        ; BDIR  LOW
        ; BC1   HIGH
        pha
        lda #(PSG1_BC1)
        sta VIA0_PORTB
        pla
        rts

Start_Music:
    ; A = Bank, X = Address
    sep #$20
    .setting "RegA16", false

    stz Music_Active
    
    sta Music_PTR_Bank
    stx Music_PTR_LO
    stz Music_Wait
    
    lda #1
    sta Music_Active    ; Engine only "sees" the new data now
    rts

Start_SFX:
    ; A = Bank, X = Address
    sep #$20
    .setting "RegA16", false

    stz SFX_Active      ; LOCK: ISR will now skip SFX logic if it fires

    sta SFX_PTR_Bank    ; Update Bank ($A6)
    stx SFX_PTR_LO      ; Update Address ($A4-$A5, assumes 16-bit X)
    stz SFX_Wait        ; Reset delay counter ($A7)

    lda #1
    sta SFX_Active      ; UNLOCK: ISR can now safely process the new SFX
    
    rts

FREQ_TABLE:
    ; Frequency Table for YM2149 / AY-3-8910, Clock: 2.000 MHz, Format: .WORD (12-bit Period Value)
    ; --- Octave 1 ---
    .WORD $0FFF     ; C1  (limited by 12-bit register)
    .WORD $0FFF     ; C#1
    .WORD $0FFF     ; D1
    .WORD $0FFF     ; D#1
    .WORD $0FFF     ; E1
    .WORD $0FFF     ; F1
    .WORD $0FFF     ; F#1
    .WORD $0FFF     ; G1
    .WORD $0FFF     ; G#1
    .WORD $0FFF     ; A1
    .WORD $0FFF     ; A#1
    .WORD $0FFF     ; B1

    ; --- Octave 2 ---
    .WORD $0F42     ; C2  (65.41 Hz)
    .WORD $0E62     ; C#2
    .WORD $0D90     ; D2
    .WORD $0CCD     ; D#2
    .WORD $0C14     ; E2
    .WORD $0B68     ; F2
    .WORD $0AC5     ; F#2
    .WORD $0A2C     ; G2
    .WORD $099E     ; G#2
    .WORD $0918     ; A2  (110.00 Hz)
    .WORD $089C     ; A#2
    .WORD $0827     ; B2

    ; --- Octave 3 ---
    .WORD $07A1     ; C3  (130.81 Hz)
    .WORD $0731     ; C#3
    .WORD $06C8     ; D3
    .WORD $0666     ; D#3
    .WORD $060A     ; E3
    .WORD $05B4     ; F3
    .WORD $0562     ; F#3
    .WORD $0516     ; G3
    .WORD $04CF     ; G#3
    .WORD $048C     ; A3  (220.00 Hz)
    .WORD $044E     ; A#3
    .WORD $0413     ; B3

    ; --- Octave 4 ---
    .WORD $03D0     ; C4  (261.63 Hz)
    .WORD $0398     ; C#4
    .WORD $0364     ; D4
    .WORD $0333     ; D#4
    .WORD $0305     ; E4
    .WORD $02DA     ; F4
    .WORD $02B1     ; F#4
    .WORD $028B     ; G4
    .WORD $0267     ; G#4
    .WORD $0246     ; A4  (440.00 Hz)
    .WORD $0227     ; A#4
    .WORD $0209     ; B4

    ; --- Octave 5 ---
    .WORD $01E8     ; C5  (523.25 Hz)
    .WORD $01CC     ; C#5
    .WORD $01B2     ; D5
    .WORD $0199     ; D#5
    .WORD $0182     ; E5
    .WORD $016D     ; F5
    .WORD $0158     ; F#5
    .WORD $0145     ; G5
    .WORD $0133     ; G#5
    .WORD $0123     ; A5  (880.00 Hz)
    .WORD $0113     ; A#5
    .WORD $0104     ; B5

    ; --- Octave 6 ---
    .WORD $00F4     ; C6
    .WORD $00E6     ; C#6
    .WORD $00D9     ; D6
    .WORD $00CC     ; D#6
    .WORD $00C1     ; E6
    .WORD $00B6     ; F6
    .WORD $00AB     ; F#6
    .WORD $00A2     ; G6
    .WORD $0099     ; G#6
    .WORD $0091     ; A6
    .WORD $0089     ; A#6
    .WORD $0082     ; B6

    ; --- Octave 7 ---
    .WORD $007A     ; C7
    .WORD $0073     ; C#7
    .WORD $006C     ; D7
    .WORD $0066     ; D#7
    .WORD $0060     ; E7
    .WORD $005B     ; F7
    .WORD $0055     ; F#7
    .WORD $0051     ; G7
    .WORD $004C     ; G#7
    .WORD $0048     ; A7
    .WORD $0044     ; A#7
    .WORD $0041     ; B7

    ; --- Octave 8 ---
    .WORD $003D     ; C8
    .WORD $0039     ; C#8
    .WORD $0036     ; D8
    .WORD $0033     ; D#8
    .WORD $0030     ; E8
    .WORD $002D     ; F8
    .WORD $002B     ; F#8
    .WORD $0028     ; G8
    .WORD $0026     ; G#8
    .WORD $0024     ; A8
    .WORD $0022     ; A#8
    .WORD $0020     ; B8    

music_table:
    .word MUSIC_MARIO_THEME, $0000      ; ID 0
    .word MUSIC_ZELDA_THEME, $0000      ; ID 1
    .word MUSIC_TETRIS_TRIPLE, $0000    ; ID 2
    .word MUSIC_VAMPIRE_KILLER, $0000   ; ID 3
    .word SFX_MARIO_JUMP, $0000         ; ID 4
    .word SFX_COIN, $0000               ; ID 5
    .word SFX_FIREBALL, $0000           ; ID 6
    .word SFX_EXPLODE, $0000            ; ID 7
    .word SFX_POWERUP, $0000            ; ID 8
    .word MUSIC_HALLOWEEN, $0000        ; ID 9
    .word MUSIC_STRANGER_THINGS, $0000  ; ID 10
    .word MUSIC_DREAM_COLLAPSING, $0000 ; ID 11
    .word MUSIC_MONKEY_ISLAND, $0000    ; ID 12
    .word MUSIC_STAR_TREK, $0000        ; ID 13
    .word MUSIC_ZELDA, $0000            ; ID 14
    .word MUSIC_DRAGONBORN, $0000       ; ID 15
    .word MUSIC_MARIO_REMIX, $0000      ; ID 16
    .word MUSIC_KUNGFU_THEME, $0000     ; ID 17     0x11
    .word MUSIC_OFF, $0000              ; ID 18     0x12
    

sfx_table:
    .word SFX_MARIO_JUMP_2, $0000         ; ID 0
    .word SFX_COIN_2, $0000               ; ID 1
    .word SFX_FIREBALL_2, $0000           ; ID 2
    .word SFX_EXPLODE_2, $0000            ; ID 3
    .word SFX_POWERUP_2, $0000            ; ID 4
    .word SFX_KUNGFU_PUNCH, $0000         ; ID 5
    .word SFX_KUNGFU_KICK, $0000          ; ID 6

SND_RESET:
    .BYTE $00, $00           ;ChanA tone period fine tune
    .BYTE $01, $00           ;ChanA tone period coarse tune
    .BYTE $02, $00           ;ChanB tone period fine tune      
    .BYTE $03, $00           ;ChanB tone period coarse tune
    .BYTE $04, $00           ;ChanC tone period fine tune  
    .BYTE $05, $00           ;ChanC tone period coarse tune
    .BYTE $06, $00           ;Noise Period
    .BYTE $07, $38           ;EnableB        ;all channels enabled, IO set to read for both ports
    .BYTE $08, $0F           ;ChanA amplitude    0F = fixed, max
    .BYTE $09, $0F           ;ChanB amplitude
    .BYTE $0A, $0F           ;ChanC amplitude
    .BYTE $0B, $00           ;Envelope period fine tune
    .BYTE $0C, $00           ;Envelope period coarse tune
    .BYTE $0D, $00           ;Envelope shape cycle
    ;.BYTE $0E, $00           ;IO Port A
    ;.BYTE $0F, $00           ;IO Port B
    .BYTE $FF, $FF           ; EOF

SND_OFF_ALL:
    .BYTE $08, $00           ;ChanA amplitude    0F = fixed, max
    .BYTE $09, $00           ;ChanB amplitude
    .BYTE $0A, $00           ;ChanC amplitude
    .BYTE $FF, $FF                ; EOF
