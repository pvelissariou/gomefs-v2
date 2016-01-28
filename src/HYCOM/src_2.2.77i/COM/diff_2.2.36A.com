#
set echo
#
foreach f ( READ* Makefile Make.com *.h *.f *.F *.c )
  echo "*****     *****     *****     *****     *****     *****     *****"
# diff -ibw $f ~/hycom/GLBT0.72/src_2.2.36_32_mpi
  diff -ibw $f ~/hycom/GOMl0.04/src_2.2.36Ai13_20_mpi
end
