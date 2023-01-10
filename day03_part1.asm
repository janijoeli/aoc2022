.const total		= $fb			// 16bit, $0000
.const input_ptr	= $39			// pointer to input data table

.const LF			= $0a			// ASCII code for Line Feed
.const priorities	= priority_table - 'A'	// priority table incl. offset

* = $0801 "Basic Header"
				.word start, input; .byte $9e; .text "2061"; .byte 0,0,0

* = * "Sum of priorities of items that exist in both compartments of rucksacks"
start:			ldy #0				// Count chars on line
			!:	lda (input_ptr),y
				beq done
				iny
				cmp #LF
				bne !-
				
				sty bytes_read		// Save total # of bytes read for later
				dey
				sty read_index		// Save index to the end of 2nd rucksack
				tya
				lsr
				sta loop_count		// Save index to the end of 1st rucksack

	next_char:	dec read_index
				ldy read_index:#$ff	// Selfmodded # of chars
				lda (input_ptr),y	// Read char from 2nd rucksack
				
				ldy loop_count:#$ff	// Compare it to chars in 1st rucksack
			!:	dey
				bmi next_char		// No match in bottom half, check next char
				cmp (input_ptr),y
				bne !-

				tay					// Match found, use it as an index to priorities table
				lda priorities, y
				clc					// Add priority to the total
				adc total
				sta total
				bcc !+
				inc total+1

			!:	lda bytes_read:#$ff	// Line done, update input table pointer
				clc
				adc input_ptr
				sta input_ptr
				bcc start
				inc input_ptr+1
				bcs start
				
done:			ldx total			// print total as decimal number
				lda total+1
				jsr $bdcd			// EXPECTED: Part1 = 7817, Part2 = ???
				rts

// Lowercase item types a through z have priorities 1 through 26.
// Uppercase item types A through Z have priorities 27 through 52.
priority_table:	.fill 26, 27+i		// A-Z ($41-$5a) = priorities 27-52
				.fill 6, 0
				.fill 26, 1+i		// a-z ($61-$7a) = priorities 1-26
				
* = * "Input Data"
input:			.import binary "input/day03_input.txt"
				// .import binary "input/day03_input_test.txt"	// expected: 157
				// In the above example, the priority of the item type that appears in both
				// compartments of each rucksack is 16 (p), 38 (L), 42 (P), 22 (v), 20 (t), and
				// 19 (s); the sum of these is 157.
				.byte 0 // End of table
* = * "End"
