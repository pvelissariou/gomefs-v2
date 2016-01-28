Function LineWidth,             $
           text,                $
           CharSize = charsize, $
           Data = data,         $
           Device = device,     $
           Normal = normal
           
;+++
; NAME:
;       LineWidth
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;       To calculate the width of lines of text in user supplied coordinates.
;       (default: normal coordinates)
;
; CATEGORY:
;       Graphics.
;
; CALLING SEQUENCE:
;       width = LineWidth(text, [charsize = value or vector], ...)
;
;       text        :   This is the text 1-D string array.
;                        Default :  REQUIRED
;
; KEYWORD PARAMETERS:
;       charsize    :   This is the optional character size.
;                        Default :  1.0
;       /data       :   Use this keyword to export the calculated values
;                        in data coordinates
;       /device     :   Use this keyword to export the calculated values
;                        in device coordinates
;       /normal     :   Use this keyword to export the calculated values
;                        in normal coordinates
;
; RETURNS:
;       The 1-D float array containing the width of each line.
;
; SIDE EFFECTS:
;	As far as I know none.
;
; MODIFICATION HISTORY:
;       Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

;-------- No hardware fonts.
currentFont = !P.FONT
if (currentFont eq 0) and (!D.NAME ne 'PS') then !P.FONT = -1

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
defChSz = 1.0
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

; ----- Create a display window if no one is open
currentWindow = !D.WINDOW

if (currentWindow eq -1) then begin
  if total(!X.WINDOW) EQ 0 then begin
    x_size = double(!D.X_SIZE)
    y_size = double(!D.Y_SIZE)
  endif else begin
    x_size = (!X.WINDOW[1] - !X.WINDOW[0]) * double(!D.X_SIZE)
    y_size = (!Y.WINDOW[1] - !Y.WINDOW[0]) * double(!D.Y_SIZE)
  endelse

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
; Get the widths(s) of the input text(s)
width = make_array(nText, /DOUBLE, VALUE = 0.0D)
for i = 0, nText - 1 do begin
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
; ----------------------------------------

; ----- Close the display window if it were opened
if (currentWindow ne -1)    then wset, currentWindow
if (n_elements(pixID) ne 0) then wdelete, pixID

; ----- Reset the font
!P.Font = currentFont

return, width

end
