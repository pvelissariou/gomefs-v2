function sat_footprint, hs, meters = meters, feet = feet
;+++
; NAME:
;	SAT_FOOTPRINT
; VERSION:
;	1.0
; PURPOSE:
;	To calculate the signal footprint from a satellite on the sea
; CALLING SEQUENCE:
;	SAT_FOOTPRINT(hs[, /meters][, /feet])
;         Where hs is the significant wave height (meters or, feet).
;         If the keyword meters (default) is set the calculations
;         are performed in the metric system and if the keyword feet
;         is setthe calculations are performed in the english system.
; RETURNS:
;	The radius of the circular signal footprint (m or, ft)
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

  numtypes = [2, 3, 12, 13, 14, 15]

  if ( n_params() lt 1 ) then $
    message, 'You need to supply a valid value for <hs>'

  itis = size( hs, /TYPE )
  if ((itis ne 2) and (itis ne 4) and (itis ne 5)) then $
    message, 'the value supplied for <hs> is not a valid number.'

; check to see if the significant wave height is given in
; meters (default) or feet
  meters = keyword_set( meters )
  feet   = keyword_set( feet )
  if (meters eq 0) and (feet eq 0) then meters = 1
  if (meters eq 1) and (feet eq 1) then meters = 1

; conversion factor between meters and feet
  unitconv = 1.0D
  if (feet eq 1) then unitconv = 3.280839895D
  
; set some constants here
; r0 = altimetry height of the satellite (km)
; re = earth radius (km)
; c  = speed of light (m/s)
; hs = significant wace height
; T  = effective pulse intarval (s)
; R  = effective radius of the circular signal footprint
r0 = 1335.0D                ; km
re = 6371.0D                ; km
c  = Double(2.998 * 10^(8.0))    ; m/s
T  = Double(3.125 * 10.0^(-9.0)) ; or 3.125 ns

R = (r0 * 10.0^(3.0)) * unitconv
R = R * (c * T * unitconv + 2.0 * Double(hs))
R = R / (1.0D + r0/re)
R = sqrt( R )

return, R

end
