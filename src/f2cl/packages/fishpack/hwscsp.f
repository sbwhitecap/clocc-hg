      SUBROUTINE HWSCSP (INTL,TS,TF,M,MBDCND,BDTS,BDTF,RS,RF,N,NBDCND,
     1                   BDRS,BDRF,ELMBDA,F,IDIMF,PERTRB,IERROR,W)
C
C     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C     *                                                               *
C     *                        F I S H P A K                          *
C     *                                                               *
C     *                                                               *
C     *     A PACKAGE OF FORTRAN SUBPROGRAMS FOR THE SOLUTION OF      *
C     *                                                               *
C     *      SEPARABLE ELLIPTIC PARTIAL DIFFERENTIAL EQUATIONS        *
C     *                                                               *
C     *                  (VERSION 3.1 , OCTOBER 1980)                  *
C     *                                                               *
C     *                             BY                                *
C     *                                                               *
C     *        JOHN ADAMS, PAUL SWARZTRAUBER AND ROLAND SWEET         *
C     *                                                               *
C     *                             OF                                *
C     *                                                               *
C     *         THE NATIONAL CENTER FOR ATMOSPHERIC RESEARCH          *
C     *                                                               *
C     *                BOULDER, COLORADO  (80307)  U.S.A.             *
C     *                                                               *
C     *                   WHICH IS SPONSORED BY                       *
C     *                                                               *
C     *              THE NATIONAL SCIENCE FOUNDATION                  *
C     *                                                               *
C     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C
C     SUBROUTINE HWSCSP SOLVES A FINITE DIFFERENCE APPROXIMATION TO THE
C       MODIFIED HELMHOLTZ EQUATION IN SPHERICAL COORDINATES ASSUMING
C       AXISYMMETRY  (NO DEPENDENCE ON LONGITUDE)
C
C          (1/R**2)(D/DR)((R**2)(D/DR)U)
C
C             + (1/(R**2)SIN(THETA))(D/DTHETA)(SIN(THETA)(D/DTHETA)U)
C
C             + (LAMBDA/(RSIN(THETA))**2)U = F(THETA,R).
C
C     THIS TWO DIMENSIONAL MODIFIED HELMHOLTZ EQUATION RESULTS FROM
C     THE FOURIER TRANSFORM OF THE THREE DIMENSIONAL POISSON EQUATION
C
C     * * * * * * * * * *     ON INPUT     * * * * * * * * * *
C
C     INTL
C       = 0  ON INITIAL ENTRY TO HWSCSP OR IF ANY OF THE ARGUMENTS
C            RS, RF, N, NBDCND ARE CHANGED FROM A PREVIOUS CALL.
C       = 1  IF RS, RF, N, NBDCND ARE ALL UNCHANGED FROM PREVIOUS CALL
C            TO HWSCSP.
C
C       NOTE   A CALL WITH INTL=0 TAKES APPROXIMATELY 1.5 TIMES AS
C              MUCH TIME AS A CALL WITH INTL = 1  .  ONCE A CALL WITH
C              INTL = 0 HAS BEEN MADE THEN SUBSEQUENT SOLUTIONS
C              CORRESPONDING TO DIFFERENT F, BDTS, BDTF, BDRS, BDRF CAN
C              BE OBTAINED FASTER WITH INTL = 1 SINCE INITIALIZATION IS
C              NOT REPEATED.
C
C     TS,TF
C       THE RANGE OF THETA (COLATITUDE), I.E., TS .LE. THETA .LE. TF.
C       TS MUST BE LESS THAN TF.  TS AND TF ARE IN RADIANS.  A TS OF
C       ZERO CORRESPONDS TO THE NORTH POLE AND A TF OF PI CORRESPONDS
C       TO THE SOUTH POLE.
C
C     * * * * * * * * * * * * * * IMPORTANT * * * * * * * * * * * * * *
C
C     IF TF IS EQUAL TO PI THEN IT MUST BE COMPUTED USING THE STATEMENT
C     TF = PIMACH(DUM). THIS INSURES THAT TF IN THE USERS PROGRAM IS
C     EQUAL TO PI IN THIS PROGRAM WHICH PERMITS SEVERAL TESTS OF THE
C     INPUT PARAMETERS THAT OTHERWISE WOULD NOT BE POSSIBLE.
C
C     M
C       THE NUMBER OF PANELS INTO WHICH THE INTERVAL (TS,TF) IS
C       SUBDIVIDED.  HENCE, THERE WILL BE M+1 GRID POINTS IN THE
C       THETA-DIRECTION GIVEN BY THETA(K) = (I-1)DTHETA+TS FOR
C       I = 1,2,...,M+1, WHERE DTHETA = (TF-TS)/M IS THE PANEL WIDTH.
C
C     MBDCND
C       INDICATES THE TYPE OF BOUNDARY CONDITION AT THETA = TS AND
C       THETA = TF.
C
C       = 1  IF THE SOLUTION IS SPECIFIED AT THETA = TS AND THETA = TF.
C       = 2  IF THE SOLUTION IS SPECIFIED AT THETA = TS AND THE
C            DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA IS
C            SPECIFIED AT THETA = TF (SEE NOTE 2 BELOW).
C       = 3  IF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA IS
C            SPECIFIED AT THETA = TS AND THETA = TF (SEE NOTES 1,2
C            BELOW).
C       = 4  IF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA IS
C            SPECIFIED AT THETA = TS (SEE NOTE 1 BELOW) AND THE
C            SOLUTION IS SPECIFIED AT THETA = TF.
C       = 5  IF THE SOLUTION IS UNSPECIFIED AT THETA = TS = 0 AND THE
C            SOLUTION IS SPECIFIED AT THETA = TF.
C       = 6  IF THE SOLUTION IS UNSPECIFIED AT THETA = TS = 0 AND THE
C            DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA IS
C            SPECIFIED AT THETA = TF (SEE NOTE 2 BELOW).
C       = 7  IF THE SOLUTION IS SPECIFIED AT THETA = TS AND THE
C            SOLUTION IS UNSPECIFIED AT THETA = TF = PI.
C       = 8  IF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA IS
C            SPECIFIED AT THETA = TS (SEE NOTE 1 BELOW) AND THE SOLUTION
C            IS UNSPECIFIED AT THETA = TF = PI.
C       = 9  IF THE SOLUTION IS UNSPECIFIED AT THETA = TS = 0 AND
C            THETA = TF = PI.
C
C       NOTES:  1.  IF TS = 0, DO NOT USE MBDCND = 3,4, OR 8, BUT
C                   INSTEAD USE MBDCND = 5,6, OR 9  .
C               2.  IF TF = PI, DO NOT USE MBDCND = 2,3, OR 6, BUT
C                   INSTEAD USE MBDCND = 7,8, OR 9  .
C
C     BDTS
C       A ONE-DIMENSIONAL ARRAY OF LENGTH N+1 THAT SPECIFIES THE VALUES
C       OF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA AT
C       THETA = TS.  WHEN MBDCND = 3,4, OR 8,
C
C            BDTS(J) = (D/DTHETA)U(TS,R(J)), J = 1,2,...,N+1  .
C
C       WHEN MBDCND HAS ANY OTHER VALUE, BDTS IS A DUMMY VARIABLE.
C
C     BDTF
C       A ONE-DIMENSIONAL ARRAY OF LENGTH N+1 THAT SPECIFIES THE VALUES
C       OF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO THETA AT
C       THETA = TF.  WHEN MBDCND = 2,3, OR 6,
C
C            BDTF(J) = (D/DTHETA)U(TF,R(J)), J = 1,2,...,N+1  .
C
C       WHEN MBDCND HAS ANY OTHER VALUE, BDTF IS A DUMMY VARIABLE.
C
C     RS,RF
C       THE RANGE OF R, I.E., RS .LE. R .LT. RF.  RS MUST BE LESS THAN
C       RF.  RS MUST BE NON-NEGATIVE.
C
C       N
C       THE NUMBER OF PANELS INTO WHICH THE INTERVAL (RS,RF) IS
C       SUBDIVIDED.  HENCE, THERE WILL BE N+1 GRID POINTS IN THE
C       R-DIRECTION GIVEN BY R(J) = (J-1)DR+RS FOR J = 1,2,...,N+1,
C       WHERE DR = (RF-RS)/N IS THE PANEL WIDTH.
C       N MUST BE GREATER THAN 2
C
C     NBDCND
C       INDICATES THE TYPE OF BOUNDARY CONDITION AT R = RS AND R = RF.
C
C       = 1  IF THE SOLUTION IS SPECIFIED AT R = RS AND R = RF.
C       = 2  IF THE SOLUTION IS SPECIFIED AT R = RS AND THE DERIVATIVE
C            OF THE SOLUTION WITH RESPECT TO R IS SPECIFIED AT R = RF.
C       = 3  IF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO R IS
C            SPECIFIED AT R = RS AND R = RF.
C       = 4  IF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO R IS
C            SPECIFIED AT RS AND THE SOLUTION IS SPECIFIED AT R = RF.
C       = 5  IF THE SOLUTION IS UNSPECIFIED AT R = RS = 0 (SEE NOTE
C            BELOW) AND THE SOLUTION IS SPECIFIED AT R = RF.
C       = 6  IF THE SOLUTION IS UNSPECIFIED AT R = RS = 0 (SEE NOTE
C            BELOW) AND THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO
C            R IS SPECIFIED AT R = RF.
C
C       NOTE:  NBDCND = 5 OR 6 CANNOT BE USED WITH
C              MBDCND = 1,2,4,5, OR 7 (THE FORMER INDICATES THAT THE
C                       SOLUTION IS UNSPECIFIED AT R = 0, THE LATTER
C                       INDICATES THAT THE SOLUTION IS SPECIFIED).
C                       USE INSTEAD
C              NBDCND = 1 OR 2  .
C
C     BDRS
C       A ONE-DIMENSIONAL ARRAY OF LENGTH M+1 THAT SPECIFIES THE VALUES
C       OF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO R AT R = RS.
C       WHEN NBDCND = 3 OR 4,
C
C            BDRS(I) = (D/DR)U(THETA(I),RS), I = 1,2,...,M+1  .
C
C       WHEN NBDCND HAS ANY OTHER VALUE, BDRS IS A DUMMY VARIABLE.
C
C     BDRF
C       A ONE-DIMENSIONAL ARRAY OF LENGTH M+1 THAT SPECIFIES THE VALUES
C       OF THE DERIVATIVE OF THE SOLUTION WITH RESPECT TO R AT R = RF.
C       WHEN NBDCND = 2,3, OR 6,
C
C            BDRF(I) = (D/DR)U(THETA(I),RF), I = 1,2,...,M+1  .
C
C       WHEN NBDCND HAS ANY OTHER VALUE, BDRF IS A DUMMY VARIABLE.
C
C     ELMBDA
C       THE CONSTANT LAMBDA IN THE HELMHOLTZ EQUATION.  IF
C       LAMBDA .GT. 0, A SOLUTION MAY NOT EXIST.  HOWEVER, HWSCSP WILL
C       ATTEMPT TO FIND A SOLUTION.  IF NBDCND = 5 OR 6 OR
C       MBDCND = 5,6,7,8, OR 9, ELMBDA MUST BE ZERO.
C
C     F
C       A TWO-DIMENSIONAL ARRAY THAT SPECIFIES THE VALUE OF THE RIGHT
C       SIDE OF THE HELMHOLTZ EQUATION AND BOUNDARY VALUES (IF ANY).
C       FOR I = 2,3,...,M AND J = 2,3,...,N
C
C            F(I,J) = F(THETA(I),R(J)).
C
C       ON THE BOUNDARIES F IS DEFINED BY
C
C            MBDCND   F(1,J)            F(M+1,J)
C            ------   ----------        ----------
C
C              1      U(TS,R(J))        U(TF,R(J))
C              2      U(TS,R(J))        F(TF,R(J))
C              3      F(TS,R(J))        F(TF,R(J))
C              4      F(TS,R(J))        U(TF,R(J))
C              5      F(0,R(J))         U(TF,R(J))   J = 1,2,...,N+1
C              6      F(0,R(J))         F(TF,R(J))
C              7      U(TS,R(J))        F(PI,R(J))
C              8      F(TS,R(J))        F(PI,R(J))
C              9      F(0,R(J))         F(PI,R(J))
C
C            NBDCND   F(I,1)            F(I,N+1)
C            ------   --------------    --------------
C
C              1      U(THETA(I),RS)    U(THETA(I),RF)
C              2      U(THETA(I),RS)    F(THETA(I),RF)
C              3      F(THETA(I),RS)    F(THETA(I),RF)
C              4      F(THETA(I),RS)    U(THETA(I),RF)   I = 1,2,...,M+1
C              5      F(TS,0)           U(THETA(I),RF)
C              6      F(TS,0)           F(THETA(I),RF)
C
C       F MUST BE DIMENSIONED AT LEAST (M+1)*(N+1).
C
C       NOTE
C
C       IF THE TABLE CALLS FOR BOTH THE SOLUTION U AND THE RIGHT SIDE F
C       AT  A CORNER THEN THE SOLUTION MUST BE SPECIFIED.
C
C     IDIMF
C       THE ROW (OR FIRST) DIMENSION OF THE ARRAY F AS IT APPEARS IN THE
C       PROGRAM CALLING HWSCSP.  THIS PARAMETER IS USED TO SPECIFY THE
C       VARIABLE DIMENSION OF F.  IDIMF MUST BE AT LEAST M+1  .
C
C     W
C       A ONE-DIMENSIONAL ARRAY THAT MUST BE PROVIDED BY THE USER FOR
C       WORK SPACE. ITS LENGTH CAN BE COMPUTED FROM THE FORMULA BELOW
C       WHICH DEPENDS ON THE VALUE OF NBDCND
C
C       IF NBDCND=2,4 OR 6 DEFINE NUNK=N
C       IF NBDCND=1 OR 5   DEFINE NUNK=N-1
C       IF NBDCND=3        DEFINE NUNK=N+1
C
C       NOW SET K=INT(LOG2(NUNK))+1 AND L=2**(K+1) THEN W MUST BE
C       DIMENSIONED AT LEAST (K-2)*L+K+5*(M+N)+MAX(2*N,6*M)+23
C
C       **IMPORTANT** FOR PURPOSES OF CHECKING, THE REQUIRED LENGTH
C                     OF W IS COMPUTED BY HWSCSP AND STORED IN W(1)
C                     IN FLOATING POINT FORMAT.
C
C
C     * * * * * * * * * *     ON OUTPUT     * * * * * * * * * *
C
C     F
C       CONTAINS THE SOLUTION U(I,J) OF THE FINITE DIFFERENCE
C       APPROXIMATION FOR THE GRID POINT (THETA(I),R(J)),
C       I = 1,2,...,M+1,   J = 1,2,...,N+1  .
C
C     PERTRB
C       IF A COMBINATION OF PERIODIC OR DERIVATIVE BOUNDARY CONDITIONS
C       IS SPECIFIED FOR A POISSON EQUATION (LAMBDA = 0), A SOLUTION MAY
C       NOT EXIST.  PERTRB IS A CONSTANT, CALCULATED AND SUBTRACTED FROM
C       F, WHICH ENSURES THAT A SOLUTION EXISTS.  HWSCSP THEN COMPUTES
C       THIS SOLUTION, WHICH IS A LEAST SQUARES SOLUTION TO THE ORIGINAL
C       APPROXIMATION. THIS SOLUTION IS NOT UNIQUE AND IS UNNORMALIZED.
C       THE VALUE OF PERTRB SHOULD BE SMALL COMPARED TO THE RIGHT SIDE
C       F. OTHERWISE , A SOLUTION IS OBTAINED TO AN ESSENTIALLY
C       DIFFERENT PROBLEM. THIS COMPARISON SHOULD ALWAYS BE MADE TO
C       INSURE THAT A MEANINGFUL SOLUTION HAS BEEN OBTAINED.
C
C     IERROR
C       AN ERROR FLAG THAT INDICATES INVALID INPUT PARAMETERS.  EXCEPT
C       FOR NUMBERS 0 AND 10, A SOLUTION IS NOT ATTEMPTED.
C
C       = 1  TS.LT.0. OR TF.GT.PI
C       = 2  TS.GE.TF
C       = 3  M.LT.5
C       = 4  MBDCND.LT.1 OR MBDCND.GT.9
C       = 5  RS.LT.0
C       = 6  RS.GE.RF
C       = 7  N.LT.5
C       = 8  NBDCND.LT.1 OR NBDCND.GT.6
C       = 9  ELMBDA.GT.0
C       = 10 IDIMF.LT.M+1
C       = 11 ELMBDA.NE.0 AND MBDCND.GE.5
C       = 12 ELMBDA.NE.0 AND NBDCND EQUALS 5 OR 6
C       = 13 MBDCND EQUALS 5,6 OR 9 AND TS.NE.0
C       = 14 MBDCND.GE.7 AND TF.NE.PI
C       = 15 TS.EQ.0 AND MBDCND EQUALS 3,4 OR 8
C       = 16 TF.EQ.PI AND MBDCND EQUALS 2,3 OR 6
C       = 17 NBDCND.GE.5 AND RS.NE.0
C       = 18 NBDCND.GE.5 AND MBDCND EQUALS 1,2,4,5 OR 7
C
C       SINCE THIS IS THE ONLY MEANS OF INDICATING A POSSLIBY INCORRECT
C       CALL TO HWSCSP, THE USER SHOULD TEST IERROR AFTER A CALL.
C
C     W
C       CONTAINS INTERMEDIATE VALUES THAT MUST NOT BE DESTROYED IF
C       HWSCSP WILL BE CALLED AGAIN WITH INTL = 1.  W(1) CONTAINS THE
C       NUMBER OF LOCATIONS WHICH W MUST HAVE
C
C     * * * * * * *   PROGRAM SPECIFICATIONS    * * * * * * * * * * * *
C
C     DIMENSION OF   BDTS(N+1),BDTF(N+1),BDRS(M+1),BDRF(M+1),
C     ARGUMENTS      F(IDIMF,N+1),W(SEE ARGUMENT LIST)
C
C     LATEST         JUNE 1979
C     REVISION
C
C     SUBPROGRAMS    HWSCSP,HWSCS1,BLKTRI,BLKTR1,PROD,PRODP,CPROD,CPRODP
C     REQUIRED       ,COMBP,PPADD,PSGF,BSRH,PPSGF,PPSPF,TEVLS,INDXA,
C                    ,INDXB,INDXC,EPMACH,STORE
C
C     SPECIAL
C     CONDITIONS
C
C     COMMON         CBLKT,VALUE
C     BLOCKS
C
C     I/O            NONE
C
C     PRECISION      SINGLE
C
C     SPECIALIST     PAUL N SWARZTRAUBER
C
C     LANGUAGE       FORTRAN
C
C     HISTORY        VERSION 1 SEPTEMBER 1973
C                    VERSION 2 APRIL     1976
C                    VERSION 3 JUNE      1979
C
C     ALGORITHM      THE ROUTINE DEFINES THE FINITE DIFFERENCE
C                    EQUATIONS, INCORPORATES BOUNDARY DATA, AND ADJUSTS
C                    THE RIGHT SIDE OF SINGULAR SYSTEMS AND THEN CALLS
C                    BLKTRI TO SOLVE THE SYSTEM.
C
C     SPACE
C     REQUIRED
C
C     PORTABILITY    AMERICAN NATIONAL STANDARDS INSTITUTE FORTRAN.
C                    THE MACHINE ACCURACY IS COMPUTED APPROXIMATELY
C                    IN FUNCTION EPMACH
C
C     REQUIRED       NONE
C     RESIDENT
C     ROUTINES
C
C     REFERENCE      SWARZTRAUBER,P. AND R. SWEET, 'EFFICIENT FORTRAN
C                    SUBPROGRAMS FOR THE SOLUTION OF ELLIPTIC EQUATIONS'
C                    NCAR TN/IA-109, JULY, 1975, 138 PP.
C
C     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C
C
C
      DIMENSION       F(IDIMF,1) ,BDTS(1)    ,BDTF(1)    ,BDRS(1)    ,
     1                BDRF(1)    ,W(1)
      PI = PIMACH(DUM)
      IERROR = 0
      IF (TS.LT.0. .OR. TF.GT.PI) IERROR = 1
      IF (TS .GE. TF) IERROR = 2
      IF (M .LT. 5) IERROR = 3
      IF (MBDCND.LT.1 .OR. MBDCND.GT.9) IERROR = 4
      IF (RS .LT. 0.) IERROR = 5
      IF (RS .GE. RF) IERROR = 6
      IF (N .LT. 5) IERROR = 7
      IF (NBDCND.LT.1 .OR. NBDCND.GT.6) IERROR = 8
      IF (ELMBDA .GT. 0.) IERROR = 9
      IF (IDIMF .LT. M+1) IERROR = 10
      IF (ELMBDA.NE.0. .AND. MBDCND.GE.5) IERROR = 11
      IF (ELMBDA.NE.0. .AND. (NBDCND.EQ.5 .OR. NBDCND.EQ.6)) IERROR = 12
      IF ((MBDCND.EQ.5 .OR. MBDCND.EQ.6 .OR. MBDCND.EQ.9) .AND.
     1    TS.NE.0.) IERROR = 13
      IF (MBDCND.GE.7 .AND. TF.NE.PI) IERROR = 14
      IF (TS.EQ.0. .AND.
     1    (MBDCND.EQ.4 .OR. MBDCND.EQ.8 .OR. MBDCND.EQ.3)) IERROR = 15
      IF (TF.EQ.PI .AND.
     1    (MBDCND.EQ.2 .OR. MBDCND.EQ.3 .OR. MBDCND.EQ.6)) IERROR = 16
      IF (NBDCND.GE.5 .AND. RS.NE.0.) IERROR = 17
      IF (NBDCND.GE.5 .AND. (MBDCND.EQ.1 .OR. MBDCND.EQ.2 .OR.
     1                                    MBDCND.EQ.5 .OR. MBDCND.EQ.7))
     2    IERROR = 18
      IF (IERROR.NE.0 .AND. IERROR.NE.9) RETURN
      NCK = N
      GO TO (101,103,102,103,101,103),NBDCND
  101 NCK = NCK-1
      GO TO 103
  102 NCK = NCK+1
  103 L = 2
      K = 1
  104 L = L+L
      K = K+1
      IF (NCK-L) 105,105,104
  105 L = L+L
      NP1 = N+1
      MP1 = M+1
      I1 = (K-2)*L+K+MAX0(2*N,6*M)+13
      I2 = I1+NP1
      I3 = I2+NP1
      I4 = I3+NP1
      I5 = I4+NP1
      I6 = I5+NP1
      I7 = I6+MP1
      I8 = I7+MP1
      I9 = I8+MP1
      I10 = I9+MP1
      W(1) = FLOAT(I10+M)
      CALL HWSCS1 (INTL,TS,TF,M,MBDCND,BDTS,BDTF,RS,RF,N,NBDCND,BDRS,
     1             BDRF,ELMBDA,F,IDIMF,PERTRB,W(2),W(I1),W(I2),W(I3),
     2             W(I4),W(I5),W(I6),W(I7),W(I8),W(I9),W(I10))
      RETURN
      END
