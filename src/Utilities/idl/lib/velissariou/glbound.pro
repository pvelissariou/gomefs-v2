;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure : GLBOUND
; Call      : GLBOUND, filename (the shoreline data file)
; Purpose   : to plot state, county, ... boundaries according to GLERL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO GLBOUND, filename

savcolor  = !P.COLOR

white  = 0
black  = 1
red    = 2
green  = 7
blue   = 11
yellow = 42

!P.COLOR  = black
thiscolor = !P.COLOR

openr, 2, filename

on_ioerror, endloop

loop1:
  readf, 2, n, id
  lon = fltarr(n)
  lat = fltarr(n)
  readf, 2, lat, lon

  ; state and national boundaries red
  if(id lt 9) then thiscolor = red

  ; counties yellow
  if(id ge 9 and id le 10) then thiscolor = yellow

  ; other boundaries green
  if(id gt 10) then thiscolor = green

  ; national, state and county boundaries in water
  if(id eq 10 or id eq 6 or id eq 2) then goto, loop1

  ; check for permanent water bodies
  if(id gt 21) then goto, loop1
  plots, -lon, lat, color = thiscolor
  goto, loop1
endloop:

close, 2

!P.COLOR = savcolor

return

end
