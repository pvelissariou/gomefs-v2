PRO DrawArrow2,        $
      position,        $
      xlen,            $
      ylen,            $
      color = color,   $
      hsize = hsize,   $
      hthick = hthick, $
      thick = thick,   $
      solid = solid,   $
      scale = scale,   $
      data = data,     $
      normal = normal
;+++
; NAME:
;	DrawArrow2
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;	this procedure plots an arrow in the specified location.
;
; CATEGORY:
;	Graphics
;
; CALLING SEQUENCE:
;	DrawArrow2, position, xlen, ylen, [keywords]
;
;       position    :   A 2-element vector containing the position
;                        ([x, y]) of the arrow origin.
;
; KEYWORD PARAMETERS:
;	xlen       :   The length of the x-component of the arrow.
;                        Default :  NONE
;	ylen       :   The length of the y-component of the arrow.
;                        Default :  NONE
;       color       :   An integer for the color index to use as an arrow
;                        color.
;                        Default :  !P.COLOR
;       hsize       :   The length of the lines used to draw the arrowheads.
;                        Default :  1.0
;       hthick      :   The thickness of the arrowheads.
;                        Default :  1.0
;       thick       :   A thickness of the arrow body.
;                        Default :  1.0
;       solid       :   Set this keyword to make a solid arrow, using polygon
;                        fills, looks better for thick arrows.
;                        Default :  no fill
;       rotation    :   Use this keyword to rotate the arrow counter-clock-wise
;                        at an angle (in degrees).
;                        Default :  0.0 (no rotation)
;       scale       :   Use this keyword to scale the arrow by a factor.
;                        Default :  1.0 (no scaling)
;
; PROCEDURE:
;	this procedure uses the input values to construct an arrow
;	at the specified position.
;
; EXAMPLE:
;	Create an arrow at [0.5, 0.5].
;	  DrawArrow2, [0.5, 0.5], 0.1, -0.2, color = 3, /solid, /data
;
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

; ---------- check for the input variables
if (n_elements(position) eq 0) then $
  message, 'please supply a float or, integer 2 element vector for <position>'

if (n_elements(xlen) eq 0) then $
  message, 'please supply a number for <xlen>'

if (n_elements(ylen) eq 0) then $
  message, 'please supply a number for <ylen>'


xx = float(xlen[0])
yy = float(ylen[0])

length = sqrt(xx * xx + yy * yy)

alpha = atan(yy, xx) / !DTOR

DrawArrow, position, length, color = color, $
           hsize = hsize, hthick = hthick, thick = thick, $
           solid = solid, rotation = alpha, scale = scale, $
           data = data, normal = normal
      
return

end
