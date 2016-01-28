;-------------------------------------------------------------
;+
; NAME:
;       ARCS
; PURPOSE:
;       Plot specified arcs or circles on the current plot device.
; CATEGORY:
; CALLING SEQUENCE:
;       arcs, r, a1, a2, [x0, y0]
; INPUTS:
;       r = radii of arcs to draw (data units).                  in
;       [a1] = Start angle of arc (deg CCW from X axis, def=0).  in
;       [a2] = End angle of arc (deg CCW from X axis, def=360).  in
;       [x0, y0] = optional arc center (def=0,0).                in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE means use device coordinates .
;         /DATA means use data coordinates (default).
;         /NORM means use normalized coordinates.
;         /NOCLIP means do not clip arcs to the plot window.
;         COLOR=c  plot color (scalar or array).
;         LINESTYLE=l  linestyle (scalar or array).
;         THICKNESS=t  line thickness (scalar or array).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: all parameters may be scalars or arrays.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 12 July, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;       R. Sterner, 17 Jun, 1992 --- added coordinate systems, cleaned up.
;       R. Sterner, 1997 Feb 24 --- Added THICKNESS keyword.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	Function ArcPoints, r, a1, a2, xx, yy, n_points, $
                 degrees = degrees
 
 	np = n_params(0)
	if (np lt 1) or keyword_set(hlp) then begin
	  print,' Plot specified arcs or circles on the current plot device.'
	  print,' arcs, r, a1, a2, [x0, y0]'
	  print,'   r = radii of arcs to draw (data units).                  in'
	  print,'   [a1] = Start angle of arc (deg CCW from X axis, def=0).  in'
	  print,'   [a2] = End angle of arc (deg CCW from X axis, def=360).  in'
	  print,'   [x0, y0] = optional arc center (def=0,0).                in'
	  print,' Keywords:'
	  print,' Note: all parameters may be scalars or arrays.'
	  return, 1
	endif
 
 
 	if np lt 2 then a1 = 0.
 	if np lt 3 then a2 = 360.
	if np lt 4 then xx = 0.
	if np lt 5 then yy = 0.

        thisDIVR = 0
        if (n_elements(divrad) ne 0) then $
          thisDIVR = divrad le 0 ? 0 : 1

        ; set the number of points
        thisPNTS = long(n_points)
        if (thisPNTS le 0) then thisPNTS = 10

        thisR = double(r)
        thisA1 = double(a1)
        thisA2 = double(a2)

        da = (thisA2 - thisA1) / thisPNTS
        a = thisA1 + da * dindgen(1 + thisPNTS )

	PolRec, thisR, a, x, y, degrees = degrees

	return, transpose([[x],[y]])
 
	end
