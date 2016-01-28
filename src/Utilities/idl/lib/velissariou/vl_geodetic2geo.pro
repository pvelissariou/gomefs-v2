;+
; NAME:
;       VL_GEODETIC2GEO
;
; PURPOSE:
;       Convert from geodetic (or planetodetic) to geographic coordinates
; EXPLANATION:
;       Converts from geodetic (latitude, longitude, altitude) to geographic
;       (latitude, longitude, altitude).  In geographic coordinates, the 
;       Earth is assumed a perfect sphere with a radius equal to its equatorial 
;       radius. The geodetic (or ellipsoidal) coordinate system takes into 
;       account the Earth's oblateness.
;
;       Geographic and geodetic longitudes are identical.
;       Geodetic latitude is the angle between local zenith and the equatorial 
;       plane.   Geographic and geodetic altitudes are both the closest distance
;       between the satellite and the ground.
;
;       The PLANET keyword allows a similar transformation for the other 
;       planets  (planetodetic to planetographic coordinates). 
;
;       The EQUATORIAL_RADIUS and POLAR_RADIUS keywords allow the 
;       transformation for any ellipsoid.
;
;       Latitudes and longitudes are expressed in degrees, altitudes in m.
;
;       REF: Stephen P.  Keeler and Yves Nievergelt, "Computing geodetic
;       coordinates", SIAM Rev. Vol. 40, No. 2, pp. 300-309, June 1998
;       Planetary constants from "Allen's Astrophysical Quantities", 
;       Fourth Ed., (2000)
;
; CALLING SEQUENCE:
;       gcoord = vl_geodetic2geo(ecoord, [ PLANET= ] )
;
; INPUT:
;       ecoord = a 3-element array of geodetic [latitude,longitude,altitude],
;                or an array [3,n] of n such coordinates.
;
; OPTIONAL KEYWORD INPUT:
;       PLANET = keyword specifying planet (default is Earth).   The planet
;                may be specified either as an integer (1-9) or as one of the
;                (case-independent) strings 'mercury','venus','earth','mars',
;                'jupiter','saturn','uranus','neptune', or 'pluto'
;
;       EQUATORIAL_RADIUS : Self-explanatory. In m. If not set, PLANET's value
;                is used.   Numeric scalar
;       POLAR_RADIUS : Self-explanatory. In m. If not set, PLANET's value is 
;                 used.   Numeric scalar
;
; OUTPUT:
;       a 3-element array of geographic [latitude,longitude,altitude], or an
;         array [3,n] of n such coordinates, double precision
;
;       The geographic and geodetic longitudes will be identical.
; COMMON BLOCKS:
;       None
;
; EXAMPLES:
;
;       IDL> geod=[90,0,0]  ; North pole, altitude 0., in geodetic coordinates
;       IDL> geo=vl_geodetic2geo(geod)
;       IDL> PRINT,geo
;       90.000000       0.0000000      -21.385000
;
;       As above, but the equivalent planetographic coordinates for Mars
;       IDL> geod=vl_geodetic2geo(geod,PLANET='Mars'); 
;       IDL> PRINT,geod
;       90.000000       0.0000000      -18.235500
;
; MODIFICATION HISTORY:
;       Written by Pascal Saint-Hilaire (shilaire@astro.phys.ethz.ch),
;                  May 2002
;
;       Generalized for all solar system planets by Robert L. Marcialis
;               (umpire@lpl.arizona.edu), May 2002
;
;       Modified 2002/05/18, PSH: added keywords EQUATORIAL_RADIUS and 
;                POLAR_RADIUS
;
;-
;===================================================================================
FUNCTION VL_Geodetic2Geo,               $
           ecoord,                      $
           PLANET = planet,             $
           EQUAT_RADIUS = equat_radius, $
           POLAR_RADIUS = polar_radius, $
           KM = km

  on_error, 2

  ; --------------------------------------------------
  ; Check the input parameters
  sz_ecoord = size(ecoord,/DIMEN)
  if sz_ecoord[0] ne 3 then message, $
     'ERROR - 3 coordinates (latitude, longitude, altitude) must be specified'

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

  elat = DEG2RAD * double(ecoord[0, *])
  elon = DEG2RAD * double(ecoord[1, *])
  ealt = double(ecoord[2, *]) / unfc ; convert in meters if in km

  ee2 = 1.0D0 - (Rp / Re) ^ (2.0)
  ee  = sqrt(ee2)
  beta = sqrt(1.0D0 - (ee * sin(elat))^2)
  r = (Re/beta + ealt)*cos(elat)
  z = (Re*(1-ee2)/beta + ealt)*sin(elat)

  glat = atan(z, r)
  glon = elon
  galt = sqrt(r^2 + z^2) - Re

  glat = RAD2DEG * glat
  glon = RAD2DEG * glon
  galt = galt * unfc ; convert back to km if requested

  return, [glat, glon, galt]

end
