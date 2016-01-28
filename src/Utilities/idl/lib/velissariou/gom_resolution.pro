PRO gom_resolution, resol

  Compile_Opt IDL2

  COMMON GLParams
  COMMON RESParams

  ; Error handling.
  On_Error, 2

  resol = (n_elements(resol) eq 0) ? 1000.0 : abs(resol[0])

  USE_RESOL = 0 & dummy = temporary(USE_RESOL)
  GRID_FACT = 0 & dummy = temporary(GRID_FACT)
  str_res   = 0 & dummy = temporary(str_res)
  str1_res  = 0 & dummy = temporary(str1_res)
  gom_res   = 0 & dummy = temporary(gom_res)

  ;-------------------------------------------------
  ; ROMS model resolution
  ;USE_RESOL =  500 ; in m (0.005 deg. ~  500 m)
  ;USE_RESOL = 1000 ; in m ( 0.01 deg. ~ 1000 m)
  ;USE_RESOL = 2000 ; in m ( 0.02 deg. ~ 2000 m)
  ;USE_RESOL = 3000 ; in m ( 0.03 deg. ~ 3000 m)
  ;USE_RESOL = 4000 ; in m ( 0.04 deg. ~ 4000 m)
  ;USE_RESOL = 5000 ; in m ( 0.05 deg. ~ 5000 m)
  ;USE_RESOL = 6000 ; in m ( 0.06 deg. ~ 6000 m)
  ;USE_RESOL = 7000 ; in m ( 0.07 deg. ~ 7000 m)
  ;USE_RESOL = 8000 ; in m ( 0.08 deg. ~ 8000 m)

  USE_RESOL = round(resol)

  ; relative to an approximate 1000.0m resolution
  GRID_FACT = float(resol) / 1000.0

  ; Get the resolution strings
  tmp_str = strcompress(string(GRID_FACT, format = '(f9.3)'), /REMOVE_ALL)
  ; Remove all trailing zeros.
  len = strlen(tmp_str)
  while (strmid(tmp_str, len - 1, 1) EQ '0') do begin
    tmp_str = strmid(tmp_str, 0, len - 1)
    len = len - 1
  endwhile
  tmp_str = strcompress(strjoin(strsplit(tmp_str, '.', /EXTRACT), /SINGLE), /REMOVE_ALL)

  str_res  = '-' + tmp_str + 'k'
  str1_res = strmid(str_res, 1)
  gom_pfx  = 'gom' + str1_res

  ; Set some default map variables (for plotting)
  MapDel = 1.00
  nMapLabs = (USE_RESOL le 1000) ? 1 : 2
  DLATLON = (USE_RESOL le 1000) ? 2.0 : 4.0
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ;  MIN Rossby Radius ~ 27 km
  ; MEAN Rossby Radius ~ 42 km
  ;  MAX Rossby Radius ~ 62 km
  ; Data from:
  ;   http://www-po.coas.oregonstate.edu/research/po/research/rossby_radius/index.html
  ; Chelton, D. B., R. A. deSzoeke, M. G. Schlax, K. El Naggar and N. Siwertz,
  ;   1998: Geographical variability of the first-baroclinic Rossby radius of
  ;   deformation. J. Phys. Oceanogr., 28, 433-460.
  RRDEF = 62000 ; maximum estimated internal radius of deformation in m
  nBUFZONE = 0 ; default no buffer zone
  xtraBUFZONE = 0 ; extra grid points to be added to the BUFZONE in case they are needed
  if (n_elements(USE_RESOL) ne 0) then begin
    xtraBUFZONE = 5
    nBUFZONE = ceil(float(RRDEF) / float(USE_RESOL))
  endif
  extnBUFZONE = nBUFZONE + xtraBUFZONE

end
