
;Command     Hershey Vector Font     TrueType Font     PostScript Font 
;  !3      Simplex Roman (default)     Helvetica          Helvetica 
;  !4      Simplex Greek             Helvetica Bold     Helvetica Bold 
;  !5      Duplex Roman              Helvetica Italic   Helvetica Narrow 
;  !6      Complex Roman          Helvetica Bold Italic Helvetica Narrow Bold Oblique 
;  !7      Complex Greek                Times               Times Roman 
;  !8      Complex Italic            Times Italic       Times Bold Italic 
;  !9     Math/special characters       Symbol                Symbol 
;  !M     Math/special characters
;        (change effective for one
;        character only)                Symbol                Symbol 
; !10    Special characters             Symbol *          Zapf Dingbats 
; !11(!G)  Gothic English               Courier               Courier 
; !12(!W)  Simplex Script           Courier Italic       Courier Oblique 
; !13      Complex Script           Courier Bold             Palatino 
; !14      Gothic Italian           Courier Bold Italic  Palatino Italic 
; !15      Gothic German              Times Bold         Palatino Bold 
; !16      Cyrillic                 Times Bold Italic    Palatino Bold Italic 
; !17      Triplex Roman              Helvetica *        Avant Garde Book 
; !18      Triplex Italic             Helvetica *        New Century Schoolbook 
; !19                                 Helvetica *        New Century Schoolbook Bold 
; !20      Miscellaneous              Helvetica *        Undefined User Font 
; !X   Revert to the entry font Revert to the entry font Revert to the entry font 
;* The font assigned to this index may be replaced in a future release of IDL. 
Function TextFont, text, font

  on_error, 2

  if (size(text, /type) ne 7) or         $
     (size(text, /n_dimensions) gt 1) or $
     (n_elements(text) eq 0)        then $
    message, "you need to supply a string or, a 1-D string array for <text>."

  thisFont = n_elements(font) eq 0 ? - 1 : fix(font[0])

  case thisFont of
       3: retval =  '!3' + text + '!X'
       4: retval =  '!4' + text + '!X'
       5: retval =  '!5' + text + '!X'
       6: retval =  '!6' + text + '!X'
       7: retval =  '!7' + text + '!X'
       8: retval =  '!8' + text + '!X'
       9: retval =  '!9' + text + '!X'
      10: retval = '!10' + text + '!X'
      11: retval = '!11' + text + '!X'
      12: retval = '!12' + text + '!X'
      13: retval = '!13' + text + '!X'
      14: retval = '!14' + text + '!X'
      15: retval = '!15' + text + '!X'
      16: retval = '!16' + text + '!X'
      17: retval = '!17' + text + '!X'
      18: retval = '!18' + text + '!X'
      19: retval = '!19' + text + '!X'
    else: retval = text
  endcase

  return, strtrim(retval, 2)

end
