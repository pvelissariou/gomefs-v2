;+
; NAME:
;       VL_GEO2GEODETIC
;
; PURPOSE:
;       Convert from geographic/planetographic to geodetic coordinates
; EXPLANATION:
;       Converts from geographic (latitude, longitude, altitude) to geodetic
;       (latitude, longitude, altitude).  In geographic coordinates, the 
;           Earth is assumed a perfect sphere with a radius equal to its equatorial 
;               radius. The geodetic (or ellipsoidal) coordinate system takes into 
;               account the Earth's oblateness.
;
;       Geographic and geodetic longitudes are identical.
;               Geodetic latitude is the angle between local zenith and the equatorial plane.
;               Geographic and geodetic altitudes are both the closest distance between 
;               the satellite and the ground.
;
;       The PLANET keyword allows a similar transformation for the other 
;       planets  (planetographic to planetodetic coordinates). 
;
;       The EQUAT_RADIUS and POLAR_RADIUS keywords allow the 
;       transformation for any ellipsoid.
;
;       Latitudes and longitudes are expressed in degrees, altitudes in m.
;
;       REF: Stephen P.  Keeler and Yves Nievergelt, "Computing geodetic
;       coordinates", SIAM Rev. Vol. 40, No. 2, pp. 300-309, June 1998
;
;       Planetary constants from "Allen's Astrophysical Quantities", 
;       Fourth Ed., (2000)
;
; CALLING SEQUENCE:
;       ecoord=vl_geo2geodetic(gcoord,[ PLANET=,EQUAT_RADIUS=, POLAR_RADIUS=])
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
;       EQUAT_RADIUS : Self-explanatory. In m. If not set, PLANET's 
;                value is used.
;       POLAR_RADIUS : Self-explanatory. In m. If not set, PLANET's value is 
;                used.
;
; OUTPUT:
;      a 3-element array of geodetic/planetodetic [latitude,longitude,altitude],
;        or an array [3,n] of n such coordinates, double precision.
;
; COMMON BLOCKS:
;       None
;
; RESTRICTIONS:
;
;       Whereas the conversion from geodetic to geographic coordinates is given
;       by an exact, analytical formula, the conversion from geographic to
;       geodetic isn't. Approximative iterations (as used here) exist, but tend 
;       to become less good with increasing eccentricity and altitude.
;       The formula used in this routine should give correct results within
;       six digits for all spatial locations, for an ellipsoid (planet) with
;       an eccentricity similar to or less than Earth's.
;       More accurate results can be obtained via calculus, needing a 
;       non-determined amount of iterations.
;       In any case, 
;          IDL> PRINT,vl_geodetic2geo(geo2geodetic(gcoord)) - gcoord
;       is a pretty good way to evaluate the accuracy of vl_geo2geodetic.pro.
;
; EXAMPLES:
;
;       Locate the geographic North pole, altitude 0., in geodetic coordinates
;       IDL> geo=[90.d0,0.d0,0.d0]  
;       IDL> geod=vl_geo2geodetic(geo); convert to equivalent geodetic coordinates
;       IDL> PRINT,geod
;       90.000000       0.0000000       21.385000
;
;       As above, but for the case of Mars
;       IDL> geod=vl_geo2geodetic(geo,PLANET='Mars')
;       IDL> PRINT,geod
;       90.000000       0.0000000       18.235500
;
; MODIFICATION HISTORY:
;       Written by Pascal Saint-Hilaire (shilaire@astro.phys.ethz.ch), May 2002
;       Generalized for all solar system planets by Robert L. Marcialis
;               (umpire@lpl.arizona.edu), May 2002
;       Modified 2002/05/18, PSH: added keywords EQUAT_RADIUS and 
;               POLAR_RADIUS
;-

;================================================================================
FUNCTION VL_Geo2Geodetic,               $
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
  ee  = sqrt(ee2)

  cosLON = cos(glon)
  sinLON = sin(glon)
  cosLAT = cos(glat)
  sinLAT = sin(glat)

  x = (Re + galt) * cosLAT * cosLON
  y = (Re + galt) * cosLAT * sinLON
  z = (Re + galt) * sinLAT
  r = sqrt(x * x + y * y)

  s  = sqrt(r^2 + z ^2) * (1 - Re * sqrt((1-ee2)/((1-ee2)*r^2 + z^2)))
  t0 = 1 + s * sqrt(1- (ee*z)^2 / (r^2 + z^2)) / Re
  dzeta1 = z * t0
  xi1 = r * (t0 - ee2)
  rho1 = sqrt(xi1^2 + dzeta1^2)
  c1 = xi1 / rho1
  s1 = dzeta1 / rho1
  b1 = Re / sqrt(1- (ee*s1)^2)
  u1 = b1 * c1
  w1 = b1 * s1 * (1- ee2)

  ealt = sqrt((r - u1)^2 + (z - w1)^2)
  elat = atan(s1, c1)
  elon = glon

  elat = RAD2DEG * elat
  elon = RAD2DEG * elon
  elat = elat * unfc ; convert back to km if requested

  return, [elat, elon, ealt]

end
