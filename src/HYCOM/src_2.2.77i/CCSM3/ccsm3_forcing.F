!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

      module ccsm3_forcing

      use ccsm3                   ! ccsm3 ocean
      use ccsm3_grid              ! ccsm3 ocean
      use ccsm3_constants         ! ccsm3 ocean
      use ccsm3_time_management   ! ccsm3 ocean
      use ccsm3_global_reductions ! ccsm3 ocean
      use ccsm3_exit              ! ccsm3 ocean
      use ccsm3_io                ! ccsm3 ocean
      use cpl_contract_mod        ! ccsm3 cpl6
      use cpl_interface_mod       ! ccsm3 cpl6
      use cpl_fields_mod          ! ccsm3 cpl6
      use shr_sys_mod             ! ccsm3 shared systems routines
      use shr_const_mod           ! ccsm3 shared constants
      use shr_timer_mod           ! shared code: timing routines
      use mod_xc,                 !hycom communication routines
     &  only : xctilr, xcaget, halo_uv, halo_ps, mnproc

      logical ::
     &  ldiag_cpl         = .TRUE.
     &, lsend_precip_fact = .false.
 
      real ::
     &  latent_heat_fusion_mks = SHR_CONST_LATICE ! latent heat of fusion ~ J/kg
     &, precip_fact = 1.0

      integer ::
     &  timer_send_to_cpl  
     &, timer_recv_from_cpl
     &, timer_recv_to_send 
     &, timer_send_to_recv 

      integer, dimension(cpl_fields_ibuf_total) ::
     &   isbuf                ! integer control buffer for sends
     &  ,irbuf                ! integer control buffer for receives
      type(cpl_contract) ::
     &   contractS            ! contract for sends to coupler
     &  ,contractR            ! contract for receives from coupler
      real, dimension(:,:), allocatable ::
     &   sbuf                 ! temporary send/recv buffer

      real, dimension(imt1:imt2,jmt1:jmt2,cpl_fields_o2c_total) ::
     &  SBUFF_SUM           ! accumulated sum of send buffer quantities
                            ! for averaging before being sent
!-----------------------------------------------------------------------
!
!  diurnal cycle switch for the net shortwave heat flux
!
!     qsw_diurnal_cycle = .T.  diurnal cycle is ON
!                       = .F.  diurnal cycle is OFF
!
!-----------------------------------------------------------------------

      logical  :: qsw_diurnal_cycle

!JY   declare new array to facilitate the implementation of diurnal cycle
      real, dimension (1-nbdy:idm+nbdy,1-nbdy:jdm+nbdy) ::
     &            surflx_no_sw
      integer ::  index_qsw

!-----------------------------------------------------------------------
!  The following variables are used in the exchange of 
!  information between cpl6 and the ocean code.
!
!  ocn --> cpl6
!  ============
!    cpl_fields_ibuf_total -- length of integer ocean "send buffer" vector (isbuf)
!    cpl_fields_o2c_total --  total number of 2D fields sent to cpl6 from ocn
!
!    integer send buffer indices (isbuf in subroutine ccsm3_init_coupled):  
!
!     o  cpl_fields_ibuf_cdate   -- ocean's character date string (yyyymmdd)
!     o  cpl_fields_ibuf_sec     -- ocean's character time string (seconds)
!     o  cpl_fields_ibuf_precadj -- precipitation adjustment factor*1e6
!     o  cpl_fields_ibuf_lsize   -- ii*jj
!     o  cpl_fields_ibuf_lisize  -- ii
!     o  cpl_fields_ibuf_ljsize  -- jj
!     o  cpl_fields_ibuf_gsize   -- itdm*jtdm
!     o  cpl_fields_ibuf_gisize  -- itdm
!     o  cpl_fields_ibuf_gjsize  -- jtdm
!     o  cpl_fields_ibuf_ncpl    -- ncouple_per_day
!     o  cpl_fields_ibuf_nfields -- cpl_fields_grid_total
!     o  cpl_fields_ibuf_dead    --  0 ==>  not a "dead" model
!
!    real send buffer indices (sbuf in subroutine ccsm3_init_coupled):
!
!     o  cpl_fields_grid_lon   -- TLONG(i,j)
!     o  cpl_fields_grid_lat   -- TLAT(i,j)
!     o  cpl_fields_grid_area  -- TAREA(i,j)/(e_radius*e_radius)
!     o  cpl_fields_grid_mask  -- float(REGION_MASK(i,j))
!     o  cpl_fields_grid_index -- (j0+j-1)*itdm + i0+i
!
!    real send buffer indices (sbuf in subroutine send_to_coupler):
!
!      (1)  cpl_fields_o2c_u     -- surface u velocity
!      (2)  cpl_fields_o2c_v     -- surface v velocity
!      (3)  cpl_fields_o2c_t     -- surface temperature
!      (4)  cpl_fields_o2c_s     -- surface salinity
!      (5)  cpl_fields_o2c_dhdx  -- e,w surface slope
!      (6)  cpl_fields_o2c_dhdy  -- n,s surface slope
!      (7)  cpl_fields_o2c_q     -- qflux
!
!
!    cpl6 --> ocn  
!    ============
!
!      cpl_fields_ibuf_total -- length of integer ocean "receive buffer" vector (irbuf)
!      cpl_fields_c2o_total --  total number of 2D fields sent to ocn from cpl6
!
!      integer receive buffer indices (irbuf in subroutine recv_from_coupler):
!
!       o  cpl_fields_ibuf_stopnow  -- stop ocean integration now
!       o  cpl_fields_ibuf_infobug  -- write ocean/coupler diagnostics now  
!       o  cpl_fields_ibuf_resteod  -- write ocean restart files at end of day
!       o  cpl_fields_ibuf_histeod  -- write ocean history files at end of day
!       o  cpl_fields_ibuf_histtavg -- write ocean "tavg"  files at end of day
!       o  cpl_fields_ibuf_diageod  -- write ocean diagnostics   at end of day
!
!      real receive buffer indices (sbuf in subroutine recv_from_coupler):
!
!       o   cpl_fields_c2o_taux  -- zonal wind stress (taux)
!       o   cpl_fields_c2o_tauy  -- meridonal wind stress (tauy)
!       o   cpl_fields_c2o_snow  -- water flux due to snow
!       o   cpl_fields_c2o_rain  -- water flux due to rain
!       o   cpl_fields_c2o_evap  -- evaporation flux
!       o   cpl_fields_c2o_meltw -- snow melt flux
!       o   cpl_fields_c2o_roff  -- river runoff flux
!       o   cpl_fields_c2o_salt  -- salt
!       o   cpl_fields_c2o_swnet -- net short-wave heat flux
!       o   cpl_fields_c2o_sen   -- sensible heat flux
!       o   cpl_fields_c2o_lwup  -- longwave radiation (up)
!       o   cpl_fields_c2o_lwdn  -- longwave radiation (down)
!       o   cpl_fields_c2o_melth -- heat flux from snow&ice melt
!       o   cpl_fields_c2o_ifrac -- ice fraction
!       o   cpl_fields_c2o_press -- sea-level pressure
!       o   cpl_fields_c2o_duu10 -- 10m wind speed squared
!
!
!-----------------------------------------------------------------------


 
      save
      
!***********************************************************************

      contains

!***********************************************************************
!************************************************************************

      subroutine ccsm3_init_coupled(gridpath)

!-----------------------------------------------------------------------
!
!     this routine sets up everything necessary for coupling with
!     the NCAR flux coupler.
!
!-----------------------------------------------------------------------

      implicit none

      character (*) :: gridpath

!-----------------------------------------------------------------------
!
!     local variables
!
!-----------------------------------------------------------------------

      character (80) ::
     &  coupled_freq_opt

      integer, parameter ::
     &  freq_opt_never    = 0
     &, freq_opt_nyear    = 1
     &, freq_opt_nmonth   = 2
     &, freq_opt_nday     = 3
     &, freq_opt_nhour    = 4
     &, freq_opt_nsecond  = 5
     &, freq_opt_nstep    = 6

      namelist /coupled_nml/ coupled_freq_opt, coupled_freq 
     &, qsw_diurnal_cycle

      integer :: k,i,j,n
     &, ncouple_per_day       ! num of coupler comms per day
     &, nml_error             ! namelist i/o error flag
     &, ier                   ! error flag for messages

!-----------------------------------------------------------------------
!
!     variables associated with the solar diurnal cycle
!
!-----------------------------------------------------------------------

      real  ::
     &   time_for_forcing,    ! time of day for surface forcing
     &   frac_day_forcing,    ! fraction of day based on time_for_forcing
     &   cycle_function,      ! intermediate result of the diurnal cycle function
     &   weight_forcing,      ! forcing weights
     &   sum_forcing          ! sum of forcing weights

      integer  ::
     &   count_forcing        ! time step counter (== nsteps_this_interval+1)

Cpg
      logical ::
     &   lp_diurnal    ! only turn on once to print out diurnal_cycle_factor

      lp_diurnal = .true.
Cpg
!-----------------------------------------------------------------------
!
!     read coupled_nml namelist to start coupling and determine
!     coupling frequency
!
!-----------------------------------------------------------------------


      lcoupled          = .false.
      coupled_freq_opt  = 'never'
      coupled_freq_iopt = freq_opt_never
      coupled_freq      = 100000
      qsw_diurnal_cycle = .false.

      if (my_task == master_task) then
        nml_error = -1
        open (nml_in, file=nml_filename, status='old')

   10   continue  !*** keep reading until find right namelist
        read(nml_in, nml=coupled_nml, err=10, end=20)
        close(nml_in)
        nml_error = 0
   20   continue
      endif

      call broadcast_scalar(nml_error, master_task)
      if (nml_error /= 0) then
 	call ccsm3_exit_HYCOM('ERROR: reading coupled_nml')
      endif


      if (my_task == master_task) then
        select case (coupled_freq_opt)

        case ('nyear')
          coupled_freq_iopt = -1000

        case ('nmonth')
          coupled_freq_iopt = -1000

        case ('nday')
          if (coupled_freq == 1) then
            lcoupled = .true.
            coupled_freq_iopt = freq_opt_nday
            ncouple_per_day = 1
          else
            coupled_freq_iopt = -1000
          endif

        case ('nhour')
          if (coupled_freq <= 24) then
            lcoupled = .true.
            coupled_freq_iopt = freq_opt_nhour
            ncouple_per_day = 24/coupled_freq
          else
            coupled_freq_iopt = -1000
          endif

        case ('nsecond')
          if (coupled_freq <= seconds_in_day) then
            lcoupled = .true.
            coupled_freq_iopt = freq_opt_nsecond
            ncouple_per_day = seconds_in_day/coupled_freq
          else
            coupled_freq_iopt = -1000
          endif

        case ('nstep')
          if (coupled_freq <= nsteps_per_day) then
            lcoupled = .true.
            coupled_freq_iopt = freq_opt_nstep
            ncouple_per_day = nsteps_per_day/coupled_freq
          else
            coupled_freq_iopt = -1000
          endif

        case ('never')
          lcoupled = .false.

        case default
          coupled_freq_iopt = -2000
        end select

      endif

      call broadcast_scalar(lcoupled,          master_task)
      call broadcast_scalar(coupled_freq_iopt, master_task)
      call broadcast_scalar(coupled_freq     , master_task)
      call broadcast_scalar(qsw_diurnal_cycle, master_task)

      if (my_task == master_task) then
          write(stdout,*) ' '
          write(stdout,*) ' Document Namelist Parameters:'
          write(stdout,*) ' ============================ '
          write(stdout,*) ' '
          write(stdout, coupled_nml)
          write(stdout,*) ' '
          call flush (stdout)
      endif


      if (coupled_freq_iopt == -1000) then
	call ccsm3_exit_HYCOM(
     &       'ERROR: Coupling frequency must be at least once per day')
      else if (coupled_freq_iopt == -2000) then
        call ccsm3_exit_HYCOM(
     &       'ERROR: Unknown option for coupling frequency')
      endif

      if (.not. lcoupled) then
        call ccsm3_exit_HYCOM(
     &       'ERROR: Coupled ifdef option enabled but lcoupled=false')
      endif


!-----------------------------------------------------------------------
!
!     Initialize flags
!
!-----------------------------------------------------------------------

      cpl_write_restart = .false.   ! init_time_flag('restart')
      cpl_write_history = .false.   ! init_time_flag('history')

      tlast_coupled = c0p
      tlast_ice     = c0p

!-----------------------------------------------------------------------
!
!     initialize grid -- needed by cpl6
!       TLON, TLAT, TAREA, IMSK
!
!-----------------------------------------------------------------------

      call ccsm3_grid_init (gridpath)
     

!-----------------------------------------------------------------------
!
!       initialize and send buffer
!
!-----------------------------------------------------------------------

      isbuf = 0

      isbuf(cpl_fields_ibuf_cdate  ) = cdate
      isbuf(cpl_fields_ibuf_sec    ) = 0
      isbuf(cpl_fields_ibuf_lsize  ) = ii*jj
      isbuf(cpl_fields_ibuf_lisize ) = ii
      isbuf(cpl_fields_ibuf_ljsize ) = jj
      isbuf(cpl_fields_ibuf_gsize  ) = itdm*jtdm
      isbuf(cpl_fields_ibuf_gisize ) = itdm
      isbuf(cpl_fields_ibuf_gjsize ) = jtdm
      isbuf(cpl_fields_ibuf_ncpl   ) = ncouple_per_day
      isbuf(cpl_fields_ibuf_nfields) = cpl_fields_grid_total
      isbuf(cpl_fields_ibuf_dead   ) = 0          

 
!-----------------------------------------------------------------------
!
!     allocate and compute the short wave heat flux multiplier for the 
!     diurnal cycle
!
!-----------------------------------------------------------------------

Cpg      allocate ( diurnal_cycle_factor(nsteps_per_day) )

      diurnal_cycle_factor = c1p
 
      if ( qsw_diurnal_cycle ) then

!       mimic a day

        time_for_forcing = c0p
        count_forcing    =  1
        sum_forcing      = c0p

        do n=1,nsteps_per_day
          frac_day_forcing = time_for_forcing / seconds_in_day 
          cycle_function = cos( pi * ( c2p * frac_day_forcing - c1p ) )
          diurnal_cycle_factor(n) = c2p * ( cycle_function 
     &                                + abs(cycle_function) ) 
     &                                    * cycle_function
          weight_forcing = c1p
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!         pop needs the following in our code, because it occasionally
!         has timesteps that are one-half the size of a normal timestep
!         if (  count_forcing == 2  .or.
!    &      mod(count_forcing,time_mix_freq) == 0 )
!    &      weight_forcing = pp5
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

          time_for_forcing = time_for_forcing + weight_forcing * baclin
          sum_forcing = sum_forcing 
     &              + weight_forcing * baclin * diurnal_cycle_factor(n)

          count_forcing = count_forcing + 1
        enddo

        diurnal_cycle_factor = diurnal_cycle_factor * seconds_in_day 
     &                        / sum_forcing

      if (lp_diurnal) then
      if (my_task == master_task) then
          write(stdout,*) ' '
          write(stdout,*) ' diurnal_cycle_factor '
          do n=1,nsteps_per_day,10
          write(stdout,'(i6,10f8.2)') n, (diurnal_cycle_factor(i),i=n,n+9)
          enddo
          write(stdout,*) ' '
          call flush (stdout)
      endif

      lp_diurnal = .false.
      endif

!       check the final integral

        count_forcing =  1
        sum_forcing   = c0p

        do n=1,nsteps_per_day
          weight_forcing = c1p

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!         if (  count_forcing == 2  .or.
!    &      mod(count_forcing,time_mix_freq) == 0 )
!    &      weight_forcing = p5
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          sum_forcing = sum_forcing
     &              + weight_forcing * baclin * diurnal_cycle_factor(n)
          count_forcing = count_forcing + 1
        enddo

        if ( sum_forcing < (seconds_in_day - 1.0e-5         )  .or.
     &       sum_forcing > (seconds_in_day + 1.0e-5         ) )
     &    call ccsm3_exit_HYCOM ('ERROR: qsw diurnal cycle temporal '//
     &                   'integral is incorrect')

      endif
 
      allocate(sbuf(ii*jj,cpl_fields_grid_total))

      sbuf = -888.0
      n=0
      do j=1,jj
      do i=1,ii

         n=n+1
         sbuf(n,cpl_fields_grid_lon  ) = TLONG(i,j)   !degrees E
         sbuf(n,cpl_fields_grid_lat  ) = TLAT(i,j)    !degrees N
         sbuf(n,cpl_fields_grid_area ) = TAREA(i,j)/(e_radius*e_radius)  
         sbuf(n,cpl_fields_grid_mask ) = float(IMSK(i,j))
         sbuf(n,cpl_fields_grid_index) = (j0+j-1)*itdm + i0+i
      enddo
      enddo


!-----------------------------------------------------------------------
!     initialize the contracts
!-----------------------------------------------------------------------
      call cpl_interface_contractInit(contractS,cpl_fields_ocnname,
     &   cpl_fields_cplname,cpl_fields_o2c_fields,isbuf,sbuf)
      call cpl_interface_contractInit(contractR,cpl_fields_ocnname,
     &   cpl_fields_cplname,cpl_fields_c2o_fields,isbuf,sbuf)

      if (my_task == master_task) then
          write(stdout,*) ' '
          write(stdout,*) '(ccsm3_init_coupled) Send initial message to cpl6'
          write(stdout,*) ' '
          call flush (stdout)
      endif

      deallocate(sbuf)

      !--- receive initial message from coupler
      call cpl_interface_ibufRecv(cpl_fields_cplname,irbuf)

      if (my_task == master_task) then
          write(stdout,*) ' '
          write(stdout,*) '(ccsm3_init_coupled) Receive initial message'
     &                    //' from cpl6'
          write(stdout,*) ' '
          call flush (stdout)
      endif

!-----------------------------------------------------------------------
!
!     send initial state info to coupler
!
!-----------------------------------------------------------------------

      call sum_buffer

      call send_to_coupler

!-----------------------------------------------------------------------
!
!     initialize timers for coupled model
!
!-----------------------------------------------------------------------
      call shr_timer_init
      
      call shr_timer_get (timer_send_to_cpl  , 'SEND'        )
      call shr_timer_get (timer_recv_from_cpl, 'RECV'        )
      call shr_timer_get (timer_recv_to_send , 'RECV to SEND')
      call shr_timer_get (timer_send_to_recv , 'SEND to RECV')


      if (my_task == master_task) then
        write(stdout,*)' (ccsm3_init_coupled) end subroutine'
      endif
!-----------------------------------------------------------------------

      end subroutine ccsm3_init_coupled

!***********************************************************************

      subroutine ccsm3_set_coupled_forcing 

!-----------------------------------------------------------------------
!
!     this routine call coupler communication routines to set
!     surface forcing data
!
!-----------------------------------------------------------------------

      implicit none


!-----------------------------------------------------------------------
!     call sum_buffer to calculate the "buffer sum" every time step!
!
!     if it is time to couple, exchange data with flux coupler
!     be sure to trigger communication on very first time step
!
!-----------------------------------------------------------------------

      if (nsteps_run /= 0) call sum_buffer


      if (cpl_ts .or. nsteps_run == 0) then
        if (nsteps_run /= 0) then
          call shr_timer_stop  (timer_recv_to_send)
          call shr_timer_start (timer_send_to_cpl)

          call send_to_coupler

          call shr_timer_stop  (timer_send_to_cpl)
        endif

        call shr_timer_start (timer_send_to_recv)
        call shr_timer_stop  (timer_send_to_recv) 
        call shr_timer_start (timer_recv_from_cpl)

        call recv_from_coupler  
         
        call shr_timer_stop  (timer_recv_from_cpl)
        call shr_timer_start (timer_recv_to_send)

      endif

!-----------------------------------------------------------------
!     Jianjun Yin (04/02/2007)
!     calculate surflx and sswflx and implement diurnal cycle here
!-----------------------------------------------------------------

      index_qsw = mod(nsteps_today,nsteps_per_day) + 1
      sswflx = diurnal_cycle_factor(index_qsw)*SHF_QSW
      surflx = surflx_no_sw + sswflx

      return
      end subroutine ccsm3_set_coupled_forcing

!***********************************************************************

      subroutine recv_from_coupler 

!-----------------------------------------------------------------------
!
!     this routine receives message from coupler with surface flux
!     data
!
!-----------------------------------------------------------------------

      implicit none

!-----------------------------------------------------------------------
!
!     output variables
!
!-----------------------------------------------------------------------

!-----------------------------------------------------------------------
!
!     local variables
!
!-----------------------------------------------------------------------

      integer ::
     &  ier                 ! error flag for message calls
     &, i,j,n, k            ! loop indices

      real, dimension(imt1:imt2,jmt1:jmt2) :: 
     &  WORK1, WORK2        ! local work space
     &, WORK3, WORK4        ! local work space
     &, WORK5 

      character*80 :: label

      real :: gsum
      real :: latent_heat_vapor = SHR_CONST_LATVAP       !(J/kg)
      real :: hflux_factor

Cpg - Diurnal cycle
      integer ::
     &  index_qsw

!############ test ics ###############
      include 'netcdf.inc'

      integer :: dims(3)
      integer :: tx_id, ty_id, snow_id, fid
      integer :: evap_id, melt_id, roff_id, salt_id,prec_id
      integer :: swnet_id, sen_id, lwup_id, lwdn_id,melth_id
      integer :: jtdm_id, itdm_id
      integer :: salflx_id, surflx_id
      real,dimension(itdm,jtdm) :: TEMP_G

      character*80 long_name
!#######################################

      master_task = 0

!-----------------------------------------------------------------------
!
!     receive message from coupler and check for terminate signal
!
!-----------------------------------------------------------------------

      allocate(sbuf(ii*jj, cpl_fields_c2o_total))
      call cpl_interface_contractRecv(cpl_fields_cplname,contractR
     &,       irbuf,sbuf)

      if     (wndflg.eq.0 .and. flxflg.eq.0) then  !no atmos forcing
        n=0
        do j=1,jj
          do i=1,ii
            n=n+1
            sbuf(n,cpl_fields_c2o_taux) = 0.0
            sbuf(n,cpl_fields_c2o_tauy) = 0.0
            sbuf(n,cpl_fields_c2o_snow) = 0.0
            sbuf(n,cpl_fields_c2o_rain) = 0.0
            sbuf(n,cpl_fields_c2o_evap) = 0.0
            sbuf(n,cpl_fields_c2o_meltw)= 0.0
            sbuf(n,cpl_fields_c2o_roff) = 0.0    
            sbuf(n,cpl_fields_c2o_salt) = 0.0 
            sbuf(n,cpl_fields_c2o_swnet)= 0.0   
            sbuf(n,cpl_fields_c2o_sen)  = 0.0
            sbuf(n,cpl_fields_c2o_lwup) = 0.0  
            sbuf(n,cpl_fields_c2o_lwdn) = 0.0 
            sbuf(n,cpl_fields_c2o_melth)= 0.0
!            sbuf(n,cpl_fields_c2o_ifrac)= 0.0
!            sbuf(n,cpl_fields_c2o_press)= 0.0
            sbuf(n,cpl_fields_c2o_duu10)= 0.0
          enddo
        enddo
      endif

!-----------------------------------------------------------------------
!
!     check all coupler flags and respond appropriately
!
!-----------------------------------------------------------------------


      if (irbuf(cpl_fields_ibuf_stopnow) == 1) then
        if (my_task == master_task) then
          write (stdout,*) '(from_coupler) received terminate signal'
          call flush(stdout)
        endif
        stop_now = 1
        return
      endif

      if (irbuf(cpl_fields_ibuf_infobug) >= 2) then
         ldiag_cpl = .true. 
      else
         ldiag_cpl = .false.
      endif

      if (irbuf(cpl_fields_ibuf_resteod) == 1) then
         cpl_write_restart = .true.
         if (my_task == master_task) then
           write(stdout,*) ' cpl requests restart file at eod ', cdate
         endif
      else
         cpl_write_restart = .false.
      endif

!-----------------------------------------------------------------------
!
!     unpack and distribute wind stress, then convert to correct units
!     if necessary, rotate components to logical coordinates
!
!-----------------------------------------------------------------------

      n = 0
      do j=1,jj
      do i=1,ii
         n = n + 1
         WORK1(i,j) = sbuf(n,cpl_fields_c2o_taux)
         WORK2(i,j) = sbuf(n,cpl_fields_c2o_tauy)
      enddo
      enddo
      call xctilr (WORK1,1,1,nbdy,nbdy,halo_uv)
      call xctilr (WORK2,1,1,nbdy,nbdy,halo_uv)


      !***
      !*** Rotate true zonal/meridional wind stress into local
      !*** coordinates and convert to dyne/cm**2
      !***

!dbi: hycom uses kg.m.s units! thus no need to use 'momentum_factor':
!
      SMFT(:,:,1) = (WORK1*cos(ANGLET) + WORK2*sin(ANGLET))*RCALCT
      SMFT(:,:,2) = (WORK2*cos(ANGLET) - WORK1*sin(ANGLET))*RCALCT
      call xctilr (SMFT(:,:,1),1,1,nbdy,nbdy,halo_uv)
      call xctilr (SMFT(:,:,2),1,1,nbdy,nbdy,halo_uv) ! 1,1 ==> 1 level

!DBI: we need friction velocity:--------------------------------
!     rho_sw = 1025.0; thref = 1.e-3
!     we use the 'standard' formula:  
      !ustar = sqrt(sqrt(SMFT(:,:,1)**2 + SMFT(:,:,2)**2)/rho_sw)
      ustar = sqrt(thref*sqrt(SMFT(:,:,1)**2 + SMFT(:,:,2)**2))
!---------------------------------------------------------------

      !***
      !*** Shift SMFT to U grid
      !***

!DBI: the interpolation from T points to U points will be done in 
!     momtum.F on the option of 'wndflg=2' (ie, on p points) 
!AJW: making tau 1:4 the same means that any 4 weights that sum to 1.0 
!     will recover the original tau
       
      SMF = SMFT
       
      taux(:,:,1) = SMFT(:,:,1)
      taux(:,:,2) = SMFT(:,:,1)
      taux(:,:,3) = SMFT(:,:,1)
      taux(:,:,4) = SMFT(:,:,1)
      tauy(:,:,1) = SMFT(:,:,2)
      tauy(:,:,2) = SMFT(:,:,2)
      tauy(:,:,3) = SMFT(:,:,2)
      tauy(:,:,4) = SMFT(:,:,2)
        

!-----------------------------------------------------------------------
!
!     distribute fresh water flux and salt flux onto hycom "tiles"
!
!-----------------------------------------------------------------------
 
      n = 0
      do j=1,jj
      do i=1,ii
         n = n + 1
         SNOW_F(i,j) = sbuf(n,cpl_fields_c2o_snow)
         WORK1(i,j)  = sbuf(n,cpl_fields_c2o_rain)
         EVAP_F(i,j) = sbuf(n,cpl_fields_c2o_evap)
         MELT_F(i,j) = sbuf(n,cpl_fields_c2o_meltw)
         ROFF_F(i,j) = sbuf(n,cpl_fields_c2o_roff)
         SALT_F(i,j) = sbuf(n,cpl_fields_c2o_salt)
      enddo
      enddo

      PREC_F = WORK1 + SNOW_F         ! rain + snow

      call xctilr (SNOW_F,1,1,nbdy,nbdy,halo_ps)
      call xctilr (PREC_F,1,1,nbdy,nbdy,halo_ps)
      call xctilr (EVAP_F,1,1,nbdy,nbdy,halo_ps)
      call xctilr (MELT_F,1,1,nbdy,nbdy,halo_ps)
      call xctilr (ROFF_F,1,1,nbdy,nbdy,halo_ps)
      call xctilr (SALT_F,1,1,nbdy,nbdy,halo_ps)


!-----------------------------------------------------------------------
!
!     for variable thickness surface layer, compute fresh water and
!     salt fluxes
!
!-----------------------------------------------------------------------

!DBI: really tricky and confusing. we take a 'simple' approach to get
!     the needed virtual salt flux for hycom:
!
      !
      !ocn_ref_salinity = 34.7      ![g/kg]
      !msu2ppt = 1000.              ![g/kg]
      !note, when required, PREC_F should be 'adjusted' (see hycom0.9 case)
      !here WORK1 is freshwater mass flux excluding ice formation term;
      !while WORK2 is salt mass flux [kg/m^2/s] from ice formation.
      !DBI: WORK1 = (PREC_F + EVAP_F + MELT_F + krbuff_roff) * RCALCT
      !
      WORK1 = (PREC_F + EVAP_F + MELT_F + ROFF_F) * RCALCT
      WORK2 = SALT_F * RCALCT
      call xctilr (WORK1,1,1,nbdy,nbdy,halo_ps)
      call xctilr (WORK2,1,1,nbdy,nbdy,halo_ps)
      !
      !Total fresh water (mass) flux (in [kg/m^2/s])
      !sfwf = WORK1 - WORK2 / (ocn_ref_salinity / msu2ppt) !DBI: currently nouse
      !Total virtual salt flux (10**-3 kg/m**2/sec) in +z direction
      salflx = - ocn_ref_salinity * WORK1 + WORK2 * msu2ppt 

      

!DBI: Note: original code from NCAR (POP) of the above conversion is 
!     quite complicated and removed.
!-----------------------------------------------------------------------

!-----------------------------------------------------------------------
!
!     unpack and distribute net shortwave to "tiles" and convert units
!
!-----------------------------------------------------------------------
      n = 0
      do j=1,jj
      do i=1,ii
         n = n + 1
         SHF_QSW(i,j) = sbuf(n,cpl_fields_c2o_swnet)
      enddo
      enddo
!--------- conversion needed? -------------
      hflux_factor = c1p/(rho_sw*cp_sw)
      write(6,*) ' rho_sw       = ', rho_sw
      write(6,*) ' cp_sw        = ', cp_sw       
      write(6,*) ' hflux_factor = ', hflux_factor
!--------- conversion needed? -------------
      SHF_QSW = SHF_QSW*RCALCT
      call xctilr (SHF_QSW,1,1,nbdy,nbdy,halo_ps)

      !SHF_QSW = SHF_QSW * RCALCT    !DBI: *hflux_factor !convert from W/m**2
      !netsw = SHF_QSW
 
!-----------------------------------------------------------------------
!
!     apply solar diurnal cycle 
!     PG:   it is done now in thermf_c.F 
!
!-----------------------------------------------------------------------

Cpg      index_qsw = mod(nsteps_today,nsteps_per_day) + 1
Cpg
Cpg      SHF_QSW = diurnal_cycle_factor(index_qsw)*SHF_QSW

!-----------------------------------------------------------------------
!
!     distribute non-sw heat flux (lat+sen+lw+melt) to tiles
!
!-----------------------------------------------------------------------

      n = 0
      do j=1,jj
      do i=1,ii
         n = n + 1
         WORK1(i,j) = sbuf(n,cpl_fields_c2o_sen)
         WORK2(i,j) = sbuf(n,cpl_fields_c2o_lwup)
         WORK3(i,j) = sbuf(n,cpl_fields_c2o_lwdn)
         WORK4(i,j) = sbuf(n,cpl_fields_c2o_melth)
      enddo
      enddo
      call xctilr (WORK1,1,1,nbdy,nbdy,halo_ps)
      call xctilr (WORK2,1,1,nbdy,nbdy,halo_ps)
      call xctilr (WORK3,1,1,nbdy,nbdy,halo_ps)
      call xctilr (WORK4,1,1,nbdy,nbdy,halo_ps)

      SENH_F  = WORK1
      LWUP_F  = WORK2
      LWDN_F  = WORK3
      MELTH_F = WORK4

      WORK5 = - SNOW_F * latent_heat_fusion_mks


!-----------------------------------------------------------------------
!
!DBI: total surface heat flux...........................................
!     combine (!DBI: and convert from W/m**2 ???)
!           (note: latent heat flux = evaporation*latent_heat_vapor)
!
!     Jianjun Yin 04/02/2007
!     surflx_no_sw does not include shortwave radiation
!     shortwave radiation is added in ccsm3_set_coupled_forcing
!----------------------------------------------------------------------

      surflx_no_sw = (EVAP_F*latent_heat_vapor+SENH_F+LWUP_F+LWDN_F
     &                  + MELTH_F + WORK5)*RCALCT


!-----------------------------------------------------------------------
!
!     unpack and distribute fractional ice coverage
!
!-----------------------------------------------------------------------

      n = 0
      do j=1,jj
      do i=1,ii
         n = n + 1
         WORK1(i,j) = sbuf(n,cpl_fields_c2o_ifrac)
      enddo
      enddo

      call xctilr (WORK1,1,1,nbdy,nbdy,halo_ps)

      covice = WORK1 * RCALCT

!-----------------------------------------------------------------------
!
!     unpack and distribute atmospheric pressure forcing
!     converting from Pa to dynes/cm**2
!     available if needed; just uncomment the following code
!-----------------------------------------------------------------------

!     n = 0
!     do j=1,jj
!     do i=1,ii
!        n = n + 1
!        WORK1(i,j) = sbuf(n,cpl_fields_c2o_press)
!     enddo
!     enddo
!     call xctilr (WORK1,1,1,nbdy,nbdy,halo_ps)

!     ATM_PRESS = c10 * WORK1 * RCALCT

!-----------------------------------------------------------------------
!
!     unpack and distribute 10m wind speed squared
!     converting from m**2/s**2 to cm**2/s**2
!     available if needed; just uncomment the following code
!
!-----------------------------------------------------------------------

!     n = 0
!     do j=1,jj
!     do i=1,ii
!        n = n + 1
!        WORK1(i,j) = sbuf(n,cpl_fields_c2o_duu10)
!     enddo
!     enddo
!     call xctilr (WORK1,1,1,nbdy,nbdy,halo_ps)

!     U10_SQR = 1.0e04 * WORK1 * RCALCT


!-----------------------------------------------------------------------
!
!     diagnostics
!
!-----------------------------------------------------------------------



      if (ldiag_cpl) then
        if  (my_task == master_task) then
          write(stdout,*)' Global averages of fluxes received from'
     &                  //' cpl at ',cdate
          call shr_sys_flush(stdout)
       endif
 
         do k = 1,cpl_fields_c2o_total
            n = 0
            do j=1,jj
            do i=1,ii
               n = n + 1
               WORK1(i,j) = sbuf(n,k)*TAREA(i,j)
            enddo
            enddo
            call xctilr (WORK1,1,1,nbdy,nbdy,halo_ps)
            gsum = ccsm3_global_real_sum(WORK1,RCALCT)*1.0e-4
            if (my_task == master_task) then
               call cpl_fields_getField(label,k,cpl_fields_c2o_fields)
               write(stdout,1100)'ocn','recv', label ,gsum
            endif
         enddo
         if (my_task == master_task) call shr_sys_flush(stdout)
      endif

1100  format ('comm_diag ', a3, 1x, a4, 1x, a8, 1x, es26.19:, 1x, a6)

      deallocate(sbuf)

!-----------------------------------------------------------------------

      end subroutine recv_from_coupler

!***********************************************************************

      subroutine send_to_coupler

!-----------------------------------------------------------------------
!
!     this routine packs fields into a message buffer and sends the
!     message to the flux coupler
!
!-----------------------------------------------------------------------

      implicit none

!-----------------------------------------------------------------------
!
!     local variables
!
!-----------------------------------------------------------------------

      character*80 :: label

      integer ::
     &  i,j,k,n

      real  :: 
     &   m2percm2
     &,  gsum

      real, dimension(imt1:imt2,jmt1:jmt2) :: 
     &  WORK1, WORK2        ! local work space
     &, WORK3, WORK4



!############ test ics ###############
      real :: tmin_val, tmax_val, smin_val, smax_val
      real :: gsum1, gsum2, gsum3
!#####################################


!-----------------------------------------------------------------------
!
!     initialize control buffer
!
!-----------------------------------------------------------------------

      allocate(sbuf(ii*jj, cpl_fields_o2c_total))

      isbuf = 0

      isbuf(cpl_fields_ibuf_cdate) = cdate
      if (my_task == master_task) then
        write(stdout,*)'(send_to_coupler) cdate = ', cdate
        call flush(stdout)
      endif
      isbuf(cpl_fields_ibuf_sec) = 0

      if ( lsend_precip_fact )
     &  isbuf(cpl_fields_ibuf_precadj) = precip_fact * 1.0e6  ! send real as integer

!-----------------------------------------------------------------------
!
!     interpolate onto T-grid points and rotate on T grid
!
!-----------------------------------------------------------------------

!dbi: no interpolation is done here right now. (do it later). so, simply
      WORK3 = SBUFF_SUM(:,:,cpl_fields_o2c_u)
      WORK4 = SBUFF_SUM(:,:,cpl_fields_o2c_v)

      WORK1 = (WORK3*cos(ANGLET)+WORK4*sin(-ANGLET))/tlast_coupled
!DBI:     &       * mpercm/tlast_coupled    !hycom u,v are in m/s!
      WORK2 = (WORK4*cos(ANGLET)-WORK3*sin(-ANGLET))/tlast_coupled
!DBI:     &       * mpercm/tlast_coupled    !so no need mpercm


      n = 0
      do j=1,jj
      do i=1,ii
         n = n + 1
         sbuf(n,cpl_fields_o2c_u) = WORK1(i,j)
         sbuf(n,cpl_fields_o2c_v) = WORK2(i,j)
      enddo
      enddo


!-----------------------------------------------------------------------
!
!     convert and pack surface temperature
!     send info only on actual physical subdomain (no "ghost" or padding)
!
!-----------------------------------------------------------------------

      n = 0
      do j=1,jj
      do i=1,ii
         n = n + 1
         sbuf(n,cpl_fields_o2c_t) = 
     &       SBUFF_SUM(i,j,cpl_fields_o2c_t)/tlast_coupled + T0_Kelvin
      enddo
      enddo


!-----------------------------------------------------------------------
!
!     convert and pack salinity
!     note that salt_to_ppt was not used by Dave Bi (not needed)
!
!-----------------------------------------------------------------------

      n = 0
      do j=1,jj
      do i=1,ii
         n = n + 1
         sbuf(n,cpl_fields_o2c_s) = 
     &       SBUFF_SUM(i,j,cpl_fields_o2c_s)/tlast_coupled  
      enddo
      enddo




!dbi........ following are comments from axh's code.....................
      !*** Coupler assumes all variables are on T points
      !*** If you want to trick the coupler and pass through
      !***  stuff at U points, comment the sw4pt calls and uncomment
      !***  lines assigning GRADP to WORK3,4
      !***  and make sure the ice model has made the same assumptions.
!dbi................change needed in ice model ?........................

!-----------------------------------------------------------------------
!
!     interpolate onto T-grid points, then rotate on T grid
!
!-----------------------------------------------------------------------
!
!dbi:...................................................................
      WORK3 = SBUFF_SUM(:,:,cpl_fields_o2c_dhdx)
      WORK4 = SBUFF_SUM(:,:,cpl_fields_o2c_dhdy)
!DBI: grav = 9.806 m/s**2 is defined in ccsm3
      WORK1 = (WORK3*cos(ANGLET) + WORK4*sin(-ANGLET))
     &        /grav/tlast_coupled
      WORK2 = (WORK4*cos(ANGLET) - WORK3*sin(-ANGLET))
     &        /grav/tlast_coupled

      n = 0
      do j=1,jj
      do i=1,ii
         n = n + 1
         sbuf(n,cpl_fields_o2c_dhdx) = WORK1(i,j)
         sbuf(n,cpl_fields_o2c_dhdy) = WORK2(i,j)
      enddo
      enddo


!-----------------------------------------------------------------------
!
!     pack heat flux due to freezing/melting (W/m^2)
!
!-----------------------------------------------------------------------

      WORK1(:,:)=SBUFF_SUM(:,:,cpl_fields_o2c_q)
      n = 0
      do j=1,jj
      do i=1,ii
         n = n + 1
         sbuf(n,cpl_fields_o2c_q) = WORK1(i,j)
      enddo
      enddo


!dbi: is the following all right (or necessary)?
      tlast_ice = c0p
      AQICE     = c0p
      QICE      = c0p

!-----------------------------------------------------------------------
!
!     send fields to coupler
!
!-----------------------------------------------------------------------

      call cpl_interface_contractSend(cpl_fields_cplname,contractS,isbuf,sbuf)


!-----------------------------------------------------------------------
!
!     diagnostics
!
!-----------------------------------------------------------------------

      if (ldiag_cpl) then
         do k = 1,cpl_fields_o2c_total
            n = 0
            do j=1,jj
            do i=1,ii
               n = n + 1
               WORK1(i,j) = sbuf(n,k)*TAREA(i,j)
            enddo
            enddo
            call xctilr (WORK1,1,1,nbdy,nbdy,halo_ps)
            gsum = ccsm3_global_real_sum(WORK1,RCALCT)*1.0e-4
            if (my_task == master_task) then
               call cpl_fields_getField(label,k,cpl_fields_o2c_fields)
               write(stdout,1100)'ocn','send', label ,gsum
            endif
         enddo
         if (my_task == master_task) call shr_sys_flush(stdout)
      endif

1100  format ('comm_diag ', a3, 1x, a4, 1x, a8, 1x, es26.19:, 1x, a6)

      tlast_coupled = c0p

      deallocate(sbuf)



!-----------------------------------------------------------------------
      return
      end subroutine send_to_coupler

!***********************************************************************

      subroutine sum_buffer

!-----------------------------------------------------------------------
!
!     this routine accumulates sums for averaging fields to
!     be sent to the coupler
!     NOTE: DBI--the potential ice formation/melt heat flux 
!           SBUFF_SUM(:,:,cpl_fields_o2c_q) 
!           is obtained in ice_flx_to_coupler, not here!
!
!-----------------------------------------------------------------------

      implicit none

!-----------------------------------------------------------------------
!
!     local variables
!
!-----------------------------------------------------------------------

      integer :: jb, i,j
      real, dimension(imt1:imt2,jmt1:jmt2) :: uu1,vv1,tt1,ss1

      integer ::
     &  curtime			!current time level

      real :: 
     &  delt                ! time interval since last step

!-----------------------------------------------------------------------
!
!     zero buffer if this is the first time after a coupling interval
!
!-----------------------------------------------------------------------

      if (tlast_coupled == c0p) SBUFF_SUM = c0p

!-----------------------------------------------------------------------
!
!     update time since last coupling
!
!-----------------------------------------------------------------------

      delt = delt1
      curtime = k1n         !dbi: k1n ?

      tlast_coupled = tlast_coupled + delt

!DBI: NOTE--u, v at land are (maybe) set to 'huge' value which must be 
!     masked here! This -'bug'- drove me crazy for long time (hycom v0.9)!
!.........................................................................
      where (ip /= 0)
        tt1 = temp(:,:,1,curtime)
        ss1 = saln(:,:,1,curtime)
      elsewhere
        tt1 = c0p
        ss1 = c0p
      endwhere

      where (iu /= 0)
        uu1 = u(:,:,1,curtime)
      elsewhere
        uu1 = c0p
      endwhere
      where (iv /= 0)
        vv1 = v(:,:,1,curtime)
      elsewhere
        vv1 = c0p
      endwhere

!DBI: u, v should be interpolated onto T points! here we simply assume
!     U/V and T are the same 'cos I am not so sure how to do the inter-
!     polation for tiles. (we could do this via an akward approach:
!     gathering tiles onto global grid, doing the interpolation there
!     and then scattering back onto tiles, thus having T point u/v.)
!     (should not be a big problem. POP does NOT do such interpolation!) 

!-----------------------------------------------------------------------
!
!     accumulate sums of U,V,T,S and GRADP
!     ice formation flux is handled separately in ice routine
!
!-----------------------------------------------------------------------


      do j=1,jj
      do i=1,ii
      SBUFF_SUM(i,j,cpl_fields_o2c_u) = SBUFF_SUM(i,j,cpl_fields_o2c_u) + 
     &                                  delt*uu1(i,j)

      SBUFF_SUM(i,j,cpl_fields_o2c_v) = SBUFF_SUM(i,j,cpl_fields_o2c_v) + 
     &                                  delt*vv1(i,j)

      SBUFF_SUM(i,j,cpl_fields_o2c_t) = SBUFF_SUM(i,j,cpl_fields_o2c_t ) + 
     &                                  delt*tt1(i,j)

      SBUFF_SUM(i,j,cpl_fields_o2c_s) = SBUFF_SUM(i,j,cpl_fields_o2c_s ) + 
     &                                  delt*ss1(i,j)

      SBUFF_SUM(i,j,cpl_fields_o2c_dhdx) = SBUFF_SUM(i,j,cpl_fields_o2c_dhdx) + 
     &                                     delt*dhdx(i,j)

      SBUFF_SUM(i,j,cpl_fields_o2c_dhdy) = SBUFF_SUM(i,j,cpl_fields_o2c_dhdy) + 
     &                                     delt*dhdy(i,j)
      enddo ! j
      enddo ! i


!     if (my_task == master_task) then
!      write(stdout,*)'(sum_buffer) end subroutine'
!       call flush(stdout)
!     endif


!-----------------------------------------------------------------------
      return
      end subroutine sum_buffer

!***********************************************************************

      subroutine ssh(m)

      implicit none

      integer         :: m

c
c --- calculate gradient of ssh, note that srfhgt is in pressure units (m * g)
c

      integer         :: i,j
      real            :: ssh_n,ssh_s,ssh_e,ssh_w
!DBI:
      real, dimension(itdm,jtdm) :: bchk

      call xctilr(srfhgt,1,1, 1,1, halo_ps)

      do j=1,jj
        do i=1,ii
          if     (ip(i,j).eq.1) then
            if     (ip(i+1,j)  .eq.1) then
              ssh_e = srfhgt(i+1,j)
            else
              ssh_e = srfhgt(i,  j)
            endif
            if     (ip(i-1,j)  .eq.1) then
              ssh_w = srfhgt(i-1,j)
            else
              ssh_w = srfhgt(i,  j)
            endif
            if     (ip(i,  j+1).eq.1) then
              ssh_n = srfhgt(i,  j+1)
            else
              ssh_n = srfhgt(i,  j)
            endif
            if     (ip(i,  j-1).eq.1) then
              ssh_s = srfhgt(i,  j-1)
            else
              ssh_s = srfhgt(i,  j)
            endif
            dhdx(i,j)=(ssh_e-ssh_w)/(scux(i+1,j)+scux(i,j))
            dhdy(i,j)=(ssh_n-ssh_s)/(scvy(i,j+1)+scvy(i,j))
          else
            dhdx(i,j)=0.0
            dhdy(i,j)=0.0
          endif
        enddo !i
      enddo !j

!DBI: check global domain:
      IF (.false. .and. nstep == 72) THEN
      call xcaget(bchk,srfhgt,0)
      if (mnproc == 1) then
        write(501,'(10e13.5)')bchk
        call flush(501)
      endif
      call xcaget(bchk,dhdx,0)
      if (mnproc == 1) then
        write(502,'(10e13.5)')bchk
        call flush(502)
      endif
      call xcaget(bchk,dhdy,0)
      if (mnproc == 1) then
        write(503,'(10e13.5)')bchk
        call flush(503)
      endif
      ENDIF

!-----------------------------------------------------------------------
      return
      end subroutine ssh



!***********************************************************************

!-----------------------------------------------------------------------
!
!     the following part of this module currently contains routines for 
!     computing ice 
!     formation and the heat flux associated with ice formation.
!     this heat flux is sent to the ice model via the flux coupler.
!
!		revised from (pop) ice.F 
!-----------------------------------------------------------------------

!***********************************************************************

!DBI: this subroutine may not be needed for hycom, leave it here anyway!
      subroutine init_ice

!-----------------------------------------------------------------------
!
!     this routine initializes ice variables.  it must be called
!     before initializing restarts because turning the ice on adds
!     an additional 2-d field to the restart file.
!
!-----------------------------------------------------------------------

!dbi      integer (kind=int_kind) :: nml_error  ! namelist i/o error flag
      integer :: nml_error  ! namelist i/o error flag

!dbi      character (char_len) ::
      character (len=80) ::
     &  ice_freq_opt        ! option for frequency of computing ice

!dbi      integer (kind=int_kind) ::
      integer ::
     &  ice_freq_iopt       ! int option for freq units
     &, ice_freq            ! freq for computing ice in above units

!dbi      namelist /ice_nml/ kmxice, sea_ice_salinity,
!dbi     &                   ice_freq_opt, ice_freq, lactive_ice
!dbi
!-----------------------------------------------------------------------
!
!     read input namelists
!
!-----------------------------------------------------------------------

      kmxice           = 1
!dbi      sea_ice_salinity =  4.0_dbl_kind
      sea_ice_salinity =  4.0
      ice_freq_opt     = 'never'
      ice_freq         = 100000
      lactive_ice      = .true.

      if (my_task == master_task) then


        !***
        !*** define salice and salref in msu
        !***
 
        salice = sea_ice_salinity*ppt_to_salt
        salref = ocn_ref_salinity*ppt_to_salt

        liceform = .true.

        select case (ice_freq_opt)
        case ('never')
          liceform = .false.
          ice_freq_iopt = freq_opt_never
        case ('coupled')
          ice_freq_iopt = freq_opt_never ! check coupler flag instead
        case ('nyear')
          ice_freq_iopt = freq_opt_nyear
        case ('nmonth')
          ice_freq_iopt = freq_opt_nmonth
        case ('nday')
          ice_freq_iopt = freq_opt_nday
        case ('nhour')
          ice_freq_iopt = freq_opt_nhour
        case ('nsecond')
          ice_freq_iopt = freq_opt_nsecond
        case ('nstep')
          ice_freq_iopt = freq_opt_nstep
        case default
          ice_freq_iopt = -1000
        end select

      endif

      call broadcast_scalar (ice_freq_iopt,    master_task)
      call broadcast_scalar (sea_ice_salinity, master_task)
      call broadcast_scalar (liceform,         master_task)
      call broadcast_scalar (ice_freq,         master_task)
      call broadcast_scalar (lactive_ice,      master_task)

      if (ice_freq_iopt == -1000) then
        call ccsm3_exit_HYCOM('unknown restart frequency option')
      endif

!-----------------------------------------------------------------------
!
!     if ice turned on, broadcast remaining vars and allocate memory
!
!-----------------------------------------------------------------------

      if (liceform) then
        call broadcast_scalar(kmxice,   master_task)
        call broadcast_scalar(salice,   master_task)
        call broadcast_scalar(salref,   master_task)
 

        !***
        !*** must keep track of time since last ice flux computed
        !***

        tlast_ice = c0p

        !***
        !*** allocate and initialize ice flux arrays
        !***


        QICE  = c0p
        AQICE = c0p
        QFLUX = c0p

      endif

!-----------------------------------------------------------------------

      end subroutine init_ice

!***********************************************************************

!dbi      subroutine ice_formation(SHF_IN, lfw_as_salt_flx)
!DBI:      subroutine ice_formation(SHF_IN)

      subroutine ice_formation(k1n, ice_ts)   !k1n might not goog here!

!-----------------------------------------------------------------------
!
!     this subroutine computes ocean heat flux to the sea-ice. it forms
!     the necessary ice in the ocean and adjusts the potential 
!     temperature and salinity fields accordingly. the logic of this 
!     subroutine is based on William Large''s 1-d model and is based
!     on a version from the NCOM model written by Gokhan Danabasoglu. 
!
!-----------------------------------------------------------------------

      implicit none

!-----------------------------------------------------------------------
!
!     input variables
!
!-----------------------------------------------------------------------

!DBI?
!      real, dimension(imt1:imt2,jmt1:jmt2), intent(in) ::
!     &  SHF_IN              ! surface heat flux
      integer :: 
     &  newtime
     & ,curtime
!DBI:
      logical :: ice_ts
      integer :: k1n

!-----------------------------------------------------------------------
!
!     local variables
!
!-----------------------------------------------------------------------

      integer :: 
     &  k                   ! vertical level index

      real, dimension(imt1:imt2,jmt1:jmt2) ::
     &  POTICE,             ! potential amt of ice formation
     &  WORK1               ! work array
     & ,WORK2

!DBI:
      real, dimension(itdm,jtdm) :: bchk
      real, dimension(imt1:imt2,jmt1:jmt2) :: ttmp,stmp

      real :: time_weight
      integer :: kmxice

!DBI:
!      real, parameter ::
!     .  rho_fw = 1000.,                 !kg/m^3  (freshwater density)
!     .  rho_sw = 1025.,                 !kg/m^3  (freshwater density)
!     .  cp_sw = 4099.,                  !J/kg/deg (specific heat of sea water)
!                                        !         (i.e., spcifh)
!     .  latent_heat_fusion = 3.34e5,    !J/kg (3.34e9 erg/g)
!     .  cp_over_lhfusion = rho_sw*cp_sw/(latent_heat_fusion*rho_fw)
!----
!-----------------------------------------------------------------------
!
!     increment time since last evaluation
!     exit if this is not time to compute ice formation
!
!-----------------------------------------------------------------------

!dbi:
      time_weight = c1p		!1.0	(?)
      tlast_ice = tlast_ice + time_weight * delt1
!dbi: 
      newtime = k1n
      curtime = k1n

!     if (my_task == master_task) then
!       write(stdout,*)'(ice_formation) nstep, ice_ts = ',
!    &                  nstep, ice_ts
!       call flush(stdout)
!     endif
!-----------------------------------------------------------------------
     
      IF ( ice_ts ) THEN

!-----------------------------------------------------------------------
!
!     initialize flux to zero
!
!-----------------------------------------------------------------------
 
        QICE = c0p
        POTICE = c0p
 
!-----------------------------------------------------------------------
!
!     compute frazil ice formation for sub-surface layers. if ice
!     forms in lower layers but layers above are warm - the heat is
!     used to melt the ice. the ice formation occurs at salinity, Si.
!     this volume is replaced with an equal volume at the salinity of
!     the layer above. the total ice heat flux is accumulated. 
!
!     WARNING: unless a monotone advection scheme is in place, 
!     advective errors could lead to temps that are far below freezing
!     in some locations and this scheme will form lots of ice.
!     ice formation should be limited to the top layer (kmxice=1)
!     if the advection scheme is not monotone.
!
!-----------------------------------------------------------------------

!dbi: the following do loop is skipped because kmxice = 1	*!
!     so the 'MISTAKES' such as dp (dp/onem) are left there.......
!
        kmxice = 1
        do k=kmxice,2,-1

        !***
        !*** potice is the potential amount of ice formation 
        !*** (potice>0) or melting (potice<0) in layer k
        !***
!dbi: ... since k = 1 (only), the following "where" choice is valid 
!         for all ocean points. we may need use "where (ip /= 0) "
!         but leave it "unlimited" now .............................
!dbi         where (k <= KMT)
!dbi            POTICE = (TFRZ(TRACER(:,:,k,2,newtime))  
!dbi     &                   - TRACER(:,:,k,1,newtime)) * dz(k)
!dbi          endwhere

!dbi: ...need check units of dp (later).............................
	  POTICE = (TFRZ(saln(:,:,k,newtime))
     &                   - temp(:,:,k,newtime)) * dp(:,:,k,newtime)

        !***
        !*** if potice < 0, use the heat to melt any ice
        !*** from lower layers
        !*** if potice > 0, keep on freezing (QICE < 0)
        !***

          POTICE = max(POTICE, QICE)

        !***
        !*** adjust tracer values based on freeze/melt
        !***

!dbi .................................................................
!          TRACER(:,:,k,1,newtime) = TRACER(:,:,k,1,newtime) 
!     &                             + POTICE / dz(k)  
!
!          if ( sfc_layer_type == sfc_layer_varthick .and.
!     &         .not. lfw_as_salt_flx ) then
!            TRACER(:,:,k,2,newtime) = ( TRACER(:,:,k,2,newtime)
!     &         * (dz(k) + cp_over_lhfusion * QICE)
!     &         + cp_over_lhfusion * (TRACER(:,:,k-1,2,newtime)
!     &         * (POTICE - QICE) - salice * POTICE) ) / dz(k)
!          else
!            TRACER(:,:,k,2,newtime) = TRACER(:,:,k,2,newtime)
!     &         + (salref - salice) * POTICE * cp_over_lhfusion / dz(k)
!          endif
!dbi....................................................................

!dbi: ... some doubts here .............................................
	  temp(:,:,k,newtime) = temp(:,:,k,newtime) 
     &				+ POTICE / dp(:,:,k,newtime)
	  saln(:,:,k,newtime) = saln(:,:,k,newtime)
     &				+ (salref - salice) * POTICE 
     &				* cp_over_lhfusion / dp(:,:,k,newtime)

          QICE = QICE - POTICE  ! accumulate freezing potential

        enddo    !nothing done above

!-----------------------------------------------------------------------
!
!     now repeat the above algorithm for the surface layer. when fresh
!     water flux formulation is used, the surface layer does not get
!     any salt from other layers. instead, its volume changes. 
!
!-----------------------------------------------------------------------

        k = 1
        newtime = k1n
        curtime = k1n
      
!DBI: check SST/SSS before ice forms:.....................
        if (.false.) then
        call xcaget(bchk,temp(:,:,k,newtime),0)
        if (mnproc == 1) then
          write(701,*) 'SST before ice formation: '
          write(701,'(10e13.5)')bchk
          call flush(701)
        endif
        !
        call xcaget(bchk,saln(:,:,k,newtime),0)
        if (mnproc == 1) then
          write(702,*) 'SSS before ice formation: '
          write(702,'(10e13.5)')bchk
          call flush(702)
        endif
        endif
!.........................................................

	WORK1 = dp(:,:,k,newtime)/onem            !layer thickness in [m]
        !DBI: note dp is in units of [kg/m/s^2], onem (ie., 1 m) = 9806. 
        !     [kg/m/s^2]. WORK1 thus gives layer thickness in [m]

!DBI:	POTICE = (TFRZ(saln(:,:,k,newtime))
!DBI:     &		 - temp(:,:,k,newtime)) * WORK1 
        !
        POTICE = (freeze - temp(:,:,k,newtime)) * WORK1
        POTICE = max(POTICE, QICE)

!DBI:   adjust surface temperature and salinity accordingly: 
        !don't do land points where dp=0!   
        ttmp(:,:) = temp(:,:,k,newtime)
        stmp(:,:) = saln(:,:,k,newtime)
        where (ip /= 0)
	!temp(:,:,k,newtime) = temp(:,:,k,newtime) + POTICE / WORK1
        ttmp = ttmp + POTICE / WORK1
	!saln(:,:,k,newtime) = saln(:,:,k,newtime)
        stmp = stmp 
     .          + (ocn_ref_salinity-ice_ref_salinity) * 0.001 !(to g/g)
     .          * POTICE * cp_over_lhfusion / WORK1
        endwhere
        temp(:,:,k,newtime) = ttmp
        saln(:,:,k,newtime) = stmp
        QICE = QICE - POTICE

!-----------------------------------------------------------------------
!
!     let any residual heat in the upper layer melt previously 
!     formed ice
!
!-----------------------------------------------------------------------
 
        AQICE = AQICE + time_weight * QICE

!-----------------------------------------------------------------------
!
!     recalculate freezing potential based on adjusted T.
!     only interested in melt potential now (POTICE < 0) - use this 
!     melt to offset any accumulated freezing (AQICE < 0) and
!     adjust T and S to reflect this melting. when freshwater flux
!     formulation, compute the associated freshwater flux instead of
!     adjusting S.
!
!-----------------------------------------------------------------------

!DBI	POTICE = (TFRZ(saln(:,:,k,newtime))
!     &		 - temp(:,:,k,newtime)) * WORK1

        POTICE = (freeze - temp(:,:,k,newtime)) * WORK1

        POTICE = max(POTICE, AQICE)

        ttmp(:,:) = temp(:,:,k,newtime)
        stmp(:,:) = saln(:,:,k,newtime)
        where (ip /=0 )          !DBI!
        !temp(:,:,k,newtime) = temp(:,:,k,newtime) + POTICE / WORK1
        ttmp = ttmp + POTICE / WORK1
!echmod        if ( sfc_layer_type == sfc_layer_varthick .and.
!echmod      &       .not. lfw_as_salt_flx ) then
!echmod           FW_FREEZE = time_weight * min(POTICE, QICE) 
!echmod      &               * cp_over_lhfusion / dt(k)
!echmod         else
!dbi          TRACER(:,:,k,2,newtime) = TRACER(:,:,k,2,newtime)  
!dbi     &       + (salref - salice) * POTICE * cp_over_lhfusion / WORK1 
!echmod         endif

!DBI: (need check if the conversion by 0.001 is RIGHT!)
	 !saln(:,:,k,newtime) = saln(:,:,k,newtime) 
         stmp = stmp
     .          + (ocn_ref_salinity-ice_ref_salinity) * 0.001   !(?to g/g)
     .          * POTICE * cp_over_lhfusion / WORK1
        endwhere
        temp(:,:,k,newtime) = ttmp
        saln(:,:,k,newtime) = stmp
        AQICE = AQICE - time_weight * POTICE

!DBI:..................................................................
!    the following is from ice_flx_to_coupler, which, when called in
!    main routine, causes "buffer problem" (see comments there). we
!    try to move the working part of here and do the summing up when
!    time is right (ice_ts = .true.)
!-----------------------------------
      !k       = 1
      !curtime = k1n
      WORK1 = dp(:,:,1,curtime)/onem

!-----------------------------------------------------------------------
!
!     first compute the melt potential
!
!-----------------------------------------------------------------------

      WORK2 = c0p

      where ( ip /= 0 )         !ocean points
        WORK2 = (freeze - temp(:,:,k,curtime)) * WORK1
      endwhere
!-----------------------------------------------------------------------
!
!     merge the ice formation and melt potential fluxes and compute
!     QFLUX in W/m^2
!
!-----------------------------------------------------------------------

      where ( AQICE < c0p )
        QICE = -AQICE
      elsewhere
        QICE = WORK2
      endwhere

!DBI: here QICE is in [deg*m], specifh (specific heat of sea water) = 4099
!     J/kg/deg, rho_sw = 1025 kg/m^3, tlast_ice in [sec], so QFLUX is in
!     [J/m^2/s = W/m^2], as required!
      !
!     write(6,*) ' spcifh = ', spcifh
!     write(6,*) ' rho_sw = ', rho_sw
!     write(6,*) ' spcifh*rho_sw = ', spcifh*rho_sw
      QFLUX = QICE * spcifh * rho_sw / tlast_ice
      where ( ip == 0)
        QFLUX = c0p
      endwhere

!-----------------------------------------------------------------------
!
!     accumulate ice formation heat flux for time averaging
!
!-----------------------------------------------------------------------

      SBUFF_SUM(:,:,cpl_fields_o2c_q) =
     &SBUFF_SUM(:,:,cpl_fields_o2c_q) + QFLUX

!DBI: check SST/SSS after ice formation:.....................

      if (.false.) then  
        call xcaget(bchk,temp(:,:,k,newtime),0)
        if (mnproc == 1) then
          write(701,*) 'SST after ice formation: '
          write(701,'(10e13.5)')bchk
          call flush(701)
        endif
        !
        call xcaget(bchk,saln(:,:,k,newtime),0)
        if (mnproc == 1) then
          write(702,*) 'SSS after ice formation: '
          write(702,'(10e13.5)')bchk
          call flush(702)
        endif
        stop
      endif
!.........................................................


!......................................................................

      ENDIF      !(ice_ts) T/S adjustment associated with ice formation.
                 ! and now also do the potential heatflux sum-up which
                 ! used to be done in ice_flx_to_coupler.
!-----------------------------------------------------------------------
      return
      end subroutine ice_formation

!***********************************************************************

      subroutine ice_flx_to_coupler

!-----------------------------------------------------------------------
!
!     this subroutine sets up the ice formation / melting potential
!     heat fluxes to be sent to the coupler. ice formation heat flux
!     is accumulated for time averaging.
!
!-----------------------------------------------------------------------

      implicit none

!-----------------------------------------------------------------------
!
!     local variables
!
!-----------------------------------------------------------------------

      integer :: 
     &  k                   ! vertical level index

      real, dimension(imt1:imt2,jmt1:jmt2) ::
     &  WORK1, WORK2        ! work arrays
     . ,btmp          !DBI:

      integer ::
     &  curtime

!DBI:
      !real, parameter :: rho_sw = 1025.     !sea water density in kg/m^3

!-----------------------------------------------------------------------
!
!     compute the first layer thickness
!
!-----------------------------------------------------------------------

!DBI:
      curtime = k1n	!????

      if (mnproc == 1) then
        write(stdout,*)'(ice_flx_to_coupler) k1n = ',k1n
        call flush(stdout)
      endif

      IF (.false.) THEN          !does the following cause the problem of
                                 !"User pack or receive buffer is too small"
                                 !when main calls hybgen?

      k = 1 

      WORK1 = dp(:,:,k,curtime)/onem

!-----------------------------------------------------------------------
!
!     first compute the melt potential
!
!-----------------------------------------------------------------------

      WORK2 = c0p
      btmp = temp(:,:,k,curtime)

      where ( ip /= 0 )		!ocean points
!DBI:	WORK2 = (TFRZ(saln(:,:,k,curtime)) - temp(:,:,k,curtime)) * WORK1
!        WORK2 = (freeze - temp(:,:,k,curtime)) * WORK1
        WORK2 = (freeze - btmp) * WORK1
      endwhere
!-----------------------------------------------------------------------
!
!     adjust ice formation amount when mixing step is tavg
!
!-----------------------------------------------------------------------
!dbi ... don't quite understand ...
!dbi        if ( tmix_iopt /= tmix_matsuno ) then
!dbi          AQICE = pp5 * AQICE
!dbi        endif
!
!DBI: no reason to me in the hycom case to adjust ice formation amount!
!     but in the below calculation, tlast_ice is actually 172800 (sec),
!     which is actually 2 days. Instead, in pop case tlast_ice is 86400
!     ie, 1 day. So the QFLUX is the "same".

!-----------------------------------------------------------------------
!
!     merge the ice formation and melt potential fluxes and compute
!     QFLUX in W/m^2
!
!-----------------------------------------------------------------------

      where ( AQICE < c0p ) 
        QICE = -AQICE
      elsewhere
        QICE = WORK2
      endwhere

!echmod        QFLUX = QICE / tlast_ice / hflux_factor
!DBI:      QFLUX = QICE * cp_sw*0.001 / tlast_ice 
                                    ! use fresh water density = 1.
                                    ! instead of rho_sw in hflux_f
!DBI: here QICE is in [deg*m], specifh (specific heat of sea water) = 4099 
!     J/kg/deg, rho_sw = 1025 kg/m^3, tlast_ice in [sec], so QFLUX is in 
!     [J/m^2/s = W/m^2], as required!
      !
      QFLUX = QICE * spcifh * rho_sw / tlast_ice
      where ( ip == 0)
        QFLUX = c0p
      endwhere

!-----------------------------------------------------------------------
!
!     accumulate ice formation heat flux for time averaging
!
!-----------------------------------------------------------------------

      SBUFF_SUM(:,:,cpl_fields_o2c_q) = 
     &SBUFF_SUM(:,:,cpl_fields_o2c_q) + QFLUX

!DBI: the above operation takes place twice per day. should we average 
!     them?--------back here later to think about the logic!

!-----------------------------------------------------------------------

      ENDIF

      return
      end subroutine ice_flx_to_coupler

!***********************************************************************

      function TFRZ(SALT)

!-----------------------------------------------------------------------
!
!     this function computes the freezing point of salt water
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
!     input variables
!
!-----------------------------------------------------------------------

      real, dimension(imt1:imt2,jmt1:jmt2), intent(in) ::
     &  SALT                ! salinity in model units (g/g)

!-----------------------------------------------------------------------
!
!     output variable
!
!-----------------------------------------------------------------------

      real, dimension(imt1:imt2,jmt1:jmt2) ::
     &  TFRZ                ! freezing temperature of water in deg C

!-----------------------------------------------------------------------
!
!     use only the first salinity term in the expansion
!
!-----------------------------------------------------------------------

c     TFRZ = -0.0544_dbl_kind*SALT*salt_to_ppt
      TFRZ = -1.8

!      TFRZ = min(-0.054_dbl_kind*SALT*salt_to_ppt,-eps2)   ! echmod

!-----------------------------------------------------------------------

      end function TFRZ

!***********************************************************************

      function TMLT(SALT)

!-----------------------------------------------------------------------
!
!     this function sets the melting point temperature of ice.
!     for now, TMLT is a separate function than TFRZ.
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
!     input variable
!
!-----------------------------------------------------------------------

      real, dimension(imt1:imt2,jmt1:jmt2), intent(in) ::
     &  SALT                ! salinity in model units (g/g)

!-----------------------------------------------------------------------
!
!     output variable
!
!-----------------------------------------------------------------------

      real, dimension(imt1:imt2,jmt1:jmt2) ::
     &  TMLT                ! melting temperature in deg C

      if ( lactive_ice ) then
	TMLT = c0p
      else
        TMLT = TFRZ(SALT)
      endif

      end function TMLT


!***********************************************************************

      end module  ccsm3_forcing

!***********************************************************************
