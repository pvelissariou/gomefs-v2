;+
; NAME:
;   getDataRange
;
; AUTHOR:
;   Panagiotis Velissariou
;   velissariou.1@osu.edu
;
; PURPOSE:
;   Locate the ranges of continuous "good" data blocks in the supplied
;   data array VDATA. Bad values in VDATA should already been assigned the
;   NaN value. In the future this procedure can be improved to incorporate
;   a user input flag for the "bad" data values.
;
; CALLING SEQUENCE:
;   WH = getDataRange(VDATA, MASK, NINTERV=, INTERV=, MINIDX=, MAXIDX=,)
;
; DESCRIPTION: 
;
;   The procedure getDataRange is a method to determine which
;   continuous data blocks in a supplied 1-D data vector do not contain
;   any bad values identified by the value NaN.
;
; INPUTS:
;
;   VDATA - an 1-D array of data, in no particular order.
;   MASK  - the mask value to check for missing data.
;
;
; KEYWORDS:
;
;   NINTERV  - the number of resulting blocks. A value of zero
;              indicates no good time intervals.
;
;   INTERV   - a 2-D array (INTERV[NINTERV,2]) of the indices defining
;              the "good" blocks of data.  The first row (INTERV[*,0])
;              contains the starting indices of the "good" data blocks
;              and the second row (INTERV[*,1]) contains the indices of
;              the ending indices of the "good" data blocks.
;
;   MINIDX   - this is the index of INTERV that denotes the "good" data
;              block with the smallest width.
;
;   MAXIDX   - this is the index of INTERV that denotes the "good" data
;              block with the largest width.
;
; RETURNS:
;
;   None
;
;
; MODIFICATION HISTORY:
;   Written, PV, 2004
;   Documented, PV, Jan 2004
;
;  $Id: getDataRange.pro,v 1.0 2004/01/23 00:08:15 pvelissariou Exp $
;
;-
; Copyright (C) 2004, Panagiotis Velissariou
; This software is provided as is without any warranty whatsoever.
; Permission to use, copy, modify, and distribute modified or
; unmodified copies is granted, provided this copyright and disclaimer
; are included unchanged.
;-
PRO getDataRange, vdata, mask, NINTERV = ninterv, INTERV = interv, $
                     MINIDX = minidx, MAXIDX = maxidx

  on_error, 1

  if ((n_elements(vdata) eq 0) or (size(vdata, /N_DIMENSIONS) ne 1)) then $
    message, 'getdatarange: need to specify an 1-D vector of values for <vdata>.'

; Initialize some variables
  nRngArr = 0L
  RngArr = -1L
  minRngArr = -1L
  maxRngArr = -1L
  
  nvdata = n_elements(vdata)

; Check for minimal data size
  if (nvdata lt 2) then goto, FINISH

; No NaN values in the supplied data vector found
  if chkformask(vdata, mask, idx, nidx, $
                complement = cidx, ncomplement = ncidx) eq 0 then begin
    nRngArr = 1
    RngArr = [[0], [nvdata - 1]]
    minRngArr = 0
    maxRngArr = 0
    goto, FINISH
  endif

; NaN values found in the supplied data vector, therefore
; get the indices of the finite elements
  Idx0 = cidx[0]
  Idx1 = cidx[ncidx - 1]

  BegStr = ''
  EndStr = ''
  for i = 0, ncidx - 1 do begin
    case cidx[i] of
      Idx0: begin
              BegStr = BegStr + ' ' + strtrim(string(cidx[i]), 2)
              if chkformask(vdata[cidx[i]+1], mask) then $
                EndStr = EndStr + ' ' + strtrim(string(cidx[i]), 2)
         end
      Idx1: begin
              EndStr = EndStr + ' ' + strtrim(string(cidx[i]), 2)
              if chkformask(vdata[cidx[i]-1], mask) then $
                BegStr = BegStr + ' ' + strtrim(string(cidx[i]), 2)
            end
      else: begin
              if chkformask(vdata[cidx[i]-1], mask) then $
                BegStr = BegStr + ' ' + strtrim(string(cidx[i]), 2)
              if chkformask(vdata[cidx[i]+1], mask) then $
                EndStr = EndStr + ' ' + strtrim(string(cidx[i]), 2)
     	    end
    endcase
  endfor

  BegStr = strtrim(string(BegStr), 2)
  nBeg   = n_elements(strsplit(BegStr))
  EndStr = strtrim(string(EndStr), 2)
  nEnd   = n_elements(strsplit(EndStr))

  if (nBeg ne nEnd) then $
    message, 'getdatarange: cannot determine the ranges of the good data points correctly.'

; Create the 2-D int array that will hold the indices of the good data blocks
  nRngArr = nBeg
  RngArr  = intarr(nRngArr, 2)
  r_arr   = intarr(nRngArr)

  reads, BegStr, r_arr
  RngArr[*, 0] = r_arr

  reads, EndStr, r_arr
  RngArr[*, 1] = r_arr

; Get the indices of the largest and smallest good data blocks
  r_arr = RngArr[*, 1] - RngArr[*, 0] + 1
  maxvar = max(r_arr, min = minvar)
  maxRngArr = where(r_arr eq maxvar)
  minRngArr = where(r_arr eq minvar)

  FINISH:
  if arg_present(NINTERV) then ninterv = nRngArr
  if arg_present(INTERV)  then interv  = RngArr
  if arg_present(MINIDX)  then minidx  = minRngArr
  if arg_present(MAXIDX)  then maxidx  = maxRngArr

end
