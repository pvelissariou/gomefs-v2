!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

      module ccsm3_global_reductions

!***********************************************************************
!
!     This module contains all the mpi versions of the global
!     reduction routines needed for the ccsm3 ocean communications
!
!
!-----------------------------------------------------------------------

      use ccsm3

#if defined(REAL4)
# define MTYPER mpi_real4
#else /* REAL8 */
# define MTYPER mpi_real8
#endif


      implicit none


!-----------------------------------------------------------------------
!
!     generic interfaces for module procedures
!
!-----------------------------------------------------------------------

      interface broadcast_scalar
        module procedure broadcast_scalar_real,
     &                   broadcast_scalar_int,
     &                   broadcast_scalar_log,
     &                   broadcast_scalar_char
      end interface

      interface broadcast_vector
        module procedure broadcast_vector_real,
     &                   broadcast_vector_int,
     &                   broadcast_vector_log
      end interface

      contains

      subroutine broadcast_scalar_real(scalar, root_pe)

      implicit none

!-----------------------------------------------------------------------
!
!     broadcasts a scalar real variable from one processor (root_pe)
!     to all other processors.
!
!-----------------------------------------------------------------------

      include 'mpif.h'  ! MPI Fortran include file

      integer, intent(in) ::
     &   root_pe              ! processor number to broadcast from

      real, intent(inout) ::
     &   scalar               ! scalar to be broadcast

      integer :: ierr  ! local MPI error flag

!-----------------------------------------------------------------------

      call MPI_BCAST(scalar, 1, MPI_DOUBLE_PRECISION, root_pe,
     &                       MPI_COMM_OCN, ierr)
      call MPI_BARRIER(MPI_COMM_OCN, ierr)

!-----------------------------------------------------------------------

      end subroutine broadcast_scalar_real


!***********************************************************************

      subroutine broadcast_scalar_int(scalar, root_pe)

      implicit none

!-----------------------------------------------------------------------
!
!     broadcasts a scalar integer variable from one processor (root_pe)
!     to all other processors.
!
!-----------------------------------------------------------------------

      include 'mpif.h'  ! MPI Fortran include file

      integer, intent(in) ::
     &    root_pe              ! processor number to broadcast from

      integer, intent(inout) ::
     &   scalar                ! scalar to be broadcast

      integer :: ierr  ! local MPI error flag

!-----------------------------------------------------------------------

      call MPI_BCAST(scalar, 1, MPI_INTEGER, root_pe,
     &                       MPI_COMM_OCN, ierr)
      call MPI_BARRIER(MPI_COMM_OCN, ierr)

!-----------------------------------------------------------------------

      end subroutine broadcast_scalar_int

!***********************************************************************

      subroutine broadcast_scalar_log(scalar, root_pe)

      implicit none

!-----------------------------------------------------------------------
!
!     broadcasts a scalar logical variable from one processor (root_pe)
!     to all other processors.
!
!-----------------------------------------------------------------------

      include 'mpif.h'  ! MPI Fortran include file

      integer, intent(in) ::
     &    root_pe              ! processor number to broadcast from

      logical, intent(inout) ::
     &   scalar                ! scalar to be broadcast

      integer ::
     &    reduce_int,          ! local temporary
     &    ierr                 ! MPI error flag

!-----------------------------------------------------------------------

      if (scalar) then
        reduce_int = 1
      else
        reduce_int = 0
      endif

      call MPI_BCAST(reduce_int, 1, MPI_INTEGER, root_pe,
     &                       MPI_COMM_OCN, ierr)
      call MPI_BARRIER(MPI_COMM_OCN, ierr)

      if (reduce_int .eq. 1) then
        scalar = .true.
      else
        scalar = .false.
      endif

!-----------------------------------------------------------------------

      end subroutine broadcast_scalar_log

!***********************************************************************

      subroutine broadcast_scalar_char(scalar, root_pe)

      implicit none

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
!     broadcasts a scalar character variable from one processor
!     (root_pe) to all other processors.
!
!-----------------------------------------------------------------------

      include 'mpif.h'  ! MPI Fortran include file

      integer, intent(in) ::
     &    root_pe              ! processor number to broadcast from

      character (*), intent(inout) ::
     &   scalar                ! scalar to be broadcast

      integer ::
     &    clength              ! length of character
     &,   ierr                 ! MPI error flag

!-----------------------------------------------------------------------

      clength = len(scalar)

      call MPI_BCAST(scalar, clength, MPI_CHARACTER, root_pe,
     &                       MPI_COMM_OCN, ierr)
      call MPI_BARRIER(MPI_COMM_OCN, ierr)

!-----------------------------------------------------------------------

      end subroutine broadcast_scalar_char

!***********************************************************************

      subroutine broadcast_vector_real(vector, root_pe, nelements)

      implicit none

!-----------------------------------------------------------------------
!
!     broadcasts a vector of real variables from one processor (root_pe)
!     to all other processors.
!
!-----------------------------------------------------------------------

      include 'mpif.h'  ! MPI Fortran include file

      integer, intent(in) ::
     &    root_pe,             ! processor number to broadcast from
     &    nelements            ! size of vector to be broadcast

      real, dimension(nelements), intent(inout) ::
     &    vector               ! vector to be broadcast

      integer :: ierr ! local MPI error flag

!-----------------------------------------------------------------------

      call MPI_BCAST(vector, nelements, MPI_DOUBLE_PRECISION, root_pe,
     &                       MPI_COMM_OCN, ierr)
      call MPI_BARRIER(MPI_COMM_OCN, ierr)

!-----------------------------------------------------------------------

      end subroutine broadcast_vector_real


!***********************************************************************

      subroutine broadcast_vector_int(vector, root_pe, nelements)

      implicit none

!-----------------------------------------------------------------------
!
!     broadcasts a vector of integer variables from one processor
!     (root_pe) to all other processors.
!
!-----------------------------------------------------------------------

      include 'mpif.h'  ! MPI Fortran include file

      integer, intent(in) ::
     &    root_pe,             ! processor number to broadcast from
     &    nelements            ! size of vector to be broadcast

      integer, dimension(nelements), intent(inout) ::
     &    vector               ! vector to be broadcast

      integer :: ierr ! local MPI error flag

!-----------------------------------------------------------------------

      call MPI_BCAST(vector, nelements, MPI_INTEGER, root_pe,
     &                       MPI_COMM_OCN, ierr)
      call MPI_BARRIER(MPI_COMM_OCN, ierr)

!-----------------------------------------------------------------------

      end subroutine broadcast_vector_int

!***********************************************************************

      subroutine broadcast_vector_log(vector, root_pe, nelements)

      implicit none

!-----------------------------------------------------------------------
!
!     broadcasts a vector of logical variables from one processor
!     (root_pe) to all other processors.
!
!-----------------------------------------------------------------------

      include 'mpif.h'  ! MPI Fortran include file

      integer, intent(in) ::
     &    root_pe,             ! processor number to broadcast from
     &    nelements            ! size of vector to be broadcast

      logical, dimension(nelements), intent(inout) ::
     &    vector               ! vector to be broadcast

      integer, dimension(nelements) ::
     &    vector_int           ! temporary vector for MPI bcast

      integer :: ierr ! local MPI error flag

!-----------------------------------------------------------------------

      where (vector)
        vector_int = 1
      elsewhere
        vector_int = 0
      end where

      call MPI_BCAST(vector_int, nelements, MPI_INTEGER, root_pe,
     &                       MPI_COMM_OCN, ierr)
      call MPI_BARRIER(MPI_COMM_OCN, ierr)

      where (vector_int == 1)
        vector = .true.
      elsewhere
        vector = .false.
      end where

!-----------------------------------------------------------------------

      end subroutine broadcast_vector_log

      function ccsm3_global_real_sum (X, MASK)

      implicit none

!-----------------------------------------------------------------------
!
!     computes the global sum of the _physical domain_ of a 2-d
!     array.
!
!-----------------------------------------------------------------------

      include 'mpif.h'  ! MPI Fortran include file

      real, dimension(imt1:imt2,jmt1:jmt2), intent(in) :: 
     &   X,                   ! array to be summed
     &   MASK                 ! real multiplicative mask

      real :: 
     &   local_sum,             ! sum of local subdomain
     &   ccsm3_global_real_sum  ! resulting global sum

      integer ::
     &   i,j,                 ! local counters
     &   ierr                 ! MPI error flag

!-----------------------------------------------------------------------

      local_sum = c0p
      do j=1,jj
        do i=1,ii
          local_sum = local_sum + X(i,j)*MASK(i,j)
        end do
      end do
     
      call MPI_ALLREDUCE(local_sum, ccsm3_global_real_sum, 1,
     &                   MTYPER, MPI_SUM, MPI_COMM_OCN, ierr) 
    
!-----------------------------------------------------------------------

      end function ccsm3_global_real_sum
      

!***********************************************************************

      end module ccsm3_global_reductions

!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
