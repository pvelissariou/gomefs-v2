;+
;   This is a heavily modified IDL ARROW procedure, with extra keywords added
;   and the COLOR keyword modified to accept color names. It assumes drawing
;   in the device coordinate space, unless the DATA or NORMALIZED keywords
;   are set.
; 
;   Copyright (c) 1993-2004, Research Systems, Inc.  All rights reserved.
;   
; :Params:
;     x0: in, required, type=float
;         The X value at the butt end of the arrow.
;     x1: in, required, type=float
;         The X value at the tip end of the arrow.
;     y0: in, required, type=float
;         The Y value at the butt end of the arrow.
;     y1: in, required, type=float
;         The Y value at the tip end of the arrow.
;
; :Keywords:
;     color: in, optional, type=string, default="opposite"
;        The name of the color to draw the grid lines in. 
;     data: in, optional, type=boolean, default=0
;        Set this keyword to draw in the data coordinate space.
;     linestyle: in, optional, type=integer, default=0
;        The graphics linestyle to draw the vector in.
;     normalized: in, optional, type=boolean, default=0
;        Set this keyword to draw in the normalized data coordinate space.
;     thick: in, optional, type=integer, default=1
;        Set this keyword to the thickness of the line used to draw the grid.
;     solid: in, optional, type=boolean, default=0
;        Set this keyword to fill the arrow head with a solid color. Otherwise,
;        draw the arrow head as an outline.
;     _extra: in, optional
;        Any keywords appropriate PlotS or PolyFill.
;-
PRO VL_DrawArrow, x0, y0, x1, y1,      $
                  CLIP=clip,           $
                  COLOR = color,       $
                  DATA = data,         $
                  HSIZE = hsize,       $
                  HTHICK = hthick,     $
                  LINESTYLE=linestyle, $
                  NORMALIZED = norm,   $
                  THICK = thick,       $
                  SOLID = solid,       $
                  _EXTRA=extra

    Compile_Opt IDL2

    on_error, 2

    ;  Set up keyword params
    IF N_Elements(thick) EQ 0 THEN thick = 1.
    IF N_Elements(hthick) EQ 0 THEN hthick = thick
    
    ; Head size in device units
    IF N_Elements(hsize) EQ 0 THEN arrowsize = !d.x_size/50. * (hthick/2. > 1) $
        ELSE arrowsize = Float(hsize)
    IF N_Elements(color) EQ 0 THEN color = "opposite"
    
    ; If arrowsize GT 15, THEN use 20% arrow. Otherwise use 30%.
    IF arrowsize LT 15 THEN BEGIN
       mcost = -0.866D
       sint = 0.500D
       msint = -sint
    ENDIF ELSE BEGIN
       mcost = - 0.939693D
       sint = 0.342020D
       msint = -sint
    ENDELSE
    
    ; Do this in decomposed color, if possible.
    cgSetColorState, 1, CURRENT=currentState
    
    FOR i = 0L, N_Elements(x0)-1 DO BEGIN   ;Each vector

       ; Clip the vectors.
       IF N_Elements(clip) THEN BEGIN
           IF (x0 LT clip[0]) || (x0 GT clip[2]) || (y0 LT clip[1]) || (y0 GT clip[3]) THEN Continue
           x1 = clip[0] > x1 < clip[2]
           y1 = clip[1] > y1 < clip[3]
       ENDIF
       
       ; Convert to DEVICE coordinates.
       IF Keyword_Set(data) THEN $   ;Convert?
           p = Convert_Coord([x0[i],x1[i]],[y0[i],y1[i]], /DATA, /TO_DEVICE) $
       ELSE IF Keyword_Set(norm) THEN $
           p = Convert_Coord([x0[i],x1[i]],[y0[i],y1[i]], /NORMAL, /TO_DEVICE) $
       ELSE p = [[x0[i], y0[i]],[x1[i], y1[i]]]
    
       xp0 = p[0,0]
       xp1 = p[0,1]
       yp0 = p[1,0]
       yp1 = p[1,1]
    
       dx = xp1 - xp0
       dy = yp1 - yp0
       zz = SQRT(dx^2d + dy^2d)  ;Length
    
       IF zz gt 0 THEN BEGIN
         dx = dx/zz     ;Cos th
         dy = dy/zz     ;Sin th
       ENDIF ELSE BEGIN
         dx = 1.
         dy = 0.
         zz = 1.
       ENDELSE
       IF arrowsize gt 0 THEN a = arrowsize $  ;a = length of head
       ELSE a = -zz * arrowsize
    
       xxp0 = xp1 + a * (dx*mcost - dy * msint)
       yyp0 = yp1 + a * (dx*msint + dy * mcost)
       xxp1 = xp1 + a * (dx*mcost - dy * sint)
       yyp1 = yp1 + a * (dx*sint  + dy * mcost)
       
    
       IF Keyword_Set(solid) THEN BEGIN   ;Use polyfill?
         b = a * mcost*.9d ;End of arrow shaft (Fudge to force join)
         Plots, [xp0, xp1+b*dx], [yp0, yp1+b*dy], /DEVICE, $
            COLOR = cgColor(color), THICK = thick, LINESTYLE=linestyle, _Extra=extra
         Polyfill, [xxp0, xxp1, xp1, xxp0], [yyp0, yyp1, yp1, yyp0], $
            /DEVICE, COLOR = cgColor(color)
       ENDIF ELSE BEGIN
         Plots, [xp0, xp1], [yp0, yp1], /DEVICE, COLOR=cgColor(color), THICK=thick, $
            LINESTYLE=linestyle, _Extra=extra
         Plots, [xxp0,xp1,xxp1],[yyp0,yp1,yyp1], /DEVICE, COLOR=cgColor(color), $
            THICK=hthick, LINESTYLE=linestyle, _Extra=extra
       ENDELSE
    ENDFOR
    
    ; Restore color state.
    cgSetColorState, currentState
END
