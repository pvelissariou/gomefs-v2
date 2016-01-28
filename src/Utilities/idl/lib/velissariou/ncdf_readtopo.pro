Pro Ncdf_ReadTopo, fname
;+++
; NAME:
;	Ncdf_ReadTopo
; VERSION:
;	1.0
; PURPOSE:
;	To read a topographic grid data file and return grid parameters
;       and depths.
; CALLING SEQUENCE:
;	Ncdf_ReadTopo, fname
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
    if ((dim_idx = (where(strmatch(dim_names, 'IDIM', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisDIM = dim_names[dim_idx]
      ncdf_diminq, ncid, ncdf_dimid(ncid, thisDIM), tmp_str, IDIM
    endif else begin
      ncdf_close, ncid
      message, 'IDIM dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'JDIM', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisDIM = dim_names[dim_idx]
      ncdf_diminq, ncid, ncdf_dimid(ncid, thisDIM), tmp_str, JDIM
    endif else begin
      ncdf_close, ncid
      message, 'JDIM dimension is not defined in: ' + fname
    endelse

    ; ------------------------------
    ; Required variables
    if ((var_idx = (where(strmatch(var_names, 'X', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), longrid
    endif else begin
      ncdf_close, ncid
      message, 'X variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'Y', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), latgrid
    endif else begin
      ncdf_close, ncid
      message, 'Y variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'Z', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), dgrid
    endif else begin
      ncdf_close, ncid
      message, 'Z variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'MASK', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), mgrid
    endif else begin
      ncdf_close, ncid
      message, 'MASK variable is not defined in: ' + fname
    endelse

    ; ------------------------------
    ; Optional variables
    if ((var_idx = (where(strmatch(var_names, 'X1', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lon_ref
    endif

    if ((var_idx = (where(strmatch(var_names, 'Y1', /FOLD_CASE) eq 1))[0]) ge 0) then begin
      thisVAR = var_names[var_idx]
      ncdf_varget, ncid, ncdf_varid(ncid, thisVAR), lat_ref
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
  IPNTS  = long(IDIM)
  JPNTS  = long(JDIM)
  TCELLS = IPNTS * JPNTS

; ---------- calculate the "wet" and "land" points
  ; water points have a mask of 1
  chk_msk = ChkForMask(mgrid, 1, WCELLSIDX, WCELLS, $
                       COMPLEMENT = LCELLSIDX, NCOMPLEMENT = LCELLS)

; ---------- Get the depth/elevation range values
  DEPTH_MIN  = min(dgrid[WCELLSIDX], MAX = DEPTH_MAX, /ABSOLUTE, /NAN)
  DEPTH_MEAN = mean(dgrid[WCELLSIDX], /NAN)
  ELEV_MIN   = min(dgrid[LCELLSIDX], MAX = ELEV_MAX, /ABSOLUTE, /NAN)
  ELEV_MEAN  = mean(dgrid[LCELLSIDX], /NAN)

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

  xgrid = longrid & xgrid[*] = 0
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
end
