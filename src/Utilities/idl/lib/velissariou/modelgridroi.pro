FUNCTION ModelGridRoi, xarr, yarr, xpnts, ypnts, $
                       REGNAME = regname,        $
                       CLIP = clip,              $
                       XPOLY = xpoly,            $
                       YPOLY = ypoly
;+++
; NAME:
;	ModelGridRoi
; VERSION:
;	1.0
; PURPOSE:
;	To find all the grid points (pixels?) that constitute
;       the line defined by the two points (x0,y0) and (x1,y1)
; CALLING SEQUENCE:
;	idxout = ModelGridRoi(xarr, yarr, 'Jamaica')
;	On input:
;             xarr - The 2D matrix of the x-coorinates (longitude)
;             yarr - The 2D matrix of the y-coorinates (latitude)
;            xpnts - The 1D vector of the x-coordinates of the
;                    enclosing polygon of the roi
;            dyarr - The 1D vector of the y-coordinates of the
;                    enclosing polygon of the roi
;          regname - The name of one of the build in default regions
;                    OPTIONAL
;             CLIP - Set a clip polygon, Indices found outside this
;                    polygon are clipped (not part of the roi - OPTIONAL)
;                    This should be a 2xn array.
;            XPOLY - A named variable that holds the x-coordinates of the
;                    enclosing polygon of the roi (OPTIONAL)
;            YPOLY - A named variable that holds the y-coordinates of the
;                    enclosing polygon of the roi (OPTIONAL)
;	On output:
;	  IDXOUT - The indices of all the grid points that are part
;                  of the roi (relevant to xarr,yarr)
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created Oct 20 2012 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  ; Error handling.
  On_Error, 2

  if ( array_equal(size(xarr), size(yarr), /NO_TYPECONV) ne 1) then begin
    message, 'incompatible array sizes found for [xarr, yarr]'
  endif

  if (size(xarr, /N_DIMENSIONS) ne 2) then begin
    message, '2D arrays are required for [xarr, yarr]'
  endif

  ; check the input variables
  do_regname = 0
  do_xpnts = 0
  do_ypnts = 0
  do_clip = 0

  if (n_elements(regname) ne 0) then begin
    regname = regname[0]
    if (size(regname, /TNAME) ne 'STRING') then $
      message, 'REGNAME should be a string variable'
    do_regname = 1
  endif else begin
    do_xpnts = (n_elements(xpnts) ne 0) ? 1 : 0
    do_ypnts = (n_elements(ypnts) ne 0) ? 1 : 0

    if ((do_xpnts + do_ypnts) ne 2) then $
      message, 'both [XPNTS, YPNTS] need to be defined'

    if ( array_equal(size(xpnts), size(ypnts), /NO_TYPECONV) ne 1) then $
      message, 'incompatible array sizes found for [XPNTS, YPNTS]'

    if (size(xpnts, /N_DIMENSIONS) ne 1) then begin
      message, '1D scalar vectors are required for [XPNTS, YPNTS]'
    endif
  endelse

  ; get the cliiping region if one is supplied by the user
  if (n_elements(clip) ne 0) then begin
    sz_clip = size(clip)
    if ((sz_clip[0] ne 2) and (sz_clip[1] ne 2)) then $
      message, 'a 2xn array is required for CLIP'
    
    do_clip = 1
    my_xclip = reform(clip[0, *])
      my_xclip = [ my_xclip, my_xclip [0] ]
    my_yclip = reform(clip[1, *])
      my_yclip = [ my_yclip, my_yclip [0] ]
  endif

  ; set some default regions to be used id REGNAME is supplied by the user
  if do_regname then begin
    case 1 of
      strmatch(strupcase(regname), '*BAHAMAS*'): $
        begin
          my_xpnts = [ -79.60, -76.30, -74.00, -73.40, -77.00, -79.50, -79.60 ]
          my_ypnts = [  27.70,  27.00,  23.80,  21.60,  22.00,  23.30,  27.70 ]
        end
      strmatch(strupcase(regname), '*BANCO*CHINCHORRO*'): $
        begin
          my_xpnts = [ -87.50, -87.10, -87.10, -87.50, -87.50 ]
          my_ypnts = [  18.85,  18.85,  18.30,  18.30,  18.85 ]
        end
      strmatch(strupcase(regname), '*BLANCA*'): $
        begin
          my_xpnts = [ -89.85, -89.60, -89.58, -89.85, -89.85 ]
          my_ypnts = [  22.60,  22.60,  22.32,  22.35,  22.60 ]
        end
      strmatch(strupcase(regname), '*CAYMAN*'): $
        begin
          my_xpnts = [ -81.60, -79.50, -79.50, -81.60, -81.60 ]
          my_ypnts = [  19.60,  20.00,  19.00,  19.00,  19.60 ]
        end
      strmatch(strupcase(regname), '*CAYOS*NORTH*'): $
        begin
          my_xpnts = [ -81.15, -81.30, -80.70, -77.55, -76.90, -77.25, -77.61, -78.79, -79.52, -81.15 ]
          my_ypnts = [  23.10,  23.22,  23.50,  22.30,  21.55,  21.57,  21.84,  22.46,  22.71,  23.10 ]
        end
      strmatch(strupcase(regname), '*CAYOS*SOUTH*'): $
        begin
          my_xpnts = [ -80.17, -78.94, -78.20, -78.20, -80.17, -80.17 ]
          my_ypnts = [  21.45,  21.45,  20.58,  20.40,  20.40,  21.45 ]
        end
      strmatch(strupcase(regname), '*COZUMEL*'): $
        begin
          my_xpnts = [ -86.96, -86.60, -86.60, -87.20, -86.96 ]
          my_ypnts = [  20.62,  20.69,  20.18,  20.18,  20.62 ]
        end
      strmatch(strupcase(regname), '*CUBA*'): $
        begin
          my_xpnts = [ -86.00, -78.30, -73.60, -73.60, -85.50, -86.00 ]
          my_ypnts = [  23.70,  23.30,  20.30,  19.20,  20.40,  23.70 ]
        end
      strmatch(strupcase(regname), '*FLORIDA KEYS*'): $
        begin
          my_xpnts = [ -83.30, -80.10, -82.00, -83.30, -83.30 ]
          my_ypnts = [  24.90,  25.10,  24.15,  24.50,  24.90 ]
        end
      strmatch(strupcase(regname), '*JAMAICA*'): $
        begin
          my_xpnts = [ -78.60, -75.80, -75.80, -78.60, -78.60 ]
          my_ypnts = [  18.70,  18.70,  17.50,  17.50,  18.70 ]
        end
      strmatch(strupcase(regname), '*JUVENTUD*'): $
        begin
          my_xpnts = [ -83.85, -83.10, -82.67, -82.30, -82.15, -81.08, -81.08, -83.85, -83.85 ]
          my_ypnts = [  22.00,  22.16,  22.57,  22.57,  22.05,  21.80,  21.30,  21.30,  22.00 ]
        end
      else: $
        begin
          message, 'wrong REGNAME is supplied'
        end
    endcase
  endif else begin
    ; Close the polygon
    my_xpnts = [ xpnts, xpnts[0] ]
    my_ypnts = [ ypnts, ypnts[0] ]
  endelse

  xpoly = my_xpnts
  ypoly = my_ypnts

  idxout = vl_inside(xarr[*], yarr[*], my_xpnts, my_ypnts, INDEX = index)

  if do_clip then begin
    if (min(idxout) ge 0) then begin
      idxclip = vl_inside(xarr[idxout], yarr[idxout], my_xclip, my_yclip, INDEX = index)
      idxout = (min(idxclip) ge 0) ? idxout[idxclip] : -1L
    endif
  endif

  return, idxout
end
