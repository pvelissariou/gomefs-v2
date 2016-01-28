Pro Ncdf_Wrf_ReadGrid, fname, $
                       WEIGHTED = weighted, $
                       CENTLON = centlon,   $
                       CENTLAT = centlat
;+++
; NAME:
;	Ncdf_Wrf_ReadGrid
; VERSION:
;	1.0
; PURPOSE:
;	To read a grid data file and return grid parameters
;       for the WRF atmospheric model.
; CALLING SEQUENCE:
;	Ncdf_Wrf_ReadGrid, fname
;	On input:
;	   fname - Full pathway name of the grid data file
;       WEIGHTED - Use this keyword to do a weighted computation for delta_lon
;                  delta_lat, delta_x and delta_y, instead of using:
;                  delta_lon = lon[i+1, j] - lon[i, j]
;	On output:
;	   WRF_IPNTS - Number of the X/longitude grid points
;	   WRF_JPNTS - Number of the Y/latitude grid points
;	 WRF_longrid - Longitude values of the grid points
;	 WRF_latgrid - Latitude values of the grid points
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created on February 18 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  COMMON WrfGridParams

  ; Error handling.
  On_Error, 2

  Undefine_Wrf_Params, /GRID

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
      WRF_IPNTS = long(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'west_east dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'west_east_stag') eq 1))[0]) ge 0) then begin
      ncdf_diminq, ncid, ncdf_dimid(ncid, 'west_east_stag'), tmp_str, thisVAL
      WRF_IPNTS_STAG = long(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'west_east_stag dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'south_north') eq 1))[0]) ge 0) then begin
      ncdf_diminq, ncid, ncdf_dimid(ncid, 'south_north'), tmp_str, thisVAL
      WRF_JPNTS = long(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'south_north dimension is not defined in: ' + fname
    endelse

    if ((dim_idx = (where(strmatch(dim_names, 'south_north_stag') eq 1))[0]) ge 0) then begin
      ncdf_diminq, ncid, ncdf_dimid(ncid, 'south_north_stag'), tmp_str, thisVAL
      WRF_JPNTS_STAG = long(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'south_north_stag dimension is not defined in: ' + fname
    endelse

    ; ------------------------------
    ; Required variables
    if ((var_idx = (where(strmatch(var_names, 'XLAT') eq 1))[0]) ge 0) then begin
      ncdf_varget, ncid, ncdf_varid(ncid, 'XLAT'), thisVAL
      if (size(thisVAL, /N_DIMENSIONS) eq 3) then thisVAL = reform(thisVAL[0, *, *])
      WRF_latgrid = temporary(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'XLAT variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'XLONG') eq 1))[0]) ge 0) then begin
      ncdf_varget, ncid, ncdf_varid(ncid, 'XLONG'), thisVAL
      if (size(thisVAL, /N_DIMENSIONS) eq 3) then thisVAL = reform(thisVAL[0, *, *])
      WRF_longrid = temporary(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'XLONG variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'XLAT_U') eq 1))[0]) ge 0) then begin
      ncdf_varget, ncid, ncdf_varid(ncid, 'XLAT_U'), thisVAL
      if (size(thisVAL, /N_DIMENSIONS) eq 3) then thisVAL = reform(thisVAL[0, *, *])
      WRF_latgrid_u = temporary(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'XLAT_U variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'XLONG_U') eq 1))[0]) ge 0) then begin
      ncdf_varget, ncid, ncdf_varid(ncid, 'XLONG_U'), thisVAL
      if (size(thisVAL, /N_DIMENSIONS) eq 3) then thisVAL = reform(thisVAL[0, *, *])
      WRF_longrid_u = temporary(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'XLONG_U variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'XLAT_V') eq 1))[0]) ge 0) then begin
      ncdf_varget, ncid, ncdf_varid(ncid, 'XLAT_V'), thisVAL
      if (size(thisVAL, /N_DIMENSIONS) eq 3) then thisVAL = reform(thisVAL[0, *, *])
      WRF_latgrid_v = temporary(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'XLAT_V variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'XLONG_V') eq 1))[0]) ge 0) then begin
      ncdf_varget, ncid, ncdf_varid(ncid, 'XLONG_V'), thisVAL
      if (size(thisVAL, /N_DIMENSIONS) eq 3) then thisVAL = reform(thisVAL[0, *, *])
      WRF_longrid_v = temporary(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'XLONG_V variable is not defined in: ' + fname
    endelse
    
    if ((var_idx = (where(strmatch(var_names, 'XLAND') eq 1))[0]) ge 0) then begin
      ncdf_varget, ncid, ncdf_varid(ncid, 'XLAND'),  XLAND
      if (size(XLAND, /N_DIMENSIONS) eq 3) then XLAND = reform(XLAND[0, *, *])
    endif else begin
      ncdf_close, ncid
      message, 'XLAND variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'LANDMASK') eq 1))[0]) ge 0) then begin
      ncdf_varget, ncid, ncdf_varid(ncid, 'LANDMASK'), thisVAL
      if (size(thisVAL, /N_DIMENSIONS) eq 3) then thisVAL = reform(thisVAL[0, *, *])
      WRF_mgrid = temporary(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'LANDMASK variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'SINALPHA') eq 1))[0]) ge 0) then begin
      ncdf_varget, ncid, ncdf_varid(ncid, 'SINALPHA'), thisVAL
      if (size(thisVAL, /N_DIMENSIONS) eq 3) then thisVAL = reform(thisVAL[0, *, *])
      WRF_SINALPHA = temporary(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'SINALPHA variable is not defined in: ' + fname
    endelse

    if ((var_idx = (where(strmatch(var_names, 'COSALPHA') eq 1))[0]) ge 0) then begin
      ncdf_varget, ncid, ncdf_varid(ncid, 'COSALPHA'), thisVAL
      if (size(thisVAL, /N_DIMENSIONS) eq 3) then thisVAL = reform(thisVAL[0, *, *])
      WRF_COSALPHA = temporary(thisVAL)
    endif else begin
      ncdf_close, ncid
      message, 'COSALPHA variable is not defined in: ' + fname
    endelse

    ; ------------------------------
    ; Global variables
    for i = 0L, (ncdf_inquire(ncid)).ngatts - 1 do begin
      thisVAR = strcompress(ncdf_attname(ncid, i, /GLOBAL), /REMOVE_ALL)
      thisINF  = ncdf_attinq(ncid, thisVAR, /GLOBAL)
      ncdf_attget, ncid, thisVAR, thisVAL, /GLOBAL
      if ((size(thisVAL, /TNAME) eq 'BYTE') and $
          (thisINF.datatype eq 'CHAR')) then begin
        thisVAL = string(thisVAL)
      endif

      case 1 of
        (strmatch(thisVAR, 'MAP_PROJ', /FOLD_CASE) eq 1): $
           begin
             MAP_PROJ = temporary(thisVAL)
             case MAP_PROJ of
               1: begin
                    WRF_PROJ = 'Lambert Conformal'
                    WRF_PROJ_NAM = 'Lambert Conformal'
                  end
               2: begin
                    WRF_PROJ = 'Polar Stereographic'
                    WRF_PROJ_NAM = 'Polar Stereographic'
                  end
               3: begin
                    WRF_PROJ = 'Mercator'
                    WRF_PROJ_NAM = 'Mercator'
                  end
               6: begin
                    WRF_PROJ = 'Cylindrical'
                    WRF_PROJ_NAM = 'latitude and longitude (including global)'
                  end
               else:
             endcase
           end
        (strmatch(thisVAR, 'CEN_LON', /FOLD_CASE) eq 1): $
           WRF_CENT_LON = temporary(thisVAL)
        (strmatch(thisVAR, 'CEN_LAT', /FOLD_CASE) eq 1): $
           WRF_CENT_LAT = temporary(thisVAL)
        (strmatch(thisVAR, 'TRUELAT1', /FOLD_CASE) eq 1): $
           WRF_TRUELAT1 = temporary(thisVAL)
        (strmatch(thisVAR, 'TRUELAT2', /FOLD_CASE) eq 1): $
           WRF_TRUELAT2 = temporary(thisVAL)
        (strmatch(thisVAR, 'STAND_LON', /FOLD_CASE) eq 1): $
           WRF_STAND_LON = temporary(thisVAL)
        else:
      endcase
    endfor
  ncdf_close, ncid

; ---------- Get the total grid points of the domain
  WRF_TCELLS = WRF_IPNTS * WRF_JPNTS

; ---------- determine the "wet" and "land" points
  ; water points have a mask of 0 in the WRF model
  chk_msk = ChkForMask(WRF_mgrid, 0, WRF_WCELLSIDX, WRF_WCELLS, $
                       COMPLEMENT = WRF_LCELLSIDX, NCOMPLEMENT = WRF_LCELLS)

  ; ---------- Set the projection variables
  WRF_PROJ     = (n_elements(WRF_PROJ) ne 0) $
                     ? WRF_PROJ $
                     : 'Mercator'
  WRF_PROJ_NAM = (n_elements(WRF_PROJ_NAM) ne 0) $
                     ? WRF_PROJ_NAM $
                     : 'Mercator'
  WRF_CENT_LON = (n_elements(WRF_CENT_LON) ne 0) $
                     ? WRF_CENT_LON $
                     : mean(WRF_longrid, /NAN)
  WRF_CENT_LAT = (n_elements(WRF_CENT_LAT) ne 0) $
                     ? WRF_CENT_LAT $
                     : mean(WRF_latgrid, /NAN)
  WRF_HDATUM = (n_elements(WRF_HDATUM) ne 0) $
                     ? WRF_HDATUM $
                     : 'Sphere'
  WRF_RADIUS = (n_elements(WRF_RADIUS) ne 0) $
                     ? WRF_RADIUS $
                     : 6370000.0d
  WRF_SemiMIN = (n_elements(WRF_SemiMIN) ne 0) $
                     ? WRF_SemiMIN $
                     : WRF_RADIUS
  WRF_SemiMAJ = (n_elements(WRF_SemiMAJ) ne 0) $
                     ? WRF_SemiMAJ $
                     : WRF_RADIUS


  thisCENT_LAT = (n_elements(centlat) ne 0) $
                     ? centlat $
                     : WRF_CENT_LAT
  thisCENT_LON = (n_elements(centlon) ne 0) $
                     ? centlon $
                     : WRF_CENT_LON

  WRF_MapStruct = VL_GetMapStruct(WRF_PROJ, $
                                  CENTER_LATITUDE     = thisCENT_LAT, $
                                  CENTER_LONGITUDE    = thisCENT_LON, $
                                  TRUE_SCALE_LATITUDE = thisCENT_LAT, $
                                  DATUM               = WRF_HDATUM,   $
                                  SEMIMAJOR_AXIS      = WRF_SemiMAJ, $
                                  SEMIMINOR_AXIS      = WRF_SemiMIN)

  WRF_xgrid = WRF_longrid & WRF_xgrid[*] = 0
  WRF_ygrid = WRF_xgrid

  tmp_arr = Map_Proj_Forward(reform(WRF_longrid[*]), reform(WRF_latgrid[*]), $
                             MAP_STRUCTURE = WRF_MapStruct)
  WRF_xgrid[*] = reform(tmp_arr[0, *])
  WRF_ygrid[*] = reform(tmp_arr[1, *])

  ; ---------- Get the "DELTA LON/LAT" and "DELTA X/Y" the values
  Get_DomainStats, WRF_longrid, /XDIR, WEIGHTED = weighted, $
                   DARR = WRF_dlongrid, $
                   MIN_VAL = WRF_LON_MIN, MAX_VAL = WRF_LON_MAX, $
                   AVE_VAL = WRF_LON_MEAN, $
                   DMIN_VAL = WRF_DLON_MIN, DMAX_VAL = WRF_DLON_MAX, $
                   DAVE_VAL = WRF_DLON_MEAN

  Get_DomainStats, WRF_latgrid, /YDIR, WEIGHTED = weighted, $
                   DARR = WRF_dlatgrid, $
                   MIN_VAL = WRF_LAT_MIN, MAX_VAL = WRF_LAT_MAX, $
                   AVE_VAL = WRF_LAT_MEAN, $
                   DMIN_VAL = WRF_DLAT_MIN, DMAX_VAL = WRF_DLAT_MAX, $
                   DAVE_VAL = WRF_DLAT_MEAN
  if (n_elements(WRF_xgrid) ne 0) then begin
    Get_DomainStats, WRF_xgrid, /XDIR, WEIGHTED = weighted,  $
                     DARR = WRF_dxgrid, $
                     MIN_VAL = WRF_X_MIN, MAX_VAL = WRF_X_MAX, $
                     AVE_VAL = WRF_X_MEAN, $
                     DMIN_VAL = WRF_DX_MIN, DMAX_VAL = WRF_DX_MAX, $
                     DAVE_VAL = WRF_DX_MEAN

    Get_DomainStats, WRF_ygrid, /YDIR, WEIGHTED = weighted, $
                     DARR = dygrid, $
                     MIN_VAL = WRF_Y_MIN, MAX_VAL = WRF_Y_MAX, $
                     AVE_VAL = WRF_Y_MEAN, $
                     DMIN_VAL = WRF_DY_MIN, DMAX_VAL = WRF_DY_MAX, $
                     DAVE_VAL = WRF_DY_MEAN
  endif
end
