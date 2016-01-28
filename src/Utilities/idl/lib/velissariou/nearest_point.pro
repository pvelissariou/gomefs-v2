function nearest_point, x, y, d, point, check = check
;+++
; NAME:
;	NEAREST_POINT
; VERSION:
;	1.0
; PURPOSE:
;	Given a cell grid find the cell corner nearest to the supplied
;       point
; CALLING SEQUENCE:
;	NEAREST_POINT(x, y, d, point[, check])
;	   x - A 2-D array containing the x values
;          y - A 2-D array containing the y values
;          d - A 2-D array containing the depths
;          point - The point in the form [x, y]
;          check - A flag to check for land points
; RETURNS:
;	The nearest grid point to the supplied point.
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

  numtypes = [2, 3, 4, 5]

  msgout = "you need to supply valid values for <x>, <y>, <d> and <point>."
  if ( n_params() lt 4 ) then message, msgout

  msgout = "<x> should be a two dimensional array of real numbers."
  if ( size(x, /n_dimensions) ne 2 ) then message, msgout
  if ( where(size(x, /type) eq numtypes) eq -1 ) then message, msgout

  msgout = "<y> should be a two dimensional array of real numbers."
  if ( size(y, /n_dimensions) ne 2 ) then message, msgout
  if ( where(size(y, /type) eq numtypes) eq -1 ) then message, msgout

  msgout = "<d> should be a two dimensional array of real numbers."
  if ( size(d, /n_dimensions) ne 2 ) then message, msgout
  if ( where(size(d, /type) eq numtypes) eq -1 ) then message, msgout

  msgout = "arrays <x>, <y> and <d> should have exactly the same dimensions."
  if ( size(x, /n_elements) ne size(y, /n_elements) ) then message, msgout
  if ( size(x, /n_elements) ne size(d, /n_elements) ) then message, msgout

  msgout = "<point> should be an one dimensional array of real numbers."
  if ( size(point, /n_dimensions) ne 1 ) then message, msgout
  if ( size(point, /n_elements) ne 2 ) then message, msgout
  if ( where(size(point, /type) eq numtypes) eq -1 ) then message, msgout

  s = size(x)
  imax = s[1]
  jmax = s[2]

  pdist = fltarr(imax, jmax)
  corner = [-1, -1]

; set the point as (xp, yp)
  xp = point[0]
  yp = point[1]

  pdist = (x - xp) * (x - xp) + (y - yp) * (y - yp)
  pdist = sqrt(pdist)
  idist = sort(pdist)

  corner[0] = idist[0] mod imax
  corner[1] = (idist[0] - corner[0]) / imax

; min(pdist) = 0.0 means we are on a grid point
  if ((min(pdist) eq 0.0) or (keyword_set(check) eq 0)) then return, corner

  for i = 0, size(idist, /n_elements) - 1 do begin
    corner[0] = idist[i] mod imax
    corner[1] = (idist[i] - corner[0]) / imax
    if ( d[corner[0], corner[1]] ne 0.0 ) then return, corner
  endfor

end
