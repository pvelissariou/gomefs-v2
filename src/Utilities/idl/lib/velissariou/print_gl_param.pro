PRO print_gl_param

  COMMON GLParams

  print
  print, '     *** BEGIN:: PROJECT PLOT VARIABLES ***'
  print

; Project lake variables
  print, '       SIUNIT = ', $
    n_elements(SIUNIT) ne 0 ? SIUNIT : 'IS_UNSET'

  print, '   MASK_VAL = ', $
    n_elements(MASK_VAL) ne 0 ? MASK_VAL : 'IS_UNSET'

  print, '       IGLD85 = ', $
    n_elements(IGLD85) ne 0 ? IGLD85 : 'IS_UNSET'

  print, '   LOW_IGLD85 = ', $
    n_elements(LOW_IGLD85) ne 0 ? LOW_IGLD85 : 'IS_UNSET'

  print, '  HIGH_IGLD85 = ', $
    n_elements(HIGH_IGLD85) ne 0 ? HIGH_IGLD85 : 'IS_UNSET'

  print, '       NAVD88 = ', $
    n_elements(NAVD88) ne 0 ? NAVD88 : 'IS_UNSET'

  print, '   RegionName = ', $
    n_elements(RegionName) ne 0 ? RegionName : 'IS_UNSET'

  print, '   RegionBath = ', $
    n_elements(RegionBath) ne 0 ? RegionBath : 'IS_UNSET'

  print, '  RegionShore = ', $
    n_elements(RegionShore) ne 0 ? RegionShore : 'IS_UNSET'

  print, '      MapProj = ', $
    n_elements(MapProj) ne 0 ? MapProj : 'IS_UNSET'

  print, '       MapSet = ', $
    n_elements(MapSet) ne 0 ? MapSet : 'IS_UNSET'

  print, '    MapCoords = ', $
    n_elements(MapCoords) ne 0 ? MapCoords : 'IS_UNSET'

  print, '    MapCenter = ', $
    n_elements(MapCenter) ne 0 ? MapCenter : 'IS_UNSET'

  print, '     nMapLabs = ', $
    n_elements(nMapLabs) ne 0 ? nMapLabs : 'IS_UNSET'

  print, '       MapDel = ', $
    n_elements(MapDel) ne 0 ? MapDel : 'IS_UNSET'

  print, '   PLOT_XSIZE = ', $
    n_elements(PLOT_XSIZE) ne 0 ? PLOT_XSIZE : 'IS_UNSET'

  print, '   PLOT_YSIZE = ', $
    n_elements(PLOT_YSIZE) ne 0 ? PLOT_YSIZE : 'IS_UNSET'

  print, '    PLOT_TYPE = ', $
    n_elements(PLOT_TYPE) ne 0 ? PLOT_TYPE : 'IS_UNSET'

  print
  print, '     *** END:: PROJECT PLOT VARIABLES ***'
  print
end
