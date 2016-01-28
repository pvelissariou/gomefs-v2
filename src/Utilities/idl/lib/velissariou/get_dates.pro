;+++
; NAME:
;	GET_GATES
; VERSION:
;	1.0
; PURPOSE:
;	To calculate the year/month/day/hour/minute values between the
;       "start" date and the "end" date given an array of hour/minute intervals.
; CALLING SEQUENCE:
;	time_max = Get_Gates(Date1, Date2, $
;                            [Options])
;
;	On input:
;         Date1 - The "start" date   (a string)
;         Date2 - The "end" date     (a string)
;         Format: YYYY/MM/DD [HH:MN:SC] or YYYY-MM-DD [HH:MN:SC]
;         Delimeters can be any of: '-', '/', '_', '.', ':', ' '
;         The above delimiters are all replaced by ' ' and then the date
;         string is converted to integer numbers.
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
;        JULIAN - Set this keyword to a named variable to receive
;                   the vector of the julian days values
;     WRF_STAMP - Set this keyword to a named variable to receive
;                   the vector of the calculated time stamps compatible
;                   with the WRF model
;     HYC_STAMP - Set this keyword to a named variable to receive
;                   the vector of the calculated time stamps compatible
;                   with the HYCOM model
;    ROMS_STAMP - Set this keyword to a named variable to receive
;                   the vector of the calculated time stamps compatible
;                   with the ROMS model
;    CUST_STAMP - Set this keyword to a named variable to receive
;                   the vector of the calculated custom time stamps
;                   in the form: YYYYMMDDHH
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
;       Modified: Wed Dec 18 2013 by Panagiotis Velissariou
;                 To replace part of the code by using Get_TimeStamp
;+++
Function Get_Dates, Date1, Date2,                $
                    HR_INTERVALS = hr_intervals, $
                    MN_INTERVALS = mn_intervals, $
                    YR_OUT       = yr_out,       $
                    MO_OUT       = mo_out,       $
                    DA_OUT       = da_out,       $
                    HR_OUT       = hr_out,       $
                    MN_OUT       = mn_out,       $
                    SC_OUT       = sc_out,       $
                    YEAR_DAY     = year_day,     $
                    JULIAN       = julian,       $
                    WRF_STAMP    = wrf_stamp,    $
                    HYC_STAMP    = hyc_stamp,    $
                    ROMS_STAMP   = roms_stamp,   $
                    CUST_STAMP   = cust_stamp

  on_error, 2

  nParam = n_params()
  if (nParam ne 2) then message, 'Incorrect number of arguments.'

  if ( (size(date1, /TNAME) ne 'STRING') or $
       (size(date2, /TNAME) ne 'STRING') ) then $
    message, "<Date1, Date2> should be all strings."

  Get_TimeStamp, date1, year1, month1, day1, hour1, minute1, second1
  Get_TimeStamp, date2, year2, month2, day2, hour2, minute2, second2

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

  ; ----- the julian day array
  julian = thisJD

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
  ; arrays
  wrf_stamp  = strarr(nREC)
  hyc_stamp  = strarr(nREC)
  roms_stamp = strarr(nREC)
  cust_stamp = strarr(nREC)

  ; formats
  wrf_fmt  = '(i4.4, "-", i2.2, "-", i2.2, "_", i2.2, ":", i2.2, ":", i2.2)'
  hyc_fmt  = '(i4.4, i3.3, i2.2)'
  roms_fmt = '(i4.4, "-", i2.2, "-", i2.2, "_", i2.2, ":", i2.2, ":", i2.2)'
  cust_fmt = '(i4.4, i2.2, i2.2, i2.2)'
  
  for i = 0L, nREC - 1 do begin
    wrf_stamp[i]  = string(yr_out[i], mo_out[i], da_out[i], $
                           hr_out[i], mn_out[i], sc_out[i], $
                           format = wrf_fmt)
    hyc_stamp[i]  = string(yr_out[i], year_day[i], hr_out[i], $
                           format = hyc_fmt)
    roms_stamp[i] = string(yr_out[i], mo_out[i], da_out[i], $
                           hr_out[i], mn_out[i], sc_out[i], $
                           format = roms_fmt)
    cust_stamp[i] = string(yr_out[i], mo_out[i], da_out[i], $
                           hr_out[i], $
                           format = cust_fmt)
  endfor

  return, nREC
end
