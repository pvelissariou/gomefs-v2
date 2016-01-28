Pro Hycom_ReadHeaders, Fname = fname, Lun = lun, Title = title, Ascii = ascii
;+++
; NAME:
;	Hycom_ReadHeaders
; VERSION:
;	1.0
; PURPOSE:
;	Helper procedure to read a set of header lines for the bathymetry/grid
;       files for GoM.
; CALLING SEQUENCE:
;	Hycom_WriteHeaders, [[fname = fname], [lun = lun]]
;	On input:
;	   fname - the full path of the header filename (regional file - optional)
;            lun - the LUN of the input/output file, already open (regional file - optional)
;          title - setting this keyword means that the very first header line is a title (optional)
;          ascii - setting this keyword modifies the bahavior of
;                  Hycom_ReadHeaders on how it reads the headers (optional)
;	On output:
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

; check for the validity of a supplied value for "title"
do_title = Keyword_set(title)
do_ascii = Keyword_set(ascii)
do_title = do_ascii eq 0 ? 0 : do_title

; ----------------------------------------
If (do_fname) Then Begin
  Openr, theLUN, fname, /Get_Lun
EndIf Else Begin
  theLUN = lun
EndElse

  MaxHeaders = 22 + do_title + do_ascii * 8
  Nrecord = 0
  HeadLines = 0
  idx_arr = ''
  While not Eof( theLUN ) Do Begin
    Nrecord++
    HeadLines++
    If (HeadLines gt MaxHeaders) Then Break
    datastr = '' & Readf, theLUN, datastr
    Case 1 of
      Strmatch(Strupcase(datastr), '*NREC *') : $
        begin
          tmpstr = '' & ivar = 0L
          Reads, datastr, ivar, tmpstr, format = '(i5, a)'
          HC_NREC = ivar
          Nrecord--
        end
      Strmatch(Strupcase(datastr), '*NPAD *') : $
        begin
          tmpstr = '' & ivar = 0L
          Reads, datastr, ivar, tmpstr, format = '(i5, a)'
          HC_NPAD = ivar
          Nrecord--
        end
      Strmatch(Strupcase(datastr), '*IDM *') : $
        begin
          tmpstr = '' & ivar = 0L
          Reads, datastr, ivar, tmpstr, format = '(i5, a)'
          IPNTS = ivar
          Nrecord--
        end
      Strmatch(Strupcase(datastr), '*JDM *') : $
        begin
          tmpstr = '' & ivar = 0L
          Reads, datastr, ivar, tmpstr, format = '(i5, a)'
          JPNTS = ivar
          Nrecord--
        end
      Strmatch(Strupcase(datastr), '*MAPFLG*') : $
        begin
          tmpstr = '' & ivar = 0L
          Reads, datastr, ivar, tmpstr, format = '(i5, a)'
          HC_MAPFLG = ivar
          Nrecord--
        end
      Strmatch(Strupcase(datastr), '*PLON:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          PLON_MIN = fvar[0]
          PLON_MAX = fvar[1]
          idx_arr = [idx_arr, 'PLON']
        end
      Strmatch(Strupcase(datastr), '*PLAT:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          PLAT_MIN = fvar[0]
          PLAT_MAX = fvar[1]
          idx_arr = [idx_arr, 'PLAT']
        end
      Strmatch(Strupcase(datastr), '*QLON:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          QLON_MIN = fvar[0]
          QLON_MAX = fvar[1]
          idx_arr = [idx_arr, 'QLON']
        end
      Strmatch(Strupcase(datastr), '*QLAT:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          QLAT_MIN = fvar[0]
          QLAT_MAX = fvar[1]
          idx_arr = [idx_arr, 'QLAT']
        end
      Strmatch(Strupcase(datastr), '*ULON:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          ULON_MIN = fvar[0]
          ULON_MAX = fvar[1]
          idx_arr = [idx_arr, 'ULON']
        end
      Strmatch(Strupcase(datastr), '*ULAT:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          ULAT_MIN = fvar[0]
          ULAT_MAX = fvar[1]
          idx_arr = [idx_arr, 'ULAT']
        end
      Strmatch(Strupcase(datastr), '*VLON:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          VLON_MIN = fvar[0]
          VLON_MAX = fvar[1]
          idx_arr = [idx_arr, 'VLON']
        end
      Strmatch(Strupcase(datastr), '*VLAT:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          VLAT_MIN = fvar[0]
          VLAT_MAX = fvar[1]
          idx_arr = [idx_arr, 'VLAT']
        end
      Strmatch(Strupcase(datastr), '*PANG:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          PANG_MIN = fvar[0]
          PANG_MAX = fvar[1]
          idx_arr = [idx_arr, 'PANG']
        end
      Strmatch(Strupcase(datastr), '*PSCX:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          PSCX_MIN = fvar[0]
          PSCX_MAX = fvar[1]
          idx_arr = [idx_arr, 'PSCX']
        end
      Strmatch(Strupcase(datastr), '*PSCY:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          PSCY_MIN = fvar[0]
          PSCY_MAX = fvar[1]
          idx_arr = [idx_arr, 'PSCY']
        end
      Strmatch(Strupcase(datastr), '*QSCX:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          QSCX_MIN = fvar[0]
          QSCX_MAX = fvar[1]
          idx_arr = [idx_arr, 'QSCX']
        end
      Strmatch(Strupcase(datastr), '*QSCY:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          QSCY_MIN = fvar[0]
          QSCY_MAX = fvar[1]
          idx_arr = [idx_arr, 'QSCY']
        end
      Strmatch(Strupcase(datastr), '*USCX:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          USCX_MIN = fvar[0]
          USCX_MAX = fvar[1]
          idx_arr = [idx_arr, 'USCX']
        end
      Strmatch(Strupcase(datastr), '*USCY:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          USCY_MIN = fvar[0]
          USCY_MAX = fvar[1]
          idx_arr = [idx_arr, 'USCY']
        end
      Strmatch(Strupcase(datastr), '*VSCX:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          VSCX_MIN = fvar[0]
          VSCX_MAX = fvar[1]
          idx_arr = [idx_arr, 'VSCX']
        end
      Strmatch(Strupcase(datastr), '*VSCY:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          VSCY_MIN = fvar[0]
          VSCY_MAX = fvar[1]
          idx_arr = [idx_arr, 'VSCY']
        end
      Strmatch(Strupcase(datastr), '*CORI:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          CORI_MIN = fvar[0]
          CORI_MAX = fvar[1]
          idx_arr = [idx_arr, 'CORI']
        end
      Strmatch(Strupcase(datastr), '*PASP:*') : $
        begin
          fvar = Fltarr(2)
          tmpstr = Strtrim(Strmid(datastr, 16), 2)
          Reads, tmpstr, fvar
          PASP_MIN = fvar[0]
          PASP_MAX = fvar[1]
          idx_arr = [idx_arr, 'PASP']
        end
      Strmatch(Strupcase(datastr), '*WET POINTS:*') : $
        begin
          ivar = Lonarr(2)
          tmpstr = datastr
          Reads, tmpstr, ivar, format = '(2(12x, i12, 2x))'
          WCELLS = ivar[0]
          LCELLS = ivar[1]
          Nrecord--
        end
      Strmatch(Strupcase(datastr), '*MIN DEPTH:*') : $
        begin
          fvar = Fltarr(3)
          tmpstr = datastr
          Reads, tmpstr, fvar, format = '(3(12x, f12.5, 2x))'
          DEPTH_MIN  = fvar[0]
          DEPTH_MAX  = fvar[1]
          DEPTH_MEAN = fvar[2]
          Nrecord--
        end
      Strmatch(Strupcase(datastr), '*MIN DLON:*') : $
        begin
          fvar = Fltarr(3)
          tmpstr = datastr
          Reads, tmpstr, fvar, format = '(3(12x, f12.5, 2x))'
          DLON_MIN  = fvar[0]
          DLON_MAX  = fvar[1]
          DLON_MEAN = fvar[2]
          Nrecord--
        end
      Strmatch(Strupcase(datastr), '*MIN DLAT:*') : $
        begin
          fvar = Fltarr(3)
          tmpstr = datastr
          Reads, tmpstr, fvar, format = '(3(12x, f12.5, 2x))'
          DLAT_MIN  = fvar[0]
          DLAT_MAX  = fvar[1]
          DLAT_MEAN = fvar[2]
          Nrecord--
        end
      Strmatch(Strupcase(datastr), '*MIN DX:*') : $
        begin
          fvar = Fltarr(3)
          tmpstr = datastr
          Reads, tmpstr, fvar, format = '(3(12x, f12.5, 2x))'
          DX_MIN  = fvar[0]
          DX_MAX  = fvar[1]
          DX_MEAN = fvar[2]
          Nrecord--
        end
      Strmatch(Strupcase(datastr), '*MIN DY:*') : $
        begin
          fvar = Fltarr(3)
          tmpstr = datastr
          Reads, tmpstr, fvar, format = '(3(12x, f12.5, 2x))'
          DY_MIN  = fvar[0]
          DY_MAX  = fvar[1]
          DY_MEAN = fvar[2]
          Nrecord--
        end
      else: Nrecord--
    EndCase
  EndWhile

If (do_fname) Then $
  If (N_Elements(theLUN) ne 0) Then Free_Lun, theLUN

If (N_Elements(HC_NREC) eq 0) Then Begin
  If (Nrecord gt 0) Then HC_NREC = Nrecord
EndIf

If ((N_Elements(IPNTS) gt 0) and (N_Elements(JPNTS) gt 0)) Then Begin
  TCELLS = IPNTS * JPNTS
  HC_NPAD = 4096 - TCELLS Mod 4096
EndIf

; get the index for each data record
If (N_Elements(idx_arr) gt 1) Then Begin
  idx_arr = idx_arr[1:*]

  idx = (Where(idx_arr eq 'PLON', icnt))[0]
    If (icnt gt 0) Then PLON_IDX = idx
  idx = (Where(idx_arr eq 'PLAT', icnt))[0]
    If (icnt gt 0) Then PLAT_IDX = idx

  idx = (Where(idx_arr eq 'QLON', icnt))[0]
    If (icnt gt 0) Then QLON_IDX = idx
  idx = (Where(idx_arr eq 'QLAT', icnt))[0]
    If (icnt gt 0) Then QLAT_IDX = idx

  idx = (Where(idx_arr eq 'ULON', icnt))[0]
    If (icnt gt 0) Then ULON_IDX = idx
  idx = (Where(idx_arr eq 'ULAT', icnt))[0]
    If (icnt gt 0) Then ULAT_IDX = idx

  idx = (Where(idx_arr eq 'VLON', icnt))[0]
    If (icnt gt 0) Then VLON_IDX = idx
  idx = (Where(idx_arr eq 'VLAT', icnt))[0]
    If (icnt gt 0) Then VLAT_IDX = idx

  idx = (Where(idx_arr eq 'PANG', icnt))[0]
    If (icnt gt 0) Then PANG_IDX = idx

  idx = (Where(idx_arr eq 'PSCX', icnt))[0]
    If (icnt gt 0) Then PSCX_IDX = idx
  idx = (Where(idx_arr eq 'PSCY', icnt))[0]
    If (icnt gt 0) Then PSCY_IDX = idx

  idx = (Where(idx_arr eq 'QSCX', icnt))[0]
    If (icnt gt 0) Then QSCX_IDX = idx
  idx = (Where(idx_arr eq 'QSCY', icnt))[0]
    If (icnt gt 0) Then QSCY_IDX = idx

  idx = (Where(idx_arr eq 'USCX', icnt))[0]
    If (icnt gt 0) Then USCX_IDX = idx
  idx = (Where(idx_arr eq 'USCY', icnt))[0]
    If (icnt gt 0) Then USCY_IDX = idx

  idx = (Where(idx_arr eq 'VSCX', icnt))[0]
    If (icnt gt 0) Then VSCX_IDX = idx
  idx = (Where(idx_arr eq 'VSCY', icnt))[0]
    If (icnt gt 0) Then VSCY_IDX = idx

  idx = (Where(idx_arr eq 'CORI', icnt))[0]
    If (icnt gt 0) Then CORI_IDX = idx

  idx = (Where(idx_arr eq 'PASP', icnt))[0]
    If (icnt gt 0) Then PASP_IDX = idx
EndIf

End
