C*******************************************************************
      SUBROUTINE O8RUP(RV)
C******* COMPUTE CORRECTION OF DUAL MULTIPLIERS
      INCLUDE 'O8COMM.INC'
      INCLUDE 'O8CONS.INC'
      INTEGER NDUALM,MDUALM,NDUAL,MI,ME,IQ
      DOUBLE PRECISION NP,RNORM,RLOW,XJ,DDUAL,R,UD,UD1
      PARAMETER (NDUALM=NX+NRESM,MDUALM=NRESM*2)
      COMMON /O8DUPA/RNORM,RLOW,NDUAL,MI,ME,IQ
      COMMON /O8QPUP/XJ(NDUALM,NDUALM),DDUAL(NDUALM),R(NDUALM,NDUALM),
     F                NP(NDUALM),UD(MDUALM),UD1(MDUALM)
      DOUBLE PRECISION RV(MDUALM),S
      INTEGER I,J
      SAVE
      DO      I=IQ,1,-1
        S=ZERO
        DO        J=I+1,IQ
          S=S+R(I,J)*RV(J)
        ENDDO
        RV(I)=(DDUAL(I)-S)/R(I,I)
      ENDDO
      RETURN
      END