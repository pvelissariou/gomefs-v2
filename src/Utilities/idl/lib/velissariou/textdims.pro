Function TextDims,                    $
           Text,                      $
           Origin = origin,           $
           CharSize = charsize,       $
           Alignment = alignment,     $
           Orientation = orientation, $
           Scale = scale,             $
           TextDims = textdims,       $
           BaseLine = baseline,       $
           Data = data,               $
           Device = device,           $
           Normal = normal
;+++
; NAME:
;       TextDims
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;       To calculate the dimensions of the box containing the text.
;
; CATEGORY:
;       Graphics.
;
; CALLING SEQUENCE:
;       txtdims = TextDims(text, [origin = (x0, y0)], [charsize = x], $
;                          [alignment = 0.0, 0.5, 1.0], [orientation = x], $
;                          [textdims = named var])
;
;       text        :   This is the text 1-D string array, we require its height
;                        and width.
;                        Default :  REQUIRED
;
; Keyword Parameters:
;       origin      :   The point (x0,y0) where to draw the text in normal coordinates.
;                        Default :  [0.0, 0.0]
;       charsize    :   The height of the characters to be used when drawing
;                        the text.
;                        Default :  1.0
;       alignment   :   The alignment of the text in respect with the origin.
;                        Default :  0.0
;       orientation :   The orientation of the text in degrees (counter-clock-wise).
;                        Default : 0.0
;       scale       :   The re-scaling of the text.
;                        Default : 1.0 (no scale)
;       textdims    :   A named variable to store the coordinates of the box that
;                        contains the transformed text. The size of this array is
;                        [8, nText], where nText is the number of elements in the
;                        text array. Going counter-clock-wise this array will
;                        contain rows of the form:
;                        [x0, y0, x1, y1, x2, y2, x3, y3]
;
; RETURNS:
;       The 2-D, [4, nText] array containing the coordinates [xmin, ymin, xmax, ymax]
;       of the horizontal box containing the transformed text (not the box in textdims)
;       and width = xmax -xmin and height = ymax - ymin.
;
; SIDE EFFECTS:
;	As far as I know none.
;
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

;-------- No hardware fonts.
currentFont = !P.FONT
if (currentFont eq 0) and (!D.NAME ne 'PS') then !P.FONT = -1

;--------
; We need ChScale for the calculation of the text height only and
; not for the calculation of the text width
ChScale = (!D.NAME eq 'PS') ? 0.875 : 1.2

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

; ----- Check the input for text (a string or, an 1D string vector)
if (size(text, /type) ne 7) then $
  message, 'a string or, an 1D string vector is required for <text>'
nText = n_elements(text)

; ----- Check the input for charsize (dimensions and size should be the same
;       as in text)
defChSz = 1.0D
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
defAlign = 0.0
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

; ----- Check the input for orientation (dimensions and size should be the same
;       as in text)
defOrient = 0.0
thisOrient = make_array(nText, /FLOAT, VALUE = defOrient)
nOrient = n_elements(orientation)
if (nOrient gt 1) then begin
  if (nOrient ge nText) then begin
    thisOrient[0:nText-1] = float(orientation[0:nText-1])
  endif else begin
    thisOrient[0:nOrient-1] = orientation[0:nOrient-1]
  endelse
endif else begin
  if (nOrient eq 1) then thisOrient[0:nText-1] = double(orientation[0])
endelse
nOrient = nText

; ----- Check the input for scale (dimensions and size should be the same
;       as in text)
defScale = 1.0
thisScale = make_array(nText, /FLOAT, VALUE = defScale)
nScale = n_elements(scale)
if (nScale ne 0) then begin
  if (nScale ge nText) then begin
    thisScale[0:nText-1] = float(scale[0:nText-1])
  endif else begin
    thisScale[0:nScale-1] = scale[0:nScale-1]
  endelse
endif
nScale = nText
  idx = where(thisScale le 0.0, icnt)
if (icnt gt 0) then thisScale[idx] = defScale

; ----- Check the input for origin (dimensions and size should be the same
;       as in text)
defOrigin = -1000000.0 ; middle of the current window in normal coordinates
thisOrigin = make_array(2, nText, /DOUBLE, VALUE = defOrigin)
nn = n_elements(origin)
if (nn gt 0) then begin
  sz = size(origin)
  case nn of
       1: begin
            thisOrigin[0, *] = double(origin)
            thisOrigin[1, *] = double(origin)
          end
       2: begin
            thisOrigin[0, *] = double(origin[0])
            thisOrigin[1, *] = double(origin[1])
          end
    else: begin
            if (sz[0] ne 2) or (sz[1] ne 2) then $
              message, 'origin should be a 2D array'
            nOrigin = (size(origin))[2]
            if (nOrigin ge nText) then begin
              thisOrigin[0, 0:nText-1] = double(origin[0, 0:nText-1])
              thisOrigin[1, 0:nText-1] = double(origin[1, 0:nText-1])
            endif else begin
              thisOrigin[0, 0:nOrigin-1] = double(origin[0, 0:nOrigin-1])
              thisOrigin[1, 0:nOrigin-1] = double(origin[1, 0:nOrigin-1])
            endelse
          end
  endcase
endif
nOrigin = nText


; ----- Create a display window if no one is open
currentWindow = !D.WINDOW

aspectRatio = GetAspect(xsize = x_size, ysize = y_size)

if (currentWindow eq -1) then begin
  if (x_size ge y_size) and ((!D.FLAGS and 256) ne 0) then begin
    window, /pixmap, /free, xsize = x_size, ysize = y_size
    pixID = !D.WINDOW
  endif else begin
    if ((!D.FLAGS and 256) ne 0) then begin
      window, /pixmap, /free, xsize = y_size, ysize = x_size
      pixID = !D.WINDOW
    endif
  endelse
endif

; ----------------------------------------
; Get the height(s) and the widths of the input text(s)
height = dblarr(nText) & width = height & baseline = height
height[*] = thisChSz * (ChScale * double(!D.Y_CH_SIZE)) ; in device coordinates
for i = 0, nText - 1 do begin
  if (device eq 0) then begin
    tmparr = convert_coord([[0.0, 0.0], [0.0, height[i]]], /device, $
                           to_data = to_data, to_normal = to_normal)
    height[i] = tmparr[1, 1] - tmparr[1, 0]
  endif
  ; xyouts returns width in normal coordinates
  xyouts, 100000, 100000, text[i], charsize = - thisChSz[i], $
          orientation = 0.0, width = tmpval, /device
  width[i] = tmpval ; in normal coordinates
  if (normal eq 0) then begin
     tmparr = convert_coord([[0.0, 0.0], [width[i], 0.0]], /normal, $
                            to_data = to_data, to_device = to_device)
     width[i] = tmparr[0, 1] - tmparr[0, 0] ; in coordinates other than normal
  endif
endfor
baseline = height / 4.0

idx = where((thisOrigin[0, *] le defOrigin) or (thisOrigin[1, *] le defOrigin), icnt)
if(icnt ne 0) then begin
  tmparr = [0.5, 0.5]
  if (normal eq 0) then $
    tmparr = convert_coord(tmparr, /normal, to_data = to_data, to_device = to_device)
  thisOrigin[0, idx] = tmparr[0]
  thisOrigin[1, idx] = tmparr[1]
endif
; ----------------------------------------

; ----- Close the display window if it were opened
if (currentWindow ne -1)    then wset, currentWindow
if (n_elements(pixID) ne 0) then wdelete, pixID


; ----- Get the dimensions (w x h) of the box that includes
;       the rotated text
dims = dblarr(4, nText) & textdims = dblarr(8, nText)
alpha = !DTOR * double(thisOrient)
for i = 0, nText - 1 do begin
  tmpval = [thisOrigin[0, i], thisOrigin[1, i]]

  xx = [tmpval[0], tmpval[0] + width[i], tmpval[0] + width[i], tmpval[0]]
  yy = [tmpval[1], tmpval[1], tmpval[1] + height[i], tmpval[1] + height[i]]

  xtr = xx[0] - thisAlign * width[i] * cos(alpha) * thisScale
  ytr = yy[0] - thisAlign * width[i] * sin(alpha) * (thisScale / aspectRatio)

  shape = [[xx[0], yy[0]], [xx[1], yy[1]], [xx[2], yy[2]], [xx[3], yy[3]]]

  shape = Transform2DShape(shape, rotation = thisOrient, center = [xx[0], yy[0]], $
                           scale = thisScale, translate = [xtr, ytr])

  ; calculate the width and the height of the box that contains
  ; transformed text (width -> x size, height -> y size)
  min_xx = min(shape[0, *], max = max_xx)
  min_yy = min(shape[1, *], max = max_yy)
  dims[*, i] = [min_xx, min_yy, max_xx, max_yy]

  ; store the coordinates of the four corners of the rotated
  ; box that exactly fits the rotated text into the named
  ; variable textdims
  textdims[*, i] = shape[*]
endfor

; ----- Reset the font
!P.Font = currentFont

return, dims

end
