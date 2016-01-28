Pro Ncdf_Cfsr_ReadOutput, fname
;+++
; NAME:
;	Ncdf_Cfsr_ReadOutput
; VERSION:
;	1.0
; PURPOSE:
;	To read a model data file and return the model's output variables.
; CALLING SEQUENCE:
;	Ncdf_Wrf_ReadOutput, fname
;	On input:
;	   fname - Full pathway name of the data file
;	On output:
;	   All the CFSR output data found in the file
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created on February 18 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  COMMON WrfGridParams
  COMMON WrfFlowParams

  ; Error handling.
  On_Error, 2

  Undefine_Wrf_Params, /FLOW

  ; check for the validity of the supplied values for "fname" or "lun"
  do_fname = N_Elements(fname) eq 0 ? 0 : 1
  If (do_fname) Then Begin
    If (Size(fname, /TNAME) ne 'STRING') Then $
      Message, "the name supplied for <fname> is not a valid string."

    fname = Strtrim(fname, 2)
    If (not readFILE(fname)) Then $
      Message, "can't read from the supplied file <" + fname + ">."
  EndIf

  ; Open and read the input NetCDF file
  ncid = ncdf_open(fname, /NOWRITE)

    ; Search for dimensions
    dim_names = ''
    for i = 0L, (ncdf_inquire(ncid)).ndims - 1 do begin
      ncdf_diminq, ncid, i, tmp_str, tmp_size
      tmp_str = strcompress(tmp_str, /REMOVE_ALL)
      dim_names = [ dim_names, tmp_str ]
    endfor
    if (n_elements(dim_names) gt 1) then begin
      dim_names = dim_names[1:*]
    endif else begin
      ncdf_close, ncid
      message, "no dimensions were found in the supplied file <" + fname + ">."
    endelse

    ; Search for variables
    var_names = ''
    for i = 0L, (ncdf_inquire(ncid)).nvars - 1 do begin
      tmp_str = strcompress((ncdf_varinq(ncid, i)).name, /REMOVE_ALL)
      var_names = [ var_names, tmp_str ]
    endfor
    if (n_elements(var_names) gt 1) then begin
      var_names = var_names[1:*]
    endif else begin
      ncdf_close, ncid
      message, "no variables were found in the supplied file <" + fname + ">."
    endelse

    ; ------------------------------
    ; Dimensions (required)
    if ((dim_idx = (where(strmatch(dim_names, 'lon') eq 1))[0]) ge 0) then begin
      ncdf_diminq, ncid, ncdf_dimid(ncid, 'lon'), tmp_str, thisVAL
      lon = long(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'lon dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'lat') eq 1))[0]) ge 0) then begin
      ncdf_diminq, ncid, ncdf_dimid(ncid, 'lat'), tmp_str, thisVAL
      lat = long(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'lat dimension is not defined in: ' + fname
    endelse

    if ((lon ne CFSR_IPNTS) and (lat ne CFSR_JPNTS)) then begin
      message, 'wrong dimensions found: (CFSR_IPNTS, CFSR_JPNTS)'
    endif

    ; ----- Required variables
    ncdf_varget, ncid, ncdf_varid(ncid, 'Times'), wrf_times
    wrf_times = string(wrf_times)

    ; ----- Optional variables
    ; ----- PRES_1_0 (x, y, time): "SFC PRESSURE"
    dat_found = Ncdf_GetData(ncid, 'PRES_1_0', cfsr_psfc, FILL_VAL = cfsr_psfc_fill, UNITS = cfsr_psfc_units, DESC = cfsr_psfc_desc)
    ; ----- Pair (x, y, time): "SFC PRESSURE"
    dat_found = Ncdf_GetData(ncid, 'Pair', cfsr_psfc, FILL_VAL = cfsr_psfc_fill, UNITS = cfsr_psfc_units, DESC = cfsr_psfc_desc)

    ; ----- U_GRD_103_10 (x, y, time): "U at 10 M"
    dat_found = Ncdf_GetData(ncid, 'U_GRD_103_10', cfsr_u10, FILL_VAL = cfsr_u10_fill, UNITS = cfsr_u10_units, DESC = cfsr_u10_desc)
    ; ----- Uwind (x, y, time): "U at 10 M"
    dat_found = Ncdf_GetData(ncid, 'Uwind', cfsr_u10, FILL_VAL = cfsr_u10_fill, UNITS = cfsr_u10_units, DESC = cfsr_u10_desc)

    ; ----- V_GRD_103_10 (x, y, time): "V at 10 M"
    dat_found = Ncdf_GetData(ncid, 'V_GRD_103_10', cfsr_v10, FILL_VAL = cfsr_v10_fill, UNITS = cfsr_v10_units, DESC = cfsr_v10_desc)
    ; ----- Vwind (x, y, time): "V at 10 M"
    dat_found = Ncdf_GetData(ncid, 'Vwind', cfsr_v10, FILL_VAL = cfsr_v10_fill, UNITS = cfsr_v10_units, DESC = cfsr_v10_desc)

    ; ----- T_CDC_200_0 (x, y, time): "TOTAL CLOUD COVER"
    dat_found = Ncdf_GetData(ncid, 'T_CDC_200_0', cfsr_cldfra, FILL_VAL = cfsr_cldfra_fill, UNITS = cfsr_cldfra_units, DESC = cfsr_cldfra_desc)
    ; ----- cloud (x, y, time): "TOTAL CLOUD COVER"
    dat_found = Ncdf_GetData(ncid, 'cloud', cfsr_cldfra, FILL_VAL = cfsr_cldfra_fill, UNITS = cfsr_cldfra_units, DESC = cfsr_cldfra_desc)

    ; ----- PRATE_1_0 (x, y, time): "PRECIPITATION RATE"
    dat_found = Ncdf_GetData(ncid, 'PRATE_1_0', cfsr_rainc, FILL_VAL = cfsr_rainc_fill, UNITS = cfsr_rainc_units, DESC = cfsr_rainc_desc)
    ; ----- rain (x, y, time): "PRECIPITATION RATE"
    dat_found = Ncdf_GetData(ncid, 'rain', cfsr_rainc, FILL_VAL = cfsr_rainc_fill, UNITS = cfsr_rainc_units, DESC = cfsr_rainc_desc)

    ; ----- TMP_103_2 (x, y, time): "TEMPERATURE at 2 M"
    dat_found = Ncdf_GetData(ncid, 'TMP_103_2', cfsr_tair, FILL_VAL = cfsr_tair_fill, UNITS = cfsr_tair_units, DESC = cfsr_tair_desc)
    ; ----- Tair (x, y, time): "TEMPERATURE at 2 M"
    dat_found = Ncdf_GetData(ncid, 'Tair', cfsr_tair, FILL_VAL = cfsr_tair_fill, UNITS = cfsr_tair_units, DESC = cfsr_tair_desc)

    ; ----- TMP_1_0 (x, y, time): "GROUND OR WATER SURFACE TEMPERATURE"
    dat_found = Ncdf_GetData(ncid, 'TMP_1_0', cfsr_sst, FILL_VAL = cfsr_sst_fill, UNITS = cfsr_sst_units, DESC = cfsr_sst_desc)
    ; ----- SST (x, y, time): "GROUND OR WATER SURFACE TEMPERATURE"
    dat_found = Ncdf_GetData(ncid, 'SST', cfsr_sst, FILL_VAL = cfsr_sst_fill, UNITS = cfsr_sst_units, DESC = cfsr_sst_desc)

    ; ----- GFLUX_1_0 (x, y, time): "GROUND HEAT FLUX"
    dat_found = Ncdf_GetData(ncid, 'GFLUX_1_0', cfsr_grdflx, FILL_VAL = cfsr_grdflx_fill, UNITS = cfsr_grdflx_units, DESC = cfsr_grdflx_desc)
    ; ----- shflux (x, y, time): "GROUND HEAT FLUX"
    dat_found = Ncdf_GetData(ncid, 'shflux', cfsr_grdflx, FILL_VAL = cfsr_grdflx_fill, UNITS = cfsr_grdflx_units, DESC = cfsr_grdflx_desc)

    ; ----- SHTFL_1_0 (x, y, time): "NET SENSIBLE HEAT FLUX"
    dat_found = Ncdf_GetData(ncid, 'SHTFL_1_0', cfsr_hfx, FILL_VAL = cfsr_hfx_fill, UNITS = cfsr_hfx_units, DESC = cfsr_hfx_desc)
    ; ----- sensible (x, y, time): "NET SENSIBLE HEAT FLUX"
    dat_found = Ncdf_GetData(ncid, 'sensible', cfsr_hfx, FILL_VAL = cfsr_hfx_fill, UNITS = cfsr_hfx_units, DESC = cfsr_hfx_desc)

    ; ----- DSWRF_1_0 (x, y, time): "DOWNWARD SHORTWAVE RADIATION FLUX"
    dat_found = Ncdf_GetData(ncid, 'DSWRF_1_0', cfsr_swdown, FILL_VAL = cfsr_swdown_fill, UNITS = cfsr_swdown_units, DESC = cfsr_swdown_desc)
    ; ----- swrad (x, y, time): "DOWNWARD SHORTWAVE RADIATION FLUX"
    dat_found = Ncdf_GetData(ncid, 'swrad', cfsr_swdown, FILL_VAL = cfsr_swdown_fill, UNITS = cfsr_swdown_units, DESC = cfsr_swdown_desc)

    ; ----- DLWRF_1_0 (x, y, time): "DOWNWARD LONGWAVE RADIATION FLUX"
    dat_found = Ncdf_GetData(ncid, 'DLWRF_1_0', cfsr_glw, FILL_VAL = cfsr_glw_fill, UNITS = cfsr_glw_units, DESC = cfsr_glw_desc)
    ; ----- lwrad_down (x, y, time): "DOWNWARD LONGWAVE RADIATION FLUX"
    dat_found = Ncdf_GetData(ncid, 'lwrad_down', cfsr_glw, FILL_VAL = cfsr_glw_fill, UNITS = cfsr_glw_units, DESC = cfsr_glw_desc)

    ; ----- LHTFL_1_0 (x, y, time): "NET LATENT HEAT FLUX"
    dat_found = Ncdf_GetData(ncid, 'LHTFL_1_0', cfsr_lh, FILL_VAL = cfsr_lh_fill, UNITS = cfsr_lh_units, DESC = cfsr_lh_desc)
    ; ----- latent (x, y, time): "NET LATENT HEAT FLUX"
    dat_found = Ncdf_GetData(ncid, 'latent', cfsr_lh, FILL_VAL = cfsr_lh_fill, UNITS = cfsr_lh_units, DESC = cfsr_lh_desc)
  ncdf_close, ncid

end
