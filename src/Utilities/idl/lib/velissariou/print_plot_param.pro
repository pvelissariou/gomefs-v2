PRO print_plot_param

  COMMON PlotParams

  print
  print, '     *** BEGIN:: PROJECT PLOT VARIABLES ***'
  print

; Project plot variables
  print, '   OldPlotDev = ', $
    n_elements(OldPlotDev) ne 0 ? OldPlotDev : 'IS_UNSET'

  print, '      PlotDev = ', $
    n_elements(PlotDev) ne 0 ? PlotDev : 'IS_UNSET'

  print, 'DevResolution = ', $
    n_elements(DevResolution) ne 0 ? DevResolution : 'IS_UNSET'

  print, '    DevStatus = ', $
    n_elements(DevStatus) ne 0 ? DevStatus : 'IS_UNSET'

  print, '  DevPlotType = ', $
    n_elements(DevPlotType) ne 0 ? DevPlotType : 'IS_UNSET'

  print, '     pageInfo = ', $
    n_elements(pageInfo) ne 0 ? pageInfo : 'IS_UNSET'

  print, '     defColor = ', $
    n_elements(defColor) ne 0 ? defColor : 'IS_UNSET'

  print, '     defThick = ', $
    n_elements(defThick) ne 0 ? defThick : 'IS_UNSET'

  print, '  defFontSize = ', $
    n_elements(defFontSize) ne 0 ? defFontSize : 'IS_UNSET'

  print, '  defCharsize = ', $
    n_elements(defCharsize) ne 0 ? defCharsize : 'IS_UNSET'

  print, '  RebinFactor = ', $
    n_elements(RebinFactor) ne 0 ? RebinFactor : 'IS_UNSET'

  print, '     TextSize = ', $
    n_elements(TextSize) ne 0 ? TextSize : 'IS_UNSET'

  print, ' PlotTitleBox = ', $
    n_elements(PlotTitleBox) ne 0 ? PlotTitleBox : 'IS_UNSET'

  print, 'PlotTitleText = ', $
    n_elements(PlotTitleText) ne 0 ? PlotTitleText : 'IS_UNSET'

  print, '      PlotBox = ', $
    n_elements(PlotBox) ne 0 ? PlotBox : 'IS_UNSET'

  print, '  PlotAreaBox = ', $
    n_elements(PlotAreaBox) ne 0 ? PlotAreaBox : 'IS_UNSET'

  print
  print, '     *** END:: PROJECT PLOT VARIABLES ***'
  print
end
