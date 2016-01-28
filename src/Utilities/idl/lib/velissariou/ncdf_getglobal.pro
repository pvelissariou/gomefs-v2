FUNCTION Ncdf_GetGlobal, fid, att, attval, LIST = list

  Compile_Opt IDL2

  On_Error, 2

  numtypes = [2, 3, 12, 13, 14, 15]
  num_val = where(numtypes eq size(fid, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<fid> should be an integer number."

  undefine, attval

  fid_inf = ncdf_inquire(fid)

  ; Get the list of all available global attributes in the input file
  att_names = ''
  for i = 0L, fid_inf.ngatts - 1 do begin
    tmp_str = ncdf_attname(fid, i, /GLOBAL)
    att_names = [ att_names, tmp_str ]
  endfor
  if (n_elements(att_names) gt 1) then att_names = att_names[1:*]

  if (arg_present(list) eq 1) then begin
    list = att_names
    return, 0
  endif

  if ( size(att, /TNAME) ne 'STRING' ) then $
    message, "<att> should be a scalar string variable."

  attidx = (where(strmatch(att_names, att, /FOLD_CASE) eq 1))[0]
  if (attidx lt 0) then return, -1

  att_name = ncdf_attname(fid, attidx, /GLOBAL)
  att_inf  = ncdf_attinq(fid, att_name, /GLOBAL) 
  att_type = att_inf.datatype

  ncdf_attget, fid, att_name, att_value, /GLOBAL
  if ((size(att_value, /TNAME) eq 'BYTE') and $
      (att_type eq 'CHAR')) then begin
    att_value = string(att_value)
  endif

  attval = att_value

  return, 1

end
