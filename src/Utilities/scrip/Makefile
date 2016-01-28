#::::::::::::::::::::::::::::::::::::::::::::::: Panagiotis Velissariou :::
# Original makefile was adopted from the ROMS model directory           :::
# Modified for SCRIP implementation                                     :::
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
#SUBDIRS := source grids
SUBDIRS := source

#  Activate debugging compiler options:

USE_DEBUG ?=

#  If applicable, link with NetCDF-4 library. Notice that the NetCDF-4
#  library needs both the HDF5 and MPI libraries.

  USE_NETCDF4 ?=
NETCDF_INCDIR ?=
NETCDF_LIBDIR ?=

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
      DOCSDIR = $(CURRENT_DIR)/../../System/docs/scrip
#      SRC_DIR = $(shell ls | egrep '^scrip-[0-9]+.[0-9]+$$' | sort -ur | head -1)
      SRC_DIR = SCRIP

      DOCS = SCRIPusers.pdf
 MISC_DOCS =

#==========================================================================
#  End of user-defined options. See also the machine-dependent include
#  file being used above.
#==========================================================================

SRC_DIR := $(strip $(SRC_DIR))
ifeq ($(strip $(SRC_DIR)),)
  $(error Variable SRC_DIR is not set)
endif

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
    ifneq ($(MAKECMDGOALS),install-docs)
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
            EXEDIR="." \
            COMPILE="$(FC)" \
            COMP="$(FC)" \
            FLAGS="$(FFLAGS) -I$(NETCDF_INCDIR)" \
            LIB="-L$(NETCDF_LIBDIR) -lnetcdff -lnetcdf" \
            INCLUDE="$(NETCDF_INCDIR)"


.PHONY: all

all:
	@for i in $(SUBDIRS) ; do \
	  dir=$(SRC_DIR)/$$i; \
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
	done


#--------------------------------------------------------------------------
#  Installing targets.
#--------------------------------------------------------------------------

.PHONY: install

install: all
	@for i in $(SUBDIRS) ; do \
	  dir=$(SRC_DIR)/$$i; \
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
	done

install-docs:
	@mkdir -p $(DOCSDIR)
	@for doc in $(DOCS) ; do \
	  echo "Installing $(DOCSDIR)/$$doc"; \
	  install -m 0644 $(SRC_DIR)/doc/$$doc $(DOCSDIR)/$$doc; \
	done
	@for doc in $(MISC_DOCS) ; do \
	  echo "Installing $(DOCSDIR)/$$doc"; \
	  install -m 0644 $(SRC_DIR)/$$doc $(DOCSDIR)/$$doc; \
	done


#--------------------------------------------------------------------------
#  Cleaning targets.
#--------------------------------------------------------------------------

.PHONY: clean

clean:
	@for i in $(SUBDIRS) ; do \
	  dir=$(SRC_DIR)/$$i; \
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
	done


.PHONY: realclean

realclean:
	@for i in $(SUBDIRS) ; do \
	  dir=$(SRC_DIR)/$$i; \
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
	done
	@if (test -d $(BINDIR)) then \
	  (echo; echo "----------"; \
	   echo "Removing $(BINDIR)"; \
	   echo "----------"; \
	   echo "rm -rf $(BINDIR)"; \
	   rm -rf $(BINDIR)); \
	fi
