      module mod_dimensions
c
c     module needed for CCSM3 integration
c
#if defined(MPI)
      include 'dimensions.h'
#else
      include 'dimensions_one.h'
#endif
      end module mod_dimensions
