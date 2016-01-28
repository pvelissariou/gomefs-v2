;+++
; NAME:
;	VL_INTERPOLDATA3D
; VERSION:
;	1.0
; PURPOSE:
;	To regrid the data from one regular grid to another.
; CALLING SEQUENCE:
;	data_out = VL_InterpolData3D(data, inlevs, outlevs, depth [options])
;
;	On input:
;
;	Optional parameters:
;
;	Keywords:
;
;	On output:
;	   data_out - The regridded array values; the size and type is the same as data
;
; SIDE EFFECTS:
;
; MODIFICATION HISTORY:
;	Created: Sat Dec 07 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++
FUNCTION VL_InterpolData3D, data, inlevs, outlevs, depth, OUT_BOUND = out_bound

  Compile_Opt idl2

  On_Error, 2

  if (size(data, /N_DIMENSIONS) ne 1) then begin
    message, 'error in InterpolData3D: "data" should be 1D vector'
  endif

  if (n_elements(data) ne n_elements(inlevs)) then begin
    message, 'error in InterpolData3D: "data" and "inlevs" should be of the same size'
  endif

  idx = where(inlevs lt 0, icnt)
  if (icnt ne 0) then begin
    message, 'error in InterpolData3D: "inlevs" should be positive down'
  endif

  idx = where(outlevs lt 0, icnt)
  if (icnt ne 0) then begin
    message, 'error in InterpolData3D: "outlevs" should be positive down'
  endif
  
  if (max(outlevs) gt depth) then begin
    message, 'error in InterpolData3D: "outlevs" extend beyond "depth"'
  endif

  myData   = data
  n_myData = n_elements(myData)
  myInLevs = inlevs
  off_dep  = 0.01 ; in meters

  ; check if depth is greater than max level in inlevs and
  ; re-assign the data values for levels greater than depth
  if (max(myInLevs) le depth) then begin
    myValOut = (n_elements(out_bound) eq 0) ? myData[n_myData - 1] : out_bound[0]
    myData   = [ myData, myValOut]
    myInLevs = [myInLevs, depth + off_dep]
  endif else begin
    ; check if depth is less than a level in inlevs and
    ; re-assign the data values for levels greater than depth
    idx = (where(myInLevs gt depth, icnt))[0]
    if (icnt gt 0) then begin
      idx0 = idx[0] - 1
      myValOut = (n_elements(out_bound) eq 0) ? myData[idx0] : out_bound[0]
      myData   = [ myData[0:idx0], myValOut]
      myInLevs = [ myInLevs[0:idx0], depth + off_dep]
    endif
  endelse

  ; check for NaN values and fill these values
  idx = where(finite(myData, /NAN) eq 1, icnt)
  if (icnt ne 0) then begin
    xin  = myInLevs
    xout = myInLevs[idx]
    myData[idx] = interpol(myData, xin, xout)
  endif

  tmp = interpol(myData, myInLevs, outlevs)

  return, tmp

end

