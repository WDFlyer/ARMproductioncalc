.DEF	NUM = R16					;numerator
.DEF	DENO = R17					;denominator
.DEF	QUOT = R18					;quotient
.DEF	RATIO = R19					;ratio to reach product
.DEF	RATIOL = R0					;low byte affter multiplication
.DEF	RATIOH = R1					;high byte after multiplication
.DEF	MAXP = R20					;maximum product
.DEF	MAXPL = R21					;reserved for lower byte of MAXP
.DEF	MAXPH = R22					;reserved for higher byte of MAXP
.SET	MBC = 100						;most basic component
.SET	PMP = 10						;previous maximum product

		LDI RATIO, 2				;give RATIO a value
;**************************************************************************************************************

		LDI NUM, MBC				;divide MBC by PMP
		LDI DENO, PMP
		CLR QUOT
L1:		INC QUOT
		SUB NUM, DENO
		BRCC L1
		DEC QUOT
		ADD NUM, DENO

		MOV MAXP, QUOT				;establish R20 as quotient location
		MUL RATIO, MAXP				;multiply quotient by RATIO

		LDI NUM, MBC				;divide MBC by RATIO
		MOV DENO, RATIOL
		CLR QUOT
L2:		INC QUOT
		SUB NUM, DENO
		BRCC L2
		DEC QUOT
		ADD NUM, DENO

		MOV MAXP, QUOT				;establish R20 as quotient location
;******************************************************************************************************************

		STS 0x100, MAXP				;store MAXP in storage
		LDS	MAXPL, 0x100
		CLC							;clear carry flag just in case
		LSL MAXPL					;shift MAXPL to isolate the lower nibble
		LSL MAXPL
		LSL MAXPL
		LSL MAXPL
		CLC
		LSR MAXPL
		LSR MAXPL
		LSR MAXPL
		LSR MAXPL
		LDS MAXPH, 0x100
		CLC							;clear carry flag just in case
		LSR MAXPH					;shift MAXPH to isolate the higher nibble
		LSR MAXPH
		LSR MAXPH
		LSR MAXPH

		CPI MAXPH, 0				;skips to the transformation section
		BREQ TRN
;*******************************************************************************************************************

		LDI R27, 0
		LDI R28, 0					;offset hexidecimal
		LDI R29, 6

		
		MOV R30, MAXPH
HEXT:	CPI R30, 2					;additional offset by amount of tens
		BRSH LFB
		BRCS BEC
LFB:	DEC R30
		ADD R27, R29
		SEC
		BRCS HEXT

BEC:	SBRS MAXPH, 4
		SUBI MAXP, 6

COUNT:	ADD R28, R29				;placeholder multiplier
		DEC MAXPH
		BRNE COUNT

		ADD MAXP, R28
		ADD MAXP, R27				;corrected value in BCD
;******************************************************************************************************************

		STS 0x100, MAXP				;store MAXP in storage
		LDS	MAXPL, 0x100
		CLC							;clear carry flag just in case
		LSL MAXPL					;shift MAXPL to isolate the lower nibble
		LSL MAXPL
		LSL MAXPL
		LSL MAXPL
		CLC
		LSR MAXPL
		LSR MAXPL
		LSR MAXPL
		LSR MAXPL
		LDS MAXPH, 0x100
		CLC							;clear carry flag just in case
		LSR MAXPH					;shift MAXPH to isolate the higher nibble
		LSR MAXPH
		LSR MAXPH
		LSR MAXPH
;********************************************************************************************************************

TRN:	LDI R30, 0
		CPI MAXPL, 0				;determines which transformation each number should have
		BREQ BIN0
		CPI MAXPL, 1
		BREQ BIN1
		CPI MAXPL, 2
		BREQ BIN2
		CPI MAXPL, 3
		BREQ BIN3
		CPI MAXPL, 4
		BREQ BIN4
		CPI MAXPL, 5
		BREQ BIN5
		CPI MAXPL, 6
		BREQ BIN6
		CPI MAXPL, 7
		BREQ BIN7
		CPI MAXPL, 8
		BREQ BIN8
		CPI MAXPL, 9
		BREQ BIN9
		LDI R30, 1					;for adding the carry for when MAXPL exceeds 9
		CPI MAXPL, 10
		BREQ BIN0
		CPI MAXPL, 11
		BREQ BIN1
		CPI MAXPL, 12
		BREQ BIN2
		CPI MAXPL, 13
		BREQ BIN3
		CPI MAXPL, 14
		BREQ BIN4
		CPI MAXPL, 15
		BREQ BIN5

BIN0:	LDI MAXPL, 0b00111111		;transforms into arabic number
		BREQ PARTH
BIN1:	LDI MAXPL, 0b00000110
		BREQ PARTH
BIN2:	LDI MAXPL, 0b01011011
		BREQ PARTH
BIN3:	LDI MAXPL, 0b01001111
		BREQ PARTH
BIN4:	LDI MAXPL, 0b01100110
		BREQ PARTH
BIN5:	LDI MAXPL, 0b01101101
		BREQ PARTH
BIN6:	LDI MAXPL, 0b01111101
		BREQ PARTH
BIN7:	LDI MAXPL, 0b00000111
		BREQ PARTH
BIN8:	LDI MAXPL, 0b01111111
		BREQ PARTH
BIN9:	LDI MAXPL, 0b01100111

PARTH:	ADD MAXPH, R30
		CPI MAXPH, 0				;determines which transformation each number should have
		BREQ BIN00
		CPI MAXPH, 1
		BREQ BIN11
		CPI MAXPH, 2
		BREQ BIN22
		CPI MAXPH, 3
		BREQ BIN33
		CPI MAXPH, 4
		BREQ BIN44
		CPI MAXPH, 5
		BREQ BIN55
		CPI MAXPH, 6
		BREQ BIN66
		CPI MAXPH, 7
		BREQ BIN77
		CPI MAXPH, 8
		BREQ BIN88
		CPI MAXPH, 9
		BREQ BIN99
		CPI MAXPH, 10				;since only 2 digits are supported, exceeding 9 results in error
		BREQ ERROR
		CPI MAXPH, 11
		BREQ ERROR
		CPI MAXPH, 12
		BREQ ERROR
		CPI MAXPH, 13
		BREQ ERROR
		CPI MAXPH, 14
		BREQ ERROR
		CPI MAXPH, 15
		BREQ ERROR

BIN00:	LDI MAXPH, 0b00111111		;transforms into arabic number
		BREQ MAIN
BIN11:	LDI MAXPH, 0b00000110
		BREQ MAIN
BIN22:	LDI MAXPH, 0b01011011
		BREQ MAIN
BIN33:	LDI MAXPH, 0b01001111
		BREQ MAIN
BIN44:	LDI MAXPH, 0b01100110
		BREQ MAIN
BIN55:	LDI MAXPH, 0b01101101
		BREQ MAIN
BIN66:	LDI MAXPH, 0b01111101
		BREQ MAIN
BIN77:	LDI MAXPH, 0b00000111
		BREQ MAIN
BIN88:	LDI MAXPH, 0b01111111
		BREQ MAIN
BIN99:	LDI MAXPH, 0b01100111
		BREQ MAIN

ERROR:	LDI MAXPH, 0b01111001		;prints E for the high byte
;*******************************************************************************************************************

MAIN:	CLC							;clears carry flag
		CLZ							;clears zero flag
		SBRC MAXPH, 0				;if bit 0 is 0, skip next line
		CALL LHF					;calls low-high fix (LHF)
		BREQ FINAL					;branch to FINAL if zero flag is set
		LSR MAXPH					;shifts MAXPH to the right

FINAL:	LDI R24,0xFF				
		OUT DDRD, R24				;all pins active
		OUT DDRB, R24
		OUT PORTD, MAXPL			;the selected arabic number
		OUT PORTB, MAXPH

END:	RJMP END

LHF:	LSR MAXPH					;shifts MAXPH to the right
		SBR MAXPL, 0x80				;sets bit 7 for MAXPL
		SEZ							;sets zero flag
		RET							;returns to CALL LHF