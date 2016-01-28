;+
; NAME:
;       VL_XY2ITRF
;
; PURPOSE:
;       Convert from cartesian coordinates to ITRF cartesian coordinates
; EXPLANATION:
;       Converts from cartesian (x, y, z) to ITRF cartesian
;       (x, y, z).
;
;
; CALLING SEQUENCE:
;       Result = VL_XY2ITRF(xyz, [ITRF=, Year=, KM=])
;
; INPUT:
;       xyz = a 3-element array of cartesian [x, y, z],
;                or an array [3, n] of n such coordinates.
;
;
; KEYWORD PARAMETERS:
;               ITRF : if set just return the names along with the relevant parameters
;               Year : the year for which the transformation is required
;                      instead of the default (1997)
;                 Km : input/output parameters are in km instead of the default m
;
; OUTPUT:
;      a 3-element array of ITRF cartesian coordinates [x, y, z],
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
FUNCTION VL_XY2ITRF, xyz, ITRF = itrf, Year = year, KM = km

  on_error, 2

  sz_xyz = size(xyz, /DIMENSIONS)
  if sz_xyz[0] ne 3 then message, $
     'ERROR - 3 coordinates (x, y, z) must be specified'

  thisYEAR = 1997.0D0
  if (n_elements(year) ne 0) then begin
    tname = size(year, /TNAME)
    if ((tname eq 'INT')     or $
        (tname eq 'UINT')    or $
        (tname eq 'LONG')    or $
        (tname eq 'ULONG')   or $
        (tname eq 'LONG64')  or $
        (tname eq 'ULONG64') or $
        (tname eq 'FLOAT')   or $
        (tname eq 'DOUBLE')) then thisYEAR = double(year[0])
  endif

  ; check if input coordinates are in km and adjust accordingly
  unfc = keyword_set(km) eq 0 ? 1.0D0 : 1000.0D0
  
  ITRF_DEFIN = [ 'ITRF',   $
                 'ITRF93', $
                 'ITRF94', $
                 'ITRF96', $
                 'ITRF97', $
                 'ITRF00'  $
               ]

  nITRF = n_elements(ITRF_DEFIN)

  tname = size(itrf, /TNAME)
  if ((tname eq 'INT')     or $
      (tname eq 'UINT')    or $
      (tname eq 'LONG')    or $
      (tname eq 'ULONG')   or $
      (tname eq 'LONG64')  or $
      (tname eq 'ULONG64') or $
      (tname eq 'FLOAT')   or $
      (tname eq 'DOUBLE')) then begin
     use_itrf = fix(itrf[0])
     if ((use_itrf lt 0) or (use_itrf gt nITRF)) then use_itrf = 0 ; default is ITRF
  endif else begin
    use_itrf = 0 ; default is ITRF
    if (tname eq 'STRING') then begin 
      use_itrf = (where(strlowcase(ITRF_DEFIN) eq strlowcase(itrf)))[0]
      if (use_itrf eq -1) then use_itrf = 0 ; default is ITRF
    endif
  endelse 

  ; Initialize the ITRF data
  ; using the values from http://www.ngs.noaa.gov/CORS/metadata1/
  itrf_struct = { tx:!VALUES.D_NAN,  ty:!VALUES.D_NAN,  tz:!VALUES.D_NAN,  $
                 tpx:!VALUES.D_NAN, tpy:!VALUES.D_NAN, tpz:!VALUES.D_NAN,  $
                  ex:!VALUES.D_NAN,  ey:!VALUES.D_NAN,  ez:!VALUES.D_NAN,  $
                 epx:!VALUES.D_NAN, epy:!VALUES.D_NAN, epz:!VALUES.D_NAN,  $
                   s:!VALUES.D_NAN,  sp:!VALUES.D_NAN,                     $
                  yr:!VALUES.D_NAN                                         $
                }
  itrf_data = replicate(itrf_struct, nITRF)
  mr = 4.84813681D-9
  ; ----- ITRF93
  itrf_data[1].tx  =   0.9769D0  ; in m
  itrf_data[1].ty  =  -1.9392D0  ; in m
  itrf_data[1].tz  =  -0.5461D0  ; in m
  itrf_data[1].tpx =   0.0000D0  ; in m * year^-1
  itrf_data[1].tpy =   0.0000D0  ; in m * year^-1
  itrf_data[1].tpz =   0.0000D0  ; in m * year^-1
  itrf_data[1].ex  =  26.4000D0  ; in mas
  itrf_data[1].ey  =  10.1000D0  ; in mas
  itrf_data[1].ez  =  10.3000D0  ; in mas
  itrf_data[1].epx =   0.0000D0  ; in mas * year^-1
  itrf_data[1].epy =   0.0000D0  ; in mas * year^-1
  itrf_data[1].epz =   0.0000D0  ; in mas * year^-1
  itrf_data[1].s   =   0.0000D0  ; dimensionless
  itrf_data[1].sp  =   0.0000D0  ; in year^-1
  itrf_data[1].yr  =   1995.0D0
  ; ----- ITRF94
  itrf_data[2].tx  =   0.9738D0  ; in m
  itrf_data[2].ty  =  -1.9353D0  ; in m
  itrf_data[2].tz  =  -0.5486D0  ; in m
  itrf_data[2].tpx =   0.0000D0  ; in m * year^-1
  itrf_data[2].tpy =   0.0000D0  ; in m * year^-1
  itrf_data[2].tpz =   0.0000D0  ; in m * year^-1
  itrf_data[2].ex  =  27.5500D0  ; in mas
  itrf_data[2].ey  =  10.0500D0  ; in mas
  itrf_data[2].ez  =  11.3600D0  ; in mas
  itrf_data[2].epx =   0.0900D0  ; in mas * year^-1
  itrf_data[2].epy =  -0.7700D0  ; in mas * year^-1
  itrf_data[2].epz =   0.0200D0  ; in mas * year^-1
  itrf_data[2].s   =   0.0000D0  ; dimensionless
  itrf_data[2].sp  =   0.0000D0  ; in year^-1
  itrf_data[2].yr  =   1996.0D0
  ; ----- ITRF96
  itrf_data[3].tx  =   0.9910D0  ; in m
  itrf_data[3].ty  =  -1.9072D0  ; in m
  itrf_data[3].tz  =  -0.5129D0  ; in m
  itrf_data[3].tpx =   0.0000D0  ; in m * year^-1
  itrf_data[3].tpy =   0.0000D0  ; in m * year^-1
  itrf_data[3].tpz =   0.0000D0  ; in m * year^-1
  itrf_data[3].ex  =  25.7900D0  ; in mas
  itrf_data[3].ey  =   9.6500D0  ; in mas
  itrf_data[3].ez  =  11.6600D0  ; in mas
  itrf_data[3].epx =   0.0532D0  ; in mas * year^-1
  itrf_data[3].epy =  -0.7423D0  ; in mas * year^-1
  itrf_data[3].epz =  -0.0316D0  ; in mas * year^-1
  itrf_data[3].s   =   0.0000D0  ; dimensionless
  itrf_data[3].sp  =   0.0000D0  ; in year^-1
  itrf_data[3].yr  =   1997.0D0
  ; ----- ITRF97
  itrf_data[4].tx  =   0.9889D0  ; in m
  itrf_data[4].ty  =  -1.9074D0  ; in m
  itrf_data[4].tz  =  -0.5030D0  ; in m
  itrf_data[4].tpx =   0.0007D0  ; in m * year^-1
  itrf_data[4].tpy =  -0.0001D0  ; in m * year^-1
  itrf_data[4].tpz =   0.0019D0  ; in m * year^-1
  itrf_data[4].ex  =  25.9150D0  ; in mas
  itrf_data[4].ey  =   9.4260D0  ; in mas
  itrf_data[4].ez  =  11.5990D0  ; in mas
  itrf_data[4].epx =   0.0670D0  ; in mas * year^-1
  itrf_data[4].epy =  -0.7570D0  ; in mas * year^-1
  itrf_data[4].epz =  -0.0310D0  ; in mas * year^-1
  itrf_data[4].s   =  -0.9300D-9 ; dimensionless
  itrf_data[4].sp  =  -0.1900D-9 ; in year^-1
  itrf_data[4].yr  =   1997.0D0
  ; ----- ITRF00
  itrf_data[5].tx  =   0.9956D0  ; in m
  itrf_data[5].ty  =  -1.9013D0  ; in m
  itrf_data[5].tz  =  -0.5215D0  ; in m
  itrf_data[5].tpx =   0.0007D0  ; in m * year^-1
  itrf_data[5].tpy =  -0.0007D0  ; in m * year^-1
  itrf_data[5].tpz =   0.0005D0  ; in m * year^-1
  itrf_data[5].ex  =  25.9150D0  ; in mas
  itrf_data[5].ey  =   9.4260D0  ; in mas
  itrf_data[5].ez  =  11.5990D0  ; in mas
  itrf_data[5].epx =   0.0670D0  ; in mas * year^-1
  itrf_data[5].epy =  -0.7570D0  ; in mas * year^-1
  itrf_data[5].epz =  -0.0510D0  ; in mas * year^-1
  itrf_data[5].s   =   0.6200D-9 ; dimensionless
  itrf_data[5].sp  =  -0.1800D-9 ; in year^-1
  itrf_data[5].yr  =   1997.0D0
  ; ----- ITRF -> ITRF96
  itrf_data[0]  = itrf_data[3]

  itrf = itrf_data[use_itrf]
  tx  = itrf.tx + itrf.tpx * double(thisYEAR - itrf.yr)
  ty  = itrf.ty + itrf.tpy * double(thisYEAR - itrf.yr)
  tz  = itrf.tz + itrf.tpz * double(thisYEAR - itrf.yr)
  omx = (itrf.ex + itrf.epx * double(thisYEAR - itrf.yr)) * mr
  omy = (itrf.ey + itrf.epy * double(thisYEAR - itrf.yr)) * mr
  omz = (itrf.ez + itrf.epz * double(thisYEAR - itrf.yr)) * mr
  ss  = itrf.s + itrf.sp * double(thisYEAR - itrf.yr)

  a1 =   1.0D0 + ss
  b1 =   omz
  c1 = - omy
  a2 = - omz
  b2 =   1.0D0 + ss
  c2 =   omx
  a3 =   omy
  b3 = - omx
  c3 =   1.0D0 + ss

  COEFF = [ [a1, b1, c1], [a2, b2, c2], [a3, b3, c3] ]

  itrf_xyz = unfc * double(xyz)
  itrf_xyz = COEFF ## transpose(itrf_xyz)
  itrf_xyz = transpose(itrf_xyz)

  itrf_xyz[0, *] = itrf_xyz[0, *] + tx
  itrf_xyz[1, *] = itrf_xyz[1, *] + ty
  itrf_xyz[2, *] = itrf_xyz[2, *] + tz
  itrf_xyz = itrf_xyz / unfc

  return, itrf_xyz

end
