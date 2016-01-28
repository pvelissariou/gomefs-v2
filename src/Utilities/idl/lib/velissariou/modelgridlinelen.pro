;*******************************************************************************
; START THE MAIN PROGRAM
FUNCTION ModelGridLineLen, xarr, yarr, marr, mask, XY = xy, $
                           RADIUS = radius, MILES = miles, METERS = meters
;+++
; NAME:
;	ModelGridLineLen
; VERSION:
;	1.0
; PURPOSE:
;	To find all the grid points (pixels?) that constitute
;       the line defined by the two points (x0,y0) and (x1,y1)
; CALLING SEQUENCE:
;	idxout = ModelGridLineLen(x0, y0, x1, y1, xarr, yarr)
;	On input:
; [x0, y0, x1, y1] - The (x, y) coordinates of the two points that
;                    define the line
;             xarr - The 2D matrix of the x-coorinates
;             yarr - The 2D matrix of the y-coorinates
;            dxarr - The 2D matrix of the spacing of the input
;                    grid in the x-direction (OPTIONAL)
;                    size(dxarr) = size(xarr)
;            dyarr - The 2D matrix of the spacing of the input
;                    grid in the y-direction (OPTIONAL)
;                    size(dyarr) = size(yarr)
;	On output:
;	  IDXOUT - The indices of all the grid points that are part
;                  of the line
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created Oct 20 2012 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  ; Error handling.
  On_Error, 2

  lenout = 0.0d

  if ( (array_equal(size(xarr), size(yarr), /NO_TYPECONV) ne 1) ) then begin
    message, 'incompatible array sizes found for [xarr, yarr, marr]'
  endif

  if ( (size(xarr, /N_DIMENSIONS) ne 1) or $
       (size(marr, /N_DIMENSIONS) ne 1) ) then begin
    message, '1D arrays are required for [xarr, yarr, marr]'
  endif

  if (n_elements(xarr) ne n_elements(marr)) then $
    message, '[xarr, yarr, marr] have incompatible sizes'

  do_miles = keyword_set(miles)
  do_meters = keyword_set(meters)
  if ((do_miles + do_meters) gt 1) then $
    message, 'only one of the keywords MILES,METERS can be set'
  if ((do_miles + do_meters) eq 0) then do_meters = 1

  if (n_elements(radius) eq 0) then begin
    if (do_meters) then radius = 6371001.0d
    if (do_miles) then radius = 6371001.0d / 1609.3440d
  endif else begin
   radius = abs(radius[0])
  endelse

  ; check the mask array
  mask = mask[0]
  chk = ChkForMask(marr, mask, idx_chkval, count_chkval, $
                   COMPLEMENT = compl_chkval, NCOMPLEMENT = ncompl_chkval, $
                   HOLE_BEG = hole_beg, HOLE_END = hole_end, $
                   HOLE_LEN = hole_len, NHOLE = nhole)
  if (chk ne 1) then begin
    message, 'could not determine the line length due to masking issues'
  endif

  min_idx = 0
  max_idx = n_elements(marr) - 1
  lenout = 0.0d
  for i = 0L, nhole - 1 do begin
    ibeg = (hole_beg[i] - 1) ge min_idx ? hole_beg[i] - 1 : hole_beg[i]
    iend = (hole_end[i] + 1) le max_idx ? hole_end[i] + 1 : hole_end[i]
    for j = ibeg, iend - 1 do begin
      x0 = xarr[j]
      x1 = xarr[j+1]
      y0 = yarr[j]
      y1 = yarr[j+1]
      if keyword_set(xy) then begin
        xx = x1 - x0
        yy = y1 - y0
        lenout = lenout + sqrt(xx*xx + yy*yy)
      endif else begin
        lenout = lenout + map_2points(x0, y0, x1, y1, radius = radius, $
                             MILES = do_miles, METERS = do_meters)
      endelse
    endfor
  endfor

  return, lenout
end
