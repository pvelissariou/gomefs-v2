;+++
; NAME:
;	UVP2RHO_POINTS
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
;	  outData = UVP2Rho_Points(data, keywords)
;	     data - The 2D array of the variable values at u, v or psi points
;
; KEYWORDS:
;            ULOC - Set this keyword if the data are given at U-points of
;                   a C-type staggered grid (mandatory)
;            VLOC - Set this keyword if the data are given at V-points of
;                   a C-type staggered grid (mandatory)
;            PLOC - Set this keyword if the data are given at PSI-points of
;                   a C-type staggered grid (mandatory)
;          Default: NONE
;             NOTE: Just one of ULOC, VLOC, PLOC should be supplied at any time
;
; RETURNS:
;         outData - The 2D array of the variable calculated at RHO
;                   locations of a C-type staggered grid. The dimensions of
;                   "outData" depend upon the grid point location.
;
; MODIFICATION HISTORY:
;       Created: Mon Dec 30 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu)
;      Modified:
;+++
FUNCTION UVP2Rho_Points, data,        $
                         ULOC = uloc, $
                         VLOC = vloc, $
                         PLOC = ploc

  Compile_Opt IDL2

  ; Error handling.
  on_error, 2

  nparam = n_params()
  if (nparam lt 1) then message, 'incorrect number of arguments, need to supply <data>'

  uloc = keyword_set(uloc)
  vloc = keyword_set(vloc)
  ploc = keyword_set(ploc)
  if ((uloc + vloc + ploc) ne 1) then begin
    message, 'one of [ULOC, VLOC, PLOC] should be set to continue with the calculations'
  endif

  if (size(data, /N_DIMENSIONS) ne 2) then begin
    message, 'only 2D arrays are supported'
  endif

  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = where(badtypes eq size(data, /TYPE), count)
    if (count ne 0) then $
      message, "only numbers are valid values for <data>."

  ; ----------------------------------------

  case 1 of
    (uloc eq 1): $
      begin
        dims = size(data, /DIMENSIONS)
        idim = dims[0]
        jdim = dims[1]
        idim_rho = idim + 1
        jdim_rho = jdim

        outData = make_array(idim_rho, jdim_rho, $
                             TYPE = size(data, /TYPE), VALUE = 0)

        outData[1:idim - 1, *] = 0.5 * (data[0:idim - 2, *] + data[1:idim - 1, *])
        outData[0, *] = outData[1, *]
        outData[idim_rho - 1, *] = outData[idim - 1, *]
      end
    (vloc eq 1): $
      begin
        dims = size(data, /DIMENSIONS)
        idim = dims[0]
        jdim = dims[1]
        idim_rho = idim
        jdim_rho = jdim + 1

        outData = make_array(idim_rho, jdim_rho, $
                             TYPE = size(data, /TYPE), VALUE = 0)

        outData[*, 1:jdim - 1] = 0.5 * (data[*, 0:jdim - 2] + data[*, 1:jdim - 1])
        outData[*, 0] = outData[*, 1]
        outData[*, jdim_rho - 1] = outData[*, jdim - 1]
      end
    (ploc eq 1): $
      begin
        dims = size(data, /DIMENSIONS)
        idim = dims[0]
        jdim = dims[1]
        idim_rho = idim + 1
        jdim_rho = jdim + 1

        outData = make_array(idim_rho, jdim_rho, $
                             TYPE = size(data, /TYPE), VALUE = 0)

        outData[1:idim - 1, 1:jdim - 1] = 0.5 * (data[0:idim - 2, 0:jdim - 2] + data[1:idim - 1, 1:jdim - 1])
        outData[0, *] = outData[1, *]
        outData[*, 0] = outData[*, 1]
        outData[idim_rho - 1, *] = outData[idim - 1, *]
        outData[*, jdim_rho - 1] = outData[*, jdim - 1]
      end
    else: $
      begin
        message, 'one of [ULOC, VLOC, PLOC] should be set to continue with the calculations'
      end
  endcase

  return, ZeroFloatFix( outData )

end
