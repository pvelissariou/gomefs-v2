PRO CONVERT_IMG, FileName, Type, ReScale = rescale

;+
; NAME:
;	CONVERT_IMG
; VERSION:
;	1.0
; PURPOSE:
;	To write the image in the Z-Buffer to a file defined
;       by "FileName" in the format defined by "Type"
;       Valid image formats are: <bmp, jpeg, png, ppm, srf, tiff>.
; CATEGORY:
;	Graphics.
; CALLING SEQUENCE:
;	CONVERT_IMG, FileName, Type
;       No filename extension is required as this is appended to "FileName"
;       by this procedure. If the "FileName" contains the extension, this
;       is stripped out.
; OUTPUTS:
;	The image file in the format specified.  
; SIDE EFFECTS:
;	As far as I know none.
; RESTRICTIONS:
;       The GIF format is not lately supported by IDL due to licensing restrictions
;       from UNISYS (may be this will change in newer versions of IDL). If the user
;       desires the creation of "gif" files he/she can create via this procedure
;       a "ppm" file and use the program "ppmtogif" to create the "gif" file.
;       The "ppmtogif" program is part of the NetPBM package which is
;       freely available (see: http://netpbm.sourceforge.net/). Alternatively
;       the user can use instead the "png" or, "jpeg" formats.
;       LZW compression is also not supported in IDL due again to licensing
;       restrictions from UNISYS.
; MODIFICATION HISTORY:
;	Created Tue Apr 1 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;-

on_error, 1

;----- Check for Z-Buffer device
if ( !D.NAME ne 'Z' ) then return

;----- Check the input arguments
np = n_params()

if ( np lt 2 ) then $
  message, 'Calling sequence is <convert_img, FileName, Type>'

if ( size(FileName, /type) ne 7 ) then begin
  message, 'Not a valid string for <FileName>.'
endif else begin
  if ( strpos(FileName,'.') eq -1 ) then begin
    ImgName = FileName
  endif else begin
    ImgName = strmid(FileName, 0, strpos(FileName, '.', /reverse_search))
  endelse
endelse

if ( size(Type, /type) ne 7 ) then $
  message, 'Not a valid string for <Type>.'

ImgName = strtrim(ImgName, 2)
ImgType = strtrim(Type, 2)

;----- Get the color table currently loaded in the device
tvlct, R, G, B, /get

;----- Get the 2-D image currently in the Z-Buffer and it's dimensions
ImgDev = tvrd()
ImgDim = size(ImgDev, /dimensions)

;----- Create a 24-bit image from the 2-D image currently in the Z-Buffer
ImgNew = bytarr(3, ImgDim[0], ImgDim[1])
ImgNew[0, *, *] = R[ImgDev]
ImgNew[1, *, *] = G[ImgDev]
ImgNew[2, *, *] = B[ImgDev]

if n_elements(rescale) eq 1 then begin
  ImgReBin = abs(float(rescale))
  ImgNew = rebin( ImgNew, 3, ImgDim[0] / ImgReBin, ImgDim[1] / ImgReBin )
endif

case ImgType of
  'bmp' : begin
            ImgName = ImgName + '.' + 'bmp'
            write_bmp,  ImgName, ImgNew, R, G, B, /rgb
          end
  'jpeg': begin
            ImgName = ImgName + '.' + 'jpeg'
            write_jpeg, ImgName, ImgNew, quality = 100, true = 1
          end
  'jpg': begin
            ImgName = ImgName + '.' + 'jpg'
            write_jpeg, ImgName, ImgNew, quality = 100, true = 1
          end
  'png' : begin
            ImgName = ImgName + '.' + 'png'
            write_png,  ImgName, ImgNew, R, G, B
          end
  'ppm' : begin
            ImgName = ImgName + '.' + 'ppm'
            write_ppm,  ImgName, reverse(ImgNew,3)
          end
  'srf' : begin
            ImgName = ImgName + '.' + 'srf'
            write_srf,  ImgName, reverse(ImgNew, 3), R, G, B, /write_32
          end
  'tiff': begin
            ImgName = ImgName + '.' + 'tiff'
            write_tiff, ImgName, reverse(ImgDev, 2), $
                        red = R, green = G, blue = B
          end
  'tif': begin
            ImgName = ImgName + '.' + 'tif'
            write_tiff, ImgName, reverse(ImgDev, 2), $
                        red = R, green = G, blue = B
          end
   else : message, 'Not a supported image format requested.'
endcase

end
