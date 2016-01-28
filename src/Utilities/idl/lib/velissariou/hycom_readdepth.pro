Pro Hycom_ReadDepth, Fname = fname, Lun = lun, Ascii = ascii, Pad = pad
;+++
; NAME:
;	Hycom_ReadDepth
; VERSION:
;	1.0
; PURPOSE:
;	To read a bathymetric grid data file and return grid parameters
;       and depths.
; CALLING SEQUENCE:
;	Hycom_ReadDepth, [[fname = fname], [lun = lun], /ascii]
;	On input:
;	   fname - Full pathway name of the bathymetry data file
;            lun - the LUN of the input/output file, already open (depth file - optional)
;          ascii - setting this keyword modifies the bahavior of
;                  Hycom_ReadDepth on how it reads the depths (ascii or binary - `optional)
;	On output:
;	   dgrid - Bathymetry values at the grid points
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

  depths  = Fltarr(IPNTS, JPNTS)
  If (do_ascii) Then Begin
    Readf, theLUN, depths
  EndIf Else Begin
    If (N_Elements(pad) ne 0) Then Begin
      n_padding = Round(Abs(pad[0]))
    EndIf Else Begin 
      n_padding = (N_Elements(HC_NPAD) eq 0) ? 4096 - TCELLS Mod 4096 : HC_NPAD
    EndElse
    If (n_padding gt 0) Then Begin
      padding = Fltarr(n_padding)
      Readu, theLUN, depths, padding
    EndIf Else Begin
      Readu, theLUN, depths
    EndElse
  EndElse

  dgrid = Dblarr(IPNTS, JPNTS)
  dgrid[*, *] = depths[*, *]

  ; HYCOM uses a very large value for depths to define the land
  ; set these depths to zero here
  mask_val = (N_Elements(HC_LANDMASK) NE 0) ? HC_LANDMASK : 2.0 ^ 100.0 ; from HYCOM source
  lidx = Where((dgrid le 0.01) or (dgrid ge 0.5 * mask_val), lcnt)      ; from HYCOM source
  If (lcnt ne 0) Then dgrid[lidx] = 0

  ; ---------- determine the "wet" and "land" points
  WCELLSIDX = Where(dgrid gt 0, WCELLS, $
                    COMPLEMENT = LCELLSIDX, NCOMPLEMENT = LCELLS)

  ; ---------- get the depth range values
  DEPTH_MAX  = Max(dgrid[WCELLSIDX], Min = DEPTH_MIN)
  DEPTH_MEAN = Mean(dgrid[WCELLSIDX])

If (do_fname) Then $
  If (N_Elements(theLUN) ne 0) Then Free_Lun, theLUN

End
