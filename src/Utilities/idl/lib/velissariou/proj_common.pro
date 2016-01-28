;----------------------------------------
; Common variables
COMMON SepChars, DIR_SEP, PATH_SEP

; ----- COMMON ProjDirs
; Parameters
;     rootDIR = the top directory for the project
;     bathDIR = the directory where the bathymetry data files are stored for the project
;      binDIR = the directory where the programs/utilities are stored for the project
;     currDIR = the directory where the current data files are stored for the project
; freesurfDIR = the directory where the free surface data files are stored for the project
;     elevDIR = the directory where the water level data files are stored for the project
;      imgDIR = the directory where the images are stored for the project
;      inpDIR = the directory where the input data files are stored for the project
;   interpDIR = the directory where the interpolation data files are stored for the project
;      libDIR = the directory where the libraries/procedures are stored for the project
;   marobsDIR = the directory where the marobs data files are stored for the project
;     miscDIR = the directory where the bathymetry files are stored for the project
;      outDIR = the directory where the output data files are stored for the project
;     plotDIR = the directory where the output plots are stored for the project
;   scriptDIR = the directory where the various scripts are stored for the project
;     waveDIR = the directory where the wave related data files are stored for the project
;     rootIDL = the top idl directory for the project
;      tmpDIR = /tmp
;     tmpFILE = the tmp file in tmpDIR for the project
; For the Great Lakes these variables are established by calling the
; ReadGrid procedure. In any other case these have to be established
; by a calling unit
COMMON ProjDirs, rootDIR, bathDIR, binDIR, currDIR, freesurfDIR, elevDIR, $
                 imgDIR, inpDIR, interpDIR, libDIR, marobsDIR, miscDIR, outDIR, $
                 plotDIR, scriptDIR, sedDIR, srcDIR, waveDIR, rootIDL, $
                 tmpDIR, tmpFILE

; ----- COMMON WrfGridParams
; These variables are established by calling the "Ncdf_Wrf_ReadGrid" procedure.
COMMON WrfGridParams, $
                   ;
                   WRF_IPNTS, WRF_JPNTS, WRF_TCELLS,                     $
                   WRF_WCELLS, WRF_WCELLSIDX, WRF_LCELLS, WRF_LCELLSIDX, $
                   WRF_IPNTS_STAG, WRF_JPNTS_STAG,                       $
                   ;
                   WRF_mgrid,                                            $
                   WRF_SINALPHA, WRF_COSALPHA,                           $
                   ;
                   WRF_longrid, WRF_latgrid,                             $
                   WRF_LON_MIN, WRF_LON_MAX, WRF_LON_MEAN,               $
                   WRF_LAT_MIN, WRF_LAT_MAX, WRF_LAT_MEAN,               $
                   WRF_longrid_u, WRF_latgrid_u,                         $
                   WRF_longrid_v, WRF_latgrid_v,                         $
                   ;
                   WRF_dlongrid, WRF_dlatgrid,                           $
                   WRF_DLON_MIN, WRF_DLON_MAX, WRF_DLON_MEAN,            $
                   WRF_DLAT_MIN, WRF_DLAT_MAX, WRF_DLAT_MEAN,            $
                   ;
                   WRF_xgrid, WRF_ygrid,                                 $
                   WRF_X_MIN, WRF_X_MAX, WRF_X_MEAN,                     $
                   WRF_Y_MIN, WRF_Y_MAX, WRF_Y_MEAN,                     $
                   ;
                   WRF_dxgrid, WRF_dygrid,                               $
                   WRF_DX_MIN, WRF_DX_MAX, WRF_DX_MEAN,                  $
                   WRF_DY_MIN, WRF_DY_MAX, WRF_DY_MEAN,                  $
                   ;
                   WRF_MapStruct,                                        $
                   WRF_PROJ, WRF_PROJ_NAM, WRF_HDATUM, WRF_VDATUM,       $
                   WRF_RADIUS, WRF_SemiMIN, WRF_SemiMAJ,                 $
                   WRF_CENT_LON, WRF_CENT_LAT, WRF_STAND_LON,            $
                   WRF_TRUELAT1, WRF_TRUELAT2

; ----- COMMON WrfFlowParams
; These variables are established by calling the "Ncdf_Cfsr_ReadGrid" procedure.
COMMON WrfFlowParams, $
                   wrf_times, $
                   wrf_hgt,      wrf_hgt_fill,      wrf_hgt_units,      wrf_hgt_desc,      $
                   wrf_psfc,     wrf_psfc_fill,     wrf_psfc_units,     wrf_psfc_desc,     $
                   wrf_u10,      wrf_u10_fill,      wrf_u10_units,      wrf_u10_desc,      $
                   wrf_v10,      wrf_v10_fill,      wrf_v10_units,      wrf_v10_desc,      $
                   wrf_hwave,    wrf_hwave_fill,    wrf_hwave_units,    wrf_hwave_desc,    $
                   wrf_pwave,    wrf_pwave_fill,    wrf_pwave_units,    wrf_pwave_desc,    $
                   wrf_lwavep,   wrf_lwavep_fill,   wrf_lwavep_units,   wrf_lwavep_desc,   $
                   wrf_cldfra,   wrf_cldfra_fill,   wrf_cldfra_units,   wrf_cldfra_desc,   $
                   wrf_albedo,   wrf_albedo_fill,   wrf_albedo_units,   wrf_albedo_desc,   $
                   wrf_rainc,    wrf_rainc_fill,    wrf_rainc_units,    wrf_rainc_desc,    $
                   wrf_rainnc,   wrf_rainnc_fill,   wrf_rainnc_units,   wrf_rainnc_desc,   $
                   wrf_tair,     wrf_tair_fill,     wrf_tair_units,     wrf_tair_desc,     $
                   wrf_tpot,     wrf_tpot_fill,     wrf_tpot_units,     wrf_tpot_desc,     $
                   wrf_sst,      wrf_sst_fill,      wrf_sst_units,      wrf_sst_desc,      $
                   wrf_sstsk,    wrf_sstsk_fill,    wrf_sstsk_units,    wrf_sstsk_desc,    $
                   wrf_tsk,      wrf_tsk_fill,      wrf_tsk_units,      wrf_tsk_desc,      $
                   wrf_q2,       wrf_q2_fill,       wrf_q2_units,       wrf_q2_desc,       $
                   wrf_emiss,    wrf_emiss_fill,    wrf_emiss_units,    wrf_emiss_desc,    $
                   wrf_grdflx,   wrf_grdflx_fill,   wrf_grdflx_units,   wrf_grdflx_desc,   $
                   wrf_acgrdflx, wrf_acgrdflx_fill, wrf_acgrdflx_units, wrf_acgrdflx_desc, $
                   wrf_hfx,      wrf_hfx_fill,      wrf_hfx_units,      wrf_hfx_desc,      $
                   wrf_qfx,      wrf_qfx_fill,      wrf_qfx_units,      wrf_qfx_desc,      $
                   wrf_swdown,   wrf_swdown_fill,   wrf_swdown_units,   wrf_swdown_desc,   $
                   wrf_gsw,      wrf_gsw_fill,      wrf_gsw_units,      wrf_gsw_desc,      $
                   wrf_glw,      wrf_glw_fill,      wrf_glw_units,      wrf_glw_desc,      $
                   wrf_olr,      wrf_olr_fill,      wrf_olr_units,      wrf_olr_desc,      $
                   wrf_lh,       wrf_lh_fill,       wrf_lh_units,       wrf_lh_desc,       $
                   wrf_achfx,    wrf_achfx_fill,    wrf_achfx_units,    wrf_achfx_desc,    $
                   wrf_aclhf,    wrf_aclhf_fill,    wrf_aclhf_units,    wrf_aclhf_desc

; ----- COMMON CfsrGridParams
; These variables are established by calling the "Ncdf_Cfsr_ReadGrid" procedure.
COMMON CfsrGridParams, $
                   ;
                   CFSR_IPNTS, CFSR_JPNTS, CFSR_TCELLS,                      $
                   CFSR_WCELLS, CFSR_WCELLSIDX, CFSR_LCELLS, CFSR_LCELLSIDX, $
                   ;
                   CFSR_mgrid,                                               $
                   ;
                   CFSR_longrid, CFSR_latgrid,                               $
                   CFSR_lon_ref, CFSR_lat_ref,                               $
                   CFSR_LON_MIN, CFSR_LON_MAX, CFSR_LON_MEAN,                $
                   CFSR_LAT_MIN, CFSR_LAT_MAX, CFSR_LAT_MEAN,                $
                   ;
                   CFSR_dlongrid, CFSR_dlatgrid,                             $
                   CFSR_DLON_MIN, CFSR_DLON_MAX, CFSR_DLON_MEAN,             $
                   CFSR_DLAT_MIN, CFSR_DLAT_MAX, CFSR_DLAT_MEAN,             $
                   ;
                   CFSR_xgrid, CFSR_ygrid,                                   $
                   CFSR_X_MIN, CFSR_X_MAX, CFSR_X_MEAN,                      $
                   CFSR_Y_MIN, CFSR_Y_MAX, CFSR_Y_MEAN,                      $
                   ;
                   CFSR_dxgrid, CFSR_dygrid,                                 $
                   CFSR_DX_MIN, CFSR_DX_MAX, CFSR_DX_MEAN,                   $
                   CFSR_DY_MIN, CFSR_DY_MAX, CFSR_DY_MEAN,                   $
                   ;
                   CFSR_MapStruct,                                           $
                   CFSR_PROJ, CFSR_PROJ_NAM, CFSR_HDATUM, CFSR_VDATUM,       $
                   CFSR_RADIUS, CFSR_SemiMIN, CFSR_SemiMAJ,                  $
                   CFSR_CENT_LON, CFSR_CENT_LAT, CFSR_STAND_LON,             $
                   CFSR_TRUELAT1, CFSR_TRUELAT2

; ----- COMMON CfsrFlowParams
; These variables are established by calling the "Ncdf_Cfsr_ReadGrid" procedure.
COMMON CfsrFlowParams, $
                   cfsr_times, $
                   cfsr_hgt,      cfsr_hgt_fill,      cfsr_hgt_units,      cfsr_hgt_desc,      $
                   cfsr_psfc,     cfsr_psfc_fill,     cfsr_psfc_units,     cfsr_psfc_desc,     $
                   cfsr_u10,      cfsr_u10_fill,      cfsr_u10_units,      cfsr_u10_desc,      $
                   cfsr_v10,      cfsr_v10_fill,      cfsr_v10_units,      cfsr_v10_desc,      $
                   cfsr_hwave,    cfsr_hwave_fill,    cfsr_hwave_units,    cfsr_hwave_desc,    $
                   cfsr_pwave,    cfsr_pwave_fill,    cfsr_pwave_units,    cfsr_pwave_desc,    $
                   cfsr_lwavep,   cfsr_lwavep_fill,   cfsr_lwavep_units,   cfsr_lwavep_desc,   $
                   cfsr_cldfra,   cfsr_cldfra_fill,   cfsr_cldfra_units,   cfsr_cldfra_desc,   $
                   cfsr_albedo,   cfsr_albedo_fill,   cfsr_albedo_units,   cfsr_albedo_desc,   $
                   cfsr_rainc,    cfsr_rainc_fill,    cfsr_rainc_units,    cfsr_rainc_desc,    $
                   cfsr_rainnc,   cfsr_rainnc_fill,   cfsr_rainnc_units,   cfsr_rainnc_desc,   $
                   cfsr_tair,     cfsr_tair_fill,     cfsr_tair_units,     cfsr_tair_desc,     $
                   cfsr_tpot,     cfsr_tpot_fill,     cfsr_tpot_units,     cfsr_tpot_desc,     $
                   cfsr_sst,      cfsr_sst_fill,      cfsr_sst_units,      cfsr_sst_desc,      $
                   cfsr_sstsk,    cfsr_sstsk_fill,    cfsr_sstsk_units,    cfsr_sstsk_desc,    $
                   cfsr_tsk,      cfsr_tsk_fill,      cfsr_tsk_units,      cfsr_tsk_desc,      $
                   cfsr_q2,       cfsr_q2_fill,       cfsr_q2_units,       cfsr_q2_desc,       $
                   cfsr_emiss,    cfsr_emiss_fill,    cfsr_emiss_units,    cfsr_emiss_desc,    $
                   cfsr_grdflx,   cfsr_grdflx_fill,   cfsr_grdflx_units,   cfsr_grdflx_desc,   $
                   cfsr_acgrdflx, cfsr_acgrdflx_fill, cfsr_acgrdflx_units, cfsr_acgrdflx_desc, $
                   cfsr_hfx,      cfsr_hfx_fill,      cfsr_hfx_units,      cfsr_hfx_desc,      $
                   cfsr_qfx,      cfsr_qfx_fill,      cfsr_qfx_units,      cfsr_qfx_desc,      $
                   cfsr_swdown,   cfsr_swdown_fill,   cfsr_swdown_units,   cfsr_swdown_desc,   $
                   cfsr_gsw,      cfsr_gsw_fill,      cfsr_gsw_units,      cfsr_gsw_desc,      $
                   cfsr_glw,      cfsr_glw_fill,      cfsr_glw_units,      cfsr_glw_desc,      $
                   cfsr_olr,      cfsr_olr_fill,      cfsr_olr_units,      cfsr_olr_desc,      $
                   cfsr_lh,       cfsr_lh_fill,       cfsr_lh_units,       cfsr_lh_desc,       $
                   cfsr_achfx,    cfsr_achfx_fill,    cfsr_achfx_units,    cfsr_achfx_desc,    $
                   cfsr_aclhf,    cfsr_aclhf_fill,    cfsr_aclhf_units,    cfsr_aclhf_desc

; ----- COMMON BathParams
; Parameters
;      lname = the lake name as obtained from the bathymetry file
;      iparm =
;      rparm =
;      dgrid = the lake bathymetry
;    longrid = the corresponding longitude values for the dgrid values
;    latgrid = the corresponding latitude values for the dgrid values
;      xgrid = the corresponding cartesian x-distance for the dgrid values
;      ygrid = the corresponding cartesian y-distance for the dgrid values
;     GridX0 = the most left point of the domain (x-origin), also (when in Great Lakes)
;                the x-offset of the model grid origin
;     GridY0 = the lower point of the domain (y-origin), also (when in Great Lakes)
;                the y-offset of the model grid origin
;     GridX1 = the most right point of the domain (x-end)
;     GridY1 = the upper point of the domain (y-end)
;    GridXSZ = the cell grid size in the x-direction
;    GridYSZ = the cell grid size in the y-direction
;      IPNTS = the total I grid points
;      JPNTS = the total J grid points
;     TCELLS = the total number of the grid cells
;     WCELLS = the total number of the wet grid cells
;  WCELLSIDX = the corresponding indeces in the IPNTS x JPNTS matrix
;              of the wet cells
;     LCELLS = the total number of the land grid cells
;  LCELLSIDX = the corresponding indeces in the IPNTS x JPNTS matrix
;              of the land cells
; For the Great Lakes these variables are established by calling the
; ReadGrid procedure. In any other case these have to be established
; by the calling unit
COMMON BathParams, lname, iparm, rparm,                                        $
                   GridX0, GridY0, GridX1, GridY1, GridXSZ, GridYSZ,           $
                   ;
                   IPNTS, JPNTS, TCELLS, WCELLS, WCELLSIDX, LCELLS, LCELLSIDX, $
                   ;
                   dgrid, mgrid,                                               $
                   DEPTH_MIN, DEPTH_MAX, DEPTH_MEAN,                           $
                   ELEV_MIN, ELEV_MAX, ELEV_MEAN,                              $
                   ;
                   longrid, latgrid,                                           $
                   LON_MIN, LON_MEAN, LON_MAX,                                 $
                   LAT_MIN, LAT_MEAN, LAT_MAX,                                 $
                   ;
                   dlongrid, dlatgrid,                                         $
                   DLON_MIN, DLON_MEAN, DLON_MAX,                              $
                   DLAT_MIN, DLAT_MEAN, DLAT_MAX,                              $
                   ;
                   xgrid, ygrid,                                               $
                   X_MIN, X_MEAN, X_MAX, Y_MIN, Y_MEAN, Y_MAX,                 $
                   ;
                   dxgrid, dygrid,                                             $
                   DX_MIN, DX_MAX, DY_MIN, DY_MAX,                             $
                   DX_MEAN, DY_MEAN,                                           $
                   ;
                   lon_ref, lat_ref,                                           $
                   REF_LON_MIN, REF_LON_MEAN, REF_LON_MAX,                     $
                   REF_LAT_MIN, REF_LAT_MEAN, REF_LAT_MAX,                     $
                   ;
                   dlon_ref, dlat_ref,                                         $
                   REF_DLON_MIN, REF_DLON_MEAN, REF_DLON_MAX,                  $
                   REF_DLAT_MIN, REF_DLAT_MEAN, REF_DLAT_MAX,                  $
                   ;
                   RFAC,                                                       $
                   ;
                   DEF_MapStruct,                                              $
                   DEF_PROJ, DEF_PROJ_NAM, DEF_HDATUM, DEF_VDATUM,             $
                   DEF_RADIUS, DEF_SemiMIN, DEF_SemiMAJ,                       $
                   DEF_CLON, DEF_CLAT, DEF_TLAT,                               $
                   ;
                   BATH_MapStruct,                                             $
                   BATH_PROJ, BATH_PROJ_NAM, BATH_HDATUM, BATH_VDATUM,         $
                   BATH_RADIUS, BATH_SemiMIN, BATH_SemiMAJ,                    $
                   BATH_CLON, BATH_CLAT, BATH_TLAT,                            $
                   ;
                   REF_MapStruct,                                              $
                   REF_PROJ, REF_PROJ_NAM, REF_HDATUM, REF_VDATUM,             $
                   REF_RADIUS, REF_SemiMIN, REF_SemiMAJ,                       $
                   REF_CLON, REF_CLAT, REF_TLAT,                               $

                   ; ----- Control Volume parameters
                   CVInit, CV_MAX, nCV, CV_struct, CV_arr,                     $
                   outCVstr, insCVstr, difCVstr,                               $

                   ; ----- HYCOM related
                   HC_NREC, HC_LANDMASK, HC_NPAD, HC_NPAD_VAL, HC_MAPFLG,      $
                   BBOXIDX, BBOXGEO,                                           $
                   IDIM, JDIM,                                                 $
                   ;
                   plon, plat, pscx, pscy,                                     $
                   PLON_MIN, PLON_MAX, PLAT_MIN, PLAT_MAX, PLON_IDX, PLAT_IDX, $
                   PSCX_MIN, PSCX_MAX, PSCY_MIN, PSCY_MAX, PSCX_IDX, PSCY_IDX, $
                   ;
                   qlon, qlat, qscx, qscy,                                     $
                   QLON_MIN, QLON_MAX, QLAT_MIN, QLAT_MAX, QLON_IDX, QLAT_IDX, $
                   QSCX_MIN, QSCX_MAX, QSCY_MIN, QSCY_MAX, QSCX_IDX, QSCY_IDX, $
                   ;
                   ulon, ulat, uscx, uscy,                                     $
                   ULON_MIN, ULON_MAX, ULAT_MIN, ULAT_MAX, ULON_IDX, ULAT_IDX, $
                   USCX_MIN, USCX_MAX, USCY_MIN, USCY_MAX, USCX_IDX, USCY_IDX, $
                   ;
                   vlon, vlat, vscx, vscy,                                     $
                   VLON_MIN, VLON_MAX, VLAT_MIN, VLAT_MAX, VLON_IDX, VLAT_IDX, $
                   VSCX_MIN, VSCX_MAX, VSCY_MIN, VSCY_MAX, VSCX_IDX, VSCY_IDX, $
                   ;
                   cori, anggrid,                                              $
                   CORI_MIN, CORI_MAX, CORI_MEAN, CORI_IDX,                    $
                   ;
                   pang,                                                       $
                   PANG_MIN, PANG_MAX, PANG_IDX,                               $
                   ;
                   pasp,                                                       $
                   PASP_MIN, PASP_MAX, PASP_IDX,                               $

                   ; ----- ROMS related
                   xi_rho, eta_rho, xi_psi, eta_psi, xi_u, eta_u, xi_v, eta_v, $
                   xl, el, pm, pn, dndx, dmde,                                 $
                   x_rho, y_rho, x_psi, y_psi, x_u, y_u, x_v, y_v,             $
                   lon_rho, lat_rho, lon_psi, lat_psi,                         $
                   lon_u, lat_u, lon_v, lat_v,                                 $
                   mask_rho, mask_psi, mask_u, mask_v, area_rho

COMMON FlowParams, RefTimeStr,                                                 $
                   ssh, ssh_fill, ssh_units,                                   $
                   vel_units,                                                  $
                   uvel, uvel_fill, ubar, ubar_fill,                           $
                   vvel, vvel_fill, vbar, vbar_fill,                           $
                   wvel, wvel_fill,                                            $
                   temp, temp_fill, temp_units,                                $
                   salt, salt_fill, salt_units,                                $
                   uwind, uwind_fill, uwind_units,                             $
                   vwind, vwind_fill, vwind_units,                             $

                   ; ----- HYCOM related
                   n_zdeps, zdeps,                                             $
                   MT,                                                         $

                   ; ----- ROMS related
                   Vtransform, Vstretching, theta_s, theta_b, Tcline, hc,      $
                   n_s_rho, s_rho, Cs_r, zdeps_rho,                            $
                   n_s_w, s_w, Cs_w, zdeps_w,                                  $
                   ocean_time

; ----- COMMON RESParams
;  Parameters
;   USE_RESOL =
;   GRID_FACT =
;     str_res =
;    str1_res =
;       RRDEF =
;    nBUFZONE =
; xtraBUFZONE =
COMMON RESParams, USE_RESOL, GRID_FACT, str_res, str1_res, gom_pfx, $
                  RRDEF, nBUFZONE, xtraBUFZONE, extnBUFZONE

; ----- COMMON GLParams
; Parameters
;      SIUNIT = flag to set the use of SI Units (0 = English, other = SI)
;  MASK_VAL = this value is used to mask array elements
;
; Next Great Lakes parameters
;      IGLD85 = the value of the chart datum for the corresponding lake
;  LOW_IGLD85 = the lowest value to be considered as a valid water level
; HIGH_IGLD85 = the highest value to be considered as a valid water level
;      NAVD88 = this value is the NAVD88 value for the datum for the G. Lake used
;
;  RegionName = the name of the region/area we are working on
;  RegionBath = the region/area bathymetry file
; RegionShore = the region/area shoreline file
;     MapProj = the map projection to be used
;      MapSet = a flag tthat denotes if the map has been initialized
;   MapCoords = the latitude, longitude of the lower and upper corners
;               of the map region that limits the lake
;   MapCenter = the latitude, longitude of the center of the map region
;               that limits the lake
;  PLOT_XSIZE = the X-size (in pixels) of the generated map plot for the lake
;  PLOT_YSIZE = the Y-size (in pixels) of the generated map plot for the lake
COMMON GLParams, SIUNIT, MASK_VAL, $
                 IGLD85, LOW_IGLD85, HIGH_IGLD85, NAVD88, $
                 RegionName, RegionBath, RegionShore, $
                 MapProj, MapSet, MapCoords, MapCenter, nMapLabs, MapDel, DLATLON, $
                 MapPlotBox, MapPlotAreaBox, $
                 PLOT_XSIZE, PLOT_YSIZE, PLOT_TYPE

; ----- COMMON PlotParams
; Plot Parameters
;    OldPlotDev = the old device
;       PlotDev = the device (possible values are 'PS' or, 'Z')
; DevResolution = the resolution of the device ([XSIZE, YSIZE])
;     DevStatus = the status of the device (0 = closed, 1 = opened)
;   DevPlotType = the plot type, one of:
;                 eps, ps, bmp, jpeg, jpg, png, ppm, srf, tiff, tif
;      pageInfo = the pageInfo structure from PSWINDOW
;      defColor = default color index for plotting
;      defThick = default thickness of the lines in the plot
;   defFontSize = default font size in pixels of the characters
;   defCharsize = default text size for plotting
;   RebinFactor = when plotting in 'Z' magnify the resolution by this
;                 factor, do the plotting and then scale back to original
;                 resolution (it is done because we get better looking
;                 fonts on the plot)
;      TextSize = defCharsize (assigned in the procedure InitProjPlots)
;  PlotTitleBox = the dimensions of the text box above the plot (title)
; PlotTitleText = the suggested dimensions of the text within the title box
;       PlotBox = the dimensions of the box containing the plot
;   PlotAreaBox = the dimensions of the plot area within the margins
COMMON PlotParams, OldPlotDev, PlotDev, DevResolution, DevStatus, DevPlotType, $
                   pageInfo, $
                   defColor, defThick, defFontSize, defCharsize, $
                   RebinFactor, TextSize,  $
                   PlotTitleBox, PlotTitleText, PlotBox, PlotAreaBox

; ----- Set some COMMON variables
HC_LANDMASK = 2.0 ^ 100.0
HC_NPAD_VAL = 2.0 ^ 100.0

DEF_PROJ     = 'Mercator'
DEF_PROJ_NAM = 'Mercator'
DEF_HDATUM   = 'Sphere'
DEF_VDATUM   = 'MSL/NAVD88'
DEF_SemiMAJ  = 6371001.0D ; HYCOM radius
DEF_SemiMIN  = DEF_SemiMAJ
DEF_RADIUS   = DEF_SemiMAJ

REF_PROJ     = 'Mercator'
REF_PROJ_NAM = 'Mercator'
REF_HDATUM   = 'GRS 1980/WGS 84'
REF_VDATUM   = 'MSL/NAVD88'
REF_SemiMAJ  = 6378137.0D
REF_SemiMIN  = 6356752.31414D
REF_RADIUS   = REF_SemiMAJ
