#
# Makefile for sample processing
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

# NETCDF_MOD := netcdf.mod
#NETCDF_TYPE := typesizes.mod
#NETCDF_LIBS := -L$(NETCDF_LIBDIR) -lnetcdf -lnetcdff

#ifneq ($(MAKECMDGOALS),clean)
#  ifneq ($(MAKECMDGOALS),realclean)
#    ifeq (, $(wildcard $(NETCDF_INCDIR)/$(NETCDF_MOD)))
#      $(error Could not locate the file: "$(NETCDF_MOD)" (set variable NETCDF_INCDIR))
#    endif

#    ifeq (, $(wildcard $(NETCDF_INCDIR)/$(NETCDF_TYPE)))
#      $(error Could not locate the file: "$(NETCDF_TYPE)" (set variable NETCDF_INCDIR))
#    endif

#    ifeq (, $(wildcard $(NETCDF_LIBDIR)/libnetcdf.*))
#      $(error Could not locate the files: "libnetcdf.*" (set variable NETCDF_LIBDIR))
#    endif

#    ifeq (, $(wildcard $(NETCDF_LIBDIR)/libnetcdff.*))
#      $(error Could not locate the files: "libnetcdff.*" (set variable NETCDF_LIBDIR))
#    endif
#  endif
#endif


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

PROGRAMS = baro_vel transport transport2 transport3 transport3_lm \
           transp_mn transp_mn2 transp_mn3 transp_mn_2p0 meantspt \
           mergetspt

NCDF_PROGRAMS =

ALL_PROGRAMS := $(PROGRAMS) $(NCDF_PROGRAMS)


#--------------------------------------------------------------------------
#  Targets to create the executables.
#--------------------------------------------------------------------------

.PHONY: all

#all: ncdf_req $(ALL_PROGRAMS)
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

MODS = mod_trans.o mod_xc.o mod_za.o wtime.o
OBJS = blkin.o geopar.o getdat.o zh.o


# ---------------------------------------------------------------------
# Executables.
# ---------------------------------------------------------------------

baro_vel: $(MODS) baro_vel.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) baro_vel.o \
	      $(MODS) $(OBJS) -o baro_vel

baro_vel_mn: $(MODS) baro_vel_mn.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) baro_vel_mn.o \
	      $(MODS) $(OBJS) -o baro_vel_mn

transport: $(MODS) transport.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) transport.o \
	      $(MODS) $(OBJS) -o transport

transport2: $(MODS) transport2.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) transport2.o \
	      $(MODS) $(OBJS) -o transport2

transport3: $(MODS) transport3.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) transport3.o \
	      $(MODS) $(OBJS) -o transport3

transport3_lm: $(MODS) transport3_lm.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) transport3_lm.o \
	      $(MODS) $(OBJS) -o transport3_lm

transp_mn: $(MODS) transp_mn.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) transp_mn.o \
	      $(MODS) $(OBJS) -o transp_mn

transp_mn2: $(MODS) transp_mn2.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) transp_mn2.o \
	      $(MODS) $(OBJS) -o transp_mn2

transp_mn3: $(MODS) transp_mn3.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) transp_mn3.o \
	      $(MODS) $(OBJS) -o transp_mn3

transp_mn_2p0: $(MODS) transp_mn_2p0.o $(OBJS)
	$(LD) $(LDFLAGS) $(X_LDFLAGS) transp_mn_2p0.o \
	      $(MODS) $(OBJS) -o transp_mn_2p0

meantspt: meantspt.o blkin.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) meantspt.o blkin.o zh.o \
	      -o meantspt

mergetspt: mergetspt.o blkin.o zh.o
	$(LD) $(LDFLAGS) $(X_LDFLAGS) mergetspt.o blkin.o zh.o \
	      -o mergetspt


# ---------------------------------------------------------------------
# File dependencies.
# ---------------------------------------------------------------------

baro_vel.o:      baro_vel.f      $(MODS)
baro_vel_mn.o:   baro_vel_mn.f   $(MODS)
transport.o:     transport.f     $(MODS)
transport2.o:    transport2.f    $(MODS)
transport3.o:    transport3.f    $(MODS)
transp_mn.o:     transp_mn.f     $(MODS)
transp_mn2.o:    transp_mn2.f    $(MODS)
transp_mn3.o:    transp_mn3.f    $(MODS)
transp_mn_2p0.o: transp_mn_2p0.f $(MODS)
geopar.o:        geopar.f        $(MODS)
getdat.o:        getdat.f        $(MODS)

blkin.o:     blkin.f
meantspt.o:  meantspt.f
mergetspt.o: mergetspt.f
wtime.o:     wtime.F

mod_trans.o: mod_trans.F mod_xc.o mod_za.o
mod_xc.o:    mod_xc.F   
mod_za.o:    mod_za.F    mod_xc.o
mod_zb.o:    mod_zb.F

zh.o:        zh.F zh_sun.f zh_t3e.f zh_ymp.f


#--------------------------------------------------------------------------
#  NetCDF requirements.
#--------------------------------------------------------------------------

#.PHONY: ncdf_req

#ncdf_req:
#	  rm -f $(NETCDF_MOD)
#	/bin/cp -f $(NETCDF_INCDIR)/$(NETCDF_MOD) $(NETCDF_MOD)
#	  rm -f $(NETCDF_TYPE)
#	/bin/cp -f $(NETCDF_INCDIR)/$(NETCDF_TYPE) $(NETCDF_TYPE)


#--------------------------------------------------------------------------
#  Cleaning targets.
#--------------------------------------------------------------------------

.PHONY: clean

clean:
	rm -f *.o *.a *.mod M*log


.PHONY: realclean

realclean: clean
	rm -f $(ALL_PROGRAMS)
