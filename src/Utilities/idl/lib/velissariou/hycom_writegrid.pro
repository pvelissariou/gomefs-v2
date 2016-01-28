Pro Hycom_WriteGrid, Fname = fname, Lun = lun, Ascii = ascii, Full = full, Pad = pad
;+++
; NAME:
;	Hycom_WriteGrid
; VERSION:
;	1.0
; PURPOSE:
;	To read a bathymetric grid data file and return grid parameters
;       and depths.
; CALLING SEQUENCE:
;	Hycom_WriteGrid, [[fname = fname], [lun = lun], /ascii]
;	On input:
;	   fname - Full pathway name of the lat/lon data file
;            lun - the LUN of the input/output file, already open (regional file - optional)
;          ascii - setting this keyword modifies the bahavior of
;                  Hycom_WriteGrid on how it writes the lat/lon values (ascii or binary - `optional)
;	On output:
;
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

do_ascii = Keyword_set(ascii)
do_full  = do_ascii and (not Keyword_set(full)) ? 0 : 1

; ----------------------------------------
If (do_fname) Then Begin
  If (do_ascii) Then Begin
    Openw, theLUN, fname, /Get_Lun
  EndIf Else Begin
    Openw, theLUN, fname, /Get_Lun, /Swap_If_Little_Endian
  EndElse
EndIf Else Begin
  theLUN = lun
EndElse

  If (do_ascii) Then Begin
    If (not do_full) Then Begin
      Printf, theLUN, plon, format = '(10(f12.5))'
      Printf, theLUN, plat, format = '(10(f12.5))'
    EndIf Else Begin
      Printf, theLUN, plon, format = '(10(f12.5))'
      Printf, theLUN, plat, format = '(10(f12.5))'
      Printf, theLUN, qlon, format = '(10(f12.5))'
      Printf, theLUN, qlat, format = '(10(f12.5))'
      Printf, theLUN, ulon, format = '(10(f12.5))'
      Printf, theLUN, ulat, format = '(10(f12.5))'
      Printf, theLUN, vlon, format = '(10(f12.5))'
      Printf, theLUN, vlat, format = '(10(f12.5))'
      Printf, theLUN, pang, format = '(10(f12.5))'
      Printf, theLUN, pscx, format = '(10(f12.5))'
      Printf, theLUN, pscy, format = '(10(f12.5))'
      Printf, theLUN, qscx, format = '(10(f12.5))'
      Printf, theLUN, qscy, format = '(10(f12.5))'
      Printf, theLUN, uscx, format = '(10(f12.5))'
      Printf, theLUN, uscy, format = '(10(f12.5))'
      Printf, theLUN, vscx, format = '(10(f12.5))'
      Printf, theLUN, vscy, format = '(10(f12.5))'
      Printf, theLUN, cori, format = '(10(f12.5))'
      Printf, theLUN, pasp, format = '(10(f12.5))'
    EndElse
  EndIf Else Begin
    If (N_Elements(pad) ne 0) Then Begin
      n_padding = Round(Abs(pad[0]))
    EndIf Else Begin 
      n_padding = (N_Elements(HC_NPAD) eq 0) ? 4096 - TCELLS Mod 4096 : HC_NPAD
    EndElse
    If (n_padding gt 0) Then Begin
      padding = Fltarr(n_padding)
      padding[*] = HC_NPAD_VAL
      Writeu, theLUN, Float(plon), padding
      Writeu, theLUN, Float(plat), padding
      Writeu, theLUN, Float(qlon), padding
      Writeu, theLUN, Float(qlat), padding
      Writeu, theLUN, Float(ulon), padding
      Writeu, theLUN, Float(ulat), padding
      Writeu, theLUN, Float(vlon), padding
      Writeu, theLUN, Float(vlat), padding
      Writeu, theLUN, Float(pang), padding
      Writeu, theLUN, Float(pscx), padding
      Writeu, theLUN, Float(pscy), padding
      Writeu, theLUN, Float(qscx), padding
      Writeu, theLUN, Float(qscy), padding
      Writeu, theLUN, Float(uscx), padding
      Writeu, theLUN, Float(uscy), padding
      Writeu, theLUN, Float(vscx), padding
      Writeu, theLUN, Float(vscy), padding
      Writeu, theLUN, Float(cori), padding
      Writeu, theLUN, Float(pasp), padding
    EndIf Else Begin
      Writeu, theLUN, Float(plon)
      Writeu, theLUN, Float(plat)
      Writeu, theLUN, Float(qlon)
      Writeu, theLUN, Float(qlat)
      Writeu, theLUN, Float(ulon)
      Writeu, theLUN, Float(ulat)
      Writeu, theLUN, Float(vlon)
      Writeu, theLUN, Float(vlat)
      Writeu, theLUN, Float(pang)
      Writeu, theLUN, Float(pscx)
      Writeu, theLUN, Float(pscy)
      Writeu, theLUN, Float(qscx)
      Writeu, theLUN, Float(qscy)
      Writeu, theLUN, Float(uscx)
      Writeu, theLUN, Float(uscy)
      Writeu, theLUN, Float(vscx)
      Writeu, theLUN, Float(vscy)
      Writeu, theLUN, Float(cori)
      Writeu, theLUN, Float(pasp)
    EndElse
  EndElse

If (do_fname) Then $
  If (N_Elements(theLUN) ne 0) Then Free_Lun, theLUN

End
