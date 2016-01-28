FUNCTION ReGrid2D, data, xdat, ydat, xout, yout

  Compile_Opt HIDDEN, IDL2

  on_error, 2

  xdimDAT = n_elements(xdat)
  ydimDAT = n_elements(ydat)
  xdimOUT = n_elements(xout)
  ydimOUT = n_elements(yout)

  x  = interpol(findgen(xdimDAT), xdat, xout)
  y  = interpol(findgen(ydimDAT), ydat, yout)
  xx = rebin(x, xdimOUT, ydimOUT, /SAMPLE)
  yy = rebin(reform(y, 1, ydimOUT), xdimOUT, ydimOUT, /SAMPLE)

  zout = interpolate(data, xx, yy, MISSING = !VALUES.F_NAN)

  return, zout
end

;+++
; NAME:
;	VL_REGRID
; VERSION:
;	1.0
; PURPOSE:
;	To regrid the data from one regular grid to another.
; CALLING SEQUENCE:
;	data_out = VL_ReGrid(data, xdat, ydat, xout, yout)
;
;	On input:
;	  data - The values of the data points at (xdat, ydat) (a 2D/3D array)
;	  xdat - The x-coordinates of the data points (a vector)
;	  ydat - The y-coordinates of the data points (a vector)
;	  xout - The x-coordinates of the output data points (a vector)
;	  yout - The y-coordinates of the output data points (a vector)
;
; OPTIONAL PARAMETERS:
;
; KEYWORDS:
;
;	On output:
;	   zdat - The regridded array values; the size and type is the same as data
;
; MODIFICATION HISTORY:
;	Created: Sat Dec 07 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++
FUNCTION VL_ReGrid, data, xdat, ydat, xout, yout

  Compile_Opt IDL2

  on_error, 2

  ; ----------
  ; check the data dimensions
  nDIMS = size(data, /N_DIMENSIONS)
  if ( (nDIMS ne 2) and (nDIMS ne 3) ) then begin
    message, $
      '<data> should be a 2D or a 3D array'
  endif

  dims = size(data, /DIMENSIONS)
  idim = dims[0]
  jdim = dims[1]

  ; ----------
  ; xdat, ydat should be 1D vectors and consistent with the data dimensions
  if ( (size(xdat, /N_DIMENSIONS) ne 1) or $
       (size(ydat, /N_DIMENSIONS) ne 1) ) then begin
    message, $
      '<xdat, ydat> should be 1D vectors'
  endif else begin
    if ( (n_elements(xdat) ne idim) or $
         (n_elements(ydat) ne jdim) ) then begin
      message, $
        '<data, xdat, ydat> have inconsistent dimensions'
    endif
  endelse

  ; ----------
  ; xout, yout should be 1D vectors
  if ( (size(xout, /N_DIMENSIONS) ne 1) or $
       (size(yout, /N_DIMENSIONS) ne 1) ) then begin
    message, $
      '<xout, yout> should be 1D vectors'
  endif

  case size(data, /N_DIMENSIONS) of
    2: $
      begin
        outData = make_array(n_elements(xout), n_elements(yout), $
                             TYPE = size(data, /TYPE), VALUE = 0)
        outData[*, *] = ReGrid2D(data, xdat, ydat, xout, yout)
      end
    3: $
      begin
        kdim = dims[2]
        outData = make_array(n_elements(xout), n_elements(yout), kdim, $
                             TYPE = size(data, /TYPE), VALUE = 0)

        for k = 0L , kdim - 1 do begin
          outData[*, *, k] = ReGrid2D(reform(data[*, *, k]), xdat, ydat, xout, yout)
        endfor
      end
    else: $
      begin
        message, "<data> only 2D or 3D data arrays are allowed."
      end
  endcase

  return, outData
end
