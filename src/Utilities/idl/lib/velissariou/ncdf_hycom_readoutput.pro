Pro Ncdf_Hycom_ReadOutput, fname, MASK = mask, LON_OUT = lon_out, LAT_OUT = lat_out
;+++
; NAME:
;	Ncdf_Hycom_ReadOutput
; VERSION:
;	1.0
; PURPOSE:
;	To read a bathymetric grid data file and return grid parameters
;       and depths.
;       Assumes that all variables are given at RHO points.
; CALLING SEQUENCE:
;	Ncdf_Hycom_ReadOutput, fname
;	On input:
;	   fname - Full pathway name of the bathymetry/grid data file
;	On output:
;	   All the ROMS output data found in the file
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created Tue Nov 13 2012 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  COMMON BathParams
  COMMON FlowParams

  ; Error handling.
  On_Error, 2

  Undefine_Hycom_Params, /FLOW

  miss_val = !VALUES.F_NAN

  ; check for the validity of the supplied values for "fname" or "lun"
  do_fname = N_Elements(fname) eq 0 ? 0 : 1
  If (do_fname) Then Begin
    If (Size(fname, /TNAME) ne 'STRING') Then $
      Message, "the name supplied for <fname> is not a valid string."

    fname = Strtrim(fname, 2)
    If (not readFILE(fname)) Then $
      Message, "can't read from the supplied file <" + fname + ">."
  EndIf

  do_mask = N_Elements(mask) eq 0 ? 0 : 1
  If (do_mask) Then Begin
    mask_dims = Size(mask, /DIMENSIONS)
    ; 1 = water point mask value
    ; 0 = land point mask value
    chk_msk = ChkForMask(mask, 1, idxWET, cntWET, $
                         COMPLEMENT = idxDRY, NCOMPLEMENT = cntDRY)
  EndIf

  ; Open and read the input NetCDF file
  ncid = ncdf_open(fname, /NOWRITE)
    ; ----- Required dimensions
    ; -----
    dnames = [ 'Y', 'Latitude', 'lat' ]
    dim_idx = Ncdf_GetDims(ncid, dnames, lat_dim)
    if (dim_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(dnames, ' ', /SINGLE) + ']'
      err_str = 'none of the requested dimensions(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; -----
    dnames = [ 'X', 'Longitude', 'lon' ]
    dim_idx = Ncdf_GetDims(ncid, dnames, lon_dim)
    if (dim_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(dnames, ' ', /SINGLE) + ']'
      err_str = 'none of the requested dimensions(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; -----
    dnames = [ 'Depth' ]
    dim_idx = Ncdf_GetDims(ncid, dnames, n_zdeps)
    if (dim_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(dnames, ' ', /SINGLE) + ']'
      err_str = 'none of the requested dimensions(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; -----
    dnames = [ 'MT', 'time' ]
    dim_idx = Ncdf_GetDims(ncid, dnames, nREC)
    if (dim_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(dnames, ' ', /SINGLE) + ']'
      err_str = 'none of the requested dimensions(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; ----- Required variables
    ; -----
    vnames = [ 'Latitude', 'lat' ]
    var_idx = Ncdf_GetData(ncid, vnames, lat_out)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; -----
    vnames = [ 'Longitude', 'lon' ]
    var_idx = Ncdf_GetData(ncid, vnames, lon_out)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif
    lon_out = ((lon_out + 180) MOD 360) - 180

    if ( (size(lon_out, /N_DIMENSIONS) eq 1) and $
         (size(lat_out, /N_DIMENSIONS) eq 1) ) then begin
      tmp_lon = make_array(lon_dim, lat_dim, TYPE = size(lon_out, /TYPE), VALUE = 0)
      tmp_lat = tmp_lon
      for icnt = 0L, lat_dim - 1 do tmp_lon[*, icnt] = lon_out[*]
      for icnt = 0L, lon_dim - 1 do tmp_lat[icnt, *] = lat_out[*]
      lon_out = tmp_lon
      lat_out = tmp_lat
    endif

    ; -----
    vnames = [ 'Depth' ]
    var_idx = Ncdf_GetData(ncid, vnames, zdeps, FILL_VAL = zdeps_fill, MISS_VAL = miss_val)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; -----
    vnames = [ 'MT', 'time' ]
    var_idx = Ncdf_GetData(ncid, vnames, MT, UNITS = RefTimeStr)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    ; ----- SSH
    vnames = [ 'ssh', 'surf_el' ]
    var_idx = Ncdf_GetData(ncid, vnames, ssh, FILL_VAL = ssh_fill, UNITS = ssh_units)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    mask_ok = 0
    if do_mask then begin
      temp_dims = size(ssh, /DIMENSIONS)
      if (array_equal(temp_dims[0:1], mask_dims) eq 1) then mask_ok = 1

      if (mask_ok ne 0) then begin
        if (n_elements(ssh_fill) ne 0) then begin
          chk_msk = ChkForMask(ssh, ssh_fill, idxNAN, cntNAN)
          if (cntNAN ne 0) then ssh[idxNAN] = miss_val
        endif
        ssh[idxDRY] = miss_val
      endif
    endif

    ; ----- U-VEL
    vnames = [ 'u', 'water_u' ]
    var_idx = Ncdf_GetData(ncid, vnames, uvel, FILL_VAL = uvel_fill, UNITS = uvel_units)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    mask_ok = 0
    if do_mask then begin
      temp_dims = size(uvel, /DIMENSIONS)
      if (array_equal(temp_dims[0:1], mask_dims) eq 1) then mask_ok = 1

      if (mask_ok ne 0) then begin
        for k = 0L, temp_dims[2] - 1 do begin
          scratch_arr = reform(uvel[*, *, k])

          if (n_elements(uvel_fill) ne 0) then begin
            chk_msk = ChkForMask(scratch_arr, uvel_fill, idxNAN, cntNAN)
            if (cntNAN ne 0) then scratch_arr[idxNAN] = miss_val
          endif
          scratch_arr[idxDRY] = miss_val
          uvel[*, *, k] = scratch_arr
        endfor
      endif
    endif

    ; ----- V-VEL
    vnames = [ 'v', 'water_v' ]
    var_idx = Ncdf_GetData(ncid, vnames, vvel, FILL_VAL = vvel_fill, UNITS = vvel_units)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    mask_ok = 0
    if do_mask then begin
      temp_dims = size(vvel, /DIMENSIONS)
      if (array_equal(temp_dims[0:1], mask_dims) eq 1) then mask_ok = 1

      if (mask_ok ne 0) then begin
        for k = 0L, temp_dims[2] - 1 do begin
          scratch_arr = reform(vvel[*, *, k])

          if (n_elements(vvel_fill) ne 0) then begin
            chk_msk = ChkForMask(scratch_arr, vvel_fill, idxNAN, cntNAN)
            if (cntNAN ne 0) then scratch_arr[idxNAN] = miss_val
          endif
          scratch_arr[idxDRY] = miss_val
          vvel[*, *, k] = scratch_arr
        endfor
      endif
    endif

    ; ----- TEMPERATURE
    vnames = [ 'temperature', 'water_temp' ]
    var_idx = Ncdf_GetData(ncid, vnames, temp, FILL_VAL = temp_fill, UNITS = temp_units)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif

    mask_ok = 0
    if do_mask then begin
      temp_dims = size(temp, /DIMENSIONS)
      if (array_equal(temp_dims[0:1], mask_dims) eq 1) then mask_ok = 1

      if (mask_ok ne 0) then begin
        for k = 0L, temp_dims[2] - 1 do begin
          scratch_arr = reform(temp[*, *, k])

          if (n_elements(temp_fill) ne 0) then begin
            chk_msk = ChkForMask(scratch_arr, temp_fill, idxNAN, cntNAN)
            if (cntNAN ne 0) then scratch_arr[idxNAN] = miss_val
          endif
          scratch_arr[idxDRY] = miss_val
          temp[*, *, k] = scratch_arr
        endfor
      endif
    endif

    ; ----- SALINITY
    vnames = [ 'salinity' ]
    var_idx = Ncdf_GetData(ncid, vnames, salt, FILL_VAL = salt_fill, UNITS = salt_units)
    if (var_idx lt 0) then begin
      ncdf_close, ncid
      err_str = '[' + strjoin(vnames, ' ', /SINGLE) + ']'
      err_str = 'none of the variable(s) ' + err_str + ' found in: '
      message, err_str + fname
    endif
    
    mask_ok = 0
    if do_mask then begin
      temp_dims = size(salt, /DIMENSIONS)
      if (array_equal(temp_dims[0:1], mask_dims) eq 1) then mask_ok = 1

      if (mask_ok ne 0) then begin
        for k = 0L, temp_dims[2] - 1 do begin
          scratch_arr = reform(salt[*, *, k])

          if (n_elements(salt_fill) ne 0) then begin
            chk_msk = ChkForMask(scratch_arr, salt_fill, idxNAN, cntNAN)
            if (cntNAN ne 0) then scratch_arr[idxNAN] = miss_val
          endif
          scratch_arr[idxDRY] = miss_val
          salt[*, *, k] = scratch_arr
        endfor
      endif
    endif
  ncdf_close, ncid
      
end
