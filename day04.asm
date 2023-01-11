.const total		= $fb			// 16bit, $0000
.const input_ptr	= $39			// pointer to input data table
.const ones			= $2			// temporary holder for a ones digit

.const range1_start	= $3			// Parsed range start and end points
.const range1_end	= $4
.const range2_start	= $5
.const range2_end	= $6

.const LF			= $0a			// ASCII code for Line Feed

* = $0801 "Basic Header"
				.word start, input; .byte $9e; .text "2061"; .byte 0,0,0

* = * "Sum of priorities of items that exist in both compartments of rucksacks"
start:			ldy #0				// Read two ranges from a line
				jsr read_number
				stx range1_start
				jsr read_number
				stx range1_end
				jsr read_number
				stx range2_start
				jsr read_number
				stx range2_end
				
				tya					// Move input pointer to beginning of next line
				clc
				adc input_ptr
				sta input_ptr
				bcc !+
				inc input_ptr+1
				
				/**
					If range ends are equal, one of them always fits to the other.
					If range starts are equal, one of them always fits to the other.
					If range1_start < range2_start, range1_end must be >= range2_end for 2 to fit 1.
					Otherwise, range2_end must be >= range1_end for 1 to fit 2.

					BCC = A is less than number
					BCS = A >= number
				 */
				
			!:
					lda range1_start
					cmp range2_start
					beq fits				// Range starts are equal
					bcc is_r1_end_bigger
					// r1 start > r2 start. Is r2 end larger or equal than r1 end? 
					lda range2_end
					cmp range1_end
					bcs fits				// r2 end is larger or equal than r1 end
					bcc start				// r2 end is smaller than r1 end, no fit
is_r1_end_bigger:	lda range1_end
					cmp range2_end
					bcc start				// r1 end is smaller than r2 end, no fit

			fits:	inc total
					bne start
					inc total+1
					bne start


				
read_number:	lax (input_ptr),y	// Read 1st digit (either ones or tens)
				beq finish			// If 0, jump to displaying the result
				iny
				lda (input_ptr),y
				iny
				cmp #'0'			// Is A at least char '0' (a number)?
				bcc one_digit		// if not (A = '-' or ',' or LF), X = single digit number
				iny					// next char isn't a number, skip
				sta ones			// Temporarily save ones
				txa					// shift 1st digit to tens, as we have a two-digit number
				asl
				asl
				asl
				asl
				clc
				adc ones			// add ones to complete the two-digit number
				tax
	one_digit:	rts					// X holds the complete number
				
				
finish:			ldx total			// print total as decimal number
				lda total+1
				jsr $bdcd
				jmp *
				
* = * "Input Data"
input:
				.import binary "input/day04_input.txt"
				// .import binary "input/day04_input_test.txt"	// Expected: 2
				// .import binary "input/day04_input_test_better.txt"	// Expected: 5
				.byte 0 // End of table
* = * "End"
