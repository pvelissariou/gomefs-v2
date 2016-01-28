#!/bin/bash

# Author:  Panagiotis Velissariou <pvelissariou@fsu.edu>
#                                 <velissariou.1@osu.edu>
# Version: 1.2
#
# Version - 1.2 Fri Nov 20 2015
# Version - 1.1 Wed Jul 23 2014
# Version - 1.0 Sun Feb 23 2014


#============================================================
# BEG:: SCRIPT INITIALIZATION
#============================================================

# Make sure that the current working directory is in the PATH
[[ ! :$PATH: == *:".":* ]] && export PATH="${PATH}:."

IDL_DIR="${IDL_DIR:-idl}"

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

# -------------------------------------------------------
# Create_IDLFiles()
# Usage:      Create_IDLFiles file_name  [FileSuffix, [BATCH STATUS]]
# Returns:    NONE
# Echoes:     NONE
#
# Create file_name" from file_name-tmpl" and the corresponding
# batch/log and status files.
# -------------------------------------------------------
Create_IDLFiles()
{
  local nm_func="${FUNCNAME[0]}"

  local file dir_name file_name file_sfx file_tmpl
  local file_batch file_log file_status
  local opt_opt opt_arg
  local -i do_batch=0 do_status=0

  if [ $# -lt 1 ]; then
    procError "wrong number of arguments" \
              "usage: ${nm_func} FileName [FileSuffix, [BATCH STATUS]]"
  fi

  file=$( echo "${1}" | sed -e 's/[ \t]//g' )
  dir_name="`dirname ${file}`"
  [ "X${dir_name}" = "X." ] && dir_name=
  file_name="${dir_name:+${dir_name}/}`basename ${file} ".idl"`"
  file_tmpl=${file}-tmpl

  if [ -f ${file_tmpl} ]; then
    [ -f ${file} ] && rm -f ${file}
    cp ${file_tmpl} ${file}
  else
    procError "${file_tmpl} not found"
  fi

  while test $# -gt 1; do
    case "${2}" in
      --*=*)
        opt_opt="`toLOWER "\`echo "${2}" | sed 's/=.*//'\`"`"
        opt_arg="`echo "${2}" | sed 's/.*=//'`"
        ;;
      *)
        opt_opt="`toLOWER "${2}"`"
        opt_arg="${opt_opt}"
        ;;
    esac

    case "${opt_opt}" in
      --sufx)
          opt_arg=$( echo "${opt_arg}" | sed -e 's/[ \t]//g' )
          if [ "X${opt_arg}" != "X" ]; then
            file_sfx="${opt_arg}"
          fi
        ;;
      batch) do_batch=1  ;;
          *)
          opt_arg=$( echo "${opt_arg}" | sed -e 's/[ \t]//g' )
          if [ "X${opt_arg}" != "X" ]; then
            file_status="${opt_arg}"
          fi
        ;;
    esac
    shift
  done

  if [ ${do_batch} -gt 0 ]; then
    file_batch="batch-${file_name}${file_sfx:+-${file_sfx}}.idl"
    file_log="batch-${file_name}${file_sfx:+-${file_sfx}}.log"

    [ -f ${file_batch} ] && rm -f ${file_batch}
    [ -f ${file_log} ] && rm -f ${file_log}
    echo ".rnew ${file}" >> ${file_batch}
    echo "exit"          >> ${file_batch}
    echo                 >> ${file_batch}

    export BATCH_FILE=${file_batch}
    export BATCH_LOG=${file_log}
  fi

#  if [ "X${file_status}" != "X" ]; then
#    STATUS_FILE=".${file_status}${file_sfx:+-${file_sfx}}.pid"
#  fi
}

IdlFilesIni()
{
  local nm_func="${FUNCNAME[0]}"

  local reqMODEL model modelDOM
  local baseFILE idlFILE
  local ifile tmp_tmpl idl_file
  local ida date0 date1
  local first_day last_day
  local date_str dom_str

  # ----- Get all the arguments
  if [ $# -lt 1 ]; then
    procError "usage: ${nm_func} model" \
              "where model is one of: [wrf, roms, swan, sed]"
  fi

  if [ "X${IdlDir}" = "X" ]; then
    procError "IdlDir is not defined" \
              "IdlDir = ${IdlDir:-UNDEF}" \
              "this is the directory where all model idl files are stored"
  fi

  reqMODEL=$( toUPPER "${1}" )
  listBATCH=
  listIDL=
  modelDOM=$( getPosInteger "${2}" )
  modelDOM=${modelDOM:-0}

  if [ ${modelDOM} -lt 1 ]; then
    procWarn "skipping this model because domain is less than 1" \
             "model    = ${reqMODEL:-UNDEF}" \
             "modelDOM = ${modelDOM:-UNDEF}"
  fi

  case "${reqMODEL}" in
    HYCOM)
      model="hycom"
      procError "${model} is not a valid option"
      ;;
    ROMS)
      model="roms"
      ;;
    SWAN)
      model="swan"
      procError "${model} model functionality is not implemented yet"
      ;;
    SED)
      model="sed"
      procError "${model} model functionality is not implemented yet"
      ;;
    *)
      procError "usage: ${nm_func} model" \
                "where model is one of: [hycom, roms, swan, sed]" \
                "supplied model was: ${1:-UNDEF}"
      ;;
  esac

  # ----- Prepare the idl files
  pushd ${IdlDir} >/dev/null
    dom_str=$( getDomString ${modelDOM} )

    baseFILE="make-initB${model:+-${model}}"
    idlFILE="${baseFILE}.idl-tmpl"
    listBATCH="${baseFILE}${dom_str}-batch.list"
    listIDL="${baseFILE}${dom_str}-idl.list"

    if [ ! -f "${idlFILE}" ]; then
      procError "the idl file: ${idlFILE} is missing"
    fi

    # Remove any previous generated files
    for ifile in ${listBATCH} ${listIDL}
    do
      if [ -f "${ifile}" ]; then
        rm -f $(cat "${ifile}")
        rm -f "${ifile}"
      fi
    done

    date_str="%F %H:00:00"
    date0="$( getDate --date="${SimBeg}" --fmt="+${date_str}" )"

    idl_file="${baseFILE}${dom_str}.idl"
    tmp_tmpl="${idl_file}-tmpl"
      [ -f "${tmp_tmpl}" ] && rm -f "${tmp_tmpl}"
    cp -f "${idlFILE}" "${tmp_tmpl}"

    Create_IDLFiles ${idl_file} batch
    echo ${idl_file}   >> ${listIDL}
    echo ${BATCH_FILE} >> ${listBATCH}
    unset BATCH_FILE BATCH_LOG
    rm -f "${tmp_tmpl}"

    ModifyIDLVar ${idl_file} INIT_DATE    "${date0}"
    ModifyIDLVar ${idl_file} DOM_NUMB     "${modelDOM}"
    ModifyIDLVar ${idl_file} INP_DIR      "${DataDir}"
    ModifyIDLVar ${idl_file} OUT_DIR      "${IniDir}"
    #ModifyIDLVar ${idl_file} CAST_ROOT   "${CAST_ROOT}"
    #ModifyIDLVar ${idl_file} CAST_BATH   "${CAST_BATH}"
    #ModifyIDLVar ${idl_file} CAST_PLOTS  "${CAST_PLOTS}"
    #ModifyIDLVar ${idl_file} CAST_OUT    "${CAST_OUT}"
    ModifyIDLVar ${idl_file} CAST_ROOT   "${DataDir}"
    ModifyIDLVar ${idl_file} CAST_BATH   "${DataDir}/bath"
    ModifyIDLVar ${idl_file} CAST_PLOTS  "${PlotDir}"
    ModifyIDLVar ${idl_file} CAST_OUT    "${OutDir}"
    ModifyIDLVar ${idl_file} FCYCLE       "${FcastDate}"
    ModifyIDLVar ${idl_file} HC_IDXI0     "${GLBHC_I0:--1}"
    ModifyIDLVar ${idl_file} HC_IDXI1     "${GLBHC_I1:--1}"
    ModifyIDLVar ${idl_file} HC_IDXJ0     "${GLBHC_J0:--1}"
    ModifyIDLVar ${idl_file} HC_IDXJ1     "${GLBHC_J1:--1}"
  popd >/dev/null

  return 0
}

############################################################
IdlFilesBry()
{
  local nm_func="${FUNCNAME[0]}"

  local reqMODEL model modelDOM
  local baseFILE tmplFILE
  local ifile tmp_tmpl idl_file
  local ida date0 date1
  local first_day last_day
  local date_str dom_str
  local EXTSimBeg EXTSimEnd
  local nEXTBEG nEXTEND

  # ----- Get all the arguments
  if [ $# -lt 1 ]; then
    procError "usage: ${nm_func} model" \
              "where model is one of: [wrf, roms, swan, sed]"
  fi

  if [ "X${IdlDir}" = "X" ]; then
    procError "IdlDir is not defined" \
              "IdlDir = ${IdlDir:-UNDEF}" \
              "this is the directory where all model idl files are stored"
  fi

  reqMODEL="`toUPPER "${1}"`"
  listBATCH=
  listIDL=

    nEXTBEG=$( getPosInteger "${dataEXTBEG:-0}" )
  nEXTBEG=${nEXTBEG:-0}
    nEXTEND=$( getPosInteger "${dataEXTEND:-0}" )
  nEXTEND=${nEXTEND:-0}

    modelDOM=$( getPosInteger "${2}" )
  modelDOM=${modelDOM:-0}

  if [ ${modelDOM} -lt 1 ]; then
    procWarn "skipping this model because domain is less than 1" \
             "model    = ${reqMODEL:-UNDEF}" \
             "modelDOM = ${modelDOM:-UNDEF}"
  fi

  case "${reqMODEL}" in
    WRF)
      model="wrf"
      procError "${model} is not a valid option"
      ;;
    ROMS)
      model="roms"
      ;;
    SWAN)
      model="swan"
      procError "${model} model functionality is not implemented yet"
      ;;
    SED)
      model="sed"
      procError "${model} model functionality is not implemented yet"
      ;;
    *)
      procError "usage: ${nm_func} model" \
                "where model is one of: [wrf, roms, swan, sed]" \
                "supplied model was: ${1:-UNDEF}"
      ;;
  esac

  # ----- Prepare the idl files
  pushd ${IdlDir} >/dev/null
    dom_str="_d$( get2DString ${modelDOM} )"

    baseFILE="make-climB${model:+-${model}}"
    tmplFILE="${baseFILE}.idl-tmpl"
    listBATCH="${baseFILE}${dom_str}-batch.list"
    listIDL="${baseFILE}${dom_str}-idl.list"

    if [ ! -f "${tmplFILE}" ]; then
      procError "the idl file: ${tmplFILE} is missing"
    fi

    # Remove any previous generated files
    for ifile in ${listBATCH} ${listIDL}
    do
      if [ -f "${ifile}" ]; then
        rm -f $(cat "${ifile}")
        rm -f "${ifile}"
      fi
    done

    ##### Set the date string format and add extra 1-day records
    date_str="%F %H:00:00"
      EXTSimBeg="`getDate --date="${SimBeg}"` -${nEXTBEG} days"
    EXTSimBeg="$( getDate --date="${EXTSimBeg}" --fmt="+${date_str}" )"
      EXTSimEnd="`getDate --date="${SimEnd}"` ${nEXTEND} days"
    EXTSimEnd="$( getDate --date="${EXTSimEnd}" --fmt="+${date_str}" )"

    first_day="$( getDate --date="${EXTSimBeg}" --fmt='+%F 00:00:00' )"
    # Use an extra day for the end of simulation
    #last_day="$( date -d "`date -d "${SimEnd}"` 1 days" "+%F 00:00:00" )"
    last_day="$( getDate --date="${EXTSimEnd}" --fmt='+%F 00:00:00' )"

    for ((ida = 0; ida <= 366; ida++))
    do
        date0="`getDate --date="${first_day}"` ${ida} days"
      date0="$( getDate --date="${date0}" --fmt="+${date_str}" )"
      
        date1="`getDate --date="${date0}"` 23 hours"
      date1="$( getDate --date="${date1}" --fmt="+${date_str}" )"
      #date1="${date0}"

      idaystr=$( get3DString ${ida} )

      idl_file="${baseFILE}${dom_str}_${idaystr}.idl"
      tmp_tmpl="${idl_file}-tmpl"
        [ -f "${tmp_tmpl}" ] && rm -f "${tmp_tmpl}"
      cp -f "${tmplFILE}" "${tmp_tmpl}"

      Create_IDLFiles ${idl_file} batch
      echo ${idl_file}   >> ${listIDL}
      echo ${BATCH_FILE} >> ${listBATCH}
      unset BATCH_FILE BATCH_LOG
      rm -f "${tmp_tmpl}"

      ModifyIDLVar ${idl_file} BEG_DATE    "${date0}"
      ModifyIDLVar ${idl_file} END_DATE    "${date1}"
      ModifyIDLVar ${idl_file} DOM_NUMB    "${modelDOM}"
      ModifyIDLVar ${idl_file} REC_EXTBEG  "${nEXTBEG}"
      ModifyIDLVar ${idl_file} REC_EXTEND  "${nEXTEND}"
      ModifyIDLVar ${idl_file} INP_DIR     "${DataDir}"
      ModifyIDLVar ${idl_file} OUT_DIR     "${BryDir}"
      ModifyIDLVar ${idl_file} CAST_ROOT   "${CAST_ROOT}"
      ModifyIDLVar ${idl_file} CAST_BATH   "${CAST_BATH}"
      ModifyIDLVar ${idl_file} CAST_PLOTS  "${CAST_PLOTS}"
      ModifyIDLVar ${idl_file} CAST_OUT    "${CAST_OUT}"
      ModifyIDLVar ${idl_file} FCYCLE      "${FcastDate}"
      ModifyIDLVar ${idl_file} HC_IDXI0    "${GLBHC_I0:--1}"
      ModifyIDLVar ${idl_file} HC_IDXI1    "${GLBHC_I1:--1}"
      ModifyIDLVar ${idl_file} HC_IDXJ0    "${GLBHC_J0:--1}"
      ModifyIDLVar ${idl_file} HC_IDXJ1    "${GLBHC_J1:--1}"

      [ "${date0}" = "${last_day}" ] && break
    done
  popd >/dev/null

  return 0
}

#------------------------------------------------------------
# SOURCE THE FORECAST FUNCTIONS AND ENVIRONMENT FILES
if [ -f "${CAST_XENV}" ]; then
  source ${CAST_XENV}
else
  echo " ### ERROR:: in ${scrNAME}"
  echo "     The CAST_XENV environment variable is not set or"
  echo "     it points to a non-existing file"
  echo "       CAST_XENV = ${CAST_XENV:-UNDEF}"
  echo "     Exiting now ..."
  echo
  exit 1
fi
#------------------------------------------------------------
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

GetPathEnvVar idl "${IDL_DIR}" reverse

#============================================================
# END:: SETTING DEFAULTS AND/OR THE USER INPUT
#============================================================

theMODEL="roms"
theDOM="${DOM_OCN}"


#============================================================
# BEG:: CALCULATIONS
#============================================================

##### Create the IDL files for theMODEL
ListIdlFiles=
ListBatchFiles=

if [ ${NO_INI} -le 0 ]; then
  IdlFilesIni ${theMODEL} ${theDOM}
  ListIdlFiles="${ListIdlFiles} ${listIDL}"
  ListBatchFiles="${ListBatchFiles} ${listBATCH}"
  unset listIDL listBATCH
fi

if [ ${NO_BRY} -le 0 ]; then
  IdlFilesBry ${theMODEL} ${theDOM}
  ListIdlFiles="${ListIdlFiles} ${listIDL}"
  ListBatchFiles="${ListBatchFiles} ${listBATCH}"
  unset listIDL listBATCH
fi

##### Check for the required IDL files
ListIdlFiles="$( strTrim "${ListIdlFiles}" 2 )"
ListBatchFiles="$( strTrim "${ListBatchFiles}" 2 )"
if [ "X${ListIdlFiles}" = "X" ]; then
  procError "no idl files were defined"
fi


############################################################
##### Run the parallel program
echo "        Creating the \"$(echo ${theMODEL} | tr [a-z] [A-Z])\" boundary and initial conditions files ..."

pushd ${IdlDir} >/dev/null
  GPARAL_JOBLOG="${LogDir}/${scrNAME%%.*}-status.log"
  GPARAL_RUNLOG="${LogDir}/${scrNAME%%.*}-run.log"

  GPARAL_OPTS="${GPARAL_OPTS_GLB} ${GPARAL_OPTS_SSH} ${GPARAL_OPTS_TIME}"
  GPARAL_OPTS="${GPARAL_OPTS} --joblog ${GPARAL_JOBLOG} ${GPARAL_OPTS_RESUME}"
  GPARAL_OPTS="${GPARAL_OPTS} --wd ${IdlDir} -j0"

  # Remove any old log files
  [ -f ${GPARAL_RUNLOG} ] && rm -f ${GPARAL_RUNLOG}
  [ -f ${GPARAL_JOBLOG} ] && rm -f ${GPARAL_JOBLOG}

  # We cannot run parallel in the background, somehow remote jobs are not
  # killed properly when a failure occurs and subsequently parallel does not exit
  ${GPARAL} ${GPARAL_OPTS} ${IDL_CMD} {} ::: $(cat ${ListBatchFiles}) > ${GPARAL_RUNLOG} 2>&1
  FAILURE_STATUS=$?

  if [ ${FAILURE_STATUS} -eq 0 -a ${CLEANUP} -ge 1 ]; then
    echo "        Cleaning all INI/BRY related temporary files ..."
    for ilist in ${ListIdlFiles} ${ListBatchFiles}
    do
      for ifile in $(cat ${ilist})
      do
        [ -f "${ifile}" ] && rm -f "${ifile}"
      done
      [ -f "${ilist}" ] && rm -f "${ilist}"
    done
  fi
popd >/dev/null

if [ ${FAILURE_STATUS} -eq 0 ]; then
  imod="${theMODEL}"
  dom_str="_d`get2DString ${theDOM}`"

  pushd ${BryDir} >/dev/null
    for ityp in clim bry
    do
      for imo in {1..12}
      do
        regex="[1-9][0-9][0-9][0-9]"
        mo_str="`get2DString ${imo}`"
        files=( $( find . -mindepth 1 -maxdepth 1 -type f \
                         -iname "${imod}${ityp}${dom_str}_${regex}-${mo_str}*.nc" \
                         -exec basename {} \; | sort -u ) )
        if [ ${#files[@]} -ne 0 ]; then
          this_date="$( echo "${files[0]%%.*}" | sed -e "s@${imod}${ityp}${dom_str}_@@g" | sed -e 's/_/ /g' )"
          files="$( strTrim "${files[*]}" 2 )"
          file_stamp="$( date -d "${this_date}" "+%Y-%m-%d_%H:00:00" )"
          file_out="${imod}${ityp}${dom_str}_${file_stamp}.nc"
          ncrcat -h ${files} ${file_out}.tmp
          if [ $? -eq 0 ]; then
            rm -f ${files}
            mv -f ${file_out}.tmp ${file_out}
            #link_stamp="$( date -d "${this_date}" "+%Y${mo_str}" )"
            #linkFILE "${file_out}" "${imod}${ityp}${dom_str}-${link_stamp}.nc"
          fi
        fi
      done
    done
  popd >/dev/null

#  pushd ${IniDir} >/dev/null
#    for ityp in init
#    do
#      file_stamp="$( date -d "${SimBeg}" "+%Y-%m-%d_%H:00:00" )"
#      file_out="${imod}${ityp}${dom_str}_${file_stamp}.nc"
#      if [ -f "${file_out}" ]; then
#        link_stamp="$( date -d "${SimBeg}" "+%Y%m" )"
#        linkFILE "${file_out}" "${imod}${ityp}${dom_str}-${link_stamp}.nc"
#      fi
#    done
  popd >/dev/null
fi

for ilog in ${GPARAL_JOBLOG} ${GPARAL_RUNLOG}
do
  log_file="${ilog}"
  stripESCFILE "${log_file}"
done

# END:: Calculations
#------------------------------------------------------------

exit ${FAILURE_STATUS:-0}
