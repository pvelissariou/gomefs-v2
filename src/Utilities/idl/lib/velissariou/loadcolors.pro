PRO LoadColors,                $
      RED,                     $
      GREEN,                   $
      BLUE,                    $
      COLOR_MAP  = color_map,  $
      MAP_NAME   = map_name,   $
      GET_COLORS = get_colors, $
      GET_NAMES  = get_names,  $
      GRAY       = gray,       $
      LOW_IDX    = low_idx,    $
      HIGH_IDX   = high_idx,   $
      _Extra = extra
;+++
; NAME:
;	LoadColors
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;	This procedure loads the requested colormap for subsequent use for drawing.
;
; CATEGORY:
;	Graphics
;
; CALLING SEQUENCE:
;	LoadColors, [RED, GREEN, BLUE], [keyword1 = ...], [keyword2 = ...], ...
;
;            RED    :   A named variable that holds the values of the "red" color
;                        of the requested colormap.
;                        corner of the box containing the legend.
;	   GREEN    :   A named variable that holds the values of the "green" color
;                        of the requested colormap.
;	    BLUE    :   A named variable that holds the values of the "blue" color
;                        of the requested colormap.
;
; KEYWORD PARAMETERS:
;       COLOR_MAP   :   This is the index (integer) or, the name (string) of the
;                        colormap to be loaded. If a system colormap is loaded the
;                        first 64 colors are replaced by the base colors defined
;                        below in this program. To load the complete system colormap
;                        use the "loadct" procedure.
;                        Default :  Grey
;        MAP_NAME   :   This a named variable that holds the name of the requested colormap.
;                        Default :  NONE
;      GET_COLORS   :   Set this keyword to just get the RGB values of the colors in the
;                        requested colormap. The values are stored in the named variables
;                        "RED", "GREEN" and "BLUE".
;                        Default :  45 (Grey)
;       GET_NAMES   :   This is a named variable that holds the names of all the
;                        colormaps. Exit if this variable is requested.
;                        Default :  NONE
;
; PROCEDURE:
;	This procedure loads the requested colormap for subsequent use for
;       drawing purposes.
;
; EXAMPLE:
;	Load the "Wave" colormap (using its name)
;	  LoadColors, 'wave'
;	Load the "Wave" colormap (using its index)
;	  LoadColors, 50
;	Get the color values of the "Wave" colormap
;	  LoadColors, RED, GREEN, BLUE, 'wave', /GET_COLORS
;
; MODIFICATION HISTORY:
;	Created March 23 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

COMMON LoadedCT, LdTableName, LdTableType
Compile_Opt IDL2

on_error, 2

tvlct, rrORIG, ggORIG, bbORIG, /GET
  
; ===== Get the names of the system colormaps
loadct, get_names = sys_maps, /SILENT
sys_maps = strtrim(sys_maps, 2)
nSysMaps = n_elements(sys_maps)

; ===== Get the names of the brewer colormaps
brewfname = 'colors_brewer.tbl'
nBrewMaps = 0
dirs = expand_path(!PATH, /array)
for j = 0L, n_elements(dirs) - 1 do begin
    fname = file_which(dirs[j], brewfname, /INCLUDE_CURRENT_DIR)
    fname = fname[0]
    if (fname ne "") then begin
      if (readFILE(fname)) then begin
        openr, lun, fname, /GET_LUN
          ntables = 0b
          readu, lun, ntables
          brew_maps = BytArr(32, ntables)
          point_lun, lun, ntables * 768L + 1
          readu, lun, brew_maps
        free_lun, lun
        brew_maps = strtrim(brew_maps, 2)
        nBrewMaps = n_elements(brew_maps)
      endif else begin
        message, 'cannot read the brewer file: ', + fname
      endelse
      break
    endif
endfor

; ===== Get the names of the custom colormaps
Custom_Maps, get_names = cust_maps
cust_maps = strtrim(cust_maps, 2)
nCustMaps = n_elements(cust_maps)

; ===== Set the names of all the available colormaps in the "maps" variable
maps = [ sys_maps, brew_maps, cust_maps ]
nMaps = n_elements(maps)

; ===== "get_names" and exit
if arg_present(get_names) then begin
  get_names = strarr(nMaps)
  for i = 0, nMaps - 1 do begin
    map_str = '(System)'
    idx = (where(strmatch(brew_maps, maps[i]) eq 1))[0]
      if (idx ge 0) then map_str = '(Brewer)'
    idx = (where(strmatch(cust_maps, maps[i]) eq 1))[0]
      if (idx ge 0) then map_str = '(Custom)'
    get_names[i] = string(i, map_str, maps[i], format = '(i3, 2x, a, 2x, a)')
  endfor
  get_names = reform(get_names, 1, nMaps)

  return
endif


; ======================================================================
; ===== get the color table index from "maps" (default is the "Grey" index)
SYSTEM_CMAP = 0
BREWER_CMAP = 0
CUSTOM_CMAP = 0

if (n_elements(color_map) ne 0) then begin
  good = [2, 3, 12, 13, 14, 15]
  if (where(good eq size(color_map, /TYPE)) ge 0) then color_map = fix(color_map, TYPE = 2)
  case size(color_map, /TNAME) of
       'INT': begin
                if (color_map lt 0) or (color_map gt (nMaps - 1)) then begin
                  tmpstr = string(0, ' and ', nMaps - 1, format = '(i1, a5, i2)')
                  message, 'invalid map index, valid values are between: ' + tmpstr
                endif
                myMAP = maps[color_map]
              end
    'STRING': begin
                idx = (where(strcmp(maps, strtrim(color_map[0], 2) , /FOLD_CASE) eq 1, icnt))[0]
                if (icnt eq 0)then begin
                  message, 'invalid map name, to see the valid names use the "get_names" keyword'
                endif
                myMAP = maps[idx]
              end
        else: message, 'invalid map name or index were supplied'
  endcase
                
  idx = (where(strcmp(sys_maps, myMAP, /FOLD_CASE) eq 1, icnt))[0]
  if (icnt ne 0) then begin
    SYSTEM_CMAP = 1
    ncolor_map = idx
    LdTableName = sys_maps[ncolor_map]
    LdTableType = 'SYSTEM_CMAP'
  endif else begin
    idx = (where(strcmp(brew_maps, myMAP, /FOLD_CASE) eq 1, icnt))[0]
    if (icnt ne 0) then begin
      BREWER_CMAP = 1
      ncolor_map = idx
      LdTableName = brew_maps[ncolor_map]
      LdTableType = 'BREWER_CMAP'
    endif else begin
      idx = (where(strcmp(cust_maps, myMAP, /FOLD_CASE) eq 1, icnt))[0]
      if (icnt ne 0) then begin
        CUSTOM_CMAP = 1
        ncolor_map = idx
        LdTableName = cust_maps[ncolor_map]
        LdTableType = 'CUSTOM_CMAP'
      endif
    endelse
  endelse
endif else begin
  CUSTOM_CMAP = 1
  ncolor_map = (where(strcmp(cust_maps, 'GREY', /FOLD_CASE) eq 1))[0] > 0
  LdTableName = cust_maps[ncolor_map]
  LdTableType = 'CUSTOM_CMAP'
endelse


; export the name of the color table to be loaded
map_name = LdTableName

low_idx  = 0
high_idx = 255

; ======================================================================
; ===== load the user requested color map but not a customized one and exit
if ((SYSTEM_CMAP gt 0) or (BREWER_CMAP gt 0)) then begin
  cgLoadCT, ncolor_map, BREWER = BREWER_CMAP, /SILENT, _Extra = extra
  tvlct, RED, GREEN, BLUE, /GET

  if (keyword_set(gray)) then begin
;    gray_clr = 0.299 * RED + 0.587 * GREEN + 0.114 * BLUE
    gray_clr = fix(0.222 * RED + 0.707 * GREEN + 0.071 * BLUE)
    gray_clr = smooth(gray_clr, 3, /EDGE_TRUNCATE)
    RED   = gray_clr
    GREEN = gray_clr
    BLUE  = gray_clr
    tvlct, RED, GREEN, BLUE
  endif

  if (keyword_set(get_colors)) then begin
    tvlct, rrORIG, ggORIG, bbORIG
    return
  endif

  return
endif

; ======================================================================
; ===== load the user requested custom color map
Custom_Maps, RED, GREEN, BLUE, COLOR_MAP = myMAP, LOW_IDX = low_idx, HIGH_IDX = high_idx

if (keyword_set(reverse)) then begin
  RED[low_idx:high_idx]   = reverse(RED[low_idx:high_idx])
  GREEN[low_idx:high_idx] = reverse(GREEN[low_idx:high_idx])
  BLUE[low_idx:high_idx]  = reverse(BLUE[low_idx:high_idx])
endif

if (keyword_set(gray)) then begin
;  gray_clr = 0.299 * RED + 0.587 * GREEN + 0.114 * BLUE
  gray_clr = fix(0.222 * RED + 0.707 * GREEN + 0.071 * BLUE)
  gray_clr = smooth(gray_clr, 3, /EDGE_TRUNCATE)
  RED   = gray_clr
  GREEN = gray_clr
  BLUE  = gray_clr
endif

; ===== exit if the keyword "get_colors" is set
if (keyword_set(get_colors)) then begin
  tvlct, rrORIG, ggORIG, bbORIG
  return
endif

; ===== load the custom colorbar if this action is requested
tvlct, RED, GREEN, BLUE

end
