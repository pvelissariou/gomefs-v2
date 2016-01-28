#
set echo
#
foreach f ( READ* Makefile Make.com *.h *.f *.F *.c )
  echo "*****     *****     *****     *****     *****     *****     *****"
  diff -ibw $f ~/hycom/GLBT0.72/src_2.2.27i_32_mpi
end
