FUNCTION Ncdf_VarDef_GomHycom_Bath, fname, XPNT, YPNT, $
                                    LONS = lons,       $
                                    LATS = lats,       $
                                    TITLE = title,     $
                                    TYPE = type,       $
                                    SOURCE = source,   $
                                    CDL = cdl

  Compile_Opt HIDDEN, IDL2

  COMMON BathParams

  ; Error handling.
  on_error, 2

  catch, theERR
  if theERR ne 0 then begin
     catch, /cancel
     help, /LAST_MESSAGE
     return, theERR
  endif

  failure = 0
  useREF = 0

  if ((n_elements(lons) ne 0) and (n_elements(lats) ne 0)) then begin
    dims = size(lons, /DIMENSIONS)
    if (array_equal(dims, size(lats, /DIMENSIONS)) ne 1) then begin
      message, '<lons, lats> should have the same dimensions
    endif
    if ((dims[0] ne XPNT) and (dims[1] ne YPNT)) then begin
      message, '<lons, lats> should have dimensions equal to: <XPNT, YPNT>'
    endif
    useREF = 1
  endif

  if (useREF gt 0) then begin
    defXYZ = vl_geodetic2xy([ transpose(lats[*]), transpose(lons[*]) ], $
                 EQUAT_RADIUS = DEF_SemiMAJ, $
                 POLAR_RADIUS = DEF_SemiMIN)
    geovals = vl_xy2geodetic(defXYZ,         $
                 EQUAT_RADIUS = REF_SemiMAJ, $
                 POLAR_RADIUS = REF_SemiMIN)

    lonsREF = make_array(XPNT, YPNT, TYPE = size(lons, /TYPE), VALUE = 0)
    latsREF = lonsREF
    lonsREF[*] = transpose(geovals[1, *])
    latsREF[*] = transpose(geovals[0, *])

    clats = mean(lats, /NAN)
    clons = mean(lons, /NAN)
    tlats = clats
    mapSTRUCT = VL_GetMapStruct(DEF_PROJ, $
                                CENTER_LATITUDE     = clats, $
                                CENTER_LONGITUDE    = clons, $
                                TRUE_SCALE_LATITUDE = tlats, $
                                SEMIMAJOR_AXIS      = DEF_SemiMAJ, $
                                SEMIMINOR_AXIS      = DEF_SemiMIN)

    ; get the xy Cartesian coordinates for the current projection
    xcrds = make_array(XPNT, YPNT, TYPE = size(lons, /TYPE), VALUE = 0)
    ycrds = xcrds
    xy = map_proj_forward(lons[*], lats[*], $
                          MAP_STRUCTURE = mapSTRUCT)
    xcrds[*] = Transpose(xy[0, *])
    ycrds[*] = Transpose(xy[1, *])

    Get_DomainStats, lons, /XDIR, $
                     MIN_VAL = MIN_LONS, MAX_VAL = MAX_LONS, $
                     AVE_VAL = MEAN_LONS, $
                     DMIN_VAL = DMIN_LONS, DMAX_VAL = DMAX_LONS, $
                     DAVE_VAL = DMEAN_LONS
    Get_DomainStats, lats, /YDIR, $
                     MIN_VAL = MIN_LATS, MAX_VAL = MAX_LATS, $
                     AVE_VAL = MEAN_LATS, $
                     DMIN_VAL = DMIN_LATS, DMAX_VAL = DMAX_LATS, $
                     DAVE_VAL = DMEAN_LATS
    Get_DomainStats, xcrds, /XDIR, $
                     MIN_VAL = MIN_XCRDS, MAX_VAL = MAX_XCRDS, $
                     AVE_VAL = MEAN_XCRDS, $
                     DMIN_VAL = DMIN_XCRDS, DMAX_VAL = DMAX_XCRDS, $
                     DAVE_VAL = DMEAN_XCRDS
    Get_DomainStats, ycrds, /YDIR, $
                     MIN_VAL = MIN_YCRDS, MAX_VAL = MAX_YCRDS, $
                     AVE_VAL = MEAN_YCRDS, $
                     DMIN_VAL = DMIN_YCRDS, DMAX_VAL = DMAX_YCRDS, $
                     DAVE_VAL = DMEAN_YCRDS
  endif

  ncid = ncdf_create(fname, /CLOBBER)

    ncdf_control, ncid, /FILL
      ; ---------- define and set the dimensions
      did_jdim  = ncdf_dimdef(ncid, 'Y', YPNT)
      did_idim  = ncdf_dimdef(ncid, 'X', XPNT)
      did_four  = ncdf_dimdef(ncid, 'four', 4)

      ; ---------- define the variables
      varid = ncdf_vardef(ncid, 'Bbox_geo', did_four, /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'geographic bounding box', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_east, degrees_north', /CHAR
      ncdf_attput, ncid, varid, 'definition', '[min_LON, min_LAT, max_LON, max_LAT]', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'subset bounding box of the original data', /CHAR

      varid = ncdf_vardef(ncid, 'Bbox_idx', did_four, /LONG)
      ncdf_attput, ncid, varid, 'standard_name', 'index bounding box', /CHAR
      ncdf_attput, ncid, varid, 'units', 'dimensionless', /CHAR
      ncdf_attput, ncid, varid, 'definition', '[min_I, min_J, max_I, max_J]', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'subset bounding box of the original data', /CHAR
      
      varid = ncdf_vardef(ncid, 'Y', did_jdim, /LONG)
      ncdf_attput, ncid, varid, 'point_spacing', 'even', /CHAR
      ncdf_attput, ncid, varid, 'units', 'dimensionless', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'Y', /CHAR

      varid = ncdf_vardef(ncid, 'X', did_idim, /LONG)
      ncdf_attput, ncid, varid, 'point_spacing', 'even', /CHAR
      ncdf_attput, ncid, varid, 'units', 'dimensionless', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'X', /CHAR

      varid = ncdf_vardef(ncid, 'Latitude', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_north', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'Y', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lat', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'latitude at P-points', /CHAR

      varid = ncdf_vardef(ncid, 'Longitude', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_east', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'X', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lon', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'longitude at P-points', /CHAR

      varid = ncdf_vardef(ncid, 'plat', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_north', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'Y', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lat', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'latitude at P-points', /CHAR

      varid = ncdf_vardef(ncid, 'plon', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_east', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'X', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lon', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'longitude at P-points', /CHAR

      varid = ncdf_vardef(ncid, 'qlat', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_north', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'Y', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lat', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'latitude at Q-points', /CHAR

      varid = ncdf_vardef(ncid, 'qlon', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_east', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'X', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lon', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'longitude at Q-points', /CHAR

      varid = ncdf_vardef(ncid, 'ulat', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_north', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'Y', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lat', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'latitude at U-points', /CHAR

      varid = ncdf_vardef(ncid, 'ulon', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_east', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'X', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lon', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'longitude at U-points', /CHAR

      varid = ncdf_vardef(ncid, 'vlat', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_north', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'Y', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lat', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'latitude at V-points', /CHAR

      varid = ncdf_vardef(ncid, 'vlon', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees_east', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'X', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lon', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'longitude at V-points', /CHAR

      varid = ncdf_vardef(ncid, 'pscx', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'longitudinal distance', /CHAR
      ncdf_attput, ncid, varid, 'units', 'm', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'longitudinal distances at P-points', /CHAR

      varid = ncdf_vardef(ncid, 'pscy', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'latitudinal distance', /CHAR
      ncdf_attput, ncid, varid, 'units', 'm', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'latitudinal distances at P-points', /CHAR

      varid = ncdf_vardef(ncid, 'qscx', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'longitudinal distance', /CHAR
      ncdf_attput, ncid, varid, 'units', 'm', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'longitudinal distances at Q-points', /CHAR

      varid = ncdf_vardef(ncid, 'qscy', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'latitudinal distance', /CHAR
      ncdf_attput, ncid, varid, 'units', 'm', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'latitudinal distances at Q-points', /CHAR

      varid = ncdf_vardef(ncid, 'uscx', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'longitudinal distance', /CHAR
      ncdf_attput, ncid, varid, 'units', 'm', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'longitudinal distances at U-points', /CHAR

      varid = ncdf_vardef(ncid, 'uscy', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'latitudinal distance', /CHAR
      ncdf_attput, ncid, varid, 'units', 'm', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'latitudinal distances at U-points', /CHAR

      varid = ncdf_vardef(ncid, 'vscx', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'longitudinal distance', /CHAR
      ncdf_attput, ncid, varid, 'units', 'm', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'longitudinal distances at V-points', /CHAR

      varid = ncdf_vardef(ncid, 'vscy', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'latitudinal distance', /CHAR
      ncdf_attput, ncid, varid, 'units', 'm', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'latitudinal distances at V-points', /CHAR

      varid = ncdf_vardef(ncid, 'cori', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'coriolis parameter', /CHAR
      ncdf_attput, ncid, varid, 'units', 'dimensionless', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'coriolis parameter', /CHAR

      varid = ncdf_vardef(ncid, 'pang', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'rotation angle', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degrees', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'rotation angle', /CHAR

      varid = ncdf_vardef(ncid, 'Depth', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'depth', /CHAR
      ncdf_attput, ncid, varid, 'units', 'm', /CHAR
      ncdf_attput, ncid, varid, 'positive', 'down', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'Z', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Height', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateZisPositive', 'down', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'depth at P-points', /CHAR

      varid = ncdf_vardef(ncid, 'Mask', [did_idim, did_jdim], /LONG)
      ncdf_attput, ncid, varid, 'standard_name', 'mask', /CHAR
      ncdf_attput, ncid, varid, 'units', 'dimensionless', /CHAR
      ncdf_attput, ncid, varid, 'flag_values', [0, 1], /LONG
      ncdf_attput, ncid, varid, 'flag_meanings', 'land water', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'mask at P-points', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'lat_ref', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degree_north', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'Y', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lat', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'latitude at P-points' + $
        ' (referenced to: ' + strtrim(string(REF_HDATUM), 2) + ' ellipsoid)', /CHAR

      varid = ncdf_vardef(ncid, 'lon_ref', [did_idim, did_jdim], /DOUBLE)
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR
      ncdf_attput, ncid, varid, 'units', 'degree_east', /CHAR
      ncdf_attput, ncid, varid, 'axis', 'X', /CHAR
      ncdf_attput, ncid, varid, '_CoordinateAxisType', 'Lon', /CHAR
      ncdf_attput, ncid, varid, 'long_name', 'longitude at P-points' + $
        ' (referenced to: ' + strtrim(string(REF_HDATUM), 2) + ' ellipsoid)', /CHAR

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

      Ncdf_PutGlobal, ncid, 'coordinates', 'geographic'

      if (useREF gt 0) then begin
        res_str    = StrTrim(String(DMEAN_LONS, format = '(f10.7)'), 2) + ' x ' + $
                       StrTrim(String(DMEAN_LATS, format = '(f10.7)'), 2) + ' (degrees)'
        res_str_xy = StrTrim(String(DMEAN_XCRDS, format = '(f10.3)'), 2) + ' x ' + $
                       StrTrim(String(DMEAN_YCRDS, format = '(f10.3)'), 2) + ' (m)'
        ncdf_attput,  ncid, /GLOBAL, 'resolution', res_str, /CHAR
        ncdf_attput,  ncid, /GLOBAL, 'resolution_xy', res_str_xy, /CHAR
      endif

      ncdf_attput, ncid, /GLOBAL, 'projection', DEF_PROJ, /CHAR
      ncdf_attput, ncid, /GLOBAL, 'projection_name', DEF_PROJ_NAM, /CHAR
      ncdf_attput, ncid, /GLOBAL, 'horizontal_datum', DEF_HDATUM, /CHAR
      ncdf_attput, ncid, /GLOBAL, 'vertical_datum', DEF_VDATUM, /CHAR
      ncdf_attput, ncid, /GLOBAL, 'semi_minor_axis', DEF_SemiMIN, /DOUBLE
      ncdf_attput, ncid, /GLOBAL, 'semi_major_axis', DEF_SemiMAJ, /DOUBLE
      ncdf_attput, ncid, /GLOBAL, 'radius', DEF_RADIUS, /DOUBLE
      ncdf_attput, ncid, /GLOBAL, 'projection_ref', REF_PROJ, /CHAR
      ncdf_attput, ncid, /GLOBAL, 'projection_name_ref', REF_PROJ_NAM, /CHAR
      ncdf_attput, ncid, /GLOBAL, 'horizontal_datum_ref', REF_HDATUM, /CHAR
      ncdf_attput, ncid, /GLOBAL, 'vertical_datum_ref', REF_VDATUM, /CHAR
      ncdf_attput, ncid, /GLOBAL, 'semi_minor_axis_ref', REF_SemiMIN, /DOUBLE
      ncdf_attput, ncid, /GLOBAL, 'semi_major_axis_ref', REF_SemiMAJ, /DOUBLE
      ncdf_attput, ncid, /GLOBAL, 'radius_ref', REF_RADIUS, /DOUBLE
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

  ; Write the ref lon/lat to the file
  if ((useREF gt 0) and (failure eq 0)) then begin
    ncid = ncdf_open(fname, /WRITE)
      ncdf_varput, ncid, ncdf_varid(ncid, 'lat_ref'), latsREF
      ncdf_varput, ncid, ncdf_varid(ncid, 'lon_ref'), lonsREF
    ncdf_close, ncid
  endif

  return, failure
end
