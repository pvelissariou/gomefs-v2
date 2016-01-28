Function Stiff_Bottom,           $
                zarr,            $
                marr,            $
                RX = rx,         $
                REPORT = report, $
                EIGHT = eight
;+++
; NAME:
;	STIFF_BOTTOM
;
; VERSION:
;	1.0
;
; PURPOSE:
;	To calculate the maximum bottom (rfac) grid stiffness parameter.
;       The rfac calculated values represent the maximum value of rfac
;       taking into consideration the requested neighboring grid points
;       (4 or 8) relative to the grid point in question.
;
;              | h(i,j) - h(i-1,j) |
;      rfac = -----------------------
;              | h(i,j) + h(i-1,j) |
;                                                          
;
;       See:      Haney, R. L., 1991. On the pressure gradient force over steep
;            bathymetry in sigma coordinates ocean models.J. Phys. Oceanogr.
;            21, 610-619.
;                Beckmann, A., Haidvogel, D.B., 1993. Numerical simulation of
;            flow around a tall isolated seamount. Part I: Problem formulation
;            and model accuracy. J. Phys. Oceanogr. 23, 1736-1753.
;                 Shchepetkin, A.F. and J.C. McWilliams, 2003. A Method for
;            Computing Horizontal Pressure-Gradient Force in an Oceanic Model
;            with a Non-Aligned Vertical Coordinate. Journal of Geophysical
;            Research, 108, Issue: C3, Pages: 3090.
;                 Mathieu Dutour Sikiric, Ivica JaneKovic, Milivoj Kuzmic, 2009.
;            A new approach to bathymetry smoothing in sigma-coordinate ocean
;            models. Ocean Modelling 29, 128-136.
;
; AUTHOR:
;
;      Panagiotis Velissariou, Ph.D, P.E.
;      E-mail: pvelissariou@fsu.edu
;
; CALLING SEQUENCE:
;      rx_out = Stiff_Bottom(zarr, marr, rx, [[/report,][/eight]])
;
;	     zarr - The depth array (2D). The size of the zarr should be:
;                   Size: zarr[IPNTS, JPNTS].
;            marr - The 2D mask array of the land points:
;                   (<= 0 <- land AND > 0 -> water).
;                   Size: marr[IPNTS, JPNTS].
;
; KEYWORDS:
;              rx - Set this keyword to a named variable that receives the
;                   values of the bottom stiffness parameter.
;                   Size: rx[IPNTS, JPNTS].
;          report - Set this keyword if you want to see the progress of the
;                   calculations.
;                   Default: no
;           eight - Set this keyword if you want to use all eight surrounding
;                   grid points for the calculations
;                   Default: use only the four grid points (cross).
;
; RETURNS:
;                   The 1D vector that contains the maximum, minimum and the
;                   average (over all the domain) values of the rx stiffness
;                   parameter.
;
; SIDE EFFECTS:
;	As far as I know none.
;
; MODIFICATION HISTORY:
;	Created July 20 2011 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  On_Error, 2

  ; --------------------
  ; check the input "depth" array (depths at w points)
  If (N_Elements(zarr) EQ 0) Then Message, "Must pass the <zarr> argument."
  If (Where([7, 8, 10, 11] EQ Size(zarr, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <zarr>."
  If (Size(zarr, /N_DIMENSIONS) NE 2) Then $
    Message, "<zarr> must be a 2D array of values."

  dims = Size(zarr, /DIMENSIONS)
  IPNTS = dims[0]
  JPNTS = dims[1]

  ; --------------------
  ; check the input "mask" array
  If (N_Elements(marr) EQ 0) Then Message, "Must pass the <marr> argument."
  If (Where([7, 8, 10, 11] EQ Size(marr, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <marr>."
  If (Size(marr, /N_DIMENSIONS) NE 2) Then $
    Message, "<marr> must be a 2D array of values."

  dims = Size(marr, /DIMENSIONS)
  If (dims[0] NE IPNTS) AND (dims[1] NE JPNTS) Then $
    Message, "<zarr, marr> have inconsistent horizontal dimensions."

  mskIDX = Where(marr GT 0, mskCNT) ; mask = 1 for water points
  If (mskCNT EQ 0) Then $
    Message, "error in <marr>: no positive values found to identify the wet grid points."

  Mask_Rx = -1.0

  ; --------------------
  ; set the directional array
  If Keyword_Set(eight) Then Begin
    DirArr = [ [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1] ]
  EndIf Else Begin
    DirArr = [ [1, 0], [0, 1], [-1, 0], [0, -1] ]
  EndElse

  ; --------------------
  ; START THE CALCULATIONS
  Rx = Make_Array(IPNTS, JPNTS, /FLOAT, VALUE = Mask_Rx)

  For imsk = 0L, mskCNT - 1 Do Begin
    idx = array_indices([IPNTS, JPNTS], mskIDX[imsk], /DIMENSIONS)
    i = idx[0]
    j = idx[1]

    If Keyword_Set(report) Then $
      print, 'Doing ', imsk + 1, '  of:  ', mskCNT, format = '(a6, i9, a7, i9)'

    ; eliminate any land points found in the search
    IdxArr = [ [(DirArr[0, *] + i > 0) AND (DirArr[0, *] + i < (IPNTS - 1)), $
                (DirArr[1, *] + j > 0) AND (DirArr[1, *] + j < (JPNTS - 1))] ]
    idx = Where(marr[IdxArr[0,*], IdxArr[1,*]] GT 0, icnt)
    If (icnt GT 0) Then Begin
      IdxArr = [IdxArr[0, idx], IdxArr[1, idx]]
    EndIf Else Begin
      Message, 'We encountered a single wet point at: ' + $
               string(i, j, format = '(2i5)')
    EndElse

    nIJ = N_Elements(IdxArr[0, *])
    TmpRX = Make_Array(nIJ, /FLOAT, VALUE = 0.0)

    For ij = 0L, nIJ - 1 Do Begin
      val1 = zarr[i, j]
      val2 = zarr[IdxArr[0, ij], IdxArr[1, ij]]

      absval1 = Abs(val1 - val2)
      absval2 = Abs(val1 + val2)

      TmpRX[ij] = (absval1 LE 0.0001) ? 0.0 : (absval1 / absval2)
    EndFor

    Rx[i, j] = Max(TmpRX)
  EndFor

  Max_Out = Mask_Rx
  Min_Out = Mask_Rx
  Ave_Out = Mask_Rx
  idx = Where(Rx GT Mask_Rx, icnt)
  If (icnt GT 0) Then Begin
    Max_Out = Max(Rx[idx], Min = Min_Out)
    Ave_Out = Mean(Rx[idx])
  EndIf

  Return, [Max_Out, Min_Out, Ave_Out]

End
