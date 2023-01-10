.const total		= $fb	// 16bit, $0000
.const input_ptr	= $39	// pointer to input data table

* = $0801 "Basic Header"
				.word init, input; .byte $9e; .text "2061"; .byte 0,0,0

* = * "Calculate total score according to the strategy plan"
init:
				// PART 1 points table
				inx
				stx $4258	// B X	Paper-Rock			1
				inx
				stx $4359	// C Y	Scissors-Paper		2
				inx
				stx $415a	// A Z	Rock-Scissors		3
				inx
				stx $4158	// A X	Rock-Rock			4
				inx
				stx $4259	// B Y	Paper-Paper			5
				inx
				stx $435a	// C Z	Scissors-Scissors	6
				inx
				stx $4358	// C X	Scissors-Rock		7
				inx
				stx $4159	// A Y	Rock-Paper			8
				inx
				stx $425a	// B Z	Paper-Scissors		9
				
				jsr readline		// Calculate score
				jsr $aad7			// Linefeed kernal routine

				// PART 2 points table (some values don't change and thus aren't updated)
				ldx #2
				stx $4358	// C X	Scissors-Paper		2
				inx
				stx $4158	// A X	Rock-Scissors		3
				inx
				stx $4159	// A Y	Rock-Rock			4
				iny	// Y = 5 + 1
				sty $4359	// C Y	Scissors-Scissors	6
				iny
				sty $435a	// C Z	Scissors-Rock		7
				iny
				sty $415a	// A Z	Rock-Paper			8
				
				sty input_ptr+1		// Y = $08 aka input table address HI byte
				ldy #0				// Reset total score
				sty total
				sty total+1
				
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
				rts

* = * "Input Data"
input:			.import binary "input/day02_input.txt"
				.byte 0 // End of table
* = * "End"
