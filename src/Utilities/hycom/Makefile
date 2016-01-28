#::::::::::::::::::::::::::::::::::::::::::::::: Panagiotis Velissariou :::
# Original makefile was adopted from the ROMS model directory           :::
# Modified for HYCOM implementation                                     :::
#                                                                       :::
# Copyright (c) 2015-2014 The ROMS/TOMS Group             Kate Hedstrom :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.txt                                                :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#                                                                       :::
#  This makefile is designed to work only with GNU Make version 3.80 or :::
#  higher. It can be used in any architecture provided that there is a  :::
#  machine/compiler rules file in the  "Compilers"  subdirectory.  You  :::
#  may need to modify the rules file to specify the  correct path  for  :::
#  the NetCDF.                                                          :::
#                                                                       :::
#  If appropriate,  the USER needs to modify the  macro definitions in  :::
#  in user-defined section below.  To activate an option set the macro  :::
#  to "on". For example, if you want to compile with debugging options  :::
#  set:                                                                 :::
#                                                                       :::
#      USE_DEBUG := on                                                  :::
#                                                                       :::
#  Otherwise, leave macro definition blank.                             :::
#                                                                       :::
#  The USER needs to provide a value for the  macro FORT.  Choose  the  :::
#  appropriate value from the list below.                               :::
#                                                                       :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

NEED_VERSION := 3.80 3.81 3.82 3.82.90 4.0 4.1
$(if $(filter $(MAKE_VERSION),$(NEED_VERSION)),,        \
 $(error This makefile requires one of GNU make version $(NEED_VERSION).))

#==========================================================================
#  Start of user-defined options. In some macro definitions below: "on" or
#  any other string means TRUE while blank (or spaces) is FALSE.
#==========================================================================

#  Define the sub-directories to build:
#SUBDIRS := bin archive cice data force meanstd ncom \
#           plot \
#           relax roms sample subregion topo

SUBDIRS := bin archive data force \
           relax roms sample subregion topo

#  Activate debugging compiler options:

USE_DEBUG ?=

#  If applicable, link with NetCDF-4 library. Notice that the NetCDF-4
#  library needs both the HDF5 and MPI libraries.

  USE_NETCDF4 ?=
NETCDF_INCDIR ?=
NETCDF_LIBDIR ?=

#  NCL library paths (used in plots directory).
NCL_INCDIR ?= /usr/include/ncarg
NCL_LIBDIR ?= /usr/lib64/ncarg

#--------------------------------------------------------------------------
#  We are going to include a file with all the settings that depend on
#  the system and the compiler. We are going to build up the name of the
#  include file using information on both. Set your compiler here from
#  the following list:
#
#  Operating System        Compiler(s)
#
#     AIX:                    xlf
#     ALPHA:                  f90
#     CYGWIN:                 g95, df, ifort
#     Darwin:                 f90, xlf
#     IRIX:                   f90
#     Linux:                  ftn, ifc, ifort, pgi, path, g95, gfortran
#     SunOS:                  f95
#     UNICOS-mp:              ftn
#     SunOS/Linux:            ftn (Cray cross-compiler)
#
#  Feel free to send us additional rule files to include! Also, be sure
#  to check the appropriate file to make sure it has the right paths to
#  NetCDF and so on.
#--------------------------------------------------------------------------

        FORT ?=

  CURRENT_DIR = $(shell pwd)
       BINDIR = $(CURRENT_DIR)/Build

#==========================================================================
#  End of user-defined options. See also the machine-dependent include
#  file being used above.
#==========================================================================

#--------------------------------------------------------------------------
#  "uname -s" should return the OS or kernel name and "uname -m" should
#  return the CPU or hardware name. In practice the results can be pretty
#  flaky. Run the results through sed to convert "/" and " " to "-",
#  then apply platform-specific conversions.
#--------------------------------------------------------------------------

OS := $(shell uname -s | sed 's/[\/ ]/-/g')
OS := $(patsubst CYGWIN_%,CYGWIN,$(OS))
OS := $(patsubst MINGW%,MINGW,$(OS))
OS := $(patsubst sn%,UNICOS-sn,$(OS))

CPU := $(shell uname -m | sed 's/[\/ ]/-/g')

ifneq ($(MAKECMDGOALS),clean)
  ifneq ($(MAKECMDGOALS),realclean)
    ifndef FORT
      $(error Variable FORT not set)
    endif

    USE_WRF =
    USE_HYCOM =
    USE_SWAN =
    USE_MCT =
    USE_ESMF =
    USE_MPI =
    USE_MPIF90 =
    USE_OpenMP =

    include ../../Compilers/$(OS)-$(strip $(FORT)).mk
  endif
endif

#--------------------------------------------------------------------------
#  Pass the platform variables to the preprocessor as macros. Convert to
#  valid, upper-case identifiers. Attach ROMS application  CPP options.
#--------------------------------------------------------------------------

CPPFLAGS += -D$(shell echo ${OS} | tr "-" "_" | tr [a-z] [A-Z])
CPPFLAGS += -D$(shell echo ${CPU} | tr "-" "_" | tr [a-z] [A-Z])
CPPFLAGS += -D$(shell echo ${FORT} | tr "-" "_" | tr [a-z] [A-Z])

#--------------------------------------------------------------------------
#  Targets to create the executables.
#--------------------------------------------------------------------------
MAKE_VARS = ROOTDIR="$(CURRENT_DIR)" \
            BINDIR="$(BINDIR)" \
            NETCDF_INCDIR="$(NETCDF_INCDIR)" \
            NETCDF_LIBDIR="$(NETCDF_LIBDIR)" \
            NCL_INCDIR="$(NCL_INCDIR)" \
            NCL_LIBDIR="$(NCL_LIBDIR)" \
            FC="$(FC)" \
            FFLAGS="$(FFLAGS)" \
            CPP="$(CPP)" \
            CPPFLAGS="$(CPPFLAGS)" \
            CC="$(CC)" \
            CXX="$(CXX)" \
            CFLAGS="$(CFLAGS)" \
            CXXFLAGS="$(CXXFLAGS)" \
            LD="$(LD)" \
            LDFLAGS="$(LDFLAGS)" \
            AR="$(AR)" \
            ARFLAGS="$(ARFLAGS)" \
            MKDIR="$(MKDIR)" \
            RM="$(RM)" \
            RANLIB="$(RANLIB)"


.PHONY: all

all:
	@for i in $(SUBDIRS) ; do \
	  dir=$(CURRENT_DIR)/$$i; \
	  if (test -d $$dir/src) then \
	    (echo; echo "----------"; \
	     echo "Making target <all> in $$dir/src"; \
	     echo "----------"; \
	     cd $$dir/src && make $(MAKE_VARS) all); \
	  else \
	    if (test -d $$dir) then \
	      (echo; echo "----------"; \
	       echo "Making target <all> in $$dir"; \
	       echo "----------"; \
	       cd $$dir && make $(MAKE_VARS) all); \
	    else \
	      (echo; echo "----------"; \
	       echo "NOT Making target <all> in $$dir"; \
	       echo "----------"); \
	    fi \
	  fi \
	done


#--------------------------------------------------------------------------
#  Installing targets.
#--------------------------------------------------------------------------

.PHONY: install

install:
	@for i in $(SUBDIRS) ; do \
	  dir=$(CURRENT_DIR)/$$i; \
	  if (test -d $$dir/src) then \
	    (echo; echo "----------"; \
	     echo "Making target <install> in $$dir/src"; \
	     echo "----------"; \
	     cd $$dir/src && make $(MAKE_VARS) install); \
	  else \
	    if (test -d $$dir) then \
	      (echo; echo "----------"; \
	       echo "Making target <install> in $$dir"; \
	       echo "----------"; \
	       cd $$dir && make $(MAKE_VARS) install); \
	    else \
	      (echo; echo "----------"; \
	       echo "NOT Making target <install> in $$dir"; \
	       echo "----------"); \
	    fi \
	  fi \
	done


#--------------------------------------------------------------------------
#  Cleaning targets.
#--------------------------------------------------------------------------

.PHONY: clean

clean:
	@for i in $(SUBDIRS) ; do \
	  dir=$(CURRENT_DIR)/$$i; \
	  if (test -d $$dir/src) then \
	    (echo; echo "----------"; \
	     echo "Making target <clean> in $$dir/src"; \
	     echo "----------"; \
	     cd $$dir/src && make clean); \
	  else \
	    if (test -d $$dir) then \
	      (echo; echo "----------"; \
	       echo "Making target <clean> in $$dir"; \
	       echo "----------"; \
	       cd $$dir && make clean); \
	    else \
	      (echo; echo "----------"; \
	       echo "NOT Making target <clean> in $$dir"; \
	       echo "----------"); \
	    fi \
	  fi \
	done


.PHONY: realclean

realclean:
	@for i in $(SUBDIRS) ; do \
	  dir=$(CURRENT_DIR)/$$i; \
	  if (test -d $$dir/src) then \
	    (echo; echo "----------"; \
	     echo "Making target <realclean> in $$dir/src"; \
	     echo "----------"; \
	     cd $$dir/src && make realclean); \
	  else \
	    if (test -d $$dir) then \
	      (echo; echo "----------"; \
	       echo "Making target <realclean> in $$dir"; \
	       echo "----------"; \
	       cd $$dir && make realclean); \
	    else \
	      (echo; echo "----------"; \
	       echo "NOT Making target <realclean> in $$dir"; \
	       echo "----------"); \
	    fi \
	  fi \
	done
	@if (test -d $(BINDIR)) then \
	  (echo; echo "----------"; \
	   echo "Removing $(BINDIR)"; \
	   echo "----------"; \
	   echo "rm -rf $(BINDIR)"; \
	   rm -rf $(BINDIR)); \
	fi
