FUNCTION Ncdf_GetData, fid, dfield, dout,   $
                       FILL_VAL = dfill,    $
                       UNITS = dunits,      $
                       DESC = ddesc,        $
                       MISS_VAL = miss_val, $
                       ERROR = error

  Compile_Opt IDL2

  On_Error, 2

  numtypes = [2, 3, 12, 13, 14, 15]
  num_val = where(numtypes eq size(fid, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<fid> should be an integer number."

  if ( size(dfield, /TNAME) ne 'STRING' ) then $
    message, "<dfield> should be a string variable."

  retval = -1
  undefine, dout, dfill, dunits

  fid_inf = ncdf_inquire(fid)

  ; Get the list of all available variables in the input file
  the_names = ''
  for i = 0L, fid_inf.nvars - 1 do begin
    the_names = [ the_names, (ncdf_varinq(fid, i)).name ]
  endfor
  if (n_elements(the_names) gt 1) then begin
    the_names = the_names[1:*]
  endif else begin
    if (keyword_set(error) gt 0) then begin
      ncdf_close, fid
      err_str = 'the input file contains no variables'
      message, err_str
    endif else begin
      return, -1L
    endelse
  endelse

  ; Make a loop here with alternative names for dfield
  ; many times, different versions of the NetCDF data files
  ; use other names for the same variable. Consider that "dfield"
  ; a single string or an array of strings describing the same variables.
  ; If "dfield" is found in the input file break out of the loop
  ; and continue with the calculations.
  the_idx = -1L
  for ivar = 0L, n_elements(dfield) - 1 do begin
    the_idx = (where(strmatch(the_names, dfield[ivar], /FOLD_CASE) eq 1))[0]
    if (the_idx ge 0) then break
  endfor
  if (the_idx lt 0) then begin
    if (keyword_set(error) gt 0) then begin
      ncdf_close, fid
      err_str = '[' + strjoin(dfield, ' ', /SINGLE) + ']'
      err_str = 'none of the requested variables(s) ' + err_str + ' found in the input file'
      message, err_str
    endif else begin
      return, -1L
    endelse
  endif

  dfield = the_names[the_idx]
  varid  = ncdf_varid(fid, dfield)
  varinf = ncdf_varinq(fid, varid)

  ; Get the data for the variable
  ncdf_varget, fid, varid, dout
  if ((size(dout, /TNAME) eq 'BYTE') and $
      (varinf.datatype eq 'CHAR')) then begin
    dout = string(dout)
  endif

  ; Get the FillValue for the data (if any)
  for i = 0L, varinf.natts - 1 do begin
    att_name = strcompress(ncdf_attname(fid, varid, i), /REMOVE_ALL)
    att_inf  = ncdf_attinq(fid, varid, att_name) 
    att_type = att_inf.datatype

    if (strmatch(att_name, '*Fill*Value*', /FOLD_CASE) eq 1) then begin
      ncdf_attget, fid, varid, att_name, att_value
      if ((size(att_value, /TNAME) eq 'BYTE') and $
          (att_type eq 'CHAR')) then begin
        att_value = string(att_value)
      endif
      dfill = att_value

      ; Fill with NaNs the variable if requested
      if (n_elements(miss_val) ne 0) then begin
        if (ChkForMask(dout, dfill, FILL_IDX, FILL_COUNT) gt 0) then begin
          dfill = miss_val[0]
          dout[FILL_IDX] = dfill
        endif
      endif
    endif

    if (strmatch(att_name, 'units', /FOLD_CASE) eq 1) then begin
      ncdf_attget, fid, varid, att_name, att_value
      if ((size(att_value, /TNAME) eq 'BYTE') and $
          (att_type eq 'CHAR')) then begin
        att_value = string(att_value)
      endif
      dunits = att_value
    endif

    if (strmatch(att_name, 'description', /FOLD_CASE) eq 1) then begin
      ncdf_attget, fid, varid, att_name, att_value
      if ((size(att_value, /TNAME) eq 'BYTE') and $
          (att_type eq 'CHAR')) then begin
        att_value = string(att_value)
      endif
      ddesc = att_value
    endif
  endfor

  return, varid

end
