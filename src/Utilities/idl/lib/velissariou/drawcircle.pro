PRO DrawCircle,              $
      xc,                    $
      yc,                    $
      Radius = radius,       $
      Color  = color,        $
      LineColor = linecolor, $
      LineThick = linethick, $
      Fill = fill,           $
      Data = data,           $
      Device = device,       $
      Normal = normal
;+++
; NAME:
;       DrawCircle
;
; PURPOSE:
;       This is routine for drawing a circle (filled or, not) on a map or, other display.
;
; AUTHOR:
;       Panagiotis Velissariou
;       E-mail: velissariou.1@osu.edu
;
; CATEGORY:
;       Graphics.
;
; CALLING SEQUENCE:
;       DrawCircle, xc, yc, [keywords]
;
;                 xc:   The X location of the center of the station plot expressed in
;                        DATA, DEVICE or, NORMAL coordinates.
;                 yc:   The Y location of the center of the station plot, expressed in
;                        DATA, DEVICE or, NORMAL coordinates.
;
; KEYWORD PARAMETERS:
;       Radius      :   The radius of the station plot circle in NORMALIZED coordinates.
;                        The radius of the inner circle is calculated as 0.4 * radius.
;                        Default :  0.02
;       Color       :   The name of the color to fill the circle.
;                        May be a vector the same length as X. Colors are those available
;                        in the procedure "LoadColors".
;                        Default :  'Yellow'
;       LineColor   :   The name of the color to use when drawing the circumference.
;                        May be a vector the same length as X. Colors are those available
;                        in the procedure "LoadColors".
;                        Default :  'Black'
;       LineThick   :   The thickness of the line used when drawing the circumference.
;                        Default :  1.0
;       Fill        :   Set this keyword if the circle is to be filled.
;                        Default :  NO FILL
;       Data        :   Set this keyword if (x, y) are in data coordinates (default).
;                        Default :  THIS IS THE DEFAULT
;       Device      :   Set this keyword if (x, y) are in device coordinates.
;                        Default :
;       Normal      :   Set this keyword if (x, y) are in normal coordinates.
;                        Default :
;
; RESTRICTIONS:
;       Requires GetColor
;
; EXAMPLE:
;   seed = -3L
;   lon = Randomu(seed, 20) * 360 - 180
;   lat = Randomu(seed, 20) * 180 - 90
;   speed = Randomu(seed, 20) * 100
;   direction = Randomu(seed, 20) * 180 + 90
;   Erase, Color = GetColor('White')
;   Map_Set, /Cylindrical,Position=[0.1, 0.1, 0.9, 0.9], Color = GetColor('Steel Blue'), /NoErase
;   Map_Grid, Color = GetColor('Seashell')
;   Map_Continents, Color = GetColor('Sea Green')
;   DrawCircle, lon, lat, Color = 'Yellow'
;
; MODIFICATION HISTORY:
;       Written by:  Panagiotis Velissariou, March 24, 2005.
;+++

; Return to caller in event of an error.
On_Error, 2

; Correct number of positional parameters?
IF N_Params() NE 2 THEN BEGIN
   Print, 'Correct Syntax:  DrawStation, x, y, Radius=radius, Color=color'
   Message, 'Incorrect number of positional parameters'
ENDIF

; Check for Data, Device or, Normal coordinates (default is data)
data   = Keyword_Set(data)
device = Keyword_Set(device)
normal = Keyword_Set(normal)
if data + device + normal gt 1 then begin
  print,' set only one of /DATA, /DEVICE, or /NORMAL.'
  return
endif
if data eq 0 then data = 1 - (device > normal)

; Check keyword values.
IF N_Elements(radius) EQ 0 THEN BEGIN
   IF Total(!X.Window) EQ 0 THEN BEGIN
      radius = 1.0 / 50.0
   ENDIF ELSE BEGIN
      radius = (!X.Window[1] - !X.Window[0]) / 50.0
   ENDELSE
ENDIF
nradius = Convert_Coord(radius, 0, /Normal, /To_Device)
nradius = Round(nradius[0])

CASE N_Elements(color) of
     0: thisColor = Make_Array(N_Elements(xc), /String, Value=GetColor('Yellow'))
     1: thisColor = Replicate(color, N_Elements(xc))
  else: thisColor = color
ENDCASE

CASE N_Elements(linecolor) of
     0: thisLineColor = Make_Array(N_Elements(xc), /String, Value=GetColor('Black'))
     1: thisLineColor = Replicate(linecolor, N_Elements(xc))
  else: thisLineColor = linecolor
ENDCASE

CASE N_Elements(linethick) of
     0: thisLineThick = Make_Array(N_Elements(xc), /String, Value = 1.0)
     1: thisLineThick = Replicate(linethick, N_Elements(xc))
  else: thisLineThick = linethick
ENDCASE

; Initial variables.
x = 0
y = nradius
d = 3 - 2 * nradius
step = ceil(float(nradius) / 120.0 > 0)

; Find the X and Y coordinates for one-eighth of a circle.
xhalfquad = Make_Array(nradius + 1, /Integer)
yhalfquad = xhalfquad
path = 0

WHILE x LT y DO BEGIN
   xhalfquad[path] = x
   yhalfquad[path] = y
   path = path + 1

   IF d LT 0 THEN BEGIN
      d = d + (4*x) + 6
   ENDIF ELSE BEGIN
      d = d + (4 * (x-y)) + 10
      y = y - step
   ENDELSE
   x = x + step
ENDWHILE

; Fill in last point, if needed.
IF x EQ y THEN BEGIN
   xhalfquad[path] = x
   yhalfquad[path] = y
   path = path + 1
ENDIF

; Shrink the arrays to their correct size.
xhalfquad = xhalfquad[0:path-1]
yhalfquad = yhalfquad[0:path-1]

; Convert the eighth circle into a quadrant.
xquad = [xhalfquad, Rotate(yhalfquad, 5)]
yquad = [yhalfquad, Rotate(xhalfquad, 5)]

; Prepare to convert the quadrants into a full circle.
xquadrev = Rotate(xquad[0L:2L*path-2], 5)
yquadrev = Rotate(yquad[0L:2L*path-2], 5)

; Create full-circle coordinates.
x = [xquad, xquadrev, -xquad[1:*], -xquadrev]
y = [yquad, -yquadrev, -yquad[1:*], yquadrev]

; Plot the coordinates about the given center after converting
; to DEVICE coordinates.
coord = Convert_Coord(xc, yc, Data = data, Device = device, Normal = normal, /To_Device)
xcenter = Round(coord[0,*])
ycenter = Round(coord[1,*])

FOR j=0L, N_Elements(xcenter)-1 DO BEGIN
  IF Keyword_Set(fill) THEN $
    Polyfill, x + xcenter[j], y + ycenter[j], $
              Color = thisColor[j], /Device
    Plots, x + xcenter[j], y + ycenter[j], $
           Color = thisLineColor[j], Thick = thisLineThick[j], /Device
ENDFOR

END
