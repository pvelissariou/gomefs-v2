Function def_format, minv, maxv, log = log

; ==========> Return default format string depending on
;             min and max value and log flag.

; ==========> General default
res = '(f7.2)'

; ==========> Determine necessary number of decimal places.
ndec    = fix( 2.-alog10( (float(maxv) - float(minv)) > 1.0E-31 ) )
ndecmin = fix( 2.-alog10( float(minv) > 1.0E-31 ) )

log = keyword_set(log)

if log then ndec = max([ndec,ndecmin-1])

if ( ndec gt 2 ) then $
   res = '(e6.3)'
if ( ndec eq 3 and log ) then $
   res = '(f7.3)'
if ( ndec le 0 ) then $
   res = '(I14)'
if ( ndec le -6 ) then $
   res = '(e6.3)'
   
return, res

end

Function lab_loc, text, center, charsize = charsize, rotation = rotation, $
                  up = up, down = down, textdims = textdims

  on_error, 2

  if (size(text, /type) ne 7) or (size(text, /n_dimensions) gt 1) then $
      message, "you need to supply a string or, a 1-D string array for <text>."
  nText = n_elements(text)

  thisCenter = fltarr(2, nText)
  case n_elements(center) of
       0:
       1: begin
            thisCenter[0, *] = float(center)
            thisCenter[1, *] = float(center)
          end
       2: begin
            thisCenter[0, *] = float(center[0])
            thisCenter[1, *] = float(center[1])
          end
    else: begin
           sz = size(center)
           if (sz[0] ne 2) or (sz[1] ne 2) or (sz[2] ne n_elements(text)) then $
             message, 'the size of <text> and <center> should be the same'
           thisCenter[0, *] = float(center[0, *])
           thisCenter[1, *] = float(center[1, *])
          end
  endcase

  thisCharsize = n_elements(charsize) eq 0 ? 1.0 : float(charsize[0])
    
  thisRotation = n_elements(rotation) eq 0 ? 0.0 : float(rotation[0])

  down = keyword_set(down)
  up   = keyword_set(up)
  if down + up gt 1 then begin
    print,' set only one of /DOWN or, /UP.'
    return, [0.0, 0.0]
  endif
  if down eq 0 then down = 1 - up ; Def is /down.

; set the dimensions of the arrays
  loc_coords = fltarr(2, nText)
  if arg_present(textdims) then textdims = loc_coords

; get the dimensions of the text bounding box
  txtbox = TextDims(text, origin = thisCenter , charsize = thisCharsize, $
                     alignment = 0.5, orientation = thisRotation)

; text box center, width, height
  bxc = 0.5 *(txtbox[0,*] + txtbox[2,*])
  byc = 0.5 *(txtbox[1,*] + txtbox[3,*])
  bwd = txtbox[2,*] - txtbox[0,*]
  bht = txtbox[3,*] - txtbox[1,*]

  loc_coords[0, *] = 2.0 * thisCenter[0, *] - bxc
  loc_coords[1, *] = 2.0 * thisCenter[1, *] - byc

  if keyword_set(down) then loc_coords[1, *] = loc_coords[1, *] - 0.5 * bht
  if keyword_set(up)   then loc_coords[1, *] = loc_coords[1, *] + 0.5 * bht

  if arg_present(textdims) then textdims = [bwd, bht]

  return, loc_coords

end

;+++
; NAME:
;    DColorBar
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;	This procedure is used to draw a discrete colorbar in a specified location.
;
; CATEGORY:
;	Graphics
;
; CALLING SEQUENCE:
;	DColorBar, levels, [keyword1 = value], [keyword2 = value], ...
;
;       Levels      :   This is the 1-D array of the data (levels) used for
;                        the colorbar. From these values the labels of the
;                        colorbar are also determined if the left/right labels
;                        are not supplied. The maximum number of levels is 60.
;                        Default :  REQUIRED
;
; KEYWORD PARAMETERS:
;       Position    :   The position of the lower left and upper right corners
;                        of the colorbar in normal coordinates.
;                        Default :  position = [0.88, 0.1, 0.95, 0.9] (vertical)
;                                   position = [0.1, 0.88, 0.9, 0.95] (horizontal)
;      Colors       :   The 1-D integer array of the color indices to be used for the
;                        colorbar. It can 1 to 256 elements, if the number of elements
;                        of <Colors> is less than the number of elements of
;                        <Levels> then, the colors in the colormap are rotated.
;                        Default :  if this array is not supplied then, the colors
;                                   of the currently loaded color table are used.
;      LowColor     :   The starting index of the colors in the <Colors> or, the
;                        color table.
;                        Default :  0
;      InvertColors :   Set this keyword if you want to reverse the colors in the
;                        colorbar.
;                        Default :  NONE
;      BarRot       :   Set this keyword if you want to rotate the colorbar by an
;                        angle theta (counter clock-wise, in degrees)
;                        Default :  0.0
;      LabRot       :   Set this keyword if you want to rotate the labels of the
;                         colorbar by an angle theta (counter clock-wise, in degrees)
;                        Default :  0.0
;      Scale        :   Set this keyword if you want to scale the colorbar.
;                        Default :  1.0 (no scaling)
;      Translate    :   Set this keyword if you want to translate the colorbar to a
;                         new origin.
;                        Default :  no translation
;      Vertical     :   Set this keyword if you want to draw a vertical colobar that is,
;                        to rotate the colorbar by 90 degrees. This is a shortcut for
;                        BarRot = 90.0
;                        Default :  a horizontal colorbar is drawn.
;      LastBox      :   Set this keyword if you want to draw the last box of the
;                        colorbar.
;                        Default :  no last box is drawn
;      Middle       :   Set this keyword if you want to draw the labels of the
;                        colorbar between the tickmarks. Setting this means that
;                        the last box is also drawn.
;                        Default :  labels are drawn at the tickmark locations
;      Left         :   Set this keyword if you want to annotate the colorbar
;                        at the left (if vertical) or, at the top (if horizontal).
;                        Default :  NONE
;      Right        :   Set this keyword if you want to annotate the colorbar
;                        at the right (if vertical) or, at the bottom (if horizontal).
;                        If both the "left" and "right" keywords are set, then the
;                        the labels are drawn at both sides of the colorbar,
;                        according to <L_Labs> and <R_Labs> or, <Levels>.
;                        Default :  NONE
;      L_Labs       :   This is the 1-D string array of the "left" (for a vertical
;                        colorbar) or, the "top" (for a horizontal colorbar) labels
;                        used for the colorbar. The <L_Labs> array should be the
;                        same size as the <Levels> array.
;                        Default : the colorbar labels are determined from the <Levels>.
;      L_Format     :   This is the format used for the "left" colorbar labels.
;                        Default :  '(i3)'.
;      R_Labs       :   This is the 1-D string array of the "right" (for a vertical
;                        colorbar) or, the "bottom" (for a horizontal colorbar) labels
;                        used for the colorbar. The <R_Labs> array should be the
;                        same size with the <Levels> array.
;                        Default : the colorbar labels are determined from the <Levels>.
;      R_Format     :   This is the format used for the "right" colorbar labels.
;                        Default :  '(i3)'.
;      LabSize      :   The size of the text of both the <L_Labs> and <R_Labs>.
;                        Default :  !P.CHARSIZE
;      TickLen      :   This is the size of the ticks in the colorbar.
;                        Default :  0.0 (no ticks are drawn).
;      L_Title      :   The string containing the text to be used for the "left"
;                        title of the colorbar.
;                        Default :  ''
;      R_Title      :   The string containing the text to be used for the "right"
;                        title of the colorbar.
;                        Default :  ''
;      TitleSize    :   The size of the text of the title of the colorbar.
;                        Default :  1.25 * LabSize
;      Fr_Color     :   The color of the frame drawn around the colorbar.
;                        It is also used when drawing the ticks of the colorbar.
;                        Default :  !P.COLOR
;      Fr_Thick     :   The thickness of the line used to draw the frame around
;                        the colorbar boxes. It is also used when drawing the ticks
;                        of the colorbar.
;                        Default :  1.0
;      Fr_Style     :   The style of the line used to draw the frame around
;                        the colorbar boxes.
;                        Default :  0
;                        Fr_Style = 0 draws a solid line.
;                        Fr_Style = 1 draws a dotted line.
;                        Fr_Style = 2 draws a dashed line.
;                        Fr_Style = 3 draws a dash-dotted line.
;                        Fr_Style = 4 draws a dash-dot-dot-dotted line.
;                        Fr_Style = 5 draws a long dashed line.
;      Br_Color     :   The color of the border drawn around the colorbar.
;                        Default :  Fr_Color
;      Br_Thick     :   The thickness of the line used to draw the border around
;                        the colorbar. If not set then no frame is drawn.
;                        Default :  Br_Thick = 0.0.
;      Br_Style     :   The style of the line used to draw the border around
;                        the colorbar.
;                        Default :  Fr_Style
;      Lb_Color     :   The color that is used to draw the colorbar labels.
;                        Default :  Fr_Color
;      Lb_Font      :   The font to be used to draw the labels.
;                        Default :  - 1
;      Tl_Color     :   The color that is used to draw the colorbar title.
;                        Default :  Lb_Color.
;      Tl_Font      :   The font to be used to draw the titles of the colorbar.
;                         Default :  - 1
;      Bk_Color     :   This is the color that is used to draw the background
;                        of the colorbar.
;                        If not set then the background is going to be the default
;                        background of the plot (that is, no background is drawn).
;      BarDims      :   This is a named variable that contains the coordinates of
;                        the lower and upper corners of the colorbar.
;
; PROCEDURE:
;	This procedure uses the input values to construct a "DISCRETE" colorbar
;	at the specified position.
;
; EXAMPLE:
;	Create an arrow at [0.2, 0.2].
;	  DColorBar, [0.0, 1.0, 2.0, 3.0], position = [0.2, 0.3], /vertical
;
; MODIFICATION HISTORY:
;    Written by: Panagiotis Velissariou, September 2000.
;
;    Re-write of the original code on February 25, 2005
;    Panagiotis Velissariou <velissariou.1@osu.edu>
;
;-------------------------------------------------------------------------------
PRO DColorBar,                     $
      levels,                      $
      position     = position,     $
      Colors       = colors,       $
      LowColor     = lowcolor,     $
      InvertColors = invertcolors, $
      BarRot       = barrot,       $
      LabRot       = labrot,       $
      Scale        = scale,        $
      Translate    = translate,    $
      Vertical     = vertical,     $
      LastBox      = lastbox,      $
      Middle       = middle,       $
      Left         = left,         $
      Right        = right,        $
      L_Labs       = l_labs,       $
      L_Format     = l_format,     $
      R_Labs       = r_labs,       $
      R_Format     = r_format,     $
      LabSize      = labsize,      $
      TickLen      = ticklen,      $
      L_Title      = l_title,      $
      R_Title      = r_title,      $
      TitleSize    = titlesize,    $
      Fr_Color     = fr_color,     $
      Fr_Thick     = fr_thick,     $
      Fr_Style     = fr_style,     $
      Br_Color     = br_color,     $
      Br_Thick     = br_thick,     $
      Br_Style     = br_style,     $
      Lb_Color     = lb_color,     $
      Lb_Font      = lb_font,      $
      Tl_Color     = tl_color,     $
      Tl_Font      = tl_font,      $
      Bk_Color     = bk_color,     $
      BarDims      = bardims,      $
      Get = get,                   $
      _Extra = extra

on_error, 2

; ======================================================================
; ===   INITIALIZE
; ======================================================================

; ===== Levels
nLevels = n_elements(levels)
nIdx = where([1, 2, 3, 4, 5, 6, 9, 12, 13, 14, 15] eq size(levels, /type), nCount)
if (nCount eq 0) or (size(levels, /n_dimensions) ne 1) then $
  message, 'please supply a float or, an integer 1-D array for <levels>'

; ===== Position
; vertical orientation
if keyword_set(vertical) then begin
  if n_elements(position) eq 0 then begin
    position = [0.88, 0.1, 0.95, 0.9]
  endif else begin
    if (position[2] - position[0]) gt (position[3] - position[1]) then begin
      position = [position[1], position[0], position[3], position[2]]
    endif
    if position[0] ge position[2] then message, "position coordinates can't be reconciled."
    if position[1] ge position[3] then message, "position coordinates can't be reconciled."
  endelse
; horizontal orientation (default)
endif else begin
  if n_elements(position) eq 0 then begin
     position = [0.1, 0.88, 0.9, 0.95]
  endif else begin
     if (position[3] - position[1]) gt (position[2] - position[0]) then begin
        position = [position[1], position[0], position[3], position[2]]
     endif
     if position[0] ge position[2] then message, "position coordinates can't be reconciled."
     if position[1] ge position[3] then message, "position coordinates can't be reconciled."
  endelse
endelse

; ===== Colors
thisLowColor = n_elements(LowColor) eq 0 ? 0 : fix(LowColor)

InvertColors = keyword_set(invertcolors)

nColors = n_elements(colors)
nColors = nColors eq 0 ? nLevels : nColors

if nColors gt 0 then begin
; explicitly use these colors to construct the colormap
  nIdx = where([1, 2, 3, 12, 13, 14, 15] eq size(Colors, /type), nCount)
  if (nCount eq 0) or (size(Colors, /n_dimensions) ne 1) then $
    message, "you need to supply an 1-D integer array for <Colors>"

  if (nColors le nLevels) then begin
    thisLowColor = 0
    lvc = Colors
    Colors = replicate(0, nLevels)
    j = 0
    for i = 0, nLevels - 1 do begin
      if (j eq nColors) then j = 0
      Colors[i] = lvc[j]
      j = j + 1
    endfor
  endif else begin
    if (thisLowColor ge (nColors - nLevels + 1)) then $
      thisLowColor = nColors - nLevels + 1
  endelse

endif else begin

  if (thisLowColor ge (255 - nLevels + 1)) then $
    thisLowColor = 255 - nLevels + 1

  Colors = replicate(0, nLevels) + thisLowColor

endelse

; ===== Vertical/Horizontal orientation of the colorbar
vertical = keyword_set(vertical)

; ===== Lastbox
lastbox = keyword_set(lastbox)

; ===== Middle location of labels
if keyword_set(middle) then lastbox = 1

; ===== Tickmarks/labels/titles positioning (default is right)
left = keyword_set(left)
right = keyword_set(right)
;if (not keyword_set(left)) and (not keyword_set(right)) then right = 1

; ===== Length of tickmarks
thisTickLen = n_elements(ticklen) eq 0 ? 0.0 : 1.0 - (1.0 - abs(float(ticklen)) > 0.0)
do_left_ticks  = keyword_set(left)  and (thisTickLen gt 0.0)
do_right_ticks = keyword_set(right) and (thisTickLen gt 0.0)

; ===== Orientation of labels
thisLabRot = n_elements(labrot) eq 0 ? 0.0 : float(labrot[0])
thisLabRot = thisLabRot mod 360.0
if (thisLabRot lt 0.0) then thisLabRot = thisLabRot + 360.0

; ===== Orientation of the colorbar
do_rotate = 0
if vertical then $
  thisBarRot = 90.0 $
else $
  thisBarRot = n_elements(barrot) eq 0 ? 0.0 : float(barrot[0])
thisBarRot = thisBarRot mod 360.0
if (thisBarRot lt 0.0) then thisBarRot = thisBarRot + 360.0
if (thisBarRot ne 0.0) then do_rotate = 1

; ===== Scaling of the colorbar
thisScale = n_elements(scale) eq 0 ? 1.0 : abs(float(scale[0]))
if thisScale eq 0.0 then thisScale = 1.0

; ===== Translation of the colorbar
do_translate = 1
case n_elements(translate) of
     0: do_translate = 0
     1: thisTranslate = [translate, translate]
  else: thisTranslate = [translate[0], translate[1]]
endcase

; ===== Color of box frame
thisFr_Color = n_elements(fr_color) eq 0 ? !P.COLOR : 255 - (255 - fix(abs(fr_color)) > 0)

; ===== Thickness of box frame
thisFr_Thick = n_elements(fr_thick) eq 0 ? 1.0 : float(fr_thick)

; ===== Linestyle of box frame (default 0 = solid)
thisFr_Style = n_elements(fr_style) eq 0 ? 0 : 5 - (5 - fix(abs(fr_style)) > 0)

; ===== Flag to frame or, not the colorbar boxes
BarFrame = n_elements(fr_color) eq 0 ? 1 : 0

; ===== Format of labels
thisL_Format = n_elements(l_format) eq 0 ? '(i3)' : string(l_format)
thisR_Format = n_elements(r_format) eq 0 ? '(i3)' : string(r_format)

; ===== Left labels
thisL_Labs = n_elements(l_labs) eq 0 ? string(levels, format = thisL_Format) : string(l_labs)
;thisL_Labs = strtrim(thisL_Labs, 2)
do_left_labs  = keyword_set(left)  and (max(strlen([thisL_Labs])) ne 0)
thisL_Labs = TextFont(thisL_Labs, lb_font)

; ===== Right labels
thisR_Labs = n_elements(r_labs) eq 0 ? string(levels, format = thisR_Format) : string(r_labs)
;thisR_Labs = strtrim(thisR_Labs, 2)
do_right_labs  = keyword_set(right)  and (max(strlen([thisR_Labs])) ne 0)
thisR_Labs = TextFont(thisR_Labs, lb_font)

; ===== Color of labels
thisLb_Color = n_elements(lb_color) eq 0 ? thisFr_Color : 255 - (255 - fix(abs(lb_color)) > 0)

; ===== Size of labels
thisLabSize = n_elements(labsize) eq 0 ? !P.CHARSIZE : float(labsize)

; ===== Left title
thisL_Title = n_elements(l_title) eq 0 ? '' : string(l_title)
do_left_title = keyword_set(left) and (strlen(thisL_Title) ne 0)
thisL_Title = TextFont(thisL_Title, tl_font)

; ===== Right title
thisR_Title = n_elements(r_title) eq 0 ? '' : string(r_title)
do_right_title = keyword_set(right) and (strlen(thisR_Title) ne 0)
thisR_Title = TextFont(thisR_Title, tl_font)

; ===== Color of titles
thisTl_Color = n_elements(tl_color) eq 0 ? thisLb_Color : 255 - (255 - fix(abs(tl_color)) > 0)

; ===== Size of titles
thisTitleSize = n_elements(titlesize) eq 0 ? 1.25 * thisLabSize : float(titlesize)

; ===== Flag to draw or, not the colorbar border
BarBorder = n_elements(br_color) eq 0 ? 1 : 0

; ===== Color of colorbar border (default fr_color)
thisBr_Color = n_elements(br_color) eq 0 ? thisFr_Color : 255 - (255 - fix(abs(br_color)) > 0)

; ===== Thickness of colorbar border
thisBr_Thick = n_elements(br_thick) eq 0 ? thisFr_Thick : float(br_thick)

; ===== Linestyle of colorbar border
thisBr_Style = n_elements(br_style) eq 0 ? thisFr_Style : 5 - (5 - fix(abs(br_style)) > 0)

; ===== Flag to draw or, not the colorbar background (default no background)
BarBackground = n_elements(bk_color) eq 0 ? 0 : 1

; ===== Color of colorbar background
thisBk_Color = n_elements(bk_color) eq 0 ? !P.BACKGROUND : 255 - (255 - fix(abs(bk_color)) > 0)

; ======================================================================
; ===   SETTINGS FOR VARIOUS COLORBAR PARAMETERS
; ======================================================================
aspectRatio = GetAspect()

; ===== Position
BarX0    = position[0]
BarY0    = position[1]
BarX1    = position[2]
BarY1    = position[3]
BarXSize = BarX1 - BarX0
BarYSize = BarY1 - BarY0

; this is for a vertical colorbar
; we first draw a horizontal colorbar and then rotate it by 90 degrees
if (BarYSize gt BarXSize) then begin
  do_rotate = 1
  BarX1 = BarX0 + (BarXSize > BarYSize) * aspectRatio
  BarY1 = BarY0 + (BarXSize < BarYSize)
  BarXSize = BarX1 - BarX0
  BarYSize = BarY1 - BarY0
endif

; ===== Offsets within the colorbar area
y_len = 0.05
x_len = y_len * aspectRatio

; ===== Label offsets
Lab_xOff = 0.1 * x_len
Lab_yOff = 0.1 * y_len

; ===== Border offsets
xOff   = 0.1 * x_len
yOff   = 0.1 * y_len

l_xOff = (1.0 - BarBorder) * xOff
r_xOff = (1.0 - BarBorder) * xOff

l_yOff = 0.25 * y_len
l_yOff = max([yOff, do_left_labs * thisLabSize * l_yOff, do_left_title * thisTitleSize * l_yOff])
l_yOff = (1.0 - BarBorder) * l_yOff

r_yOff = 0.25 * y_len
r_yOff = max([yOff, do_right_labs * thisLabSize * r_yOff, do_right_title * thisTitleSize * r_yOff])
r_yOff = (1.0 - BarBorder) * r_yOff

; ===== Colorbar boxes
if lastbox then begin
  nBoxes = nLevels
  nTickMarks = nBoxes
endif else begin
  nBoxes = nLevels - 1
  nTickMarks = nBoxes + 1
endelse

boxlen = BarXSize / float(nBoxes)
Boxes  = BarX0 + boxlen * indgen(nBoxes + 1)
BoxArr = replicate(1.0, nBoxes + 1)

MiddleOff = keyword_set(middle) eq 0 ? 0.0 : 0.5 * boxlen

; ===== Colorbar tickmarks
thisTickLen = thisTickLen * BarYSize
TickArr = replicate(1.0, nTickMarks)
TickMarks = BarX0 + boxlen * indgen(nTickMarks)

; ===== Colorbar title dimensions
thisTmp = TextDims(thisL_Title, origin = [0.0, 0.0], charsize = thisTitleSize, $
                   alignment = 0.5, orientation = 0.0)
thisL_TitleWidth  = thisTmp[2] - thisTmp[0]
thisL_TitleHeight = thisTmp[3] - thisTmp[1]

thisTmp = TextDims(thisR_Title, origin = [0.0, 0.0], charsize = thisTitleSize, $
                   alignment = 0.5, orientation = 0.0)
thisR_TitleWidth  = thisTmp[2] - thisTmp[0]
thisR_TitleHeight = thisTmp[3] - thisTmp[1]

; ======================================================================
; ===   DETERMINE THE COORDINATES OF THE VARIOUS COLORBAR SECTIONS
; ======================================================================

l_Len   = BarY1
r_Len   = BarY0
l_X0Len = BarX0
r_X0Len = BarX0
l_X1Len = BarX1
r_X1Len = BarX1

xrot_flag = round(sin(!DTOR * (- thisBarRot + thisLabRot)) * 100000.0) / 100000.0
if (abs(xrot_flag) ne 1.0) and (xrot_flag ne 0.0) then xrot_flag = 0.0

; ===== ColorBar boxes
xx = [Boxes, Boxes]
yy = [BarY1 * BoxArr, BarY0 * BoxArr]

; ===== ColorBar tick marks
; left
if do_left_ticks then begin
  ll = l_Len
  l_Len = l_Len + thisTickLen
  xx = [xx, TickMarks + MiddleOff, TickMarks + MiddleOff]
  yy = [yy, ll * TickArr, l_Len * TickArr]
endif
; right
if do_right_ticks then begin
  ll = r_Len
  r_Len = r_Len - thisTickLen
  xx = [xx, TickMarks + MiddleOff, TickMarks + MiddleOff]
  yy = [yy, ll * TickArr, r_Len * TickArr]
endif

; ===== ColorBar tick labels
; left
if do_left_labs then begin
  l_Len = l_Len + Lab_yOff
  nLabs = n_elements(thisL_Labs)
  labloc = fltarr(2, nLabs)
  labdims = fltarr(2, nLabs)
  thisOrigin = [transpose(TickMarks + MiddleOff), transpose(l_Len * TickArr)]

  for ilab = 0, nLabs - 1 do begin
    labloc[*, ilab] = lab_loc(thisL_Labs[ilab], thisOrigin[*, ilab], charsize = thisLabSize, $
                     rotation = - thisBarRot + thisLabRot, /up, textdims = tmpdims)
    labdims[*, ilab] = tmpdims
  endfor
  xx = [xx, transpose(labloc[0, *])]
  yy = [yy, transpose(labloc[1, *])]

  l_Len = l_Len + max(labdims[1, *])
  l_X0Len = labloc[0, 0] - 0.5 * (1.0 + xrot_flag) * labdims[0, 0]
  l_X1Len = labloc[0, nTickMarks - 1] + 0.5 * (1.0 - xrot_flag) * labdims[0, nLabs - 1]
endif
; right
if do_right_labs then begin
  r_Len = r_Len - Lab_yOff
  nLabs = n_elements(thisR_Labs)
  labloc = fltarr(2, nLabs)
  labdims = fltarr(2, nLabs)
  thisOrigin = [transpose(TickMarks + MiddleOff), transpose(r_Len * TickArr)]

  for ilab = 0, nLabs - 1 do begin
    labloc[*, ilab] = lab_loc(thisR_Labs[ilab], thisOrigin[*, ilab], charsize = thisLabSize, $
                     rotation = - thisBarRot + thisLabRot, /down, textdims = tmpdims)
    labdims[*, ilab] = tmpdims
  endfor

  xx = [xx, transpose(labloc[0, *])]
  yy = [yy, transpose(labloc[1, *])]

  r_Len = r_Len - max(labdims[1, *])
  r_X0Len = labloc[0, 0] - 0.5 * (1.0 + xrot_flag) * labdims[0, 0]
  r_X1Len = labloc[0, nTickMarks - 1] + 0.5 * (1.0 - xrot_flag) * labdims[0, nLabs - 1]
endif

; ===== ColorBar titles
; left
if do_left_title then begin
  ylen = max([4.0 * Lab_yOff, thisL_TitleHeight])

  l_len = l_len + 0.5 * ylen
  xx = [xx, 0.5 * (BarX0 + BarX1)]
  yy = [yy, l_len]
  l_len = l_len + thisL_TitleHeight
endif
; right
if do_right_title then begin
  ylen = max([4.0 * Lab_yOff, thisR_TitleHeight])

  r_len = r_len - 0.5 * ylen - 1.25 * thisR_TitleHeight
  xx = [xx, 0.5 * (BarX0 + BarX1)]
  yy = [yy, r_len + 0.25 * thisR_TitleHeight]
  r_len = r_len
endif

; ===== ColorBar border/background
l_len = l_len + l_yOff
r_len = r_len - r_yOff

ww = max([thisL_TitleWidth, thisR_TitleWidth])
minx = min([BarX0, BarX0 + (BarXSize - ww) / 2.0, l_X0Len, r_X0Len]) - l_xOff
maxx = max([BarX1, BarX0 + (BarXSize + ww) / 2.0, l_X1Len, r_X1Len]) + r_xOff

xx = [xx, minx, maxx, minx, maxx]
yy = [yy, l_len, l_len, r_len, r_len]

minx = min(xx, max = maxx)
miny = min(yy, max = maxy)

; ======================================================================
; ===   PERFORM THE ROTATION/TRANSLATION/SCALING OF THE COLORBAR
; ======================================================================
thisLabSize   = thisScale * thisLabSize
thisTitleSize = thisScale * thisTitleSize
thisBr_Thick  = thisScale * thisBr_Thick
thisFr_Thick  = thisScale * thisFr_Thick

if (not do_translate) then thisTranslate = [BarX0, BarY0]
if vertical then $
  thisTranslate = thisTranslate + [(maxy - miny) * aspectRatio, 0.0]

BarCoord = Transform2DShape(xx, yy, center = [minx, r_len], $
             rotation = thisBarRot,                         $
             translate = thisTranslate,                     $
             scale = thisScale)

xx = transpose(BarCoord[0,*])
yy = transpose(BarCoord[1,*])

if arg_present(bardims) then begin
  minx = min(xx, max = maxx)
  miny = min(yy, max = maxy)
  bardims = [minx, miny, maxx, maxy]
endif

if (keyword_set(get)) then return

; ===== convert to device coordinates
BarCoord = convert_coord(BarCoord, /normal, /to_device)
xx = transpose(BarCoord[0,*])
yy = transpose(BarCoord[1,*])

; ======================================================================
; ===   DRAW THE COLORBAR
; ======================================================================

; ===== ColorBar border/background
i0 = n_elements(xx) - 4
box = [xx[i0+2], yy[i0+2], xx[i0+3], yy[i0+3], xx[i0+1], yy[i0+1], xx[i0], yy[i0]]
DrawBox, box, fr_color = thisBr_Color, bk_color = thisBk_Color, $
         fr_thick = thisBr_Thick, fr_style = thisBr_Style, $
         noframe = BarBorder, fill = BarBackground, /device

; ===== ColorBar boxes
for i = 0, nBoxes - 1 do begin
  i0 = nBoxes + 1 + i
  box = [xx[i0], yy[i0], xx[i0+1], yy[i0+1], xx[i+1], yy[i+1], xx[i], yy[i]]
  DrawBox, box, $
           fr_color = thisFr_Color, bk_color = fix(Colors[i]), $
           fr_thick = thisFr_Thick, fr_style = thisFr_Style, $
           noframe = BarFrame, fill = 1, /device
endfor
i0 = i0 + 2

; ===== ColorBar tick marks
; left
if do_left_ticks then begin
  j = i0
  for i = 0, nTickMarks - 1 do begin
    i0 = j + i
    i1 = i0 + nTickMarks
    if(strlen(strtrim(thisL_Labs[i], 2)) gt 0) then $
      plots, [xx[i0], xx[i1]], [yy[i0], yy[i1]], $
             color = thisFr_Color, thick = thisFr_Thick, linestyle = thisFr_Style, $
             /device
  endfor
  i0 = i1 + 1
endif
; right
if do_right_ticks then begin
  j = i0
  for i = 0, nTickMarks - 1 do begin
    i0 = j + i
    i1 = i0 + nTickMarks
    if(strlen(strtrim(thisR_Labs[i], 2)) gt 0) then $
      plots, [xx[i0], xx[i1]], [yy[i0], yy[i1]], $
             color = thisFr_Color, thick = thisFr_Thick, linestyle = thisFr_Style, $
             /device
  endfor
  i0 = i1 + 1
endif

; ===== ColorBar tick labels
; left
if do_left_labs then begin
  i1 = i0
  for i = 0, nTickMarks - 1 do begin
    i0 = i1 + i
    xyouts, xx[i0], yy[i0], thisL_Labs[i], charsize = thisLabSize, color = thisLb_Color, $
            orientation = thisLabRot, alignment = 0.5, $
            /device
  endfor
  i0 = i0 + 1
endif
; right
if do_right_labs then begin
  i1 = i0
  for i = 0, nTickMarks - 1 do begin
    i0 = i1 + i
    xyouts, xx[i0], yy[i0], thisR_Labs[i], charsize = thisLabSize, color = thisLb_Color, $
            orientation = thisLabRot, alignment = 0.5, $
            /device
  endfor
  i0 = i0 + 1
endif

; ===== ColorBar titles
; left
if do_left_title then begin
  xyouts, xx[i0], yy[i0], thisL_Title, charsize = thisTitleSize, color = thisTl_Color, $
          orientation = thisBarRot, alignment = 0.5, $
          /device
  i0 = i0 + 1
endif
; right
if do_right_title then begin
  xyouts, xx[i0], yy[i0], thisR_Title, charsize = thisTitleSize, color = thisTl_Color, $
          orientation = thisBarRot, alignment = 0.5, $
          /device
endif

end
