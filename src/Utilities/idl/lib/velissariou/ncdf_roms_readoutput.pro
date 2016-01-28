Pro Ncdf_Roms_ReadOutput, fname
;+++
; NAME:
;	Ncdf_Roms_ReadOutput
; VERSION:
;	1.0
; PURPOSE:
;	To read a bathymetric grid data file and return grid parameters
;       and depths.
; CALLING SEQUENCE:
;	Ncdf_Roms_ReadOutput, fname
;	On input:
;	   fname - Full pathway name of the bathymetry/grid data file
;	On output:
;	   All the ROMS output data found in the file
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created April 22 2011 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  COMMON BathParams
  COMMON FlowParams

  ; Error handling.
  On_Error, 2

  Undefine_Roms_Params, /FLOW

  ; check for the validity of the supplied values for "fname" or "lun"
  do_fname = N_Elements(fname) eq 0 ? 0 : 1
  If (do_fname) Then Begin
    If (Size(fname, /TNAME) ne 'STRING') Then $
      Message, "the name supplied for <fname> is not a valid string."

    fname = Strtrim(fname, 2)
    If (not readFILE(fname)) Then $
      Message, "can't read from the supplied file <" + fname + ">."
  EndIf

  ; Open and read the input NetCDF file
  ncid = ncdf_open(fname, /NOWRITE)

    ; ----- Required dimensions
    ncdf_diminq, ncid, ncdf_dimid(ncid, 's_rho'),  nm, n_s_rho
      if (strcmp(nm, 's_rho') ne 1) then $
        message, 's_rho dimension is not defined in: ' + fname

    ncdf_diminq, ncid, ncdf_dimid(ncid, 's_w'),  nm, n_s_w
      if (strcmp(nm, 's_w') ne 1) then $
        message, 's_w dimension is not defined in: ' + fname

    ; ----- Required variables
    varid = ncdf_varid(ncid, 'ocean_time')
    ncdf_varget, ncid, varid, ocean_time
    ncdf_attget, ncid, varid, 'units', RefTimeStr
    RefTimeStr = string(RefTimeStr)

    varid = ncdf_varid(ncid, 'Vtransform')
    ncdf_varget, ncid, varid, Vtransform

    varid = ncdf_varid(ncid, 'Vstretching')
    ncdf_varget, ncid, varid, Vstretching

    varid = ncdf_varid(ncid, 'theta_s')
    ncdf_varget, ncid, varid, theta_s

    varid = ncdf_varid(ncid, 'theta_b')
    ncdf_varget, ncid, varid, theta_b

    varid = ncdf_varid(ncid, 'Tcline')
    ncdf_varget, ncid, varid, Tcline

    varid = ncdf_varid(ncid, 'hc')
    ncdf_varget, ncid, varid, hc

    varid = ncdf_varid(ncid, 's_rho')
    ncdf_varget, ncid, varid, s_rho

    varid = ncdf_varid(ncid, 's_w')
    ncdf_varget, ncid, varid, s_w

    varid = ncdf_varid(ncid, 'Cs_r')
    ncdf_varget, ncid, varid, Cs_r

    varid = ncdf_varid(ncid, 'Cs_w')
    ncdf_varget, ncid, varid, Cs_w

    varid = ncdf_varid(ncid, 'h')
    ncdf_varget, ncid, varid, hdep

    ; ----- Optional variables
    ; ----- SSH
    dat_found = Ncdf_GetData(ncid, 'zeta', ssh, FILL_VAL = ssh_fill, UNITS = ssh_units)

    ; ----- UBAR
    dat_found = Ncdf_GetData(ncid, 'ubar', ubar, FILL_VAL = ubar_fill, UNITS = ubar_units)

    ; ----- VBAR
    dat_found = Ncdf_GetData(ncid, 'vbar', vbar, FILL_VAL = vbar_fill, UNITS = vbar_units)

    ; ----- U-VEL
    dat_found = Ncdf_GetData(ncid, 'u', uvel, FILL_VAL = uvel_fill, UNITS = uvel_units)

    ; ----- V-VEL
    dat_found = Ncdf_GetData(ncid, 'v', vvel, FILL_VAL = vvel_fill, UNITS = vvel_units)

    ; ----- W-VEL
    dat_found = Ncdf_GetData(ncid, 'w', wvel, FILL_VAL = wvel_fill, UNITS = wvel_units)

    ; ----- TEMPERATURE
    dat_found = Ncdf_GetData(ncid, 'temp', temp, FILL_VAL = temp_fill, UNITS = temp_units)

    ; ----- SALINITY
    dat_found = Ncdf_GetData(ncid, 'salt', salt, FILL_VAL = salt_fill, UNITS = salt_units)
    
    ; ----- WIND U-VEL
    dat_found = Ncdf_GetData(ncid, 'Uwind', uwind, FILL_VAL = uwind_fill, UNITS = uwind_units)

    ; ----- WIND U-VEL
    dat_found = Ncdf_GetData(ncid, 'Vwind', vwind, FILL_VAL = vwind_fill, UNITS = vwind_units)

  ncdf_close, ncid

end
