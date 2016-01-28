;+++
; NAME:
;	STRETCHING
;
; VERSION:
;	1.0
;
; PURPOSE:
;	To calculate the sigma coordinate function(s).
;
;       See:      https://www.myroms.org/wiki/index.php/File:Manual_2012.pdf
;
; AUTHOR:
;
;      Panagiotis Velissariou, Ph.D, P.E.
;      E-mail: pvelissariou@coaps.fsu.edu
;
; CALLING SEQUENCE:
;	Stretching, nLAY, vstretching, s_theta, b_theta [[, NAMED_VAR = var][, KEYWORD]]
;	     nLAY - The number of s-levels at rho points
;	  s_theta - S-coordinate parameter (a zero value implies no stretching)
;                   range: 0 - 20, default = 0.0
;	  b_theta - S-coordinate parameter
;                   range: 0 - 1, default = 0.0
;
; KEYWORDS:
;             w_s - Set this keyword to a named variable that receives the
;                   values of the s-coordinate at the w-points
;                   (1D array w_s = w_s(k))
;             r_s - Set this keyword to a named variable that receives the
;                   values of the s-coordinate at the rho-points
;                   (1D array r_s = r_s(k))
;            w_cs - Set this keyword to a named variable that receives the
;                   values of the s-coordinate stretching function at the w-points
;                   (1D array w_cs = w_cs(k))
;            r_cs - Set this keyword to a named variable that receives the
;                   values of the s-coordinate stretching function at the rho-points
;                   (1D array r_cs = r_cs(k))
;            rev - Set this keyword to reverse the sigma coordinates. Default is
;                   from bottom (-1) to top (0): k = 0 -> s = -1.0, k = KMAX-1 -> s = 0.0
;
; RETURNS:
;               NOTHING
;
; SIDE EFFECTS:
;	As far as I know none.
;
; MODIFICATION HISTORY:
;	Created Tue Dec 18, 2012 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++
Pro Stretching, $
           nLAY,        $
           vstretching, $
           s_theta,     $
           b_theta,     $
           W_S = w_s,   $
           R_S = r_s,   $
           W_CS = w_cs, $
           R_CS = r_cs, $
           REV = rev

  Compile_Opt HIDDEN, IDL2

  On_Error, 2

  nParam = n_params()
  if (nParam ne 4) then message, 'Incorrect number of arguments.'

  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = Where(badtypes EQ Size(nLAY, /TYPE), count)
    If (count NE 0) Then $
      Message, "Only numbers are valid values for <nLAY>."
  void = Where(badtypes EQ Size(vstretching, /TYPE), count)
    If (count NE 0) Then $
      Message, "Only numbers are valid values for <vstretching>."
  void = Where(badtypes EQ Size(s_theta, /TYPE), count)
    If (count NE 0) Then $
      Message, "Only numbers are valid values for <s_theta>."
  void = Where(badtypes EQ Size(b_theta, /TYPE), count)
    If (count NE 0) Then $
      Message, "Only numbers are valid values for <b_theta>."

  ;NL_r: Number of vertical terrain-following levels at RHO-points
  NL_r = (1 > fix(nLAY))
  ;NL_w: Number of vertical terrain-following levels at W-points
  NL_w = NL_r + 1

  V_str = (1 > fix(vstretching) < 4)
  S_tht = (0 > s_theta )
  B_tht = (0 > b_theta )

  ; setup the sigma levels
  ds  = 1.0D / Double(NL_r)

  ; s-coord at w points
  ; make sure that at bottom/top the values are set to -1/0
  w_s = ZeroFloatFix( ds * (Findgen(NL_w) - NL_r) )
  w_s[0] = -1.0D
  w_s[NL_w - 1] = 0.0D

  ; s-coord at rho points
  r_s = ZeroFloatFix( ds * (Findgen(NL_r) + 0.5 - NL_r) ) ; s-coord at rho points

  Case V_str Of
    ; Original vertical stretching function (Song and Haidvogel, 1994).
    1: $
      Begin
        S_tht = (0 > S_tht < 20)
        B_tht = (0 > B_tht < 1)
        If (S_tht gt 0) Then Begin
          awght = ZeroFloatFix( Sinh(S_tht * w_s) / Sinh(S_tht) )
          bwght = ZeroFloatFix( (Tanh(S_tht * (w_s + 0.5)) / (2.0 * Tanh(0.5 * S_tht))) - 0.5 )
          w_cs  = ZeroFloatFix( (1.0 - B_tht) * awght + B_tht * bwght )
          
          awght = ZeroFloatFix( Sinh(S_tht * r_s) / Sinh(S_tht) )
          bwght = ZeroFloatFix( (Tanh(S_tht * (r_s + 0.5)) / (2.0 * Tanh(0.5 * S_tht))) - 0.5 )
          r_cs  = ZeroFloatFix( (1.0 - B_tht) * awght + B_tht * bwght )
        EndIf Else Begin
          w_cs = w_s
          r_cs = r_s
        EndElse
      End
    ; A. Shchepetkin (UCLA-ROMS, 2005) vertical stretching function.
    2: $
      Begin
        awght = 1.0D
        bwght = 1.0D
        If (S_tht gt 0) Then Begin
          wSUR = ZeroFloatFix( (1.0 - Cosh(S_tht * w_s)) / (Cosh(S_tht) - 1.0) )
          rSUR = ZeroFloatFix( (1.0 - Cosh(S_tht * r_s)) / (Cosh(S_tht) - 1.0) )
          If (B_tht gt 0) Then Begin
            wBOT = ZeroFloatFix( - 1.0 + Sinh(B_tht * (w_s + 1.0)) / Sinh(B_tht) )
            rBOT = ZeroFloatFix( - 1.0 + Sinh(B_tht * (r_s + 1.0)) / Sinh(B_tht) )

            wWGHT = ((w_s + 1.0) ^ (awght)) * $
                      (1.0 + (awght / bwght) * (1.0 - ((w_s + 1.0) ^ (bwght))))
            wWGHT = ZeroFloatFix( wWGHT )

            rWGHT = ((r_s + 1.0) ^ (awght)) * $
                      (1.0 + (awght / bwght) * (1.0 - ((r_s + 1.0) ^ (bwght))))
            rWGHT = ZeroFloatFix( rWGHT )

            w_cs = ZeroFloatFix( wWGHT * wSUR + (1.0 - wWGHT) * wBOT )
            r_cs = ZeroFloatFix( rWGHT * rSUR + (1.0 - rWGHT) * rBOT )
          EndIf Else Begin
            w_cs = wSUR
            r_cs = rSUR
          EndElse
        EndIf Else Begin
          w_cs = w_s
          r_cs = r_s
        EndElse
      End
    ; R. Geyer BBL vertical stretching function.
    3: $
      Begin
        If (S_tht gt 0) Then Begin
          hscale = 3.0
          wSUR = ZeroFloatFix( - Alog(Cosh(hscale * Abs(w_s) ^ (S_tht))) / Alog(Cosh(S_tht)) )
          rSUR = ZeroFloatFix( - Alog(Cosh(hscale * Abs(r_s) ^ (S_tht))) / Alog(Cosh(S_tht)) )

          wBOT = ZeroFloatFix( Alog(Cosh(hscale * (w_s + 1.0) ^ (B_tht))) / Alog(Cosh(hscale)) - 1.0 )
          rBOT = ZeroFloatFix( Alog(Cosh(hscale * (r_s + 1.0) ^ (B_tht))) / Alog(Cosh(hscale)) - 1.0 )

          wWGHT = ZeroFloatFix( 0.5 * (1.0 - Tanh(hscale * (w_s + 0.5))) )
          rWGHT = ZeroFloatFix( 0.5 * (1.0 - Tanh(hscale * (r_s + 0.5))) )

          w_cs = ZeroFloatFix( (1.0 - wWGHT) * wSUR + wWGHT * wBOT )
          r_cs = ZeroFloatFix( (1.0 - rWGHT) * rSUR + rWGHT * rBOT )
        EndIf Else Begin
          w_cs = w_s
          r_cs = r_s
        EndElse
      End
    ; A. Shchepetkin (UCLA-ROMS, 2010) double vertical stretching function
    ; with bottom refinement
    4: $
      Begin
        S_tht = (0 > S_tht < 10)
        B_tht = (0 > B_tht < 4)
        If (S_tht gt 0) Then Begin
          wSUR = ZeroFloatFix( (1.0 - Cosh(w_s * S_tht)) / (Cosh(S_tht) - 1.0) )
          rSUR = ZeroFloatFix( (1.0 - Cosh(r_s * S_tht)) / (Cosh(S_tht) - 1.0) )
        EndIf Else Begin
          wSUR = ZeroFloatFix( - w_s ^ (2.0) )
          rSUR = ZeroFloatFix( - r_s ^ (2.0) )
        EndElse
        If (B_tht gt 0) Then Begin
          wBOT = ZeroFloatFix( (Exp(wSUR * B_tht) - 1.0) / (1.0 - Exp(- B_tht)) )
          rBOT = ZeroFloatFix( (Exp(rSUR * B_tht) - 1.0) / (1.0 - Exp(- B_tht)) )

          w_cs = wBOT
          r_cs = rBOT
        EndIf Else Begin
          w_cs = wSUR
          r_cs = rSUR
        EndElse
      End
    else:
  EndCase

  ; make sure that at the bottom/top the values are set to -1/0
  w_cs[0] = -1.0D
  w_cs[NL_w - 1] = 0.0D

  If (Keyword_Set(rev) EQ 1) Then Begin
    w_s = Reverse(w_s)
    r_s = Reverse(r_s)

    w_cs = Reverse(w_cs)
    r_cs = Reverse(r_cs)
  EndIf

End

;+++
; NAME:
;	SGRID
;
; VERSION:
;	1.0
;
; PURPOSE:
;	To calculate the sigma coordinate function and the corresponding
;       z values.
;
;       See:      https://www.myroms.org/wiki/index.php/File:Manual_2010.pdf
;
; AUTHOR:
;
;      Panagiotis Velissariou, Ph.D, P.E.
;      E-mail: pvelissariou@coaps.fsu.edu
;
; CALLING SEQUENCE:
;	SGrid, depths, nLAY, [[mask = mask], ...])
;	   depths - The depth array at rho points (2D - bathymetry with positive depths)
;	     nLAY - The number of s-levels at rho points
;	     mask - The mask array at rho points (2D - water points have mask = 1.0, land points mask = 0.0)
;
; KEYWORDS:
;	     ZETA - Set this keyword for the free surface fluctuation (2D array)
;                   Default: zeta[*, *] = 0
;      VTRANSFORM - The Vtransform to be used
;                   Default: vtransform = 2
;     VSTRETCHING - The Vstretching to be used
;                   Default: vstretching = 4
;          TCLINE - S-coordinate parameter
;                   Default: tcline = 0.0
;         S_THETA - S-coordinate parameter
;                   Default = 0.0
;         B_THETA - S-coordinate parameter
;                   Default = 0.0
;              HC - Set this keyword to a named variable that receives the
;                   value of the critical depth between min depths and tcline
;             W_S - Set this keyword to a named variable that receives the
;                   values of the s-coordinate at the w-points
;                   (1D array w_s = w_s(k))
;             R_S - Set this keyword to a named variable that receives the
;                   values of the s-coordinate at the rho-points
;                   (1D array r_s = r_s(k))
;            W_CS - Set this keyword to a named variable that receives the
;                   values of the s-coordinate stretching function at the w-points
;                   (1D array w_cs = w_cs(k))
;            R_CS - Set this keyword to a named variable that receives the
;                   values of the s-coordinate stretching function at the rho-points
;                   (1D array r_cs = r_cs(k))
;          W_ZARR - Set this keyword to a named variable that receives the
;                   z-values at the w_s w-points
;                   (3D array w_zarr = w_zarr(i,j,k))
;          R_ZARR - Set this keyword to a named variable that receives the
;                   z-values at the r_s rho-points
;                   (3D array r_zarr = r_zarr(i,j,k))
;         OUT_DEP - Set this keyword to a named variable that receives the
;                   calculated depths at U/V/W/PSI/RHO locations
;                   (2D array)
;
;            STAGGERED GRID LOCATION
;            Default: calculations are performed at RHO-points
;
;            ULOC - Set this keyword to perform the calculations at U-points of
;                   a C-type staggered grid (optional)
;            VLOC - Set this keyword to perform the calculations at V-points of
;                   a C-type staggered grid (optional)
;            WLOC - Set this keyword to perform the calculations at W-points of
;                   a C-type staggered grid (optional)
;            PLOC - Set this keyword to perform the calculations at PSI-points of
;                   a C-type staggered grid (optional)
;
;            REV - Set this keyword to reverse the sigma coordinates. Default is
;                   from bottom (-1) to top (0): k = 0 -> s = -1.0, k = KMAX-1 -> s = 0.0
;
; RETURNS:
;               NONE
;
; SIDE EFFECTS:
;	As far as I know none.
;
; MODIFICATION HISTORY:
;	Created July 20 2011 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++
Pro SGrid, depths,                    $
           nLAY,                      $
           mask,                      $
           ZETA = zeta,               $
           VTRANSFORM  = vtransform,  $
           VSTRETCHING = vstretching, $
           TCLINE  = tcline,          $
           S_THETA = s_theta,         $
           B_THETA = b_theta,         $
           HC = hc,                   $
           W_S = w_s,                 $
           R_S = r_s,                 $
           W_CS = w_cs,               $
           R_CS = r_cs,               $
           W_ZARR = w_zarr,           $
           R_ZARR = r_zarr,           $
           WETDRY = wetdry,           $
           OUT_DEP = out_dep,         $
           ULOC = uloc,               $
           VLOC = vloc,               $
           PLOC = ploc,               $
           WLOC = wloc,               $
           REV = rev

  Compile_Opt IDL2

  On_Error, 2

  nParam = N_Params()
  If (nParam LT 2) Then Message, 'Incorrect number of arguments, need <depths, nLAY [,mask]>.'

  uloc = (keyword_set(uloc) eq 1) ? 1 : 0
  vloc = (keyword_set(vloc) eq 1) ? 1 : 0
  ploc = (keyword_set(ploc) eq 1) ? 1 : 0
  wloc = (keyword_set(wloc) eq 1) ? 1 : 0

  if ((uloc + vloc + ploc + wloc) gt 1) then $
    message, 'Only one of <ULOC, VLOC, PLOC, WLOC> should be supplied.'

  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = Where(badtypes EQ Size(depths, /TYPE), count)
    If (count NE 0) Then $
      Message, "Only numbers are valid values for <depths>."
  void = Where(badtypes EQ Size(nLAY, /TYPE), count)
    If (count NE 0) Then $
      Message, "Only numbers are valid values for <nLAY>."

  ; --------------------
  ; check the input "depths" array (depths at RHO points)
  If ( Size(depths, /N_DIMENSIONS) NE 2 ) Then $
    Message, "<depths> should be a 2D array."
  If ( Min(depths) LT 0 ) Then $
    Message, "<depths> should be positive down."

  ; --------------------
  ; check the input "mask" array
  WCELLS = 0L
  LCELLS = 0L
  If (N_Elements(mask) NE 0) Then Begin
    If ( ~ Array_Equal(Size(depths, /DIMENSIONS), Size(mask, /DIMENSIONS)) ) Then $
      Message, "<depths, mask> have inconsistent dimensions."
    ; water points have a mask value of 1.0
    chkmsk = ChkForMask(mask, 1, WCELLSIDX, WCELLS, $
                        COMPLEMENT = LCELLSIDX, NCOMPLEMENT = LCELLS)
  EndIf

  ; --------------------
  ; check the input "zeta" array
  If (N_Elements(zeta) NE 0) Then Begin
    If ( ~ Array_Equal(Size(depths, /DIMENSIONS), Size(zeta, /DIMENSIONS)) ) Then $
      Message, "<depths, zeta> have inconsistent dimensions."
  EndIf Else Begin
    zeta    = depths
    zeta[*] = 0
  EndElse
  ; make sure that over land zeta is set to zero
  If (LCELLS NE 0) Then zeta[LCELLSIDX] = 0

  ; ----- Set/Get the basic parameters for the transformations below
  V_trn  = (N_Elements(vtransform) NE 0) $
             ? (1 > Fix(vtransform[0]) < 2) $
             : 2
  V_str = (N_Elements(vstretching) NE 0) $
             ? (1 > Fix(vstretching[0]) < 4) $
             : 4
  T_cln = (N_Elements(tcline) NE 0) $
             ? (0 > Double(tcline[0])) $
             : 0.0D
  S_tht = (N_Elements(s_theta) NE 0) $
             ? (0 > Double(s_theta[0])) $
             : 0.0D
  B_tht = (N_Elements(b_theta) NE 0) $
             ? (0 > Double(b_theta[0])) $
             : 0.0D

  NL_r = (1 > fix(nLAY))
  NL_w = NL_r + 1

  ; ---------- start the calculations
  Case 1 Of
    (ploc eq 1): $   ; horizontal PSI-points
      Begin
        out_dep = Rho2UVP_Points(depths, /PLOC)
        ssh     = Rho2UVP_Points(zeta, /PLOC)
      End
    (uloc eq 1): $   ; horizontal U-points
      Begin
        out_dep = Rho2UVP_Points(depths, /ULOC)
        ssh     = Rho2UVP_Points(zeta, /ULOC)
      End
    (vloc eq 1): $   ; horizontal V-points
      Begin
        out_dep = Rho2UVP_Points(depths, /VLOC)
        ssh     = Rho2UVP_Points(zeta, /VLOC)
      End
    (wloc eq 1): $   ; horizontal RHO-points
      Begin
        out_dep = depths
        ssh     = zeta
      End
    else: $  ; default is horizontal RHO-points
      Begin
        out_dep = depths
        ssh     = zeta
      End
  EndCase

  dims = size(out_dep, /DIMENSIONS)
  IPNTS = dims[0]
  JPNTS = dims[1]

  wetIDX = Where(out_dep gt 0, wetCNT, COMPLEMENT = dryIDX, NCOMPLEMENT = dryCNT)

  ; make sure that over land ssh is set to zero
  If (dryCNT NE 0) Then ssh[dryIDX] = 0

  ; get the sigma coordinates and stretching functions
  Stretching, NL_r, V_str, S_tht, B_tht, $
              W_S = w_s, R_S = r_s,      $
              W_CS = w_cs, R_CS = r_cs,  $
              REV = rev

  ; set the s-zlevel arrays
  w_zarr = Make_Array(IPNTS, JPNTS, NL_w, TYPE = Size(out_dep, /TYPE), VALUE = 0)
  r_zarr = Make_Array(IPNTS, JPNTS, NL_r, TYPE = Size(out_dep, /TYPE), VALUE = 0)
                             
  Case V_trn Of
    ; Original formulation (Shchepetkin and McWilliams, 2005)
    1: $
      Begin
        thisDEP = out_dep[wetIDX]
        thisSSH = ssh[wetIDX]

        min_dep = Min(thisDEP, MAX = max_dep)
        If (Keyword_Set(wetdry)) Then Begin
          hc = ZeroFloatFix( Min([Max([min_dep, 0]), T_cln]) )
        EndIf Else Begin
          hc = ZeroFloatFix( Min([min_dep, T_cln]) )
        EndElse

	For k = 0L, NL_w - 1 Do Begin
	  tmp_arr = out_dep & tmp_arr[*] = 0
	  z0 = ZeroFloatFix( (w_s[k] - w_cs[k]) * hc + w_cs[k] * thisDEP )
          tmp_arr[wetIDX] = ZeroFloatFix( z0 + thisSSH * (1.0 + z0 / thisDEP) )
          w_zarr[*, *, k] = tmp_arr
          
          If (k LT (NL_w - 1)) Then Begin
            tmp_arr = out_dep & tmp_arr[*] = 0
	    z0 = ZeroFloatFix( (r_s[k] - r_cs[k]) * hc + r_cs[k] * thisDEP )
            tmp_arr[wetIDX] = ZeroFloatFix( z0 + thisSSH * (1.0 + z0 / thisDEP) )
            r_zarr[*, *, k] = tmp_arr
          EndIf
	EndFor
      End
    ; New formulation (A. Shchepetkin)
    2: $
      Begin
        thisDEP = out_dep[wetIDX]
        thisSSH = ssh[wetIDX]

        hc = ZeroFloatFix( T_cln )

	For k = 0L, NL_w - 1 Do Begin
          tmp_arr = out_dep & tmp_arr[*] = 0
	  z0 = ZeroFloatFix( (w_s[k] * hc + w_cs[k] * thisDEP) / (hc + thisDEP) )
          tmp_arr[wetIDX] = ZeroFloatFix( thisSSH + (thisDEP + thisSSH) * z0 )
          w_zarr[*, *, k] = tmp_arr
          
          If (k LT (NL_w - 1)) Then Begin
            tmp_arr = out_dep & tmp_arr[*] = 0
	    z0 = ZeroFloatFix( (r_s[k] * hc + r_cs[k] * thisDEP) / (hc + thisDEP) )
            tmp_arr[wetIDX] = ZeroFloatFix( thisSSH + (thisDEP + thisSSH) * z0 )
            r_zarr[*, *, k] = tmp_arr
          EndIf
	EndFor
      End
    else: message, 'Vtransform should be equal to 1 or 2'
  EndCase

End
