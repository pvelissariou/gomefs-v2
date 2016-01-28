;+++
; NAME:
;    VL_CoLinear
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (pvelissariou@fsu.edu)
;
; PURPOSE:
;	This procedure is used to determine if n points or any point triplets
;       within the n-point set are co-linear. The input coordinates of the
;       points are slightly perturbed to produce a set of points that does not
;       contain co-linear points.
;
; CATEGORY:
;	Utilities, Mathematics, General Programming
;
; CALLING SEQUENCE:
;	VL_CoLinear, xin, yin, [keyword1 = value], [keyword2 = value], ...
;
;      xin, yin     :   These are the 1-D arrays of the point coordinates.
;                        Default :  REQUIRED
;
; KEYWORD PARAMETERS:
;           XOUT    :   A named variable that contains on the output the perturbed
;                        x-coordinates of the points.
;                        Default :  OPTIONAL
;           YOUT    :   A named variable that contains on the output the perturbed
;                        y-coordinates of the points.
;                        Default :  OPTIONAL
;           TOL     :   A tolerance value that determines when the area of a triangle
;                       (point triplets) is considered to be zero, that is
;                        area <= tol is considered to be zero.
;                        Default :  0.001
;       PERTURB     :   A perturbation value that xin, yin are perturbed about.
;                        The perturbation is done using a random number generator
;                        that produces: -0.5 <= rr <= 0.5, with the perturbed xin
;                        calculated as xin = xin + rr * PERTURB
;                        Default :  1.0
;       ITER        :   The maximum number of tries to find the perturbed values
;                        of the 3-point coordinates such that the points form a
;                        a triangle and not a line. If the area of the polygon
;                        described by the three points is greater than "tol"
;                        then these points are not co-linear.
;                        Default :  10
;       TRI_AREA    :   A named variable that contains on the output the areas of
;                        possible triangles found from the perturbed (xout,yout)
;                        coordinates.
;                        Default :  OPTIONAL
;
; PROCEDURE:
;	This procedure uses the input values to first determine if a given set
;       of data points contains any 3 points that are co-linear, and then apply
;       a slight perturbation on these points to produce non co-linear points.
;
; EXAMPLE:
;	Create an arrow at [0.2, 0.2].
;	  VL_CoLinear, [0.0, 1.0, 2.0, 3.0], [0.0, 1.0, 2.0, 3.0], xout = xout, yout = yout
;
; MODIFICATION HISTORY:
;    Written by: Panagiotis Velissariou, on March 31, 2012.
;
;-------------------------------------------------------------------------------
PRO VL_CoLinear, xin, yin,       $
                 XOUT = xout,    $
                 YOUT = yout,    $
                 TOL = tol,      $
                 PERTURB = prtb, $
                 ITER = iter,    $
                 TRI_AREA = tri_area

Compile_Opt IDL2

On_Error, 2

sz_xin = size(xin)
sz_yin = size(yin)
if ((sz_xin[0] ne 1) or (sz_yin[0] ne 1)) then begin
  message, $
   'ERROR: the input XIN, YIN coordinates are not vectors'
endif else begin
  if (sz_xin[sz_xin[0] + 2] ne sz_yin[sz_yin[0] + 2]) then begin
    message, $
     'ERROR: the input XIN, YIN vectors are not of the same size'
  endif else begin
    if (sz_xin[sz_xin[0] + 2] lt 3) then begin
      message, $
       'ERROR: the input XIN, YIN should be vectors of at least 3 elements'
    endif else begin
      numtypes = [2, 3, 4, 5, 12, 13, 14, 15]
      if ((where(sz_xin[sz_xin[0] + 1] eq numtypes) eq - 1) or $
          (where(sz_yin[sz_yin[0] + 1] eq numtypes) eq - 1)) then begin
        message, $
         'ERROR: the input XIN, YIN should be vectors of nummbers'
      endif
    endelse
  endelse
endelse

tol  = n_elements(tol) eq 0 ? 0.001d : abs(double(tol[0]))
prtb = n_elements(prtb) eq 0 ? 1.0d : abs(double(prtb[0]))
iter = n_elements(iter) eq 0 ? 10 : abs(iter[0])

xinCOORDS = double(xin) & xoutCOORDS = xinCOORDS
yinCOORDS = double(yin) & youtCOORDS = yinCOORDS
nCOORDS   = sz_xin[sz_xin[0] + 2]

; check for co-linearity using the area of the triangles
; and perturb the input coordinates slightly to eliminate
; co-linearity
; the perturbed coordinates are stored in the varibles xout and yout
area = dblarr(nCOORDS * (nCOORDS - 1) * (nCOORDS - 2))
tri_cnt = 0L
for i_cnt = 0, nCOORDS - 1 do begin
  for j_cnt = 0, nCOORDS - 1 do begin
    if (i_cnt ne j_cnt) then begin
      for k_cnt = 0, nCOORDS - 1 do begin
        if ((i_cnt ne k_cnt) and (j_cnt ne k_cnt)) then begin
          i0 = i_cnt
          i1 = j_cnt
          i2 = k_cnt
          idx = [i0, i1, i2]
          xx  = xoutCOORDS[idx] & xx1 = xx
          yy  = youtCOORDS[idx] & yy1 = yy
          ar = 0.0d
          ar_cnt = 0L
          while (ar le tol) do begin
            if (ar_cnt ge iter) then begin
              str_iter = strtrim(string(iter, format = '(i10)'), 2)
              message, $ 'WARNING: perturbation iterations exceeded the max value of ' + str_iter, $
                       /INFORMATIONAL
              break
            endif
            ar = [transpose(xx1), transpose(yy1), transpose([1, 1, 1])]
            ar = abs(0.5 * determ(ar, /CHECK, /DOUBLE, ZERO = 0.0))
            if (ar le tol) then begin
              xseed = 1001L + fix((0.5 - randomu(seed, 1)) * 1001L, TYPE = 3)
              yseed = 1001L + fix((0.5 - randomu(seed, 1)) * 1001L, TYPE = 3)
              rx = (0.5 - (randomu(xseed, 3) > 0.001)) * prtb
              ry = (0.5 - (randomu(yseed, 3) > 0.001)) * prtb
              xx1 = xx + rx
              yy1 = yy + ry
              ar_cnt++
            endif
          endwhile
          xoutCOORDS[idx] = xx1
          youtCOORDS[idx] = yy1
          area[tri_cnt] = ar
          tri_cnt++
        endif
      endfor
    endif
  endfor
endfor

tri_area = area
xout = xoutCOORDS
yout = youtCOORDS

End

