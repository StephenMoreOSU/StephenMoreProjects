;***********************************************************
;*
;*	RobotRx.asm
;*
;*  This is the receiver source code. It handles receiving
;*  USART transmitted data. The bot checks if USART is using
;*  the correct address. If it is the bot can interpret a number
;*  of commands like halt and turn. There is also functionality 
;*  for it to freeze no matter the address
;*
;***********************************************************
;*
;*	 Author: Braam Beresford and Stephen More
;*	   Date: 12/04/2019
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multi-Purpose Register
.def    freeCount = r17
.def    addressReg = r18
.def    commandReg = r19
.def    freezeCount = r20

.equ	WskrR = 0				; Right Whisker Input Bit
.equ	WskrL = 1				; Left Whisker Input Bit
.equ	EngEnR = 4				; Right Engine Enable Bit
.equ	EngEnL = 7				; Left Engine Enable Bit
.equ	EngDirR = 5				; Right Engine Direction Bit
.equ	EngDirL = 6				; Left Engine Direction Bit

.equ	BotAddress = $0f
.equ    FreezeCode = 0b01010101

;/////////////////////////////////////////////////////////////
;These macros are the values to make the TekBot Move.
;/////////////////////////////////////////////////////////////
.equ	MovFwd =  (1<<EngDirR|1<<EngDirL)	;0b01100000 Move Forward Action Code
.equ	MovBck =  $00						;0b00000000 Move Backward Action Code
.equ	TurnR =   (1<<EngDirL)				;0b01000000 Turn Right Action Code
.equ	TurnL =   (1<<EngDirR)				;0b00100000 Turn Left Action Code
.equ	Halt =    (1<<EngEnR|1<<EngEnL)		;0b10010000 Halt Action Code

;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt

.org $0002
		rcall Bump_Left          ;Bump left
		reti
		
.org $0004
		rcall Bump_Right          ; Bump right
		reti

.org    $003C                   ; Rx complete interrupt
        rcall USART_Receive
        reti

.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
	;Stack Pointer initiliazation
    ldi R16, low(RAMEND); //Load lower ramend into stack pointer
    out SPL, R16;
    ldi R16, high(RAMEND); //Load high ramend into stack pointer
    out SPH, R16;
    clr R16;

	;I/O
	; Initialize Port B for output
    ldi mpr, (1<<EngEnL)|(1<<EngEnR)|(1<<EngDirR)|(1<<EngDirL) 
    out DDRB, mpr
    ldi mpr, (0<<EngEnL)|(0<<EngEnR)|(0<<EngDirR)|(0<<EngDirL)
    out PORTB, mpr


    ; Initialize Port D for input
    ldi		mpr, (0<<WskrL)|(0<<WskrR)		; Set Port D Data Direction Register
    out		DDRD, mpr		; for input
    ldi		mpr, (1<<WskrL)|(1<<WskrR)		; Initialize Port D Data Register
    out		PORTD, mpr		; so all Port D inputs are Tri-State

	;USART1
	;Set baudrate at 2400bps
    ; Set baud rate to 2400 with 16Mhz clock rounded to closest int
	lds mpr, UBRR1H      ;Save reserved bits
	ori mpr, high(832)
    sts UBRR1H, mpr
    ldi mpr, low(832)
    sts UBRR1L, mpr


    ; Enable recieve interrupt and turn on reciever
    ldi mpr, (1 << RXCIE1 | 1 << RXEN1)
    sts UCSR1B, mpr

    ; Enable asynchronous, no parity, 2 stop bits
    ldi mpr, (0<<UMSEL1 | 0<<UPM11 | 0<<UPM10 | 1<<USBS1)
    ; Set 8 bits of data
    ori mpr, (0<<UCSZ12 | 1<<UCSZ11 | 1<<UCSZ10 | 0 << UCPOL1)
    sts UCSR1C, mpr

	;Double data rate
	ldi mpr, (1<<U2X1)
	sts UCSR1A, mpr

	;External Interrupts
	;Set the External Interrupt Mask
	;Set the Interrupt Sense Control to falling edge detection
    
    ldi mpr, 0b00000010 | 0b00001000 
    sts EICRA, mpr
    ldi mpr, 0b000000011
	out EIMSK, mpr

    ;Other

    ldi		mpr, MovFwd		; Load Move Forward Command
    out		PORTB, mpr		; Send command to motors

	clr freezeCount
    sei

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
		rjmp	MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;----------------------------------------------------------------
; Sub:	USART_REceive
; Desc: Handles when the USART recieve interrupt is triggered.
;       Checks the address and runs commands if appropriate.
;       Also handles receiving a freeze command.
;----------------------------------------------------------------
USART_Receive:
	;Save state of MPR
    push mpr
    clr mpr
	
	; Fetch first 8 bits received
    lds mpr, UDR1

	;Check if freeze code
    cpi mpr, FreezeCode					
    breq Freeze

	mov addressReg, mpr
	
	; Wait to receive next 8 bits of data 
Receive_Loop:
	lds mpr, UCSR1A
    sbrs mpr, RXC1
    rjmp Receive_Loop

	; Get the command
    lds commandReg, UDR1		

	; Verify that the address is correct
    ldi mpr, BotAddress
    cpse mpr, addressReg
    rjmp End_of_USART

	; Decision tree for what to do next
	; Compare received command against 
	; what is expected

    ; At this point valid address
    ldi mpr, 0b10110000 ; Move Forward
    cp mpr, commandReg
    breq Move_Forward

    ldi mpr, 0b10000000 ; Move backward
    cp mpr, commandReg
    breq Move_Backward

    ldi mpr, 0b10100000 ; Turn right
    cp mpr, commandReg
    breq Turn_Right

    ldi mpr, 0b10010000 ; Turn left
    cp mpr, commandReg
    breq Turn_Left

    ldi mpr, 0b11001000 ; Halt
    cp mpr, commandReg
    breq Halt_Bot   

	ldi mpr, 0b11111000 ;Freeze Code
	cp mpr, commandReg

	ldi mpr, (1 << RXCIE1 | 1 << RXEN1)
    sts UCSR1B, mpr
    breq Send_Freeze 



End_of_USART:
    ldi mpr, 0xFF				; Clear the interrupt register
	out EIFR, mpr

    pop mpr
    ret



;----------------------------------------------------------------
; Sub:	LED Routines
; Desc:	These load the correct LED configuration based on
;		the code received.
;----------------------------------------------------------------
Move_Forward:
    ldi		mpr, MovFwd		; Load Move Forward Command
    out		PORTB, mpr		; Send command to motors
	rjmp End_of_USART
    

Move_Backward:
    ldi		mpr, MovBck		; Load Move Back Command
    out		PORTB, mpr		; Send command to motors
	rjmp End_of_USART


Turn_Right:
    ldi		mpr, TurnR		; Load Move Right Command
    out		PORTB, mpr		; Send command to motors
	rjmp End_of_USART
    

Turn_Left:
    ldi		mpr, TurnL		; Load Move Left Command
    out		PORTB, mpr		; Send command to motors
	rjmp End_of_USART
    

Halt_Bot:
    ldi		mpr, Halt		; Load Halt Command
    out		PORTB, mpr		; Send command to motors
	rjmp End_of_USART
    
;----------------------------------------------------------------
; Sub:	Freeze
; Desc:	Freeze the bot for 5 seconds, if frozen three times
;		freeze forever
;----------------------------------------------------------------
Freeze:
	;Store previous state
    in mpr, PORTB
    push mpr
    

    ldi		mpr, Halt		; Load Halt Command
    out		PORTB, mpr		; Send command to motors

	; Check if frozen three times
	inc freezeCount
    cpi freezeCount, 3
    breq Freeze_Forever

	;Freeze for 5 seconds
	rcall WAIT_FUNC_ONE_SEC
	rcall WAIT_FUNC_ONE_SEC
	rcall WAIT_FUNC_ONE_SEC
	rcall WAIT_FUNC_ONE_SEC

	;Restore previos state
    pop mpr
    out PORTB, mpr
	rjmp End_of_USART


;----------------------------------------------------------------
; Sub:	Free_Forever
; Desc:	Enters infinite loop with halt LEDs to freeze bot
;----------------------------------------------------------------
Freeze_Forever:
	cli						;Turn off interrupts
	ldi		mpr, Halt	
	out PORTB, mpr
    rjmp Freeze_Forever



;----------------------------------------------------------------
; Sub:	Send_Freeze
; Desc:	Send the freeze code to other bots. Does not freeze
;		this bot
;----------------------------------------------------------------
Send_Freeze:
	; Debug code
	

	; Disable receive and its interrupt, enable transmit
	ldi mpr, (0 << RXCIE1 | 0 << RXEN1 | 1 << TXEN1)
    sts UCSR1B, mpr
	
	; Load freeze code into sending buffer
	ldi mpr, FreezeCode
	sts UDR1, mpr

	; Wait for transmit to complete
Wait_Transmit:
		lds mpr, UCSR1A
		sbrs mpr, TXC1
		rjmp Wait_Transmit

	;Clear the transmit interrupt
	lds    mpr, UCSR1A 
    sbr    mpr, 1<<TxC1                   
    sts    UCSR1A, mpr 
	

	; Enable receive and its interrupt, disable transmit
	ldi mpr, (1 << RXCIE1 | 1 << RXEN1 | 0 << TXEN1)
    sts UCSR1B, mpr

	rjmp End_of_USART





;----------------------------------------------------------------
; Sub:	Bump_Left
; Desc:	Handles functionality of the TekBot when the left whisker
;		is triggered. Bot backs up for one second, turns right 
;		for one second, then resumes what it was doing
;----------------------------------------------------------------
Bump_Left:
	push mpr
	in mpr, PORTB
	push mpr
	
	;Disable receive
	ldi mpr, (0 << RXCIE1 | 0 << RXEN1)
	sts UCSR1B, mpr

	ldi		mpr, MovBck		; Load Move Back Command
    out		PORTB, mpr		; Send command to motors
	rcall WAIT_FUNC_ONE_SEC

	ldi		mpr, TurnL		; Load Move Left Command
    out		PORTB, mpr		; Send command to motors
	rcall WAIT_FUNC_ONE_SEC


	ldi		mpr, MovFwd		; Load Move Forward Command
    out		PORTB, mpr		; Send command to motors


	pop mpr					;Restore state 
	out PORTB, mpr

	; Renable recieve
	ldi mpr, (1 << RXCIE1 | 1 << RXEN1)
	sts UCSR1B, mpr

	ldi mpr, 0xFF				; Clear the interrupt register
	out EIFR, mpr
	pop mpr
	ret


;----------------------------------------------------------------
; Sub:	Bump_Right
; Desc:	Handles functionality of the TekBot when the right whisker
;		is triggered. Bot backs up for one second, turns left 
;		for one second, then resumes what it was doing
;----------------------------------------------------------------
Bump_Right:
	push mpr
	in mpr, PORTB
	push mpr

	;Disable receive
	ldi mpr, (0 << RXCIE1 | 0 << RXEN1)
	sts UCSR1B, mpr

	ldi		mpr, MovBck		; Load Move Back Command
    out		PORTB, mpr		; Send command to motors
	rcall WAIT_FUNC_ONE_SEC

	ldi		mpr, TurnR		; Load Move Right Command
    out		PORTB, mpr		; Send command to motors
	rcall WAIT_FUNC_ONE_SEC


	ldi    mpr, MovFwd		; Load Move Forward Command
    out		PORTB, mpr		; Send command to motors


	pop mpr
	out PORTB, mpr

	; Renable recieve
	ldi mpr, (1 << RXCIE1 | 1 << RXEN1)
	sts UCSR1B, mpr


	ldi mpr, 0xFF				; Clear the interrupt register
	out EIFR, mpr

	pop mpr
	ret



;----------------------------------------------------------------
; Sub:	WAIT_FUNC_ONE_SEC
; Desc:	Causes a 1 second delay
;----------------------------------------------------------------
WAIT_FUNC_ONE_SEC:
		ldi		r22, 100
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
