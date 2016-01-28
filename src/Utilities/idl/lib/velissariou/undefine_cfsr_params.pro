Pro Undefine_Cfsr_Params, GRID = grid, FLOW = flow
;+++
; NAME:
;	Undefine_Cfsr_Params
; VERSION:
;	1.0
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created on February 18 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  COMMON CfsrGridParams
  COMMON CfsrFlowParams

  ; Error handling.
  On_Error, 2

  if keyword_set(grid) then begin
    undefine CFSR_IPNTS, CFSR_JPNTS, CFSR_TCELLS
    undefine CFSR_WCELLS, CFSR_WCELLSIDX, CFSR_LCELLS, CFSR_LCELLSIDX
    ;
    undefine CFSR_mgrid
    ;
    undefine CFSR_longrid, CFSR_latgrid
    undefine CFSR_ref_lon, CFSR_ref_lat
    undefine CFSR_LON_MIN, CFSR_LON_MAX, CFSR_LON_MEAN
    undefine CFSR_LAT_MIN, CFSR_LAT_MAX, CFSR_LAT_MEAN
    ;
    undefine CFSR_dlongrid, CFSR_dlatgrid
    undefine CFSR_DLON_MIN, CFSR_DLON_MAX, CFSR_DLON_MEAN
    undefine CFSR_DLAT_MIN, CFSR_DLAT_MAX, CFSR_DLAT_MEAN
    ;
    undefine CFSR_xgrid, CFSR_ygrid
    undefine CFSR_X_MIN, CFSR_X_MAX, CFSR_X_MEAN
    undefine CFSR_Y_MIN, CFSR_Y_MAX, CFSR_Y_MEAN
    ;
    undefine CFSR_dxgrid, CFSR_dygrid
    undefine CFSR_DX_MIN, CFSR_DX_MAX, CFSR_DX_MEAN
    undefine CFSR_DY_MIN, CFSR_DY_MAX, CFSR_DY_MEAN
    ;
    undefine CFSR_MapStruct
    undefine CFSR_PROJ, CFSR_PROJ_NAM, CFSR_HDATUM, CFSR_VDATUM
    undefine CFSR_RADIUS, CFSR_SemiMIN, CFSR_SemiMAJ
    undefine CFSR_CENT_LON, CFSR_CENT_LAT, CFSR_STAND_LON
    undefine CFSR_TRUELAT1, CFSR_TRUELAT2
  endif

  if keyword_set(flow) then begin
    undefine, cfsr_times
    undefine, cfsr_hgt,      cfsr_hgt_fill,      cfsr_hgt_units,      cfsr_hgt_desc
    undefine, cfsr_psfc,     cfsr_psfc_fill,     cfsr_psfc_units,     cfsr_psfc_desc
    undefine, cfsr_u10,      cfsr_u10_fill,      cfsr_u10_units,      cfsr_u10_desc
    undefine, cfsr_v10,      cfsr_v10_fill,      cfsr_v10_units,      cfsr_v10_desc
    undefine, cfsr_hwave,    cfsr_hwave_fill,    cfsr_hwave_units,    cfsr_hwave_desc
    undefine, cfsr_pwave,    cfsr_pwave_fill,    cfsr_pwave_units,    cfsr_pwave_desc
    undefine, cfsr_lwavep,   cfsr_lwavep_fill,   cfsr_lwavep_units,   cfsr_lwavep_desc
    undefine, cfsr_cldfra,   cfsr_cldfra_fill,   cfsr_cldfra_units,   cfsr_cldfra_desc
    undefine, cfsr_albedo,   cfsr_albedo_fill,   cfsr_albedo_units,   cfsr_albedo_desc
    undefine, cfsr_rainc,    cfsr_rainc_fill,    cfsr_rainc_units,    cfsr_rainc_desc
    undefine, cfsr_rainnc,   cfsr_rainnc_fill,   cfsr_rainnc_units,   cfsr_rainnc_desc
    undefine, cfsr_tair,     cfsr_tair_fill,     cfsr_tair_units,     cfsr_tair_desc
    undefine, cfsr_tpot,     cfsr_tpot_fill,     cfsr_tpot_units,     cfsr_tpot_desc
    undefine, cfsr_sst,      cfsr_sst_fill,      cfsr_sst_units,      cfsr_sst_desc
    undefine, cfsr_sstsk,    cfsr_sstsk_fill,    cfsr_sstsk_units,    cfsr_sstsk_desc
    undefine, cfsr_tsk,      cfsr_tsk_fill,      cfsr_tsk_units,      cfsr_tsk_desc
    undefine, cfsr_q2,       cfsr_q2_fill,       cfsr_q2_units,       cfsr_q2_desc
    undefine, cfsr_emiss,    cfsr_emiss_fill,    cfsr_emiss_units,    cfsr_emiss_desc
    undefine, cfsr_grdflx,   cfsr_grdflx_fill,   cfsr_grdflx_units,   cfsr_grdflx_desc
    undefine, cfsr_acgrdflx, cfsr_acgrdflx_fill, cfsr_acgrdflx_units, cfsr_acgrdflx_desc
    undefine, cfsr_hfx,      cfsr_hfx_fill,      cfsr_hfx_units,      cfsr_hfx_desc
    undefine, cfsr_qfx,      cfsr_qfx_fill,      cfsr_qfx_units,      cfsr_qfx_desc
    undefine, cfsr_swdown,   cfsr_swdown_fill,   cfsr_swdown_units,   cfsr_swdown_desc
    undefine, cfsr_gsw,      cfsr_gsw_fill,      cfsr_gsw_units,      cfsr_gsw_desc
    undefine, cfsr_glw,      cfsr_glw_fill,      cfsr_glw_units,      cfsr_glw_desc
    undefine, cfsr_olr,      cfsr_olr_fill,      cfsr_olr_units,      cfsr_olr_desc
    undefine, cfsr_lh,       cfsr_lh_fill,       cfsr_lh_units,       cfsr_lh_desc
    undefine, cfsr_achfx,    cfsr_achfx_fill,    cfsr_achfx_units,    cfsr_achfx_desc
    undefine, cfsr_aclhf,    cfsr_aclhf_fill,    cfsr_aclhf_units,    cfsr_aclhf_desc
  endif

end
