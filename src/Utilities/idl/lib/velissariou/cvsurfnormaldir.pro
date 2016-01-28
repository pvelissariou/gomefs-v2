FUNCTION CVSurfNormalDir,        $
           unvect, pnts, cspnts, $
           CHKPNT = chkpnt,      $
           NVECT = nvect,        $
           PLANE = plane

  ; unvect: are the unit normal vectors at the grid faces passing through pnts
  ; pnts:   are the points (origin) of the unit normal vectors
  ; cspnts: are the coordinates of the vertices of the control surface
  ; chkpnt: is a reference point interior to the control surface that is
  ;         used to determine the direction of the normal unit vector.
  ;         If it is supplied it used (and cspnts are not used, the user can
  ;         omit this parameter), otherwise the reference point is defined
  ;         as the cendroid of the control surface)
  ; The function returns the outward unit normal vector and the
  ; adjusted normal vector and plane equation.

  Compile_Opt IDL2

  on_error, 2

  ; The unit normal vector to adjust if needed
  dimsUNV = size(unvect, /DIMENSIONS)
  nelmUNV = n_elements(dimsUNV)
  if ( ((nelmUNV ne 1) and (nelmUNV ne 2)) or $
       ((dimsUNV[0] ne 2) and (dimsUNV[0] ne 3)) ) then $
      message,'UNVECT must be a 2 x N or a 3 x N array.'
  nUNV = n_elements(unvect) / dimsUNV[0]

  ; The point(s) (coordinates) of the origin of the unit normal vectors
  ; (these should be points of the control surface)
  dimsPNTS = size(pnts, /DIMENSIONS)
  nelmPNTS = n_elements(dimsPNTS)
  if ( ((nelmPNTS ne 1) and (nelmPNTS ne 2)) or $
       ((dimsPNTS[0] ne 2) and (dimsPNTS[0] ne 3))) then $
      message,'PNTS must be a 2 x N or a 3 x N array.'
  if (dimsUNV[0] lt dimsPNTS[0]) then begin
    tmp_str = strcompress(string(dimsPNTS[0], format = '(i3)'), /REMOVE_ALL) + ' x N'
    message,'UNVECT must be a ' + tmp_str + ' array (as PNTS)'
  endif
  if ((n_elements(pnts) / dimsPNTS[0]) ne nUNV) then $
      message,'UNVECT and PNTS must have the same number of elements.'

  ; The check point if one is supplied (a point in the interior of the
  ; region enclosed by the control surface, preferably away from the
  ; CS boundary).
  if (n_elements(chkpnt) ne 0) then begin
    dimsCHKPNT = size(chkpnt, /DIMENSIONS)
    nelmCHKPNT = n_elements(dimsCHKPNT)
    if ( (nelmCHKPNT ne 1) or $
         ((dimsCHKPNT[0] ne 2) and (dimsCHKPNT[0] ne 3)) ) then $
        message,'CHKPNT must be a 2 x 1 or a 3 x 1 vector.'
    if (dimsCHKPNT[0] ne dimsPNTS[0]) then begin
      tmp_str = strcompress(string(dimsPNTS[0], format = '(i3)'), /REMOVE_ALL) + ' x 1'
      message,'CHKPNT must be a ' + tmp_str + ' vector (to comply with PNTS)'
    endif
  endif else begin
    ; Instead use control surface points (the CS encloses the CV)
    dimsCSPNTS = size(cspnts, /DIMENSIONS)
    if ((n_elements(dimsCSPNTS) ne 2) or ((dimsCSPNTS[0] ne 2) and (dimsCSPNTS[0] ne 3))) then $
        message,'CSPNTS must be a 2 x N or a 3 x N array.'
    if (dimsCSPNTS[0] ne dimsPNTS[0]) then begin
      tmp_str = strcompress(string(dimsPNTS[0], format = '(i3)'), /REMOVE_ALL) + ' x N'
      message,'CSPNTS must be a ' + tmp_str + ' array (as PNTS)'
    endif

    chkpnt = reform(cspnts[ *, 0])
    for i = 0L, dimsPNTS[0] - 1 do $
      chkpnt[i] = mean(cspnts[i, *])
  endelse

  ; ---------- Start the calculations
  OUT_unvect = unvect

  for i = 0L, nUNV - 1 do begin
    un_vec = unvect[0:dimsPNTS[0] - 1, i]
    ck_vec = chkpnt - pnts[*, i]
    dotPROD = (transpose(un_vec) # ck_vec)[0]
    if (dotPROD ge 0.0) then begin
      OUT_unvect[*, i] = ZeroFloatFix( - OUT_unvect[*, i] )
      if (n_elements(nvect) ne 0) then nvect[*, i] = ZeroFloatFix( - nvect[*, i] )
      if (n_elements(plane) ne 0) then plane[*, i] = ZeroFloatFix( - plane[*, i] )
    endif
  endfor

  return, OUT_unvect
end
