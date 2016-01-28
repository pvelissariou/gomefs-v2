Function MonthDays, year, month
;+++
; NAME:
;	MonthDays
; VERSION:
;	1.0
; PURPOSE:
;	To calculate the total number of days in a month for the specified year
; CALLING SEQUENCE:
;	days = MonthDays(year, month)
;	   year - The four digit year
;         month - The month between 1 and 12
; RETURNS:
;       The days in the month
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

  numtypes = [2, 3, 12, 13, 14, 15]

  if ( n_params() lt 2 ) then $
    message, "you need to supply a valid values for <year> and <month>."

  num_val = where(numtypes eq size(year, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<year> should be an integer number."

  num_val = where(numtypes eq size(month, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<month> should be an integer number."
  if ( (month lt 1) or (month gt 12) ) then $
    message, "<month> should be between 1 and 12."

  YRDAYS = yeardays(year)
  if (YRDAYS eq 366) then begin
    MODAYS = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  endif else begin
    MODAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  endelse

  return, MODAYS[month - 1]

end
