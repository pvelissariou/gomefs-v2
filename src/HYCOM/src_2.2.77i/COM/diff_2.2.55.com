#
set echo
#
foreach f ( READ* Makefile Make.com *.h *.f *.F *.c )
  echo "*****     *****     *****     *****     *****     *****     *****"
  diff -ibw $f ~/hycom/GLBt0.72/src_2.2.55-17t-2io_32_mpi
end
