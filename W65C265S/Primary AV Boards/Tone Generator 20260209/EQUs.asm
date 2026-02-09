	LONGI	ON
	LONGA	ON
    
;; IO Ports 
  PCS7: 			equ $DF27 ;; Port 7 Chip Select

  PDD6: 			equ $DF26 ;; Port 6 Data Direction Register
  PDD5: 			equ $DF25 ;; Port 5 Data Direction Register
  PDD4: 			equ $DF24 ;; Port 4 Data Direction Register
  PDD3:				equ $DF07	;; Port 3 Data Direction Register
  PDD2:				equ $DF06	;; Port 2 Data Direction Register
  PDD1:				equ $DF05	;; Port 1 Data Direction Register
  PDD0:				equ $DF04	;; Port 0 Data Direction Register

  ;PIBER:			equ $DF79 ;; parallel port interface

  PD7:  			equ $DF23 ;; Port 7 Data Register
  PD6:  			equ $DF22 ;; Port 6 Data Register
  PD5:  			equ $DF21 ;; Port 5 Data Register
  PD4:  			equ $DF20 ;; Port 4 Data Register
  PD3:				equ $DF03 ;; Port 3 Data Register
  PD2:				equ $DF02 ;; Port 2 Data Register
  PD1:				equ $DF01 ;; Port 1 Data Register
  PD0:				equ $DF00 ;; Port 0 Data Register
  
  ;; Control and Status Register Memory Map
  TIER:  			equ $DF46 ;; Timer Interrupt Enable Register
  TIFR:  			equ $DF44 ;; Timer Interrupt Flag Register
  TER:  			equ $DF43 ;; Timer Enable Register
  TCR:  			equ $DF42 ;; Timer Control Register
  SSCR:  			equ $DF41 ;; System Speed Control Register
  BCR:  			equ $DF40 ;; Bus Control Register
  EIER:  			equ $DF47 ;; Edge Interrupt Enable Register		  data sheet pg 14, Monitor ROM code, sample projects
  EIFR:  			equ $DF45 ;; Edge Interrupt Flag Register		    data sheet pg 14, Monitor ROM code, sample projects
  ;EIER:  			equ $DF45 ;; Edge Interrupt Enable Register		data sheet pg 24 - incorrect
  ;EIFR:  			equ $DF47 ;; Edge Interrupt Flag Register		  data sheet pg 25 - incorrect

  PE56ENABLE:  		equ %00000001		;$01
  NE57ENABLE:  		equ %00000010		;$02
  PE60ENABLE:  		equ %00000100		;$04
  PWMENABLE:   		equ %00001000		;$08
  NE64ENABLE:  		equ %00010000		;$10	;*****************************************
  NE66ENABLE:  		equ %00100000		;$20
  PIBIRQENABLE:		equ %01000000		;$40
  IRQENABLE:		equ %10000000		;$80

;; On Chip RAM
  OCRAM_BASE: equ $DF80 ;; RAM Registers
  
  IRQHandlerBank: EQU $00	; IRQHandler / $10000   ; divide by 65536 to get bank

; 1602 LCD
  E:   			equ %01000000
  RW:  			equ %00100000
  RS:  			equ %00010000

; PS/2 Keyboard
  KBD_READY:	equ %00000001
  RELEASE:		equ %00000010
  SHIFT:        equ %00000100

  ;************************* VIAs *************************************
  ;VIA Registers
  VIA_PORTB: 		equ $00		; Port B data register
  VIA_PORTA: 		equ $01		; Port A data register
  VIA_DDRB:  		equ $02		; Port B data direction register
  VIA_DDRA:  		equ $03		; Port A data direction register
  VIA_T1C_L: 		equ $04		; T1 low-order latches (write) / counter
  VIA_T1C_H: 		equ $05		; T1 high-order counter
  VIA_T1L_L: 		equ $06		; T1 low-order latches
  VIA_T1L_H: 		equ $07		; T1 high-order latches
  VIA_T2C_L: 		equ $08		; T2 low-order latches (write) / counter
  VIA_T2C_H: 		equ $09		; T1 high-order counter
  VIA_SR:    		equ $0A		; Shift register
  VIA_ACR:   		equ $0B		; Auxiliary control register
  VIA_PCR:   		equ $0C		; Peripheral control register
  VIA_IFR:   		equ $0D		; Interrupt flag register
  VIA_IER:   		equ $0E		; Interrupt enable register
  VIA_PORTA_NH:	equ $0F		; Port A data register without handshake

  ;VIA0 Address - %11000000:00000000:00000000 - $C0:0000
  ;PS2 keyboard & 1602 LCD
  VIA0_ADDR:  	equ $C00000
  VIA0_PORTB: 	equ $C00000		; VIA1_ADDR + VIA_PORTB
  VIA0_PORTA: 	equ $C00001		; VIA1_ADDR + VIA_PORTA
  VIA0_DDRB:  	equ $C00002		; VIA1_ADDR + VIA_DDRB
  VIA0_DDRA:  	equ $C00003		; VIA1_ADDR + VIA_DDRA
  VIA0_T1CL:  	equ $C00004		; VIA1_ADDR + VIA_T1C_L
  VIA0_T1CH:  	equ $C00005		; VIA1_ADDR + VIA_T1C_H
  VIA0_T1LL:  	equ $C00006		; VIA1_ADDR + VIA_T1L_L
  VIA0_T1LH:  	equ $C00007		; VIA1_ADDR + VIA_T1L_H
  VIA0_T2CL:  	equ $C00008		; VIA1_ADDR + VIA_T2C_L
  VIA0_T2CH:  	equ $C00009		; VIA1_ADDR + VIA_T2C_H
  VIA0_SR:    	equ $C0000A		; VIA1_ADDR + VIA_SR
  VIA0_ACR:   	equ $C0000B		; VIA1_ADDR + VIA_ACR
  VIA0_PCR:   	equ $C0000C		; VIA1_ADDR + VIA_PCR
  VIA0_IFR:   	equ $C0000D		; VIA1_ADDR + VIA_IFR
  VIA0_IER:   	equ $C0000E		; VIA1_ADDR + VIA_IER

  ;VIA1 Address - %11010000:00000000:00000000 - $D0:0000
  ;ILI LCD
  VIA1_ADDR:  	equ $D00000
  VIA1_PORTB: 	equ $D00000		; VIA2_ADDR + VIA_PORTB
  VIA1_PORTA: 	equ $D00001		; VIA2_ADDR + VIA_PORTA
  VIA1_DDRB:  	equ $D00002		; VIA2_ADDR + VIA_DDRB
  VIA1_DDRA:  	equ $D00003		; VIA2_ADDR + VIA_DDRA
  VIA1_IFR:   	equ $D0000D		; VIA2_ADDR + VIA_IFR
  VIA1_IER:   	equ $D0000E		; VIA2_ADDR + VIA_IER

  ;VIA2 Address - %11100000:00000000:00000000 - $E0:0000
  ;SPI
  ;************************* /VIAs *************************************

  ;************************* VGA ***************************************
  VRAM_ADDR_BASE: equ $EA0000
  VRAM_ADDR_MAX:	equ $EBFFFF

  ;ASCII_CHARMAP	equ %11100000
  PIXEL_COL1:     equ %10000000
  PIXEL_COL2:     equ %01000000
  PIXEL_COL3:     equ %00100000
  PIXEL_COL4:     equ %00010000
  PIXEL_COL5:     equ %00001000
  ;************************* /VGA ***************************************


  ;************************* UART3 *************************************
  ACSR3:			equ $DF76    	; UART3 control/status
  ARTD3:			equ $DF77     	; UART3 data register (read=RX, write=TX)

  UIER:  			equ $DF49 		; UART Interrupt Enable Register
  UIFR:  			equ $DF48 		; UART Interrupt Flag Register		!!!!!!!!!!!!!!!!!!!!!! data sheet pg 27 lists $DF47! so many problems with the data sheet!
  ; UIFR bits: 					; data sheet pg 27
  U3RF:			equ %01000000	; receive full
  U3TF:			equ %10000000	; transmit full ??? seems to be, but documentation isn't consistent

  ; Timer 3 Registers (for baud rate)
  T3LL:			equ $DF56     	; Timer 3 low latch
  T3LH:			equ $DF57     	; Timer 3 high latch
  ;************************* /UART3 ************************************

  ;************************* tone generators ***************************
  T5CL:     		equ $DF6A   	; Timer 5 counter low
  T5CH:     		equ $DF6B   	; Timer 5 counter high
  ;************************* /tone generators **************************
