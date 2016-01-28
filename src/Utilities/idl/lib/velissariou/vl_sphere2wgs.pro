;+
; NAME:
;       VL_SPHERE2WGS
;
; PURPOSE:
;       Convert from SPHERE lat/lon coordinates to WGS84 lat/lon coordinates
;
; CALLING SEQUENCE:
;       VL_Sphere2WGS, lons, lats,[ LATS_OUT=,LONS_OUT=, RADIUS=]
;
; INPUT:
;       lons = the array of the longitude values
;       lats = the array of the latitude values
;     RADIUS = a keyword variable used to define another radius for earth
;              than the default HYCOM radius
;
; OPTIONAL KEYWORD INPUT:
;     LONS_OUT = a named variable that holds the converted longitude values
;     LATS_OUT = a named variable that holds the converted latitude values
;
; OUTPUT:
;      the converted lat/lon values
;
; COMMON BLOCKS:
;       None
;
; RESTRICTIONS:
;
;       None
;-

;================================================================================
PRO VL_Sphere2WGS,         $
      lons, lats,          $
      LONS_OUT = lons_out, $
      LATS_OUT = lats_out, $
      RADIUS   = radius

  on_error, 2

  ; --------------------------------------------------
  ; Check the input parameters
  if (n_elements(lons) eq 0) then message, "must pass the <lons> argument."
  dim_lons = size(lons, /DIMENSIONS)
  if (where([7, 8, 10, 11] eq size(lons, /type)) ge 0) then $
    message, "strings, structures, ... are not valid values for <lons>."

  if (n_elements(lats) eq 0) then message, "must pass the <lats> argument."
  dim_lats = size(lats, /DIMENSIONS)
  if (where([7, 8, 10, 11] eq size(lats, /type)) ge 0) then $
    message, "strings, structures, ... are not valid values for <lats>."

  if (array_equal(dim_lons, dim_lats) ne 1) then begin
    message, "<lons, lats> must have the same dimensions."
  endif

  ; Sphere parameters
  if (n_elements(radius) ne 0) then begin
    SemiMAJ  = double(radius[0])
  endif else begin
    SemiMAJ  = 6371001.0D ; Hycom radius
  endelse
  SemiMIN  = SemiMAJ

  ; WGS84 ellipsoid parameters
  wgsSemiMAJ  = 6378137.0D
  wgsSemiMIN  = 6356752.31414D

  ; calculate the cartesian coordinates for the current domain
  ; referenced to the SPHERE ellipsoid
  ; these will be used to calculate the values of lon/lat
  ; in reference to the WGS84 ellipsoid
  ; This only works with geocentric, un-rotated ellipsoids.
  sphXYZ = vl_geodetic2xy([ transpose(lats[*]), transpose(lons[*]) ], $
            EQUAT_RADIUS = SemiMAJ, $
            POLAR_RADIUS = SemiMIN)
  geovals = vl_xy2geodetic(sphXYZ, $
            EQUAT_RADIUS = wgsSemiMAJ, $
            POLAR_RADIUS = wgsSemiMIN)

  lons_out = lons & lons_out[*] = 0
  lats_out = lons_out
  lons_out[*] = transpose(geovals[1, *])
  lats_out[*] = transpose(geovals[0, *])

end
