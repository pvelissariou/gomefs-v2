Pro Ncdf_Wrf_ReadOutput, fname
;+++
; NAME:
;	Ncdf_Wrf_ReadOutput
; VERSION:
;	1.0
; PURPOSE:
;	To read a model data file and return the model's output variables.
; CALLING SEQUENCE:
;	Ncdf_Wrf_ReadOutput, fname
;	On input:
;	   fname - Full pathway name of the data file
;	On output:
;	   All the WRF output data found in the file
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
    if ((dim_idx = (where(strmatch(dim_names, 'west_east') eq 1))[0]) ge 0) then begin
      ncdf_diminq, ncid, ncdf_dimid(ncid, 'west_east'), tmp_str, thisVAL
      west_east = long(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'west_east dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'south_north') eq 1))[0]) ge 0) then begin
      ncdf_diminq, ncid, ncdf_dimid(ncid, 'south_north'), tmp_str, thisVAL
      south_north = long(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'south_north dimension is not defined in: ' + fname
    endelse

    if ((west_east ne WRF_IPNTS) and (south_north ne WRF_JPNTS)) then begin
      message, 'wrong dimensions found: (WRF_IPNTS, WRF_JPNTS)'
    endif

    ; ----- Required variables
    ncdf_varget, ncid, ncdf_varid(ncid, 'Times'), wrf_times
    wrf_times = string(wrf_times)

    ; ----- Optional variables
    ; ----- HGT (x, y, time): "TERRAIN HEIGHT"
    dat_found = Ncdf_GetData(ncid, 'HGT', wrf_hgt, FILL_VAL = wrf_hgt_fill, UNITS = wrf_hgt_units, DESC = wrf_hgt_desc)

    ; ----- PSFC (x, y, time): "SFC PRESSURE"
    dat_found = Ncdf_GetData(ncid, 'PSFC', wrf_psfc, FILL_VAL = wrf_psfc_fill, UNITS = wrf_psfc_units, DESC = wrf_psfc_desc)

    ; ----- U10 (x, y, time): "U at 10 M"
    dat_found = Ncdf_GetData(ncid, 'U10', wrf_u10, FILL_VAL = wrf_u10_fill, UNITS = wrf_u10_units, DESC = wrf_u10_desc)

    ; ----- V10 (x, y, time): "V at 10 M"
    dat_found = Ncdf_GetData(ncid, 'V10', wrf_v10, FILL_VAL = wrf_v10_fill, UNITS = wrf_v10_units, DESC = wrf_v10_desc)

    ; ----- HWAVE (x, y, time): "SEA SURFACE WAVE HEIGHTS"
    dat_found = Ncdf_GetData(ncid, 'HWAVE', wrf_hwave, FILL_VAL = wrf_hwave_fill, UNITS = wrf_hwave_units, DESC = wrf_hwave_desc)

    ; ----- PWAVE (x, y, time): "SEA SURFACE PEAK WAVE PERIOD"
    dat_found = Ncdf_GetData(ncid, 'PWAVE', wrf_pwave, FILL_VAL = wrf_pwave_fill, UNITS = wrf_pwave_units, DESC = wrf_pwave_desc)

    ; ----- LWAVEP (x, y, time): "SEA SURFACE PEAK WAVE LENGTH"
    dat_found = Ncdf_GetData(ncid, 'LWAVEP', wrf_lwavep, FILL_VAL = wrf_lwavep_fill, UNITS = wrf_lwavep_units, DESC = wrf_lwavep_desc)

    ; ----- CLDFRA (x, y, z, time): "CLOUD FRACTION"
    dat_found = Ncdf_GetData(ncid, 'CLDFRA', wrf_cldfra, FILL_VAL = wrf_cldfra_fill, UNITS = wrf_cldfra_units, DESC = wrf_cldfra_desc)

    ; ----- ALBEDO (x, y, time): "ALBEDO"
    dat_found = Ncdf_GetData(ncid, 'ALBEDO', wrf_albedo, FILL_VAL = wrf_albedo_fill, UNITS = wrf_albedo_units, DESC = wrf_albedo_desc)

    ; ----- RAINC (x, y, time): "ACCUMULATED TOTAL CUMULUS PRECIPITATION"
    dat_found = Ncdf_GetData(ncid, 'RAINC', wrf_rainc, FILL_VAL = wrf_rainc_fill, UNITS = wrf_rainc_units, DESC = wrf_rainc_desc)

    ; ----- RAINNC (x, y, time): "ACCUMULATED TOTAL GRID SCALE PRECIPITATION"
    dat_found = Ncdf_GetData(ncid, 'RAINNC', wrf_rainnc, FILL_VAL = wrf_rainnc_fill, UNITS = wrf_rainnc_units, DESC = wrf_rainnc_desc)

    ; ----- T2 (x, y, time): "TEMPERATURE at 2 M"
    dat_found = Ncdf_GetData(ncid, 'T2', wrf_tair, FILL_VAL = wrf_tair_fill, UNITS = wrf_tair_units, DESC = wrf_tair_desc)

    ; ----- TH2 (x, y, time): "POTENTIAL TEMPERATURE at 2 M"
    dat_found = Ncdf_GetData(ncid, 'TH2', wrf_tpot, FILL_VAL = wrf_tpot_fill, UNITS = wrf_tpot_units, DESC = wrf_tpot_desc)

    ; ----- SST (x, y, time): "SEA SURFACE TEMPERATURE"
    dat_found = Ncdf_GetData(ncid, 'SST', wrf_sst, FILL_VAL = wrf_sst_fill, UNITS = wrf_sst_units, DESC = wrf_sst_desc)

    ; ----- SSTSK (x, y, time): "SKIN SEA SURFACE TEMPERATURE"
    dat_found = Ncdf_GetData(ncid, 'SSTSK', wrf_sstsk, FILL_VAL = wrf_sstsk_fill, UNITS = wrf_sstsk_units, DESC = wrf_sstsk_desc)

    ; ----- TSK (x, y, time): "SURFACE SKIN TEMPERATURE"
    dat_found = Ncdf_GetData(ncid, 'TSK', wrf_tsk, FILL_VAL = wrf_tsk_fill, UNITS = wrf_tsk_units, DESC = wrf_tsk_desc)

    ; ----- Q2 (x, y, time): "WATER VAPOR MIXING RATIO at 2 M"
    dat_found = Ncdf_GetData(ncid, 'Q2', wrf_q2, FILL_VAL = wrf_q2_fill, UNITS = wrf_q2_units, DESC = wrf_q2_desc)

    ; ----- EMISS (x, y, time): "SURFACE EMISSIVITY"
    dat_found = Ncdf_GetData(ncid, 'EMISS', wrf_emiss, FILL_VAL = wrf_emiss_fill, UNITS = wrf_emiss_units, DESC = wrf_emiss_desc)

    ; ----- GRDFLX (x, y, time): "GROUND HEAT FLUX"
    dat_found = Ncdf_GetData(ncid, 'GRDFLX', wrf_grdflx, FILL_VAL = wrf_grdflx_fill, UNITS = wrf_grdflx_units, DESC = wrf_grdflx_desc)

    ; ----- ACGRDFLX (x, y, time): "ACCUMULATED GROUND HEAT FLUX"
    dat_found = Ncdf_GetData(ncid, 'ACGRDFLX', wrf_acgrdflx, FILL_VAL = wrf_acgrdflx_fill, UNITS = wrf_acgrdflx_units, DESC = wrf_acgrdflx_desc)

    ; ----- HFX (x, y, time): "UPWARD HEAT FLUX AT THE SURFACE"
    dat_found = Ncdf_GetData(ncid, 'HFX', wrf_hfx, FILL_VAL = wrf_hfx_fill, UNITS = wrf_hfx_units, DESC = wrf_hfx_desc)

    ; ----- QFX (x, y, time): "UPWARD MOISTURE FLUX AT THE SURFACE"
    dat_found = Ncdf_GetData(ncid, 'QFX', wrf_qfx, FILL_VAL = wrf_qfx_fill, UNITS = wrf_qfx_units, DESC = wrf_qfx_desc)

    ; ----- SWDOWN (x, y, time): "DOWNWARD SHORT WAVE FLUX AT GROUND SURFACE"
    dat_found = Ncdf_GetData(ncid, 'SWDOWN', wrf_swdown, FILL_VAL = wrf_swdown_fill, UNITS = wrf_swdown_units, DESC = wrf_swdown_desc)

    ; ----- GSW (x, y, time): "NET SHORT WAVE FLUX AT GROUND SURFACE"
    dat_found = Ncdf_GetData(ncid, 'GSW', wrf_gsw, FILL_VAL = wrf_gsw_fill, UNITS = wrf_gsw_units, DESC = wrf_gsw_desc)

    ; ----- GLW (x, y, time): "DOWNWARD LONG WAVE FLUX AT GROUND SURFACE"
    dat_found = Ncdf_GetData(ncid, 'GLW', wrf_glw, FILL_VAL = wrf_glw_fill, UNITS = wrf_glw_units, DESC = wrf_glw_desc)

    ; ----- OLR (x, y, time): "TOA OUTGOING LONG WAVE"
    dat_found = Ncdf_GetData(ncid, 'OLR', wrf_olr, FILL_VAL = wrf_olr_fill, UNITS = wrf_olr_units, DESC = wrf_olr_desc)

    ; ----- LH (x, y, time): "LATENT HEAT FLUX AT THE SURFACE"
    dat_found = Ncdf_GetData(ncid, 'LH', wrf_lh, FILL_VAL = wrf_lh_fill, UNITS = wrf_lh_units, DESC = wrf_lh_desc)

    ; ----- ACHFX (x, y, time): "ACCUMULATED UPWARD HEAT FLUX AT THE SURFACE"
    dat_found = Ncdf_GetData(ncid, 'ACHFX', wrf_achfx, FILL_VAL = wrf_achfx_fill, UNITS = wrf_achfx_units, DESC = wrf_achfx_desc)

    ; ----- ACLHF (x, y, time): "ACCUMULATED UPWARD LATENT HEAT FLUX AT THE SURFACE"
    dat_found = Ncdf_GetData(ncid, 'ACLHF', wrf_aclhf, FILL_VAL = wrf_aclhf_fill, UNITS = wrf_aclhf_units, DESC = wrf_aclhf_desc)

  ncdf_close, ncid

end
