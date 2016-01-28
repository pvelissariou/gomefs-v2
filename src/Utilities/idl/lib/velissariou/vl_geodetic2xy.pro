;+
; NAME:
;       VL_GEODETIC2XY
;
; PURPOSE:
;       Convert from geodetic coordinates to cartesian coordinates
; EXPLANATION:
;       Converts from geodetic (latitude, longitude, altitude) to cartesian
;       (x, y, height).
;
;       The PLANET keyword allows a similar transformation for the other 
;       planets  (planetographic to planetodetic coordinates). 
;
;       The EQUATORIAL_RADIUS and POLAR_RADIUS keywords allow the 
;       transformation for any ellipsoid.
;
;       Latitudes and longitudes are expressed in degrees, altitudes in km.
;
;
; CALLING SEQUENCE:
;       ecoord=vl_geodetic2xy(gcoord,[ PLANET=,EQUATORIAL_RADIUS=, POLAR_RADIUS=])
;
; INPUT:
;       gcoord = a 3-element array of geographic [latitude,longitude,altitude],
;                or an array [3,n] of n such coordinates.
;
;
; OPTIONAL KEYWORD INPUT:
;       PLANET = keyword specifying planet (default is Earth).   The planet
;                may be specified either as an integer (1-9) or as one of the
;                (case-independent) strings 'mercury','venus','earth','mars',
;                'jupiter','saturn','uranus','neptune', or 'pluto'
;               
;       EQUATORIAL_RADIUS : Self-explanatory. In m/km. If not set, PLANET's 
;                value is used.
;       POLAR_RADIUS : Self-explanatory. In m/km. If not set, PLANET's value is 
;                used.
;
; OUTPUT:
;      a 3-element array of cartesian coordinates [x,y,z],
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
FUNCTION VL_Geodetic2XY,                $
           gcoord,                      $
           PLANET = planet,             $
           EQUAT_RADIUS = equat_radius, $
           POLAR_RADIUS = polar_radius, $
           KM = km

  on_error, 2

  ; --------------------------------------------------
  ; Check the input parameters
  sz_gcoord = size(gcoord,/DIMEN)
  if sz_gcoord[0] lt 2 then begin
    print, $
     'ERROR - at least (latitude, longitude) must be specified'
    message, $
      'gcoord: (latitude, longitude, altitude) must be specified'
  endif

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

  glat = DEG2RAD * double(gcoord[0, *])
  glon = DEG2RAD * double(gcoord[1, *])
  if (sz_gcoord[0] lt 3) then begin
    galt = glon & galt[*] = 0.0D0
  endif else begin
    galt = double(gcoord[2, *])
  endelse
  galt = galt / unfc ; convert in meters if in km

  ee2 = 1.0D0 - (Rp / Re) ^ (2.0)
  ee  = ee2 / (1.0D0 - ee2)

  cosLON = cos(glon)
  sinLON = sin(glon)
  cosLAT = cos(glat)
  sinLAT = sin(glat)

  v = Re / sqrt(1.0 - ee2 * sinLAT * sinLAT)
  x = (v + galt) * cosLAT * cosLON
  y = (v + galt) * cosLAT * sinLON
  z = ((1.0 - ee2) * v + galt) * sinLAT

  x = x * unfc ; convert back to km if requested
  y = y * unfc ; convert back to km if requested
  z = z * unfc ; convert back to km if requested
  
  return, [x, y, z]
end
