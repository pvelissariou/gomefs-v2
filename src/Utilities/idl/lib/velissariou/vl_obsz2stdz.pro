PRO AcceptDist, zval, insD, outD

  Compile_Opt HIDDEN, IDL2

  on_error, 2

  ; ----- Check for valid input
  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = where(badtypes eq size(zval, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <zval>.'

  zval = zval[0]
  case 1 of
    (zval lt 0):     message, 'Only positive numbers are valid values for <zval>.'
    (zval gt 10000): message, 'zval should be less than 10000 m.'
    else:
  endcase

  DEPS = [                                            $
               0,   10,   20,   30,   50,   75,  100, $
             125,  150,  200,  250,  300,  400,  500, $
             600,  700,  800,  900, 1000, 1100, 1200, $
            1300, 1400, 1500, 1750, 2000, 2500, 3000, $
            3500, 4000, 4500, 5000, 5500, 6000, 7000, $
            8000, 9000,                               $
           10000                                      $
         ]

  insDIST = [                                           $
                 5,   50,   50,   50,   50,   50,   50, $
                50,   50,   50,  100,  100,  100,  100, $
               100,  100,  100,  200,  200,  200,  200, $
               200,  200,  200,  200, 1000, 1000, 1000, $
              1000, 1000, 1000, 1000, 1000, 1000, 1000, $
              1000, 1000,                               $
              1000                                      $
            ]

  outDIST = [                                           $
               200,  200,  200,  200,  200,  200,  200, $
               200,  200,  200,  200,  200,  200,  400, $
               400,  400,  400,  400,  400,  400,  400, $
              1000, 1000, 1000, 1000, 1000, 1000, 1000, $
              1000, 1000, 1000, 1000, 1000, 1000, 1000, $
              1000, 1000,                               $
              1000                                      $
            ]

;  void = min(abs(DEPS - zval), imin)
;  insD = insDIST[imin]
;  outD = outDIST[imin]

  insD = interpol(insDIST, DEPS, zval)
  outD = interpol(outDIST, DEPS, zval)
end

;+++
; NAME:
;	VL_OBSZ2STDZ
; VERSION:
;	1.0
; PURPOSE:
;	To interpolate from observation z-levels to standard z-levels.
; CALLING SEQUENCE:
;	  outData = VL_ObsZ2StdZ(data, obslevs, stdlevs [, depth] [, keywords])
;	     data - The data array (1D - at positive down levels)
;	  obslevs - The z-levels where data values are given (negative down or positive)
;	  stdlevs - The output z-levels (negative down or positive)
;	    depth - The depth at this location (optional)
;
;	NOTE: The interpolation method is linear or Reiniger-Ross interpolation.
;
; KEYWORDS:
;       REINIGER - Set this keyword to use the Reiniger-Ross interpolation
;        REVERSE - Set this keyword to reverse the output data vector
;       MISS_VAL - Set this variable to a value to be used as a mask
;                  for missing data
;
; RETURNS:
;	 outData - The interpolated values at the standard z-levels
;
; SIDE EFFECTS:
;
; MODIFICATION HISTORY:
;	Created : Fri May 09 2014 by Panagiotis Velissariou (pvelissariou@fsu.edu)
;	Modified: Mon May 19 2014 by Panagiotis Velissariou (pvelissariou@fsu.edu)
;+++
FUNCTION VL_ObsZ2StdZ, Data, ObsLevs, StdLevs, Depth, $
                       REINIGER = reiniger, $
                       REVERSE  = reverse,  $
                       MISS_VAL = miss_val

  Compile_Opt IDL2

  on_error, 2

  ; check for required parameters
  nParam = n_params()
  if (nParam lt 3) then message, 'Incorrect number of arguments.'

  if (n_elements(miss_val) ne 0) then fill = miss_val[0]
  miss = !VALUES.F_NAN
  fill = (n_elements(fill) ne 0) ? fill : miss

  ; ------------------------------------------------------------
  ; ----- Check for valid input
  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = where(badtypes eq size(data, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <data>.'
  void = where(badtypes eq size(obslevs, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <obslevs>.'
  void = where(badtypes eq size(stdlevs, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <stdlevs>.'
  if (n_elements(depth) ne 0) then begin
    void = where(badtypes eq size(depth, /TYPE), count)
      if (count ne 0) then $
        message, 'Only numbers are valid values for <depth>.'
    thisDepth = depth[0]
  endif

  ; ------------------------------------------------------------
  ; ----- Check the size of input data
  if ( (size(data, /N_DIMENSIONS) ne 1)   or $
       (size(stdlevs, /N_DIMENSIONS) ne 1) or $
       (size(obslevs, /N_DIMENSIONS) ne 1) ) then begin
    message, '<data, obslevs, stdlevs> should all be 1D vectors.'
  endif
  if (n_elements(data) ne n_elements(obslevs)) then begin
    message, '<data, obslevs> should be of the same size.'
  endif

  ; ------------------------------------------------------------
  ; ----- Check the obslevs, the observation z-levels
  thisObsLevs = double(obslevs)
  nOBSLEV = n_elements(thisObsLevs)
  if (nOBSLEV lt 3) then begin
    message, '<obslevs> should be at least three levels'
  endif
  ; (A) check if "obslevs" are all positive and force them to be negative
  ;     according to the sigma convention (this does not change the results)
  idxPOS = where(thisObsLevs ge 0, cntPOS)
  idxNEG = where(thisObsLevs le 0, cntNEG)
  if ( (cntPOS ne nOBSLEV) and (cntNEG ne nOBSLEV) ) then begin
    message, '<obslevs> should all be either positive or negative (including zero)'
  endif else begin
    thisObsLevs = ZeroFloatFix( - abs(thisObsLevs) )
  endelse
  ; (B) make sure that "obslevs" are sorted from "deep" to "shallow" order
  ;     thisObsLevs[0] < thisObsLevs[1] < ...
  obsIDX = sort(thisObsLevs)
  obsFLG = 0
  if (max(ZeroFloatFix( thisObsLevs - thisObsLevs[obsIDX]) ) ne 0) then begin
    thisObsLevs = thisObsLevs[obsIDX]
    obsFLG = 1
  endif

  ; ------------------------------------------------------------
  ; ----- The data. Re-arrange the data according to obsFLG
  thisData = double(data)
  if (obsFLG gt 0) then thisData = thisData[obsIDX]

  ; ------------------------------------------------------------
  ; ----- Check the stdlevs, the standard z-levels
  thisStdLevs = double(stdlevs)
  nSTDLEV = n_elements(thisStdLevs)
  ; (A) check if "stdlevs" are all positive and force them to be negative
  ;     according to the sigma convention (this does not change the results)
  idxPOS = where(thisStdLevs ge 0, cntPOS)
  idxNEG = where(thisStdLevs le 0, cntNEG)
  if ( (cntPOS ne nSTDLEV) and (cntNEG ne nSTDLEV) ) then begin
    message, '<stdlevs> should all be either positive or negative (including zero)'
  endif else begin
    thisStdLevs = ZeroFloatFix( - abs(thisStdLevs) )
  endelse
  ; (B) make sure that "stdlevs" are sorted from "deep" to "shallow" order
  ;     thisStdLevs[0] < thisStdLevs[1] < ...
  stdIDX = sort(thisStdLevs)
  stdFLG = 0
  if (max(ZeroFloatFix( thisStdLevs - thisStdLevs[stdIDX]) ) ne 0) then begin
    thisStdLevs = thisStdLevs[stdIDX]
    stdFLG = 1
  endif

  ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ; %%%%% START THE CALCULATIONS
  ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  outData = make_array(nSTDLEV, TYPE = size(data, /TYPE), VALUE = miss)

  ; ----- Perform the linear interpolation
  xin  = thisObsLevs
  vin  = thisData
  xout = thisStdLevs
  outData[*] = interpol(vin, xin, xout)

  ; ----- Perform the Reiniger-Ross interpolation if requested
  ;       R.F. Reiniger and C.K. Ross (1968). A method of interpolation
  ;         with application to oceanographic data. Deep Sea Research, 15,
  ;         p.185-193 
  ;       Rattray, Jr, Maurice (1962). Interpolation errors and oceanographic
  ;       sampling.  Deep Sea Research, 9, p.25-37
  ;
  ;       The interpolation scheme is that of Reiniger & Ross (1968),
  ;       which is a method of weighted parabolas, an extension of the
  ;       work of Rattray (1962), who used an arithmetic mean of two
  ;       parabolas. This method is considered to be especially suitable
  ;       for vertical oceanic profiles, and deals well with the problem
  ;       of the thermocline, by diminishing the "overshoot" effect of
  ;       an unacceptable parabola.
  ;
  ;if (keyword_set(reiniger) gt 0) then begin
  ;endif

  ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ; %%%%% POST PROCESS THE OUTPUT DATA
  ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ; ----- Set all values of the output "data" array at "stdlevs" less
  ;       greater or equal to "depth" to "miss"
  if (n_elements(thisDepth) ne 0) then begin
    idx = where(abs(thisStdLevs) gt abs(thisDepth), count)
    if (count ne 0) then outData[idx] = miss
  endif

  ; ----- Re-arrange the outData according to the input StdLevs
  if (stdFLG gt 0) then begin
    tmpData = outData & outData[*] = miss
    for i = 0L, nSTDLEV - 1 do begin
      if (ChkForMask(abs(thisStdLevs), abs(stdlevs[i]), idx, count) gt 0) then begin
        outData[i] = tmpData[idx[0]]
      endif
    endfor
  endif

  ; ----- Set all missing values of the output "data" array to
  ;       the "fill" value
  if (ChkForMask(outData, miss, idx, count) gt 0) then begin
    outData[idx] = fill
  endif

  ; ----- Reverse the output data if requested
  if (keyword_set(reverse) gt 0) then outData = reverse(outData)

  return, outData
end
