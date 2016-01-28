#::::::::::::::::::::::::::::::::::::::::::::::: Panagiotis Velissariou :::
# Original makefile was adopted from the ROMS model directory           :::
# Modified for GNU PARALLEL implementation                              :::
#                                                                       :::
# Copyright (c) 2015-2014 The ROMS/TOMS Group             Kate Hedstrom :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.txt                                                :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#                                                                       :::
#  This makefile is designed to work only with GNU Make version 3.80 or :::
#  higher.                                                              :::
#                                                                       :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

NEED_VERSION := 3.80 3.81 3.82 3.82.90 4.0 4.1
$(if $(filter $(MAKE_VERSION),$(NEED_VERSION)),,        \
 $(error This makefile requires one of GNU make version $(NEED_VERSION).))

#==========================================================================
#  Start of user-defined options. In some macro definitions below: "on" or
#  any other string means TRUE while blank (or spaces) is FALSE.
#==========================================================================

  CURRENT_DIR = $(shell pwd)
       BINDIR = $(CURRENT_DIR)/Build
      DOCSDIR = $(CURRENT_DIR)/../../System/docs/parallel
      SRC_DIR = $(shell ls | egrep '^parallel-[0-9]+$$' | sort -ur | head -1)

  PROGRAMS = niceload parallel sem sql

      DOCS = niceload.pdf parallel.pdf sem.pdf sql.pdf \
             parallel_design.pdf parallel_tutorial.pdf
 MISC_DOCS = CITATION COPYING CREDITS NEWS README

#==========================================================================
#  End of user-defined options. See also the machine-dependent include
#  file being used above.
#==========================================================================

SRC_DIR := $(strip $(SRC_DIR))
ifeq ($(strip $(SRC_DIR)),)
  $(error Variable SRC_DIR is not set)
endif

#--------------------------------------------------------------------------
#  Targets to create the executables.
#--------------------------------------------------------------------------

.PHONY: all

all:

#--------------------------------------------------------------------------
#  Installing targets.
#--------------------------------------------------------------------------

.PHONY: install

install: all
	@mkdir -p $(BINDIR)
	@for prog in $(PROGRAMS) ; do \
	  echo "Installing $(BINDIR)/$$prog"; \
	  install -m 0755 $(SRC_DIR)/src/$$prog $(BINDIR)/$$prog; \
	done

install-docs:
	@mkdir -p $(DOCSDIR)
	@for doc in $(DOCS) ; do \
	  echo "Installing $(DOCSDIR)/$$doc"; \
	  install -m 0644 $(SRC_DIR)/src/$$doc $(DOCSDIR)/$$doc; \
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
	rm -f *.o *.a *.mod M*log


.PHONY: realclean

realclean: clean
	@if (test -d $(BINDIR)) then \
	  (echo; echo "----------"; \
	   echo "Removing $(BINDIR)"; \
	   echo "----------"; \
	   echo "rm -rf $(BINDIR)"; \
	   rm -rf $(BINDIR)); \
	fi
