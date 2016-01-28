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
#  Check for the required NetCDF files.
#--------------------------------------------------------------------------

 NETCDF_MOD := netcdf.mod
NETCDF_TYPE := typesizes.mod
NETCDF_LIBS := -L$(NETCDF_LIBDIR) -lnetcdf -lnetcdff

ifneq ($(MAKECMDGOALS),clean)
  ifneq ($(MAKECMDGOALS),realclean)
    ifeq (, $(wildcard $(NETCDF_INCDIR)/$(NETCDF_MOD)))
      $(error Could not locate the file: "$(NETCDF_MOD)" (set variable NETCDF_INCDIR))
    endif

    ifeq (, $(wildcard $(NETCDF_INCDIR)/$(NETCDF_TYPE)))
      $(error Could not locate the file: "$(NETCDF_TYPE)" (set variable NETCDF_INCDIR))
    endif

    ifeq (, $(wildcard $(NETCDF_LIBDIR)/libnetcdf.*))
      $(error Could not locate the files: "libnetcdf.*" (set variable NETCDF_LIBDIR))
    endif

    ifeq (, $(wildcard $(NETCDF_LIBDIR)/libnetcdff.*))
      $(error Could not locate the files: "libnetcdff.*" (set variable NETCDF_LIBDIR))
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

PROGRAMS =

NCDF_PROGRAMS = archv2nc

ALL_PROGRAMS := $(PROGRAMS) $(NCDF_PROGRAMS)


#--------------------------------------------------------------------------
#  Targets to create the executables.
#--------------------------------------------------------------------------

.PHONY: all

all: ncdf_req $(ALL_PROGRAMS)


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

MODS = date_sub.o globals.o

OBJS = ncrange.o wrtNcdf.o archv2nc.o raw.o locate.o

SRCS = archv2nc.f wrtNcdf.f ncrange.f locate.f raw.f globals.F date_sub.F


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

archv2nc: $(MODS) $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) -o archv2nc \
	$(MODS) $(OBJS) $(NETCDF_LIBS)


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

archv2nc.o: archv2nc.f globals.o date_sub.o wrtNcdf.o raw.o locate.o
wrtNcdf.o:  wrtNcdf.f ncrange.o globals.o
ncrange.o:  ncrange.f
globals.o:  globals.F
data_sub.o: date_sub.F
raw.o:      raw.f


#--------------------------------------------------------------------------
#  NetCDF requirements.
#--------------------------------------------------------------------------

.PHONY: ncdf_req

ncdf_req:
	  rm -f $(NETCDF_MOD)
	/bin/cp -f $(NETCDF_INCDIR)/$(NETCDF_MOD) $(NETCDF_MOD)
	  rm -f $(NETCDF_TYPE)
	/bin/cp -f $(NETCDF_INCDIR)/$(NETCDF_TYPE) $(NETCDF_TYPE)


#--------------------------------------------------------------------------
#  Cleaning targets.
#--------------------------------------------------------------------------

.PHONY: clean

clean:
	rm -f *.o *.a *.mod M*log


.PHONY: realclean

realclean: clean
	rm -f $(ALL_PROGRAMS)
