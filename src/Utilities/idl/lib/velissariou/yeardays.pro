Function YearDays, year
;+++
; NAME:
;	YEARDAYS
; VERSION:
;	1.0
; PURPOSE:
;	To calculate the total number of days in a year
; CALLING SEQUENCE:
;	YEARDAYS(year)
;	   year - The four digit year
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

  numtypes = [2, 3, 12, 13, 14, 15]

  if ( n_params() lt 1 ) then $
    message, "you need to supply a valid value for <year>."

  num_val = where(numtypes eq size(year, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<year> should be an integer number."

  days = 0
  if ( ((year mod   4) eq 0) and $
       ((year mod 100) ne 0)  or $
       ((year mod 400) eq 0) ) then begin
    days = 366
  endif else begin
    days = 365
  endelse

  return, days

end
