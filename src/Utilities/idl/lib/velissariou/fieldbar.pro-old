FUNCTION FieldBar, data, depgrd, ZSPACING = zsp, MASK = mask
; Function FieldBar
;
; Calculate the vertically integrated field
;
; INPUT
;     data : variable to be integrated
;            the variable can be on rho, u, v, psi points that is,
;            as defined by the Arakawa C-grid.
;            Missing values are being identified as NAN values or by
;            using the mask value.
;            The user has to pre-treat the data to fill any missing values.
;   depgrd : the bathymetry of the grid domain depgrd[IPOINTS, JPOINTS]
;            it is used to determine the position of the variable
;            on the Arakawa C-grid and to eliminate the zspacing points
;            below the local depth
;
; OUTPUT
;  retval: the integrated variable

  Compile_Opt IDL2

  on_error, 2

  data_size = size(data)
  if ((data_size[0] ne 1) and (data_size[0] ne 3)) then begin
    message, 'a 1-D or 3-D array is required for DATA in FieldBar'
  endif
  data_NDIM   = data_size[0]
  data_DIMIDX = (data_NDIM eq 1) ? 1 : 3
  data_NPNTS  = data_size[data_DIMIDX]
  data_TYPE   = size(data, /TYPE)

  thisData = data

  if (n_elements(mask) ne 0) then begin
    mask_size = size(mask)
    mask_DIMIDX = (data_NDIM eq 1) ? 1 : 2
    case data_NDIM of
      1: $
        begin
          if (mask_size[0] ne data_NDIM) then begin
            message, "<data> and <mask> must have the same dimensions."
          endif
          ; 1 = water point mask value
          ; 0 = land point mask value
          chk_msk = ChkForMask(mask, 0, idx, icnt)
          if (icnt ne 0) then thisData[idx] = !VALUES.F_NAN
        end
      3: $
        begin
          if (mask_size[0] ne data_NDIM - 1) then begin
            message, "<mask> must be a 2D array of values."
          endif
          ; 1 = water point mask value
          ; 0 = land point mask value
          chk_msk = ChkForMask(mask, 0, idx, icnt)
          kdim = (size(data, /DIMENSIONS))[2]
          for k = 0L, kdim - 1 do begin
            if (icnt ne 0) then begin
              tmp_arr = reform(thisData[*, *, k])
              tmp_arr[idx] = !VALUES.F_NAN
              thisData[*, *, k] = tmp_arr
            endif
          endfor
        end
      else: message, "<mask> has invalid dimensions."
    endcase
  endif

  ; If zspacing is not supplied, assume that the data are evenly
  ; spaced in the vertical direction.
  if (n_elements(zsp) eq 0) then begin
    idxFIN = where(finite(thisData) eq 0, icntFIN)

    dz = thisData & dz[*] = 1
    if(icntFIN ne 0) then dz[idxFIN] = 0
    if(icntFIN ne 0) then thisData[idxFIN] = 0

    tot_dat = total(thisData, data_DIMIDX, /PRESERVE_TYPE)
    tot_dz  = total(dz, data_DIMIDX, /PRESERVE_TYPE)

    retval = tot_dat & retval[*] = !VALUES.F_NAN
    idx = where(tot_dz gt 0.0, icnt)
    if (icnt ne 0) then retval[idx] = tot_dat[idx] / tot_dz[idx]

    return, ZeroFloatFix(retval)
  endif
      
  ; The calculations below consider that the vertical spacing may be
  ; uniform or non-uniform (based on ZSPACING)
  if (n_elements(depgrd) eq 0) then begin
    message, 'need to supply the DEPGRD values that define the depths (a scalar or a 2-D array)'
  endif

  dep_NDIM = (size(depgrd))[0]
  if (dep_NDIM ne (data_NDIM - 1)) then begin
    message, 'DEPGRD should be a scalar or a 2-D array (DATA is prescribed as an 1-D or a 3-D array)'
  endif
  
  ; If zspacing is supplied, the number of elements of zspacing
  ; should be equal to the number of elements of the last
  ; dimension (for z_r type spacings) OR that number plus one
  ; (for z_w type spacings). As last dimension for the 3-D data array
  ; case (i, j, k) is considered the k-dim (vertical direction).
  ; The "data" and "zsp" arrays should always have the same number
  ; of dimensions
  zsp_size = size(zsp)
  if ((zsp_size[0] ne 1) and (zsp_size[0] ne 3)) then begin
    message, 'a 1-D or 3-D array is required for ZSPACING in FieldBar'
  endif
  zsp_NDIM   = zsp_size[0]
  zsp_DIMIDX = (zsp_NDIM eq 1) ? 1 : 3
  zsp_NPNTS  = zsp_size[zsp_DIMIDX]

  ; ----------------------------------------
  ; Case of 1-D data (this is for just a grid point horizontally)
  ; No further checking is performed to locate the position of the
  ; data on the Arakawa C-grid.
  if (data_NDIM eq 1) then begin
    if (zsp_NDIM ne data_NDIM) then $
      message, 'ZSPACING should be an 1-D array (as DATA)'

    if ((zsp_NPNTS ne data_NPNTS) and (zsp_NPNTS ne (data_NPNTS + 1))) then $
      message, 'ZSPACING should have DATA or DATA+1 points'

    ; treat the zspacings 
    thisZSP = zsp
    idxFIN = where(finite(thisData) eq 0, icntFIN)
    if (zsp_NPNTS eq data_NPNTS) then begin
      dz = float(abs(thisZSP[1:zsp_NPNTS - 1] - thisZSP[0:zsp_NPNTS - 2]))
      dz = [ dz, dz[zsp_NPNTS - 2] ]
      thisZSP = [thisZSP - 0.5 * dz, thisZSP[zsp_NPNTS - 1] + 0.5 * dz[zsp_NPNTS - 1]]
      dz = float(abs(thisZSP[1:zsp_NPNTS] - thisZSP[0:zsp_NPNTS - 1]))

      idx1 = 0
      idx2 = data_NPNTS - 1
      vint1 = 0.0 & dz1 = 0.0
      vint2 = 0.0 & dz2 = 0.0
      if (finite(thisData[idx1]) eq 1) then begin
        vint1 = 0.5 * thisData[idx1] * dz[idx1]
        dz1   = 0.5 * dz[idx1]
      endif
      if (finite(thisData[idx2]) eq 1) then begin
        vint2 = 0.5 * thisData[idx2] * dz[idx2]
        dz2   = 0.5 * dz[idx2]
      endif

      ; Set the above NaN values to zero to calculate the totals
      if(icntFIN ne 0) then dz[idxFIN] = 0
      if(icntFIN ne 0) then thisData[idxFIN] = 0

      tot_dat = total(thisData * dz, data_DIMIDX, /PRESERVE_TYPE) - vint1 - vint2
      tot_dz  = total(dz, data_DIMIDX, /PRESERVE_TYPE) - dz1 - dz2

      ; We revert back to NaN values to return the final calculated values
      retval = tot_dat & retval[*] = !VALUES.F_NAN
      idx = where(tot_dz gt 0.0, icnt)
      if (icnt ne 0) then retval[idx] = tot_dat[idx] / tot_dz[idx]
    endif else begin
      dz = float(abs(thisZSP[1:zsp_NPNTS - 1] - thisZSP[0:zsp_NPNTS - 2]))
      if(icntFIN ne 0) then dz[idxFIN] = 0
      if(icntFIN ne 0) then thisData[idxFIN] = 0

      tot_dat = total(thisData * dz, data_DIMIDX, /PRESERVE_TYPE)
      tot_dz  = total(dz, data_DIMIDX, /PRESERVE_TYPE)

      retval = tot_dat & retval[*] = !VALUES.F_NAN
      idx = where(tot_dz gt 0.0, icnt)
      if (icnt ne 0) then retval[idx] = tot_dat[idx] / tot_dz[idx]
    endelse

    return, ZeroFloatFix(retval)
  endif

  ; ----------------------------------------
  ; Case of 3-D data.
  if (data_NDIM eq 3) then begin
    if (zsp_NDIM ne (dep_NDIM + 1)) then $
      message, 'ZSPACING should be a 3-D array (as DATA)'

    if ((zsp_NPNTS ne data_NPNTS) and (zsp_NPNTS ne (data_NPNTS + 1))) then $
      message, 'ZSPACING should have DATA or DATA+1 points'

    ; Get the position on the Arakawa C-grid.
    szg = (size(depgrd, /DIMENSIONS))[0:1]
    szd = (size(data, /DIMENSIONS))[0:1]
    IDIM = szg[0]
    JDIM = szg[1]
    case 1 of
      ; U position
      ((szg - szd)[0] eq 1) and ((szg - szd)[1] eq 0): $
        begin
          thisZSP = 0.5 * (zsp[0:IDIM - 2, *, *] + zsp[1:IDIM - 1, *, *])
          thisDEP = 0.5 * (depgrd[0:IDIM - 2, *] + depgrd[1:IDIM - 1, *])
        end
      ; V position
      ((szg - szd)[0] eq 0) and ((szg - szd)[1] eq 1): $
        begin
          thisZSP = 0.5 * (zsp[*, 0:JDIM - 2, *] + zsp[*, 1:JDIM - 1, *])
          thisDEP = 0.5 * (depgrd[*, 0:JDIM - 2] + depgrd[*, 1:JDIM - 1])
        end
      ; RHO position
      ((szg - szd)[0] eq 1) and ((szg - szd)[1] eq 1): $
        begin
          thisZSP = zsp
          thisDEP = depgrd
        end
      ; PSI position
      ((szg - szd)[0] eq 0) and ((szg - szd)[1] eq 0): $
        begin
          thisZSP = zsp
          thisDEP = depgrd
        end
      else: message, 'Could not determine the C-grid location'
    endcase

    ; treat the zspacings
    idxFIN = where(finite(thisData) eq 0, icntFIN)
    if (zsp_NPNTS eq data_NPNTS) then begin
      dz = thisZSP & dz[*] = 0
      dz[*, *, 0:zsp_NPNTS - 2] = float(abs(thisZSP[*, *, 1:zsp_NPNTS - 1] - thisZSP[*, *, 0:zsp_NPNTS - 2]))
      dz[*, *, zsp_NPNTS - 1] = dz[*, *, zsp_NPNTS - 2]

      tmp_dat = thisZSP & tmp_dat[*] = 0
      tmp_sz = size(tmp_dat, /DIMENSIONS)
      tmp_dat = congrid(tmp_dat, tmp_sz[0], tmp_sz[1], tmp_sz[2] + 1)
      tmp_dat[*, *, 0:zsp_NPNTS - 1] = thisZSP[*, *, 0:zsp_NPNTS - 1] - 0.5 * dz[*, *, 0:zsp_NPNTS - 1]
      tmp_dat[*, *, zsp_NPNTS] = thisZSP[*, *, zsp_NPNTS - 1] + 0.5 * dz[*, *, zsp_NPNTS - 1]
      thisZSP = tmp_dat
      dz = float(abs(thisZSP[*, *, 1:zsp_NPNTS] - thisZSP[*, *, 0:zsp_NPNTS - 1]))

      ; Check if the end points hold NaN values and procceed accordingly
      idx1 = 0
      idx2 = data_NPNTS - 1
      vint1 = reform(dz[*, *, 0]) & vint1[*] = 0.0
      vint2 = vint1 & dz1 = vint1 & dz2 = vint1

      tmp_dat = reform(thisData[*, *, idx1])
      tmp_dz  = reform(dz[*, *, idx1])
      idx = where(finite(tmp_dat) eq 1, icnt)
      if (icnt ne 0) then begin
        vint1[idx] = 0.5 * tmp_dat[idx] * tmp_dz[idx]
        dz1[idx]   = 0.5 * tmp_dz[idx]
      endif
      tmp_dat = reform(thisData[*, *, idx2])
      tmp_dz  = reform(dz[*, *, idx2])
      idx = where(finite(tmp_dat) eq 1, icnt)
      if (icnt ne 0) then begin
        vint2[idx] = 0.5 * tmp_dat[idx] * tmp_dz[idx]
        dz2[idx]   = 0.5 * tmp_dz[idx]
      endif

      ; Set the above NaN values to zero to calculate the totals
      if(icntFIN ne 0) then dz[idxFIN] = 0
      if(icntFIN ne 0) then thisData[idxFIN] = 0

      tot_dat = total(thisData * dz, data_DIMIDX, /PRESERVE_TYPE) - vint1 - vint2
      tot_dz  = total(dz, data_DIMIDX, /PRESERVE_TYPE) - dz1 - dz2

      ; We revert back to NaN values to return the final calculated values
      retval = tot_dat & retval[*] = !VALUES.F_NAN
      idx = where(tot_dz gt 0.0, icnt)
      if (icnt ne 0) then retval[idx] = tot_dat[idx] / tot_dz[idx]
    endif else begin
      dz = float(abs(thisZSP[*, *, 1:zsp_NPNTS - 1] - thisZSP[*, *, 0:zsp_NPNTS - 2]))
      if(icntFIN ne 0) then dz[idxFIN] = 0
      if(icntFIN ne 0) then thisData[idxFIN] = 0

      tot_dat = total(thisData * dz, data_DIMIDX, /PRESERVE_TYPE)
      tot_dz  = total(dz, data_DIMIDX, /PRESERVE_TYPE)

      retval = tot_dat & retval[*] = !VALUES.F_NAN
      idx = where(tot_dz gt 0.0, icnt)
      if (icnt ne 0) then retval[idx] = tot_dat[idx] / tot_dz[idx]
    endelse

    return, ZeroFloatFix(retval)
  endif

  return, !VALUES.F_NAN
end
