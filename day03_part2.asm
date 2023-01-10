.const total		= $fb			// 16bit, $0000
.const input_ptr	= $39			// 16bit input table pointer
.const buffer1		= $4000			// Buffer addresses
.const buffer2		= $4100
.const buffer3		= $4200

.const LF			= $0a			// ASCII code for Line Feed
.const priorities	= priority_table - 'A'

* = $0801 "Basic Header"
				.word start, input; .byte $9e; .text "2061"; .byte 0,0,0

* = * "Sum of priorities of badges that exist in sets of three rucksacks"
start:			jsr line_to_buffer	// Read three lines to buffers
				sty s1_size
				inc buf_ptr+1
				jsr line_to_buffer
				sty s2_size
				inc buf_ptr+1
				jsr line_to_buffer
				sty s3_size
				dec buf_ptr+1
				dec buf_ptr+1
				
				ldy s1_size:#$ff	// Get char from buffer 1 and check if exists in 2 and 3
	next_char:	dey
				lda buffer1,y

				ldx s2_size:#$ff
			!:	dex
				bmi next_char		// No match in buffer 2, move on to the next char
				cmp buffer2,x
				bne !-

				ldx s3_size:#$ff
			!:	dex
				bmi next_char		// No match in buffer 3, move on to the next char
				cmp buffer3,x
				bne !-

match:			tay					// Match found, use it as an index to priorities table
				lda priorities, y	// Read priority for given char
				clc					// Add priority to the total
				adc total
				sta total
				bcc start
				inc total+1
				bcs start


line_to_buffer:	ldy #0				// Count chars on a line
			!:	lda (input_ptr),y
				beq done			// End of input data, print the result on screen
				sta buf_ptr:buffer1,y	// selfmodded buffer address
				iny
				cmp #LF				// Read until reaching end of line
				bne !-
				
				tya					// Move input pointer to beginning of next line
				clc
				adc input_ptr
				sta input_ptr
				bcc !+
				inc input_ptr+1
			!:	dey					// Y--, now holds # of chars in line
				rts


done:			ldx total			// print total as decimal number
				lda total+1
				jsr $bdcd			// EXPECTED: Part1 = 7817, Part2 = ???
				bvc *

// Lowercase item types a through z have priorities 1 through 26.
// Uppercase item types A through Z have priorities 27 through 52.
priority_table:	.fill 26, 27+i		// A-Z ($41-$5a) = priorities 27-52
				.fill 6, 0
				.fill 26, 1+i		// a-z ($61-$7a) = priorities 1-26
				
* = * "Input Data"
input:
				.import binary "input/day03_input.txt"
				// .import binary "input/day03_input_test.txt"	// expected: part1 = 157, part2 = 70
				.byte 0 // End of table
* = * "End"
