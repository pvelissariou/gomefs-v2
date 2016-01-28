!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

      module ccsm3_io

!-----------------------------------------------------------------------
!
!     This module is based upon the pop module, io_mod.F
!
!-----------------------------------------------------------------------
      use ccsm3                   ! ccsm3 ocean
      use ccsm3_exit              ! ccsm3 ocean exit
      use ccsm3_global_reductions ! ccsm3 ocean mpi communications


      implicit none
      save

!-----------------------------------------------------------------------
!
!     module variables
!
!-----------------------------------------------------------------------

      integer, parameter ::
     &   max_units = 99        ! maximum number of open units
     &,  stdin     =  5        ! reserved unit for standard input
     &,  stdout    =  6        ! reserved unit for standard output
     &,  stderr    =  6        ! reserved unit for standard error
     &,  nml_in    = 10        ! reserved unit for namelist input
     &,  recl_int  =  4        ! record length factor for integers
     &,  recl_real =  4        ! record length factor for reals
     &,  recl_dbl  =  8        ! record length factor for doubles

      logical, dimension(max_units) ::
     &   in_use                ! flag=.true. if unit currently open

      logical ::
     &   lredirect_stdout      ! redirect stdout to log file
     &,  luse_pointer_files    ! use pointer files to determine
                               !   name/location of restart files
      character (80) ::
     &   log_filename          ! root name for log file
     &,  pointer_filename      ! root name of pointer files
     &,  char_blank


      character (8), parameter :: 
     &   nml_filename = 'hycom_in'  ! input namelist filename

      character*80  
     &             flnmdepd 
     &,            flnmgrdd 
     &,            flnminitd 
     &,            flnmlatlond 
     &,            flnmrlxd 
     &,            flnmrsid 
     &,            flnmrsod 
     &,            flnmarcd 
     &,            flnmovrd 
     &,            flnmsumd 
     &,            flnmflxd 
     &,            flnmpard   !path for parameter input
     &,            flnmptchd  !path for patch.input

!***********************************************************************

      contains

!***********************************************************************

      subroutine ccsm3_io_init

!-----------------------------------------------------------------------
!
!     this routine initializes some i/o arrays and checks the validity
!     of the i/o processor number
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
!     local variables
!
!-----------------------------------------------------------------------

      integer :: 
     &  nml_error             ! namelist i/o error flag
     &, cindx,cindx2          ! indices into character strings

      character (80) ::
     &  char_tmp              ! temp character string for filenames

      namelist /io_nml/ 
     &        	lredirect_stdout
     &, 	log_filename	!standard output *redirected* filename
     &, 	luse_pointer_files
     &, 	pointer_filename
     +,         flnmdepd
     +,         flnmlatlond 
     +,         flnmgrdd
     +,         flnminitd
     +,         flnmrlxd
     +,		flnmrsid
     +,		flnmrsod
     +,		flnmarcd
     +,		flnmovrd
     +,		flnmsumd
     +,         flnmflxd
     +,         flnmpard
     +,         flnmptchd 
 
!-----------------------------------------------------------------------

      in_use = .false.            ! no unit in use

      in_use(stdin)  = .true.    ! reserved units
      in_use(stdout) = .true.
      in_use(stderr) = .true.
      in_use(nml_in)  = .true.


      lredirect_stdout   = .false.
      log_filename       = 'hyc.out'
      luse_pointer_files = .false.
      pointer_filename = 'hycom_pointer'

      if (my_task == master_task) then
        nml_error = -1
        write(stdout,'(2a)')'(ccsm3_io_init)open namelist file: ',  
     &                nml_filename
        call flush(stdout)
        open (nml_in, file=nml_filename) !, status='old')
   10   continue  !*** keep reading until find right namelist
        read(nml_in, nml=io_nml,err=10,end=20)
        close(nml_in)
        nml_error = 0
   20   continue
      
       endif

       call broadcast_scalar (nml_error, master_task)
       if (nml_error /= 0) then
         call ccsm3_exit_HYCOM ('ERROR reading io_nml')
       endif

       call broadcast_scalar (lredirect_stdout,   master_task)
       call broadcast_scalar (log_filename,       master_task)
       call broadcast_scalar (luse_pointer_files, master_task)
       call broadcast_scalar (pointer_filename,   master_task)
       call broadcast_scalar (flnmdepd,           master_task)
       call broadcast_scalar (flnmlatlond,        master_task)
       call broadcast_scalar (flnmgrdd,           master_task)
       call broadcast_scalar (flnminitd,          master_task)
       call broadcast_scalar (flnmrlxd,           master_task)
       call broadcast_scalar (flnmrsid,           master_task)
       call broadcast_scalar (flnmrsod,           master_task)
       call broadcast_scalar (flnmarcd,           master_task)
       call broadcast_scalar (flnmovrd,           master_task)
       call broadcast_scalar (flnmsumd,           master_task)
       call broadcast_scalar (flnmflxd,           master_task)
       call broadcast_scalar (flnmpard,           master_task)
       call broadcast_scalar (flnmptchd,          master_task)


!-----------------------------------------------------------------------
!
!     redirect stdout to a log file if requested
!
!-----------------------------------------------------------------------

      if (lredirect_stdout .and. my_task == master_task) then
        open(stdout, file=log_filename, position='append')
      endif

      if (my_task == master_task) then
        write(stdout,*) ' '
        write(stdout,*) ' Document Namelist Parameters:'
        write(stdout,*) ' ============================ '
        write(stdout,*) ' '
        write(stdout, io_nml)
        write(stdout,*) ' '
        call flush(stdout)

        write(stdout,*)' (ccsm3_io_init) namelist read in:'
        write(stdout,*)' lredirect_stdout  =',lredirect_stdout
        write(stdout,*)' log_filename      =',log_filename
        write(stdout,*)' luse_pointer_files=',luse_pointer_files
        write(stdout,*)' pointer_filename  =',trim(pointer_filename)
        write(stdout,*)' flnmdepd          =',trim(flnmdepd)
        write(stdout,*)' flnmlatlond       =',trim(flnmlatlond)
        write(stdout,*)' flnmgrdd          =',trim(flnmgrdd)
        write(stdout,*)' flnminitd         =',trim(flnminitd)
        write(stdout,*)' flnmrlxd          =',trim(flnmrlxd)
        write(stdout,*)' flnmrsid          =',trim(flnmrsid)
        write(stdout,*)' flnmrsod          =',trim(flnmrsod)
        write(stdout,*)' flnmarcd          =',trim(flnmarcd)
        write(stdout,*)' flnmovrd          =',trim(flnmovrd)
        write(stdout,*)' flnmsumd          =',trim(flnmsumd)
        write(stdout,*)' flnmflxd          =',trim(flnmflxd)
        write(stdout,*)' flnmpard          =',trim(flnmpard)
        call flush(stdout)
      endif

!-----------------------------------------------------------------------

      end subroutine ccsm3_io_init

!***********************************************************************

      subroutine ccsm3_io_get_unit(iunit)

!-----------------------------------------------------------------------
!
!     this routine returns the next available i/o unit
!     note that _all_ processors must call ccsm3_io_get_unit 
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
!     output variable
!
!-----------------------------------------------------------------------

      integer, intent(out) ::
     &   iunit                 ! next free i/o unit

!-----------------------------------------------------------------------
!
!     find next free unit
!
!-----------------------------------------------------------------------

      srch_units: do iunit=1,max_units
        if (.not. in_use(iunit)) exit srch_units
      end do srch_units

      in_use(iunit) = .true.    ! mark iunit as being in use

!-----------------------------------------------------------------------

      end subroutine ccsm3_io_get_unit

!***********************************************************************

      subroutine ccsm3_io_release_unit(iunit)

!-----------------------------------------------------------------------
!
!     this routine releases an i/o unit (marks it as available).
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
!     input variable
!
!-----------------------------------------------------------------------

      integer, intent(in) ::
     &   iunit                 ! i/o unit to be released

!-----------------------------------------------------------------------

      in_use(iunit) = .false.

!-----------------------------------------------------------------------

      end subroutine ccsm3_io_release_unit

!***********************************************************************

      subroutine ccsm3_io_open_parallel_file(nu,filename,recl_factor)

!-----------------------------------------------------------------------
!
!     this routine opens a file for parallel i/o
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
!     input variables
!
!-----------------------------------------------------------------------

      integer, intent(in) :: 
     &   recl_factor      ! factor for multiplying grid size to get
                          ! record length

      character (*), intent(in) ::
     &   filename   ! file to open and assign to unit nu

!-----------------------------------------------------------------------
!
!     output variables
!
!-----------------------------------------------------------------------

      integer, intent(out) :: 
     &   nu         ! unit number attached to newly-opened file

!-----------------------------------------------------------------------

      call ccsm3_io_get_unit(nu)


!-----------------------------------------------------------------------

      end subroutine ccsm3_io_open_parallel_file

!***********************************************************************

      subroutine ccsm3_io_close_parallel_file(nu)

!-----------------------------------------------------------------------
!
!     this routine closes a parallel file
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
!     input variables
!
!-----------------------------------------------------------------------

      integer, intent(in) :: 
     &   nu         ! unit number to close

!-----------------------------------------------------------------------

      call ccsm3_io_release_unit(nu)

!-----------------------------------------------------------------------

      end subroutine ccsm3_io_close_parallel_file



!***********************************************************************

      end module ccsm3_io

!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
