Pro DrawBox, position,              $
               Fr_Color = fr_color, $
               Fr_Thick = fr_thick, $
               Fr_Style = fr_style, $
               Bk_Color = bk_color, $
               NoFrame = noframe,   $
               Fill = fill,         $
               Data = data,         $
               Device = device,     $
               Normal = normal,     $
               _Extra = extra
;+++
; NAME:
;    DrawBox
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;       This procedure is used to draw a box in a specified location.
;
; CATEGORY:
;       Graphics.
;
; CALLING SEQUENCE:
;       DrawBox, position, [keywords]
;                where: position = [x1, y1, x2, y2] or,
;                       position = [x1, y1, x2, y2, x3, y3, x4, y4]
;       position    :   This is the 1-D float/integer array which specifies
;                        the position/dimensions of the box. If 4 elements
;                        are specified then they are taken as:
;                        [xmin, ymin, xmax, ymax] that is, the coordinates of
;                        the lower left and upper right coordinates of the box.
;                        If 8 elements are specified they are taken as the
;                        coordinates of the four corners of the box.
;                        Default :  REQUIRED
;
; KEYWORD PARAMETERS:
;       fr_color    :   The color of the frame drawn around the box.
;                        Default :  !P.COLOR
;       fr_thick    :   The thickness of the line used to draw the frame
;                        around the box. fr_thick = 1.0 is normal.
;                        Default :  1.0.
;       fr_style    :   The style of the line used to draw the frame around
;                        the box.
;                        fr_style = 0 draws a solid line.
;                        fr_style = 1 draws a dotted line.
;                        fr_style = 2 draws a dashed line.
;                        fr_style = 3 draws a dash-dotted line.
;                        fr_style = 4 draws a dash-dot-dot-dotted line.
;                        fr_style = 5 draws a long dashed line.
;                        Default :  0.
;       bk_color    :   The solid color that is used to fill the box.
;                        Default :  !P.COLOR
;
; MODIFICATION HISTORY:
;       Written by: Panagiotis Velissariou, September 2000.
;+++

on_error, 2

; ----- Check for the input variables
nPosition = n_elements(position)

if (nPosition ne 4) and (nPosition ne 8) then $
  message, 'please supply a 4(or, 8) element float/integer vector for <position>'

nIdx = where([1, 2, 3, 4, 5, 6, 9, 12, 13, 14, 15] eq size(position, /type), nCount)
if (nCount eq 0) then $
  message, 'please supply a 4(or, 8) element float/integer vector for <position>'

ThisFr_Color = n_elements(fr_color) eq 0 ? !P.COLOR : 255 - (255 - fix(abs(fr_color)) > 0)
ThisFr_Thick = n_elements(fr_thick) eq 0 ? 1.0 : fr_thick
ThisFr_Style = n_elements(fr_style) eq 0 ? 0 : 5 - (5 - fix(abs(fr_style)) > 0)
ThisBk_Color = n_elements(bk_color) eq 0 ? !P.COLOR : 255 - (255 - fix(abs(bk_color)) > 0)

data   = keyword_set(data)
device = keyword_set(device)
normal = keyword_set(normal)
if data + device + normal gt 1 then begin
  print,' set only one of /DATA, /DEVICE, or /NORMAL.'
  return
endif
if data eq 0 then data = 1 - (device > normal) ; Def is /data.

ThisPosition = position[*]

if (nPosition eq 4) then begin
  xx = ThisPosition[[0, 2, 2, 0]]
  yy = ThisPosition[[1, 1, 3, 3]]
endif else begin
  xx = ThisPosition[[0, 2, 4, 6]]
  yy = ThisPosition[[1, 3, 5, 7]]
endelse

if keyword_set(fill) then $
  polyfill, [xx, xx[0]], [yy, yy[0]], color = ThisBk_Color, $
            data = data, device = device, normal = normal,  $
            _Extra = extra

if (not keyword_set(noframe)) then $
   plots, [xx, xx[0]], [yy, yy[0]], color = ThisFr_Color, $
          thick = ThisFr_Thick, linestyle = ThisFr_Style, $
          data = data, device = device, normal = normal,  $
          _Extra = extra

end
