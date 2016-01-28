;+++
; NAME:
;	VL_SORTVERT
; VERSION:
;	1.0
; PURPOSE:
;	To perform sorting of the vertices of a shape.
; CALLING SEQUENCE:
;	VL_SortVert, xdat, ydat [,Keywords]
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
;	   The [2, *] array of the sorted coordinates.
;
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	 Created: Tue Oct 29 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;	Modified:
;+++
FUNCTION VL_SortVert, xdat, ydat, CW = cw

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
  
  cw = (keyword_set(cw) eq 1) ? 1 : 0
  ; ----------

  ; Sort the vertices into counter-clockwise order.
  xmin = min(xdat, MAX = xmax)
  ymin = min(ydat, MAX = ymax)
  cx = (xmin + xmax) / 2.0
  cy = (ymin + ymax) / 2.0

  angDIFF = ZeroFloatFix( atan(ydat - cy, xdat - cx) )

  idxNEG = where(angDIFF lt 0.0, icntNEG)
  if (icntNEG ne 0) then $
    angDIFF[idxNEG] = angDIFF[idxNEG] + (2.0 * !PI)

  idxSORT = sort(angDIFF)
  if (cw gt 0) then idxSORT = reverse(idxSORT)

  xout = xdat[idxSORT]
  yout = ydat[idxSORT]

  return, [ transpose(xout), transpose(yout) ]

end
