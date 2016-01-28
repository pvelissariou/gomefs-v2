FUNCTION Ncdf_GetVarID, fid, var_name

  Compile_Opt IDL2

  On_Error, 2

  numtypes = [2, 3, 12, 13, 14, 15]
  num_val = where(numtypes eq size(fid, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<fid> should be an integer number."

  if ( size(var_name, /TNAME) ne 'STRING' ) then $
    message, "<var_name> should be a scalar string variable."


  ;------------------------------------------------------------

  varid = -1

  fid_info = ncdf_inquire(fid)

  for i = 0L, fid_info.nvars - 1 do begin
    my_var_name = (ncdf_varinq(fid, i)).name
    if (strcmp(my_var_name, var_name, /FOLD_CASE) eq 1) then begin
      var_name = my_var_name
      varid = i
      break
    endif
  endfor

  return, varid

end
