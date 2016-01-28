      PROGRAM WDSTAT
      IMPLICIT NONE
      INTEGER*8  IU6
      PARAMETER (IU6=6)
C
      CHARACTER*40     CTITLE
      INTEGER*4        IWI,JWI,NREC
      REAL*4           WDAY(6000),XFIN,YFIN,DXIN,DYIN
C
      CHARACTER*240     CFILE
      INTEGER          KREC,IOS
      INTEGER*8        IUNIT,IOS8
      REAL*4           JDAY,YEAR
C
      EXTERNAL         WNDAY
C
C**********
C*
C 1)  PRINT MODEL WIND FILE STATISTICS.
C
C 2)  WIND FILE ON UNIT 55, OR USE THE ENVIRONEMENT VARIABLE FOR055.
C
C 3)  ALAN J. WALLCRAFT,  FEBRUARY 1993.
C*
C**********
C
C     OPEN THE FILE.
C
      CFILE = ' '
      CALL GETENV('FOR055',CFILE)
      IF     (CFILE.EQ.' ') THEN
        CFILE = 'fort.55'
      ENDIF
      IUNIT = 55
      CALL ASNUNIT(IUNIT,'-F f77',IOS8)
      IF     (IOS8.NE.0) THEN
        WRITE(0,*) 'wind_stat: cannot asnunit UNIT 55'
        WRITE(0,*) 'IOS = ',IOS8
        CALL EXIT(1)
        STOP
      ENDIF
      OPEN(UNIT=55, FILE=CFILE, FORM='UNFORMATTED', STATUS='OLD',
     +     IOSTAT=IOS)
      IF     (IOS.NE.0) THEN
        WRITE(0,*) 'wind_stat: cannot open ',CFILE(1:LEN_TRIM(CFILE))
        WRITE(0,*) 'IOS = ',IOS
        CALL EXIT(1)
        STOP
      ENDIF
C
C     READ THE FIRST TWO RECORDS.
C
      READ(UNIT=55,IOSTAT=IOS) CTITLE
      IF     (IOS.NE.0) THEN
        WRITE(0,*) 'wind_stat: cannot read ',CFILE(1:LEN_TRIM(CFILE))
        WRITE(0,*) 'IOS = ',IOS
        CALL EXIT(2)
        STOP
      ENDIF
      READ( 55)     IWI,JWI,XFIN,YFIN,DXIN,DYIN,NREC,WDAY
      CLOSE(UNIT=55)
C
C     STATISTICS.
C
      WRITE(6,6000) CTITLE
      WRITE(6,6100) IWI,JWI,XFIN,YFIN,DXIN,DYIN,
     +              NREC,(WDAY(KREC), KREC=1,NREC+1)
      CALL FLUSH(IU6)
C
C     SUMMARY.
C
      CALL WNDAY(WDAY(1), YEAR,JDAY)
      IF     (YEAR.LT.1904.5) THEN
        WRITE(6,6200) NREC,JDAY,NINT(YEAR),WDAY(NREC+1)-WDAY(1)
      ELSE
        WRITE(6,6250) NREC,JDAY,NINT(YEAR),WDAY(NREC+1)-WDAY(1)
      ENDIF
      CALL EXIT(0)
      STOP
C
 6000 FORMAT(A40)
 6100 FORMAT(
     +      'IWI,JWI =',I4,',',I4,
     +   4X,'XFIN,YFIN =',F8.2,',',F8.2,
     +   4X,'DXIN,DYIN =',F6.3,',',F6.3 /
     +      'NREC =',I5,5X,'WDAY =' / (8F9.2) )
 6200 FORMAT(I5,' RECORD CLIMATOLOGY STARTING ON',F7.2,'/',I4,
     +   ' COVERING',F9.2,' DAYS')
 6250 FORMAT(I5,' WIND RECORDS STARTING ON',F7.2,'/',I4,
     +   ' COVERING',F9.2,' DAYS')
C     END OF WDSTAT.
      END
      SUBROUTINE WNDAY(WDAY, YEAR,DAY)
      IMPLICIT NONE
      REAL*4  WDAY,YEAR,DAY
C
C**********
C*
C  1) CONVERT 'WIND DAY' INTO JULIAN DAY AND YEAR.
C
C  2) THE 'WIND DAY' IS THE NUMBER OF DAYS SINCE 001/1901 (WHICH IS 
C      WIND DAY 1.0).
C     FOR EXAMPLE:
C      A) YEAR=1901.0 AND DAY=1.0, REPRESENTS 0000Z HRS ON 001/1901
C         SO WDAY WOULD BE 1.0.
C      B) YEAR=1901.0 AND DAY=2.5, REPRESENTS 1200Z HRS ON 002/1901
C         SO WDAY WOULD BE 2.5.
C     YEAR MUST BE NO LESS THAN 1901.0, AND NO GREATER THAN 2099.0.
C     NOTE THAT YEAR 2000 IS A LEAP YEAR (BUT 1900 AND 2100 ARE NOT).
C
C  3) ALAN J. WALLCRAFT, PLANNING SYSTEMS INC., FEBRUARY 1993.
C*
C**********
C
      INTEGER IYR,NLEAP
      REAL*4  WDAY1
C
C     FIND THE RIGHT YEAR.
C
      IYR   = (WDAY-1.0)/365.25
      NLEAP = IYR/4
      WDAY1 = 365.0*IYR + NLEAP + 1.0
      DAY   = WDAY - WDAY1 + 1.0
      IF     (WDAY1.GT.WDAY) THEN
        IYR   = IYR - 1
      ELSEIF (DAY.GE.367.0) THEN
        IYR   = IYR + 1
      ELSEIF (DAY.GE.366.0 .AND. MOD(IYR,4).NE.3) THEN
        IYR   = IYR + 1
      ENDIF
      NLEAP = IYR/4
      WDAY1 = 365.0*IYR + NLEAP + 1.0
C
C     RETURN YEAR AND JULIAN DAY.
C
      YEAR = 1901 + IYR
      DAY  = WDAY - WDAY1 + 1.0
      RETURN
C     END OF WNDAY.
      END
      SUBROUTINE GETENV(CNAME, CVALUE)
      IMPLICIT NONE
C
      CHARACTER*(*) CNAME,CVALUE
C
C     THIS SUBROUTINE PROVIDES GETENV FUNCTIONALITY
C     ON THE T3E, USING PXFGETENV.
C
      INTEGER*8 INAME,IVALUE,IERR
C
      INAME = 0
      IERR  = 0
      CALL PXFGETENV(CNAME,INAME, CVALUE,IVALUE, IERR)
      IF     (IERR.NE.0) THEN
        CVALUE = ' '
      ENDIF
      RETURN
C     END OF GETENV.
      END
