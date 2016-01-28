#
# Makefile for force processing
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

PROGRAMS = ap time_interp time_shift aphf_add aphf_climo aphf_diurnal \
           aphf_extend aphf_meanfit aphf_monthly aphf_offset aphf_scale \
           aphf_flcorr aphf_tacorr kp kp_const kphf_const kphf_table \
           tp tp_sal w_const wi wi_curl wi_magstress wi_meanfit \
           off_diff off_zero pcip_zero pcip_riv_mon pcip_riv_hf \
           conv_f_mm5 conv_w_mm5

NCDF_PROGRAMS = force2nc nrl2nc ap_nc kp_nc tp_nc wi_nc

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
OBJS = interp.o zh.o
MODP = mod_xc.o mod_za.o wtime.o mod_scrip.o
OBJP = interp.o zh.o scrip.o


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

ap: $(MODS) ap.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) ap.o \
	      $(MODS) $(OBJS) -o ap

time_interp: $(MODS) time_interp.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) time_interp.o \
	      $(MODS) $(OBJS) -o time_interp

time_shift: $(MODS) time_shift.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) time_shift.o \
	      $(MODS) $(OBJS) -o time_shift

aphf_add: $(MODS) aphf_add.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) aphf_add.o \
	      $(MODS) $(OBJS) -o aphf_add

aphf_climo: $(MODS) aphf_climo.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) aphf_climo.o \
	      $(MODS) $(OBJS) -o aphf_climo

aphf_diurnal: $(MODS) aphf_diurnal.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) aphf_diurnal.o \
	      $(MODS) $(OBJS) -o aphf_diurnal

aphf_extend: $(MODS) aphf_extend.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) aphf_extend.o \
	      $(MODS) $(OBJS) -o aphf_extend

aphf_meanfit: $(MODS) aphf_meanfit.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) aphf_meanfit.o \
	      $(MODS) $(OBJS) -o aphf_meanfit

aphf_monthly: $(MODS) aphf_monthly.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) aphf_monthly.o \
	      $(MODS) $(OBJS) -o aphf_monthly

aphf_offset: $(MODS) aphf_offset.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) aphf_offset.o \
	      $(MODS) $(OBJS) -o aphf_offset

aphf_scale: $(MODS) aphf_scale.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) aphf_scale.o \
	      $(MODS) $(OBJS) -o aphf_scale

aphf_flcorr: $(MODS) aphf_flcorr.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) aphf_flcorr.o \
	      $(MODS) $(OBJS) -o aphf_flcorr

aphf_tacorr: $(MODS) aphf_tacorr.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) aphf_tacorr.o \
	      $(MODS) $(OBJS) -o aphf_tacorr

kp: $(MODS) kp.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) kp.o \
	      $(MODS) $(OBJS) -o kp

kp_const: $(MODS) kp_const.o zh.o   
	$(LD) $(LDFLAGS) $(X_LDFLAGS) kp_const.o \
	      $(MODS) zh.o -o kp_const

kphf_const: $(MODS) kphf_const.o zh.o   
	$(LD) $(LDFLAGS) $(X_LDFLAGS) kphf_const.o \
	      $(MODS) zh.o -o kphf_const

kphf_table: $(MODS) kphf_table.o zh.o   
	$(LD) $(LDFLAGS) $(X_LDFLAGS) kphf_table.o \
	      $(MODS) zh.o -o kphf_table

tp: $(MODS) tp.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) tp.o \
	      $(MODS) $(OBJS) -o tp

tp_sal: $(MODS) tp_sal.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) tp_sal.o \
	      $(MODS) $(OBJS) -o tp_sal

w_const: $(MODS) w_const.o zh.o   
	$(LD) $(LDFLAGS) $(X_LDFLAGS) w_const.o \
	      $(MODS) zh.o -o w_const

wi: $(MODS) wi.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wi.o \
	      $(MODS) $(OBJS) -o wi

wi_curl: $(MODS) wi_curl.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wi_curl.o \
	      $(MODS) $(OBJS) -o wi_curl

wi_magstress: $(MODS) wi_magstress.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wi_magstress.o \
	      $(MODS) $(OBJS) -o wi_magstress

wi_meanfit: $(MODS) wi_meanfit.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wi_meanfit.o \
	      $(MODS) $(OBJS) -o wi_meanfit

off_diff: $(MODS) off_diff.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) off_diff.o \
	      $(MODS) $(OBJS) -o off_diff

off_zero: $(MODS) off_zero.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) off_zero.o \
	      $(MODS) zh.o -o off_zero

pcip_zero: $(MODS) pcip_zero.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) pcip_zero.o \
	      $(MODS) zh.o -o pcip_zero

pcip_riv_mon: $(MODS) pcip_riv_mon.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) pcip_riv_mon.o \
	      $(MODS) $(OBJS) -o pcip_riv_mon

pcip_riv_hf: $(MODS) pcip_riv_hf.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) pcip_riv_hf.o \
	      $(MODS) $(OBJS) -o pcip_riv_hf

conv_f_mm5: $(MODS) conv_f_mm5.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) conv_f_mm5.o \
	      $(MODS) zh.o -o conv_f_mm5

conv_w_mm5: $(MODS) conv_w_mm5.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) conv_w_mm5.o \
	      $(MODS) zh.o -o conv_w_mm5

force2nc: force2nc.o $(MODS) zh.o   
	$(LD) $(LDFLAGS) $(X_LDFLAGS) force2nc.o \
	      $(MODS) zh.o $(NETCDF_LIBS) -o force2nc

nrl2nc: nrl2nc.o $(MODS) zh.o   
	$(LD) $(LDFLAGS) $(X_LDFLAGS) nrl2nc.o \
	      $(MODS) zh.o $(NETCDF_LIBS) -o nrl2nc

ap_nc: $(MODS) ap_nc.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) ap_nc.o \
	      $(MODS) $(OBJS) $(NETCDF_LIBS) -o ap_nc

kp_nc: $(MODS) kp_nc.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) kp_nc.o \
	      $(MODS) $(OBJS) $(NETCDF_LIBS) -o kp_nc

tp_nc: $(MODS) tp_nc.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) tp_nc.o \
	      $(MODS) $(OBJS) $(NETCDF_LIBS) -o tp_nc

wi_nc: $(MODP) wi_nc.o $(OBJP)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) wi_nc.o \
	      $(MODP) $(OBJP) $(NETCDF_LIBS) -o wi_nc 


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

mod_scrip.o: mod_scrip.f
mod_xc.o:    mod_xc.F
mod_za.o:    mod_za.F mod_xc.o

zh.o:        zh.F zh_sun.f zh_t3e.f zh_ymp.f


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
