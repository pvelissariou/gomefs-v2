Function BathSmooth_Mellor, darr,                      $
                            marr,                      $
                            RFAC = rfac,               $
                            RX = rx,                   $
                            MAX_ITER = max_iter,       $
                            REPORT = report,           $
                            FULL_REPORT = full_report, $
                            EIGHT = eight
;+++
; NAME:
;	HANEY
;
; VERSION:
;	1.0
;
; PURPOSE:
;	To smooth locally a bathymetry to be used in a sigma enable hydrodynamic
;       model. The smoothing is performed locally (when needed) using Mellor's
;       approach.
;
;       See:      G. L. Mellor, T. Ezer and L. Y. Oey, 1994. The pressure gradient
;            conundrum of sigma coordinate ocean models. Journal of Atmospheric and
;            Oceanic Technology, 11, 1126-1134.
;                Haney, R. L., 1991. On the pressure gradient force over steep
;            bathymetry in sigma coordinates ocean models. J. Phys. Oceanogr.
;            21, 610-619.
;                Beckmann, A., Haidvogel, D.B., 1993. Numerical simulation of
;            flow around a tall isolated seamount. Part I: Problem formulation
;            and model accuracy. J. Phys. Oceanogr. 23, 1736-1753.
;                 Mathieu Dutour Sikiric, Ivica JaneKovic, Milivoj Kuzmic, 2009.
;            A new approach to bathymetry smoothing in sigma-coordinate ocean
;            models. Ocean Modelling 29, 128-136.
;                 http://www.liga.ens.fr/~dutour/Bathymetry/
;                 http://www.liga.ens.fr/~dutour/Presentations/SteepnessPres.pdf
;
; AUTHOR:
;
;      Panagiotis Velissariou, Ph.D, P.E.
;      E-mail: pvelissariou@coaps.fsu.edu
;
; CALLING SEQUENCE:
;      farr = BathSmooth_Mellor(darr, marr, [[RFAC = rfac], [tol = tol], [RX = rx],
;                                            [/report], [/full_report], [/eight]])
;	     darr - The depth array (bathymetry). This is a 2D array of values
;                   that represent the water depths (positive) at the gidded
;                   locations.
;            marr - The 2D mask array of the land points (<= 0 <- land AND > 0 -> water)
;
; KEYWORDS:
;            rfac - This keyword variable is for the maximum value of the rfac
;                   stiffness parameter that controls the level of smoothing.
;                   User input. Default: rfac = 0.2
;             tol - Set the tolerance where the calculations are finished
;                   (that is, when rfac (calculated) <= rfac (input) + tol.
;                   Range: 0.00001 - 0.01
;                   User input. Default: rfac = 0.0001
;              rx - Set this keyword to a named variable that receives the
;                   max value of the calculated final bottom stiffness
;                   parameter
;          report - Set this keyword if you want to see the progress of the
;                   calculations
;     full_report - Set this keyword if you want to see the full progress of the
;                   calculations
;           eight - Set this keyword if you want to use all eight surrounding
;                   grid points for the calculations
;                   default: use only the four grid points (cross)
;
; RETURNS:
;            farr - The modified (smoothed) bathymetry
;
; SIDE EFFECTS:
;	As far as I know none.
;
; MODIFICATION HISTORY:
;	Created August 10 2011 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  On_Error, 2

  ; --------------------
  ; check the input "depth" array (depths at RHO points)
  If (N_Elements(darr) EQ 0) Then Message, "Must pass the <darr> argument."
  If (Where([7, 8, 10, 11] EQ Size(darr, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <darr>."
  If (Size(darr, /N_DIMENSIONS) NE 2) Then $
    Message, "<darr> must be a 2D array of values."

  dims = Size(darr, /DIMENSIONS)
  IPNTS = dims[0]
  JPNTS = dims[1]

  darrType = size(darr, /TYPE)
  macinf = machar(double = ((darrType eq 5) or (darrType eq 9)))

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

  ; wetIDX contains the indices of the "wet" grid points
  wetIDX = Where(marr GT 0, wetCNT, COMPLEMENT = landIDX, NCOMPLEMENT = landCNT)
  If (wetCNT EQ 0) Then $
    Message, "error in <marr>: no positive values found to identify the wet grid points."

  Mask_Rx = -1.0

  ; --------------------
  ; check for the remaining arguments
  MAX_ITER = (N_Elements(MAX_ITER) EQ 0) ? 10000L : Round(Abs(MAX_ITER[0]))
  rfac     = (N_Elements(rfac) EQ 0) ? 0.2  : (0.01 > Float(rfac[0]) < 1.0)
  myRFAC   = 0.50 * rfac

  ; --------------------
  ; set the directional array
  If Keyword_Set(eight) Then Begin
    DirArr = [ [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1] ]
  EndIf Else Begin
    DirArr = [ [1, 0], [0, 1], [-1, 0], [0, -1] ]
  EndElse

  ; --------------------
  ; get the indices (locations) of the minimum water depth
  ; we need to keep the minimum depth fixed (controlled)
  MinDep = Min(darr[wetIDX])
  MeanDep = Mean(darr[wetIDX])
  MinDepIDX = wetIDX[Where(Abs(darr[wetIDX] - MinDep) LE macinf.eps, MinDepCNT)]

  ; --------------------
  ; get the initial bottom stiffness parameter array
  max_rx = (Stiff_Bottom(darr, marr, RX = rx, EIGHT = eight, $
                         report = full_report))[0]
  rxIDX = Where(rx GT rfac, rxCNT)
  If (rxCNT EQ 0) Then Return, darr

  ; ############################################################
  ; ##### START THE CALCULATIONS
  ; ############################################################

  farr = darr
  rxRATIO = (1.0 - myRFAC) / (1.0 + myRFAC)

  For iter = 0L, MAX_ITER - 1 Do Begin
    If Keyword_Set(report) Then $
      print, 'Iteration: ', iter + 1, 'max_rx = ', max_rx, 'fix points = ', rxCNT, $
              format = '(a11, i4, a12, f11.8, a15, i8)'

    For irx = 0L, rxCNT - 1 Do Begin
      idx = array_indices([IPNTS, JPNTS], rxIDX[irx], /DIMENSIONS)
      i = idx[0]
      j = idx[1]

      If Keyword_Set(full_report) Then $
        print, '  Doing ', irx + 1, '  of:  ', rxCNT, format = '(a8, i9, a7, i9)'

      ; get all neighboring grid points to [i, j] and the corresponding indices
      IJarr = [ [(DirArr[0, *] + i > 0) AND (DirArr[0, *] + i < (IPNTS - 1)), $
                 (DirArr[1, *] + j > 0) AND (DirArr[1, *] + j < (JPNTS - 1))] ]
      IDXarr = reform(IJarr[1, *]) * IPNTS + reform(IJarr[0, *])

      ; take out the point [i, j] (this is because of the above statement at
      ; the borders we might get the [i, j] again
      IDXarr = IDXarr[Where(IDXarr NE rxIDX[irx])]

      ; eliminate duplicate indices (if there are any)
      IDXarr = IDXarr[Uniq(IDXarr, Sort(IDXarr))]

      ; take out any land points found in the search
      idx = Where(marr[IDXarr] GT 0, icnt)
      If (icnt GT 0) Then IDXarr = IDXarr[idx]

      ; re-calculate the IJarr from the final IDXarr
      IJarr = array_indices([IPNTS, JPNTS], IDXarr, /DIMENSIONS)

      For ij = 0L, N_Elements(IDXarr) - 1 Do Begin
        iIJ = IJarr[0, ij]
        jIJ = IJarr[1, ij]

        chkRX = Abs(farr[i, j] - farr[iIJ, jIJ]) / $
                Abs(farr[i, j] + farr[iIJ, jIJ])

        If (chkRX GT myRFAC) Then Begin
          delta  = 0.5 * ( (myRFAC - 1.0) * farr[i, j] + (myRFAC + 1.0) * farr[iIJ, jIJ] )
          farr[i, j] = farr[i, j] + delta
          farr[iIJ, jIJ] = farr[iIJ, jIJ] - delta
        EndIf
      EndFor
    EndFor ; irx

    max_rx = (Stiff_Bottom(farr, marr, RX = rx, EIGHT = eight, $
                           report = full_report))[0]

    If (max_rx LE rfac) Then Break

    rxIDX = Where(rx GT rfac, rxCNT)
  EndFor ; iter

  Return, farr

End
