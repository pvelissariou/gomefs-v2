Pro Ncdf_ReadBath_Roms, fname
;+++
; NAME:
;	Ncdf_ReadBath_Roms
; VERSION:
;	1.0
; PURPOSE:
;	To read a bathymetric grid data file and return grid parameters
;       and depths.
; CALLING SEQUENCE:
;	Ncdf_ReadBath_Roms, fname
;	On input:
;	   fname - Full pathway name of the bathymetry/grid data file
;	On output:
;	   IPNTS - Number of the X/longitude grid points
;	   JPNTS - Number of the Y/latitude grid points
;	 longrid - Longitude values of the grid points
;	 latgrid - Latitude values of the grid points
;	   dgrid - Depth values of the grid points
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created:  Oct 24 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  COMMON BathParams

  ; Error handling.
  On_Error, 2

  Undefine_Roms_Params, /BATH, /ELLIPSOID

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
    if ((dim_idx = (where(strmatch(dim_names, 'xi_rho', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisDIM = dim_names[dim_idx]
      ncdf_diminq, ncid, ncdf_dimid(ncid, thisDIM), tmp_str, xi_rho
    endif else begin
      ncdf_close, ncid
      message, 'XI_RHO dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'xi_psi', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisDIM = dim_names[dim_idx]
      ncdf_diminq, ncid, ncdf_dimid(ncid, thisDIM), tmp_str, xi_psi
    endif else begin
      ncdf_close, ncid
      message, 'XI_PSI dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'xi_u', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisDIM = dim_names[dim_idx]
      ncdf_diminq, ncid, ncdf_dimid(ncid, thisDIM), tmp_str, xi_u
    endif else begin
      ncdf_close, ncid
      message, 'XI_U dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'xi_v', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisDIM = dim_names[dim_idx]
      ncdf_diminq, ncid, ncdf_dimid(ncid, thisDIM), tmp_str, xi_v
    endif else begin
      ncdf_close, ncid
      message, 'XI_V dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'eta_rho', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisDIM = dim_names[dim_idx]
      ncdf_diminq, ncid, ncdf_dimid(ncid, thisDIM), tmp_str, eta_rho
    endif else begin
      ncdf_close, ncid
      message, 'ETA_RHO dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'eta_psi', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisDIM = dim_names[dim_idx]
      ncdf_diminq, ncid, ncdf_dimid(ncid, thisDIM), tmp_str, eta_psi
    endif else begin
      ncdf_close, ncid
      message, 'ETA_PSI dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'eta_u', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisDIM = dim_names[dim_idx]
      ncdf_diminq, ncid, ncdf_dimid(ncid, thisDIM), tmp_str, eta_u
    endif else begin
      ncdf_close, ncid
      message, 'ETA_U dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'eta_v', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisDIM = dim_names[dim_idx]
      ncdf_diminq, ncid, ncdf_dimid(ncid, thisDIM), tmp_str, eta_v
    endif else begin
      ncdf_close, ncid
      message, 'ETA_V dimension is not defined in: ' + fname
    endelse

    ; ------------------------------
    ; Required variables
    if ((var_idx = (where(strmatch(var_names, 'lon_rho', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lon_rho
      longrid = lon_rho
    endif else begin
      ncdf_close, ncid
      message, 'LON_RHO variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'lat_rho', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lat_rho
      latgrid = lat_rho
    endif else begin
      ncdf_close, ncid
      message, 'LAT_RHO variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'h', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), h
      dgrid = h
    endif else begin
      ncdf_close, ncid
      message, 'H variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'mask_rho', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), mask_rho
      mgrid = mask_rho
    endif else begin
      ncdf_close, ncid
      message, 'MASK_RHO variable is not defined in: ' + fname
    endelse

    ; ------------------------------
    ; Optional variables
    if ((var_idx = (where(strmatch(var_names, 'xl', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), xl
    endif

    if ((var_idx = (where(strmatch(var_names, 'el', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), el
    endif

    if ((var_idx = (where(strmatch(var_names, 'pm', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), pm
    endif

    if ((var_idx = (where(strmatch(var_names, 'pn', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), pn
    endif

    if ((var_idx = (where(strmatch(var_names, 'dmde', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), dmde
    endif

    if ((var_idx = (where(strmatch(var_names, 'dndx', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), dndx
    endif

    if ((var_idx = (where(strmatch(var_names, 'x_rho', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), x_rho
    endif

    if ((var_idx = (where(strmatch(var_names, 'y_rho', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), y_rho
    endif

    if ((var_idx = (where(strmatch(var_names, 'x_psi', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), x_psi
    endif

    if ((var_idx = (where(strmatch(var_names, 'y_psi', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), y_psi
    endif

    if ((var_idx = (where(strmatch(var_names, 'x_u', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), x_u
    endif

    if ((var_idx = (where(strmatch(var_names, 'y_u', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), y_u
    endif

    if ((var_idx = (where(strmatch(var_names, 'x_v', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), x_v
    endif

    if ((var_idx = (where(strmatch(var_names, 'y_v', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), y_v
    endif

    if ((var_idx = (where(strmatch(var_names, 'lon_ref', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lon_ref
    endif

    if ((var_idx = (where(strmatch(var_names, 'lat_ref', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lat_ref
    endif

    if ((var_idx = (where(strmatch(var_names, 'lon_psi', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lon_psi
    endif

    if ((var_idx = (where(strmatch(var_names, 'lat_psi', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lat_psi
    endif

    if ((var_idx = (where(strmatch(var_names, 'lon_u', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lon_u
    endif

    if ((var_idx = (where(strmatch(var_names, 'lat_u', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lat_u
    endif

    if ((var_idx = (where(strmatch(var_names, 'lon_v', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lon_v
    endif

    if ((var_idx = (where(strmatch(var_names, 'lat_v', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lat_v
    endif

    if ((var_idx = (where(strmatch(var_names, 'f', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), cori
    endif

    if ((var_idx = (where(strmatch(var_names, 'angle', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), anggrid
    endif

    if ((var_idx = (where(strmatch(var_names, 'mask_psi', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), mask_psi
    endif

    if ((var_idx = (where(strmatch(var_names, 'mask_u', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), mask_u
    endif

    if ((var_idx = (where(strmatch(var_names, 'mask_v', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), mask_v
    endif

    if ((var_idx = (where(strmatch(var_names, 'area_rho', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), area_rho
    endif

    if ((var_idx = (where(strmatch(var_names, 'rx', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), RFAC
      RFAC = RFAC[0]
    endif

    ; ------------------------------
    ; Global variables
    read_vars = [ 'projection', 'projection_name', $
                  'horizontal_datum', 'vertical_datum', $
                  'radius', 'semi_minor_axis', 'semi_major_axis', $
                  'center_longitude', 'center_latitude', $
                  'true_scale_latitude', $
                  'ref_projection', 'ref_projection_name', $
                  'ref_horizontal_datum', 'ref_vertical_datum', $
                  'ref_radius', 'ref_semi_minor_axis', 'ref_semi_major_axis' ]
    for i = 0L, n_elements(read_vars) - 1 do begin
      thisVAR = strcompress(read_vars[i], /REMOVE_ALL)

      found = Ncdf_GetGlobal(ncid, thisVAR, thisVAL)

      case 1 of
        (strmatch(thisVAR, 'PROJECTION', /FOLD_CASE) eq 1): $
           BATH_PROJ = temporary(thisVAL)
        (strmatch(thisVAR, 'PROJECTION_NAME', /FOLD_CASE) eq 1): $
           BATH_PROJ_NAM = temporary(thisVAL)
        (strmatch(thisVAR, 'HORIZONTAL_DATUM', /FOLD_CASE) eq 1): $
           BATH_HDATUM = temporary(thisVAL)
        (strmatch(thisVAR, 'VERTICAL_DATUM', /FOLD_CASE) eq 1): $
           BATH_VDATUM = temporary(thisVAL)
        (strmatch(thisVAR, 'RADIUS', /FOLD_CASE) eq 1): $
           BATH_RADIUS = temporary(thisVAL)
        (strmatch(thisVAR, 'SEMI_MINOR_AXIS', /FOLD_CASE) eq 1): $
           BATH_SemiMIN = temporary(thisVAL)
        (strmatch(thisVAR, 'SEMI_MAJOR_AXIS', /FOLD_CASE) eq 1): $
           BATH_SemiMAJ = temporary(thisVAL)
        (strmatch(thisVAR, 'CENTER_LONGITUDE', /FOLD_CASE) eq 1): $
           BATH_CLON = temporary(thisVAL)
        (strmatch(thisVAR, 'CENTER_LATITUDE', /FOLD_CASE) eq 1): $
           BATH_CLAT = temporary(thisVAL)
        (strmatch(thisVAR, 'TRUE_SCALE_LATITUDE', /FOLD_CASE) eq 1): $
           BATH_TLAT = temporary(thisVAL)
        (strmatch(thisVAR, 'REF_PROJECTION', /FOLD_CASE) eq 1): $
           REF_PROJ = temporary(thisVAL)
        (strmatch(thisVAR, 'REF_PROJECTION_NAME', /FOLD_CASE) eq 1): $
           REF_PROJ_NAM = temporary(thisVAL)
        (strmatch(thisVAR, 'REF_HORIZONTAL_DATUM', /FOLD_CASE) eq 1): $
           REF_HDATUM = temporary(thisVAL)
        (strmatch(thisVAR, 'REF_VERTICAL_DATUM', /FOLD_CASE) eq 1): $
           REF_VDATUM = temporary(thisVAL)
        (strmatch(thisVAR, 'REF_RADIUS', /FOLD_CASE) eq 1): $
           REF_RADIUS = temporary(thisVAL)
        (strmatch(thisVAR, 'REF_SEMI_MINOR_AXIS', /FOLD_CASE) eq 1): $
           REF_SemiMIN = temporary(thisVAL)
        (strmatch(thisVAR, 'REF_SEMI_MAJOR_AXIS', /FOLD_CASE) eq 1): $
           REF_SemiMAJ = temporary(thisVAL)
        else:
      endcase
    endfor
  ncdf_close, ncid

; ---------- Get the dimensions of the domain
  IPNTS  = long(xi_rho)
  JPNTS  = long(eta_rho)
  TCELLS = IPNTS * JPNTS

; ---------- determine the "wet" and "land" points
  ; water points have a mask of 1
  chk_msk = ChkForMask(mgrid, 1, WCELLSIDX, WCELLS, $
                       COMPLEMENT = LCELLSIDX, NCOMPLEMENT = LCELLS)

; ---------- Get the depth range values
  DEPTH_MIN  = min(dgrid[WCELLSIDX], MAX = DEPTH_MAX, /NAN)
  DEPTH_MEAN = mean(dgrid[WCELLSIDX], /NAN)
  ELEV_MIN   = min(dgrid[LCELLSIDX], MAX = ELEV_MAX, /NAN)
  ELEV_MEAN  = mean(dgrid[LCELLSIDX], /NAN)

; ---------- Get the coriolis range values
  CORI_MIN  = min(cori, MAX = CORI_MAX, /NAN)
  CORI_MEAN = mean(cori, /NAN)

  ; ---------- Set the "X/Y coordinates"
  BATH_PROJ     = (n_elements(BATH_PROJ) ne 0) $
                     ? BATH_PROJ $
                     : 'Mercator'
  BATH_CLON = (n_elements(BATH_CLON) ne 0) $
                     ? BATH_CLON $
                     : mean(longrid, /NAN)
  BATH_CLAT = (n_elements(BATH_CLAT) ne 0) $
                     ? BATH_CLAT $
                     : mean(latgrid, /NAN)
  BATH_TLAT = (n_elements(BATH_TLAT) ne 0) $
                     ? BATH_TLAT $
                     : BATH_CLAT

  BATH_MapStruct = VL_GetMapStruct(BATH_PROJ, $
                                   CENTER_LATITUDE     = BATH_CLAT,    $
                                   CENTER_LONGITUDE    = BATH_CLON,    $
                                   TRUE_SCALE_LATITUDE = BATH_TLAT,    $
                                   SEMIMAJOR_AXIS      = BATH_SemiMAJ, $
                                   SEMIMINOR_AXIS      = BATH_SemiMIN)

  xgrid = longrid & xgrid[*] = 0.0
  ygrid = xgrid

  tmp_arr = Map_Proj_Forward(reform(longrid[*]), reform(latgrid[*]), $
                             MAP_STRUCTURE = BATH_MapStruct)
  xgrid[*] = reform(tmp_arr[0, *])
  ygrid[*] = reform(tmp_arr[1, *])

  ; ---------- Get the "DELTA LON/LAT" and "DELTA X/Y" the values
  Get_DomainStats, longrid, /XDIR, $
                   DARR = dlongrid, $
                   MIN_VAL = LON_MIN, MAX_VAL = LON_MAX, $
                   AVE_VAL = LON_MEAN, $
                   DMIN_VAL = DLON_MIN, DMAX_VAL = DLON_MAX, $
                   DAVE_VAL = DLON_MEAN

  Get_DomainStats, latgrid, /YDIR, $
                   DARR = dlatgrid, $
                   MIN_VAL = LAT_MIN, MAX_VAL = LAT_MAX, $
                   AVE_VAL = LAT_MEAN, $
                   DMIN_VAL = DLAT_MIN, DMAX_VAL = DLAT_MAX, $
                   DAVE_VAL = DLAT_MEAN
  Get_DomainStats, xgrid, /XDIR,  $
                   DARR = dxgrid, $
                   MIN_VAL = X_MIN, MAX_VAL = X_MAX, $
                   AVE_VAL = X_MEAN, $
                   DMIN_VAL = DX_MIN, DMAX_VAL = DX_MAX, $
                   DAVE_VAL = DX_MEAN

  Get_DomainStats, ygrid, /YDIR, $
                   DARR = dygrid, $
                   MIN_VAL = Y_MIN, MAX_VAL = Y_MAX, $
                   AVE_VAL = Y_MEAN, $
                   DMIN_VAL = DY_MIN, DMAX_VAL = DY_MAX, $
                   DAVE_VAL = DY_MEAN

; ---------- Reference longitudes/latitudes (WGS 84 ellipsoid)
  if ((n_elements(lon_ref) eq 0) or (n_elements(lat_ref) eq 0)) then begin
    VL_Hycom2WGS, longrid, latgrid, $
                  LONS_OUT = lon_ref, LATS_OUT = lat_ref
  endif

  Get_DomainStats, lon_ref, /XDIR, $
                   DARR = dlon_ref, $
                   MIN_VAL  = REF_LON_MIN, MAX_VAL = REF_LON_MAX, $
                   AVE_VAL  = REF_LON_MEAN, $
                   DMIN_VAL = REF_DLON_MIN, DMAX_VAL = REF_DLON_MAX, $
                   DAVE_VAL = REF_DLON_MEAN

  Get_DomainStats, lat_ref, /YDIR, $
                   DARR = dlat_ref, $
                   MIN_VAL  = REF_LAT_MIN, MAX_VAL = REF_LAT_MAX, $
                   AVE_VAL  = REF_LAT_MEAN, $
                   DMIN_VAL = REF_DLAT_MIN, DMAX_VAL = REF_DLAT_MAX, $
                   DAVE_VAL = REF_DLAT_MEAN
end
