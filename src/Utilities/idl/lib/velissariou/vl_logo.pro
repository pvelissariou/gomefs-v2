PRO VL_Logo,               $
      Position,            $
      Fname,               $
      Scale    = scale,    $
      Bk_Color = bk_color, $
      LogoDims = logodims, $
      Get_Dims = get_dims, $
      _EXTRA = extra
;+++
; NAME:
;	VL_Logo
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (pvelissariou@fsu.edu)
;
; PURPOSE:
;	This procedure plots a title text within the specified position box.
;
; CATEGORY:
;	Graphics
;
; CALLING SEQUENCE:
;	VL_PlotTitle, Position, [keywords]
;
;       position    :   A 4-element vector containing the position:
;                        [x_min,y_min, x_max, y_max] in normal/data or device
;                        coordinates of the lower left and upper right corners
;                        of the box containing the title(s).
;                        Default :  NONE
;       fname       :   The filename (full path) of the logo image.
;                        Default :  NONE
;
; KEYWORD PARAMETERS:
;      bk_color     :   This is the index for the background color to be used
;                        to fill the background of the logo area.
;                        Default :  !P.BACKGROUND
;      LogoDims     :   A named variable that holds the final dimensions
;                        of the rectangle enclosing the logo image.
;                        and to the right edges of the title box, when drawing
;                        the title texts.
;                        Default :  NONE
;
; PROCEDURE:
;	This procedure uses the input values to place a logo image
;	on the current plot.
;
; EXAMPLE:
;	  VL_Logo, [0.01, 0.01, 0.99, 0.25], $
;                  'mylogo.jpg, $
;                   scale = 1.5, $
;                   logodims = dims
;
; MODIFICATION HISTORY:
;	Developed April  8 2012 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

Compile_Opt IDL2

COMMON PlotParams

on_error, 2

defScale     = 1.0
defBackColor = !P.BACKGROUND

; --------------------
; Check the fname (a string) input variable
if ( size(fname[0], /TNAME) ne 'STRING' ) then $
  message, 'a string is required for <fname>'

thisFNAME = strcompress(fname[0], /REMOVE_ALL)

thisIMG_OK = query_jpeg(thisFNAME, thisIMG_INFO)
if (thisIMG_OK ne 1) then $
  thisIMG_OK = query_png(thisFNAME, thisIMG_INFO)
if (thisIMG_OK ne 1) then $
  thisIMG_OK = query_ppm(thisFNAME, thisIMG_INFO)
if (thisIMG_OK ne 1) then $
  thisIMG_OK = query_gif(thisFNAME, thisIMG_INFO)
if (thisIMG_OK ne 1) then $
  thisIMG_OK = query_gif(thisFNAME, thisIMG_INFO)
if (thisIMG_OK ne 1) then $
  thisIMG_OK = query_tiff(thisFNAME, thisIMG_INFO)
if (thisIMG_OK ne 1) then $
  thisIMG_OK = query_bmp(thisFNAME, thisIMG_INFO)

if (thisIMG_OK ne 1) then begin
  message, 'could not determine the logo image type', /INFORMATIONAL
  message, 'accepted image types are: JPEG, PNG, PPM, GIF, TIFF, BMP'
endif

thisIMG_TYPE = strupcase(thisIMG_INFO.type)
; --------------------

; --------------------
; Check the position input variable
numtypes = [2, 3, 4, 5, 12, 13, 14, 15]
num_val = where(numtypes eq size(position, /type))
if ( num_val[0] eq -1 ) then $
  message, "<position> should be a vector of numbers."

thisPOSITION = float(position)

if ((size(thisPOSITION))[0] ne 1) then begin
  message, '<position> should be a vector of 2 or 4 elements.'
endif else begin
  if ((n_elements(thisPOSITION) ne 2) and (n_elements(thisPOSITION) ne 4)) then $
    message, '<position> should be a vector of 2 or 4 elements.'
endelse
; --------------------

; --------------------
; Check the scale input variable
thisSCALE = defScale
if (n_elements(scale) ne 0) then begin
  numtypes = [2, 3, 4, 5, 12, 13, 14, 15]
  num_val = where(numtypes eq size(scale, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<scale> should be a number."
  thisSCALE = float(scale[0]) > 0.0
endif
; --------------------

; --------------------
; Background color
thisBk_Color  = n_elements(bk_color) eq 0 ? defBackColor : 255 - (255 - fix(abs(bk_color)) > 0)
; --------------------

; --------------------------------------------------------------------------------
old_dev = !D.NAME
set_plot, 'Z'
device, set_resolution = DevResolution
thisIMG_DIMS = convert_coord(thisIMG_INFO.dimensions, /device, /to_normal)
set_plot,old_dev

if (n_elements(position) eq 2) then begin
  thisPOSITION = [ thisPOSITION[0],                   $
                   thisPOSITION[1],                   $
                   thisPOSITION[0] + thisIMG_DIMS[0], $
                   thisPOSITION[1] + thisIMG_DIMS[1]  $
                 ]
endif

if (n_elements(scale) ne 0) then begin
  scoord = Transform2DShape([ thisPOSITION[0], thisPOSITION[2] ], $
                            [ thisPOSITION[1], thisPOSITION[3] ], $
                            scale = thisScale)
  xx = reform(scoord[0,*])
  yy = reform(scoord[1,*])
  thisPOSITION = [ xx[0], yy[0], xx[1], yy[1] ]
endif

if (keyword_set(get_dims)) then begin
  logodims = thisPOSITION
  return
endif

case thisIMG_TYPE of
   'BMP':  read_bmp, thisFNAME, thisIMG
   'GIF':  read_gif, thisFNAME, thisIMG
  'JPEG': read_jpeg, thisFNAME, thisIMG
   'PNG':  read_png, thisFNAME, thisIMG
   'PPM':  read_ppm, thisFNAME, thisIMG
  'TIFF': read_tiff, thisFNAME, thisIMG
    else:   message, 'image format is not recognized'
endcase

cgImage, thisIMG, position = thisPOSITION, /KEEP_ASPECT,          $
         Background = thisBk_Color,                               $
         OPosition = logodims

end
