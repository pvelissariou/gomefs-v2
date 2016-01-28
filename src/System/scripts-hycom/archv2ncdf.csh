#!/bin/csh
#
# --- extract 2-d fields from a single HYCOM archive file.
# --- configured for 22 layers.
#
# --- output is netCDF.
# --- this is an example, customize it for your datafile needs.
#
#
# --- optional title and institution.
#
# Check that the neccesary variables are sourced, otherwise try to source them
if (-e ${HYCOMDIR}/ALL/scripts/sourceall.src) then
  source ${HYCOMDIR}/ALL/scripts/sourceall.src
else
  echo 'warning: sourceall.src not in expected location. Sourcing has possibly failed'
endif

if (-e /opt/modules/modules/init/csh) then #We are on aster
  source /opt/modules/modules/init/csh 
  module load nco-3.0.0
endif

# Get the thbase and yrflag value from blkdat.input
setenv THB  `grep \'thbase blkdat.input | awk '{print $1}'`
setenv YRF  `grep \'yrflag blkdat.input | awk '{print $1}'`
setenv DP00 `grep \'dp00\  blkdat.input | awk '{print $1}'`
setenv DP00X `grep \'dp00x blkdat.input | awk '{print $1}'`
setenv DP00F `grep \'dp00f blkdat.input | awk '{print $1}'`
setenv DS00 `grep \'ds00\  blkdat.input | awk '{print $1}'`
setenv DS00X `grep \'ds00x blkdat.input | awk '{print $1}'`
setenv DS00F `grep \'ds00f blkdat.input | awk '{print $1}'`
setenv SIGMA `grep \'sigma blkdat.input | awk '{print $1}'`
setenv INIFLG `grep \'iniflg blkdat.input | awk '{print $1}'`
setenv JERLV0 `grep \'jerlv0 blkdat.input | awk '{print $1}'`
setenv BNSTFQ `grep \'bnstfq blkdat.input | awk '{print $1}'`
setenv NESTFQ `grep \'nestfq blkdat.input | awk '{print $1}'`
setenv VORTFQ `grep \'vortfq blkdat.input | awk '{print $1}'`
setenv VORTNO `grep \'vortno blkdat.input | awk '{print $1}'`
setenv BACLIN `grep \'baclin blkdat.input | awk '{print $1}'`
setenv BATROP `grep \'batrop blkdat.input | awk '{print $1}'`
setenv HYBFLG `grep \'hybflg blkdat.input | awk '{print $1}'`
setenv ADVFLG `grep \'advflg blkdat.input | awk '{print $1}'`
setenv SLIP `grep \'slip blkdat.input | awk '{print $1}'`
setenv VISCO2 `grep \'visco2 blkdat.input | awk '{print $1}'`
setenv VISCO4 `grep \'visco4 blkdat.input | awk '{print $1}'`
setenv VELDF2 `grep \'veldf2 blkdat.input | awk '{print $1}'`
setenv VELDF4 `grep \'veldf4 blkdat.input | awk '{print $1}'`
setenv THKDF2 `grep \'thkdf2 blkdat.input | awk '{print $1}'`
setenv THKDF4 `grep \'thkdf4 blkdat.input | awk '{print $1}'`
setenv TEMDF2 `grep \'temdf2 blkdat.input | awk '{print $1}'`
setenv VERTMX `grep \'vertmx blkdat.input | awk '{print $1}'`
setenv CBAR `grep \'cbar blkdat.input | awk '{print $1}'`
setenv CB `grep \'cb\  blkdat.input | awk '{print $1}'`
setenv THKBOT `grep \'thkbot blkdat.input | awk '{print $1}'`
setenv SIGJMP `grep \'sigjmp blkdat.input | awk '{print $1}'`
setenv TMLJMP `grep \'tmljmp blkdat.input | awk '{print $1}'`
setenv THKMLR `grep \'thkmlr blkdat.input | awk '{print $1}'`
setenv MLFLAG `grep \'mlflag blkdat.input | awk '{print $1}'`
setenv CLMFLG `grep \'clmflg blkdat.input | awk '{print $1}'`
setenv LBFLAG `grep \'lbflag blkdat.input | awk '{print $1}'`
setenv WNDFLG `grep \'wndflg blkdat.input | awk '{print $1}'`
setenv FLXFLG `grep \'flxflg blkdat.input | awk '{print $1}'`
setenv RELAX `grep \'relax blkdat.input | awk '{print $1}'`
setenv SRELAX `grep \'srelax blkdat.input | awk '{print $1}'`
setenv TRELAX `grep \'trelax blkdat.input | awk '{print $1}'`
setenv TRCRLX `grep \'trcrlx blkdat.input | awk '{print $1}'`

# addition informatin written to netcdf files:
setenv CDF_TITLE	"HYCOM ${REGION}"
setenv CDF_INST 	"IMAU"

# set some directory names:
set RUNDIR=`mktemp -d $TMPDIR/tfile.XXXXXXXXXX`
set ARCHV2NCDF2D=${HYCOMDIR}/ALL/archive/src/archv2ncdf2d
set OUTPUTDIR=${HYCOMDIR}/${REGION}/expt_${IEXPT}/data/ncdf/

cd ${RUNDIR}

ln -s ${TOPODIR}/regional.grid.nc
ln -s ${DEPTHDIR}/depth.nc regional.depth.nc

# Iterate over all arch.[ab] files in the directory
touch rundirarchives
if (-e ${HYCOMDIR}/${REGION}/expt_${IEXPT}/rundir && ${ARCH} != aster) then
    ls ${HYCOMDIR}/${REGION}/expt_${IEXPT}/rundir/archv*.nc > rundirarchives
endif
if (! -z rundirarchives) then
    echo 'using rundir'
    set INFILES=`ls ${HYCOMDIR}/${REGION}/expt_${IEXPT}/rundir/archv*.nc | sort `
else
    echo 'using data'
    set INFILES=`ls ${HYCOMDIR}/${REGION}/expt_${IEXPT}/data/archv*.nc | sort `
endif

foreach INFILE ( ${INFILES} )
    set OUTFILE=./`basename $INFILE nc`nc
    setenv CDF051  ${OUTFILE}
    rm -f ${OUTFILE}
    ${ARCHV2NCDF2D} << EOF
${INFILE}
netCDF
000	'iexpt ' = experiment number x10 (000=from archive file)
 ${YRF} 'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3-actual)
 ${IDM}	'idm   ' = longitudinal array size
 ${JDM}	'jdm   ' = latitudinal  array size
 ${KDM}	'kdm   ' = number of layers
 ${THB}	'thbase' = reference density (sigma units)
  0	'smooth' = smooth fields before plotting (0=F,1=T)
  0	'mthin ' = mask thin layers from plots   (0=F,1=T)
  1	'iorign' = i-origin of plotted subregion
  1	'jorign' = j-origin of plotted subregion
  0	'idmp  ' = i-extent of plotted subregion (<=idm; 0 implies idm)
  0	'jdmp  ' = j-extent of plotted subregion (<=jdm; 0 implies jdm)
 51	'botio ' = bathymetry       I/O unit (0 no I/O)
 51	'flxio ' = surf. heat flux  I/O unit (0 no I/O)
 51	'empio ' = surf. evap-pcip  I/O unit (0 no I/O)
 51	'ttrio ' = surf. temp trend I/O unit (0 no I/O)
 51	'strio ' = surf. saln trend I/O unit (0 no I/O)
  0	'icvio ' = ice coverage     I/O unit (0 no I/O)
  0	'ithio ' = ice thickness    I/O unit (0 no I/O)
  0	'ictio ' = ice temperature  I/O unit (0 no I/O)
 51	'sshio ' = sea surf. height I/O unit (0 no I/O)
 51	'ubtio ' = baro. u. velocity I/O unit (0 no I/O)
 51	'vbtio ' = baro. v. velocity I/O unit (0 no I/O)
 51     'bkeio ' = bar. kin. energy I/O unit (0 no I/O)
 51 	'bsfio ' = baro. strmfn.    I/O unit (0 no I/O)
 51	'uvmio ' = mix. lay. u-vel. I/O unit (0 no I/O)
 51	'vvmio ' = mix. lay. v-vel. I/O unit (0 no I/O)
 51	'spmio ' = mix. lay. speed  I/O unit (0 no I/O)
 51	'bltio ' = bnd. lay. thick. I/O unit (0 no I/O)
 51	'mltio ' = mix. lay. thick. I/O unit (0 no I/O)
 51	'sstio ' = mix. lay. temp.  I/O unit (0 no I/O)
 51	'sssio ' = mix. lay. saln.  I/O unit (0 no I/O)
 51	'ssdio ' = mix. lay. dens.  I/O unit (0 no I/O)
 -1	'kf    ' = first output layer (=0 end output; <0 label with layer #)
 ${KDM}	'kl    ' = last  output layer
 51	'rvoio ' = layer k   vorticity I/O unit (0 no I/O)
 51	'uvlio ' = layer k   u-vel. I/O unit (0 no I/O)
 51	'vvlio ' = layer k   v-vel. I/O unit (0 no I/O)
 51	'splio ' = layer k   speed. I/O unit (0 no I/O)
 51	'iwvio ' = layer k   i.vel. I/O unit (0 no I/O)
 51	'infio ' = layer k   i.dep. I/O unit (0 no I/O)
 51	'thkio ' = layer k   thick. I/O unit (0 no I/O)
 51	'temio ' = layer k   temp   I/O unit (0 no I/O)
 51	'salio ' = layer k   saln.  I/O unit (0 no I/O)
 51 	'tthio ' = layer k   dens,  I/O unit (0 no I/O)
  0	'sfnio ' = layer k  strmfn. I/O unit (0 no I/O)
  0	'kf    ' = first output layer (=0 end output; <0 label with layer #)
EOF
end

# The ncrcat utility is from the nco projects. It concatenates the files produced above
mkdir -p ${OUTPUTDIR}
rm -f ${OUTPUTDIR}/archv.${REGION}.${IEXPT}.nc
ls archv*.nc | sort | ncrcat ${OUTPUTDIR}/archv.${REGION}.${IEXPT}.nc

# clean up:
#rm -rf ${RUNDIR}

