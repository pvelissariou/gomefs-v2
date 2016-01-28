;*******************************************************************************
; START THE MAIN PROGRAM
FUNCTION ModelGridLine, x0, y0, x1, y1, xarr, yarr, $
                             DX = dxarr,   $
                             DY = dyarr,   $
                        INDICES = indices, $
                           HORZ = horz,    $
                           VERT = vert
;+++
; NAME:
;	ModelGridLine
; VERSION:
;	1.0
; PURPOSE:
;	To find all the grid points (pixels?) that constitute
;       the line defined by the two points (x0,y0) and (x1,y1)
; CALLING SEQUENCE:
;	idxout = ModelGridLine(x0, y0, x1, y1, xarr, yarr)
;	On input:
; [x0, y0, x1, y1] - The (x, y) coordinates of the two points that
;                    define the line
;             xarr - The 2D matrix of the x-coorinates
;             yarr - The 2D matrix of the y-coorinates
;            dxarr - The 2D matrix of the spacing of the input
;                    grid in the x-direction (OPTIONAL)
;                    size(dxarr) = size(xarr)
;            dyarr - The 2D matrix of the spacing of the input
;                    grid in the y-direction (OPTIONAL)
;                    size(dyarr) = size(yarr)
;	On output:
;	  IDXOUT - The indices of all the grid points that are part
;                  of the line
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created Oct 20 2012 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  ; Error handling.
  On_Error, 2

  idxout = -1L
  horz = -1L
  vert = -1L
  tol_off = 0.0001d

  if ( array_equal(size(xarr), size(yarr), /NO_TYPECONV) ne 1) then begin
    message, 'incompatible array sizes found for [xarr, yarr]'
  endif

  if (size(xarr, /N_DIMENSIONS) ne 2) then begin
    message, '2D arrays are required for [xarr, yarr]'
  endif

  ; make sure that x0 < x1 and y0 < y1
  ; these are used below for various checks
  thisX0 = min([x0, x1], MAX = thisX1)
  thisY0 = min([y0, y1], MAX = thisY1)

  ; check for the orientation of the desired line
  vertical   = (abs(x1 - x0) lt tol_off) ? 1 : 0
  horizontal = (abs(y1 - y0) lt tol_off) ? 1 : 0
  inclined   = ((vertical + horizontal) eq 0) ? 1 : 0
  if ((vertical + horizontal) eq 2) then begin
    message, '[x0, y0, x1, y1] defines just a point'
  endif

  ; get the X/Y dimensions of the input arrays
  sz = size(xarr)
  IDIM = sz[1]
  JDIM = sz[2]

  ; set the arrays "dxarr" and "dyarr" to hold the dx, dy values
  ; for the input arrays "xarr", "yarr" if they are not a user input
  if (n_elements(dxarr) gt 0) then begin
    if (n_elements(dxarr) eq 1) then begin
      dxarr = make_array(IDIM, JDIM, TYPE = size(xarr, /TYPE), VALUE = dxarr[0])
    endif else begin
      if ( array_equal(size(dxarr), size(xarr), /NO_TYPECONV) ne 1) then begin
        message, 'incompatible array sizes found for [xarr, dxarr]'
      endif
    endelse
  endif else begin
    dxarr = make_array(IDIM, JDIM, TYPE = size(xarr, /TYPE), VALUE = 0.0)
    dl  = abs(xarr[1:IDIM - 1, *] - xarr[0:IDIM - 2, *])
    dl1 = ( dl[0:IDIM - 3, *] * dl[0:IDIM - 3, *] + dl[1:IDIM - 2, *] * dl[1:IDIM - 2, *] ) / $
          abs( dl[0:IDIM - 3, *] + dl[1:IDIM - 2, *] )
    dxarr[1:IDIM - 2, *] = dl1
    dxarr[0, *] = dl[0, *]
    dxarr[IDIM - 1, *] = dl[IDIM - 2, *]
  endelse
  if (n_elements(dyarr) gt 0) then begin
    if (n_elements(dyarr) eq 1) then begin
      dyarr = make_array(IDIM, JDIM, TYPE = size(xarr, /TYPE), VALUE = dyarr[0])
    endif else begin
      if ( array_equal(size(dyarr), size(yarr), /NO_TYPECONV) ne 1) then begin
        message, 'incompatible array sizes found for [yarr, dyarr]'
      endif
    endelse
  endif else begin
    dyarr = make_array(IDIM, JDIM, TYPE = size(xarr, /TYPE), VALUE = 0.0)
    dl  = abs(yarr[*, 1:JDIM - 1] - yarr[*, 0:JDIM - 2])
    dl1 = ( dl[*, 0:JDIM - 3] * dl[*, 0:JDIM - 3] + dl[*, 1:JDIM - 2] * dl[*, 1:JDIM - 2] ) / $
          abs( dl[*, 0:JDIM - 3] + dl[*, 1:JDIM - 2] )
    dyarr[*, 1:JDIM - 2] = dl1
    dyarr[*, 0] = dl[*, 0]
    dyarr[*, JDIM - 1] = dl[*, JDIM - 2]
  endelse

  xoff = 0.50 * max(dxarr, /NAN)
  yoff = 0.50 * max(dyarr, /NAN)
  if (n_elements(indices) ne 0) then begin
    inpIDX = indices[uniq(indices)]
    inpCNT = n_elements(inpIDX)
  endif else begin
    inpIDX = where((xarr ge thisX0 - xoff) and $
                   (xarr le thisX1 + xoff) and $
                   (yarr ge thisY0 - yoff) and $
                   (yarr le thisY1 + yoff), inpCNT)
  endelse

  if (inpCNT eq 0) then return, -1L

  ; ----- The line is vertical
  if (vertical eq 1) then begin
    dy = y1 - y0
    dx = x1 - x0

    A  =  dy
    B  = 0.0
    C  = - dy * x0
    AB = sqrt(A * A + B * B)
    cosa = 1.0d

    yy = yarr[inpIDX]
    xx = yy & xx[*] = x0

    for i = 0L, inpCNT - 1 do begin
      thisXX = xx[i]
      thisYY = yy[i]

      F = A * thisXX + B * thisYY + C
      D = abs( F / AB)
      tol = abs(0.5 * (dxarr[i] + tol_off) * cosa)

      if (D le tol) then idxout = [ idxout, inpIDX[i] ]
    endfor

    if (n_elements(idxout) ne 1) then begin
      idxout = idxout[1:*]
    endif
  endif

  ; ----- The line is horizontal
  if (horizontal eq 1) then begin
    dy = y1 - y0
    dx = x1 - x0

    A  =  0.0
    B  = -dx
    C  = dx * y0
    AB = sqrt(A * A + B * B)
    cosa = 1.0d

    xx = xarr[inpIDX]
    yy = yarr[inpIDX]

    for i = 0L, inpCNT - 1 do begin
      thisXX = xx[i]
      thisYY = yy[i]

      F = A * thisXX + B * thisYY + C
      D = abs( F / AB)
      tol = abs(0.5 * (dyarr[i] + tol_off) * cosa)

      if (D le tol) then idxout = [ idxout, inpIDX[i] ]
    endfor

    if (n_elements(idxout) ne 1) then begin
      idxout = idxout[1:*]
    endif
  endif

  ; ----- The line is inclined
  if (inclined eq 1) then begin
    dy = y1 - y0
    dx = x1 - x0
    slope = dy / dx
    inter = y0 - slope * x0
    cosa = cos(atan(slope))

    A  =  dy
    B  = -dx
    C  = inter * dx
    AB = sqrt(A * A + B * B)

    xx = xarr[inpIDX]
    yy = yarr[inpIDX]

    prevF = 1.0
    for i = 0L, inpCNT - 1 do begin
      thisXX = xx[i]
      thisYY = yy[i]
      thisF   = A * thisXX + B * thisYY + C
      thisD   = abs( thisF / AB)
      thisTOL = abs(0.5 * (dyarr[i] + tol_off) * cosa)

      chkLIM = ((thisD le thisTOL) and $
                (thisXX ge thisX0) and (thisXX le thisX1))
      if (chkLIM eq 1) then begin
        if (thisF * prevF ge 0.0) then begin
          idxout = [ idxout, inpIDX[i] ]
        endif else begin
          idxout = [ idxout, inpIDX[i-1], inpIDX[i] ]
        endelse
        prevF = thisF
      endif
    endfor

    if (n_elements(idxout) ne 1) then begin
      idxout = idxout[1:*]
      idxout = idxout[uniq(idxout)]
    endif
  endif

  if (n_elements(idxout) ne 1) then begin
    ijIDX = array_indices([IDIM, JDIM], idxout, /DIMENSIONS)
    iIDX = reform(ijIDX[0, *])
    jIDX = reform(ijIDX[1, *])
    horz = iIDX[uniq(iIDX, sort(iIDX))]
    vert = jIDX[uniq(jIDX, sort(jIDX))]
  endif
    
  return, idxout
end
