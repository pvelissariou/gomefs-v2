FUNCTION ChkForMask, data, mask, index, count,                 $
                     COMPLEMENT = compl, NCOMPLEMENT = ncompl, $
                     BEG_HOLE = beg_hole, END_HOLE = end_hole, $
                     LEN_HOLE = len_hole, NHOLE = nhole
;+++
; NAME:
;	CHKFORMASK
; VERSION:
;	1.0
; PURPOSE:
;	To check if in the data (value or, array) there are entries
;       with values equal to "mask"
; CALLING SEQUENCE:
;	CHKFORMASK(data, mask, [[index], [count]])
;	     data - The value or, array to be checked against the mask value
;	     mask - The mask value
;           index - A named variable that holds the indices of "data"
;                   with entries with values equal to "mask"
;           count - A named variable that holds the total number of entries
;                   in "data" with values equal to "mask"
; KEYWORDS:
;      COMPLEMENT - Set this keyword to a named variable that receives the
;                   subscripts of the zero elements of "data"
;     NCOMPLEMENT - Set this keyword to a named variable that receives the
;                   number of zero elements found in "data"
;        BEG_HOLE - Set this keyword to a named variable that receives the
;                   starting indeces of the missing data ranges
;                   (default [-1])
;        END_HOLE - Set this keyword to a named variable that receives the
;                   ending indeces of the missing data ranges
;                   (default [-1])
;        LEN_HOLE - Set this keyword to a named variable that receives the
;                   lengths of the missing data ranges
;                   (default [-1])
;           NHOLE - Set this keyword to a named variable that receives the
;                   total number of the missing data blocks
;                   (default 0)
; RETURNS:
;               0 - If no entries found with values equal to "mask"
;               1 - If entries found with values equal to "mask"
;                   and they are of type: STRING
;               2 - If entries found with values equal to "mask"
;                   and they are of type: FINITE NUMBER
;               3 - If entries found with values equal to "mask"
;                   and they are of type: NAN
;               4 - If entries found with values equal to "mask"
;                   and they are of type: INFINITY
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

  bad = [8, 10, 11]

  if ( n_elements(data) eq 0 ) then $
    message, "you need to supply a valid value for <data>."
  if ( where(bad eq size(data, /type)) ge 0 ) then $
    message, "structures, pointers, objref are not valid values for <data>."

  if ( n_elements(mask) ne 1 ) then $
    message, "you need to supply a scalar value for <mask>."
  if ( where(bad eq size(mask, /type)) ge 0 ) then $
    message, "structures, pointers, objref are not valid values for <mask>."

  retval   =  0
  index    = -1L
  count    =  0L
  compl    = -1L
  ncompl   =  0L
  beg_hole = [ -1L ]
  end_hole = [ -1L ]
  len_hole = [ -1L ]
  nhole = 0

  case 1 of
    (size(mask, /type) eq 7): $ ; strings
       begin
         index = where(strcmp(data, mask, /FOLD_CASE) eq 1, count, $
                       complement = compl, ncomplement = ncompl)
         if (count ne 0) then retval = 1
       end
    (finite(mask) eq 1): $ ; finite values only
       begin
         tmp_data = ZeroFloatFix(data - mask)

         mType = Size(tmp_data, /TYPE)
         info = machar(DOUBLE = (mType EQ 5 OR mType EQ 9))

         index = where(abs(tmp_data) le info.eps, count, $
                         complement = compl, ncomplement = ncompl)
         if (count ne 0) then retval = 2
       end
    (finite(mask, /NAN) eq 1): $ ; NaN values only
       begin
         index = where(finite(data, /NAN) eq 1, count, $
                       complement = compl, ncomplement = ncompl)
         if (count ne 0) then retval = 3
       end
    (finite(mask, /INFINITY) eq 1): $ ; Infinity values only
       begin
         index = where(finite(data, /INFINITY) eq 1, count, $
                       complement = compl, ncomplement = ncompl)
         if (count ne 0) then retval = 4
       end
    else: $
       begin
         retval   =  0
         index    = -1L
         count    =  0L
         compl    = -1L
         ncompl   =  0L
         beg_hole = [ -1L ]
         end_hole = [ -1L ]
         len_hole = [ -1L ]
         nhole = 0
       end
  endcase

  if (retval ge 1) then begin
    good = [-1, compl, count + ncompl]
    ngood = ncompl + 2
    delta = good[1:ngood - 1] - good[0:ngood - 2]
    holes = where(delta gt 1, nhole)
    if(nhole ne 0) then begin
      beg_hole = good[holes] + 1
      len_hole = delta[holes] - 1
      end_hole = beg_hole + len_hole - 1
    endif
  endif

  return, retval

end
