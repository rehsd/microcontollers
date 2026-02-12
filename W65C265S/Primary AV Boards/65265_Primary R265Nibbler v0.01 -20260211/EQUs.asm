.setting "RegA16", true
.setting "RegXY16", true

    
;; IO Ports 
  PCS7 			= $DF27 ;; Port 7 Chip Select
  PDD6 			= $DF26 ;; Port 6 Data Direction Register
  PDD5 			= $DF25 ;; Port 5 Data Direction Register
  PDD4 			= $DF24 ;; Port 4 Data Direction Register
  PDD3				= $DF07	;; Port 3 Data Direction Register
  PDD2				= $DF06	;; Port 2 Data Direction Register
  PDD1				= $DF05	;; Port 1 Data Direction Register
  PDD0				= $DF04	;; Port 0 Data Direction Register

  ;PIBER:			= $DF79 ;; parallel port interface

  PD7  			= $DF23 ;; Port 7 Data Register
  PD6  			= $DF22 ;; Port 6 Data Register
  PD5  			= $DF21 ;; Port 5 Data Register
  PD4  			= $DF20 ;; Port 4 Data Register
  PD3				= $DF03 ;; Port 3 Data Register
  PD2				= $DF02 ;; Port 2 Data Register
  PD1				= $DF01 ;; Port 1 Data Register
  PD0				= $DF00 ;; Port 0 Data Register
  
  ;; Control and Status Register Memory Map
  TIER  			= $DF46 ;; Timer Interrupt Enable Register
  TIFR  			= $DF44 ;; Timer Interrupt Flag Register
  TER  			= $DF43 ;; Timer Enable Register
  TCR  			= $DF42 ;; Timer Control Register
  SSCR  			= $DF41 ;; System Speed Control Register
  BCR  			= $DF40 ;; Bus Control Register
  EIER  			= $DF47 ;; Edge Interrupt Enable Register		  data sheet pg 14, Monitor ROM code, sample projects
  EIFR  			= $DF45 ;; Edge Interrupt Flag Register		    data sheet pg 14, Monitor ROM code, sample projects
  ;EIER:  			= $DF45 ;; Edge Interrupt Enable Register		data sheet pg 24 - incorrect
  ;EIFR:  			= $DF47 ;; Edge Interrupt Flag Register		  data sheet pg 25 - incorrect

  PE56ENABLE  		= %00000001		;$01
  NE57ENABLE  		= %00000010		;$02
  PE60ENABLE  		= %00000100		;$04
  PWMENABLE   		= %00001000		;$08
  NE64ENABLE  		= %00010000		;$10	;*****************************************
  NE66ENABLE  		= %00100000		;$20
  PIBIRQENABLE		= %01000000		;$40
  IRQENABLE		= %10000000		;$80

;; On Chip RAM
  OCRAM_BASE = $DF80 ;; RAM Registers
  
  IRQHandlerBank: = $00	; IRQHandler / $10000   ; divide by 65536 to get bank

; 1602 LCD
  E   			= %01000000
  RW  			= %00100000
  RS  			= %00010000

; PS/2 Keyboard
  KBD_READY	= %00000001
  RELEASE		= %00000010
  SHIFT        = %00000100

  ;************************* VIAs *************************************
  ;VIA Registers
  VIA_PORTB 		= $00		; Port B data register
  VIA_PORTA 		= $01		; Port A data register
  VIA_DDRB  		= $02		; Port B data direction register
  VIA_DDRA  		= $03		; Port A data direction register
  VIA_T1C_L 		= $04		; T1 low-order latches (write) / counter
  VIA_T1C_H 		= $05		; T1 high-order counter
  VIA_T1L_L 		= $06		; T1 low-order latches
  VIA_T1L_H 		= $07		; T1 high-order latches
  VIA_T2C_L 		= $08		; T2 low-order latches (write) / counter
  VIA_T2C_H 		= $09		; T1 high-order counter
  VIA_SR    		= $0A		; Shift register
  VIA_ACR   		= $0B		; Auxiliary control register
  VIA_PCR   		= $0C		; Peripheral control register
  VIA_IFR   		= $0D		; Interrupt flag register
  VIA_IER   		= $0E		; Interrupt enable register
  VIA_PORTA_NH	= $0F		; Port A data register without handshake

  ;VIA0 Address - %11000000:00000000:00000000 - $C0:0000
  ;PS2 keyboard & 1602 LCD
  VIA0_ADDR  	= $C00000
  VIA0_PORTB 	= $C00000		; VIA1_ADDR + VIA_PORTB
  VIA0_PORTA 	= $C00001		; VIA1_ADDR + VIA_PORTA
  VIA0_DDRB  	= $C00002		; VIA1_ADDR + VIA_DDRB
  VIA0_DDRA  	= $C00003		; VIA1_ADDR + VIA_DDRA
  VIA0_T1CL  	= $C00004		; VIA1_ADDR + VIA_T1C_L
  VIA0_T1CH  	= $C00005		; VIA1_ADDR + VIA_T1C_H
  VIA0_T1LL  	= $C00006		; VIA1_ADDR + VIA_T1L_L
  VIA0_T1LH  	= $C00007		; VIA1_ADDR + VIA_T1L_H
  VIA0_T2CL  	= $C00008		; VIA1_ADDR + VIA_T2C_L
  VIA0_T2CH  	= $C00009		; VIA1_ADDR + VIA_T2C_H
  VIA0_SR    	= $C0000A		; VIA1_ADDR + VIA_SR
  VIA0_ACR   	= $C0000B		; VIA1_ADDR + VIA_ACR
  VIA0_PCR   	= $C0000C		; VIA1_ADDR + VIA_PCR
  VIA0_IFR   	= $C0000D		; VIA1_ADDR + VIA_IFR
  VIA0_IER   	= $C0000E		; VIA1_ADDR + VIA_IER

  ;VIA1 Address - %11010000:00000000:00000000 - $D0:0000
  ;ILI LCD
  VIA1_ADDR  	= $D00000
  VIA1_PORTB 	= $D00000		; VIA2_ADDR + VIA_PORTB
  VIA1_PORTA 	= $D00001		; VIA2_ADDR + VIA_PORTA
  VIA1_DDRB  	= $D00002		; VIA2_ADDR + VIA_DDRB
  VIA1_DDRA  	= $D00003		; VIA2_ADDR + VIA_DDRA
  VIA1_IFR   	= $D0000D		; VIA2_ADDR + VIA_IFR
  VIA1_IER   	= $D0000E		; VIA2_ADDR + VIA_IER

  ;VIA2 Address - %11100000:00000000:00000000 - $E0:0000
  ;SPI
  ;************************* /VIAs *************************************

  ;************************* ILI ***************************************
  ; VRAM_ADDR_BASE: = $EA0000
  ; VRAM_ADDR_MAX:	= $EBFFFF

  ;ASCII_CHARMAP	= %11100000
  ILI_PIXEL_COL1     = %10000000
  ILI_PIXEL_COL2     = %01000000
  ILI_PIXEL_COL3     = %00100000
  ILI_PIXEL_COL4     = %00010000
  ILI_PIXEL_COL5     = %00001000
  
  ;************************* /ILI ***************************************


  ;************************* UART3 *************************************
  ACSR3			= $DF76    	; UART3 control/status
  ARTD3			= $DF77     	; UART3 data register (read=RX, write=TX)

  UIER  			= $DF49 		; UART Interrupt Enable Register
  UIFR  			= $DF48 		; UART Interrupt Flag Register		!!!!!!!!!!!!!!!!!!!!!! data sheet pg 27 lists $DF47! so many problems with the data sheet!
  ; UIFR bits: 					; data sheet pg 27
  U3RF			= %01000000	; receive full
  U3TF			= %10000000	; transmit full ??? seems to be, but documentation isn't consistent

  ; Timer 3 Registers (for baud rate)
  T3LL			= $DF56     	; Timer 3 low latch
  T3LH			= $DF57     	; Timer 3 high latch
  ;************************* /UART3 ************************************

  ;************************* tone generators ***************************
  T5CL     		= $DF6A   	; Timer 5 counter low
  T5CH     		= $DF6B   	; Timer 5 counter high
  ;************************* /tone generators **************************
