Pro Ncdf_WriteBath_Public, fname,                  $
                         depths, mask, lons, lats, $
                         DEP_MIN = dep_min,        $
                         EXCAVATE = excavate,      $
                         ELP = elp, SELP = selp,   $
                         TITLE = title
;+++
; NAME:
;	Ncdf_WriteBath_Public
; VERSION:
;	1.0
; PURPOSE:
;	To write a bathymetric grid data file.
; CALLING SEQUENCE:
;	Ncdf_WriteBath_Public, fname, depths, lons, lats
;
;	Required input:
;	   fname - Full pathway name of the bathymetry/grid data file
;	  depths - The water depths (a 2D array)
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
;	Modified: Tue Oct 22 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;	Created:  Tue Jan 08 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  ; Error handling.
  On_Error, 2

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

  IDIM = IPNTS
  JDIM = JPNTS

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
  datPROJ     = 'Mercator'
  datPROJ_NAM = 'Mercator'
  datHDATUM   = 'Sphere'
  datVDATUM   = 'MSL/NAVD88'
  datSemiMAJ  = 6371001.0D ; HYCOM radius
  datSemiMIN  = datSemiMAJ
  datRADIUS   = datSemiMAJ
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
  refPROJ     = 'Mercator'
  refPROJ_NAM = 'Mercator'
  refHDATUM   = 'GRS 1980/WGS 84'
  refVDATUM   = 'MSL/NAVD88'
  refSemiMIN  = 6356752.31414D
  refSemiMAJ  = 6378137.0D
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


  ; ----- CELL CENTER POINTS
  x_crd = lons & x_crd[*] = 0
  y_crd = x_crd
  ref_lons = lons & ref_lons[*] = 0
  ref_lats = ref_lons

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
  ref_lons[*] = Transpose(xy[1, *])
  ref_lats[*] = Transpose(xy[0, *])
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

  h[LCELLSIDX] = 0
  h[WCELLSIDX] = ZeroFloatFix( Abs(h[WCELLSIDX]) )

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
      did_idim  = Ncdf_DimDef(ncid, 'IDIM', IDIM)
      did_jdim  = Ncdf_DimDef(ncid, 'JDIM', JDIM)

      ; ---------- define the DATA variables
      varid = Ncdf_VarDef(ncid, 'h', [did_idim, did_jdim], /DOUBLE)
        tmpVAL = [hmin, hmax]
      Ncdf_AttPut, ncid, varid, 'long_name', 'bathymetry at cell center', /CHAR
      Ncdf_AttPut, ncid, varid, 'range', tmpVAL, /DOUBLE
      Ncdf_AttPut, ncid, varid, 'units', 'meter', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'depth', /CHAR

      ; ----------
      varid = Ncdf_VarDef(ncid, 'lat', [did_idim, did_jdim], /DOUBLE)
        tmpVAL = [LAT_MIN, LAT_MAX]
      Ncdf_AttPut, ncid, varid, 'long_name', 'latitude of cell center', /CHAR
      Ncdf_AttPut, ncid, varid, 'range', tmpVAL, /DOUBLE
      Ncdf_AttPut, ncid, varid, 'units', 'degree_north', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'latitude', /CHAR

      varid = Ncdf_VarDef(ncid, 'lon', [did_idim, did_jdim], /DOUBLE)
        tmpVAL = [LON_MIN, LON_MAX]
      Ncdf_AttPut, ncid, varid, 'long_name', 'longitude of cell center', /CHAR
      Ncdf_AttPut, ncid, varid, 'range', tmpVAL, /DOUBLE
      Ncdf_AttPut, ncid, varid, 'units', 'degree_east', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'longitude', /CHAR

      ; ----------
      varid = Ncdf_VarDef(ncid, 'angle', [did_idim, did_jdim], /DOUBLE)
      Ncdf_AttPut, ncid, varid, 'long_name', 'angle between X-axis and EAST', /CHAR
      Ncdf_AttPut, ncid, varid, 'units', 'radians', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'angle', /CHAR

      ; ---------- masks
      varid = Ncdf_VarDef(ncid, 'mask', [did_idim, did_jdim], /DOUBLE)
      Ncdf_AttPut, ncid, varid, 'long_name', 'mask at cell center', /CHAR
      Ncdf_AttPut, ncid, varid, 'flag_values', [0.0, 1.0], /DOUBLE
      Ncdf_AttPut, ncid, varid, 'flag_meanings', 'land water', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'mask', /CHAR

      ; ----------
      varid = Ncdf_VarDef(ncid, 'ref_lat', [did_idim, did_jdim], /DOUBLE)
        tmpVAL = [Min(ref_lats, /NAN), Max(ref_lats, /NAN)]
      Ncdf_AttPut, ncid, varid, 'long_name', 'latitude of cell center' + $
        ' (referenced to: ' + refHDATUM + ')', /CHAR
      Ncdf_AttPut, ncid, varid, 'range', tmpVAL, /DOUBLE
      Ncdf_AttPut, ncid, varid, 'units', 'degree_north', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'latitude', /CHAR

      varid = Ncdf_VarDef(ncid, 'ref_lon', [did_idim, did_jdim], /DOUBLE)
        tmpVAL = [Min(ref_lons, /NAN), Max(ref_lons, /NAN)]
      Ncdf_AttPut, ncid, varid, 'long_name', 'longitude of cell center' + $
        ' (referenced to: ' + refHDATUM + ')', /CHAR
      Ncdf_AttPut, ncid, varid, 'range', tmpVAL, /DOUBLE
      Ncdf_AttPut, ncid, varid, 'units', 'degree_east', /CHAR
      Ncdf_AttPut, ncid, varid, 'standard_name', 'longitude', /CHAR
 
      ; ---------- define the GLOBAL variables
      If (N_Elements(title) NE 0) Then Begin
        Ncdf_PutGlobal, ncid, 'title', strtrim(string(title), 2)
      EndIf Else Begin
        res_str = '1/' + Strtrim(String(Fix(1.0/DLON_MEAN)), 2)
        res_str = '(resolution: ' + res_str + ' degrees)'
        Ncdf_PutGlobal, ncid, 'title', 'Gulf of Mexico Bathymetry ' + res_str
      EndElse

      Ncdf_PutGlobal, ncid, 'type', 'Gridded Bathymetry'

      Ncdf_PutGlobal, ncid, 'bath_file', File_Basename(fname)

      Ncdf_PutGlobal_Devel, ncid

      res_str    = StrTrim(String(DLON_MEAN, format = '(f10.7)'), 2) + ' x ' + $
                     StrTrim(String(DLAT_MEAN, format = '(f10.7)'), 2) + ' (degrees)'
      res_str_xy = StrTrim(String(DX_MEAN, format = '(f10.3)'), 2) + ' x ' + $
                     StrTrim(String(DY_MEAN, format = '(f10.3)'), 2) + ' (m)'

      Ncdf_AttPut,  ncid, $
         'resolution', res_str, /GLOBAL, /CHAR

      Ncdf_AttPut,  ncid, $
         'resolution_xy', res_str_xy, /GLOBAL, /CHAR

      ; ----- ELLIPSOID IN USE
      Ncdf_AttPut, ncid, $
         'projection', datPROJ, /GLOBAL, /CHAR

      Ncdf_AttPut, ncid, $
         'projection_name', datPROJ_NAM, /GLOBAL, /CHAR

      Ncdf_AttPut, ncid, $
         'horizontal_datum', datHDATUM, /GLOBAL, /CHAR

      Ncdf_AttPut, ncid, $
         'vertical_datum', datVDATUM, /GLOBAL, /CHAR

      Ncdf_AttPut, ncid, $
         'radius', datRADIUS, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, $
         'semi_minor_axis', datSemiMIN, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, $
         'semi_major_axis', datSemiMAJ, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, $
         'center_longitude', datCLON, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, $
         'center_latitude', datCLAT, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, $
         'true_scale_latitude', datTLAT, /GLOBAL, /DOUBLE

      ; ----- STANDARD/REFERENCE ELLIPSOID

      Ncdf_AttPut, ncid, $
         'ref_projection', refPROJ, /GLOBAL, /CHAR

      Ncdf_AttPut, ncid, $
         'ref_projection_name', refPROJ_NAM, /GLOBAL, /CHAR

      Ncdf_AttPut, ncid, $
         'ref_horizontal_datum', refHDATUM, /GLOBAL, /CHAR

      Ncdf_AttPut, ncid, $
         'ref_vertical_datum', refVDATUM, /GLOBAL, /CHAR

      Ncdf_AttPut, ncid, $
         'ref_radius', refRADIUS, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, $
         'ref_semi_minor_axis', refSemiMIN, /GLOBAL, /DOUBLE

      Ncdf_AttPut, ncid, $
         'ref_semi_major_axis', refSemiMAJ, /GLOBAL, /DOUBLE

    Ncdf_Control, ncid, /ENDEF

    ;-------------------------------------------------
    ; topography h grid
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'h')
    ncdf_varput,ncid, varid, h

    ;-------------------------------------------------
    ; geographic coordinates
    ;-------------------------------------------------
    ; lat/lon values at the pressure/rho points (center of the grid cell)
      varid = ncdf_varid(ncid, 'lon')
    ncdf_varput,ncid, varid, lons

      varid = ncdf_varid(ncid, 'lat')
    ncdf_varput,ncid, varid, lats

    ; lat/lon values at the pressure/rho points (referenced to WGS ellipsoid)
      varid = ncdf_varid(ncid, 'ref_lon')
    ncdf_varput,ncid, varid, ref_lons

      varid = ncdf_varid(ncid, 'ref_lat')
    ncdf_varput,ncid, varid, ref_lats

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
