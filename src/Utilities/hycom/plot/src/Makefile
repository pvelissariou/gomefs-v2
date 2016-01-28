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
#  Check for the required NCL files.
#--------------------------------------------------------------------------

NCL_LIBS  := -L$(NCL_LIBDIR) -lncarg -lncarg_gks -lncarg_gks_cairo -lncarg_c
NCL_XLIBS := -lgfortran
X11_LIBS  := -lX11

ifneq ($(MAKECMDGOALS),clean)
  ifneq ($(MAKECMDGOALS),realclean)
    ifeq (, $(wildcard $(NCL_LIBDIR)/libncarg.*))
      $(error Could not locate the files: "libncarg.*" (set variable NCL_LIBDIR))
    endif

    ifeq (, $(wildcard $(NCL_LIBDIR)/libncarg_gks.*))
      $(error Could not locate the files: "libncarg_gks.*" (set variable NCL_LIBDIR))
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

STD_PROGRAMS = hycomproc micomproc fieldproc fieldcell

MEDIA_PROGRAMS = hp_meta hp_psp hp_psl hp_x11 \
                 mp_meta mp_psp mp_psl mp_x11 \
                 fp_meta fp_psp fp_psl fp_x11 \
                 fc_meta fc_psp fc_psl fc_x11

TEST_PROGRAMS  = hycomtest fieldtest fieldctst

PROGRAMS := $(STD_PROGRAMS) $(MEDIA_PROGRAMS)

NCDF_PROGRAMS = hycomnavo

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

#OPNGKS_OBJ = opngks_meta.o
#OPNGKS_OBJ = opngks_x11.o
#OPNGKS_OBJ = opngks_psl.o
OPNGKS_OBJ = opngks_psp.o

MODS     =	mod_plot.o mod_xc.o mod_za.o wtime.o

MPRC_OBJ = 	arrow1.o bigrid.o bigrd1.o blkin.o bord.o \
		colbar.o colors.o conrec.o contur.o \
		extrct.o extrot.o filtr1.o fram.o fordate.o \
                getdat.o getdtm.o getdepth.o grdtrns.o \
		horplt.o indxi.o  indxj.o legend1.o \
		         poisnd.o prtmsk.o psmoo.o \
		sbmerg.o xsecij.o ssort.o  zebra.o \
		tracks.o \
		zh.o \
		pakk.o   
# 		pakk_micom.o   

PROC_OBJ = 	arrow1.o bigrid.o bigrd1.o blkin.o bord.o \
		colbar.o colors.o conrec.o contur.o \
		extrct.o extrot.o filtr1.o fram.o fordate.o \
                getdat.o getdtm.o getdepth.o grdtrns.o \
		horplt.o indxi.o  indxj.o legend1.o \
		pakk.o   poisnd.o prtmsk.o psmoo.o \
		sbmerg.o xsecij.o ssort.o  zebra.o \
		tracks.o \
		zh.o

PROC_SRC = 	arrow1.f bigrid.f bigrd1.f bklin.f bord.f \
		colbar.f colors.f conrec.f contur.f \
		extrct.f extrot.f filtr1.f fram.f fordate.f \
		getdat.f getdtm.f getdepth.f grdtrns.f \
		horplt.f indxi.f  indxj.f legend1.f \
		         poisnd.f prtmsk.f psmoo.f \
		pakk.f   pakk_micom.f \
		sbmerg.f xsecij.f ssort.f  zebra.f \
		tracks.f \
		mod_xc.F mod_za.F mod_za_sm.F wtime.F

NAVO_OBJ := 	$(PROC_OBJ) getdat_nc.o

NAVO_SRC := 	$(PROC_SRC) getdat_nc.f

FIELD_OBJ = 	blkin.o bord.o \
		colbar.o colors.o conrec.o contur.o \
		getdepth.o extrct.o fram.o \
		horplt.o \
		prtmsk.o \
		arrow1.o carrow.o legend1.o \
		tracks.o \
		         zebra.o zh.o
CELL_OBJ = 	blkin.o bord.o \
		colbar.o colors.o conrec.o contur.o \
		getdepth.o extrct.o fram.o \
		prtmsk.o \
		tracks.o \
		cpmpxy_cell.o \
		         zebra.o zh.o

FIELD_SRC = 	fieldproc.f carrow.f fieldcell.f cpmpxy_cell.f

EXT_LIBS := $(NCL_LIBS) $(NCL_XLIBS) $(X11_LIBS) 


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

# --- default executables.
#
hycomproc: $(MODS) hycomproc.o $(PROC_OBJ) $(OPNGKS_OBJ)
	$(LD) $(LDFLAGS) hycomproc.o \
	      $(MODS) $(PROC_OBJ) $(OPNGKS_OBJ) $(EXT_LIBS) -o hycomproc

hycomnavo: $(MODS) hycomnavo.o $(NAVO_OBJ) $(OPNGKS_OBJ)
	$(LD) $(LDFLAGS) hycomnavo.o \
	      $(MODS) $(NAVO_OBJ) $(OPNGKS_OBJ) $(NETCDF_LIBS) $(EXT_LIBS) -o hycomnavo

micomproc: $(MODS) micomproc.o $(MPRC_OBJ) $(OPNGKS_OBJ)
	$(LD) $(LDFLAGS) micomproc.o \
	      $(MODS) $(MPRC_OBJ) $(OPNGKS_OBJ) $(EXT_LIBS) -o micomproc

fieldproc: $(MODS) fieldproc.o $(FIELD_OBJ) $(OPNGKS_OBJ)
	$(LD) $(LDFLAGS) fieldproc.o \
	      $(MODS) $(FIELD_OBJ) $(OPNGKS_OBJ) $(EXT_LIBS) -o fieldproc

fieldcell: $(MODS) fieldcell.o $(CELL_OBJ) $(OPNGKS_OBJ)
	$(LD) $(LDFLAGS) fieldcell.o \
	      $(MODS) $(CELL_OBJ) $(OPNGKS_OBJ) $(EXT_LIBS) -o fieldcell

# --- executables for specific output media.
#
hp_meta: $(MODS) hycomproc.o $(PROC_OBJ) opngks_meta.o
	$(LD) $(LDFLAGS) hycomproc.o \
	      $(MODS) $(PROC_OBJ) opngks_meta.o $(EXT_LIBS) -o hp_meta

hp_psp: $(MODS) hycomproc.o $(PROC_OBJ) opngks_psp.o
	$(LD) $(LDFLAGS) hycomproc.o \
	      $(MODS) $(PROC_OBJ) opngks_psp.o $(EXT_LIBS) -o hp_psp

hp_psl: $(MODS) hycomproc.o $(PROC_OBJ) opngks_psl.o
	$(LD) $(LDFLAGS) hycomproc.o \
	      $(MODS) $(PROC_OBJ) opngks_psl.o $(EXT_LIBS) -o hp_psl

hp_x11: $(MODS) hycomproc.o $(PROC_OBJ) opngks_x11.o
	$(LD) $(LDFLAGS) hycomproc.o \
	      $(MODS) $(PROC_OBJ) opngks_x11.o $(EXT_LIBS) -o hp_x11

mp_meta: $(MODS) micomproc.o $(MPRC_OBJ) opngks_meta.o
	$(LD) $(LDFLAGS) micomproc.o \
	      $(MODS) $(MPRC_OBJ) opngks_meta.o $(EXT_LIBS) -o mp_meta

mp_psp: $(MODS) micomproc.o $(MPRC_OBJ) opngks_psp.o
	$(LD) $(LDFLAGS) micomproc.o \
	      $(MODS) $(MPRC_OBJ) opngks_psp.o $(EXT_LIBS) -o mp_psp

mp_psl: $(MODS) micomproc.o $(MPRC_OBJ) opngks_psl.o
	$(LD) $(LDFLAGS) micomproc.o \
	      $(MODS) $(MPRC_OBJ) opngks_psl.o $(EXT_LIBS) -o mp_psl

mp_x11: $(MODS) micomproc.o $(MPRC_OBJ) opngks_x11.o
	$(LD) $(LDFLAGS) micomproc.o \
	      $(MODS) $(MPRC_OBJ) opngks_x11.o $(EXT_LIBS) -o mp_x11

fp_meta: $(MODS) fieldproc.o $(FIELD_OBJ) opngks_meta.o
	$(LD) $(LDFLAGS) fieldproc.o \
	      $(MODS) $(FIELD_OBJ) opngks_meta.o $(EXT_LIBS) -o fp_meta

fp_psp: $(MODS) fieldproc.o $(FIELD_OBJ) opngks_psp.o
	$(LD) $(LDFLAGS) fieldproc.o \
	      $(MODS) $(FIELD_OBJ) opngks_psp.o $(EXT_LIBS) -o fp_psp

fp_psl: $(MODS) fieldproc.o $(FIELD_OBJ) opngks_psl.o
	$(LD) $(LDFLAGS) fieldproc.o \
	      $(MODS) $(FIELD_OBJ) opngks_psl.o $(EXT_LIBS) -o fp_psl

fp_x11: $(MODS) fieldproc.o $(FIELD_OBJ) opngks_x11.o
	$(LD) $(LDFLAGS) fieldproc.o \
	      $(MODS) $(FIELD_OBJ) opngks_x11.o $(EXT_LIBS) -o fp_x11

fc_meta: $(MODS) fieldcell.o $(CELL_OBJ) opngks_meta.o
	$(LD) $(LDFLAGS) fieldcell.o \
	      $(MODS) $(CELL_OBJ) opngks_meta.o $(EXT_LIBS) -o fc_meta

fc_psp: $(MODS) fieldcell.o $(CELL_OBJ) opngks_psp.o
	$(LD) $(LDFLAGS) fieldcell.o \
	      $(MODS) $(CELL_OBJ) opngks_psp.o $(EXT_LIBS) -o fc_psp

fc_psl: $(MODS) fieldcell.o $(CELL_OBJ) opngks_psl.o
	$(LD) $(LDFLAGS) fieldcell.o \
	      $(MODS) $(CELL_OBJ) opngks_psl.o $(EXT_LIBS) -o fc_psl

fc_x11: $(MODS) fieldcell.o $(CELL_OBJ) opngks_x11.o
	$(LD) $(LDFLAGS) fieldcell.o \
	      $(MODS) $(CELL_OBJ) opngks_x11.o $(EXT_LIBS) -o fc_x11

#
# --- test executables.
#
hycomtest: $(MODS) hycomtest.o $(PROC_OBJ) $(OPNGKS_OBJ)
	$(LD) $(LDFLAGS) hycomtest.o \
	      $(MODS) $(PROC_OBJ) $(OPNGKS_OBJ) $(EXT_LIBS) -o hycomtest

micomtest: $(MODS) micomtest.o $(MPRC_OBJ) $(OPNGKS_OBJ)
	$(LD) $(LDFLAGS) micomtest.o \
	      $(MODS) $(MPRC_OBJ) $(OPNGKS_OBJ) $(EXT_LIBS) -o micomtest

fieldtest: $(MODS) fieldtest.o $(FIELD_OBJ) $(OPNGKS_OBJ)
	$(LD) $(LDFLAGS) fieldtest.o \
	      $(MODS) $(FIELD_OBJ) $(OPNGKS_OBJ) $(EXT_LIBS) -o fieldtest

fieldctst: $(MODS) fieldctst.o $(CELL_OBJ) $(OPNGKS_OBJ)
	$(LD) $(LDFLAGS) fieldctst.o \
	      $(MODS) $(CELL_OBJ) $(OPNGKS_OBJ) $(EXT_LIBS) -o fieldctst


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

hycomnavo.o: hycomnavo.f mod_plot.o mod_za.o
hycomproc.o: hycomproc.f mod_plot.o mod_za.o
micomproc.o: micomproc.f mod_plot.o mod_za.o
fieldproc.o: fieldproc.f mod_plot.o mod_za.o
fieldcell.o: fieldcell.f mod_plot.o mod_za.o

hycomtest.o: hycomtest.f mod_plot.o mod_za.o
micomtest.o: micomtest.f mod_plot.o mod_za.o
fieldtest.o: fieldtest.f mod_plot.o mod_za.o
fieldctst.o: fieldctst.f mod_plot.o mod_za.o

cpmpxy_cell.o: cpmpxy_cell.f mod_plot.o

arrow1.o:   arrow1.f
bigrd1.o:   bigrd1.f      mod_plot.o
bigrid.o:   bigrid.f      mod_plot.o
blkin.o:    blkin.f
bord.o:     bord.f        mod_plot.o
carrow.o:   carrow.f
colbar.o:   colbar.f
colors.o:   colors.f
conrec.o:   conrec.f
contur.o:   contur.f
extrct.o:   extrct.f
extrot.o:   extrot.f
filtr1.o:   filtr1.f
fram.o:     fram.f
fordate.o:  fordate.f
getdat.o:   getdat.f      mod_plot.o mod_za.o
getdepth.o: getdepth.f    mod_plot.o mod_za.o
getdtm.o:   getdtm.f      mod_plot.o mod_za.o
grdtrns.o:  grdtrns.f
horplt.o:   horplt.f
indxi.o:    indxi.f       mod_plot.o
indxj.o:    indxj.f       mod_plot.o
legend1.o:  legend1.f
pakk.o:     pakk.f
poisnd.o:   poisnd.f      mod_plot.o
prtmsk.o:   prtmsk.f
psmoo.o:    psmoo.f       mod_plot.o
sbmerg.o:   sbmerg.f      mod_plot.o
ssort.o:    ssort.f
tracks.o:   tracks.f
wtime.o:    wtime.F
xsecij.o:   xsecij.f
zebra.o:    zebra.f

opngks_meta.o: opngks_meta.f
opngks_psp.o:  opngks_psp.f
opngks_psl.o:  opngks_psl.f
opngks_x11.o:  opngks_x11.f

mod_plot.o: mod_plot.F
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
