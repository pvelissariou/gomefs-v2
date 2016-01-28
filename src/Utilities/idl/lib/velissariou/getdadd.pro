FUNCTION GetDADD, DaddDir, DaddYear, IsMap = ismap

  on_error, 2

  COMMON SepChars
  COMMON BathParams

  dd_dir = strtrim(string(DaddDir), 2)
  if (not readDIR(dd_dir)) then $
    message, 'please supply a valid directory name for: ' + dd_dir

  dd_year = fix(DaddYear)
  dd_yrdays = YearDays(dd_year)
  dd_yrstr = strtrim(string(dd_year, format = '(i4.4)'), 2)

  dd_map = 0
  if (n_elements(ismap) ne 0) then $
    dd_map = fix(ismap) le 2 ? 0 : 1

  dd_arr = make_array(IPNTS, JPNTS, dd_yrdays, /DOUBLE, VALUE = !VALUES.D_NAN)

  found_dd_file = 0
  if( dd_map le 0 ) then begin
    dd_file = 'WLdailym' + dd_yrstr + '.dat'
    dd_file = dd_dir + DIR_SEP + dd_file
    if (readFILE(dd_file)) then begin
      openr, 2, dd_file
      for i = 0, dd_yrdays - 1 do begin
        tmpstr = ''
        tmpval = 0.0D
        tmparr = make_array(IPNTS, JPNTS, /DOUBLE, VALUE = !VALUES.D_NAN)
        readf, 2, tmpstr
        tmpstr = strsplit(tmpstr, ' ', /EXTRACT)
        tmpval = double(tmpstr[n_elements(tmpstr) - 1])
        tmparr[WCELLSIDX] = tmpval
        dd_arr[*, *, i] = tmparr
      endfor
      close, 2
      found_dd_file = 1
    endif
  endif else begin
    for i = 0, dd_yrdays - 1 do begin
      dd_file = 'WLdailym' + dd_yrstr + string(i + 1, format = '(i3.3)') + '00' + '.dat'
      dd_file = dd_dir + DIR_SEP + dd_file
      if (readFILE(dd_file)) then begin
        tmpstr = ''
        tmparr0 = make_array(WCELLS, /DOUBLE, VALUE = !VALUES.D_NAN)
        tmparr = make_array(IPNTS, JPNTS, /DOUBLE, VALUE = !VALUES.D_NAN)
        openr, 2, dd_file
        readf, 2, tmpstr
        readf, 2, tmparr0
        tmparr[WCELLSIDX] = tmparr0
        dd_arr[*, *, i] = tmparr
        close, 2
        found_dd_file = 1
      endif else begin
        message, 'Warning: file not found: ' + dd_file
      endelse
    endfor
  endelse

  if (found_dd_file eq 0) then $
    message, 'please supply a valid filename for: ' + dd_file

  return, dd_arr

end
