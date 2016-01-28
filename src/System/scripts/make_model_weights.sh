#!/bin/bash

# Author:  Panagiotis Velissariou <pvelissariou@fsu.edu>
#                                 <velissariou.1@osu.edu>
# Version: 1.1
#
# Version - 1.1 Wed Nov 18 2015
# Version - 1.0 Thu Jul 10 2014


#============================================================
# BEG:: SCRIPT INITIALIZATION
#============================================================

# Make sure that the current working directory is in the PATH
[[ ! :$PATH: == *:".":* ]] && export PATH="${PATH}:."

MATLAB_DIR="${MATLAB_DIR:-matlab}"

##########
# Script identification variables
# The script name and the directory where this script is located
scrNAME="$( basename ${0} )"
scrDIR="$( dirname ${0} )"
pushd "${scrDIR}" >/dev/null 2>&1
  scrDIR=$( pwd )
popd >/dev/null 2>&1

##########
# Set/Check the "ROOT_DIR" variable
# This is the directory of the modeling system source code
ROOT_DIR=${ROOT_DIR:-${scrDIR}}
export ROOT_DIR

##########
# Local Functions
isInteger()
{
  local -i retval=1

  [ $# -eq 0 ] && return ${retval}

  if [ "${1:-UNDEF}" -eq "${1}" ] 2>/dev/null
  then
    retval=0
  fi

  return ${retval}
}

getInteger()
{
  local -i retval=0
  local echoval= minus=

  # strip spaces, '+' signs and '-' signs
  # if the first character of the string is '-', set the minus variable
  echoval="$( echo "${1}" | sed 's/[[:space:]+]//g' )"
  [ "X$( echo "${echoval:0:1}" )" = "X-" ] && minus="-"
  echoval="${minus}$( echo "${echoval}" | sed 's/[[:space:]-]//g' )"

  if isInteger ${echoval}; then
    echoval="$(echo "scale=0; ${echoval} + 0" | bc -ql 2>/dev/null)"
    retval=$?
    echoval="${echoval:-0}"
  else
    echoval=
    retval=1
  fi

  echo -n ${echoval}

  return ${retval}
}

getPosInteger()
{
  local -i retval=0
  local echoval=

  echoval=$( getInteger "${1}" )
  retval=$?

  if [ ${retval} -ne 0 ] ; then
    echoval=
    retval=1
  else
    if [ ${echoval} -lt 0 ]; then
      echoval=
      retval=1
    fi
  fi

  echo -n ${echoval}

  return ${retval}
}

getDomString()
{
  local -i STATUS=1
  local dom_str

  if [ "${1:-UNDEF}" -eq "${1}" ] 2>/dev/null
  then
    [ ${1} -gt 0 ] && \
      [ ${1} -lt 100 ] && \
        dom_str=_d$( printf "%0*d" 2 ${1} )
    STATUS=$?
  fi

  echo -n ${dom_str}

  return ${STATUS}
}

function toUPPER()
{
  echo "${1}" | tr '[:lower:]' '[:upper:]'
}

function toLOWER()
{
  echo "${1}" | tr '[:upper:]' '[:lower:]'
}

escapeSTR()
{
  echo -n "$(echo "${1}" | sed -e "s/[\"\'\(\)\/\*]/\\\&/g;s/\[/\\\&/g;s/\]/\\\&/g")"
}

function strTrim ()
{
  local trimFLG="${2:-0}"
  local out_str=

  case ${trimFLG} in
    0) out_str="$(echo "${1}" | sed 's/[[:space:]]*$//')" ;;
    1) out_str="$(echo "${1}" | sed 's/^[[:space:]]*//')" ;;
    2) out_str="$(echo "${1}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')" ;;
    *) out_str="$(echo "${1}" | sed 's/[[:space:]]*$//')" ;;
  esac

  echo -n ${out_str}
}

strRmDuplicate()
{
  local sep_str="${2:-[[:space:]]}"

  echo -n $( echo "${1}" | tr "${sep_str}" "\n" | \
             awk '{if ($1 in a) next; a[$1]=$0; print}' | \
             tr "\n" " " )
}

getYesNo()
{
  local param answer
  
  param="$( echo "${1}" | tr '[:upper:]' '[:lower:]' )"

  if [ "${param}" -eq "${param}" ] 2>/dev/null
  then
    [ ${param} -le 0 ] && param=0
    [ ${param} -gt 0 ] && param=1
  fi

  case "${param}" in
    1|y|yes|yea|yeah|yep) answer="yes" ;;
     0|n|no|not|nop|nope) answer="no"  ;;
                       *) answer="no"  ;; # DEFAULT
  esac

  echo -n ${answer}
}

GetPathEnvVar()
{
  local nm_func="${FUNCNAME[0]}"

  local -i reverse=0
  local dirLIST pathVAR pathLIST dirLIST
  local dir var val tmpSTR chkSTR


  [ $# -lt 1 ] && return 0

  ##########
  # Work on the function arguments
  pathVAR=$( toLOWER "${1-}" | awk '{print $1}' )
  case "${pathVAR}" in
    path)
      var=PATH
      ;;
    ld)
      var=LD_LIBRARY_PATH
      ;;
    man)
      var=MANPATH
      ;;
    matlab)
      var=MATLABPATH
      ;;
    idl)
      ;;
    *)
      echo "Usage: ${nm_func} pathVAR dirLIST"
      echo "       pathVAR one of: path, ld, man, matlab, idl"
      echo "       dirLIST: the list of the directories to include recursively"
      echo "                into the corresponding environment variable"
      echo "       Environment variables that can be set are:"
      echo "         path -> PATH,         ld -> LD_LIBRARY_PATH"
      echo "          man -> MANPATH,  matlab -> MATLABPATH"
      echo "          idl -> IDL_PATH and IDL_DLM_PATH"
      return 1
      ;;
  esac

  if [ $# -lt 2 ]; then
    if [ "X${pathVAR:-}" = "Xidl" ]; then
      IDL_PATH="${IDL_PATH:-}"
      IDL_DLM_PATH="${IDL_DLM_PATH:-}"
      export IDL_PATH IDL_DLM_PATH
    else
      val="$( eval "echo \$$(echo ${var})" )"
      eval "${var}=${val:-}"
      export ${var}
    fi
    return 0
  fi

  dirLIST=$( echo $( for dir in ${2-}; do echo "${dir}"; done | sed 's/\/*$//' ) )
  dirLIST=$( strRmDuplicate "${dirLIST}" )

  # Reverse the order of the input directories (if requested)
  [[ "$( toLOWER "${3-}" | awk '{print $1}' )" = rev* ]] && \
    reverse=1

  if [ ${reverse} -gt 0 ]; then
    tmpSTR=
    dirLIST=$( echo $( for dir in ${dirLIST}; do tmpSTR="${dir} ${tmpSTR}"; done; echo ${tmpSTR}  ) )
  fi
  ##########


  # Were given a directory list therefore, we proceed with the following code


  ##########
  # Special treatment for idl.
  # When idl encounters a '+' sign in front of a directory
  # in the IDL_PATH or IDL_DLM_PATH environment variables
  # it recursively checks the directory for appropriate
  # idl files (*.pro, *.sav, *.dlm) and then expands
  # the environment variables.
  if [ "X${pathVAR:-}" = "Xidl" ]; then
    my_IDL_PATH=${IDL_PATH:-<IDL_DEFAULT>}
    my_IDL_DLM_PATH=${IDL_DLM_PATH:-<IDL_DEFAULT>}

    pathLIST=
    for dir in ${dirLIST}
    do
      if [ -d "${dir}" ]; then
        if [ ${reverse} -gt 0 ]; then
          pathLIST="+${dir}:${pathLIST}"
        else
          pathLIST="${pathLIST}:+${dir}"
        fi
      fi
    done
    # The IDL_PATH variable.
      chkSTR=( $( echo "${my_IDL_PATH}" | sed 's/[+:]/ /g' ) )
      chkSTR=${chkSTR[${#chkSTR[@]}-1]}
    tmpSTR=$( echo ${my_IDL_PATH}${pathLIST:+:+${pathLIST}} | sed 's/[+:]/ /g' )
    tmpSTR=$( strRmDuplicate "${tmpSTR}" )
    tmpSTR=$( echo ${tmpSTR#*${chkSTR}} | sed 's/ /:+/g' )
    if [ ${reverse} -gt 0 ]; then
      my_IDL_PATH=$( echo "+${tmpSTR}:${my_IDL_PATH}" )
    else
      my_IDL_PATH=$( echo ${my_IDL_PATH}:+${tmpSTR} )
    fi
    # The IDL_DLM_PATH variable.
      chkSTR=( $( echo "${my_IDL_DLM_PATH}" | sed 's/[+:]/ /g' ) )
      chkSTR=${chkSTR[${#chkSTR[@]}-1]}
    tmpSTR=$( echo ${my_IDL_DLM_PATH}${pathLIST:+:+${pathLIST}} | sed 's/[+:]/ /g' )
    tmpSTR=$( strRmDuplicate "${tmpSTR}" )
    tmpSTR=$( echo ${tmpSTR#*${chkSTR}} | sed 's/ /:+/g' )
    if [ ${reverse} -gt 0 ]; then
      my_IDL_DLM_PATH=$( echo "+${tmpSTR}:${my_IDL_DLM_PATH}" )
    else
      my_IDL_DLM_PATH=$( echo ${my_IDL_DLM_PATH}:+${tmpSTR} )
    fi

    IDL_PATH=${my_IDL_PATH}
    IDL_DLM_PATH=${my_IDL_DLM_PATH}
    export IDL_PATH IDL_DLM_PATH

    return 0
  fi
  ##########


  ##########
  # Special treatment for matlab.
  # For matlab recurse each input (root) directory
  # and append all directories found in the MATLABPATH
  # environment variable.
  if [ "X${pathVAR:-}" = "Xmatlab" ]; then
    pathLIST="${MATLABPATH:-}"
    for dir in ${dirLIST}
    do
      if [ -d "${dir}" ]; then
        dir=$( find ${dir} \
               -type f \( -iname "*.m" -o -iname "*.mat" -o -iname "*.mex*" \
                                       -o -iname "*.mdl*" -o -iname "*.slx*" \) \
               -exec dirname  {} \; \
               | sort -u | sed '/\/\./d' | tr '\n' ':' | sed 's/:$//' )
        if [ ${reverse} -gt 0 ]; then
          pathLIST="${dir}:${pathLIST}"
        else
          pathLIST="${pathLIST}:${dir}"
        fi
      fi
    done
    pathLIST=$( echo "${pathLIST}" | sed 's/:/ /g' )
    pathLIST=$( strRmDuplicate "${pathLIST}" )
    pathLIST=$( echo "${pathLIST}" | sed 's/ /:/g' )

    MATLABPATH=${pathLIST:-}
    export MATLABPATH

    return 0
  fi
  ##########


  ##########
  # All other PATH variables.
  val="$( eval "echo \$$(echo ${var})" )"
  pathLIST="${val:-}"
  for dir in ${dirLIST}
  do
    if [ -d "${dir}" ]; then
      if [ ${reverse} -gt 0 ]; then
        pathLIST="${dir}:${pathLIST}"
      else
        pathLIST="${pathLIST}:${dir}"
      fi
    fi
  done
  pathLIST=$( echo "${pathLIST}" | sed 's/:/ /g' )
  pathLIST=$( strRmDuplicate "${pathLIST}" )
  pathLIST=$( echo "${pathLIST}" | sed 's/ /:/g' )

  eval "${var}=${pathLIST:-}"
  export ${var}
  ##########


  return 0
}

getPROG()
{
  local nm_func=${FUNCNAME[0]}

  local nm_prog exe_prog old_PATH
  local dirLIST my_dirLIST
  local dir dir1
  local -i STATUS

  local cwd="$( pwd )"
  local old_PATH=${PATH}


  if [ $# -eq 0 ]; then
    exe_prog="Usage: ${nm_func} progname"
    echo -n "${exe_prog}"
    return 1
  fi


  nm_prog=${1}
  unalias ${nm_prog} >/dev/null 2>&1


  ###############
  ### Check if full program path was supplied
  #   (including the current directory full path)
  if $( checkPROG "${nm_prog}" ); then
    exe_prog="$( pathFILE "${nm_prog}" )"
    echo -n ${exe_prog}
    return 0
  fi


  ###############
  ### Check if program is a bultin function
  unset PATH
    exe_prog="$( command -v ${nm_prog} 2>&1 )"
    STATUS=$?
  PATH=${old_PATH}
  export PATH
  if [ ${STATUS} -eq 0 ]; then
    echo -n "${exe_prog}"
    return ${STATUS}
  fi


  ###############
  ### Check if program is in bin Bin sbin ... ${HOME}/bin ${HOME}/Bin ${HOME}/sbin ...
  #   and in user's path.
  dirLIST="bin Bin sbin ${cwd} ${cwd}/.. ${cwd}/../.."
  dirLIST="${dirLIST} ${cwd}/../../.. ${cwd}/../../../.. ${cwd}/../../../../.."
  dirLIST="${dirLIST} ${RootDir:-} ${ROOT_DIR:-} ${CAST_ROOT:-}"
  dirLIST="${dirLIST} ${MY_PROJECT_DIR:-} ${PROJECT_DIR:-} ${HOME:-}"
  my_dirLIST=
  for dir in ${dirLIST}
  do
    if $( checkDIR -rx "${dir}" ); then
      pushd ${dir} >/dev/null 2>&1
        dir="$( pwd )"
      popd >/dev/null 2>&1

      dir="${dir#${cwd}/}"
      if [ -n "${dir:+1}" ]; then
        my_dirLIST="${my_dirLIST} ${dir}"
        for idir in Bin bin sbin
        do
          dir1="$( echo "${dir}" | sed 's/\/*$//' )"
          [ -d ${dir1}/${idir} ] && \
            my_dirLIST="${my_dirLIST} ${dir1}/${idir}"
        done
      fi
    fi
  done
  dirLIST=$( strRmDuplicate "${my_dirLIST}" )
  dirLIST=$( strTrim "${dirLIST}" 2 )

  GetPathEnvVar path "${dirLIST}" reverse
  
  exe_prog="$( command -v ${nm_prog} 2>&1 )"
  STATUS=$?

  [ ${STATUS} -ne 0 ] && \
    exe_prog="${nm_func}: Could not locate/execute the program/function \"${nm_prog:-UNDEF}\""

  PATH=${old_PATH}
  export PATH

  echo -n "${exe_prog}"

  return ${STATUS}
}

checkFILE()
{
  local -i retval=0
  local get_opts my_arg="" chk_my_arg="" my_opts="-f" iopt
# Use these to reset the options since the shell does not
# do that automatically
  local opt_id=${OPTIND} opt_arg="${OPTARG}"

  [ $# -eq 0 ] && { retval=1; return ${retval}; }

  while getopts ":hLrsw" get_opts
  do
    case ${get_opts} in
      h|L) my_opts="${my_opts} -h";;
        r) my_opts="${my_opts} -r";;
        s) my_opts="${my_opts} -s";;
        w) my_opts="${my_opts} -w";;
        *) ;; # DEFAULT
    esac
  done

# Get the first argument after the options
  shift $(( ${OPTIND} - 1))
  my_arg=${1}

# Reset the option variables since the shell doesn't do it
  OPTIND=${opt_id}
  OPTARG="${opt_arg}"

  chk_my_arg="$( echo "${my_arg##*/}" | sed -e 's/[[:space:]]//g' )"
  [ "X${my_arg}" = "X" ] && { retval=1; return ${retval}; }

  for iopt in ${my_opts}
  do
    [ ! ${iopt} "${my_arg}" ] && { retval=1; return ${retval}; }
  done

  return ${retval}
}

checkDIR()
{
  local -i retval=0
  local get_opts my_arg="" chk_my_arg="" my_opts="-d" iopt
# Use these to reset the options since the shell does not
# do that automatically
  local opt_id=${OPTIND} opt_arg="${OPTARG}"

  [ $# -eq 0 ] && { retval=1; return ${retval}; }

  while getopts ":hLrxw" get_opts
  do
    case ${get_opts} in
      h|L) my_opts="${my_opts} -h";;
        r) my_opts="${my_opts} -r";;
        x) my_opts="${my_opts} -x";;
        w) my_opts="${my_opts} -w";;
        *) ;; # DEFAULT
    esac
  done

# Get the first argument after the options
  shift $(( ${OPTIND} - 1))
  my_arg=${1}

# Reset the option variables since the shell doesn't do it
  OPTIND=${opt_id}
  OPTARG="${opt_arg}"

  chk_my_arg="$( echo "${my_arg##*/}" | sed -e 's/[[:space:]]//g' )"
  [ "X${my_arg}" = "X" ] && { retval=1; return ${retval}; }

  for iopt in ${my_opts}
  do
    [ ! ${iopt} "${my_arg}" ] && { retval=1; return ${retval}; }
  done

  return ${retval}
}

checkPROG()
{
  local get_opts my_arg="" chk_my_arg="" my_opts="-f -x" iopt
# Use these to reset the options since the shell does not
# do that automatically
  local opt_id=${OPTIND} opt_arg="${OPTARG}"

  [ $# -eq 0 ] && return 1

  while getopts ":hLrs" get_opts
  do
    case ${get_opts} in
      h|L) my_opts="${my_opts} -h";;
        r) my_opts="${my_opts} -r";;
        s) my_opts="${my_opts} -s";;
        *) ;; # DEFAULT
    esac
  done

# Get the first argument after the options
  shift $(( ${OPTIND} - 1))
  my_arg=${1}

# Reset the option variables since the shell doesn't do it
  OPTIND=${opt_id}
  OPTARG="${opt_arg}"

  chk_my_arg="$( echo "${my_arg##*/}" | sed -e 's/[[:space:]]//g' )"
  [ "X${chk_my_arg}" = "X" ] && return 1

  for iopt in ${my_opts}
  do
    [ ! ${iopt} ${my_arg} ] && return 1
  done

  return 0
}

pathFILE()
{
  local nm_func="${FUNCNAME[0]}"

  local inp_file inp_dir

  if [ $# -lt 1 ]; then
    inp_file="wrong number of arguments
              usage: ${nm_func} filename"
    echo -n "${inp_file}"
    return 1
  fi

  inp_file=${1}

  inp_dir=$( dirname "${inp_file}" )
  inp_file=$( basename "${inp_file}" )

  if [ -d "${inp_dir}"  ]; then
    pushd ${inp_dir} >/dev/null 2>&1
      inp_dir="$( pwd )"
    popd >/dev/null 2>&1
  fi

  if [ "${inp_dir}" = "/" ] && [ "${inp_file}" = "/" ]; then
    inp_file=${inp_dir}
  elif [ "${inp_dir}" = "/" ]; then
    inp_file=${inp_dir}${inp_file}
  else
    inp_file=${inp_dir}/${inp_file}
  fi

  echo -n ${inp_file}

  return 0
}

procError()
{
  # These are for the current function (procError)
  local fnm0="${FUNCNAME[0]}"
  local snm0="$( basename "${BASH_SOURCE[0]}" )"

  # These are for the calling function(s)
  local err_str fun_str src_str
  local fnm1="${FUNCNAME[1]}"
  local fnm2="${FUNCNAME[2]}"
  local fnm3="${FUNCNAME[3]}"
  local fnm4="${FUNCNAME[4]}"
  local snm1="$( basename "${BASH_SOURCE[1]}" )"
  local snm2="$( basename "${BASH_SOURCE[2]}" )"
  local snm3="$( basename "${BASH_SOURCE[3]}" )"
  local snm4="$( basename "${BASH_SOURCE[4]}" )"

  # proc_str: strings to be displayed (if supplied)
  # trim_str: trimmed version of proc_str
  local trim_str proc_str=( "$@" )
  local -i istr


  # Strings that identify the calling functions and sources
  cfnm="${fnm2:+${fnm2}:}${fnm3:+${fnm3}:}${fnm4:+${fnm4}:}"
    cfnm="${cfnm:+(${cfnm%:})}"
  csnm="${snm2:+${snm2}:}${snm3:+${snm3}:}${snm4:+${snm4}:}"
    csnm="${csnm:+(${csnm%:})}"

  src_str="${snm1}${csnm:+ ${csnm}}"
  fun_str="${fnm1}${cfnm:+ ${cfnm}}"

  err_str="${fun_str:+${fun_str}: }${src_str:+called from: ${src_str}}"
  [ -z "${err_str:-}" ] && \
    err_str="${fnm0:+${fnm0}: }${snm0:+defined in: ${snm0}}"

  # Display everything and then issue the exit command
  [ -n "${err_str:+1}" ] && echo "ERROR:: ${err_str}"
  for ((istr = 0; istr < ${#proc_str[@]}; istr++))
  do
    trim_str="$( strTrim "${proc_str[${istr}]}" 2)"
    [ -n "${trim_str:+1}" ] && echo "        ${proc_str[${istr}]}"
  done
  echo "        Exiting now ..."
  echo
  if [ -n "${PS1:+1}" ]; then
    return 1
  else
    exit 1
  fi
}

checkFuncOpt() {
  local opt_inp opt

  [ $# -eq 0 ] && return 0

  opt_inp="${1}"

  # Check it's not already in use
  for opt in ${__OPTION_LIST}
  do 
    if [ "${opt_inp}" = "${opt}" ]; then
      procError "Option name \"${opt_inp}\" is already in use"
    fi
  done

  __OPTION_LIST="${__OPTION_LIST} ${opt_inp}"
  export __OPTION_LIST
}

ParseArgs()
{
  local nm_func=$( basename ${BASH_SOURCE[${#BASH_SOURCE[@]}-1]} )

  local -i opt_flg=0
  local opt_all opt_opt opt_arg

  local ans0 ans ival intN
  local all_evars


  all_evars="CASEID DOMS MODELS TOPOS MATLAB_DIR CLEANUP"

  for ival in ${all_evars}
  do
    unset __${ival}

    ans0="$( eval "echo \${$(echo ${ival}):-}" )"
    [ -n "${ans0:+1}" ] && \
      opt_flg=$(( ${opt_flg} + 1 ))
  done


  __DOMS="0 0"
  __CLEANUP=1


  # -----
  # Process the function options
  opt_all=( c doms models topos matd clean h help )
  opt_all=":$( echo "${opt_all[@]/#/-} ${opt_all[@]/#/--}" | sed 's/ /:/g' ):"

  __OPTION_LIST=
  while test $# -gt 0; do
    case "${1}" in
      -[^-]*=* | --[^-]*=* )
        opt_opt="$( toLOWER "$( echo "${1}" | sed 's/=.*//' )" )"
        opt_arg="$( strTrim "$( echo "${1}" | sed 's/.*=//' )" 2 )"
        [ "$( echo "${opt_all}" | egrep -o ":${opt_arg}:" )" ] && \
          opt_arg=
        ;;
      -[^-]* | --[^-]* )
        opt_opt="$( toLOWER "${1}" )"
        opt_arg="$( strTrim "$( echo "${2}" | sed 's/=.*//' )" 2 )"
        [ "$( echo "${opt_all}" | egrep -o ":${opt_arg}:" )" ] && \
          opt_arg=
        ;;
      *)
        opt_opt= 
        opt_arg=
        ;;
    esac

    case "${opt_opt}" in
      -c | --c )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            __CASEID="$( echo "${opt_arg}" | sed 's/[[:space:]]//g' )"
            opt_flg=$(( ${opt_flg} + 1 ))
          fi
        ;;
      -doms | --doms )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            __DOMS=( ${opt_arg} )
            for ((ival = 0; ival < ${#__DOMS[@]}; ival++))
            do
              intN=$( getPosInteger "${__DOMS[${ival}]}" )
              [ $? -ne 0 ] && intN=0
              __DOMS[${ival}]=${intN}
            done
            __DOMS="${__DOMS[@]}"
            opt_flg=$(( ${opt_flg} + 1 ))
          fi
        ;;
      -models | --models )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            __MODELS="$( strTrim "${opt_arg}" 2 )"
            opt_flg=$(( ${opt_flg} + 1 ))
          fi
        ;;
      -topos | --topos )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            __TOPOS="$( strTrim "${opt_arg}" 2 )"
            opt_flg=$(( ${opt_flg} + 1 ))
          fi
        ;;
      -matd | --matd )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            __MATLAB_DIR="$( echo ${opt_arg} | sed -e 's#//*#/#g' )"
            __MATLAB_DIR=$( strRmDuplicate "${__MATLAB_DIR}" )
            opt_flg=$(( ${opt_flg} + 1 ))
          fi
        ;;
      -clean | --clean )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          __CLEANUP=1
          if [ "X${opt_arg}" != "X" ]; then
            [ "$( getYesNo "${opt_arg}" )" = "no" ] && __CLEANUP=0
          fi
        ;;
      -h | -help | --h | --help )
          Usage ${nm_func}
        ;;
      *) ;; # DEFAULT
    esac
    shift
    opt_opt= 
    opt_arg=
  done
  __OPTION_LIST=

  [ ${opt_flg} -le 0 ] && Usage ${nm_func}
  # -----

  ans=
  for ival in ${__MATLAB_DIR}
  do
    if $( checkDIR "${ival}" ); then
      ans="${ans} $( pathFILE ${ival} )"
    fi
  done
  __MATLAB_DIR="$( echo ${ans:-} )"

  # Export the values of all __* variables.
  for ival in ${all_evars}
  do
    ans0="$( eval "echo \${$(echo ${ival}):-}" )"
    ans="$( eval "echo \${$(echo __${ival}):-}" )"
    ans=${ans:-${ans0:-}}

    eval "${ival}=\${ans}"
    export ${ival}

    unset __${ival}
  done

  return 0
}

Usage()
{
  local nm="$( basename ${1:-${0}} )"

  echo
  echo "Usage: \"${nm}\" [{-|--}option1{=|space}[option_value1]] [{-|--}option2{=|space}[option_value2]] ..."
  echo "Example:    -doms \"1 2\",  -doms=\"1 2\" (both set doms for MODEL1 MODEL2)"
  echo "           --doms \"1 2\", --doms=\"1 2\" (both set doms for MODEL1 MODEL2)"
  echo
  sleep 1

  echo "AVAILABLE OPTIONS"
  echo
  echo " In addition to passing the configuration parameters/variables using"
  echo "   the available options of this script, the configuration parameters/variables"
  echo "   can also be obtained from the environment if the defaults are not sufficient."
  echo " The environment variables can be set (a) from the command line,"
  echo "   (b) by exporting them to the environment prior of running this script."
  echo " For a further explanation of these variables, see the script source code."
  echo

  #---
  echo "   h|help"
  echo "       Show this help screen and then exit."
  #---
  echo "   c \"caseid\"; Associated EnvVar: CASEID (optional)."
  echo "       Set a name/id for the case being run/compiled."
  echo "       Default: not set."
  #---
  echo "   doms \"model_doms\"; Associated EnvVar: DOMS (optional)."
  echo "       The domain identification number (nest) in each model."
  echo "       A string that contains the domain numbers in the following sequence:"
  echo "       model_doms=\"1 1\", (DOM_MODEL1 DOM_MODEL2)."
  echo "       Default: 0 for all models."
  #---
  echo "   models \"models\"; Associated EnvVar: MODELS (mandatory)."
  echo "       The list model names."
  echo "       A string that contains the model names in the following sequence:"
  echo "       models=\"MODEL1 MODEL2\"."
  echo "       Default: not set."
  #---
  echo "   topos \"models\"; Associated EnvVar: TOPOS (mandatory)."
  echo "       The list model grid definitions (e.g., topographies/bathymetries)."
  echo "       A string that contains the model grid definitions in the following sequence:"
  echo "       topos=\"GRID_MODEL1 GRID_MODEL2\"."
  echo "       Default: not set."
  #---
  echo "   matd \"mat_dir\"; Associated EnvVar: MATLAB_DIR (optional)."
  echo "       The list of matlab directories to prepend in the MATLABPATH environment variable."
  echo "       A string that contains the matlab directories in the following sequence:"
  echo "       mat_dir=\"DIR1 DIR2 ...\"."
  echo "       The script searches also the sub-directories for suitable matlab files."
  echo "       Default: matlab."
  #---
  echo "   clean \"0|1|yes|no\"; Associated EnvVar: CLEANUP (optional)."
  echo "       Set this option to clean all intermediate files created during this simulation."
  echo "       Default: 1."

  exit 0
}

ScripMatRun()
{
  local nm_func="${FUNCNAME[0]}"

  local scrip_file scrip_tmp
  local grid_file out_file
  local dir xpr1 xpr2
  local RUN_CMD RUN_ERR

  # ----- Get all the arguments
  if [ $# -lt 2 ]; then
    procError "Usage ${nm_func} scripFILE gridFILE"
  fi

  scrip_file=$( echo ${1} | sed 's/[[:space:]].*$//g' )
  grid_file=$( echo ${2} | sed 's/[[:space:]].*$//g' )
  out_file=$( echo ${3} | sed 's/[[:space:]].*$//g' )

  # The matlab script and the grid data file
  if $( ! checkFILE -r "${scrip_file}" ); then
    if [ -n "${MATLAB_DIR:+1}" ]; then
      for dir in ${MATLAB_DIR}
      do
        scrip_tmp=$( find -L ${dir} -type f -iname "${scrip_file}" | xargs )
        scrip_tmp=$( echo ${scrip_tmp} | sed 's/[[:space:]].*$//g' )
        [ -n "${scrip_tmp:+1}" ] && break
      done
    fi
    if [ -n "${scrip_tmp:+1}" ]; then
      scrip_file=${scrip_tmp}
    else
      procError "Scrip matlab file not found: ${scrip_file:-UNDEF}"
    fi
  fi

  if $( ! checkFILE -r "${grid_file}" ); then
    procError "Grid data file not found: ${grid_file:-UNDEF}"
  fi
  # -----


  # -----
  RUN_CMD=$( getPROG matlab )
  [ $? -ne 0 ] && procError "${RUN_CMD}"

  [ -z "${out_file:-}" ] && \
    out_file="scrip_$( basename ${grid_file} )"

  scrip_tmp="$( basename ${scrip_file%%.*}_tmp.m )"
  # -----


  # ----- Modify the scrip matlab file
  # Remove any old files
  rm -fv ${scrip_tmp}
  cp -f ${scrip_file} ${scrip_tmp}

  xpr1='^[[:space:]]*grid_file[[:space:]]*='
  xpr2=" \'`escapeSTR ${grid_file}`\';"
  sed -i "s/\(${xpr1}\)\(.*\)/\1${xpr2}/g" ${scrip_tmp}
    
  xpr1='^[[:space:]]*out_file[[:space:]]*='
  xpr2=" \'`escapeSTR ${out_file}`\';"
  sed -i "s/\(${xpr1}\)\(.*\)/\1${xpr2}/g" ${scrip_tmp}

  echo          >> ${scrip_tmp}
  echo "close;" >> ${scrip_tmp}
  echo "exit"   >> ${scrip_tmp}
  # -----


  ##########
  RUN_CMD="${RUN_CMD} -nojvm -nosplash -nodesktop -r ${scrip_tmp%%.*}"

  echo
  echo "##### Running ${RUN_CMD}"

  rm -fv ${out_file}

  RUN_ERR="$( ${RUN_CMD} 2>&1 )"
  if [ $? -ne 0 ]; then
    rm -fv ${out_file}
    procError "The following command failed:" \
              "  ${RUN_CMD}" \
              "${RUN_ERR}"
  fi
  ##########

  if [ ${CLEANUP:-0} -gt 0 ]; then
    rm -fv ${scrip_tmp}
  fi

  scripOUT=${out_file}
  export scripOUT

  return 0
}

ScripRun()
{
  local nm_func="${FUNCNAME[0]}"

  local scrip_file scrip_tmp
  local grid_file1 grid_file2
  local map_file1 map_file2
  local model1 model2
  local RUN_CMD RUN_ERR
  local scrip_in="scrip_in"

  # ----- Get all the arguments
  if [ $# -lt 5 ]; then
    procError "Usage ${nm_func} scripINP grid1 map1 grid2 map2 [model1, model2]"
  fi

  scrip_file=$( echo ${1} | sed 's/[[:space:]].*$//g' )
  grid_file1=$( echo ${2} | sed 's/[[:space:]].*$//g' )
   map_file1=$( echo ${3} | sed 's/[[:space:]].*$//g' )
  grid_file2=$( echo ${4} | sed 's/[[:space:]].*$//g' )
   map_file2=$( echo ${5} | sed 's/[[:space:]].*$//g' )
      model1=$( echo ${6} | sed 's/[[:space:]].*$//g' )
      model1=${model1:-MODEL1}
      model2=$( echo ${7} | sed 's/[[:space:]].*$//g' )
      model2=${model2:-MODEL2}

  if $( ! checkFILE -r "${grid_file1}" ) || \
     $( ! checkFILE -r "${grid_file2}" ); then
    procError "One or both of the generated scrip grid files could not be read:" \
              "  SCRIP_GRID1 = ${grid_file1:-UNDEF}" \
              "  SCRIP_GRID2 = ${grid_file2:-UNDEF}"
  fi

  if [ -z "${map_file1:-}" ] || \
     [ -z "${map_file2:-}" ]; then
    procError "One or both of the scrip map files is not defined:" \
              "  SCRIP_MAP1 = ${map_file1:-UNDEF}" \
              "  SCRIP_MAP2 = ${map_file2:-UNDEF}"
  fi
  # -----


  # -----
  RUN_CMD=$( getPROG scrip )
  [ $? -ne 0 ] && procError "${RUN_CMD}"

  rm -fv ${scrip_file}

# Create the scrip_in file for the requested models
cat << EOF > ${scrip_file}
&remap_inputs
num_maps        = 2
grid1_file      = '${grid_file1}'
grid2_file      = '${grid_file2}'
interp_file1    = '${map_file1}'
interp_file2    = '${map_file2}'
map1_name       = '${model1} to ${model2} Mapping'
map2_name       = '${model2} to ${model1} Mapping'
map_method      = 'conservative'
normalize_opt   = 'fracarea'
output_opt      = 'scrip'
restrict_type   = 'latlon'
num_srch_bins   = 90 
luse_grid1_area = .false.
luse_grid2_area = .false.
/
EOF
  # -----


  ##########
  echo
  echo "##### Running ${RUN_CMD} on file: ${scrip_file}"

  rm -fv ${scrip_in}
  ln -sf ${scrip_file} ${scrip_in}

  RUN_ERR="$( ${RUN_CMD} 2>&1 )"
  if [ $? -ne 0 ]; then
    procError "The following command failed:" \
              "  ${RUN_CMD} (for ${scrip_in} -> ${scrip_file})" \
              "${RUN_ERR}"
  fi
  ##########

  if [ ${CLEANUP:-0} -gt 0 ]; then
    rm -fv ${scrip_file}
    rm -fv ${scrip_in}
    rm -fv ${grid_file1}
    rm -fv ${grid_file2}
  fi

  return 0
}
#============================================================
# END:: SCRIPT INITIALIZATION
#============================================================


#============================================================
# BEG:: SETTING DEFAULTS AND/OR THE USER INPUT
#============================================================

#########
# Call ParseArgs to get any additional user input. They overwrite
# the parameter values set in the environment.
ParseArgs "${@}"

GetPathEnvVar matlab "${MATLAB_DIR}" reverse

#============================================================
# END:: SETTING DEFAULTS AND/OR THE USER INPUT
#============================================================


#============================================================
# BEG:: CHECK THE VARIABLES
#============================================================
SUPPORTED_MODELS="roms hycom wrf swan"

##### The models
checkVAR=( $( toLOWER "${MODELS}" ) )
MODEL1=$( echo ${SUPPORTED_MODELS} | egrep -o "${checkVAR[0]}" )
MODEL2=$( echo ${SUPPORTED_MODELS} | egrep -o "${checkVAR[1]}" )

if [ -z "${MODEL1}" ] || \
   [ -z "${MODEL2}" ] || \
   [ "X${MODEL1}" = "X${MODEL2}" ]; then
  procError "Need to specify two different models to proceed:" \
            "  MODEL1 = ${MODEL1:-UNDEF}" \
            "  MODEL2 = ${MODEL2:-UNDEF}" \
            "Supported models are:" \
            "  SUPPORTED_MODELS = ${SUPPORTED_MODELS:-UNDEF}"
fi

##### The grid definitions
checkVAR=( ${TOPOS} )
GRID_MODEL1=${checkVAR[0]}
GRID_MODEL2=${checkVAR[1]}

if [ -z "${GRID_MODEL1}" ] || \
   [ -z "${GRID_MODEL2}" ] || \
   [ "X${GRID_MODEL1}" = "X${GRID_MODEL2}" ]; then
  procError "Need to specify two different grid definitions to proceed:" \
            "  GRID_MODEL1 = ${GRID_MODEL1:-UNDEF}" \
            "  GRID_MODEL2 = ${GRID_MODEL2:-UNDEF}"
else
  if $( ! checkFILE -r "${GRID_MODEL1}" ) || \
     $( ! checkFILE -r "${GRID_MODEL2}" ); then
    procError "One or both of the grid definition files could not be read:" \
              "  GRID_MODEL1 = ${GRID_MODEL1:-UNDEF}" \
              "  GRID_MODEL2 = ${GRID_MODEL2:-UNDEF}"
  fi
fi

##### The domains
checkVAR=( ${DOMS} )
DOM_MODEL1=$( getDomString ${checkVAR[0]} )
DOM_MODEL2=$( getDomString ${checkVAR[1]} )

#============================================================
# END:: CHECK THE VARIABLES
#============================================================


#============================================================
# BEG:: CALCULATIONS
#============================================================

echo "----- Creating the model weight NetCDF files."

##### Run matlab to create the scrip program input files
ScripMatRun scrip_${MODEL1}.m ${GRID_MODEL1}
  scripMODEL1=${scripOUT}
  unset scripOUT

ScripMatRun "scrip_${MODEL2}.m" "${GRID_MODEL2}"
  scripMODEL2="${scripOUT}"
  unset scripOUT

##### Run scrip to create the model weight files
ScripRun "scrip_in_${MODEL1}-${MODEL2}" \
         "${scripMODEL1}" \
           "${MODEL1}${DOM_MODEL1}-${MODEL2}${DOM_MODEL2}-weights.nc" \
         "${scripMODEL2}" \
           "${MODEL2}${DOM_MODEL2}-${MODEL1}${DOM_MODEL1}-weights.nc" \
         "$( toUPPER ${MODEL1} )" "$( toUPPER ${MODEL2} )"

#============================================================
# END:: CALCULATIONS
#============================================================

exit 0
