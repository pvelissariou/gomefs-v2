FUNCTION Ncdf_VarDef_GomRoms_CFSR, fname, tag, xi_rho, eta_rho, vid_arr, $
                                   REF_TIME = ref_time,         $
                                   FILL_VAL = fill_val,         $
                                   TITLE = title,               $
                                   TYPE = type,                 $
                                   SOURCE = source,             $
                                   CDL = cdl

  on_error, 2

  nParam = n_params()
  if (nParam ne 5) then message, 'Incorrect number of arguments.'

  numtypes = [2, 3, 12, 13, 14, 15]

  if ( size(fname, /TNAME) ne 'STRING' ) then $
    message, "<fname> should be a string."

  if ( size(tag, /TNAME) ne 'STRING' ) then $
    message, "<tag> should be a string."

  num_val = where(numtypes eq size(xi_rho, /TYPE))
  if ( num_val[0] eq -1 ) then $
    message, "<xi_rho> should be an integer number."

  num_val = where(numtypes eq size(eta_rho, /TYPE))
  if ( num_val[0] eq -1 ) then $
    message, "<eta_rho> should be an integer number."

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
  myTIME_NAME = 'time'

  vid_arr = make_array(n_elements(tag), /INTEGER, VALUE = -1)

  ncid = ncdf_create(fname, /CLOBBER)

    ncdf_control, ncid, /NOFILL
      ; ---------- define and set the dimensions
      did_xi_rho  = ncdf_dimdef(ncid, 'xi_rho',    xi_rho)
      did_xi_u    = ncdf_dimdef(ncid, 'xi_u',      xi_rho - 1)
      did_xi_v    = ncdf_dimdef(ncid, 'xi_v',      xi_rho)
      did_eta_rho = ncdf_dimdef(ncid, 'eta_rho',   eta_rho)
      did_eta_u   = ncdf_dimdef(ncid, 'eta_u',     eta_rho)
      did_eta_v   = ncdf_dimdef(ncid, 'eta_v',     eta_rho - 1)
      did_time    = ncdf_dimdef(ncid, myTIME_NAME, /UNLIMITED)

      ; ----- TIMES
      varid = ncdf_vardef(ncid, myTIME_NAME, did_time, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'atmospheric forcing time', /CHAR
      ncdf_attput, ncid, varid, 'units', 'days since ' + myREF_TIME, /CHAR
      ncdf_attput, ncid, varid, 'field', myTIME_NAME + ',' + ' scalar, series', /CHAR
      
      for itag = 0L, n_elements(tag) - 1 do begin
        case strupcase(strcompress(tag[itag], /REMOVE_ALL)) of
          'PAIR': begin
                   varid = ncdf_vardef(ncid, 'Pair', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'air pressure', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'surface air pressure', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'millibar', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'Pair, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
          'TDEW': begin
                   varid = ncdf_vardef(ncid, 'Tdew', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'dew-point temperature', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'surface dew-point temperature', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'Kelvin', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'Tdew, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
          'TAIR': begin
                   varid = ncdf_vardef(ncid, 'Tair', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'air temperature', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'surface air temperature', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'Celsius', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'Tair, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
           'SST': begin
                   varid = ncdf_vardef(ncid, 'SST', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'sea surface temperature', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'sea surface temperature', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'Celsius', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'SST, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
          'QAIR': begin
                   varid = ncdf_vardef(ncid, 'Qair', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'air relative humidity', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'surface air relative humidity', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'percentage', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'g/kg', /CHAR
                   ;ncdf_attput, ncid, varid, $
                   ;   'field', 'Qair, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
         'CLOUD': begin
                   varid = ncdf_vardef(ncid, 'cloud', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'cloud fraction', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'cloud fraction', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'nondimensional', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'cloud, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
        'DSWRFL': begin
                   varid = ncdf_vardef(ncid, 'swrad', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'solar shortwave radiation flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'solar shortwave radiation flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'Watts meter-2', /CHAR
                   ncdf_attput, ncid, varid, $
                      'positive_value', 'downward flux, heating', /CHAR
                   ncdf_attput, ncid, varid, $
                      'negative_value', 'upward flux, cooling', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'swrad, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
        'DLWRFL': begin
                   varid = ncdf_vardef(ncid, 'lwrad', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'net longwave radiation flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'net longwave radiation flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'Watts meter-2', /CHAR
                   ncdf_attput, ncid, varid, $
                      'positive_value', 'downward flux, heating', /CHAR
                   ncdf_attput, ncid, varid, $
                      'negative_value', 'upward flux, cooling', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'lwrad, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
          'LHFL': begin
                   varid = ncdf_vardef(ncid, 'latent', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'net latent heat flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'net latent heat flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'Watts meter-2', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'latent heat flux, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
          'SHFL': begin
                   varid = ncdf_vardef(ncid, 'sensible', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'net sensible heat flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'net sensible heat flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'Watts meter-2', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'sensible heat flux, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
          'RAIN': begin
                   varid = ncdf_vardef(ncid, 'rain', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'rain fall rate', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'rain fall rate', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'kilogram meter-2 second-1', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'rain, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
         'UWIND': begin
                   varid = ncdf_vardef(ncid, 'Uwind', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'surface u-wind component', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'surface u-wind component', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'meter second-1', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'u-wind, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
         'VWIND': begin
                   varid = ncdf_vardef(ncid, 'Vwind', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'surface v-wind component', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'surface v-wind component', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'meter second-1', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'v-wind, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
        'SSFLUX': begin
                   varid = ncdf_vardef(ncid, 'ssflux', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'surface net salt flux, (E-P)*SALT', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'surface net salt flux, (E-P)*SALT', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'meter second-1', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'surface net salt flux, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
        'SHFLUX': begin
                   varid = ncdf_vardef(ncid, 'shflux', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'surface net heat flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'surface net heat flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'Watts meter-2', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'surface net heat flux, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
        'SWFLUX': begin
                   varid = ncdf_vardef(ncid, 'swflux', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'surface net freswater flux, (E-P)', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'surface net freswater flux, (E-P)', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'centimeter day-1', /CHAR
                   ncdf_attput, ncid, varid, $
                      'positive_value', 'net evaporation', /CHAR
                   ncdf_attput, ncid, varid, $
                      'negative_value', 'net precipitation', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'surface net salt flux, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
        'BHFLUX': begin
                   varid = ncdf_vardef(ncid, 'bhflux', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'bottom net heat flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'bottom net heat flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'Watts meter-2', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'bottom heat flux, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
        'BWFLUX': begin
                   varid = ncdf_vardef(ncid, 'bwflux', [did_xi_rho, did_eta_rho, did_time], /FLOAT)
                   vid_arr[itag] = varid
                   ncdf_attput, ncid, varid, $
                      'standard_name', 'bottom net freshwater flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'long_name', 'bottom net freshwater flux', /CHAR
                   ncdf_attput, ncid, varid, $
                      'units', 'centimeter day-1', /CHAR
                   ncdf_attput, ncid, varid, $
                      'field', 'bottom water flux, scalar, series', /CHAR
                   ncdf_attput, ncid, varid, $
                      'time', myTIME_NAME, /CHAR
                   if (n_elements(fill_val) ne 0) then $
                     ncdf_attput, ncid, varid, '_FillValue', fill_val, /FLOAT
                  end
            else: begin
                   msg_str = 'PAIR, TDEW, TAIR, SST, QAIR, CLOUD, DSWRFL, DLWRFL, LHFL, SHFL, RAIN,'
                   msg_str = msg_str + ' UWIND, VWIND, SHFLUX, SWFLUX, BHFLUX, BWFLUX'
                   message, 'tag should be one or more of: ' + msg_str
                  end
        endcase
      endfor ; itag

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
