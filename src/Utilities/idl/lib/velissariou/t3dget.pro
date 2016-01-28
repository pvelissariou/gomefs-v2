Function T3DGet, center,          $
           rotation = rotation,   $
           translate = translate, $
           scale = scale,         $
           nographics = nographics
;+++
; NAME:
;       T3DGet
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;       This function returns the 3-D transformation in respect to center
;       according of the input keywords.
;
; CATEGORY:
;       Graphics.
;
; CALLING SEQUENCE:
;       newt3d = T3DGet([x, y], [rotation = x], [translate = [x,y]], $
;                       [scale = x])
;
; rotation      :   The angle of rotation in degrees counter-clock-wise.
;                    Default :  0.0 (no rotation)
; translate     :   The point to translate the shape to, [x, y].
;                    Default :  no translation
; scale         :   The 1D scale factor vector to scale the input shape.
;                    Default :  1.0 (no scaling)
;
;
; EXAMPLE:
;	  newt3d = T3DGet([0.2, 0.3], rotation = 60.0, translate = [0.5, 0.5], $
;                         scale = 1.2)
;
; MODIFICATION HISTORY:
;    Written by: Panagiotis Velissariou, March 2005.
;+++

on_error, 2

; ----- Check for the input variables
case n_elements(center) of
     0: message, 'please supply a float or, integer two element vector for <Center>'
     1: ThisCenter = [center, center, 0.0]
  else: ThisCenter = [center[0], center[1], 0.0]
endcase

; Rotate
ThisRotation = n_elements(rotation) eq 0 ? 0.0 : double(rotation[0])
do_rotate = ThisRotation eq 0.0 ? 0 : 1
ThisRotation = [0.0, 0.0, ThisRotation]

; Translate
do_translate = 1
case n_elements(translate) of
     0: do_translate = 0
     1: ThisTranslate = [translate, translate, 0.0]
  else: ThisTranslate = [translate[0], translate[1], 0.0]
endcase

; Scale
do_scale = 1
case n_elements(scale) of
     0: do_scale = 0
     1: begin
          ThisScale = double(scale)
          if ((ThisScale eq 0.0) or $
              (ThisScale eq 1.0)) then do_scale = 0
          ThisScale = [ThisScale, ThisScale, 0.0]
        end
     2: begin
          ThisScale = double(scale)
          if ((total(ThisScale) eq 0.0) or $
              (total(ThisScale) eq 2.0)) then do_scale = 0
          ThisScale = [ThisScale[0], ThisScale[1], 0.0]
        end
  else: begin
          ThisScale = double([scale[0], scale[1], scale[2]])
          if ((total(ThisScale) eq 0.0) or $
              (total(ThisScale) eq 3.0)) then do_scale = 0
          ThisScale = [ThisScale[0], ThisScale[1], ThisScale[2]]
        end
endcase

nographics = keyword_set(nographics)

; ----- Start the calculations
saved_PT = !P.T

sxy = double(!D.Y_SIZE) / double(!D.X_SIZE)
if(nographics eq 1) then sxy = 1.0

t3d, /reset

if do_rotate then begin
  t3d, translate = - ThisCenter
  t3d, scale = [1.0, sxy, 1.0]
  t3d, rotate = ThisRotation
  t3d, scale = [1.0 , 1.0 / sxy, 1.0]
  t3d, translate = ThisCenter
endif

if do_translate then begin
  t3d, translate = - ThisCenter
  t3d, translate = ThisTranslate
  ThisCenter = ThisTranslate
endif

if do_scale then begin
  t3d, translate = - ThisCenter
  t3d, scale = ThisScale
  t3d, translate = ThisCenter
endif

t3dmat = !P.T

!P.T = saved_PT

return, t3dmat

end
