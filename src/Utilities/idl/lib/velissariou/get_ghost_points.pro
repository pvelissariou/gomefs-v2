Pro Get_Ghost_Points, x0, y0, x1, y1, ghstX, ghstY, $
                      NX = nx, NY = ny,             $
                      OFF = off
;+++
; NAME:
;	Get_Ghost_Points
; VERSION:
;	1.0
; PURPOSE:
;	To create a set of ghost points enclosing the model domain.
; CALLING SEQUENCE:
;	Get_Ghost_Points, x0, y0, x1, y1, ghstX, ghstY
;	On input:
;	    x0 - The minimum x-coordinate of the enclosing rectangle
;                x0, y0, x1, y1 (longitude in degrees, or cartesian)
;	    y0 - The minimum y-coordinate of the enclosing rectangle
;                x0, y0, x1, y1 (latitude in degrees, or cartesian)
;	    x1 - The maximum x-coordinate of the enclosing rectangle
;                x0, y0, x1, y1 (longitude in degrees, or cartesian)
;	    y1 - The maximum y-coordinate of the enclosing rectangle
;                x0, y0, x1, y1 (latitude in degrees, or cartesian)
;
;	Optional parameters:
;	      NX - The number of the ghost points in the x-direction,
;                  default: nx = 10 (longitude, or X)
;	      NY - The number of the ghost points in the y-direction,
;                  default: ny = 10 (latitude, or Y)
;	     OFF - The additional offset in the x- and y-directions if
;                  other than (0.0, 0.0) - a two element vector
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

  ; ... the number of the ghost points in both directions.
  thisNX = (n_elements(nx) eq 0) ? 10 : round(abs(nx[0]))
  thisNY = (n_elements(ny) eq 0) ? 10 : round(abs(ny[0]))

  ; Determine the offset in the x- and the y-direction
  thisOFF = [0.0, 0.0]
  if (n_elements(off) ne 0) then begin
    if (n_elements(off) lt 2) then begin
      thisOFF[0] = off[0]
      thisOFF[1] = off[0]
    endif else begin
      thisOFF[0] = off[0]
      thisOFF[1] = off[1]
    endelse
  endif
  
  thisX0 = min([x0, x1]) - thisOFF[0]
  thisX1 = max([x0, x1]) + thisOFF[0]
  thisY0 = min([y0, y1]) - thisOFF[1]
  thisY1 = max([y0, y1]) + thisOFF[1]

  xx = thisX0 + indgen(thisNX) * ( (thisX1 - thisX0) / float(thisNX - 1) )
  yy = thisY0 + indgen(thisNY) * ( (thisY1 - thisY0) / float(thisNY - 1) )

  ghstX = dblarr(2 * (thisNX + thisNY - 2))
  ghstY = ghstX

    n1 = 0 & n2 = n1 + thisNX - 1
  ghstX[n1:n2] = xx
  ghstY[n1:n2] = yy[0]
    n1 = n2 + 1 & n2 = n1 + thisNY - 3
  ghstX[n1:n2] = xx[thisNX - 1]
  ghstY[n1:n2] = yy[1:thisNY - 2]
    n1 = n2 + 1 & n2 = n1 + thisNX - 1
  ghstX[n1:n2] = reverse(xx)
  ghstY[n1:n2] = yy[thisNY - 1]
    n1 = n2 + 1 & n2 = n1 + thisNY - 3
  ghstX[n1:n2] = xx[0]
  ghstY[n1:n2] = reverse(yy[1:thisNY - 2])

end
