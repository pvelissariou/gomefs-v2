Pro WriteGrid, fname, To_File = to_file, To_Screen = to_screen
;+++
; NAME:
;	WriteGrid
; VERSION:
;	1.0
; PURPOSE:
;	To read a bathymetric grid data file and return grid parameters
;       and depths.
; CALLING SEQUENCE:
;	WriteGrid, fname
;	   fname - Full pathway name of output (lat, lon) grid.
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

on_error, 2

; Check for "To_File", "To_Screen" printing
to_file   = keyword_set(to_file)
to_screen = keyword_set(to_screen)
if to_file + to_screen gt 1 then begin
  print,' set only one of /TO_FILE, /TO_SCREEN.'
  return
endif
if (to_screen eq 0) then to_screen = 1 - to_file

if keyword_set(to_file) then begin
  if (n_elements(fname) eq 0) then $
    message, "you need to supply a valid name for <fname>"

  if (size(fname, /TNAME ) ne 'STRING') then $
    message, "the name supplied for <" + fname + "> is not a valid string."

  fname = strtrim(fname, 2)
endif

COMMON BathParams

formstr = '(2(1x, i3), 2(1x, f11.6), 1x, f8.4)'

if keyword_set(to_file) then begin
  openw, 3, fname
  for j = 0, JPNTS - 1 do begin
    for i = 0, IPNTS - 1 do begin
        printf, 3, i+1, j+1, latgrid[i, j], longrid[i, j], dgrid[i, j], format = formstr
    endfor
  endfor
  close, 3
endif

if keyword_set(to_screen) then begin
  for j = 0, JPNTS - 1 do begin
    for i = 0, IPNTS - 1 do begin
        print, i+1, j+1, latgrid[i, j], longrid[i, j], dgrid[i, j], format = formstr
    endfor
  endfor
endif

return

end
