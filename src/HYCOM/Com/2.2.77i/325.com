#! /bin/csh
#
# --- check that the C comment command is available.
#
C >& /dev/null
if (! $status) then
  if (-e ${home}/hycom/ALL/bin/C) then
    set path = ( ${path} ${home}/hycom/ALL/bin )
  else
    echo "Please put the command hycom/ALL/bin/C in your path"
  endif
endif
#
set echo
set time = 1
set timestamp
C
C Based on Alans
C
C --- Experiment GOMl0.04 - 43.X series
C --- 27 layer HYCOM for Gulf of Mexico
C
C --- 43.X - Tidal test cases, all tides, cb=0.0025, start in 2011a.
C ---         Restart from data assimilative 31.8
C --- 43.0 - tidal.JSL, drgscl=0.9, variable tidsal, btrmas=1, 2.3.02
C ---         tidal boundary forcing from TPXO7-ATLAS.v2
C --- 43.1 - twin of 43.0 with btrmas=0.
C --- 43.2 - twin of 43.1 with 2.2.62.
C --- 43.3 - twin of 43.2 with 2.2.72 and cb_72b_10mm.
C --- 43.4 - twin of 43.3 with drgscl=0.0
C --- 43.5 - twin of 43.4 with tpxo_sal_hReIm.
C
setenv OS `uname`
switch ($OS)
case 'SunOS':
case 'Linux':
    head -40 /proc/cpuinfo
    head -40 /proc/meminfo
    which poe
    if (! $status) then
      setenv OS IDP
#      module swap mpi/intel/openmpi/1.5.5  mpi/intel/ibmpe/1.2.0.8
      module swap mpi mpi/intel/impi/4.1.0
      module list
    endif
    setenv NOMP 0
    setenv NMPI 32
    setenv TYPE mpi
    breaksw
case 'IRIX64':
case 'OSF1':
case 'AIX':
    setenv NOMP 0
    setenv NMPI 32
    setenv TYPE mpi
#    setenv TYPE mpi64
    breaksw
case 'sn6705':
    setenv OS unicosmk
case 'unicosmk':
    setenv ACCT `newacct -l | awk '{print $4}'`
#   setenv ACCT `groups | awk '{print $1}'`
#   always TYPE=shmem and NOMP=0 on T3E
    setenv TYPE shmem
    setenv NOMP 0
    setenv NMPI `limit -v | grep "MPP PE limit" | awk '{printf("%d\n",$4)}'`
    breaksw
case 'unicos':
    setenv ACCT `newacct -l | awk '{print $4}'`
    setenv NOMP 0
    setenv NMPI 0
    breaksw
default:
    echo 'Unknown Operating System: ' $OS
    exit (1)
endsw
C
C --- modify NOMP and NMPI based on batch limits
C
if ( $?LSB_MCPU_HOSTS ) then
# LSF batch system
#  if ( $?LSB_INITIAL_NUM_PROCESSORS) then
#    setenv NCPU $LSB_INITIAL_NUM_PROCESSORS
#  else
#    setenv NCPU `echo $LSB_MCPU_HOSTS | awk '{print $2+$4+$6+$8+$10+$12}'`
#  endif
#  if      ($NMPI == 0) then
#    setenv NOMP $NCPU
#  else if ($NOMP == 0) then
#    setenv NMPI $NCPU
#  else
#    setenv NMPI `echo $NCPU $NOMP | awk '{print int($1/$2)}'`
#  endif
else if ( $?GRD_TOTAL_MPI_TASKS ) then
# GRD batch system
  if      ($NMPI == 0) then
    echo "error - NMPI=0, but running in a MPI batch queue"
    exit
  else
    setenv NMPI $GRD_TOTAL_MPI_TASKS
  endif
else if ( $?NSLOTS ) then
# codine or GRD batch system
  if      ($NMPI == 0) then
    setenv NOMP $NSLOTS
  else if ($NOMP == 0) then
    setenv NMPI $NSLOTS
  else
    setenv NMPI `echo $NSLOTS $NOMP | awk '{print int($1/$2)}'`
  endif
endif
echo "NOMP is " $NOMP " and NMPI is " $NMPI
C
C --- R is region name.
C --- V is source code version number.
C --- T is topography number.
C --- K is number of layers.
C --- E is expt number.
C --- P is primary path.
C --- D is permanent directory.
C --- S is scratch   directory, must not be the permanent directory.
C
setenv R GOMl0.04
#setenv V 2.2.72
#setenv V 2.2.77i-ice
setenv V 2.2.77i-sm-sse
setenv T 72b
setenv K 27
setenv E 325
setenv P hycom/${R}/expt_32.5/data
setenv D ~/$P
C
switch ($OS)
case 'SunOS':
    if (-e /net/hermes/scrb) then
#                  NRLSSC
      setenv S     /net/hermes/scrb/${user}/$P
    else if (-e /scr) then
#                  NAVO MSRC
      mkdir        /scr/${user}
      chmod a+rx   /scr/${user}
      setenv S     /scr/${user}/$P
    else
#                  Single Disk
      setenv S     ~/$P/SCRATCH
    endif
    breaksw
case 'Linux':
case 'IDP':
    if (-e /export/a/$user) then
#              NRLSSC
      setenv S /export/a/${user}/$P
    else if (-e /scr) then
#                  NAVO MSRC, under LoadLeveler
      mkdir        /scr/${user}
      chmod a+rx   /scr/${user}
      setenv S     /scr/${user}/$P
#      setenv POE  poe
    else
#              Single Disk
      setenv S ~/$P/SCRATCH
    endif
    breaksw
case 'OSF1':
    if      (-e /work) then
#                  ERDC MSRC
      mkdir        /work/${user}
      chmod a+rx   /work/${user}
      setenv S     /work/${user}/$P
    else if (-e /workspace) then
#                  ASC MSRC
      mkdir        /workspace/${user}
      chmod a+rx   /workspace/${user}
      setenv S     /workspace/${user}/$P
    else
#                  Single Disk
      setenv S     ~/$P/SCRATCH
    endif
    breaksw
case 'IRIX64':
    if      (-e /scr) then
#                  NAVO MSRC
      mkdir        /scr/${user}
      chmod a+rx   /scr/${user}
      setenv S     /scr/${user}/$P
    else
#                  Single Disk
      setenv S     ~/$P/SCRATCH
    breaksw
case 'AIX':
    if      (-e /gpfs/work) then
#                  ERDC MSRC, under PBS
      mkdir        /gpfs/work/${user}
      chmod a+rx   /gpfs/work/${user}
      setenv S     /gpfs/work/${user}/$P
      setenv POE  pbspoe
    else if (-e /scr) then
#                  NAVO MSRC, under LoadLeveler or LSF
      mkdir        /scr/${user}
      chmod a+rx   /scr/${user}
      setenv S     /scr/${user}/$P
      if ($?LSB_JOBINDEX) then
        setenv POE mpirun.lsf
      else
        setenv POE poe
      endif
    else
#                  ARL MSRC, under GRD
      mkdir        /usr/var/tmp/${user}
      chmod a+rx   /usr/var/tmp/${user}
      setenv S     /usr/var/tmp/${user}/$P
      setenv POE  grd_poe
    endif
    breaksw
case 'unicos':
case 'unicosmk':
    if      (-e /work) then
#                  ERDC MSRC
      mkdir        /work/${user}
      chmod a+rx   /work/${user}
      mkdir        /work/${user}/$R
      chgrp $ACCT  /work/${user}/$R
      setenv S     /work/${user}/$P
    else
      mkdir        /tmp/${user}
      chmod a+rx   /tmp/${user}
      mkdir        /tmp/${user}/$R
      chgrp $ACCT  /tmp/${user}/$R
      setenv S     /tmp/${user}/$P
    endif
    breaksw
endsw
C
mkdir -p $S
cd       $S
C
C --- For whole year runs.
C ---   Y01 initial model year of this run.
C ---   YXX is the last model year of this run, and the first of the next run.
C ---   A and B are identical, typically blank.
C --- For part year runs.
C ---   A is this part of the year, B is next part of the year.
C ---   Y01 is the start model year of this run.
C ---   YXX is the end   model year of this run, usually Y01.
C --- For a few hour/day run
C ---   A   is the start day and hour, of form "dDDDhHH".
C ---   B   is the end   day and hour, of form "dXXXhYY".
C ---   Y01 is the start model year of this run.
C ---   YXX is the end   model year of this run, usually Y01.
C --- Note that these variables are set by the .awk generating script.
C
setenv A "g"
setenv B "h"
setenv Y01 "001"
setenv YXX "001"
C
echo "Y01 =" $Y01 "YXX = " $YXX  "A =" ${A} "B =" ${B}
#
if ( ${Y01} == 103) then
#assim
 setenv ASSIM 1
else if ( ${Y01} == 203) then
#no assim
 setenv ASSIM 0
endif
echo ${ASSIM}
#
# hour of restart file
#
setenv HR 12
setenv HR2 12
#
setenv idtg 
setenv idtgtod 
setenv nmdays 1
set  idtgmax=`/u/home/smedstad/bin/addndays yyyymmdd ${idtg} +${nmdays}`
# want to run forecast to 00Z so add 1 day to idtgmax
set  idtgmax2=`/u/home/smedstad/bin/addndays yyyymmdd ${idtgmax} +1`
set  idtgp1=`/u/home/smedstad/bin/addndays yyyymmdd ${idtg} +1`
#set  idtgp1=`/u/home/smedstad/bin/addndays yyyymmdd ${idtg} +${nmdays}`
# want restart for tomorrows run
set  idtgrst=`/u/home/${user}/bin/addndays yyyymmdd ${idtg} +1`
#hindcast
#set  idtgrst=${idtgmax}
#
set year=`echo ${idtg}${HR} | cut -c 1-4`
set mon=`echo ${idtg}${HR} | cut -c 5-6`
set day=`echo ${idtg}${HR} | cut -c 7-8`
set hour=`echo ${idtg}${HR} | cut -c 9-10`
# make restart
#set hour=00
echo ${year} ${mon} ${day} ${hour}
set dayin=`echo ${year} ${mon} ${day} ${hour} | /u/home/wallcraf/hycom/ALL/bin/hycom_ymdh_wind | awk '{print $1}'`
#
if ( ${nmdays} != 1) then
# forecast
 set year=`echo ${idtgmax2}${HR2} | cut -c 1-4`
 set mon=`echo ${idtgmax2}${HR2} | cut -c 5-6`
 set day=`echo ${idtgmax2}${HR2} | cut -c 7-8`
 set hour=`echo ${idtgmax2}${HR2} | cut -c 9-10`
 echo ${year} ${mon} ${day} ${hour}
 set daymax=`echo ${year} ${mon} ${day} 00 | /u/home/wallcraf/hycom/ALL/bin/hycom_ymdh_wind | awk '{print $1}'`
#
else
#
# tide run to 00Z for forecasts 12 hour foreward in time and also if you want a daily mean at 12Z
 set year=`echo ${idtgmax2}${HR2} | cut -c 1-4`
 set mon=`echo ${idtgmax2}${HR2} | cut -c 5-6`
 set day=`echo ${idtgmax2}${HR2} | cut -c 7-8`
 set hour=`echo ${idtgmax2}${HR2} | cut -c 9-10`
 echo ${year} ${mon} ${day} ${hour}
# starting at 12Z so can run to 00Z only
 set daymax=`echo ${year} ${mon} ${day} 00 | /u/home/wallcraf/hycom/ALL/bin/hycom_ymdh_wind | awk '{print $1}'`
endif
#
C
C --- local input files.
C
if (-e ${D}/../${E}y${idtg}.limits) then
  /bin/cp ${D}/../${E}y${idtg}.limits limits
else
#  use "LIMITI"  when starting a run after day zero.
#  use "LIMITS9" (say) for a 9-day run
#  echo "LIMITS" | awk -f ${D}/../${E}.awk y01=${Y01} ab=${A} >! limits
 echo $dayin $daymax | awk '{printf " %11.2f %11.2f    false    false\n",  $1, $2}' >! limits
endif
cat limits
C
if (-e ${D}/../ports.input_${idtg}) then
  /bin/cp ${D}/../ports.input_${idtg} ports.input
else
  /bin/cp ${D}/../ports.input ports.input
endif
C
if (-e    ${D}/../ports_z.input_${idtg}) then
  /bin/cp ${D}/../ports_z.input_${idtg} ports_z.input
  /bin/cp ${D}/../ports_u.input_${idtg} ports_u.input
  /bin/cp ${D}/../ports_v.input_${idtg} ports_v.input
  /bin/cp ${D}/../ports_a.input_${idtg} ports_a.input
else
  /bin/cp ${D}/../ports_z.input ports_z.input
  /bin/cp ${D}/../ports_u.input ports_u.input
  /bin/cp ${D}/../ports_v.input ports_v.input
  /bin/cp ${D}/../ports_a.input ports_a.input
endif
C
if (-e ${D}/../tracer.input_${idtg}) then
  /bin/cp ${D}/../tracer.input_${idtg} tracer.input
else
  /bin/cp ${D}/../tracer.input tracer.input
endif
C
#set dy0=`cat limits|awk '{printf "%7.0f", $2}'`
set dy0=`echo ${daymax}|awk '{printf "%7.0f", $1}'`
# set time of restart file for restart if assimilating before tau=0
#set dy0=`expr ${dy0} - 1`
set dy0=`expr ${dy0} -  ${nmdays}`
#set dy0=`echo "scale=2 ; ${dy0} + ${HR} / 24.0" | bc`
set dy0=`echo "scale=2 ; ${dy0} + ${HR} / 24.0" | bc`
#set dy0=`echo "scale=3 ; ${dy0} / 10.0" | bc`
C
if (-e ${D}/../blkdat.input_${idtg}) then
  /bin/cp ${D}/../blkdat.input_${idtg} blkdat.input
else
  awk -f  ${D}/../blkdat.awk dy0=${dy0}  ${D}/../blkdat.input >! blkdat.input
#  /bin/cp ${D}/../blkdat.input blkdat.input
endif
C
if (-e      ${D}/../archs.input_${idtg}) then
  /bin/cp   ${D}/../archs.input_${idtg} archs.input
else if (-e ${D}/../archs.input) then
  /bin/cp   ${D}/../archs.input archs.input
endif 
C 
if (-e ${D}/../profile.input_${idtg}) then
  /bin/cp ${D}/../profile.input_${idtg} profile.input
else if (-e ${D}/../profile.input) then
  /bin/cp ${D}/../profile.input profile.input
else
  touch profile.input 
endif            
if (! -z profile.input) then
  if (-e ./ARCHP) then
    /bin/mv ./ARCHP ./ARCHP_$$
  endif      
  mkdir ./ARCHP  
endif
C
if (-e ./cice) then
  if (-e ${D}/../ice_in_${idtg}) then
    /bin/cp ${D}/../ice_in_${idtg} ice_in
  else
    /bin/cp ${D}/../ice_in ice_in
  endif
endif
C
if ($NMPI != 0) then
  setenv NPATCH `echo $NMPI | awk '{printf("%03d", $1)}'`
  /bin/rm -f patch.input
  /bin/cp ${D}/../../topo/partit/depth_${R}_${T}.${NPATCH} patch.input
endif
#
#set dy0=`cat limits|awk '{printf "%7.0f", $2}'`
#set dy0=`expr ${dy0} - 0`
#set dy0=`echo "scale=1 ; ${dy0} / 10.0" | bc`
#
#echo ${dy0}
#
C
C --- check that iexpt from blkdat.input agrees with E from this script.
C
setenv EB `grep "'iexpt ' =" blk* | awk '{printf("%03d", $1)}'`
if ($EB != $E) then
  cd $D/..
  /bin/mv LIST LIST_BADRUN
  echo "BADRUN" > LIST
  exit
endif
#C
#C --- turn on detailed debugging.
#C
#touch PIPE_DEBUG
C
C --- pget, pput "copy" files between scratch and permanent storage.
C --- Can both be cp if the permanent filesystem is mounted locally.
C
switch ($OS)
case 'SunOS':
case 'Linux':
case 'OSF1':
case 'IRIX64':
case 'AIX':
#case 'IDP':
case 'unicos':
case 'unicosmk':
    if      (-e ~wallcraf/bin/pget_navo) then
      setenv pget ~wallcraf/bin/pget_navo
      setenv pput ~wallcraf/bin/pput_navo
    else if (-e ~wallcraf/bin/pget) then
      setenv pget ~wallcraf/bin/pget
      setenv pput ~wallcraf/bin/pput
    else
      setenv pget /bin/cp
      setenv pput /bin/cp
    endif
    breaksw
default:
    setenv pget /bin/cp
    setenv pput /bin/cp
endsw
C
C --- input files from file server.
C
touch regional.depth.a regional.depth.b
if (-z regional.depth.a) then
   ${pget} ${D}/../../topo/depth_${R}_${T}.a regional.depth.a &
endif
if (-z regional.depth.b) then
   ${pget} ${D}/../../topo/depth_${R}_${T}.b regional.depth.b &
endif
C
touch regional.grid.a regional.grid.b
if (-z regional.grid.a) then
   ${pget} ${D}/../../topo/regional.grid.a regional.grid.a &
endif
if (-z regional.grid.b) then
   ${pget} ${D}/../../topo/regional.grid.b regional.grid.b &
endif
C
if (! -e ./wind) then
C
C --- Climatological atmospheric forcing.
C
  setenv FN era15-annfd-mn6hr
  touch forcing.tauewd.a forcing.taunwd.a forcing.wndspd.a forcing.ustar.a
  touch forcing.radflx.a forcing.shwflx.a forcing.vapmix.a forcing.precip.a
  touch forcing.airtmp.a forcing.seatmp.a forcing.surtmp.a
  touch forcing.tauewd.b forcing.taunwd.b forcing.wndspd.b forcing.ustar.b
  touch forcing.radflx.b forcing.shwflx.b forcing.vapmix.b forcing.precip.b
  touch forcing.airtmp.b forcing.seatmp.b forcing.surtmp.b
  if (-z forcing.tauewd.a) then
     ${pget} ${D}/../../force/${FN}/tauewd.a      forcing.tauewd.a &
  endif
  if (-z forcing.tauewd.b) then
     ${pget} ${D}/../../force/${FN}/tauewd.b      forcing.tauewd.b &
  endif
  if (-z forcing.taunwd.a) then
     ${pget} ${D}/../../force/${FN}/taunwd.a      forcing.taunwd.a &
  endif
  if (-z forcing.taunwd.b) then
     ${pget} ${D}/../../force/${FN}/taunwd.b      forcing.taunwd.b &
  endif
  if (-z forcing.wndspd.a) then
     ${pget} ${D}/../../force/${FN}/wndspd.a      forcing.wndspd.a &
  endif
  if (-z forcing.wndspd.b) then
     ${pget} ${D}/../../force/${FN}/wndspd.b      forcing.wndspd.b &
  endif
  if (-z forcing.ustar.a) then
#    ${pget} ${D}/../../force/${FN}/ustar.a       forcing.ustar.a &
  endif
  if (-z forcing.ustar.b) then
#    ${pget} ${D}/../../force/${FN}/ustar.b       forcing.ustar.b &
  endif
  if (-z forcing.vapmix.a) then
     ${pget} ${D}/../../force/${FN}/vapmix.a      forcing.vapmix.a &
  endif
  if (-z forcing.vapmix.b) then
     ${pget} ${D}/../../force/${FN}/vapmix.b      forcing.vapmix.b &
  endif
  setenv AO ""
# setenv AO "_037c"
  if (-z forcing.airtmp.a) then
     ${pget} ${D}/../../force/${FN}/airtmp${AO}.a forcing.airtmp.a &
  endif
  if (-z forcing.airtmp.b) then
     ${pget} ${D}/../../force/${FN}/airtmp${AO}.b forcing.airtmp.b &
  endif
  setenv PO ""
# setenv PO "_zero"
  if (-z forcing.precip.a) then
     ${pget} ${D}/../../force/${FN}/precip${PO}.a forcing.precip.a &
  endif
  if (-z forcing.precip.b) then
     ${pget} ${D}/../../force/${FN}/precip${PO}.b forcing.precip.b &
  endif
  setenv FR ""
# setenv FR "-s14w"
  if (-z forcing.radflx.a) then
     ${pget} ${D}/../../force/${FN}/radflx${FR}.a forcing.radflx.a &
  endif
  if (-z forcing.radflx.b) then
     ${pget} ${D}/../../force/${FN}/radflx${FR}.b forcing.radflx.b &
  endif
  if (-z forcing.shwflx.a) then
     ${pget} ${D}/../../force/${FN}/shwflx${FR}.a forcing.shwflx.a &
  endif
  if (-z forcing.shwflx.b) then
     ${pget} ${D}/../../force/${FN}/shwflx${FR}.b forcing.shwflx.b &
  endif
  if (-z forcing.surtmp.a) then
     ${pget} ${D}/../../force/${FN}/surtmp.a      forcing.surtmp.a &
  endif
  if (-z forcing.surtmp.b) then
     ${pget} ${D}/../../force/${FN}/surtmp.b      forcing.surtmp.b &
  endif
# setenv FS $FN
  setenv FS RS_SST-mn6hr
  if (-z forcing.seatmp.a) then
#    ${pget} ${D}/../../force/${FS}/seatmp.a      forcing.seatmp.a &
  endif
  if (-z forcing.seatmp.b) then
#    ${pget} ${D}/../../force/${FS}/seatmp.b      forcing.seatmp.b &
  endif
endif
C
C --- time-invarent heat flux offset
C
#setenv FO "_052i+590+053_clip"
setenv FO "_071_08"
#setenv FO ""
touch  forcing.offlux.a
touch  forcing.offlux.b
if (-z forcing.offlux.a) then
   ${pget} ${D}/../../force/offset/offlux${FO}.a forcing.offlux.a &
endif
if (-z forcing.offlux.b) then
   ${pget} ${D}/../../force/offset/offlux${FO}.b forcing.offlux.b &
endif
C
touch  forcing.rivers.a
touch  forcing.rivers.b
if (-z forcing.rivers.a) then
   ${pget} ${D}/../../force/rivers/rivers_${T}.a forcing.rivers.a &
endif
if (-z forcing.rivers.b) then
   ${pget} ${D}/../../force/rivers/rivers_${T}.b forcing.rivers.b &
endif
C
touch  forcing.kpar.a
touch  forcing.kpar.b
if (-z forcing.kpar.a) then
   ${pget} ${D}/../../force/seawifs/kpar.a forcing.kpar.a &
endif
if (-z forcing.kpar.b) then
   ${pget} ${D}/../../force/seawifs/kpar.b forcing.kpar.b &
endif
C
touch relax.rmu.a relax.saln.a relax.temp.a relax.intf.a
touch relax.rmu.b relax.saln.b relax.temp.b relax.intf.b
if (-z relax.rmu.a) then
   ${pget} ${D}/../../relax/${E}/relax_rmu.a relax.rmu.a  &
endif
if (-z relax.rmu.b) then
   ${pget} ${D}/../../relax/${E}/relax_rmu.b relax.rmu.b  &
endif
if (-z relax.saln.a) then
   ${pget} ${D}/../../relax/${E}/relax_sal.a relax.saln.a &
endif
if (-z relax.saln.b) then
   ${pget} ${D}/../../relax/${E}/relax_sal.b relax.saln.b &
endif
if (-z relax.temp.a) then
   ${pget} ${D}/../../relax/${E}/relax_tem.a relax.temp.a &
endif
if (-z relax.temp.b) then
   ${pget} ${D}/../../relax/${E}/relax_tem.b relax.temp.b &
endif
if (-z relax.intf.a) then
   ${pget} ${D}/../../relax/${E}/relax_int.a relax.intf.a &
endif
if (-z relax.intf.b) then
   ${pget} ${D}/../../relax/${E}/relax_int.b relax.intf.b &
endif
setenv XS "100"
if ($XS != "") then
  touch  relax.ssh.a
  if (-z relax.ssh.a) then
     ${pget} ${D}/../../relax/SSH_${T}/relax_ssh_${XS}.a relax.ssh.a &
  endif
  touch  relax.ssh.b
  if (-z relax.ssh.b) then
     ${pget} ${D}/../../relax/SSH_${T}/relax_ssh_${XS}.b relax.ssh.b &
  endif
endif
C
setenv XR "_-0.5"
if ($XR != "") then
  touch  relax.sssrmx.a
  if (-z relax.sssrmx.a) then
     ${pget} ${D}/../../relax/SSSRMX/sssrmx${XR}.a relax.sssrmx.a &
  endif
  touch  relax.sssrmx.b
  if (-z relax.sssrmx.b) then
     ${pget} ${D}/../../relax/SSSRMX/sssrmx${XR}.b relax.sssrmx.b &
  endif
else
  touch  relax.sssrmx.a
  if (-z relax.sssrmx.a) then
     ${pget} ${D}/../../relax/SSSRMX/sssrmx.a relax.sssrmx.a &
  endif
  touch  relax.sssrmx.b
  if (-z relax.sssrmx.b) then
     ${pget} ${D}/../../relax/SSSRMX/sssrmx.b relax.sssrmx.b &
  endif
endif
C
touch tbaric.a
touch tbaric.b
if (-z tbaric.a) then
   ${pget} ${D}/../../relax/${E}/tbaric.a tbaric.a  &
endif
if (-z tbaric.b) then
   ${pget} ${D}/../../relax/${E}/tbaric.b tbaric.b  &
endif
C
touch iso.sigma.a
touch iso.sigma.b
if (-z iso.sigma.a) then
   ${pget} ${D}/../../relax/${E}/iso_sigma.a iso.sigma.a  &
endif
if (-z iso.sigma.b) then
   ${pget} ${D}/../../relax/${E}/iso_sigma.b iso.sigma.b  &
endif
C
touch veldf2.a
touch veldf2.b
if (-z veldf2.a) then
   ${pget} ${D}/../../relax/${E}/veldf2.a veldf2.a  &
endif
if (-z veldf2.b) then
   ${pget} ${D}/../../relax/${E}/veldf2.b veldf2.b  &
endif
C
touch veldf4.a
touch veldf4.b
if (-z veldf4.a) then
   ${pget} ${D}/../../relax/${E}/veldf4.a veldf4.a  &
endif
if (-z veldf4.b) then
   ${pget} ${D}/../../relax/${E}/veldf4.b veldf4.b  &
endif
C
#setenv TZ ""
setenv TZ "_10mm"
if ($TZ != "") then
  touch  cb.a
  if (-z cb.a) then
     ${pget} ${D}/../../relax/DRAG/cb_${T}${TZ}.a cb.a  &
  endif 
  touch  cb.b
  if (-z cb.b) then
     ${pget} ${D}/../../relax/DRAG/cb_${T}${TZ}.b cb.b  &
  endif 
endif 
C   
setenv TT ""
#setenv TT ".lim5"
if ($TT != "") then
  touch tidal.rh.a
  touch tidal.rh.b
  if (-z tidal.rh.a) then
     ${pget} ${D}/../../relax/DRAG/tidal.JSLrh.${T}${TT}.a tidal.rh.a  &
  endif 
  if (-z tidal.rh.b) then
     ${pget} ${D}/../../relax/DRAG/tidal.JSLrh.${T}${TT}.b tidal.rh.b  &
  endif 
endif  
C     
setenv TS ""
echo $TS
#setenv TS $T
if (${TS} != "") then
  touch  tidal.sal.a
  if (-z tidal.sal.a) then
     ${pget} ${D}/../../relax/SAL/tpxa_salQtide_${TS}.a tidal.sal.a &
  endif 
  touch  tidal.sal.b
  if (-z tidal.sal.b) then
     ${pget} ${D}/../../relax/SAL/tpxa_salQtide_${TS}.b tidal.sal.b &
  endif 
endif   
C     
#setenv SRI ""
setenv SRI "tpxo_sal"
if ($SRI != "") then
  touch  tidal.salReIm.a
  if (-z tidal.salReIm.a) then
     ${pget} ${D}/../../relax/SAL/${SRI}_hReIm.a tidal.salReIm.a  &
  endif 
  touch  tidal.salReIm.b
  if (-z tidal.salReIm.b) then
     ${pget} ${D}/../../relax/SAL/${SRI}_hReIm.b tidal.salReIm.b  &
  endif 
endif
C
C --- restart input
C
if ( ${ASSIM} == 1) then
  if (-z restart_r${idtg}${HR}.a) then
   ${pget} ${D}/../nowcast/restart_r${idtg}${HR}.a . &
  endif
  if (-z restart_r${idtg}${HR}.b) then
   ${pget} ${D}/../nowcast/restart_r${idtg}${HR}.b . &
  endif
else if ( ${ASSIM} == 0) then
  if (-z restart_n${idtg}${HR}.a) then
   ${pget} ${D}/../noassim/restart_n${idtg}${HR}.a . &
  endif
  if (-z restart_n${idtg}${HR}.b) then
    ${pget} ${D}/../noassim/restart_n${idtg}${HR}.b . &
  endif
endif
#
C
C --- model executable
C
if      ($NMPI == 0 && $NOMP == 0) then
  setenv TYPE one
else if ($NMPI == 0) then
  setenv TYPE omp
else if ($NOMP == 0) then
  if ( ! $?TYPE ) then
    setenv TYPE mpi
  endif
else
  setenv TYPE ompi
endif
if (-e ./cice) then
  setenv TYPE cice
  setenv HEXE hycom_cice
else
  setenv HEXE hycom
endif
/bin/cp /u/home/wallcraf/hycom/${R}/src_${V}_${K}_${TYPE}/hycom . &
#/bin/cp /u/home/smedstad/hycom/${R}/src_${V}_${K}_${TYPE}/hycom hycom &
C
C --- summary printout
C
touch   summary_out
/bin/mv summary_out summary_old
C
C --- heat transport output
C
touch   flxdp_out.a flxdp_out.b
/bin/mv flxdp_out.a flxdp_old.a
/bin/mv flxdp_out.b flxdp_old.b
C
touch   ovrtn_out
/bin/mv ovrtn_out ovrtn_old
C
C --- clean up old archive files, typically from batch system rerun.
C
mkdir KEEP
touch archv.dummy.b
foreach f (arch*.{a,b,txt})
  /bin/mv $f KEEP/$f
end
if (-e restart_out.b) then
  /bin/rm -f KEEP/restart_out.[ab]
  /bin/ln         restart_out.[ab] KEEP
endif
if (-e restart_out1.b) then
  /bin/rm -f KEEP/restart_out1.[ab]
  /bin/ln         restart_out1.[ab] KEEP
endif
#
/bin/rm   restart_out.a restart_out.b restart_out1.a restart_out1.b
/bin/rm restart_in.a restart_in.b
if ( ${ASSIM} == 0) then
 ln -s restart_n${idtg}${HR}.a restart_in.a
 ln -s restart_n${idtg}${HR}.b restart_in.b
else
 ln -s restart_r${idtg}${HR}.a restart_in.a
 ln -s restart_r${idtg}${HR}.b restart_in.b
endif
C
C --- Nesting input archive files.
C
if (-e ./nest) then
  cd ./nest
  touch rmu.a rmu.b
  if (-z rmu.a) then
     ${pget} ${D}/../../relax/${E}/nest_rmu.a rmu.a &
  endif
  if (-z rmu.b) then
     ${pget} ${D}/../../relax/${E}/nest_rmu.b rmu.b &
  endif
ls -la
#  touch   arch.dummy.b
#  /bin/rm arch*.[ab]
  touch nest_${year}.tar
  if (-z nest_${year}.tar) then
    ${pget} ~smedstad/hycom/GOMl0.04/expt_01.1/nest_27_${T}/nest_${year}.tar .
  endif
  tar xvf nest_${year}.tar
 cd ..
endif
C
C --- let all file copies complete.
C
date
wait
date
C
C --- zero file length means no rivers.
C
if (-z forcing.rivers.a) then
   /bin/rm forcing.rivers.[ab]
endif
C
C --- Just in time atmospheric forcing.
C
if (-e ./wind) then
  if (! -e ./flux) then
    echo './flux must exist if ./wind does'
    exit
  endif
C
C --- Check to see if wind and flux files exist, if not make them and wait.
C --- Assume that ustar is not needed for synoptic wind case.
C
  /bin/rm -f forcing.tauewd.a forcing.taunwd.a forcing.wndspd.a
  /bin/rm -f forcing.tauewd.b forcing.taunwd.b forcing.wndspd.b
  /bin/rm -f ./wind/${E}w${idtg}
  if (-e ./wind/tauewd_${idtg}.a && \
      -e ./wind/tauewd_${idtg}.b && \
      -e ./wind/taunwd_${idtg}.a && \
      -e ./wind/taunwd_${idtg}.b    ) then
    /bin/ln -sf ./wind/tauewd_${idtg}.a forcing.tauewd.a
    /bin/ln -sf ./wind/taunwd_${idtg}.a forcing.taunwd.a
    /bin/ln -sf ./wind/tauewd_${idtg}.b forcing.tauewd.b
    /bin/ln -sf ./wind/taunwd_${idtg}.b forcing.taunwd.b
    if (-e ./wind/wndspd_${idtg}.a && \
        -e ./wind/wndspd_${idtg}.b    ) then
      /bin/ln -sf ./wind/wndspd_${idtg}.a forcing.wndspd.a
      /bin/ln -sf ./wind/wndspd_${idtg}.b forcing.wndspd.b
    endif
  else
    cd ./wind
    touch ${E}w${idtg}
    /bin/rm -f ${E}w${idtg}.com ${E}w${idtg}.log
#    awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../${E}W.com > ${E}w${idtg}.com
    awk -f $D/../${E}.awk y01=${Y01} ab=${A} ts=$dayin tm=$daymax td=${idtg} te=$daymax $D/../${E}W.com > ${E}w${idtg}.com
    csh ${E}w${idtg}.com >& ${E}w${idtg}.log &
    cd ..
  endif
  if (-e ./wspd) then
    /bin/rm -f forcing.wndspd.a
    /bin/rm -f forcing.wndspd.b
    /bin/rm -f ./wspd/${E}s${idtg}
    if (-e ./wspd/wndspd_${idtg}.a && \
        -e ./wspd/wndspd_${idtg}.b    ) then
      /bin/ln -sf ./wspd/wndspd_${idtg}.a forcing.wndspd.a
      /bin/ln -sf ./wspd/wndspd_${idtg}.b forcing.wndspd.b
    else
      cd ./wspd
      touch ${E}s${idtg}
      /bin/rm -f ${E}s${idtg}.com ${E}s${idtg}.log
#      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../${E}S.com > ${E}s${idtg}.com
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} ts=$dayin tm=$daymax td=${idtg} te=$daymax $D/../${E}S.com > ${E}s${idtg}.com
      csh ${E}s${idtg}.com >& ${E}s${idtg}.log &
      cd ..
    endif
  endif
  if (-e ./ssta) then
    /bin/rm -f forcing.surtmp.a
    /bin/rm -f forcing.surtmp.b
    /bin/rm -f ./ssta/${E}p${idtg}
    if (-e ./ssta/surtmp_${idtg}.a && \
        -e ./ssta/surtmp_${idtg}.b    ) then
      /bin/ln -sf ./ssta/surtmp_${idtg}.a forcing.surtmp.a
      /bin/ln -sf ./ssta/surtmp_${idtg}.b forcing.surtmp.b
    else
      cd ./ssta
      touch ${E}t${idtg}
      /bin/rm -f ${E}t${idtg}.com ${E}t${idtg}.log
#      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../${E}T.com > ${E}t${idtg}.com
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} ts=$dayin tm=$daymax td=${idtg} te=$daymax $D/../${E}T.com > ${E}t${idtg}.com
      csh ${E}t${idtg}.com >& ${E}t${idtg}.log &
      cd ..
    endif
  endif
  if (-e ./ssto) then
    /bin/rm -f forcing.seatmp.a
    /bin/rm -f forcing.seatmp.b
    /bin/rm -f ./ssto/${E}p${idtg}
    if (-e ./ssto/seatmp_${idtg}.a && \
        -e ./ssto/seatmp_${idtg}.b    ) then
      /bin/ln -sf ./ssto/seatmp_${idtg}.a forcing.seatmp.a
      /bin/ln -sf ./ssto/seatmp_${idtg}.b forcing.seatmp.b
    else
      cd ./ssto
      touch ${E}o${idtg}
      /bin/rm -f ${E}o${idtg}.com ${E}o${idtg}.log
#      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../${E}O.com > ${E}o${idtg}.com
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} ts=$dayin tm=$daymax td=${idtg} te=$daymax $D/../${E}O.com > ${E}o${idtg}.com
      csh ${E}o${idtg}.com >& ${E}o${idtg}.log &
      cd ..
    endif
  endif
  if (-e ./pcip) then
    /bin/rm -f forcing.precip.a
    /bin/rm -f forcing.precip.b
    /bin/rm -f ./pcip/${E}p${idtg}
    if (-e ./pcip/precip_${idtg}.a && \
        -e ./pcip/precip_${idtg}.b    ) then
      /bin/ln -sf ./pcip/precip_${idtg}.a forcing.precip.a
      /bin/ln -sf ./pcip/precip_${idtg}.b forcing.precip.b
    else
      cd ./pcip
      touch ${E}p${idtg}
      /bin/rm -f ${E}p${idtg}.com ${E}p${idtg}.log
#      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../${E}P.com > ${E}p${idtg}.com
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} ts=$dayin tm=$daymax td=${idtg} te=$daymax $D/../${E}P.com > ${E}p${idtg}.com
      csh ${E}p${idtg}.com >& ${E}p${idtg}.log &
      cd ..
    endif
    /bin/rm -f forcing.airtmp.a forcing.radflx.a forcing.shwflx.a forcing.vapmix.a
    /bin/rm -f forcing.airtmp.b forcing.radflx.b forcing.shwflx.b forcing.vapmix.b
    /bin/rm -f ./flux/${E}f${idtg}
    if (-e ./flux/airtmp_${idtg}.a && \
        -e ./flux/airtmp_${idtg}.b && \
        -e ./flux/radflx_${idtg}.a && \
        -e ./flux/radflx_${idtg}.b && \
        -e ./flux/shwflx_${idtg}.a && \
        -e ./flux/shwflx_${idtg}.b && \
        -e ./flux/vapmix_${idtg}.a && \
        -e ./flux/vapmix_${idtg}.b    ) then
      /bin/ln -sf ./flux/airtmp_${idtg}.a forcing.airtmp.a
      /bin/ln -sf ./flux/radflx_${idtg}.a forcing.radflx.a
      /bin/ln -sf ./flux/shwflx_${idtg}.a forcing.shwflx.a
      /bin/ln -sf ./flux/vapmix_${idtg}.a forcing.vapmix.a
      /bin/ln -sf ./flux/airtmp_${idtg}.b forcing.airtmp.b
      /bin/ln -sf ./flux/radflx_${idtg}.b forcing.radflx.b
      /bin/ln -sf ./flux/shwflx_${idtg}.b forcing.shwflx.b
      /bin/ln -sf ./flux/vapmix_${idtg}.b forcing.vapmix.b
    else
      cd ./flux
      touch ${E}f${idtg}
      /bin/rm -f ${E}f${idtg}.com ${E}f${idtg}.log
#      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../${E}F.com > ${E}f${idtg}.com
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} ts=$dayin tm=$daymax td=${idtg} te=$daymax $D/../${E}F.com > ${E}f${idtg}.com
      csh ${E}f${idtg}.com >& ${E}f${idtg}.log &
      cd ..
    endif
  else
    /bin/rm -f forcing.airtmp.a forcing.precip.a forcing.radflx.a forcing.shwflx.a forcing.vapmix.a
    /bin/rm -f forcing.airtmp.b forcing.precip.b forcing.radflx.b forcing.shwflx.b forcing.vapmix.b
    /bin/rm -f ./flux/${E}f${idtg}
    if (-e ./flux/airtmp_${idtg}.a && \
        -e ./flux/airtmp_${idtg}.b && \
        -e ./flux/precip_${idtg}.a && \
        -e ./flux/precip_${idtg}.b && \
        -e ./flux/radflx_${idtg}.a && \
        -e ./flux/radflx_${idtg}.b && \
        -e ./flux/shwflx_${idtg}.a && \
        -e ./flux/shwflx_${idtg}.b && \
        -e ./flux/vapmix_${idtg}.a && \
        -e ./flux/vapmix_${idtg}.b    ) then
      /bin/ln -sf ./flux/airtmp_${idtg}.a forcing.airtmp.a
      /bin/ln -sf ./flux/precip_${idtg}.a forcing.precip.a
      /bin/ln -sf ./flux/radflx_${idtg}.a forcing.radflx.a
      /bin/ln -sf ./flux/shwflx_${idtg}.a forcing.shwflx.a
      /bin/ln -sf ./flux/vapmix_${idtg}.a forcing.vapmix.a
      /bin/ln -sf ./flux/airtmp_${idtg}.b forcing.airtmp.b
      /bin/ln -sf ./flux/precip_${idtg}.b forcing.precip.b
      /bin/ln -sf ./flux/radflx_${idtg}.b forcing.radflx.b
      /bin/ln -sf ./flux/shwflx_${idtg}.b forcing.shwflx.b
      /bin/ln -sf ./flux/vapmix_${idtg}.b forcing.vapmix.b
    else
      cd ./flux
      touch ${E}f${idtg}
      /bin/rm -f ${E}f${idtg}.com ${E}f${idtg}.log
#      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../${E}F.com > ${E}f${idtg}.com
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} ts=$dayin tm=$daymax td=${idtg} te=$daymax $D/../${E}F.com > ${E}f${idtg}.com
      csh ${E}f${idtg}.com >& ${E}f${idtg}.log &
      cd ..
    endif
  endif
  wait
  if (-e ./ssto/seatmp_${idtg}.a && \
        -e ./ssto/seatmp_${idtg}.b    ) then
      /bin/ln -sf ./ssto/seatmp_${idtg}.a forcing.seatmp.a
      /bin/ln -sf ./ssto/seatmp_${idtg}.b forcing.seatmp.b
  endif
  if (-e ./ssta/surtmp_${idtg}.a && \
        -e ./ssta/surtmp_${idtg}.b    ) then
      /bin/ln -sf ./ssta/surtmp_${idtg}.a forcing.surtmp.a
      /bin/ln -sf ./ssta/surtmp_${idtg}.b forcing.surtmp.b
  endif
  if (-e ./wind/tauewd_${idtg}.a && \
      -e ./wind/tauewd_${idtg}.b && \
      -e ./wind/taunwd_${idtg}.a && \
      -e ./wind/taunwd_${idtg}.b    ) then
    /bin/ln -sf ./wind/tauewd_${idtg}.a forcing.tauewd.a
    /bin/ln -sf ./wind/taunwd_${idtg}.a forcing.taunwd.a
    /bin/ln -sf ./wind/tauewd_${idtg}.b forcing.tauewd.b
    /bin/ln -sf ./wind/taunwd_${idtg}.b forcing.taunwd.b
    if (-e ./wspd/wndspd_${idtg}.a && \
        -e ./wspd/wndspd_${idtg}.b    ) then
      /bin/ln -sf ./wspd/wndspd_${idtg}.a forcing.wndspd.a
      /bin/ln -sf ./wspd/wndspd_${idtg}.b forcing.wndspd.b
    endif
  endif
  if (-e ./pcip) then
    if (-e ./pcip/${E}p${idtg}) then
      /bin/ln -sf ./pcip/precip_${idtg}.a forcing.precip.a
      /bin/ln -sf ./pcip/precip_${idtg}.b forcing.precip.b
    endif
    if (-e ./flux/airtmp_${idtg}.a && \
        -e ./flux/airtmp_${idtg}.b && \
        -e ./flux/precip_${idtg}.a && \
        -e ./flux/precip_${idtg}.b && \
        -e ./flux/radflx_${idtg}.a && \
        -e ./flux/radflx_${idtg}.b && \
        -e ./flux/shwflx_${idtg}.a && \
        -e ./flux/shwflx_${idtg}.b && \
        -e ./flux/vapmix_${idtg}.a && \
        -e ./flux/vapmix_${idtg}.b    ) then
      /bin/ln -sf ./flux/airtmp_${idtg}.a forcing.airtmp.a
      /bin/ln -sf ./flux/radflx_${idtg}.a forcing.radflx.a
      /bin/ln -sf ./flux/shwflx_${idtg}.a forcing.shwflx.a
      /bin/ln -sf ./flux/vapmix_${idtg}.a forcing.vapmix.a
      /bin/ln -sf ./flux/airtmp_${idtg}.b forcing.airtmp.b
      /bin/ln -sf ./flux/radflx_${idtg}.b forcing.radflx.b
      /bin/ln -sf ./flux/shwflx_${idtg}.b forcing.shwflx.b
      /bin/ln -sf ./flux/vapmix_${idtg}.b forcing.vapmix.b
    endif
  else
    if (-e ./flux/airtmp_${idtg}.a && \
        -e ./flux/airtmp_${idtg}.b && \
        -e ./flux/precip_${idtg}.a && \
        -e ./flux/precip_${idtg}.b && \
        -e ./flux/radflx_${idtg}.a && \
        -e ./flux/radflx_${idtg}.b && \
        -e ./flux/shwflx_${idtg}.a && \
        -e ./flux/shwflx_${idtg}.b && \
        -e ./flux/vapmix_${idtg}.a && \
        -e ./flux/vapmix_${idtg}.b    ) then
      /bin/ln -sf ./flux/airtmp_${idtg}.a forcing.airtmp.a
      /bin/ln -sf ./flux/precip_${idtg}.a forcing.precip.a
      /bin/ln -sf ./flux/radflx_${idtg}.a forcing.radflx.a
      /bin/ln -sf ./flux/shwflx_${idtg}.a forcing.shwflx.a
      /bin/ln -sf ./flux/vapmix_${idtg}.a forcing.vapmix.a
      /bin/ln -sf ./flux/airtmp_${idtg}.b forcing.airtmp.b
      /bin/ln -sf ./flux/precip_${idtg}.b forcing.precip.b
      /bin/ln -sf ./flux/radflx_${idtg}.b forcing.radflx.b
      /bin/ln -sf ./flux/shwflx_${idtg}.b forcing.shwflx.b
      /bin/ln -sf ./flux/vapmix_${idtg}.b forcing.vapmix.b
    endif
  endif
C
endif
C
C --- Nesting input archive files for next segment.
C
#if (-e ./nest) then
#ls -la ./nest/
#  cd ./nest
#  touch archv_${idtgmax}.tar
#  if (-z archv_${idtgmax}.tar) then
#    ${pget} ${D}/nest/archv_${idtgmax}.tar archv_${idtgmax}.tar &
#  endif
#  cd ..
#endif
C
chmod ug+x hycom
/bin/ls -laFq
C
#if (-e ./nest) then
#  ls -laFq nest
#endif
C
C ---  Check to make sure restart file is there
C
#if (`echo $LI | awk '{print ($1 > 0.0)}'` && -z restart_in.a) then
if ($Y01 != "001" && -z restart_in.a) then
  cd $D/..
  /bin/mv LIST LIST_BADRUN
  echo "BADRUN" > LIST
  exit
endif
echo "START MODEL"
date
C
if ($NMPI == 0) then
C
C --- run the model, without MPI or SHMEM
C
if ($NOMP == 0) then
  setenv NOMP 1
endif
C
switch ($OS)
case 'SunOS':
C
C   --- $NOMP CPUs/THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    env OMP_NUM_THREADS=$NOMP ./hycom
    breaksw
case 'Linux':
C
C   --- $NOMP CPUs/THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    env OMP_NUM_THREADS=$NOMP MPSTKZ=8M ./hycom
    breaksw
case 'OSF1':
C
C   --- $NOMP CPUs/THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    env OMP_NUM_THREADS=$NOMP ./hycom
    breaksw
case 'IRIX64':
C
C   --- $NOMP CPUs/THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    setenv FILENV .assign
    assign -R
    assign -s sbin u:18
    assign -V
    env OMP_NUM_THREADS=$NOMP ./hycom
    assign -V
    assign -R
    breaksw
case 'unicosmk':
C
C   --- ONE CPU ONLY.
C
    /bin/rm -f core
    touch core
    ulimit
    assign -V
    ./hycom
    if (! -z core)  debugview hycom core
    ulimit
    assign -V
    assign -R
    limit -v
    breaksw
case 'unicos':
C
C   --- $NOMP CPUs/THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    assign -V
    env OMP_NUM_THREADS=$NOMP ./hycom
    if (! -z core)  debug -s hycom core
    assign -V
    assign -R
    breaksw
endsw
else
C
C --- run the model, with MPI or SHMEM and perhaps also with OpenMP.
C
touch patch.input
if (-z patch.input) then
C
C --- patch.input is always required for MPI or SHMEM.
C
  cd $D/..
  /bin/mv LIST LIST_BADRUN
  echo "BADRUN" > LIST
  exit
endif
C
switch ($OS)
case 'SunOS':
C
C   --- $NMPI MPI tasks and $NOMP THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    setenv OMP_NUM_THREADS $NOMP
#   mpirun -np $NMPI ./hycom
    pam ./hycom
    breaksw
case 'Linux':
C
C   --- $NMPI MPI tasks and $NOMP THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    setenv OMP_NUM_THREADS $NOMP
    mpirun -np $NMPI ./hycom
    breaksw
case 'IDP':
        setenv LANG en_US
#       setenv NLSPATH "$NLSPATH:/opt/ibmhpc/pecurrent/base/msg/%l_%t/%N"
        setenv MP_RESD poe
        setenv MP_INFOLEVEL 0
        setenv MP_EUILIB us
        setenv MP_DEVTYPE ib
        setenv MP_EUIDEVICE sn_single
        setenv MP_INSTANCES 1
        setenv MP_SINGLE_THREAD yes
        setenv MP_EUIDEVELOP min
        setenv MP_PE_AFFINITY yes
        setenv MP_TASK_AFFINITY CORE
        setenv MP_CLOCK_SOURCE OS
        setenv MP_SYNC_QP yes
        setenv MP_COREFILE_FORMAT light_core
        setenv MP_POLLING_INTERVAL 100000000
        setenv MP_EAGER_LIMIT 128K
        setenv MP_WAIT_MODE poll
        setenv MP_CSS_INTERRUPT no
        setenv MP_PMDLOG no
        setenv MPICH_ALLTOALL_THROTTLE 0
        setenv MP_EAGER_LIMIT_LOCAL 128K
        setenv MP_DEBUG_SLOT_DATA_SIZE 64K
        setenv MP_DEBUG_DISPATCHER_THROTTLE 200
        setenv MP_STDOUTMODE unordered
        setenv MP_PRINTENV no
        setenv MP_USE_BULK_XFER yes
        setenv MP_BULK_MIN_MSG_SIZE 128K
        if ($NOMP == 0) then
#            poe ./hycom
            mpirun ./hycom
        else
            setenv OMP_DYNAMIC          FALSE            setenv OMP_NUM_THREADS      $NOMP
            poe ./hycom
        endif
        breaksw
case 'OSF1':
C
C   --- $NMPI MPI tasks and $NOMP THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    setenv OMP_NUM_THREADS $NOMP
#   mpirun -np $NMPI ./hycom
    time prun -n $NMPI ./hycom
    breaksw
case 'IRIX64':
if ($TYPE == "shmem") then
C
C   --- $NMPI SHMEM tasks
C
    /bin/rm -f core
    touch core
    setenv FILENV .assign
    assign -R
    assign -s sbin u:18
    assign -V
    setenv OMP_NUM_THREADS	1
    setenv SMA_DSM_TOPOLOGY	free
    setenv SMA_DSM_VERBOSE	1
    setenv SMA_VERSION		1
    env NPES=$NMPI ./hycom
    assign -V
    assign -R
    breaksw
else
C
C   --- $NMPI MPI tasks and $NOMP THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    setenv FILENV .assign
    assign -R
    assign -s sbin u:18
    assign -V
    setenv OMP_NUM_THREADS	$NOMP
    setenv MPI_DSM_VERBOSE	1
    setenv MPI_REQUEST_MAX	8192
    mpirun -np $NMPI ./hycom < /dev/zero
    assign -V
    assign -R
    breaksw
endif
case 'AIX':
C
C   --- $NMPI MPI tasks and $NOMP THREADs, if compiled for IBM OpenMP.
C
    ldedit -bdatapsize=64K -bstackpsize=64K ./${HEXE}
    /bin/rm -f core
    touch core
    setenv SPINLOOPTIME         500
    setenv YIELDLOOPTIME        500
    setenv XLSMPOPTS            "parthds=${NOMP}:spins=0:yields=0"
    setenv MP_SHARED_MEMORY     yes
    setenv MP_SINGLE_THREAD     yes
#
# added 20091021
#
    setenv MP_LABELIO           yes
    setenv MP_PRINTENV          yes
#
#   setenv MP_SINGLE_THREAD     no
    setenv MP_EAGER_LIMIT       65536
#   setenv MP_EUILIB            us
#   list where the MPI job will run
#   env MP_LABELIO=YES $POE hostname
    if      (-e /site/bin/launch) then
      setenv MEMORY_AFFINITY    MCM
      setenv UL_MODE            PURE_MPI
      setenv UL_TARGET_CPU_LIST AUTO_SELECT
      time $POE /site/bin/launch ./${HEXE}
#      time $POE ./${HEXE}
    else
      time $POE ./${HEXE}
    endif
    breaksw
#case 'AIX':
#C
#C   --- $NMPI MPI tasks and $NOMP THREADs, if compiled for KAI OpenMP.
#C
#    /bin/rm -f core
#    touch core
#    setenv OMP_NUM_THREADS	$NOMP
#    setenv MP_SHARED_MEMORY	yes
#    setenv MP_SINGLE_THREAD	yes
#    setenv MP_EAGER_LIMIT	65536
#    setenv MP_EUILIB		us
#    setenv MP_EUIDEVICE		css0
##   list where the MPI job will run
#    env MP_LABELIO=YES $POE hostname
#    time $POE ./hycom
#    breaksw
case 'unicosmk':
C
C   --- $NMPI MPI/SHMEM tasks
C
    /bin/rm -f core
    touch core
    ulimit
    assign -V
    mpprun -n $NMPI ./hycom
    if (! -z core)  debugview hycom core
    ulimit
    assign -V
    assign -R
    limit -v
    breaksw
default:
    echo "This O/S," $OS ", is not configured for MPI/SHMEM"
    exit (1)
endsw
endif
C
touch   PIPE_DEBUG
/bin/rm PIPE_DEBUG
C
C --- archive output in a separate tar directory
C
touch archv.dummy.a archv.dummy.b archv.dummy.txt
touch archm.dummy.a archm.dummy.b archm.dummy.txt
touch arche.dummy.a arche.dummy.b arche.dummy.txt
touch archp.dummy.a archp.dummy.b archp.dummy.txt
touch archt.dummy.a archt.dummy.b archt.dummy.txt
touch cice.dummy.nc
C
if (-e ./SAVE) then
  foreach t ( v s m )
    foreach f (arch${t}.*.a)
      /bin/ln ${f} SAVE/${f}
    end
    foreach f (arch${t}.*.b)
      /bin/ln ${f} SAVE/${f}
    end
    foreach f (arch${t}.*.txt)
      /bin/ln ${f} SAVE/${f}
    end
  end
  foreach f (cice.*.nc)
    /bin/ln -f ${f} SAVE/${f}
  end
endif
C
foreach t ( v s m )
 echo ${t}
  mkdir -p ./tar${t}_${idtgtod}${HR}_${idtgp1}00
switch ($OS)
case 'XT3':
case 'XT4':
  lfs setstripe ./tar${t}_${idtgtod}${HR}_${idtgp1}00 1048576 -1 8
  breaksw
endsw
  foreach f (arch${t}.*.a)
    /bin/mv ${f} ./tar${t}_${idtgtod}${HR}_${idtgp1}00/${E}_${f}
  end
  foreach f (arch${t}.*.b)
    /bin/mv ${f} ./tar${t}_${idtgtod}${HR}_${idtgp1}00/${E}_${f}
  end
  foreach f (arch${t}.*.txt)
    /bin/mv ${f} ./tar${t}_${idtgtod}${HR}_${idtgp1}00/${E}_${f}
  end
  date
end
foreach f (cice.*.nc)
  /bin/mv ${f} ./tarc_${idtgtod}${HR}_${idtgp1}00/${E}_${f}
end
if (! -z archt.input) then
  if (-e ./tart_${idtgtod}${HR}_${idtgp1}00) then
    /bin/mv ./tart_${idtgtod}${HR}_${idtgp1}00 ./tart_${idtgtod}${HR}_${idtgp1}00_$$
  endif
  /bin/mv ./ARCHT ./tart_${idtgtod}${HR}_${idtgp1}00
endif
endif
C
C TRANSFER FILES
pwd
chmod -R a+rx tar_${idtgtod}${HR}_${idtgp1}00
foreach t ( v s m )
  awk -f $D/../${E}.awk y01=${Y01} hr=${HR} tod=${idtgtod} ab=${A} td=${idtgp1} \
       $D/../${E}A${t}.com >! ${E}tar${t}${idtgp1}a.com
   ~wallcraf/bin/q_navo          ${E}tar${t}${idtgp1}a.com
end
C
C --- heat transport statistics output
C
if (-e flxdp_out.a) then
# ${pput} flxdp_out.a ${D}/flxdp_${idtg}.a
endif
if (-e flxdp_out.b) then
# ${pput} flxdp_out.b ${D}/flxdp_${idtg}.b
endif
if (-e ovrtn_out) then
# ${pput} ovrtn_out ${D}/ovrtn_${idtg}
endif
C
C --- restart output
C
mkdir ./PPUT
#
if (-e restart_out.a) then
#  /bin/mv restart_out.a  restart_r${idtgmax}${HR}.a
  /bin/mv restart_out.a  restart_r${idtgmax2}00.a
endif
if (-e restart_out.b) then
#  /bin/mv restart_out.b  restart_r${idtgmax}${HR}.b
  /bin/mv restart_out.b  restart_r${idtgmax2}00.b
endif
if (-e restart_out1.a) then
  /bin/mv restart_out1.a restart_r${idtgrst}${HR}.a
endif
if (-e restart_out1.b) then
  /bin/mv restart_out1.b restart_r${idtgrst}${HR}.b
endif
#else
#if (-e restart_out.a) then
#  /bin/mv restart_out.a  restart_r${idtgmax}${HR}.a
#endif
#if (-e restart_out.b) then
#  /bin/mv restart_out.b  restart_r${idtgmax}${HR}.b
#endif
#if (-e restart_out1.a) then
#  /bin/mv restart_out1.a restart_r${idtgrst}${HR}.a
#endif
#if (-e restart_out1.b) then
#  /bin/mv restart_out1.b restart_r${idtgrst}${HR}.b
#endif
#endif
C
if (-e ./wind) then
C
C --- Delete just in time wind and flux files.
C
  touch summary_out
#  if ( `tail -1 summary_out | grep -c "^normal stop"` == 1 ) then
#    /bin/rm -f ./wind/*_${idtg}.[ab]
#    /bin/rm -f ./wspd/*_${idtg}.[ab]
#    /bin/rm -f ./flux/*_${idtg}.[ab]
#    /bin/rm -f ./pcip/*_${idtg}.[ab]
#    /bin/rm -f ./ssta/*_${idtg}.[ab]
#    /bin/rm -f ./ssto/*_${idtg}.[ab]
#  endif
C
  if (-e ./wind/${E}w${idtg}.com) then
    /bin/mv ./wind/${E}w${idtg}.{com,log} $D/..
  endif
  if (-e ./wspd/${E}s${idtg}.com) then
    /bin/mv ./wspd/${E}s${idtg}.{com,log} $D/..
  endif
  if (-e ./flux/${E}f${idtg}.com) then
    /bin/mv ./flux/${E}f${idtg}.{com,log} $D/..
  endif
  if (-e ./pcip/${E}f${idtg}.com) then
    /bin/mv ./pcip/${E}f${idtg}.{com,log} $D/..
  endif
  if (-e ./ssta/${E}f${idtg}.com) then
    /bin/mv ./ssta/${E}f${idtg}.{com,log} $D/..
  endif
  if (-e ./ssto/${E}o${idtg}.com) then
    /bin/mv ./ssto/${E}o${idtg}.{com,log} $D/..
  endif
C
C --- Wait for wind and flux interpolation of next segment.
C
  wait
C
  if (-e ./wind/${E}w${idtgmax}.com) then
    /bin/mv ./wind/${E}w${idtgmax}.{com,log} $D/..
  endif
  if (-e ./wspd/${E}s${idtgmax}.com) then
    /bin/mv ./wspd/${E}s${idtgmax}.{com,log} $D/..
  endif
  if (-e ./flux/${E}f${idtgmax}.com) then
    /bin/mv ./flux/${E}f${idtgmax}.{com,log} $D/..
  endif
  if (-e ./pcip/${E}p${idtgmax}.com) then
    /bin/mv ./pcip/${E}p${idtgmax}.{com,log} $D/..
  endif
  if (-e ./ssta/${E}t${idtgmax}.com) then
    /bin/mv ./ssta/${E}t${idtgmax}.{com,log} $D/..
  endif
  if (-e ./ssto/${E}o${idtgmax}.com) then
    /bin/mv ./ssto/${E}o${idtgmax}.{com,log} $D/..
  endif
endif
C
C --- wait for nesting .tar file.
C
#if (-e ./nest) then
#  wait
#endif
C
C --- submit postprocessing job
C
#awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../../postproc_${E}.com >! \
#         ./postproc_${E}_${idtg}.com
#q          postproc_${E}_${idtg}.com
C
C --- HYCOM error stop is implied by the absence of a normal stop.
C
touch summary_out
if ( `tail -1 summary_out | grep -c "^normal stop"` == 0 ) then
  cd $D/..
  /bin/mv LIST LIST_BADRUN
  echo "BADRUN" > LIST
endif
C
C  --- END OF MODEL RUN SCRIPT
C
