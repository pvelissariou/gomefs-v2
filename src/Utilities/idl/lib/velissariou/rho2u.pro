;+++
; NAME:
;	RHO2U
;
; VERSION:
;	1.0
;
; PURPOSE:
;	Interpolate from field at rho points to a field at u points.
;
; AUTHOR:
;
;      Panagiotis Velissariou, Ph.D, P.E.
;      E-mail: pvelissariou@coaps.fsu.edu
;
; CALLING SEQUENCE:
;	  outData = Rho2U(data [, mask] [, keywords])
;	     data - The 2D/3D array of the variable values at rho points
;	     mask - The 2D array of the mask values at rho points
;                   0 = land, 1 = water
;
; KEYWORDS:
;        mask_val - The mask value to use for the land points when
;                   constructing the data array at the rho points
;                   This value is in effect if and only if the mask
;                   array is also set
;
; RETURNS:
;         outData - The 2D/3D array of the variable calculated at U
;                   locations of a C-type staggered grid.
;
; MODIFICATION HISTORY:
;       Created: Mon Dec 30 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu)
;      Modified: Fri May 09 2014 by Panagiotis Velissariou (pvelissariou@fsu.edu)
;+++
FUNCTION Rho2U, data, mask, MASK_VAL = mask_val

  Compile_Opt IDL2

  ; Error handling.
  on_error, 2

  ; ----- Check the "data" array and get the dimensions
  nparam = n_params()
  if (nparam lt 1) then message, 'incorrect number of arguments, need to supply <data>'

  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = where(badtypes eq size(data, /TYPE), count)
    if (count ne 0) then $
      message, "only numbers are valid values for <data>."

  dims  = size(data, /DIMENSIONS)
  nDIMS = n_elements(dims)
  if (nDIMS lt 2) then begin
    message, 'only 2D/3D arrays are supported for <data>'
  endif

  idim_rho = dims[0]
  jdim_rho = dims[1]
  idim = idim_rho - 1
  jdim = jdim_rho
  kdim = (nDIMS gt 2) ? dims[2] : -1

  ; ----- Check the "mask" array for consistency
  do_mask = 0
  do_fill = 0
  if (n_elements(mask) ne 0) then begin
    mask_dims = size(mask, /DIMENSIONS)
    if (n_elements(mask_dims) ne 2) then begin
      message, 'only 2D arrays are supported for <mask>'
    endif
    if ((mask_dims[0] ne idim_rho) and (mask_dims[1] ne jdim_rho)) then begin
      message, 'wrong dimensions for <mask>'
    endif
    do_mask = 1
    mask_dat = UVP_Mask(mask, /ULOC)
    DRYIDX = where(mask_dat le 0, DRYCNT, COMPLEMENT = WETIDX, NCOMPLEMENT = WETCNT)
    if( n_elements(mask_val) ne 0 ) then begin
      do_fill = 1
      fill_val = mask_val[0]
    endif
  endif


  ; ----------------------------------------


  case nDIMS of
    2: $
      begin
        outData = make_array(idim, jdim, $
                             TYPE = size(data, /TYPE), VALUE = 0)

        inpData = data
        if (do_mask gt 0) then inpData = ZeroFloatFix( inpData * mask )
        inpData = Rho2UVP_Points(inpData, /ULOC)
        if( do_fill gt 0 ) then inpData[DRYIDX] = fill_val
        outData[*, *] = inpData
      end
    3: $
      begin
        outData = make_array(idim, jdim, kdim, $
                             TYPE = size(data, /TYPE), VALUE = 0)

        for k = 0L , kdim - 1 do begin
          inpData = reform(data[*, *, k])
          if (do_mask gt 0) then inpData = ZeroFloatFix( inpData * mask )
          inpData = Rho2UVP_Points(inpData, /ULOC)
          if( do_fill gt 0 ) then inpData[DRYIDX] = fill_val
          outData[*, *, k] = inpData
        endfor
      end
    else: $
      begin
        message, "<data> only 2D or 3D data arrays are allowed."
      end
  endcase

  return, outData
end
