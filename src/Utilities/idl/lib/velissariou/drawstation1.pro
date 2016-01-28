PRO DrawStation1,          $
      xc,                  $
      yc,                  $
      Radius   = radius,   $
      InColor  = incolor,  $
      OutColor = outcolor, $
      Label    = label,    $
      Lb_Size  = lb_size,  $
      Lb_Font  = lb_font,  $
      Lb_Color = lb_color, $
      Fill = fill,         $
      Frame = frame,       $
      Fr_Color = fr_color, $
      Fr_Thick = fr_thick, $
      Fr_Style = fr_style, $
      Fr_Off = fr_off,     $
      Lb_Back  = lb_back,  $
      Top      = top,      $
      Bottom   = bottom,   $
      Left     = left,     $
      Right    = right,    $
      Data     = data,     $
      Device   = device,   $
      Normal   = normal
;+++
; NAME:
;       DrawStation1
;
; PURPOSE:
;       This is routine for drawing station plots (concentric circles) on a map
;       or, other display.
;
; AUTHOR:
;       Panagiotis Velissariou
;       E-mail: velissariou.1@osu.edu
;
; CATEGORY:
;       Graphics.
;
; CALLING SEQUENCE:
;       DrawStation1, xc, yc, [keywords]
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
;       InColor     :   The name of the color to fill the inner circle of the station plot.
;                        May be a vector the same length as X. Colors are those available
;                        in the procedure "LoadColors".
;                        Default :  'Yellow'
;       OutColor    :   The name of the color to fill the outer circle of the station plot.
;                        May be a vector the same length as X. Colors are those available
;                        in the procedure "LoadColors".
;                        Default :  'Yellow'
;       Label       :   The label that accompanies the station plot. May be a vector
;                        the same length as X.
;                        Default :  NONE
;       Lb_Size     :   The charsize for the labels.
;                        Default :  1.0
;                        Default :  NO FONT CHANGE
;       Lb_Back     :   If this keyword is set fill the background of the label with
;                        color.
;                        Default :  !P.BACKGROUND
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
;       Requires GetColor, TextDims
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
;   DrawStation1, lon, lat, InColor = 'Yellow', OutColor = 'Indian Red'
;
; MODIFICATION HISTORY:
;       Written by:  Panagiotis Velissariou, March 24, 2005.
;+++

; Return to caller in event of an error.
On_Error, 2

; Correct number of positional parameters?
IF N_Params() NE 2 THEN BEGIN
   Print, 'Correct Syntax:  DrawStation1, x, y, Radius=radius, Color=color'
   Message, 'Incorrect number of positional parameters'
ENDIF
nStations = N_Elements(xc)

defLabelSz    = 1.0
defScale      = 1.0
defColor      = !P.COLOR
defColor      = !P.COLOR
defBackColor  = !P.BACKGROUND
defThick      = 1.0
defOffset     = 0.0

;-------- Determine coordinate system
data = keyword_set(data)
device = keyword_set(device)
normal = keyword_set(normal)
if ((data + device + normal) gt 1) then $
  message, 'set only one of /DATA, /DEVICE, or /NORMAL.'
if device eq 0 then device = 1 - (normal > data) ; Default is /device
to_data   = data
to_device = device
to_normal = normal

;-------- Check for Top, Bottom, Left or, Right positioning of the label (default is top)
top    = Keyword_Set(top)
bottom = Keyword_Set(bottom)
left   = Keyword_Set(left)
right  = Keyword_Set(right)
if top + bottom + left + right gt 1 then begin
  print,' set only one of /TOP, /BOTTOM, /LEFT OR, /RIGHT.'
  return
endif
if top eq 0 then top = 1 - max([bottom, left, right])

; ----- Check for Labels
thisLabel = make_array(nStations, /STRING, VALUE = '')
nLabel = n_elements(label)
if (nLabel gt 1) then begin
  if (nLabel ge nStations) then begin
    thisLabel[0:nStations-1] = strtrim(label[0:nStations-1])
  endif else begin
    thisLabel[0:nLabel-1] = strtrim(label[0:nLabel-1])
  endelse
endif else begin
  if (nLabel eq 1) then thisLabel[0:nStations-1] = strtrim(label[0], 2)
endelse
nLabel = nStations
if (n_elements(lb_font) gt 0) then begin
  for i = 0, nStations - 1 do begin
    if (thisLabel[i] ne '') then thisLabel[i] = TextFont(thisLabel[i], lb_font)
  endfor
endif

; ----- Check the input for charsize (dimensions and size should be the same
;       as in text)
thisLabelSZ = make_array(nStations, /DOUBLE, VALUE = defLabelSZ)
nLabelSZ = n_elements(lb_size)
if (nLabelSZ gt 1) then begin
  if (nLabelSZ ge nStations) then begin
    thisLabelSZ[0:nStations-1] = double(lb_size[0:nStations-1])
  endif else begin
    thisLabelSZ[0:nLabelSZ-1] = lb_size[0:nLabelSZ-1]
  endelse
endif else begin
  if (nLabelSZ eq 1) then thisLabelSZ[0:nStations-1] = double(lb_size[0])
endelse
nLabelSZ = nStations

; ----- Label colors
thisLb_Color = make_array(nStations, /INTEGER, VALUE = defLb_Color)
nLb_Color = n_elements(lb_color)
if (nLb_Color gt 1) then begin
  if (nLb_Color ge nStations) then begin
    thisLb_Color[0:nStations-1] = fix(lb_color[0:nStations-1])
  endif else begin
    thisLb_Color[0:nLb_Color-1] = fix(lb_color[0:nLb_Color-1])
  endelse
endif else begin
  if (nLb_Color eq 1) then thisLb_Color[0:nStations-1] = fix(lb_color[0])
endelse
nLb_Color = nStations

; ----- Background colors
thisLb_Back = make_array(nStations, /INTEGER, VALUE = defLb_Back)
nLb_Back = n_elements(lb_back)
if (nLb_Back gt 1) then begin
  if (nLb_Back ge nStations) then begin
    thisLb_Back[0:nStations-1] = fix(lb_back[0:nStations-1])
  endif else begin
    thisLb_Back[0:nLb_Back-1] = fix(lb_back[0:nLb_Back-1])
  endelse
endif else begin
  if (nLb_Back eq 1) then thisLb_Back[0:nStations-1] = fix(lb_back[0])
endelse
nLb_Back = nStations

; ----- Fill with the background color (if requested)
fill  = keyword_set(fill)

; ----- The label frame (if any)
frame = keyword_set(frame)
thisFr_Color = n_elements(fr_color) eq 0 ? defColor : 255 - (255 - fix(abs(fr_color)) > 0)
thisFr_Thick = n_elements(fr_thick) eq 0 ? defThick : fr_thick
thisFr_Style = n_elements(fr_style) eq 0 ? 0 : 5 - (5 - fix(abs(fr_style)) > 0)
thisFr_Off = n_elements(fr_off) eq 0 ? defOffset : abs(fr_off[0])

; Check for radius
IF N_Elements(radius) EQ 0 THEN BEGIN
   IF Total(!X.Window) EQ 0 THEN BEGIN
      radius = 1.0 / 50.0
   ENDIF ELSE BEGIN
      radius = (!X.Window[1] - !X.Window[0]) / 50.0
   ENDELSE
ENDIF

; ----- The aspect ratio of the window
ch_xsize = double(!D.X_CH_SIZE) ; in device coordinates
ch_ysize = double(!D.Y_CH_SIZE) ; in device coordinates
aspectRatio = ch_ysize / ch_xsize

XLabOff = ch_xsize
XLabOff = Round(0.20 * aspectRatio * XLabOff)
YLabOff = (!D.NAME eq 'PS') ? 0.875 * ch_ysize : 1.2 * ch_ysize
YLabOff = Round(0.20 * YLabOff)

; Plot the coordinates about the given center after converting
; to DEVICE coordinates.
coord = Convert_Coord(xc, yc, Data = data, Device = device, Normal = normal, /To_Device)
xcenter = Round(coord[0,*])
ycenter = Round(coord[1,*])
nradius = convert_coord(radius, 0, /Normal, /To_Device)
nradius = Round(nradius[0])

; Plot the station
DrawCircle, xc, yc, radius = radius, color = outcolor, /fill, $
             linecolor = outcolor, linethick = 0.0, $
             data = data, device = device, normal = normal

DrawCircle, xc, yc, radius = 0.45 * radius, color = incolor, /fill, $
             linecolor = incolor, linethick = 0.0, $
             data = data, device = device, normal = normal

IF N_ELEMENTS(label) gt 0 THEN BEGIN
  FOR j=0L, N_Elements(xcenter)-1 DO BEGIN
     VL_Legend, [xcenter[j], ycenter[j]], thisLabel[j], charsize = thisLabelSZ, $
                alignment = 0.5, $
                frame = frame, fr_color = thisFr_Color, fr_thick = thisFr_Thick, $
                fr_style = thisFr_Style, fr_off = thisFr_Off, $
                /device, /get, legdims = legdims
     tw = Round(legdims[2] - legdims[0])
     th = Round(legdims[3] - legdims[1])

     IF Keyword_Set(top) THEN BEGIN
       tx = xcenter[j] - Round(0.50 * tw)
       ty = ycenter[j] + nradius + YLabOff
     ENDIF

     IF Keyword_Set(bottom) THEN BEGIN
       tx = xcenter[j] - Round(0.50 * tw)
       ty = ycenter[j] - nradius - th - YLabOff
     ENDIF

     IF Keyword_Set(left) THEN BEGIN
       tx = xcenter[j] - nradius - XLabOff - tw
       ty = ycenter[j] - Round(0.50 * th)
     ENDIF

     IF Keyword_Set(right) THEN BEGIN
       tx = xcenter[j] + nradius + XLabOff
       ty = ycenter[j] - Round(0.50 * th)
     ENDIF

     VL_Legend, [tx, ty], thisLabel[j], charsize = thisLabelSZ, color = thisLb_Color[j], $
                frame = frame, fr_color = thisFr_Color, fr_thick = thisFr_Thick, $
                fr_style = thisFr_Style, fr_off = thisFr_Off, bk_color = thisLb_Back[j], $
                fill = fill, $
                alignment = 0.5, $
                /device
  ENDFOR
ENDIF

END
