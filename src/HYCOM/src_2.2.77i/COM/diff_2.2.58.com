#
set echo
#
foreach f ( READ* Makefile Make.com *.h *.f *.F *.c )
  echo "*****     *****     *****     *****     *****     *****     *****"
  diff -ibw $f ~/hycom/GLBt0.72/src_2.2.58_02_mpi
end
