
	; ********** VGA ****************************************************************
		vidpageVRAM 				= $10	; 4 bytes - pointer - current VRAM location
		color                   	= $14	; 2
		row                     	= $16	; 2
		fill_region_start_x     	= $18	; 2     ;Horizontal pixel position, 0 to 319
		fill_region_start_y     	= $1A	; 2     ;Vertical pixel position,   0 to 239
		fill_region_end_x       	= $1C	; 2     ;Horizontal pixel position, 0 to 319
		fill_region_end_y       	= $1E	; 2     ;Vertical pixel position,   0 to 239
		fill_region_color       	= $20	; 2     ;Color for fill,            0 to 255  
		jump_to_line_y          	= $22	; 2     ;Line to jump to,           0 to 239
		col_end                 	= $24	; 2     ;Used in FillRegion to track end column for fill
		rows_remain             	= $26	; 2     ;Used in FillRegion to track number of rows to process
		char_color              	= $28	; 2
		char_y_offset           	= $2A	; 2
		char_y_offset_orig      	= $2C	; 2
		charPixelRowLoopCounter 	= $2E	; 2     ;character pixel row loop counter
		char_current_val        	= $30	; 2
		char_from_charmap       	= $32	; 2     ;stored current char from appropriate charmap
		char_vp_x               	= $34	; 2
		char_vp_y               	= $36	; 2
		message_to_process      	= $38	; 2
		xtmp						= $3A	; 2                    
		tmpHex						= $3C	; 2
		move_size               	= $3E	; 2
		move_source             	= $40	; 2
		move_dest               	= $42	; 2
		move_counter            	= $44	; 2
		move_frame_counter      	= $46	; 2
		char_vp						= $48	; 4
	; ********** /VGA ***************************************************************




		Str_ptr			    = $50   	; 	2		; pointer to a string


	; ********** Extended SRAM POST Test ************************************************
		TestBankPointer    = $60       ; 4 bytes (Address Low, High, Bank) - really only need 3 bytes
		TestBank           = $64       ; 2 byte (counter) - really only need 1 byte
		TestPattern        = $66       ; 2 bytes (The pattern being tested)



	; Div32by16 (ToneGen.asm)
		FreqVal                 = $70   ;.BLKB	2
		Dividend  			    = $72   ;.BLKB	4
		Divisor   				= $76   ;.BLKB	2
		Remainder 				= $78   ;.BLKB	2

	
	;**** SOUND
		TUNE_PTR_LO             = $0080
		TUNE_PTR_HI             = $0081
		TUNE_PTR_BANK           = $0082

		CMDtoProcess            = $0088     ;Set by interrupt to indicate DPRAM has queud commands to process; Set to 0 when finished processing queue on interrupt.

		toneDelayDuration       = $2000
		//Sound_ROW               = $2001     ;track with 'row' we are in for a sound sequence
		audio_data_to_write     = $2002       ;used to track when audio config data has been received from Arduino and should be processed in loop:

		SND_PSG                 = $2003     ;which programmable sound generator (i.e., AY) to use for CMD
		SND_CMD                 = $2004     ;when reading from SD Card, used to capture the current command number to process
		SND_VAL                 = $2005     ;used to capture the value to use with the current command

		SND_ROM_POS             = $2006     ;used to track media ROM read location MSB POS3_POS2_POS to LSB (19 bits req'd to access full 512KB of ROM)
		SND_ROM_POS2            = $2007
		SND_ROM_POS3            = $2008

		SND_ABORT_MUSIC         = $200E     ;If set to 1, abort playback of current song
		SND_MUSIC_PLAYING       = $2010

		TonePeriodCourseLA      = $2100     ;0
		TonePeriodCourseLB      = $2101
		TonePeriodCourseLC      = $2102
		TonePeriodCourseLD      = $2103
		TonePeriodCourseLE      = $2104
		TonePeriodCourseLF      = $2105
		TonePeriodFineLA        = $2106
		TonePeriodFineLB        = $2107
		TonePeriodFineLC        = $2108
		TonePeriodFineLD        = $2109
		TonePeriodFineLE        = $210A     ;10
		TonePeriodFineLF        = $210B
		VolumeLA                = $210C
		VolumeLB                = $210D
		VolumeLC                = $210E
		VolumeLD                = $210F
		VolumeLE                = $2110
		VolumeLF                = $2111
		TonePeriodCourseRA      = $2112
		TonePeriodCourseRB      = $2113
		TonePeriodCourseRC      = $2114     ;20
		TonePeriodCourseRD      = $2115
		TonePeriodCourseRE      = $2116
		TonePeriodCourseRF      = $2117
		TonePeriodFineRA        = $2118
		TonePeriodFineRB        = $2119
		TonePeriodFineRC        = $211A
		TonePeriodFineRD        = $211B
		TonePeriodFineRE        = $211C
		TonePeriodFineRF        = $211D
		VolumeRA                = $211E     ;30
		VolumeRB                = $211F     ;31
		VolumeRC                = $2120
		VolumeRD                = $2121
		VolumeRE                = $2122
		VolumeRF                = $2123
		NoisePeriodL1           = $2124
		EnvelopePeriodCourseL1  = $2125
		EnvelopePeriodFineL1    = $2126
		EnvelopeShapeCycleL1    = $2127
		EnableLeft1             = $2128     ;40
		EnableRight1            = $2129
		EnableLeft2             = $212A
		EnableRight2            = $212B
		NoisePeriodR1           = $212C
		EnvelopePeriodCourseR1  = $212D
		EnvelopePeriodFineR1    = $212E
		EnvelopeShapeCycleR1    = $212F
		NoisePeriodL2           = $2130
		EnvelopePeriodCourseL2  = $2131
		EnvelopePeriodFineL2    = $2132     ;50
		EnvelopeShapeCycleL2    = $2133
		NoisePeriodR2           = $2134
		EnvelopePeriodCourseR2  = $2135
		EnvelopePeriodFineR2    = $2136
		EnvelopeShapeCycleR2    = $2137
		SoundDelay              = $2138
		Sound_Future1           = $2139
		Sound_Future2           = $213A
		Sound_Future3           = $213B
		Sound_Future4           = $213C     ;60
		Sound_Future5           = $213D     
		Sound_Future6           = $213E
		Sound_EOF               = $213F     ;63 (64th byte... END)
		




		; --- New Command Buffer ---
		cmd_buffer      = $0200         ; 64-byte command string
		cmd_index       = $0240         ; current length of command

	sysptr = $1000
	sysroutine = $1004
