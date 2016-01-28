Pro Get_Ghost_CirclePoints, x0, y0, rd, ghstX, ghstY, NPOINTS = npoints
;+++
; NAME:
;	Get_Ghost_CirclePoints
; VERSION:
;	1.0
; PURPOSE:
;	To create a set of ghost points enclosing the model domain.
; CALLING SEQUENCE:
;	Get_Ghost_CirclePoints, x0, y0, x1, y1, ghstX, ghstY
;	On input:
;	    x0 - The center x-coordinate of the enclosing circle
;	    y0 - The center y-coordinate of the enclosing circle
;	   rad - The radius of the enclosing circle
;                x0, y0 (latitude in degrees, or cartesian)
;
;	Optional parameters:
;	 NPOINTS - The number of the ghost points,
;                  default: npoints = 60
;
;	Keywords:
;
;	On output:
;	   ghstX - The X-coordinates of the ghost points (longitude, or X)
;	   ghstY - The Y-coordinates of the ghost points (latitude, or Y)
;
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created Sat Nov 24 2012 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  ; Error handling.
  Catch, theError
  If theError ne 0 Then Begin
    Catch, /Cancel
    Help, /Last_Message
    Return
  EndIf

  ; ... the number of the ghost points.
  thisPNTS = (n_elements(npoints) eq 0) ? 60 : round(abs(npoints[0]))
  
  xy = VL_CirclePoints(x0, y0, rd, thisPNTS)

  ghstX = transpose(xy[0, *])
  ghstY = transpose(xy[1, *])

end
