;+++
; NAME:
;	UVP_MASK
;
; VERSION:
;	1.0
;
; PURPOSE:
;	To calculate the values of a variable at the rho locations
;       given the variable values at the u, v or psi locations.
;
; AUTHOR:
;
;      Panagiotis Velissariou, Ph.D, P.E.
;      E-mail: pvelissariou@coaps.fsu.edu
;
; CALLING SEQUENCE:
;	  outMask = UVP_Mask(mask, keywords)
;	     mask - The 2D array of the mask values at rho points
;                   0 = land, 1 = water
;
; KEYWORDS:
;            ULOC - Set this keyword if the mask is calculated at U-points of
;                   a C-type staggered grid (mandatory)
;            VLOC - Set this keyword if the mask is calculated at V-points of
;                   a C-type staggered grid (mandatory)
;            PLOC - Set this keyword if the mask is calculated at PSI-points of
;                   a C-type staggered grid (mandatory)
;          Default: NONE
;             NOTE: Just one of ULOC, VLOC, PLOC should be supplied at any time
;
; RETURNS:
;         outMask - The 2D array of the mask variable calculated at the grid
;                   point location of a C-type staggered grid. The dimensions of
;                   "outMask" depend upon the grid point location.
;
; MODIFICATION HISTORY:
;       Created: Fri May 09 2014 by Panagiotis Velissariou (pvelissariou@fsu.edu)
;      Modified:
;+++
FUNCTION UVP_Mask, mask,        $
                   ULOC = uloc, $
                   VLOC = vloc, $
                   PLOC = ploc

  Compile_Opt IDL2

  ; Error handling.
  on_error, 2

  nparam = n_params()
  if (nparam lt 1) then message, 'incorrect number of arguments, need to supply <mask>'

  uloc = keyword_set(uloc)
  vloc = keyword_set(vloc)
  ploc = keyword_set(ploc)
  if ((uloc + vloc + ploc) ne 1) then begin
    message, 'one of [ULOC, VLOC, PLOC] should be set to continue with the calculations'
  endif

  if (size(mask, /N_DIMENSIONS) ne 2) then begin
    message, 'only 2D arrays are supported'
  endif

  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = where(badtypes eq size(mask, /TYPE), count)
    if (count ne 0) then $
      message, "only numbers are valid values for <mask>."

  ; ----------------------------------------

  dims = size(mask, /DIMENSIONS)
  idim = dims[0]
  jdim = dims[1]
  case 1 of
    (uloc eq 1): $
      begin
        outMask = mask[1:idim - 1, *] * mask[0:idim - 2, *]
      end
    (vloc eq 1): $
      begin
        outMask = mask[*, 1:jdim - 1] * mask[*, 0:jdim - 2]
      end
    (ploc eq 1): $
      begin
        outMask = mask[1:idim - 1, 1:jdim - 1] * mask[0:idim - 2, 0:jdim - 2]
      end
    else: $
      begin
        message, 'one of [ULOC, VLOC, PLOC] should be set to continue with the calculations'
      end
  endcase

  return, outMask

end
