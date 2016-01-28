/*
** Include file "globaldef.h"
**
*******************************************************************************
**                                                                           **
** WARNING: This  file  contains  a set of  predetermined macro definitions  **
** =======  which are inserted into the individual files by C-preprocessor.  **
** It is strongly recommended to NOT modify any of the definitions below.    **
**                                                                           **
*******************************************************************************
*/

/*
** Undefine all un-supported models in this configuration.
*/
#undef  ROMS_MODEL

/*
** Set assumed-shape array switch.  Imported arrays with dummy
** arguments that takes the shape of the actual argument passed
** to it.  If off, all the arrays are explicit-shape.  In some
** computer explicit-shape arrays slow down performacnce because
** the arrays are copied when passed by arguments.
*/

#if !((defined G95 && defined I686) || defined UNICOS_SN)
# define ASSUMED_SHAPE
#endif

/*
** Set switch for computer lacking 4-byte (32 bit) floating point
** representation, like some Crays.  This becomes important when
** defining attributes for 4-byte float variables in NetCDF files.
** We need to have the _FillValue attribute of the same type as
** as the NetCDF variable.
*/

#if defined UNICOS_SN
# define NO_4BYTE_REALS
#endif

/*
** Set internal distributed-memory switch.
*/

#if defined MPI
# define DISTRIBUTE
#endif

/*
** Turn ON/OFF time profiling.
*/

#define PROFILE

/*
** Turn ON/OFF double precision for real type variables and
** associated intrinsic functions.
*/

#define DOUBLE_PRECISION

/*
** Turn ON masking when wetting and drying is activated.
*/

#if !defined MASKING && defined WET_DRY
# define MASKING
#endif

/*
** Remove OpenMP directives in serial and distributed memory
** Applications.  This definition will be used in conjunction with
** the pearl script "cpp_clean" to remove the full directive.
*/

#if !defined _OPENMP
# define $OMP !
#endif

/*
** Choice of double/single precision for real type variables and
** associated intrinsic functions.
*/

#if (defined CRAY || defined CRAYT3E) && !defined CRAYX1
# ifdef  DOUBLE_PRECISION
#  undef  DOUBLE_PRECISION
# endif
#endif

/*
** Define internal option to couple to other models.
**
*/

#if defined HYCOM_MODEL && (defined SWAN_MODEL || defined WRF_MODEL)
# define HYCOM_COUPLING
#endif
#if defined SWAN_MODEL && (defined HYCOM_MODEL || defined WRF_MODEL)
# define SWAN_COUPLING
#endif
#if defined WRF_MODEL && (defined SWAN_MODEL || defined HYCOM_MODEL)
# define WRF_COUPLING
#endif

#if defined WRF_COUPLING && defined HYCOM_COUPLING
# define AIR_OCEAN
#endif

#if defined WRF_COUPLING && defined SWAN_COUPLING
# define AIR_WAVES
#endif

#if (defined REFDIF_COUPLING || defined SWAN_COUPLING) && \
     defined HYCOM_COUPLING
# define WAVES_OCEAN
#endif

#if defined AIR_OCEAN || defined AIR_WAVES || defined WAVES_OCEAN
# define COAWST_COUPLING
#endif

#if defined COAWST_COUPLING && defined NESTING
# if defined WAVES_OCEAN
#  define MCT_INTERP_OC2WV
# endif
# if defined AIR_OCEAN
#  define MCT_INTERP_OC2AT
# endif
# ifdef AIR_WAVES
#  define MCT_INTERP_WV2AT
# endif
#endif
