FUNCTION DistFromLine, x0, y0, x1, y1, xloc, yloc
;+++
; NAME:
;	DistFromLine
; VERSION:
;	1.0
; PURPOSE:
;	To find all the distances of  points (xloc, yloc)
;       from the line defined by the two points (x0,y0) and (x1,y1)
; CALLING SEQUENCE:
;	distpnts = DistFromLine(x0, y0, x1, y1, xloc, yloc)
;	On input:
; [x0, y0, x1, y1] - The (x, y) coordinates of the two points that
;                    define the line
;             xloc - The 1D vector of the x-coorinates
;             yloc - The 1D vector of the y-coorinates
;	On output:
;	distpnts - The distances of the points from the line
;                  defined by the two points (x0,y0) and (x1,y1)
;                  (1D vector)
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created Sun Nov 17 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt Hidden, IDL2

  ; Error handling.
  On_Error, 2

  tol = 0.0001d

  if ( array_equal(size(xloc), size(yloc), /NO_TYPECONV) ne 1) then begin
    message, 'incompatible array sizes found for [xloc, yloc]'
  endif

  if (size(xloc, /N_DIMENSIONS) ne 1) then begin
    message, '2D arrays are required for [xloc, yloc]'
  endif

  ; check for the orientation of the desired line
  vertical   = (abs(x1 - x0) le tol) ? 1 : 0
  horizontal = (abs(y1 - y0) le tol) ? 1 : 0
  inclined   = ((vertical + horizontal) eq 0) ? 1 : 0
  if ((vertical + horizontal) eq 2) then begin
    message, '[x0, y0, x1, y1] defines just a point'
  endif

  ; ----- The line is vertical
  if (vertical eq 1) then begin
    dy = y1 - y0
    dx = x1 - x0

    A  =  dy
    B  = 0.0D
    C  = - dy * x0
    AB = sqrt(A * A + B * B)
  endif

  ; ----- The line is horizontal
  if (horizontal eq 1) then begin
    dy = y1 - y0
    dx = x1 - x0

    A  =  0.0D
    B  = -dx
    C  = dx * y0
    AB = sqrt(A * A + B * B)
  endif

  ; ----- The line is inclined
  if (inclined eq 1) then begin
    dy = y1 - y0
    dx = x1 - x0
    slope = dy / dx
    inter = y0 - slope * x0

    A  =  dy
    B  = -dx
    C  = inter * dx
    AB = sqrt(A * A + B * B)
  endif

  ; get the distances of all points from the line defined by the points
  ; (x0, y0) and (x1, y1)
  npnts = n_elements(xloc)
  distpnts = make_array(npnts, /DOUBLE, VALUE = 0)

  for i = 0L, npnts - 1 do begin
    F = A * xloc[i] + B * yloc[i] + C
    distpnts[i] = F / AB
  endfor

  return, ZeroFloatFix( distpnts )
end

;+
; NAME:
;      GET_GSHHS_SEGMENTS
;
; PURPOSE:
;
;      Uses files from the Globally Self-consistent Hierarchical High-resolution Shoreline
;      (GSHHS) data base to extract the polygons defining shorelines.
;      The GSHHS data files can be downloaded from this
;      location:
;
;         http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
;
;      Note, the authors of the GSHHS software *continually* change the header
;      structure, which you MUST know to read the data file. There are are now
;      at least four different structures in common use. Please find the one
;      you need from the commented list below. The current code uses the structure
;      for the 2.0 version of the GSHHS software.
;
; AUTHOR:
;
;      Panagiotis Velissariou, Ph.D, P.E.
;      E-mail: pvelissariou@coaps.fsu.edu
;      Based on Coyote's Library programs: http://www.dfanning.com
;
; CATEGORY:

;      Mapping Utilities
;
; CALLING SEQUENCE:
;
;      my_data = Get_Gshhs_Segments(filename [, OPT_PARAMETER = VALUE])
;
; ARGUMENTS:
;      filename:  The name of the GSHHS input file.
;                 If not supplied defaults to: 'gshhs_f.b', full resolution shorelines
;
; KEYWORDS:
;      LEVEL:     The polygon LEVEL. All polygons less than or equal to this value are considered
;                 1-land, 2-lakes, 3-island in lake, 4-pond in island
;                 Usage: LEVEL = 2
;                 Default: 4 (land and lake outlines)
;      MINAREA:   The minimum feature area.
;                 Usage: MINAREA = 100
;                 Default: 500 km^2
;      GEOREGION: The geographical region (rectangle) where the analysis takes place
;                 Usage: GEOREGION = [minLAT, minLON, maxLAT, maxLON]
;                 Default: None
;
; RETURNS:
;    DATA_STRUCT: The data structure that contains the polygons of each feature
;                 {count:-1L, id:-1L, ibeg:-1L, iend:-1L, lon:0.0D, lat:0.0D}
;                 count = total number of polygons found in the data file
;                 id    = the polygon level (see the LEVEL parameter above)
;                 river = values: 0 = not set, 1 = river-lake and level = 2
;                 ibeg  = begin index in the lat/lon vectors of the polygon
;                 iend  = end index in the lat/lon vectors of the polygon
;                 lon   = vector of longitudes of the polygon vertices
;                         range: -180.0 to 180.0
;                 lat   = vector of latitudes of the polygon vertices
;                         range: -90.0 to 90.0
;
; RESTRICTIONS:
;     Requires the following programs from the Coyote Library:
;
;         http://www.dfanning.com/programs/find_resource_file.pro
;         http://www.dfanning.com/programs/undefine.pro
;
; EXAMPLE:
;         datafile = 'gshhs_h.b'
;         my_data = Get_Gshhs_Segments(datafile, Level=3)
;
;
; MODIFICATION HISTORY:
;     Written by Panagiotis Velissariou, 29 April 2011.
;     Based on the program by David W. Fanning map_gshhs_shoreline.
;
FUNCTION Get_GSHHS_Segments, filename,          $
                             LEVEL = level,     $                 
                             MINAREA = minarea, $
                             GEOREGION = georegion

   On_Error, 2

   ; ----- Get optional parameters and default values.
   If N_Elements(filename) EQ 0 Then filename = 'gshhs_f.b' ; full resolution shoreline
   ; In case something goes wrong.
   gshhs_file = filename
   ; Can the file be located?
   found = File_Test(filename, /READ)
   ; If you can't find it, do a search in resource directories for it.
   If ~found Then Begin
    loc_idl = StrCompress(GetEnv('LOCAL_IDL_DIR'), /REMOVE_ALL)
    If (loc_idl NE "") Then Begin
      success = 0
      directories = Expand_Path('+' + loc_idl, /ARRAY, /ALL_DIRS)
      For j = 0L, N_Elements(directories) - 1 Do Begin
        get_file = (File_Which(directories[j], filename, /INCLUDE_CURRENT_DIR))[0]
        get_file = StrCompress(get_file, /REMOVE_ALL)
        If (get_file ne "") Then Begin
          success = 1
          Break
        EndIf
      EndFor
    EndIf Else Begin
      get_file = Find_Resource_File(filename, SUCCESS=success)
    EndElse
     If success Then Begin
       gshhs_file = get_file
     EndIf Else Begin
       Message, 'Cannot locate the file: ' + filename
     EndElse
   EndIf Else Begin
     ; Is this a fully-qualified path to the file?
     If StrUpCase(gshhs_file) EQ StrUpCase(File_Basename(gshhs_file)) Then Begin
       CD, CURRENT = thisDir
       gshhs_file = Filepath(ROOT_DIR = thisDir, gshhs_file)
     EndIf
   EndElse

   If N_Elements(level) EQ 0   Then level = 4 Else level = (1 > level < 4)

   If N_Elements(minArea) EQ 0 Then minArea = 500.0 ; square kilometers.

   useGeoReg = 0
   If (N_Elements(georegion) NE 0) Then Begin
     lon = (([ georegion[1], georegion[3] ] + 180) MOD 360) - 180
     minRegLon = lon[0]
     maxRegLon = lon[1]
     minRegLon = (-180.0 > minRegLon < 180.0)
     maxRegLon = (-180.0 > maxRegLon < 180.0)
     minRegLon = Min([ minRegLon, maxRegLon ], MAX = maxRegLon)

     minRegLat = georegion[0]
     maxRegLat = georegion[2]
     minRegLat = (-90.0 > minRegLat < 90.0)
     maxRegLat = (-90.0 > maxRegLat < 90.0)
     minRegLat = Min([ minRegLat, maxRegLat ], MAX = maxRegLat)

     ; Set the WGS84 map structure
     CLON = mean( [minRegLon, maxRegLon] )
     CLAT = mean( [minRegLat, maxRegLat] )
     TLAT = CLAT
     mapSTRUCT = VL_GetMapStruct('Mercator', $
                                 CENTER_LATITUDE     = CLAT, $
                                 CENTER_LONGITUDE    = CLON, $
                                 TRUE_SCALE_LATITUDE = TLAT, $
                                 SEMIMAJOR_AXIS      = 6378137.0D, $
                                 SEMIMINOR_AXIS      = 6356752.31414D)

     useGeoReg = 1
   EndIf

   ; Open the GSHHS data file.
   OPENR, lun, gshhs_file, /Get_Lun, /Swap_If_Little_Endian

;   ; Define the polygon header. This is for versions of the GSHHS software of 1.3 and earlier.
;   header = { id: 0L, $        ; A unique polygon ID number, starting at 0.
;              npoints: 0L, $   ; The number of points in this polygon.
;              polygonLevel: 0L, $ ; 1 land, 2 lake, 3 island-in-lake, 4 pond-in-island.
;              west: 0L, $      ; West extent of polygon boundary in micro-degrees.
;              east: 0L, $      ; East extent of polygon boundary in micro-degrees.
;              south: 0L, $     ; South extent of polygon boundary in micro-degrees.
;              north: 0L, $     ; North extent of polygon boundary in micro-degrees.
;              area: 0L, $      ; The area of polygon in 1/10 km^2.
;              version: 0L, $   ; Polygon version, always set to 3 in this version.
;              greenwich: 0S, $ ; Set to 1 if Greenwich median is crossed by polygon.
;              source: 0S }     ; Database source: 0 WDB, 1 WVS.

   ; Define the polygon header, for GSHHS software 1.4 through 1.11, which uses a 40 byte
   ; header structure. For example, gshhs_i.b from the gshhs_1.10.zip file.
;   header = { id: 0L, $        ; A unique polygon ID number, starting at 0.
;              npoints: 0L, $   ; The number of points in this polygon.
;              flag: 0L, $      ; Contains polygonlevel, version, greenwich, and source values.
;              west: 0L, $      ; West extent of polygon boundary in micro-degrees.
;              east: 0L, $      ; East extent of polygon boundary in micro-degrees.
;              south: 0L, $     ; South extent of polygon boundary in micro-degrees.
;              north: 0L, $     ; North extent of polygon boundary in micro-degrees.
;              area: 0L, $      ; Database source: 0 WDB, 1 WVS.
;              junk:bytarr(8)}  ; Eight bytes of junk to pad header.     

   ; Define the polygon header, for GSHHS software 1.4 through 1.11, which uses a 32 byte
   ; header structure. For example, gshhs_h.b from the gshhs_1.11.zip.
;   header = { id: 0L, $        ; A unique polygon ID number, starting at 0.
;              npoints: 0L, $   ; The number of points in this polygon.
;              flag: 0L, $      ; Contains polygonlevel, version, greenwich, and source values.
;              west: 0L, $      ; West extent of polygon boundary in micro-degrees.
;              east: 0L, $      ; East extent of polygon boundary in micro-degrees.
;              south: 0L, $     ; South extent of polygon boundary in micro-degrees.
;              north: 0L, $     ; North extent of polygon boundary in micro-degrees.
;              area: 0L}        ; Database source: 0 WDB, 1 WVS.
              
   ; Define the polygon header, for GSHHS software 2.0, which uses a 44 byte
   ; header structure. For example, gshhs_h.b from the gshhs_2.0.zip.
;   header = { id: 0L, $        ; A unique polygon ID number, starting at 0.
;              npoints: 0L, $   ; The number of points in this polygon.
;              flag: 0L, $      ; Contains polygon level, version, greenwich, source, and river values.
;              west: 0L, $      ; West extent of polygon boundary in micro-degrees.
;              east: 0L, $      ; East extent of polygon boundary in micro-degrees.
;              south: 0L, $     ; South extent of polygon boundary in micro-degrees.
;              north: 0L, $     ; North extent of polygon boundary in micro-degrees.
;              area: 0L, $      ; Area of polygon in 1/10 km^2.
;              area_full: 0L, $ ; Area of origiinal full-resolution polygon in 1/10 km^2.
;              container: 0L, $ ; ID of container polygon that encloses this polygon (-1 if "none").
;              ancestor: 0L }   ; ID of ancestor polygon in the full resolution set that was the source
;                               ; of this polygon (-1 of "none").
;
;  I don't have a polygon header for version 2.1 of the GSHHS software but I believe the 2.0 header will
;  work. This version of GSHHS was pretty buggy and not used very long. Better to upgrade to 2.2.
;  
   ; Define the polygon header, for GSHHS software 2.2, which uses a 44 byte
   ; header structure. For example, gshhs_h.b from the gshhg_2.2.zip.
   header = { id: 0L, $        ; A unique polygon ID number, starting at 0.
              npoints: 0L, $   ; The number of points in this polygon.
              flag: 0L, $      ; Bytes defined as:
              ;    1st byte:    level = flag & 255: Values: 1 land, 2 lake, 3 island_in_lake, 4 pond_in_island_in_lake
              ;    2nd byte:    version = (flag >> 8) & 255: Values: Should be 9 for GSHHS release 9
              ;    3rd byte:    greenwich = (flag >> 16) & 3: Values: 0 if Greenwich nor Dateline are crossed,
              ;                 1 if Greenwich is crossed, 2 if Dateline is crossed, 3 if both is crossed.
              ;    4th byte:    source = (flag >> 24) & 1: Values: 0 = CIA WDBII, 1 = WVS
              ;    5th byte:    river = (flag >> 25) & 1: Values: 0 = not set, 1 = river-lake and GSHHS level = 2 (or WDBII class 0)
              ;    6th byte:    area magnitude scale p (as in 10^p) = flag >> 26.  We divide area by 10^p.
              west: 0L, $      ; West extent of polygon boundary in micro-degrees.
              east: 0L, $      ; East extent of polygon boundary in micro-degrees.
              south: 0L, $     ; South extent of polygon boundary in micro-degrees.
              north: 0L, $     ; North extent of polygon boundary in micro-degrees.
              area: 0L, $      ; Area of polygon in area/10^p = km^2.
              area_full: 0L, $ ; Area of original full-resolution polygon in area_full/10^p = km2.
              container: 0L, $ ; ID of container polygon that encloses this polygon (-1 if "none").
              ancestor: 0L }   ; ID of ancestor polygon in the full resolution set that was the source
                               ; of this polygon (-1 of "none").

   ; Read the data and output the results.
   ibeg = 0L
   iend = 0L
   tmp_id  = Make_array(1, /Long)
   tmp_riv = Make_array(1, /Long)
   tmp_beg = Make_array(1, /Long)
   tmp_end = Make_array(1, /Long)
   tmp_lon = Make_array(1, /Double)
   tmp_lat = Make_array(1, /Double)

   While (EOF(lun) NE 1) Do Begin
     READU, lun, header
   
     ; Parse the flag. Version 6 corresponds to 1.1x. Version 7 corresponds to 2.0.
     ; Version 8 corresponds to 2.1 and Version 9 corresponds to 2.2.
     f = header.flag
     version = ISHFT(f, -8) AND 255B

     IF version LT 9 THEN BEGIN
         IF version LE 3 THEN polygonLevel = header.level ELSE polygonLevel = (f AND 255B) 
         greenwich = ISHFT(f, -16) AND 1B
         source = ISHFT(f, -24) AND 1B
         river = ISHFT(f, -25) AND 1B
     ENDIF ELSE BEGIN
         polygonLevel = (f AND 255B) 
         greenwich = ISHFT(f, -16) AND 3B
         source = ISHFT(f, -24) AND 1B
         river = ISHFT(f, -25) AND 1B
         magnitude = ISHFT(f, -26) AND 255B ; Divide header.area by 10^magnitude to get true area.
     ENDELSE

     ; Get the polygon coordinates. Convert to lat/lon.
     polygon = LonArr(2, header.npoints, /NoZero)
     READU, lun, polygon
     lonParent = Reform(polygon[0,*] * 1.0e-6)
     latParent = Reform(polygon[1,*] * 1.0e-6)
     Undefine, polygon

     ; Discriminate polygons based on header information.
     IF version LT 9 THEN BEGIN
         polygonArea = Double(header.area) * 0.1 ; km^2
     ENDIF ELSE BEGIN
         polygonArea = Double(header.area) / 10.0^magnitude ; km^2
     ENDELSE

     If polygonLevel GT level Then CONTINUE
     If polygonArea LE minArea Then CONTINUE

     ; Convert lons from 0 -> 360 to -180 -> 180.
     lonParent = ((lonParent + 180) MOD 360) - 180
     lon = lonParent
     lat = latParent

     ; If requested, confine the search into the Geo Region.
     If (useGeoReg GT 0) Then Begin
       idxPolygon = where( ((lon GE minRegLon) AND (lon LE maxRegLon)) AND $
                           ((lat GE minRegLat) AND (lat LE maxRegLat)), pntsPolygon )

       If (pntsPolygon LT 3) Then CONTINUE

       lon = lon[idxPolygon]
       lat = lat[idxPolygon]

       If (pntsPolygon GT 3) Then Begin
         ; three points on the plane form a triangle or they are co-linear
         ; so we don't need to do anything here (except in the case of co-linearity)
         xy = Map_Proj_Forward(lon, lat, MAP_STRUCTURE = mapSTRUCT)
         xx = reform(xy[0, *])
         yy = reform(xy[1, *])

         x0 = xx[0]
         y0 = yy[0]
         x1 = xx[pntsPolygon - 1]
         y1 = yy[pntsPolygon - 1]

         If ( (ZeroFloatFix(Abs(x0 - x1)) NE 0) AND $
              (ZeroFloatFix(Abs(y0 - y1)) NE 0) ) Then Begin
           ; Polygon is not closed.

           disPNTS = DistFromLine(x0, y0, x1, y1, xx, yy)
           idxNEG = where(disPNTS lt 0, cntNEG)
           idxPOS = where(disPNTS gt 0, cntPOS)

           If ( (cntNEG EQ 0) OR (cntPOS EQ 0) ) Then Begin
             ; This is a convex polygon.
             lon = [ lon, lon[0] ]
             lat = [ lat, lat[0] ]
           EndIf Else Begin
             ; This is a concave polygon.
             ; If the polygon is completely contained within GeoRegion
             ; it will always be convex (according to GSHHS).
             ; The only case considered here then is when the GSHHS polygon
             ; extends outside the GeoRegion therefore, we need to define
             ; the overlap area of the GSHHS polygon.
             shp1 = [minRegLon, maxRegLon, maxRegLon, minRegLon, minRegLon]
             shp2 = [minRegLat, minRegLat, maxRegLat, maxRegLat, minRegLat]
             shp1 = [ Transpose(shp1), Transpose(shp2) ]
             shp2 = [ Transpose(lonParent), Transpose(latParent) ]
             shp  = Shape_Overlap(shp1, shp2, EXISTS = exs)
             If exs Then Begin
               lon = Transpose(shp[0, *])
               lat = Transpose(shp[1, *])
             EndIf Else Begin
               lon = lonParent
               lat = latParent
             EndElse
           EndElse
         EndIf ; ZeroFloatFix(Abs(x0 - x1))
       EndIf ; pntsPolygon GT 3
     EndIf ; useGeoReg

     ibeg = iend
     iend = iend + N_Elements(lon)

     tmp_id  = [ tmp_id,  polygonLevel ]
     tmp_riv = [ tmp_riv, river ]
     tmp_beg = [ tmp_beg, ibeg ]
     tmp_end = [ tmp_end, iend - 1 ]
     tmp_lon = [ tmp_lon, lon ]
     tmp_lat = [ tmp_lat, lat ]
   EndWhile
   Free_Lun, lun

   count = n_elements(tmp_id) - 1

   If (count GT 0) Then Begin
     tmp_id  = tmp_id[1:*]
     tmp_riv = tmp_riv[1:*]
     tmp_beg = tmp_beg[1:*]
     tmp_end = tmp_end[1:*]
     tmp_lon = tmp_lon[1:*]
     tmp_lat = tmp_lat[1:*]

     Return, {count:count, id:tmp_id, river:tmp_riv, ibeg:tmp_beg, iend:tmp_end, lon:tmp_lon, lat:tmp_lat}
   EndIf Else Begin
     Return, {count:-1L, id:-1L, river:0L, ibeg:-1L, iend:-1L, lon:0.0D, lat:0.0D}
   EndElse

END
