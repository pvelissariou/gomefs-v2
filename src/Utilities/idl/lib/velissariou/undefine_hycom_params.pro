Pro Undefine_Hycom_Params, BATH = bath, FLOW = flow, ELLIPSOID = ellipsoid
;+++
; NAME:
;	Undefine_Hycom_Params
; VERSION:
;	1.0
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created April 22 2011 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  COMMON BathParams
  COMMON FlowParams

  ; Error handling.
  On_Error, 2

  if keyword_set(ellipsoid) then begin
    undefine, BATH_MapStruct
    undefine, BATH_PROJ, BATH_PROJ_NAM, BATH_HDATUM, BATH_VDATUM
    undefine, BATH_RADIUS, BATH_SemiMIN, BATH_SemiMAJ
    undefine, BATH_CLON, BATH_CLAT, BATH_TLAT
  endif

  if keyword_set(bath) then begin
    undefine, GridX0, GridY0, GridX1, GridY1, GridXSZ, GridYSZ
    undefine, IPNTS, JPNTS, TCELLS, WCELLS, WCELLSIDX, LCELLS, LCELLSIDX
    ;
    undefine, dgrid, mgrid
    undefine, DEPTH_MIN, DEPTH_MAX, DEPTH_MEAN
    undefine, ELEV_MIN, ELEV_MAX, ELEV_MEAN
    ;
    undefine, longrid, latgrid
    undefine, LON_MIN, LON_MEAN, LON_MAX
    undefine, LAT_MIN, LAT_MEAN, LAT_MAX
    ;
    undefine, dlongrid, dlatgrid
    undefine, DLON_MIN, DLON_MEAN, DLON_MAX
    undefine, DLAT_MIN, DLAT_MEAN, DLAT_MAX
    ;
    undefine, xgrid, ygrid
    undefine, X_MIN, X_MEAN, X_MAX, Y_MIN, Y_MEAN, Y_MAX
    ;
    undefine, dxgrid, dygrid
    undefine, DX_MIN, DX_MAX, DY_MIN, DY_MAX
    undefine, DX_MEAN, DY_MEAN
    ;
    undefine, lon_ref, lat_ref
    undefine, REF_LON_MIN, REF_LON_MEAN, REF_LON_MAX
    undefine, REF_LAT_MIN, REF_LAT_MEAN, REF_LAT_MAX
    ;
    undefine, dlon_ref, dlat_ref
    undefine, REF_DLON_MIN, REF_DLON_MEAN, REF_DLON_MAX
    undefine, REF_DLAT_MIN, REF_DLAT_MEAN, REF_DLAT_MAX
    ;
    undefine, RFAC
    ; ----- HYCOM related
    undefine, BBOXIDX, BBOXGEO
    undefine, IDIM, JDIM
    ;
    undefine, plon, plat, pscx, pscy
    undefine, PLON_MIN, PLON_MAX, PLAT_MIN, PLAT_MAX, PLON_IDX, PLAT_IDX
    undefine, PSCX_MIN, PSCX_MAX, PSCY_MIN, PSCY_MAX, PSCX_IDX, PSCY_IDX
    ;
    undefine, qlon, qlat, qscx, qscy
    undefine, QLON_MIN, QLON_MAX, QLAT_MIN, QLAT_MAX, QLON_IDX, QLAT_IDX
    undefine, QSCX_MIN, QSCX_MAX, QSCY_MIN, QSCY_MAX, QSCX_IDX, QSCY_IDX
    ;
    undefine, ulon, ulat, uscx, uscy
    undefine, ULON_MIN, ULON_MAX, ULAT_MIN, ULAT_MAX, ULON_IDX, ULAT_IDX
    undefine, USCX_MIN, USCX_MAX, USCY_MIN, USCY_MAX, USCX_IDX, USCY_IDX
    ;
    undefine, vlon, vlat, vscx, vscy
    undefine, VLON_MIN, VLON_MAX, VLAT_MIN, VLAT_MAX, VLON_IDX, VLAT_IDX
    undefine, VSCX_MIN, VSCX_MAX, VSCY_MIN, VSCY_MAX, VSCX_IDX, VSCY_IDX
    ;
    undefine, cori, anggrid
    undefine, CORI_MIN, CORI_MAX, CORI_MEAN, CORI_IDX
    ;
    undefine, pang
    undefine, PANG_MIN, PANG_MAX, PANG_IDX
    ;
    undefine, pasp
    undefine, PASP_MIN, PASP_MAX, PASP_IDX
  endif

  if keyword_set(flow) then begin
    undefine, RefTimeStr
    undefine, ssh, ssh_fill, ssh_units
    undefine, vel_units
    undefine, uvel, uvel_fill, ubar, ubar_fill
    undefine, vvel, vvel_fill, vbar, vbar_fill
    undefine, wvel, wvel_fill
    undefine, temp, temp_fill, temp_units
    undefine, salt, salt_fill, salt_units
    undefine, uwind, uwind_fill, uwind_units
    undefine, vwind, vwind_fill, vwind_units
    ; ----- HYCOM related
    undefine, n_zdeps, zdeps
    undefine, MT
  endif

end
