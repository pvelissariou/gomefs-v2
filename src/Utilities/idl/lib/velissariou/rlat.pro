Function RLat, x, y
;+++
; NAME:
;	RLat
; VERSION:
;	1.0
; PURPOSE:
;	To return the latitude of a point on the grid described by the arrays "rparm"
;	and "iparm", given x and y displacements from the grid origin
; CALLING SEQUENCE:
;	RLat(x, y)
;         Where "x" is the x-distance from the grid origin (m) and
;               "y" is the y-distance from the grid origin (m).
; RETURNS:
;	The latitude of the point (x,y).
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

  if ( n_params() lt 2 ) then $
    message, "you need to supply valid values for <x> and <y>"

  itis = size( x, /TYPE )
  if ((itis ne 2) and (itis ne 4) and (itis ne 5)) then $
    message, "the value supplied for <x = " + strtrim(string(x), 2) + "> is not a valid number."

  itis = size( y, /TYPE )
  if ((itis ne 2) and (itis ne 4) and (itis ne 5)) then $
    message, "the value supplied for <y = " + strtrim(string(y), 2) + "> is not a valid number."

  COMMON BathParams
 
  alpha = Double( rparm[6] * !DTOR )

; Transform the points to the 'primed' coordinate system,
; ie., that of the standard bathymetric grid

; first translate
  xx = Double( x - iparm[2] * GridXSZ )
  yy = Double( y - iparm[3] * GridYSZ )

; now  rotate
  xp = Double( xx * cos(alpha) - yy * sin(alpha) )
  yp = Double( yy * cos(alpha) + xx * sin(alpha) )

; transformation for approximate polyconic projection
  if(iparm[4] eq 0) then begin
    xp   = Double( xp / 1000.0 ) ; need it in kilometers here
    yp   = Double( yp / 1000.0 ) ; need it in kilometers here
    lout = Double( rparm[19] * xp + rparm[20] * yp + $
                   rparm[21] * xp * yp + rparm[22] * xp * xp )
    lout = Double( rparm[0] + lout )
  endif

; transformation for lambert conformal conic projection
  if(iparm[4] eq 1) then begin
   xp   = Double( xp + rparm[12] )
   yp   = Double( yp + rparm[13] )
   xx   = Double( xp / rparm[11] )
   yy   = Double( yp / rparm[11] )
   r    = Double( sqrt(xx * xx + yy * yy) )
   lout = Double( 360.0D * (!PI / 4.0 - atan(r^(1.0 / rparm[10]))) / !PI )
  endif

  return, lout

end
