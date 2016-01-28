PRO Ncdf_PutGlobal, fid, att, attval

  Compile_Opt IDL2

  On_Error, 2

  numtypes = [2, 3, 12, 13, 14, 15]
  num_val = where(numtypes eq size(fid, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<fid> should be an integer number."

  if ( size(att, /TNAME) ne 'STRING' ) then $
    message, "<att> should be a scalar string variable."

  if ( n_elements(attval) eq 0 ) then begin
    message, "<attval> value is required."
  endif else begin
    ok_BYTE   = 0
    ok_CHAR   = 0
    ok_DOUBLE = 0
    ok_FLOAT  = 0
    ok_LONG   = 0
    ok_SHORT  = 0
    case size(attval, /TNAME) of
        'BYTE': ok_BYTE   = 1
        'CHAR': ok_CHAR   = 1
      'STRING': ok_CHAR   = 1
      'DOUBLE': ok_DOUBLE = 1
       'FLOAT': ok_FLOAT  = 1
        'LONG': ok_LONG   = 1
       'SHORT': ok_SHORT  = 1
          else: message, '<attval> unknown attribute value type'
    endcase
  endelse

  ; Get the list of all available global attributes in the input file
  fid_inf = ncdf_inquire(fid)

  thisATT    = att
  thisATTVAL = attval
  found_att  = 0

  for i = 0L, fid_inf.ngatts - 1 do begin
    tmp_str = ncdf_attname(fid, i, /GLOBAL)
    if (strcmp(att, tmp_str, /FOLD_CASE) eq 1) then begin
      thisATT = tmp_str
      found_att = 1
      break
    endif
  endfor

  if (found_att gt 0) then begin
     ncdf_attput, fid, $
       thisATT, thisATTVAL, /GLOBAL, $
       BYTE = ok_BYTE, CHAR = ok_CHAR, DOUBLE = ok_DOUBLE, FLOAT = ok_FLOAT, $
       LONG = ok_LONG, SHORT = ok_SHORT
  endif else begin
    theERR = 0
    catch, theERR
    if (theERR ne 0) then begin
      catch, /cancel
    endif else begin
      ncdf_control, fid, /REDEF
    endelse
    catch, /cancel
      ncdf_attput, fid, $
         thisATT, thisATTVAL, /GLOBAL, $
         BYTE = ok_BYTE, CHAR = ok_CHAR, DOUBLE = ok_DOUBLE, FLOAT = ok_FLOAT, $
         LONG = ok_LONG, SHORT = ok_SHORT
    if (theERR eq 0) then begin
      ncdf_control, fid, /ENDEF
    endif
  endelse

end
