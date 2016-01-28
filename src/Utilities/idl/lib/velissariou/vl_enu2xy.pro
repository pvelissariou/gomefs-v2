;+
; NAME:
;       VL_ENU2XY
;
; PURPOSE:
;       Convert from ENU cartesian coordinates to ECEF earth centered cartesian
;       coordinates
; EXPLANATION:
;       Converts from ENU cartesian (x, y, z) to ECEF earth centered cartesian
;       (x, y, z).
;
;
; CALLING SEQUENCE:
;       Result = VL_ENU2XY(xyz, [geoREF=, xyzREF=])
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
;             They are used to translate the origin [0, 0, 0] of the ENU system.          
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
FUNCTION VL_ENU2XY, xyz, geoREF = georef, xyzREF = xyzref

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

  xECEF = - sinLON * xyz[0, *] - $
            sinLAT * cosLON * xyz[1, *] + $
            cosLAT * cosLON * xyz[2, *]
  xECEF = xECEF[*] + xyz_ref[0]


  yECEF =   cosLON * xyz[0, *] - $
            sinLAT * sinLON * xyz[1, *] + $
            cosLAT * sinLON * xyz[2, *]
  yECEF = yECEF[*] + xyz_ref[1]


  zECEF =   cosLAT * xyz[1, *] + $
            sinLAT * xyz[2, *]
  zECEF = zECEF[*] + xyz_ref[2]


  idx = where(abs(xECEF) le 0.00001, icnt)
  if (icnt gt 0) then xECEF[idx] = 0.0

  idx = where(abs(yECEF) le 0.00001, icnt)
  if (icnt gt 0) then yECEF[idx] = 0.0

  idx = where(abs(zECEF) le 0.00001, icnt)
  if (icnt gt 0) then zECEF[idx] = 0.0

  return, [xECEF, yECEF, zECEF]

end
