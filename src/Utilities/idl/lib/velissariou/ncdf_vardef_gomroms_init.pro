FUNCTION Ncdf_VarDef_GomRoms_Init, fname, xi_rho, eta_rho, s_rho, $
                                   REF_TIME = ref_time,           $
                                   FILL_VAL = fill_val,           $
                                   TITLE = title,                 $
                                   TYPE = type,                   $
                                   SOURCE = source,               $
                                   CDL = cdl

  on_error, 2

  numtypes = [2, 3, 12, 13, 14, 15]

  if ( size(fname, /TNAME) ne 'STRING' ) then $
    message, "<fname> should be a string."

  num_val = where(numtypes eq size(xi_rho, /TYPE))
  if ( num_val[0] eq -1 ) then $
    message, "<xi_rho> should be an integer number."

  num_val = where(numtypes eq size(eta_rho, /TYPE))
  if ( num_val[0] eq -1 ) then $
    message, "<eta_rho> should be an integer number."

  num_val = where(numtypes eq size(s_rho, /TYPE))
  if ( num_val[0] eq -1 ) then $
    message, "<s_rho> should be an integer number."

  myREF_TIME = '0000-01-01 00:00:00'
  if (n_elements(ref_time) gt 0) then begin
    if ( size(ref_time[0], /TNAME) ne 'STRING' ) then $
      message, "<ref_time> a scalar string variable."
    myREF_TIME = strtrim(ref_time[0], 2)
  endif

  if (n_elements(fill_val) gt 0) then begin
    numtypes = [2, 3, 4, 5, 12, 13, 14, 15]
    num_val = where(numtypes eq size(fill_val, /TYPE))
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
  myTIME_NAME = 'ocean_time'

  ncid = ncdf_create(fname, /CLOBBER)

    ncdf_control, ncid, /NOFILL
      ; ---------- define and set the dimensions
      did_xi_rho  = ncdf_dimdef(ncid, 'xi_rho',    xi_rho)
      did_xi_u    = ncdf_dimdef(ncid, 'xi_u',      xi_rho - 1)
      did_xi_v    = ncdf_dimdef(ncid, 'xi_v',      xi_rho)
      did_eta_rho = ncdf_dimdef(ncid, 'eta_rho',   eta_rho)
      did_eta_u   = ncdf_dimdef(ncid, 'eta_u',     eta_rho)
      did_eta_v   = ncdf_dimdef(ncid, 'eta_v',     eta_rho - 1)
      did_s_rho   = ncdf_dimdef(ncid, 's_rho',     s_rho)
      did_s_w     = ncdf_dimdef(ncid, 's_w',       s_rho + 1)
      did_tracer  = ncdf_dimdef(ncid, 'tracer',    2)
      did_time    = ncdf_dimdef(ncid, myTIME_NAME, /UNLIMITED)

      ; ---------- define the variables
      varid = ncdf_vardef(ncid, 'spherical', /LONG)
      ncdf_attput, ncid, varid, 'long_name', 'grid type logical switch', /CHAR
      ncdf_attput, ncid, varid, 'flag_values', '0, 1', /CHAR
      ncdf_attput, ncid, varid, 'flag_meanings', 'Cartesian spherical', /CHAR

      varid = ncdf_vardef(ncid, 'Vtransform', /LONG)
      ncdf_attput, ncid, varid, 'long_name', 'vertical terrain-following transformation equation', /CHAR

      varid = ncdf_vardef(ncid, 'Vstretching', /LONG)
      ncdf_attput, ncid, varid, 'long_name', 'vertical terrain-following stretching function', /CHAR

      varid = ncdf_vardef(ncid, 'theta_s', /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'S-coordinate surface control parameter', /CHAR

      varid = ncdf_vardef(ncid, 'theta_b', /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'S-coordinate bottom control parameter', /CHAR

      varid = ncdf_vardef(ncid, 'Tcline', /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'S-coordinate surface/bottom layer width', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR

      varid = ncdf_vardef(ncid, 's_rho', did_s_rho, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'S-coordinate at RHO-points', /CHAR
      ncdf_attput, ncid, varid, 'valid_min', -1.0, /DOUBLE
      ncdf_attput, ncid, varid, 'valid_max',  0.0, /DOUBLE
      ncdf_attput, ncid, varid, 'positive',  'up', /CHAR
      ncdf_attput, ncid, varid, 'standard_name',  'ocean_s_coordinate_g1', /CHAR
      ncdf_attput, ncid, varid, 'formula_terms', 's: s_rho C: Cs_r eta: zeta depth: h depth_c: hc', /CHAR
      ncdf_attput, ncid, varid, 'field', 's_rho, scalar', /CHAR

      varid = ncdf_vardef(ncid, 's_w', did_s_w, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'S-coordinate at W-points'
      ncdf_attput, ncid, varid, 'valid_min', -1.0, /DOUBLE
      ncdf_attput, ncid, varid, 'valid_max',  0.0, /DOUBLE
      ncdf_attput, ncid, varid, 'positive',  'up', /CHAR
      ncdf_attput, ncid, varid, 'standard_name',  'ocean_s_coordinate_g1', /CHAR
      ncdf_attput, ncid, varid, 'formula_terms', 's: s_w C: Cs_w eta: zeta depth: h depth_c: hc', /CHAR
      ncdf_attput, ncid, varid, 'field', 's_w, scalar', /CHAR

      varid = ncdf_vardef(ncid, 'Cs_r', did_s_rho, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'S-coordinate stretching curves at RHO-points'
      ncdf_attput, ncid, varid, 'valid_min', -1.0, /DOUBLE
      ncdf_attput, ncid, varid, 'valid_max',  0.0, /DOUBLE
      ncdf_attput, ncid, varid, 'field', 'Cs_r, scalar', /CHAR

      varid = ncdf_vardef(ncid, 'Cs_w', did_s_w, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'S-coordinate stretching curves at W-points'
      ncdf_attput, ncid, varid, 'valid_min', -1.0, /DOUBLE
      ncdf_attput, ncid, varid, 'valid_max',  0.0, /DOUBLE
      ncdf_attput, ncid, varid, 'field', 'Cs_w, scalar', /CHAR

      ; ----- TIMES
      varid = ncdf_vardef(ncid, myTIME_NAME, did_time, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'time for climatology data', /CHAR
      ncdf_attput, ncid, varid, 'units', 'days since ' + myREF_TIME, /CHAR
      ncdf_attput, ncid, varid, 'field', myTIME_NAME + ',' + ' scalar, series', /CHAR

      ; ----- ZETA
      varid = ncdf_vardef(ncid, 'zeta', [did_xi_rho, did_eta_rho, did_time], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'free surface climatology', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'field', 'free-surface, scalar, series', /CHAR
      ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
      if (n_elements(fill_val) ne 0) then $
        ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE

      varid = ncdf_vardef(ncid, 'ubar', [did_xi_u, did_eta_u, did_time], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'vertically integrated u-momentum component climatology', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter second-1', /CHAR
      ncdf_attput, ncid, varid, 'field', 'ubar-velocity, scalar, series', /CHAR
      ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
      if (n_elements(fill_val) ne 0) then $
        ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE

      varid = ncdf_vardef(ncid, 'vbar', [did_xi_v, did_eta_v, did_time], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'vertically integrated v-momentum component climatology', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter second-1', /CHAR
      ncdf_attput, ncid, varid, 'field', 'vbar-velocity, scalar, series', /CHAR
      ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
      if (n_elements(fill_val) ne 0) then $
        ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE

      varid = ncdf_vardef(ncid, 'u', [did_xi_u, did_eta_u, did_s_rho, did_time], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'u-momentum component climatology', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter second-1', /CHAR
      ncdf_attput, ncid, varid, 'field', 'u-velocity, scalar, series', /CHAR
      ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
      if (n_elements(fill_val) ne 0) then $
        ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE

      varid = ncdf_vardef(ncid, 'v', [did_xi_v, did_eta_v, did_s_rho, did_time], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'v-momentum component climatology', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter second-1', /CHAR
      ncdf_attput, ncid, varid, 'field', 'v-velocity, scalar, series', /CHAR
      ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
      if (n_elements(fill_val) ne 0) then $
        ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE

      varid = ncdf_vardef(ncid, 'temp', [did_xi_rho, did_eta_rho, did_s_rho, did_time], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'potential temperature climatology', /CHAR
      ncdf_attput, ncid, varid, 'units', 'Celsius', /CHAR
      ncdf_attput, ncid, varid, 'field', 'temperature, scalar, series', /CHAR
      ncdf_attput, ncid, varid, 'time', myTIME_NAME
      if (n_elements(fill_val) ne 0) then $
        ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE

      varid = ncdf_vardef(ncid, 'salt', [did_xi_rho, did_eta_rho, did_s_rho, did_time], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'salinity climatology', /CHAR
      ncdf_attput, ncid, varid, 'units', 'PSU', /CHAR
      ncdf_attput, ncid, varid, 'field', 'salinity, scalar, series', /CHAR
      ncdf_attput, ncid, varid, 'time', myTIME_NAME, /CHAR
      if (n_elements(fill_val) ne 0) then $
        ncdf_attput, ncid, varid, '_FillValue', fill_val, /DOUBLE

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
