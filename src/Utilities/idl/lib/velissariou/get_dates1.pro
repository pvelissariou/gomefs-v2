;+++
; NAME:
;	GET_DATES1
; VERSION:
;	1.0
; PURPOSE:
;	To calculate the year/month/day/hour/minute values between the
;       "start" date and the "end" date given an array of hour/minute intervals.
; CALLING SEQUENCE:
;	time_max = Get_Dates1(Year1, Month1, Day1, Hour1, Minute1, $
;                             Year2, Month2, Day2, Hour2, Minute2, $
;                             [Options])
;
;	On input:
;         Year1 - The "start" year           (a positive number)
;        Month1 - The "start" month of year  (a positive number)
;          Day1 - The "start" day of month   (a positive number)
;         Hour1 - The "start" hour of day    (a positive number)
;       Minute1 - The "start" minute of hour (a positive number)
;         Year2 - The "end" year             (a positive number)
;        Month2 - The "end" month of year    (a positive number)
;          Day2 - The "end" day of month     (a positive number)
;         Hour2 - The "end" hour of day      (a positive number)
;       Minute2 - The "end" minute of hour   (a positive number)
;
;	Optional parameters:
;  HR_INTERVALS - The hour intervals to use for each day:
;                  e.g, HR_INTERVALS = [0, 6, 12, 18]
;                  default: HR_INTERVALS = [0]
;  MN_INTERVALS - The minute intervals to use for each hour:
;                  e.g, MN_INTERVALS = [0, 20, 40, 60]
;                  default: MN_INTERVALS = [0]
;
;	Keywords:
;        YR_OUT - Set this keyword to a named variable to receive
;                   the vector of the year values
;        MO_OUT - Set this keyword to a named variable to receive
;                   the vector of the month values
;        DA_OUT - Set this keyword to a named variable to receive
;                   the vector of the day values
;        HR_OUT - Set this keyword to a named variable to receive
;                   the vector of the hour values
;        MN_OUT - Set this keyword to a named variable to receive
;                   the vector of the minute values
;        SC_OUT - Set this keyword to a named variable to receive
;                   the vector of the second values
;      YEAR_DAY - Set this keyword to a named variable to receive
;                   the vector of the day of the year values
;     WRF_STAMP - Set this keyword to a named variable to receive
;                   the vector of the calculated time stamps compatible
;                   with the WRF model
;     HYC_STAMP - Set this keyword to a named variable to receive
;                   the vector of the calculated time stamps compatible
;                   with the HYCOM model
;    ROMS_STAMP - Set this keyword to a named variable to receive
;                   the vector of the calculated time stamps compatible
;                   with the ROMS model
;    NOTE: The size of the above vectors is determined by:
;            time_max = ceil((end_julian - start_julian) * $
;                       n_elements(hr_intervals) * n_elements(mn_intervals))
;
;	On output:
;      time_max - The interpolated values; the size and type is the same as xloc
;                 NOTE: If not available data found, zloc is set to !VALUES.F_NAN
;
; MODIFICATION HISTORY:
;	Created : Sun Dec 15 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;       Modified:
;+++
Function Get_Dates1,                            $
           Year1, Month1, Day1, Hour1, Minute1, $
           Year2, Month2, Day2, Hour2, Minute2, $
           HR_INTERVALS = hr_intervals,         $
           MN_INTERVALS = mn_intervals,         $
           YR_OUT       = yr_out,               $
           MO_OUT       = mo_out,               $
           DA_OUT       = da_out,               $
           HR_OUT       = hr_out,               $
           MN_OUT       = mn_out,               $
           SC_OUT       = sc_out,               $
           YEAR_DAY     = year_day,             $
           WRF_STAMP    = wrf_stamp,            $
           HYC_STAMP    = hyc_stamp,            $
           ROMS_STAMP   = roms_stamp

  on_error, 2

  nParam = n_params()
  if (nParam ne 10) then message, 'Incorrect number of arguments.'

  numtypes = [2, 3, 12, 13, 14, 15]

  num_val = (where(numtypes eq size(year1, /TYPE)))[0]
  if ( ( (where(numtypes eq size(year1, /TYPE)))[0] eq -1 )   or $
       ( (where(numtypes eq size(month1, /TYPE)))[0] eq -1 )  or $
       ( (where(numtypes eq size(day1, /TYPE)))[0] eq -1 )    or $
       ( (where(numtypes eq size(hour1, /TYPE)))[0] eq -1 )   or $
       ( (where(numtypes eq size(minute1, /TYPE)))[0] eq -1 ) ) then $
    message, "<Year1, Month1, Day1, Hour1, Minute1> should be all integer numbers."

  if ( ( (where(numtypes eq size(year2, /TYPE)))[0] eq -1 )   or $
       ( (where(numtypes eq size(month2, /TYPE)))[0] eq -1 )  or $
       ( (where(numtypes eq size(day2, /TYPE)))[0] eq -1 )    or $
       ( (where(numtypes eq size(hour2, /TYPE)))[0] eq -1 )   or $
       ( (where(numtypes eq size(minute2, /TYPE)))[0] eq -1 ) ) then $
    message, "<Year2, Month2, Day2, Hour2, Minute2> should be all integer numbers."

  if ( (year1 lt 0) or (year2 lt 0) ) then $
    message, "<year1, year2> should be integers greater than 0."

  if ( (month1 lt 1) or (month2 lt 1) ) then $
    message, "<month1, month2> should be integers greater than 1."

  if ( (day1 lt 1) or (day2 lt 1) ) then $
    message, "<day1, day2> should be integers greater than 1."

  if ( (hour1 lt 0) or (hour2 lt 0) ) then $
    message, "<hour1, hour2> should be integers greater than 0."

  if ( (minute1 lt 0) or (minute2 lt 0) ) then $
    message, "<minute1, minute2> should be integers greater than 0."


  jd1 = julday(month1, day1, year1, hour1, minute1, 0)
  jd2 = julday(month2, day2, year2, hour2, minute2, 0)


  if ( jd2 lt jd1 ) then $
    message, "<begin time> should be greater or equal to <end time>."


  ; ----- check for the hr_intervals
  if ( n_elements(hr_intervals) eq 0 ) then hr_intervals = [ 0 ]
  hr_intervals = fix(hr_intervals)

  if ( min(hr_intervals) lt  0 ) then $
    message, "<hr_intervals> should be integers greater than 0."

  hr_intervals = hr_intervals[uniq(hr_intervals, sort(hr_intervals))]

  ; ----- check for the mn_intervals
  if ( n_elements(mn_intervals) eq 0 ) then mn_intervals = [ 0 ]
  mn_intervals = fix(mn_intervals)

  if ( min(mn_intervals) lt  0 ) then $
    message, "<mn_intervals> should be integers greater than 0."

  mn_intervals = mn_intervals[uniq(mn_intervals, sort(mn_intervals))]


  ; ----- calculate the maximum number of records
  nREC = ceil((jd2 - jd1) * n_elements(hr_intervals) * n_elements(mn_intervals))

  thisJD = timegen(nREC, $
                   HOURS = hr_intervals, MINUTES = mn_intervals, SECONDS = 0, $
                   START = jd1, FINAL = jd2)
  thisJD = thisJD[where((thisJD - jd1) ge 0, nREC)]

  ; ----- calculate the year, month, day, hour and minute arrays
  caldat, thisJD, mo_out, da_out, yr_out, hr_out, mn_out, sc_out
  da_out = fix(da_out)
  hr_out = fix(hr_out)
  mn_out = fix(mn_out)
  sc_out = fix(sc_out)

  ; ----- calculate the day of the year
  ref_jd = julday(1, 1, yr_out, 0, 0, 0)
  year_day = fix(thisJD - ref_jd + 1)

  ; ----- calculate the time stamp strings
  if ( (arg_present(wrf_stamp) ne 0) or $
       (arg_present(hyc_stamp) ne 0) or $
       (arg_present(roms_stamp) ne 0) ) then begin

    ; arrays
    wrf_stamp  = strarr(nREC)
    hyc_stamp  = strarr(nREC)
    roms_stamp = strarr(nREC)

    ; formats
    wrf_fmt  = '(i4.4, "-", i2.2, "-", i2.2, "_", i2.2, ":", i2.2, ":", i2.2)'
    hyc_fmt  = '(i4.4, i3.3, i2.2)'
    roms_fmt = '(i4.4, "-", i2.2, "-", i2.2, "_", i2.2, ":", i2.2, ":", i2.2)'
    
    for i = 0L, nREC - 1 do begin
      wrf_stamp[i]  = string(yr_out[i], mo_out[i], da_out[i], $
                             hr_out[i], mn_out[i], sc_out[i], $
                             format = wrf_fmt)
      hyc_stamp[i]  = string(yr_out[i], year_day[i], hr_out[i], $
                             format = hyc_fmt)
      roms_stamp[i] = string(yr_out[i], mo_out[i], da_out[i], $
                             hr_out[i], mn_out[i], sc_out[i], $
                             format = roms_fmt)
    endfor
  endif

  return, nREC
end
