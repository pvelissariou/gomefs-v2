FUNCTION Get_SupportedMapVar, fid, var_name, supp_struct, $
                              LEVEL   = level,   $
                              LVTEXT  = lvtext,  $
                              VDATA   = vdata,   $
                              VNAME   = vname,   $
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

  idx = (where(strcmp(supp_struct.nam, var_name, /FOLD_CASE) eq 1, count))[0]
  if (count eq 0) then begin
    print, 'WARNING:: the requested variable '+ var_name + ' is not supported.'
    return, -1
  endif

  var_id = Ncdf_GetData(fid, var_name, vdata, FILL_VAL = dfill)
  if (var_id lt 0) then begin
    print, 'WARNING:: the requested variable '+ var_name + ' is not found in the input file'
    print, '          in the input file'
    goto, notFOUND
  endif

  vdim = Get_VarSpatDim(supp_struct[idx].dim)
  vdim_infile = size(vdata, /N_DIMENSIONS)
  if (vdim_infile ne vdim) then begin
    print, 'WARNING:: wrong dimensions for the variable '+ var_name + ' encountered'
    print, '          in the input file'
    return, -1
  endif

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

  if (n_elements(dfill) ne 0) then begin
    void = ChkForMask(vdata, dfill, MISS_IDX, count)
    if (count ne 0) then vdata[MISS_IDX] = !VALUES.F_NAN
  endif

  notFOUND:

  vunit   = strcompress(supp_struct[idx].uout, /REMOVE_ALL)

  vrange  = supp_struct[idx].range

  vdrange = abs((supp_struct[idx].drange)[0])

  vbdry    = [0, 0]
  vbdry[0] = fix((supp_struct[idx].bdry)[0])
  vbdry[1] = fix((supp_struct[idx].bdry)[1])
  vbdry[0] = (vbdry[0] ge 0) ? vbdry[0] : 0
  vbdry[1] = (vbdry[1] ge 0) ? vbdry[1] : 0

  vclrtbl = strcompress(supp_struct[idx].ctbl, /REMOVE_ALL)
  vclow   = strtrim(supp_struct[idx].clow, 2)
  vchigh  = strtrim(supp_struct[idx].chigh, 2)
  vnlow   = fix(supp_struct[idx].nlow)
  vnhigh  = fix(supp_struct[idx].nhigh)
                              
  vtitle  = (vunit eq '') $
    ? strtrim(supp_struct[idx].title, 2) $
    : strtrim(supp_struct[idx].title, 2) + ' (' + vunit + ')'


  ; The level identification text
  lvtext = (n_elements(lvtext) ne 0) ? strtrim(lvtext[0], 2) : ''

  bot_vars = [ 'bustr', 'bvstr', 'bustrc', 'bvstrc', 'bustrw', 'bvstrw', $
               'bustrcwmax', 'bvstrcwmax', 'bstrcwmax', 'Ur', 'Vr', $
               'bhflux', 'bwflux', 'Pwave_bot', 'Uwave_rms', 'bed_porosity', $
               'bed_biodiff', 'bed_tau_crit', 'ripple_length', 'ripple_height', $
               'rdrag', 'rdrag2', 'ZoBot', 'Zo_def', 'Zo_app', 'Zo_Nik', 'Zo_bio', $
               'Zo_bedform', 'Zo_bedload', 'Zo_wbl', 'saltation', 'ubar_bstm', $
               'vbar_bstm', 'ubar_bstr', 'vbar_sstr', 'vbar_bstr', 'u_bstm', 'v_bstm', $
               'Ubot', 'Vbot', 'bedload_Usand', 'bedload_Umud', 'bedload_Vsand', $
               'bedload_Vmud', 'bed_inund_depth', 'ero_flux', 'dep_net', $
               'bed_thickness', 'bed_age', 'bed_wave_amp' ]
  idx = (where(strmatch(bot_vars, var_name, /FOLD_CASE) eq 1, count))[0]
  if (count ne 0) then lvtext = 'Bottom'

  int_vars = [ 'ubar', 'vbar', 'uWave', 'vWave', 'Sxx_bar', 'Sxy_bar', $
               'Syy_bar', 'ubar_WECstress', 'ubar_stokes', 'vbar_WECstress', $
               'vbar_stokes', 'ubar2', 'vbar2', 'rubar', 'rvbar', $
               'rufrc', 'rvfrc' ]
  idx = (where(strmatch(int_vars, var_name, /FOLD_CASE) eq 1, count))[0]
  if (count ne 0) then lvtext = ''

  return, var_id
end
