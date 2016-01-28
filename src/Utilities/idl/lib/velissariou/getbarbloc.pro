FUNCTION GetBarbLoc, mask_grid, mask_val, NBARB = nbarb, NMOD = nmod, ALL = all
;+++
; NAME:
;	GETBARBLOC
; VERSION:
;	1.0
; PURPOSE:
;	To check if in the data (value or, array) there are entries
;       with values equal to "mask"
; CALLING SEQUENCE:
;	GetBarbLoc(mask_grid [, mask_val] [, keywords/options])
;	mask_grid - The gridded (2D) array to be checked against the mask value "mask_val"
;	 mask_val - The mask value (optional, default = 1)
;            NMOD - The modulus value that determines the "barb" locations
;                   nmod = 6 means that barbs are located every 6 points,
;                   default: 4
;           NBARB - Set this keyword to a named variable that holds the
;                   total number of "barb" locations (output)
; KEYWORDS:
;             ALL - Set this keyword if all grid points and not only the
;                   masked points are to be considered as "barb" locations
; RETURNS:
;         locBarb - The indeces of the "barb" locations in respect to "mask_grid"
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created:  Wed May 28 2014 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;	Modified:
;+++

  Compile_Opt IDL2

  on_error, 2

  if (size(mask_grid, /N_DIMENSIONS) ne 2) then begin
    message, 'only 2D arrays are supported for <mask_grid>.'
  endif

  mask_val = (n_elements(mask_val) ne 0) ? mask_val[0] : 1
  nmod = (n_elements(nmod) ne 0) ? fix(abs(nmod[0])) : 4

  i_start = 1
  j_start = 1

  sz = size(mask_grid, /DIMENSIONS)
  IPNTS = sz[0]
  JPNTS = sz[1]

  IArr = mask_grid
  for i = 0L, JPNTS - 1 do IArr[*, i] = indgen(IPNTS)

  JArr = mask_grid
  for i = 0L, IPNTS - 1 do JArr[i, *] = indgen(JPNTS)

  nBarb = 0L
  locBarb = -1L
  if keyword_set(all) then begin
    locBarb = where( ((IArr mod nmod) eq i_start) and $
                     ((JArr mod nmod) eq j_start), nBarb)
  endif else begin
    chk_msk = ChkForMask(mask_grid, mask_val, idx, count)
    if (count ne 0) then begin
      mask_temp = make_array(size(mask_grid, /DIMENSIONS), /INTEGER, VALUE = 0)
      mask_temp[idx] = 1
      locBarb = where( ((IArr mod nmod) eq i_start) and $
                       ((JArr mod nmod) eq j_start) and $
                       (mask_temp eq 1), nBarb)
    endif
  endelse
                     
  return, locBarb
end
