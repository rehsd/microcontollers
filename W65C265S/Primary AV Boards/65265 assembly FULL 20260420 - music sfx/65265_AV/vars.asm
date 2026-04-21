
; ********** VGA ****************************************************************
	vidpageVRAM 				.equ 	$10		; 4 bytes 	Pointer - current VRAM location
	color                   	.equ 	$14		; 2
	row                     	.equ 	$16		; 2
	fill_region_start_x     	.equ 	$18		; 2     	Horizontal pixel position, 0 to 319
	fill_region_start_y     	.equ 	$1A		; 2     	Vertical pixel position,   0 to 239
	fill_region_end_x       	.equ 	$1C		; 2     	Horizontal pixel position, 0 to 319
	fill_region_end_y       	.equ 	$1E		; 2     	Vertical pixel position,   0 to 239
	fill_region_color       	.equ 	$20		; 2     	Color for fill,            0 to 255  
	jump_to_line_y          	.equ 	$22		; 2     	Line to jump to,           0 to 239
	col_end                 	.equ 	$24		; 2     	Used in FillRegion to track end column for fill
	rows_remain             	.equ 	$26		; 2     	Used in FillRegion to track number of rows to process
	char_color              	.equ 	$28		; 2
	char_x_offset           	.equ 	$2A		; 2
	char_x_offset_orig      	.equ 	$2C		; 2
	charPixelRowLoopCounter 	.equ 	$2E		; 2     	Character pixel row loop counter
	char_current_val        	.equ 	$30		; 2
	char_from_charmap       	.equ 	$32		; 2     	Stored current char from appropriate charmap
	char_vp_x               	.equ 	$34		; 2			Used to set x position of char
	char_vp_y               	.equ 	$36		; 2			Used to set y position of char
	message_to_process      	.equ 	$38		; 2
	xtmp						.equ 	$3A		; 2                    
	tmpHex						.equ 	$3C		; 2
	move_size               	.equ 	$3E		; 2
	move_source             	.equ 	$40		; 2
	move_dest               	.equ 	$42		; 2
	move_counter            	.equ 	$44		; 2
	move_frame_counter      	.equ 	$46		; 2
	char_vp						.equ 	$48		; 4

	line_delta_x				.equ 	$4C		; 2
	line_delta_y				.equ 	$4E		; 2
	line_step_x					.equ 	$50		; 2
	line_step_y					.equ 	$52		; 2
	line_error					.equ 	$54		; 2
	line_error2					.equ 	$56		; 2

	rect_line_start_x:  		.equ 	$58		; 2
	rect_line_start_y:      	.equ 	$5A		; 2	
	rect_line_end_x:   			.equ 	$5C		; 2
	rect_line_end_y:    		.equ 	$5E		; 2

	circle_x:         			.equ 	$60		; 2
	circle_y:         			.equ 	$62		; 2
	circle_error:     			.equ 	$64		; 2
	circle_temp_cmp:  			.equ 	$66		; 2

	diamond_cur_y:      		.equ 	$68		; 2
	diamond_cur_offset: 		.equ 	$6A		; 2
	diamond_row_count:  		.equ 	$6C		; 2

	sprite_x:					.equ 	$70		; 2
	sprite_y:					.equ 	$72		; 2
	sprite_id:					.equ 	$74		; 2

	ptrsrc   					.equ 	$76		; 2
	srcbank  					.equ 	$78		; 2
	ptrdest  					.equ 	$7A		; 2
	tempmath 					.equ 	$7C		; 2
	ptrvram						.equ 	$80		; 4

; ********** /VGA ***************************************************************



;**** SOUND
	TUNE_PTR_LO             	.equ 	$84		; 1 byte
	TUNE_PTR_HI             	.equ 	$85		; 1 byte
	TUNE_PTR_BANK           	.equ 	$86		; 1 byte

	CMDtoProcess            	.equ 	$88	;			Set by interrupt to indicate DPRAM has queud commands to process; Set to 0 when finished processing queue on interrupt.

; ********** Extended SRAM POST Test ************************************************
	TestBankPointer   			.equ 	$90     ; 4 bytes 	Address Low, High, Bank) - really only need 3 bytes
	TestBank          			.equ 	$94     ; 2 byte 	counter) - really only need 1 byte
	TestPattern       			.equ 	$96     ; 2 bytes 	The pattern being tested)

	Str_ptr			    		.equ 	$98   	; 2			Pointer to a string

	; ********** Randomizer ********************************************************
		RNG_SEED    				.equ 	$9A     ; 2 bytes			; seed
		RNG_MAX     				.equ 	$9C     ; 2 bytes			; holds incoming max
		temp_rng					.equ 	$9E		; 2 bytes

; ****** Audio Engine Variables (Direct Page) *******
	Music_PTR_LO        		.equ 	$A0 
	Music_PTR_HI        		.equ 	$A1 
	Music_PTR_Bank      		.equ 	$A2 
	Music_Wait          		.equ 	$A3 
	SFX_PTR_LO          		.equ 	$A4 
	SFX_PTR_HI          		.equ 	$A5 
	SFX_PTR_Bank        		.equ 	$A6 
	SFX_Wait            		.equ 	$A7 
	SND_CMD             		.equ 	$A8 
	SND_VAL             		.equ 	$A9 
	Shadow_R7_P0        		.equ 	$AA 
	Shadow_R7_P1        		.equ 	$AB
	Music_Active				.equ 	$AC
	SFX_Active					.equ 	$AD
	Audio_Prescale				.equ 	$AE 
	Music_ID_Lo	    			.equ	$B0		; 2     ; Incoming address offset from Master
	Music_ID_Hi					.equ	$B2	    ; 2     ; Incoming bank/high word from Master
	Music_Volume				.equ   	$B4		; 2		; Global volume setting ($0000-$000F)
	Music_LoopFlag				.equ	$B6		; 2     ; 1 = Restart on $FF, 0 = Stop on $FF	
	Music_Status				.equ	$B8		; 2     ; Bit 0: 1=Playing, 0=Stopped. Bit 1: 1=Looping, 0=Not looping.
	SFX_ID_Lo	    			.equ	$BA		; 2     ; Incoming address offset from Master
	SFX_ID_Hi					.equ	$BC	    ; 2     ; Incoming bank/high word from Master
	SFX_Volume					.equ   	$BE		; 2

; Div32by16 (ToneGen.asm)
	FreqVal                 	.equ 	$100   	; 2
	Dividend  			   		.equ 	$102   	; 4
	Divisor   					.equ 	$106   	; 2
	Remainder 					.equ 	$108   	; 2

; --- New Command Buffer ---
	cmd_buffer      			.equ 	$0200         ; 64-byte command string
	cmd_index       			.equ 	$0240         ; current length of command



; ---
	sysptr 						.equ 	$1000
	sysroutine 					.equ 	$1004

; --- OLD sound vars -----
	toneDelayDuration       	.equ 	$2000
	//Sound_ROW               	.equ 	$2001     ;track with 'row' we are in for a sound sequence
	audio_data_to_write     	.equ 	$2002       ;used to track when audio config data has been received from Arduino and should be processed in loop:

	SND_PSG                 	.equ 	$2003     ;which programmable sound generator (i.e., AY) to use for CMD
	//SND_CMD                 	.equ 	$2004     ;when reading from SD Card, used to capture the current command number to process
	//SND_VAL                 	.equ 	$2005     ;used to capture the value to use with the current command

	SND_ROM_POS            		.equ 	$2006     ;used to track media ROM read location MSB POS3_POS2_POS to LSB (19 bits req'd to access full 512KB of ROM)
	SND_ROM_POS2           		.equ 	$2007
	SND_ROM_POS3           		.equ 	$2008

	SND_ABORT_MUSIC        		.equ 	$200E     ;If set to 1, abort playback of current song
	SND_MUSIC_PLAYING      		.equ 	$2010

	TonePeriodCourseLA     		.equ 	$2100     ;0
	TonePeriodCourseLB     		.equ 	$2101
	TonePeriodCourseLC     		.equ 	$2102
	TonePeriodCourseLD     		.equ 	$2103
	TonePeriodCourseLE     		.equ 	$2104
	TonePeriodCourseLF     		.equ 	$2105
	TonePeriodFineLA       		.equ 	$2106
	TonePeriodFineLB       		.equ 	$2107
	TonePeriodFineLC       		.equ 	$2108
	TonePeriodFineLD       		.equ 	$2109
	TonePeriodFineLE       		.equ 	$210A     ;10
	TonePeriodFineLF       		.equ 	$210B
	VolumeLA               		.equ 	$210C
	VolumeLB               		.equ 	$210D
	VolumeLC               		.equ 	$210E
	VolumeLD               		.equ 	$210F
	VolumeLE               		.equ 	$2110
	VolumeLF               		.equ 	$2111
	TonePeriodCourseRA     		.equ 	$2112
	TonePeriodCourseRB     		.equ 	$2113
	TonePeriodCourseRC     		.equ 	$2114     ;20
	TonePeriodCourseRD     		.equ 	$2115
	TonePeriodCourseRE     		.equ 	$2116
	TonePeriodCourseRF     		.equ 	$2117
	TonePeriodFineRA       		.equ 	$2118
	TonePeriodFineRB       		.equ 	$2119
	TonePeriodFineRC       		.equ 	$211A
	TonePeriodFineRD       		.equ 	$211B
	TonePeriodFineRE       		.equ 	$211C
	TonePeriodFineRF       		.equ 	$211D
	VolumeRA               		.equ 	$211E     ;30
	VolumeRB               		.equ 	$211F     ;31
	VolumeRC               		.equ 	$2120
	VolumeRD               		.equ 	$2121
	VolumeRE               		.equ 	$2122
	VolumeRF               		.equ 	$2123
	NoisePeriodL1          		.equ 	$2124
	EnvelopePeriodCourseL1 		.equ 	$2125
	EnvelopePeriodFineL1   		.equ 	$2126
	EnvelopeShapeCycleL1   		.equ 	$2127
	EnableLeft1            		.equ 	$2128     ;40
	EnableRight1           		.equ 	$2129
	EnableLeft2            		.equ 	$212A
	EnableRight2           		.equ 	$212B
	NoisePeriodR1          		.equ 	$212C
	EnvelopePeriodCourseR1 		.equ 	$212D
	EnvelopePeriodFineR1   		.equ 	$212E
	EnvelopeShapeCycleR1   		.equ 	$212F
	NoisePeriodL2          		.equ 	$2130
	EnvelopePeriodCourseL2 		.equ 	$2131
	EnvelopePeriodFineL2   		.equ 	$2132     ;50
	EnvelopeShapeCycleL2   		.equ 	$2133
	NoisePeriodR2          		.equ 	$2134
	EnvelopePeriodCourseR2 		.equ 	$2135
	EnvelopePeriodFineR2   		.equ 	$2136
	EnvelopeShapeCycleR2   		.equ 	$2137
	SoundDelay             		.equ 	$2138
	Sound_Future1          		.equ 	$2139
	Sound_Future2          		.equ 	$213A
	Sound_Future3          		.equ 	$213B
	Sound_Future4          		.equ 	$213C     ;60
	Sound_Future5          		.equ 	$213D     
	Sound_Future6          		.equ 	$213E
	Sound_EOF              		.equ 	$213F     ;63 (64th byte... END)
	

