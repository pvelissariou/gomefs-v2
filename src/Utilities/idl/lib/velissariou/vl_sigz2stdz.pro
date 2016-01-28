;+++
; NAME:
;	VL_SIGZ2STDZ
; VERSION:
;	1.0
; PURPOSE:
;	To interpolate from standard z-levels to sigma z-levels.
; CALLING SEQUENCE:
;	data_out = VL_SigZ2StdZ(data, stdlevs, siglevs, depth [, keywords])
;	     data - The data array (1D - at positive down levels)
;	  stdlevs - The positive down z-levels input levels (0 at free surface)
;	  siglevs - The sigma z-levels (negative down)
;	    depth - The depth at this location
;
;	NOTE: The interpolation method is linear.
;
; KEYWORDS:
;
;        REVERSE - Set this keyword to reverse the output data vector
;
; RETURNS:
;	 data_out - The interpolated values at the standard z-levels
;
; SIDE EFFECTS:
;
; MODIFICATION HISTORY:
;	Created : Fri May 09 2014 by Panagiotis Velissariou (pvelissariou@fsu.edu)
;	Modified:
;+++
FUNCTION VL_SigZ2StdZ, Data, StdLevs, SigLevs, Depth, REVERSE = reverse, MASK_VAL = mask_val

  Compile_Opt IDL2

  on_error, 2

  ; check for required parameters
  nParam = n_params()
  if (nParam ne 4) then message, 'Incorrect number of arguments.'

  if (n_elements(mask_val) ne 0) then begin
    miss_val = mask_val[0]
  endif else begin
    miss_val = !VALUES.F_NAN
  endelse

  thisData    = double(data)
  thisStdLevs = double(stdlevs)
  thisSigLevs = double(siglevs)

  ; ----------
  ; check for valid input
  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = where(badtypes eq size(thisData, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <data>.'
  void = where(badtypes eq size(thisStdLevs, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <stdlevs>.'
  void = where(badtypes eq size(thisSigLevs, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <siglevs>.'
  void = where(badtypes eq size(depth, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <depth>.'
  if (depth le 0) then $
    message, '<depth> should be positive down.'
  ; ----------


  ; ----------
  ; check the size of input data
  if ( (size(thisData, /N_DIMENSIONS) ne 1)   or $
       (size(thisStdLevs, /N_DIMENSIONS) ne 1) or $
       (size(thisSigLevs, /N_DIMENSIONS) ne 1) ) then begin
    message, '<data, stdlevs, siglevs> should all be 1D vectors.'
  endif
  if (n_elements(thisData) ne n_elements(thisSigLevs)) then begin
    message, '<data, siglevs> should be of the same size.'
  endif
  ; ----------


  ; ----- Check the siglevs, the sigma z-levels
  nSIGLEV = n_elements(thisSigLevs)
  ; (A) check if "siglevs" are all positive and force them to be negative
  ;     according to the sigma convention (this does not change the results)
  void = where(thisSigLevs ge 0, cntPOS)
  if (cntPOS eq n_elements(thisSigLevs)) then begin
    thisSigLevs = ZeroFloatFix( - thisSigLevs )
  endif

  ; (B) make sure that "siglevs" are sorted from "deep" to "shallow" order
  ;     thisSigLevs[0] < thisSigLevs[1] < ...
  if (nSIGLEV ge 2) then begin
    diflevs = thisSigLevs[1:*] - thisSigLevs[0:nSIGLEV-2]
    if array_equal(fix(diflevs / abs(diflevs)), -1) then begin
    message, '<siglevs> are sorted from "shallow" to "deep", please reverse them'
    endif
  endif

  ; (C) make sure that the maximum siglev is less or equal to depth
  if (abs(thisSigLevs[0]) gt depth) then $
    message, '<siglevs> should all be less or equal to <depth>.'
  ; -----


  ; ----- Check the stdlevs, the standard z-levels
  nSTDLEV = n_elements(thisStdLevs)
  ; (A) check if "stdlevs" are all positive and force them to be negative
  ;     according to the sigma convention (this does not change the results)
  void = where(thisStdLevs ge 0, cntPOS)
  if (cntPOS eq n_elements(thisStdLevs)) then begin
    thisStdLevs = ZeroFloatFix( - thisStdLevs )
  endif

  ; (B) make sure that "stdlevs" are sorted from "deep" to "shallow" order
  ;     thisStdLevs[0] < thisStdLevs[1] < ...
  if (nSTDLEV ge 2) then begin
    diflevs = thisStdLevs[1:*] - thisStdLevs[0:nSTDLEV-2]
    if array_equal(fix(diflevs / abs(diflevs)), -1) then begin
    message, '<stdlevs> are sorted from "shallow" to "deep", please reverse them'
    endif
  endif
  ; -----


  ; ----- check for sufficient input data
  nPNTS = 3
  npnts_str = string(nPNTS, format = '(" ", i1, " ")')
  if (nSIGLEV lt nPNTS) then begin
    message, '<siglevs> should have at least' + npnts_str + 'unique elements.'
  endif else begin
    void = where(finite(thisData) eq 1, count)
    if (count lt nPNTS) then begin
      message, '<data> should have at least' + npnts_str + 'finite values.'
    endif
  endelse
  ; -----


  ; ----------
  ; Perform the linear interpolation
  xin  = thisSigLevs
  vin  = thisData
  xout = thisStdLevs
  thisData = interpol(vin, xin, xout)
  ; ----------


  ; ----------
  ; set all values of the output "data" array at "stdlevs" less
  ; greater or equal to "depth" to miss_val
  idx = where(abs(thisStdLevs) gt depth, count)
  if (count ne 0) then begin
    thisData[idx] = miss_val
  endif
  ; ----------

  if (keyword_set(reverse) eq 1) then thisData = reverse(thisData)

  return, thisData

end

