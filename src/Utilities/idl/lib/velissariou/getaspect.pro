;+
; NAME:
;  ASPECT_RATIO
;
; PURPOSE:
;
;  This function calculates and returns the aspect ratio for the
;  graphics window


FUNCTION GetAspect,         $
           XSize = xsize,   $
           YSize = ysize,   $
           Data = data,     $
           Device = device, $
           Normal = normal

Compile_Opt IDL2

ON_ERROR, 2

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

; Window aspect
xsize = double(!D.X_VSIZE)
ysize = double(!D.Y_VSIZE)
if (normal eq 0) then begin
  if total(!X.WINDOW) EQ 0 then begin
    xsize = (!X.WINDOW[1] - !X.WINDOW[0]) * xsize
    ysize = (!Y.WINDOW[1] - !Y.WINDOW[0]) * ysize
  endif
endif
wAspectRatio = ysize / xsize

return, wAspectRatio

end
