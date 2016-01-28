#
# Makefile for archive processing
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

PROGRAMS = hycom_mean hycom_std hycom_diff hycom_wsum hesmf_mean \
           hesmf_std

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

MODS     =	mod_mean.o mod_mean_esmf.o mod_xc.o mod_za.o wtime.o zh.o

MEAN_OBJ = 	bigrid.o blkin.o \
		extrct.o \
                getdat.o putdat.o

MEAN_SRC = 	putdat.f


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

hycom_diff: $(MODS) hycom_diff.o $(MEAN_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_diff.o \
	      $(MODS) $(MEAN_OBJ) -o hycom_diff

hycom_mean: $(MODS) hycom_mean.o $(MEAN_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_mean.o \
	      $(MODS) $(MEAN_OBJ) -o hycom_mean

hycom_std: $(MODS) hycom_std.o $(MEAN_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_std.o \
	      $(MODS) $(MEAN_OBJ) -o hycom_std

hycom_wsum: $(MODS) hycom_wsum.o $(MEAN_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_wsum.o \
	      $(MODS) $(MEAN_OBJ) -o hycom_wsum

hesmf_mean: $(MODS) hesmf_mean.o $(MEAN_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hesmf_mean.o \
	      $(MODS) $(MEAN_OBJ) -o hesmf_mean

hesmf_std: $(MODS) hesmf_std.o $(MEAN_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hesmf_std.o \
	      $(MODS) $(MEAN_OBJ) -o hesmf_std


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

hesmf_mean.o: hesmf_mean.f            mod_mean_esmf.o mod_za.o
hesmf_std.o:  hesmf_std.f             mod_mean_esmf.o mod_za.o

hycom_diff.o: hycom_diff.f mod_mean.o                 mod_za.o
hycom_mean.o: hycom_mean.f mod_mean.o                 mod_za.o
hycom_std.o:  hycom_std.f  mod_mean.o                 mod_za.o
hycom_wsum.o: hycom_wsum.f mod_mean.o                 mod_za.o

bigrid.o:  bigrid.f        mod_mean.o mod_mean_esmf.o
blkin.o:   blkin.f
extrct.o:  extrct.f
getdat.o:  getdat.f        mod_mean.o mod_mean_esmf.o mod_za.o
putdat.o:  putdat.f        mod_mean.o mod_mean_esmf.o mod_za.o
wtime.o:   wtime.F

mod_mean.o: mod_mean.F
mod_mean_esmf.o: mod_mean_esmf.F
mod_xc.o:   mod_xc.F
mod_za.o:   mod_za.F	mod_xc.o

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
