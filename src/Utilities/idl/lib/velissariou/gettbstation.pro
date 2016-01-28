Function GetTBStation,      $
           gDB,             $
           gID    = gid,    $
           MHHW   = mhhw,   $
           MHW    = mhw,    $
           NAVD88 = navd88, $
           MTL    = mtl,    $
           MSL    = msl,    $
           MLW    = mlw,    $
           MLLW   = mllw,   $
           BATH   = bath,   $
           IDS    = ids,    $
           Names  = names,  $
           FEET   = feet
;+++
; NAME:
;    GetTBStation
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;	To obtain the properties of a Water Level gage station by reading the
;	 database file with the station information.
;
; CATEGORY:
;	Data
;
; CALLING SEQUENCE:
;	GetTBStation(gDB, [keyword1 = value], [keyword2 = value], ...)
;
;          gDB      :   The name of the file that contains the gage information.
;                        The format of the database file is as follows:
;
;          NOS STATIONS
;          ------------
;                        Columns
;                        -------
;                                 NOS Geographic region code
;                                 --------------------------
;                         1- 3    831 = St. Lawrence River
;                                 901 = St. Clair River
;                                 903 = Lake St. Clair
;                                 904 = Detroit River
;                                 905 = Lake Ontario
;                                 906 = Lake Erie, Niagara River
;                                 907 = Lake Huron, St. Mary's River
;                                 908 = Lake Michigan
;                                 909 = Lake Superior
;
;                                 NOS Gauge ID code
;                                 -----------------
;                         4- 7    10dd = St. Lawrence River
;                                 20dd = Lake Ontario
;                                 30dd = Lake Erie, Niagara River
;                                 40dd = Lake St. Clair, Detroit River, St. Clair River
;                                 50dd = Lake Huron
;                                 60dd = St. Mary's River
;                                 70dd = Lake Michigan
;                                 90dd = Lake Superior
;
;                         8-28    Gauge Location
;
;                        29-32    Latitude in hundredths of a degree
;
;                        33-36    Longitude in hundredths of a degree
;
;                        37-39    Low water datum in meters (IGLD 1985)
;
;                                 Reporting frequency
;                                 -------------------
;                        40-40    0 = Hourly
;                                 1 = Daily
;                                 2 = Monthly
;
;                                 Time zone of gauge
;                                 ------------------
;                        41-41    0 = Greenwich mean time
;                                 1 = Eastern time
;                                 2 = Central time
;
; KEYWORD PARAMETERS:
;          gID      :   The identification string (or, integer) of the gage
;                        station (the first 7 digits in the datafile line). If the
;                        "lake" keyword is set to a valid lake name then "gID"
;                        should be a named variable that will hold the IDs' of the
;                        gage stations (as obtained from the gDB).
;
;         MHHW      :   A named variable that holds the station Mean Higher High Water
;                        (MHHW) datum value.
;
;          MHW      :   A named variable that holds the station Mean High Water
;                        (MHW) datum value.
;
;       NAVD88      :   A named variable that holds the station NAVD88 datum value.
;
;          MTL      :   A named variable that holds the station Mean Tidal Level
;                        (MTL) datum value.
;
;          MSL      :   A named variable that holds the station Mean Sea Level
;                        (MSL) datum value.
;
;         MLLW      :   A named variable that holds the station Mean Lower Low Water
;                        (MLLW) datum value.
;
;          MLW      :   A named variable that holds the station Mean Low Water
;                        (MLW) datum value.
;
;          IDS      :   A named variable that holds the station id
;                        (as obtained from the gDB).
;
;        Names      :   A named variable that holds the description of the
;                        name of the location of the gage station
;                        (as obtained from the gDB).
;
; FUNCTION:
;	This function uses the input values gDB [and gID] to extract the
;	gage station properties from gDB based on gID.
;
; RETURNS:
;	On failure returns -1, otherwise returns a (2xN) array that holds the
;        values of the latitude and longitude of the station(s)
;        (as obtained from the gDB).
;
; EXAMPLE:
;	  success = GetTBStation(stationDB)
;
; SIDE EFFECTS:
;	As far as I know none.
;
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

;  on_error, 2

  retval = -1

; This is the required format of the records in the station database
  fmtSTAID = '(a7, a21, i4, i4)'

;------------------------------
; Check for a valid filename <gDB>
  if (n_params() eq 0) then $
    message, "you need to specify a valid filename for GDB"

  gDB = strtrim(string(gDB), 2)
  if file_test(gDB, /READ) eq 0 then $
    message, "the data file <" + gDB + "> doesn't exist or, it is unreadable"

;------------------------------
; If the GID keyword were not supplied then,
; do all the stations found in the station database
  do_gid  = n_elements(gid) eq 0 ? 0 : 1
  do_all = do_gid eq 0 ? 1 : 0

;------------------------------
; If the FEET keyword were supplied then, use units of feet for
; the datums (default is meters)
  conv_units = keyword_set(feet) eq 0 ? 1.0 : 3937.0 / 1200.0

;------------------------------
; Read the station database and eliminate possible blank records
  nLines = file_lines(gDB)
  if (nLines eq 0) then $
    message, "the data file <" + gDB + "> is empty"

  tmp_arr = strarr(nLines)
  dat_arr = strarr(nLines)
  openr, 3, gDB
    readf, 3, dat_arr
  close, 3
  tmp_arr = strtrim(dat_arr, 2)
  idx = where(strlen(tmp_arr) gt 0, count)
  if (count ne 0) then begin
   dat_arr = dat_arr[idx]
   nLines = count
  endif
  if (nLines eq 0) then $
    message, "the data file <" + gDB + "> is empty"

;------------------------------
; Different behaviour if all stations were requested
  if do_all then begin
    gidfmt = '(' + (strsplit(fmtSTAID, '(,)', /extract))[0] + ')'
    thisGID = string(dat_arr, format = gidfmt)
  endif else begin
    types = [2, 3, 7, 12, 13, 14, 15]
    if (where(types eq size(gid, /TYPE)))[0] eq -1 then $
      message, "illegal value for <gID> was supplied (requires an integer or, string)"
    thisGID = strtrim(string(gid), 2)
  endelse

  nGage  = n_elements(thisGID)
  mhhw   = fltarr(nGage) & mhhw[*]   = !VALUES.F_NAN
  mhw    = fltarr(nGage) & mhw[*]    = !VALUES.F_NAN
  navd88 = fltarr(nGage) & navd88[*] = !VALUES.F_NAN
  mtl    = fltarr(nGage) & mtl[*]    = !VALUES.F_NAN
  msl    = fltarr(nGage) & msl[*]    = !VALUES.F_NAN
  mlw    = fltarr(nGage) & mlw[*]    = !VALUES.F_NAN
  mllw   = fltarr(nGage) & mllw[*]   = !VALUES.F_NAN
  bath   = fltarr(nGage) & bath[*]   = !VALUES.F_NAN
  ids    = strarr(nGage)
  names  = strarr(nGage)
  retval = fltarr(2, nGage)

  for i = 0, nGage - 1 do begin
    idx = where(strmatch(dat_arr, thisGID[i] + '*') eq 1, count)
    if (count ne 0) then begin
      ivar = lonarr(2)
      svar = strarr(2)
      reads, dat_arr[idx[0]], svar, ivar, format = fmtSTAID
; station ids
      ids[i] = svar[0]
; station names
      names[i] = strtrim(svar[1], 2)
; station datums (default units are meters)
  case strupcase(thisGID[i]) of
    '8726282': begin
                 mhhw[i]   = 1.0650 * conv_units
                 mhw[i]    = 0.9870 * conv_units
                 navd88[i] = 0.8990 * conv_units
                 mtl[i]    = 0.7520 * conv_units
                 msl[i]    = 0.7600 * conv_units
                 mlw[i]    = 0.5170 * conv_units
                 mllw[i]   = 0.4050 * conv_units
                 bath[i]   = 0.20057 * conv_units
               end
    'USF83BE': begin
                 mhhw[i]   = 0.7749 * conv_units
                 mhw[i]    = 0.6683 * conv_units
                 navd88[i] = 0.5187 * conv_units
                 mtl[i]    = 0.4067 * conv_units
                 msl[i]    = 0.4175 * conv_units
                 mlw[i]    = 0.1473 * conv_units
                 mllw[i]   = 0.0000 * conv_units
                 bath[i]   = 8.41240 * conv_units
               end
    '8726347': begin
                 mhhw[i]   = 1.0500 * conv_units
                 mhw[i]    = 0.9730 * conv_units
                 navd88[i] = 0.8790 * conv_units
                 mtl[i]    = 0.7410 * conv_units
                 msl[i]    = 0.7480 * conv_units
                 mlw[i]    = 0.5090 * conv_units
                 mllw[i]   = 0.3930 * conv_units
                 bath[i]   = 1.35300 * conv_units
               end
    'USFB624': begin
                 mhhw[i]   = 0.7850 * conv_units
                 mhw[i]    = 0.6793 * conv_units
                 navd88[i] = 0.5206 * conv_units
                 mtl[i]    = 0.4124 * conv_units
                 msl[i]    = 0.4194 * conv_units
                 mlw[i]    = 0.1479 * conv_units
                 mllw[i]   = 0.0000 * conv_units
                 bath[i]   = 1.35300 * conv_units
               end
    '8726384': begin
                 mhhw[i]   = 0.7310 * conv_units
                 mhw[i]    = 0.6490 * conv_units
                 navd88[i] = 0.5380 * conv_units
                 mtl[i]    = 0.4110 * conv_units
                 msl[i]    = 0.4190 * conv_units
                 mlw[i]    = 0.1740 * conv_units
                 mllw[i]   = 0.0630 * conv_units
                 bath[i]   = 0.59250 * conv_units
               end
    '8726520': begin
                 mhhw[i]   = 1.7160 * conv_units
                 mhw[i]    = 1.6300 * conv_units
                 navd88[i] = 1.4670 * conv_units
                 mtl[i]    = 1.3880 * conv_units
                 msl[i]    = 1.3940 * conv_units
                 mlw[i]    = 1.1450 * conv_units
                 mllw[i]   = 1.0280 * conv_units
                 bath[i]   = 7.23370 * conv_units
               end
    '8726607': begin
                 mhhw[i]   = 9.3800 * conv_units
                 mhw[i]    = 9.2850 * conv_units
                 navd88[i] = 9.1070 * conv_units
                 mtl[i]    = 9.0220 * conv_units
                 msl[i]    = 9.0180 * conv_units
                 mlw[i]    = 8.7590 * conv_units
                 mllw[i]   = 8.6230 * conv_units
                 bath[i]   = 1.25320 * conv_units
               end
    '8726667': begin
                 mhhw[i]   = 0.9190 * conv_units
                 mhw[i]    = 0.8200 * conv_units
                 navd88[i] = 0.5690 * conv_units
                 mtl[i]    = 0.5320 * conv_units
                 msl[i]    = 0.5420 * conv_units
                 mlw[i]    = 0.2450 * conv_units
                 mllw[i]   = 0.0980 * conv_units
                 bath[i]   = 1.21750 * conv_units
               end
    '8726724': begin
                 mhhw[i]   = 1.3530 * conv_units
                 mhw[i]    = 1.2490 * conv_units
                 navd88[i] = 1.0640 * conv_units
                 mtl[i]    = 0.9640 * conv_units
                 msl[i]    = 0.9700 * conv_units
                 mlw[i]    = 0.6790 * conv_units
                 mllw[i]   = 0.5190 * conv_units
;                 bath[i]   = X.XXXXX * conv_units
               end
  endcase
; station latitudes
      retval[0, i] = float(ivar[0]) / 100.0
; station longitudes
      retval[1, i] = float(ivar[1]) / 100.0
    endif
  endfor

  return, retval

end
