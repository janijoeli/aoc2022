.const screen 		= $0400	// Screen RAM location
.const tbl_ptr		= $39	// table pointer on ZP
.const set_sum		= $2	// sum of cals
.const highest_set	= $5	// highest sum of cals

* = $0801 "Basic Header"
// ----------------------------------------------------------------------------
//	BASIC HEADER
// ----------------------------------------------------------------------------
				.word main
				.word input; .byte $9e; .text "2061"; .byte $00
				.word $0000
// ----------------------------------------------------------------------------
//	FIND ANSWER
// ----------------------------------------------------------------------------
* = * "Finding Highest Valued Set"
main:			jsr $e544
				lda #0
				sta highest_set
				sta highest_set+1
				sta highest_set+2

next_set:		lda #0
				sta set_sum
				sta set_sum+1
				sta set_sum+2

next_in_set:	ldy #0
				lda (tbl_ptr), y
				cmp #$fe
				beq show_result
				cmp #$ff
				beq compare_sets
				pha
				iny
				lda (tbl_ptr), y
				pha
				iny
				lda (tbl_ptr), y
				pha
				lda tbl_ptr
				clc
				adc #3
				sta tbl_ptr
				bcc add_to_set
				inc tbl_ptr+1

add_to_set:		clc
				pla
				adc set_sum+2
				sta set_sum+2
				pla
				adc set_sum+1
				sta set_sum+1
				pla
				adc set_sum
				sta set_sum
				
				jmp next_in_set

compare_sets:	inc tbl_ptr
				bne !+
				inc tbl_ptr+1
			!:	lda highest_set
				cmp set_sum
				bne compare
				lda highest_set+1
				cmp set_sum+1
				bne compare
				lda highest_set+2
				cmp set_sum+2

compare:		bcc new_highest
				jmp next_set

new_highest:	lda set_sum
				sta highest_set
				lda set_sum+1
				sta highest_set+1
				lda set_sum+2
				sta highest_set+2
				jmp next_set

// ----------------------------------------------------------------------------
//	DISPLAY ANSWER
// ----------------------------------------------------------------------------
// Another Hexadecimal to Decimal Conversion by Mace
// https://codebase64.org/doku.php?id=base:another_hexadecimal_to_decimal_conversion
* = * "Convert Hex to Dec and Display on Screen"
show_result:	lda #$30		// init the result on screen to 00000
				ldy #4
		clear:	sta screen,y
				dey
				bpl clear
				
				ldy #6			// skip 7 MSBs, as we only have a 17 bit value
				clc
			!:	rol highest_set+2
				rol highest_set+1
				rol highest_set
				dey
				bpl !-
				
				ldx #5*17-1		// set x to last index of table
		loop1:	clc
				rol highest_set+2
				rol highest_set+1
				rol highest_set
				bcs calculate	// when bit drops off, decimal value must be added
								// if not, go to the next bit
				txa
				axs #5			// Equivalent to sec ; sbc #5 ; tax
				bpl loop1

		end:	rts
				
calculate:		clc
				ldy #4
		loop2:	lda table,x		// get decimal equivalent of bit in ASCII numbers
				adc #0			// add carry, is set if the former addition ≥10
				beq zero		// skip (speed up) when there's nothing to add
				adc screen,y	// add to whatever result we already have
				cmp #$3a		// ≥10 with the addition?
				bcc notten		// if not, skip the subtraction
				sbc #$0a		// subtract 10 
		notten:	sta screen,y
		zero:	dex
				dey
				bpl loop2		// loop until all 5 digits have been updated
				jmp loop1

		table:	// decimal values for every bit in 17-bit figure
				.byte 0,0,0,0,1 // %00000000000000001
				.byte 0,0,0,0,2 // %00000000000000010
				.byte 0,0,0,0,4 // %00000000000000100
				.byte 0,0,0,0,8 // %00000000000001000
				.byte 0,0,0,1,6 // %00000000000010000
				.byte 0,0,0,3,2 // %00000000000100000
				.byte 0,0,0,6,4 // %00000000001000000
				.byte 0,0,1,2,8 // %00000000010000000
				.byte 0,0,2,5,6 // %00000000100000000
				.byte 0,0,5,1,2 // %00000001000000000
				.byte 0,1,0,2,4 // %00000010000000000
				.byte 0,2,0,4,8 // %00000100000000000
				.byte 0,4,0,9,6 // %00001000000000000
				.byte 0,8,1,9,2 // %00010000000000000
				.byte 1,6,3,8,4 // %00100000000000000
				.byte 3,2,7,6,8 // %01000000000000000
				.byte 6,5,5,3,6 // %10000000000000000

/**
	- Input file is read into sets of 24bit numbers.
	- $ff = end of set.
	- $fe = end of table.
*/
* = * "Input Data"
input:
	.var inputFile = LoadBinary("input/day01.txt")
	.var valueSum = 0
	.var highestSum = 0
	.var line = ""
	.var setNum = 0
	.for (var i = 0; i < inputFile.getSize(); i++) {
		.var b = inputFile.get(i)
		.if (b != $0a) {
			.eval line += toIntString(b-$30) // add number to value string
		} else {
			.if (line != "") {
				.var value = line.asNumber()
				.eval valueSum += value
				.var hibyte = floor(value/65536)
				.eval value = mod(value, 65536)
				.var midbyte = floor(value/256)
				.var lobyte = mod(value, 256)
				.byte hibyte, midbyte, lobyte // next 24bit value in set
				.eval line = ""
			} else {
				.if (valueSum > highestSum) {
					.eval highestSum = valueSum
				}
				.eval setNum++
				.print "########## set " + setNum + ": " + valueSum + ", highest: " + highestSum
				.eval valueSum = 0
				.byte $ff // End of set
			}
		}
	}
	.byte $ff // End of set
	.byte $fe // End of table
	.print "########## highest sum: " + highestSum

* = * "End"
