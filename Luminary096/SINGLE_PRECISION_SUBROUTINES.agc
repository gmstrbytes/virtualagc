### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SINGLE_PRECISION_SUBROUTINES.agc
## Purpose:     A section of Luminary revision 96.
##              It is part of the reconstructed source code for the
##              original release of the flight software for the Lunar 
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 11.
##              The code has been recreated from a copy of Luminary 99
##              revision 001, using asterisks indicating changed lines in
##              the listing and Luminary Memos #83 and #85, which list 
##              changes between Luminary 97 and 98, and 98 and 99. The
##              code has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 96 in NASA drawing
##              2021152D, which gives relatively high confidence that the
##              reconstruction is correct.
## Reference:   p.  1102
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Warning:     THIS PROGRAM IS STILL UNDERGOING RECONSTRUCTION
##              AND DOES NOT YET REFLECT THE ORIGINAL CONTENTS OF
##              LUMINARY 96.
## Mod history: 2019-08-04 MAS  Created from Luminary 97.

## Page 1102
		BLOCK	02

# SINGLE PRECISION SINE AND COSINE

		COUNT*	$$/INTER
SPCOS		AD	HALF		# ARGUMENTS SCALED AT PI
SPSIN		TS	TEMK
		TCF	SPT
		CS	TEMK
SPT		DOUBLE
		TS	TEMK
		TCF	POLLEY
		XCH	TEMK
		INDEX	TEMK
		AD 	LIMITS
		COM
		AD	TEMK
		TS	TEMK
		TCF	POLLEY
		TCF	ARG90
POLLEY		EXTEND
		MP	TEMK
		TS	SQ
		EXTEND
		MP	C5/2
		AD	C3/2
		EXTEND
		MP	SQ
		AD	C1/2
		EXTEND
		MP	TEMK
		DDOUBL
		TS	TEMK
		TC	Q
ARG90		INDEX	A
		CS	LIMITS
		TC	Q		# RESULT SCALED AT 1
		

