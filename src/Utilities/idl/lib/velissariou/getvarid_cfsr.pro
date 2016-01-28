Function GetVarId_CFSR, fid, nVARS = nvars,     $
                        NAMES = names,          $
                        TAG = tag, DESC = desc, $
                        UNIT = unit, LEV = lev, $
                        FILLVAL = fillval,      $
                        FNAME = fname

on_error, 2

  numtypes = [2, 3, 12, 13, 14, 15]

  ;  PRES: Pressure (ground or at height above ground)
  ;   DPT: Dew Point Temperature (at height above ground)
  ;   TMP: Temperature (ground or at height above ground)
  ;   SPF: Specific Humidity (at height above ground)
  ; T_CDC: Total Cloud Cover  (Entire atmosphere)
  ; DSWRF: Downward Shortwave Radiation Flux (ground)
  ; DLWRF: Downward Longwave Radiation Flux (ground)
  ; LHTFL: Latent Heat Flux (ground)
  ; SHTFL: Sensible Heat Flux (ground)
  ; PRATE: Precipitation Rate/Flux (ground)
  ; U_GRD: Eastward Wind/U Component of Wind (Specified height above ground - value: 10 m)
  ; V_GRD: Northward Wind/V Component of Wind (Specified height above ground - value: 10 m)
  var_abrv = [ 'PRES', 'DPT', 'TMP', 'SPF', 'T_CDC', $
               'DSWRF', 'DLWRF', 'LHTFL', 'SHTFL', 'PRATE', $
               'U_GRD', 'V_GRD' $
             ]

  desc_tags = [ 'PAIR',             $
                'TDEW',             $
                'TAIR', 'SST',      $
                'QAIR',             $
                'CLOUD',            $
                'DSWRFL', 'DLWRFL', $
                'LHFL', 'SHFL',     $
                'RAIN',             $
                'UWIND', 'VWIND'    $
              ]

    
  nEXPS = n_elements(desc_tags)
  exps_struct = {id:-1L, tag:'', name:'', lev:'', desc:'', unit:'', fill:!VALUES.F_NAN}
  exps_array = replicate(exps_struct, nEXPS)

  num_val = where(numtypes eq size(fid, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<fid> should be an integer number."

  fid_info = ncdf_inquire(fid)

  var_count = 0L
  for var_id = 0, fid_info.Nvars - 1 do begin
    vinfo = ncdf_varinq(fid, var_id)
    undefine, var_exp, var_name, var_dsc, var_uni, var_lev, var_fil
    ; ----- Loop through the the variables
    for ivar = 0L, n_elements(var_abrv) - 1 do begin
      if (stregex(vinfo.name , '^' + var_abrv[ivar] + '.*', /FOLD_CASE) ge 0) then begin
        var_exp  = var_abrv[ivar]
        var_name = vinfo.name

        ; ----- Loop through the attributes of the variable
        for atid = 0, vinfo.Natts - 1 do begin
          attr_name = ncdf_attname(fid, var_id, atid)
          ncdf_attget, fid, var_id, attr_name, attr_val
          attr_info = ncdf_attinq(fid, var_id, attr_name)
          att_type = strupcase(attr_info.dataType)

          ; Strings are stored as byte values in attributes, so convert them back.
          if (size(attr_val, /TNAME) eq 'BYTE') and (att_type eq 'CHAR') then $
            attr_val = string(attr_val)

          case strupcase(attr_name) of
            'DESCRIPTION': begin
                             var_dsc = attr_val
                           end
          'STANDARD_NAME': begin
                             if (n_elements(var_dsc) ne 0) then $
                               print, 'GetVarId_CFSR: var_dsc already defined, replacing by standard_name'
                             var_dsc = attr_val
                           end
                  'UNITS': begin
                             var_uni = attr_val
                           end
                  'LEVEL': begin
                            var_lev = attr_val
                           end
             '_FILLVALUE': begin
                            var_fil = attr_val
                           end
                     else:
          endcase
        endfor ; atid

        ; ----- Required attributes are: 'LEVEL'
        if (n_elements(var_lev) eq 0) then begin
          message, 'attribute level not found in the input file for variable' + var_name
        endif

        exps_array[var_count].id = var_id
        exps_array[var_count].name = var_name
        exps_array[var_count].lev  = var_lev
        if (n_elements(var_dsc) ne 0) then exps_array[var_count].desc = var_dsc
        if (n_elements(var_uni) ne 0) then exps_array[var_count].unit = var_uni
        if (n_elements(var_fil) ne 0) then exps_array[var_count].fill = var_fil

        fname = ''
        case strupcase(var_exp) of
          'PRES': begin
                    if (stregex(var_lev , '^' + 'GROUND.*SURFACE' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'PAIR'
                      fname = strlowcase(exps_array[var_count].tag) + '_srf'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
           'DPT': begin
                    if (stregex(var_lev , '^' + 'SPECIFIED.*HEIGHT.*ABOVE.*2.*M' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'TDEW'
                      fname = strlowcase(exps_array[var_count].tag) + '_h2m'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
           'TMP': begin
                    if (stregex(var_lev , '^' + 'SPECIFIED.*HEIGHT.*ABOVE.*2.*M' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'TAIR'
                      fname = strlowcase(exps_array[var_count].tag) + '_h2m'
                    endif else begin
                      if (stregex(var_lev , '^' + 'GROUND.*SURFACE' + '.*', /FOLD_CASE) ge 0) then $
                        exps_array[var_count].tag  = 'SST'
                        fname = strlowcase(exps_array[var_count].tag)
                    endelse
                  end
           'SPF': begin
                    if (stregex(var_lev , '^' + 'SPECIFIED.*HEIGHT.*ABOVE.*2.*M' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'QAIR'
                      fname = strlowcase(exps_array[var_count].tag) + '_h2m'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
         'T_CDC': begin
                    if (stregex(var_lev , '^' + 'ENTIRE.*ATMOSPHERE' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'CLOUD'
                      fname = strlowcase(exps_array[var_count].tag) + '_tot'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
         'DSWRF': begin
                    if (stregex(var_lev , '^' + 'GROUND.*SURFACE' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'DSWRFL'
                      fname = strlowcase(exps_array[var_count].tag) + '_srf'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
         'DLWRF': begin
                    if (stregex(var_lev , '^' + 'GROUND.*SURFACE' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'DLWRFL'
                      fname = strlowcase(exps_array[var_count].tag) + '_srf'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
         'LHTFL': begin
                    if (stregex(var_lev , '^' + 'GROUND.*SURFACE' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'LHFL'
                      fname = strlowcase(exps_array[var_count].tag) + '_srf'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
         'SHTFL': begin
                    if (stregex(var_lev , '^' + 'GROUND.*SURFACE' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'SHFL'
                      fname = strlowcase(exps_array[var_count].tag) + '_srf'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
         'PRATE': begin
                    if (stregex(var_lev , '^' + 'GROUND.*SURFACE' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'RAIN'
                      fname = strlowcase(exps_array[var_count].tag) + '_srf'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
         'U_GRD': begin
                    if (stregex(var_lev , '^' + 'SPECIFIED.*HEIGHT.*ABOVE.*10.*M' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'UWIND'
                      fname = 'wind' + '_h10m'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
         'V_GRD': begin
                    if (stregex(var_lev , '^' + 'SPECIFIED.*HEIGHT.*ABOVE.*10.*M' + '.*', /FOLD_CASE) ge 0) then begin
                      exps_array[var_count].tag  = 'VWIND'
                      fname = 'wind' + '_h10m'
                    endif else begin
                      exps_array[var_count].tag  = ''
                      fname = ''
                    endelse
                  end
            else:
        endcase
        var_count++
        break
      endif ; vinfo.name
    endfor ; ivar
  endfor ; var_id

  idx = where(exps_array.id gt 0, count)
  if (count ne 0) then begin
    nvars   = count
    names   = exps_array[idx].name
    tag     = exps_array[idx].tag
    desc    = exps_array[idx].desc
    unit    = exps_array[idx].unit
    lev     = exps_array[idx].lev
    fillval = exps_array[idx].fill
    varids  = exps_array[idx].id
  endif else begin
    nvars   = 0
    name    = ''
    tag     = ''
    desc    = ''
    unit    = ''
    lev     = ''
    fillval = !VALUES.F_NAN
    fname   = ''
    varids  = -1
  endelse

  return, varids

end
