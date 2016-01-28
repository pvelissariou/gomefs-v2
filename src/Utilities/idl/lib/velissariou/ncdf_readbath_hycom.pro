Pro Ncdf_ReadBath_Hycom, fname
;+++
; NAME:
;	Ncdf_ReadBath_Hycom
; VERSION:
;	1.0
; PURPOSE:
;	To read a bathymetric grid data file and return grid parameters
;       and depths.
; CALLING SEQUENCE:
;	Ncdf_ReadBath_Hycom, fname
;	On input:
;	   fname - Full pathway name of the bathymetry/grid data file
;     MAP_STRUCT - The map structure obtained by calling VL_GetMapStruct
;                  If this parameter is not present, then the xgrid/ygrid
;                  arrays are not computed
;	On output:
;	   IPNTS - Number of the X/longitude grid points
;	   JPNTS - Number of the Y/latitude grid points
;	 longrid - Longitude values of the grid points
;	 latgrid - Latitude values of the grid points
;	   dgrid - Depth values of the grid points
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created : April 22 2011 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;	Modified: Wed Jul 09 2014 by Panagiotis Velissariou (pvelissariou@fsu.edu)
;+++

  Compile_Opt IDL2

  COMMON BathParams

  ; Error handling.
  On_Error, 2

  Undefine_Hycom_Params, /BATH, /ELLIPSOID

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
    ; ----- Required dimensions
    ; -----
    dnames = [ 'Y', 'Latitude', 'lat' ]
    dim_idx = Ncdf_GetDims(ncid, dnames, JDIM)
    if (dim_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(dnames, ' ', /SINGLE) + ']'
      err_str = 'none of the requested dimensions(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; -----
    dnames = [ 'X', 'Longitude', 'lon' ]
    dim_idx = Ncdf_GetDims(ncid, dnames, IDIM)
    if (dim_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(dnames, ' ', /SINGLE) + ']'
      err_str = 'none of the requested dimensions(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; ----- Required variables
    ; -----
    vnames = [ 'Latitude', 'lat' ]
    var_idx = Ncdf_GetData(ncid, vnames, latgrid)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; -----
    vnames = [ 'Longitude', 'lon' ]
    var_idx = Ncdf_GetData(ncid, vnames, longrid)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif
    longrid = ((longrid + 180) MOD 360) - 180

    if ( (size(longrid, /N_DIMENSIONS) eq 1) and $
         (size(latgrid, /N_DIMENSIONS) eq 1) ) then begin
      tmp_lon = make_array(IDIM, JDIM, TYPE = size(longrid, /TYPE), VALUE = 0)
      tmp_lat = tmp_lon
      for icnt = 0L, JDIM - 1 do tmp_lon[*, icnt] = longrid[*]
      for icnt = 0L, IDIM - 1 do tmp_lat[icnt, *] = latgrid[*]
      longrid = tmp_lon
      latgrid = tmp_lat
    endif

    ; -----
    vnames = [ 'Depth', 'bathymetry', 'topo' ]
    var_idx = Ncdf_GetData(ncid, vnames, dgrid, FILL_VAL = dgrid_fill)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; -----
    vnames = [ 'Mask' ]
    var_idx = Ncdf_GetData(ncid, vnames, mgrid)
    if (var_idx lt 0) then begin
      if (n_elements(dgrid_fill) ne 0) then begin
        chk_msk = ChkForMask(dgrid, dgrid_fill, LCELLSIDX, LCELLS, $
                       COMPLEMENT = WCELLSIDX, NCOMPLEMENT = WCELLS)
        mgrid = make_array(size(dgrid, /DIMENSIONS), /INTEGER, VALUE = 0)
        mgrid[WCELLSIDX] = 1
      endif else begin
        ncdf_close, ncid
        err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
        err_str = 'none of the variable(s) ' + err_str + ' found in: '
        message, err_str + fname
      endelse
    endif

    ; ----- Optional variables
    void = Ncdf_GetData(ncid, 'Bbox_idx', BBOXIDX)
    void = Ncdf_GetData(ncid, 'Bbox_geo', BBOXGEO)

    var_idx = Ncdf_GetData(ncid, 'plat', plat)
    if (var_idx ge 0) then $
      PLAT_MIN = min(plat, MAX = PLAT_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'plon', plon)
    if (var_idx ge 0) then $
      PLON_MIN = min(plon, MAX = PLON_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'qlat', qlat)
    if (var_idx ge 0) then $
      QLAT_MIN = min(qlat, MAX = QLAT_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'qlon', qlon)
    if (var_idx ge 0) then $
      QLON_MIN = min(qlon, MAX = QLON_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'ulat', ulat)
    if (var_idx ge 0) then $
      ULAT_MIN = min(ulat, MAX = ULAT_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'ulon', ulon)
    if (var_idx ge 0) then $
      ULON_MIN = min(ulon, MAX = ULON_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'vlat', vlat)
    if (var_idx ge 0) then $
      VLAT_MIN = min(vlat, MAX = VLAT_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'vlon', vlon)
    if (var_idx ge 0) then $
      VLON_MIN = min(vlon, MAX = VLON_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'pscx', pscx)
    if (var_idx ge 0) then $
      PSCX_MIN = min(pscx, MAX = PSCX_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'pscy', pscy)
    if (var_idx ge 0) then $
      PSCY_MIN = min(pscy, MAX = PSCY_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'qscx', qscx)
    if (var_idx ge 0) then $
      QSCX_MIN = min(qscx, MAX = QSCX_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'qscy', qscy)
    if (var_idx ge 0) then $
      QSCY_MIN = min(qscy, MAX = QSCY_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'uscx', uscx)
    if (var_idx ge 0) then $
      USCX_MIN = min(uscx, MAX = USCX_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'uscy', uscy)
    if (var_idx ge 0) then $
      USCY_MIN = min(uscy, MAX = USCY_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'vscx', vscx)
    if (var_idx ge 0) then $
      VSCX_MIN = min(vscx, MAX = VSCX_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'vscy', vscy)
    if (var_idx ge 0) then $
      VSCY_MIN = min(vscy, MAX = VSCY_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'cori', cori)
    if (var_idx ge 0) then $
      CORI_MIN = min(cori, MAX = CORI_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'pang', pang)
    if (var_idx ge 0) then $
      PANG_MIN = min(pang, MAX = PANG_MAX, /NAN)

    var_idx = Ncdf_GetData(ncid, 'pasp', pasp)
    if (var_idx ge 0) then $
      PASP_MIN = min(pasp, MAX = PASP_MAX, /NAN)

    void = Ncdf_GetData(ncid, 'lon_ref', lon_ref)
    void = Ncdf_GetData(ncid, 'lat_ref', lat_ref)
  ncdf_close, ncid

; ---------- Get the dimensions of the domain
  IPNTS = long(IDIM)
  JPNTS = long(JDIM)
  TCELLS = IPNTS * JPNTS

; ---------- determine the "wet" and "land" points
  ; water points have a mask of 1
  chk_msk = ChkForMask(mgrid, 1, WCELLSIDX, WCELLS, $
                       COMPLEMENT = LCELLSIDX, NCOMPLEMENT = LCELLS)

; ---------- Get the depth range values
  dgrid[LCELLSIDX] = 0
  DEPTH_MIN  = min(dgrid[WCELLSIDX], MAX = DEPTH_MAX, /NAN)
  DEPTH_MEAN = mean(dgrid[WCELLSIDX], /NAN)

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
  BATH_HDATUM = (n_elements(BATH_HDATUM) ne 0) $
                     ? BATH_HDATUM $
                     : 'Sphere'

  BATH_MapStruct = VL_GetMapStruct(BATH_PROJ, $
                                   CENTER_LATITUDE     = BATH_CLAT, $
                                   CENTER_LONGITUDE    = BATH_CLON, $
                                   TRUE_SCALE_LATITUDE = BATH_TLAT, $
                                   DATUM               = BATH_HDATUM,   $
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
  if (n_elements(xgrid) ne 0) then begin
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
  endif

; ---------- Reference longitudes/latitudes (WGS 84 ellipsoid)
  if ((n_elements(lon_ref) eq 0) or (n_elements(lat_ref) eq 0)) then begin
    VL_Sphere2WGS, longrid, latgrid, $
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
