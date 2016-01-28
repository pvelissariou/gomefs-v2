Function AreaRho_Roms, xdat, ydat,            $
                       XU = x_u, YU = y_u,    $
                       XV = x_v, YV = y_v,    $
                       XP = x_psi, YP = y_psi
;+++
; NAME:
;	AreaRho_Roms
; VERSION:
;	1.0
; PURPOSE:
;	To calculate the grid cell areas at the rho points.
; CALLING SEQUENCE:
;	AreaRho_Roms, xdat, ydat
;
;	On input:
;	    xdat - The X-coordinates of the "RHO" points (a 2D array, required)
;	    ydat - The Y-coordinates of the "RHO" points (a 2D array, required)
;
;	On output:
;	area_rho - The 2D array of the calculated areas at the RHO points
;
;	Optional parameters:
;	      XU - Set this to a named variable to get the x-coordinates
;                  of the "U" points
;	      YU - Set this to a named variable to get the y-coordinates
;                  of the "U" points
;	      XV - Set this to a named variable to get the x-coordinates
;                  of the "V" points
;	      YV - Set this to a named variable to get the y-coordinates
;                  of the "V" points
;	      XP - Set this to a named variable to get the x-coordinates
;                  of the "PSI" points
;	      YP - Set this to a named variable to get the y-coordinates
;                  of the "PSI" points
;
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Modified:
;	Created:  Fri Nov 01 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  ; Error handling.
  On_Error, 2

  ; --------------------
  ; check the input "xdat" array
  If (N_Elements(xdat) EQ 0) Then Message, "Must pass the <xdat> argument."
  If (Where([7, 8, 10, 11] EQ Size(xdat, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <xdat>."
  If (Size(xdat, /N_DIMENSIONS) NE 2) Then $
    Message, "<xdat> must be a 2D array of values."

  dims   = Size(xdat, /DIMENSIONS)
  IPNTS  = Long(dims[0])
  JPNTS  = Long(dims[1])

  ; --------------------
  ; check the input "ydat" array
  If (N_Elements(ydat) EQ 0) Then Message, "Must pass the <ydat> argument."
  If (Where([7, 8, 10, 11] EQ Size(ydat, /TYPE)) GE 0) Then $
    Message, "Strings, structures, ... are not valid values for <ydat>."
  If (Size(ydat, /N_DIMENSIONS) NE 2) Then $
    Message, "<ydat> must be a 2D array of values."

  dims = Size(ydat, /DIMENSIONS)
  If (dims[0] NE IPNTS) AND (dims[1] NE JPNTS) Then $
    Message, "<xdat, ydat> have inconsistent horizontal dimensions."


  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ; START THE CALCULATIONS
  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  x_rho = xdat
  y_rho = ydat
  area_rho = x_rho & area_rho[*] = 0

  ; ----- U-POINTS
  x_u = Rho2UVP_Points(x_rho, /ULOC)
  y_u = Rho2UVP_Points(y_rho, /ULOC)

  ; ----- V-POINTS
  x_v = Rho2UVP_Points(x_rho, /VLOC)
  y_v = Rho2UVP_Points(y_rho, /VLOC)

  ; ----- PSI-POINTS
  x_psi = Rho2UVP_Points(x_rho, /PLOC)
  y_psi = Rho2UVP_Points(y_rho, /PLOC)

  ; ----- CELL AREAS AT RHO POINTS
  ; counterclock-wise direction
  dir_u   = [ [-1, 0], [0, 0] ]
  dir_v   = [ [0, -1], [0, 0] ]
  dir_psi = [ [-1, -1], [0, -1], [0, 0], [-1, 0] ]
  for j = 0L, JPNTS - 1 do begin
    for i = 0L, IPNTS - 1 do begin
      xx = -1.0D
      yy = -1.0D

      ; U-locations
      xIDX = transpose(dir_u[0, *] + i)
      yIDX = transpose(dir_u[1, *] + j)
      idx = where( (xIDX ge 0) and (xIDX le (IPNTS - 2)) and $
                   (yIDX ge 0) and (yIDX le (JPNTS - 1)), icnt )
      if (icnt ne 0) then begin
        xIDX = xIDX[idx]
        yIDX = yIDX[idx]
        xx = [ xx, x_u[xIDX, yIDX] ]
        yy = [ yy, y_u[xIDX, yIDX] ]
      endif

      ; V-locations
      xIDX = transpose(dir_v[0, *] + i)
      yIDX = transpose(dir_v[1, *] + j)
      idx = where( (xIDX ge 0) and (xIDX le (IPNTS - 1)) and $
                   (yIDX ge 0) and (yIDX le (JPNTS - 2)), icnt )
      if (icnt ne 0) then begin
        xIDX = xIDX[idx]
        yIDX = yIDX[idx]
        xx = [ xx, x_v[xIDX, yIDX] ]
        yy = [ yy, y_v[xIDX, yIDX] ]
      endif

      ; PSI-locations
      xIDX = transpose(dir_psi[0, *] + i)
      yIDX = transpose(dir_psi[1, *] + j)
      idx = where( (xIDX ge 0) and (xIDX le (IPNTS - 2)) and $
                   (yIDX ge 0) and (yIDX le (JPNTS - 2)), icnt )
      if (icnt ne 0) then begin
        xIDX = xIDX[idx]
        yIDX = yIDX[idx]
        xx = [ xx, x_psi[xIDX, yIDX] ]
        yy = [ yy, y_psi[xIDX, yIDX] ]
      endif

      if (n_elements(xx) ge 4) then begin
        xx = xx[1:*]
        yy = yy[1:*]

        xy = VL_SortVert(xx, yy)
        xx = transpose(xy[0, *])
        yy = transpose(xy[1, *])

        object = Obj_New('IDLanROI', [xx, xx[0]], [yy, yy[0]])
          inPNT = object->ContainsPoints(x_rho[i, j], y_rho[i, j])
          if (inPNT ne 1) then begin
            xx = [xx, x_rho[i, j]]
            yy = [yy, y_rho[i, j]]
          endif
        obj_destroy, object

        area_rho[i, j] = abs( VL_ShapeArea(xx, yy) )
      endif
    endfor
  endfor

  return, area_rho

end
