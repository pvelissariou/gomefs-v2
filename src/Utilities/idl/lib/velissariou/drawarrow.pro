PRO DrawArrow,                 $
      position,                $
      length,                  $
      color = color,           $
      hsize = hsize,           $
      hthick = hthick,         $
      thick = thick,           $
      solid = solid,           $
      rotation = rotation,     $
      scale = scale,           $
      data = data,             $
      normal = normal
;+++
; NAME:
;	DrawArrow
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;	This procedure plots an arrow in the specified location.
;
; CATEGORY:
;	Graphics
;
; CALLING SEQUENCE:
;	DrawArrow, Position, Label, [keywords]
;
;       position    :   A 2-element vector containing the position
;                        ([x, y]) of the arrow origin.
;
; KEYWORD PARAMETERS:
;	length      :   The length of the arrow.
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
;	This procedure uses the input values to construct an arrow
;	at the specified position.
;
; EXAMPLE:
;	Create an arrow at [0.2, 0.2].
;	  DrawArrow, [0.2, 0.2], 0.05, rotation = 30.0, color = 3, /solid, /data
;
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

; ---------- check for the input variables
; Position
if (n_elements(position) ne 2) then $
  message, 'please supply a float or, integer 2 element vector for <position>'
ThisPosition = float([position[0], position[1]])

; Length
if (n_elements(length) eq 0) then $
  message, 'please supply a float or, integer number for <length>'
ThisLength = float(length[0])

; Color
ThisColor = n_elements(color) eq 0 ? !P.COLOR : 255 - (255 - fix(abs(color)) > 0)

; Hsize
defHsize = float(!D.X_SIZE) / 64.0
thisHsize = n_elements(hsize) eq 0 ? defHsize : abs(float(hsize[0]) * defHsize)

; Hthick
thisHthick = n_elements(hthick) eq 0 ? 1.0 : abs(float(hthick[0]))

; Thick
thisThick = n_elements(thick) eq 0 ? 1.0 : abs(float(thick[0]))

; Rotation
thisRotation = n_elements(rotation) eq 0 ? 0.0 : float(rotation[0])

; Scale
thisScale = n_elements(scale) eq 0 ? 1.0 : float(scale[0])

; Determine arrow position accounting for rotation/scaling
thisShape = [[thisPosition[0], thisPosition[1]], $
             [thisPosition[0] + thisLength, thisPosition[1]]]
thisShape = Transform2DShape(thisShape, rotation = thisRotation, $
               center = [thisPosition[0], thisPosition[1]], $
               scale = thisScale)

x0 = thisShape[0, 0]
y0 = thisShape[1, 0]
x1 = thisShape[0, 1]
y1 = thisShape[1, 1]

; Adjust for scaling
thisHsize  = thisScale * thisHsize
thisHthick = thisScale * thisHthick
thisThick  = thisScale * thisThick

; Plot the arrow
Arrow, x0, y0, x1, y1, color = thisColor, $
       hsize = thisHsize, hthick = thisHthick, thick = thisThick, $
       solid = solid, data = data, normalized = normal

return

end
