PRO print_init

  COMMON ProjDirs

  print
  print, '     *** BEGIN:: PROJECT INIT VARIABLES ***'
  print

; Project directories for data, programs, ...
  print, '      rootDIR = ', $
    n_elements(rootDIR) ne 0 ? rootDIR : 'IS_UNSET'

  print, '      bathDIR = ', $
    n_elements(bathDIR) ne 0 ? bathDIR : 'IS_UNSET'

  print, '       binDIR = ', $
    n_elements(binDIR) ne 0 ? binDIR : 'IS_UNSET'

  print, '      currDIR = ', $
    n_elements(currDIR) ne 0 ? currDIR : 'IS_UNSET'

  print, '  freesurfDIR = ', $
    n_elements(freesurfDIR) ne 0 ? freesurfDIR : 'IS_UNSET'

  print, '      elevDIR = ', $
    n_elements(elevDIR) ne 0 ? elevDIR : 'IS_UNSET'

  print, '       imgDIR = ', $
    n_elements(imgDIR) ne 0 ? imgDIR : 'IS_UNSET'

  print, '       inpDIR = ', $
    n_elements(inpDIR) ne 0 ? inpDIR : 'IS_UNSET'

  print, '    interpDIR = ', $
    n_elements(interpDIR) ne 0 ? interpDIR : 'IS_UNSET'

  print, '       libDIR = ', $
    n_elements(libDIR) ne 0 ? libDIR : 'IS_UNSET'

  print, '    marobsDIR = ', $
    n_elements(marobsDIR) ne 0 ? marobsDIR : 'IS_UNSET'

  print, '      miscDIR = ', $
    n_elements(miscDIR) ne 0 ? miscDIR : 'IS_UNSET'

  print, '       outDIR = ', $
    n_elements(outDIR) ne 0 ? outDIR : 'IS_UNSET'

  print, '      plotDIR = ', $
    n_elements(plotDIR) ne 0 ? plotDIR : 'IS_UNSET'

  print, '    scriptDIR = ', $
    n_elements(scriptDIR) ne 0 ? scriptDIR : 'IS_UNSET'

  print, '       sedDIR = ', $
    n_elements(sedDIR) ne 0 ? sedDIR : 'IS_UNSET'

  print, '       srcDIR = ', $
    n_elements(srcDIR) ne 0 ? srcDIR : 'IS_UNSET'

  print, '      waveDIR = ', $
    n_elements(waveDIR) ne 0 ? waveDIR : 'IS_UNSET'

; IDL directories for user defined procedures, programs, ...
  print, '      rootIDL = ', $
    n_elements(rootIDL) ne 0 ? rootIDL : 'IS_UNSET'

; The temporary directory that can be used in this system.
  print, '      tmpDIR  = ', $
    n_elements(tmpDIR) ne 0 ? tmpDIR : 'IS_UNSET'

  print, '      tmpFILE = ', $
    n_elements(tmpFILE) ne 0 ? tmpFILE : 'IS_UNSET'

; Set additional PATH directories for user defined IDL procedures.
    print, '      !PATH = ', !PATH

  print
  print, '     *** END:: PROJECT INIT VARIABLES ***'
  print
end
