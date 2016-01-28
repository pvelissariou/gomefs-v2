Pro ReadGrid, fname
;+++
; NAME:
;	ReadGrid
; VERSION:
;	1.0
; PURPOSE:
;	To read a bathymetric grid data file and return grid parameters
;       and depths.
; CALLING SEQUENCE:
;	ReadGrid, fname
;	On input:
;	   fname - Full pathway name of bathymetric data file
;	On output:
;	   lname - Lake name (from bathymetric data file)
;	   dgrid - Depth grid
;	   iparm - Integer parameters for grid description and
;                  coordinate conversion
;	   rparm - Real parameters for grid description and
;                  coordinate conversion
; FORMAT OF BATHYMETRIC DATA FILE:
;                 FIELD                            FORTRAN FORMAT  COLUMNS
;       ------------------------------------------------------------------
;       RECORD 1: LAKE NAME                            40A1          1-40
;       RECORD 2: FIRST (I) DIMENSION OF DEPTH ARRAY   I5            1-5
;                 SECOND (J) DIMENSION OF DEPTH ARRAY  I5            6-10
;                 BASE LATITUDE                        F12.7        11-22
;                 BASE LONGITUDE                       F12.7        23-34
;                 GRID SIZE                            F5.0         35-39
;                 MAXIMUM DEPTH                        F5.0         40-44
;                 MINIMUM DEPTH                        F5.0         45-49
;                 BASE ROTATION (CCW FROM E-W)         F6.2         50-55
;                 I DISPLACEMENT                       I5           56-60
;                 J DISPLACEMENT                       I5           61-65
;                 ROTATION FROM BASE (CCW)             F6.2         66-71
;                 POWER OF TEN TO CONVERT DEPTHS TO 
;                                       METERS         I3           72-74
;                 MAP PROJECTION INDICATOR
;                  0=APPROXIMATE POLYCONIC
;                  1=LAMBERT CONFORMAL CONIC           I2           75-76
;       RECORDS 3-6 (FOR APPROXIMATE POLYCONIC PROJECTION):
;                 MAP PROJECTION COORDINATE CONVERSION
;                  COEFFICIENTS                       4E15.6         1-60
;       RECORD 3 (FOR LAMBERT CONFORMAL CONIC PROJECTION):
;                 CENTRAL MERIDIAN OF PROJECTION       E15.6         1-15
;                 SOUTHERNMOST STANDARD PARALLEL       E15.6        16-30
;                 NORTHERNMOST STANDARD PARALLEL       E15.6        31-45
;       FOLLOWING RECORDS:
;                 DEPTHS IN ASCENDING I, ASCENDING J
;                  SEQUENCE, 19 TO A RECORD           19F4.0         1-76
;       ------------------------------------------------------------------
;
; ON OUTPUT:
;                     D - DEPTH ARRAY. ZERO FOR LAND, AVERAGE DEPTH
;                         OF GRID BOX IN METERS FOR WATER.
;                     RPARM - ARRAY CONTAINING REAL-VALUED BATHYMETRIC
;                            GRID PARAMETERS AS FOLLOWS:
;                        1.  BASE LATITUDE
;                        2.  BASE LONGITUDE
;                        3.  GRID SIZE (M)
;                        4.  MAXIMUM DEPTH (M)
;                        5.  MINIMUM DEPTH (M)
;                        6.  BASE ROTATION (COUNTERCLOCKWISE FROM E-W)
;                        7.  ROTATION FROM BASE (COUNTERCLOCKWISE)
;
;                      FOR IPARM(45)=0 (APPROXIMATE POLYCONIC PROJECTION):
;                        8-11. GEOGRAPHIC-TO-MAP COORDINATE CONVERSION
;                             COEFFICIENTS FOR X
;                        12-15.  GEOGRAPHIC-TO-MAP COORDINATE CONVERSION
;                                COEFFICIENTS FOR Y
;                        16-19.  MAP-TO-GEOGRAPHIC COORDINATE CONVERSION
;                                COEFFICIENTS FOR LONGITUDE
;                        20-23.  MAP-TO-GEOGRAPHIC COORDINATE CONVERSION
;                                COEFFICIENTS FOR LATITUDE
;
;                      FOR IPARM(45)=1 (LAMBERT CONFORMAL CONIC PROJECTION):
;                        8.  CENTRAL MERIDIAN OF PROJECTION (RADIANS)
;                        9.  SOUTHERNMOST STANDARD PARALLEL (RADIANS)
;                        10. NORTHERNMOST STANDARD PARALLEL (RADIANS)
;                        11. LOGARITHMIC COEFFICIENT FOR TRANSFORMATIONS
;                        12. DISTANCE SCALING FACTOR FOR TRANSFORMATIONS
;                        13. X DISPLACEMENT OF BATHYMETRIC GRID ORIGIN
;                             FROM MAP PROJECTION ORIGIN
;                        14. Y DISPLACEMENT OF BATHYMETRIC GRID ORIGIN
;                             FROM MAP PROJECTION ORIGIN
;
;                    IPARM - ARRAY CONTAINING INTEGER-VALUED BATHYMETRIC
;                            GRID PARAMETERS AS FOLLOWS:
;                        1.  NUMBER OF GRID BOXES IN X DIRECTION
;                        2.  NUMBER OF GRID BOXES IN Y DIRECION
;                        3.  I DISPLACEMENT - THE NUMBER OF NEW GRID
;                            SQUARES IN THE X-DIRECTION FROM THE NEW
;                            GRID ORIGIN TO THE OLD GRID ORIGIN
;                            (USED ONLY FOR IPARM(45)=0)
;                        4.  J DISPLACEMENT - THE NUMBER OF NEW GRID
;                            SQUARES IN THE Y-DIRECTION FROM THE NEW
;                            GRID ORIGIN TO THE OLD GRID ORIGIN
;                            (USED ONLY FOR IPARM(45)=0)
;                        5. MAP PROJECTION USED FOR BATHYMETRIC GRID:
;                            0=APPROXIMATE POLYCONIC (GREAT LAKES GRIDS)
;                            1=LAMBERT CONFORMAL CONIC
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created June 10 2003 by Panagiotis Velissariou (velissariou.1@osu.edu).
;+++

Compile_Opt IDL2

on_error, 2

if (n_elements(fname) eq 0) then $
  message, "you need to supply a valid name for <fname>"

if (size(fname, /TNAME ) ne 'STRING') then $
  message, "the name supplied for <" + fname + "> is not a valid string."

fname = strtrim(fname, 2)

if (not file_test( fname, /READ)) then $
  message, "can't open the supplied file <" + fname + "> for reading."

COMMON BathParams

rparm = Dblarr(23)
iparm = intarr(5)
lname = ' '

openr, 3, fname

readf, 3, lname

iarr1 = intarr(2)
iarr2 = intarr(2)
rarr1 = Dblarr(6)

on_ioerror, next
readf, 3, iarr1, rarr1, iarr2, r1, idexp, iproj, $
          format = '(2I5, 2F12.7, 3F5.0, F6.2, 2I5, F6.2, I3, I2)'
goto, next1
next: iarr2 = [0, 0]
r1    = 0.0
idexp = 0
iproj = 0
next1: on_ioerror, null

iparm[0:1] = iarr1
rparm[0:5] = rarr1
iparm[2:3] = iarr2
iparm[4]   = iproj
rparm[6]   = r1

if(iproj eq 0) then begin
  rarr1 = Dblarr(16)
  readf, 3, rarr1, format = '(4E15.6)'
  rparm[7:22] = rarr1
endif

if(iproj eq 1) then begin
  rarr1 = Dblarr(3)
  readf, 3, rarr1, format = '(3E15.6)'
  rparm[7:9] = rarr1
endif

IPNTS   = long(iparm[0])
JPNTS   = long(iparm[1])
TCELLS  = IPNTS * JPNTS
GridXSZ = rparm[2] ; in meters
GridYSZ = rparm[2] ; in meters
GridX0 = 0.5D * GridXSZ
GridY0 = 0.5D * GridYSZ

; read the depths
dgrid = Dblarr(IPNTS, JPNTS)
;  readf, 3, dgrid, format = '(15F8.4)'
readf, 3, dgrid
close, 3

; determine the total number of the "wet" cell points
WCELLSIDX = where(dgrid gt 0.0, WCELLS)

; determine the total number of the "land" cell points
LCELLSIDX = where(dgrid le 0.0, LCELLS)

; adjust the depths
dfac     = 10.0^(idexp)
rparm[4] = rparm[4] * dfac
rparm[5] = rparm[5] * dfac
dgrid    = dgrid * dfac

; for lambert projection compute the required constants
if(iparm[4] eq 1) then begin
  a45 = atan(1.0)
  rparm[7] = rparm[7] * !DTOR
  rparm[8] = rparm[8] * !DTOR
  rparm[9] = rparm[9] * !DTOR

  a1 = rparm[8]
  a2 = rparm[9]
  rparm[10] = ( alog(cos(a1))-alog(cos(a2)) ) / $
              ( alog(tan(a45 - a1/2.0))-alog(tan(a45 - a2/2.0)) )
; set scale factor for n-s distance from a1 to a2
  aexp      = rparm[10]
  y1        = (tan(a45 - a1/2.0))^(aexp)
  y2        = (tan(a45-a2/2.))^(aexp)
  rparm[11] = 6378140.0 * ((a2 - a1)/(y1 - y2))
  rparm[12] = 0.0
  rparm[13] = 0.0
  dx        = xdist(rparm[0], rparm[1])
  dy        = ydist(rparm[0], rparm[1])
  rparm[12] = dx
  rparm[13] = dy
endif

; determine the latitude/longitude of the cell points
xgrid = Dblarr(IPNTS, JPNTS)
ygrid = xgrid
latgrid = xgrid
longrid = xgrid
for j = 0L, JPNTS - 1 do begin
  for i = 0L, IPNTS - 1 do begin
    xx  = GridX0 + i * GridXSZ
    yy  = GridY0 + j * GridYSZ
    latgrid[i, j] = rlat(xx, yy)
    longrid[i, j] = -rlon(xx, yy)
    xgrid[i, j] = xx
    ygrid[i, j] = yy
  endfor
endfor

return

end
