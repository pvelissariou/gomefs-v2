PRO GetParams,                 $
      Region,                  $
      Bath       = bath,       $
      Shore      = shore,      $
      PlotSize   = plotsize,   $
      Map_Coords = map_coords, $
      Map_Proj   = map_proj
;+++
; NAME:
;       GetParams
;
; PURPOSE:
;       To set various lake parameters in the COMMON BLOCK "GLParams"
;
; AUTHOR:
;       Panagiotis Velissariou
;       E-mail: velissariou.1@osu.edu
;
; CATEGORY:
;       Graphics.
;
; CALLING SEQUENCE:
;       GlakesParams, Region
;
;       Region: The name of the region. Valid names are:
;              'erie', 'huron', 'michigan', 'ontario', 'stclair', 'superior',
;              'all', 'any other name'
;
;
; RESTRICTIONS:
;
; EXAMPLE:
;   GetParams, 'michigan'
;
; MODIFICATION HISTORY:
;       Written by:  Panagiotis Velissariou, March 24, 2005.
;+++

on_error, 2

COMMON GLParams

if ((n_elements(region) eq 0) or (size(region, /TYPE) ne 7)) then $
    message, 'GetParams: need a string value for <Region>.'

; trim leading/trailing blanks from Region
tREGION = strtrim(Region, 2)

; make sure that the variables are strings
if (n_elements(bath) ne 0) then begin
  tmp_str = strtrim(string(bath), 2)
  if (tmp_str ne '') then tBATH = tmp_str
endif

if (n_elements(shore) ne 0) then begin
  tmp_str = strtrim(string(shore), 2)
  if (tmp_str ne '') then tSHORE = tmp_str
endif

; make sure that "map_coords" is a 4-element vector
if(n_elements(map_coords) gt 0) then begin
  if(size(map_coords, /n_dimensions) ne 1) then $
     message, "the Map_Coords value should be a four or an eight element vector"
  if((n_elements(map_coords) ne 4) and (n_elements(map_coords) ne 8)) then $
     message, "the Map_Coords value should be a four or an eight element vector"
endif

case strlowcase(tREGION) of
  'erie'    : begin
                RegionName = 'Lake Erie'
                RegionBath = n_elements(tBATH) eq 0 ? ['e_bath.inp', 'c_bath.inp'] : tBATH
                RegionShore = n_elements(tSHORE) eq 0 ? 'e_shore.inp' : tSHORE
                MapProj = n_elements(map_proj) eq 0 ? 'LambertConic' : strtrim(string(map_proj), 2)
;                MapCoords = [41.38034, -83.48544, 42.90948, -78.85729]
                MapCoords = n_elements(map_coords) eq 0 ? [40.80, -83.61, 43.20, -78.40] : map_coords
                MapDel   = 0.20
                nMapLabs = 2
                IGLD85 = SIUNIT ne 0 ? 173.492 : 569.20
                NAVD88 = SIUNIT ne 0 ? 173.492 : 569.20
                PlotSize = n_elements(plotsize) eq 0 ? 625 : plotsize
              end
  'huron'   : begin
                RegionName = 'Lake Huron'
                RegionBath = n_elements(tBATH) eq 0 ? 'h_bath.inp' : tBATH
                RegionShore = n_elements(tSHORE) eq 0 ? 'h_shore.inp' : tSHORE
                MapProj = n_elements(map_proj) eq 0 ? 'LambertConic' : strtrim(string(map_proj), 2)
;                MapCoords = [42.99976, -84.77025, 46.30428, -79.84528]
                MapCoords = n_elements(map_coords) eq 0 ? [42.40, -84.80, 46.40, -79.79] : map_coords
                MapDel   = 0.20
                nMapLabs = 3
                IGLD85 = SIUNIT ne 0 ? 176.022 : 577.50
                NAVD88 = SIUNIT ne 0 ? 176.022 : 577.50
                PlotSize = n_elements(plotsize) eq 0 ? 625 : plotsize
              end
  'michigan': begin
                RegionName = 'Lake Michigan'
                RegionBath = n_elements(tBATH) eq 0 ? 'm_bath.inp' : tBATH
                RegionShore = n_elements(tSHORE) eq 0 ? 'm_shore.inp' : tSHORE
                MapProj = n_elements(map_proj) eq 0 ? 'TransverseMercator' : strtrim(string(map_proj), 2)
;                MapCoords = [41.60016, -88.01919, 46.09929, -84.75810]
                MapCoords = n_elements(map_coords) eq 0 ? [41.60, -88.40, 46.30, -84.79] : map_coords
                MapDel   = 0.20
                nMapLabs = 3
                IGLD85 = SIUNIT ne 0 ? 176.022 : 577.50
                NAVD88 = SIUNIT ne 0 ? 176.022 : 577.50
                PlotSize = n_elements(plotsize) eq 0 ? 600 : plotsize
              end
  'ontario' : begin
                RegionName = 'Lake Ontario'
                RegionBath = n_elements(tBATH) eq 0 ? 'o_bath.inp' : tBATH
                RegionShore = n_elements(tSHORE) eq 0 ? 'o_shore.inp' : tSHORE
                MapProj = n_elements(map_proj) eq 0 ? 'LambertConic' : strtrim(string(map_proj), 2)
;                MapCoords = [42.25489, -84.37969, 46.55000, -75.98371]
                MapCoords = n_elements(map_coords) eq 0 ? [42.70, -80.01, 44.60, -75.71] : map_coords
                MapDel   = 0.20
                nMapLabs = 2
                IGLD85 = SIUNIT ne 0 ? 74.158 : 243.30
                NAVD88 = SIUNIT ne 0 ? 74.158 : 243.30
                PlotSize = n_elements(plotsize) eq 0 ? 625 : plotsize
              end
  'stclair' : begin
                RegionName = 'Lake St. Clair'
                RegionBath = n_elements(tBATH) eq 0 ? 'c_bath.inp' : tBATH
                RegionShore = n_elements(tSHORE) eq 0 ? 'c_shore.inp' : tSHORE
                MapProj = n_elements(map_proj) eq 0 ? 'LambertConic' : strtrim(string(map_proj), 2)
;                MapCoords = [42.29966, -82.95000,  42.69038, -82.41142]
                MapCoords = n_elements(map_coords) eq 0 ? [42.20, -83.01, 42.70, -82.30] : map_coords
                MapDel   = 0.05
                nMapLabs = 3
                IGLD85 = SIUNIT ne 0 ? 174.437 : 572.30
                NAVD88 = SIUNIT ne 0 ? 174.437 : 572.30
                PlotSize = n_elements(plotsize) eq 0 ? 300 : plotsize
              end
  'superior': begin
                RegionName = 'Lake Superior'
                RegionBath = n_elements(tBATH) eq 0 ? 's_bath.inp' : tBATH
                RegionShore = n_elements(tSHORE) eq 0 ? 's_shore.inp' : tSHORE
                MapProj = n_elements(map_proj) eq 0 ? 'LambertConic' : strtrim(string(map_proj), 2)
;                MapCoords = [46.40891, -92.11119, 49.01887, -84.35170]
                MapCoords = n_elements(map_coords) eq 0 ? [45.70, -92.20, 49.30, -84.0] : map_coords
                MapDel   = 0.40
                nMapLabs = 2
                IGLD85 = SIUNIT ne 0 ? 183.21528 : 601.10
                NAVD88 = SIUNIT ne 0 ? 183.21528 : 601.10
                PlotSize = n_elements(plotsize) eq 0 ? 625 : plotsize
              end
  'all'     : begin
                RegionName = 'Great Lakes'
                RegionBath = n_elements(tBATH) eq 0 ? ['e_bath.inp', 'h_bath.inp', 'm_bath.inp', $
                                                       'o_bath.inp', 'c_bath.inp', 's_bath.inp'] : tBATH
                RegionShore = n_elements(tSHORE) eq 0 ? ['e_shore.inp', 'h_shore.inp', 'm_shore.inp', $
                                                        'o_shore.inp', 'c_shore.inp', 's_shore.inp'] : tSHORE
                MapProj = n_elements(map_proj) eq 0 ? 'LambertConic' : strtrim(string(map_proj), 2)
;                MapCoords = [46.40891, -92.11119, 49.01887, -84.35170]
                MapCoords = n_elements(map_coords) eq 0 ? [40.50, -92.00, 49.50, -76.00] : map_coords
                MapDel   = 0.50
                nMapLabs = 4
                IGLD85 = SIUNIT ne 0 ? 183.21528 : 601.10
                NAVD88 = SIUNIT ne 0 ? 183.21528 : 601.10
                PlotSize = n_elements(plotsize) eq 0 ? 800 : plotsize
              end
  else      : begin
                RegionName  = tREGION
                if (n_elements(tBATH) ne 0)  then RegionBath = tBATH
                if (n_elements(tSHORE) ne 0) then RegionShore = tSHORE
                MapProj = n_elements(map_proj) eq 0 ? 'LambertConic' : strtrim(string(map_proj), 2)
                MapCoords = n_elements(map_coords) eq 0 ? [20.0, -120.0, 60.0, -60.0] : map_coords
                PlotSize = n_elements(plotsize) eq 0 ? 600 : plotsize
              end
endcase

; This is for the center of the map as calculated by the MapCoords points
if (n_elements(MapCoords) eq 4) then begin
  ; MapCoords = [lat0, lon0, lat1, lon1]
  ; Specifies the boundaries of the region to be mapped. (Latmin, Lonmin) and (Latmax, Lonmax)
  ; are the latitudes and longitudes of two points diagonal from each other on the region's boundary.
  lat_idx = [0, 2]
  lon_idx = [1, 3]
endif else begin
  ; MapCoords = [lat0, lon0, lat1, lon1, lat2, lon2, lat3, lon3]
  ; These four latitude/longitude pairs describe, respectively, four points on the
  ; left, top, right, and bottom edges of the map extent.
  lat_idx = [0, 2, 4, 6]
  lon_idx = [1, 3, 5, 7]
endelse

MapCenter = [mean(MapCoords[lat_idx]), mean(MapCoords[lon_idx])]
min_lat = min(MapCoords[lat_idx], Max = max_lat)
min_lon = min(MapCoords[lon_idx], Max = max_lon)

xx = (map_2points(min_lon, MapCenter[0], max_lon, MapCenter[0]))[0]
yy = (map_2points(MapCenter[1], min_lat, MapCenter[1], max_lat))[0]

PLOT_XSIZE = round(PlotSize * (xx / yy < 1.0))
PLOT_YSIZE = round(PlotSize * (yy / xx < 1.0))

end
