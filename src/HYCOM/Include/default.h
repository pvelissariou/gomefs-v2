/*
** Include file "cppdefs.h"
*/

/*===== MODELS to USE =====*/
/*#define WRF_MODEL*/

#define HYCOM_MODEL

/*#define SWAN_MODEL*/

/*#define ICE_MODEL*/
/*#define DUMMY_ICE_MODEL*/

/*#define ESMF_LIB*/


/*===== DEFINE MCT COUPLING PARAMETERS =====*/
#if (defined(HYCOM_MODEL) && (defined(WRF_MODEL)  || defined(SWAN_MODEL))) || \
    (defined(WRF_MODEL)  && (defined(HYCOM_MODEL) || defined(SWAN_MODEL))) || \
    (defined(SWAN_MODEL) && (defined(HYCOM_MODEL) || defined(WRF_MODEL)))
#  define MCT_LIB
#  if defined(HYCOM_MODEL) && defined(WRF_MODEL)
#    define MCT_INTERP_OC2AT
#  endif
#  if defined(HYCOM_MODEL) && defined(SWAN_MODEL)
#    define MCT_INTERP_OC2WV
#  endif
#  if defined(WRF_MODEL) && defined(SWAN_MODEL)
#    define MCT_INTERP_WV2AT
#  endif
#endif
