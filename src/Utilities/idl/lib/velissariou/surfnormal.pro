FUNCTION get_a_surfnorm,        $
           Xvert, Yvert, Zvert, $
           NVECT = nvect,       $
           PLANE = plane

  ; This function calculates the normal vector to a plane surface
  ; described by the coordinates of its vertices according to Newell's algorithm:
  ; A =   0.5 * {(y0*z1-y1*z0) + (y1*z2-y2*z1) + ...} =
  ;     - 0.5 * {(z1+z0)*(y1-y0) + (z2+z1)*(y2-y1) + ...}
  ; B =   0.5 * {(z0*x1-z1*x0) + (z1*x2-z2*x1) + ...} =
  ;     - 0.5 * {(x1+x0)*(z1-z0) + (x2+x1)*(z2-z1) + ...}
  ; C =   0.5 * {(x0*y1-x1*y0) + (x1*y2-x2*y1) + ...} =
  ;     - 0.5 * {(y1+y0)*(x1-x0) + (y2+y1)*(x2-x1) + ...}
  ; where: (xn, yn, zn) = (x0, y0, z0), to close the polygon

  on_error, 2

  ; Try to do the calculations in double precision here
  nVERT = n_elements(Xvert)
  xx = make_array(nVERT, /DOUBLE, VALUE = 0.0)
  yy = xx & zz = xx
  xx[*] = Xvert[*]
  yy[*] = Yvert[*]
  zz[*] = Zvert[*]
  
  x0 = xx & x1 = [ x0[1:*], x0[0] ]
  y0 = yy & y1 = [ y0[1:*], y0[0] ]
  z0 = zz & z1 = [ z0[1:*], z0[0] ]

  ; Calculate the normal vector coefficients aa, bb and cc
  ; and the equation of the plane
  cX = mean(xx)
  cY = mean(yy)
  cZ = mean(zz)
  aa = ZeroFloatFix( - 0.5 * total( (z1 + z0) * (y1 - y0) ) )
  bb = ZeroFloatFix( - 0.5 * total( (x1 + x0) * (z1 - z0) ) )
  cc = ZeroFloatFix( - 0.5 * total( (y1 + y0) * (x1 - x0) ) )
  dd = ZeroFloatFix( - aa * cX - bb * cY - cc * cZ )

  nvect = [aa, bb, cc]
  plane = [aa, bb, cc, dd]

  denom = sqrt(aa*aa + bb*bb + cc*cc)
  unvect = (denom gt 0.000001) ? nvect / denom : [0.0d, 0.0d, 0.0d]

  return, unvect
end

FUNCTION SurfNormal,            $
           Xvert, Yvert, Zvert, $
           X1, Y1, Z1,          $
           NVECT = nvect,       $
           PLANE = plane,       $
           CW = cw,             $
           CCW = ccw

  on_error, 2

  if ( (size(Xvert, /N_DIMENSIONS) ne 1) and $
       (size(Yvert, /N_DIMENSIONS) ne 1) and $
       (size(Zvert, /N_DIMENSIONS) ne 1) ) then $
    message, 'Only 1-D arrays are supported'

  nVERT = n_elements(Xvert)
  if (nVERT le 2) then $
    message, 'Not enough vertices supplied'
  
  if ( (nVERT ne n_elements(Yvert)) and $
       (nVERT ne n_elements(Zvert)) ) then begin
    message,'X, Y and Z arrays must have same size'
  endif

  do_cw  = keyword_set(cw)
  do_ccw = keyword_set(ccw)
  if ((do_cw + do_ccw) gt 1) then $
    message, 'only one of the keywords CW/CCW should be set'

  ; Use this to force conversion to float or double if necessary
  dbl = size(1d, /TYPE)
  do_double = (size(Xvert, /TYPE) eq dbl) or $
              (size(Yvert, /TYPE) eq dbl) or $
              (size(Zvert, /TYPE) eq dbl)

  ; Try to do the calculations in double precision here
  nVERT = n_elements(Xvert)
  xx = make_array(nVERT, /DOUBLE, VALUE = 0.0)
  yy = xx & zz = xx
  xx[*] = Xvert[*]
  yy[*] = Yvert[*]
  zz[*] = Zvert[*]

  ; Get a first estimate of the normal vector
  unvect = get_a_surfnorm(xx, yy, zz, NVECT = nvect, PLANE = plane)

  ; Check if the user explicitly requested a clockwise (CW) or a
  ; counter-clockwise (CCW) arrangement of the coordinates and
  ; adjust accordingly. In any other case do nothing.
  if ((do_cw + do_ccw) eq 1) then begin
    maxval = max(abs(unvect))
    idx = where(abs(unvect) lt maxval, icnt)
    if (icnt eq 2) then begin
      oXYZ = [ transpose(xx), transpose(yy), transpose(zz) ]
      nXY = oXYZ[idx, *]

      nXMin = min(nXY[0,*], max = nXMax)
      nYMin = min(nXY[1,*], max = nYMax)
      cX = (nXMin + nXMax) / 2.0
      cY = (nYMin + nYMax) / 2.0

      angDiff = atan(nXY[1,*] - cY, nXY[0,*] - cX)

     if do_ccw then begin
        negInd = where(angDiff lt 0.0)
        if (negInd[0] ge 0L) then angDiff[negInd] = angDiff[negInd] + (2.0 * !PI)
        sortInd = sort(temporary(angDiff))
      endif else begin
        negInd = where(angDiff gt 0.0)
        if (negInd[0] ge 0L) then angDiff[negInd] = angDiff[negInd] - (2.0 * !PI)
        sortInd = sort(temporary(abs(angDiff)))
      endelse

      xx = xx[sortInd]
      yy = yy[sortInd]
      zz = zz[sortInd]

      unvect = get_a_surfnorm(xx, yy, zz, NVECT = nvect, PLANE = plane)
    endif
  endif

  X1 = (do_double eq 0) ? float(xx)  : xx
  Y1 = (do_double eq 0) ? float(yy)  : yy
  Z1 = (do_double eq 0) ? float(zz)  : zz

  nvect  = (do_double eq 0) ? float(nvect)  : nvect
  unvect = (do_double eq 0) ? float(unvect) : unvect
  plane  = (do_double eq 0) ? float(plane)  : plane

  return, unvect
end
