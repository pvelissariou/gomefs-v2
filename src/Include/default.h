/*
** Include file "cppdefs.h"
*/

/*===== MODELS to USE =====*/
#define WRF_MODEL

/*#define  SWAN_MODEL*/

/*#define ESMF_LIB*/


/*===== DEFINE MCT COUPLING PARAMETERS =====*/
#if defined WRF_MODEL && defined SWAN_MODEL
#  define MCT_LIB
#  define MCT_INTERP_WV2AT
#endif
