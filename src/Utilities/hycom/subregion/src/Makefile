#
# Makefile for subregion processing
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

PROGRAMS = isubregion isub3region isuba_arche isuba_field isuba_gmapi \
           isuba_topog isubaregion half_topog sub_grid

NCDF_PROGRAMS = isubs_field isubs_count

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

MODS = mod_xc.o mod_za.o mod_zb.o wtime.o zh.o
MODX = mod_xc.o mod_za.o mod_zb.o wtime.o zh.o mod_scrip.o


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

isubaregion: $(MODS) isubaregion.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isubaregion.o \
	      $(MODS) -o isubaregion

isubregion: $(MODS) isubregion.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isubregion.o \
	      $(MODS) -o isubregion

isub3region: $(MODS) isub3region.o extrct.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isub3region.o extrct.o \
	      $(MODS) -o isub3region

isuba_arche: $(MODS) isuba_arche.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isuba_arche.o \
	      $(MODS) -o isuba_arche

isuba_field: $(MODS) isuba_field.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isuba_field.o \
	      $(MODS) -o isuba_field

isubm_field: $(MODS) isubm_field.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isubm_field.o \
	      $(MODS) -o isubm_field

isubs_count: $(MODX) isubs_count.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isubs_count.o \
	      $(MODX) $(NETCDF_LIBS) -o isubs_count

isubs_field: $(MODX) isubs_field.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isubs_field.o \
	      $(MODX) $(NETCDF_LIBS) -o isubs_field

isuba_gmap: $(MODS) isuba_gmap.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isuba_gmap.o \
	      $(MODS) -o isuba_gmap

isuba_gmapi: $(MODS) isuba_gmapi.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isuba_gmapi.o \
	      $(MODS) -o isuba_gmapi

isuba_topog: $(MODS) isuba_topog.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isuba_topog.o \
	      $(MODS) -o isuba_topog

isub_topog: $(MODS) isub_topog.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isub_topog.o \
	      $(MODS) -o isub_topog

isubx_gmap: $(MODS) isubx_gmap.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) isubx_gmap.o \
	      $(MODS) -o isubx_gmap

sub_grid: $(MODS) sub_grid.o  extrct.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sub_grid.o  extrct.o \
	      $(MODS)  -o sub_grid

half_topog: $(MODS) half_topog.o        
	$(LD) $(LDFLAGS) $(X_LDFLAGS) half_topog.o \
	      $(MODS) -o half_topog


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

mod_scrip.o: mod_scrip.f
mod_xc.o:    mod_xc.F
mod_za.o:    mod_za.F mod_xc.o
mod_zb.o:    mod_za.F mod_xc.o

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
