#
# Makefile for cice processing
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

PROGRAMS = cice_tiles grid2cice

NCDF_PROGRAMS = cice2hycom

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

MODS     =	mod_cice.o mod_xc.o mod_za.o wtime.o

GRID_OBJ = 	blkin.o  \
		zh.o dum_gks.o 

ARCHV_OBJ = 	bigrid.o blkin.o  \
		forday.o  \
                putdat.o \
		zh.o dum_gks.o 


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

cice2hycom: $(MODS) cice2hycom.o $(GRID_OBJ)
	$(LD) $(LDFLAGS) cice2hycom.o \
	      $(GRID_OBJ) $(MODS) $(NETCDF_LIBS) -o cice2hycom

cice_tiles: $(MODS) cice_tiles.o blkin.o
	$(LD) $(LDFLAGS) cice_tiles.o blkin.o \
	      -o cice_tiles

grid2cice: $(MODS) grid2cice.o $(GRID_OBJ)
	$(LD) $(LDFLAGS) grid2cice.o \
	      $(GRID_OBJ) $(MODS) -o grid2cice


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

cice_tiles.o: cice_tiles.F
cice2hycom.o: cice2hycom.f                  mod_za.o
grid2cice.o:  grid2cice.f        mod_cice.o mod_za.o

bigrid.o:   bigrid.f      mod_cice.o
blkin.o:    blkin.f
dum_gks.o:  dum_gks.f
forday.o:   forday.f
putdat.o:   putdat.f      mod_cice.o mod_za.o
wtime.o:    wtime.F

mod_cice.o: mod_cice.F
mod_xc.o:   mod_xc.F   
mod_za.o:   mod_za.F   mod_xc.o

zh.o:       zh.F zh_sun.f zh_t3e.f zh_ymp.f


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
