#!/bin/csh
#
#BSUB -J        Make_ccsm3_new
#BSUB -o        Make_ccsm3_new.log
#BSUB -e        Make_ccsm3_new.log
#BSUB -W        12:00
#BSUB -P        NRLSS018
#BSUB -q        share
#BSUB -n        1
#
set echo
cd $cwd
#
# --- Usage:  ./Make_ccsm3_new.com >& Make_ccsm3_new.log
#
# --- Copy files to this directory and make CCSM3 version of HYCOM
#
foreach f ( archiv barotp bigrid cnuity convec diapfl dpthuv dpudpv forfun hybgen icloan inicon inigiss inikpp inimy latbdy matinv momtum mxkprf mxkrt mxkrtm mxpwp overtn poflat prtmsk psmoo restart trcupd tsadvc )
 cp ../${f}.f ${f}.F
end
foreach f ( blkdat.F common_blocks.h dimensions.h geopar.F hycom.F isnan.F machine.F machi_c.c mod_dimensions.F mod_floats.F mod_hycom.F mod_incupd.F mod_pipe.F mod_tides.F mod_mean.F mod_xc.F mod_xc_mp.h mod_xc_sm.h mod_za.F mod_za_mp.h mod_za_mp1.h mod_za_sm.h mod_za_zt.h stmt_fns.h unit_offset.h wtime.F )
  cp ../${f} .
end
#
# --- some machines require gmake
#
#gmake -f Makefile_ccsm3 hycom
make -f Makefile_ccsm3 hycom
