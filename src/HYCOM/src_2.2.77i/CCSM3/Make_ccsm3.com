#!/bin/csh
#
#BSUB -J        Make_ccsm3
#BSUB -o        Make_ccsm3.log
#BSUB -e        Make_ccsm3.log
#BSUB -W        12:00
#BSUB -P        NRLSS018
#BSUB -q        share
#BSUB -n        1
#
set echo
cd $cwd
#
# --- Usage:  ./Make_ccsm3.com >& Make_ccsm3.log
#
# --- Make CCSM3 version of HYCOM
# --- Assume that needed files are in this directory.
#
# --- some machines require gmake
#
#gmake -f Makefile_ccsm3 hycom
make -f Makefile_ccsm3 hycom
