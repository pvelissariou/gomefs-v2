#!/bin/csh
#
set echo
cd $cwd
#
# --- Usage:  ./diff_ccsm3.com >& diff_ccsm3.log
#
# --- Difference between CCSM3 and standard source code (should be none).
#
foreach f ( archiv barotp bigrid cnuity convec diapfl dpthuv dpudpv forfun hybgen icloan inicon inigiss inikpp inimy latbdy matinv momtum mxkprf mxkrt mxkrtm mxpwp overtn poflat prtmsk psmoo restart trcupd tsadvc )
  echo "*****     *****     *****     *****     *****     *****     *****"
  diff -bwi ${f}.F ../${f}.f
end
foreach f ( blkdat.F common_blocks.h dimensions.h geopar.F hycom.F isnan.F machine.F machi_c.c mod_dimensions.F mod_floats.F mod_hycom.F mod_incupd.F mod_pipe.F mod_tides.F mod_xc.F mod_xc_mp.h mod_xc_sm.h mod_za.F mod_za_mp.h mod_za_mp1.h mod_za_sm.h stmt_fns.h unit_offset.h wtime.F )
  echo "*****     *****     *****     *****     *****     *****     *****"
  diff -bwi ${f} ../${f}
end
