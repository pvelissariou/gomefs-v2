Function GetEllipsoid, ellipsoid, GetNames = getnames, Name = name, Km = km
;+++
; NAME:
;	GetEllipsoid
; VERSION:
;	1.0
; PURPOSE:
;	To print the ellipsoid parameters
; CALLING SEQUENCE:
;	GetEllipsoid(ellipsoid)
;
; KEYWORD PARAMETERS:
;               GetNames : if set just return the names along with the relevant parameters
;                   Name : a named variable that holds the planet's name
;                     Km : output the parameters in km instead of the default m
;
; RETURNS:
;               The ellipsoid parameters: [a, b, f, e]
;                 where: a = semi major axis in m/km
;                        b = semi minor axis in m/km
;                        f = flattening coefficient, dimensionless
;                        e = eccentricity, dimensionless
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created February 16 2009 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

  on_error, 2

  TOL_VAL = 1.0D-6

  ELLIPS_DEFIN = [ 'Earth',                 $
                   'T/P',                   $
                   'Jason',                 $
                   'Airy',                  $
                   'Australian National',   $
                   'Bessel 1841',           $
                   'Bessel 1841 (Nambia)',  $
                   'Clarke 1866',           $
                   'Clarke 1880',           $
                   'Everest',               $
                   'Fischer 1960',          $
                   'Fischer 1968',          $
                   'GRS67',                 $
                   'GRS80',                 $
                   'Helmert 1906',          $
                   'Hough',                 $
                   'International',         $
                   'International 1967',    $
                   'Krassovsky',            $
                   'Mercury 1960',          $
                   'Modified Airy',         $
                   'Modified Everest',      $
                   'Modified Fischer 1960', $
                   'Modified Mercury 1968', $
                   'South American 1969',   $
                   'Walbeck',               $
                   'WGS60',                 $
                   'WGS66',                 $
                   'WGS72',                 $
                   'WGS84',                 $
                   'Southeast Asia',        $
                   'ITRF',                  $
                   'ITRF96'                 $
                 ]

  ELLIPS_MAJOR = [ 6378137.0000D0, $  ; (in m) Earth
                   6378136.3000D0, $  ; (in m) T/P
                   6378136.3000D0, $  ; (in m) Jason
                   6377563.3960D0, $  ; (in m) Airy
                   6378160.0000D0, $  ; (in m) Australian National
                   6377397.1550D0, $  ; (in m) Bessel 1841
                   6377483.8650D0, $  ; (in m) Bessel 1841 (Nambia)
                   6378206.4000D0, $  ; (in m) Clarke 1866
                   6378249.1450D0, $  ; (in m) Clarke 1880
                   6377276.3452D0, $  ; (in m) Everest
                   6378166.0000D0, $  ; (in m) Fischer 1960
                   6378150.0000D0, $  ; (in m) Fischer 1968
                   6378160.0000D0, $  ; (in m) GRS67
                   6378137.0000D0, $  ; (in m) GRS80
                   6378200.0000D0, $  ; (in m) Helmert 1906
                   6378270.0000D0, $  ; (in m) Hough
                   6378388.0000D0, $  ; (in m) International
                   6378157.5000D0, $  ; (in m) International 1967
                   6378245.0000D0, $  ; (in m) Krassovsky
                   6378166.0000D0, $  ; (in m) Mercury 1960
                   6377340.1890D0, $  ; (in m) Modified Airy
                   6377304.0630D0, $  ; (in m) Modified Everest
                   6378155.0000D0, $  ; (in m) Modified Fischer 1960
                   6378150.0000D0, $  ; (in m) Modified Mercury 1968
                   6378160.0000D0, $  ; (in m) South American 1969
                   6378137.0000D0, $  ; (in m) Walbeck
                   6378165.0000D0, $  ; (in m) WGS60
                   6378145.0000D0, $  ; (in m) WGS66
                   6378135.0000D0, $  ; (in m) WGS72
                   6378137.0000D0, $  ; (in m) WGS84
                   6378155.0000D0, $  ; (in m) Southeast Asia
                   6378136.4900D0, $  ; (in m) ITRF
                   6378136.4900D0  $  ; (in m) ITRF96
                 ]

  ELLIPS_INVFLAT = [ 298.252840000D0, $  ; (dimensionless) Earth
                     298.257000000D0, $  ; (dimensionless) T/P
                     298.257000000D0, $  ; (dimensionless) Jason
                     299.324964600D0, $  ; (dimensionless) Airy
                     298.250000000D0, $  ; (dimensionless) Australian National
                     299.152812800D0, $  ; (dimensionless) Bessel 1841
                     299.152812800D0, $  ; (dimensionless) Bessel 1841 (Nambia)
                     294.978698200D0, $  ; (dimensionless) Clarke 1866
                     293.465000000D0, $  ; (dimensionless) Clarke 1880
                     300.801700000D0, $  ; (dimensionless) Everest
                     298.300000000D0, $  ; (dimensionless) Fischer 1960
                     298.300000000D0, $  ; (dimensionless) Fischer 1968
                     298.247167427D0, $  ; (dimensionless) GRS67
                     298.257222101D0, $  ; (dimensionless) GRS80
                     298.300000000D0, $  ; (dimensionless) Helmert 1906
                     297.000000000D0, $  ; (dimensionless) Hough
                     297.000000000D0, $  ; (dimensionless) International
                     298.249600000D0, $  ; (dimensionless) International 1967
                     298.300000000D0, $  ; (dimensionless) Krassovsky
                     298.300000000D0, $  ; (dimensionless) Mercury 1960
                     299.324964600D0, $  ; (dimensionless) Modified Airy
                     300.801700000D0, $  ; (dimensionless) Modified Everest
                     298.300000000D0, $  ; (dimensionless) Modified Fischer 1960
                     298.300000000D0, $  ; (dimensionless) Modified Mercury 1968
                     298.250000000D0, $  ; (dimensionless) South American 1969
                     298.257223560D0, $  ; (dimensionless) Walbeck
                     298.300000000D0, $  ; (dimensionless) WGS60
                     298.250000000D0, $  ; (dimensionless) WGS66
                     298.260000000D0, $  ; (dimensionless) WGS72
                     298.257223563D0, $  ; (dimensionless) WGS84
                     298.300000000D0, $  ; (dimensionless) Southeast Asia
                     298.256450000D0, $  ; (dimensionless) ITRF
                     298.256450000D0  $  ; (dimensionless) ITRF96
                   ]

  nELLIPSOID = n_elements(ELLIPS_DEFIN)

  ; check if input distances are in km and adjust accordingly
  unfc = 1.0D0
  unit = ' m'
  fmtstr = '(i3, 3x, a22, 2(3x, f12.4, a), 2(3x, f13.9))'
  km = keyword_set(km)
  if (km eq 1) then begin
    unfc = 1.0D0 / 1000.0D0
    unit = ' km'
    fmtstr = '(i3, 3x, a22, 2(3x, f10.4, a), 2(3x, f13.9))'
  endif

  getnames = keyword_set(getnames)
  if (getnames eq 1) then begin
    for i = 0, nELLIPSOID - 1 do begin
      aa = unfc * double(ELLIPS_MAJOR[i])
      ff = double(ELLIPS_INVFLAT[i])
      bb = aa * (1.0D0 - 1.0D0 / ff)
      ee2 = 1.0D0 - (bb / aa) ^ (2.0)
      ee = sqrt(ee2)
      print, i, ELLIPS_DEFIN[i], aa, unit, bb, unit, ff, ee, $
             format = fmtstr
    endfor
    return, -1
  endif

  tname = size(ellipsoid, /TNAME)
  if ((tname eq 'INT')     or $
      (tname eq 'UINT')    or $
      (tname eq 'LONG')    or $
      (tname eq 'ULONG')   or $
      (tname eq 'LONG64')  or $
      (tname eq 'ULONG64') or $
      (tname eq 'FLOAT')   or $
      (tname eq 'DOUBLE')) then begin
     el_idx = fix(ellipsoid[0])
     if ((el_idx lt 0) or (el_idx gt nELLIPSOID)) then begin
       message, 'invalid ellipsoid requested'
     endif
  endif else begin
    if (tname eq 'STRING') then begin 
      el_idx = (where(strlowcase(ELLIPS_DEFIN) eq strlowcase(ellipsoid)))[0]
      if (el_idx eq -1) then $
        message, 'invalid ellipsoid requested'
    endif else begin
        message, 'invalid ellipsoid requested'
    endelse
  endelse

  aa = unfc * double(ELLIPS_MAJOR[el_idx])
  ff = double(ELLIPS_INVFLAT[el_idx])
  bb = aa * (1.0D0 - 1.0D0 / ff)
  ee2 = 1.0D0 - (bb / aa) ^ (2.0)
  ee = sqrt(ee2)
  name = ELLIPS_DEFIN[el_idx]

  return, [aa, bb, ff, ee]
end
