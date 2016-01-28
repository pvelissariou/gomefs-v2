!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

      module ccsm3_grid

!***********************************************************************
!
!     Based upon pop grid.F  CVS:$Name: ccsm3_0_rel04 $
!
!-----------------------------------------------------------------------

      use ccsm3                   ! ccsm3 ocean
      use ccsm3_constants         ! ccsm3 ocean constants
      use ccsm3_io                ! ccsm3 ocean io
      use ccsm3_exit              ! ccsm3 ocean exit 
      use ccsm3_global_reductions ! ccsm3 mpi communications 

      implicit none
      save


!-----------------------------------------------------------------------
!
!     geometric scalars
!
!-----------------------------------------------------------------------
      real, public, dimension(imt1:imt2,jmt1:jmt2) ::
     &  TLONG                   !
     &, TLAT
     &, TAREA                   !T-cell area 
     &, ANGLET                   
     &, RCALCT                  !mask (1. or 0.)



!***********************************************************************

      contains

!***********************************************************************

      subroutine ccsm3_grid_init (gridpath)

!-----------------------------------------------------------------------
!
!     intializes all grid quantities
!
!-----------------------------------------------------------------------
      character (*) :: gridpath


!-----------------------------------------------------------------------
!
!     local variables
!
!-----------------------------------------------------------------------

      character*80  :: gridname, gridtype

      namelist /coupled_grid_nml/gridname, gridtype

      integer ::
     &  nml_error           ! namelist i/o error flag
     &, i,j

 
!-----------------------------------------------------------------------
!
!     read input namelist for grid setup options
!
!-----------------------------------------------------------------------

      gridname      = 'unknown_horiz_gridname'
      gridtype      = 'unknown_horiz_gridtype'

      if (my_task == master_task) then
        nml_error = -1
        open (nml_in, file=nml_filename, status='old')
   10   continue  !*** keep reading until find right namelist
        read(nml_in, nml=coupled_grid_nml,err=10,end=20)
        close(nml_in)
        nml_error = 0
   20   continue
      endif

      call broadcast_scalar(nml_error, master_task)
      if (nml_error /= 0) then
        call ccsm3_exit_HYCOM ('ERROR reading grid_nml')
      endif

      if (my_task == master_task) then
        write(stdout,1000)
        write(stdout,1001)
        write(stdout,1002)
        write(stdout,1001)
        write(stdout,1000)
        call flush(stdout)
 1000   format(72('-'))
 1001   format(' ')
 1002   format(' Grid options')

        write(stdout,*) ' '
        write(stdout,*) ' Document Namelist Parameters:'
        write(stdout,*) ' ============================ '
        write(stdout,*) ' '
        write(stdout, coupled_grid_nml)
        write(stdout,*) ' '
        call flush(stdout)
      endif

      call broadcast_scalar(gridname, master_task)
      call broadcast_scalar(gridtype, master_task)

!-----------------------------------------------------------------------
!
!     read horizontal grid
!
!-----------------------------------------------------------------------

      ! with gx initialization, use the grid defined in geopar 
      call ccsm3_grid_set_horiz

      if (my_task == master_task) then
        write(stdout,*) ' '
        write(stdout,*) ' (ccsm3_grid_init) completed '
        call flush(stdout)
      endif


      end subroutine ccsm3_grid_init


!***********************************************************************

      subroutine ccsm3_grid_set_horiz

      integer :: i,j,n

!-----------------------------------------------------------------------
!
!     set horizontal grid information for cpl6, based upon plat, plon
!
!     cpl6 needs the following grid information (in 'normal' x-y directions):
!     TLON, TLAT: T cell lon, lat
!     TAREA:      T cell area in square radians;
!     IMASK_G:    T point land mask (1-ocean, 0-land);
!
!..........................................................................

      
      do j=1,jj
      do i=1,ii
         if     (plon(i,j).lt.-720.0) then
           TLONG(i,j) = mod(plon(i,j)+1080.0,360.0)
         elseif (plon(i,j).lt.-360.0) then
           TLONG(i,j) = mod(plon(i,j)+ 720.0,360.0)
         elseif (plon(i,j).lt.  0.0) then
           TLONG(i,j) = mod(plon(i,j)+ 360.0,360.0)
         elseif (plon(i,j).gt.360.0) then
           TLONG(i,j) = mod(plon(i,j),360.0)
         else
           TLONG(i,j) =     plon(i,j)
         endif
         TLAT (i,j) = plat(i,j)
         TAREA(i,j) = scp2(i,j)*1.0e4  ! convert from m^2  to cm^2
         IMSK (i,j) = ip  (i,j)   
         if     (ip(i,j).ne.0.0) then
           RCALCT(i,j) = c1p
         else
           RCALCT(i,j) = c0p
         endif
      enddo
      enddo

      end subroutine ccsm3_grid_set_horiz



      end module ccsm3_grid

!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
