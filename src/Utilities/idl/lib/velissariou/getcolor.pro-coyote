Function GetColor,          $
           color,           $
           NAMES = names,   $
           _Extra = extra
;+++
; NAME:
;	GetColor
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;	This function returns the indeces (0 - 255) of the colors defined in "color"
;       as found in the color definitions in the procedure "LoadColors".
;
; CATEGORY:
;	Graphics
;
; CALLING SEQUENCE:
;	GetColor(color) or, GetColor(/NAMES)
;
;          color    :   A scalar or, vector of integer or, string values that identify
;                        the colors defined in the procedure "LoadColors".
;                        Default :  0
;
; KEYWORD PARAMETERS:
;          NAMES    :   Set this keyword to return the names of all colors defined here.
;                        Default :  NONE
;
; FUNCTION:
;	This function returns the indeces (0 - 255) of the colors defined in "color"
;	as found in the color definitions in the procedure "LoadColors".
;
; EXAMPLE:
;	GetColor('Light Yellow')
;       GetColor(['Purple', 'Light Yellow', 'Green'])
;       GetColor(/names)
;
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

COMMON LoadedCT, LdTableName, LdTableType
Compile_Opt IDL2

on_error, 2

whichMAP = (n_elements(LdTableType) ne 0) ? strtrim(LdTableType, 2) : ''

; these custom colors are defined in the procedure LoadColors
cust_colors = reform(Colors_Base())
cust_colors = $
 [   cust_colors, $
     'CLR1',    'CLR2',    'CLR3',    'CLR4',    'CLR5',    'CLR6',    'CLR7',    'CLR8', $ ; 128-255
     'CLR9',   'CLR10',   'CLR11',   'CLR12',   'CLR13',   'CLR14',   'CLR15',   'CLR16', $
    'CLR17',   'CLR18',   'CLR19',   'CLR20',   'CLR21',   'CLR22',   'CLR23',   'CLR24', $
    'CLR25',   'CLR26',   'CLR27',   'CLR28',   'CLR29',   'CLR30',   'CLR31',   'CLR32', $
    'CLR33',   'CLR34',   'CLR35',   'CLR36',   'CLR37',   'CLR38',   'CLR39',   'CLR40', $
    'CLR41',   'CLR42',   'CLR43',   'CLR44',   'CLR45',   'CLR46',   'CLR47',   'CLR48', $
    'CLR49',   'CLR50',   'CLR51',   'CLR52',   'CLR53',   'CLR54',   'CLR55',   'CLR56', $
    'CLR57',   'CLR58',   'CLR59',   'CLR60',   'CLR61',   'CLR62',   'CLR63',   'CLR64', $
    'CLR65',   'CLR66',   'CLR67',   'CLR68',   'CLR69',   'CLR70',   'CLR71',   'CLR72', $
    'CLR73',   'CLR74',   'CLR75',   'CLR76',   'CLR77',   'CLR78',   'CLR79',   'CLR80', $
    'CLR81',   'CLR82',   'CLR83',   'CLR84',   'CLR85',   'CLR86',   'CLR87',   'CLR88', $
    'CLR89',   'CLR90',   'CLR91',   'CLR92',   'CLR93',   'CLR94',   'CLR95',   'CLR96', $
    'CLR97',   'CLR98',   'CLR99',  'CLR100',  'CLR101',  'CLR102',  'CLR103',  'CLR104', $
   'CLR105',  'CLR106',  'CLR107',  'CLR108',  'CLR109',  'CLR110',  'CLR111',  'CLR112', $
   'CLR113',  'CLR114',  'CLR115',  'CLR116',  'CLR117',  'CLR118',  'CLR119',  'CLR120', $
   'CLR121',  'CLR122',  'CLR123',  'CLR124',  'CLR125',  'CLR126',  'CLR127',  'CLR128'  $
 ]

; these custom colors are defined in the procedure LoadColors
colors = reform(cgColor(/NAMES))

if keyword_set(names) then begin
  if (strcmp(whichMAP, 'CUSTOM_CMAP', /FOLD_CASE) eq 1)  then begin
    return, reform(cust_colors, 1, n_elements(cust_colors))
  endif else begin
    return, cgColor(/NAMES)
  endelse
endif

retval = 0
nColors = n_elements(color)
if (nColors eq 0) then return, 0

good = [2, 3, 12, 13, 14, 15]
if (where(good eq size(color, /TYPE)) ge 0) then color = fix(color, TYPE = 2)

case size(color, /TNAME) of
     'INT': begin
              ; in this case we are just using the custom colors defined here
              if (strcmp(whichMAP, 'CUSTOM_CMAP', /FOLD_CASE) eq 1)  then begin
                retval = fix(abs(color)) < 255
              endif else begin
                retval  = cgColor(colors[color], _Extra = extra)
              endelse
            end
  'STRING': begin
              color = strtrim(color, 2)
              if (strcmp(whichMAP, 'CUSTOM_CMAP', /FOLD_CASE) eq 1)  then begin
                if (nColors eq 1) then begin
                  retval = (where(strcmp(cust_colors, color, /FOLD_CASE) eq 1))[0] > 0
                endif else begin
                  retval = intarr(nColors)
                  for i = 0, nColors - 1 do $
                    retval[i] = (where(strcmp(cust_colors, color[i], /FOLD_CASE) eq 1))[0] > 0
                endelse
              endif else begin
                retval  = cgColor(color, _Extra = extra)
              endelse
            end
      else: message, 'no valid color name or index were supplied by the user'
endcase

return, retval

end
