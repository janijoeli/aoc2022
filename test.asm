BasicUpstart2(main)
main:

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
				ldy #1
				sty $4258
				iny
				sta $4359
				iny
				sta $415a
				iny
				sta $4158
				iny
				sta $4259
				iny
				sta $435a
				iny
				sta $4358
				iny
				sta $4159
				iny
				sta $425a

				sei
				lda #23
				sta $d018

				lda #%01000001 // A
				sta $0400
				lda #%01000010 // B
				sta $0401
				lda #%01000011 // C
				sta $0402
				lda #%01011000 // X
				sta $0403
				lda #%01011001 // Y
				sta $0404
				lda #%01011010 // Z
				sta $0405
				cli
				rts
