#! /bin/csh -x
#PBS -N test_xcp
#PBS -j oe
#PBS -o test_xcp.log
#PBS -W umask=027 
#PBS -l application=hycom
#PBS -l select=1:ncpus=64:mpiprocs=64
#PBS -l place=scatter:excl
#PBS -l walltime=0:10:00
#PBS -A NRLSS03755018
#PBS -q debug
#
set echo
set time = 1
set timestamp
#
setenv NMPI 64
setenv T hycom/GLBt0.72/src_2.2.59_02_mpi/TEST
#
mkdir -p /scr/${user}/${T}
cd       /scr/${user}/${T}
#
setenv NPATCH `echo $NMPI | awk '{printf("%04d", $1)}'`
/bin/cp ~/${T}/test_xcp .
/bin/cp ~/${T}/../../topo/partit/depth_GLBt0.72_14.${NPATCH}  patch.input
#
    setenv MP_SHARED_MEMORY     yes
    setenv MP_SINGLE_THREAD     yes
    setenv MP_EAGER_LIMIT       32768
    setenv MP_LABELIO		YES
    if      (-e /site/bin/launch) then
      setenv MEMORY_AFFINITY    MCM
      setenv UL_MODE            PURE_MPI
      setenv UL_TARGET_CPU_LIST AUTO_SELECT
      time poe /site/bin/launch ./test_xcp
    else
      time poe ./test_xcp
    endif
