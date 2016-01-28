#
# Makefile for topo processing
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

PROGRAMS = topo_malt2h topo_m2h topo_p2h bathy_02min bathy_05min \
           grid_ellipsoid grid_hudson landsea_02min landsea_05min \
           topo_1d topo_2d topo_batrop topo_clip topo_diff topo_edit \
           topo_flat grid_360 topo_hgram topo_landfill topo_landmask \
           topo_island grid_latitude grid_lonlat grid_lonlat_2d grid_lpanam \
           topo_map topo_mapsub grid_mercator topo_merge mask_modify \
           topo_onesea topo_onesea-b topo_onesea_fill topo_onesea-b_mask \
           grid_panam partit partit_noshrink partit_arctic partit_arctic_ns \
           topo_ppmX topo_ports topo_ports_find topo_ports_latlon grid_rotated \
           topo_rough topo_shrink topo_slope topo_smallsea topo_smooth \
           topo_smooth_skip topo_subset topo_tiles topo_zcells topo_zthin

NCDF_PROGRAMS = bathy_01min landsea_01min bathy_30sec landsea_30sec

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
MODG = $(MODS) spherdist.o rotang.o
MODN = mod_xc.o mod_za.o wtime.o


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

# use malt2h for micom bathymetries with the alternative pakk encoding
topo_malt2h: $(MODS) topo_m2h.o pakk_micom.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_m2h.o pakk_micom.o zh.o \
	      $(MODS) -o topo_malt2h

topo_m2h: $(MODS) topo_m2h.o pakk_hycom.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_m2h.o pakk_hycom.o zh.o \
	      $(MODS) -o topo_m2h

topo_p2h: $(MODS) topo_p2h.o pakk_hycom.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_p2h.o pakk_hycom.o zh.o \
	      $(MODS) -o topo_p2h

bathy_30sec: $(MODS) bathy_30sec.o interp.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) bathy_30sec.o interp.o zh.o \
	      $(MODN) $(NETCDF_LIBS) -o bathy_30sec

bathy_01min: $(MODS) bathy_01min.o interp.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) bathy_01min.o interp.o zh.o \
	      $(MODN) $(NETCDF_LIBS) -o bathy_01min

bathy_02min: $(MODS) bathy_02min.o interp.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) bathy_02min.o interp.o zh.o \
	      $(MODS) -o bathy_02min

bathy_05min: $(MODS) bathy_05min.o interp.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) bathy_05min.o interp.o zh.o \
	      $(MODS) -o bathy_05min

bathy_caspi: $(MODS) bathy_caspi.o interp.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) bathy_caspi.o interp.o zh.o \
	      $(MODS) -o bathy_caspi

landsea_30sec: $(MODS) landsea_30sec.o interp.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) landsea_30sec.o interp.o zh.o \
	      $(MODN) $(NETCDF_LIBS) -o landsea_30sec

landsea_01min: $(MODS) landsea_01min.o interp.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) landsea_01min.o interp.o zh.o \
	      $(MODN) $(NETCDF_LIBS) -o landsea_01min

landsea_02min: $(MODS) landsea_02min.o interp.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) landsea_02min.o interp.o zh.o \
	      $(MODS) -o landsea_02min

landsea_05min: $(MODS) landsea_05min.o interp.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) landsea_05min.o interp.o zh.o \
	      $(MODS) -o landsea_05min

landsea_caspi: $(MODS) landsea_caspi.o interp.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) landsea_caspi.o interp.o zh.o \
	      $(MODS) -o landsea_caspi

topo_1d: $(MODS) topo_1d.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_1d.o zh.o \
	      $(MODS) -o topo_1d

topo_2d: $(MODS) topo_2d.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_2d.o zh.o \
	      $(MODS) -o topo_2d

topo_batrop: $(MODG) topo_batrop.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_batrop.o zh.o \
	      $(MODS) -o topo_batrop

topo_clip: $(MODS) topo_clip.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_clip.o zh.o \
	      $(MODS) -o topo_clip

topo_diff: $(MODS) topo_diff.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_diff.o zh.o \
	      $(MODS) -o topo_diff

topo_edit: $(MODS) topo_edit.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_edit.o zh.o \
	      $(MODS) -o topo_edit

topo_flat: $(MODS) topo_flat.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_flat.o zh.o \
	      $(MODS) -o topo_flat

grid_360: $(MODS) grid_360.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_360.o zh.o \
	      $(MODS) -o grid_360

topo_shrink: $(MODG) topo_shrink.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_shrink.o zh.o \
	      $(MODS) -o topo_shrink

topo_slope: $(MODG) topo_slope.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_slope.o zh.o \
	      $(MODS) -o topo_slope

grid_ellipsoid: $(MODG) grid_ellipsoid.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_ellipsoid.o zh.o \
	      $(MODG) -o grid_ellipsoid

grid_hudson: $(MODG) grid_hudson.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_hudson.o zh.o \
	      $(MODG) -o grid_hudson

topo_island: $(MODS) topo_island.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_island.o zh.o \
	      $(MODS) -o topo_island

topo_landfill: $(MODS) topo_landfill.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_landfill.o zh.o \
	      $(MODS) -o topo_landfill

topo_landmask: $(MODS) topo_landmask.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_landmask.o zh.o \
	      $(MODS) -o topo_landmask

grid_latitude: $(MODG) grid_latitude.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_latitude.o zh.o \
	      $(MODG) -o grid_latitude

grid_lonlat: $(MODG) grid_lonlat.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_lonlat.o zh.o \
	      $(MODG) -o grid_lonlat

grid_lonlat_2d: $(MODG) grid_lonlat_2d.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_lonlat_2d.o zh.o \
	      $(MODG) -o grid_lonlat_2d

grid_lpanam: $(MODG) grid_lpanam.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_lpanam.o zh.o \
	      $(MODG) -o grid_lpanam

topo_map: $(MODS) topo_map.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_map.o zh.o \
	      $(MODS) -o topo_map

topo_mapsub: $(MODS) topo_mapsub.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_mapsub.o zh.o \
	      $(MODS) -o topo_mapsub

grid_mercator: $(MODG) grid_mercator.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_mercator.o zh.o \
	      $(MODG) -o grid_mercator

mask_modify: $(MODS) mask_modify.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) mask_modify.o zh.o \
	      $(MODS) -o mask_modify

grid_panam: $(MODG) grid_panam.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_panam.o zh.o \
	      $(MODG) -o grid_panam

topo_ports: $(MODS) topo_ports.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_ports.o zh.o \
	      $(MODS) -o topo_ports

topo_ports_find: $(MODS) topo_ports_find.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_ports_find.o zh.o \
	      $(MODS) -o topo_ports_find

topo_ports_latlon: $(MODS) topo_ports_latlon.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_ports_latlon.o zh.o \
	      $(MODS) -o topo_ports_latlon

grid_olddist: $(MODS) grid_olddist.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_olddist.o zh.o \
	      $(MODS) -o grid_olddist

grid_rosby: $(MODS) grid_rosby.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_rosby.o zh.o \
	      $(MODS) -o grid_rosby

topo_rough: $(MODG) topo_rough.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_rough.o zh.o \
	      $(MODS) -o topo_rough

grid_rotated: $(MODG) grid_rotated.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) grid_rotated.o zh.o \
	      $(MODG) -o grid_rotated

topo_merge: $(MODS) topo_merge.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_merge.o zh.o \
	      $(MODS) -o topo_merge

topo_onesea: $(MODS) topo_onesea.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_onesea.o zh.o \
	      $(MODS) -o topo_onesea

topo_onesea-b: $(MODS) topo_onesea-b.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_onesea-b.o zh.o \
	      $(MODS) -o topo_onesea-b

topo_onesea_fill: $(MODS) topo_onesea_fill.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_onesea_fill.o zh.o \
	      $(MODS) -o topo_onesea_fill

topo_onesea-b_fill: $(MODS) topo_onesea-b_fill.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_onesea-b_fill.o zh.o \
	      $(MODS) -o topo_onesea-b_fill

topo_onesea-b_mask: $(MODS) topo_onesea-b_mask.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_onesea-b_mask.o zh.o \
	      $(MODS) -o topo_onesea-b_mask

partit: $(MODS) partit.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) partit.o zh.o \
	      $(MODS) -o partit

partit_arctic: $(MODS) partit_arctic.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) partit_arctic.o zh.o \
	      $(MODS) -o partit_arctic

partit_arctic_ns: $(MODS) partit_arctic_ns.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS)  partit_arctic_ns.o zh.o \
	      $(MODS) -o partit_arctic_ns

partit_noshrink: $(MODS) partit_noshrink.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) partit_noshrink.o zh.o \
	      $(MODS) -o partit_noshrink

partit_test: $(MODS) partit_test.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) partit_test.o zh.o \
	      $(MODS) -o partit_test

topo_hgram: $(MODS) topo_hgram.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_hgram.o zh.o \
	      $(MODS) -o topo_hgram

topo_ppmX: $(MODS) topo_ppmX.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_ppmX.o zh.o \
	      $(MODS) -o topo_ppmX

topo_smallsea: $(MODS) topo_smallsea.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_smallsea.o zh.o \
	      $(MODS) -o topo_smallsea

topo_smooth: $(MODS) topo_smooth.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_smooth.o zh.o \
	      $(MODS) -o topo_smooth

topo_smooth_skip: $(MODS) topo_smooth_skip.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_smooth_skip.o zh.o \
	      $(MODS) -o topo_smooth_skip

topo_subset: $(MODS) topo_subset.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_subset.o zh.o \
	      $(MODS) -o topo_subset

topo_tiles: $(MODS) topo_tiles.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_tiles.o zh.o \
	      $(MODS) -o topo_tiles

topo_zcells: $(MODS) topo_zcells.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_zcells.o zh.o \
	      $(MODS) -o topo_zcells

topo_zthin: $(MODS) topo_zthin.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) topo_zthin.o zh.o \
	      $(MODS) -o topo_zthin


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
