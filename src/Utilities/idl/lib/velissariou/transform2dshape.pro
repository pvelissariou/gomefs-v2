Function Transform2DShape,        $
           x, y,                  $
           center = center,       $
           rotation = rotation,   $
           translate = translate, $
           scale = scale,         $
           nographics = nographics
;+++
; NAME:
;       Transform2DShape
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;       This function returns a transformed shape according to the values
;       of the input keywords.
;
; CATEGORY:
;       Graphics.
;
; CALLING SEQUENCE:
;       newshape = Transform2DShape(x, [y], [rotation = x],
;                    [center = [x,y]], [translate = [x,y]],
;                    [scale = x])
;
;       x           :   This is the 1-D array of the vertex x-coordinates
;                        of the shape to be transformed. If only x is supplied
;                        then x should be a 2-D array containing the (x,y)
;                        coordinates of the vertices.
;                        Default :  REQUIRED
;       y           :   This is the 1-D array of the vertex y-coordinates
;                        of the shape to be transformed.
;                        Default :  OPTIONAL
;
; KEYWORD PARAMETERS:
;       rotation    :   The angle of rotation in degrees counter-clock-wise.
;                        Default :  0.0
;       center      :   The center of transformation, [x, y].
;                        Default :  [x[0], y[0]]
;       translate   :   The point to translate the shape to, [x, y].
;                        Default :  [0.0, 0.0]
;       scale       :   The scale factor to scale the input shape.
;                        Default :  1.0
;
; RETURNS:
;       Returns the 2xN array that contains the coordinates of the transformed shape.
;
; EXAMPLE:
;         shape = [[0.2, 0.2], [0.3, 0.4]]
;	  newshape = Transform2DShape(shape, rotation = 60.0, $
;                      center = [0.2, 0.2], translate = [0.5, 0.5], $
;                      scale = 1.2)
;
; MODIFICATION HISTORY:
;    Written by: Panagiotis Velissariou, March 2005.
;+++

on_error, 2

; ----- Check for the input variables
nY = n_elements(y)

case nY of
      0: begin
            szX = size(x)
            if (szX[0] ne 2) or (szX[1] ne 2) then $
              message, 'please supply a float or, integer 2xN array for <x>'
            nShape = szX[2]
            ThisShape = dblarr(4, nShape)
            ThisShape[0, *] = double(x[0, *])
            ThisShape[1, *] = double(x[1, *])
            ThisShape[2, *] = 0.0
            ThisShape[3, *] = 1.0
         end
   else: begin
            szX = size(x)
            szY = size(y)
            if (szX[0] ne 1) then $
              message, '<x> should be a float or, integer vector'
            if (szY[0] ne 1) then $
              message, '<y> should be a float or, integer vector'
            if (szX[1] ne szY[1]) then $
              message, 'both <x> and <y> should have the same number of elements'
            nShape = szX[1]
            ThisShape = dblarr(4, nShape)
            ThisShape[0, *] = double(x[*])
            ThisShape[1, *] = double(y[*])
            ThisShape[2, *] = 0.0
            ThisShape[3, *] = 1.0
         end
endcase

ThisOrigin = [ThisShape[0, 0], ThisShape[1, 0]]
ThisOrigin = n_elements(center) eq 0 ? ThisOrigin : double([center[0], center[1]])
           
; ----- Start the calculations
t3dmat = T3DGet(ThisOrigin, rotation = rotation, $
                translate = translate, scale = scale, nographics = nographics)

if not array_equal(t3dmat, !P.T) then $
  ThisShape = transpose(transpose(ThisShape) # t3dmat)

return, [ThisShape[0, *], ThisShape[1, *]]

end
