/**
	1 for Rock
	2 for Paper
	3 for Scissors
	0 if you lost
	3 if draw
	6 if you won

	Rock-Rock			$41-$58		1+3	D	01000001,01011000 = eor=11001	and=1000000	or=1011001
	Rock-Paper			$41-$59		2+6	W	01000001,01011001 = eor=11000	and=1000001	or=1011001
	Rock-Scissors		$41-$5a		3+0	L	01000001,01011010 = eor=11011	and=1000000	or=1011011
	Paper-Rock			$42-$58		1+0	L	01000010,01011000 = eor=11010	and=1000000	or=1011010
	Paper-Paper			$42-$59		2+3	D	01000010,01011001 = eor=11011	and=1000000	or=1011011
	Paper-Scissors		$42-$5a		3+6	W	01000010,01011010 = eor=11000	and=1000010	or=1011010
	Scissors-Rock		$43-$58		1+6	W	01000011,01011000 = eor=11011	and=1000000	or=1011011
	Scissors-Paper		$43-$59		2+0	L	01000011,01011001 = eor=11010	and=1000001	or=1011011
	Scissors-Scissors	$43-$5a		3+3	D	01000011,01011010 = eor=11001	and=1000010	or=1011011
 */
 
.const total		= $fb	// 16bit, $0000
.const input_ptr	= $39	// pointer to input data table

* = $0801 "Basic Header"
				.word init, input; .byte $9e; .text "2061"; .byte 0,0,0

* = * "Calculate total score according to the strategy plan"
init:
				// sei				// disable interrupts
				// lda #%00001011	// turn screen off
				// sta $d011
				inx
				stx $4258	// B X	1
				inx
				stx $4359	// C Y	2
				inx
				stx $415a	// A Z	3
				inx
				stx $4158	// A X	4
				inx
				stx $4259	// B Y	5
				inx
				stx $435a	// C Z	6
				inx
				stx $4358	// C X	7
				inx
				stx $4159	// A Y	8
				inx
				stx $425a	// B Z	9
				
readline:		lda (input_ptr),y
				beq done			// 0 = end of input
				iny
				iny
				sta pts+1			// A = HI byte of the points location
				lax (input_ptr),y	// X = offset from the HI00 points location
				lda pts:$ff00,x		// Selfmodded address to fetch the points
				iny
				iny
				bne !+
				inc input_ptr+1
			!:	clc
				adc total
				sta total
				bcc readline
				inc total+1
				bcs readline

done:			ldx total			// print total as decimal number
				lda total+1
				jsr $bdcd
				// 122125 cycles @ 985248 cycles per second = ~124ms
				// 115761 with screen turned off = actual cycles
				// cli				// enable interrupts
				// lda #%00011011	// turn screen on
				// sta $d011
				rts

* = * "Input Data"
input:			.import binary "input/day02_input.txt"
				.byte 0 // End of table
* = * "End"
