FUNCTION Fill2D, data, miss_val,    $
                 BOXCAR  = boxcar,  $
                 FLAP    = flap,    $
                 ITER    = iter,    $
                 TOL     = tol,     $
                 SMWIN   = smwin,   $
                 DEBUG   = debug

  Compile_Opt HIDDEN, IDL2

  on_error, 2

  boxcar  = (keyword_set(boxcar) eq 1) ? 1 : 0
  flap    = (keyword_set(flap) eq 1) ? 1 : 0
  meth    = boxcar + flap
  if (meth ne 1) then $
    message, 'One of <BOXCAR, FLAP> should be supplied.'

  iter = (n_elements(iter) eq 0) $
            ? 10000 $
            : round(abs(iter[0]))

  tol = (n_elements(tol) eq 0) $
            ? 1.0d-3 $
            : abs(tol[0])


  chk_msk = ChkForMask(data, miss_val, bad_idx, bad_cnt, $
                       COMPLEMENT = good_idx, NCOMPLEMENT = good_cnt)

  if(bad_cnt eq 0) then return, data

  if(good_cnt eq 0) then begin
    message, 'no useful data found in the field'
  endif

  ; --------------------
  missVAL = !VALUES.F_NAN
  outData = data
  outData[bad_idx] = missVAL

  if (boxcar eq 1) then begin
    smwin = (n_elements(smwin) eq 0) $
               ? 11 $
               : round(abs(smwin[0]))

    ;print, '   Performing a boxcar smoothing to fill the missing data'

    counter = 0L
    badDiff = missVAL
    while( (ChkForMask(badDiff, missVAL) ne 0) or (badDiff gt tol) ) do begin
      counter++
      badOld = outData[bad_idx]

      badNew = (smooth(outData, smwin, /EDGE_TRUNCATE, /NAN))[bad_idx]
      outData[bad_idx] = badNew

      badDiff = max(abs(badNew - badOld))

      if(counter gt iter) then begin
        iter_str = 'iter = ' + strtrim(string(counter, format = '(i10)'), 2)
        iter_str = iter_str + ' (max: ' + strtrim(string(iter, format = '(i10)'), 2) + ')'
        tol_str = 'max data diff = ' + strtrim(string(badDiff, format = '(f20.12)'), 2)
        tol_str = tol_str + ' (tol: ' + strtrim(string(tol, format = '(f20.12)'), 2) + ')'
        print, iter_str, tol_str, format = '(3x, a, 3x, a)'
        message, 'too many filling iterations, please check your data or increase the number of iterations'
        break
      endif
    endwhile
  endif

  if (flap eq 1) then begin
    ;print, '   Performing a five-point laplacian filter smoothing to fill the missing data'

    ; mean value of the good data
    outData[bad_idx] = mean(outData[good_idx])

    dims = size(outData, /DIMENSIONS)
    idim = dims[0]
    jdim = dims[1]
    i1 = 1
    i2 = idim - 2
    j1 = 1
    j2 = jdim - 2

    counter = 0L
    badDiff = missVAL
    while( (ChkForMask(badDiff, missVAL) ne 0) or (badDiff gt tol) ) do begin
      counter++
      badOld = outData[bad_idx]

      tmp = outData
      tmp[i1:i2, j1:j2] = $
         outData[i1:i2, j1:j2] + (0.5 / 4.0) * $
            ( outData[i1+1:i2+1, j1:j2] + $
              outData[i1:i2, j1-1:j2-1] + $
              outData[i1-1:i2-1, j1:j2] + $
              outData[i1:i2, j1+1:j2+1] - $
              4 * outData[i1:i2, j1:j2] )
      tmp[0, *] = tmp[1, *]
      tmp[idim - 1, *] = tmp[idim - 2, *]
      tmp[*, 0] = tmp[*, 1]
      tmp[*, jdim - 1] = tmp[*, jdim - 2]
 
      badNew = tmp[bad_idx]
      outData[bad_idx] = badNew

      badDiff = max(abs(badNew - badOld))

      if(counter gt iter) then begin
        iter_str = 'iter = ' + strtrim(string(counter, format = '(i10)'), 2)
        iter_str = iter_str + ' (max: ' + strtrim(string(iter, format = '(i10)'), 2) + ')'
        tol_str = 'max data diff = ' + strtrim(string(badDiff, format = '(f20.12)'), 2)
        tol_str = tol_str + ' (tol: ' + strtrim(string(tol, format = '(f20.12)'), 2) + ')'
        print, 'warning: too many iterations, increase the number of iterations if desired'
        print, iter_str, tol_str, format = '(3x, a, 3x, a)'
        break
      endif
    endwhile
  endif

  if(keyword_set(debug) eq 1) then begin
    iter_str = 'iter = ' + strtrim(string(counter, format = '(i10)'), 2)
    iter_str = iter_str + ' (max: ' + strtrim(string(iter, format = '(i10)'), 2) + ')'
    tol_str = 'max data diff = ' + strtrim(string(badDiff, format = '(f20.12)'), 2)
    tol_str = tol_str + ' (tol: ' + strtrim(string(tol, format = '(f20.12)'), 2) + ')'
    print, iter_str, tol_str, format = '(3x, a, 3x, a)'
  endif

  return, outData
end

;+++
; NAME:
;	VL_FILLDATA
; VERSION:
;	1.0
; PURPOSE:
;	To fill missing missing records for an almost equally spaced dataset.
;       It only fills the missing records and it does not modify the
;       actual data.
;       Missing values are identified by the "miss_val" value.
; CALLING SEQUENCE:
;	data_out = VL_FillData(data, miss_val [, Options])
;
;	On input:
;	    data - The values of the data points (1D, 2D or 3D array).
;	miss_val - The value that identifies the missing data.
;
; OPTIONAL PARAMETERS:
;	    ITER - The maximum number of iterations (calls) for the
;                  boxcar/5-point laplacian filter methods.
;                  Default: ITER = 1000
;	     TOL - The tolerance used in the iterations (calls) for the
;                  boxcar/5-point laplacian filter methods.
;                  Default: TOL = 1.0d-3
;          SMWIN - The smoothing window to be used in the boxcar averaging.
;                  Default: 11
;
; KEYWORDS:
;         BOXCAR - Set this keyword to use the boxcar averaging method
;                  to fill the missing data
;           FLAP - Set this keyword to use the 5-point laplacian filter
;                  smoothing method to fill the missing data
;
;	On output:
;	data-out - The filled data array
;
; MODIFICATION HISTORY:
;	Created Sat Oct 12 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++
FUNCTION VL_FillData, data, miss_val,    $
                      BOXCAR  = boxcar,  $
                      FLAP    = flap,    $
                      ITER    = iter,    $
                      TOL     = tol,     $
                      SMWIN   = smwin,   $
                      DEBUG   = debug

  Compile_Opt IDL2

  on_error, 2

  nParam = n_params()
  if (nParam ne 2) then message, 'Incorrect number of arguments.'

  boxcar  = (keyword_set(boxcar) eq 1) ? 1 : 0
  flap    = (keyword_set(flap) eq 1) ? 1 : 0
  meth    = boxcar + flap
  if (meth gt 1) then $
    message, 'Only one of <BOXCAR, FLAP> should be supplied.'

  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = where(badtypes eq size(data, /TYPE), count)
    if (count ne 0) then $
      message, "only numbers are valid values for <data>."
  void = where(badtypes eq size(miss_val, /TYPE), count)
    if (count ne 0) then $
      message, "only numbers are valid values for <miss_val>."

  ; default filling method
  if (meth eq 0) then boxcar = 1

  case size(data, /N_DIMENSIONS) of
    1: $
      begin
        if(keyword_set(debug) eq 1) then begin
          fill_str = 'method: '
          if (boxcar eq 1) then fill_str = 'method: boxcar averaging fill'
          if (flap eq 1)   then fill_str = 'method: 5-point laplacian filter smoothing fill'
          print, fill_str, format = '(3x, a)'
        endif

        outData = data
        chk_msk = ChkForMask(outData, miss_val, bad_idx, bad_cnt, $
                             COMPLEMENT = good_idx, NCOMPLEMENT = good_cnt)

        if(bad_cnt ne 0) then begin
          smwin = (n_elements(smwin) eq 0) $
                     ? 11 $
                     : round(abs(smwin[0]))
          iter  = (n_elements(iter) eq 0) $
                     ? 1000 $
                     : round(abs(iter[0]))

          ; mean value of the good data
          mean_good = mean(outData[good_idx])
          if(finite(mean_good) eq 0) then begin
            message, "no useful data found in the field."
          endif else begin
            ; inital guess: replace missing values with the mean of the data
            outData[bad_idx] = mean_good
          endelse

          for i = 0L, iter - 1 do begin
            outData[bad_idx] = (smooth(outData, smwin, /EDGE_TRUNCATE, /NAN))[bad_idx]
          endfor
        endif
      end
    2: $
      begin
        if(keyword_set(debug) eq 1) then begin
          fill_str = 'method: '
          if (boxcar eq 1) then fill_str = 'method: boxcar averaging fill'
          if (flap eq 1)   then fill_str = 'method: 5-point laplacian filter smoothing fill'
          print, fill_str, format = '(3x, a)'
        endif

        outData = Fill2D(data, miss_val,   $
                         BOXCAR  = boxcar, $
                         FLAP    = flap,   $
                         ITER    = iter,   $
                         TOL     = tol,    $
                         SMWIN   = smwin,  $
                         DEBUG   = debug)
      end
    3: $
      begin
        if(keyword_set(debug) eq 1) then begin
          fill_str = 'method: '
          if (boxcar eq 1) then fill_str = 'method: boxcar averaging fill'
          if (flap eq 1)   then fill_str = 'method: 5-point laplacian filter smoothing fill'
          print, fill_str, format = '(3x, a)'
        endif

        datDIMS = size(data, /DIMENSIONS)
        outData = make_array(datDIMS, TYPE = size(data, /TYPE), VALUE = 0)

        kmax = datDIMS[2]
        for k = 0L , kmax - 1 do begin
          outData[*, *, k] = Fill2D(reform(data[*, *, k]), miss_val, $
                                    BOXCAR  = boxcar, $
                                    FLAP    = flap,   $
                                    ITER    = iter,   $
                                    TOL     = tol,    $
                                    SMWIN   = smwin,  $
                                    DEBUG   = debug)
        endfor
      end
    else: $
      begin
        message, "<data> only 1D, 2D or 3D data arrays are allowed."
      end
  endcase

  return, outData
end
