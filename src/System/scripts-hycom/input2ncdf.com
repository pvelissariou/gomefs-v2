#!/bin/csh
#
# This script bundles all input files of an experiment into one netcdf file and puts
# it in data/ncdf 

# Check that the neccesary variables are sourced, otherwise try to source them
if (-e ${HYCOMDIR}/ALL/scripts/sourceall.src) then
  source ${HYCOMDIR}/ALL/scripts/sourceall.src
else
  echo 'warning: sourceall.src not in expected location. Sourcing has possibly failed'
  echo '         go to an experiment directory if run.com fails'
endif

set RUNDIR=`mktemp -d $TMPDIR/tfile.XXXXXXXXXX`

cp ${FORCEDIR}/*.nc ${RUNDIR}
cp ${RELAXDIR}/*.nc ${RUNDIR}
cp ${DEPTHDIR}/*.nc ${RUNDIR}
cp ${TOPODIR}/*.nc ${RUNDIR}

cd ${RUNDIR}
ncwa -O -a MT,Step regional.grid.nc regional.grid.nc
ncwa -O -a MT,Step depth.nc depth.nc

ncks -A -a -v plon,plat,qlon,qlat,ulon,ulat,vlon,vlat,pang,pscx,pscy,qscx,qscy,uscx,uscy,vscx,vscy,cori,pasp regional.grid.nc input.nc >&/dev/null
ncks -A -v depth  depth.nc  input.nc >&/dev/null
ncks -A -v airtmp airtmp.nc input.nc >&/dev/null
ncks -A -v precip precip.nc input.nc >&/dev/null
ncks -A -v radflx radflx.nc input.nc >&/dev/null
ncks -A -v shwflx shwflx.nc input.nc >&/dev/null
ncks -A -v tau_ewd tauewd.nc input.nc >&/dev/null
ncks -A -v tau_nwd taunwd.nc input.nc >&/dev/null
ncks -A -v vapmix vapmix.nc input.nc >&/dev/null
ncks -A -v wnd_spd wndspd.nc input.nc >&/dev/null
ncks -A -v tem relax_tem.nc input.nc >&/dev/null
ncks -A -v int relax_int.nc input.nc >&/dev/null
ncks -A -v sal relax_sal.nc input.nc >&/dev/null
ncks -A -v rmu relax_rmu.nc input.nc >&/dev/null

mkdir -p ${EXPTDIR}/data/ncdf
mv input.nc ${EXPTDIR}/data/ncdf/input.${REGION}.${IEXPT}.nc

rm -rf ${RUNDIR}
