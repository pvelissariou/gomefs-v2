Function TPtoXY,              $
         lat,              $
         lon,             $
         hght, $
         Rad=rad,             $
         KPa = kpa,           $
         Bar = bar,           $
         MBar = mbar
;+++
; NAME:
;	IBtoPres
; VERSION:
;	1.0
; PURPOSE:
;	To calculate the atmospheric pressure given the inverse barometric
;       pressure in meters
; CALLING SEQUENCE:
;	IBtoPres(IBPres [,keyword])
;	 IBPres - Inverse barometric pressure in METERS (m) at a location
;                 It can be a single value or a vector of values or an
;                 array of values
;      StdPress - Input standard atmospheric pressure in kPa
;
; KEYWORD PARAMETERS:
;        pa    :   The output pressure will be in Pascals
;       kpa    :   The output pressure will be in KiloPascals (default)
;       bar    :   The output pressure will be in Bars
;      mbar    :   The output pressure will be in MiliBars
;
; RETURNS:
;               The atmospheric pressure value based on the input inverse
;               barometric pressure
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

  on_error, 2

  ;-------- Determine the pressure units on the output
  pa = keyword_set(pa)
  kpa = keyword_set(kpa)
  bar = keyword_set(bar)
  mbar = keyword_set(mbar)

  ; ----- Check for keywords
  if ((pa + kpa + bar + mbar) gt 1) then $
    message, 'set only one of /PA, /KPA, /BAR or /MBAR.'
  if kpa eq 0 then kpa = 1 - (pa > bar > mbar) ; Default is /kpa

  ; constants
  ; 1 bar = 100 kPa
  ; 1 mbar = 0.1 kPa, 1 kPa = 10 mbar
  if (n_elements(RefPres) ne 0) then begin
    Pstd = double(RefPres[0]) ; input atmospheric pressure in kPa
    if ((Pstd lt 80.0) or (Pstd gt 120.0)) then begin
      tmpstr = strtrim(string(Pstd, format = '(f10.3)'), 2)
      message, 'ERROR ***: invalid pressure value was given: ' + tmpstr
    endif
    Pstd = Pstd * 10.0D ; input atmospheric pressure in mbar
  endif else begin
    Pstd = 1013.25D ; standard atmospheric pressure in mbar
  endelse

  Patm = double(IBPres) * 1000.0D      ; in mm
  Patm = Pstd - (Patm / double(9.948)) ; result is in mbar

  if ( pa eq 1) then begin
    Pstd = Pstd * 100.0D
    Patm = Patm * 100.0D
  endif
  if ( kpa eq 1) then begin
    Pstd = Pstd * 0.1D
    Patm = Patm * 0.1D
  endif
  if ( bar eq 1) then begin
    Pstd = Pstd * 0.001D
    Patm = Patm * 0.001D
  endif

  StdPress = Pstd

  return, Patm

end
