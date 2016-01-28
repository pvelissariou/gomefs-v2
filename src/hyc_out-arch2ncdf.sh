#!/bin/bash

# Author:  Panagiotis Velissariou <pvelissariou@fsu.edu>
#                                 <velissariou.1@osu.edu>
# Version: 1.0
#
# Version - 1.0 Mon Aug 31 2015


# The script name and the directory where this script is located
scrNAME="$( basename ${0} )"
scrDIR="$( dirname ${0} )"
pushd ${scrDIR} > /dev/null 2>&1
  scrDIR="$( pwd )"
popd > /dev/null 2>&1


#------------------------------------------------------------
# UTILITY FUNCTIONS
#
[[ ! :$PATH: == *:".":* ]] && export PATH="${PATH}:."

if [ -f "functions_cast" ]; then
  source functions_cast
else
  echo " ### ERROR: in ${scrNAME}"
  echo "     Cannot locate the file: functions_cast"
  echo "     Exiting now ..."
  echo
  exit 1
fi
#------------------------------------------------------------


#------------------------------------------------------------
##### The name of the filename of main model input file.
#     This file should exist and be readable by the current user.
MODEL_INP="${MODEL_INP:-blkdat.input}"

ParseArgs "${@}"
#------------------------------------------------------------


#------------------------------------------------------------
# BEG:: Calculations
unset FAILURE_STATUS
unset FileLUN FileLST DateLST JulLST

FILE_PFX="${FILE_PFX:-ocn_his_}"
FILE_SFX="${FILE_SFX:-a}"
FILE_TYPE="${FILE_TYPE:-archv}"
DATA_DIR="${DATA_DIR:-Output}"

theMODEL="HYCOM"
theSCRIPT="convert_${theMODEL:+${theMODEL}_}${FILE_TYPE}2ncdf"


############################################################
##### Create the list of input data files
# (A) First try to use the start/end simulation dates if
#     they are defined (user input)
SimBeg=$( getDate --date="${SimBeg:-UNDEF}" --fmt='+%F_%T' )
  [ $? -ne 0 ] && unset SimBeg
SimEnd=$( getDate --date="${SimEnd:-UNDEF}" --fmt='+%F_%T' )
  [ $? -ne 0 ] && unset SimEnd

if [ -n "${SimBeg:+1}" ] || [ -n "${SimEnd:+1}" ]; then
  # The minus sign needs to be at the start or at the end of the
  # regular expression to be matched otherwise you get the "range"
  # error message
  expr="[[:space:].:_-]"
  x_date="$( getDateStrExpr ${DATE_FMT:-YMDH} )"
    [ $? -ne 0 ] && procError "${x_date}"

  x_file="^${FILE_PFX}.*${FILE_TYPE:+${FILE_TYPE}.*}"
  x_file="${x_file}${x_date:+${x_date}.*}${FILE_SFX:+\.${FILE_SFX}}$"

  # Get the file list based on the date regular expression x_date
  FileLST="$( echo $( ls "${DATA_DIR}" 2>/dev/null | \
                      egrep "${x_file}" 2>/dev/null  | sort -u ) )"
  FileLST="$( strTrim "${FileLST}" 2 )"

  # Continue only if FileLST is not empty
  if [ -n "${FileLST:+1}" ]; then
    # Get the date string from the filename based on the
    # date regular expression x_date
    DateLST="$( echo $( echo "${FileLST}" | \
                        egrep -o "${x_date}" | sed "s/${expr}//g" ) )"
    DateLST="$( strTrim "${DateLST}" 2 )"

    FileLST=( ${FileLST} )
    DateLST=( ${DateLST} )

    if [ ${#FileLST[@]} -eq ${#DateLST[@]} ]; then
      rflag=-1
      [ -n "${SimBeg:+1}" ] && \
        [ -n "${SimEnd:+1}" ] && rflag=1
      [ -n "${SimBeg:+1}" ] && \
        [ -z "${SimEnd:-}" ] && rflag=2
      [ -z "${SimBeg:-}" ] && \
        [ -n "${SimEnd:+1}" ] && rflag=3

      unset file_list
      case ${rflag} in
        1)
          # Get the begin date (an integer number, according to x_date)
          b_date="$( echo $( echo "${SimBeg}" | \
                             egrep -o "${x_date}" | sed "s/${expr}//g" ) )"

          # Get the end date (an integer number, according to x_date)
          e_date="$( echo $( echo "${SimEnd}" | \
                             egrep -o "${x_date}" | sed "s/${expr}//g" ) )"

          for ((i = 0; i < ${#FileLST[@]}; i++))
          do
            if [ ${DateLST[${i}]} -ge ${b_date} ] && \
               [ ${DateLST[${i}]} -le ${e_date} ]; then
              file_list="${file_list} ${FileLST[${i}]}"
            fi
          done

          file_list="$( strTrim "${file_list}" 2 )"
          unset FileLST
          if [ -n "${file_list:+1}" ]; then
            file_list=( ${file_list} ) # Make file_list an array for the next line
            FileLST="${file_list[@]/#/${DATA_DIR:+${DATA_DIR}/}}"
          fi
        ;;
        2)
          # Get the begin date (an integer number, according to x_date)
          b_date="$( echo $( echo "${SimBeg}" | \
                             egrep -o "${x_date}" | sed "s/${expr}//g" ) )"

          for ((i = 0; i < ${#FileLST[@]}; i++))
          do
            if [ ${DateLST[${i}]} -ge ${b_date} ]; then
              file_list="${file_list} ${FileLST[${i}]}"
            fi
          done

          file_list="$( strTrim "${file_list}" 2 )"
          unset FileLST
          if [ -n "${file_list:+1}" ]; then
            file_list=( ${file_list} ) # Make file_list an array for the next line
            FileLST="${file_list[@]/#/${DATA_DIR:+${DATA_DIR}/}}"
          fi
        ;;
        3)
          # Get the end date (an integer number, according to x_date)
          e_date="$( echo $( echo "${SimEnd}" | \
                             egrep -o "${x_date}" | sed "s/${expr}//g" ) )"

          for ((i = 0; i < ${#FileLST[@]}; i++))
          do
            if [ ${DateLST[${i}]} -le ${e_date} ]; then
              file_list="${file_list} ${FileLST[${i}]}"
            fi
          done

          file_list="$( strTrim "${file_list}" 2 )"
          unset FileLST
          if [ -n "${file_list:+1}" ]; then
            file_list=( ${file_list} ) # Make file_list an array for the next line
            FileLST="${file_list[@]/#/${DATA_DIR:+${DATA_DIR}/}}"
          fi
        ;;
        *) unset FileLST ;; # DEFAULT
      esac
    else
      procWarn "Inconsistent number of array elements" \
               "  Number of Input Filenames: ${#FileLST[@]}" \
               "  Number of Input Filedates: ${#DateLST[@]}" \
               "Reverting to full file listing ..."
      unset FileLST DateLST
    fi
  fi # FileLST
fi # SimBeg, SimEnd


# (B) In case code block (A) were not used or failed (FileLST = empty)
#     proceed with this code block to get the full file listing
if [ -z "${FileLST:-}" ]; then
  x_file="^${FILE_PFX}.*${FILE_TYPE:+${FILE_TYPE}.*}"
  x_file="${x_file}${FILE_SFX:+\.${FILE_SFX}}$"

  FileLST="$( echo $( ls "${DATA_DIR}" 2>/dev/null | \
                      egrep "${x_file}" 2>/dev/null  | sort -u ) )"

  FileLST="$( strTrim "${FileLST}" 2 )"
  FileLST=( ${FileLST} ) # Make FileLST an array for the next line
  FileLST="${FileLST[@]/#/${DATA_DIR:+${DATA_DIR}/}}"
fi


if [ -n "${FileLST:+1}" ]; then
  echo "        Converting the \"${theMODEL:-MODEL}\" ${FILE_TYPE:-arch[X]} files to NetCDF format ..."
else
  procError "No ${FILE_TYPE} files for \"${theMODEL}\" were found in:" \
            "   DATA_DIR = ${DATA_DIR:-UNDEF}" \
            "   FILE_PFX = ${FILE_PFX:-UNDEF}" \
            "   FILE_SFX = ${FILE_SFX:-UNDEF}" \
            "  FILE_TYPE = ${FILE_TYPE:-UNDEF}"
fi


# (C) Generate the final file list and lun arrays to be used
#     in the subsequent calculations
FileLST=( ${FileLST} )
FileLUN=( ${!FileLST[@]} )
for ((i = 0; i < ${#FileLUN[@]}; i++))
do
  FileLUN[${i}]=$(( ${FileLUN[${i}]} + 1 ))
done


############################################################
##### Check if we use the shared memory
adjustYESNOVar USE_SHMEM


############################################################
##### Check for GNU parallel availability
adjustYESNOVar USE_GPAR

GPAR=$( getPROG ${GPAR:-parallel} )
  [ $? -ne 0 ] && unset GPAR

[ -n "${USE_GPAR:+1}" ] && \
  [ -z "${GPAR:-}" ] && \
    unset USE_GPAR

if [ -n "${USE_GPAR:+1}" ]; then
  GPAR_OPTS_ENV="${GPAR_OPTS_ENV:-}"
  GPAR_OPTS_GLB="${GPAR_OPTS_GLB:---gnu --no-run-if-empty -vv --verbose --progress --halt 1}"
  GPAR_OPTS_SSH="${GPAR_OPTS_SSH:---filter-hosts --slf ${GPAR_SLF:-..}}"
  GPAR_OPTS_TIME="${GPAR_OPTS_TIME:---timeout 3600}"
  GPAR_OPTS_RESUME="${GPAR_OPTS_RESUME:---resume-failed --retries 1}"
fi


############################################################
##### Start the calculations
# Always define it before the call to MakeScript_Arch2Ncdf
SHM_LOC="$( basename ${theSCRIPT%.*}_shmdir.txt )"
ROOT_DIR=${ROOT_DIR:-${scrDIR:-.}}

MakeScript_Arch2Ncdf --script=${theSCRIPT} --conf=${MODEL_INP} \
                     --type=${FILE_TYPE} --root=${ROOT_DIR} \
                     --shm=${USE_SHMEM:+1}0

if [ -n "${USE_GPAR:+1}" ]; then
  GPAR_JOBLOG="${LogDir:+${LogDir}/}${scrNAME%%.*}-status.log"
  GPAR_RUNLOG="${LogDir:+${LogDir}/}${scrNAME%%.*}-run.log"

  GPAR_OPTS="${GPAR_OPTS_ENV} ${GPAR_OPTS_GLB} ${GPAR_OPTS_SSH} ${GPAR_OPTS_TIME}"
  GPAR_OPTS="${GPAR_OPTS} --joblog ${GPAR_JOBLOG} ${GPAR_OPTS_RESUME}"
  GPAR_OPTS="${GPAR_OPTS} --wd ${scrDIR} --jobs ${GPAR_JOBS:-4}"

  # Remove any old log files
  [ -f ${GPAR_RUNLOG} ] && rm -f ${GPAR_RUNLOG}
  [ -f ${GPAR_JOBLOG} ] && rm -f ${GPAR_JOBLOG}

  # We cannot run parallel in the background, somehow remote jobs are not
  # killed properly when a failure occurs and subsequently parallel does not exit
  ${GPAR} ${GPAR_OPTS} --xapply ${theSCRIPT} {1} {2} \
    ::: $(echo ${FileLST[@]}) \
    ::: $(echo ${FileLUN[@]}) >> ${GPAR_RUNLOG} 2>&1
  FAILURE_STATUS=$?

  # Remove clutter from the log files
  for ilog in ${GPAR_JOBLOG} ${GPAR_RUNLOG}
  do
    log_file="${ilog}"
    stripESCFILE "${log_file}"
  done
else # GNU parallel
  for ((i = 0; i < ${#FileLST[@]}; i++))
  do
    ${theSCRIPT} ${FileLST[${i}]} ${FileLUN[${i}]} 2>&1
    FAILURE_STATUS=$?
  done
fi # sequential

# On SUCCESS remove all intermediate files
if [ ${CLEANUP:-0} -gt 0 ] && [ ${FAILURE_STATUS:-1} -eq 0 ]; then
  if [ -f "${SHM_LOC}" ]; then
    rm -rf "$( cat ${SHM_LOC} | awk 'NF>0' | awk 'NR==1' )"
    rm -f "${SHM_LOC}"
  fi

  rm -f ${theSCRIPT}
fi

# END:: Calculations
#------------------------------------------------------------

exit ${FAILURE_STATUS:-1}
