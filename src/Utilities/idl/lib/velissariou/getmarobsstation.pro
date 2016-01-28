Function GetMarobsStation,  $
           gDB,             $
           Lake   = lake,   $
           gID    = gid,    $
           Types  = types,  $
           IDS    = ids,    $
           Names  = names,  $
           Lk_IDS = lk_ids
;+++
; NAME:
;    GetMarobsStation
;
; VERSION:
;       1.0
;
; AUTHOR:
;       Panagiotis Velissariou (Velissariou.1@osu.edu)
;
; PURPOSE:
;	To obtain the properties of a MAROBS station by reading the
;	 database file with the station information.
;
; CATEGORY:
;	Data
;
; CALLING SEQUENCE:
;	GetMarobsStation(gDB, gID = 'GID', [keyword1 = value], [keyword2 = value], ...)
;
;          gDB      :   The name of the file that contains the gage information.
;                        The format of the database file is as follows:
;
;            -------------------------------------------------------------------------
;            Record Format for Station File: STATIONS.DAT
;            -------------------------------------------------------------------------
;          
;            -------         -----------
;            Columns         Description
;            -------         -----------
;          
;             1- 1   Station type:  0 = NDBC buoy
;                                   1 = CMAN station
;                                   2 = U.S. Coast Guard station
;                                   3 = Ship
;                                   4 = OMR (Other Marine Reports) station
;                                   5 = Surface Synoptic station
;                                   6 = Surface Airways station
;
;             2- 9   Station ID code
;            10-11   Year of effective date for this station directory entry: last two digits
;            12-13   Month of effective date for this station directory entry
;            14-15   Day of month of effective date for this station directory entry
;            16-35   Station name
;            36-39   Latitude in hundreths of a degree
;            40-43   Longitude in hundreths of a degree
;           
;            44-44   Lake number:   0 = Superior
;                                   1 = Michigan
;                                   2 = Huron
;                                   3 = St. Clair
;                                   4 = Erie
;                                   5 = Ontario
;                                   6 = Georgian Bay
;           
;            45-45   Lake sector
;            46-49   Station elevation above MSL in feet
;            50-52   Anemometer height above the ground in feet
;            53-54   Hexadecimal representation of sheltering mask:
;           
;                                  Bit Set   Sheltered from:
;                                  -------   ---------------
;          
;                                 0000 0001       NE
;                                 0000 0010        E
;                                 0000 0100       SE
;                                 0000 1000        S
;                                 0001 0000       SW
;                                 0010 0000        W
;                                 0100 0000       NW
;                                 1000 0000        N
;           
;           
;                         --------------------------------------------
;                         MISSING DATA IS INDICATED BY BLANK FIELDS!!!
;                         --------------------------------------------
;           
;           
;             Marine Meteorological Observations (MAROBS):
;
;              Marine meteorological observations may be in either of two formats, GLERL
;              Marine Observation format or GLERL Enhanced Marine Observation format.
;              The two types of records may be intermixed in the input files.
;
;                       ------------------------------------------------
;                       Record Format for GLERL Marine Observation Files
;                       ------------------------------------------------
;
;                    Data file names: GYYJJJ00.LMO
;
;                              YY = Last two digits of year
;                             JJJ = Julian day of year
;
;            -------         -----------
;            Columns         Description
;            -------         -----------
;
;             1- 2   Last two digits of year of observation
;             3- 5   Julian day of observation
;             6- 9   GMT hour and minute of observation (HHMM)
;
;            10-10   Station type:  0 = Buoy
;                                   1 = CMAN station
;                                   2 = U.S. Coast Guard station
;                                   3 = Ship report
;                                   4 = OMR (Other Marine Reports) station
;                                   5 = Surface Synoptic station
;                                   6 = Surface Airways station
;
;            11-18   Station ID code
;            19-19   Lake number:   0 = Superior
;                                   1 = Michigan
;                                   2 = Huron
;                                   3 = St. Clair
;                                   4 = Erie
;                                   5 = Ontario
;                                   6 = Georgian Bay
;
;            20-22   Air temperature in degrees Fahrenheit
;            23-25   Dew point in degrees Fahrenheit
;            26-28   Wind direction in degrees
;            29-30   Wind speed in knots
;            31-32   Maximum wind gust in knots
;            33-33   Cloud amount in octas: 9 for sky obscured
;            34-38   Sea level pressure in tenths of a millibar
;            39-40   Water temperature in degrees Fahrenheit 
;            41-42   Wave height in feet
;            43-44   Wave period in seconds
;
;                --- The following fields are included in ship reports ONLY: ---
;
;            45-48   Latitude in hundreths of a degree
;            49-52   Longitude in hundreths of a degree
;
;                              --------------------------------------------
;                              MISSING DATA IS INDICATED BY BLANK FIELDS!!!
;                              --------------------------------------------
;
;                                  --------------------------------------------------
;                                     GLERL Lake Meteorological Data (LMD) Format 
;                                  --------------------------------------------------
;
;           yyyyjjjhhmmTiiiiiiiilf aaa.a eee.e ddd ss.s gg.g ccc rrrr.r bbbb.b tt.t ww.w pp.p [nn.nn oo.o
;
;              -------   --------   -----------
;               Field    Position   Description
;              -------   --------   -----------
;
;                yyyy     1-4       Year of observation
;
;                 jjj     5-7       Day of year (zero fill, i3.3)
;
;                  hh     8-9       Hour (GMT) (zero fill, i2.2)
;
;                  mm     10-11     Minute (zero fill, i2.2)
;
;                   T     12        Station type:
;                                         0 = Buoy
;                                         1 = CMAN station
;                                         2 = U.S. Coast Guard station
;                                         3 = Ship report
;                                         4 = OMR (Other Marine Reports) station
;                                         5 = Surface Synoptic station
;                                         6 = Surface Airways station
;                                         9 = GLERL met station
;                                     blank = unknown or not specified
;
;             iiiiiiii    13-20     Unique Station ID code (8 characters, left justified)
;
;                    l    21        Lake number:
;                                         0 = Superior
;                                         1 = Michigan
;                                         2 = Huron
;                                         3 = St. Clair
;                                         4 = Erie
;                                         5 = Ontario
;                                         6 = Georgian Bay
;                                     blank = unknown or not specified
;
;                    f    22        Data Format (GLMON/LMD):
;
;                                         9 = Lake Meteorological Data (LMD) Format
;
;                aaa.a    24-28     Air temperature         (degrees Centigrade)
;                eee.e    30-34     Dew point               (degrees Centigrade)
;                  ddd    36-38     Wind direction          (degrees from, 0=north, 90=east)
;                 ss.s    40-43     Wind speed              (meters/second)
;                 gg.g    45-48     Maximum wind gust       (meters/second)
;                  ccc    50-53     Cloud cover             (percent)
;               rrrr.r    54-59     Solar Radiation         (watts/meter**2)
;               bbbb.b    61-66     Barometric pressure     (millibars)
;                 tt.t    68-71     Water temperature       (degrees Centigrade)
;                 ww.w    73-76     Significant Wave height (meters)
;                 pp.p    78-81     Wave period             (seconds)
;                 
;              ------------------------------------------------------------
;               The following fields are present for ship observations only:
;               ------------------------------------------------------------
;
;                 nn.nn    83-87     North Latitude          (Decimal degrees)
;                 oo.oo    89-93     West Longitude          (Decimal degrees)
;                 
;                         ------------------------------------------------
;                          MISSING DATA ARE INDICATED BY "9" IN ALL DIGITS
;                         ------------------------------------------------
;
; KEYWORD PARAMETERS:
;          gID      :   The identification string (or, integer) of the MAROBS
;                        station (the first 9 digits in the datafile line). If the
;                        "lake" keyword is set to a valid lake name then "gID"
;                        should be a named variable that will hold the IDs' of the
;                        gage stations (as obtained from the gDB).
;
;         Lake      :   Set this keword to a valid lake to obtain all the stations
;                        for this lake (as obtained from the gDB).
;
;        Types      :   A named variable that holds the type of the MAROBS station(s)
;                        (as obtained from the gDB).
;
;          IDS      :   A named variable that holds the identification strings of the
;                        MAROBS station(s)
;                        (as obtained from the gDB).
;
;        Names      :   A named variable that holds the description of the
;                        name of the location of the MAROBS station
;                        (as obtained from the gDB).
;       Lk_IDS      :   A named variable that holds the identification numbers of the
;                        lakes where the stations are located
;                        (as obtained from the gDB).
;          
; FUNCTION:
;	This function uses the input values gDB and gID to extract the
;	MAROBS station properties from gDB based on gID.
;
; RETURNS:
;	On failure returns -1, otherwise returns a (2xN) array that holds the
;        values of the latitude and longitude of the station(s)
;        (as obtained from the gDB).
;
; EXAMPLE:
;	  success = GetMarobsStation(stationDB, gid = '9063007')
;
; SIDE EFFECTS:
;	As far as I know none.
;
; MODIFICATION HISTORY:
;	Created February 16 2005 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

;  on_error, 2

  types  = -1
  ids    = ''
  names  = ''
  lk_ids = -1
  retval = -1

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
   tmp_arr = dat_arr[idx]
   nLines = count
  endif
  if (nLines eq 0) then $
    message, "the data file <" + gDB + "> is empty"

  data_struct = {type:-1, id:'', name:'', lat:0.0, lon:0.0, lknum:-1}
  dat_arr = replicate(data_struct, nLines)
  for i = 0, nLines - 1 do begin
    tmpstr = strtrim(strmid(tmp_arr[i], 0, 1), 2)
    if (strlen(tmpstr) gt 0) then dat_arr[i].type  = fix(tmpstr)

    tmpstr = strtrim(strmid(tmp_arr[i], 1, 8), 2)
    dat_arr[i].id   = tmpstr

    tmpstr = strtrim(strmid(tmp_arr[i], 15, 20), 2)
    dat_arr[i].name = tmpstr

    tmpstr = strtrim(strmid(tmp_arr[i], 35, 4), 2)
    if (strlen(tmpstr) gt 0) then dat_arr[i].lat = float(tmpstr) / 100.0

    tmpstr = strtrim(strmid(tmp_arr[i], 39, 4), 2)
    if (strlen(tmpstr) gt 0) then dat_arr[i].lon = float(tmpstr) / 100.0

    tmpstr = strtrim(strmid(tmp_arr[i], 43, 1), 2)
    if (strlen(tmpstr) gt 0) then dat_arr[i].lknum = fix(tmpstr)
  endfor

; Only use unique stations
  tmp_idx = uniq(dat_arr.id, sort(dat_arr.id))
  tmp_idx = tmp_idx[sort(tmp_idx)]
  dat_arr = dat_arr[tmp_idx]

;------------------------------
; DO_ALL stations section
  if do_all then begin
    types  = dat_arr.type
    ids    = dat_arr.id
    names  = dat_arr.name
    lk_ids = dat_arr.lknum
    retval = [transpose(dat_arr.lat), transpose(dat_arr.lon)]

    idx = where(lk_ids eq 3, count)
    if (count gt 0) then lk_ids[idx] = 4

    idx = where(lk_ids eq 6, count)
    if (count gt 0) then lk_ids[idx] = 2
  endif

;------------------------------
; DO_GID stations section
  if do_gid then begin
    types = [2, 3, 7, 12, 13, 14, 15]
    if (where(types eq size(gid, /TYPE)))[0] eq -1 then $
      message, "illegal value for <gID> was supplied (requires an integer or, string)"
    thisGID = strtrim(string(gid), 2)

    for i = 0, n_elements(thisGID) - 1 do begin
      tmp_idx = where(dat_arr.id eq thisGID[i], tmp_count)
      if (tmp_count ne 0) then begin
        if (n_elements(gid_idx) eq 0) then begin
          gid_idx = tmp_idx
        endif else begin
          gid_idx = [gid_idx, tmp_idx]
        endelse
      endif
    endfor

    if (n_elements(gid_idx) ne 0) then begin
      types  = dat_arr[gid_idx].type
      ids    = dat_arr[gid_idx].id
      names  = dat_arr[gid_idx].name
      lk_ids = dat_arr[gid_idx].lknum
      retval = [transpose(dat_arr[gid_idx].lat), transpose(dat_arr[gid_idx].lon)]

      idx = where(lk_ids eq 3, count)
      if (count gt 0) then lk_ids[idx] = 4

      idx = where(lk_ids eq 6, count)
      if (count gt 0) then lk_ids[idx] = 2
    endif
  endif

;------------------------------
; DO_LAKE stations section
  if do_lake then begin
    if (size(lake, /TNAME) ne 'STRING') then $
      message, "illegal value for <lake> was supplied (requires a string)"
 
    case strlowcase(strtrim(lake, 2)) of
         'erie' : thisGID = 4
        'huron' : thisGID = 2
      'michigan': thisGID = 1
      'ontario' : thisGID = 5
      'stclair' : thisGID = 3
      'superior': thisGID = 0
         'gbay' : thisGID = 6
           else : begin
                    message, "please supply a valid name for <lake>", /continue
                    message, "valid lake names are: " + $
                             "['erie', 'huron', 'michigan', 'ontario', 'stclair', 'superior', 'gbay']"
                  end
      endcase

      lk_idx = where(dat_arr.lknum eq thisGID, lk_count)
      if (lk_count ne 0) then begin
        types  = dat_arr[lk_idx].type
        ids    = dat_arr[lk_idx].id
        names  = dat_arr[lk_idx].name
        lk_ids = dat_arr[lk_idx].lknum
        retval = [transpose(dat_arr[lk_idx].lat), transpose(dat_arr[lk_idx].lon)]

        idx = where(lk_ids eq 3, count)
        if (count gt 0) then lk_ids[idx] = 4

        idx = where(lk_ids eq 6, count)
        if (count gt 0) then lk_ids[idx] = 2
      endif
  endif

  return, retval

end
