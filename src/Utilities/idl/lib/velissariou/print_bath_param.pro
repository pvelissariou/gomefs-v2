PRO print_bath_param

  COMMON BathParams

  print
  print, '     *** BEGIN:: PROJECT BATHYMETRY VARIABLES ***'
  print

; Project bathymetry variables
  print, '        lname = ', $
    n_elements(lname) ne 0 ? lname : 'IS_UNSET'

  print, '        iparm = ', $
    n_elements(iparm) ne 0 ? iparm : 'IS_UNSET'

  print, '        rparm = ', $
    n_elements(rparm) ne 0 ? rparm : 'IS_UNSET'

  print, '        dgrid = ', $
    n_elements(dgrid) ne 0 ? 'array: dgrid[IPNTS, JPNTS]' : 'IS_UNSET'

  print, '      longrid = ', $
    n_elements(longrid) ne 0 ? 'array: longrid[IPNTS, JPNTS]' : 'IS_UNSET'

  print, '      latgrid = ', $
    n_elements(latgrid) ne 0 ? 'array: latgrid[IPNTS, JPNTS]' : 'IS_UNSET'

  print, '       xgrid = ', $
    n_elements(xgrid) ne 0 ? 'array: xgrid[IPNTS, JPNTS]' : 'IS_UNSET'

  print, '       ygrid = ', $
    n_elements(ygrid) ne 0 ? 'array: ygrid[IPNTS, JPNTS]' : 'IS_UNSET'

  print, '       GridX0 = ', $
    n_elements(GridX0) ne 0 ? GridX0 : 'IS_UNSET'

  print, '       GridY0 = ', $
    n_elements(GridY0) ne 0 ? GridY0 : 'IS_UNSET'

  print, '      GridXSZ = ', $
    n_elements(GridXSZ) ne 0 ? GridXSZ : 'IS_UNSET'

  print, '      GridYSZ = ', $
    n_elements(GridYSZ) ne 0 ? GridYSZ : 'IS_UNSET'

  print, '        IPNTS = ', $
    n_elements(IPNTS) ne 0 ? IPNTS : 'IS_UNSET'

  print, '        JPNTS = ', $
    n_elements(JPNTS) ne 0 ? JPNTS : 'IS_UNSET'

  print, '       TCELLS = ', $
    n_elements(TCELLS) ne 0 ? TCELLS : 'IS_UNSET'

  print, '       WCELLS = ', $
    n_elements(WCELLS) ne 0 ? WCELLS : 'IS_UNSET'

  print, '    WCELLSIDX = ', $
    n_elements(WCELLSIDX) ne 0 ? 'vector: WCELLSIDX[*]' : 'IS_UNSET'

  print, '       LCELLS = ', $
    n_elements(LCELLS) ne 0 ? LCELLS : 'IS_UNSET'

  print, '    LCELLSIDX = ', $
    n_elements(LCELLSIDX) ne 0 ? 'vector: LCELLSIDX[*]' : 'IS_UNSET'

  print
  print, '     *** END:: PROJECT BATHYMETRY VARIABLES ***'
  print
end
