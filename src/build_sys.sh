#!/bin/bash

# Author:  Panagiotis Velissariou <pvelissariou@fsu.edu>
#                                 <velissariou.1@osu.edu>
# Version: 1.4
#
# Version - 1.4 Wed Nov 11 2015
# Version - 1.3 Thu Jul 30 2015
# Version - 1.2 Sun Jul 28 2013
# Version - 1.1 Wed Feb 27 2013
# Version - 1.0 Wed Jul 25 2012


#============================================================
# BEG:: SCRIPT INITIALIZATION
#============================================================
USE_HYCOM_VER=2.2.77i
#USE_HYCOM_VER=2.2.98ZA

# Make sure that the current working directory is in the PATH
[[ ! :$PATH: == *:".":* ]] && export PATH="${PATH}:."

##########
# Script identification variables
# The script name and the directory where this script is located
scrNAME="$( basename ${0} )"
scrDIR="$( dirname ${0} )"
pushd "${scrDIR}" >/dev/null 2>&1
  scrDIR=$( pwd )
popd >/dev/null 2>&1

##########
# Set/Check the "rootDIR" variable
# This is the directory of the modeling system source code
rootDIR=${rootDIR:=${scrDIR}}

if [ ! -d "${rootDIR}" ]; then
  echo " ### ERROR: in ${scrNAME}"
  echo "       The supplied value for:"
  echo "       rootDIR = ${rootDIR}"
  echo "       is not a valid directory. This variable is essential"
  echo "       for this script to be executed properly."
  echo "     Exiting now ..."
  echo
  exit 1
fi

##########
# Source the Utility Functions so they are available
# to this script
if [ -f functions_build ]; then
  source functions_build
else
  echo " ### ERROR: in ${scrNAME}"
  echo "       Couldn't locate the file <functions_build> that contains"
  echo "       all the necessary utility functions required for this"
  echo "       script to be executed properly."
  echo "     Exiting now ..."
  exit 1
fi

COLORSET=1

#============================================================
# END:: SCRIPT INITIALIZATION
#============================================================


#============================================================
# BEG:: SETTING DEFAULTS AND/OR THE USER INPUT
#============================================================
OCEAN_MODEL_NAME=${OCEAN_MODEL_NAME:-}
MODNAMEBASE=gomfs

Get_LibName

##########
# Source the file pointed by the BUILD_SYS_ENV environment variable
# (if it is set) to get any user defined values. If BUILD_SYS_ENV is
# not set try a file called "build_env" next. We source
# these files before calling ParseArgsBuild below in case the user has
# already set some variables in these files.
unset envISSET
if [ -z "${BUILD_SYS_ENV:-}" ]; then
  srchPATH="./ ${scrDIR} ${rootDIR}
            ${scrDIR}/.. ${scrDIR}/../scripts
            ${rootDIR}/scripts"
  for spath in ${srchPATH}
  do
    if $( checkFILE -r ${spath}/build_env ); then
      source ${spath}/build_env
      export envISSET=1
      break
    fi
  done
  unset spath srchPATH
else
  if $( checkFILE -r "${BUILD_SYS_ENV}" ); then
    source "${BUILD_SYS_ENV}"
    export envISSET=2
  fi
fi

export WRF_OS="${WRF_OS:-$( uname )}"
export WRF_MACH="${WRF_MACH:-$( uname -m )}"
export WRF_EM_CORE="${WRF_EM_CORE:-1}"
export WRF_NMM_CORE="${WRF_NMM_CORE:-0}"

#########
# Call ParseArgsBuild to get any additional user input. They overwrite
# the parameter values set in the environment.
ParseArgsBuild "${@}"

#============================================================
# END:: SETTING DEFAULTS AND/OR THE USER INPUT
#============================================================


#============================================================
# BEG:: CHECK THE VARIABLES
# Check the environment variables and adjust as needed
# User defined environmental variables. See the makefile for
# details on other options the user might want to set here. Be sure to
# leave the switches meant to be off set to an empty string or commented
# out. Any string value (including off) will evaluate to TRUE in
# conditional if-statements.
#============================================================

# ------------------------------------------------------------
# ROMS_APPLICATION should be set in any case.
if [ -z "${ROMS_APPLICATION:-}" ]; then
  procError "The ROMS_APPLICATION variable is not set:" \
            "  ROMS_APPLICATION = ${ROMS_APPLICATION:-UNDEF}" \
            "Use: ${scrNAME} -h, to see all available options"
fi

# ------------------------------------------------------------
# The module file(s) to load (if any).
LoadEnvModules ${MODFILES:-}


# ------------------------------------------------------------
# The Fortran compiler to use.
COMPILER=${COMPILER:-ifort}
Get_Compiler "${COMPILER}"

# ------------------------------------------------------------
# Check for the important modelling system directories.
export MY_ROOT_DIR="${MY_ROOT_DIR:-${rootDIR}}"
export MY_PROJECT_DIR="${MY_PROJECT_DIR:-}"
export MY_ROMS_SRC="${MY_ROMS_SRC:-${MY_ROOT_DIR}}"
export OCN_DIR=$( GetOcnDir )
export WRF_DIR="${WRF_DIR:-${MY_ROMS_SRC:+${MY_ROMS_SRC}/}WRF}"
export WPS_DIR="${WPS_DIR:-${MY_ROMS_SRC:+${MY_ROMS_SRC}/}WPS}"
export SWAN_DIR="${SWAN_DIR:-${MY_ROMS_SRC:+${MY_ROMS_SRC}/}SWAN}"
export SYS_DIR="${SYS_DIR:-${MY_ROMS_SRC:+${MY_ROMS_SRC}/}System}"
export UTIL_DIR="${UTIL_DIR:-${MY_ROMS_SRC:+${MY_ROMS_SRC}/}Utilities}"

Check_SystemDirs

# Get all the models that are active in the coupled system
# that is, OCEAN/WRF/SWAN and the coupling status (yes/no) of the system
SystemActiveModels

# ------------------------------------------------------------
# Get the versions of the modeling components.
# Get the ROMS Version, Revision and Release Date
MY_MOD_DIR="${MY_ROMS_SRC:+${MY_ROMS_SRC}/}ROMS"
if $( checkDIR -rx "${MY_MOD_DIR}" ); then
  if $( checkFILE -r ${MY_MOD_DIR}/Modules/mod_ncparam.F ); then
    ROMS_VER="$( cat ${MY_MOD_DIR}/Modules/mod_ncparam.F | grep -Ei 'version.*=' )"
    ROMS_VER="$( echo "${ROMS_VER}" | sed -e 's/.*[vV][eE][rR][sS][iI][oO][nN].*=//g' )"
    ROMS_VER="$( echo "${ROMS_VER}" | sed -e 's/'\''//g' | awk '{print $1}' | sed -e 's/[vV]//g' )"
  fi
  if $( checkFILE -r ${MY_MOD_DIR}/Version ); then
    ROMS_REV="$( cat ${MY_MOD_DIR}/Version | grep -Ei revision: )"
    ROMS_REV="$( echo "${ROMS_REV}" | sed -e 's/.*[rR][eE][vV][iI][sS][iI][oO][nN]//g' )"
    ROMS_REV="$( echo "${ROMS_REV}" | sed -e 's/[=;:,_()\{\}\$\\]/ /g' | awk '{print $1}' )"
    ROMS_DATE="$( cat ${MY_MOD_DIR}/Version | grep -Ei changeddate: | sed -e 's/.*[aA][tT][eE]://g' )"
    ROMS_DATE="$( echo "${ROMS_DATE}" | sed -e 's/\$//g' | awk '{print $1}' )"
    ROMS_DATE="$( getDate --date="${ROMS_DATE}" --fmt='+%m-%d-%Y' )"
  fi
fi
unset MY_MOD_DIR

# Get the HYCOM Version, Revision and Release Date
MY_MOD_DIR="${MY_ROMS_SRC:+${MY_ROMS_SRC}/}HYCOM"
if $( checkDIR -rx "${MY_MOD_DIR}" ); then
  HYCOM_VER=${USE_HYCOM_VER:-2.2.77i}
  #HYCOM_VER==${USE_HYCOM_VER:-2.2.98ZA}

  HYCOM_SRC="${MY_MOD_DIR}/src_${HYCOM_VER}"
  if $( checkDIR -rx "${HYCOM_SRC}" ); then
    case "${HYCOM_VER}" in
      "2.2.77i")
        HYCOM_REV=
        HYCOM_DATE="$( getDate --date="2012-01-11" --fmt='+%m-%d-%Y' )"
        ;;
      "2.2.98ZA")
        HYCOM_REV=
        HYCOM_DATE="$( getDate --date="2015-03-04" --fmt='+%m-%d-%Y' )"
        ;;
      *)
        unset HYCOM_VER HYCOM_REV HYCOM_DATE
        ;;
    esac
  fi
fi
unset HYCOM_SRC MY_MOD_DIR

# Get the WRF Version
if $( checkDIR -rx "${WRF_DIR}" ); then
  if $( checkFILE -r ${WRF_DIR}/inc/version_decl ); then
    WRF_VER="$( cat ${WRF_DIR}/inc/version_decl | grep -Ei release_version )"
    WRF_VER="$( echo "${WRF_VER}" | sed -e 's/.*[vV][eE][rR][sS][iI][oO][nN].*=//g' )"
    WRF_VER="$( echo "${WRF_VER}" | sed -e 's/'\''//g' | awk '{print $1}' | sed -e 's/[vV]//g' )"
  fi
  if $( checkFILE -r ${WRF_DIR}/README ); then
    if [ -n "${WRF_VER:+1}" ]; then
      WRF_DATE="$( cat ${WRF_DIR}/README | grep -Ei "^WRF.*Version.*${WRF_VER}.*" | sed -e "s/.*${WRF_VER}//g" )"
      WRF_DATE="$( echo ${WRF_DATE} | sed -e 's/[=;,_()\{\}\\]/ /g' )"
      WRF_REV="$( cat ${WRF_DIR}/README | grep -Ei "Version.*${WRF_VER}.*released on " | sed -e 's/.*[rR][eE][vV]//g' )"
      WRF_REV="$( echo "${WRF_REV}" | sed -e 's/[=;,_()\{\}\\]/ /g' | awk '{print $1}' )"
    fi
    WRF_DATE="$( getDate --date="${WRF_DATE}" --fmt='+%m-%d-%Y' )"
  fi
fi

# Get the WPS Version
if $( checkDIR -rx "${WPS_DIR}" ); then
  if $( checkFILE -r ${WPS_DIR}/README ); then
    WPS_STR=
    WPS_STR="$( cat ${WPS_DIR}/README | grep -Ei "Pre-Processing System Version" )"
    WPS_STR="$( echo ${WPS_STR} | sed -e 's/[=;,_()\{\}\\]/ /g' )"
    WPS_VER="$( echo ${WPS_STR} | sed -e 's/.*[vV][eE][rR][sS][iI][oO][nN]//g' | awk '{print $1}' )"
    if [ -n "${WPS_VER:+1}" ]; then
      WPS_DATE="$( echo ${WPS_STR} | sed -e "s/.*[vV][eE][rR][sS][iI][oO][nN].*${WPS_VER}//g" )"
      WPS_DATE="$( echo ${WPS_DATE} | sed -e "s/[rR][eE][vV].*//g" )"
      WPS_REV="$( echo ${WPS_STR} | sed -e "s/.*[rR][eE][vV][iI][sS][iI][oO][nN]//g" | awk '{print $1}' )"
      unset WPS_STR
    fi
    WPS_DATE="$( getDate --date="${WPS_DATE}" --fmt='+%m-%d-%Y' )"
    unset WPS_STR
  fi
fi

# Get the SWAN Version
if $( checkDIR -rx "${SWAN_DIR}" ); then
  if $( checkFILE -r ${SWAN_DIR}/Src/swanmain.F ); then
    SWAN_VER="$( cat ${SWAN_DIR}/Src/swanmain.F | grep -Ei ".*VERNUM.*=" )"
    SWAN_VER="$( echo "${SWAN_VER}" | sed -e 's/.*[vV][eE][rR][nN][uU][mM].*=//g' | awk '{print $1}' )"
  fi
  if $( checkFILE -r ${SWAN_DIR}/Src/swanuse.tex ); then
    if [ -n "${SWAN_VER:+1}" ]; then
      SWAN_DATE="$( cat ${SWAN_DIR}/Src/swanuse.tex | grep -Ei "\(Version.*${SWAN_VER}" | sort -u )"
      SWAN_DATE="$( echo ${SWAN_DATE} | sed -e 's/.*([vV][eE][rR][sS][iI][oO][nN].*,//g' | sed -e 's/[(),.]//g' )"
      SWAN_DATE="$( echo ${SWAN_DATE} | awk '{print $1 " 1, " $2}' )"
    fi
    SWAN_DATE="$( getDate --date="${SWAN_DATE}" --fmt='+%m-%d-%Y' )"
  fi
fi

# ------------------------------------------------------------
# Check for an MPI/OpenMP setup
if [ "${USE_MPI:-no}" = "yes" ] && [ "${USE_OpenMP:-no}" = "yes" ]; then
  procError "   USE_MPI = ${USE_MPI}" \
            "USE_OpenMP = ${USE_OpenMP}" \
            "Only one of the USE_MPI/USE_OpenMP variables can be set" \
            "Please adjust your command line or the environment file accordingly"
fi

if [ "${USE_MPI:-no}" = "no" ]; then
  unset USE_MPI
  unset USE_MPIF90
  unset USE_PNETCDF
  unset USE_PARALLEL_IO
else
  # force the use of mpif90 when USE_MPI="yes"
  USE_MPIF90="yes"
  Get_MpiCompiler "mpif90"
  if [ "${USE_PARALLEL_IO:-no}" = "yes" ]; then
    USE_PNETCDF=yes
    USE_NETCDF4=yes
    unset USE_NETCDF3
  else
    unset USE_PNETCDF
  fi
fi

[ "${USE_NETCDF4:-no}" = "yes" -o "${USE_PNETCDF:-no}" = "yes" -o "${USE_PARALLEL_IO:-no}" = "yes" ] && \
  unset USE_NETCDF3

# ------------------------------------------------------------
# Get the path of the NetCDF headers and libraries
Get_NetCDFPath
if [ "$?" -ne 0 ]; then
  procError "No suitable NetCDF header/libraries found in the system" \
            "User/Script variables used:" \
            "    USE_NETCDF3 = ${USE_NETCDF3:-no}" \
            "    USE_NETCDF4 = ${USE_NETCDF4:-no}" \
            " NETCDF_VERSION = ${NETCDF_VERSION:-UNDEF}" \
            "    NETCDF_ROOT = ${NETCDF_ROOT:-UNDEF}" \
            "      NC_CONFIG = ${NC_CONFIG:-UNDEF}" \
            "  NETCDF_INCDIR = ${NETCDF_INCDIR:-UNDEF}" \
            "  NETCDF_LIBDIR = ${NETCDF_LIBDIR:-UNDEF}" \
            "NETCDF_PARALLEL = ${NETCDF_PARALLEL:-no}"
fi

# ------------------------------------------------------------
# Get the path of the NetCDF headers and libraries
Get_MCTPath
if [ "$?" -ne 0 ]; then
  procError "No suitable MCT header/libraries found in the system" \
            "User/Script variables used:" \
            "     USE_MCT = ${USE_MCT:-no}" \
            " MCT_VERSION = ${MCT_VERSION:-UNDEF}" \
            "    MCT_ROOT = ${MCT_ROOT:-UNDEF}" \
            "  MCT_INCDIR = ${MCT_INCDIR:-UNDEF}" \
            "  MCT_LIBDIR = ${MCT_LIBDIR:-UNDEF}" \
            "MCT_PARALLEL = ${MCT_PARALLEL:-no}"
fi

# ------------------------------------------------------------
# Get the path of the HDF5 headers and libraries (possibly for parallel IO)
Get_HDF5Path
if [ "$?" -ne 0 ]; then
  procError "No suitable HDF5 header/libraries found in the system" \
            "User/Script variables used:" \
            "    NETCDF_ROOT = ${NETCDF_ROOT:-UNDEF}" \
            "      NC_CONFIG = ${NC_CONFIG:-UNDEF}" \
            "  NETCDF_INCDIR = ${NETCDF_INCDIR:-UNDEF}" \
            "  NETCDF_LIBDIR = ${NETCDF_LIBDIR:-UNDEF}" \
            " NETCDF_VERSION = ${NETCDF_VERSION:-UNDEF}" \
            "NETCDF_PARALLEL = ${NETCDF_PARALLEL:-no}" \
            "USE_PARALLEL_IO = ${USE_PARALLEL_IO:-no}" \
            "    USE_PNETCDF = ${USE_PNETCDF:-no}" \
            "       USE_HDF5 = ${USE_HDF5:-no}" \
            "      HDF5_ROOT = ${NETCDF_ROOT:-UNDEF}" \
            "    HDF5_INCDIR = ${HDF5_INCDIR:-UNDEF}" \
            "    HDF5_LIBDIR = ${HDF5_LIBDIR:-UNDEF}" \
            "   HDF5_VERSION = ${HDF5_VERSION:-UNDEF}" \
            "  HDF5_PARALLEL = ${HDF5_PARALLEL:-no}"
fi

# ------------------------------------------------------------
# Get the path of the PNetCDF headers and libraries
Get_PNetCDFPath
if [ "$?" -ne 0 ]; then
  procError "No suitable PNetCDF header/libraries found in the system" \
            "User/Script variables used:" \
            "    NETCDF_ROOT = ${NETCDF_ROOT:-UNDEF}" \
            "      NC_CONFIG = ${NC_CONFIG:-UNDEF}" \
            "  NETCDF_INCDIR = ${NETCDF_INCDIR:-UNDEF}" \
            "  NETCDF_LIBDIR = ${NETCDF_LIBDIR:-UNDEF}" \
            " NETCDF_VERSION = ${NETCDF_VERSION:-UNDEF}" \
            "NETCDF_PARALLEL = ${NETCDF_PARALLEL:-no}" \
            "USE_PARALLEL_IO = ${USE_PARALLEL_IO:-no}" \
            "    USE_PNETCDF = ${USE_PNETCDF:-no}" \
            "PNETCDF_VERSION = ${PNETCDF_VERSION:-UNDEF}" \
            "   PNETCDF_ROOT = ${NETCDF_ROOT:-UNDEF}" \
            " PNETCDF_INCDIR = ${PNETCDF_INCDIR:-UNDEF}" \
            " PNETCDF_LIBDIR = ${PNETCDF_LIBDIR:-UNDEF}"
fi

# ------------------------------------------------------------
# Get the path of the Jasper headers and libraries
# if requested.

if [ "${USE_JASPER:-no}" = "yes" ]; then
  theFiles="jasper.h jas_version.h"
  Check_Includes "${JASPER_INCDIR}" "${theFiles}" warning
  if [ $? -ne 0 ]; then
    unset JASPER_INCDIR
    procError "The Jasper headers not found"
  fi

  theFiles="libjasper.*"
  Check_Libraries "${JASPER_LIBDIR}" "${theFiles}" warning
  if [ $? -ne 0 ]; then
    unset JASPER_LIBDIR
    procError "The Jasper libraries not found"
  fi
else
  unset JASPER_ROOT JASPER_INCDIR JASPER_LIBDIR
fi

# ------------------------------------------------------------
# Get the path of the NCARG headers and libraries
# if requested.

if [ "${USE_NCL:-no}" = "yes" ]; then
  theFiles="libncarg.* libncarg_gks.* libncarg_c.*"
  Check_Libraries "${NCL_LIBDIR}" "${theFiles}" warning
  if [ $? -ne 0 ]; then
    unset NCL_LIBDIR
    procError "The NCAR libraries not found"
  fi
else
  unset NCL_ROOT NCL_INCDIR NCL_LIBDIR
fi

# ------------------------------------------------------------
# Make sure that all variables are set correctly
SystemDefaults

Adjust_YESNOVars

ExportSystemEnvVars

#============================================================
# END:: CHECK THE VARIABLES
#============================================================


#============================================================
# BEG:: ECHO THE FINAL VALUES OF THE ASSIGNED PARAMETERS
#       AND THE USER'S RESPONSE
#============================================================

Print_Vars
echo

checkOceanModels

echo -n "Are these values correct? [y/n]: "
echo_response=
while [ -z "${echo_response}" ] ; do
  read echo_response
  echo_response="$( getYesNo "${echo_response}" )"
done

if [ "${echo_response:-no}" = "no" ]; then
  echo
  echo "User responded: ${echo_response}"
  echo "Exiting now ..."
  echo
  exit 1
fi

unset echo_response

#============================================================
# END:: ECHO THE FINAL VALUES OF THE ASSIGNED PARAMETERS
#       AND THE USER'S RESPONSE
#============================================================


#============================================================
# BEG:: START THE COMPILATION
#============================================================

ulimit -s unlimited

# ------------------------------------------------------------
# Get the active status of all supported ocean models (to be used later)
getOceanModels
  models=( ${ocnMODELS} )
use_mods=( ${ocnUSEMODS} )
val_mods=( ${ocnUSEVALS} )

# ------------------------------------------------------------
# These are for forcing the model to use the *_INCDIR and *_LIBDIR variables
unset USE_NETCDF3
unset USE_NETCDF4
unset NETCDF
unset USE_PNETCDF
unset PNETCDF

VER_STR=
if [ "${VERSIONING:-0}" -gt 0 ]; then
  VER_STR="${USE_PARALLEL_IO:+-pio}"
  VER_STR="${VER_STR}${COMPSYS:+-${COMPSYS}}${MPISYS:+-${MPISYS}${MPIVER:+-${MPIVER}}}"
  VER_STR="${VER_STR#-}"
fi
EXE_STR="${CASEID:-}${VER_STR:+-${VER_STR}}"
EXE_STR="${EXE_STR#-}"
export VER_STR EXE_STR

# ------------------------------------------------------------
# Create the final name of the resulting executable
# (A) Get the model(s) suffix
if [ -n "${USE_MPI:+1}" ]; then
  mod_sfx=M
elif [ -n "${USE_OpenMP:+1}" ]; then
  mod_sfx=O
elif [ -n "${USE_DEBUG:+1}" ]; then
  mod_sfx=G
else
  mod_sfx=S
fi

# (B) Get the model(s) identification
mod_ids=
for ((i = 0; i < ${#models[@]}; i++))
do
  if [ "${val_mods[${i}]:-no}" = "yes" ]; then
    mod_ids=${models[${i}]:0:1}
    break
  fi
done
[ -n "${USE_WRF:+1}"  ] && mod_ids=${mod_ids}W
[ -n "${USE_SWAN:+1}" ] && mod_ids=${mod_ids}S
[ -n "${USE_SED:+1}"  ] && mod_ids=${mod_ids}D
[ -n "${USE_ICE:+1}"  ] && mod_ids=${mod_ids}I

# (C) Get the model's full name
if [ -n "${USE_WRF:+1}" -a -z "${COUPLED_SYSTEM:-}" ]; then
  model_name=wrf
  model_exe=wrf${EXE_STR:+-${EXE_STR}}.exe
else
  model_name=${MODNAMEBASE}${mod_sfx}${mod_ids}
  model_exe=${model_name}${EXE_STR:+-${EXE_STR}}
fi


########## BEG:: CREATE MAKEFILE
# Modify the makefile-tmpl and create the makefile
INP_MAKE=makefile-tmpl
if $( checkFILE -r ${INP_MAKE} ); then
  [ -f makefile ] && rm -f makefile
  cp -f ${INP_MAKE} makefile
  for imod in S G M O wrf.exe
  do
    if [ "${imod}" = "wrf.exe" ]; then
      imod_n="$( echo ${imod%.exe} )${EXE_STR:+-${EXE_STR}}.exe"
      perl -pi -e  "s@\\$\(BINDIR\)/${imod_n}@\\$\(BINDIR\)/${imod_n}@g" \
        makefile
    else
      imod_n="${MODNAMEBASE}${imod}${mod_ids}${EXE_STR:+-${EXE_STR}}"
      perl -pi -e  "s@\\$\(BINDIR\)/_name_${imod}@\\$\(BINDIR\)/${imod_n}@g" \
        makefile
    fi
  done
else
  procError "The template makefile: ${INP_MAKE}" \
            "is not found. This file is required for" \
            "the compilation of the modeling components."
fi
########## END:: CREATE MAKEFILE


########## BEG:: CLEANONLY
if [ ${CLEANONLY:-0} -gt 0 ]; then
  CLEAN=1
  CLEANWRF=1
  CLEANWPS=1
  CLEANUTIL=1
  export CLEAN CLEANWRF CLEANWPS CLEANUTIL

  pushd ${MY_ROMS_SRC} >/dev/null 2>&1
    Clean_UTILFiles
    Clean_WRF

    make clean

    for ifile in ${MODNAMEBASE:-UNDEF}[MOGS]* wrf.exe*
    do
      if $( checkPROG -r "${ifile}" ); then
        rm -f ${ifile}
      fi
    done

    # Remove the modified makefile
    [ -f makefile ] && rm -f makefile
  popd >/dev/null 2>&1

  exit 0
fi
########## END:: CLEANONLY


########## BEG:: DO_COMPILE
if [ ${DO_COMPILE:-1} -gt 0 ]; then
  # Compile (the binaries will go to BINDIR set above).
  # (BINDIR is internally set to be: BINDIR=MY_ROMS_SRC).
  pushd ${MY_ROMS_SRC} >/dev/null 2>&1

    # Make link HYCOM/src to real HYCOM version used
    if [ -n "${USE_HYCOM:+1}" ]; then
      my_file="HYCOM/src_${HYCOM_VER}/hycom.F"
      if $( checkFILE -r "${my_file}" ); then
        [ -f "Master/hycom.F" ] && rm -f Master/hycom.F
        cp -f ${my_file} Master/
      else
        procError "The source file \"${my_file}\" does not exist or," \
                  "permissions are not valid for the current user." \
                  "This file is essential for a successful compilation of HYCOM."
      fi

      linkFILE HYCOM/src_${HYCOM_VER} HYCOM/src
    fi

    # Make a backup copy of the model binary.
    [ -f "${BINDIR}/${model_exe}" ] && \
      mv -f ${BINDIR}/${model_exe} ${BINDIR}/${model_exe}.backup

    # Clean in the source directory.
    Clean_WRF
    for imod in ${SUPPORTED_OCEAN_MODELS}
    do
        command -v Clean_${imod} >/dev/null 2>&1 && \
      Clean_${imod}
    done

    # Configure WRF/WPS (only if USE_WRF or BUILD_WPS are set).
    Configure_WRF
    [ $? -ne 0 ] && \
      procError "WRF configuration failed"

    if [ -n "${USE_WRF:+1}" ]; then
      # Compile WRF.
      make ${PARMAKE_NCPUS:+-j ${PARMAKE_NCPUS}} wrf
      [ $? -ne 0 ] && \
        procError "WRF compilation failed"

      # Compile in the WPS directory. This has to be done after WRF
      # has been compiled successfully.
      if [ -n "${BUILD_WPS:+1}" ]; then
        pushd ${WPS_DIR} >/dev/null 2>&1

          # Compile WPS
          ./compile wps
          [ $? -ne 0 ] && \
            procError "WPS compilation failed"

          # Compile WPS utilities
          ./compile util
          [ $? -ne 0 ] && \
            procError "WPS utilities compilation failed"
        popd >/dev/null 2>&1
      fi
    fi

    # Compile the Ocean Model
    make ${PARMAKE_NCPUS:+-j ${PARMAKE_NCPUS}}
      [ $? -ne 0 ] && \
        procError "OCEAN/WAVE compilation failed"

    # Remove the modified makefile
    #[ -f makefile ] && rm -f makefile
  popd >/dev/null 2>&1
fi
########## END:: DO_COMPILE


########## BEG:: BUILD IN UTILITIES DIRECTORY
if $( checkDIR -rwx "${UTIL_DIR:-}" ); then
  if [ -n "${USE_HYCOM:+1}" ]; then
    # Compile in the Utilities/hycom directory.
    # Build the hycom utilities only if USE_HYCOM is set.
    # This compilation is independent of HYCOM and can be done
    # outside the compilation of the modeling components.
    # Compiled binaries and scripts are installed in UTIL_DIR/hycom/Build.
    # This needs to be done just once.
    dir_inp=${UTIL_DIR}/hycom
    if $( checkDIR -rwx "${dir_inp}" ); then
      pushd "${dir_inp}" >/dev/null 2>&1
        [ ${CLEANUTIL} -gt 0 ] && \
          make realclean

        make install
        [ $? -ne 0 ] && \
          procError "HYCOM utilities compilation failed"
      popd >/dev/null 2>&1
    fi
  fi

  if [ -n "${BUILD_UTIL:+1}" ]; then
    # Compile in the Utilities/scrip directory.
    # Build the scrip utilities if BUILD_UTIL is set.
    # Binaries and scripts are installed in UTIL_DIR/scrip/Build.
    # This needs to be done just once.
    dir_inp=${UTIL_DIR}/scrip
    if $( checkDIR -rwx "${dir_inp}" ); then
      pushd "${dir_inp}" >/dev/null 2>&1
        [ ${CLEANUTIL} -gt 0 ] && \
          make realclean

        make install
        [ $? -ne 0 ] && \
          procError "SCRIP compilation failed"
      popd >/dev/null 2>&1
    fi
  fi

  # Compile in the Utilities/parallel directory.
  # Build the parallel utilities (required for all builds).
  # Binaries and scripts are installed in UTIL_DIR/parallel/Build.
  # This needs to be done just once.
  dir_inp=${UTIL_DIR}/parallel
  if $( checkDIR -rwx "${dir_inp}" ); then
    pushd "${dir_inp}" >/dev/null 2>&1
      [ ${CLEANUTIL} -gt 0 ] && \
        make realclean

      make install
      [ $? -ne 0 ] && \
        procError "GNU Parallel compilation failed"
    popd >/dev/null 2>&1
  fi

else
  procWarn "Please modify the variables UTIL_DIR." \
           "The utilities directory UTIL_DIR is not accessible:" \
           "  BUILD_UTIL = ${BUILD_UTIL:-no}" \
           "    UTIL_DIR = ${UTIL_DIR:-UNDEF}" \
           "Compilation in the utilities directory is abandoned."
fi # BUILD_UTIL
########## END:: BUILD IN UTILITIES DIRECTORY


########## BEG:: INSTALL MODEL BINARIES, UTILITY BINARIES, SCRIPTS AND DATA
if [ "${MY_PROJECT_DIR}" != "${MY_ROMS_SRC}" ]; then
  if [ "${BINDIR}" != "${MY_PROJECT_DIR}" ]; then
    install -m 0755 -p "${BINDIR}/${model_exe}" "${MY_PROJECT_DIR}/${model_exe}"
  fi

  # ------------------------------------------------------------
  # Install model binaries and data.
  for imod in ${ocnMODELS}
  do
    command -v Install_${imod}Files >/dev/null 2>&1 && \
      Install_${imod}Files
  done

  Install_WRFFiles
  Install_WPSFiles
  Install_SWANFiles
  Install_SEDFiles

  Install_UTILFiles

  # ------------------------------------------------------------
  # Install helper files and data.
  dir_inp=${SYS_DIR:-System}/scripts
  dir_out=${MY_PROJECT_DIR}
  files="functions_common functions_run"
  for ifile in ${files}
  do
    file_inp=${dir_inp}/${ifile}
    file_out=${dir_out}/${ifile}

    if $( checkFILE -r "${file_inp}" ); then
      echo "Installing -> ${file_out}"
      install -m 0644 -p ${file_inp} ${file_out}
    else
      procError "Couldn't install the required file:" \
                "  File = ${file_inp:-UNDEF}"
    fi
  done

  if [ -n "${COUPLED_SYSTEM:+1}" ]; then
    dir_inp=${SYS_DIR:-System}/inputs
    dir_out=${MY_PROJECT_DIR}
    files="coupling.in"
    for ifile in ${files}
    do
      file_inp=${dir_inp}/sample-${ifile}-tmpl
      file_out=${dir_out}/${ifile}-tmpl

      if $( checkFILE -r "${file_inp}" ); then
        if $( checkFILE "${file_out}" ); then
          file_out=${file_out}.new
        fi
        echo "Installing -> ${file_out}"
        install -m 0644 -p ${file_inp} ${file_out}
      else
        procWarn "Couldn't install the file:" \
                  "  File = ${file_inp:-UNDEF}"
      fi
    done
  fi

  # ------------------------------------------------------------
  # Create and install the models_env file.
  dir_inp=${SYS_DIR:-System}/env
  dir_out=${MY_PROJECT_DIR}
  files="models_env"
  for ifile in ${files}
  do
    file_inp=${dir_inp}/${ifile}-tmpl
    file_out=${dir_out}/${ifile}
    if $( checkFILE -r "${file_inp}" ); then
      if $( checkFILE -r "${file_out}" ); then
        file_out=${file_out}.new
      fi
      Make_MODELEnv "${file_inp}" "${file_out}"
    else
      procWarn "Couldn't install the script:" \
                "  Env. File = ${file_inp:-UNDEF}"
    fi
  done

  # ------------------------------------------------------------
  # Create and install the model run scripts.
  dir_inp=${SYS_DIR:-System}/scripts
  dir_out=${MY_PROJECT_DIR}
  files="mpirun msub slurm"
  for ifile in ${files}
  do
    file_inp=${dir_inp}/script_${ifile}-tmpl
    file_out=${dir_out}/${ifile}${model_name:+-${model_name}}.sh
    if $( checkFILE -r "${file_inp}" ); then
      if $( checkFILE -r "${file_out}" ); then
        file_out=${file_out}.new
      fi
      Make_RUNScripts "${file_inp}" "${file_out}"
    else
      procWarn "Couldn't install the script:" \
                "  Script = ${file_inp:-UNDEF}"
    fi
  done
else
  procWarn "Please modify your variables MY_PROJECT_DIR/MY_ROMS_SRC." \
           "The destination directory MY_PROJECT_DIR points to the source directory:" \
           "  MY_PROJECT_DIR = ${MY_PROJECT_DIR:-UNDEF}" \
           "     MY_ROMS_SRC = ${MY_ROMS_SRC:-UNDEF}" \
           "Installation of binaries and data files is abandoned."
fi
########## END:: INSTALL MODEL BINARIES, SCRIPTS AND DATA
