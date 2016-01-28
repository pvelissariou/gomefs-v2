;+++
; NAME:
;	GetPlanet
; VERSION:
;	1.0
; PURPOSE:
;	To print the planet parameters
; CALLING SEQUENCE:
;	GetPlanet(planet)
;
; KEYWORD PARAMETERS:
;               GetNames : if set just return the names along with the relevant parameters
;                   Name : a named variable that holds the planet's name
;                     Km : output the parameters in km instead of the default m
;
; RETURNS:
;               The planet parameters: [a, b, f, e]
;                 where: a = semi major axis in m/km
;                        b = semi minor axis in m/km
;                        f = flattening coefficient, dimensionless
;                        e = eccentricity, dimensionless
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created February 16 2009 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

;================================================================================
FUNCTION GetPlanet, planet, GetNames = getnames, Name = name, Km = km

  on_error, 2

  TOL_VAL = 1.0D-6

  PLANET_DEFIN = [ 'Mercury', $
                   'Venus',   $
                   'Earth',   $
                   'Mars',    $
                   'Jupiter', $
                   'Saturn',  $
                   'Uranus',  $
                   'Neptune', $
                   'Pluto'    $
                 ]

  PLANET_MAJOR = [   2439700.0000D0, $  ; (in m) Mercury
                     6051800.0000D0, $  ; (in m) Venus
                     6378137.0000D0, $  ; (in m) Earth
                     3397620.0000D0, $  ; (in m) Mars
                    71492000.0000D0, $  ; (in m) Jupiter
                    60268000.0000D0, $  ; (in m) Saturn
                    25559000.0000D0, $  ; (in m) Uranus
                    24764000.0000D0, $  ; (in m) Neptune
                     1195000.0000D0  $  ; (in m) Pluto
                 ]

  PLANET_MINOR = [   2439700.0000D0, $  ; (in m) Mercury
                     6051800.0000D0, $  ; (in m) Venus
                     6356752.0000D0, $  ; (in m) Earth
                     3379384.5000D0, $  ; (in m) Mars
                    67136556.2000D0, $  ; (in m) Jupiter
                    54890768.6000D0, $  ; (in m) Saturn
                    24986135.4000D0, $  ; (in m) Uranus
                    24347655.1000D0, $  ; (in m) Neptune
                     1195000.0000D0  $  ; (in m) Pluto
                 ]

  nPLANET = n_elements(PLANET_DEFIN)

  ; check if input distances are in km and adjust accordingly
  unfc = 1.0D0
  unit = ' m'
  fmtstr = '(i3, 3x, a10, 2(3x, f14.4, a), 2(3x, f13.9))'
  km = keyword_set(km)
  if (km eq 1) then begin
    unfc = 1.0D0 / 1000.0D0
    unit = ' km'
    fmtstr = '(i3, 3x, a10, 2(3x, f12.4, a), 2(3x, f13.9))'
  endif

  getnames = keyword_set(getnames)
  if (getnames eq 1) then begin
    for i = 0, nPLANET - 1 do begin
      aa = unfc * double(PLANET_MAJOR[i])
      bb = unfc * double(PLANET_MINOR[i])
      ee2 = 1.0D0 - (bb / aa) ^ (2.0)
      ee = sqrt(ee2)
      ff = ee le TOL_VAL ? !VALUES.D_NAN : 1.0D0 / (1.0D0 - sqrt(1.0D0 - ee2))
      print, i, PLANET_DEFIN[i], aa, unit, bb, unit, ff, ee, $
             format = fmtstr
    endfor
    return, -1
  endif

  tname = size(planet, /TNAME)
  if ((tname eq 'INT')     or $
      (tname eq 'UINT')    or $
      (tname eq 'LONG')    or $
      (tname eq 'ULONG')   or $
      (tname eq 'LONG64')  or $
      (tname eq 'ULONG64') or $
      (tname eq 'FLOAT')   or $
      (tname eq 'DOUBLE')) then begin
     el_idx = fix(planet[0])
     if ((el_idx lt 0) or (el_idx gt nPLANET)) then el_idx = 2 ; default is Earth
  endif else begin
    el_idx = 2 ; default is Earth
    if (tname eq 'STRING') then begin 
      el_idx = (where(strlowcase(PLANET_DEFIN) eq strlowcase(planet)))[0]
      if (el_idx eq -1) then el_idx = 2 ; default is Earth
    endif
  endelse 

  aa  = unfc * double(PLANET_MAJOR[el_idx]) ; equatorial radius
  bb  = unfc * double(PLANET_MINOR[el_idx]) ; polar radius
  ee2 = 1.0D0 - (bb / aa) ^ (2.0)           ; eccentricity squared
  ee  = sqrt(ee2)                           ; eccentricity
  ff = ee le TOL_VAL ? !VALUES.D_NAN : 1.0D0 / (1.0D0 - sqrt(1.0D0 - ee2)) ; inverse flattening coefficient
  name = PLANET_DEFIN[el_idx]

  return, [aa, bb, ff, ee]

end
