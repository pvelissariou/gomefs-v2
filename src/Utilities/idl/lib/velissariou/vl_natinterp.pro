;+++
; NAME:
;	VL_NATINTERP
; VERSION:
;	1.0
; PURPOSE:
;	To perform a Natural Neighbors interpolation on point by point basis.
; CALLING SEQUENCE:
;	zloc = VL_NatInterp(xloc, yloc, xdat, ydat, zdat, [Options])
;
;       Uses the sort_sd procedure from the coyote library.
;
;	On input:
;	  xloc - The x-coordinates of the interpolation points (a scalar,
;                a vector, or an array)
;	  yloc - The y-coordinates of the interpolation points (a scalar,
;                a vector, or an array)
;	  xdat - The x-coordinates of the data points (a vector, or an array)
;	  ydat - The y-coordinates of the data points (a vector, or an array)
;	  zdat - The values of the data points at (xdat, ydat) (a vector, or an array)
;
;	Optional parameters:
;	 NPOINTS - The number of the nearest points to consider during the,
;                  interpolation.
;                  default: NPOINTS = 9
;  SEARCH_RADIUS - The radius of the disk (center at (xloc,yloc)) used to
;                  scan for the nearest available data.
;                  default: NONE
;                  NOTE: If this variable is not set then the variable
;                        NPOINTS is used instead
;
;	Keywords:
;
;	On output:
;	   zloc - The interpolated values; the size and type is the same as xloc
;                 NOTE: If not available data found, zloc is set to !VALUES.F_NAN
;
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created Sat Oct 12 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++
FUNCTION VL_NatInterp, xloc, yloc, xdat, ydat, zdat,  $
                       NPOINTS = npoints,             $
                       SEARCH_RADIUS = search_radius, $
                       DEBUG = debug

  Compile_Opt IDL2

  on_error, 2

  ; ----------
  ; xloc and yloc should have the same number of elements
  sz1 = size(xloc, /DIMENSIONS)
  sz2 = size(yloc, /DIMENSIONS)
  if ( array_equal(sz1, sz2) ne 1 ) then begin
    message, $
      'xloc and yloc should have the same size'
  endif
  
  ; xdat, ydat and zdat should have the same number of elements
  sz1 = size(xdat, /DIMENSIONS)
  sz2 = size(ydat, /DIMENSIONS)
  sz3 = size(zdat, /DIMENSIONS)
  if ( (array_equal(sz1, sz2) ne 1) or $
       (array_equal(sz1, sz3) ne 1) ) then begin
    message, $
      'xdat, ydat and zdat should have the same size'
  endif

  ; get the optional arguments
  ; we require minimum 3 points
  nrPNTS = (n_elements(npoints) ne 0) ? (fix(npoints[0]) > 3) : 9

  use_searchRAD = 0
  if (n_elements(search_radius) ne 0) then begin
    searchRAD = abs(float(search_radius[0]))
    use_searchRAD = 1
  endif
  
  do_debug = (keyword_set(debug) eq 1) ? 1 : 0
  ; ----------

  ; set the values of some common parameters
  idw_mth = 'ModifiedShepard'
  idw_pow = 2.0
  missDAT = !VALUES.F_NAN

  ; set the output array
  zloc = xloc & zloc[*] = missDAT

  ; -----
  ; check if all input data have finite values
  idxFIN = where(finite(zdat) eq 1, cntFIN)
  if (cntFIN eq 0) then return, zloc

  nDAT = cntFIN
  inpXDAT = xdat[idxFIN]
  inpYDAT = ydat[idxFIN]
  inpZDAT = zdat[idxFIN]
  ; -----

  limPNTS = ((8L * nrPNTS) < 300)

  nLOC = n_elements(xloc)
  thisXLOC = xloc[*]
  thisYLOC = yloc[*]
  thisZLOC = zloc[*]

  for i = 0L, nLOC - 1 do begin
    pnt_str = 'Point index = ' + strtrim(string(i, format = '(i12)'), 2) + '. '

    nDAT = n_elements(inpXDAT)
    thisXDAT = inpXDAT
    thisYDAT = inpYDAT
    thisZDAT = inpZDAT

    thisXOUT = thisXLOC[i]
    thisYOUT = thisYLOC[i]
    thisZOUT = thisZLOC[i]

    ; sort the input data arrays accrding to the distance
    ; from the interpolation point; sorting is performed
    ; in ascending order
    xx = thisXDAT - thisXOUT
    yy = thisYDAT - thisYOUT
    dd = sqrt(xx * xx + yy * yy)
    idx_sort = sort_nd(dd, 1)

    ; re-arrange the input data according to "idx_sort"
    ; consider, at maximum, the limPNTS nearest points;
    ; later in the code we choose what points to consider
    if (use_searchRAD gt 0) then begin
      for np_cnt = 0L, 9 do begin
        rad = (np_cnt + 1) * searchRAD
        idx = where(dd[idx_sort] le rad, np)
        np = (np < limPNTS)
        if (np gt 0) then begin
          break
        endif else begin
          if (do_debug gt 0) then begin
            rad1_str = strtrim(string(searchRAD, format = '(f12.3)'), 2)
            rad2_str = strtrim(string(rad + searchRAD, format = '(f12.3)'), 2)
            print, '   ' + pnt_str + $
                   'WARNING: increasing the search radius from ' + $
                   rad1_str + ' to ' + rad2_str
          endif
        endelse
      endfor
    endif else begin
      np = (n_elements(idx_sort) < limPNTS)
    endelse

    if (np le 0) then begin
      if (use_searchRAD gt 0) then begin
        message, 'available data not found, please increase the search radius'
      endif else begin
        message, 'available data not found, please increase the number of nearest points'
      endelse
    endif
    
    thisXDAT = thisXDAT[idx_sort[0:np - 1]]
    thisYDAT = thisYDAT[idx_sort[0:np - 1]]
    thisZDAT = thisZDAT[idx_sort[0:np - 1]]
    thisDIST = dd[idx_sort[0:np - 1]]

    ; ----- if just a few data points are available, apply the inverse
    ;       distance interpolation method
    if (np lt 3) then begin
      if (do_debug gt 0) then begin
        print, '   ' + pnt_str + $
               'WARNING: found less than three available data, performing the ' + $
               idw_mth + ' IDW interpolation ...'
      endif
      thisZOUT = ( InvDist_Interp(thisXOUT, thisYOUT, $
                                  thisXDAT, thisYDAT, thisZDAT, $
                                  METHOD = idw_mth, $
                                  EXPNT  = idw_pow) )[0]
      thisZLOC[i] = thisZOUT
      continue
    endif
    ; -----


    ; ----- if more than three data points are available, apply the
    ;       natural neighbors interpolation method
    
    ; (1) get the available data points in each quadrant
    ;     up to the number of "nrPNTS" requested by the user
    qFLG = 0
    qidx = -1L
    dxDAT = ZeroFloatFix(thisXDAT - thisXOUT)
    dyDAT = ZeroFloatFix(thisYDAT - thisYOUT)
    ; quadrant I: x >= x0 and y >= y0
      idx = where( (dxDAT gt 0) and (dyDAT gt 0), icnt)
      if (icnt ne 0) then begin
        ;nrp = (use_searchRAD gt 0) ? icnt : (icnt < nrPNTS)
        nrp = (icnt < nrPNTS)
        qidx = [ qidx, idx[0:nrp - 1] ]
      endif else begin
        qFLG = qFLG - 1
      endelse
    ; quadrant II: x < x0 and y > y0
      idx = where( (dxDAT lt 0) and (dyDAT gt 0), icnt)
      if (icnt ne 0) then begin
        ;nrp = (use_searchRAD gt 0) ? icnt : (icnt < nrPNTS)
        nrp = (icnt < nrPNTS)
        qidx = [ qidx, idx[0:nrp - 1] ]
      endif else begin
        qFLG = qFLG - 1
      endelse
    ; quadrant III: x < x0 and y < y0
      idx = where( (dxDAT lt 0) and (dyDAT lt 0), icnt)
      if (icnt ne 0) then begin
        ;nrp = (use_searchRAD gt 0) ? icnt : (icnt < nrPNTS)
        nrp = (icnt < nrPNTS)
        qidx = [ qidx, idx[0:nrp - 1] ]
      endif else begin
        qFLG = qFLG - 1
      endelse
    ; quadrant IV: x > x0 and y < y0
      idx = where( (dxDAT gt 0) and (dyDAT lt 0), icnt)
      if (icnt ne 0) then begin
        ;nrp = (use_searchRAD gt 0) ? icnt : (icnt < nrPNTS)
        nrp = (icnt < nrPNTS)
        qidx = [ qidx, idx[0:nrp - 1] ]
      endif else begin
        qFLG = qFLG - 1
      endelse
    ; data on x-axis or y-axis: x = x0 or y = y0, or both
      idx = where( (dxDAT eq 0) or (dyDAT eq 0), icnt)
      if (icnt ne 0) then begin
        ;nrp = (use_searchRAD gt 0) ? icnt : (icnt < nrPNTS)
        nrp = (icnt < nrPNTS)
        qidx = [ qidx, idx[0:nrp - 1] ]
      endif else begin
        qFLG = qFLG - 1
      endelse

    if (n_elements(qidx) gt 1) then begin
      qidx = qidx[1:*]
      idx_sort = sort_nd(thisDIST[qidx], 1)
      thisXDAT = thisXDAT[qidx[idx_sort]]
      thisYDAT = thisYDAT[qidx[idx_sort]]
      thisZDAT = thisZDAT[qidx[idx_sort]]
      thisDIST = thisDIST[qidx[idx_sort]]
    endif else begin
      undefine, qidx
      if (use_searchRAD gt 0) then begin
        message, pnt_str + $
                 'available data not found, please increase the search radius'
      endif else begin
        message, pnt_str + $
                 'available data not found, please increase the number of nearest points'
      endelse
    endelse
             
    ; (2) get a set of ghost points enclosing the convex hull
    ;     of the input data; this can eliminate the precense
    ;     of artifacts near the boundaries (e.g., thin triangles
    ;     during tringulation) and to ensure that we do not
    ;     extrapolate from the input data
    xmin = min([ thisXDAT, thisXOUT ], MAX = xmax)
    ymin = min([ thisYDAT, thisYOUT ], MAX = ymax)
    xc   = 0.5 * (xmin + xmax)
    yc   = 0.5 * (ymin + ymax)
    xx   = xmax - xmin
    yy   = ymax - ymin
    rad  = 0.5 * sqrt( xx * xx + yy * yy )
    ngPNTS = (4 > n_elements(thisZDAT) < 60)

    Get_Ghost_CirclePoints, xc, yc, 2.0 * rad, $
                            NPoints = ngPNTS,  $
                            ghost_xx, ghost_yy

    ghost_zz = InvDist_Interp( ghost_xx, ghost_yy, $
                               thisXDAT, thisYDAT, thisZDAT, $
                               METHOD = idw_mth, $
                               EXPNT  = idw_pow )

    ; (3) apply the natural neighbor interpolation
    xx = [thisXDAT, ghost_xx]
    yy = [thisYDAT, ghost_yy]
    zz = [thisZDAT, ghost_zz]

    nNATDAT = n_elements(zz)
    thisLEN = mean(thisDIST, /NAN)
    prtb = 1.0e-3 * thisLEN
    tol  = 1.0e-6 * thisLEN

    ; apply small perturbations on the data locations to
    ; eliminate, if possible, co-linear points
    ;xseed = 1001L + fix((0.5 - randomu(seed, 1)) * 1001L, TYPE = size(xx, /TYPE))
    ;yseed = 1001L + fix((0.5 - randomu(seed, 1)) * 1001L, TYPE = size(yy, /TYPE))
    ;xx = xx + (0.5 - (randomu(xseed, nNATDAT) > 0.001)) * prtb
    ;yy = yy + (0.5 - (randomu(yseed, nNATDAT) > 0.001)) * prtb

    grid_input, xx, yy, zz, xx1, yy1, zz1
    xx = temporary(xx1)
    yy = temporary(yy1)
    zz = temporary(zz1)

    ; ----- triangulate the field and catch any errors in the
    ;       triangulation process
    triERR = 0
    catch, triERR
    if (triERR ne 0) then begin
      catch, /cancel
      print
      print, '   The following error was caught during triangulation:'
      help, /LAST_MESSAGE
      print, '   Execution continues using the inverse distance interpolation ...'
      print
    endif else begin
      triangulate, xx, yy, tri, TOLERANCE = tol
    endelse
    catch, /cancel
    ; -----

    ; ----- perform the natural neighbors interpolation and catch
    ;       any errors; fallback to inverse distance if there are
    ;       any errors
    grdERR = 0
    catch, grdERR
    if (triERR eq 0) then begin
      if (grdERR ne 0) then begin
        catch, /cancel
        print
        print, '   The following error was caught during NAT interpolation:'
        help, /LAST_MESSAGE
        print, '   Execution continues using the inverse distance interpolation ...'
        print
      endif else begin
        thisZOUT = ( griddata(xx, yy, zz, /NATURAL_NEIGHBOR, $
                              TRIANGLES = tri,               $
                              MISSING = missDAT,             $
                              XOUT = thisXOUT[*], YOUT = thisYOUT[*]) )[0]
        thisZOUT = ZeroFloatFix(thisZOUT)
      endelse
    endif
    catch, /cancel
    ; -----

    ; ----- fallback interpolation is the inverse distance method;
    ;       apply this method when: (a) triangulation failed,
    ;       (b) griddata failed, or (c) the interpolated value
    ;       is intVAL < min(data) or intVAL > max(data)
    fallINT = ( (triERR ne 0) or (grdERR ne 0) or $
                (thisZOUT lt min(zz)) or (thisZOUT gt max(zz)) )
    if (fallINT ne 0) then begin
      if (do_debug gt 0) then begin
        print, '   ' + pnt_str + $
               'WARNING: NAT interpolation failed, performing the ' + $
               idw_mth + ' IDW interpolation ...'
        if (triERR ne 0) then begin
          print, '   because of error in triangulate'
        endif else begin
          if (grdERR ne 0) then begin
            print, '   because of error in griddata'
          endif else begin
            if (thisZOUT lt min(zz)) then print, '   because the interpolated value is less than the min data value'
            if (thisZOUT gt max(zz)) then print, '   because the interpolated value is greater than the max data value'
          endelse
        endelse
      endif
      thisZOUT = ( InvDist_Interp(thisXOUT[*], thisYOUT[*], $
                                  xx, yy, zz,               $
                                  METHOD = idw_mth,         $
                                  EXPNT  = idw_pow ) )[0]
    endif
    ; -----

    thisZLOC[i] = thisZOUT
  endfor

  zloc[*] = thisZLOC

  return, zloc

end
