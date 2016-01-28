#
# Makefile for ncom processing
#

ifneq ($(MAKECMDGOALS),clean)
  ifneq ($(MAKECMDGOALS),realclean)
    ifneq "$(strip $(ROOTDIR))" ""
      include $(ROOTDIR)/MakeDefs.mk
    else
      include MakeDefs.mk
    endif
  endif
endif


#--------------------------------------------------------------------------
#  Set Pattern rules.
#--------------------------------------------------------------------------

.c.o:
	$(CC) -c $(CPPFLAGS) $(X_CPPFLAGS) $(CFLAGS) $(X_CFLAGS)  -c $*.c

.f.o:
	$(FC) -c $(FFLAGS) $(X_FFLAGS) $*.f

.F.o:
	$(FC) -c $(CPPFLAGS) $(X_CPPFLAGS) $(FFLAGS) $(X_FFLAGS) $*.F


# ---------------------------------------------------------------------
# Makefile targets.
# ---------------------------------------------------------------------

PROGRAMS = ncom2archv ncomc2archv grid2ncom grid2ncom_arctic

ALL_PROGRAMS := $(PROGRAMS)


#--------------------------------------------------------------------------
#  Targets to create the executables.
#--------------------------------------------------------------------------

.PHONY: all

all: $(ALL_PROGRAMS)


#--------------------------------------------------------------------------
#  Installing targets.
#--------------------------------------------------------------------------

.PHONY: install

install: all
	@mkdir -p $(BINDIR)
	@for prog in $(ALL_PROGRAMS) ; do \
        echo "Installing $(BINDIR)/$$prog"; \
	install -m 0755 $$prog $(BINDIR)/$$prog; \
	done


# ---------------------------------------------------------------------
# Source and object definitions.
# ---------------------------------------------------------------------

MODS     =	mod_ncom.o mod_xc.o mod_za.o wtime.o

ARCHV_OBJ = 	bigrid.o blkin.o  \
		forday.o  \
                getdat.o putdat.o \
		zh.o    dum_gks.o 


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

ncom2archv: $(MODS) ncom2archv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) ncom2archv.o \
	      $(MODS) $(ARCHV_OBJ) -o ncom2archv

ncomc2archv: $(MODS) ncomc2archv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) ncomc2archv.o \
	      $(MODS) $(ARCHV_OBJ) -o ncomc2archv

grid2ncom: $(MODS) grid2ncom.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid2ncom.o \
	      $(MODS) $(ARCHV_OBJ) -o grid2ncom

grid2ncom_arctic: $(MODS) grid2ncom_arctic.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid2ncom_arctic.o \
	      $(MODS) $(ARCHV_OBJ) -o grid2ncom_arctic


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

ncom2archv.o:       ncom2archv.f       mod_ncom.o mod_za.o
ncomc2archv.o:      ncomc2archv.f      mod_ncom.o mod_za.o
grid2ncom.o:        grid2ncom.f        mod_ncom.o mod_za.o
grid2ncom_arctic.o: grid2ncom_arctic.f mod_ncom.o mod_za.o

bigrid.o:   bigrid.f      mod_ncom.o
blkin.o:    blkin.f
dum_gks.o:  dum_gks.f
forday.o:   forday.f
getdat.o:   getdat.f      mod_ncom.o mod_za.o
putdat.o:   putdat.f      mod_ncom.o mod_za.o
wtime.o:    wtime.F

mod_ncom.o: mod_ncom.F
mod_xc.o:   mod_xc.F   
mod_za.o:   mod_za.F   mod_xc.o

zh.o:       zh.F zh_sun.f zh_t3e.f zh_ymp.f


#--------------------------------------------------------------------------
#  Cleaning targets.
#--------------------------------------------------------------------------

.PHONY: clean

clean:
	rm -f *.o *.a *.mod M*log


.PHONY: realclean

realclean: clean
	rm -f $(ALL_PROGRAMS)
