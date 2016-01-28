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

PROGRAMS = hycomarchv micomarchv conv_archv hybgen_archv mrgl_archv \
           ncoda_archv ncoda_archv_inc remap_archv remapi_archv trim_archv \
           archt2archv archv2data2d archm2data2d archv2data2t archv2data3z \
           archm2data3z archv2datasf archv2datasfl archv2datasfz archv2ncombc \
           archv2restart archm2restart field2data restart2archv

NCDF_PROGRAMS = archv2ncdf2d archm2ncdf2d archv2ncdf2t archv2ncdf3z \
	        archm2ncdf3z archv2ncdfsf archv2ncdfsfl archv2ncdfsfz \
                field2ncdf

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

MODS     =	mod_plot.o mod_xc.o mod_za.o               wtime.o
MODB     =	mod_plot.o mod_xc.o mod_za.o mod_zb.o      wtime.o
MODZ     =	mod_plot.o mod_xc.o mod_za.o mod_zb.o      wtime.o mod_ppsw.o
MODR     =	mod_plot.o mod_xc.o mod_za.o mod_restart.o wtime.o

DATAX_OBJ = 	bigrid.o           blkin.o    \
		buoflx.o                      \
		extrct.o  extrot.o fordate.o  \
                getdat.o  getdtm.o getdepth.o \
		          indxi.o  indxj.o    \
                pakk.o             psmoo.o    \
		          zebra.o  zh.o       \
                dum_gks.o

DATAH_OBJ = 	$(DATAX_OBJ) horout.o
DATAR_OBJ = 	$(DATAX_OBJ) putdat.o
DATAZ_OBJ = 	$(DATAH_OBJ) layer2z.o mixlay.o

NCDFH_OBJ = 	$(DATAX_OBJ) horout_nc.o
NCDFZ_OBJ = 	$(NCDFH_OBJ) layer2z.o mixlay.o

ARCHM_OBJ = 	bigrid.o blkin.o  \
		extrct.o extrot.o \
                getdat.o getdtm.o getdepth.f putdat.o \
		indxi.o  indxj.o  \
		zebra.o  zh.o     dum_gks.o \
		pakk.o   
# 		pakk_micom.o   

ARCHV_OBJ = 	bigrid.o blkin.o  \
		extrct.o extrot.o fordate.o \
                getdat.o getdtm.o getdepth.o putdat.o \
		indxi.o  indxj.o  pakk.o     psmoo.o  \
		zebra.o   zh.o    dum_gks.o 

ARCHT_OBJ = 	          zh.o    dum_gks.o 

ARCHV_SRC = 	hycomarchv.f micomarchv.f \
                conv_archv.f trim_archv.f mrgl_archv.f cooperhaines_archv.f \
                hybgen_archv.f     \
                hybgen_archv_old.f \
                ncoda_archv.f     \
                ncoda_archv_inc.f \
                remap_archv.f remapi_archv.f \
                field2data.f \
                archt2archv.f \
                archv2data2d.f archv2data2t.f  archv2data3z.f \
                archv2datasf.f archv2datasfl.f archv2datasfz.f \
                archv2oam.f    archv2oam_m.f   archv2restart.f putdat.f


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

archv2data2d: $(MODB) archv2data2d.o $(DATAH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2data2d.o \
	      $(MODB) $(DATAH_OBJ) -o archv2data2d

archm2data2d: $(MODB) archm2data2d.o $(DATAH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archm2data2d.o \
	      $(MODB) $(DATAH_OBJ) -o archm2data2d

archv2data2t: $(MODB) archv2data2t.o $(DATAH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2data2t.o \
	      $(MODB) $(DATAH_OBJ) -o archv2data2t

archm2data2t: $(MODB) archm2data2t.o $(DATAH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archm2data2t.o \
	      $(MODB) $(DATAH_OBJ) -o archm2data2t

archv2data3z: $(MODZ) archv2data3z.o $(DATAZ_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2data3z.o \
	      $(MODZ) $(DATAZ_OBJ) -o archv2data3z

archm2data3z: $(MODZ) archm2data3z.o $(DATAZ_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archm2data3z.o \
	      $(MODZ) $(DATAZ_OBJ) -o archm2data3z

archv2datasf: $(MODB) archv2datasf.o $(DATAZ_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2datasf.o \
	      $(MODB) $(DATAZ_OBJ) -o archv2datasf

archv2datasfl: $(MODB) archv2datasfl.o $(DATAZ_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2datasfl.o \
	      $(MODB) $(DATAZ_OBJ) -o archv2datasfl

archv2datasfz: $(MODB) archv2datasfz.o $(DATAZ_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2datasfz.o \
	      $(MODB) $(DATAZ_OBJ) -o archv2datasfz

field2data: $(MODB) field2data.o $(DATAH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) field2data.o \
	      $(MODB) $(DATAH_OBJ) -o field2data

field2ncdf: $(MODB) field2data.o $(NCDFH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) field2data.o \
	      $(MODB) $(NCDFH_OBJ) $(NETCDF_LIBS) -o field2ncdf

archv2ncdf2d: $(MODB) archv2data2d.o $(NCDFH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2data2d.o \
	      $(MODB) $(NCDFH_OBJ) $(NETCDF_LIBS) -o archv2ncdf2d

archm2ncdf2d: $(MODB) archm2data2d.o $(NCDFH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archm2data2d.o \
	      $(MODB) $(NCDFH_OBJ) $(NETCDF_LIBS) -o archm2ncdf2d

archv2ncdf2t: $(MODB) archv2data2t.o $(NCDFH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2data2t.o \
	      $(MODB) $(NCDFH_OBJ) $(NETCDF_LIBS) -o archv2ncdf2t

archv2ncdf3z: $(MODZ) archv2data3z.o $(NCDFZ_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2data3z.o \
	      $(MODZ) $(NCDFZ_OBJ) $(NETCDF_LIBS) -o archv2ncdf3z

archm2ncdf3z: $(MODZ) archm2data3z.o $(NCDFZ_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archm2data3z.o \
	      $(MODZ) $(NCDFZ_OBJ) $(NETCDF_LIBS) -o archm2ncdf3z

archv2ncdfsf: $(MODB) archv2datasf.o $(NCDFZ_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2datasf.o \
	      $(MODB) $(NCDFZ_OBJ) $(NETCDF_LIBS) -o archv2ncdfsf

archv2ncdfsfl: $(MODB) archv2datasfl.o $(NCDFZ_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2datasfl.o \
	      $(MODB) $(NCDFZ_OBJ) $(NETCDF_LIBS) -o archv2ncdfsfl

archv2ncdfsfz: $(MODB) archv2datasfz.o $(NCDFZ_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2datasfz.o \
	      $(MODB) $(NCDFZ_OBJ) $(NETCDF_LIBS) -o archv2ncdfsfz

archv2ncombc: $(MODB) archv2ncombc.o $(DATAH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2ncombc.o \
	      $(MODB) $(DATAH_OBJ) -o archv2ncombc

archv2oam: $(MODB) archv2oam.o $(DATAH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2oam.o \
	      $(MODB) $(DATAH_OBJ) -o archv2oam

archv2oam_m: $(MODB) archv2oam_m.o $(DATAH_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2oam_m.o \
	      $(MODB) $(DATAH_OBJ) -o archv2oam_m

archv2restart: $(MODR) archv2restart.o $(DATAX_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archv2restart.o \
	      $(MODR) $(DATAX_OBJ) -o archv2restart

archm2restart: $(MODR) archm2restart.o $(DATAX_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archm2restart.o \
	      $(MODR) $(DATAX_OBJ) -o archm2restart

cooperhaines_archv: $(MODS) cooperhaines_archv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) cooperhaines_archv.o \
	      $(MODS) $(ARCHV_OBJ) -o cooperhaines_archv

archt2archv: $(MODS) archt2archv.o $(ARCHT_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) archt2archv.o \
	      $(MODS) $(ARCHT_OBJ) -o archt2archv

hycomarchv: $(MODS) hycomarchv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hycomarchv.o \
	      $(MODS) $(ARCHV_OBJ) -o hycomarchv

micomarchv: $(MODS) micomarchv.o $(ARCHM_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) micomarchv.o \
	      $(MODS) $(ARCHM_OBJ) -o micomarchv

conv_archv: $(MODS) conv_archv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) conv_archv.o \
	      $(MODS) $(ARCHV_OBJ) -o conv_archv

hybgen_archv: $(MODS) hybgen_archv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hybgen_archv.o \
	      $(MODS) $(ARCHV_OBJ) -o hybgen_archv

hybgen_archv_old: $(MODS) hybgen_archv_old.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) hybgen_archv_old.o \
	      $(MODS) $(ARCHV_OBJ) -o hybgen_archv_ol

mrgl_archv: $(MODS) mrgl_archv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) mrgl_archv.o \
	      $(MODS) $(ARCHV_OBJ) -o mrgl_archv

trim_archv: $(MODS) trim_archv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) trim_archv.o \
	      $(MODS) $(ARCHV_OBJ) -o trim_archv

ncoda_archv: $(MODS) ncoda_archv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) ncoda_archv.o \
	      $(MODS) $(ARCHV_OBJ) -o ncoda_archv

ncoda_archv_inc: $(MODS) ncoda_archv_inc.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) ncoda_archv_inc.o \
	      $(MODS) $(ARCHV_OBJ) -o ncoda_archv_inc

remap_archv: $(MODS) remap_archv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) remap_archv.o \
	      $(MODS) $(ARCHV_OBJ) -o remap_archv

remapi_archv: $(MODS) remapi_archv.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) remapi_archv.o \
	      $(MODS) $(ARCHV_OBJ) -o remapi_archv

remap_ncombc: $(MODS) remap_ncombc.o $(ARCHV_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) remap_ncombc.o \
	      $(MODS) $(ARCHV_OBJ) -o remap_ncomb

restart2archv: $(MODR) restart2archv.o $(DATAR_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) restart2archv.o \
	      $(MODR) $(DATAR_OBJ) -o restart2archv

restart2archv_ssh: $(MODR) restart2archv_ssh.o $(DATAR_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) restart2archv_ssh.o \
	      $(MODR) $(DATAR_OBJ) -o restart2archv_ss

restart2archv_sig2a: $(MODR) restart2archv_sig2a.o $(DATAR_OBJ)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) restart2archv_sig2a.o \
	      $(MODR) $(DATAR_OBJ) -o restart2archv_sig2a


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

archv2data2d.o:  archv2data2d.f  mod_plot.o mod_za.o
archm2data2d.o:  archm2data2d.f  mod_plot.o mod_za.o
archv2data3z.o:  archv2data3z.f  mod_plot.o mod_za.o
archm2data3z.o:  archm2data3z.f  mod_plot.o mod_za.o
archv2datasf.o:  archv2datasf.f  mod_plot.o mod_za.o
archv2datasfl.o: archv2datasfl.f mod_plot.o mod_za.o
archv2datasfz.o: archv2datasfz.f mod_plot.o mod_za.o
archv2ncombc.o:  archv2ncombc.f  mod_plot.o mod_za.o
archv2restart.o: archv2restart.f mod_plot.o mod_za.o mod_restart.o
archm2restart.o: archm2restart.f mod_plot.o mod_za.o mod_restart.o

hycomarchv.o:    hycomarchv.f    mod_plot.o mod_za.o
micomarchv.o:    micomarchv.f    mod_plot.o mod_za.o
mrgl_archv.o:    mrgl_archv.f    mod_plot.o mod_za.o
trim_archv.o:    trim_archv.f    mod_plot.o mod_za.o
remap_archv.o:   remap_archv.f   mod_plot.o mod_za.o

hybgen_archv.o:     hybgen_archv.f     mod_plot.o mod_za.o
hybgen_archv_old.o: hybgen_archv_old.f mod_plot.o mod_za.o

ncoda_archv.o:      ncoda_archv.f      mod_plot.o mod_za.o
ncoda_archv_inc.o:  ncoda_archv_inc.f  mod_plot.o mod_za.o

restart2archv.o: restart2archv.f mod_plot.o mod_za.o mod_restart.o

bigrid.o:   bigrid.f      mod_plot.o
blkin.o:    blkin.f
buoflx.o:   buoflx.f
dum_gks.o:  dum_gks.f
extrct.o:   extrct.f
extrot.o:   extrot.f
fordate.o:  fordate.f
getdat.o:   getdat.f      mod_plot.o mod_za.o
getdepth.o: getdepth.f    mod_plot.o mod_za.o
getdtm.o:   getdtm.f      mod_plot.o mod_za.o
horout.o:   horout.f      mod_plot.o mod_xc.o mod_zb.o
horout_nc.o: horout_nc.f  mod_plot.o mod_xc.o mod_zb.o
indxi.o:    indxi.f       mod_plot.o
indxj.o:    indxj.f       mod_plot.o
layer2z.o:  layer2z.f
mixlay.o:   mixlay.f
pakk.o:     pakk.f
prtmsk.o:   prtmsk.f
psmoo.o:    psmoo.f       mod_plot.o
putdat.o:   putdat.f      mod_plot.o mod_za.o
wtime.o:    wtime.F
zebra.o:    zebra.f

mod_plot.o: mod_plot.F
mod_ppsw.o: mod_ppsw.F
mod_xc.o:   mod_xc.F   
mod_za.o:   mod_za.F   mod_xc.o
mod_zb.o:   mod_zb.F

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
