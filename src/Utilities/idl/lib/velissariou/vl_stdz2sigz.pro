;+++
; NAME:
;	VL_STDZ2SIGZ
; VERSION:
;	1.0
; PURPOSE:
;	To interpolate from standard z-levels to sigma z-levels.
; CALLING SEQUENCE:
;	data_out = VL_StdZ2SigZ(data, stdlevs, outlevs, depth [options])
;	     data - The data array (1D - at positive down levels)
;	  stdlevs - The positive down z-levels input levels (0 at free surface)
;	  outlevs - The sigma z-levels (negative down)
;	    depth - The depth at this location
;
;	NOTE: Default interpolation method is linear. Use any of the keywords
;             below to change this behavior.
;             If there are any missing values (NaN) in the input data, these
;             values are filled using linear interpolation.
;
; KEYWORDS:
;       DEP_BOUND - Set this keyword to a value (greater than depth) where
;                   the interpolated values are bounded (primarily used
;                   for the flow velocities)
;                   Default: depth + 0.01 m
;       VAL_BOUND - Set this keyword to a bounding value for the data
;                   Default: NaN
;     LSQUADRATIC - Set this keyword to interpolate using a least squares
;                   quadratic fit to the equation y = a + b*x + c*x^2, for
;                   each 4 point neighborhood (x[i-1], x[i], x[i+1], x[i+2])
;                   surrounding the interval of the interpolate, x[i] < u < x[i+1]
;                   Default: Not set
;       QUADRATIC - Set this keyword to interpolate by fitting a quadratic
;                   y = a + b*x + c*x^2, to the 3 point neighborhood
;                   (x[i-1], x[i], x[i+1]) surrounding the interval
;                   x[i] < u < x[i+1]
;                   Default: Not set
;          SPLINE - Set this keyword to interpolate by fitting a cubic spline
;                   to the 4 point neighborhood (x[i-1], x[i], x[i+1], x[i+2])
;                   surrounding the interval x[i] < u < x[i+1]
;                   Default: Not set
;
; RETURNS:
;	 data_out - The interpolated values at the sigma z-levels
;
; SIDE EFFECTS:
;
; MODIFICATION HISTORY:
;	Created : Sat Dec 07 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;	Modified: Thu Dec 26 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++
FUNCTION VL_StdZ2SigZ, Data, StdLevs, OutLevs, Depth, $
                       VAL_BOUND   = val_bound,       $
                       DEP_BOUND   = dep_bound,       $
                       LSQUADRATIC = lsquadratic,     $
                       QUADRATIC   = quadratic,       $
                       SPLINE      = spline

  Compile_Opt IDL2

  on_error, 2

  ; check for required parameters
  nParam = n_params()
  if (nParam ne 4) then message, 'Incorrect number of arguments.'

  miss_val = !VALUES.F_NAN

  meth_lsquad = (keyword_set(lsquadratic) eq 1) ? 1 : 0
  meth_quad   = (keyword_set(quadratic) eq 1)   ? 1 : 0
  meth_spline = (keyword_set(spline) eq 1)      ? 1 : 0
  meth_interp = meth_lsquad + meth_quad + meth_spline

  if (meth_interp gt 1) then $
    message, 'Only one of <LSQUADRATIC, QUADRATIC, SPLINE> should be supplied.'

  thisData    = double(reform(data))
  thisStdLevs = double(reform(stdlevs))
  thisOutLevs = double(reform(outlevs))

  ; ----------
  ; check for valid input
  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = where(badtypes eq size(thisData, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <data>.'
  void = where(badtypes eq size(thisStdLevs, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <stdlevs>.'
  void = where(badtypes eq size(thisOutLevs, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <outlevs>.'
  void = where(badtypes eq size(depth, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <depth>.'
  if (depth le 0) then $
    message, '<depth> should be positive down.'

  if (n_elements(val_bound) ne 0) then begin
    void = where(badtypes eq size(val_bound, /TYPE), count)
      if (count ne 0) then $
        message, 'Only numbers are valid values for <val_bound>.'
  endif

  if (n_elements(dep_bound) ne 0) then begin
    void = where(badtypes eq size(dep_bound, /TYPE), count)
      if (count ne 0) then $
        message, 'Only numbers are valid values for <dep_bound>.'
    if (dep_bound le depth) then $
      message, '<dep_bound> should be greater than <depth>.'
  endif

  off_dep   = 0.01 ; in meters
  thisDepBound = (n_elements(dep_bound) eq 0) ? (depth + off_dep) : dep_bound
  thisValBound = (n_elements(val_bound) eq 0) ? miss_val : val_bound
  ; ----------


  ; ----------
  ; check the size of input data
  if ( (size(thisData, /N_DIMENSIONS) ne 1)   or $
       (size(thisStdLevs, /N_DIMENSIONS) ne 1) or $
       (size(thisOutLevs, /N_DIMENSIONS) ne 1) ) then begin
    message, '<data, stdlevs, outlevs> should all be 1D vectors.'
  endif
  if (n_elements(thisData) ne n_elements(thisStdLevs)) then begin
    message, '<data, stdlevs> should be of the same size.'
  endif
  ; ----------


  ; ----------
  ; check the outlevs, the sigma z-levels
  ; check if "outlevs" are all positive and force them to be negative
  ; according to the sigma convention (this does not change the results)
  ; This step is not exactly necessary ...
  void = where(thisOutLevs ge 0, cntPOS)
  if (cntPOS eq n_elements(thisOutLevs)) then begin
    thisOutLevs = ZeroFloatFix( - thisOutLevs )
  endif

  nSIGLEV = n_elements(thisOutLevs)

  ; "outlevs" do not need to be in monotonic order
  ; (interpol requires that only the input data are to be in monotonic order)

  ; make sure that "outlevs" are sorted from "deep" to "shallow" order
  ; thisOutLevs[0] < thisOutLevs[1] < ...
  RevOutLevs = 0
  if (nSIGLEV ge 2) then begin
    diflevs = thisOutLevs[1:*] - thisOutLevs[0:nSIGLEV-2]
    if array_equal(fix(diflevs / abs(diflevs)), -1) then begin
      ; "outlevs" are sorted from "shallow" to "deep", so reverse them
      thisOutLevs = reverse(thisOutLevs)
      RevOutLevs = 1
    endif
  endif

  if (abs(thisOutLevs[0]) gt depth) then $
    message, '<outlevs> should all be less or equal to <depth>.'

  top_outlev = max(thisOutLevs)
  bot_outlev = - abs(thisDepBound)
  ; ----------


  ; ----------
  ; check data/stdlevs
  ; check if "stdlevs" are all positive and force them to be negative
  ; according to the sigma convention (this does not change the results)
  void = where(thisStdLevs ge 0, cntPOS)
  if (cntPOS eq n_elements(thisStdLevs)) then begin
    thisStdLevs = ZeroFloatFix( - thisStdLevs )
  endif

  top_stdlev = max(thisStdLevs, MIN = bot_stdlev)

  ; make sure before interpolating that "outlevs" are bounded
  ; at top/bottom by "stdlevs"; if not insert extra top and
  ; bottom standard layers
  ; insert a top layer if needed
  if (top_outlev gt top_stdlev) then begin
    thisStdLevs = [ top_outlev, thisStdLevs ]
    thisData    = [ miss_val, thisData]
  endif

  ; insert a bottom layer
  ; we insert this any way so that we can bound the bottom
  ; velocities if needed
  thisStdLevs = [ thisStdLevs, bot_outlev ]
  thisData    = [ thisData, thisValBound ]

  ; make sure that "stdlevs" are sorted in monotonic order (here in ascending order)
  ; (interpol requires that input data should be in monotonic order)
  idxSORT     = uniq(thisStdLevs, sort(thisStdLevs))
  thisData    = thisData[idxSORT]
  thisStdLevs = thisStdLevs[idxSORT]
  nSTDLEV     = n_elements(thisStdLevs)

  ; make sure that "stdlevs" are ordered from "deep" to "shallow"
  ; thisStdLevs[0] < thisStdLevs[1] < ...
  diflevs = thisStdLevs[1:*] - thisStdLevs[0:nSTDLEV-2]
  if array_equal(fix(diflevs / abs(diflevs)), -1) then begin
    ; "stdlevs" are sorted from "shallow" to "deep", so reverse them
    thisStdLevs = reverse(thisStdLevs)
    thisData    = reverse(thisData)
  endif

  ; check for sufficient input data
  nPNTS = 3
  if (meth_interp eq 1) then begin
    if (meth_quad eq 1) then nPNTS = 3
    if ( (meth_lsquad eq 1) or $
         (meth_spline eq 1) ) then nPNTS = 4
  endif

  npnts_str = string(nPNTS, format = '(" ", i1, " ")')
  if (nSTDLEV lt nPNTS) then begin
    message, '<stdlevs> should have at least' + npnts_str + 'unique elements.'
  endif else begin
    void = where(finite(thisData) eq 1, count)
    if (count lt nPNTS) then begin
      message, '<data> should have at least' + npnts_str + 'finite values.'
    endif
  endelse
  ; ----------


  ; ----------
  ; check for NaN values and fill these values using linear interpolation
  idxNAN = where(finite(thisData) eq 0, cntNAN, $
                 COMPLEMENT = idxFIN, NCOMPLEMENT = cntFIN)
  if (cntNAN ne 0) then begin
    xin  = thisStdLevs[idxFIN]
    vin  = thisData[idxFIN]
    xout = thisStdLevs[idxNAN]
    ; here we use linear interpolation to fill any missing data
    thisData[idxNAN] = interpol(vin, xin, xout)
  endif
  ; ----------


  ; ----------
  ; set all values of the "data" array at "stdlevs" less
  ; than bot_outlev to val_bound; this is primarily
  ; used to bound the bottom flow velocities
  idx = where(thisStdLevs lt bot_outlev, count)
  if (count ne 0) then begin
    chkmsk = ChkForMask(thisStdLevs, bot_outlev, botIDX, botCNT)
    thisData[idx] = thisData[botIDX]
  endif
  ; ----------


  ; finally interpolate at the sigma z-levels
  if (meth_interp eq 1) then begin
    ;if (meth_lsquad eq 1) then print, 'Using: least squares quadratic fit'
    ;if (meth_quad eq 1)   then print, 'Using: quadratic fit'
    ;if (meth_spline eq 1) then print, 'Using: cubic splines'
    tmp = interpol(thisData, thisStdLevs, thisOutLevs, $
                   LSQUADRATIC = meth_lsquad,          $
                   QUADRATIC   = meth_quad,            $
                   SPLINE      = meth_spline)

    max_dat = max(thisData, MIN = min_dat)
    void = where( (tmp gt max_dat) or (tmp lt min_dat), count)
    if (count ne 0) then begin
      ; fall back to linear interpolation if tmp contains
      ; values out of data range
      ;print, 'Fallback: linear interpolation'
      tmp = interpol(thisData, thisStdLevs, thisOutLevs)
    endif
  endif else begin
    ; perform the linear interpolation if meth_interp = 0
    ;print, 'Using: linear interpolation'
    tmp = interpol(thisData, thisStdLevs, thisOutLevs)
  endelse

  if (RevOutLevs gt 0) then tmp = reverse(tmp)

  return, tmp

end

