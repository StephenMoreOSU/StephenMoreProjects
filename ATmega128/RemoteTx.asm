;***********************************************************
;*	
;*	RemoteTx.asm
;*	
;*	This code transmits actions to a specified bot address 
;*	using 2400 baud rate 8 bit data transmission, no parity, asynchrounous. 
;*	Actions are defined at the top of the code
;*	
;*
;***********************************************************
;*
;*	 Author: Stephen More and Braam Beresford
;*	   Date: 12/4/2019
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multi-Purpose Register

.equ	EngEnR = 4				; Right Engine Enable Bit
.equ	EngEnL = 7				; Left Engine Enable Bit
.equ	EngDirR = 5				; Right Engine Direction Bit
.equ	EngDirL = 6				; Left Engine Direction Bit
; Use these action codes between the remote and robot
; MSB = 1 thus:
; control signals are shifted right by one and ORed with 0b10000000 = $80
.equ	MovFwd =  ($80|1<<(EngDirR-1)|1<<(EngDirL-1))	;0b10110000 Move Forward Action Code
.equ	MovBck =  ($80|$00)								;0b10000000 Move Backward Action Code
.equ	TurnR =   ($80|1<<(EngDirL-1))					;0b10100000 Turn Right Action Code
.equ	TurnL =   ($80|1<<(EngDirR-1))					;0b10010000 Turn Left Action Code
.equ	Halt =    ($80|1<<(EngEnR-1)|1<<(EngEnL-1))		;0b11001000 Halt Action Code
.equ	Freeze =  0b11111000							;0b11111000 Freeze Action Code
.equ	D0 = 0b11111110									;Defintions for polling mode PORTD input
.equ	D1 = 0b11111101
.equ	D2 = 0b11111011									;Skipping D3 bc USART1 Tx 
.equ	D4 = 0b11101111
.equ	D5 = 0b11011111
.equ	D6 = 0b10111111
;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt
;.org	$0002
;		rcall TxMovFwd			; TxMovFwd at INT0
;		reti					
;.org	$0004 
;		rcall TxMovBck			; TxMovBck at INT1
;		reti
;.org	$0006 
;		rcall TxTurnR			; TxTurnR at INT2
;		reti
;.org	$000A
;		rcall TxTurnL			; TxTurnL at INT4 (Skipping INT3 bc TX1 is at PD3)
;		reti
;.org	$000C
;		rcall TxHalt			; TxHalt at INT5
;		reti
;.org	$000E					; TxFreeze at INT6
;		rcall TxFreeze
;		reti				
								; TxComplete Interrupt Vector

.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
	;Stack Pointer (VERY IMPORTANT!!!!)
	ldi mpr, high(RAMEND)
	out SPH, mpr
	ldi mpr, low(RAMEND)
	out SPL, mpr
	;I/O Ports
	;Init PORT D for input
	ldi mpr, (1<<PD3)				;Set Port D pin 3 (TXD1) for output
	out DDRD, mpr					;Set Port D other pins to input
	;Enable pullup resistors
	ldi mpr, 0b11110111		;Disable pull up on pin 3 (TXD1)
	out PORTD, mpr
	;USART1
		;Set double data rate for error checking
		ldi mpr, (1<<U2X1)
		sts UCSR1A, mpr
		;Set baudrate at 2400bps (If not using U2X1 set to 416)
		lds mpr, UBRR1H
		ori mpr, high(832)		;bits 7-4 are reserved on UBRR1H so high of 832 is ord with previous val
		sts UBRR1H, mpr			;Store back into UBRR1H
		ldi mpr, low(832)		
		sts UBRR1L, mpr
		;Enable transmitter
		ldi mpr, (1<<TXEN1) ;| 1<<TXCIE1)  ;Enable Transmitter
		sts UCSR1B, mpr
		;Set frame format: 8 data bits, 2 stop bit, asynchronous, no parity, 
		ldi mpr, (1<<USBS0 | 1<<UCSZ11 | 1<<UCSZ10)
		sts UCSR1C, mpr
	;Other

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
		in mpr, PIND	;Take in PIND values into mpr to compare to button press
		cpi mpr, D0		;Compare with D0 to see if button 0 was pressed
		brne BckTest	;If not button 0 try button 1
		rcall TxMovFwd	;If button 0 call TxMovFwd
		BckTest:		
		cpi mpr, D1		;Compare D1 to see if button 1 was pressed
		brne TurnRTest	;If not button 1 try button 2
		rcall TxMovBck	;If button 1 call TxMovBck
		TurnRTest:
		cpi mpr, D2		;Compare with D2 to see if button 2 was pressed
		brne TurnLTest  ;If not button 2 try button 4
		rcall TxTurnR	;If button 2 call TxTurnR
		TurnLTest:
		cpi mpr, D4		;Compare with D4 to see if button 4 was pressed
		brne HaltTest	;If not button 4 try button 5
		rcall TxTurnL	;If button 4 call TxTurnL
		HaltTest:
		cpi mpr, D5		;Compare with D5 to see if button 5 was pressed
		brne FreezeTest	;If not button 5 try button 6
		rcall TxHalt	;If button 5 call TxHalt
		FreezeTest:
		cpi mpr, D6		;Compare with D6 to see if button 6 was pressed
		brne MAIN		;If not button 6 go back to beginning
		rcall TxFreeze	;If button 6 call TxFreeze
		rjmp MAIN 
		

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;----------------------------------------------------------------
; Sub:	USART_Transmit
; Desc:	Transmits whatever is in register r17 Using USART1
;----------------------------------------------------------------
USART_Transmit:
	lds mpr, UCSR1A		;Loads value of UCSR1A into mpr
	sbrs mpr, UDRE1		;Loops until UDR1 is empty
	rjmp USART_Transmit	;If UDRE1 is set UDR1 is empty, if UDRE1 is cleared UDR1 is written
	sts UDR1, r17		;move data to tx data buffer and send it
	ret
;----------------------------------------------------------------
; Sub:	TxFreeze
; Desc:	Transmits action code for Freeze to specified bot address
;----------------------------------------------------------------
TxFreeze:
	rcall WAIT_FUNC		;To compensate for debounce
	ldi r17, Freeze		;Loads Freeze action code into r17
	rcall TxAction		;Transmits bot id and action code
	ret
;----------------------------------------------------------------
; Sub:	TxMovFwd
; Desc:	Transmits action code for MovFwd to specified bot address
;----------------------------------------------------------------
TxMovFwd:
	rcall WAIT_FUNC		
	ldi r17, MovFwd
	rcall TxAction
	ret
;----------------------------------------------------------------
; Sub:	TxMovBck
; Desc:	Transmits action code for MovBck to specified bot address
;----------------------------------------------------------------
TxMovBck:
	rcall WAIT_FUNC
	ldi r17, MovBck
	rcall TxAction
	ret
;----------------------------------------------------------------
; Sub:	TxTurnR
; Desc:	Transmits action code for TurnR to specified bot address
;----------------------------------------------------------------
TxTurnR:
	rcall WAIT_FUNC
	ldi r17, TurnR
	rcall TxAction
	ret
;----------------------------------------------------------------
; Sub:	TxTurnL
; Desc:	Transmits action code for halt to specified bot address
;----------------------------------------------------------------
TxTurnL:
	rcall WAIT_FUNC
	ldi r17, TurnL
	rcall TxAction
	ret
;----------------------------------------------------------------
; Sub:	TxHalt
; Desc:	Transmits action code for halt to specified bot address
;----------------------------------------------------------------
TxHalt:
	rcall WAIT_FUNC			;Waits to prevent debouncing
	ldi r17, Halt			;Loads halt action code
	rcall TxAction
	ret
;----------------------------------------------------------------
; Sub:	TxAction
; Desc:	Transmits action code for any given action to specified bot address, precondition that r17 contains action code
;----------------------------------------------------------------
TxAction:
	rcall TxRobotAddr			;transmits robot address
	rcall USART_Transmit		;transmits data held in r17
	ret 
;----------------------------------------------------------------
; Sub:	TxRobotAddr
; Desc:	Transmits bot address over USART 1
;----------------------------------------------------------------
TxRobotAddr:
	push r17				; pushes r17 onto the stack so previous transmission data will not be overriden
	ldi r17,$0F				; Making up this number to be the specified robot address
	rcall USART_Transmit	; transmits address
	pop r17 
	ret
;----------------------------------------------------------------
; Sub:	WAIT_FUNC
; Desc:	Wait for r22*10ms. R22 = 10, wait 100ms. 
;----------------------------------------------------------------
WAIT_FUNC:
		ldi		r22, 10
Loop:	ldi		r24, 224		; load r24 register
OLoop:	ldi		r23, 237		; load r23 register
ILoop:	dec		r23			; decrement r23     
		brne	ILoop			; Continue Inner Loop
		dec		r24			; decrement r24
		brne	OLoop			; Continue Outer Loop
		dec		r22			; Decrement r22 
		brne	Loop			; Continue Wait loop	
		ret		
;***********************************************************
;*	Stored Program Data
;***********************************************************

;***********************************************************
;*	Additional Program Includes
;***********************************************************