!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      module ccsm3_time_management

!-----------------------------------------------------------------------
!
!     time-related variables used in ccsm3 coupling
!
!-----------------------------------------------------------------------
      use ccsm3                    ! ccsm3 ocean
      use ccsm3_io                 ! ccsm3 ocean io
      use ccsm3_exit               ! ccsm3 exit module
      use ccsm3_global_reductions  ! ccsm3 ocean mpi communications

      character (len=80) ::
     &  runid               ! an identifier for the run
     &, dt_option           ! method to determine tracer timestep size
     &, runtype
     &, restart_opt
     &, histfq_opt
     &, diagfq_opt
     &, dumpfq_opt

      integer ::
     &  nsteps_run          ! timesteps taken since beginning of this run
     &, nsteps_total        ! timesteps taken since beginning of the very first run
     &, len_runid           ! length of character runid
     &, stop_now

      real ::
     &  restartfq
     &, dumpfq
     &, histfq

      logical ::            ! this timestep is:
     &  eod                 !   at the end of the day
     &, eom                 !   at the end of the month
     &, eoy                 !   at the end of the year
     &, first_step          !   first time step
     &, ice_ts              !   an ice-formation timestep
     &, cpl_ts              !   time to couple with cpl6

 
      real ::
     &  stepsize            ! timestep size, in ***days***
     &, steps_per_year      ! number of timesteps in one year
     &, steps_per_day       ! number of timesteps in one day

!-----------------------------------------------------------------------
!
!     quantities related to date
!
!-----------------------------------------------------------------------

      integer ::
     &  iyear               ! year    [0,inf)  for present timestep
     &, imonth              ! month   [1,12]          |
     &, iday                ! day     [1,31]          |
     &, ihour               ! hour    [0,23]          |
     &, iminute             ! minute  [0,59]          |
     &, isecond             ! second  [0,59]          |
     &, iday_of_year        ! day no. [1,365/6]       V


      integer ::
     &  iyear_last          ! year    [0,inf)   from previous timestep
     &, imonth_last         ! month   [1,12]          |
     &, iday_last           ! day     [1,31]          |
     &, ihour_last          ! hour    [0,23]          |
     &, iday_of_year_last   ! day no. [1,365/6]       V

      integer ::
     &  iyear0              ! initial start date and time
     &, imonth0             !   for complete run
     &, iday0               !
     &, ihour0              !
     &, iminute0            !
     &, isecond0            !
 

      integer ::
     &  iyear_start_run          ! initial start date and time
     &, imonth_start_run         !   for this run              
     &, iday_start_run           !
     &, ihour_start_run          !
     &, iminute_start_run        !
     &, isecond_start_run        !
     &, iday_of_year_start_run   !

      integer :: ! number of:
     &  days_in_year             ! days in present year
     &, days_in_prior_year       ! days in prior   year 
     &, elapsed_days             ! full days elapsed since   01-01-0000
     &, elapsed_days0            ! full days elapsed between 01-01-0000 and day0 
     &, elapsed_days_this_year   ! full days elapsed since beginning of yr
     &, elapsed_days_this_run    ! full days elapsed since beginning of
                                 !                   this segment of run
     &, elapsed_days_init_date   ! full days elapsed since initial time
     &, elapsed_days_max         ! maximum number of full days allowed 
     &, elapsed_months           ! full months elapsed since 01-01-0000
     &, elapsed_months_this_run  ! full months elapsed since beginning of
                                 !                     this segment of run
     &, elapsed_months_init_date ! full months elapsed since initial time
     &, elapsed_years            ! full years  elapsed since 01-01-0000
     &, elapsed_years_this_run   ! full years  elapsed since beginning of
                                 !                     this segment of run
     &, elapsed_years_init_date  ! full years  elapsed since initial time
 
      integer, dimension(12) ::
     &  days_in_prior_months     ! cumulative num days in preceeding months
                                 ! computed in ccsm3_time_init
     &, days_in_month =          ! number of days in each calendar month
     &    (/31,28,31,  30,31,30,  31,31,30,   31,30,31/)
        !   J  F  M    A  M  J    J  A  S     O  N  D

      integer, dimension(12) ::
     &  day_mid_month =          ! day number at the middle of each month
     &    (/16,14,16,  15,16,15,  16,16,15,   16,15,16/)
        !   J  F  M    A  M  J    J  A  S     O  N  D


      real ::
     &  seconds_this_year       ! seconds elapsed since beginning of year
     &, seconds_this_day        ! seconds elapsed this day    
     &, seconds_in_year         ! seconds in one year -- note, no leap year here
     &, hours_in_year           ! hours   in one year
     &, frac_day                ! fraction of the day elapsed today

      integer ::
     &  cdate               !coded date yyyymmdd

      character (4) ::
     &  cyear               ! character version of year

      character (2) ::
     &  cday                ! character version of day
     &, chour               ! character version of hour
     &, cminute             ! character version of minute
     &, csecond             ! character version of second

      character (3), dimension(12) ::
     &  cmonth3 = (/'jan','feb','mar','apr','may','jun','jul',
     &                 'aug','sep','oct','nov','dec'/)

 
      integer, parameter ::
     &  days_in_norm_year = 365 !   days in a non-leap year

      real, parameter ::
     &  seconds_in_minute =    60.0d0
     &, seconds_in_hour   =  3600.0d0
     &, seconds_in_day    = 86400.0d0
     &, minutes_in_hour   =    60.0d0

!-----------------------------------------------------------------------
!
!     parameters for time frequency and start options
!
!-----------------------------------------------------------------------

      integer, parameter ::
     &  freq_opt_never    = 0
     &, freq_opt_nyear    = 1
     &, freq_opt_nmonth   = 2
     &, freq_opt_nday     = 3
     &, freq_opt_nhour    = 4
     &, freq_opt_nsecond  = 5
     &, freq_opt_nstep    = 6

      integer, parameter ::
     &  start_opt_nstep   = 1
     &, start_opt_nday    = 2
     &, start_opt_nyear   = 3
     &, start_opt_date    = 4

      integer, parameter ::
     &  next_opt_day      = 1 
     &, next_opt_month    = 2 
     &, next_opt_year     = 3 
     &, stop_opt_never    = 0 
     &, stop_opt_sometime = 1 

!JY      logical,private :: linit
      logical,save :: linit

      integer,private :: dsm(12)   ! elapsed Days on Start of Month
      integer,private :: dpm(12)   ! Days Per Month
      data     dsm  / 0,31,59, 90,120,151, 181,212,243, 273,304,334/
      data     dpm  /31,28,31, 30, 31, 30,  31, 31, 30,  31, 30, 31/


      save
      implicit none
      contains

      subroutine ccsm3_time_init (time0, time, dtime0, dtime)
!     ==========================

!-----------------------------------------------------------------------
!
!     local variables
!
!-----------------------------------------------------------------------

      real*8  :: dtime, dtime0
      real    ::  time,  time0
      integer :: nml_error
      integer :: nm

      namelist /time_manager_nml/
     &          runtype,runid 
     &,         iyear0,imonth0,iday0 
     &,         restart_opt, restartfq 
     &,         histfq_opt,  histfq 
     &,         diagfq_opt,  diagfq 
     &,         dumpfq_opt,  dumpfq 
     &,         trcrin, trcout
 
!--------------------------------------------------------------
!     set defaults
!--------------------------------------------------------------
      iyear0         = 0
      imonth0        = 1
      iday0          = 1
      ihour0         = 0
      iminute0       = 0
      isecond0       = 0

!--------------------------------------------------------------
!     set counter for steps in this run
!--------------------------------------------------------------
      nsteps_run = 0

!--------------------------------------------------------------
!     obtain time-related variables from namelist input
!--------------------------------------------------------------
      if (my_task == master_task) then
        nml_error = -1
        open (nml_in, file=nml_filename, status='old')

   10   continue  !*** keep reading until find right namelist
        read(nml_in, nml=time_manager_nml,err=10,end=20)
        close(nml_in)
        nml_error = 0
   20   continue
      endif

      call broadcast_scalar(nml_error, master_task)
      if (nml_error /= 0) then
 	call ccsm3_exit_HYCOM('ERROR: reading time_manager_nml')
      endif

      call broadcast_scalar(runtype,     master_task)
      call broadcast_scalar(runid,       master_task)
      call broadcast_scalar(iyear0,      master_task)
      call broadcast_scalar(imonth0,     master_task)
      call broadcast_scalar(iday0,       master_task)
      call broadcast_scalar(restart_opt, master_task)
      call broadcast_scalar(restartfq,   master_task)
      call broadcast_scalar(histfq_opt,  master_task)
      call broadcast_scalar(histfq,      master_task)
      call broadcast_scalar(diagfq_opt,  master_task)
      call broadcast_scalar(diagfq,      master_task)
      call broadcast_scalar(dumpfq_opt,  master_task)
      call broadcast_scalar(dumpfq,      master_task)
      call broadcast_scalar(trcrin,      master_task)
      call broadcast_scalar(trcout,      master_task)

      if (my_task == master_task) then
          write(stdout,*) ' '
          write(stdout,*) ' Document Namelist Parameters:'
          write(stdout,*) ' ============================ '
          write(stdout,*) ' '
          write(stdout, time_manager_nml)
          write(stdout,*) ' '
          call flush (stdout)
      endif

      if (my_task == master_task) then
        write(stdout,'(2a)')'(ccsm3_time_init) namelist read: ',nml_filename
        write(stdout,*)'   runtype: ',runtype
        write(stdout,*)'   runid  : ',runid
        write(stdout,*)'   iyear0 : ',iyear0
        write(stdout,*)'   imonth0: ',imonth0
        write(stdout,*)'   iday0  : ',iday0
        write(stdout,*)'   restart_opt: ',restart_opt
        write(stdout,*)'   restartfq  : ',restartfq
        write(stdout,*)'   histfq_opt : ',histfq_opt
        write(stdout,*)'   histfq     : ',histfq
        write(stdout,*)'   diagfq_opt : ',diagfq_opt
        write(stdout,*)'   diagfq     : ',diagfq
        write(stdout,*)'   dumpfq_opt : ',dumpfq_opt
        write(stdout,*)'   dumpfq     : ',dumpfq
        write(stdout,*)'   trcrin     : ',trcrin
        write(stdout,*)'   trcout     : ',trcout
        call flush(stdout)
      endif

      days_in_year = days_in_norm_year

      if (trim(runtype) == 'startup') then
        linit = .true.
      else
        linit = .false.
      endif

      nsteps_per_day = seconds_in_day/baclin
      nsteps_today   = 0
 
      stepsize  = baclin/seconds_in_day   ! stepsize in days
 
      elapsed_days0 = iyear0*days_in_year + 
     &                days_in_prior_months(imonth0)
     &               + iday0 - 1
      elapsed_days  = elapsed_days0
      nstep1 = elapsed_days0*nsteps_per_day
      nstep  = elapsed_days0*nsteps_per_day
 
      time0  = elapsed_days0
      time   = time0
      dtime0 = elapsed_days0 - 1.0d0
      dtime  = dtime0


!-----------------------------------------------------------------
!     compute cdate, iyear, imonth, and iday from elapsed_days
!-----------------------------------------------------------------
      call eday2date (elapsed_days,cdate)
      call eday2ymd  (elapsed_days,iyear,imonth,iday)
      isecond = 0          
Cpg
      ihour = 0
Cpg

      eoy = .false.
      eom = .false.
      stop_now = 0 

      cpl_ts = (mod(nstep,nsteps_per_day) .eq. 0)

!--------------------------------------------------------------
!     compute the number of days in prior months
!--------------------------------------------------------------
      days_in_prior_months(1) = 0

      do nm=2,12
        days_in_prior_months(nm) =
     &  days_in_prior_months(nm-1) + days_in_month(nm-1)
      enddo

!-----------------------------------------------------------------------
!     report initial time in format recognized by ccsm3
!-----------------------------------------------------------------------
      if (my_task == master_task .and. linit) then
Cpg          write(stdout,1000) iyear, cmonth3(imonth), iday, isecond
          write(stdout,1000) iyear,cmonth3(imonth),iday,ihour,isecond
          write(stdout,*) ' dtime0 dtime', dtime0, dtime
          write(stdout,*) '  time0  time',  time0,  time
          call flush(stdout)
      endif

1000  format ('(ccsm3_time_init)', ' ocn date ', i4.4, '-', a3, '-',
     &        i2.2,'-', i2.2,', ', i7, ' sec') 

      end subroutine ccsm3_time_init


      subroutine ccsm3_time_init1 
!     ===========================

!-----------------------------------------------------------------
!     Now that restart header file has been read in, 
!     compute cdate, iyear, imonth, and iday from elapsed_days
!-----------------------------------------------------------------
      call eday2date (elapsed_days,cdate)
      call eday2ymd  (elapsed_days,iyear,imonth,iday)
Cpg
      ihour = isecond/3600
Cpg

!-----------------------------------------------------------------------
!     report restart time in format recognized by ccsm3
!-----------------------------------------------------------------------
      if (my_task == master_task) then
Cpg          write(stdout,1000) iyear, cmonth3(imonth), iday, isecond
          write(stdout,1000) iyear,cmonth3(imonth),iday,ihour,isecond
          call flush(stdout)
      endif

1000  format('(ccsm3_time_init1)',' restart at ocn date ',i4.4,'-',a3,'-',
     &        i2.2,'-',i2.2,', ',i7,' sec') 

      end subroutine ccsm3_time_init1


      subroutine ccsm3_time_advance (time,dtime)
!     =============================

!-----------------------------------------------------------------------
!
!     this subroutine manages the time-keeping needed to communicate 
!     with ccsm3
!         1) increment nstep, time, dtime
!         2) calculate iyear, imonth, iday, isecond, and integer-coded
!             date (cdate)
!         3) set logical switches which control coupling and diagnostics
!
!-----------------------------------------------------------------------


!-----------------------------------------------------------------------
!     declarations
!-----------------------------------------------------------------------
      integer :: nm    
      real    ::  time
      real*8  :: dtime


!-----------------------------------------------------------------------
!     set logical switches off
!-----------------------------------------------------------------------
      eod = .false.
      eom = .false.
      eoy = .false.

      dodump       = .false.      
      chk_ovtn     = .false.   
      dosstbud     = .false.  
       
      doovtn       = .false.
      ice_ts       = .false.
      diagno       = .false.
      dohist       = .false.
      dorestart    = .false.

!-----------------------------------------------------------------------
!     save previous values of iyear, imonth, iday
!-----------------------------------------------------------------------
      iyear_last   = iyear
      imonth_last  = imonth
      iday_last    = iday

!-----------------------------------------------------------------------
!     increment timestepping variables
!-----------------------------------------------------------------------
      nstep        = nstep        + 1
      nsteps_run   = nsteps_run   + 1

      if (nsteps_today+1 == nsteps_per_day) then
          nsteps_today = 0
          elapsed_days = elapsed_days + 1
      else
          nsteps_today = nsteps_today + 1
      endif

Cpg
      if (my_task == master_task) then
          write(stdout,*) ' '
          write(stdout,*) ' nstep,nsteps_today,nsteps_per_day,elapsed_days,0 '
          write(stdout,'(5i8)') nstep,nsteps_today,nsteps_per_day,
     &         elapsed_days,elapsed_days0
          write(stdout,*) ' '
      endif
Cpg
!--------------------------------------------------------------------
!     determine iday, imonth, iyear, and cdate
!--------------------------------------------------------------------
      call eday2ymd (elapsed_days,iyear,imonth,iday)
      call eday2date(elapsed_days,cdate)
    
!--------------------------------------------------------------------
!     determine isecond
!--------------------------------------------------------------------
      frac_day         = nsteps_today*stepsize
      seconds_this_day = frac_day*seconds_in_day 
      isecond          = nint(seconds_this_day)
Cpg
      ihour = isecond/3600
Cpg

!--------------------------------------------------------------------
!     set dtime and time, in days 
!--------------------------------------------------------------------
      dtime = elapsed_days + frac_day
      time  = elapsed_days + frac_day

!--------------------------------------------------------------------
!     is this the end of the day? end of the month? end of the year?
!--------------------------------------------------------------------
      if (iday .ne. iday_last .and. isecond == 0) eod = .true.
      if (eod .and. imonth .ne. imonth_last)      eom = .true.
      if (eom .and. iyear  .ne. iyear_last )      eoy = .true.

!--------------------------------------------------------------------
!     set logical controls, based upon eod, eom, eoy
!--------------------------------------------------------------------
      select case (trim(restart_opt))
        case ('day')
          if (eod) then
             dorestart = .true.
          endif
        case ('month')
!JY
          if (eom .and. mod(imonth-1, int(restartfq)) .eq. 0) then
             dorestart = .true.
          endif
        case ('year')
          if (eoy) then
             dorestart = .true.
          endif
        case default
          if (eoy) then
             dorestart = .true.
          endif
      end select 

      select case (trim(histfq_opt))
        case ('day')
          if (eod) then
             dohist    = .true.
          endif
        case ('month')
          if (eom) then
             dohist    = .true.
          endif
        case ('year')
          if (eoy) then
             dohist    = .true.
          endif
        case default
          if (eoy) then
             dohist    = .true.
          endif
      end select 

!-------------------------------------------------------------------------
!     set logical flag which control coupling
!-------------------------------------------------------------------------
      cpl_ts = eod

!-------------------------------------------------------------------------
!     Note from Dave Bi:
!     Temperature adjustment should be done for two consective time steps
!     because of the 2-timelevel frog leap stepping before coupling! so:
!-------------------------------------------------------------------------
     
      if(mod(nstep,nsteps_per_day)==0 .or.
     &   mod(nstep+1,nsteps_per_day)==0) then
        ice_ts = .true.       !do adjustment at end-of-day
      endif
    
!-------------------------------------------------------------------------
!     Note from Dave Bi:
!     sth should be done here for "diagfq" . here we set the frequency as every
!     (end of) month and the "diagno" control is not in operation in most cases
!-------------------------------------------------------------------------
      if (eom .and. mod(imonth-1,int(diagfq)) == 0) then
        diagno=.true.
        if (my_task == master_task) then
          write(stdout,*)'(ccsm3_time_advance) diagno = ', diagno
          call flush(stdout)
        endif
      endif

      if (iday == day_mid_month(imonth) .and. isecond == 0 .or.
     &    eom) then
        doovtn=.true.
      endif

      if (my_task == master_task .and. doovtn) then
        write(stdout,*)'(ccsm3_time_advance) doovtn = ', doovtn
        call flush(stdout)
      endif

!-----------------------------------------------------------------
!  report time in format required by ccsm3
!-----------------------------------------------------------------
      if (my_task == master_task) then
Cpg          write(stdout,1000) iyear, cmonth3(imonth), iday, isecond
          write(stdout,1000) iyear,cmonth3(imonth),iday,ihour,isecond
          call flush(stdout)
      endif

1000  format (1x,'(ccsm3_time_advance)', ' ocn date ', i4.4, '-', a3, '-',
     &        i2.2,'-', i2.2,', ', i7, ' sec') 

      end subroutine ccsm3_time_advance



      subroutine ccsm3_time_date_stamp (date_string, ymds)

!-----------------------------------------------------------------------
!
!     write a character string containing the date stamp
!        yyyy-mm-dd, yyyy-mm, or yyyy
!
!-----------------------------------------------------------------------

      character (*) :: 
     &  date_string            ! a string to fill with date stamp
     &, ymds                   ! a string indicating date stamp format
 
      character (4) :: ccsm_cyear
      character (2) :: ccsm_cmonth
      character (2) :: ccsm_cday  
      character (5) :: ccsm_csecond
 
      integer ::
     &  iyear_stamp
     &, imonth_stamp
     &, iday_stamp   
     &, itotal_second
 
      date_string = ' '

!---------------------------------------------------------------------
!     set ixxxx_stamp variables to conform to the ccsm standard
!---------------------------------------------------------------------
      if (eoy) then
        iyear_stamp  = iyear_last
        imonth_stamp = 12
        iday_stamp   = 31
      elseif (eom) then
        iyear_stamp  = iyear
        imonth_stamp = imonth_last
        iday_stamp   = iday_last
      elseif (eod) then 
        iyear_stamp  = iyear
        imonth_stamp = imonth
        iday_stamp   = iday_last
      else
        iyear_stamp  = iyear
        imonth_stamp = imonth
        iday_stamp   = iday_last
      endif
 
      select case (trim(ymds))
        case ('ymds')
!---------------------------------------------------------------------
!       use unmodified ixxx variables if printing ymds information
!---------------------------------------------------------------------
        itotal_second = isecond + 60*iminute + 3600*ihour
        call int_to_char (4,iyear        , ccsm_cyear  )
        call int_to_char (2,imonth       , ccsm_cmonth )
        call int_to_char (2,iday         , ccsm_cday   )
        call int_to_char (5,itotal_second, ccsm_csecond)
        write (date_string,1000) ccsm_cyear, ccsm_cmonth, ccsm_cday
     &,                          ccsm_csecond

        case ('ymd')
        call int_to_char (4,iyear_stamp  , ccsm_cyear )
        call int_to_char (2,imonth_stamp , ccsm_cmonth)
        call int_to_char (2,iday_stamp   , ccsm_cday  )
        write (date_string,1000) ccsm_cyear, ccsm_cmonth, ccsm_cday

        case ('ym')
        call int_to_char (4,iyear_stamp  , ccsm_cyear )
        call int_to_char (2,imonth_stamp , ccsm_cmonth)
        write (date_string,1000) ccsm_cyear, ccsm_cmonth

        case ('y')
        call int_to_char (4,iyear_stamp  , ccsm_cyear)
        write (date_string,1000) ccsm_cyear
        
        case default 
        call ccsm3_exit_HYCOM('(ccsm_date_stamp)',normal_exit=.false.)
 
      end select
 

 1000 format (a4,:,'-',a2:,'-',a2,:,'-',a5)
 

      end subroutine ccsm3_time_date_stamp

      subroutine int_to_char (string_length,int_in,char_out)

!-----------------------------------------------------------------------
!
!     converts an integer into an n-digit character and pads the
!     spaces with zeroes
!
!-----------------------------------------------------------------------

      integer, intent(in) :: 
     &  int_in                       ! input integer to convert
     &, string_length                ! length of output character

      character(*), intent(out) :: 
     &  char_out                     ! output character string containg int

      integer                 :: n   ! dummy counter
      character (len=8)       :: fmt ! variable format
 
!-----------------------------------------------------------------------

      if (string_length >= 1 .and. string_length <= 9) then
        write(fmt,1100) string_length
      else if (string_length >= 10 .and. string_length <= 99) then
        write(fmt,1200) string_length
      else
        call ccsm3_exit_HYCOM('string_length too long in sub. int_to_char'
     &,                normal_exit=.false.)
      endif
 
1100  format ('(i',i1,')')
1200  format ('(i',i2,')')
 
      write(char_out,fmt) int_in

      do n=1,string_length
        if (char_out(n:n) == ' ') char_out(n:n) = '0'
      end do

!-----------------------------------------------------------------------

      end subroutine int_to_char


!===============================================================================
! The following routines were taken by Dave Bi from old ccsm2 code and
! used in the time-management of coupled hycom.      
! NJN01 moved the routines from what Dave called calendar_mod.F to 
! the ccsm3_time_management module on 1/3/2005
! Here's the CVS info from the version of the routines that Dave used:
! CVS $Id: calendar_mod.F90,v 1.1 2000/01/03 22:56:15 kauff Exp $
! CVS $Source: /fs/cgd/csm/models/CVS.REPOS/cpl/cpl5/calendar_mod.F90,v $
! CVS $Name: ccsm2_0_beta26 $
!===============================================================================


   !============================================================================
   ! Purpose:
   !   these calendar routines do conversions between...
   !   o the integer number of elapsed days 
   !   o the integer triple (year,month,day)
   !   o the integer coded calendar date (yyyymmdd)
   !
   ! Assumptions:
   !   o there is a year 0
   !   o all years have 365 days (no leap years)
   !   o elapsed days = 0 <=> start of  1 Jan, year 0
   !
   !============================================================================



!===============================================================================

 	SUBROUTINE eday2date(eday,date)

  	implicit none

   	integer :: eday,date

   	integer :: k,year,month,day

   !----------------------------------------------------------------------------
   ! PURPOSE:
   !   compute the calendar date: year/month/day
   ! INPUT:
   !   an integer :: number of elapsed days
   ! OUTPUT:
   !   coded (yyyymmdd) calendar date
   ! NOTE:
   !   this calendar has a year zero (but no day or month zero)
   !----------------------------------------------------------------------------

   	year = eday/365       ! calandar year (note: Fortran truncation)
   	day  = mod(eday,365)  ! elapsed days within current year
   	DO k=1,12
     	  IF (day .ge. dsm(k)) month=k   ! calendar month
   	END DO
   	day = day-dsm(month) + 1         ! calendar day
  
   	date = year*10000 + month*100 + day  ! coded calendar date

	END SUBROUTINE eday2date

!===============================================================================

	SUBROUTINE eday2ymd (eday,year,month,day)

   	implicit none

   	integer :: eday,year,month,day

   	integer :: k

   !----------------------------------------------------------------------------
   ! PURPOSE:
   !   compute the calendar date: year/month/day
   ! INPUT:
   !   an integer :: number of elapsed days
   ! OUTPUT:
   !   uncoded calendar date, integer :: year, month, & day
   ! NOTE:
   !   this calendar has a year zero (but no day or month zero)
   !----------------------------------------------------------------------------

   	year = eday/365       ! calandar year (note: Fortran truncation)
   	day  = mod(eday,365)  ! elapsed days within current year
   	DO k=1,12
     	  IF (day .ge. dsm(k)) month=k   ! calendar month
   	END DO
   	day = day-dsm(month) + 1         ! calendar day

	END SUBROUTINE eday2ymd 

!===============================================================================


      end module ccsm3_time_management
      
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
