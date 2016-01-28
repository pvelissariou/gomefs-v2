Function GetStation,      $
           gDB,           $
           Lake  = lake,  $
           gID   = gid,   $
           USA   = usa,   $
           CAN   = can,   $
           IDS   = ids,   $
           Names = names
;+++
; NAME:
;    GetStation
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
;	GetStations(gDB, gID, [keyword1 = value], [keyword2 = value], ...)
;
;          gDB      :   The name of the file that contains the gage information.
;                        The format of the database file is as follows:
;
;          USA SIDE
;          --------
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
;          CANADA SIDE
;          -----------
;                        Columns
;                        -------
;                                 Geographic region code
;                                 ----------------------
;                         1- 2    03 = Lake St. Clair
;                                 05 = Lake Ontario
;                                 06 = Lake Erie, Niagara River
;                                 07 = Lake Huron, St. Mary's River
;                                 08 = Lake Michigan
;                                 09 = Lake Superior
;
;                                 Gauge ID code
;                                 -------------
;                         3- 7    1dddd
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
;         Lake      :   Set this keword to a valid lake to obtain all the stations
;                        for this lake (as obtained from the gDB).
;
;        Names      :   A named variable that holds the description of the
;                        name of the location of the gage station
;                        (as obtained from the gDB).
;
; FUNCTION:
;	This function uses the input values gDB and gID to extract the
;	gage station properties from gDB based on gID.
;
; RETURNS:
;	On failure returns -1, otherwise returns a (2xN) array that holds the
;        values of the latitude and longitude of the station(s)
;        (as obtained from the gDB).
;
; EXAMPLE:
;	  success = GetStations(stationDB, '9063007', lat = lat, lon = lon)
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
; Check for the supplied gage id and/or lake. The lake keyword is
; only intended for use in the Great Lakes region, and in this case
; the keywords 'LAKE" and "GID" can not be set at the same time
  do_lake = n_elements(lake) eq 0 ? 0 : 1
  do_gid  = n_elements(gid) eq 0 ? 0 : 1

  if (do_gid + do_lake gt 1) then $
    message, ' use only one of the GID or, LAKE keywords.'

;------------------------------
; If none of the GID and the LAKE keywords were supplied then,
; do all the stations found in the station database
  do_all = (do_gid + do_lake) eq 0 ? 1 : 0

;------------------------------
; Check for the supplied USA and/or CAN keywords. This is only used
; for the Great Lakes to include or, not the stations located
; in these countries.
usa = do_lake ne 0 ? keyword_set(usa) : 0
can = do_lake ne 0 ? keyword_set(can) : 0
if (usa + can gt 1) then $
  message, ' set only one of the /USA or, /CAN keywords.'

if usa then $
  countryGIDS = ['90630', '90750', '90870', '90520', '90340', '90990']
if can then $
  countryGIDS = [  '061',   '071',   '081',   '051',   '031',   '091']

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
; DO_ALL stations section
  if do_all then begin
    gidfmt = '(' + (strsplit(fmtSTAID, '(,)', /extract))[0] + ')'
    thisGID = string(dat_arr, format = gidfmt)

; This section is for the USA/CAN keywords
    if n_elements(countryGIDS) ne 0 then begin
      idx   = -1
      nGage = 0
      for i = 0, n_elements(countryGIDS) - 1 do begin
        idx1 = where(strmatch(dat_arr, countryGIDS[i] + '*') eq 1, count)
        if (count ne 0) then begin
          nGage = nGage + count
          idx = [idx, idx1]
        endif
      endfor
      if (nGage ne 0) then begin
        idx = idx[1:*]
        thisGID = thisGID[idx]
      endif
    endif

    nGage  = n_elements(thisGID)
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
;        ids[i] = strtrim(svar[0], 2)
        ids[i] = svar[0]
; station names
        names[i] = strtrim(svar[1], 2)
; station latitudes
        retval[0, i] = float(ivar[0]) / 100.0
; station longitudes
        retval[1, i] = float(ivar[1]) / 100.0
      endif
    endfor
  endif

;------------------------------
; DO_GID stations section
  if do_gid then begin
    types = [2, 3, 7, 12, 13, 14, 15]
    if (where(types eq size(gid, /TYPE)))[0] eq -1 then $
      message, "illegal value for <gID> was supplied (requires an integer or, string)"
    thisGID = strtrim(string(gid), 2)

; this section is for the USA/CAN keywords
    if n_elements(countryGIDS) ne 0 then begin
      idx   = -1
      nGage = 0
      for i = 0, n_elements(countryGIDS) - 1 do begin
        idx1 = where(strmatch(thisGID, countryGIDS[i] + '*') eq 1, count)
        if (count ne 0) then begin
          nGage = nGage + count
          idx = [idx, idx1]
        endif
      endfor
      if (nGage ne 0) then begin
        idx = idx[1:*]
        thisGID = thisGID[idx]
      endif
    endif

    nGage  = n_elements(thisGID)
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
;        ids[i] = strtrim(svar[0], 2)
        ids[i] = svar[0]
; station names
        names[i] = strtrim(svar[1], 2)
; station latitudes
        retval[0, i] = float(ivar[0]) / 100.0
; station longitudes
        retval[1, i] = float(ivar[1]) / 100.0
      endif
    endfor
  endif

;------------------------------
; DO_LAKE stations section
  if do_lake then begin
    if (size(lake, /TNAME) ne 'STRING') then $
      message, "illegal value for <lake> was supplied (requires a string)"
    lake = strtrim(lake[0], 2)
    case strlowcase(lake) of
         'erie' : begin
; USA = thisGID[0] and CAN = thisGID[1]
                    thisGID = ['90630', '061']
                    if usa then thisGID = thisGID[0]
                    if can then thisGID = thisGID[1]
                  end
        'huron' : begin
; USA = thisGID[0] and CAN = thisGID[1]
                    thisGID = ['90750', '071']
                    if usa then thisGID = thisGID[0]
                    if can then thisGID = thisGID[1]
                  end
      'michigan': begin
; USA = thisGID[0] and CAN = thisGID[1]
                    thisGID = ['90870', '081']
                    if usa then thisGID = thisGID[0]
                    if can then thisGID = thisGID[1]
                  end
      'ontario' : begin
; USA = thisGID[0] and CAN = thisGID[1]
                    thisGID = ['90520', '051']
                    if usa then thisGID = thisGID[0]
                    if can then thisGID = thisGID[1]
                  end
      'stclair' : begin
; USA = thisGID[0] and CAN = thisGID[1]
                    thisGID = ['90340', '031']
                    if usa then thisGID = thisGID[0]
                    if can then thisGID = thisGID[1]
                  end
      'superior': begin
; USA = thisGID[0] and CAN = thisGID[1]
                    thisGID = ['90990', '091']
                    if usa then thisGID = thisGID[0]
                    if can then thisGID = thisGID[1]
                  end
           else : begin
                    message, "please supply a valid name for <lake>", /continue
                    message, "valid lake names are: " + $
                             "['erie', 'huron', 'michigan', 'ontario', 'stclair', 'superior']"
                  end
      endcase

    idx = -1
    nGage = 0
    for i = 0, n_elements(thisGID) - 1 do begin
      idx1 = where(strmatch(dat_arr, thisGID[i] + '*') eq 1, count)
      if (count ne 0) then begin
        nGage = nGage + count
        idx = [idx, idx1]
      endif
    endfor

    if (nGage ne 0) then begin
      idx = idx[1:*]
      ids = strarr(nGage)
      names = strarr(nGage)
      retval = fltarr(2, nGage)
      for i = 0, nGage - 1 do begin
        ivar = lonarr(2)
        svar = strarr(2)
          reads, dat_arr[idx[i]], svar, ivar, format = fmtSTAID
; station ids
;          ids[i] = strtrim(svar[0], 2)
          ids[i] = svar[0]
; station names
        names[i] = strtrim(svar[1], 2)
; station latitudes
        retval[0, i] = float(ivar[0]) / 100.0
; station longitudes
        retval[1, i] = float(ivar[1]) / 100.0
      endfor
    endif else begin
      ids   = ''
      names = ''
    endelse
  endif

  return, retval

end
