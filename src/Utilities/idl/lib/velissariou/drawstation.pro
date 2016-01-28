;+++
; NAME:
;       DrawStation
;
; PURPOSE:
;       This is routine for drawing station plots on a map or other display.
;
; CATEGORY:
;       Graphics.
;
; CALLING SEQUENCE:
;       DrawStation, xc, yc, [keywords]
;
;                 xc:   The X location of the center of the station plot expressed in
;                        DATA, DEVICE or, NORMAL coordinates.
;                 yc:   The Y location of the center of the station plot, expressed in
;                        DATA, DEVICE or, NORMAL coordinates.
;
; KEYWORD PARAMETERS:
;       Radius      :   The radius of the station plot circle in NORMALIZED coordinates.
;                        Default :  0.02
;       Color       :   The name of the color to draw the station plot in. May be a vector
;                        the same length as X. Colors are those available in the procedure
;                        "LoadColors".
;                        Default :  'Yellow'
;       Label       :   The label that accompanies the station plot. May be a vector
;                        the same length as X.
;                        Default :  NONE
;       Lb_Size     :   The charsize for the labels.
;                        Default :  1.0
;       Lb_Font     :   The font to be used for the labels as defined in the function
;                        "TextFont".
;                        Default :  NO FONT CHANGE
;       Lb_Color    :   The color to be used when drawing the labels.
;                        May be a vector the same length as X. Colors are those available
;                        in the procedure "LoadColors".
;                        Default :  'Black'
;       Top         :   Set this keyword to draw the label at the top of the station plot.
;                        Default :  THIS IS THE DEFAULT
;       Bottom      :   Set this keyword to draw the label at the bottom of the station plot.
;                        Default :
;       Left        :   Set this keyword to draw the label at the left of the station plot.
;                        Default :
;       Right       :   Set this keyword to draw the label at the right of the station plot.
;                        Default :
;       Data        :   Set this keyword if (x, y) are in data coordinates (default).
;                        Default :  THIS IS THE DEFAULT
;       Device      :   Set this keyword if (x, y) are in device coordinates.
;                        Default :
;       Normal      :   Set this keyword if (x, y) are in normal coordinates.
;                        Default :
;
; RESTRICTIONS:
;       Requires GetColor, TextFont, TextDims
;
; EXAMPLE:
;   seed = -3L
;   lon = Randomu(seed, 20) * 360 - 180
;   lat = Randomu(seed, 20) * 180 - 90
;   speed = Randomu(seed, 20) * 100
;   direction = Randomu(seed, 20) * 180 + 90
;   Erase, Color=GetColor('White')
;   Map_Set, /Cylindrical,Position=[0.1, 0.1, 0.9, 0.9], Color=GetColor('Steel Blue'), /NoErase
;   Map_Grid, Color=GetColor('Seashell')
;   Map_Continents, Color=GetColor('Sea Green')
;   DrawStation, lon, lat, Color='Indian Red'
;
; MODIFICATION HISTORY:
;      Panagiotis Velissariou, March 24, 2005.
;+++
;###########################################################################
PRO DrawStation,           $
      xc,                  $
      yc,                  $
      Radius   = radius,   $
      Color    = color,    $
      Label    = label,    $
      Lb_Size  = lb_size,  $
      Lb_Font  = lb_font,  $
      Lb_Color = lb_color, $
      Top      = top,      $
      Bottom   = bottom,   $
      Left     = left,     $
      Right    = right,    $
      Data     = data,     $
      Device   = device,   $
      Normal   = normal

; Return to caller in event of an error.
On_Error, 2

; Correct number of positional parameters?
IF N_Params() NE 2 THEN BEGIN
   Print, 'Correct Syntax:  DrawStation, x, y, Radius=radius, Color=color'
   Message, 'Incorrect number of positional parameters'
ENDIF

; Check for radius
IF N_Elements(radius) EQ 0 THEN BEGIN
   IF Total(!X.Window) EQ 0 THEN BEGIN
      radius = 1.0 / 50.0
   ENDIF ELSE BEGIN
      radius = (!X.Window[1] - !X.Window[0]) / 50.0
   ENDELSE
ENDIF
nradius = Convert_Coord(radius, 0, /Normal, /To_Device)
nradius = Round(nradius[0])
textoff = Convert_Coord(radius + 0.01, 0, /Normal, /To_Device)
textoff = Round(textoff[0])

; Check for label
CASE N_Elements(label) of
     0:
     1: thisLabel = Replicate(TextFont(string(label), lb_font), N_Elements(xc))
  else: thisLabel = TextFont(string(label), lb_font)
ENDCASE

; Check for label size
IF N_Elements(lb_size) EQ 0 THEN lb_size = !P.CHARSIZE

; Check for label color
CASE N_Elements(lb_color) of
     0: thisLb_Color = Make_Array(N_Elements(xc), /String, Value=GetColor('Black'))
     1: thisLb_Color = Replicate(lb_color, N_Elements(xc))
  else: thisLb_Color = lb_color
ENDCASE

; Check for color
CASE N_Elements(color) of
     0: thisColor = Make_Array(N_Elements(xc), /String, Value=GetColor('Yellow'))
     1: thisColor = Replicate(color, N_Elements(xc))
  else: thisColor = color
ENDCASE

; Check for Top, Bottom, Left or, Right positioning of the label (default is top)
top    = Keyword_Set(top)
bottom = Keyword_Set(bottom)
left   = Keyword_Set(left)
right  = Keyword_Set(right)
if top + bottom + left + right gt 1 then begin
  print,' set only one of /TOP, /BOTTOM, /LEFT OR, /RIGHT.'
  return
endif
if top eq 0 then top = 1 - max([bottom, left, right])

; Check for Data, Device or, Normal coordinates (default is data)
data   = Keyword_Set(data)
device = Keyword_Set(device)
normal = Keyword_Set(normal)
if data + device + normal gt 1 then begin
  print,' set only one of /DATA, /DEVICE, or /NORMAL.'
  return
endif
if data eq 0 then data = 1 - max([device, normal])

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
   Plots, x + xcenter[j], y + ycenter[j], Color = thisColor[j], /Device
ENDFOR

x = [xquad,  xquadrev]
y = [yquad, -yquadrev]
u = [xquadrev,  -xquad[1:*]]
v = [-yquadrev, -yquad[1:*]]
FOR j=0L, N_Elements(xcenter)-1 DO BEGIN
   Polyfill, x + xcenter[j], y + ycenter[j], Color = thisColor[j], /Device
   Polyfill, u + xcenter[j], v + ycenter[j], Color = thisColor[j], /Device
ENDFOR

IF N_ELEMENTS(label) gt 0 THEN BEGIN
  FOR j=0L, N_Elements(xcenter)-1 DO BEGIN
     thisTmp = TextDims(thisLabel[j], origin = [0.0, 0.0], charsize = lb_size, $
                   alignment = 0.5, orientation = 0.0)
     tw = Convert_Coord(thisTmp[2] - thisTmp[0], 0, /Normal, /To_Device)
     tw = Round(tw[0] / 2.0)
     th = Convert_Coord(0, thisTmp[3] - thisTmp[1], /Normal, /To_Device)
     th = Round(th[1] / 2.0)

     IF Keyword_Set(top) THEN BEGIN
       tx = xcenter[j]
       ty = ycenter[j] + textoff
     ENDIF

     IF Keyword_Set(bottom) THEN BEGIN
       tx = xcenter[j]
       ty = ycenter[j] - textoff - 2 * th
     ENDIF

     IF Keyword_Set(left) THEN BEGIN
       tx = xcenter[j] - textoff - tw
       ty = ycenter[j] - th
     ENDIF

     IF Keyword_Set(right) THEN BEGIN
       tx = xcenter[j] + textoff + tw
       ty = ycenter[j] - th
     ENDIF

     xyouts, tx, ty, thisLabel[j], $
             Color = thisLb_Color[j], charsize = lb_size, $
             alignment = 0.5, orientation = 0.0, $
             /Device
  ENDFOR
ENDIF

END
