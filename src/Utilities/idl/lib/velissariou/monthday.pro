Pro MonthDay, year, day, yr_mo, mo_da, $
              MONTH_NAME = month_name, DAY_NAME = day_name, $
              JULIAN = julian
;+++
; NAME:
;	MONTHDAY
; VERSION:
;	1.0
; PURPOSE:
;	Given the day of the year (first day is 1), determine the month and
;       the day of the month for the given year
; CALLING SEQUENCE:
;	MONTHDAY, year, day [, yr_mo, mo_da]
;	   year - The four digit year
;	   day  - The day of the year
; OPTIONAL PARAMETERS:
;         yr_mo - A named variable that holds the month of the year (1-12) 
;         mo_da - A named variable that holds the day of the month (1-31)
; KEYWORDS:
;    MONTH_NAME - Set this keyword to a named variable that holds the
;                 name of the month of the year
;      DAY_NAME - Set this keyword to a named variable that holds the
;                 name of the day of the week
; RETURNS:
;       None
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created  : June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;	Modified : Dec  07 2013 by Panagiotis Velissariou (velissariou.1@osu.edu).
;                  Converted it to a procedure, added the named variables yr_mo,
;                  mo_da, MONTH_NAME, DAY_NAME
;+++

on_error, 2

  numtypes = [2, 3, 12, 13, 14, 15]

  if ( n_params() lt 2 ) then begin
    print, 'Correct Syntax:  MonthDay, year, day'
    message, "Incorrect number of positional parameters"
  endif

  num_val = where(numtypes eq size(year, /type))
  if ( num_val[0] eq -1 ) then $
    message, '<year> should be an integer number.'

  num_val = where(numtypes eq size(day, /type))
  if ( num_val[0] eq -1 ) then $
    message, '<day> should be an integer number.'

  theYEAR = fix(year)
  theDAY  = fix(day)

  yrdays = YearDays(year)

  if ( (day le 0) or (day gt yrdays) ) then $
    message, '<day> should be 1 <= day <= 365(366).'

  day_tab = [ [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31], $
	      [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] ]

  ; Month names
  month_names = [  'January', 'February',    'March',    'April', $
                       'May',     'June',     'July',   'August', $
                ' September',  'October', 'November', 'December' ]

  ; Day names
  day_names = [   'Sunday', 'Monday', 'Tuesday', 'Wednesday', $
                'Thursday',  'Friday',  'Saturday' ]

  leap = ((year mod 4) eq 0) and ((year mod 100) ne 0) or ((year mod 400) eq 0)

  mo_da = 0
  yr_mo = 0
  for i = 1, 12 do begin
    if( mo_da ge day ) then break
    mo_da = mo_da + day_tab[i, leap]
  endfor

  yr_mo = i - 1
  mo_da = day_tab[i - 1, leap] - (mo_da - day)
  month_name = month_names[yr_mo - 1]

  a = (14 - yr_mo) / 12
  y = year - a
  m = yr_mo + 12 * a - 2

  if (keyword_set(julian) eq 1) then begin
    ; For Julian Calendar
    d = ( (5 + mo_da + y + (y / 4) + ((31 * m) / 12)) mod 7 )
  endif else begin
    ; For Gregorian Calendar
    d = ( (mo_da + y + (y / 4) - (y / 100) + (y / 400) + ((31 * m) / 12)) mod 7 )
  endelse
  day_name = day_names[d]

end
