PRO VL_MapVector, u, v, lons, lats,      $
                  HSIZE = hsize,         $
                  LENGTH = length,       $
                  THICK = thick,         $
                  HTHICK = hthick,       $
                  LINESTYLE = linestyle, $
                  COLOR = color,         $
                  SOLID = solid,         $
                  CLIP = clip,           $
                  PALETTE = palette,     $
                  _EXTRA = extrakeywords

    Compile_Opt IDL2

    on_error, 2

    ; You have to have data to plot. If not exit quietly.
    IF (N_Elements(lons) EQ 0) OR (N_Elements(lats) EQ 0) THEN BEGIN
        Message, 'The Lons and Lats arrays must be supplied in order to proceed.'
    ENDIF
    IF (N_Elements(u) EQ 0) OR (N_Elements(v) EQ 0) THEN BEGIN
        Message, 'The U and V arrays must be supplied in order to proceed.'
    ENDIF
    
    ; If the vectors don't all have the same number of elements, there is an error.
    IF N_Elements(lons) NE N_Elements(lats) THEN BEGIN
        Message, 'The number of elements in the latitude and longitude arrays must be the same.'
    ENDIF
    IF N_Elements(u) NE N_Elements(v) THEN BEGIN
        Message, 'The number of elements in the U and V arrays must be the same.'
    ENDIF
    IF N_Elements(lons) NE N_Elements(v) THEN BEGIN
        Message, 'The number of elements in the lon, lat, u, and v arrays must be the same.'
    ENDIF


    ; ----- Defaults
    IF N_Elements(color) EQ 0 THEN color = "Black"

    IF N_Elements(thick) EQ 0 THEN BEGIN
      thick = 1.0
    ENDIF ELSE thick = Abs(thick[0])

    IF N_Elements(hthick) EQ 0 THEN BEGIN
      hthick = thick
    ENDIF ELSE hthick = Abs(hthick[0])

    IF N_Elements(hsize) EQ 0 THEN BEGIN
      hsize = Min([!d.x_vsize, !d.y_vsize])/64.0 * (hthick/2. > 1)
    ENDIF ELSE hsize = hsize[0]

    IF N_Elements(linestyle) EQ 0 THEN BEGIN
      linestyle = 0
    ENDIF ELSE linestyle = Fix(Abs(linestyle[0]))

    ; Do we have to assign a value to length?
    IF N_Elements(length) EQ 0 THEN BEGIN
        maxlen = Max( [Max(lons)-Min(lons), Max(lats)-Min(lats)] )
        length = maxlen / 100.0 
    ENDIF ELSE length = Abs(length[0])

    ; If clip is not defined, then set it here.
    IF N_Elements(clip) EQ 0 THEN BEGIN
      clip = [!X.CRange[0], !Y.CRange[0], !X.CRange[1], !Y.CRange[1]]
    ENDIF ELSE clip = [clip[0], clip[1], clip[2], clip[3]]

    ; Load colors if you have them.
    IF N_Elements(palette) NE 0 THEN BEGIN
        TVLCT, r, g, b, /Get
        TVLCT, palette
    ENDIF
    ; -----


    ; Scale the U and V values by the length.
    maxmag = Max(Sqrt(u^2 + v^2))
    uscaled = (u/maxmag) * length 
    vscaled = (v/maxmag) * length 

    ; Calculate the endpoints of the arrow and draw it.
    FOR j=0L,N_Elements(u)-1 DO BEGIN
        x0 = (lons)[j]
        y0 = (lats)[j]
        x1 = x0 + uscaled[j]
        y1 = y0 + vscaled[j]
        xhalf = (x1-x0)/2.0
        yhalf = (y1-y0)/2.0
        x0 = x0 - xhalf
        y0 = y0 - yhalf
        x1 = x1 - xhalf
        y1 = y1 - yhalf
        VL_DrawArrow, x0, y0, x1, y1,         $
                      HSIZE = hsize,          $
                      THICK = thick,          $
                      HTHICK = thick,         $
                      LENGTH = length,        $
                      COLOR = color,          $
                      CLIP = clip,            $
                      SOLID = solid,          $
                      _EXTRA = extrakeywords, $
                      /DATA,                  $
                      LINESTYLE = linestyle
    ENDFOR

    IF N_Elements(palette) NE 0 THEN TVLCT, r, g, b
END
