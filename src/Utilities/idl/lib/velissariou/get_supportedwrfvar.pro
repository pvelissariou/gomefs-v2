FUNCTION Get_SupportedWrfVar, fid, var_name, supp_struct, $
                              LEVEL   = level,   $
                              LVTEXT  = lvtext,  $
                              VDATA   = vdata,   $
                              VNAME   = vname,   $
                              VTYPE   = vtype,   $
                              VTITLE  = vtitle,  $
                              VUNIT   = vunit,   $
                              VDIM    = vdim,    $
                              VRANGE  = vrange,  $
                              VDRANGE = vdrange, $
                              VBDRY   = vbdry,   $
                              VCLRTBL = vclrtbl, $
                              VCLOW   = vclow,   $
                              VCHIGH  = vchigh,  $
                              VNLOW   = vnlow,   $
                              VNHIGH  = vnhigh

  Compile_Opt IDL2

  on_error, 2

  ; ----- Check for valid input
  numtypes = [2, 3, 12, 13, 14, 15]
  num_val = where(numtypes eq size(fid, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<fid> should be an integer number."

  if ( size(var_name, /TNAME) ne 'STRING' ) then $
    message, "<var_name> should be a string."
  ; -----

  SupVarIdx = (where(strcmp(supp_struct.nam, var_name, /FOLD_CASE) eq 1, SupVarCount))[0]
  if (SupVarCount eq 0) then begin
    print, 'WARNING:: the requested variable '+ var_name + ' is not supported.'
    return, -1
  endif

  ; ----- Start the calculations
  grv  = 9.80665 ; Gravitational acceleration (m/s^2)
  rd   = 287.058 ; Gas constant (J/K*kg)
  cp   = 1003.5  ; Specific heat of dry air (J/K*kg)
  
  myVarName = strupcase(var_name)
  case 1 of
    (myVarName eq 'MSLP'): $
      begin
        var_id = 1

        tmp_id = Ncdf_GetData(fid, 'psfc', psfc, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable PSFC required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif else begin
          vdim = Get_VarSpatDim(supp_struct[SupVarIdx].dim)
          vdim_infile = size(psfc, /N_DIMENSIONS)
          if (vdim_infile ne vdim) then begin
            print, 'WARNING:: wrong dimensions for the variable ' + myVarName
            print, '          encountered in the input file'
            return, -1
          endif
        endelse

        tmp_id = Ncdf_GetData(fid, 'hgt', hgt, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable HGT required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif

        tmp_id = Ncdf_GetData(fid, 'q2', q2, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable Q2 required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif

        tmp_id = Ncdf_GetData(fid, 't2', t2, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable T2 required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif

        if (var_id lt 0) then begin
          print, 'WARNING:: can not calculate the variable: '+ myVarName
          goto, notFOUND
        endif

        t2c  = t2 - 273.16            ; Temperature (Celcius, t2 is in K)
        tv2  = t2 * (1.0 + 0.61 * q2) ; Virtual temperature (K)

        ; Calculate the (hgt + 2m) pressure using hypsometric equation (in Pa),
        ; assume temp at (hgt + 2m) = temp at hgt.
        tv_mean = tv2
        p2 = psfc / ( exp((grv * 2.0) / (rd * tv_mean)) )

        ; Estimate the mean sea level actual and virtual temperatures (K)
        ; using the adiabatic lapse rate for dry air
        tmsl  = t2 + (grv / cp) * (hgt + 2.0)
        tvmsl = tmsl * (1.0 + 0.61 * q2) ; assume q2 ~ qmsl

        ; Calculate the mean sea level pressure using hypsometric equation (in Pa),
        tv_mean = 0.5 * (tv2 + tvmsl)
        pmsl = p2 * ( exp((grv * (hgt + 2.0)) / (rd * tv_mean)) )

        vdata = pmsl
      end
    (myVarName eq 'SPH2') or (myVarName eq 'RELH2') or (myVarName eq 'TD2'): $
      begin
        var_id = 1

        tmp_id = Ncdf_GetData(fid, 'q2', q2, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable Q2 required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif else begin
          vdim = Get_VarSpatDim(supp_struct[SupVarIdx].dim)
          vdim_infile = size(q2, /N_DIMENSIONS)
          if (vdim_infile ne vdim) then begin
            print, 'WARNING:: wrong dimensions for the variable ' + myVarName
            print, '          encountered in the input file'
            return, -1
          endif
        endelse

        tmp_id = Ncdf_GetData(fid, 't2', t2, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable T2 required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif

        tmp_id = Ncdf_GetData(fid, 'psfc', psfc, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable PSFC required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif

        if (var_id lt 0) then begin
          print, 'WARNING:: can not calculate the variable: '+ myVarName
          goto, notFOUND
        endif

        t2c  = t2 - 273.16            ; Temperature (Celcius, t2 is in K)
        tv2  = t2 * (1.0 + 0.61 * q2) ; Virtual temperature (K)

        ; Calculate the (hgt + 2m) pressure using hypsometric equation (in Pa),
        ; assume temp at (hgt + 2m) = temp at hgt.
        tv_mean = tv2
        p2 = psfc / ( exp((grv * 2.0) / (rd * tv_mean)) )

        ; Calculate the vapor pressure at 2m (in Pa)
        e = (q2 * p2) / (q2 + 0.622)

        ; Calculate the saturation vapor pressure at 2m (in Pa)
        es = 611.2 * exp( (17.67 * t2c) / (t2c + 243.5) )

        ; Calculate the specific humidity at 2m (kg/kg)
        sph2 = (0.622 * e) / (p2 - 0.378 * e )

        ; Calculate the relative humidity at 2m (%)
        relh2 = (e / es) * ((p2 - es) / (p2 - e)) * 100.0

        ; Calculate the dew point temperature at 2m (Celcius)
        td2 = alog(e / 611.2)
        td2 = (243.5 * td2) / (17.67 - td2)

        if (myVarName eq 'SPH2')  then vdata = sph2
        if (myVarName eq 'RELH2') then vdata = relh2
        if (myVarName eq 'TD2')   then vdata = td2
      end
    (myVarName eq 'CRAIN'): $
      begin
        var_id = 1

        tmp_id = Ncdf_GetData(fid, 'rainc', rainc, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable RAINC required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif else begin
          vdim = Get_VarSpatDim(supp_struct[SupVarIdx].dim)
          vdim_infile = size(rainc, /N_DIMENSIONS)
          if (vdim_infile ne vdim) then begin
            print, 'WARNING:: wrong dimensions for the variable ' + myVarName
            print, '          encountered in the input file'
            return, -1
          endif
        endelse

        tmp_id = Ncdf_GetData(fid, 'rainnc', rainnc, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable RAINNC required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif

        if (var_id lt 0) then begin
          print, 'WARNING:: can not calculate the variable: '+ myVarName
          goto, notFOUND
        endif

        vdata = rainc + rainnc
      end
    (myVarName eq 'RAIN'): $
      begin
        var_id = 1

        tmp_id = Ncdf_GetData(fid, 'raincv', raincv, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable RAINCV required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif else begin
          vdim = Get_VarSpatDim(supp_struct[SupVarIdx].dim)
          vdim_infile = size(raincv, /N_DIMENSIONS)
          if (vdim_infile ne vdim) then begin
            print, 'WARNING:: wrong dimensions for the variable ' + myVarName
            print, '          encountered in the input file'
            return, -1
          endif
        endelse

        tmp_id = Ncdf_GetData(fid, 'rainncv', rainncv, FILL_VAL = dfill)
        if (tmp_id lt 0) then begin
          print, 'WARNING:: the variable RAINNCV required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          var_id = tmp_id
        endif

        if (var_id lt 0) then begin
          print, 'WARNING:: can not calculate the variable: '+ myVarName
          goto, notFOUND
        endif

        Result = Ncdf_GetGlobal(fid, 'DT', dt) ; this is in seconds
        if (Result ge 1) then begin
          vdata = (3600.0 * (raincv + rainncv)) / float(dt)
        endif else begin
          print, 'WARNING:: the global variable DT required for the calculation of: ' + myVarName
          print, '          is not found in the input file'
          goto, notFOUND
        endelse
      end
  else: $
      begin
        var_id = Ncdf_GetData(fid, myVarName, vdata, FILL_VAL = dfill)
        if (var_id lt 0) then begin
          print, 'WARNING:: the requested variable '+ myVarName
          print, '          is not found in the input file'
          goto, notFOUND
        endif

        vdim = Get_VarSpatDim(supp_struct[SupVarIdx].dim)
        vdim_infile = size(vdata, /N_DIMENSIONS)
        if (vdim_infile ne vdim) then begin
          print, 'WARNING:: wrong dimensions for the variable ' + var_name
          print, '          encountered in the input file'
          return, -1
        endif

        if (n_elements(dfill) ne 0) then begin
          void = ChkForMask(vdata, dfill, MISS_IDX, count)
          if (count ne 0) then vdata[MISS_IDX] = !VALUES.F_NAN
        endif
      end
  endcase

  case 1 of
    (vdim eq 1): $
      begin
        undefine, vdata, vtitle, vunit, vdim, vrange, vdrange, vbdry, vclrtbl
        return, -1
      end
    (vdim eq 2):
    (vdim eq 3): $
      begin
        level = (n_elements(level) eq 0) ? 0 : fix(level[0])
        if (level lt 0) then $
          message, '<level> should be a positive integer'
        vdata = reform(vdata[*, *, level])
      end
    else: $
      begin
        undefine, vdata, vtitle, vunit, vdim, vrange, vdrange, vbdry, vclrtbl
        return, -1
      end
  endcase

  ; ----- Convert units for certain variables
  uinp = strtrim(supp_struct[SupVarIdx].uinp, 2)
  uout = strtrim(supp_struct[SupVarIdx].uout, 2)

  ; Convert temperatures from Kelvin to Celcius.
  if ( (strcmp(uinp, 'K', /FOLD_CASE) eq 1) and $
       (strcmp(uinp, uout, /FOLD_CASE) eq 0) ) then begin
    vdata = vdata - 273.16
  endif

  ; Convert pressures from Pa to mbar.
  if ( (strcmp(uinp, 'Pa', /FOLD_CASE) eq 1) and $
       (strcmp(uinp, uout, /FOLD_CASE) eq 0) ) then begin
    vdata = 0.01 * vdata
  endif
  ; -----

  notFOUND:

  vunit   = strtrim(supp_struct[SupVarIdx].uout, 2)

  vrange  = supp_struct[SupVarIdx].range

  vdrange = abs((supp_struct[SupVarIdx].drange)[0])

  vbdry    = [0, 0]
  vbdry[0] = fix((supp_struct[SupVarIdx].bdry)[0])
  vbdry[1] = fix((supp_struct[SupVarIdx].bdry)[1])
  vbdry[0] = (vbdry[0] ge 0) ? vbdry[0] : 0
  vbdry[1] = (vbdry[1] ge 0) ? vbdry[1] : 0

  vclrtbl = strtrim(supp_struct[SupVarIdx].ctbl, 2)
  vclow   = strtrim(supp_struct[SupVarIdx].clow, 2)
  vchigh  = strtrim(supp_struct[SupVarIdx].chigh, 2)
  vnlow   = fix(supp_struct[SupVarIdx].nlow)
  vnhigh  = fix(supp_struct[SupVarIdx].nhigh)
                              
  vtitle  = (vunit eq '') $
    ? strtrim(supp_struct[SupVarIdx].title, 2) $
    : strtrim(supp_struct[SupVarIdx].title, 2) + ' (' + vunit + ')'


  ; The level identification text
  lvtext = (n_elements(lvtext) ne 0) ? strtrim(lvtext[0], 2) : ''

  return, var_id
end
