;+
; NAME:
;       VL_XY2ENU
;
; PURPOSE:
;       Convert from earth centered cartesian coordinates to ENU cartesian coordinates
; EXPLANATION:
;       Converts from earth centered cartesian (x, y, z) to ENU cartesian
;       (x, y, z).
;
;
; CALLING SEQUENCE:
;       Result = VL_XY2ENU(xyz, [geoREF=, xyzREF=])
;
; INPUT:
;       xyz = a 3-element array of cartesian [x, y, z],
;                or an array [3, n] of n such coordinates.
;
;
; KEYWORD PARAMETERS:
;             geoREF : the latitude and longitude of a reference point,
;               use: geoREF = [lat, lon]
;             xyzREF : the corresponding to geoREF earth centered cartesian
;                      coordinates
;               use: xyzREF = [x, y, z]
;             None or both geoREF and xyzREF need to be specified.
;             They set the origin [0, 0, 0] of the ENU system.          
;
; OUTPUT:
;      a 3-element array of ENU cartesian coordinates [x, y, z],
;        or an array [3,n] of n such coordinates, double precision.
;
; COMMON BLOCKS:
;       None
;
; RESTRICTIONS:
;
;       None
;-

;================================================================================
FUNCTION VL_XY2ENU, xyz, geoREF = georef, xyzREF = xyzref

  on_error, 2

  ; Check the input parameters
  refFLG = 0
  refFLG = (n_elements(georef) ne 0) ? refFLG + 1 : refFLG
  refFLG = (n_elements(xyzref) ne 0) ? refFLG + 1 : refFLG

  if ( refFLG eq 0 ) then begin
    lat_ref = 0.0d
    lon_ref = 0.0d
    xyz_ref = [0.0d, 0.0d, 0.0d]
  endif else begin
    if ( refFLG ne 2 ) then begin
      message, $
         'ERROR - values for all parameters "georef" and "xyzref" must be specified'
    endif else begin
      sz_geo = size(georef, /DIMENSIONS)
      if sz_geo[0] ne 2 then message, $
         'ERROR - 2 coordinates (lat, lon) must be specified for "georef"'
         
      sz_xyz = size(xyzref, /DIMENSIONS)
      if sz_xyz[0] ne 3 then message, $
         'ERROR - 3 coordinates (x, y, z) must be specified for "xyzref"'

      lat_ref = georef[0]
      lon_ref = georef[1]
      xyz_ref = xyzref
    endelse
  endelse

  sz_xyz = size(xyz, /DIMENSIONS)
  if sz_xyz[0] ne 3 then message, $
     'ERROR - 3 coordinates (x, y, z) must be specified for xyz'


  ; Start the calculations
  lonRAD = !DTOR * lon_ref
  latRAD = !DTOR * lat_ref
  cosLON = cos(lonRAD)
  sinLON = sin(lonRAD)
  cosLAT = cos(latRAD)
  sinLAT = sin(latRAD)

  xENU = - sinLON * (xyz[0, *] - xyz_ref[0]) + $
           cosLON * (xyz[1, *] - xyz_ref[1])

  yENU = - sinLAT * cosLON * (xyz[0, *] - xyz_ref[0]) - $
           sinLAT * sinLON * (xyz[1, *] - xyz_ref[1]) + $
           cosLAT * (xyz[2, *] - xyz_ref[2])

  zENU =   cosLAT * cosLON * (xyz[0, *] - xyz_ref[0]) + $
           cosLAT * sinLON * (xyz[1, *] - xyz_ref[1]) + $
           sinLAT * (xyz[2, *] - xyz_ref[2])

  xENU = ZeroFloatFix(xENU)
  yENU = ZeroFloatFix(yENU)
  zENU = ZeroFloatFix(zENU)

  return, [xENU, yENU, zENU]

end
