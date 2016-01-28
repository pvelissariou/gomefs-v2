PRO Ncdf_DelGlobal, fid, att

  Compile_Opt IDL2

  On_Error, 2

  numtypes = [2, 3, 12, 13, 14, 15]
  num_val = where(numtypes eq size(fid, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<fid> should be an integer number."

  if ( size(att, /TNAME) ne 'STRING' ) then $
    message, "<att> should be a scalar string variable."

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
    theERR = 0
    catch, theERR
    if (theERR ne 0) then begin
      catch, /cancel
    endif else begin
      ncdf_control, fid, /REDEF
    endelse
    catch, /cancel
      ncdf_attdel, fid, thisATT, /GLOBAL
    if (theERR eq 0) then begin
      ncdf_control, fid, /ENDEF
    endif
  endif

end
