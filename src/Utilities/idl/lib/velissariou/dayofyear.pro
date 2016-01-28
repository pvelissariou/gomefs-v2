Function DayOfYear, year, month, day
;+++
; NAME:
;	DayOfYear
; VERSION:
;	1.0
; PURPOSE:
;	To calculate the day of the year
; CALLING SEQUENCE:
;	DayOfYear(year, month, day)
;	   year - The four digit year
;         month - The two digit month of the year
;           day - The two digit day of the month
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created Tue Nov 13 2012 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

on_error, 2

  numtypes = [2, 3, 12, 13, 14, 15]

  if ( n_params() ne 3 ) then begin
    print, 'Correct Syntax:  DayOfYear, year, month, day'
    message, "Incorrect number of positional parameters"
  endif
  
  num_val = where(numtypes eq size(year, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<year> should be an integer number."

  num_val = where(numtypes eq size(month, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<month> should be an integer number."
  if ( month lt 1 ) or ( month gt 12 ) then $
    message, "<month> should be a value between 1 and 12"
    
  num_val = where(numtypes eq size(day, /type))
  if ( num_val[0] eq -1 ) then $
    message, '<day> should be an integer number.'

  day_tab = [ [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31], $
	      [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]]

  leap = ((year mod 4) eq 0) and ((year mod 100) ne 0) or ((year mod 400) eq 0)

  if ( day lt 1 ) or ( day gt day_tab[month, leap] ) then $
    message, "<day> should be a value between 1 and " + $
             string(day_tab[month, leap], format = '(i2)')

  return, total(day_tab[0:month - 1, leap], /INTEGER) + day

end
