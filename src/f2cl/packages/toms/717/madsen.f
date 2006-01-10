C  ***  SIMPLE TEST PROGRAM FOR DGLG AND DGLF  ***
C
      INTEGER IV(92), LIV, LV, NOUT, UI(1)
      DOUBLE PRECISION V(200), X(2), UR(1)
      EXTERNAL I7MDCN, MADRJ, RHOLS
      INTEGER I7MDCN
C
C I7MDCN... RETURNS OUTPUT UNIT NUMBER.
C
      INTEGER COVPRT, COVREQ, LASTIV, LASTV, LMAX0, RDREQ
      PARAMETER (COVPRT=14, COVREQ=15, LASTIV=44, LASTV=45, LMAX0=35,
     1           RDREQ=57)
C
C+++++++++++++++++++++++++++++++  BODY  ++++++++++++++++++++++++++++++++
C
      NOUT = I7MDCN(1)
      LV = 200
      LIV = 92
C
C  ***  SPECIFY INITIAL X  ***
C
      X(1) = 3.D+0
      X(2) = 1.D+0
C
C  ***  SET IV(1) TO 0 TO FORCE ALL DEFAULT INPUT COMPONENTS TO BE USED.
C
       IV(1) = 0
C
       WRITE(NOUT,10)
 10    FORMAT(' DGLG ON PROBLEM MADSEN...')
C
C  ***  CALL DGLG, PASSING UI FOR RHOI, UR FOR RHOR, AND MADRJ FOR
C  ***  UFPARM (ALL UNUSED IN THIS EXAMPLE).
C
      CALL DGLG(3, 2, 2, X, RHOLS, UI, UR, IV, LIV, LV, V, MADRJ, UI,
     1          UR, MADRJ)
C
C  ***  SEE HOW MUCH STORAGE DGLG USED...
C
      WRITE(NOUT,20) IV(LASTIV), IV(LASTV)
 20   FORMAT(' DGLG NEEDED LIV .GE. ',I3,' AND LV .GE.',I4)
C
C  ***  SOLVE THE SAME PROBLEM USING DGLF...
C
      WRITE(NOUT,30)
 30   FORMAT(/' DGLF ON PROBLEM MADSEN...')
      X(1) = 3.D+0
      X(2) = 1.D+0
      IV(1) = 0
      CALL DGLF(3, 2, 2, X, RHOLS, UI, UR, IV, LIV, LV, V, MADRJ, UI,
     1          UR, MADRJ)
C
C  ***  REPEAT THE LAST RUN, BUT WITH A DIFFERENT INITIAL STEP BOUND
C  ***  AND WITH THE COVARIANCE AND REGRESSION DIAGNOSTIC CALCUATIONS
C  ***  SUPPRESSED...
C
C  ***  FIRST CALL DIVSET TO GET DEFAULT IV AND V INPUT VALUES...
C
      CALL DIVSET(1, IV, LIV, LV, V)
C
C  ***  NOW ASSIGN THE NONDEFAULT VALUES.
C
      IV(COVPRT) = 0
      IV(COVREQ) = 0
      IV(RDREQ) = 0
      V(LMAX0) = 0.1D+0
      X(1) = 3.D+0
      X(2) = 1.D+0
C
      WRITE(NOUT,40)
 40   FORMAT(/' DGLF ON PROBLEM MADSEN AGAIN...')
C
      CALL DGLF(3, 2, 2, X, RHOLS, UI, UR, IV, LIV, LV, V, MADRJ, UI,
     1          UR, MADRJ)
C
      STOP
      END
C***********************************************************************
C
C     MADRJ
C
C***********************************************************************
      SUBROUTINE MADRJ(N, P, X, NF, NEED, R, RP, UI, UR, UF)
      INTEGER N, P, NF, NEED, UI(1)
      DOUBLE PRECISION X(P), R(N), RP(P,N), UR(1)
      EXTERNAL UF
      DOUBLE PRECISION TWO, ZERO
      PARAMETER (TWO = 2.D+0, ZERO = 0.D+0)
C
C *** BODY ***
C
      IF (NEED .EQ. 2) GO TO 10
      R(1) = X(1)**2 + X(2)**2 + X(1)*X(2)
      R(2) = SIN(X(1))
      R(3) = COS(X(2))
      GO TO 999
C
 10   RP(1,1) = TWO*X(1) + X(2)
      RP(2,1) = TWO*X(2) + X(1)
      RP(1,2) = COS(X(1))
      RP(2,2) = ZERO
      RP(1,3) = ZERO
      RP(2,3) = -SIN(X(2))
C
 999  RETURN
      END
      SUBROUTINE RHOLS(NEED, F, N, NF, XN, R, RP, UI, UR, W)
C
C *** LEAST-SQUARES RHO ***
C
      INTEGER NEED(2), N, NF, UI(1)
      DOUBLE PRECISION F, XN(*), R(N), RP(N), UR(1), W(N)
C
C *** EXTERNAL FUNCTIONS ***
C
      EXTERNAL DR7MDC, DV2NRM
      DOUBLE PRECISION DR7MDC, DV2NRM
C
C *** LOCAL VARIABLES ***
C
      INTEGER I
      DOUBLE PRECISION HALF, ONE, RLIMIT, ZERO
      DATA HALF/0.5D+0/, ONE/1.D+0/, RLIMIT/0.D+0/, ZERO/0.D+0/
C
C *** BODY ***
C
      IF (NEED(1) .EQ. 2) GO TO 20
      IF (RLIMIT .LE. ZERO) RLIMIT = DR7MDC(5)
C     ** SET F TO 2-NORM OF R **
      F = DV2NRM(N, R)
      IF (F .GE. RLIMIT) GO TO 10
      F = HALF * F**2
      GO TO 999
C
C     ** COME HERE IF F WOULD OVERFLOW...
 10   NF = 0
      GO TO 999
C
 20   DO 30 I = 1, N
         RP(I) = ONE
         W(I) = ONE
 30      CONTINUE
 999  RETURN
C *** LAST LINE OF RHOLS FOLLOWS ***
      END
