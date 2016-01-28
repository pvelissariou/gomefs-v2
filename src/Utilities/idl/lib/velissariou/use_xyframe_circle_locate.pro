Function use_xyframe_circle_locate, lat0, lon0, lat, lon, R
;+++
; NAME:
;	USE_XYFRAME_CIRCLE_LOCATE
; VERSION:
;	1.0
; PURPOSE:
;	To return the indeces (lix, liy, uix, uiy) where the cicle is located
;       within the 2-D grid of latitude and longitude values.
; CALLING SEQUENCE:
;	USE_XYFRAME_CIRCLE_LOCATE(lat0, lon0, lat, lon, R)
;         lat0 = latitude of the grid origin (I, J) = (0,0)
;         lon0 = longitude of the grid origin (I, J) = (0,0)
;         lat  = latitude of the center of the cicle
;         lon  = longitude of the center of the cicle
;         R    = radius of the cicle in meters
; RETURNS:
;	A vector with the lower left corner and upper right corner indeces of the
;       rectangular region of the grid that contains the cicle (lat, lon, R)
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

  on_error, 2

  COMMON BathParams
  COMMON GLParams

  numtypes = [2, 3, 4, 5]

  msgout = "you need to supply valid values for <lat0>, <lon0>, <lat>, <lon> and <R>."
  if ( n_params() lt 5 ) then message, msgout

  msgout = "<lat0> should be a real number."
  if ( where(size(lat0, /type) eq numtypes) eq -1 ) then message, msgout

  msgout = "<lon0> should be a real number."
  if ( where(size(lon0, /type) eq numtypes) eq -1 ) then message, msgout

  msgout = "<lat> should be a real number."
  if ( where(size(lat, /type) eq numtypes) eq -1 ) then message, msgout

  msgout = "<lon> should be a real number."
  if ( where(size(lon, /type) eq numtypes) eq -1 ) then message, msgout

  msgout = "<R> should be a real number."
  if ( where(size(R, /type) eq numtypes) eq -1 ) then message, msgout

  thisLON0 = abs(Double(lon0))
  thisLAT0 = Double(lat0)
  thisLON  = abs(Double(lon))
  thisLAT  = Double(lat)
  thisR    = Double(R)

  xd0 = xdist(thisLAT0, thisLON0)
  yd0 = ydist(thisLAT0, thisLON0)
  xd  = xdist(thisLAT, thisLON)
  yd  = ydist(thisLAT, thisLON)
  lix = floor((xd - thisR - xd0) / GridXSZ)
  liy = floor((yd - thisR - yd0) / GridYSZ)
  uix = ceil((xd + thisR - xd0) / GridXSZ)
  uiy = ceil((yd + thisR - yd0) / GridYSZ)

  return, [lix, liy, uix, uiy]

end
