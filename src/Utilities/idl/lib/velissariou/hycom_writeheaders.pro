Pro Hycom_WriteHeaders, Fname = fname, Lun = lun, Title = title, Ascii = ascii
;+++
; NAME:
;	Hycom_WriteHeaders
; VERSION:
;	1.0
; PURPOSE:
;	Helper procedure to write a set of header lines in the bathymetry/grid
;       files for GoM.
; CALLING SEQUENCE:
;	Hycom_WriteHeaders, [[fname = fname], [lun = lun], [title = title], /ascii]
;	On input:
;	   fname - the full path of the header filename (regional file - optional)
;            lun - the LUN of the input/output file, already open (regional file - optional)
;          title - the title, or the very first header line (optional)
;          ascii - setting this keyword modifies the bahavior of
;                  Hycom_WriteHeaders on how it writes out the headers (optional)
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
  If (not writeFILE(fname)) Then $
    Message, "can't write to the supplied file <" + fname + ">."
EndIf

If (do_lun) Then Begin
  If ((Where([2, 3, 12, 13, 14, 15] eq Size(lun, /TYPE)))[0] lt 0) Then $
    Message, "the value supplied for <lun> is not an integer."

  If ((Where([-2, -1, Indgen(99) + 1] eq lun))[0] lt 0) Then $
    Message, "the value supplied for <lun> should be one of <-2, -1, 1-99>."
EndIf

; check for the validity of a supplied value for "title"
do_title = N_Elements(title) eq 0 ? 0 : 1
do_ascii = Keyword_set(ascii)
do_title = do_ascii eq 0 ? 0 : do_title

If (do_title) Then $
  If (Size(title, /TNAME ) ne 'STRING') Then $
    Message, "the value supplied for <title> is not a valid string."

; ----------------------------------------
If (do_fname) Then Begin
  Openw, theLUN, fname, /Get_Lun
EndIf Else Begin
  theLUN = lun
EndElse

If (do_title) Then $
  Printf, theLUN, title

If (do_ascii) Then Begin
  If (N_Elements(HC_NREC) gt 0) Then $
    Printf, theLUN, HC_NREC, "'nrec  ' = number of records", format = '(i5, a32)'
  If (N_Elements(HC_NPAD) gt 0) Then $
  Printf, theLUN, HC_NPAD, "'npad  ' = padding at the end of each record", format = '(i5, a48)'
EndIf

Printf, theLUN, IPNTS, "'idm   ' = longitudinal array size", format = '(i5,a38)'
Printf, theLUN, JPNTS, "'jdm   ' = latitudinal  array size", format = '(i5,a38)'
Printf, theLUN, HC_MAPFLG, "'mapflg' = map flag (-1=unknown,0=mercator,2=uniform,4=f-plane)", $
                 format = '(i5, a67)'
Printf, theLUN, 'plon:  min,max = ', PLON_MIN, PLON_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'plat:  min,max = ', PLAT_MIN, PLAT_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'qlon:  min,max = ', QLON_MIN, QLON_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'qlat:  min,max = ', QLAT_MIN, QLAT_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'ulon:  min,max = ', ULON_MIN, ULON_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'ulat:  min,max = ', ULAT_MIN, ULAT_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'vlon:  min,max = ', VLON_MIN, VLON_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'vlat:  min,max = ', VLAT_MIN, VLAT_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'pang:  min,max = ', PANG_MIN, PANG_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'pscx:  min,max = ', PSCX_MIN, PSCX_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'pscy:  min,max = ', PSCY_MIN, PSCY_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'qscx:  min,max = ', QSCX_MIN, QSCX_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'qscy:  min,max = ', QSCY_MIN, QSCY_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'uscx:  min,max = ', USCX_MIN, USCX_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'uscy:  min,max = ', USCY_MIN, USCY_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'vscx:  min,max = ', VSCX_MIN, VSCX_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'vscy:  min,max = ', VSCY_MIN, VSCY_MAX, format = '(a17, 2f15.5)'
Printf, theLUN, 'cori:  min,max = ', CORI_MIN, CORI_MAX, format = '(a17, 2f15.10)'
Printf, theLUN, 'pasp:  min,max = ', PASP_MIN, PASP_MAX, format = '(a17, 2f15.5)'

If (do_ascii) Then Begin
  If (N_Elements(WCELLS) gt 0) Then Begin
    Printf, theLUN, 'Wet points: ', WCELLS, 'Land points: ', LCELLS, $
                     format = '(2(a12, i12, 2x))'
  EndIf
  If (N_Elements(DEPTH_MIN) gt 0) Then Begin
    Printf, theLUN, 'min DEPTH: ', DEPTH_MIN, 'max DEPTH: ', DEPTH_MAX, $
                     'mean DEPTH: ', DEPTH_MEAN, $
                     format = '(3(a12, f12.5, 2x))'
  EndIf
  If ((N_Elements(DLON_MIN) gt 0) and (N_Elements(DLAT_MIN) gt 0)) Then Begin
    Printf, theLUN, 'min DLON: ', DLON_MIN, 'max DLON: ', DLON_MAX, 'mean DLON: ', DLON_MEAN, $
                     format = '(3(a12, f12.5, 2x))'
    Printf, theLUN, 'min DLAT: ', DLAT_MIN, 'max DLAT: ', DLAT_MAX, 'mean DLAT: ', DLAT_MEAN, $
                     format = '(3(a12, f12.5, 2x))'
  EndIf
  If ((N_Elements(DX_MIN) gt 0) and (N_Elements(DY_MIN) gt 0)) Then Begin
    Printf, theLUN, 'min DX: ', DX_MIN, 'max DX: ', DX_MAX, 'mean DX: ', DX_MEAN, $
                     format = '(3(a12, f12.5, 2x))'
    Printf, theLUN, 'min DY: ', DY_MIN, 'max DY: ', DY_MAX, 'mean DY: ', DY_MEAN, $
                     format = '(3(a12, f12.5, 2x))'
  EndIf
EndIf

If (do_fname) Then $
  If (N_Elements(theLUN) ne 0) Then Free_Lun, theLUN

End
