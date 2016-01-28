#
# Makefile for bin processing
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
	$(CC) -c $(CFLAGS) $(X_CFLAGS)  -c $*.c

.f.o:
	$(FC) -c $(FFLAGS) $(X_FFLAGS) $*.f

.F.o:
	$(FC) -c $(CPPFLAGS) $(X_CPPFLAGS) $(FFLAGS) $(X_FFLAGS) $*.F


# ---------------------------------------------------------------------
# Makefile targets.
# ---------------------------------------------------------------------

C_PROGRAMS = echo2 endian

PROGRAMS = clim_stat wind_stat wind_stat_check wind_stat_range \
           wind_stat_range2 wind_stat_range5 wind_stat_raw \
           cice_restart cice_stat hycom_palette lonlat_dist hycom_alat \
           hycom_archm_dates hycom_archv_dates hycom_depth hycom_depth_40 \
           hycom_nest_dates hycom_profile+sig hycom_profile+thstar \
           hycom_profile2pcm hycom_profile2z hycom_profile2zi \
           hycom_profile_argo hycom_profile_hybgen+ hycom_profile_hybgen \
           hycom_profile_locsig hycom_profile_mld hycom_profile_remap \
           hycom_sigma hycom_ts hycom_wind_date hycom_wind_ymdh \
           hycom_ymdh_wind hycom_yoflat sigma0_to_sigma2 sigma2_to_sigma0 \
           ts_to_sigma z2zi zi2z hycom_date_wind hycom_profile2plm \
           hycom_profile_hybgen_34 hycom_profile_hybgen_35 hycom_subset_xy \
           hycom_dp0k hycom_dp0k_cm hycom_dp0k_sigma \
           hycom_crosscorr hycom_crosscorr_lag hycom_join unf42hycom unf82hycom \
           hycom2raw hycom2raw8 hycom_1st_isopyc hycom_arctic hycom_arctic_ok \
           hycom_bandmask hycom_binning hycom_binning_fld hycom_bouflx hycom_clip \
           hycom_count hycom_eddy_center hycom_expr hycom_extract hycom_fill \
           hycom_halfsm hycom_histogram hycom_ij2lonlat hycom_islands hycom_larger \
           hycom_lonlat2ij hycom_lonlat2xy hycom_mask hycom_mass hycom_mean \
           hycom_meanfit hycom_median hycom_meridional hycom_meridional_lon \
           hycom_mixlay hycom_mixlay_old hycom_mxthrd hycom_NaN hycom_print \
           hycom_range hycom_range_ij hycom_rivers hycom_rotate hycom_runmean \
           hycom_sample hycom_sample_list hycom_sea_ok hycom_shift hycom_skill \
           hycom_slopefit hycom_smooth hycom_stericssh hycom_subset hycom_superset \
           hycom_thirdsm hycom_tidelat hycom_triple hycom_void hycom_xy2lonlat \
           hycom_zonal hycom_zonal_lat ascii2hycom raw2hycom raw82hycom \
           hycom_2d_ok hycom_autocorr hycom_autocorr_lag hycom_boxmean hycom_boxtime \
           hycom_index_sort hycom_mask_ok hycom_mass_corr hycom_newzi hycom_quadlsq \
           hycom_regression hycom_sstice hycom_botfric hycom_boxsmooth hycom_diflat \
           hycom_merge hycom_sample_xy hycom_scatter hycom_tidebody hycom_vmean \
           hycom_xward hycom_profile_list

NCDF_PROGRAMS =

ALL_PROGRAMS := $(C_PROGRAMS) $(PROGRAMS) $(NCDF_PROGRAMS)


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

OBJS     =	parse.o hycom_endian_io.o
OBJX    :=	$(OBJS) hycom_profile_lib.o

SRCS     =	parse.c hycom_endian_io.F
SRCX    :=	$(SRCS) hycom_profile_lib.F


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

echo2: echo2.o
	$(CC) $(CFLAGS) $(X_CFLAGS) echo2.o \
	      -o echo2

endian: endian.o
	$(CC) $(CFLAGS) $(X_CFLAGS) endian.o \
	      -o endian


clim_stat: clim_stat.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) clim_stat.o \
	      -o clim_stat

wind_stat: wind_stat.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wind_stat.o \
	      -o wind_stat

wind_stat_check: wind_stat_check.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wind_stat_check.o \
	      -o wind_stat_check

wind_stat_range: wind_stat_range.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wind_stat_range.o \
	      -o wind_stat_range

wind_stat_range2: wind_stat_range2.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wind_stat_range2.o \
	      -o wind_stat_range2


wind_stat_range5: wind_stat_range5.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wind_stat_range5.o \
	      -o wind_stat_range5

wind_stat_raw: wind_stat_raw.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wind_stat_raw.o \
	      -o wind_stat_raw



cice_restart: cice_restart.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) cice_restart.o \
	      -o cice_restart

cice_stat: cice_stat.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) cice_stat.o \
	      -o cice_stat

hycom_palette: hycom_palette.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_palette.o \
	      -o hycom_palette

lonlat_dist: lonlat_dist.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) lonlat_dist.o \
	      -o lonlat_dist

hycom_alat: hycom_alat.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_alat.o \
	      -o hycom_alat

hycom_archm_dates: hycom_archm_dates.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_archm_dates.o \
	      -o hycom_archm_dates

hycom_archv_dates: hycom_archv_dates.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_archv_dates.o \
	      -o hycom_archv_dates

hycom_depth: hycom_depth.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_depth.o \
	      -o hycom_depth

hycom_depth_40: hycom_depth_40.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_depth_40.o \
	      -o hycom_depth_40

hycom_nest_dates: hycom_nest_dates.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_nest_dates.o \
	      -o hycom_nest_dates

hycom_profile+sig: hycom_profile+sig.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile+sig.o \
	      -o hycom_profile+sig

hycom_profile+thstar: hycom_profile+thstar.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile+thstar.o \
	      -o hycom_profile+thstar

hycom_profile2pcm: hycom_profile2pcm.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile2pcm.o \
	      -o hycom_profile2pcm

hycom_profile2z: hycom_profile2z.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile2z.o \
	      -o hycom_profile2z

hycom_profile2zi: hycom_profile2zi.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile2zi.o \
	      -o hycom_profile2zi

hycom_profile_argo: $(OBJX) hycom_profile_argo.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile_argo.o \
	      $(OBJX) -o hycom_profile_argo

hycom_profile_hybgen+: hycom_profile_hybgen+.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile_hybgen+.o \
	      -o hycom_profile_hybgen+

hycom_profile_hybgen: hycom_profile_hybgen.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile_hybgen.o \
	      -o hycom_profile_hybgen

hycom_profile_locsig: hycom_profile_locsig.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile_locsig.o \
	      -o hycom_profile_locsig

hycom_profile_mld: hycom_profile_mld.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile_mld.o \
	      -o hycom_profile_mld

hycom_profile_remap: hycom_profile_remap.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile_remap.o \
	      -o hycom_profile_remap

hycom_sigma: hycom_sigma.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_sigma.o \
	      -o hycom_sigma

hycom_ts: hycom_ts.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_ts.o \
	      -o hycom_ts

hycom_wind_date: hycom_wind_date.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_wind_date.o \
	      -o hycom_wind_date

hycom_wind_ymdh: hycom_wind_ymdh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_wind_ymdh.o \
	      -o hycom_wind_ymdh

hycom_ymdh_wind: hycom_ymdh_wind.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_ymdh_wind.o \
	      -o hycom_ymdh_wind

hycom_yoflat: hycom_yoflat.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_yoflat.o \
	      -o hycom_yoflat

sigma0_to_sigma2: sigma0_to_sigma2.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sigma0_to_sigma2.o \
	      -o sigma0_to_sigma2

sigma2_to_sigma0: sigma2_to_sigma0.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) sigma2_to_sigma0.o \
	      -o sigma2_to_sigma0

ts_to_sigma: ts_to_sigma.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) ts_to_sigma.o \
	      -o ts_to_sigma

z2zi: z2zi.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) z2zi.o \
	      -o z2zi

zi2z: zi2z.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) zi2z.o \
	      -o zi2z

hycom_date_wind: hycom_date_wind.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_date_wind.o \
	      -o hycom_date_wind

hycom_profile2plm: hycom_profile2plm.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile2plm.o \
	      -o hycom_profile2plm

hycom_profile_hybgen_34: hycom_profile_hybgen_34.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile_hybgen_34.o \
	      -o hycom_profile_hybgen_34

hycom_profile_hybgen_35: hycom_profile_hybgen_35.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile_hybgen_35.o \
	      -o hycom_profile_hybgen_35

hycom_subset_xy: hycom_subset_xy.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_subset_xy.o \
	      -o hycom_subset_xy

hycom_dp0k: hycom_dp0k.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_dp0k.o \
	      -o hycom_dp0k

hycom_dp0k_cm: hycom_dp0k_cm.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_dp0k_cm.o \
	      -o hycom_dp0k_cm

hycom_dp0k_sigma: hycom_dp0k_sigma.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_dp0k_sigma.o \
	      -o hycom_dp0k_sigma


hycom_crosscorr: $(OBJS) hycom_crosscorr.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_crosscorr.o \
	      $(OBJS) -o hycom_crosscorr

hycom_crosscorr_lag: $(OBJS) hycom_crosscorr_lag.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_crosscorr_lag.o \
	      $(OBJS) -o hycom_crosscorr_lag

hycom_join: $(OBJS) hycom_join.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_join.o \
	      $(OBJS) -o hycom_join

unf42hycom: $(OBJS) unf42hycom.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) unf42hycom.o \
	      $(OBJS) -o unf42hycom

unf82hycom: $(OBJS) unf82hycom.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) unf82hycom.o \
	      $(OBJS) -o unf82hycom

hycom2raw: $(OBJS) hycom2raw.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom2raw.o \
	      $(OBJS) -o hycom2raw

hycom2raw8: $(OBJS) hycom2raw8.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom2raw8.o \
	      $(OBJS) -o hycom2raw8

hycom_1st_isopyc: $(OBJS) hycom_1st_isopyc.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_1st_isopyc.o \
	      $(OBJS) -o hycom_1st_isopyc

hycom_arctic: $(OBJS) hycom_arctic.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_arctic.o \
	      $(OBJS) -o hycom_arctic

hycom_arctic_ok: $(OBJS) hycom_arctic_ok.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_arctic_ok.o \
	      $(OBJS) -o hycom_arctic_ok

hycom_bandmask: $(OBJS) hycom_bandmask.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_bandmask.o \
	      $(OBJS) -o hycom_bandmask

hycom_binning: $(OBJS) hycom_binning.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_binning.o \
	      $(OBJS) -o hycom_binning

hycom_binning_fld: $(OBJS) hycom_binning_fld.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_binning_fld.o \
	      $(OBJS) -o hycom_binning_fld

hycom_bouflx: $(OBJS) hycom_bouflx.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_bouflx.o \
	      $(OBJS) -o hycom_bouflx

hycom_clip: $(OBJS) hycom_clip.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_clip.o \
	      $(OBJS) -o hycom_clip

hycom_count: $(OBJS) hycom_count.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_count.o \
	      $(OBJS) -o hycom_count

hycom_eddy_center: $(OBJS) hycom_eddy_center.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_eddy_center.o \
	      $(OBJS) -o hycom_eddy_center

hycom_expr: $(OBJS) hycom_expr.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_expr.o \
	      $(OBJS) -o hycom_expr

hycom_extract: $(OBJS) hycom_extract.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_extract.o \
	      $(OBJS) -o hycom_extract

hycom_fill: $(OBJS) hycom_fill.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_fill.o \
	      $(OBJS) -o hycom_fill

hycom_halfsm: $(OBJS) hycom_halfsm.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_halfsm.o \
	      $(OBJS) -o hycom_halfsm

hycom_histogram: $(OBJS) hycom_histogram.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_histogram.o \
	      $(OBJS) -o hycom_histogram

hycom_ij2lonlat: $(OBJS) hycom_ij2lonlat.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_ij2lonlat.o \
	      $(OBJS) -o hycom_ij2lonlat

hycom_islands: $(OBJS) hycom_islands.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_islands.o \
	      $(OBJS) -o hycom_islands

hycom_larger: $(OBJS) hycom_larger.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_larger.o \
	      $(OBJS) -o hycom_larger

hycom_lonlat2ij: $(OBJS) hycom_lonlat2ij.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_lonlat2ij.o \
	      $(OBJS) -o hycom_lonlat2ij

hycom_lonlat2xy: $(OBJS) hycom_lonlat2xy.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_lonlat2xy.o \
	      $(OBJS) -o hycom_lonlat2xy

hycom_mask: $(OBJS) hycom_mask.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_mask.o \
	      $(OBJS) -o hycom_mask

hycom_mass: $(OBJS) hycom_mass.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_mass.o \
	      $(OBJS) -o hycom_mass

hycom_mean: $(OBJS) hycom_mean.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_mean.o \
	      $(OBJS) -o hycom_mean

hycom_meanfit: $(OBJS) hycom_meanfit.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_meanfit.o \
	      $(OBJS) -o hycom_meanfit

hycom_median: $(OBJS) hycom_median.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_median.o \
	      $(OBJS) -o hycom_median

hycom_meridional: $(OBJS) hycom_meridional.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_meridional.o \
	      $(OBJS) -o hycom_meridional

hycom_meridional_lon: $(OBJS) hycom_meridional_lon.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_meridional_lon.o \
	      $(OBJS) -o hycom_meridional_lon

hycom_mixlay: $(OBJS) hycom_mixlay.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_mixlay.o \
	      $(OBJS) -o hycom_mixlay

hycom_mixlay_old: $(OBJS) hycom_mixlay_old.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_mixlay_old.o \
	      $(OBJS) -o hycom_mixlay_old

hycom_mxthrd: $(OBJS) hycom_mxthrd.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_mxthrd.o \
	      $(OBJS) -o hycom_mxthrd

hycom_NaN: $(OBJS) hycom_NaN.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_NaN.o \
	      $(OBJS) -o hycom_NaN

hycom_print: $(OBJS) hycom_print.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_print.o \
	      $(OBJS) -o hycom_print

hycom_range: $(OBJS) hycom_range.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_range.o \
	      $(OBJS) -o hycom_range

hycom_range_ij: $(OBJS) hycom_range_ij.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_range_ij.o \
	      $(OBJS) -o hycom_range_ij

hycom_rivers: $(OBJS) hycom_rivers.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_rivers.o \
	      $(OBJS) -o hycom_rivers

hycom_rotate: $(OBJS) hycom_rotate.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_rotate.o \
	      $(OBJS) -o hycom_rotate

hycom_runmean: $(OBJS) hycom_runmean.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_runmean.o \
	      $(OBJS) -o hycom_runmean

hycom_sample: $(OBJS) hycom_sample.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_sample.o \
	      $(OBJS) -o hycom_sample

hycom_sample_list: $(OBJS) hycom_sample_list.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_sample_list.o \
	      $(OBJS) -o hycom_sample_list

hycom_sea_ok: $(OBJS) hycom_sea_ok.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_sea_ok.o \
	      $(OBJS) -o hycom_sea_ok

hycom_shift: $(OBJS) hycom_shift.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_shift.o \
	      $(OBJS) -o hycom_shift

hycom_skill: $(OBJS) hycom_skill.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_skill.o \
	      $(OBJS) -o hycom_skill

hycom_slopefit: $(OBJS) hycom_slopefit.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_slopefit.o \
	      $(OBJS) -o hycom_slopefit

hycom_smooth: $(OBJS) hycom_smooth.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_smooth.o \
	      $(OBJS) -o hycom_smooth

hycom_stericssh: $(OBJS) hycom_stericssh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_stericssh.o \
	      $(OBJS) -o hycom_stericssh

hycom_subset: $(OBJS) hycom_subset.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_subset.o \
	      $(OBJS) -o hycom_subset

hycom_superset: $(OBJS) hycom_superset.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_superset.o \
	      $(OBJS) -o hycom_superset

hycom_thirdsm: $(OBJS) hycom_thirdsm.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_thirdsm.o \
	      $(OBJS) -o hycom_thirdsm

hycom_tidelat: $(OBJS) hycom_tidelat.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_tidelat.o \
	      $(OBJS) -o hycom_tidelat

hycom_triple: $(OBJS) hycom_triple.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_triple.o \
	      $(OBJS) -o hycom_triple

hycom_void: $(OBJS) hycom_void.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_void.o \
	      $(OBJS) -o hycom_void

hycom_xy2lonlat: $(OBJS) hycom_xy2lonlat.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_xy2lonlat.o \
	      $(OBJS) -o hycom_xy2lonlat

hycom_zonal: $(OBJS) hycom_zonal.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_zonal.o \
	      $(OBJS) -o hycom_zonal

hycom_zonal_lat: $(OBJS) hycom_zonal_lat.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_zonal_lat.o \
	      $(OBJS) -o hycom_zonal_lat

ascii2hycom: $(OBJS) ascii2hycom.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) ascii2hycom.o \
	      $(OBJS) -o ascii2hycom

raw2hycom: $(OBJS) raw2hycom.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) raw2hycom.o \
	      $(OBJS) -o raw2hycom

raw82hycom: $(OBJS) raw82hycom.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) raw82hycom.o \
	      $(OBJS) -o raw82hycom

hycom_2d_ok: $(OBJS) hycom_2d_ok.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_2d_ok.o \
	      $(OBJS) -o hycom_2d_ok

hycom_autocorr: $(OBJS) hycom_autocorr.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_autocorr.o \
	      $(OBJS) -o hycom_autocorr

hycom_autocorr_lag: $(OBJS) hycom_autocorr_lag.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_autocorr_lag.o \
	      $(OBJS) -o hycom_autocorr_lag

hycom_boxmean: $(OBJS) hycom_boxmean.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_boxmean.o \
	      $(OBJS) -o hycom_boxmean

hycom_boxtime: $(OBJS) hycom_boxtime.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_boxtime.o \
	      $(OBJS) -o hycom_boxtime

hycom_index_sort: $(OBJS) hycom_index_sort.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_index_sort.o \
	      $(OBJS) -o hycom_index_sort

hycom_mask_ok: $(OBJS) hycom_mask_ok.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_mask_ok.o \
	      $(OBJS) -o hycom_mask_ok

hycom_mass_corr: $(OBJS) hycom_mass_corr.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_mass_corr.o \
	      $(OBJS) -o hycom_mass_corr

hycom_newzi: $(OBJS) hycom_newzi.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_newzi.o \
	      $(OBJS) -o hycom_newzi

hycom_quadlsq: $(OBJS) hycom_quadlsq.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_quadlsq.o \
	      $(OBJS) -o hycom_quadlsq

hycom_regression: $(OBJS) hycom_regression.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_regression.o \
	      $(OBJS) -o hycom_regression

hycom_sstice: $(OBJS) hycom_sstice.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_sstice.o \
	      $(OBJS) -o hycom_sstice

hycom_botfric: $(OBJS) hycom_botfric.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_botfric.o \
	      $(OBJS) -o hycom_botfric

hycom_boxsmooth: $(OBJS) hycom_boxsmooth.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_boxsmooth.o \
	      $(OBJS) -o hycom_boxsmooth

hycom_diflat: $(OBJS) hycom_diflat.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_diflat.o \
	      $(OBJS) -o hycom_diflat

hycom_merge: $(OBJS) hycom_merge.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_merge.o \
	      $(OBJS) -o hycom_merge

hycom_sample_xy: $(OBJS) hycom_sample_xy.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_sample_xy.o \
	      $(OBJS) -o hycom_sample_xy

hycom_scatter: $(OBJS) hycom_scatter.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_scatter.o \
	      $(OBJS) -o hycom_scatter

hycom_tidebody: $(OBJS) hycom_tidebody.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_tidebody.o \
	      $(OBJS) -o hycom_tidebody

hycom_vmean: $(OBJS) hycom_vmean.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_vmean.o \
	      $(OBJS) -o hycom_vmean

hycom_xward: $(OBJS) hycom_xward.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_xward.o \
	      $(OBJS) -o hycom_xward


hycom_profile_list: $(OBJX) hycom_profile_list.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycom_profile_list.o \
	      $(OBJX) -o hycom_profile_list


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

echo2.o:                   echo2.c
endian.o:                  endian.c


clim_stat.o:               clim_stat.f
wind_stat.o:               wind_stat.f
wind_stat_check.o:         wind_stat_check.f
wind_stat_range.o:         wind_stat_range.f
wind_stat_range2.o:        wind_stat_range2.f
wind_stat_range5.o:        wind_stat_range5.f
wind_stat_raw.o:           wind_stat_raw.f
cice_restart.o:            cice_restart.f
cice_stat.o:               cice_stat.f
hycom_palette.o:           hycom_palette.f
lonlat_dist.o:             lonlat_dist.f
hycom_alat.o:              hycom_alat.f
hycom_archm_dates.o:       hycom_archm_dates.f
hycom_archv_dates.o:       hycom_archv_dates.f
hycom_depth.o:             hycom_depth.f
hycom_depth_40.o:          hycom_depth_40.f
hycom_nest_dates.o:        hycom_nest_dates.f
hycom_profile+sig.o:       hycom_profile+sig.f
hycom_profile+thstar.o:    hycom_profile+thstar.f
hycom_profile2pcm.o:       hycom_profile2pcm.f
hycom_profile2z.o:         hycom_profile2z.f
hycom_profile2zi.o:        hycom_profile2zi.f
hycom_profile_argo.o:      hycom_profile_argo.f    $(OBJX)
hycom_profile_hybgen+.o:   hycom_profile_hybgen+.f
hycom_profile_hybgen.o:    hycom_profile_hybgen.f
hycom_profile_locsig.o:    hycom_profile_locsig.f
hycom_profile_mld.o:       hycom_profile_mld.f
hycom_profile_remap.o:     hycom_profile_remap.f
hycom_sigma.o:             hycom_sigma.f
hycom_ts.o:                hycom_ts.f
hycom_wind_date.o:         hycom_wind_date.f
hycom_wind_ymdh.o:         hycom_wind_ymdh.f
hycom_ymdh_wind.o:         hycom_ymdh_wind.f
hycom_yoflat.o:            hycom_yoflat.f
sigma0_to_sigma2.o:        sigma0_to_sigma2.f
sigma2_to_sigma0.o:        sigma2_to_sigma0.f
ts_to_sigma.o:             ts_to_sigma.f
z2zi.o:                    z2zi.f
zi2z.o:                    zi2z.f
hycom_date_wind.o:         hycom_date_wind.f
hycom_profile2plm.o:       hycom_profile2plm.f
hycom_profile_hybgen_34.o: hycom_profile_hybgen_34.f
hycom_profile_hybgen_35.o: hycom_profile_hybgen_35.f
hycom_subset_xy.o:         hycom_subset_xy.f
hycom_dp0k.o:              hycom_dp0k.f
hycom_dp0k_cm.o:           hycom_dp0k_cm.f
hycom_dp0k_sigma.o:        hycom_dp0k_sigma.f


hycom_crosscorr.o:         hycom_crosscorr.F      $(OBJS)
hycom_crosscorr_lag.o:     hycom_crosscorr_lag.F  $(OBJS)
hycom_join.o:              hycom_join.F           $(OBJS)
unf42hycom.o:              unf42hycom.F           $(OBJS)
unf82hycom.o:              unf82hycom.F           $(OBJS)
hycom2raw.o:               hycom2raw.F            $(OBJS)
hycom2raw8.o:              hycom2raw8.F           $(OBJS)
hycom_1st_isopyc.o:        hycom_1st_isopyc.F     $(OBJS)
hycom_arctic.o:            hycom_arctic.F         $(OBJS)
hycom_arctic_ok.o:         hycom_arctic_ok.F      $(OBJS)
hycom_bandmask.o:          hycom_bandmask.F       $(OBJS)
hycom_binning.o:           hycom_binning.F        $(OBJS)
hycom_binning_fld.o:       hycom_binning_fld.F    $(OBJS)
hycom_bouflx.o:            hycom_bouflx.F         $(OBJS)
hycom_clip.o:              hycom_clip.F           $(OBJS)
hycom_count.o:             hycom_count.F          $(OBJS)
hycom_eddy_center.o:       hycom_eddy_center.F    $(OBJS)
hycom_expr.o:              hycom_expr.F           $(OBJS)
hycom_extract.o:           hycom_extract.F        $(OBJS)
hycom_fill.o:              hycom_fill.F           $(OBJS)
hycom_halfsm.o:            hycom_halfsm.F         $(OBJS)
hycom_histogram.o:         hycom_histogram.F      $(OBJS)
hycom_ij2lonlat.o:         hycom_ij2lonlat.F      $(OBJS)
hycom_islands.o:           hycom_islands.F        $(OBJS)
hycom_larger.o:            hycom_larger.F         $(OBJS)
hycom_lonlat2ij.o:         hycom_lonlat2ij.F      $(OBJS)
hycom_lonlat2xy.o:         hycom_lonlat2xy.F      $(OBJS)
hycom_mask.o:              hycom_mask.F           $(OBJS)
hycom_mass.o:              hycom_mass.F           $(OBJS)
hycom_mean.o:              hycom_mean.F           $(OBJS)
hycom_meanfit.o:           hycom_meanfit.F        $(OBJS)
hycom_median.o:            hycom_median.F         $(OBJS)
hycom_meridional.o:        hycom_meridional.F     $(OBJS)
hycom_meridional_lon.o:    hycom_meridional_lon.F $(OBJS)
hycom_mixlay.o:            hycom_mixlay.F         $(OBJS)
hycom_mixlay_old.o:        hycom_mixlay_old.F     $(OBJS)
hycom_mxthrd.o:            hycom_mxthrd.F         $(OBJS)
hycom_NaN.o:               hycom_NaN.F            $(OBJS)
hycom_print.o:             hycom_print.F          $(OBJS)
hycom_range.o:             hycom_range.F          $(OBJS)
hycom_range_ij.o:          hycom_range_ij.F       $(OBJS)
hycom_rivers.o:            hycom_rivers.F         $(OBJS)
hycom_rotate.o:            hycom_rotate.F         $(OBJS)
hycom_runmean.o:           hycom_runmean.F        $(OBJS)
hycom_sample.o:            hycom_sample.F         $(OBJS)
hycom_sample_list.o:       hycom_sample_list.F    $(OBJS)
hycom_sea_ok.o:            hycom_sea_ok.F         $(OBJS)
hycom_shift.o:             hycom_shift.F          $(OBJS)
hycom_skill.o:             hycom_skill.F          $(OBJS)
hycom_slopefit.o:          hycom_slopefit.F       $(OBJS)
hycom_smooth.o:            hycom_smooth.F         $(OBJS)
hycom_stericssh.o:         hycom_stericssh.F      $(OBJS)
hycom_subset.o:            hycom_subset.F         $(OBJS)
hycom_superset.o:          hycom_superset.F       $(OBJS)
hycom_thirdsm.o:           hycom_thirdsm.F        $(OBJS)
hycom_tidelat.o:           hycom_tidelat.F        $(OBJS)
hycom_triple.o:            hycom_triple.F         $(OBJS)
hycom_void.o:              hycom_void.F           $(OBJS)
hycom_xy2lonlat.o:         hycom_xy2lonlat.F      $(OBJS)
hycom_zonal.o:             hycom_zonal.F          $(OBJS)
hycom_zonal_lat.o:         hycom_zonal_lat.F      $(OBJS)
ascii2hycom.o:             ascii2hycom.F          $(OBJS)
raw2hycom.o:               raw2hycom.F            $(OBJS)
raw82hycom.o:              raw82hycom.F           $(OBJS)
hycom_2d_ok.o:             hycom_2d_ok.F          $(OBJS)
hycom_autocorr.o:          hycom_autocorr.F       $(OBJS)
hycom_autocorr_lag.o:      hycom_autocorr_lag.F   $(OBJS)
hycom_boxmean.o:           hycom_boxmean.F        $(OBJS)
hycom_boxtime.o:           hycom_boxtime.F        $(OBJS)
hycom_index_sort.o:        hycom_index_sort.F     $(OBJS)
hycom_mask_ok.o:           hycom_mask_ok.F        $(OBJS)
hycom_mass_corr.o:         hycom_mass_corr.F      $(OBJS)
hycom_newzi.o:             hycom_newzi.F          $(OBJS)
hycom_quadlsq.o:           hycom_quadlsq.F        $(OBJS)
hycom_regression.o:        hycom_regression.F     $(OBJS)
hycom_sstice.o:            hycom_sstice.F         $(OBJS)
hycom_botfric.o:           hycom_botfric.F        $(OBJS)
hycom_boxsmooth.o:         hycom_boxsmooth.F      $(OBJS)
hycom_diflat.o:            hycom_diflat.F         $(OBJS)
hycom_merge.o:             hycom_merge.F          $(OBJS)
hycom_sample_xy.o:         hycom_sample_xy.F      $(OBJS)
hycom_scatter.o:           hycom_scatter.F        $(OBJS)
hycom_tidebody.o:          hycom_tidebody.F       $(OBJS)
hycom_vmean.o:             hycom_vmean.F          $(OBJS)
hycom_xward.o:             hycom_xward.F          $(OBJS)

hycom_profile_list.o:      hycom_profile_list.F   $(OBJX)

hycom_profile_lib.o: hycom_profile_lib.F
hycom_endian_io.o:   hycom_endian_io.F
parse.o:             parse.c


#--------------------------------------------------------------------------
#  Cleaning targets.
#--------------------------------------------------------------------------

.PHONY: clean

clean:
	rm -f *.o *.a *.mod M*log


.PHONY: realclean

realclean: clean
	rm -f $(ALL_PROGRAMS)
