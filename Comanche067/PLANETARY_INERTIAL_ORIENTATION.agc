### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	PLANETARY_INERTIAL_ORIENTATION.agc
## Purpose:	Part of the source code for Comanche 67 (Colossus 2C),
##		the one-and-only software release for the Apollo Guidance 
##		Computer (AGC) of Apollo 12's command module.  In the 
##		absence of a contemporary assembly listing for Comanche 67, 
##		the intention is to reconstruct the source code from a 
##		Comanche 55 (Colossus 2A, Apollo 11 CM) baseline and 
##		contemporary documentation describing the differences 
##		between the two.  Page numbers listed in the program 
##		comments follow Comanche 55 unless otherwise noted.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Mod history: 2020-12-25 RSB	Began adaptation from Comanche 55 baseline.

## Page 1243
# ..... RP-TO-R SUBROUTINE .....
# SUBROUTINE TO CONVERT RP (VECTOR IN PLANETARY COORDINATE SYSTEM, EITHER
# EARTH-FIXED OR MOON-FIXED) TO R (SAME VECTOR IN THE BASIC REF. SYSTEM)
#	R = MT(T) * (RP + LP X RP)	MT = M MATRIX TRANSPOSE
#
# CALLING SEQUENCE
#	L 	CALL
#	L+1		RP-TO-R
#
# SUBROUTINES USED
#	EARTHMX, MOONMX, EARTHL
#
# 	ITEMS AVAILABLE FROM LAUNCH DATA
#		504LM = THE LIBRATION VECTOR L OF THE MOON AT TIME TIMSUBL, EXPRESSED
#		IN THE MOON-FIXED COORD. SYSTEM		RADIANS B0
#
#	ITEMS NECESSARY FOR SUBR. USED (SEE DESCRIPTION OF SUBR.)
#
# INPUT
#	MPAC = 0 FOR EARTH, NON-ZERO FOR MOON
#	0-5D = RP VECTOR
#	6-7D = TIME
#
# OUTPUT
#	MPAC = R VECTOR METERS B-29 FOR EARTH, B-27 FOR MOON

		SETLOC	PLANTIN
		BANK

		COUNT*	$$/LUROT

RP-TO-R		STQ	BHIZ
			RPREXIT
			RPTORA
		CALL			# COMPUTE M MATRIX FOR MOON
			MOONMX		# LP=LM FOR MOON	RADIANS B0
		VLOAD
			504LM
RPTORB		VXV	VAD
			504RPR
			504RPR
		VXM	GOTO
			MMATRIX		# MPAC=R=MT(T)*(RP+LPXRP)
			RPRPXXXX	# RESET PUSHLOC TO 0 BEFORE EXITING
RPTORA		CALL			# EARTH COMPUTATIONS
			EARTHMX		# M MATRIX B-1
		CALL
			EARTHL		# L VECTOR RADIANS B0
		MXV	VSL1		# LP=M(T)*L 	RAD B-0
			MMATRIX
## Page 1244
		GOTO
			RPTORB

## Page 1245
# ..... R-TO-RP SUBROUTINE .....
# SUBROUTINE TO CONVERT R (VECTOR IN REFERENCE COORD. SYSTEM) TO RP
# (VECTOR IN PLANETARY COORD SYSTEM) EITHER EARTH-FIXED OR MOON-FIXED
#	RP = M(T) * (R - L X R)
#
# CALLING SEQUENCE
#	L	CALL
#	L+1		R-TO-RP
#
# SUBROUTINES USED
#	EARTHMX, MOONMX, EARTHL
#
# INPUT
#	MPAC = 0 FOR EARTH, NON-ZERO FOR MOON
#	0-5D = R VECTOR
#	6-7D = TIME
#
#	ITEMS AVAILABLE FROM LAUNCH DATA
#		504LM = THE LIBRATION VECTOR L OF THE MOON AT TIME TIMSUBL, EXPRESSED
#		IN THE MOON-FIXED COORD. SYSTEM			RADIANS B0
#
#	ITEMS NECESSARY FOR SUBROUTINES USED (SEE DESCRIPTION OF SUBR.)
#
# OUTPUT
#	MPAC = RP VECTOR METERS B-29 FOR EARTH, B-27 FOR MOON

R-TO-RP		STQ	BHIZ
			RPREXIT
			RTORPA
		CALL
			MOONMX
		VLOAD	VXM
			504LM		# LP=LM
			MMATRIX
		VSL1			# L = MT(T)*LP 		RADIANS B0
RTORPB		VXV	BVSU
			504RPR
			504RPR
		MXV			# M(T)*(R-LXR)		B-2
			MMATRIX
RPRPXXXX	VSL1	SETPD
			0D
		GOTO
			RPREXIT
RTORPA		CALL			# EARTH COMPUTATIONS
			EARTHMX
		CALL
			EARTHL
		GOTO			# MPAC=L=(-AX,-AY,0) 	RAD B-0
			RTORPB

## Page 1246
# ..... MOONMX SUBROUTINE .....
# SUBROUTINE TO COMPUTE THE TRANSFORMATION MATRIX M FOR THE MOON
#
# CALLING SEQUENCE
#	L	CALL
#	L+1		MOONMX
#
# SUBROUTINES USED
#	NEWANGLE
#
# INPUT
#	6-7D = TIME
#
#	ITEMS AVAILABLE FROM LAUNCH DATA
#		BSUBO, BDOT
#		TIMSUBO, NODIO, NODDOT, FSUBO, FDOT
#		COSI = COS(I)	B-1
#		SINI = SIN(I)	B-1
#		I IS THE ANGLE BETWEEN THE MEAN LUNAR EQUATORIAL PLANE AND THE
#		PLANE OF THE ECLIPTIC (1 DEGREE 32.1 MINUTES)
#
# OUTPUT
#	MMATRIX = 3X3 M MATRIX		B-1 (STORED IN VAC AREA)

MOONMX		STQ	SETPD
			EARTHMXX
			8D
		AXT,1			# B REQUIRES SL 0, SL 5 IN NEWANGLE
			5
		DLOAD	PDDL		# PD 10D	8-9D=BSUBO
			BSUBO		#		10-11D=BDOT
			BDOT
		PUSH	CALL		# PD 12D
			NEWANGLE	# EXIT WITH PD 8D AND MPAC= B	REVS B0
		PUSH	COS		# PD 10D
		STODL	COB		# PD 8D		COS(B) B-1
		SIN			#		SIN(B) B-1
		STODL	SOB		# 		SETUP INPUT FOR NEWANGLE
			FSUBO		# 			8-9D=FSUBO
		PDDL	PUSH		# PD 10D THEN 12D	10-11D=FDOT
			FDOT
		AXT,1	CALL		# F REQUIRES SL 1, SL 6 IN NEWANGLE
			4
			NEWANGLE	# EXIT WITH PD 8D AND MPAC= F REVS B0
		STODL	AVECTR +2	# SAVE F TEMP
			NODIO		#			8-9D=NODIO
		PDDL	PUSH		# PD 10D THEN 12D	10-11D=NODDOT
			NODDOT		#			MPAC=T
		AXT,1	CALL		# NODE REQUIRES SL 0, SL 5 IN NEWANGLE
			5
			NEWANGLE	# EXIT WITH PD 8D AND MPAC= NODI REVS B0
## Page 1247
		PUSH	COS		# PD 10D	8-9D= NODI REVS B0
		PUSH			# PD 12D	10-11D= COS(NODI) B-1
		STORE	AVECTR
		DMP	SL1R
			COB		#			COS(NODI) B-1
		STODL	BVECTR +2	# PD 10D  20-25D=AVECTR=COB*SIN(NODI)
		DMP	SL1R		#			SOB*SIN(NODI)
			SOB
		STODL	BVECTR +4	# PD 8D
		SIN	PUSH		# PD 10D		-SIN(NODI) B-1
		DCOMP			#         26-31D=BVECTR=COB*COS(NODI)
		STODL	BVECTR		# PD 8D			SOB*COS(NODI)
			AVECTR +2	# MOVE F FROM TEMP LOC. TO 504F
		STODL	504F
		DMP	SL1R
			COB
		STODL	AVECTR +2
			SINNODI		# 8-9D=SIN(NODI) B-1
		DMP	SL1R
			SOB
		STODL	AVECTR +4	#			0
			HI6ZEROS	#	8-13D= CVECTR=	-SOB B-1
		PDDL	DCOMP		# PD 10D		COB
			SOB
		PDDL	PDVL		# PD 12D THEN PD 14D
			COB
			BVECTR
		VXSC	PDVL		# PD 20D	BVECTR*SINI B-2
			SINI
			CVECTR
		VXSC	VAD		# PD 14D	CVECTR*COSI B-2
			COSI
		VSL1
		STOVL	MMATRIX +12D	# PD 8D  M2=BVECTR*SINI+CVECTR*COSI B-1
		VXSC	PDVL		# PD 14D
			SINI		#		CVECTR*SINI B-2
			BVECTR
		VXSC	VSU		# PD 8D		BVECTR*COSI B-2
			COSI
		VSL1	PDDL		# PD 14D
			504F		# 8-13D=DVECTR=BVECTR*COSI-CVECTR*SINI B-1
		COS	VXSC
			DVECTR
		PDDL	SIN		# PD 20D  14-19D= DVECTR*COSF B-2
			504F
		VXSC	VSU		# PD 14D	AVECTR*SINF B-2
			AVECTR
		VSL1
		STODL	MMATRIX +6	# M1= AVECTR*SINF-DVECTR*COSF B-1
			504F
## Page 1248
		SIN	VXSC		# PD 8D
		PDDL	COS		# PD 14D  8-13D=DVECTR*SINF B-2
			504F
		VXSC	VAD		# PD 8D		AVECTR*COSF B-2
			AVECTR
		VSL1	VCOMP
		STCALL	MMATRIX		# M0= -(AVECTR*COSF+DVECTR*SINF) B-1
			EARTHMXX

# COMPUTE X=X0+(XDOT)(T+T0)
# 8-9D= XO (REVS B-0), PUSHLOC SET AT 12D
# 10-11D=XDOT (REVS/CSEC) SCALED B+23 FOR WEARTH,B+28 FOR NODDOT AND BDOT
#			AND B+27 FOR FDOT
# X1=DIFFERENCE IN 23 AND SCALING OF XDOT, =0 FOR WEARTH, 5 FOR NODDOT AND
#					BDOT AND 4 FOR FDOT
# 6-7D=T (CSEC B-28), TIMSUBO= (CSEC B-42 TRIPLE PREC.)

NEWANGLE	DLOAD	SR		# ENTER PD 12D
			6D
			14D
		TAD	TLOAD		# CHANGE MODE TO TP
			TIMSUBO
			MPAC
		STODL	TIMSUBM		# T+T0 CSEC B-42
			TIMSUBM +1
		DMP			# PD 10D	MULT BY XDOT IN 10-11D
		SL*	DAD		# PD 8D		ADD XO IN 8-9D AFTER SHIFTING
			5,1		#		SUCH THAT SCALING IS B-0
		PUSH	SLOAD		# PD 10D  SAVE PARTIAL (X0+XDOT*T) IN 8-9D
			TIMSUBM
		SL	DMP
			9D
			10D		# XDOT
		SL*	DAD		# PD 8D		SHIFT SUCH THAT THIS PART OF X
			10D,1		#		IS SCALED REVS/CSEC B-0
		BOV			# TURN OFF OVERFLOW IF SET BY SHIFT
			+1		# INSTRUCTION BEFORE EXITING
		RVQ			# MPAC=X= X0+(XDOT)(T+T0)	REVS B0

## Page 1249
# ..... EARTHMX SUBROUTINE .....
# SUBROUTINE TO COMPUTE THE TRANSFORMATION MATRIX M FOR THE EARTH
#
# CALLING SEQUENCE
#	L	CALL
#	L+1		EARTHMX
#
# SUBROUTINES USED
#	NEWANGLE
#
# INPUT
#	INPUT AVAILABLE FROM LAUNCH DATA	AZO REVS B-0
#						TEPHEM CSEC B-42
#	6-7D= TIME CSEC B-28
#
# OUTPUT
#	MMATRIX= 3X3 M MATRIX B-1 (STORED IN VAC AREA)

EARTHMX		STQ	SETPD		# SET 8-9D=AZO
			EARTHMXX
			8D		# 10-11D=WEARTH
		AXT,1			# FOR SL 5, AND SL 10 IN NEWANGLE
			0
		DLOAD	PDDL		# LEAVING PD SET AT 12D FOR NEWANGLE
			AZO
			WEARTH
		PUSH	CALL
			NEWANGLE
		SETPD	PUSH		# 18-19D=504AZ
			18D		#			 COS(AZ)   SIN(AZ)     0
		COS	PDDL		# 20-37D=  MMATRIX=	-SIN(AZ)   COS(AZ)     0    B-1
			504AZ		#			    0         0        1
		SIN	PDDL
			HI6ZEROS
		PDDL	SIN
			504AZ
		DCOMP	PDDL
			504AZ
		COS	PDVL
			HI6ZEROS
		PDDL	PUSH
			HIDPHALF
		GOTO
			EARTHMXX

## Page 1250
# ..... EARTHL SUBROUTINE .....
# SUBROUTINE TO COMPUTE L VECTOR FOR EARTH
#
# CALLING SEQUENCE
#	L	CALL
#	L+1		EARTHL
#
# INPUT
#	AXO,AYO SET AT LAUNCH TIME WITH AYO IMMEDIATELY FOLLOWING AXO IN CORE
#
# OUTPUT
#		-AX
#	MPAC=	-AY	RADIANS B-0
#		  0

EARTHL		DLOAD	DCOMP
			AXO
		STODL	504LPL
			-AYO
		STODL	504LPL +2
			HI6ZEROS
		STOVL	504LPL +4
			504LPL
		RVQ

## Page 1251
# CONSTANTS AND ERASABLE ASSIGNMENTS

1B1		=	DP1/2		# 1 SCALED B-1
COSI		2DEC	.99964173 B-1	# COS(5521.5 SEC) B-1

SINI		2DEC	.02676579 B-1	# SIN(5521.5 SEC) B-1

RPREXIT		=	S1		# R-TO-RP AND RP-TO-R SUBR EXIT
EARTHMXX	=	S2		# EARTHMX, MOONMX SUBR. EXITS
504RPR		=	0D		# 6 REGS	R OR RP VECTOR
SINNODI		=	8D		# 2		SIN(NODI)
DVECTR		=	8D		# 6		D VECTOR MOON
CVECTR		=	8D		# 6		C VECTR MOON
504AZ		=	18D		# 2		AZ
TIMSUBM		=	14D		# 3		TIME SUB M (MOON) T+T0 IN GETAZ
504LPL		=	14D		# 6		L OR LP VECTOR
AVECTR		=	20D		# 6		A VECTOR (MOON)
BVECTR		=	26D		# 6		B VECTOR (MOON)
MMATRIX		=	20D		# 18		M MATRIX
COB		=	32D		# 2		COS(B) B-1
SOB		=	34D		# 2		SIN(B) B-1
504F		=	6D		# 2		F(MOON)
NODDOT		2DEC	-.457335121 E-2	# REVS/CSEC B+28=-1.07047011 E-8  RAD/SEC

FDOT		2DEC	.570863327	# REVS/CSEC B+27= 2.67240410 E-6  RAD/SEC

BDOT		2DEC	-3.07500686 E-8	# REVS/CSEC B+28=-7.19757301 E-14 RAD/SEC

NODIO		2DEC	.986209434	# REVS B-0      = 6.19653663041   RAD

FSUBO		2DEC	.829090536	# REVS B-0	= 5.20932947829	  RAD

BSUBO		2DEC	.0651201393	# REVS B-0	= 0.40916190299	  RAD

WEARTH		2DEC	.973561595	# REVS/CSEC B+23= 7.29211494 E-5  RAD/SEC

