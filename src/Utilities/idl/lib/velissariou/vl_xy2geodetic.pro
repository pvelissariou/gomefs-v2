;+
; NAME:
;       VL_XY2GEODETIC
;
; PURPOSE:
;       Convert from cartesian coordinates to geodetic coordinates
; EXPLANATION:
;       Converts from cartesian (x, y, height) to geodetic
;       (latitude, longitude, altitude).
;
;       The PLANET keyword allows a similar transformation for the other 
;       planets  (planetographic to planetodetic coordinates). 
;
;       The EQUATORIAL_RADIUS and POLAR_RADIUS keywords allow the 
;       transformation for any ellipsoid.
;
;       Latitudes and longitudes are expressed in degrees, altitudes/heights in km.
;
;
; CALLING SEQUENCE:
;       ecoord=vl_xy2geodetic(xyz,[ PLANET=,EQUATORIAL_RADIUS=, POLAR_RADIUS=])
;
; INPUT:
;       xyz = a 3-element array of geographic [latitude,longitude,altitude],
;                or an array [3,n] of n such coordinates.
;
;
; OPTIONAL KEYWORD INPUT:
;       PLANET = keyword specifying planet (default is Earth).   The planet
;                may be specified either as an integer (1-9) or as one of the
;                (case-independent) strings 'mercury','venus','earth','mars',
;                'jupiter','saturn','uranus','neptune', or 'pluto'
;               
;       EQUATORIAL_RADIUS : Self-explanatory. In km. If not set, PLANET's 
;                value is used.
;       POLAR_RADIUS : Self-explanatory. In km. If not set, PLANET's value is 
;                used.
;
; OUTPUT:
;      a 3-element array of geodetic coordinates [latitude,longitude,altitude],
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
FUNCTION VL_XY2Geodetic,                $
           xyz,                         $
           PLANET = planet,             $
           EQUAT_RADIUS = equat_radius, $
           POLAR_RADIUS = polar_radius, $
           KM = km

  on_error, 2

  ; --------------------------------------------------
  ; Check the input parameters
  sz_xyz = size(xyz, /DIMENSIONS)
  if sz_xyz[0] ne 3 then message, $
     'ERROR - 3 coordinates (x, y, z) must be specified'

  ; set the converion factor between km and m
  unfc = keyword_set(km) eq 0 ? 1.0D0 : 1.0D0 / 1000.0D0

  equatRAD = (n_elements(equat_radius) ne 0) ? 1 : 0
  polarRAD = (n_elements(polar_radius) ne 0) ? 1 : 0
  radFLG = equatRAD + polarRAD

  case radFLG of
    ; use default equatoral/polar semi-axes for the given planet
    0: $
      begin
        params = GetPlanet(planet, KM = km) ; default is Earth
        Re = double(params[0]) ; equatorial radius
        Rp = double(params[1]) ; polar radius
      end
    ; planet is considered a sphere here
    1: $
      begin
        if (equatRAD eq 1) then begin
          Re = double(equat_radius[0])
          Rp = double(equat_radius[0])
        endif else begin
          Re = double(polar_radius[0])
          Rp = double(polar_radius[0])
        endelse
      end
    2: $
      begin
        Re = double(equat_radius[0])
        Rp = double(polar_radius[0])
        if (Rp gt Re) then begin
          message, $
            'ERROR - semi-minor axis (polar radius) > semi-major axis (equatoral radius)'
        endif
      end
    else:
  endcase

  Re = Re / unfc ; convert in meters if in km
  Rp = Rp / unfc ; convert in meters if in km
  ; --------------------------------------------------


  DEG2RAD = !DTOR
  RAD2DEG = 1.0D0 / DEG2RAD

  ee2 = 1.0D0 - (Rp / Re) ^ (2.0)
  ee  = ee2 / (1.0D0 - ee2)

  x = double(xyz[0, *])
  y = double(xyz[1, *])
  z = double(xyz[2, *])
  r = sqrt(x * x + y * y)
  q = atan((z * Re) / (r * Rp))

  cosQ = cos(q)
  sinQ = sin(q)

  var1 = z + ee * Rp * sinQ * sinQ * sinQ
  var2 = r - ee2 * Re * cosQ * cosQ * cosQ
  glat = atan(var1 / var2)
  glon = atan(y, x)

  cosLAT = cos(glat)
  sinLAT = sin(glat)

  v = Re / sqrt(1.0 - ee2 * sinLAT * sinLAT)
  galt = (r / cosLAT) - v

  glat = RAD2DEG * glat
  glon = RAD2DEG * glon
  galt = galt * unfc ; convert back to km if requested

  return, [glat, glon, galt]
end
