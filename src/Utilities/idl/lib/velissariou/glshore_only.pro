;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure : GLSHORE
; Call      : GLSHORE, filename (the shoreline data file)
; Purpose   : to plot GLERL shoreline
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO GLSHORE_ONLY, filename, DOPLOT = doplot, NOISLANDS = noislands, POINTS = points

savcolor = !P.COLOR

black = getcolor('Black')

!P.COLOR  = black
thiscolor = !P.COLOR

out_points = fltarr(2, 20000)

openr, 2, filename

xs = 0
ys = 0
ns = 0
nns = 0
rw1 = fltarr(8)
gname = ' '

loop:on_ioerror,loop3
readf, 2, gname

if keyword_set(noislands) then $
  if (strpos(strlowcase(gname), 'island') ne -1) then goto, jumpout

loop1:on_ioerror,loop3
rw1=rw1*0.
readf, 2, rw1, format = '(8f9.5)'
loop2:for i=0,6,2 do begin
 if rw1(i) ne 0 then begin
  xs=[xs,rw1[i]]
  ys=[ys,rw1[i+1]]
  ns=ns+1

  out_points[0, nns] = rw1[i]
  out_points[1, nns] = rw1[i+1]
  nns = nns + 1

 endif else begin
  if keyword_set(doplot) then $
    plots, -xs(1:ns), ys(1:ns), color = thiscolor
  xs=0
  ys=0
  ns=0
  goto,loop
 endelse
endfor
goto,loop1
loop3:
on_ioerror,null

jumpout:

close, 2

!P.COLOR = savcolor

points = out_points[*, 0:nns-1]

return

end
