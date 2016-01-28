Function FillWithMask, chkval, oldmask, newmask, idx_chkval, count_chkval
;+++
; NAME:
;	FILLWITHMASK
; VERSION:
;	1.0
; PURPOSE:
;	To replace a data array entries with !VALUES_NAN given the mval
; CALLING SEQUENCE:
;	FILLWITHMASK(chkval, oldmask, newmask, [[idx_chkval], [count_chkval]])
;	   chkval - The value or, array to be checked against the oldmask value
;	  oldmask - The old mask value
;	  newmask - The new mask value
;      idx_chkval - A named variable that holds the indices of "chkval"
;                   with entries with values equal to "mask"
;    count_chkval - A named variable that holds the total number of entries
;                   in "chkval" with values equal to "mask"
; RETURNS:
;               The modified "chkval", where the entries with values
;               "oldmask" were replaced by "newmask"
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

  retval       = chkval
  idx_chkval   = -1
  count_chkval =  0

  if ( n_elements(chkval) eq 0 ) then $
    message, "you need to supply a valid value for <chkval>."

  if ( n_elements(oldmask) ne 1 ) then $
    message, "you need to supply a scalar value for <oldmask>."

  if ( n_elements(newmask) ne 1 ) then $
    message, "you need to supply a scalar value for <newmask>."

  if chkformask(chkval, oldmask, idx_chkval, count_chkval) then begin
    retval[idx_chkval] = newmask
  endif
  
  return, retval

end
