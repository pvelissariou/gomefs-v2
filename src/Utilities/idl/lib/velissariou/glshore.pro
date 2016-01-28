;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure : GLSHORE
; Call      : GLSHORE, filename (the shoreline data file)
; Purpose   : to plot GLERL shoreline
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO GLSHORE, filename

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

xs = 0
ys = 0
ns = 0
rw1 = fltarr(8)
gname = ' '

loop:on_ioerror,loop3
readf, 2, gname
loop1:on_ioerror,loop3
rw1=rw1*0.
readf, 2, rw1, format = '(8f9.5)'
loop2:for i=0,6,2 do begin
 if rw1(i) ne 0 then begin
  xs=[xs,rw1(i)]
  ys=[ys,rw1(i+1)]
  ns=ns+1
 endif else begin
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

close, 2

!P.COLOR = savcolor

return

end
