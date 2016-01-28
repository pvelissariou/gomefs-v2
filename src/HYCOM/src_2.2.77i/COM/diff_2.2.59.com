#
set echo
#
foreach f ( READ* Makefile Make.com *.h *.f *.F *.c )
  echo "*****     *****     *****     *****     *****     *****     *****"
  diff -ibw $f ~/hycom/GLBt0.72/src_2.2.59_02_mpi
# diff -ibw $f ~/hycom/GOMl0.04/src_2.2.59_02_mpi
end
