;+
; NAME:
;       FIND_BOUNDARY1
;
; PURPOSE:
;
;       This program finds the boundary points about a region of interest (ROI)
;       represented by pixel indices. It uses a "chain-code" algorithm for finding
;       the boundary pixels.
;
; CATEGORY:
;
;       Graphics, math.
;
; CALLING SEQUENCE:
;
;       boundaryPts = Find_Boundary1(Indices, XSize=xsize, YSize=ysize)
;
; OPTIONAL INPUTS:
;
;       Indices - A 1D vector of pixel indices that describe the ROI. For example,
;            the indices may be returned as a result of the WHERE function.
;
; OUTPUTS:
;
;       boundaryPts - A 2-by-n points array of the X and Y points that describe the
;            boundary. The points are scaled if the SCALE keyword is used.
;
; INPUT KEYWORDS:
;
;       SCALE - A one-element or two-element array of the pixel scale factors, [xscale, yscale],
;            used to calculate the perimeter length or area of the ROI. The SCALE keyword is
;            NOT applied to the boundary points. By default, SCALE=[1,1].
;
;       XSIZE - The X size of the window or array from which the ROI indices are taken.
;            Set to !D.X_Size by default.
;
;       YSIZE - The Y size of the window or array from which the ROI indices are taken.
;            Set to !D.Y_Size by default.
;  ALL_POINTS - If it is so desired to include all the points in the outline set this
;               keyword
; START_POINT - Use this keyword to change the default starting point (going CCW) from the
;               first point in the 1D vector of ROI indices to whatever starting point it is
;               required
;   START_DIR - Use this keyword to change the default starting direction (going CCW)
;               start_dir = 0->7, default = 4
; OUTPUT KEYWORDS:
;
;       AREA - A named variable that contains the pixel area represented by the input pixel indices,
;            scaled by the SCALE factors.
;
;       CENTER - A named variable that contains a two-element array containing the center point or
;            centroid of the ROI. The centroid is the position in the ROI that the ROI would
;            balance on if all the index pixels were equally weighted. The output is a two-element
;            floating-point array in device coordinate system, unless the SCALE keyword is used,
;            in which case the values will be in the scaled coordinate system.
;
;       PERIM_AREA - A named variable that contains the (scaled) area represented by the perimeter
;            points, as indicated by John Russ in _The Image Processing Handbook, 2nd Edition_ on
;            page 490. This is the same "perimeter" that is returned by IDLanROI in its
;            ComputeGeometry method, for example. In general, the perimeter area will be
;            smaller than the pixel area.
;
;       PERIMETER - A named variable that will contain the perimeter length of the boundary
;            upon returning from the function, scaled by the SCALE factors.
;
;  EXAMPLE:
;
;       LoadCT, 0, /Silent
;       image = BytArr(400, 300)+125
;       image[125:175, 180:245] = 255B
;       Indices = Where(image EQ 255)
;       Window, XSize=400, YSize=300
;       TV, image
;       PLOTS, Find_Boundary1(Indices, XSize=400, YSize=300, Perimeter=length), $
;           /Device, Color=GetColor('red')
;       Print, length
;           230.0
;
; DEPENDENCIES:
;
;       Requires ERROR_MESSAGE from the Coyote Library.
;
;       This version also requires the IDL_NEARPT developed by P. Velissariou
;       to determine the nearest points to a query point
;
;###########################################################################
FUNCTION Find_Boundary_Outline1, mask, darray, boundaryPts, ptIndex, $
   xsize, ysize, from_direction, ALL_POINTS = all_points

On_Error, 2
;Catch, theError
;IF theError NE 0 THEN stop

ptN = 0
bndPts = LonArr(8, 2)
ptDirect = IntArr(8)

; 0B   is a background point and
; 1B   is a visited ROI point
; 255B is a ROI point
maskVAL = 1B

oldPt = boundaryPts[*, ptIndex - 1]

; Mark previous point (but the first) as visited
IF (ptIndex GT 1) THEN mask[oldPt[0], oldPt[1]] = maskVAL

FOR j = 1, 7 DO BEGIN

   to_direction = (from_direction + j) MOD 8
   newPt = oldPt + darray[*, to_direction]

   ; If this is the edge, assume it is a background point.

   IF (newPt[0] LT 0 OR newPt[0] GE xsize OR newPt[1] LT 0 OR $
       newPt[1] GE ysize) THEN CONTINUE

   IF (mask[newPt[0], newPt[1]] GT maskVAL) THEN BEGIN
     IF Keyword_Set(all_points) THEN BEGIN
       bndPts[ptN, *] = newPt
       ptDirect[ptN] = to_direction
       ptN = ptN + 1
     ENDIF ELSE BEGIN
       ptN = ptN + 1
       boundaryPts[*, ptIndex] = newPt
       ; Return the "from" direction.
       RETURN, (to_direction + 4) MOD 8
     ENDELSE
   ENDIF

ENDFOR

IF (Keyword_Set(all_points) AND (ptN GT 0)) THEN BEGIN
  bndPts = bndPts[0:ptN-1, *]
  ptDirect = ptDirect[0:ptN-1]
  nQP = 1
  qMeth = 1
  points = float(bndPts)
  qpoint = float(oldPt)
  qpcrd  = fltarr(nQP, 2)
  qpidx  = lonarr(nQP)

  idl_nearpt, points, ptN, 2, qpoint, nQP, qMeth, qpcrd, qpidx

  boundaryPts[*, ptIndex] = fix(points[qpidx[0], *])

  FOR j = 0, ptN - 1 DO BEGIN
    IF ((bndPts[j, 0] eq boundaryPts[0, ptIndex]) and $
        (bndPts[j, 1] eq boundaryPts[1, ptIndex])) THEN BEGIN
      to_direction = ptDirect[j]
      BREAK
    ENDIF
  ENDFOR
  RETURN, (to_direction + 4) MOD 8
ENDIF

   ; If we get this far, this is either a solitary point or an isolated point.

IF TOTAL(mask GT maskVAL) GT 1 THEN BEGIN ; Isolated point.
   newPt = boundaryPts[*, ptIndex - 1] + darray[*, from_direction]
   boundaryPts[*, ptIndex] = newPt
;   print, 'ISOLATED = ', boundaryPts[*, ptIndex]
   RETURN, (from_direction + 4) MOD 8
ENDIF ELSE BEGIN ; Solitary point.
   boundaryPts[*, ptIndex] = boundaryPts[*, ptIndex - 1]
;   print, 'SOLITARY = ', boundaryPts[*, ptIndex]
   RETURN, -1
ENDELSE
END

; ------------------------------------------------------------------------------------------
FUNCTION Find_Boundary1, Indices, $
   AREA=area, $
   CENTER=center, $
   PERIM_AREA=perim_area, $
   PERIMETER=perimeter, $
   SCALE=scale, $
   XSIZE=xsize, $
   YSIZE=ysize, $
   All_Points = all_points, $
   Start_Point = start_point, $
   Start_Dir = start_dir


Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Error_Message()
   RETURN, -1
ENDIF


IF N_Elements(Indices) EQ 0 THEN Message, 'Indices of boundary region are required. Returning...'
IF N_Elements(scale) EQ 0 THEN BEGIN
   diagonal = SQRT(2.0D)
ENDIF ELSE BEGIN
   scale = Double(scale)
   diagonal = SQRT(scale[0]^2 + scale[1]^2)
ENDELSE
IF N_Elements(xsize) EQ 0 THEN xsize = !D.X_Size ELSE xsize = Long(xsize)
IF N_Elements(ysize) EQ 0 THEN ysize = !D.Y_Size ELSE ysize = Long(ysize)
IF Arg_Present(perimeter) THEN perimeter = 0.0

; This is the maximum allowed points to be found
Max_Iter = 10000L

; 0B   is a background point and
; 1B   is a visited ROI point
; 255B is a ROI point
maskVAL = 255B

   ; Create a mask with boundary region inside.

Indices = Indices[Uniq(Indices)]
nIndices = N_Elements(Indices)
mask = BytArr(xsize, ysize)
mask[Indices] = maskVAL

   ; Set up a direction array.

darray = [[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1],[0,-1],[1,-1]]

   ; Find a starting point. The pixel to the left of
   ; this point is background

use_start = 0
IF (N_Elements(start_point) gt 0) THEN BEGIN
  firstPt = [start_point[0] MOD xsize, start_point[0] / xsize]
  IF ((firstPt[0] LT 0) OR (firstPt[0] GE xsize) OR $
      (firstPt[1] LT 0) OR (firstPt[1] GE ysize)) THEN BEGIN
    Message, 'Start_Point is out of bounds: [0-Xsize, 0-Ysize]', /continue
  ENDIF ELSE BEGIN
    use_start = 1
  ENDELSE
ENDIF

IF (use_start eq 0) THEN BEGIN
  i = Where(mask GT 0)
  firstPt = [i[0] MOD xsize, i[0] / xsize]
ENDIF

from_direction = 4
IF (N_Elements(start_dir) NE 0) THEN BEGIN
  IF ((start_dir[0] GE 0) AND (start_dir[0] LE 7)) THEN from_direction = start_dir[0]
ENDIF

   ; Set up output points array.

boundaryPts = IntArr(2, Long(xsize) * ysize / 4L)
boundaryPts[*, 0] = firstPt
ptIndex = 0L

   ;   We shall not cease from exploration
   ;   And the end of all our exploring
   ;   Will be to arrive where we started
   ;   And know the place for the first time
   ;
   ;                     T.S. Eliot
REPEAT BEGIN
   ptIndex = ptIndex + 1L
   IF ptindex eq Max_Iter THEN BEGIN
     message, 'Upper limit of boundary points exceeded (please increase Max_Iter)', /continue
     stop
   ENDIF
   from_direction = Find_Boundary_Outline1(mask, darray, $
      boundaryPts, ptIndex, xsize, ysize, from_direction, ALL_POINTS = all_points)

   IF N_Elements(perimeter) NE 0 THEN BEGIN
      IF N_Elements(scale) EQ 0 THEN BEGIN
         CASE from_direction OF
            0: perimeter = perimeter + 1.0D
            1: perimeter = perimeter + diagonal
            2: perimeter = perimeter + 1.0D
            3: perimeter = perimeter + diagonal
            4: perimeter = perimeter + 1.0D
            5: perimeter = perimeter + diagonal
            6: perimeter = perimeter + 1.0D
            7: perimeter = perimeter + diagonal
            ELSE: perimeter = 4
         ENDCASE
       ENDIF ELSE BEGIN
         CASE from_direction OF
            0: perimeter = perimeter + scale[0]
            1: perimeter = perimeter + diagonal
            2: perimeter = perimeter + scale[1]
            3: perimeter = perimeter + diagonal
            4: perimeter = perimeter + scale[0]
            5: perimeter = perimeter + diagonal
            6: perimeter = perimeter + scale[1]
            7: perimeter = perimeter + diagonal
            ELSE: perimeter = (2*scale[0]) + (2*scale[1])
         ENDCASE
      ENDELSE
   ENDIF
ENDREP UNTIL ((boundaryPts[0,ptIndex] EQ firstPt[0] AND $
            boundaryPts[1,ptIndex] EQ firstPt[1]) OR (ptIndex GE nIndices))

boundaryPts = boundaryPts[*, 0:ptIndex-1]

   ; Calculate area.

IF N_Elements(scale) EQ 0 THEN BEGIN

   area = N_Elements(i)

      ; Calculate area from the perimeter.
      ; The first point must be the same as the last point. Method
      ; of Russ, p.490, _Image Processing Handbook, 2nd Edition_.

   bx = Double(Reform(boundaryPts[0,*]))
   by = Double(Reform(boundaryPts[1,*]))
   bx = [bx, bx[0]]
   by = [by, by[0]]
   n = N_Elements(bx)
   perim_area = Total( (bx[1:n-1] + bx[0:n-2]) * (by[1:n-1] - by[0:n-2]) ) / 2.


ENDIF ELSE BEGIN

   area = N_Elements(i) * scale[0] * scale[1]

      ; Calculate area from the perimeter.
      ; The first point must be the same as the last point. Method
      ; of Russ, p.490, _Image Processing Handbook, 2nd Edition_.

   bx = Double(Reform(boundaryPts[0,*])) * scale[0]
   by = Double(Reform(boundaryPts[1,*])) * scale[1]
   bx = [bx, bx[0]]
   by = [by, by[0]]
   n = N_Elements(bx)
   perim_area = Total( (bx[1:n-1] + bx[0:n-2]) * (by[1:n-1] - by[0:n-2]) ) / 2.

   boundaryPts = Double(Temporary(boundaryPts))
   boundaryPts[0,*] = boundaryPts[0,*] * scale[0]
   boundaryPts[1,*] = boundaryPts[1,*] * scale[1]
ENDELSE

   ; Calculate the centroid

mask = mask GT 0
totalMass = Total(mask)
xcm = Total( Total(mask, 2) * Indgen(xsize) ) / totalMass
ycm = Total( Total(mask, 1) * Indgen(ysize) ) / totalMass
center = [xcm, ycm]

RETURN, boundaryPts
END
