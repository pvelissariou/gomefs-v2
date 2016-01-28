#::::::::::::::::::::::::::::::::::::::::::::::: Panagiotis Velissariou :::
# Original template was adopted from the ROMS model directory           :::
# Modified for HYCOM implementation                                     :::
#                                                                       :::
# Copyright (c) 2015-2014 The ROMS/TOMS Group             Kate Hedstrom :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.txt                                                :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local_sub  := HYCOM/src

local_lib  := libHYCOM.a

mods_src := mod_dimensions.F mod_xc.F mod_za.F mod_pipe.F mod_incupd.F \
	    mod_floats.F mod_tides.F mod_mean.F mod_archiv.F mod_hycom.F

modd_src := mod_dimensions.F mod_xc.F mod_za.F mod_pipe.F mod_incupd.F \
	    mod_floats.F mod_tides.F mod_mean.F mod_archiv.F mod_hycom_dummy.F

obj_src := barotp.F bigrid.F blkdat.F cnuity.F convec.F          \
	   diapfl.F dpthuv.F dpudpv.F forfun.F geopar.F hybgen.F \
	   icloan.F inicon.F inigiss.F inikpp.F inimy.F latbdy.F \
	   matinv.F momtum.F mxkprf.F mxkrt.F mxkrtm.F mxpwp.F   \
	   overtn.F poflat.F prtmsk.F psmoo.F restart.F          \
	   thermf.F trcupd.F tsadvc.F                            \
	   machine.F wtime.F machi_c.c isnan.F

ifneq ($(strip $(USE_SEAICE)),)
  local_src  := $(addprefix $(local_sub)/,$(mods_src) mod_OICPL.F $(obj_src))
else ifneq ($(strip $(USE_DUMMY_SEAICE)),)
  local_src  := $(addprefix $(local_sub)/,$(modd_src) mod_OICPL.F $(obj_src))
else
  local_src  := $(addprefix $(local_sub)/,$(mods_src) $(obj_src))
endif

$(eval $(call make-library,$(local_lib),$(local_src)))

$(eval $(compile-rules))
