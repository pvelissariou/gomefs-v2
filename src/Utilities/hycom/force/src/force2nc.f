      PROGRAM FORCE2NC
      USE MOD_ZA  ! HYCOM array I/O interface
      IMPLICIT NONE
C
C     WIND/FLUX ARRAYS.
C
      INTEGER, ALLOCATABLE :: MSK(:,:)
      REAL,    ALLOCATABLE :: FLD(:,:),PLON(:,:),PLAT(:,:)
C
      CHARACTER PREAMBL(5)*79,CNAME*8,PNAME*80,SNAME*80,UNAME*80
C
C**********
C*
C 1)  FROM WIND/FLUX FIELDS (.[ab] FILES) ON THE MODEL GRID,
C      CREATE A CORROSPONDING NETCDF FILE.
C
C 2)  INPUT:
C        ON UNIT 20:    UNFORMATTED MODEL FIELD FILE
C     OUTPUT:
C                       NETCDF MODEL FIELD FILE
C
C        The NetCDF filename is taken from
C         environment variable CDF_FILE, with no default.
C        The NetCDF title and institution are taken from 
C         environment variables CDF_TITLE and CDF_INST.
C
C 3)  THE INPUT AND OUTPUT FIELDS ARE AT EVERY GRID POINT OF THE MODEL'S
C     'P' GRID.  ARRAY SIZE IS 'IDM' BY 'JDM'.
C
C 4)  ALAN J. WALLCRAFT,  NRL,  MAY 2004.
C*
C**********
C
      INTEGER    MAXREC
      PARAMETER (MAXREC=190000)
C
      CHARACTER*240 CLINE
      INTEGER       NREC
      REAL          WDAY(MAXREC+1),WSTRT,WEND
      REAL          HMINA,HMINB,HMAXA,HMAXB
C
      INTEGER       I,J,KREC
      REAL          FDY,WYR
      LOGICAL       NEWREC,LEOF
C
C --- MODEL ARRAYS.
C
      CALL XCSPMD  !define idm,jdm
      CALL ZHFLSH(6)
      ALLOCATE(  MSK(IDM,JDM) )
      ALLOCATE(  FLD(IDM,JDM) )
      ALLOCATE( PLON(IDM,JDM) )
      ALLOCATE( PLAT(IDM,JDM) )
*         WRITE(6,*) 'allocated 4 arrays'
*         CALL ZHFLSH(6)
C
      CALL ZHOPEN(6, 'FORMATTED', 'UNKNOWN', 0)
C
      CALL ZAIOST
*         WRITE(6,*) 'exit ZAIOST'
*         CALL ZHFLSH(6)
C
C     GRID INPUT.
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
C     INITIALIZE INPUT.
C
      CALL ZAIOPN('OLD', 20)
      CALL ZHOPEN(20, 'FORMATTED', 'OLD', 0)
C
      READ( 20,'(A79)') PREAMBL
      WRITE(6,*)
      WRITE(6, '(A79)') PREAMBL
      WRITE(6,*)
      CALL ZHFLSH(6)
C
C     LOOP THROUGH ALL RECORDS.
C
      KREC = 0
      DO
        KREC = KREC+1
        CALL READ20(FLD,MSK, WDAY(KREC),CNAME,LEOF)
        IF     (LEOF) THEN
          EXIT
        ENDIF
C
C       DETECT COMMON FIELD NAMES.
C
        IF     (KREC.EQ.1) THEN
          CALL NAMES(CNAME, PNAME,SNAME,UNAME)
        ENDIF
C
C       WRITE OUT HYCOM WINDS/FLUXS.
C
        WDAY(KREC+1) = WDAY(KREC) + (WDAY(KREC) - WDAY(MAX(1,KREC-1)))
*           WRITE(6,*) 'CALL HOROUT, KREC = ',KREC
*           CALL ZHFLSH(6)
        CALL HOROUT(FLD,PLON,PLAT,IDM,JDM,WDAY(KREC),WDAY(KREC+1),
     +              PNAME,CNAME,SNAME,UNAME)
*           WRITE(6,*) 'EXIT HOROUT, KREC = ',KREC
*           CALL ZHFLSH(6)
      ENDDO
      STOP
C
C     END OF PROGRAM FORCE2NC
      END
      SUBROUTINE WNDAY(WDAY, YEAR,DAY)
      IMPLICIT NONE
      REAL   WDAY,YEAR,DAY
C
C**********
C*
C  1) CONVERT 'FLUX DAY' INTO JULIAN DAY AND YEAR.
C
C  2) THE 'FLUX DAY' IS THE NUMBER OF DAYS SINCE 001/1901 (WHICH IS 
C      FLUX DAY 1.0).
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
      REAL    WDAY1
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
      SUBROUTINE READ20(FIN,MSK, DAY,CNAME,LEOF)
      USE MOD_ZA  ! HYCOM array I/O interface
      IMPLICIT NONE
C
      LOGICAL     LEOF
      CHARACTER*8 CNAME
      INTEGER     MSK(IDM,JDM)
      REAL        FIN(IDM,JDM),DAY
C
C     READ THE NEXT WIND/FLUX RECORD ON UNIT 20.
C
      INTEGER       I,IOS,MONTH
      REAL          FINC,XMINA,XMAXA,XMINB,XMAXB
      CHARACTER*240 CLINE
C
      READ(20,'(A)',IOSTAT=IOS) CLINE
      LEOF = IOS.NE.0
      IF     (LEOF) THEN
        RETURN
      ENDIF
      I = INDEX(CLINE,':')
      CNAME = TRIM(CLINE(MAX(1,10-I):I-1))
      DO I= 1,7
        IF     (CNAME(1:1).NE.' ') THEN
          EXIT
        ENDIF
        CNAME= CNAME(2:8)
      ENDDO
      I = INDEX(CLINE,'month')
      IF     (I.NE.0) THEN
        I = INDEX(CLINE,'=')
        READ(CLINE(I+1:),*) MONTH,XMINB,XMAXB
        DAY  = 1111.0 + (MONTH-1)*30.5  !1st record nominaly on Jan 16th 1904.
        FINC = 30.5
      ELSE
        I = INDEX(CLINE,'=')
        READ(CLINE(I+1:),*) DAY,FINC,XMINB,XMAXB
      ENDIF
      IF     (XMINB.EQ.XMAXB) THEN  !constant field
        FIN(:,:) = XMINB
        CALL ZAIOSK(20)
      ELSE
        CALL ZAIORD(FIN,MSK,.FALSE., XMINA,XMAXA, 20)
        IF     (ABS(XMINA-XMINB).GT.ABS(XMINB)*1.E-4 .OR.
     &          ABS(XMAXA-XMAXB).GT.ABS(XMAXB)*1.E-4     ) THEN
          WRITE(6,'(/ a / a,1p3e14.6 / a,1p3e14.6 /)')
     &      'error (read20) - .a and .b files not consistent:',
     &      '.a,.b min = ',XMINA,XMINB,XMINA-XMINB,
     &      '.a,.b max = ',XMAXA,XMAXB,XMAXA-XMAXB
          CALL ZHFLSH(6)
          STOP
        ENDIF
      ENDIF
*
*     WRITE(6,"(A,F9.2)") 'READ20:',DAY
*     CALL ZHFLSH(6)
      RETURN
      END

      SUBROUTINE NAMES(CNAME, PNAME,SNAME,UNAME)
      IMPLICIT NONE
C
      CHARACTER*8   CNAME  ! ncdf name
      CHARACTER*(*) PNAME, ! plot name
     +              SNAME, ! ncdf standard_name
     +              UNAME  ! units
C
C     DETECT COMMON FIELD TYPES,
C     OR USE ENVIRONMENT VARIABLES CDF_[PSU]NAME.
C
      PNAME = ' '
      CALL GETENV('CDF_PNAME',PNAME)
      SNAME = ' '
      CALL GETENV('CDF_SNAME',SNAME)
      UNAME = ' '
      CALL GETENV('CDF_UNAME',UNAME)
      IF     (PNAME.NE.' ' .OR.
     +        SNAME.NE.' ' .OR.
     +        UNAME.NE.' '     )THEN
        RETURN
      ENDIF
C
      IF     (CNAME.EQ.'radflx') THEN
        PNAME = ' surf. rad. flux  '
        SNAME = 'surface_net_downward_radiative_flux'  !downward = into ocean
        UNAME = 'w/m2'
      ELSEIF (CNAME.EQ.'shwflx') THEN
        PNAME = ' surf. shw. flux  '
        SNAME = 'surface_net_downward_shortwave_flux'  !downward = into ocean
        UNAME = 'w/m2'
      ELSEIF (CNAME.EQ.'vapmix') THEN
        PNAME = ' vapor mix. ratio '
        SNAME = 'specific_humidity'  !specific humidity and
                                     ! water vapor mixing ratio
                                     ! are essentially interchangable
        UNAME = 'kg/kg'
      ELSEIF (CNAME.EQ.'airtmp') THEN
        PNAME = ' air temperature  '
        SNAME = 'air_temperature'
        UNAME = 'degC'  !should be K but oceanographers use degC
      ELSEIF (CNAME.EQ.'surtmp') THEN
        PNAME = '  surface temp.   '
        SNAME = 'surface_temperature'  !sea or sea ice
        UNAME = 'degC'  !should be K but oceanographers use degC
      ELSEIF (CNAME.EQ.'seatmp') THEN
        PNAME = ' sea surf. temp.  '
        SNAME = 'sea_surface_temperature'
        UNAME = 'degC'  !should be K but oceanographers use degC
      ELSEIF (CNAME.EQ.'precip') THEN
        PNAME = ' precipitation    '
        SNAME = 'lwe_precipitation_rate' ! "lwe" is liquid water equivalent
        UNAME = 'm/s'
      ELSEIF (CNAME.EQ.'wndspd' .OR. CNAME.EQ.'wnd_spd') THEN
        PNAME = ' 10m wind speed   '
        SNAME = 'wind_speed'
        UNAME = 'm/s'
      ELSEIF (CNAME.EQ.'tauewd' .OR. CNAME.EQ.'tau_ewd') THEN
        PNAME = ' Ewd wind stress  '
        SNAME = 'surface_downward_eastward_stress'  !downward = into ocean
        UNAME = 'Pa'
      ELSEIF (CNAME.EQ.'taunwd' .OR. CNAME.EQ.'tau_nwd') THEN
        PNAME = ' Nwd wind stress  '
        SNAME = 'surface_downward_northward_stress'  !downward = into ocean
        UNAME = 'Pa'
      ELSE
        PNAME = ' Unknown Scalar   '
        SNAME = 'unknown_field'
        UNAME = ' '
      ENDIF
      RETURN
      END

      subroutine fordate(dtime,yrflag, iyear,month,iday,ihour)
      implicit none
c
      double precision dtime
      integer          yrflag, iyear,month,iday,ihour
c
c --- converts model day to "calendar" date (year,month,day,hour).
c
      integer          jday,k,m
c
      integer month0(13,3)
      data month0 / 1,  31,  61,  91, 121, 151, 181,
     +                 211, 241, 271, 301, 331, 361,
     +              1,  32,  60,  91, 121, 152, 182,
     +                 213, 244, 274, 305, 335, 366,
     +              1,  32,  61,  92, 122, 153, 183,
     +                 214, 245, 275, 306, 336, 367 /
c
      call forday(dtime,yrflag, iyear,jday,ihour)
c
      if (yrflag.eq.3) then
        if     (mod(iyear,4).eq.0) then
          k = 3
        else
          k = 2
        endif
      elseif (yrflag.eq.0) then
        k = 1
      else
        k = 3
      endif
      do m= 1,12
        if     (jday.ge.month0(m,  k) .and.
     +          jday.lt.month0(m+1,k)      ) then
          month = m
          iday  = jday - month0(m,k) + 1
        endif
      enddo
      return
      end

      subroutine forday(dtime,yrflag, iyear,iday,ihour)
      implicit none
c
      double precision dtime
      integer          yrflag, iyear,iday,ihour
c
c --- converts model day to "calendar" date (year,julian-day,hour).
c
      double precision dtim1,day
      integer          iyr,nleap
c
      if     (yrflag.eq.0) then
c ---   360 days per model year, starting Jan 16
        iyear =  int((dtime+15.001d0)/360.d0) + 1
        iday  =  mod( dtime+15.001d0 ,360.d0) + 1
        ihour = (mod( dtime+15.001d0 ,360.d0) + 1.d0 - iday)*24.d0
c
      elseif (yrflag.eq.1) then
c ---   366 days per model year, starting Jan 16
        iyear =  int((dtime+15.001d0)/366.d0) + 1
        iday  =  mod( dtime+15.001d0 ,366.d0) + 1
        ihour = (mod( dtime+15.001d0 ,366.d0) + 1.d0 - iday)*24.d0
c
      elseif (yrflag.eq.2) then
c ---   366 days per model year, starting Jan 01
        iyear =  int((dtime+ 0.001d0)/366.d0) + 1
        iday  =  mod( dtime+ 0.001d0 ,366.d0) + 1
        ihour = (mod( dtime+ 0.001d0 ,366.d0) + 1.d0 - iday)*24.d0
c
      elseif (yrflag.eq.3) then
c ---   model day is calendar days since 01/01/1901
        iyr   = (dtime-1.d0)/365.25d0
        nleap = iyr/4
        dtim1 = 365.d0*iyr + nleap + 1.d0
        day   = dtime - dtim1 + 1.d0
        if     (dtim1.gt.dtime) then
          iyr = iyr - 1
        elseif (day.ge.367.d0) then
          iyr = iyr + 1
        elseif (day.ge.366.d0 .and. mod(iyr,4).ne.3) then
          iyr = iyr + 1
        endif
        nleap = iyr/4
        dtim1 = 365.d0*iyr + nleap + 1.d0
c
        iyear =  1901 + iyr
        iday  =  dtime - dtim1 + 1
        ihour = (dtime - dtim1 + 1.d0 - iday)*24.d0
c
      else
        write( 6,*)
        write( 6,*) 'error in forday - unsupported yrflag value'
        write( 6,*)
        stop '(forday)'
      endif
      return
      end

      subroutine horout(array,plon,plat,ii,jj,wday,wday_next,
     &                  name,namec,names,units)
      use netcdf   ! NetCDF fortran 90 interface
      implicit none
c
      character*(*) name,namec,names,units
      integer       ii,jj
      real          array(ii,jj),plon(ii,jj),plat(ii,jj)
      real          wday,wday_next
c
c     the NetCDF filename is taken from
c      environment variable CDF_FILE, with no default.
c     the NetCDF title and institution are taken from 
c      environment variables CDF_TITLE and CDF_INST.
c
c     This routine needs version 3.5 of the NetCDF library, from: 
c     http://www.unidata.ucar.edu/packages/netcdf/
c
      integer          :: ncfileID, status, varID
      integer          :: pLatDimID,pLonDimID,pLatVarID,pLonVarID
      integer          :: pYDimID,pXDimID,pYVarID,pXVarID
      integer          :: MTDimID,MTVarID,datVarID
      character        :: ncfile*240,ncenv*240
c
      logical          :: lopen,lexist
      integer          :: i,j,l,iyear,month,iday,ihour,
     &                          iyrms,monms,idms,ihrms
      real             :: hmin,hmax,hrange(2)
      double precision :: time,time_next,year,date_next
c
      integer,          save :: mt_rec  = 0
      double precision, save :: date    = 0.d0
      logical,          save :: laxis
      real,        parameter :: fill_value = 2.0**100
c
      save
c
      if     (mt_rec.eq.0) then
c
c       initialization.
c
        mt_rec = 1
c
        write(6,'(2a)') 'horout - name =',trim( name)
        write(6,'(2a)') 'horout - namec=',trim(namec)
        write(6,'(2a)') 'horout - names=',trim(names)
        write(6,'(2a)') 'horout - units=',trim(units)
c
        laxis = .true.
        do i= 2,ii
          laxis = laxis .and. 
     &            maxval(abs(plat(1,:)-plat(i,:))).le.1.e-2
        enddo
        do j= 2,jj
          laxis = laxis .and. 
     &            maxval(abs(plon(:,1)-plon(:,j))).le.1.e-2
        enddo
c
        if     (laxis) then
          write( 6,'(/2a/)') 'horout - NetCDF I/O (lat/lon axes)'
        else
          write( 6,'(/2a/)') 'horout - NetCDF I/O (curvilinear)'
        endif
c
c       NetCDF I/O
c
        time = wday
c       correct wind day to nearest 15 minutes
        time = nint(time*96.d0)/96.d0
        call fordate(time,3, iyear,month,iday,ihour)
        date = (iday + 100 * month + 10000 * iyear) + 
     &         (time - int(time))
c
        time_next = wday_next
        time_next = nint(time_next*96.d0)/96.d0
        call fordate(time_next,3, iyear,month,iday,ihour)
        date_next = (iday + 100 * month + 10000 * iyear) + 
     &              (time_next - int(time_next))
c
        write(6,6300) mt_rec,time,date
        call zhflsh(6)
c
        ncfile = ' '
        call getenv('CDF_FILE',ncfile)
        if     (ncfile.eq.' ') then
          write( 6,'(/a/)')  'error in horout - CDF_FILE not defined'
          stop
        endif
c
        call ncrange(array,ii,jj,1, fill_value, hmin,hmax)
c
        inquire(file= ncfile, exist=lexist)
        if (lexist) then
          write( 6,'(/2a/a/)')  'error in horout - ',
     &                        'CDF_FILE is an existing file',
     &                        trim(ncfile)
          stop
        else
c
c          create a new NetCDF and write data to it
c
          call nchek("nf90_create",
     &                nf90_create(trim(ncfile),nf90_noclobber,ncfileID))
          ! define the dimensions
          call nchek("nf90_def_dim-MT",
     &                nf90_def_dim(ncfileID,
     &                             "MT", nf90_unlimited,MTDimID))
          if     (laxis) then
            call nchek("nf90_def_dim-Latitude",
     &                  nf90_def_dim(ncfileID,
     &                               "Latitude",  jj,pLatDimID))
            call nchek("nf90_def_dim-Longitude",
     &                  nf90_def_dim(ncfileID,
     &                               "Longitude", ii,pLonDimID))
          else
            call nchek("nf90_def_dim-Y",
     &                  nf90_def_dim(ncfileID,
     &                               "Y",         jj,pYDimID))
            call nchek("nf90_def_dim-X",
     &                  nf90_def_dim(ncfileID,
     &                               "X",         ii,pXDimID))
          endif
          ! create the global attributes
          call nchek("nf90_put_att-Conventions",
     &                nf90_put_att(ncfileID,nf90_global,
     &                             "Conventions",
     &                             "CF-1.0"))
            ncenv = ' '
            call getenv('CDF_TITLE',ncenv)
            if     (ncenv.eq.' ') then
              ncenv = "HYCOM"
            endif
            call nchek("nf90_put_att-title",
     &                  nf90_put_att(ncfileID,nf90_global,
     &                               "title",
     &                               trim(ncenv)))
            ncenv = ' '
            call getenv('CDF_INST',ncenv)
            if     (ncenv.ne.' ') then
              call nchek("nf90_put_att-institution",
     &                    nf90_put_att(ncfileID,nf90_global,
     &                                 "institution",
     &                                 trim(ncenv)))
            endif
            call nchek("nf90_put_att-source",
     &                  nf90_put_att(ncfileID,nf90_global,
     &                               "source",
     &                               "HYCOM forcing file"))
            call nchek("nf90_put_att-history",
     &                  nf90_put_att(ncfileID,nf90_global,
     &                               "history",
     &                               "force2nc"))
          ! create the variables and attributes
            call nchek("nf90_def_var-MT",
     &                  nf90_def_var(ncfileID,"MT",  nf90_double,
     &                               MTDimID,MTVarID))
              call nchek("nf90_put_att-long_name",
     &                    nf90_put_att(ncfileID,MTVarID,
     &                                 "long_name",
     &                                 "time"))
              call nchek("nf90_put_att-units",
     &                    nf90_put_att(ncfileID,MTVarID,
     &                                 "units",
     &                            "days since 1900-12-31 00:00:00"))
              call nchek("nf90_put_att-calendar",
     &                    nf90_put_att(ncfileID,MTVarID,
     &                                 "calendar",
     &                                 "gregorian"))  !same as standard
            call nchek("nf90_put_att-axis",
     &                  nf90_put_att(ncfileID,MTVarID,
     &                               "axis","T"))
            call nchek("nf90_def_var-Date",
     &                  nf90_def_var(ncfileID,"Date", nf90_double,
     &                               MTDimID,datVarID))
            call nchek("nf90_put_att-long_name",
     &                  nf90_put_att(ncfileID,datVarID,
     &                               "long_name",
     &                               "date"))
            call nchek("nf90_put_att-units",
     &                  nf90_put_att(ncfileID,datVarID,
     &                               "units",
     &                               "day as %Y%m%d.%f"))
            call nchek("nf90_put_att-C_format",
     &                  nf90_put_att(ncfileID,datVarID,
     &                               "C_format",
     &                               "%13.4f"))
            call nchek("nf90_put_att-FORTRAN_format",
     &                  nf90_put_att(ncfileID,datVarID,
     &                               "FORTRAN_format",
     &                               "(f13.4)"))
          if     (laxis) then
              call nchek("nf90_def_var-Latitude",
     &                    nf90_def_var(ncfileID,"Latitude",  nf90_float,
     &                                 pLatDimID,pLatVarID))
            call nchek("nf90_put_att-standard_name",
     &                  nf90_put_att(ncfileID,pLatVarID,
     &                               "standard_name","latitude"))
            call nchek("nf90_put_att-units",
     &                  nf90_put_att(ncfileID,pLatVarID,
     &                               "units","degrees_north"))
            if     (abs((plat(1,jj)-plat(1,1))-
     &                  (plat(1, 2)-plat(1,1))*(jj-1)).lt.1.e-2) then
              call nchek("nf90_put_att-point_spacing",
     &                    nf90_put_att(ncfileID,pLatVarID,
     &                                 "point_spacing","even"))  !ferret
            endif
            call nchek("nf90_put_att-axis",
     &                  nf90_put_att(ncfileID,pLatVarID,
     &                               "axis","Y"))
              call nchek("nf90_def_var-Longitude",
     &                    nf90_def_var(ncfileID,"Longitude", nf90_float,
     &                                 pLonDimID,pLonVarID))
            call nchek("nf90_put_att-standard_name",
     &                  nf90_put_att(ncfileID,pLonVarID,
     &                               "standard_name","longitude"))
            call nchek("nf90_put_att-units",
     &                  nf90_put_att(ncfileID,pLonVarID,
     &                               "units","degrees_east"))
            if     (abs((plon(ii,1)-plon(1,1))-
     &                  (plon( 2,1)-plon(1,1))*(ii-1)).lt.1.e-2) then
              call nchek("nf90_put_att-point_spacing",
     &                    nf90_put_att(ncfileID,pLonVarID,
     &                                 "point_spacing","even"))  !ferret
            endif
            if     (abs((plon(ii,1)+(plon(2,1)-plon(1,1)))-
     &                  (plon( 1,1)+ 360.0) ).lt.1.e-2) then
              call nchek("nf90_put_att-modulo",
     &                    nf90_put_att(ncfileID,pLonVarID,
     &                                 "modulo","360 degrees"))  !ferret
            endif
            call nchek("nf90_put_att-axis",
     &                  nf90_put_att(ncfileID,pLonVarID,
     &                               "axis","X"))
            call nchek("nf90_put_att-next_MT",
     &                  nf90_put_att(ncfileID,MTVarID,
     &                               "next_MT",
     &                               time_next))
            call nchek("nf90_put_att-next_Date",
     &                  nf90_put_att(ncfileID,datVarID,
     &                               "next_Date",
     &                               date_next))
          else !.not.laxis
            call nchek("nf90_def_var-Y",
     &                  nf90_def_var(ncfileID,"Y", nf90_int,
     &                               pYDimID,pYVarID))
            call nchek("nf90_put_att-point_spacing",
     &                  nf90_put_att(ncfileID,pYVarID,
     &                               "point_spacing","even"))  !ferret
            call nchek("nf90_put_att-axis",
     &                  nf90_put_att(ncfileID,pYVarID,
     &                               "axis","Y"))
            call nchek("nf90_def_var-X",
     &                  nf90_def_var(ncfileID,"X", nf90_int,
     &                               pXDimID,pXVarID))
            call nchek("nf90_put_att-point_spacing",
     &                  nf90_put_att(ncfileID,pXVarID,
     &                               "point_spacing","even"))  !ferret
            call nchek("nf90_put_att-axis",
     &                  nf90_put_att(ncfileID,pXVarID,
     &                               "axis","X"))
            call nchek("nf90_def_var-Latitude",
     &                  nf90_def_var(ncfileID,"Latitude",  nf90_float,
     &                               (/pXDimID, pYDimID/), pLatVarID))
            call nchek("nf90_put_att-standard_name",
     &                  nf90_put_att(ncfileID,pLatVarID,
     &                               "standard_name","latitude"))
            call nchek("nf90_put_att-units",
     &                  nf90_put_att(ncfileID,pLatVarID,
     &                               "units","degrees_north"))
            call nchek("nf90_def_var-Longitude",
     &                  nf90_def_var(ncfileID,"Longitude", nf90_float,
     &                               (/pXDimID, pYDimID/), pLonVarID))
            call nchek("nf90_put_att-standard_name",
     &                  nf90_put_att(ncfileID,pLonVarID,
     &                               "standard_name","longitude"))
            call nchek("nf90_put_att-units",
     &                  nf90_put_att(ncfileID,pLonVarID,
     &                               "units","degrees_east"))
            if     (abs((plon(ii,1)+(plon(2,1)-plon(1,1)))-
     &                  (plon( 1,1)+ 360.0) ).lt.1.e-2) then
              call nchek("nf90_put_att-modulo",
     &                    nf90_put_att(ncfileID,pLonVarID,
     &                                 "modulo","360 degrees"))  !ferret
            endif
            call nchek("nf90_put_att-next_MT",
     &                  nf90_put_att(ncfileID,MTVarID,
     &                               "next_MT",
     &                               time_next))
            call nchek("nf90_put_att-next_Date",
     &                  nf90_put_att(ncfileID,datVarID,
     &                               "next_Date",
     &                               date_next))
          endif !laxis:else
          ! model 2d variable
            if     (laxis) then
              call nchek("nf90_def_var-namec",
     &                    nf90_def_var(ncfileID,trim(namec),nf90_float,
     &                               (/pLonDimID, pLatDimID, MTDimID/),
     &                                 varID))
              call nchek("nf90_put_att-coordinates",
     &                    nf90_put_att(ncfileID,varID,
     &                                 "coordinates",
     &                                 "Date"))
            else
              call nchek("nf90_def_var-namec",
     &                    nf90_def_var(ncfileID,trim(namec),nf90_float,
     &                               (/pXDimID,   pYDimID,   MTDimID/),
     &                                 varID))
              call nchek("nf90_put_att-coordinates",
     &                    nf90_put_att(ncfileID,varID,
     &                                 "coordinates",
     &                                 "Longitude Latitude Date"))
            endif
          if     (name.ne." ") then
            call nchek("nf90_put_att-long_name",
     &                  nf90_put_att(ncfileID,varID,
     &                               "long_name",trim(name)))
          endif
          if     (names.ne." ") then
            call nchek("nf90_put_att-standard_name",
     &                  nf90_put_att(ncfileID,varID,
     &                               "standard_name",trim(names)))
          endif
          call nchek("nf90_put_att-units",
     &                nf90_put_att(ncfileID,varID,"units",trim(units)))
          call nchek("nf90_put_att-_FillValue",
     &                nf90_put_att(ncfileID,varID,
     &                             "_FillValue",fill_value))
          call nchek("nf90_put_att-valid_range",
     &                nf90_put_att(ncfileID,varID,
     &                             "valid_range",
     &                             (/hmin, hmax/)))
          ! leave def mode
          call nchek("nf90_enddef",
     &                nf90_enddef(ncfileID))
          ! write data into coordinate variables
            call nchek("nf90_put_var-time",
     &                  nf90_put_var(ncfileID,MTVarID, time))
            call nchek("nf90_put_var-date",
     &                  nf90_put_var(ncfileID,datVarID,date    ))
          if     (laxis) then
            call nchek("nf90_put_var-pLatVarID",
     &                  nf90_put_var(ncfileID,pLatVarID,
     &                               (/plat(1,:)/)))     !1-d Latitudes
            call nchek("nf90_put_var-pLonVarID",
     &                  nf90_put_var(ncfileID,pLonVarID,
     &                               (/plon(:,1)/)))     !1-d Longtudes
          else
            call nchek("nf90_put_var-pYVarID",
     &                  nf90_put_var(ncfileID,pYVarID,
     &                               (/(j, j=1,jj)/)))
            call nchek("nf90_put_var-pXVarID",
     &                  nf90_put_var(ncfileID,pXVarID,
     &                               (/(i, i=1,ii)/)))
            call nchek("nf90_put_var-plat",
     &                  nf90_put_var(ncfileID,pLatVarID,plat(:,:)))
            call nchek("nf90_put_var-plon",
     &                  nf90_put_var(ncfileID,pLonVarID,plon(:,:)))
          endif
          ! write to model variable
          call nchek("nf90_put_var-array",
     &                nf90_put_var(ncfileID,varID,array(:,:)))
          ! close NetCDF file
          call nchek("nf90_close",
     &                nf90_close(ncfileID))
        endif !lexist
        return  !from first call
      endif  !initialization
c
c     Append data to the NetCDF file
c
      mt_rec = mt_rec + 1
c
      time = wday
c     correct wind day to nearest 15 minutes
      time = nint(time*96.d0)/96.d0
      call fordate(time,3, iyear,month,iday,ihour)
      date = (iday + 100 * month + 10000 * iyear) + 
     &       (time - int(time))
c
      time_next = wday_next
      time_next = nint(time_next*96.d0)/96.d0
      call fordate(time_next,3, iyear,month,iday,ihour)
      date_next = (iday + 100 * month + 10000 * iyear) + 
     &            (time_next - int(time_next))
c
      write(6,6300) mt_rec,time,date
      call zhflsh(6)
c
      ! open NetCDF file
      call nchek("nf90_open",
     &            nf90_open(trim(ncfile),nf90_write, ncfileID))
      !append values
      call nchek("nf90_put_var-time",
     &            nf90_put_var(ncfileID,MTVarID, time,
     &                         start=(/mt_rec/)))
      call nchek("nf90_put_var-date",
     &            nf90_put_var(ncfileID,datVarID,date,
     &                         start=(/mt_rec/)))
      call nchek("nf90_put_att-next_MT",
     &            nf90_put_att(ncfileID,MTVarID,
     &                         "next_MT",
     &                         time_next))
      call nchek("nf90_put_att-next_Date",
     &            nf90_put_att(ncfileID,datVarID,
     &                         "next_Date",
     &                         date_next))
      call nchek("nf90_put_var-array",
     &            nf90_put_var(ncfileID,varID,array(:,:),
     &                         start=(/1,1,mt_rec/)))
      !update valid_range
      call ncrange(array,ii,jj,1, fill_value, hmin,hmax)
      call nchek("nf90_get_att-valid_range",
     &            nf90_get_att(ncfileID,varID,
     &                         "valid_range",
     &                         hrange(1:2)))
      hrange(1) = min( hrange(1), hmin )
      hrange(2) = max( hrange(2), hmax )
      call nchek("nf90_put_att-valid_range",
     &            nf90_put_att(ncfileID,varID,
     &                         "valid_range",
     &                         hrange(1:2)))
      ! close file 
      call nchek("nf90_close",
     &            nf90_close(ncfileID))
      return
 6300 FORMAT(10X,'WRITING RECORD',I6,
     +           '     FDAY =',F12.5,
     +            '   FDATE =',F14.5 )
      end

      subroutine nchek(cnf90,status)
      use netcdf   ! NetCDF fortran 90 interface
      implicit none
c
      character*(*), intent(in) :: cnf90
      integer,       intent(in) :: status
c
c     subroutine to handle NetCDF errors
c
      if     (.FALSE.) then !nodebug
*     if     (.TRUE. ) then !debug
        write(6,'(a)') trim(cnf90)
        call zhflsh(6)
      endif

      if (status /= nf90_noerr) then
        write(6,'(/a)')   'error in profout - from NetCDF library'
        write(6,'(a/)')   trim(cnf90)
        write(6,'(a/)')   trim(nf90_strerror(status))
        call zhflsh(6)
        stop
      end if
      end subroutine nchek

      subroutine ncrange(h,ii,jj,kk, fill_value, hmin,hmax)
      implicit none
c
      integer, intent(in ) :: ii,jj,kk
      real,    intent(in ) :: h(ii,jj,kk),fill_value
      real,    intent(out) :: hmin,hmax
c
c     return range of array, ignoring fill_value
c
      integer i,j,k
      real    hhmin,hhmax
c
      hhmin =  abs(fill_value)
      hhmax = -abs(fill_value)
      do k= 1,kk
        do j= 1,jj
          do i= 1,ii
            if     (h(i,j,k).ne.fill_value) then
              hhmin = min(hhmin,h(i,j,k))
              hhmax = max(hhmax,h(i,j,k))
            endif
          enddo
        enddo
      enddo
      hmin = hhmin
      hmax = hhmax
      end subroutine ncrange
