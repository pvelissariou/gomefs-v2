#
# MakeDefs file
#

USE_FORT := $(shell echo $(FORT) | tr "-" "_" | tr [a-z] [A-Z])

ifeq ($(USE_FORT),IFORT)
  X_FFLAGS   := -warn nogeneral -convert big_endian -assume byterecl -mcmodel=medium
  X_CFLAGS   := -mcmodel=medium
  X_CPPFLAGS := -DIA32 -DREAL4
  X_LDFLAGS  := -shared-intel
else ifeq ($(USE_FORT),IFC)
  X_FFLAGS   := -convert big_endian
  X_CFLAGS   :=
  X_CPPFLAGS := -DIA32 -DREAL4
  X_LDFLAGS  :=
else
  $(error Compiler "$(FORT)" is not supported)
endif
