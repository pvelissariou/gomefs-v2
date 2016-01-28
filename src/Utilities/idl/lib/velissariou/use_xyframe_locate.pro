Function use_xyframe_locate, lon, lat
;+++
; NAME:
;	USE_XYFRAME_LOCATE
; VERSION:
;	1.0
; PURPOSE:
;	To return the floating indeces (ix, iy) where the point is located
;       within the 2-D grid of latitude and longitude values.
; CALLING SEQUENCE:
;	USE_XYFRAME_LOCATE(lat, lon)
;         lon  = longitude of the point in question
;         lat  = latitude of the point in question
; RETURNS:
;	A vector with the indexes (as floating numbers) of the point
;       (relative to the model grid)
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

  on_error, 2

  COMMON BathParams

  numtypes = [2, 3, 4, 5]

  msgout = "you need to supply valid values for <lat> and <lon>."
  if ( n_params() lt 2 ) then message, msgout

  msgout = "<lon> should be a real number."
  if ( where(size(lon, /type) eq numtypes) eq -1 ) then message, msgout

  msgout = "<lat> should be a real number."
  if ( where(size(lat, /type) eq numtypes) eq -1 ) then message, msgout

  thisLON = abs(Double(lon))
  thisLAT = Double(lat)

  xd  = xdist(thisLAT, thisLON)
  yd  = ydist(thisLAT, thisLON)

  ix  = (xd - GridX0) / Double(GridXSZ)
  iy  = (yd - GridY0) / Double(GridYSZ)

  return, [ix, iy]

end
