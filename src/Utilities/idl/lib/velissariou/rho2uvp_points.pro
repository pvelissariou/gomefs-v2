;+++
; NAME:
;	RHO2UVP_POINTS
;
; VERSION:
;	1.0
;
; PURPOSE:
;	To calculate the values of a variable at the u, v and psi locations
;       given the variable values at the rho locations.
;
; AUTHOR:
;
;      Panagiotis Velissariou, Ph.D, P.E.
;      E-mail: pvelissariou@coaps.fsu.edu
;
; CALLING SEQUENCE:
;	  outData = Rho2UVP_Points(data, keywords)
;	     data - The 2D array of the variable values at rho points
;
; KEYWORDS:
;            ULOC - Set this keyword to perform the calculations at U-points of
;                   a C-type staggered grid (mandatory)
;            VLOC - Set this keyword to perform the calculations at V-points of
;                   a C-type staggered grid (mandatory)
;            PLOC - Set this keyword to perform the calculations at PSI-points of
;                   a C-type staggered grid (mandatory)
;          Default: NONE
;             NOTE: Just one of ULOC, VLOC, PLOC should be supplied at any time
;
; RETURNS:
;         outData - The 2D array of the variable calculated at U, V or PSI
;                   locations of a C-type staggered grid. The dimensions of
;                   "outData" depend upon the grid point location.
;
; MODIFICATION HISTORY:
;       Created: Mon Dec 30 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu)
;      Modified:
;+++
FUNCTION Rho2UVP_Points, data,        $
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

  dims = size(data, /DIMENSIONS)
  idim = dims[0]
  jdim = dims[1]

  u_var = 0.5 * (data[0:idim-2, *] + data[1:idim-1, *])
  v_var = 0.5 * (data[*, 0:jdim-2] + data[*, 1:jdim-1])
  p_var = 0.5 * (u_var[*, 0:jdim-2] + u_var[*, 1:jdim-1])

  if (uloc eq 1) then outData = u_var
  if (vloc eq 1) then outData = v_var
  if (ploc eq 1) then outData = p_var

  return, ZeroFloatFix( outData )

end
