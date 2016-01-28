Pro Ncdf_WriteTopo, fname,                    $
                    depths, mask, lons, lats, $
                    DEP_MIN = dep_min,        $
                    EXCAVATE = excavate,      $
                    ELP = elp, SELP = selp,   $
                    TITLE = title,            $
                    TYPE = type,              $
                    SOURCE = source,          $
                    CDL = cdl
;+++
; NAME:
;	Ncdf_WriteTopo
; VERSION:
;	1.0
; PURPOSE:
;	To write a bathymetric grid data file.
; CALLING SEQUENCE:
;	Ncdf_WriteTopo, fname, depths, lons, lats
;
;	Required input:
;	   fname - Full pathway name of the bathymetry/grid data file
;	  depths - The depths/elevations (a 2D array)
;	    mask - The mask values (a 2D array)
;                  0 = land, 1 = water
;	    lons - The longitudes at the "rho" points (a 2D array)
;	    lats - The latitudes at the "rho" points (a 2D array)
;
;	Optional input:
;	 dep_min - The minimum depth to be set for the "wet" points
;                    (clipping depth)
;	excavate - Set this keyword if you want to excavate the
;                    whole domain to bring the min depth to be
;                    equal to dep_min, instead of just setting
;                    all the points less than dep_min equal to dep_min
;	     elp - The structure that describes the geodetic
;                    coordinate system that is currently used for the data
;	    selp - The structure that describes a standard (e.g WGS84)
;                    reference geodetic coordinate system
;       The elp/selp structures are of the form:
;         elp = { proj:'', proj_nam:'', hdatum:'', vdatum:'', $
;                 minor:0.0D, major:0.0D, cent_lon:0.0D, cent_lat:0.0D, true_lat:0.0D}
;
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created:  Tue Oct 22 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  COMMON BathParams

  ; Error handling.
  On_Error, 2

  failure = 0

  ; --------------------
  ; check for the validity of the supplied values for "fname"
  If (Size(fname, /TNAME) NE 'STRING') Then $
    Message, "the name supplied for <fname> is not a valid string."
  fname = Strtrim(fname, 2)

  ; --------------------
  ; check the input "depths" array
  If (N_Elements(depths) EQ 0) Then Message, "Must pass the <depths> argument."
  If (Where([7, 8, 10, 11] EQ Size(depths, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <depths>."
  If (Size(depths, /N_DIMENSIONS) NE 2) Then $
    Message, "<depths> must be a 2D array of values."
  
;  idx = Where(depths LT 0, icnt)
;  If (icnt NE 0) Then $
;    Message, "<depths> must only contain positive values."

  dims   = Size(depths, /DIMENSIONS)
  IPNTS  = Long(dims[0])
  JPNTS  = Long(dims[1])
  TCELLS = IPNTS * JPNTS

  ; --------------------
  ; check the input "mask" array
  If (N_Elements(mask) EQ 0) Then Message, "Must pass the <mask> argument."
  If (Where([7, 8, 10, 11] EQ Size(mask, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <mask>."
  If (Size(mask, /N_DIMENSIONS) NE 2) Then $
    Message, "<mask> must be a 2D array of values."

  dims = Size(mask, /DIMENSIONS)
  If (dims[0] NE IPNTS) AND (dims[1] NE JPNTS) Then $
    Message, "<depths, mask> have inconsistent horizontal dimensions."

  ; --------------------
  ; check the input "lons" array
  If (N_Elements(lons) EQ 0) Then Message, "Must pass the <lons> argument."
  If (Where([7, 8, 10, 11] EQ Size(lons, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <lons>."
  If (Size(lons, /N_DIMENSIONS) NE 2) Then $
    Message, "<lons> must be a 2D array of values."

  dims = Size(lons, /DIMENSIONS)
  If (dims[0] NE IPNTS) AND (dims[1] NE JPNTS) Then $
    Message, "<depths, lons> have inconsistent horizontal dimensions."

  ; --------------------
  ; check the input "lats" array
  If (N_Elements(lats) EQ 0) Then Message, "Must pass the <lats> argument."
  If (Where([7, 8, 10, 11] EQ Size(lats, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <lats>."
  If (Size(lats, /N_DIMENSIONS) NE 2) Then $
    Message, "<lats> must be a 2D array of values."

  dims = Size(lats, /DIMENSIONS)
  If (dims[0] NE IPNTS) AND (dims[1] NE JPNTS) Then $
    Message, "<depths, lats> have inconsistent horizontal dimensions."

  ; --------------------
  ; check the input "elp" structure
  If (N_Elements(elp) NE 0) Then Begin
    If (Size(elp, /TYPE) NE 8) Then $
      Message, "<elp> should be a structure."
  EndIf

  ; --------------------
  ; check the input "selp" structure
  If (N_Elements(selp) NE 0) Then Begin
    If (Size(selp, /TYPE) NE 8) Then $
      Message, "<selp> should be a structure."
  EndIf


  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ; START THE CALCULATIONS
  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;  ref_clon = 0.0D
;  ref_clat = 0.0D
;  ref_tlat = 0.0D
  ref_clon = mean(lons, /NAN)
  ref_clat = mean(lats, /NAN)
  ref_tlat = ref_clat

  ; ----- data datum definitions
  datCLON     = ref_clon
  datCLAT     = ref_clat
  datTLAT     = ref_tlat
  datPROJ     = DEF_PROJ
  datPROJ_NAM = DEF_PROJ_NAM
  datHDATUM   = DEF_HDATUM
  datVDATUM   = DEF_VDATUM
  datSemiMAJ  = DEF_SemiMAJ
  datSemiMIN  = DEF_SemiMIN
  datRADIUS   = DEF_RADIUS
  If (N_Elements(elp) NE 0) Then Begin
    datPROJ     = StrTrim(elp.proj, 2)
    datPROJ_NAM = StrTrim(elp.proj_nam, 2)
    datHDATUM   = StrTrim(elp.hdatum, 2)
    datVDATUM   = StrTrim(elp.vdatum, 2)
    datSemiMIN  = (Double(elp.minor) > 0)
    datSemiMAJ  = (Double(elp.major) > 0)
    datRADIUS   = datSemiMAJ
    datCLON     = Double(elp.cent_lon)
    datCLAT     = Double(elp.cent_lat)
    datTLAT     = Double(elp.true_lat)
  EndIf

  If (datSemiMIN LE 0) OR (datSemiMAJ LE 0) Then Begin
    Message, "elp: (semi_minor, semi_major) values should be greater than zero."
  EndIf

  datSTRUCT = VL_GetMapStruct(datPROJ, $
                              CENTER_LATITUDE     = datCLAT, $
                              CENTER_LONGITUDE    = datCLON, $
                              TRUE_SCALE_LATITUDE = datTLAT, $
                              SEMIMAJOR_AXIS      = datSemiMAJ, $
                              SEMIMINOR_AXIS      = datSemiMIN)
  ; -----


  ; ----- data reference ellipsoid datum definitions
  refCLON = datCLON
  refCLAT = datCLAT
  refTLAT = datTLAT
  refPROJ     = REF_PROJ
  refPROJ_NAM = REF_PROJ_NAM
  refHDATUM   = REF_HDATUM
  refVDATUM   = REF_VDATUM
  refSemiMAJ  = REF_SemiMAJ
  refSemiMIN  = REF_SemiMIN
  refRADIUS   = refSemiMAJ
  If (N_Elements(selp) NE 0) Then Begin
    refPROJ     = StrTrim(selp.proj, 2)
    refPROJ_NAM = StrTrim(selp.proj_nam, 2)
    refHDATUM   = StrTrim(selp.hdatum, 2)
    refVDATUM   = StrTrim(selp.vdatum, 2)
    refSemiMIN  = (Double(selp.minor) > 0)
    refSemiMAJ  = (Double(selp.major) > 0)
    refRADIUS   = refSemiMAJ
  EndIf

  If (refSemiMIN LE 0) OR (refSemiMAJ LE 0) Then Begin
    Message, "selp: (semi_minor, semi_major) values should be greater than zero."
  EndIf

  refSTRUCT = VL_GetMapStruct(refPROJ, $
                              CENTER_LATITUDE     = refCLAT, $
                              CENTER_LONGITUDE    = refCLON, $
                              TRUE_SCALE_LATITUDE = refTLAT, $
                              SEMIMAJOR_AXIS      = refSemiMAJ, $
                              SEMIMINOR_AXIS      = refSemiMIN)
  ; -----


  ; ----- CENTER OF CELL POINTS
  x_crd = lons & x_crd[*] = 0
  y_crd = x_crd
  lons_ref = lons & lons_ref[*] = 0
  lats_ref = lons_ref

  ; get the xy Cartesian coordinates for the current projection
  xy = map_proj_forward(lons[*], lats[*], $
                        MAP_STRUCTURE = datSTRUCT)
  x_crd[*] = Transpose(xy[0, *])
  y_crd[*] = Transpose(xy[1, *])

  ; get the reference geodetic coordinates
  xy = vl_geodetic2xy([ Transpose(lats[*]), Transpose(lons[*]) ], $
                      EQUAT_RADIUS = datSemiMAJ, $
                      POLAR_RADIUS = datSemiMIN)
  xy = vl_xy2geodetic(xy, $
                      EQUAT_RADIUS = refSemiMAJ, $
                      POLAR_RADIUS = refSemiMIN)
  lons_ref[*] = Transpose(xy[1, *])
  lats_ref[*] = Transpose(xy[0, *])
  undefine, xy

  ; ----- DOMAIN STATS
  Get_DomainStats, lons, /XDIR, $
                   MIN_VAL = LON_MIN, MAX_VAL = LON_MAX, $
                   AVE_VAL = LON_MEAN, $
                   DMIN_VAL = DLON_MIN, DMAX_VAL = DLON_MAX, $
                   DAVE_VAL = DLON_MEAN
  Get_DomainStats, lats, /YDIR, $
                   MIN_VAL = LAT_MIN, MAX_VAL = LAT_MAX, $
                   AVE_VAL = LAT_MEAN, $
                   DMIN_VAL = DLAT_MIN, DMAX_VAL = DLAT_MAX, $
                   DAVE_VAL = DLAT_MEAN
  Get_DomainStats, x_crd, /XDIR, $
                   MIN_VAL = X_MIN, MAX_VAL = X_MAX, $
                   AVE_VAL = X_MEAN, $
                   DMIN_VAL = DX_MIN, DMAX_VAL = DX_MAX, $
                   DAVE_VAL = DX_MEAN
  Get_DomainStats, y_crd, /YDIR, $
                   MIN_VAL = Y_MIN, MAX_VAL = Y_MAX, $
                   AVE_VAL = Y_MEAN, $
                   DMIN_VAL = DY_MIN, DMAX_VAL = DY_MAX, $
                   DAVE_VAL = DY_MEAN


  ; ----- TOPOGRAPHY H GRID
  h = depths

  ; water points have a mask of 1
  chk_msk = ChkForMask(mask, 1, WCELLSIDX, WCELLS, $
                       COMPLEMENT = LCELLSIDX, NCOMPLEMENT = LCELLS)

  ; determine a minimum water depth
  hmin = Min(h[WCELLSIDX], MAX = hmax)

  If (N_Elements(dep_min) NE 0) Then Begin
    dep_min = (dep_min[0] > 0.1) 
    If (dep_min GT hmin) Then Begin
      If Keyword_Set(excavate) Then Begin
        ; excavate the ocean floor to meet the minimum dep_min
        dh = ZeroFloatFix( dep_min - hmin )
        h[WCELLSIDX] = h[WCELLSIDX] + dh
        ; re-assign the land depth value from zero to
        ; max(min h, dep_min) > 0.0 (ROMS wants this)
        hmin = Min(h[WCELLSIDX], MAX = hmax)
      EndIf Else Begin
        idx = Where(h[WCELLSIDX] LE dep_min, icnt)
        If (icnt NE 0) Then h[WCELLSIDX[idx]] = dep_min
        ; re-assign the land depth value from zero to
        ; max(min h, dep_min) > 0.0 (ROMS wants this)
        hmin = Min(h[WCELLSIDX], MAX = hmax)
      EndElse
    EndIf
  EndIf

  ; ----- rotation angle values (as calculated at the rho points)
  angle = 0.0d

  ; ----- land/sea masks
  mask[WCELLSIDX] = 1
  mask[LCELLSIDX] = 0


  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ; PRINT THE RESULTS
  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Print, 'Writting the data to the output file: ' + fname

  ncid = Ncdf_Create(fname, /CLOBBER)

    Ncdf_Control, ncid, /FILL

      ; ---------- define and set the dimensions
      did_idim    = Ncdf_DimDef(ncid, 'IDIM',   IPNTS)
      did_jdim    = Ncdf_DimDef(ncid, 'JDIM',   JPNTS)

      ; ---------- define the DATA variables
      ; ----- LONGITUDE
      varid = Ncdf_VarDef(ncid, 'x', [did_idim, did_jdim], /DOUBLE)
        tmpVAL = [LON_MIN, LON_MAX]
      Ncdf_AttPut, ncid, varid, 'long_name', 'longitude at cell center', /CHAR
      Ncdf_AttPut, ncid, varid, 'range', tmpVAL, /DOUBLE
      Ncdf_AttPut, ncid, varid, 'units', 'degrees_east', /CHAR
      Ncdf_AttPut, ncid, varid, 'direction', 'west_east', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'longitude', /CHAR

      varid = Ncdf_VarDef(ncid, 'x1', [did_idim, did_jdim], /DOUBLE)
        tmpVAL = [Min(lons_ref, /NAN), Max(lons_ref, /NAN)]
      Ncdf_AttPut, ncid, varid, 'long_name', 'longitude at cell center' + $
        ' (referenced to: ' + refHDATUM + ')', /CHAR
      Ncdf_AttPut, ncid, varid, 'range', tmpVAL, /DOUBLE
      Ncdf_AttPut, ncid, varid, 'units', 'degrees_east', /CHAR
      Ncdf_AttPut, ncid, varid, 'direction', 'west_east', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'longitude', /CHAR

      ; ----- LATITUDE
      varid = Ncdf_VarDef(ncid, 'y', [did_idim, did_jdim], /DOUBLE)
        tmpVAL = [LAT_MIN, LAT_MAX]
      Ncdf_AttPut, ncid, varid, 'long_name', 'latitude at cell center', /CHAR
      Ncdf_AttPut, ncid, varid, 'range', tmpVAL, /DOUBLE
      Ncdf_AttPut, ncid, varid, 'units', 'degrees_north', /CHAR
      Ncdf_AttPut, ncid, varid, 'direction', 'south_north', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'latitude', /CHAR

      varid = Ncdf_VarDef(ncid, 'y1', [did_idim, did_jdim], /DOUBLE)
        tmpVAL = [Min(lats_ref, /NAN), Max(lats_ref, /NAN)]
      Ncdf_AttPut, ncid, varid, 'long_name', 'latitude at cell center' + $
        ' (referenced to: ' + refHDATUM + ')', /CHAR
      Ncdf_AttPut, ncid, varid, 'range', tmpVAL, /DOUBLE
      Ncdf_AttPut, ncid, varid, 'units', 'degrees_north', /CHAR
      Ncdf_AttPut, ncid, varid, 'direction', 'south_north', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'latitude', /CHAR

      ; ----- ELEVATION
      varid = Ncdf_VarDef(ncid, 'z', [did_idim, did_jdim], /DOUBLE)
        tmpVAL = [hmin, hmax]
      Ncdf_AttPut, ncid, varid, 'long_name', 'elevation at cell center', /CHAR
      Ncdf_AttPut, ncid, varid, 'range', tmpVAL, /DOUBLE
      Ncdf_AttPut, ncid, varid, 'units', 'meter', /CHAR
      Ncdf_AttPut, ncid, varid, 'positive', 'up', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'elevation', /CHAR

      ; ----- ROTATION ANGLE
      varid = Ncdf_VarDef(ncid, 'angle', [did_idim, did_jdim], /DOUBLE)
      Ncdf_AttPut, ncid, varid, 'long_name', 'angle between X-axis and EAST', /CHAR
      Ncdf_AttPut, ncid, varid, 'units', 'radians', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'angle', /CHAR

      ; ----- MASK
      varid = Ncdf_VarDef(ncid, 'mask', [did_idim, did_jdim], /DOUBLE)
      Ncdf_AttPut, ncid, varid, 'long_name', 'mask at cell center', /CHAR
      Ncdf_AttPut, ncid, varid, 'flag_values', [0.0, 1.0], /DOUBLE
      Ncdf_AttPut, ncid, varid, 'flag_meanings', 'land water', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'mask', /CHAR

      ; ---------- define the GLOBAL variables
      Ncdf_PutGlobal, ncid, 'Conventions', 'CF-1.1'

      If (N_Elements(title) NE 0) Then Begin
        Ncdf_PutGlobal, ncid, 'title', strtrim(string(title), 2)
      EndIf Else Begin
        res_str = '1/' + Strtrim(String(Fix(1.0/DLON_MEAN)), 2)
        res_str = '(resolution: ' + res_str + ' degrees)'
        Ncdf_PutGlobal, ncid, 'title', 'Gridded DEM ' + res_str
      EndElse

      If (N_Elements(type) NE 0) Then Begin
        Ncdf_PutGlobal, ncid, 'type', strtrim(string(type), 2)
      EndIf Else Begin
        Ncdf_PutGlobal, ncid, 'type', 'Gridded DEM'
      EndElse

      Ncdf_PutGlobal, ncid, 'institution', string(10B) + CoapsAddress()
      Ncdf_PutGlobal, ncid, 'contact', 'pvelissariou@fsu.edu'

      Ncdf_PutGlobal, ncid, 'dem_file', File_Basename(fname)

      Ncdf_PutGlobal_Devel, ncid

      res_str    = StrTrim(String(DLON_MEAN, format = '(f10.7)'), 2) + ' x ' + $
                     StrTrim(String(DLAT_MEAN, format = '(f10.7)'), 2) + ' (degrees)'
      res_str_xy = StrTrim(String(DX_MEAN, format = '(f10.3)'), 2) + ' x ' + $
                     StrTrim(String(DY_MEAN, format = '(f10.3)'), 2) + ' (m)'

      Ncdf_AttPut, ncid, /GLOBAL, $
         'resolution', res_str, /CHAR

      Ncdf_AttPut, ncid, /GLOBAL, $
         'resolution_xy', res_str_xy, /CHAR

      ; ----- ELLIPSOID IN USE
      Ncdf_AttPut, ncid, /GLOBAL, $
         'projection', datPROJ, /CHAR

      Ncdf_AttPut, ncid, /GLOBAL, $
         'projection_name', datPROJ_NAM, /CHAR

      Ncdf_AttPut, ncid, /GLOBAL, $
         'horizontal_datum', datHDATUM, /CHAR

      Ncdf_AttPut, ncid, /GLOBAL, $
         'vertical_datum', datVDATUM, /CHAR

      Ncdf_AttPut, ncid, /GLOBAL, $
         'radius', datRADIUS, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, /GLOBAL, $
         'semi_minor_axis', datSemiMIN, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, /GLOBAL, $
         'semi_major_axis', datSemiMAJ, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, /GLOBAL, $
         'center_longitude', datCLON, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, /GLOBAL, $
         'center_latitude', datCLAT, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, /GLOBAL, $
         'true_scale_latitude', datTLAT, /GLOBAL, /DOUBLE

      ; ----- STANDARD/REFERENCE ELLIPSOID

      Ncdf_AttPut, ncid, /GLOBAL, $
         'ref_projection', refPROJ, /CHAR

      Ncdf_AttPut, ncid, /GLOBAL, $
         'ref_projection_name', refPROJ_NAM, /CHAR

      Ncdf_AttPut, ncid, /GLOBAL, $
         'ref_horizontal_datum', refHDATUM, /CHAR

      Ncdf_AttPut, ncid, /GLOBAL, $
         'ref_vertical_datum', refVDATUM, /CHAR

      Ncdf_AttPut, ncid, /GLOBAL, $
         'ref_radius', refRADIUS, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, /GLOBAL, $
         'ref_semi_minor_axis', refSemiMIN, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, /GLOBAL, $
         'ref_semi_major_axis', refSemiMAJ, /GLOBAL, /DOUBLE

    Ncdf_Control, ncid, /ENDEF

  Ncdf_Close, ncid

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


  ncid = Ncdf_Open(fname, /WRITE)

    ;-------------------------------------------------
    ; topography h grid
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'z')
    ncdf_varput,ncid, varid, h

    ;-------------------------------------------------
    ; geographic coordinates
    ;-------------------------------------------------
    ; lat/lon values at the pressure/rho points (center of the grid cell)
      varid = ncdf_varid(ncid, 'x')
    ncdf_varput,ncid, varid, lons

      varid = ncdf_varid(ncid, 'y')
    ncdf_varput,ncid, varid, lats

    ; lat/lon values at the pressure/rho points (referenced to WGS ellipsoid)
      varid = ncdf_varid(ncid, 'x1')
    ncdf_varput,ncid, varid, lons_ref

      varid = ncdf_varid(ncid, 'y1')
    ncdf_varput,ncid, varid, lats_ref

    ;-------------------------------------------------
    ; rotation angle
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'angle')
    ncdf_varput,ncid, varid, angle

    ;-------------------------------------------------
    ; land/sea masks
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'mask')
    ncdf_varput,ncid, varid, mask

  Ncdf_Close, ncid

end
