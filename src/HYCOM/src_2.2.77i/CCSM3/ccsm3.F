!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

      module ccsm3

      use ccsm3_constants         ! ccsm3 ocean constants
      use mod_dimensions          ! hycom dimensions.h
      use cpl_contract_mod        ! ccsm3 cpl6 
      use cpl_interface_mod       ! ccsm3 cpl6 
      use cpl_fields_mod          ! ccsm3 cpl6 
      use shr_sys_mod             ! ccsm3 shared systems routines
      use shr_msg_mod             ! ccsm3 shared message-passing 

      implicit none
      include 'common_blocks.h'
      save
      
!-----------------------------------------------------------------------
!
!     module variables
!
!-----------------------------------------------------------------------


      logical ::	
     &  lcoupled              ! flag for coupled forcing


      integer ::
     &  coupled_freq_iopt,    ! coupler frequency option
     &  coupled_freq          ! frequency of coupling

      integer, public, dimension(imt1:imt2,jmt1:jmt2) ::
     &   IMSK

      real, public, dimension(imt1:imt2,jmt1:jmt2) ::
     &  dhdx 			!gradient of srfhgt
     &, dhdy

      real, public, dimension(imt1:imt2,jmt1:jmt2,2) ::
     &  SMF                !  surface momentum fluxes (wind stress)
     &, SMFT               !  surface momentum fluxes at T points
      real, public, dimension(imt1:imt2,jmt1:jmt2) ::
     &  SHF_QSW            !  penetrative solar heat flux

!dbi: add in ice-model related stuff.........................................
      integer ::
     &  kmxice                ! lowest level from which to integrate 
                              ! ice formation

      integer, private ::
     &  ice_flag              ! time flag id for ice formation
     &, ice_cpl_flag          ! time flag id for coupled timestep

      logical ::
     &  liceform              ! flag to turn on/off ice formation

      real ::
     &  salice,               ! sea ice salinity in msu
     &  salref,               ! ocean ref salinity in msu
     &  tlast_ice             ! time since last ice flux computed

      real , dimension(imt1:imt2,jmt1:jmt2) :: 
     &  QICE,               ! tot column cooling from ice form (in C*cm)
     &  AQICE,              ! accumulated ice heat flux
     &  QFLUX               ! ice formation / melt heat flux in  W/m^2 

      real ::
     &  sea_ice_salinity

!-----------------------------------------------------------------------
!
!     lactive_ice = .T.     ocean is coupled to an active ice model,
!                   .F.     ocean is coupled to a dummy ice model.
!
!-----------------------------------------------------------------------

      logical :: lactive_ice

      integer ::
     &  k1n                     ! "current time level"

      integer, public ::
     &  MPI_COMM_OCN		! communicator for processors assigned to ocn

      integer, public ::
     &  cpl_task,               ! task id for coupler
     &  ocn_task                ! task id for ocean

      integer ::
     &  my_task,                ! task id for local process
     &  master_task             ! task id for master process


      logical ::
     &  cpl_write_restart       ! flag id for write restart
     &, cpl_write_history       ! flag id for write history


      real ::
     &  tlast_coupled


      real, dimension(imt1:imt2,jmt1:jmt2) ::
     &  EVAP_F = c0p         ! evaporation   flux    -- from cpl (kg/m2/s)
     &, PREC_F = c0p         ! precipitation flux    -- from cpl (kg/m2/s)
     &, SNOW_F = c0p         ! snow          flux    -- from cpl (kg/m2/s)
     &, MELT_F = c0p         ! melt          flux    -- from cpl (kg/m2/s)
     &, ROFF_F = c0p         ! river runoff  flux    -- from cpl (kg/m2/s)
     &, SALT_F = c0p         ! salt          flux    -- from cpl (kg(salt)/m2/s)
     &, SENH_F = c0p         ! sensible heat flux    -- from cpl (W/m2   )
     &, LWUP_F = c0p         ! longwave heat flux up -- from cpl (W/m2   )
     &, LWDN_F = c0p         ! longwave heat flux dn -- from cpl (W/m2   )
     &, MELTH_F= c0p         ! melt     heat flux    -- from cpl (W/m2   )




!***********************************************************************

      contains

!***********************************************************************
        subroutine ccsm3_setup_coupling_env

        implicit none

        include 'mpif.h'

        integer :: ier

!-----------------------------------------------------------------------
!
!       initialize cpl6 communications
!
!-----------------------------------------------------------------------

        call cpl_interface_init(cpl_fields_ocnname,MPI_COMM_OCN)

        master_task = 0

        call MPI_COMM_RANK(MPI_COMM_OCN, my_task, ier)
        if (master_task == my_task) then
          write(6,*)'(ccsm3_setup_coupling_env) successful!'
          call flush(6)
        endif

        if (my_task == master_task) call shr_msg_dirio('ocn') ! redirect stdin/stdout

        return
        end subroutine ccsm3_setup_coupling_env

!************************************************************************



      end module  ccsm3

!***********************************************************************
