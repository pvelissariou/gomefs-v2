FUNCTION Ncdf_VarDef_GomRoms_Bry, fname, xi_rho, eta_rho, s_rho, $
                                  boundaries,                    $
                                  REF_TIME   = ref_time,         $
                                  ZETA_TIME  = zeta_time,        $
                                  UVBAR_TIME = uvbar_time,       $
                                  UV3D_TIME  = uv3d_time,        $
                                  TEMP_TIME  = temp_time,        $
                                  SALT_TIME  = salt_time,        $
                                  FILL_VAL   = fill_val,         $
                                  TITLE = title,                 $
                                  TYPE = type,                   $
                                  SOURCE = source,               $
                                  CDL = cdl

  on_error, 2

  numtypes = [2, 3, 12, 13, 14, 15]

  if ( size(fname, /TNAME) ne 'STRING' ) then $
    message, "<fname> should be a string."

  num_val = where(numtypes eq size(xi_rho, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<xi_rho> should be an integer number."

  num_val = where(numtypes eq size(eta_rho, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<eta_rho> should be an integer number."

  num_val = where(numtypes eq size(s_rho, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<s_rho> should be an integer number."

  numtypes = [2, 3, 12, 13, 14, 15]
  num_val = where(numtypes eq size(boundaries, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<boundaries> should be a 4-element vector of integer numbers."

  myREF_TIME = '0000-01-01 00:00:00'
  if (n_elements(ref_time) gt 0) then begin
    if ( size(ref_time[0], /TNAME) ne 'STRING' ) then $
      message, "<ref_time> a scalar string variable."
    myREF_TIME = strtrim(ref_time[0], 2)
  endif

  if (n_elements(fill_val) gt 0) then begin
    numtypes = [2, 3, 4, 5, 12, 13, 14, 15]
    num_val = where(numtypes eq size(fill_val, /type))
    if ( num_val[0] eq -1 ) then $
      message, "<fill_val> should be a number."
  endif

  ; Error handling.
  catch, theERR
  if theERR ne 0 then begin
     catch, /cancel
     help, /LAST_MESSAGE
     return, theERR
  endif

  failure = 0

  ; default values
  varid = - 1
  myTIME_NAME = 'bry_time'

  ncid = ncdf_create(fname, /CLOBBER)

    ncdf_control, ncid, /FILL
      ; ---------- define and set the dimensions
      did_xi_rho     = ncdf_dimdef(ncid, 'xi_rho',    xi_rho)
      did_xi_u       = ncdf_dimdef(ncid, 'xi_u',      xi_rho - 1)
      did_xi_v       = ncdf_dimdef(ncid, 'xi_v',      xi_rho)
      did_eta_rho    = ncdf_dimdef(ncid, 'eta_rho',   eta_rho)
      did_eta_u      = ncdf_dimdef(ncid, 'eta_u',     eta_rho)
      did_eta_v      = ncdf_dimdef(ncid, 'eta_v',     eta_rho - 1)
      did_s_rho      = ncdf_dimdef(ncid, 's_rho',     s_rho)
      did_time       = ncdf_dimdef(ncid, myTIME_NAME, /UNLIMITED)
      did_zeta_time  = did_time
      did_uvbar_time = did_time
      did_uv3d_time  = did_time
      did_temp_time  = did_time
      did_salt_time  = did_time

      if (n_elements(zeta_time) ne 0) then $
        did_zeta_time = ncdf_dimdef(ncid, 'zeta_time', zeta_time)
      if (n_elements(uvbar_time) ne 0) then $
        did_uvbar_time = ncdf_dimdef(ncid, 'v2d_time', uvbar_time)
      if (n_elements(uv3d_time) ne 0) then $
        did_uv3d_time = ncdf_dimdef(ncid, 'v3d_time', uv3d_time)
      if (n_elements(temp_time) ne 0) then $
        did_temp_time = ncdf_dimdef(ncid, 'temp_time', temp_time)
      if (n_elements(salt_time) ne 0) then $
        did_salt_time = ncdf_dimdef(ncid, 'salt_time', salt_time)

      ; ---------- define the variables
      ; ----- TIMES
      varid = ncdf_vardef(ncid, myTIME_NAME, did_time, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'open boundary conditions time', /CHAR
      ncdf_attput, ncid, varid, 'units', 'days since ' + myREF_TIME, /CHAR
      ncdf_attput, ncid, varid, 'field', myTIME_NAME + ',' + ' scalar, series', /CHAR

      varid = ncdf_vardef(ncid, 'zeta_time', did_zeta_time, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'time for free surface OBC', /CHAR
      ncdf_attput, ncid, varid, 'units', 'days since ' + myREF_TIME, /CHAR
      ncdf_attput, ncid, varid, 'field', 'zeta_time, scalar, series', /CHAR

      varid = ncdf_vardef(ncid, 'v2d_time', did_uvbar_time, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'time for 2D momentum OBC', /CHAR
      ncdf_attput, ncid, varid, 'units', 'days since ' + myREF_TIME, /CHAR
      ncdf_attput, ncid, varid, 'field', 'v2d_time, scalar, series', /CHAR

      varid = ncdf_vardef(ncid, 'v3d_time', did_uv3d_time, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'time for 3D momentum OBC', /CHAR
      ncdf_attput, ncid, varid, 'units', 'days since ' + myREF_TIME, /CHAR
      ncdf_attput, ncid, varid, 'field', 'v3d_time, scalar, series', /CHAR

      varid = ncdf_vardef(ncid, 'temp_time', did_temp_time, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'time for temperature OBC', /CHAR
      ncdf_attput, ncid, varid, 'units', 'days since ' + myREF_TIME, /CHAR
      ncdf_attput, ncid, varid, 'field', 'temp_time, scalar, series', /CHAR

      varid = ncdf_vardef(ncid, 'salt_time', did_salt_time, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'time for salinity OBC', /CHAR
      ncdf_attput, ncid, varid, 'units', 'days since ' + myREF_TIME, /CHAR
      ncdf_attput, ncid, varid, 'field', 'salt_time, scalar, series', /CHAR

      ; ----- ZETA
      for i = 0, 3 do begin
        if (boundaries[i] gt 0) then begin
          if (i eq 0) then begin
            tmp_var = 'zeta_west'
            tmp_nam = 'free-surface western boundary condition'
            tmp_dim = [did_eta_rho, did_zeta_time]
          endif
          if (i eq 1) then begin
            tmp_var = 'zeta_south'
            tmp_nam = 'free-surface southern boundary condition'
            tmp_dim = [did_xi_rho, did_zeta_time]
          endif
          if (i eq 2) then begin
            tmp_var = 'zeta_east'
            tmp_nam = 'free-surface eastern boundary condition'
            tmp_dim = [did_eta_rho, did_zeta_time]
          endif
          if (i eq 3) then begin
            tmp_var = 'zeta_north'
            tmp_nam = 'free-surface northern boundary condition'
            tmp_dim = [did_xi_rho, did_zeta_time]
          endif
          varid = ncdf_vardef(ncid, tmp_var, tmp_dim, /DOUBLE)
          ncdf_attput, ncid, varid, 'long_name', tmp_nam, /CHAR
          ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
          ncdf_attput, ncid, varid, 'field', tmp_var + ', scalar, series', /CHAR
          ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
          if (n_elements(fill_val) ne 0) then $
            ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE
        endif
      endfor

      ; ----- UBAR
      for i = 0, 3 do begin
        if (boundaries[i] gt 0) then begin
          if (i eq 0) then begin
            tmp_var = 'ubar_west'
            tmp_nam = '2D u-momentum western boundary condition'
            tmp_dim = [did_eta_u, did_uvbar_time]
          endif
          if (i eq 1) then begin
            tmp_var = 'ubar_south'
            tmp_nam = '2D u-momentum southern boundary condition'
            tmp_dim = [did_xi_u, did_uvbar_time]
          endif
          if (i eq 2) then begin
            tmp_var = 'ubar_east'
            tmp_nam = '2D u-momentum eastern boundary condition'
            tmp_dim = [did_eta_u, did_uvbar_time]
          endif
          if (i eq 3) then begin
            tmp_var = 'ubar_north'
            tmp_nam = '2D u-momentum northern boundary condition'
            tmp_dim = [did_xi_u, did_uvbar_time]
          endif
          varid = ncdf_vardef(ncid, tmp_var, tmp_dim, /DOUBLE)
          ncdf_attput, ncid, varid, 'long_name', tmp_nam, /CHAR
          ncdf_attput, ncid, varid, 'units', 'meter second-1', /CHAR
          ncdf_attput, ncid, varid, 'field', tmp_var + ', scalar, series', /CHAR
          ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
          if (n_elements(fill_val) ne 0) then $
            ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE
        endif
      endfor

      ; ----- VBAR
      for i = 0, 3 do begin
        if (boundaries[i] gt 0) then begin
          if (i eq 0) then begin
            tmp_var = 'vbar_west'
            tmp_nam = '2D v-momentum western boundary condition'
            tmp_dim = [did_eta_v, did_uvbar_time]
          endif
          if (i eq 1) then begin
            tmp_var = 'vbar_south'
            tmp_nam = '2D v-momentum southern boundary condition'
            tmp_dim = [did_xi_v, did_uvbar_time]
          endif
          if (i eq 2) then begin
            tmp_var = 'vbar_east'
            tmp_nam = '2D v-momentum eastern boundary condition'
            tmp_dim = [did_eta_v, did_uvbar_time]
          endif
          if (i eq 3) then begin
            tmp_var = 'vbar_north'
            tmp_nam = '2D v-momentum northern boundary condition'
            tmp_dim = [did_xi_v, did_uvbar_time]
          endif
          varid = ncdf_vardef(ncid, tmp_var, tmp_dim, /DOUBLE)
          ncdf_attput, ncid, varid, 'long_name', tmp_nam, /CHAR
          ncdf_attput, ncid, varid, 'units', 'meter second-1', /CHAR
          ncdf_attput, ncid, varid, 'field', tmp_var + ', scalar, series', /CHAR
          ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
          if (n_elements(fill_val) ne 0) then $
            ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE
        endif
      endfor

      ; ----- U-VEL
      for i = 0, 3 do begin
        if (boundaries[i] gt 0) then begin
          if (i eq 0) then begin
            tmp_var = 'u_west'
            tmp_nam = '3D u-momentum western boundary condition'
            tmp_dim = [did_eta_u, did_s_rho, did_uv3d_time]
          endif
          if (i eq 1) then begin
            tmp_var = 'u_south'
            tmp_nam = '3D u-momentum southern boundary condition'
            tmp_dim = [did_xi_u, did_s_rho, did_uv3d_time]
          endif
          if (i eq 2) then begin
            tmp_var = 'u_east'
            tmp_nam = '3D u-momentum eastern boundary condition'
            tmp_dim = [did_eta_u, did_s_rho, did_uv3d_time]
          endif
          if (i eq 3) then begin
            tmp_var = 'u_north'
            tmp_nam = '3D u-momentum northern boundary condition'
            tmp_dim = [did_xi_u, did_s_rho, did_uv3d_time]
          endif
          varid = ncdf_vardef(ncid, tmp_var, tmp_dim, /DOUBLE)
          ncdf_attput, ncid, varid, 'long_name', tmp_nam, /CHAR
          ncdf_attput, ncid, varid, 'units', 'meter second-1', /CHAR
          ncdf_attput, ncid, varid, 'field', tmp_var + ', scalar, series', /CHAR
          ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
          if (n_elements(fill_val) ne 0) then $
            ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE
        endif
      endfor

      ; ----- V-VEL
      for i = 0, 3 do begin
        if (boundaries[i] gt 0) then begin
          if (i eq 0) then begin
            tmp_var = 'v_west'
            tmp_nam = '3D v-momentum western boundary condition'
            tmp_dim = [did_eta_v, did_s_rho, did_uv3d_time]
          endif
          if (i eq 1) then begin
            tmp_var = 'v_south'
            tmp_nam = '3D v-momentum southern boundary condition'
            tmp_dim = [did_xi_v, did_s_rho, did_uv3d_time]
          endif
          if (i eq 2) then begin
            tmp_var = 'v_east'
            tmp_nam = '3D v-momentum eastern boundary condition'
            tmp_dim = [did_eta_v, did_s_rho, did_uv3d_time]
          endif
          if (i eq 3) then begin
            tmp_var = 'v_north'
            tmp_nam = '3D v-momentum northern boundary condition'
            tmp_dim = [did_xi_v, did_s_rho, did_uv3d_time]
          endif
          varid = ncdf_vardef(ncid, tmp_var, tmp_dim, /DOUBLE)
          ncdf_attput, ncid, varid, 'long_name', tmp_nam, /CHAR
          ncdf_attput, ncid, varid, 'units', 'meter second-1', /CHAR
          ncdf_attput, ncid, varid, 'field', tmp_var + ', scalar, series', /CHAR
          ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
          if (n_elements(fill_val) ne 0) then $
            ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE
        endif
      endfor

      ; ----- TEMP
      for i = 0, 3 do begin
        if (boundaries[i] gt 0) then begin
          if (i eq 0) then begin
            tmp_var = 'temp_west'
            tmp_nam = 'potential temperature western boundary condition'
            tmp_dim = [did_eta_rho, did_s_rho, did_temp_time]
          endif
          if (i eq 1) then begin
            tmp_var = 'temp_south'
            tmp_nam = 'potential temperature southern boundary condition'
            tmp_dim = [did_xi_rho, did_s_rho, did_temp_time]
          endif
          if (i eq 2) then begin
            tmp_var = 'temp_east'
            tmp_nam = 'potential temperature eastern boundary condition'
            tmp_dim = [did_eta_rho, did_s_rho, did_temp_time]
          endif
          if (i eq 3) then begin
            tmp_var = 'temp_north'
            tmp_nam = 'potential temperature northern boundary condition'
            tmp_dim = [did_xi_rho, did_s_rho, did_temp_time]
          endif
          varid = ncdf_vardef(ncid, tmp_var, tmp_dim, /DOUBLE)
          ncdf_attput, ncid, varid, 'long_name', tmp_nam, /CHAR
          ncdf_attput, ncid, varid, 'units', 'Celsius', /CHAR
          ncdf_attput, ncid, varid, 'field', tmp_var + ', scalar, series', /CHAR
          ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
          if (n_elements(fill_val) ne 0) then $
            ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE
        endif
      endfor

      ; ----- SALINITY
      for i = 0, 3 do begin
        if (boundaries[i] gt 0) then begin
          if (i eq 0) then begin
            tmp_var = 'salt_west'
            tmp_nam = 'salinity western boundary condition'
            tmp_dim = [did_eta_rho, did_s_rho, did_salt_time]
          endif
          if (i eq 1) then begin
            tmp_var = 'salt_south'
            tmp_nam = 'salinity southern boundary condition'
            tmp_dim = [did_xi_rho, did_s_rho, did_salt_time]
          endif
          if (i eq 2) then begin
            tmp_var = 'salt_east'
            tmp_nam = 'salinity eastern boundary condition'
            tmp_dim = [did_eta_rho, did_s_rho, did_salt_time]
          endif
          if (i eq 3) then begin
            tmp_var = 'salt_north'
            tmp_nam = 'salinity northern boundary condition'
            tmp_dim = [did_xi_rho, did_s_rho, did_salt_time]
          endif
          varid = ncdf_vardef(ncid, tmp_var, tmp_dim, /DOUBLE)
          ncdf_attput, ncid, varid, 'long_name', tmp_nam, /CHAR
          ncdf_attput, ncid, varid, 'units', 'PSU', /CHAR
          ncdf_attput, ncid, varid, 'field', tmp_var + ', scalar, series', /CHAR
          ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
          if (n_elements(fill_val) ne 0) then $
            ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE
        endif
      endfor

      ; ---------- define the GLOBAL variables
      Ncdf_PutGlobal, ncid, 'Conventions', 'CF-1.1'
      if (n_elements(title) ne 0) then $
        Ncdf_PutGlobal, ncid, 'title', strtrim(string(title), 2)
      if (n_elements(type) ne 0) then $
        Ncdf_PutGlobal, ncid, 'type', strtrim(string(type), 2)

      Ncdf_PutGlobal, ncid, 'institution', string(10B) + CoapsAddress()
      Ncdf_PutGlobal, ncid, 'contact', 'pvelissariou@fsu.edu'

      if (n_elements(source) ne 0) then $
        Ncdf_PutGlobal, ncid, 'source', strtrim(string(source), 2)

      Ncdf_PutGlobal_Devel, ncid
    ncdf_control, ncid, /ENDEF

  ncdf_close, ncid

  if (keyword_set(cdl) eq 1) then begin
    len = (0 > strpos(fname, '.', /REVERSE_SEARCH))
    if (len eq 0) then len = strlen(fname)
    
    cdl_file = strmid(fname, 0, len) + '.cdl'
    
    exe_cmd = 'ncdump -h ' + fname + ' > ' + cdl_file
    failure = Spawn_Cmd(exe_cmd)

    if (failure eq 0) then begin
      exe_cmd = 'ncgen -b -o ' + fname + ' ' + cdl_file
      failure = Spawn_Cmd(exe_cmd)
    endif

    file_delete, cdl_file, /ALLOW_NONEXISTENT
  endif

  return, failure
end
