Function VarInfo_Wrf, nVARS
;+++
; NAME:
;	VarInfo_Wrf
; VERSION:
;	1.0
; PURPOSE:
;	To export all supported variable names in a WRF output file.
; CALLING SEQUENCE:
;	VarInfo_Wrf [,nVARS]
;
;	On input:
;
;	On output:
;    varinfo_wrf - The structure array containing the variable names:
;                  struct = { nam:'', title:'', uinp:'', uout:'', dim:'', $
;                             range:def_range, drange:def_drange, bdry:def_bdry, $
;                             ctbl:'', clow:'', chigh:'', nlow:-1, nhigh:-1}
;                  nam = the variable name
;                title = the title (description) of the variable
;                 uinp = the units of the variable as given in the NetCDF file
;                 uout = the units of the variable suitable for displaying
;                        in plots (TeXtoIDL might be involved)
;                  dim = the string denoting the variable dimensionality
;                        and its position on a staggered grid
;                range = the plotting range of the data
;                        default: def_range = [-1.0, 1.0]
;               drange = the tick spacing of the data (positive)
;                        default: def_drange = 0.2
;                 bdry = to draw the end arrows of the colorbar
;                        default: def_bdry = [1, 1]
;                        def_bdry: [0, 0] -> no min/max arrows in the colorbar
;                        def_bdry: [1, 0] -> no max arrow in the colorbar
;                        def_bdry: [0, 1] -> no min arrow in the colorbar
;                        def_bdry: [1, 1] -> both min/max arrows in the colorbar
;                 ctbl = the color table to be used (string or integer)
;                        default: def_clr_table = 'Cont_Elev1'
;                 clow = the color to be used for the low out of range
;                        values (for the colorbar)
;                        default: def_clr_low = 'Navy'
;                chigh = the color to be used for the high out of range
;                        values (for the colorbar)
;                        default: def_clr_high = 'Dark Red'
;                 nlow = the number of colors to cut from the low end of
;                        the loaded color table
;                        default: def_n_low = 10
;                nhigh = the number of colors to cut from the upper end of
;                        the loaded color table
;                        default: def_n_high = 10
;
;	Optional parameters:
;	   nVARS - Set this to a named variable to get the total number
;                  of the supported variables
;
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Modified:
;	Created:  Mon May 05 2014 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  ; Error handling.
  On_Error, 2


  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ; START THE CALCULATIONS
  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  def_range  = [ -1.0, 1.0 ]
  def_drange = 0.2

  ; def_bdry: [0, 0] -> no min/max arrows in the colorbar
  ; def_bdry: [1, 0] -> no max arrow in the colorbar
  ; def_bdry: [0, 1] -> no min arrow in the colorbar
  ; def_bdry: [1, 1] -> both min/max arrows in the colorbar
  def_bdry = [1, 1]

  def_clr_table = 'Cont_Elev1'
  def_clr_low   = 'Navy'
  def_clr_high  = 'Dark Red'
  def_n_low     = 10
  def_n_high    = 10

  var_struc = { nam:'', typ:'', title:'', uinp:'', uout:'', dim:'', $
                range:def_range, drange:def_drange, bdry:def_bdry, $
                ctbl:'', clow:'', chigh:'', nlow:-1, nhigh:-1}
  var_array = replicate(var_struc, 5000)

  if (!P.FONT ne -1) and (!D.NAME ne 'PS') then begin
    un_wpm2     = 'W m-2'
    un_celc     = 'Celcius'
  endif else begin
    un_wpm2     = TeXtoIDL('W/m^{2}')
    un_celc     = TeXtoIDL('^{0}C')
  endelse

  ivar = 0
    var_array[ivar].nam    = 'HGT'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'Terrain Height'
    var_array[ivar].uinp   = 'm'
    var_array[ivar].uout   = 'm'
    var_array[ivar].range  = [0.0, 3000.0]
    var_array[ivar].drange = 200.0
    var_array[ivar].bdry   = [0, 1]
    var_array[ivar].ctbl   = 'Cont_Vel'
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = def_n_low
    var_array[ivar].nhigh  = def_n_high
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'U10'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'U-Wind component at 10 m'
    var_array[ivar].uinp   = 'm s-1'
    var_array[ivar].uout   = 'm/s'
    var_array[ivar].range  = [-20.0, 20.0]
    var_array[ivar].drange = 2.0
    var_array[ivar].bdry   = def_bdry
    var_array[ivar].ctbl   = 'Cont_Vel'
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = def_n_low
    var_array[ivar].nhigh  = def_n_high
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'V10'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'V-Wind component at 10 m'
    var_array[ivar].uinp   = 'm s-1'
    var_array[ivar].uout   = 'm/s'
    var_array[ivar].range  = [-20.0, 20.0]
    var_array[ivar].drange = 2.0
    var_array[ivar].bdry   = def_bdry
    var_array[ivar].ctbl   = 'Cont_Vel'
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = def_n_low
    var_array[ivar].nhigh  = def_n_high
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'HFX'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'Sensible heat flux at the surface'
    var_array[ivar].uinp   = 'W m-2'
    var_array[ivar].uout   = un_wpm2
    var_array[ivar].range  = [-200.0, 200.0]
    var_array[ivar].drange = 20.0
    var_array[ivar].bdry   = def_bdry
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = def_n_low
    var_array[ivar].nhigh  = def_n_high
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'LH'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'Latent heat flux at the surface'
    var_array[ivar].uinp   = 'W m-2'
    var_array[ivar].uout   = un_wpm2
    var_array[ivar].range  = [-200.0, 200.0]
    var_array[ivar].drange = 20.0
    var_array[ivar].bdry   = def_bdry
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = def_n_low
    var_array[ivar].nhigh  = def_n_high
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'GLW'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'Downward longwave flux at the surface'
    var_array[ivar].uinp   = 'W m-2'
    var_array[ivar].uout   = un_wpm2
    var_array[ivar].range  = [100.0, 400.0]
    var_array[ivar].drange = 20.0
    var_array[ivar].bdry   = def_bdry
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = def_n_low
    var_array[ivar].nhigh  = def_n_high
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'OLR'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'Total outgoing longwave at the surface'
    var_array[ivar].uinp   = 'W m-2'
    var_array[ivar].uout   = un_wpm2
    var_array[ivar].range  = [100.0, 400.0]
    var_array[ivar].drange = 20.0
    var_array[ivar].bdry   = def_bdry
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = def_n_low
    var_array[ivar].nhigh  = def_n_high
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'SWDOWN'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'Downward shortwave flux at the surface'
    var_array[ivar].uinp   = 'W m-2'
    var_array[ivar].uout   = un_wpm2
    var_array[ivar].range  = [0.0, 100.0]
    var_array[ivar].drange = 5.0
    var_array[ivar].bdry   = [0, 1]
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = def_n_low
    var_array[ivar].nhigh  = def_n_high
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'GRDFLX'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'Ground heat flux'
    var_array[ivar].uinp   = 'W m-2'
    var_array[ivar].uout   = un_wpm2
    var_array[ivar].range  = [-100.0, 100.0]
    var_array[ivar].drange = 20
    var_array[ivar].bdry   = def_bdry
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = def_n_low
    var_array[ivar].nhigh  = def_n_high
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'ALBEDO'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'Albedo'
    var_array[ivar].uinp   = ''
    var_array[ivar].uout   = ''
    var_array[ivar].range  = [0.02, 0.30]
    var_array[ivar].drange = 0.02
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'ALBBCK'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'Background Albedo'
    var_array[ivar].uinp   = ''
    var_array[ivar].uout   = ''
    var_array[ivar].range  = [0.02, 0.30]
    var_array[ivar].drange = 0.02
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'CLDFRA'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'Cloud fraction'
    var_array[ivar].uinp   = ''
    var_array[ivar].uout   = ''
    var_array[ivar].range  = [0.05, 1.0]
    var_array[ivar].drange = 0.05
    var_array[ivar].bdry   = [1, 0]
    var_array[ivar].ctbl   = 'Cont_Vel3'
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = 'Navy'
    var_array[ivar].nlow   = 80
    var_array[ivar].nhigh  = 0
    var_array[ivar].dim    = 'r3dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'Q2'
    var_array[ivar].typ    = 'humidity'
    var_array[ivar].title  = 'Water Vapor Mixing Ratio at 2 m'
    var_array[ivar].uinp   = 'kg/kg'
    var_array[ivar].uout   = 'kg/kg'
    var_array[ivar].range  = [0.0025, 0.03]
    var_array[ivar].drange = 0.0025
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = 'Cont_Elev1'
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = 'Dark Red'
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'SPH2'
    var_array[ivar].typ    = 'humidity'
    var_array[ivar].title  = 'Specific Humidity at 2 m'
    var_array[ivar].uinp   = 'kg/kg'
    var_array[ivar].uout   = 'kg/kg'
    var_array[ivar].range  = [0.0025, 0.03]
    var_array[ivar].drange = 0.0025
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = 'Cont_Elev1'
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = 'Dark Red'
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'RELH2'
    var_array[ivar].typ    = 'rel_humidity'
    var_array[ivar].title  = 'Relative Humidity at 2 m'
    var_array[ivar].uinp   = '%'
    var_array[ivar].uout   = '%'
    var_array[ivar].range  = [5.0, 95.0]
    var_array[ivar].drange = 5.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = 'Cont_Elev1'
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = 'Dark Red'
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'T2'
    var_array[ivar].typ    = 'temperature'
    var_array[ivar].title  = 'Temperature at 2 m'
    var_array[ivar].uinp   = 'K'
    var_array[ivar].uout   = un_celc
    var_array[ivar].range  = [0.0, 32.0]
    var_array[ivar].drange = 2.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = 'Cont_Temp1'
    var_array[ivar].clow   = 'Navy'
    var_array[ivar].chigh  = 'Dark Red'
    var_array[ivar].nlow   = 20
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'TH2'
    var_array[ivar].typ    = 'temperature'
    var_array[ivar].title  = 'Potential temperature at 2 m'
    var_array[ivar].uinp   = 'K'
    var_array[ivar].uout   = un_celc
    var_array[ivar].range  = [0.0, 32.0]
    var_array[ivar].drange = 2.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = 'Cont_Temp1'
    var_array[ivar].clow   = 'Navy'
    var_array[ivar].chigh  = 'Dark Red'
    var_array[ivar].nlow   = 20
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'TD2'
    var_array[ivar].typ    = 'temperature'
    var_array[ivar].title  = 'Dew Point at 2 m'
    var_array[ivar].uinp   = 'K'
    var_array[ivar].uout   = un_celc
    var_array[ivar].range  = [0.0, 32.0]
    var_array[ivar].drange = 2.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = 'Cont_Temp1'
    var_array[ivar].clow   = 'Navy'
    var_array[ivar].chigh  = 'Dark Red'
    var_array[ivar].nlow   = 20
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'SST'
    var_array[ivar].typ    = 'temperature'
    var_array[ivar].title  = 'Sea surface temperature'
    var_array[ivar].uinp   = 'K'
    var_array[ivar].uout   = un_celc
    var_array[ivar].range  = [0.0, 32.0]
    var_array[ivar].drange = 2.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = 'Cont_Temp1'
    var_array[ivar].clow   = 'Navy'
    var_array[ivar].chigh  = 'Dark Red'
    var_array[ivar].nlow   = 20
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'TSK'
    var_array[ivar].typ    = 'temperature'
    var_array[ivar].title  = 'Surface skin temperature'
    var_array[ivar].uinp   = 'K'
    var_array[ivar].uout   = un_celc
    var_array[ivar].range  = [0.0, 32.0]
    var_array[ivar].drange = 2.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = 'Cont_Temp1'
    var_array[ivar].clow   = 'Navy'
    var_array[ivar].chigh  = 'Dark Red'
    var_array[ivar].nlow   = 20
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'SSTSK'
    var_array[ivar].typ    = 'temperature'
    var_array[ivar].title  = 'Sea surface skin temperature'
    var_array[ivar].uinp   = 'K'
    var_array[ivar].uout   = un_celc
    var_array[ivar].range  = [0.0, 32.0]
    var_array[ivar].drange = 2.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = 'Cont_Temp1'
    var_array[ivar].clow   = 'Navy'
    var_array[ivar].chigh  = 'Dark Red'
    var_array[ivar].nlow   = 20
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'PSFC'
    var_array[ivar].typ    = 'pressure'
    var_array[ivar].title  = 'Pressure at the surface'
    var_array[ivar].uinp   = 'Pa'
    var_array[ivar].uout   = 'mbar'
    var_array[ivar].range  = [960.0, 1040.0]
    var_array[ivar].drange = 5.0
    var_array[ivar].bdry   = def_bdry
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 20
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'MSLP'
    var_array[ivar].typ    = 'pressure'
    var_array[ivar].title  = 'Mean Sea Level Pressure'
    var_array[ivar].uinp   = 'Pa'
    var_array[ivar].uout   = 'mbar'
    var_array[ivar].range  = [980.0, 1030.0]
    var_array[ivar].drange = 5.0
    var_array[ivar].bdry   = def_bdry
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 20
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'PBLH'
    ;var_array[ivar].typ    = ''
    var_array[ivar].title  = 'PBL height'
    var_array[ivar].uinp   = 'm'
    var_array[ivar].uout   = 'm'
    var_array[ivar].range  = [200.0, 3000.0]
    var_array[ivar].drange = 200.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = def_clr_low
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 20
    var_array[ivar].nhigh  = 10
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'RAINC'
    var_array[ivar].typ    = 'rain'
    var_array[ivar].title  = 'Accumulated total cumulus precipitation'
    var_array[ivar].uinp   = 'mm'
    var_array[ivar].uout   = 'mm'
    var_array[ivar].range  = [4.0, 100.0]
    var_array[ivar].drange = 4.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 0
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'RAINNC'
    var_array[ivar].typ    = 'rain'
    var_array[ivar].title  = 'Accumulated total grid scale precipitation'
    var_array[ivar].uinp   = 'mm'
    var_array[ivar].uout   = 'mm'
    var_array[ivar].range  = [4.0, 100.0]
    var_array[ivar].drange = 4.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 0
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'RAINCV'
    var_array[ivar].typ    = 'rain'
    var_array[ivar].title  = 'Time-Step Cumulus Precipitation'
    var_array[ivar].uinp   = 'mm'
    var_array[ivar].uout   = 'mm'
    var_array[ivar].range  = [0.5, 10.0]
    var_array[ivar].drange = 0.5
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 0
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'RAINNCV'
    var_array[ivar].typ    = 'rain'
    var_array[ivar].title  = 'Time-Step NonConvective Precipitation'
    var_array[ivar].uinp   = 'mm'
    var_array[ivar].uout   = 'mm'
    var_array[ivar].range  = [0.5, 10.0]
    var_array[ivar].drange = 0.5
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 0
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'CRAIN'
    var_array[ivar].typ    = 'rain'
    var_array[ivar].title  = 'Accumulated Rainfall'
    var_array[ivar].uinp   = 'mm'
    var_array[ivar].uout   = 'mm'
    var_array[ivar].range  = [2.0, 50.0]
    var_array[ivar].drange = 2.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 0
    var_array[ivar].dim    = 'r2dvar'
  ivar = ivar + 1
    var_array[ivar].nam    = 'RAIN'
    var_array[ivar].typ    = 'rain'
    var_array[ivar].title  = 'Rainfall Rate'
    var_array[ivar].uinp   = 'mm/hr'
    var_array[ivar].uout   = 'mm/hr'
    var_array[ivar].range  = [1.0, 30.0]
    var_array[ivar].drange = 1.0
    var_array[ivar].bdry   = [1, 1]
    var_array[ivar].ctbl   = def_clr_table
    var_array[ivar].clow   = 'White'
    var_array[ivar].chigh  = def_clr_high
    var_array[ivar].nlow   = 35
    var_array[ivar].nhigh  = 0
    var_array[ivar].dim    = 'r2dvar'

  idx = where((strcompress(var_array.nam, /REMOVE_ALL) ne '') and $
              (strcompress(var_array.dim, /REMOVE_ALL) ne ''), count)


  if (count ne 0) then begin
    nVARS = count
    var_array = var_array[idx]
  endif else begin
    nVARS = -1L
    var_array = { }
  endelse

  return, var_array
end
