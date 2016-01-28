Function InvDist_Interp, xloc, yloc,        $
                         xdat, ydat, zdat,  $
                         NPOINTS = npoints, $
                         EXPNT  = expnt,    $
                         METHOD = method

  Compile_Opt IDL2

  on_error, 2

  nLOC = n_elements(xloc)
  nDAT = n_elements(xdat)
  
  if (nLOC lt 1) then $
    message, 'at least one interpolation point is required in [xloc, yloc]'

  if (nDAT lt 1) then $
    message, 'at least one data point is required in [xdat, ydat, zdat]'

  ; ----------
  ; get the optional arguments

  ; only used in "MODIFIEDSHEPARD" method
  nrPNTS = (n_elements(npoints) ne 0) ? (fix(npoints[0]) > 1) : 9

  ; used in "SHEPARD" and "MODIFIEDSHEPARD" methods
  myEXP = (n_elements(expnt) ne 0) ? float(expnt[0]) : 2.0


  method = (n_elements(method) ne 0) $
             ? (string(method))[0]   $
             : 'MODIFIEDSHEPARD'
  case 1 of
    strmatch(method, 'N*Point*', /FOLD_CASE): $
      begin
        myMETH = 1
        method = 'NearestPoint'
      end
    strmatch(method, 'Shep*', /FOLD_CASE): $
      begin
        myMETH = 2
        method = 'Shepard'
      end
    strmatch(method, 'M*Shep*', /FOLD_CASE): $
      begin
        myMETH = 3
        method = 'ModifiedShepard'
      end
    else: message, 'Unknown interpolation method was supplied'
  endcase
  ; ----------


  missDAT = !VALUES.F_NAN

  zloc = xloc & zloc[*] = missDAT
  myXLOC = xloc[*]
  myYLOC = yloc[*]
  myZLOC = zloc[*]

  myXDAT = xdat[*]
  myYDAT = ydat[*]
  myZDAT = zdat[*]

  for i = 0L, nLOC - 1 do begin
    xx = myXDAT - myXLOC[i]
    yy = myYDAT - myYLOC[i]
    zz = myZDAT
    dd = sqrt(xx * xx + yy * yy)

    minDD_val = min(dd, minDD_idx, MAX = maxDD_val)

    ; check if the interpolation point coincides with a data point
    if ((nDAT eq 1) or (minDD_val le 0.001)) then begin
      myZLOC[i] = zz[minDD_idx]
      continue
    endif

    case myMETH of
      1: $
        begin
          myZLOC[i] = zz[minDD_idx]
        end
      2: $
        begin
          wh = 1.0 / (dd ^ (myEXP))
          wh = wh / total(wh)
          myZLOC[i] = total(wh * zz)
        end
      3: $
        begin
          ; sort data in ascending order based on distance
          idx_sort = sort_nd(dd, 1)
          zz = zz[idx_sort]
          dd = dd[idx_sort]

          np = (n_elements(dd) < nrPNTS)

          maxR = max(dd[0:np-1])
          del_maxR = ((maxR - dd) > 0)
          wh = (del_maxR / (maxR * dd)) ^ (myEXP)
          wh = wh / total(wh)
          myZLOC[i] = total(wh * zz)
        end
      else:
    endcase
  endfor

  zloc[*] = ZeroFloatFix( myZLOC )

  return, zloc

End
