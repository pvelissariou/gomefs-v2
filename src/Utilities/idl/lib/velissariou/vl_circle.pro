;--------------------
Function CheckScalarNum, val

error = 0
numtypes = [2, 3, 4, 5, 12, 13, 14, 15]

if (size(val, /dimensions) ne 0) then error = 1
if (where(size(val, /type) eq numtypes) eq -1) then error = 2

return, error

end

;--------------------
pro VL_Circle, xc, yc, CIRCLESIZE = circlesize, SCALE = scale, $
            LINETHICK = linethick, LINECOLOR = linecolor, $
            FILLIT = fillit, FILLCOLOR = fillcolor, $
            DATA = data, DEVICE = device

on_error, 2

;------------------------------------------------------------
; check input parameters
if (n_params() lt 2) then $
  message, "need to specify valid values for all: <XC, YC>."

if CheckScalarNum(xc) then $
  message, "need to specify a valid scalar value for: <XC>."

if CheckScalarNum(yc) then $
  message, "need to specify a valid scalar value for: <YC>."

;------------------------------------------------------------
; go through the optional input parameters/keywords
if (n_elements(circlesize) eq 0) then begin
  circlesize = 1.0
endif else begin
  if CheckScalarNum(circlesize) then $
    message, "need to specify a valid scalar value for: <CIRCLESIZE>."
  circlesize = abs(circlesize) < 100
endelse

scaleme = 1.0
yscale = 1.0
if keyword_set(scale) then begin
  scaleme = float(!D.Y_Size) / float(!D.X_Size)
endif

if (n_elements(linethick) eq 0) then begin
  linethick = 1.0
endif else begin
  if CheckScalarNum(linethick) then $
    message, "need to specify a valid scalar value for: <LINETHICK>."
  linethick = abs(linethick)
endelse

if (n_elements(linecolor) eq 0) then begin
  linecolor = !P.COLOR
endif else begin
  if CheckScalarNum(linecolor) then $
    message, "need to specify a valid scalar value for: <LINECOLOR>."
  linecolor = round(abs(linecolor))
endelse

if (n_elements(fillcolor) eq 0) then begin
  fillcolor = !P.COLOR
endif else begin
  if CheckScalarNum(fillcolor) then $
    message, "need to specify a valid scalar value for: <FILLCOLOR>."
  fillcolor = round(abs(fillcolor))
endelse

;------------------------------------------------------------
; start calculations
normal = 1

; the center of the circle (in normal coordinates)
xyc = [xc, yc, 0.0]
if keyword_set(data) then begin
  normal = 0 & data = 1 & device = 0
  xyc = convert_coord(xyc[0], xyc[1], /DATA, /TO_NORMAL)
endif else begin
  if keyword_set(device) then begin
    normal = 0 & data = 0 & device = 1
    xyc = convert_coord(xyc[0], xyc[1], /DEVICE, /TO_NORMAL)
  endif
endelse

; the circle perimeter points (in normal coordinates)
xy = VL_CirclePoints(xyc[0], xyc[1], 0.01 * circlesize)
; transform back to data/device coordinates (if applicable)
if keyword_set(data) then begin
  xy = convert_coord(xy[0,*], xy[1,*], /NORMAL, /TO_DATA)
endif else begin
  if keyword_set(device) then $
    xy = convert_coord(xy[0,*], xy[1,*], /NORMAL, /TO_DEVICE)
endelse

xy[0, *] = xc + (xy[0, *] - xc) * (scaleme)

;xy[1, *] = yc + (xy[1, *] - yc) * scaleme

print, float(!D.Y_Size) / float(!D.X_Size)
print, ''
print, ''
for i= 0,90 do begin
print, i, xy[0, i] - xc, xy[1, i] - yc
endfor

;------------------------------------------------------------
; do the plotting
if keyword_set(fillit) then begin
  polyfill, xy[0, *], xy[1, *], $
            NORMAL = normal, DATA = data, DEVICE = device, $
            COLOR = fillcolor
  plots, xy[0, *], xy[1, *], $
         NORMAL = normal, DATA = data, DEVICE = device, $
         COLOR = linecolor, THICK = linethick
endif else begin
  plots, xy[0, *], xy[1, *], $
         NORMAL = normal, DATA = data, DEVICE = device, $
         COLOR = linecolor, THICK = linethick
endelse

end
