Pro Undefine_Wrf_Params, GRID = grid, FLOW = flow
;+++
; NAME:
;	Undefine_Wrf_Params
; VERSION:
;	1.0
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

  if keyword_set(grid) then begin
    undefine, WRF_IPNTS, WRF_JPNTS, WRF_TCELLS
    undefine, WRF_WCELLS, WRF_WCELLSIDX, WRF_LCELLS, WRF_LCELLSIDX
    undefine, WRF_IPNTS_STAG, WRF_JPNTS_STAG
    ;
    undefine, WRF_mgrid
    undefine, WRF_SINALPHA, WRF_COSALPHA
    ;
    undefine, WRF_longrid, WRF_latgrid
    undefine, WRF_LON_MIN, WRF_LON_MAX, WRF_LON_MEAN
    undefine, WRF_LAT_MIN, WRF_LAT_MAX, WRF_LAT_MEAN
    undefine, WRF_longrid_u, WRF_latgrid_u
    undefine, WRF_longrid_v, WRF_latgrid_v
    ;
    undefine, WRF_dlongrid, WRF_dlatgrid
    undefine, WRF_DLON_MIN, WRF_DLON_MAX, WRF_DLON_MEAN
    undefine, WRF_DLAT_MIN, WRF_DLAT_MAX, WRF_DLAT_MEAN
    ;
    undefine, WRF_xgrid, WRF_ygrid
    undefine, WRF_X_MIN, WRF_X_MAX, WRF_X_MEAN
    undefine, WRF_Y_MIN, WRF_Y_MAX, WRF_Y_MEAN
    ;
    undefine, WRF_dxgrid, WRF_dygrid
    undefine, WRF_DX_MIN, WRF_DX_MAX, WRF_DX_MEAN
    undefine, WRF_DY_MIN, WRF_DY_MAX, WRF_DY_MEAN
    ;
    undefine, WRF_MapStruct
    undefine, WRF_PROJ, WRF_PROJ_NAM, WRF_HDATUM, WRF_VDATUM
    undefine, WRF_RADIUS, WRF_SemiMIN, WRF_SemiMAJ
    undefine, WRF_CENT_LON, WRF_CENT_LAT, WRF_STAND_LON
    undefine, WRF_TRUELAT1, WRF_TRUELAT2
  endif

  if keyword_set(flow) then begin
    undefine, wrf_times
    undefine, wrf_hgt,      wrf_hgt_fill,      wrf_hgt_units,      wrf_hgt_desc
    undefine, wrf_psfc,     wrf_psfc_fill,     wrf_psfc_units,     wrf_psfc_desc
    undefine, wrf_u10,      wrf_u10_fill,      wrf_u10_units,      wrf_u10_desc
    undefine, wrf_v10,      wrf_v10_fill,      wrf_v10_units,      wrf_v10_desc
    undefine, wrf_hwave,    wrf_hwave_fill,    wrf_hwave_units,    wrf_hwave_desc
    undefine, wrf_pwave,    wrf_pwave_fill,    wrf_pwave_units,    wrf_pwave_desc
    undefine, wrf_lwavep,   wrf_lwavep_fill,   wrf_lwavep_units,   wrf_lwavep_desc
    undefine, wrf_cldfra,   wrf_cldfra_fill,   wrf_cldfra_units,   wrf_cldfra_desc
    undefine, wrf_albedo,   wrf_albedo_fill,   wrf_albedo_units,   wrf_albedo_desc
    undefine, wrf_rainc,    wrf_rainc_fill,    wrf_rainc_units,    wrf_rainc_desc
    undefine, wrf_rainnc,   wrf_rainnc_fill,   wrf_rainnc_units,   wrf_rainnc_desc
    undefine, wrf_tair,     wrf_tair_fill,     wrf_tair_units,     wrf_tair_desc
    undefine, wrf_tpot,     wrf_tpot_fill,     wrf_tpot_units,     wrf_tpot_desc
    undefine, wrf_sst,      wrf_sst_fill,      wrf_sst_units,      wrf_sst_desc
    undefine, wrf_sstsk,    wrf_sstsk_fill,    wrf_sstsk_units,    wrf_sstsk_desc
    undefine, wrf_tsk,      wrf_tsk_fill,      wrf_tsk_units,      wrf_tsk_desc
    undefine, wrf_q2,       wrf_q2_fill,       wrf_q2_units,       wrf_q2_desc
    undefine, wrf_emiss,    wrf_emiss_fill,    wrf_emiss_units,    wrf_emiss_desc
    undefine, wrf_grdflx,   wrf_grdflx_fill,   wrf_grdflx_units,   wrf_grdflx_desc
    undefine, wrf_acgrdflx, wrf_acgrdflx_fill, wrf_acgrdflx_units, wrf_acgrdflx_desc
    undefine, wrf_hfx,      wrf_hfx_fill,      wrf_hfx_units,      wrf_hfx_desc
    undefine, wrf_qfx,      wrf_qfx_fill,      wrf_qfx_units,      wrf_qfx_desc
    undefine, wrf_swdown,   wrf_swdown_fill,   wrf_swdown_units,   wrf_swdown_desc
    undefine, wrf_gsw,      wrf_gsw_fill,      wrf_gsw_units,      wrf_gsw_desc
    undefine, wrf_glw,      wrf_glw_fill,      wrf_glw_units,      wrf_glw_desc
    undefine, wrf_olr,      wrf_olr_fill,      wrf_olr_units,      wrf_olr_desc
    undefine, wrf_lh,       wrf_lh_fill,       wrf_lh_units,       wrf_lh_desc
    undefine, wrf_achfx,    wrf_achfx_fill,    wrf_achfx_units,    wrf_achfx_desc
    undefine, wrf_aclhf,    wrf_aclhf_fill,    wrf_aclhf_units,    wrf_aclhf_desc
  endif

end
