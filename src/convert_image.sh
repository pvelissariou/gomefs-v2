#!/bin/bash

# Author:  Panagiotis Velissariou <pvelissariou@fsu.edu>
#                                 <velissariou.1@osu.edu>
# Version: 1.0
#
# Version - 1.0 Thu Nov 26 12015


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
isNumber()
{
  local -i retval=1
  local numb="${1}"

  local pat pat1 pat2

  # Remove leading/trailing whitespace characters. Approach 1
  #numb="$(echo "${1}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

  # Remove leading/trailing whitespace characters. Approach 2
  numb="${numb#"${numb%%[![:space:]]*}"}"
  numb="${numb%"${numb##*[![:space:]]}"}"

  [ -z "${numb:-}" ] && return ${retval}

    pat1='[^0-9dDeE+\.\-]'
  [[ "${numb}" =~ ${pat1} ]] && return ${retval}

    pat1='^([-+]?[0-9]+)?([.][0-9]+)?([eE][-+]?[0-9]+)?$'
    pat2='^([-+]?[0-9]+)?([.][0-9]+)?([dD][-+]?[0-9]+)?$'
  for pat in ${pat1} ${pat2}
  do
    if  [[ "${numb}" =~ ${pat} ]] ; then
       retval=0
       break
    fi
  done

  return ${retval}
}

function toUPPER()
{
  echo "${1}" | tr '[:lower:]' '[:upper:]'
}

function toLOWER()
{
  echo "${1}" | tr '[:upper:]' '[:lower:]'
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


  all_evars="CONV_PROG CONV_OPT DENS GEOM FILES SFX VERBOSE"

  for ival in ${all_evars}
  do
    unset __${ival}
  done


  __CONV_PROG=convert
  #__DENS=400
  #__GEOM=25
  __SFX=jpg
  __VERBOSE=0


  # -----
  # Process the function options
  opt_all=( conv conv_opt dens geom files sfx v h help )
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
      -conv | --conv )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            __CONV_PROG="$( echo "${opt_arg}" | sed 's/[[:space:]]//g' )"
          fi
        ;;
      -conv_opt | --conv_opt )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            __CONV_OPT="$( strTrim "${opt_arg}" 2 )"
          fi
        ;;
      -dens | --dens )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            if $( isNumber "${opt_arg}" ); then
              __DENS=${opt_arg}
            fi
          fi
        ;;
      -geom | --geom )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            if $( isNumber "${opt_arg}" ); then
              __GEOM=${opt_arg}
            fi
          fi
        ;;
      -files | --files )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            __FILES="$( strTrim "${opt_arg}" 2 )"
          fi
        ;;
      -sfx | --sfx )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          if [ "X${opt_arg}" != "X" ]; then
            __SFX="$( strTrim "${opt_arg}" 2 )"
          fi
        ;;
      -v | --v )
          checkFuncOpt "$( echo "${opt_opt}" | sed 's/^[-]*//' )"
          __VERBOSE=1
          if [ "X${opt_arg}" != "X" ]; then
            [ "$( getYesNo "${opt_arg}" )" = "no" ] && __VERBOSE=0
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
  # -----

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
  echo "This script uses ImageMagick or GraphicsMagick to perform all image manipulations."
  echo
  echo "Usage: \"${nm}\" [{-|--}option1{=|space}[option_value1]] [{-|--}option2{=|space}[option_value2]] ..."
  echo "Example:    -conv convert,  -conv=convert"
  echo "           --conv convert, --conv=convert"
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
  echo "   v \"verbose\"; Associated EnvVar: VERBOSE (optional)."
  echo "       Make the convert program to be verbose."
  echo "       Default: no."
  #---
  echo "   conv \"convert program\"; Associated EnvVar: CONV_PROG (optional)."
  echo "       The name of the program to use to convert the images."
  echo "       Default: convert."
  #---
  echo "   conv_opt \"convert options\"; Associated EnvVar: CONV_OPT (optional)."
  echo "       The string that contains all options to the convert program."
  echo "       conv_opt=\"opt1 opt2 ...\"."
  echo "       Default: \"-flatten -antialias -colorspace RGB -density 400 -geometry 25% -quality 100\"."
  #---
  echo "   dens \"dens\"; Associated EnvVar: DENS (optional)."
  echo "       The horizontal and vertical density of the resulting image."
  #echo "       Default: 400."
  echo "       Default: not set."
  #---
  echo "   geom \"geom\"; Associated EnvVar: GEOM (optional)."
  echo "       The preferred size or location of the resulting image."
  #echo "       Default: 25."
  echo "       Default: not set."
  #---
  echo "   files \"image files\"; Associated EnvVar: FILES (mandatory)."
  echo "       The list of image files to convert."
  echo "       files=\"image*.pdf images/*.ps ...\"."
  echo "       Default: not set."
  #---
  echo "   sfx \"image suffix\"; Associated EnvVar: SFX (optional)."
  echo "       The suffix of the resulting image file."
  echo "       It is used from the convert program to write the correct format of the resulting image."
  echo "       Default: jpg."

  exit 0
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

#============================================================
# END:: SETTING DEFAULTS AND/OR THE USER INPUT
#============================================================


#============================================================
# BEG:: CHECK THE VARIABLES
#============================================================

CONV_PROG=$( getPROG ${CONV_PROG:-} )
[ $? -ne 0 ] && procError "${CONV_PROG}"

#DENS=${DENS:-400}
#GEOM=${GEOM:-25}

SFX=${SFX:-jpg}
SFX=${SFX##*.}

if [ -z "${CONV_OPT:-}" ]; then
  CONV_OPT="-flatten -antialias -quality 100"
  [ -n "${DENS:+1}" ] && CONV_OPT="${CONV_OPT} -density ${DENS}"
  [ -n "${GEOM:+1}" ] && CONV_OPT="${CONV_OPT} -geometry ${GEOM}%"
fi

if [ -z "${FILES:-}" ]; then
  procError "A list of input image files is required to proceed with the conversions." \
            "  FILES = ${FILES:-UNDEF}"
fi

#============================================================
# END:: CHECK THE VARIABLES
#============================================================


#============================================================
# BEG:: CALCULATIONS
#============================================================

for ifile in ${FILES}
do
  if $( checkFILE -r "${ifile}" ); then
    extINP=${ifile##*.}
    extOUT=${SFX}

    fileINP=${ifile}
    fileOUT=${ifile%%.${extINP}}.${SFX}

    if [ ${VERBOSE:-0} -gt 0 ]; then
      ${CONV_PROG} -verbose ${CONV_OPT} ${fileINP} ${fileOUT}
      if [ $? -ne 0 ]; then
        [ -e ${fileOUT} ] && rm -f ${fileOUT}
      else
        echo "Converted:  ${fileINP} -> ${fileOUT}"
      fi
    else
      ${CONV_PROG} ${CONV_OPT} ${fileINP} ${fileOUT} >/dev/null 2>&1
      if [ $? -ne 0 ]; then
        [ -e ${fileOUT} ] && rm -f ${fileOUT}
      else
        echo "Converted:  ${fileINP} -> ${fileOUT}"
      fi
    fi
  fi
done

#============================================================
# END:: CALCULATIONS
#============================================================

exit 0
