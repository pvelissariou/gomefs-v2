/*
** Include file "cppdefs.h"
*/

#if defined ROMS_HEADER
# include ROMS_HEADER
#else
   CPPDEFS - Choose an appropriate GOMSYS application.
#endif

/*
**  Include internal CPP definitions.
*/

#include "globaldefs.h"

#ifdef INWAVE_MODEL
#include "../InWave/Include/inwave.h"
#endif
