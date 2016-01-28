FUNCTION Ncdf_GetDims, fid, dfield, dout, $
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
  undefine, dout

  fid_inf = ncdf_inquire(fid)

  ; Get the list of all available dimensions in the input file
  the_names = ''
  for i = 0L, fid_inf.ndims - 1 do begin
    ncdf_diminq, fid, i, the_name, the_size
    the_names = [ the_names, the_name ]
  endfor
  if (n_elements(the_names) gt 1) then the_names = the_names[1:*]

  ; Make a loop here with alternative names for dfield
  ; many times, different versions of the NetCDF data files
  ; use other names for the same dimension. Consider that "dfield"
  ; a single string or an array of strings describing the same dimensions.
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
      err_str = 'none of the requested dimension(s) ' + err_str + ' found in the input file'
      message, err_str
    endif else begin
      return, -1L
    endelse
  endif

  ncdf_diminq, fid, the_idx, dfield, dout

  return, the_idx

end
