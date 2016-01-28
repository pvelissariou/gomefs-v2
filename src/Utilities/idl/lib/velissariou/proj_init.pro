PRO proj_init, ROOT_DIR =     root_dir,     $
               BATH_DIR =     bath_dir,     $
               BIN_DIR =      bin_dir,      $
               CURR_DIR =     curr_dir,     $
               FREESURF_DIR = freesurf_dir, $
               ELEV_DIR =     elev_dir,     $
               IMG_DIR =      img_dir,      $
               INP_DIR =      inp_dir,      $
               INTERP_DIR =   interp_dir,   $
               LIB_DIR =      lib_dir,      $
               MAROBS_DIR =   marobs_dir,   $
               MISC_DIR =     misc_dir,     $
               OUT_DIR =      out_dir,      $
               PLOT_DIR =     plot_dir,     $
               SCRIPT_DIR =   script_dir,   $
               SED_DIR =      sed_dir,      $
               SRC_DIR =      src_dir,      $
               WAVE_DIR =     wave_dir,     $
               ROOT_IDL =     root_idl
                 
  COMMON SepChars
  COMMON ProjDirs
  COMMON BathParams
  COMMON GLParams
  COMMON PlotParams

  ; ----- SepChars
  UNDEFINE, DIR_SEP, PATH_SEP
  ; ----- ProjDirs
  UNDEFINE, rootDIR, bathDIR, binDIR, currDIR, freesurfDIR, elevDIR, imgDIR, inpDIR
  UNDEFINE, interpDIR, libDIR, marobsDIR, miscDIR, outDIR, plotDIR, scriptDIR, sedDIR
  UNDEFINE, srcDIR, waveDIR, rootIDL, tmpDIR, tmpFILE
  ; ----- BathParams
  UNDEFINE, lname, iparm, rparm, dgrid, longrid, latgrid, xgrid, ygrid
  UNDEFINE, GridX0, GridY0, GridXSZ, GridYSZ, IPNTS, JPNTS, TCELLS, WCELLS
  UNDEFINE, WCELLSIDX, LCELLS, LCELLSIDX
  ; ----- GLParams
  UNDEFINE, SIUNIT, MASK_VAL, IGLD85, LOW_IGLD85, HIGH_IGLD85, NAVD88
  UNDEFINE, RegionName, RegionBath, RegionShore
  UNDEFINE, MapProj, MapSet, MapCoords, MapCenter, nMapLabs, MapDel
  UNDEFINE, PLOT_XSIZE, PLOT_YSIZE, PLOT_TYPE
  ; ----- PlotParams
  UNDEFINE, OldPlotDev, PlotDev, DevResolution, DevStatus, DevPlotType, pageInfo
  UNDEFINE, defColor, defThick, defFontSize, defCharsize, RebinFactor, TextSize
  UNDEFINE, PlotTitleBox, PlotTitleText, PlotBox, PlotAreaBox

  dirsep

; The root directory of this project.
  IF N_ELEMENTS(root_dir)     EQ 0 THEN  root_dir     = GetEnv('HOME')
  IF N_ELEMENTS(bath_dir)     EQ 0 THEN  bath_dir     = root_dir + DIR_SEP + 'bathymetry'
  IF N_ELEMENTS(bin_dir)      EQ 0 THEN  bin_dir      = root_dir + DIR_SEP + 'bin'
  IF N_ELEMENTS(curr_dir)     EQ 0 THEN  curr_dir     = root_dir + DIR_SEP + 'current'
  IF N_ELEMENTS(freesurf_dir) EQ 0 THEN  freesurf_dir = root_dir + DIR_SEP + 'freesurface'
  IF N_ELEMENTS(elev_dir)     EQ 0 THEN  elev_dir     = root_dir + DIR_SEP + 'wlevel'
  IF N_ELEMENTS(img_dir)      EQ 0 THEN  img_dir      = root_dir + DIR_SEP + 'images'
  IF N_ELEMENTS(inp_dir)      EQ 0 THEN  inp_dir      = root_dir + DIR_SEP + 'input'
  IF N_ELEMENTS(interp_dir)   EQ 0 THEN  interp_dir   = root_dir + DIR_SEP + 'interp'
  IF N_ELEMENTS(lib_dir)      EQ 0 THEN  lib_dir      = root_dir + DIR_SEP + 'lib'
  IF N_ELEMENTS(marobs_dir)   EQ 0 THEN  marobs_dir   = root_dir + DIR_SEP + 'marobs'
  IF N_ELEMENTS(misc_dir)     EQ 0 THEN  misc_dir     = root_dir + DIR_SEP + 'misc'
  IF N_ELEMENTS(out_dir)      EQ 0 THEN  out_dir      = root_dir + DIR_SEP + 'output'
  IF N_ELEMENTS(plot_dir)     EQ 0 THEN  plot_dir     = root_dir + DIR_SEP + 'plots'
  IF N_ELEMENTS(script_dir)   EQ 0 THEN  script_dir   = root_dir + DIR_SEP + 'scripts'
  IF N_ELEMENTS(sed_dir)      EQ 0 THEN  sed_dir      = root_dir + DIR_SEP + 'sediment'
  IF N_ELEMENTS(src_dir)      EQ 0 THEN  src_dir      = root_dir + DIR_SEP + 'src'
  IF N_ELEMENTS(wave_dir)     EQ 0 THEN  wave_dir     = root_dir + DIR_SEP + 'wave'
  IF N_ELEMENTS(root_idl)     EQ 0 THEN  root_idl     = root_dir + DIR_SEP + 'idl'

  rootDIR     = fixDIRname(root_dir)
  bathDIR     = fixDIRname(bath_dir)
  binDIR      = fixDIRname(bin_dir)
  currDIR     = fixDIRname(curr_dir)
  freesurfDIR = fixDIRname(freesurf_dir)
  elevDIR     = fixDIRname(elev_dir)
  imgDIR      = fixDIRname(img_dir)
  inpDIR      = fixDIRname(inp_dir)
  interpDIR   = fixDIRname(interp_dir)
  libDIR      = fixDIRname(lib_dir)
  marobsDIR   = fixDIRname(marobs_dir)
  miscDIR     = fixDIRname(misc_dir)
  outDIR      = fixDIRname(out_dir)
  plotDIR     = fixDIRname(plot_dir)
  scriptDIR   = fixDIRname(script_dir)
  sedDIR      = fixDIRname(sed_dir)
  srcDIR      = fixDIRname(src_dir)
  waveDIR     = fixDIRname(wave_dir)
  rootIDL     = fixDIRname(root_idl)

  if (strcmp(rootDIR,     'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, rootDIR
  if (strcmp(bathDIR,     'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, bathDIR
  if (strcmp(binDIR,      'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, binDIR
  if (strcmp(currDIR,     'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, currDIR
  if (strcmp(freesurfDIR, 'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, freesurfDIR
  if (strcmp(elevDIR,     'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, elevDIR
  if (strcmp(imgDIR,      'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, imgDIR
  if (strcmp(inpDIR,      'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, inpDIR
  if (strcmp(interpDIR,   'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, interpDIR
  if (strcmp(libDIR,      'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, libDIR
  if (strcmp(marobsDIR,   'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, marobsDIR
  if (strcmp(miscDIR,     'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, miscDIR
  if (strcmp(outDIR,      'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, outDIR
  if (strcmp(plotDIR,     'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, plotDIR
  if (strcmp(scriptDIR,   'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, scriptDIR
  if (strcmp(sedDIR,      'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, sedDIR
  if (strcmp(srcDIR,      'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, srcDIR
  if (strcmp(waveDIR,     'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, waveDIR
  if (strcmp(rootIDL,     'IS_UNSET', /FOLD_CASE) eq 1) then UNDEFINE, rootIDL
  
; IDL directories for user defined procedures, programs, ...
  rootIDL = fixDIRname(root_idl)
  if (strcmp(rootIDL, 'IS_UNSET', /FOLD_CASE) eq 1) then begin
    UNDEFINE, rootIDL
  endif else begin
    if (strmatch(!PATH,'*' + rootIDL + '*') eq 0) then $
      !PATH = !PATH + PATH_SEP + expand_path('+' + rootIDL)
  endelse

; The temporary directory that can be used in this system.
  tmpDIR  = fixDIRname(DIR_SEP + 'tmp')
  tmpFILE = tmpDIR + DIR_SEP + 'delete_me.txt'

end
