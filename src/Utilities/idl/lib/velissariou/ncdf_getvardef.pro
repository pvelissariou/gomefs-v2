PRO Ncdf_GetVarDef, fid, var_name,            $
                    VAR_ID      = var_id,     $
                    VAR_TYPE    = var_type,   $
                    VAR_NDIMS   = var_ndims,  $
                    VAR_NATTS   = var_natts,  $
                    VAR_DIM     = var_dim,    $
                    ATTR_NAMES  = attr_names

  on_error, 2

  numtypes = [2, 3, 12, 13, 14, 15]

  num_val = where(numtypes eq size(fid, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<fid> should be an integer number."

  if ( size(var_name, /TNAME) ne 'STRING' ) then $
    message, "<var_name> should be a scalar string variable."

  ; Error handling.
  catch, theERR
  if theERR ne 0 then begin
     catch, /cancel
     help, /LAST_MESSAGE
     return
  endif

  varid = ncdf_varid(fid, var_name)
  varsc = ncdf_varinq(fid, varid)

  var_id    = varid
  var_type  = varsc.DataType
  var_ndims = varsc.Ndims
  var_natts = varsc.Natts
  var_dim   = varsc.Dim

  if (var_natts gt 0) then begin
    attr_names = strarr(var_natts)
    for i = 0L, var_natts - 1 do begin
      attr_names[i] = ncdf_attname(fid, varid, i)
    endfor
  endif else begin
    attr_names = ''
  endelse

end
