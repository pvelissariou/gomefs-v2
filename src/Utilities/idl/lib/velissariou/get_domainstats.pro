Pro Get_DomainStats, data,                $
                     XDIR = xdir,         $
                     YDIR = ydir,         $
                     WEIGHTED = weighted, $
                     DARR = darr,         $
                     MIN_VAL  = min_val,  $
                     MAX_VAL  = max_val,  $
                     AVE_VAL  = ave_val,  $
                     DMIN_VAL = dmin_val, $
                     DMAX_VAL = dmax_val, $
                     DAVE_VAL = dave_val

  ; Error handling.
  Compile_Opt IDL2

  ; --------------------
  ; check the input variables
  xdir = keyword_set(xdir)
  ydir = keyword_set(ydir)
  If ((xdir + ydir) ne 1) Then $
    message, 'need to set one of /XDIR, or /YDIR.'

  If (N_Elements(data) EQ 0) Then Message, "Must pass the <data> argument."
  If (Where([7, 8, 10, 11] EQ Size(data, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <data>."
  If (Size(data, /N_DIMENSIONS) NE 2) Then $
    Message, "<data> must be a 2D array of values."

  dims   = size(data, /DIMENSIONS)
  IPNTS  = long(dims[0])
  JPNTS  = long(dims[1])

  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ; START THE CALCULATIONS

  MAX_VAL = max(data, MIN = MIN_VAL, /NAN)
  AVE_VAL = mean(data, /NAN)

  ; ---------- Get the "DELTA" values
  ARR = data
  dARR = ARR & dARR[*] = 0
  if keyword_set(xdir) then begin
    if keyword_set(weighted) then begin
      ; here we are using a weighted average
      difX  = abs(ARR[1:IPNTS - 1, *] - ARR[0:IPNTS - 2, *])
      difX1 = ( difX[0:IPNTS - 3, *] * difX[0:IPNTS - 3, *] + $
                difX[1:IPNTS - 2, *] * difX[1:IPNTS - 2, *] ) / $
              abs( difX[0:IPNTS - 3, *] + difX[1:IPNTS - 2, *] )
      dARR[1:IPNTS - 2, *] = difX1
      dARR[0, *] = difX[0, *]
      dARR[IPNTS - 1, *] = difX[IPNTS - 2, *]
    endif else begin
      ; here we are using a simple average
      dARR[0:IPNTS - 2, *] = abs(ARR[1:IPNTS - 1, *] - ARR[0:IPNTS - 2, *])
      dARR[IPNTS - 1, *]   = dARR[IPNTS - 2, *]
    endelse
      DMAX_VAL = max(dARR, MIN = DMIN_VAL, /NAN)
      DAVE_VAL = mean(dARR, /NAN)
  endif else begin
    if keyword_set(weighted) then begin
      ; here we are using a weighted average
      difX  = abs(ARR[*, 1:JPNTS - 1] - ARR[*, 0:JPNTS - 2])
      difX1 = ( difX[*, 0:JPNTS - 3] * difX[*, 0:JPNTS - 3] + $
                difX[*, 1:JPNTS - 2] * difX[*, 1:JPNTS - 2] ) / $
              abs( difX[*, 0:JPNTS - 3] + difX[*, 1:JPNTS - 2] )
      dARR[*, 1:JPNTS - 2] = difX1
      dARR[*, 0] = difX[*, 0]
      dARR[*, JPNTS - 1] = difX[*, JPNTS - 2]
    endif else begin
      ; here we are using a simple average
      dARR[*, 0:JPNTS - 2] = abs(ARR[*, 1:JPNTS - 1] - ARR[*, 0:JPNTS - 2])
      dARR[*, JPNTS - 1]   = dARR[*, JPNTS - 2]
    endelse
      DMAX_VAL = max(dARR, MIN = DMIN_VAL, /NAN)
      DAVE_VAL = mean(dARR, /NAN)
  endelse

end
