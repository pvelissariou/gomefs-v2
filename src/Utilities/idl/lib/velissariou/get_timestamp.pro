;+++
; NAME:
;	GET_TIMESTAMP
; VERSION:
;	1.0
; PURPOSE:
;	To extract the year/month/day/hour/minute/second values from the
;       input date.
; CALLING SEQUENCE:
;	Get_TimeStamp(Date, [Options])
;
;	On input:
;         Date - The date   (a string)
;         Format: YYYY/MM/DD [HH:MN:SC] or YYYY-MM-DD [HH:MN:SC]
;         Delimeters any of: '-', '/', '_', '.', ':', ' '
;         The above delimiters are all replaced by ' ' and then the date
;         string is converted to integer numbers.
;
;	Optional Variables:
;          YEAR - Set this to to a named variable to receive
;                   the value for the year
;         MONTH - Set this to to a named variable to receive
;                   the value for the month
;           DAY - Set this to to a named variable to receive
;                   the value for the day
;          HOUR - Set this to to a named variable to receive
;                   the value for the hour
;        MINUTE - Set this to to a named variable to receive
;                   the value for the minutes
;        SECOND - Set this to to a named variable to receive
;                   the value for the seconds
;
;	Keywords:
;      YEAR_DAY - Set this keyword to a named variable to receive
;                   the day of the year corresponding to the input date
;        JULIAN - Set this keyword to a named variable to receive
;                   the julian day corresponding to the input date
;     WRF_STAMP - Set this keyword to a named variable to receive
;                   the calculated time stamp compatible
;                   with the WRF model
;     HYC_STAMP - Set this keyword to a named variable to receive
;                   the calculated time stamp compatible
;                   with the HYCOM model
;    ROMS_STAMP - Set this keyword to a named variable to receive
;                   the calculated time stamp compatible
;                   with the ROMS model
;    CUST_STAMP - Set this keyword to a named variable to receive
;                   the calculated custom time stamp
;                   in the form: YYYYMMDDHH
;
;	On output:
;
; MODIFICATION HISTORY:
;	Created : Wed Dec 18 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;       Modified:
;+++
Pro Get_TimeStamp, Date, Year, Month, Day, Hour, Minute, Second, $
                   YEAR_DAY     = year_day,   $
                   JULIAN       = julian,     $
                   WRF_STAMP    = wrf_stamp,  $
                   HYC_STAMP    = hyc_stamp,  $
                   ROMS_STAMP   = roms_stamp, $
                   CUST_STAMP   = cust_stamp

  on_error, 2

  nParam = n_params()
  if (nParam lt 1) then message, 'Incorrect number of arguments.'

  if (size(date, /TNAME) ne 'STRING') then $
    message, "<Date> should be a string."

  old_rep = ['-', '/', '_', '.', ':', ' ']
  new_rep = make_array(n_elements(old_rep), /STRING, VALUE = ' ')
  time = fix(strsplit(vl_StrReplace(date, old_rep, new_rep, recursive = 10), /EXTRACT))

  if (n_elements(time) lt 3) then $
    message, "<Date> should include at least YEAR/MONTH/DAY."

  year   = fix(time[0])
  month  = fix(time[1])
  day    = fix(time[2])
  hour   = (n_elements(time) gt 3) ? fix(time[3]) : 0
  minute = (n_elements(time) gt 4) ? fix(time[4]) : 0
  second = (n_elements(time) gt 5) ? fix(time[5]) : 0

  julian = julday(month, day, year, hour, minute, second)

  ; ----- calculate the day of the year
  jd0 = julday(1, 1, year, 0, 0, 0)
  year_day = fix(julian - jd0 + 1)

  ; ----- calculate the time stamp strings
  ; formats
  wrf_fmt  = '(i4.4, "-", i2.2, "-", i2.2, "_", i2.2, ":", i2.2, ":", i2.2)'
  hyc_fmt  = '(i4.4, i3.3, i2.2)'
  roms_fmt = '(i4.4, "-", i2.2, "-", i2.2, "_", i2.2, ":", i2.2, ":", i2.2)'
  cust_fmt = '(i4.4, i2.2, i2.2, i2.2)'
  
  wrf_stamp  = string(year, month, day, $
                      hour, minute, second, $
                      format = wrf_fmt)
  hyc_stamp  = string(year, year_day, hour, $
                      format = hyc_fmt)
  roms_stamp = string(year, month, day, $
                      hour, minute, second, $
                      format = roms_fmt)
  cust_stamp = string(year, month, day, $
                      hour, $
                      format = cust_fmt)

  return
end
