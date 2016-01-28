#!/bin/bash

# Author:  Panagiotis Velissariou <pvelissariou@fsu.edu>
#                                 <velissariou.1@osu.edu>
# Version: 1.1
#
# Version - 1.1 Tue Nov  3 2015
# Version - 1.0 Sun Aug 10 2014


#============================================================
# BEG:: SCRIPT INITIALIZATION
#============================================================

# Make sure that the current working directory is in the PATH
[[ ! :$PATH: == *:".":* ]] && export PATH="${PATH}:."

##########
# Script identification variables
# The script name and the directory where this script is located
scrNAME="$( basename ${0} )"
scrDIR="$( dirname ${0} )"
pushd "${scrDIR}" > /dev/null 2>&1
  scrDIR="$( pwd )"
popd > /dev/null 2>&1

##########
# Source the Utility Functions so they are available
# to this script
if [ -f functions_wps ]; then
  source functions_wps
else
  echo " ### ERROR:: in ${scrNAME}"
  echo "     Cannot load the required file: functions_wps"
  echo "     Exiting now ..."
  echo
  exit 1
fi

WPS_DIR="_WPS_DIR_"
wrfNListFile="namelist.input"
wpsNListFile="namelist.wps"
DateFile="date.dat"
X_FILE_TYPE="GFS SST"
X_VTABLE_NAME="Vtable.GFS Vtable.SST"
MODFILES="_MY_MODFILES_"
USER_CPUS=
HOSTFILE=
REMOVE_DIR=0

FILE_TYPE=( ${X_FILE_TYPE} )
VTABLE_NAME=( ${X_VTABLE_NAME} )

#============================================================
# END:: SCRIPT INITIALIZATION
#============================================================


# ============================================================
# BEG:: CHECK THE INPUT VARIABLES AND REQUIRED FILES
# ============================================================

#----------
# The names of the modulefiles to load (if any).
# If during compilation modules were used to set the paths
# of the compilers/libraries then, the same modules should
# be used/loaded at runtime as well.
#
# Load the requested modules.
LoadEnvModules ${MODFILES}
#----------


#----------
# Check if the workDIR exists and it has write permissions
# for the current user.
if ! `checkDIR -rwx "${1}"` ; then
  procError "required input is missing" \
            "usage: ${scrNAME} work_dir" \
            "Supplied: WORK_DIR = ${1:-UNDEF}"
fi
workDir="${1}"
#----------


#----------
# Determine how to run "metgrid" and "real".
RUN_AS=
if [ ${USER_CPUS:-0} -gt 1 ]; then
  RUN_AS="mpirun -n ${USER_CPUS} -wdir ${workDir}"
  if [ -n "${HOSTFILE:+1}" ]; then
    if `checkFILE -r "${HOSTFILE}"` ; then
      RUN_AS="${RUN_AS:+${RUN_AS} -machinefile ${HOSTFILE}}"
    else
      procWarn "the mpirun hostfile was not found" \
               "we won't use the supplied hostfile:" \
               "HOSTFILE = ${HOSTFILE:-UNDEF}"
    fi
  fi
fi
#----------

# ============================================================
# END:: CHECK THE INPUT VARIABLES AND REQUIRED FILES
# ============================================================


# ============================================================
# BEG:: CALCULATIONS
# ============================================================

pushd "${workDir}" >/dev/null 2>&1
  echo "Working in: ${workDir}"

  ##### Check for the files that contain the list of the required data files
  for ((idat=0; idat<${#FILE_TYPE[@]}; idat++))
  do
    ifl="${FILE_TYPE[${idat}]}"
    if [ ! -f "data_${ifl}.list" ]; then
      procError "the required data list file not found" \
                "this file is essential for the subsequent calculations" \
                "DATA_LIST = "data_${ifl}.list""
    fi
  done

  ##### Check for the namelist files
  for idat in ${wrfNListFile} ${wpsNListFile}
  do
    if [ ! -f "${idat}" ]; then
      procError "could not find the required namelist file:" \
                "NAMELIST_FILE = ${idat:-UNDEF}"
    fi
  done

  ##### Check for the required Table file(s)
  wrf_core="$( echo "`getNameListVar ${wpsNListFile} wrf_core`" | awk '{print $3}' )"

  # Geogrid Table file
  fdir="Geogrid_Tables"
  fstr="GEOGRID.TBL"
  ifl="${wrf_core:+${fstr}.${wrf_core}}"

  if ! `checkFILE -r "${fdir}/${ifl}"` ; then
    procError "could not locate the ${ifl} table file:" \
              "TABLE = ${fdir}/${ifl:-UNDEF}"
  else
    pushd ${fdir} >/dev/null
      linkFILE "${ifl}" "${fstr}"
    popd >/dev/null
  fi

  # Metgrid Table file
  fdir="Metgrid_Tables"
  fstr="METGRID.TBL"
  ifl="${wrf_core:+${fstr}.${wrf_core}}"

  if ! `checkFILE -r "${fdir}/${ifl}"` ; then
    procError "could not locate the ${ifl} table file:" \
              "TABLE = ${fdir}/${ifl:-UNDEF}"
  else
    pushd ${fdir} >/dev/null
      linkFILE "${ifl}" "${fstr}"
    popd >/dev/null
  fi

  # Variable Table file(s)
  for ((idat=0; idat<${#FILE_TYPE[@]}; idat++))
  do
    ifl="${VTABLE_NAME[${idat}]}"
    if ! `checkFILE -r "Variable_Tables/${ifl}"` ; then
      procError "could not locate the ${FILE_TYPE[${idat}]} Vtable file:" \
                "VTABLE = Variable_Tables/${ifl:-UNDEF}"
    fi
  done

  ##### Remove previously created files (sanity)
  rm -f geo_*.d*
  for idat in ${FILE_TYPE[@]}; do rm -f ${idat}:*; done
  rm -f RUNWPS* GRIBFILE.* PFILE:* *.log* met_* namelist.output

  ##### (1) Modify the relevant variables in the namelist files
    ModifyNameListVar ${wpsNListFile} fg_name    "${FILE_TYPE[*]}"
    ModifyNameListVar ${wrfNListFile} sst_skin   "1"
    ModifyNameListVar ${wrfNListFile} usemonalb  ".true."
    if [ "X`echo "${FILE_TYPE[*]}" | grep -i sst`" != "X" ]; then
      ModifyNameListVar ${wrfNListFile} sst_update "1"
    else
      ModifyNameListVar ${wrfNListFile} sst_update "0"
    fi

  ##### (2) Run the "geogrid" program
    echo "  Running geogrid.exe (log files: geogrid_run_wps.log, geogrid.log) ..."
    ./geogrid.exe > geogrid_run_wps.log 2>&1
    FAILURE_STATUS=$?
    [ ${FAILURE_STATUS} -ne 0 ] && \
      procError "geogrid.exe failed"

  ##### (3) Run the "ungrib" program multiple times if needed
    for ((idat=0; idat<${#FILE_TYPE[@]}; idat++))
    do
      # Modify the namelist files
      ModifyNameListVar ${wpsNListFile} prefix "${FILE_TYPE[${idat}]}"

      # Make the link of the corresponding Vtable file
      linkFILE "Variable_Tables/${VTABLE_NAME[${idat}]}" Vtable
    
      # Link the data files
      RUNWPS="RUNWPS_${FILE_TYPE[${idat}]}:"
      rm -f ${RUNWPS}* 
      my_FILES="$( cat data_${FILE_TYPE[${idat}]}.list )"
      if [ -n "${my_FILES:+1}" ]; then
        for ifl in ${my_FILES}
        do
          linkFILE "${ifl}" "${RUNWPS}`basename "${ifl}"`"
        done
      else
        procError "the data list is empty" \
                  "the data list is essential for the subsequent calculations"
      fi

      ./link_grib.csh ${RUNWPS}*
      FAILURE_STATUS=$?
      [ ${FAILURE_STATUS} -ne 0 ] && \
        procError "link_grib.csh failed"

      # Run "ungrib"
      echo "  Running ungrib.exe (log files: ungrib_run_wps_${FILE_TYPE[${idat}]}.log, ungrib.log) ..."
      ./ungrib.exe > ungrib_run_wps_${FILE_TYPE[${idat}]}.log 2>&1
      FAILURE_STATUS=$?
      [ ${FAILURE_STATUS} -ne 0 ] && \
        procError "ungrib.exe failed"

      rm -f ${RUNWPS}* GRIBFILE.* PFILE:*
    done

  ##### (4) Run the "metgrid" program
    echo "  Running metgrid.exe (log files: metgrid_run_wps.log metgrid.log[XXXX]) ..."
    ${RUN_AS} ./metgrid.exe > metgrid_run_wps.log 2>&1
    FAILURE_STATUS=$?
    [ ${FAILURE_STATUS} -ne 0 ] && \
      procError "metgrid.exe failed"

    unset chkMET_LEV chkST_LAY chkMET_FILE chkST_FILE
    mtSTR="num_metgrid_levels"
    stSTR="num_st_layers"
    smSTR="num_sm_layers"
    for imet in met_*.d*.nc
    do
      met_lev="`ncdf_getDim ${imet} ${mtSTR}`"
      [ $? -ne 0 ] && met_lev=
      met_lev=$( echo "${met_lev}" | awk '{print $2}' )

      st_lay="`ncdf_getDim ${imet} ${stSTR}`"
      [ $? -ne 0 ] && st_lay=
      st_lay=$( echo "${st_lay}" | awk '{print $2}' )

      if [ -z "${met_lev}" -o -z "${st_lay}" ]; then
        procError "missing one or both of the required dimensions \"${mtSTR}\" and \"${stSTR}\"" \
                  "FILE: = ${imet}"
      fi

      if [ -z "${chkMET_LEV}" ]; then
        chkMET_LEV=${met_lev}
        chkMET_FILE=${imet}
      else
        if [ ${met_lev} -ne ${chkMET_LEV} ]; then
          procError "inconsistent number of metgrid levels in file: ${imet}" \
                    "Expected: ${mtSTR} = ${chkMET_LEV}" \
                    "    from: ${chkMET_FILE}" \
                    "Got:      ${mtSTR} = ${met_lev}" \
                    "    from: ${imet}"
        fi
      fi

      if [ -z "${chkST_LAY:-}" ]; then
        chkST_LAY=${st_lay}
        chkST_FILE=${imet}
      else
        if [ ${st_lay} -ne ${chkST_LAY} ]; then
          procError "inconsistent number of soil layers in file: ${imet}" \
                    "Expected: ${stSTR} = ${chkST_LAY}" \
                    "    from: ${chkST_FILE}" \
                    "Got:      ${stSTR} = ${st_lay}" \
                    "    from: ${imet}"
        fi
      fi
    done

    # Modify "num_metgrid_levels"
    ModifyNameListVar ${wrfNListFile} num_metgrid_levels "${chkMET_LEV}"

    # Modify "num_metgrid_soil_levels"
    ModifyNameListVar ${wrfNListFile} num_metgrid_soil_levels "${chkST_LAY}"

  ##### (5) Run the "real" program
    echo "  Running real.exe (log files: real_run_wps.log) ..."
    ${RUN_AS} ./real.exe  > real_run_wps.log 2>&1
    FAILURE_STATUS=$?
    [ ${FAILURE_STATUS} -ne 0 ] && \
      procError "real.exe failed"

  ##### (6) Rename the resulting WRF output files
  fileSTR=( $( cat ${DateFile} ) )
  fileSTR="${fileSTR[0]}"
  for idat in wrfbdy_d[0-9][0-9] wrfinput_d[0-9][0-9] wrflowinp_d[0-9][0-9]
  do
    inpFILE="${idat}"
    outFILE="${WPS_DIR:+${WPS_DIR}/}${idat}${fileSTR:+_${fileSTR}}.nc"

    if [ -f ${inpFILE} ]; then
      [ -f ${outFILE} ] && rm -f ${outFILE}
      cp -fp ${inpFILE} ${outFILE}
      FAILURE_STATUS=$?
    fi
  done

  ##### (7) Rename and copy the metgrid files for further use
#  for idat in met_em.d[0-9][0-9]*
#  do
#    inpFILE="${idat}"

#    tmpSTR="$( echo "${inpFILE}" | sed 's/\./ /g' )"
#    outFILE="met_`echo "${tmpSTR}" | awk '{print $2}'`"
#    outFILE="${outFILE}_`echo "${tmpSTR}" | awk '{print $3}'`"
#    outFILE="${WPS_DIR:+${WPS_DIR}/}${outFILE}.`echo "${tmpSTR}" | awk '{print $4}'`"

#    if [ -f ${inpFILE} ]; then
#      [ -f ${outFILE} ] && rm -f ${outFILE}
#      cp -fp ${inpFILE} ${outFILE}
#      FAILURE_STATUS=$?
#    fi
#  done
popd >/dev/null 2>&1

##### Delete the work directory if requested
if [ ${FAILURE_STATUS} -eq 0 -a ${REMOVE_DIR:-0} -gt 0 ]; then
  deleteDIR ${workDir}
fi

# ============================================================
# END:: CALCULATIONS
# ============================================================

exit ${FAILURE_STATUS:-0}
