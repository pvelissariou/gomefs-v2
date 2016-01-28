;-------------------------------------------------------------------------------
function aver_angle, angvec, RADIANS=radians
; Default values for angvec are assumed to be in degrees. If
; the keyword RADIANS is specified then the angles are taken
; to be in radians.

  on_error, 1

  if ( n_params() lt 1 ) then $
    message, 'aver_angle: need to specify a vector of values for <angvec>.'

  if (size(angvec, /N_DIMENSIONS) ne 1) then $
    message, 'aver_angle: need to specify a vector of values for <angvec>.'
    
  itis = size( angvec, /TYPE )
  if ((itis ne 2) and (itis ne 4) and (itis ne 5)) then $
    message, 'aver_angle: <angvec> is not a valid number vector.'

  rads = !DTOR
  pi2  = !DPI / 2.0
  if ( keyword_set(radians) eq 1 ) then rads = 1.0

  locvec = rads * double(angvec)
  cosval = total(cos(locvec), /DOUBLE)
  sinval = total(sin(locvec), /DOUBLE)
  magval = (cosval * cosval + sinval * sinval)^(0.5)
  
  cosave = cosval / magval
  sinave = sinval / magval

  case cosave of
    0.0 : begin
            if (sinave eq 1.0 ) then averval = pi2 / rads
            if (sinave eq -1.0) then averval = (3.0 * pi2) / rads
          end
    else: begin
            averval = atan(sinave/cosave) / rads 
          end
  endcase

  if ( averval lt 0.0 ) then $
    averval = averval + (4.0 * pi2) / rads
  if ( averval ge ((4.0 * pi2) / rads) ) then $
    averval = averval - (4.0 * pi2) / rads

  return, averval

end
