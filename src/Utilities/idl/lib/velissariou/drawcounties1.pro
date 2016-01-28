;+
; NAME:
;       DRAWCOUNTIES1
;
; PURPOSE:
;
;       Draws state counties in the USA from county shape files.
;
; AUTHOR:
;
;       Panagiotis Velissariou
;       E-mail: belissariou.1@osu.edu
;
; CATEGORY:

;       Utilities
;
; CALLING SEQUENCE:
;
;       DrawCounties1, Records
;
; ARGUMENTS:
;
;       Records:       This the 1D vector of structures containing the values of the variables
;                      defining the counties (as obtained from "GetRecords").
;                       The structure is of the form:
;                       records = {stID:'', stNM:'', coFIPS:'', coNM:'', part:0L,
;                      where: stID = the state abbreviation id (e.g 'MI')
;                             stNM = the state official name (e.g 'Michigan')
;                           coFIPS = the county identification code
;                             coNM = the county official name (e.g 'Keweenaw')
;                             part = the county part indices (if consists from more than one partitions)
;                             lat  = the latitude of the vertex for that county
;                             lon  = the longitude of the vertex for that county
;
; KEYWORDS:
;
;     COUNTIES:        The name(s) of the counties you wish to draw the boundaries as retrieved
;                      from "Records". This is an 1D string vector containing the names
;                      of the counties or, 'ALL' which is the default.
;
;     COLORS:          The name of a color to draw the state outline or polygon in. This
;                      may be a string array of the same size as COUNTIES. Color names
;                      correspond to the colors available in GetColor. By default, "Blue".
;
;     BK_COLORS:       The name of a color to fill the state outline or polygon in. This
;                      may be a string array of the same size as COUNTIES. Bk_Color names
;                      correspond to the colors available in GetColor. By default, "Sky Blue".
;                      This is used only if also the keyword "Fill" is set.
;
;     LINESTYLE:       The normal LINESTYLE keyword index to choose plotting linestyles.
;                      By default, set to 0 and solid lines. May be a vector of the same
;                      size as COUNTIES.
;
;     THICK:           The line thickness. By default, 1.0.
;
;     FILL:            Set this keyword if filled counties are to be drawn (default no)
;
; F_ORIENTATION:       Use this keyword to fill the counties with lines instead of solid
;                      color (default no)
;
;     LABEL:           Set this keyword if the county names are to be drawn (default no)
;
;     TEXTFONT:        Define the font to be used when the county names are drawn.
;                      Fonts are defined as in TextFont function.
;
; RESTRICTIONS:
;
;     It is assumed a map projection command has been issued and is in effect at
;     the time this program is called.
;
;     If STATENAMES is undefined, all states are drawn, but only a single value
;     for COLORS, LINESTYLE, and THICK is allowed.
;
;     Required Coyote Library programs:
;
;       Error_Message
;
;     Required Personal programs:
;
;       GetColor
;       TextFont
;
; EXAMPLE:
;
;       Create a map with Nevada in yellow and other state's counties in blue.
;
;       Window, XSize=500, YSize=500, Title='County Boundaries'
;       Map_Set, 37.5, -120, /Albers, /IsoTropic, Limit=[30, -125, 45, -108], $
;         Position=[0.05, 0.05, 0.95, 0.95]
;       Erase, COLOR=GetColor('ivory')
;       Map_Grid, LatDel = 2.0, LonDel = 2.0, /Box_Axes, Color=GetColor('charcoal')
;       colors = [Replicate('dodger blue', 6), 'indian red']
;       DrawCounties1, records, Colors = colors, textfont = 8, /label
;
; MODIFICATION HISTORY:
;
;       Written by Panagiotis Velissariou, March 28, 2006.
;       (the code was extracted from the drawcounties.pro found in Coyote Library and
;        expanded to its present form)
;-
;###########################################################################
PRO DrawCounties1,                   $
      records,                       $
      COUNTIES = counties,           $
      Colors = colors,               $
      Bk_Colors = bk_colors,         $
      Linestyle = linestyle,         $
      Thick = thick,                 $
      Fill = fill,                   $
      F_Orientation = f_orientation, $
      Label = label,                 $
      TextFont = textfont,           $
      _Extra = extra

  ; error handling.
  catch, theError
  if theError ne 0 then begin
    ok = error_message(/traceback)
    return
  endif

  ; create an array of sorted/unique county names if 'ALL'
  theCounties = n_elements(counties) eq 0 ? 'ALL' : counties
  if (theCounties[0] eq 'ALL') then begin
    theCounties = records.coNM
    theCounties = theCounties[uniq(theCounties, sort(theCounties))]
  endif
  nCounties = n_elements(theCounties)

  ; this is for the boundary color(s)
  theColors = n_elements(colors) eq 0 ? 'Blue' : colors
  if (n_elements(theColors) eq 1) then theColors = replicate(theColors, nCounties)
  nColors = n_elements(theColors)
  if (nColors gt nCounties) then theColors = theColors[0:nCounties-1]
  if (nColors lt nCounties) then begin
    n = ceil(float(nCounties) / nColors)
    tmp = theColors
    for i = 0, n - 1 do tmp = [tmp, theColors]
    theColors = tmp[0:nCounties-1]
  endif

  ; this is for the fill color(s)
  fill = keyword_set(fill)
  if (fill) then begin
    theBk_Colors = n_elements(bk_colors) eq 0 ? 'Sky Blue' : bk_colors
    if (n_elements(theBk_Colors) eq 1) then theBk_Colors = replicate(theBk_Colors, nCounties)
    nBk_Colors = n_elements(theBk_Colors)
    if (nBk_Colors gt nCounties) then theBk_Colors = theBk_Colors[0:nCounties-1]
    if (nBk_Colors lt nCounties) then begin
      n = ceil(float(nCounties) / nBk_Colors)
      tmp = theBk_Colors
      for i = 0, n - 1 do tmp = [tmp, theBk_Colors]
      theBk_Colors = tmp[0:nCounties-1]
    endif
  endif

  linestyle = n_elements(linestyle) eq 0 ? 0 : linestyle[0]

  thick = n_elements(thick) eq 0 ? 1.0 : thick[0]

  ; this is to label or, not the counties
  label = keyword_set(label)
  textfont = n_elements(textfont) eq 0 ? 1 : fix(textfont)

  for i = 0L, n_elements(theCounties) - 1 do begin
    coIDX = where(records.coNM eq theCounties[i], coCount)
    countyName = (records[coIDX].coNM)[0]

    if (coCount gt 0) then begin
      coFIPS = records[coIDX].coFIPS
      coFIPS = coFIPS[uniq(coFIPS)]

      for j = 0, n_elements(coFIPS) - 1 do begin
        idx = where(records[coIDX].coFIPS eq coFIPS[j], count)
        if (count gt 0) then begin
          indices = coIDX[idx]
          low_part = min(records[indices].part, max = high_part)

          for k = low_part, high_part do begin
            idx = where(records[indices].part eq k, count)
            if (count gt 0) then begin
              xx = records[indices[idx]].lon
              yy = records[indices[idx]].lat

              if (fill) then $
                polyfill, xx, yy, orientation = f_orientation, color = GetColor(theBk_Colors[i])

              plots, xx, yy, color = GetColor(theColors[i]), $
                     linestyle = linestyle, thick = thick, _Extra = extra
            endif
          endfor
          if (label) then begin
            xx = mean(records[indices].lon)
            yy = mean(records[indices].lat)
            text = TextFont(countyName, textfont)
            xyouts, xx, yy, text, _Extra = extra
          endif
        endif
      endfor
    endif
  endfor

end
