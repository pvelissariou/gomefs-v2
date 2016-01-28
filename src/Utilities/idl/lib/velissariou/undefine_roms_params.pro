Pro Undefine_Roms_Params, BATH = bath, FLOW = flow, ELLIPSOID = ellipsoid
;+++
; NAME:
;	Undefine_Roms_Params
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
    ;
    undefine, cori, anggrid
    undefine, CORI_MIN, CORI_MAX, CORI_MEAN
    ; ----- ROMS related
    undefine, xi_rho, eta_rho, xi_psi, eta_psi, xi_u, eta_u, xi_v, eta_v
    undefine, xl, el, pm, pn, dndx, dmde
    undefine, x_rho, y_rho, x_psi, y_psi, x_u, y_u, x_v, y_v
    undefine, lon_rho, lat_rho, lon_psi, lat_psi
    undefine, lon_u, lat_u, lon_v, lat_v
    undefine, mask_rho, mask_psi, mask_u, mask_v, area_rho
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
    ; ----- ROMS related
    undefine, Vtransform, Vstretching, theta_s, theta_b, Tcline, hc
    undefine, n_s_rho, s_rho, Cs_r, zdeps_rho
    undefine, n_s_w, s_w, Cs_w, zdeps_w
    undefine, ocean_time
  endif

end
