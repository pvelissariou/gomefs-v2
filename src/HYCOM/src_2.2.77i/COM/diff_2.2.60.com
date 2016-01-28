#
set echo
#
foreach f ( READ* Makefile Make.com *.h *.f *.F *.c )
  echo "*****     *****     *****     *****     *****     *****     *****"
# diff -ibw $f ~/hycom/GLBt0.72/src_2.2.60_02_mpi
# diff -ibw $f ~/hycom/GOMl0.04/src_2.2.60_02_mpi
  diff -ibw $f ~/hycom/GLBb0.08/src_2.2.60smt_02_mpi
end
