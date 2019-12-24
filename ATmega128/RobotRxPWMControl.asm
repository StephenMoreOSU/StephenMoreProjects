;***********************************************************
;*
;*	RobotRxPWMControl.asm
;*
;*	Handles increasing and decreasing speeds, replacing freeze
;*  and halt. 
;*
;***********************************************************
;*
;*	 Author: Stephen more and Braam Beresford
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
.def    speed		= r21
.def	timerTime   = r22

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
.org	$001C	;Vector for Timer1 if using Timer3 use $003A
		jmp TEST
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

	ldi mpr, $00
	out TCCR1A, mpr	;If Timer3 change to TCCR3A, TCCR3B and use sts
	ldi mpr, $04 ;Sets prescale to 256
	out TCCR1B, mpr
	ldi mpr, 0b00000100 ;Sets overflow interrupt enable (TOV1) 
	out TIMSK, mpr		; If Timer3 is used use ETIMSK with 0b00000100 and sts
	
	;I/O
	; Initialize Port B for output
   ldi mpr, 0xFF 
		out DDRB, mpr
		ldi mpr, 0x00
		out PORTB, mpr


    ; Initialize Port D for input
    ldi		mpr, (0<<WskrL)|(0<<WskrR)		; Set Port D Data Direction Register
    out		DDRD, mpr		; for input
    ldi		mpr, (1<<WskrL)|(1<<WskrR)		; Initialize Port D Data Register
    out		PORTD, mpr		; so all Port D inputs are Tri-State

	;USART1
	;Set baudrate at 2400bps
	;Enable receiver and enable receive interrupts
	;Set frame format: 8 data bits, 2 stop bits

    ; Set baud rate to 2400 with 16Mhz clock rounded to closest int
    //ldi mpr, high(0x01A0)
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
    
    

    ldi mpr, 0b00000010 | 0b00001000 | 0b00100000 | 0b10000000
    sts EICRA, mpr

	;Enable interrupt on buttons
    ldi mpr, 0b000000011
	out EIMSK, mpr


	

	; Configure 8-bit Timer/Counters, no prescaling, Fast PWM, clear on compare match
	ldi mpr, 0b01101001
	out TCCR0, mpr

	; Configure 8-bit Timer/Counters, no prescaling, Fast PWM, clear on compare match
	ldi mpr, 0b01101001				
	out TCCR2, mpr

    ;Other

    ldi		speed, 0b11110000		; Load Move Forward Command
    out		PORTB, speed		; Send command to motors

	; Set initial speed, display on Port B pins 3:0
		ldi mpr, 255
		out OCR0, mpr
		out OCR2, mpr
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
USART_Receive:
    push mpr
    clr mpr

    lds mpr, UDR1
    cpi mpr, FreezeCode					;Check if freeze code
    ;breq Freeze

	mov addressReg, mpr
	

Receive_Loop:
	lds mpr, UCSR1A
    sbrs mpr, RXC1
    rjmp Receive_Loop

    lds commandReg, UDR1			;;Get command

    ldi mpr, BotAddress
  ;  ori mpr, 0b10_00_00_00
    cpse mpr, addressReg
    rjmp End_Of_USART


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
    breq IncSpeed   

	ldi mpr, 0b11111000 ;Freeze Code
	cp mpr, commandReg
    breq DecSpeed 



End_of_USART:
    ldi mpr, 0xFF				; Clear the interrupt register
	out EIFR, mpr

    pop mpr
    ret


Move_Forward:
	in mpr, PORTB
	andi mpr, 0b00_00_00_00
	ori mpr, MovFwd
   ; ldi		mpr, MovFwd		; Load Move Forward Command
    out		PORTB, mpr		; Send command to motors
	rjmp End_of_USART
    

Move_Backward:
    ldi		mpr, MovBck		; Load Move Back Command
    out		PORTB, mpr		; Send command to motors
	rjmp End_of_USART


Turn_Right:
in mpr, PORTB
	andi mpr, 0b00_00_00_00
	ori mpr, TurnR
	;or mpr, speed
  ;  ldi		mpr, TurnR		; Load Move Right Command
    out		PORTB, mpr		; Send command to motors
	rjmp End_of_USART
    

Turn_Left:
in mpr, PORTB
	andi mpr, 0b00_00_00_00
	ori mpr, TurnL
	or mpr, speed
 ;   ldi		mpr, TurnL		; Load Move Left Command
    out		PORTB, mpr		; Send command to motors
	rjmp End_of_USART
    

IncSpeed:
		;Wait, prevent double bounce of button
		ldi  timerTime, 20
		//rcall WAIT_FUNC_ONE_SEC          

		;Check not at max speed already
		in mpr, OCR0
		cpi mpr, 0

		;If max, reset interrupt and return
		breq End_of_USART	

		subi mpr, 17
		out OCR0, mpr			;Update new speed by subtracting 17 in both OCR0
		out OCR2, mpr			;and OCR2. 17 because 255/25 = 17

		inc speed;				;Increment speed displayed on the LEDs
		in mpr, PORTB
		andi mpr, 0b01_10_00_00
		ori mpr, 0b10_01_00_00			;Update the new speed while displaying PWM
		or mpr, speed
		out PORTB, mpr				;Push to LEDs

		ldi mpr, 0xFF				; Clear the interrupt register
		out EIFR, mpr
		rjmp End_of_USART
    
Freeze:
    in mpr, PORTB
    push mpr
    

    ldi		mpr, Halt		; Load Halt Command
    out		PORTB, mpr		; Send command to motors

	inc freezeCount
    cpi freezeCount, 3
    breq Freeze_Forever

	ldi timerTime, 100
    rcall WAIT_FUNC_ONE_SEC
	rcall WAIT_FUNC_ONE_SEC
	rcall WAIT_FUNC_ONE_SEC
	rcall WAIT_FUNC_ONE_SEC
	rcall WAIT_FUNC_ONE_SEC

    pop mpr
    out PORTB, mpr
	rjmp End_of_USART

Freeze_Forever:
	cli						;Turn off interrupts
	ldi mpr, $FF
	out PORTB, mpr
    rjmp Freeze_Forever

DecSpeed:
		;Wait, prevent double bounce of button
		ldi timerTime, 30
		//rcall WAIT_FUNC_ONE_SEC       

		;Check not at min speed already  
		in mpr, OCR0
		cpi mpr, 255

		;If min, reset interrupt and return
		breq End_of_USART


		ldi r30, 17
		add mpr, r30				;Update new speed by adding 17 in both OCR0
		out OCR0, mpr				;and OCR2. 17 because 255/25 = 17
		out OCR2, mpr

		dec speed;					;Decrement speed displayed on the LEDs
		in mpr, PORTB
		andi mpr, 0b01_10_00_00
		ori mpr, 0b10_01_00_00			;Update the new speed while displaying PWM
		or mpr, speed
		out PORTB, mpr				;Push to LEDs

		ldi mpr, 0xFF				; Clear the interrupt register
		out EIFR, mpr
		rjmp End_of_USART


Wait_Transmit:
		lds mpr, UCSR1A
		sbrs mpr, TXC1
		rjmp Wait_Transmit


	lds    mpr, UCSR1A 
    sbr    mpr, 1<<TxC1                   ; Clear any interrupt. 
    sts    UCSR1A, mpr 
	

	; Enable receive and its interrupt, disable transmit
	ldi mpr, (1 << RXCIE1 | 1 << RXEN1 | 0 << TXEN1)
    sts UCSR1B, mpr

	rjmp End_of_USART




Bump_Left:
	push mpr
	 ldi mpr, (0 << RXCIE1 | 0 << RXEN1)
	in mpr, PORTB
	push mpr

	andi mpr, 0b10_01_11_11
	;or mpr, speed
	ori mpr, MovBck
    out		PORTB, mpr		; Send command to motors
	ldi timerTime, 255
	rcall WAIT_FUNC_ONE_SEC


	andi mpr, 0b10_01_11_11
	ori mpr, TurnL
	;or mpr, speed
    out		PORTB, mpr		; Send command to motors
	ldi timerTime, 255
	rcall WAIT_FUNC_ONE_SEC


	ldi    mpr, MovFwd		; Load Move Forward Command
    out		PORTB, mpr		; Send command to motors

	ldi mpr, (1 << RXCIE1 | 1 << RXEN1)
	ldi mpr, 0xFF				; Clear the interrupt register
	out EIFR, mpr

	pop mpr
	out PORTB, mpr
	pop mpr
	ret

Bump_Right:
	push mpr
	 ldi mpr, (0 << RXCIE1 | 0 << RXEN1)
	in mpr, PORTB
	push mpr

	andi mpr, 0b10_01_11_11
	;or mpr, speed
	ori mpr, MovBck
    out		PORTB, mpr		; Send command to motors
	ldi timerTime, 255
	rcall WAIT_FUNC_ONE_SEC


	andi mpr, 0b10_01_11_11
	ori mpr, TurnR
	;or mpr, speed
    out		PORTB, mpr		; Send command to motors
	ldi timerTime, 255
	rcall WAIT_FUNC_ONE_SEC


	ldi    mpr, MovFwd		; Load Move Forward Command
    out		PORTB, mpr		; Send command to motors

	ldi mpr, (1 << RXCIE1 | 1 << RXEN1)
	ldi mpr, 0xFF				; Clear the interrupt register
	out EIFR, mpr

	pop mpr
	out PORTB, mpr
	pop mpr
	ret




WAIT_FUNC_ONE_SEC:
		ldi		r22, 40
Loop:	ldi		r24, 224		; load r24 register
OLoop:	ldi		r23, 237		; load r23 register
ILoop:	dec		r23			; decrement r23     
		brne	ILoop			; Continue Inner Loop
		dec		r24			; decrement r24
		brne	OLoop			; Continue Outer Loop
		dec		r22			; Decrement r22 
		brne	Loop			; Continue Wait loop	
		ret		

TC_WAIT_FUNC:
	  ldi mpr, high(3036)
	  out TCNT1H, mpr		;If using Timer3 replace with TCNT3H, TCNT3L using sts
	  ldi mpr, low(3036)
	  out TCNT1L, mpr
repeat: rjmp repeat		;Interrupt triggered when TOV1 is set
TEST: reti



;***********************************************************
;*	Stored Program Data
;***********************************************************

;***********************************************************
;*	Additional Program Includes
;***********************************************************

