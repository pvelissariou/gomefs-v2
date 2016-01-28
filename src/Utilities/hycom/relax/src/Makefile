#
# Makefile for relax processing
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

PROGRAMS = bottom iso_density relax_flat_rivers relax_tracer relaxi relaxv \
           rmu rmu2 tracer_const z_archive z_const z_levitus z_medatlas \
           z_modify z_modify sst_pf sst_pf_4km

#z_modas sst_rs Need SDS/HDF libraries

NCDF_PROGRAMS = ssh_modas sst_modas sst_gdem3 sst_gdem4 sst_woa \
                z_gdem3 z_gdem4 z_woa_tracer

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

MODS = mod_xc.o mod_za.o wtime.o
OBJS = blkdat.o interp.o zh.o
OBJN = blkdat.o interp.o zh.o


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

tracer_const: $(MODS) tracer_const.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) tracer_const.o \
	      $(MODS) $(OBJS) -o tracer_const

iso_density: $(MODS) iso_density.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) iso_density.o \
	      $(MODS) $(OBJS) -o iso_density

z_levitus: $(MODS) z_levitus.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_levitus.o \
	      $(MODS) $(OBJS) -o z_levitus

z_lev_tracer: $(MODS) z_lev_tracer.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_lev_tracer.o \
	      $(MODS) $(OBJS) -o z_lev_tracer

z_caspian: $(MODS) z_caspian.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_caspian.o \
	      $(MODS) $(OBJN) -o z_caspian

z_medatlas: $(MODS) z_medatlas.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_medatlas.o \
	      $(MODS) $(OBJS) -o z_medatlas

z_woa: $(MODS) z_woa.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_woa.o \
	      $(MODS) $(OBJN) -o z_woa

z_woa_med: $(MODS) z_woa_med.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_woa_med.o \
	      $(MODS) $(OBJN) -o z_woa_med

z_woa_med78: $(MODS) z_woa_med78.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_woa_med78.o \
	      $(MODS) $(OBJN) -o z_woa_med78

z_woa_tracer: $(MODS) z_woa_tracer.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_woa_tracer.o \
	      $(MODS) $(OBJN) $(NETCDF_LIBS) -o z_woa_tracer

sst_woa: $(MODS) sst_woa.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sst_woa.o \
	      $(MODS) $(OBJN) $(NETCDF_LIBS) -o sst_woa

z_gdem3: $(MODS) z_gdem3.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_gdem3.o \
	      $(MODS) $(OBJN) $(NETCDF_LIBS) -o z_gdem3

sst_gdem3: $(MODS) sst_gdem3.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sst_gdem3.o \
	      $(MODS) $(OBJN) $(NETCDF_LIBS) -o sst_gdem3

z_gdem4: $(MODS) z_gdem4.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_gdem4.o \
	      $(MODS) $(OBJN) $(NETCDF_LIBS) -o z_gdem4

sst_gdem4: $(MODS) sst_gdem4.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sst_gdem4.o \
	      $(MODS) $(OBJN) $(NETCDF_LIBS) -o sst_gdem4

ssh_modas: $(MODS) ssh_modas.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) ssh_modas.o \
	      $(MODS) $(OBJN) $(NETCDF_LIBS) -o ssh_modas

z_modas: $(MODS) z_modas.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_modas.o \
	      $(MODS) $(OBJS) \
	 -lsds -ldf -o z_modas

z_const: $(MODS) z_const.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_const.o \
	      $(MODS) $(OBJS) -o z_const

z_modify: $(MODS) z_modify.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_modify.o \
	      $(MODS) $(OBJS) -o z_modify

sst_modas: $(MODS) sst_modas.o $(OBJN)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sst_modas.o \
	      $(MODS) $(OBJN) $(NETCDF_LIBS) -o sst_modas

sst_pf: $(MODS) sst_pf.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sst_pf.o \
	      $(MODS) $(OBJS) -o sst_pf

sst_pf_4km: $(MODS) sst_pf_4km.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sst_pf_4km.o \
	      $(MODS) $(OBJS) -o sst_pf_4km

sst_noaa: $(MODS) sst_noaa.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sst_noaa.o \
	      $(MODS) $(OBJS) -o sst_noaa

sst_rs: $(MODS) sst_rs.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sst_rs.o \
	      $(MODS) $(OBJS) \
	 -lsds -ldf -o sst_rs

rmu: $(MODS) rmu.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) rmu.o \
	      $(MODS) zh.o -o rmu

rmu2: $(MODS) rmu2.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) rmu2.o \
	      $(MODS) zh.o -o rmu2

rmus: $(MODS) rmus.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) rmus.o \
	      $(MODS) zh.o -o rmus

zncoda_density: $(MODS) zncoda_density.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) zncoda_density.o \
	      $(MODS) $(OBJS) -o zncoda_density

zncoda_archive: $(MODS) zncoda_archive.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) zncoda_archive.o \
	      $(MODS) $(OBJS) -o zncoda_archive

z_archive: $(MODS) z_archive.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z_archive.o \
	      $(MODS) $(OBJS) -o z_archive

relax_flat_rivers: $(MODS) relax_flat_rivers.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) relax_flat_rivers.o \
	      $(MODS) $(OBJS) -o relax_flat_rivers

relax_tracer: $(MODS) relax_tracer.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) relax_tracer.o \
	      $(MODS) $(OBJS) -o relax_tracer

bottom: $(MODS) bottom.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) bottom.o \
	      $(MODS) $(OBJS) -o bottom

relaxv: $(MODS) relaxv.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) relaxv.o \
	      $(MODS) $(OBJS) -o relaxv

relaxi: $(MODS) relaxi.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) relaxi.o \
	      $(MODS) $(OBJS) -o relaxi

zonal_field: $(MODS) zonal_field.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) zonal_field.o \
	      $(MODS) $(OBJS) -o zonal_field


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

mod_xc.o:   mod_xc.F
mod_za.o:   mod_za.F mod_xc.o

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
