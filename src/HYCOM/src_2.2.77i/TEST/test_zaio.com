#!/bin/csh
#
#@ job_name         = test_zaio
#@ output           = $(job_name).log
#@ error            = $(job_name).log
#@ restart          = yes
#@ job_type         = parallel
#@ network.MPI      = css0,not_shared,US
#@ environment      = MP_EUILIB=us     
#@ node             = 1
#@ total_tasks      = 3
#@ node_usage       = not_shared
#@ wall_clock_limit = 0:10:00
#@ account_no       = NRLSS018
#@ class            = batch
#@ queue
#
set echo
set time = 1
set timestamp
#
setenv MP_SHARED_MEMORY yes
setenv MP_SINGLE_THREAD yes
setenv MP_EAGER_LIMIT   65536
#setenv MP_EUILIB       us
#setenv MP_EUIDEVICE    css0
#
# --- test zaiod and zaiowr, 1-d partitioning.
#
cd ~/hycom/ATLa2.00/src_2.0.01_16_ompi/TEST
#
touch   regional.depth.a
/bin/rm regional.depth.a
ln -s ../../topo/depth_ATLa2.00_01.a regional.depth.a
#
# --- 3x1.
#
touch      fort.029
/bin/rm -f fort.029*
#
touch   patch.input
/bin/rm patch.input
ln -s ../../topo/partit/depth_ATLa2.00_01.03x01 patch.input
cat     patch.input
poe ./test_zaio
#setenv NPES 3
#mpprun -n $NPES ./test_zaio
#
ls -oF fort.029*
cmp fort.029 fort.029a
#
# --- 1x3.
#
touch      fort.029
/bin/rm -f fort.029*
#
touch   patch.input
/bin/rm patch.input
ln -s ../../topo/partit/depth_ATLa2.00_01.01x03 patch.input
cat     patch.input
poe ./test_zaio
#setenv NPES 3
#mpprun -n $NPES ./test_zaio
#
ls -oF fort.029*
cmp fort.029 fort.029a
