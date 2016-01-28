FUNCTION Ncdf_GetDimID, fid, dim_name, dim_size, ERROR = error

  Compile_Opt IDL2

  On_Error, 2

  numtypes = [2, 3, 12, 13, 14, 15]
  num_val = where(numtypes eq size(fid, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<fid> should be an integer number."

  if ( size(dim_name, /TNAME) ne 'STRING' ) then $
    message, "<dim_name> should be a scalar string variable."


  ;------------------------------------------------------------

  dimid = -1

  fid_info = ncdf_inquire(fid)

  for i = 0L, fid_info.ndims - 1 do begin
    ncdf_diminq, fid, i, my_dim_name, my_dim_size
    if (strcmp(my_dim_name, dim_name, /FOLD_CASE) eq 1) then begin
      dim_name = my_dim_name
      dim_size = my_dim_size
      dimid = i
      break
    endif
  endfor

  if (keyword_set(error) gt 0) then begin
    if (dimid lt 0) then begin
      ncdf_close, fid
      message, 'the dimension ' + '<' + dim_name + '>' + ' is not defined in the input file'
    endif
  endif

  return, dimid
end
