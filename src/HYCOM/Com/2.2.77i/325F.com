#!/bin/csh
#PBS -N 999pbs
#PBS -j oe
#PBS -o 999pbsXX.log
#PBS -l walltime=2:00:00
#PBS -A NRLSS03755018
#PBS -q transfer
#
set echo
set time = 1
set timestamp
C
C --- Create model interpolated fluxes for HYCOM. Use linear interpolation
C --- on fluxes because they change on such short space scales.
C ---
C --- offset annual mean airtmp, radflx, shwflx.
C ---
C --- prebuild this script similar to a model script
# --- awk -f 284.awk y01=098 ab=a 284F.com > 284f098a.com
C
C --- Preamble, script keys on O/S name.
C
setenv OS `uname`
switch ($OS)
case 'SunOS':
C   assumes /usr/5bin is before /bin and /usr/bin in PATH.
    breaksw
case 'Linux':
    breaksw
case 'OSF1':
    breaksw
case 'IRIX64':
    breaksw
case 'AIX':
    breaksw
case 'unicosmk':
    setenv ACCT `groups | awk '{print $1}'`
    breaksw
case 'unicos':
    setenv ACCT `newacct -l | awk '{print $4}'`
    breaksw
default:
    echo 'Unknown Operating System: ' $OS
    exit (1)
endsw
C
C --- pget, pput "copy" files between scratch and permanent storage.
C --- Can both be cp if the permanent filesystem is mounted locally.
C
switch ($OS)
case 'SunOS':
case 'Linux':
case 'OSF1':
case 'AIX':
case 'unicos':
case 'unicosmk':
    if (-e ~wallcraf/bin/pget) then
      setenv pget ~wallcraf/bin/pget
      setenv pput ~wallcraf/bin/pput
    else
      setenv pget cp
      setenv pput cp
    endif
    breaksw
default:
    setenv pget cp
    setenv pput cp
endsw
C
C --- E is expt number.
C --- P is primary path.
C --- D is permanent directory.
C --- S is scratch   directory, must not be the permanent directory.
C --- N is data-set name, e.g. ecmwf-reanal
C --- W is permanent native pcip directory
C
setenv E 325
setenv P hycom/GOMl0.04/expt_32.5/data
setenv D ~/$P
#setenv N coamps0.2a
#setenv N nogaps0.5c
#setenv N nogaps0.5a
setenv N navgem0.5a
C
switch ($OS)
case 'SunOS':
    if (-e /net/hermes/scrb) then
#                  NRLSSC
      setenv S     /net/hermes/scrb/${user}/$P
      setenv W     /net/hermes/scrb/metzger/flux_ieee/$N
    else
#                  NAVO MSRC
      mkdir        /scr/${user}
      chmod a+rx   /scr/${user}
      setenv S     /scr/${user}/$P
      setenv W     /u/b/metzger/flux_ieee/$N
    endif
    breaksw
case 'Linux':
    if (-e /external/fast) then
#                  NRLSSC
      setenv S /external/fast/${user}/$P
      setenv W ~/flux_ieee/$N
    else if (-e /scr) then
#                  NAVO MSRC, under LoadLeveler
      mkdir        /scr/${user}
      chmod a+rx   /scr/${user}
      setenv S     /scr/${user}/$P
#      setenv W2     /u/home/metzger/force/$N/cen_amer
      setenv W2     /u/home/metzger/force/$N
#      setenv W     /u/home/metzger/force/${N}/cen_amer/
#      setenv W     /u/home/metzger/force/climo_extend/nogaps0.5a/thermal/
#      setenv W      /p/cwfs/dsfrank/force/climo_extend/nogaps0.5a/thermal/
#      setenv W     /p/cwfs/dsfrank/force/climo_extend/navgem0.5a/thermal/
      setenv W     /scr/ooc/data/hycom/preproc/force/navgem/1.2_0.5a/3hrly/climo_extend/thermal
    else
#                  Single Disk
      setenv S ~/$P/SCRATCH
      setenv W ~/flux_ieee/$N
    endif
    breaksw
case 'OSF1':
    mkdir        ~/scratch
    chmod a+rx   ~/scratch
    setenv S     ~/scratch/$P
    setenv W     /u/b/metzger/flux_ieee/$N
    breaksw
case 'IRIX64':
    mkdir        /workspace/${user}
    chmod a+rx   /workspace/${user}
    setenv S     /workspace/${user}/$P
    setenv W1    /msas031/metzger/flux_ieee/$N1
    setenv W2    /msas031/metzger/flux_ieee/$N2
    breaksw
case 'AIX':
    if (-e /gpfs/work) then
#                  ERDC MSRC
      mkdir        /gpfs/work/${user}
      chmod a+rx   /gpfs/work/${user}
      setenv S     /gpfs/work/${user}/$P
      setenv W     /u/b/metzger/flux_ieee/$N
    else if (-e /scr) then
#                  NAVO MSRC
      mkdir        /scr/${user}
      chmod a+rx   /scr/${user}
      setenv S     /scr/${user}/$P
      setenv W2     /u/home/metzger/force/$N/cen_amer
      setenv W2     /u/home/metzger/force/$N
      setenv W     /u/home/metzger/force/${N}/cen_amer
      setenv W     /u/home/metzger/force/climo_extend/nogaps0.5a/thermal
    else
#                  ARL MSRC, under GRD
      mkdir        /usr/var/tmp/${user}
      chmod a+rx   /usr/var/tmp/${user}
      setenv S     /usr/var/tmp/${user}/$P
      setenv W     /archive/navy/metzger/flux_ieee/$N
    endif
    breaksw
case 'unicos':
case 'unicosmk':
    mkdir        /tmp/${user}
    chmod a+rx   /tmp/${user}
    mkdir        /tmp/${user}/ATLd0.08
    chgrp $ACCT  /tmp/${user}/ATLd0.08
    setenv S     /tmp/${user}/$P
    setenv W     /u/b/metzger/flux_ieee/$N
    breaksw
endsw
C
mkdir -p $S/flux
cd       $S/flux
C
C --- For whole year runs.
C ---   ymx number of years per model run.
C ---   Y01 initial model year of this run.
C ---   YXX is the last model year of this run, and the first of the next run.
C ---   A and B are identical, typically blank.
C --- For part year runs.
C ---   A is this part of the year, B is next part of the year.
C ---   Y01 initial model year of this run.
C ---   YXX year at end of this part year run.
C ---   ymx is 1.
C --- Note that these variables and the .awk generating script must
C ---  be consistant to get a good run script.
C
C --- For fluxes, only Y01 and A are used.
C
C --- One year spin-up run.
C
@ ymx =  1
C
setenv A "a"
setenv B "b"
setenv Y01 "099"
C
switch ("${B}")
case "${A}":
    setenv YXX `echo $Y01 $ymx | awk '{printf("%03d", $1+$2)}'`
    breaksw
case "a":
    setenv YXX `echo $Y01 | awk '{printf("%03d", $1+1)}'`
    breaksw
default:
    setenv YXX $Y01
endsw
C
echo "Y01 =" $Y01 "YXX = " $YXX  "A =" ${A} "B =" ${B}
C
C --- time limits.
C
setenv TS `echo "LIMITS" | awk -f ${D}/../${E}.awk y01=${Y01} ab=${A} | awk '{print $1}'`
setenv TM `echo "LIMITS" | awk -f ${D}/../${E}.awk y01=${Y01} ab=${A} | awk '{print $2}'`

setenv idtg 20030101
C
echo "TS =" $TS "TM =" $TM
C
C --- input files from file server.
C
touch regional.grid.a regional.grid.b
if (-z regional.grid.b) then
  ${pget} ${D}/../../topo/regional.grid.b regional.grid.b &
endif
if (-z regional.grid.a) then
  ${pget} ${D}/../../topo/regional.grid.a regional.grid.a &
endif
C
#touch  fort.70
#if (-z fort.70) then
#  ${pget} /u/home/metzger/mask_ieee/fnmoc/nogaps_mask_360x181.D fort.70 &
#endif
C
#touch  fort.71 fort.72
#@ i = 70
#foreach y (2013 2014)
#  @ i = $i + 1
#  setenv N `echo $i | awk '{printf("%02d\n", $1)}'`
#  touch  fort.${N}
#  if (-z fort.${N}) then
#      ${pget} ${W2}/3hourly/navgem0.5a-sea_${y}_03hr_TaqaQrQp.D fort.${N} &
#  endif
#end
#
# real time
/bin/rm fort.71 fort.72
touch  fort.71 fort.72
if (-z fort.71) then
#  ${pget} ${W}/nogaps0.5a_TaqaQrQp.D fort.71 &
  /bin/cp ${W}/navgem0.5a_TaqaQrQp.D fort.71 &
endif
if (-z fort.72) then
#  ${pget} ${W}/nogaps0.5a-sea_clim_TaqaQrQp.D fort.72 &
# sec for navgem 1.2
  /bin/cp ${W}/navgem0.5a-sec_clim_TaqaQrQp.D fort.72 &
endif
#
C --- executable
C
/bin/cp /u/home/wallcraf/hycom/ALL/force/src/ap . &
/bin/cp /u/home/wallcraf/hycom/ALL/force/src/aphf_meanfit . &
wait
chmod ug+rx ap
chmod ug+rx aphf_meanfit
ls -laFq
C
C --- NAMELIST input.
C
touch   fort.05i
/bin/rm fort.05i
cat <<E-o-D  > fort.05i
 &AFTITL
  CTITLE = '1234567890123456789012345678901234567890',
  CTITLE = 'NAVGEM 0.5a, 3hrly, sea-only, MKS',
 /
 &AFTIME
  HMKS   =   1.0,          !kg/kg             to kg/kg
  RMKS   =   1.0,          !W/m**2 into ocean to W/m**2 into ocean
  PMKS   =   1.1574074E-5, !m/day  into ocean to m/s    into ocean
  BIASPC =   0.0,
  PCMEAN =   0.0,
  BIASRD =   0.0,
  RDMEAN =   0.0,
  FSTART = ${TS},
  TSTART = ${TS},
  TMAX   = ${TM},
 /
 &AFFLAG
  IFFILE =   5,  !3:monthly-climo; 5:actual-day;
  IFTYPE =   4,  !5:Ta-Ha-Qr-Qp-Pc; 4:Ta-Ha-Qr-Qp; 2:Qr; 1:Pc;
  INTERP =   0,  !0:piecewise-linear; 1:cubic-spline;
  INTMSK =   0,  !0:no mask; 1:land/sea=0/1; 2:land/sea=1/0;
 /
E-o-D
C
C --- run the flux interpolation.
C
touch fort.10 fort.10a
/bin/rm -f fort.1[0-4] fort.1[0-4]a
C
setenv FOR010A fort.10a
setenv FOR011A fort.11a
setenv FOR012A fort.12a
setenv FOR013A fort.13a
setenv FOR014A fort.14a
C
switch ($OS)
case 'SunOS':
case 'Linux':
case 'OSF1':
case 'AIX':
    /bin/rm -f core
    touch core
    ./ap < fort.05i
    breaksw
case 'IRIX64':
    /bin/rm -f core
    touch core
    assign -V
    ./ap < fort.05i
    assign -V
    assign -R
    breaksw
case 'unicosmk':
    /bin/rm -f core
    touch core
    assign -V
    ./ap < fort.05i
    if (! -z core)  debugview ap core
    assign -V
    assign -R
    breaksw
case 'unicos':
    /bin/rm -f core
    touch core
    assign -V
    ./ap < fort.05i
    if (! -z core)  debug -s ap core
    assign -V
    assign -R
    breaksw
endsw
C
C --- Output, use .A and .B if further correction is needed.
C
#/bin/mv fort.10  airtmp_${idtg}.B
#/bin/mv fort.10a airtmp_${idtg}.A
/bin/mv fort.10  airtmp_${idtg}.b
/bin/mv fort.10a airtmp_${idtg}.a
/bin/mv fort.11  vapmix_${idtg}.b
/bin/mv fort.11a vapmix_${idtg}.a
#/bin/mv fort.12  radflx_${idtg}.B
#/bin/mv fort.12a radflx_${idtg}.A
#/bin/mv fort.13  shwflx_${idtg}.B
#/bin/mv fort.13a shwflx_${idtg}.A
# no radiaton correction
/bin/mv fort.12  radflx_${idtg}.b
/bin/mv fort.12a radflx_${idtg}.a
/bin/mv fort.13  shwflx_${idtg}.b
/bin/mv fort.13a shwflx_${idtg}.a
if (-e fort.14) then
  /bin/mv fort.14  precip_${idtg}.b
  /bin/mv fort.14a precip_${idtg}.a
endif
C
C --- Annual Mean airtmp correction.
C
if (-e airtmp_${idtg}.A) then
  setenv FOR010A fort.10A
  setenv FOR020A fort.20A
  setenv FOR030A fort.30A
C
  setenv Q era40-fnmoc_clip
  /bin/rm -f fort.10 fort.10A
  /bin/rm -f fort.20 fort.20A fort.30A
  /bin/mv airtmp_${idtg}.B fort.20
  /bin/mv airtmp_${idtg}.A fort.20A
  touch  airtmp_ann_${Q}.a
  if (-z airtmp_ann_${Q}.a) then
    ${pget} ${D}/../../force/offset/airtmp_ann_${Q}.a airtmp_ann_${Q}.a
  endif
  ln -sf airtmp_ann_${Q}.a fort.30A
  ./aphf_meanfit <<'E-o-D'
 &AFMEAN
  TITLE = '1234567890123456789012345678901234567890123456789012345678901234567890123456789',
  TITLE = 'Offset to ERA40 annual mean Ta (-2 < offset < +2)',
  S1     = 1.0,  !no bias
 /
'E-o-D'
  mv fort.10  airtmp_${idtg}.b
  mv fort.10A airtmp_${idtg}.a
  /bin/rm -f fort.20 fort.20A fort.30A
endif
C
C --- Annual Mean Radiative Correction
C
if (-e radflx_${idtg}.A) then
  setenv FOR010A fort.10A
  setenv FOR011A fort.11A
  setenv FOR020A fort.20A
  setenv FOR021A fort.21A
  setenv FOR030A fort.30A
  setenv FOR031A fort.31A
C
  /bin/rm -f fort.10 fort.10A
  /bin/rm -f fort.20 fort.20A fort.30A
  /bin/rm -f fort.21 fort.21A fort.31A
  /bin/mv radflx_${idtg}.B fort.20
  /bin/mv radflx_${idtg}.A fort.20A
  /bin/mv shwflx_${idtg}.B fort.21
  /bin/mv shwflx_${idtg}.A fort.21A
C
  setenv Q fdQfnmoc
  touch  lwflux_ann_${Q}.a
  if (-z lwflux_ann_${Q}.a) then
    ${pget} ${D}/../../force/offset/lwflux_ann_${Q}.a lwflux_ann_${Q}.a &
  endif
  touch  shwflx_ann_${Q}.a
  if (-z shwflx_ann_${Q}.a) then
    ${pget} ${D}/../../force/offset/lwflux_ann_${Q}.a shwflx_ann_${Q}.a &
  endif
  wait
  ln -sf lwflux_ann_${Q}.a fort.30A
  ln -sf shwflx_ann_${Q}.a fort.31A
  ./aphf_meanfit <<'E-o-D'
 &AFMEAN
  TITLE = '1234567890123456789012345678901234567890123456789012345678901234567890123456789',
  TITLE = 'Biased to ISSCP FD annual mean Qsw and Qlw',
          'Biased to ISSCP FD annual mean Qsw',
  SOLAR  = .TRUE.,
  S0     = 0.0,  !no offset for Qlw
           0.0,  !no offset for Qsw
 /
'E-o-D'
  mv fort.10  radflx_${idtg}.b
  mv fort.10A radflx_${idtg}.a
  mv fort.11  shwflx_${idtg}.b
  mv fort.11A shwflx_${idtg}.a
  /bin/rm -f fort.20 fort.20A fort.30A
  /bin/rm -f fort.21 fort.21A fort.31A
endif
#set sizefl=`ls -la airtmp_${idtg}.a | awk '{print $5}'`
#echo ${E} GOMl0.04 ${sizefl} >! ~/${P}/wrongforcing.txt
#if ( ${sizefl} != '83312640' ) then
# mail -s 'SMALL AIRTMP FILE ' ${user} < ~/${P}/wrongforcing.txt
#endif
#set sizefl=`ls -la vapmix_${idtg}.a | awk '{print $5}'`
#echo ${E} GOMl0.04 ${sizefl} >! ~/${P}/wrongforcing.txt
#if ( ${sizefl} != '83312640' ) then
# mail -s 'SMALL VAPMIX FILE ' ${user} < ~/${P}/wrongforcing.txt
#endif
#set sizefl=`ls -la radflx_${idtg}.a | awk '{print $5}'`
#echo ${E} GOMl0.04 ${sizefl} >! ~/${P}/wrongforcing.txt
#if ( ${sizefl} != '83312640' ) then
# mail -s 'SMALL RADFLX FILE ' ${user} < ~/${P}/wrongforcing.txt
#endif
#set sizefl=`ls -la shwflx_${idtg}.a | awk '{print $5}'`
#echo ${E} GOMl0.04 ${sizefl} >! ~/${P}/wrongforcing.txt
#if ( ${sizefl} != '83312640' ) then
# mail -s 'SMALL SHWFLX FILE ' ${user} < ~/${P}/wrongforcing.txt
#endif
C
if (-e ./SAVE) then
  ln airtmp_${idtg}.a ./SAVE/airtmp_${idtg}.a
  ln airtmp_${idtg}.b ./SAVE/airtmp_${idtg}.b
  ln vapmix_${idtg}.a ./SAVE/vapmix_${idtg}.a
  ln vapmix_${idtg}.b ./SAVE/vapmix_${idtg}.b
  ln radflx_${idtg}.a ./SAVE/radflx_${idtg}.a
  ln radflx_${idtg}.b ./SAVE/radflx_${idtg}.b
  ln shwflx_${idtg}.a ./SAVE/shwflx_${idtg}.a
  ln shwflx_${idtg}.b ./SAVE/shwflx_${idtg}.b
  if (-e fort.14) then
    ln precip_${idtg}.a ./SAVE/precip_${idtg}.a
    ln precip_${idtg}.b ./SAVE/precip_${idtg}.b
  endif
endif
C
C  --- END OF JUST IN TIME FLUX GENERATION SCRIPT.
C
