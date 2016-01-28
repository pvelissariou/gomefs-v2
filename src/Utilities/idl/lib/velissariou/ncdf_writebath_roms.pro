Pro Ncdf_WriteBath_Roms, fname,                    $
                         depths, mask, lons, lats, $
                         DEP_MIN = dep_min,        $
                         EXCAVATE = excavate,      $
                         ELP = elp, SELP = selp,   $
                         TITLE = title
;+++
; NAME:
;	Ncdf_WriteBath_Roms
; VERSION:
;	1.0
; PURPOSE:
;	To write a bathymetric grid data file.
; CALLING SEQUENCE:
;	Ncdf_WriteBath_Roms, fname, depths, lons, lats
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
  ; check the input "depths" array (depths of RHO points)
  If (N_Elements(depths) EQ 0) Then Message, "Must pass the <depths> argument."
  If (Where([7, 8, 10, 11] EQ Size(depths, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <depths>."
  If (Size(depths, /N_DIMENSIONS) NE 2) Then $
    Message, "<depths> must be a 2D array of values."

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

  xi_rho  = IPNTS
  xi_psi  = IPNTS - 1
  xi_u    = IPNTS - 1
  xi_v    = IPNTS
  eta_rho = JPNTS
  eta_psi = JPNTS - 1
  eta_u   = JPNTS
  eta_v   = JPNTS - 1

  ; water points have a mask of 1
  chk_msk = ChkForMask(mask, 1, WCELLSIDX, WCELLS, $
                       COMPLEMENT = LCELLSIDX, NCOMPLEMENT = LCELLS)

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


  ; ----- RHO-POINTS
  lon_rho = lons
  lat_rho = lats
  x_rho = lon_rho & x_rho[*] = 0 & y_rho = x_rho
  lons_ref = x_rho & lats_ref = x_rho

  ; get the xy Cartesian coordinates for the current projection
  xy = map_proj_forward(lon_rho[*], lat_rho[*], $
                        MAP_STRUCTURE = datSTRUCT)
  x_rho[*] = Transpose(xy[0, *])
  y_rho[*] = Transpose(xy[1, *])

  ; get the reference geodetic coordinates
  xy = vl_geodetic2xy([ Transpose(lat_rho[*]), Transpose(lon_rho[*]) ], $
                      EQUAT_RADIUS = datSemiMAJ, $
                      POLAR_RADIUS = datSemiMIN)
  xy = vl_xy2geodetic(xy, $
                      EQUAT_RADIUS = refSemiMAJ, $
                      POLAR_RADIUS = refSemiMIN)
  lons_ref[*] = Transpose(xy[1, *])
  lats_ref[*] = Transpose(xy[0, *])
  undefine, xy

  ; ----- LATS/LONS AT PSI-POINTS
  lon_psi = Rho2UVP_Points(lon_rho, /PLOC)
  lat_psi = Rho2UVP_Points(lat_rho, /PLOC)

  ; ----- LATS/LONS AT U-POINTS
  lon_u = Rho2UVP_Points(lon_rho, /ULOC)
  lat_u = Rho2UVP_Points(lat_rho, /ULOC)

  ; ----- LATS/LONS AT V-POINTS
  lon_v = Rho2UVP_Points(lon_rho, /VLOC)
  lat_v = Rho2UVP_Points(lat_rho, /VLOC)

  ; ----- CELL AREAS AND X_U/Y_U, X_V/Y_V, X_PSI/Y_PSI
  ;       VALUES (the X_*/Y_* values can also be calculated
  ;       using directly the Rho2UVP function)
  area_rho = AreaRho_Roms(x_rho, y_rho,       $
                          XU = x_u, YU = y_u, $
                          XV = x_v, YV = y_v, $
                          XP = x_psi, YP = y_psi)

  ; ----- DOMAIN STATS
  Get_DomainStats, lon_rho, /XDIR, $
                   MIN_VAL = LON_MIN, MAX_VAL = LON_MAX, $
                   AVE_VAL = LON_MEAN, $
                   DMIN_VAL = DLON_MIN, DMAX_VAL = DLON_MAX, $
                   DAVE_VAL = DLON_MEAN
  Get_DomainStats, lat_rho, /YDIR, $
                   MIN_VAL = LAT_MIN, MAX_VAL = LAT_MAX, $
                   AVE_VAL = LAT_MEAN, $
                   DMIN_VAL = DLAT_MIN, DMAX_VAL = DLAT_MAX, $
                   DAVE_VAL = DLAT_MEAN
  Get_DomainStats, x_rho, /XDIR, $
                   MIN_VAL = X_MIN, MAX_VAL = X_MAX, $
                   AVE_VAL = X_MEAN, $
                   DARR = dx_rho, $
                   DMIN_VAL = DX_MIN, DMAX_VAL = DX_MAX, $
                   DAVE_VAL = DX_MEAN
  Get_DomainStats, y_rho, /YDIR, $
                   MIN_VAL = Y_MIN, MAX_VAL = Y_MAX, $
                   AVE_VAL = Y_MEAN, $
                   DARR = dy_rho, $
                   DMIN_VAL = DY_MIN, DMAX_VAL = DY_MAX, $
                   DAVE_VAL = DY_MEAN

  ; ----- DX/DY
  dx_len = x_rho & dx_len[*] = 0
  dy_len = dx_len
  difX  = x_rho[1:IPNTS - 1, *] - x_rho[0:IPNTS - 2, *]
  difY  = y_rho[1:IPNTS - 1, *] - y_rho[0:IPNTS - 2, *]
  dx_len[1:IPNTS - 1, *] = sqrt(difX * difX + difY * difY)
  dx_len[0, *] = dx_len[1, *]
  
  difX  = x_rho[*, 1:JPNTS - 1] - x_rho[*, 0:JPNTS - 2]
  difY  = y_rho[*, 1:JPNTS - 1] - y_rho[*, 0:JPNTS - 2]
  dy_len[*, 1:JPNTS - 1] = sqrt(difX * difX + difY * difY)
  dy_len[*, 0] = dy_len[*, 1]

  ; ----- DOMAIN SIZE (in meters)
  xl = Max(x_rho, /NAN) - Min(x_rho, /NAN)
  el = Max(y_rho, /NAN) - Min(y_rho, /NAN)

  ; ----- TOPOGRAPHY H GRID AND BOTTOM STIFFNESS PARAMETER
  h = depths
  h[LCELLSIDX] = 0
  h[WCELLSIDX] = ZeroFloatFix( Abs(h[WCELLSIDX]) )

  ; determine a minimum water depth
  hmin = Min(h[WCELLSIDX], MAX = hmax)
  h[LCELLSIDX] = hmin ; for ROMS

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
        h[LCELLSIDX] = hmin
      EndIf Else Begin
        idx = Where(h[WCELLSIDX] LE dep_min, icnt)
        If (icnt NE 0) Then h[WCELLSIDX[idx]] = dep_min
        ; re-assign the land depth value from zero to
        ; max(min h, dep_min) > 0.0 (ROMS wants this)
        hmin = Min(h[WCELLSIDX], MAX = hmax)
        h[LCELLSIDX] = hmin
      EndElse
    EndIf
  EndIf

  ; bottom stiffness parameter
  rx = Stiff_Bottom(h, mask)

  ; ----- pn = 1/dy, pm = 1/dx (m^-1)
  pm = 1.0 / dx_len
  pn = 1.0 / dy_len

  ; ----- 
  ; compute dmde=change in dx(1/pm - ROMS uses m for dx) with y (eta)
  ; and dndx=change in dy (1/pn) with x
  ; compute only for interior points and use centered diff. like seagrid does?
  dmde = dx_len & dmde[*] = 0 & dndx = dmde

  dmde[1:IPNTS-1, 1:JPNTS-2] = 0.5 * (dx_len[1:IPNTS-1, 2:JPNTS-1] - dx_len[1:IPNTS-1, 0:JPNTS-3])
  dmde[*, 1] = 0
  dmde[*, JPNTS-1] = 0
  dmde[1, *] = 0
  dmde[IPNTS-1, *] = 0

  dndx[1:IPNTS-2, 1:JPNTS-1] = 0.5 * (dy_len[2:IPNTS-1, 1:JPNTS-1] - dy_len[0:IPNTS-3, 1:JPNTS-1])
  dndx[*, 1] = 0
  dndx[*, JPNTS-1] = 0
  dndx[1, *] = 0
  dndx[IPNTS-1, *] = 0

  ; ----- coriolis parameter values (as calculated at the rho points)
  ; %s-1   A.E.Gill p.597
  OMEGA = 7.292d-5
  cori = 2.0 * OMEGA * sin(lat_rho * !DTOR)

  ; ----- rotation angle values (as calculated at the rho points)
  angle = 0.0d

  ; ----- land/sea masks
  mask_rho = mask
  mask_rho[WCELLSIDX] = 1
  mask_rho[LCELLSIDX] = 0

  ; mask_u, mask at u points
  mask_u = UVP_Mask(mask_rho, /ULOC)

  ; mask_v, mask at v points
  mask_v = UVP_Mask(mask_rho, /VLOC)

  ; mask_psi, mask at psi points
  mask_psi = UVP_Mask(mask_rho, /PLOC)

  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ; PRINT THE RESULTS
  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Print, 'Writting the data to the output file: ' + fname

  ncid = ncdf_create(fname, /CLOBBER)

    ncdf_control, ncid, /FILL

      ; ---------- define and set the dimensions
      did_three   = ncdf_dimdef(ncid, 'three',  3)
      did_xi_rho  = ncdf_dimdef(ncid, 'xi_rho',  xi_rho )
      did_xi_psi  = ncdf_dimdef(ncid, 'xi_psi',  xi_psi )
      did_xi_u    = ncdf_dimdef(ncid, 'xi_u',    xi_u   )
      did_xi_v    = ncdf_dimdef(ncid, 'xi_v',    xi_v   )
      did_eta_rho = ncdf_dimdef(ncid, 'eta_rho', eta_rho)
      did_eta_psi = ncdf_dimdef(ncid, 'eta_psi', eta_psi)
      did_eta_u   = ncdf_dimdef(ncid, 'eta_u',   eta_u  )
      did_eta_v   = ncdf_dimdef(ncid, 'eta_v',   eta_v  )
      did_bath    = ncdf_dimdef(ncid, 'bath', /UNLIMITED)

      ; ---------- define the DATA variables
      varid = ncdf_vardef(ncid, 'spherical', /CHAR)
      ncdf_attput, ncid, varid, 'long_name', 'Grid type logical switch', /CHAR
      ncdf_attput, ncid, varid, 'option_T', 'spherical', /CHAR
      ncdf_attput, ncid, varid, 'option_F', 'Cartesian', /CHAR

      varid = ncdf_vardef(ncid, 'xl', /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'domain length in the XI-direction', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR

      varid = ncdf_vardef(ncid, 'el', /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'domain length in the ETA-direction', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR

      varid = ncdf_vardef(ncid, 'hraw', [did_xi_rho, did_eta_rho, did_bath], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'Working bathymetry at RHO-points', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'depth', /CHAR

      varid = ncdf_vardef(ncid, 'h', [did_xi_rho, did_eta_rho], /DOUBLE)
        tmpVAL = [hmin, hmax]
      ncdf_attput, ncid, varid, 'long_name', 'Final bathymetry at RHO-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'depth', /CHAR

      varid = ncdf_vardef(ncid, 'f', [did_xi_rho, did_eta_rho], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'Coriolis parameter of RHO-points', /CHAR
      ncdf_attput, ncid, varid, 'units', 'second-1', /CHAR

      varid = ncdf_vardef(ncid, 'pm', [did_xi_rho, did_eta_rho], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'curvilinear coordinate metric in XI', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter-1', /CHAR

      varid = ncdf_vardef(ncid, 'pn', [did_xi_rho, did_eta_rho], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'curvilinear coordinate metric in ETA', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter-1', /CHAR

      varid = ncdf_vardef(ncid, 'dndx', [did_xi_rho, did_eta_rho], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'xi derivative of inverse metric factor pn', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR

      varid = ncdf_vardef(ncid, 'dmde', [did_xi_rho, did_eta_rho], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'eta derivative of inverse metric factor pm', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'x_rho', [did_xi_rho, did_eta_rho], /DOUBLE)
        tmpVAL = [X_MIN, X_MAX]
      ncdf_attput, ncid, varid, 'long_name', 'x location of RHO-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'x_location', /CHAR

      varid = ncdf_vardef(ncid, 'y_rho', [did_xi_rho, did_eta_rho], /DOUBLE)
        tmpVAL = [Y_MIN, Y_MAX]
      ncdf_attput, ncid, varid, 'long_name', 'y location of RHO-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'y_location', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'x_psi', [did_xi_psi, did_eta_psi], /DOUBLE)
        tmpVAL = [Min(x_psi, /NAN), Max(x_psi, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'x location of PSI-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'x_location', /CHAR

      varid = ncdf_vardef(ncid, 'y_psi', [did_xi_psi, did_eta_psi], /DOUBLE)
        tmpVAL = [Min(y_psi, /NAN), Max(y_psi, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'y location of PSI-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'y_location', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'x_u', [did_xi_u, did_eta_u], /DOUBLE)
        tmpVAL = [Min(x_u, /NAN), Max(x_u, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'x location of U-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'x_location', /CHAR

      varid = ncdf_vardef(ncid, 'y_u', [did_xi_u, did_eta_u], /DOUBLE)
        tmpVAL = [Min(y_u, /NAN), Max(y_u, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'y location of U-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'y_location', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'x_v', [did_xi_v, did_eta_v], /DOUBLE)
        tmpVAL = [Min(x_v, /NAN), Max(x_v, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'x location of V-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'x_location', /CHAR

      varid = ncdf_vardef(ncid, 'y_v', [did_xi_v, did_eta_v], /DOUBLE)
        tmpVAL = [Min(y_v, /NAN), Max(y_v, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'y location of V-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'meter', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'y_location', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'lat_rho', [did_xi_rho, did_eta_rho], /DOUBLE)
        tmpVAL = [LAT_MIN, LAT_MAX]
      ncdf_attput, ncid, varid, 'long_name', 'latitude of RHO-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'degree_north', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR

      varid = ncdf_vardef(ncid, 'lon_rho', [did_xi_rho, did_eta_rho], /DOUBLE)
        tmpVAL = [LON_MIN, LON_MAX]
      ncdf_attput, ncid, varid, 'long_name', 'longitude of RHO-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'degree_east', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'lat_psi', [did_xi_psi, did_eta_psi], /DOUBLE)
        tmpVAL = [Min(lat_psi, /NAN), Max(lat_psi, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'latitude of PSI-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'degree_north', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR

      varid = ncdf_vardef(ncid, 'lon_psi', [did_xi_psi, did_eta_psi], /DOUBLE)
        tmpVAL = [Min(lon_psi, /NAN), Max(lon_psi, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'longitude of PSI-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'degree_east', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'lat_u', [did_xi_u, did_eta_u], /DOUBLE)
        tmpVAL = [Min(lat_u, /NAN), Max(lat_u, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'latitude of U-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'degree_north', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR

      varid = ncdf_vardef(ncid, 'lon_u', [did_xi_u, did_eta_u], /DOUBLE)
        tmpVAL = [Min(lon_u, /NAN), Max(lon_u, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'longitude of U-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'degree_east', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'lat_v', [did_xi_v, did_eta_v], /DOUBLE)
        tmpVAL = [Min(lat_v, /NAN), Max(lat_v, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'latitude of V-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'degree_north', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR

      varid = ncdf_vardef(ncid, 'lon_v', [did_xi_v, did_eta_v], /DOUBLE)
        tmpVAL = [Min(lon_v, /NAN), Max(lon_v, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'longitude of V-points', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'degree_east', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'angle', [did_xi_rho, did_eta_rho], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'angle between XI-axis and EAST', /CHAR
      ncdf_attput, ncid, varid, 'units', 'radians', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'angle', /CHAR

      ; ---------- masks
      varid = ncdf_vardef(ncid, 'mask_rho', [did_xi_rho, did_eta_rho], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'mask on RHO-points', /CHAR
      ncdf_attput, ncid, varid, 'flag_values', [0.0, 1.0], /DOUBLE
      ncdf_attput, ncid, varid, 'flag_meanings', 'land water', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'mask', /CHAR

      varid = ncdf_vardef(ncid, 'mask_u', [did_xi_u, did_eta_u], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'mask on U-points', /CHAR
      ncdf_attput, ncid, varid, 'flag_values', [0.0, 1.0], /DOUBLE
      ncdf_attput, ncid, varid, 'flag_meanings', 'land water', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'mask', /CHAR

      varid = ncdf_vardef(ncid, 'mask_v', [did_xi_v, did_eta_v], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'mask on V-points', /CHAR
      ncdf_attput, ncid, varid, 'flag_values', [0.0, 1.0], /DOUBLE
      ncdf_attput, ncid, varid, 'flag_meanings', 'land water', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'mask', /CHAR

      varid = ncdf_vardef(ncid, 'mask_psi', [did_xi_psi, did_eta_psi], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'mask on PSI-points', /CHAR
      ncdf_attput, ncid, varid, 'flag_values', [0.0, 1.0], /DOUBLE
      ncdf_attput, ncid, varid, 'flag_meanings', 'land water', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'mask', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'lat_ref', [did_xi_rho, did_eta_rho], /DOUBLE)
        tmpVAL = [Min(lats_ref, /NAN), Max(lats_ref, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'latitude of RHO-points' + $
        ' (referenced to: ' + refHDATUM + ')', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'degree_north', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'latitude', /CHAR

      varid = ncdf_vardef(ncid, 'lon_ref', [did_xi_rho, did_eta_rho], /DOUBLE)
        tmpVAL = [Min(lons_ref, /NAN), Max(lons_ref, /NAN)]
      ncdf_attput, ncid, varid, 'long_name', 'longitude of RHO-points' + $
        ' (referenced to: ' + refHDATUM + ')', /CHAR
      ncdf_attput, ncid, varid, 'range', tmpVAL, /DOUBLE
      ncdf_attput, ncid, varid, 'units', 'degree_east', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'longitude', /CHAR

      ; ----------
      varid = ncdf_vardef(ncid, 'area_rho', [did_xi_rho, did_eta_rho], /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'cell area at RHO-points', /CHAR
      ncdf_attput, ncid, varid, 'units', 'meter2', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'area', /CHAR
        tmpVAL = strtrim(string(total(area_rho[LCELLSIDX] / 1.0d+6, /NAN), format = '(f16.3)'), 2) + ' km2'
      ncdf_attput, ncid, varid, 'total_land', tmpVAL, /CHAR
        tmpVAL = strtrim(string(total(area_rho[WCELLSIDX] / 1.0d+6, /NAN), format = '(f16.3)'), 2) + ' km2'
      ncdf_attput, ncid, varid, 'total_water', tmpVAL, /CHAR
      ; ----------
      varid = ncdf_vardef(ncid, 'rx', did_three, /DOUBLE)
      ncdf_attput, ncid, varid, 'long_name', 'Beckman and Haidvogel bottom stiffness parameters', /CHAR
      ncdf_attput, ncid, varid, 'element_1', 'maximum', /CHAR
      ncdf_attput, ncid, varid, 'element_2', 'minimum', /CHAR
      ncdf_attput, ncid, varid, 'element_3', 'average', /CHAR
      ncdf_attput, ncid, varid, 'units', 'dimensionless', /CHAR
      ncdf_attput, ncid, varid, 'standard_name', 'stiffness parameter', /CHAR

      ; ---------- define the GLOBAL variables
      Ncdf_PutGlobal, ncid, 'Conventions', 'CF-1.1'

      if (n_elements(title) ne 0) then begin
        Ncdf_PutGlobal, ncid, 'title', strtrim(string(title), 2)
      endif else begin
        res_str = '1/' + strtrim(string(fix(1.0/DLON_MEAN)), 2)
        res_str = '(resolution: ' + res_str + ' degrees)'
        Ncdf_PutGlobal, ncid, 'title', 'Gulf of Mexico Bathymetry ' + res_str
      endelse

      if (n_elements(type) ne 0) then begin
        Ncdf_PutGlobal, ncid, 'type', strtrim(string(type), 2)
      endif else begin
        Ncdf_PutGlobal, ncid, 'type', 'Gridded Bathymetry'
      endelse

      Ncdf_PutGlobal, ncid, 'institution', string(10B) + CoapsAddress()
      Ncdf_PutGlobal, ncid, 'contact', 'pvelissariou@fsu.edu'

      Ncdf_PutGlobal, ncid, 'bath_file', File_Basename(fname)

      Ncdf_PutGlobal_Devel, ncid

      res_str    = StrTrim(String(DLON_MEAN, format = '(f10.7)'), 2) + ' x ' + $
                     StrTrim(String(DLAT_MEAN, format = '(f10.7)'), 2) + ' (degrees)'
      res_str_xy = StrTrim(String(DX_MEAN, format = '(f10.3)'), 2) + ' x ' + $
                     StrTrim(String(DY_MEAN, format = '(f10.3)'), 2) + ' (m)'

      ncdf_attput,  ncid, $
         'resolution', res_str, /GLOBAL, /CHAR

      ncdf_attput,  ncid, $
         'resolution_xy', res_str_xy, /GLOBAL, /CHAR

      ; ----- ELLIPSOID IN USE
      ncdf_attput, ncid, $
         'projection', datPROJ, /GLOBAL, /CHAR

      ncdf_attput, ncid, $
         'projection_name', datPROJ_NAM, /GLOBAL, /CHAR

      ncdf_attput, ncid, $
         'horizontal_datum', datHDATUM, /GLOBAL, /CHAR

      ncdf_attput, ncid, $
         'vertical_datum', datVDATUM, /GLOBAL, /CHAR

      ncdf_attput, ncid, $
         'radius', datRADIUS, /GLOBAL, /DOUBLE

      ncdf_attput, ncid, $
         'semi_minor_axis', datSemiMIN, /GLOBAL, /DOUBLE

      ncdf_attput, ncid, $
         'semi_major_axis', datSemiMAJ, /GLOBAL, /DOUBLE

      ncdf_attput, ncid, $
         'center_longitude', datCLON, /GLOBAL, /DOUBLE

      ncdf_attput, ncid, $
         'center_latitude', datCLAT, /GLOBAL, /DOUBLE

      ncdf_attput, ncid, $
         'true_scale_latitude', datTLAT, /GLOBAL, /DOUBLE

      ; ----- STANDARD/REFERENCE ELLIPSOID

      ncdf_attput, ncid, $
         'ref_projection', refPROJ, /GLOBAL, /CHAR

      ncdf_attput, ncid, $
         'ref_projection_name', refPROJ_NAM, /GLOBAL, /CHAR

      ncdf_attput, ncid, $
         'ref_horizontal_datum', refHDATUM, /GLOBAL, /CHAR

      ncdf_attput, ncid, $
         'ref_vertical_datum', refVDATUM, /GLOBAL, /CHAR

      ncdf_attput, ncid, $
         'ref_radius', refRADIUS, /GLOBAL, /DOUBLE

      ncdf_attput, ncid, $
         'ref_semi_minor_axis', refSemiMIN, /GLOBAL, /DOUBLE

      ncdf_attput, ncid, $
         'ref_semi_major_axis', refSemiMAJ, /GLOBAL, /DOUBLE

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

  ncid = ncdf_open(fname, /WRITE)

    ;-------------------------------------------------
    ; coordinate system
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'spherical')
    ncdf_varput, ncid, varid, 'T'

    ;-------------------------------------------------
    ; domain size in meters
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'xl')
    ncdf_varput, ncid, varid, xl
      varid = ncdf_varid(ncid, 'el')
    ncdf_varput, ncid, varid, el

    ;-------------------------------------------------
    ; topography h grid
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'h')
    ncdf_varput, ncid, varid, h

    ;-------------------------------------------------
    ; pn and pm
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'pm')
    ncdf_varput, ncid, varid, pm
      varid = ncdf_varid(ncid, 'pn')
    ncdf_varput, ncid, varid, pn

    ;-------------------------------------------------
    ; dmde and dndx
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'dmde')
    ncdf_varput, ncid, varid, dmde
      varid = ncdf_varid(ncid, 'dndx')
    ncdf_varput, ncid, varid, dndx

    ;-------------------------------------------------
    ; Cartesian coordinates
    ;-------------------------------------------------
    ; x/y values at the pressure/rho points (center of the grid cell)
      varid = ncdf_varid(ncid, 'x_rho')
    ncdf_varput, ncid, varid, x_rho

      varid = ncdf_varid(ncid, 'y_rho')
    ncdf_varput, ncid, varid, y_rho

    ; x/y values at the corner points
      varid = ncdf_varid(ncid, 'x_psi')
    ncdf_varput, ncid, varid, x_psi

      varid = ncdf_varid(ncid, 'y_psi')
    ncdf_varput, ncid, varid, y_psi

    ; x/y values at the u points (midpoints at the west-east grid cell faces)
      varid = ncdf_varid(ncid, 'x_u')
    ncdf_varput, ncid, varid, x_u

      varid = ncdf_varid(ncid, 'y_u')
    ncdf_varput, ncid, varid, y_u

    ; x/y values at the v points (midpoints at the south-north grid cell faces)
      varid = ncdf_varid(ncid, 'x_v')
    ncdf_varput, ncid, varid, x_v

      varid = ncdf_varid(ncid, 'y_v')
    ncdf_varput, ncid, varid, y_v

    ;-------------------------------------------------
    ; geographic coordinates
    ;-------------------------------------------------
    ; lat/lon values at the pressure/rho points (center of the grid cell)
      varid = ncdf_varid(ncid, 'lon_rho')
    ncdf_varput, ncid, varid, lon_rho

      varid = ncdf_varid(ncid, 'lat_rho')
    ncdf_varput, ncid, varid, lat_rho

    ; lat/lon values at the pressure/rho points (referenced to WGS ellipsoid)
      varid = ncdf_varid(ncid, 'lon_ref')
    ncdf_varput, ncid, varid, lons_ref

      varid = ncdf_varid(ncid, 'lat_ref')
    ncdf_varput, ncid, varid, lats_ref

    ; lat/lon values at the corner points
      varid = ncdf_varid(ncid, 'lon_psi')
    ncdf_varput, ncid, varid, lon_psi

      varid = ncdf_varid(ncid, 'lat_psi')
    ncdf_varput, ncid, varid, lat_psi

    ; lat/lon values at the u points (midpoints at the west-east grid cell faces)
      varid = ncdf_varid(ncid, 'lon_u')
    ncdf_varput, ncid, varid, lon_u

      varid = ncdf_varid(ncid, 'lat_u')
    ncdf_varput, ncid, varid, lat_u

    ; lat/lon values at the v points (midpoints at the south-north grid cell faces)
      varid = ncdf_varid(ncid, 'lon_v')
    ncdf_varput, ncid, varid, lon_v

      varid = ncdf_varid(ncid, 'lat_v')
    ncdf_varput, ncid, varid, lat_v

    ;-------------------------------------------------
    ; coriolis parameter
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'f')
    ncdf_varput, ncid, varid, cori

    ;-------------------------------------------------
    ; rotation angle
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'angle')
    ncdf_varput, ncid, varid, angle

    ;-------------------------------------------------
    ; land/sea masks
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'mask_rho')
    ncdf_varput, ncid, varid, mask_rho

      varid = ncdf_varid(ncid, 'mask_u')
    ncdf_varput, ncid, varid, mask_u

      varid = ncdf_varid(ncid, 'mask_v')
    ncdf_varput, ncid, varid, mask_v

      varid = ncdf_varid(ncid, 'mask_psi')
    ncdf_varput, ncid, varid, mask_psi

    ;-------------------------------------------------
    ; cell areas
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'area_rho')
    ncdf_varput, ncid, varid, area_rho

    ;-------------------------------------------------
    ; RX parameters
    ;-------------------------------------------------
      varid = ncdf_varid(ncid, 'rx')
    ncdf_varput, ncid, varid, rx

  ncdf_close, ncid

end
