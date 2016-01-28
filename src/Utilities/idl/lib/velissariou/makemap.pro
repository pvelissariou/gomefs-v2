PRO MakeMap,                   $
      Set        = set,        $
      Projection = projection, $
      Coasts     = coasts,     $
      Rivers     = rivers,     $
      Countries  = countries,  $
      Usa        = usa,        $
      Continents = continents, $
      No_Grid    = no_grid,    $
      No_Labels  = no_labels,  $
      Box_Axes   = box_axes,   $
      Title      = title,      $
      Lb_Size    = lb_size,    $
      Tl_Size    = tl_size,    $
      _Extra     = extra

;+++
; NAME:
;       MakeMap
;
; PURPOSE:
;       To plot the map for a region.
;
; AUTHOR:
;       Panagiotis Velissariou
;       E-mail: velissariou.1@osu.edu
;
; CATEGORY:
;       Graphics.
;
; CALLING SEQUENCE:
;       MakeMap, [keywords]
;
; KEYWORD PARAMETERS:
;           Set     :   Set this keyword variable initialize the map.
;                        Need to first call "MakeMap" with /set and other
;                        relevant keywords to initialize the map and then
;                        call "MakeMap" to plot the map.
;    Projection     :   This is the string for the projection name to be used.
;                        Default :  'LambertConic'
;         Coasts    :   Set this keyword variable to draw coastlines.
;         Rivers    :   Set this keyword variable to draw rivers.
;      Countries    :   Set this keyword variable to draw country boundaries.
;            Usa    :   Set this keyword variable to draw a usa location.
;     Continents    :   Set this keyword variable to draw continent boundaries.
;        No_Grid    :   Set this keyword variable if no grid lines are to be drawn.
;                        Only the grid labels are drawn.
;                        Default :  PLOT THE GRID LINES
;      No_Labels    :   Set this keyword variable if no grid labels are to be drawn.
;                        Default :  PLOT THE GRID LABELS
;       Box_Axes    :   Set this keyword variable to box the axes of the map.
;                        Default :  DO NOT BOX THE AXES
;          Title    :   Set this keyword variable to draw the title for the Region.
;                       The name of the region is established by a previous call
;                       of the GetParams procedure
;                        Default :  NO TITLE
;        Lb_Size    :   This is the size for the labels.
;                        Default :  0.8 * !P.CHARSIZE
;        Tl_Size    :   This is the size for the title.
;                        Default :  1.25 * !P.CHARSIZE
;
; RESTRICTIONS:
;       Requires GLakesParams
;
; EXAMPLE:
;   MakeMap, 'michigan', /box_axes
;
; MODIFICATION HISTORY:
;       Written by:  Panagiotis Velissariou, March 24, 2005.
;+++

on_error, 2

COMMON GLParams
COMMON PlotParams

; ----- Get the current color table to restore it later
tvlct, RED, GREEN, BLUE, /GET

if (keyword_set(set) eq 0) then $
  if n_elements(MapSet) eq 0 then begin
    message, "the map has not been established", /continue
    message, "call first MakeMap with the keyword /set to initialize the map"
  endif

lb_size = n_elements(lb_size) eq 0 ? 0.8 * !P.CHARSIZE : abs(lb_size)
tl_size = n_elements(tl_size) eq 0 ? 1.25 * !P.CHARSIZE : abs(tl_size)

; check for valid projection
if n_elements(projection) eq 0 then begin
  projection = 'LambertConic'
  proj_title = 'Lambert Conic'
endif else begin
  case strlowcase(projection) of
    'stereographic'         : proj_title = 'Stereographic'
    'orthographic'          : proj_title = 'Orthographic'
    'lambertconic'          : proj_title = 'Lambert Conic'
    'lambertazimuthal'      : proj_title = 'Lambert Azimuthal'
    'gnomic'                : proj_title = 'Gnomic'
    'azimuthalequidistant'  : proj_title = 'Azimuthal Equidistant'
    'satellite'             : proj_title = 'Satellite'
    'cylindrical'           : proj_title = 'Cylindrical'
    'mercator'              : proj_title = 'Mercator'
    'mollweide'             : proj_title = 'Mollweide'
    'sinusoidal'            : proj_title = 'Sinusoidal'
    'aitoff'                : proj_title = 'Aitoff'
    'hammeraitoff'          : proj_title = 'Hammer Aitoff'
    'albersequalareaconic'  : proj_title = 'Albers Equal Area Conic'
    'transversemercator'    : proj_title = 'Transverse Mercator'
    'millercylindrical'     : proj_title = 'Miller Cylindrical'
    'robinson'              : proj_title = 'Robinson'
    'lambertconicellipsoid' : proj_title = 'Lambert Conic Ellipsoid'
    'goodeshomolosine'      : proj_title = 'Goodes Homolosine'
    else                    : begin
                                projection = 'LambertConic'
                                proj_title = 'Lambert Conic'
                              end
  endcase
endelse

re_bin = n_elements(RebinFactor) eq 0 ? 1.0 : RebinFactor
box_axes = keyword_set(box_axes) eq 0 ? 0 : re_bin * abs(box_axes)

no_grid   = keyword_set(no_grid)
no_labels = keyword_set(no_labels)

do_grid = no_grid + no_labels ge 2 ? 0 : 1

do_title = size(title, /type) eq 7 ? 1 : 0
if do_title then begin
   if (abs(PlotTitleBox[3] - PlotTitleBox[1]) le 0.0) then begin
      do_title = 0
   endif else begin
      if (strtrim(string(title), 2) eq '') then do_title = 0
   endelse
endif

coasts     = keyword_set(coasts)
rivers     = keyword_set(rivers)
countries  = keyword_set(countries)
usa        = keyword_set(usa)
continents = keyword_set(continents)

; Re-set the map according to the possibly adjusted plot box area
len = lb_size * !D.Y_CH_SIZE
thisLEN = convert_coord(len, len, /device, /to_normal)

if keyword_set(box_axes) then begin
  b_len = 1.25 * len + box_axes * 0.1 * !D.Y_PX_CM
  thisLEN = convert_coord(b_len, b_len, /device, /to_normal)
endif

blen = [thisLEN[0], thisLEN[1], -thisLEN[0], -thisLEN[1]]

; ----------------------------------------
; Initialize the map given the map coordinates
if keyword_set(set) then begin
  !P.POSITION = !P.POSITION[[0, 1, 2, 3]] + blen

  map_set, MapCenter[0], MapCenter[1], limit = MapCoords, $
           name = projection, /noerase,                   $
           color = GetColor('White'),                     $
           _Extra = extra

  MapSet = 1
  MapPlotBox = [ !X.WINDOW[0], !Y.WINDOW[0], !X.WINDOW[1], !Y.WINDOW[1] ]
  MapPlotAreaBox = !P.POSITION

  ; ----- Restore the color table to its original state
  tvlct, RED, GREEN, BLUE
  return
endif

if do_grid then                                                   $
map_grid, latlab = MapCoords[3], latalign = 1.0, latdel = MapDel, $
          lonlab = MapCoords[2], lonalign = 0.5, londel = MapDel, $
          label = nMapLabs, glinestyle = 1, glinethick = re_bin,  $
          color = GetColor('Black'), charsize = lb_size,          $
          box_axes = box_axes, no_grid = no_grid,                 $
          _Extra = extra

if ~ box_axes then $
  DrawBox, MapPlotBox,                                      $
           fr_color = GetColor('Black'), fr_thick = re_bin, $
           /normal, _Extra = extra

; ----------------------------------------
; This for the projection legend
lengSZ = 0.7

lengOFF = 0.125 * !D.Y_PX_CM
lengOFF = convert_coord(lengOFF, lengOFF, /device, /to_normal)

lengFR_OFF = lengSZ * !D.Y_CH_SIZE
lengFR_OFF = 0.25 * max((convert_coord(lengFR_OFF, lengFR_OFF, /device, /to_normal))[0:1])

lengTXT = TextFont(proj_title, 3)

VL_Legend, [0.0, 0.0], lengTXT, charsize = lengSZ,  $
           frame = 1, fr_color = GetColor('Black'), $
           fr_thick = re_bin, fr_off = lengFR_OFF,  $
           legdims = legdims, /get

lengW = legdims[2] - legdims[0]
lengH = legdims[3] - legdims[1]
lengX0 = MapPlotBox[2] - lengW - lengOFF[0]
lengY0 = MapPlotBox[1] + lengOFF[1]
VL_Legend, [lengX0, lengY0], lengTXT, charsize = lengSZ, $
           color = GetColor('Black'),                    $
           frame = 1, fr_color = GetColor('Black'),      $
           fr_thick = re_bin, fr_off = lengFR_OFF,       $
           bk_color = GetColor('White'), /fill

; ----------------------------------------
; Draw coastlines, rivers, etc.
if coasts then $
  map_continents, /coasts, /hires, color = GetColor('Navy'), $
                  mlinestyle = 0, mlinethick = re_bin

if rivers then $
  map_continents, /rivers, /hires, color = GetColor('Royal Blue'), $
                  mlinestyle = 0, mlinethick = re_bin

if countries then $
  map_continents, /countries, /hires, color = GetColor('Brown'), $
                  mlinestyle = 4, mlinethick = re_bin

if usa then $
  map_continents, /usa, /hires, color = GetColor('Black'), $
                  mlinestyle = 0, mlinethick = re_bin

if continents then $
  map_continents, /continents, /hires, color = GetColor('Dark Green'), $
                  mlinestyle = 5, mlinethick = re_bin,                 $
                  _Extra = extra

if (do_title) then begin
  DrawBox, PlotTitleBox, Bk_Color = GetColor('White'), $
           /fill, /noframe, /normal,                   $
           _Extra = extra

  region_name = TextFont(Title, 6)
  tmp_val = TextDims(region_name, origin = [0.0, 0.0], charsize = tl_size, $
                       alignment = 0.5, orientation = 0.0)

  tx = 0.5 * (PlotTitleText[0] + PlotTitleText[2])
  ty = 0.5 * (PlotTitleText[1] + PlotTitleText[3]) - 0.5 * (tmp_val[3] - tmp_val[1])
  xyouts, tx, ty, region_name,                          $
          charsize = tl_size, color = GetColor('Navy'), $
          orientation = 0.0, alignment = 0.5, /normal,  $
          _Extra = extra
endif

; ----- Restore the color table to its original state
tvlct, RED, GREEN, BLUE

end
