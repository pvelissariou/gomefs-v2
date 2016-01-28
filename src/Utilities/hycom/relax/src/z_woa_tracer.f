      PROGRAM TSZINT
      USE MOD_ZA  ! HYCOM array I/O interface
      USE netcdf  ! NetCDF fortran 90 interface
      IMPLICIT NONE
C
C     DEFINE INPUT TRACER CLIMATOLOGY GRID.
C
C     SETUP FOR 1.0 DEGREE WOA2001 (Levitus) GLOBAL CLIMATOLOGY.
C
      INTEGER    IWI,JWI
      REAL*4     XFIN,YFIN,DXIN,DYIN
      PARAMETER (IWI=360, JWI=180)
      PARAMETER (XFIN=0.5, YFIN=-89.5, DXIN=1.0, DYIN=1.0)
C
C     CLIM ARRAYS.
C
      INTEGER, ALLOCATABLE :: MSK(:,:)
      REAL*4,  ALLOCATABLE :: PLON(:,:),PLAT(:,:),XAF(:,:),YAF(:,:)
      REAL*4,  ALLOCATABLE :: TM(:,:),ZLEV(:)
C
      INTEGER   KWI
      REAL*4    XAMAX,XAMIN,YAMAX,YAMIN
      REAL*4    TSEAIN(IWI,JWI)
      CHARACTER PREAMBL(5)*79
C
C     NETCDF I/O VARIABLES.
C
      CHARACTER*(256) CFILET
      INTEGER         ncFIDt,ncVIDt,ncDIDt
C
C     INTERPOLATION ARRAYS.
C
      INTEGER IBD(4)
      REAL*4  TSEAI(IWI+4,JWI+4)
      REAL*4  FXI(IWI+4),FYI(JWI+4),
     +        WQSEA3(IWI+4,JWI+4,3),WK(3*(IWI+JWI+8)+1)
C
C     NAMELIST.
C
      INTEGER          JPR
      COMMON/NPROCS/   JPR
      SAVE  /NPROCS/
C
      CHARACTER*40     CTITLE
      CHARACTER*21     CTYPE
      NAMELIST/AFTITL/ CTITLE,CTYPE
      INTEGER          INTERP,MONTH,ITEST,JTEST
      NAMELIST/AFFLAG/ INTERP,MONTH,ITEST,JTEST,JPR
C
C**********
C*
C 1)  FROM UNFORMATTED Sig0-T OR Sig0-S OR T-S DATA ON ITS NATIVE GRID,
C      CREATE A FORMATTED MODEL GRID CLIM FILE SUITABLE FOR INPUT TO THE
C      HYCOM ISOPYCNAL CLIMATOLOGY GENERATOR OVER THE GIVEN REGION.
C
C     INTERPOLATION IS EITHER PIECEWISE BILINEAR OR CUBIC SPLINE.
C
C 2)  PARAMETERS:
C
C     NATIVE CLIM GRID SPECIFICATION, SEE (4):
C
C        IWI    = 1ST DIMENSION OF CLIM GRID
C        JWI    = 2ND DIMENSION OF CLIM GRID
C        JWI    = 3RD DIMENSION OF CLIM GRID (NUMBER OF Z-LEVELS)
C        XFIN   = LONGITUDE OF 1ST CLIM GRID POINT
C        YFIN   = LATITUDE  OF 1ST CLIM GRID POINT
C        DXIN   = CLIM LONGITUDINAL GRID SPACING
C        DYIN   = CLIM LATITUDINAL  GRID SPACING
C
C 3)  NAMELIST INPUT:
C
C     /AFTITL/
C        CTITLE - ONE (40-CHARACTER) LINE TITLE.
C        CTYPE  - ONE (21-CHARACTER) TRACER netCDF VARIABLE NAME.
C
C     /AFFLAG/
C        INTERP - INTERPOLATION FLAG.
C                   =0; PIECEWISE LINEAR
C                   =1; CUBIC SPLINE (DEFAULT)
C        MONTH  - MONTH OF CLIMATOLOGY (1 TO 12)
C        ITEST  - 1ST ARRAY INDEX FOR DIAGNOSTIC PRINTOUT
C                   =0; NO DIAGNOSTIC PRINTOUT
C        JTEST  - 2ND ARRAY INDEX FOR DIAGNOSTIC PRINTOUT
C                   =0; NO DIAGNOSTIC PRINTOUT
C
C 4)  INPUT:
C        ON UNIT  5: NAMELIST /AFTITL/, /AFTIME/
C        netCDF NATIVE Tracer CLIM FILE (ENV.VAR. CDF_TRACER), SEE (5).
C     OUTPUT:
C        ON UNIT 10:    UNFORMATTED MODEL    CLIM FILE, SEE (6).
C
C 5)  THE INPUT CLIM FIELDS, VIA NetCDF, ARE ON THE 'NATIVE' LAT-LON
C      GRID, STARTING AT THE POINT 'XFIN' EAST AND 'YFIN' NORTH WITH 
C      'YFIN' NORTH WITH GRIDSIZE 'DXIN' BY 'DYIN' DEGREES.  THE
C      INPUT ARRAY SIZE IS 'IWI' BY 'JWI', AND THERE ARE NO REPEATED
C      NODES (EVEN FOR GLOBAL DATA SETS).  
C
C     ALL CLIMATOLOGY FIELDS MUST BE DEFINED AT EVERY GRID POINT,
C      INCLUDING LAND AND BELOW THE OCEAN FLOOR.
C
C 6)  THE OUTPUT CLIMS ARE AT EVERY GRID POINT OF THE MODEL'S 'P' GRID.
C     ARRAY SIZE IS 'IDM' BY 'JDM'.
C
C 7)  SEVERAL STATISTICS ARE WRITTEN OUT IN ORDER TO CHECK THE 
C      INTERPOLATION BETWEEN VARIOUS MACHINES.  MIN, MAX, MEAN AND RMS 
C      OF THE ENTIRE BASIN ARE OUTPUT FOR (TM, SM, RM) FOR EACH 
C      RECORD.  NOTE HOWEVER THAT THESE VALUES MAY NOT REPRESENT THE
C      STATISTICS OF THE CLIMS AS SEEN BY THE MODEL, IF THE INPUT CLIM 
C      DATA HAS NON-REALISTIC VALUES OVER LAND.  IT IS UP TO THE USER 
C      TO CHECK THE LOG FILES FOR CONSISTENCY BETWEEN MACHINES.
C
C 8)  ALAN J. WALLCRAFT,  PLANNING SYSTEMS INC.,  OCTOBER 1995.
C      BASED ON EARILER VERSIONS BY SEVERAL AUTHORS.
C*
C**********
C
      EXTERNAL LINEAR, AVERMS,MINMAX
C
      REAL*4     ZERO,RADIAN
      PARAMETER (ZERO=0.0, RADIAN=57.2957795)
      REAL*8     DZERO,DTHIRD
      PARAMETER (DZERO=0.D0,DTHIRD=1.D0/3.D0)
C
      CHARACTER*80 CLINE
      CHARACTER*40 CCNAME
      INTEGER IUNIT,IWIT,JWIT,KWIT
      REAL*4  XFINT,YFINT,DXINT,DYINT
      REAL*4  HMINA,HMINB,HMAXA,HMAXB
C
      INTEGER I,IWIX,J,KREC
      REAL*4  XFD,YFD,DXD,DYD
      REAL*4  XLIN,XFDX,XOV,YOU,
     +        XMIN,XMAX,XAVE,XRMS
C
      CHARACTER*11 CMONTH(12)
      DATA CMONTH /  ', January',
     +               ', February',
     +               ', March',
     +               ', April',
     +               ', May',
     +               ', June',
     +               ', July',
     +               ', August',
     +               ', September',
     +               ', October',
     +               ', November',
     +               ', December'  /
C
C --- MODEL ARRAYS.
C
      CALL XCSPMD  !define idm,jdm
      ALLOCATE(  MSK(IDM,JDM) )
      ALLOCATE( PLON(IDM,JDM) )
      ALLOCATE( PLAT(IDM,JDM) )
      ALLOCATE(  XAF(IDM,JDM) )
      ALLOCATE(  YAF(IDM,JDM) )
      ALLOCATE(   TM(IDM,JDM) )
C
C     NAMELIST INPUT.
C
      CALL ZHOPEN(6, 'FORMATTED', 'UNKNOWN', 0)
C
      CTITLE = ' '
      WRITE(6,*) 'READING /AFTITL/'
      CALL ZHFLSH(6)
      READ( 5,AFTITL)
      WRITE(6,AFTITL)
C
      INTERP = 1
      MONTH  = 1
      ITEST  = 0
      JTEST  = 0
      JPR    = 8
      WRITE(6,*) 'READING /AFFLAG/'
      CALL ZHFLSH(6)
      READ( 5,AFFLAG)
      WRITE(6,AFFLAG)
      WRITE(6,*)
      CALL ZHFLSH(6)
C
C     GRID INPUT.
C
      CALL ZAIOST
C
      CALL ZHOPNC(21, 'regional.grid.b', 'FORMATTED', 'OLD', 0)
      CALL ZAIOPF('regional.grid.a', 'OLD', 21)
C
      READ(21,*) ! skip idm
      READ(21,*) ! skip jdm
      READ(21,*) ! skip mapflg
      READ(21,'(A)') CLINE
      I = INDEX(CLINE,'=')
      READ (CLINE(I+1:),*)   HMINB,HMAXB
      CALL ZAIORD(PLON,MSK,.FALSE., HMINA,HMAXA, 21)
      IF     (ABS(HMINA-HMINB).GT.ABS(HMINB)*1.E-4 .OR.
     &        ABS(HMAXA-HMAXB).GT.ABS(HMAXB)*1.E-4     ) THEN
        WRITE(6,'(/ a / a,1p3e14.6 / a,1p3e14.6 /)')
     &    'error - .a and .b grid files not consistent (plon):',
     &    '.a,.b min = ',HMINA,HMINB,HMINA-HMINB,
     &    '.a,.b max = ',HMAXA,HMAXB,HMAXA-HMAXB
        CALL ZHFLSH(6)
        STOP
      ENDIF
C
      READ(21,'(A)') CLINE
      I = INDEX(CLINE,'=')
      READ (CLINE(I+1:),*)   HMINB,HMAXB
      CALL ZAIORD(PLAT,MSK,.FALSE., HMINA,HMAXA, 21)
      IF     (ABS(HMINA-HMINB).GT.ABS(HMINB)*1.E-4 .OR.
     &        ABS(HMAXA-HMAXB).GT.ABS(HMAXB)*1.E-4     ) THEN
        WRITE(6,'(/ a / a,1p3e14.6 / a,1p3e14.6 /)')
     &    'error - .a and .b grid files not consistent (plat):',
     &    '.a,.b min = ',HMINA,HMINB,HMINA-HMINB,
     &    '.a,.b max = ',HMAXA,HMAXB,HMAXA-HMAXB
        CALL ZHFLSH(6)
        STOP
      ENDIF
C
      CLOSE(UNIT=21)
      CALL ZAIOCL(21)
C
C     INITIALIZE OUTPUT.
C
      CTITLE = trim(CTITLE) // CMONTH(MONTH)
      WRITE(6,6000) 'OUTPUT:',CTITLE
      CALL ZHFLSH(6)
C
      CALL ZAIOPN('NEW', 10)
      CALL ZAIOPN('NEW', 11)
      CALL ZAIOPN('NEW', 12)
C
      CALL ZHOPEN(10, 'FORMATTED', 'NEW', 0)
      CALL ZHOPEN(11, 'FORMATTED', 'NEW', 0)
      CALL ZHOPEN(12, 'FORMATTED', 'NEW', 0)
C
      PREAMBL(1) = CTITLE
      PREAMBL(2) = ' '
      PREAMBL(3) = ' '
      PREAMBL(4) = ' '
      WRITE(PREAMBL(5),'(A,2I5)')
     +        'i/jdm =',
     +       IDM,JDM
      WRITE(10,4101) PREAMBL
C
      WRITE(6,*)
      WRITE(6, 4101) PREAMBL
      WRITE(6,*)
C
C     INITIALIZE CLIMS.
C
      CALL GETENV('CDF_TRACER',CFILET)
      WRITE(6,*)
      WRITE(6,*) 'CDF_TRACER = ',trim(CFILET)
      CALL ZHFLSH(6)
      ! open NetCDF file
      call ncheck(nf90_open(trim(CFILET), nf90_nowrite, ncFIDt))
      ! get KWI
      WRITE(6,*) 'nf90_inq_dimid - ', 'Depth'
      CALL ZHFLSH(6)
      call ncheck(nf90_inq_dimid(        ncFIDt, 'Depth',ncDIDt))
      call ncheck(nf90_inquire_dimension(ncFIDt,         ncDIDt,
     +                                                  len=kwi))
      WRITE(6,*) 'KWI = ',KWI
      CALL ZHFLSH(6)
      ! get ZLEV
      ALLOCATE(  ZLEV(KWI) )
      WRITE(6,*) 'nf90_inq_varid - ','Depth'
      CALL ZHFLSH(6)
      call ncheck(nf90_inq_varid(ncFIDt,'Depth',ncVIDt))
      call ncheck(nf90_get_var(  ncFIDt,        ncVIDt,ZLEV(:)))
      ZLEV(:) = ABS(ZLEV(:))  !positive downwards
      ! inquire variable ID
      WRITE(6,*) 'nf90_inq_varid - ',trim(ctype)
      CALL ZHFLSH(6)
      call ncheck(nf90_inq_varid(ncFIDt,trim(ctype),ncVIDt))
C
C     DEFINE THE GRID COORDINATES.
C
      IF     (IWI*DXIN.GE.359.9) THEN
        IF     (ABS(IWI * DXIN - 360.0) .GT. 0.01) THEN
          WRITE(6,9050)
          CALL ZHFLSH(6)
          STOP
        ENDIF
        IWIX = IWI + 1
        IBD(1) = 3
        IBD(2) = 3
        IBD(3) = 2
        IBD(4) = 2
      ELSE
        IWIX = IWI
        IBD(1) = 2
        IBD(2) = 2
        IBD(3) = 2
        IBD(4) = 2
      ENDIF
C
C     CONVERT HYCOM LON,LAT TO CLIMATOLOGY ARRAY COORDS.
C
      XLIN  = XFIN + (IWIX-1)*DXIN
      XAMIN = 2*IWI
      XAMAX = 0
      DO J= 1,JDM
        DO I= 1,IDM
          XOV = PLON(I,J)
          IF     (XOV.LT.XFIN) THEN
            XOV = XOV + 360.0
          ELSEIF (XOV.GE.XLIN) THEN
            XOV = XOV - 360.0
          ENDIF
C
          XAF(I,J) = 3.0 + (XOV - XFIN)/DXIN
C
          IF     (MOD(J,100).EQ.1 .OR. J.EQ.JDM) THEN
            IF     (MOD(I,10).EQ.1 .OR. I.EQ.IDM) THEN
              WRITE(6,'("I,J,LONV,XAF =",2I5,2F10.3)') I,J,XOV,XAF(I,J)
            ENDIF
          ENDIF
          XAMIN  = MIN( XAMIN, XAF(I,J) )
          XAMAX  = MAX( XAMAX, XAF(I,J) )
        ENDDO
      ENDDO
C
      YAMIN = 2*JWI
      YAMAX = 0
      DO I= 1,IDM
        DO J= 1,JDM
          YOU = PLAT(I,J)
C
          YAF(I,J) = 3.0 + (YOU - YFIN)/DYIN
C
          IF     (MOD(I,100).EQ.1 .OR. I.EQ.IDM) THEN
            IF     (MOD(J,10).EQ.1 .OR. J.EQ.JDM) THEN
              WRITE(6,'("I,J,LATU,YAF =",2I5,2F10.3)') I,J,YOU,YAF(I,J)
            ENDIF
          ENDIF
          YAMIN  = MIN( YAMIN, YAF(I,J) )
          YAMAX  = MAX( YAMAX, YAF(I,J) )
        ENDDO
      ENDDO
C
      WRITE(6,6200) XAMIN,XAMAX,YAMIN,YAMAX
      CALL ZHFLSH(6)
C
C     CHECK THAT THE INTERPOLATION IS 'SAFE',
C
      IF     (INT(XAMIN).LT.3 .OR. INT(XAMAX).GT.IWI+2 .OR.
     +        INT(YAMIN).LT.3 .OR. INT(YAMAX).GT.JWI+2     ) THEN
        WRITE(6,9150)
        CALL ZHFLSH(6)
        STOP
      ENDIF
C
C     PROCESS ALL THE CLIM RECORDS.
C
      DO 810 KREC= 1,KWI
C
C       READ THE INPUT CLIMS.
C
        call ncheck(nf90_get_var(ncFIDt,ncVIDt,
     &                           TSEAIN(:,:),
     &                           (/ 1,1,KREC /) ))
C
C       COPY INTO THE (LARGER) INTERPOLATION ARRAYS.
C
        DO 310 J= 1,JWI
          DO 311 I= 1,IWI
            TSEAI(I+2,J+2) = TSEAIN(I,J)
  311     CONTINUE
  310   CONTINUE
C
C       FILL IN THE PADDING AREA AS NECESSARY.
C
        IF     (INT(XAMAX).GE.IWI+1) THEN
          IF     (IWIX.GT.IWI) THEN
            DO 320 J= 3,JWI+2
              TSEAI(IWI+3,J) = TSEAI(3,J)
              TSEAI(IWI+4,J) = TSEAI(4,J)
  320       CONTINUE
          ELSE
            DO 325 J= 3,JWI+2
              TSEAI(IWI+3,J) = 2.0*TSEAI(IWI+2,J) -     TSEAI(IWI+1,J)
              TSEAI(IWI+4,J) = 3.0*TSEAI(IWI+2,J) - 2.0*TSEAI(IWI+1,J)
  325       CONTINUE
          ENDIF
        ENDIF
        IF     (INT(XAMIN).LE.3) THEN
          IF     (IWIX.GT.IWI) THEN
            DO 330 J= 3,JWI+2
              TSEAI(1,J) = TSEAI(IWI+1,J)
              TSEAI(2,J) = TSEAI(IWI+2,J)
  330       CONTINUE
          ELSE
            DO 335 J= 3,JWI+2
              TSEAI(1,J) = 3.0*TSEAI(3,J) - 2.0*TSEAI(4,J)
              TSEAI(2,J) = 2.0*TSEAI(3,J) -     TSEAI(4,J)
  335       CONTINUE
          ENDIF
        ENDIF
        IF     (INT(YAMAX).GE.JWI+1) THEN
          DO 340 I= 1,IWI+4
            TSEAI(I,JWI+3) = 2.0*TSEAI(I,JWI+2) -     TSEAI(I,JWI+1)
            TSEAI(I,JWI+4) = 3.0*TSEAI(I,JWI+2) - 2.0*TSEAI(I,JWI+1)
  340     CONTINUE
        ENDIF
        IF     (INT(YAMIN).LE.3) THEN
          DO 350 I= 1,IWI+4
            TSEAI(I,1) = 3.0*TSEAI(I,3) - 2.0*TSEAI(I,4)
            TSEAI(I,2) = 2.0*TSEAI(I,3) -     TSEAI(I,4)
  350     CONTINUE
        ENDIF
C
C       INTERPOLATE FROM NATIVE TO MODEL CLIM GRIDS.
C
        IF     (INTERP.EQ.0) THEN
          CALL LINEAR(TM,XAF,YAF,IDM,IDM,JDM,
     +                TSEAI,IWI+4,IWI+4,JWI+4)
        ELSE
          CALL CUBSPL(TM,XAF,YAF,IDM,IDM,JDM,
     +                TSEAI,IWI+4,IWI+4,JWI+4, IBD, FXI,FYI,WQSEA3,WK)
        ENDIF
C
C       WRITE OUT STATISTICS.
C
        CALL MINMAX(TM,IDM,JDM, XMIN,XMAX)
        CALL AVERMS(TM,IDM,JDM, XAVE,XRMS)
        WRITE(6,8100) 'TSEA', XMIN,XMAX,XAVE,XRMS
C
C       DIAGNOSTIC PRINTOUT.
C
        IF     (MIN(ITEST,JTEST).GT.0) THEN
          WRITE(6,*)
          WRITE(6,'(A,2I5,I3,A,F8.2,A,F6.2)')
     +      'I,J,K =',ITEST,JTEST,KREC,
     +      '   ZLEV =',ZLEV(KREC),
     +         '   T =',TM(ITEST,JTEST)
          WRITE(6,*)
          CALL ZHFLSH(6)
        ENDIF
C
C       WRITE OUT HYCOM CLIMS.
C
        CALL ZAIOWR(TM,MSK,.FALSE., XMIN,XMAX, 10, .FALSE.)
        WRITE(10,4102) TRIM(CTYPE),ZLEV(KREC),XMIN,XMAX
C
        WRITE(6,6300) KREC,ZLEV(KREC)
        CALL ZHFLSH(6)
  810 CONTINUE
C
      CALL ZAIOCL(10)
      CLOSE( UNIT=10)
C
C     SUMMARY.
C
      WRITE(6,6400) KWI
      CALL ZHFLSH(6)
      STOP
C
 4101 FORMAT(A79)
 4102 FORMAT(A,': depth,range = ',F7.1,1P2E16.7)
 6000 FORMAT(1X,A,2X,A40 //)
 6200 FORMAT(/ 1X,'MIN,MAX I COORDS = ',F8.2,',',F8.2 
     +       / 1X,'MIN,MAX J COORDS = ',F8.2,',',F8.2 /)
 6300 FORMAT(10X,'WRITING CLIM RECORD',I3,'     ZLEV =',F7.1 /)
 6400 FORMAT(I5,' LEVEL CLIMATOLOGY COMPLETED.')
 8100 FORMAT(1X,A,': MIN=',F13.8,' MAX=',F13.8,
     +             ' AVE=',F13.8,' RMS=',F13.8)
 9000 FORMAT(// 20X,'*****  ERROR ON UNIT -',I3,
     +   ' INPUT DOES NOT AGREE WITH PARAMETERS  *****' //
     +   1X,'IWI,JWI,KWI = ',I5,  I10,  I4 /
     +   1X,'XFIN,YFIN   = ',F8.2,F10.2    /
     +   1X,'DXIN,DYIN   = ',F9.3, F9.3    //)
 9050 FORMAT(// 20X,'**********  ERROR - ',
     +   'INPUT IS GLOBAL AND IWI*DXIN IS NOT 360 DEGREES  ****' //)
 9150 FORMAT(// 20X,'**********  ERROR - ',
     +   'THE OUTPUT GRID IS NOT INSIDE THE INPUT GRID  **********' //)
C     END OF PROGRAM WNDINT.
      END

      subroutine ncheck(status)
      use netcdf   ! NetCDF fortran 90 interface
      implicit none
c
      integer, intent(in) :: status
c
c     subroutine to handle NetCDF errors
c
      if (status /= nf90_noerr) then
        write(6,'(/a)')   'error from NetCDF library'
        write(6,'(a/)')   trim(nf90_strerror(status))
        call zhflsh(6)
        stop
      end if
      end subroutine ncheck
