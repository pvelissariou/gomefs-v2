FUNCTION FlowRate, unvec, velvec, area, TODIR = todir

  ; It is assumed that unvec represents the normal (possibly outward)
  ; vector to the surface "area". If another direction is desired
  ; use the keyeord variable to change the direction of the calculated
  ; mass fluxes.

  Compile_Opt IDL2

  on_error, 2

  sz = size(unvec)
  if (sz[0] ne 1) and (sz[0] ne 2) then $
    message, 'a 3xn array is required for: UNVECT'
  if ((size(unvec, /DIMENSIONS))[0] ne 3) then $
    message, 'a 3xn array is required for: UNVECT'

  sz = size(velvec)
  if (sz[0] ne 1) and (sz[0] ne 2) then $
    message, 'a 3xn array is required for: VELVEC'
  if ((size(velvec, /DIMENSIONS))[0] ne 3) then $
    message, 'a 3xn array is required for: VELVEC'

  nUNV = n_elements(unvec) / 3
  nVEL = n_elements(velvec) / 3

  if ((nUNV ne 1) and (nUNV ne nVEL)) then $
    message, 'the elements of UNVECT should be 3 or equal to the elements of VELVEC'

  if (n_elements(area) ne nVEL) then $
    message, 'the number of elements in AREA should be equal to: elements(VELVEC) / 3'

  ; Get the precision numbers for the platform used
  eps = (machar()).eps

  ; Make sure that unvec/velvec are of the same size
  oldUNV = unvec
  if (nUNV eq 1) then oldUNV = oldUNV # replicate(1, nVEL)

  ; Examine if we want to do the calculations in another surface
  ; orientation
  if (n_elements(todir) ne 0) then begin
    sz = size(todir)
    if (sz[0] ne 1) and (sz[0] ne 2) then $
      message, 'a 3xn array is required for: TODIR'
    if ((size(todir, /DIMENSIONS))[0] ne 3) then $
      message, 'a 3xn array is required for: TODIR'

    nDIR = n_elements(todir) / 3

    if ((nDIR ne 1) and (nDIR ne nVEL)) then $
      message, 'the elements of TODIR should be 3 or equal to the elements of VELVEC'

    newUNV = todir
    if (nDIR eq 1) then newUNV = newUNV # replicate(1, nVEL)
  endif

  ; Change surface direction if requested
  thisUNV = oldUNV
  if (n_elements(nDIR) ne 0) then thisUNV = newUNV

  flowOUT = [ !VALUES.F_NAN, !VALUES.F_NAN, !VALUES.F_NAN ]
  for i = 0L, nVEL - 1 do begin
    old_unv = reform(oldUNV[*, i])
    tmp_vel = reform(velvec[*, i])
    nrm_old = norm(old_unv)
    nrm_vel = norm(tmp_vel)

    if ((nrm_old * nrm_vel) le eps) then begin
      TOTL_flow = 0.0d
      NORM_flow = TOTL_flow
      TANG_flow = ZeroFloatFix(TOTL_flow - NORM_flow)
    endif else begin
      ; Make the normal vector the unit normal vector
      old_unv = old_unv / nrm_old
      dotPROD = (transpose(old_unv) # tmp_vel)[0]

      TOTL_flow = ZeroFloatFix(dotPROD * area[i])
      NORM_flow = TOTL_flow
      TANG_flow = ZeroFloatFix(TOTL_flow - NORM_flow)

      if (n_elements(nDIR) ne 0) then begin
        new_unv = reform(newUNV[*, i])
        nrm_new = norm(new_unv)

        if ((nrm_old * nrm_new) le eps) then begin
          TOTL_flow = 0.0d
          NORM_flow = TOTL_flow
          TANG_flow = ZeroFloatFix(TOTL_flow - NORM_flow)
        endif else begin
          ; Make the normal vector the unit normal vector
          new_unv = new_unv / nrm_new
          dotPROD = (transpose(old_unv) # new_unv)[0]

          NORM_flow = ZeroFloatFix(dotPROD * TOTL_flow)
          TANG_flow = ZeroFloatFix(TOTL_flow - NORM_flow)
        endelse
      endif
    endelse

    flowOUT = [ [flowOUT], [[ TOTL_flow, NORM_flow, TANG_flow ]] ]
  endfor

  if ((size(flowOUT, /DIMENSIONS))[1] gt 1) then $
    flowOUT = flowOUT[*, 1:*]

  return, flowOUT
end
