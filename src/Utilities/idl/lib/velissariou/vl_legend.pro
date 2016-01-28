PRO VL_Legend,                   $
      Position,                  $
      Text,                      $
      CharSize = charsize,       $
      Alignment = alignment,     $
      HAlign = halign,           $
      VAlign = valign,           $
      Color = color,             $
      Title = title,             $
      Tl_Size = tl_size,         $
      Tl_Color = tl_color,       $
      Fill = fill,               $
      Frame = frame,             $
      Fr_Color = fr_color,       $
      Fr_Thick = fr_thick,       $
      Fr_Style = fr_style,       $
      Fr_Off = fr_off,           $
      Bk_Color = bk_color,       $
      Rotation = rotation,       $
      Scale = scale,             $
      Spacing = spacing,         $
      LegDims = legdims,         $
      Get = get,                 $
      Data = data,               $
      Device = device,           $
      Normal = normal
;+++
; NAME:
;	VL_Legend
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;	This procedure plots a legend for line plots.
;
; CATEGORY:
;	Graphics
;
; CALLING SEQUENCE:
;	VL_Legend, Position, Label, [keywords]
;
;       position    :   A 2-element vector containing the position
;                        ([x,y]) in normal/data or device coordinates of
;                        the lower left corner of the box containing the legend.
;	 text       :   A vector, of type string, containing the labels
;                        for each line.
;
; KEYWORD PARAMETERS:
;       charsize    :   The height of the characters to be used when drawing
;                        the text.
;                        Default :  1.0
;       alignment   :   The alignment of the labels within the legend area.
;                        Default :  1.0
;       title       :   A string containing the title of the legend. The size
;                        of the title text is 1.25 * charsize
;                        Default :  '' (no title)
;       fill        :   Set this keyword if you want the legend area to
;                        have a background color.
;                        Default :  no fill
;       frame       :   Set this keyword if you want the legend area to
;                        have a frame.
;                        Default :  no frame
;       fr_color    :   This is the color index to be used when drawing the
;                        frame.
;                        Default :  Black
;       fr_thick    :   This is the thickness to be used when drawing the
;                        frame.
;                        Default :  1.0
;       fr_style    :   This is the type of line to be used when drawing the
;                        frame.
;                        Default :  0 (solid line)
;       bk_color    :   This is the index for the background color to be used
;                        when the legend area is to be filled.
;                        Default :  White
;       rotation    :   Use this keyword to rotate the legend counter-clock-wise
;                        at an angle (in degrees).
;                        Default :  0.0 (no rotation)
;       scale       :   Use this keyword to scale the legend by a factor.
;                        Default :  1.0 (no scaling)
;       legdims     :   A named variable that holds the coordinates of the horizontal
;                        box containing the legend area (including the title) that is,
;                        legdims = [xmin, ymin, xmax, ymax] and:
;                        width = xmax -xmin, height = ymax - ymin.
;                        Default :  NONE
;
; PROCEDURE:
;	This procedure uses the input values to construct an appropriate
;	box containing the legend for a plot.
;
; EXAMPLE:
;	Create a legend for a two-line plot (colors red and green).
;	  tek_color
;	  VL_Legend, [0.2,0.2], ['Red','Green'], title='Legend'
;
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

; ----- Check the input for text (a string or, an 1D string vector)
if (size(text, /type) ne 7) then $
  message, 'a string or, an 1D string vector is required for <text>'
nText = n_elements(text)

defChSz       = 1.0
defTlSz       = 1.25 * defChSz
defAlign      = 0.0
defOrient     = 0.0
defScale      = 1.0
defColor      = GetColor('Black')
defBackColor  = GetColor('White')
defThick      = 1.0
defOffset     = 0.002
vSpaceSymbols = ['J', 'Q', 'f', 'g', 'j', 'p', 'q', 'y', '(', ')', '{', '}', '[', ']']

;-------- Determine coordinate system
data = keyword_set(data)
device = keyword_set(device)
normal = keyword_set(normal)
if ((data + device + normal) gt 1) then $
  message, 'set only one of /DATA, /DEVICE, or /NORMAL.'
if normal eq 0 then normal = 1 - (device > data) ; Default is /normal
to_data   = data
to_device = device
to_normal = normal

; ----- Check the input for charsize (dimensions and size should be the same
;       as in text)
thisChSz = make_array(nText, /DOUBLE, VALUE = defChSz)
nChSz = n_elements(charsize)
if (nChSz gt 1) then begin
  if (nChSz ge nText) then begin
    thisChSz[0:nText-1] = double(charsize[0:nText-1])
  endif else begin
    thisChSz[0:nChSz-1] = charsize[0:nChSz-1]
  endelse
endif else begin
  if (nChSz eq 1) then thisChSz[0:nText-1] = double(charsize[0])
endelse
nChSz = nText

; ----- Check the input for alignment (dimensions and size should be the same
;       as in text)
thisAlign = make_array(nText, /FLOAT, VALUE = defAlign)
nAlign = n_elements(alignment)
if (nAlign gt 1) then begin
  if (nAlign ge nText) then begin
    thisAlign[0:nText-1] = float(alignment[0:nText-1])
  endif else begin
    thisAlign[0:nAlign-1] = alignment[0:nAlign-1]
  endelse
endif else begin
  if (nAlign eq 1) then thisAlign[0:nText-1] = double(alignment[0])
endelse
nAlign = nText
  idx = where(thisAlign le 0.0, icnt)
if (icnt gt 0) then thisAlign[idx] = 0.0
  idx = where(thisAlign ge 1.0, icnt)
if (icnt gt 0) then thisAlign[idx] = 1.0

; ----- Alignment of the legend itself
thisHAlign = 0.0d
if (n_elements(halign) ne 0) then begin
  thisHAlign = double(halign[0])
  if (thisHAlign gt 0.5) then thisHAlign = 1.0d
  if (thisHAlign lt 0.5) then thisHAlign = 0.0d
endif

thisVAlign = 0.0d
if (n_elements(valign) ne 0) then begin
  thisVAlign = double(valign[0])
  if (thisVAlign gt 0.5) then thisVAlign = 1.0d
  if (thisVAlign lt 0.5) then thisVAlign = 0.0d
endif

; ----- Rotation of the legend
thisRotation  = n_elements(rotation) eq 0 ? defOrient : double(rotation[0])

; ----- Scaling of the legend
thisScale  = n_elements(scale) eq 0 ? defScale : double(scale[0])

; ----- Spacing of the legend lines
thisSpacing  = n_elements(spacing) eq 0 ? 1.0 : (double(spacing[0]) > 0.0)

; ----- Text colors
thisColor = make_array(nText, /INTEGER, VALUE = defColor)
nColor = n_elements(color)
if (nColor gt 1) then begin
  if (nColor ge nText) then begin
    thisColor[0:nText-1] = color[0:nText-1]
  endif else begin
    thisColor[0:nColor-1] = color[0:nColor-1]
  endelse
endif else begin
  if (nColor eq 1) then thisColor[0:nText-1] = color[0]
endelse
nColor = nText

; ----- Legend title
thisTitle = n_elements(title) eq 0 ? '' : strtrim(title, 2)
do_title = strlen(thisTitle) eq 0 ? 0 : 1
thisTl_Size = n_elements(tl_size) eq 0 ? defTlSz * mean(thisChSz) : abs(tl_size[0])
thisTitleColor = n_elements(tl_color) eq 0 ? defColor : 255 - (255 - fix(abs(tl_color)) > 0)

; ----- The legend frame (if any)
thisFr_Color = n_elements(fr_color) eq 0 ? defColor : 255 - (255 - fix(abs(fr_color)) > 0)
thisFr_Thick = n_elements(fr_thick) eq 0 ? defThick : fr_thick
thisFr_Style = n_elements(fr_style) eq 0 ? 0 : 5 - (5 - fix(abs(fr_style)) > 0)
thisFr_Off = n_elements(fr_off) eq 0 ? defOffset : abs(fr_off[0])

; Background color
thisBk_Color  = n_elements(bk_color) eq 0 ? defBackColor : 255 - (255 - fix(abs(bk_color)) > 0)

; ----- The aspect ratio of the window
ch_xsize = double(!D.X_CH_SIZE)
ch_ysize = double(!D.Y_CH_SIZE)
aspectRatio = GetAspect(xsize = x_size, ysize = y_size)

; --------------------------------------------------------------------------------
; --------------------------------------------------------------------------------

; ----- Determine the legend box corner positions
xpos = double(position[0])
ypos = double(position[1])
if (normal eq 0) then begin
  tmparr = convert_coord([xpos, ypos], data = data, device = device, /to_normal)
  xpos = tmparr[0]
  ypos = tmparr[1]
endif

; Adjust for multiple plots in the page
if !P.MULTI[1] ne 0 then begin
  if !P.MULTI[0] eq 0 then $
    pmulti0 = !P.MULTI[1] * !P.MULTI[2] $
  else $
    pmulti0 = !P.MULTI[0]
  xpos = (pmulti0 + !P.MULTI[1] - 1) / !P.MULTI[1] - pmulti0 / 1.0 / !P.MULTI[1] $
         + xpos / !P.MULTI[1]
endif
if !P.MULTI[2] ne 0 then begin
  if !P.MULTI[0] eq 0 then $
    pmulti0 = !P.MULTI[1] * !P.MULTI[2] $
  else $
    pmulti0 = !P.MULTI[0]
  ypos = ( ypos + (pmulti0-1) / !P.MULTI[1] ) / 1.0 / !P.MULTI[2]
endif

; ----- Character scale
if (!P.MULTI[2] gt 1) then begin
  thisChSz = thisChSz / !P.MULTI[2]
  thisTl_Size = thisTl_Size / !P.MULTI[2]
endif

;---------- A hack to shift the first legend line above the baseline if needed
LabSpaceFlag = make_array(nText, /INTEGER, VALUE = 0)
for i = 0, n_elements(vSpaceSymbols) - 1 do begin
  if (strpos(text[0], vSpaceSymbols[i]) ge 0) then begin
    LabSpaceFlag[0] = 1
    break
  endif
endfor
;----------

; Set a small offset for the labels
yOff = thisFr_Off
xOff = yOff * aspectRatio

; Determine the legend dimensions for horizontal positioning
labdims = TextDims('M', origin = [0.0, 0.0], $
                   charsize = 1.0, orientation = 0.0, baseline = LabDesc_base, /normal)
labdims = TextDims(text, origin = [xpos, ypos], $
                   charsize = thisChSz, orientation = 0.0, baseline = LabDesc, /normal)
LabHeight = labdims[3,*] - labdims[1,*]
LabWidth  = labdims[2,*] - labdims[0,*]
LabOffset = total(LabSpaceFlag * LabDesc)

LegLineDist = make_array(nText, /DOUBLE, VALUE = 0.0)
for i = 0, nText - 1 do LegLineDist[i] = thisSpacing * (LabDesc_base > LabDesc[i])
LegLineDist[*] = LegLineDist[*] + max(LegLineDist) & LegLineDist[0] = 0.0

maxLabWidth = max(LabWidth)
LegHeight = LabOffset + total(LabHeight) + total(LegLineDist) + 2.0 * yOff
LegWidth  = maxLabWidth + 2.0 * xOff

; Do this for a possible alignment of the legend
xpos = xpos - thisHAlign * LegWidth
ypos = ypos - thisVAlign * LegHeight

; Determine the coordinates of the individual components of the legend
nT0 = 4
nT1 = nT0 + nText - 1
nLegCoord = 4 + (nT1 - nT0 + 1)
if do_title then nLegCoord = nLegCoord + 1

LegCoord = dblarr(2, nLegCoord)
LegCoord[*, 0] = [ xpos, ypos]
LegCoord[*, 1] = [ xpos + LegWidth, ypos]
LegCoord[*, 2] = [ xpos + LegWidth, ypos + LegHeight]
LegCoord[*, 3] = [ xpos, ypos + LegHeight]

yy = ypos + yOff + LabOffset
for i = 0, nText - 1 do begin
  jj = nT0 + i
  xx = xpos + xOff + thisAlign[i] * maxLabWidth
  yy = (i eq 0) ? yy : yy + LabHeight[i - 1] + LegLineDist[i]
  LegCoord[*, jj] = [ xx, yy]
endfor

; The last object in the LegCoord array is the title
if do_title then begin
  TitleDesc = 0.0
  titledims = TextDims(thisTitle, origin = [xpos, ypos], $
                       charsize = thisTl_Size, orientation = 0.0, baseline = bs, /normal)
  for i = 0, n_elements(vSpaceSymbols) - 1 do begin
    if (strpos(thisTitle, vSpaceSymbols[i]) ge 0) then begin
      TitleDesc = bs
      break
    endif
  endfor
  xx = (LegCoord[0, 0] + LegCoord[0, 1]) / 2.0
  yy = LegCoord[1, 3] + (titledims[3] - titledims[1]) / 2.0
  LegCoord[*, nLegCoord - 1] = [xx, yy]
endif

; ---------- Adjust for possible rotation/scaling of the legend ...
LegCoord1 = LegCoord ; first save the untransformed coordinates
LegCoord = Transform2DShape(LegCoord, rotation = thisRotation, $
                            center = [xpos, ypos], scale = thisScale)

; ---------- ... and convert to the appropriate coordinates
if (normal eq 0) then $
  LegCoord = convert_coord(LegCoord, /normal, to_data = to_data, to_device = to_device)

min_xx = min(LegCoord[0, *], max = max_xx)
min_yy = min(LegCoord[1, *], max = max_yy)

if do_title then begin
  titledims = TextDims(thisTitle, origin = [LegCoord1[0, nLegCoord - 1] , LegCoord1[1, nLegCoord - 1]], $
                       charsize = thisTl_Size, alignment = 0.5, orientation = 0.0, /normal)
  xx = [transpose(LegCoord1[0, *]), titledims[0], titledims[2]]
  yy = [transpose(LegCoord1[1, *]), titledims[1], titledims[3]]
  LegCoord1 = transpose([[xx], [yy]])
  LegCoord1 = Transform2DShape(LegCoord1, rotation = thisRotation, $
                               center = [xpos, ypos], scale = thisScale)
  xx = [titledims[0], titledims[2]]
  yy = [titledims[1] - TitleDesc, titledims[3]]
  TitleCoord = transpose([[xx], [yy]])
  TitleCoord = Transform2DShape(TitleCoord, rotation = thisRotation, $
                             center = [xpos, ypos], scale = thisScale)
  if (normal eq 0) then begin
    LegCoord1  = convert_coord(LegCoord1, /normal, to_data = to_data, to_device = to_device)
    TitleCoord = convert_coord(TitleCoord, /normal, to_data = to_data, to_device = to_device)
  endif

  min_xx = min(LegCoord1[0, *], max = max_xx)
  min_yy = min(LegCoord1[1, *], max = max_yy)
endif

legdims = [min_xx, min_yy, max_xx, max_yy]

if (keyword_set(get)) then return


; --------------------------------------------------------------------------------
; --------------------------------------------------------------------------------


; ---------- Perform the actual plotting of the legend
; Adjust for scaling
thisChSz  = thisScale * thisChSz
thisTl_Size = thisScale * thisTl_Size
;thisFr_Thick  = thisScale * thisFr_Thick

;LegCoord = convert_coord(LegCoord, /normal, /to_device)
xx = [transpose(LegCoord[0, 0:3]), LegCoord[0, 0]]
yy = [transpose(LegCoord[1, 0:3]), LegCoord[1, 0]]

; Draw the legend background
if keyword_set(fill) then $
  polyfill, xx, yy, color = thisBk_Color, data = data, device = device, normal = normal

; Draw the legend frame
if keyword_set(frame) then $
  plots, xx, yy,                                                               $
         color = thisFr_Color, thick = thisFr_Thick, linestyle = thisFr_Style, $
         data = data, device = device, normal = normal

; Draw the labels
xx = transpose(LegCoord[0, nT0:nT1])
yy = transpose(LegCoord[1, nT0:nT1])
for i = 0, nText -1 do begin
  xyouts, xx[i], yy[i], text[i], charsize = thisChSz[i],          $
          alignment = thisAlign[i], orientation = thisRotation,   $
          color = thisColor[i],                                   $
          data = data, device = device, normal = normal
endfor

; Draw the legend title
if do_title then begin
  if keyword_set(fill) then begin
    xx = [TitleCoord[0, 0], TitleCoord[0, 1], TitleCoord[0, 1], TitleCoord[0, 0], TitleCoord[0, 0]]
    yy = [TitleCoord[1, 0], TitleCoord[1, 0], TitleCoord[1, 1], TitleCoord[1, 1], TitleCoord[1, 0]]
    polyfill, xx, yy, color = thisBk_Color, data = data, device = device, normal = normal
  endif
  xyouts, LegCoord[0, nLegCoord - 1], LegCoord[1, nLegCoord - 1], title,       $
          charsize = thisTl_Size, alignment = 0.5, orientation = thisRotation, $
          color = thisTitleColor,                                              $
          data = data, device = device, normal = normal
endif

return

end
