Pro Hycom_ReadGrid, Fname = fname, $
                    Lun = lun,     $
                    Ascii = ascii, $
                    Full = full,   $
                    Pad = pad,     $
                    STATS = stats
;+++
; NAME:
;	Hycom_ReadGrid
; VERSION:
;	1.0
; PURPOSE:
;	To read a bathymetric grid data file and return grid parameters
;       and depths.
; CALLING SEQUENCE:
;	Hycom_ReadGrid, [[fname = fname], [lun = lun], /ascii]
;	On input:
;	   fname - Full pathway name of the lat/lon data file
;            lun - the LUN of the input/output file, already open (regional file - optional)
;          ascii - setting this keyword modifies the bahavior of
;                  Hycom_ReadGrid on how it reads the lat/lon values (ascii or binary - `optional)
;	On output:
;	 longrid - Longitude values of the grid points
;	    plon - Longitude values of the pressure grid points (same as longrid)
;	 latgrid - Latitude values of the grid points
;	    plat - Latitude values of the pressure grid points (same as latgrid)
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created April 22 2011 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

Compile_Opt IDL2

COMMON BathParams

; Error handling.
Catch, theError
If theError ne 0 Then Begin
  Catch, /Cancel
  If (N_Elements(do_fname) ne 0) Then $
    If (N_Elements(theLUN) ne 0) Then Free_Lun, theLUN
  Help, /Last_Message
  Return
EndIf

; check for the simultaneous supply of "fname" and "lun"
; only ONE of these options can be used
do_fname = N_Elements(fname) eq 0 ? 0 : 1
do_lun   = N_Elements(lun) eq 0 ? 0 : 1

If ((do_fname + do_lun) ne 1) Then $
  Message, 'you need to supply either <fname> or <lun> (but not both).'

; check for the validity of the supplied values for "fname" or "lun"
If (do_fname) Then Begin
  If (Size(fname, /TNAME) ne 'STRING') Then $
    Message, "the name supplied for <fname> is not a valid string."

  fname = Strtrim(fname, 2)
  If (not readFILE(fname)) Then $
    Message, "can't read from the supplied file <" + fname + ">."
EndIf

If (do_lun) Then Begin
  If ((Where([2, 3, 12, 13, 14, 15] eq Size(lun, /TYPE)))[0] lt 0) Then $
    Message, "the value supplied for <lun> is not an integer."

  If ((Where([-2, -1, Indgen(99) + 1] eq lun))[0] lt 0) Then $
    Message, "the value supplied for <lun> should be one of <-2, -1, 1-99>."
EndIf

do_ascii = Keyword_set(ascii)
do_full  = do_ascii and (not Keyword_set(full)) ? 0 : 1
do_stats = (Keyword_set(stats) eq 1) ? 1 : 0

; ----------------------------------------
If (do_fname) Then Begin
  If (do_ascii) Then Begin
    Openr, theLUN, fname, /Get_Lun
  EndIf Else Begin
    Openr, theLUN, fname, /Get_Lun, /Swap_Endian
  EndElse
EndIf Else Begin
  theLUN = lun
EndElse

  Nrecords = do_full ? HC_NREC : 2
  tmp_arr1 = Fltarr(IPNTS, JPNTS, Nrecords)
  tmp_arr2 = Fltarr(TCELLS)

  If (do_ascii) Then Begin
    For irec = 0, Nrecords - 1 Do Begin
      Readf, theLUN, tmp_arr2
      tmp_arr1[*, *, irec] = tmp_arr2
    EndFor
  EndIf Else Begin
    If (N_Elements(pad) ne 0) Then Begin
      n_padding = Round(Abs(pad[0]))
    EndIf Else Begin 
      n_padding = (N_Elements(HC_NPAD) eq 0) ? 4096 - TCELLS Mod 4096 : HC_NPAD
    EndElse
    For irec = 0, Nrecords - 1 Do Begin
      If (n_padding gt 0) Then Begin
        padding = Fltarr(n_padding)
        Readu, theLUN, tmp_arr2, padding
        tmp_arr1[*, *, irec] = tmp_arr2
      EndIf Else Begin
        Readu, theLUN, tmp_arr2
        tmp_arr1[*, *, irec] = tmp_arr2
      EndElse
    EndFor
  EndElse

  longrid = Make_array(IPNTS, JPNTS, /DOUBLE, VALUE = 0)
  latgrid = longrid
  If (not do_full) Then Begin
    plon = longrid & plat = longrid
    longrid[*, *] = tmp_arr1[*, *, 0]
    latgrid[*, *] = tmp_arr1[*, *, 1]
    plon[*, *] = longrid[*, *]
    plat[*, *] = latgrid[*, *]
  EndIf Else Begin
    plon = longrid & plat = longrid
    qlon = longrid & qlat = longrid
    ulon = longrid & ulat = longrid
    vlon = longrid & vlat = longrid
    pang = longrid
    pscx = longrid & pscy = longrid
    qscx = longrid & qscy = longrid
    uscx = longrid & uscy = longrid
    vscx = longrid & vscy = longrid
    cori = longrid & pasp = longrid
  
    longrid[*, *] = tmp_arr1[*, *, PLON_IDX]
    latgrid[*, *] = tmp_arr1[*, *, PLAT_IDX]
    plon[*, *] = longrid[*, *]
    plat[*, *] = latgrid[*, *]
    qlon[*, *] = tmp_arr1[*, *, QLON_IDX]
    qlat[*, *] = tmp_arr1[*, *, QLAT_IDX]
    ulon[*, *] = tmp_arr1[*, *, ULON_IDX]
    ulat[*, *] = tmp_arr1[*, *, ULAT_IDX]
    vlon[*, *] = tmp_arr1[*, *, VLON_IDX]
    vlat[*, *] = tmp_arr1[*, *, VLAT_IDX]
    pang[*, *] = tmp_arr1[*, *, PANG_IDX]
    pscx[*, *] = tmp_arr1[*, *, PSCX_IDX]
    pscy[*, *] = tmp_arr1[*, *, PSCY_IDX]
    qscx[*, *] = tmp_arr1[*, *, QSCX_IDX]
    qscy[*, *] = tmp_arr1[*, *, QSCY_IDX]
    uscx[*, *] = tmp_arr1[*, *, USCX_IDX]
    uscy[*, *] = tmp_arr1[*, *, USCY_IDX]
    vscx[*, *] = tmp_arr1[*, *, VSCX_IDX]
    vscy[*, *] = tmp_arr1[*, *, VSCY_IDX]
    cori[*, *] = tmp_arr1[*, *, CORI_IDX]
    pasp[*, *] = tmp_arr1[*, *, PASP_IDX]
  EndElse

  If (do_stats gt 0) Then Begin
    ; ---------- Get the "DELTA LON" values
    Get_DomainStats, longrid, /XDIR, WEIGHTED = 0, $
                     DARR = dlongrid, $
                     MIN_VAL = LON_MIN, MAX_VAL = LON_MAX, $
                     AVE_VAL = LON_MEAN, $
                     DMIN_VAL = DLON_MIN, DMAX_VAL = DLON_MAX, $
                     DAVE_VAL = DLON_MEAN

    ; ---------- Get the "DELTA LON" values
    Get_DomainStats, latgrid, /YDIR, WEIGHTED = 0, $
                     DARR = dlatgrid, $
                     MIN_VAL = LAT_MIN, MAX_VAL = LAT_MAX, $
                     AVE_VAL = LAT_MEAN, $
                     DMIN_VAL = DLAT_MIN, DMAX_VAL = DLAT_MAX, $
                     DAVE_VAL = DLAT_MEAN

    ; ---------- Get the "DELTA X" values
    tmparr = Make_array(IPNTS, JPNTS, /DOUBLE, VALUE = 0)
    radius = 6371001.0D ; this is the average earth radius as defined in hycom
    If ((N_Elements(ulon) eq 0) or (N_Elements(ulat) eq 0)) Then Begin
      lon_grid = plon
      lat_grid = plat
    EndIf Else Begin
      lon_grid = ulon
      lat_grid = ulat
    EndElse
    For j = 0 , JPNTS - 1 Do Begin
      For i = 0 , IPNTS - 2 Do Begin
        lon0 = lon_grid[i, j]
        lon1 = lon_grid[i + 1, j]
        lat0 = lat_grid[i, j]
        lat1 = lat_grid[i + 1, j]
        tmparr[i, j] = Map_2Points(lon0, lat0, lon1, lat1, /meters, radius = radius)
      EndFor
      i = IPNTS - 1
      tmparr[i, j] = tmparr[i - 1, j]
    EndFor
    DX_MAX = Max(tmparr, Min = DX_MIN)
    DX_MEAN = Mean(tmparr)

    ; ---------- Get the "DELTA X" values
    tmparr = Make_array(IPNTS, JPNTS, /DOUBLE, VALUE = 0)
    radius = 6371001.0D ; this is the average earth radius as defined in hycom
    If ((N_Elements(vlon) eq 0) or (N_Elements(vlat) eq 0)) Then Begin
      lon_grid = plon
      lat_grid = plat
    EndIf Else Begin
      lon_grid = vlon
      lat_grid = vlat
    EndElse
    For j = 0 , JPNTS - 2 Do Begin
      For i = 0 , IPNTS - 1 Do Begin
        lon0 = lon_grid[i, j]
        lon1 = lon_grid[i, j + 1]
        lat0 = lat_grid[i, j]
        lat1 = lat_grid[i, j + 1]
        tmparr[i, j] = Map_2Points(lon0, lat0, lon1, lat1, /meters, radius = radius)
      EndFor
    EndFor
    j = JPNTS - 1
    For i = 0 , IPNTS - 1 Do tmparr[i, j] = tmparr[i, j - 1]
    DY_MAX = Max(tmparr, Min = DY_MIN)
    DY_MEAN = Mean(tmparr)
  EndIf

If (do_fname) Then $
  If (N_Elements(theLUN) ne 0) Then Free_Lun, theLUN

End
