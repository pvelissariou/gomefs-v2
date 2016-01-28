;+++
; NAME:
;	VL_SHAPEAREA
; VERSION:
;	1.0
; PURPOSE:
;	To calculate the area of a shape given the coordinates of its vertices.
; CALLING SEQUENCE:
;	VL_ShapeArea, xdat, ydat [,Keywords]
;
;	On input:
;	  xdat - The x-coordinates of the data points (a vector)
;	  ydat - The y-coordinates of the data points (a vector)
;
;	Optional parameters:
;
;	Keywords:
;	    CW - Set this keyword to perform clock-wise sorting.
;                  default: counter-clockwise
;
;	On output:
;	   The area of the shape in (x,y) units.
;
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	 Created: Tue Oct 29 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;	Modified:
;+++
FUNCTION VL_ShapeArea, xdat, ydat, CW = cw

  Compile_Opt IDL2

  on_error, 2

  ; ----------
  ; xdat and ydat should have the same number of elements
  sz1 = size(xdat, /N_DIMENSIONS)
  sz2 = size(ydat, /N_DIMENSIONS)
  if ( (sz1 ne 1) or (sz2 ne 1) ) then begin
    message, $
      'xdat and ydat should be vectors'
  endif
  
  ; xdat, ydat and zdat should have the same number of elements
  sz1 = n_elements(xdat)
  sz2 = n_elements(ydat)
  if ( sz1 ne sz2 ) then begin
    message, $
      'xdat and ydat should have the same number of elements'
  endif

  sortdat = (keyword_set(sortdat) eq 1) ? 1 : 0
  cw = (keyword_set(cw) eq 1) ? 1 : 0
  ; ----------

  ; Sort the vertices into counter-clockwise order.
  xy = VL_SortVert(xdat, ydat, CW = cw)
  xout = transpose(xy[0, *])
  yout = transpose(xy[1, *])

  ; Calculate area from the perimeter.
  ; The first point must be the same as the last point. Method
  ; of Russ, p.490, _Image Processing Handbook, 2nd Edition_.
  bx = double(xout)
  by = double(yout)
  bx = [bx, bx[0]]
  by = [by, by[0]]
  n = n_elements(bx)
  area = total( (bx[1:n-1] + bx[0:n-2]) * (by[1:n-1] - by[0:n-2]) ) / 2.0

  return, ZeroFloatFix( area )

end
