/**
	Part 1 rules:
	If range starts are equal, one of them always fits to the other.
	If range1_start < range2_start, range1_end must be >= range2_end for 2 to fit 1.
	If range1_start > range2_start, range2_end must be >= range1_end for 1 to fit 2.
	Part 2 rules:
	If range1 ends before r2 starts, or if range1 starts after r2 ends, they don't overlap.
	
	These two rulesets could be combined, i.e. test for any overlap first and then do less 
	tests to see if ranges completely overlap, but hey ho, on to the next one.
*/

.const fits_count		= $fb		// 16bit, $0000
.const overlaps_count	= $fd		// 16bit, $0000
.const input_ptr		= $39		// pointer to input data table
.const ones				= $2		// temporary holder for a ones digit

.const range1_start		= $3		// Parsed range start and end points
.const range1_end		= $4
.const range2_start		= $5
.const range2_end		= $6

.const LF				= $0a		// ASCII code for Line Feed

* = $0801 "Basic Header"
				.word start, input; .byte $9e; .text "2061"; .byte 0,0,0

* = * "Finding Fully or Partially Overlapping Ranges"
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
				bcc compare_ranges
				inc input_ptr+1
				
				// Part1 - testing for fully overlapping ranges
compare_ranges:	lda range1_start
				cmp range2_start
				beq fits			// Range starts are equal, one fits another
				bcc is_r1_longer	// r1 starts earlier, does it also end later?
				lda range2_end		// r1 starts later, does r2 end later?
				cmp range1_end
				bcs fits			// r2 ends at or after r1 end, fits
				bcc check_overlap	// r2 ends before r1, no fit
is_r1_longer:	lda range1_end
				cmp range2_end
				bcc check_overlap	// r1 ends before r2, no fit
		fits:	inc fits_count
				bne check_overlap
				inc fits_count+1
				bne check_overlap
				
				// Part2 - testing for partially overlapping ranges
check_overlap:	lda range1_end
				cmp range2_start
				bcc start			// r1 ends before r2 starts, r1 is fully below r2, no overlap
				lda range2_end
				cmp range1_start
				bcc start			// r2 ends before r1 starts, r1 is fully above r2, no overlap
				inc overlaps_count	// r1 is neither above or below r2, thus the ranges must overlap
				bne start
				inc overlaps_count+1
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
				
				
finish:			ldx fits_count			// print fits_count as decimal number
				lda fits_count+1
				jsr $bdcd
				jsr $aad7				// New line
				ldx overlaps_count		// print overlaps_count as decimal number
				lda overlaps_count+1
				jsr $bdcd
				jmp *
				
* = * "Input Data"
input:			.import binary "input/day04_input.txt"
				// .import binary "input/day04_input_test.txt"	// Expected: part1 = 2, part2 = 4
				// .import binary "input/day04_input_test_better.txt"	// Expected: part1 = 5, part2 = 7
				.byte 0 // End of table
* = * "End"
