Function YDist, lat, lon, Kilometers = kilometers
;+++
; NAME:
;	YDist
; VERSION:
;	1.0
; PURPOSE:
;	To return the y distance in meters from the grid origin
;	described by the arrays rparm and iparm, given the values 
;	of the latitude (lat) and longitude (lon) of the point in lake Erie
; CALLING SEQUENCE:
;	YDist(lat, lon)
;         Where "lat" is the latitude of the point, "lon" is the
;         longitude of the point.
; RETURNS:
;	The y distance in meters from the grid origin.
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

  COMMON BathParams

  if ( n_params() lt 2 ) then $
    message, "you need to supply valid values for <lat> and <lon>"

  itis = size( lat, /TYPE )
  if ((itis ne 2) and (itis ne 4) and (itis ne 5)) then $
    message, "the value supplied for <lat = " + strtrim(string(lat), 2) + "> is not a valid number."

  itis = size( lon, /TYPE )
  if ((itis ne 2) and (itis ne 4) and (itis ne 5)) then $
    message, "the value supplied for <lon = " + strtrim(string(lon), 2) + "> is not a valid number."

  alpha = Double( rparm[6] * !DTOR )

; Find xprime, yprime - distances from the origin of the standard
; bathymetric grid

; transformation for approximate polyconic projection
  if(iparm[4] eq 0) then begin
    dlat = Double( lat - rparm[0] )
    dlon = Double( rparm[1] - lon )
    xp   = Double( rparm[7] * dlon + rparm[8] * dlat + $
                   rparm[9] * dlon * dlat + rparm[10] * dlon * dlon )
    yp   = Double( rparm[11] * dlon + rparm[12] * dlat + $
                   rparm[13] * dlon * dlat + rparm[14] * dlon * dlon )
    xp   = Double( xp * 1000.0D )
    yp   = Double( yp * 1000.0D )
  endif

; transformation for lambert conformal conic projection
  if(iparm[4] eq 1) then begin
    r  = Double( (tan(!PI / 4.0 - !DTOR * lat / 2.0))^(rparm[10]) )
    xp = Double( rparm[11] * r * sin(rparm[10] * (rparm[7] - !DTOR * lon)) )
    yp = Double( - rparm[11] * r * cos(rparm[10] * (rparm[7] - !DTOR * lon)) )
    xp = Double( xp - rparm[12] )
    yp = Double( yp - rparm[13] )
  endif

; transform to 'unprimed' system
;
; first rotate
  dout = Double( yp * cos(alpha) - xp * sin(alpha) )
; now translate
  dout = Double( dout + iparm[3] * GridYSZ )

  kilometers = keyword_set( kilometers )
  if (kilometers eq 1) then dout = dout / 1000.0D

  return, dout

end
