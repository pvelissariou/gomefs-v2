!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

      module ccsm3_exit

!***********************************************************************
!
!     this module provides a means for a graceful exit from HYCOM when
!     encountering an error.  it contains only the routine ccsm3_exit_HYCOM
!
!
!-----------------------------------------------------------------------

      use ccsm3               ! ccsm3 ocean
      use ccsm3_constants     ! ccsm3 ocean constants
      use cpl_contract_mod    ! ccsm3 cpl6 communication
      use cpl_interface_mod   ! ccsm3 cpl6 communication
      use cpl_fields_mod      ! ccsm3 cpl6 communication
      use shr_sys_mod         ! ccsm3 shared systems routines
      use shr_msg_mod         ! ccsm3 shared message-passing 

      implicit none

      contains


!***********************************************************************

      subroutine ccsm3_exit_HYCOM(exit_message, normal_exit)

!-----------------------------------------------------------------------
!
!     this routine prints a message, exits any message environment
!     and cleans up before stopping
!
!     if this is NOT a normal exit (eg, anything other than successful 
!      completion at the end of program pop), then call mpi_abort
!      if running in a coupled environment.
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
!     input variables
!
!-----------------------------------------------------------------------

      character (*)                 :: exit_message ! message to print 
      logical, optional, intent(in) :: normal_exit


!-----------------------------------------------------------------------
!
!     local variables
!
!-----------------------------------------------------------------------

      integer :: ierr                        ! error flag
      logical :: call_mpi_abort              ! if .t., call mpi_abort
     &,          present_normal_exit         ! .t. if normal_exit is 
                                             ! present

!--------------------------------------------------------
!     finalize memory-statistics code
!--------------------------------------------------------
!     call summary()

!-----------------------------------------------------------------------
!     print message
!-----------------------------------------------------------------------
      if (my_task == master_task) then
        write (6,1000)
        write (6,*)
        write (6,*) 'HYCOM exiting...'
        write (6,*) exit_message
        write (6,*) 'normal_exit = ', normal_exit
        write (6,*)
        write (6,1000)
        call shr_sys_flush(6)
 1000   format(72('-'))
      endif

!-----------------------------------------------------------------------
!
!     abort if this is an error exit
!    
!-----------------------------------------------------------------------

      present_normal_exit = present(normal_exit)

      if (present_normal_exit) then
         call_mpi_abort = .not. normal_exit
      else
         call_mpi_abort = .true.
      endif

      if (call_mpi_abort) then
         call mpi_barrier(MPI_COMM_OCN,ierr)
         ierr = 13
         call mpi_abort(0,ierr)
      endif

!-----------------------------------------------------------------------
!
!     exit the message-passing environment if required (cpl6 version)
!    
!-----------------------------------------------------------------------


      call cpl_interface_finalize(cpl_fields_ocnname)

!-----------------------------------------------------------------------
!
!     now we can stop
!
!-----------------------------------------------------------------------

      stop



      end subroutine ccsm3_exit_HYCOM

!***********************************************************************


      end module ccsm3_exit

!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

