Function Get_GomGshhs, Resol, FileName, Gshhs_Level = level, Gshhs_Area = area
;+++
; NAME:
;	Get_GomGshhs
; VERSION:
;	1.0
; PURPOSE:
;	To get the full path to the gshhs filename and obtain relevant
;       parameters to the GoM grid.
; CALLING SEQUENCE:
;	gshhs_name = Get_GomGshhs(name, [[Level = level], [Area = area]])
;	On input:
;	   Resol - The resolution desired for the GoM grid
;	FileName - The gshhs filename, e.g "gshhs_h.b"
;          Level - The polygon LEVEL. All polygons less than or equal to this value
;                  are considered. 1-land, 2-lakes, 3-island in lake, 4-pond in island.
;                  By default, 2 (land and lake outlines).
;           Area - The minimum feature area. By default, 500 km^2.
;	On output:
;	 Level - This is a named variable
;	  Area - This is a named variable
;
; RETURNS
;       The full filepath of the gshhs filename defined by "name"
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created April 22 2011 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  On_Error, 2

  ; check for a correct string "filename"
  If N_Elements(filename) EQ 0 Then Begin
    filename = 'gshhs_h.b' ; high resolution shoreline
  EndIf Else Begin
    If (Size(filename, /TNAME) ne 'STRING') Then Begin
      Message, "the name supplied for <filename> is not a valid string."
    EndIf Else Begin
      filename = StrCompress(filename, /REMOVE_ALL)
      If (filename eq '') Then $
      Message, "the name supplied for <filename> is an empty string."
    EndElse
  EndElse

  ; check for a correct number "resol"
  If ((Where([2, 3, 4, 5, 12, 13, 14, 15] eq Size(resol, /TYPE)))[0] lt 0) Then Begin
    Message, "the value supplied for <resol> is not a number."
  EndIf

;  struct GSHHS {  /* Global Self-consistent Hierarchical High-resolution Shorelines */
;          int id;         /* Unique polygon id number, starting at 0 */
;          int n;          /* Number of points in this polygon */
;          int flag;       /* = level + version << 8 + greenwich << 16 + source << 24 + river << 25 + p << 26 */
;          /* flag contains 6 items, as follows:
;           * low byte:    level = flag & 255: Values: 1 land, 2 lake, 3 island_in_lake, 4 pond_in_island_in_lake
;           * 2nd byte:    version = (flag >> 8) & 255: Values: Should be 9 for GSHHS release 9
;           * 3rd byte:    greenwich = (flag >> 16) & 3: Values: 0 if Greenwich nor Dateline are crossed,
;           *              1 if Greenwich is crossed, 2 if Dateline is crossed, 3 if both is crossed.
;           * 4th byte:    source = (flag >> 24) & 1: Values: 0 = CIA WDBII, 1 = WVS
;           * 4th byte:    river = (flag >> 25) & 1: Values: 0 = not set, 1 = river-lake and GSHHS level = 2 (or WDBII class 0)
;           * 4th byte:    area magnitude scale p (as in 10^p) = flag >> 26.  We divide area by 10^p.
;           */
;          int west, east, south, north;   /* min/max extent in micro-degrees */
;          int area;       /* Area of polygon in km^2 * 10^p for this resolution file */
;          int area_full;  /* Area of corresponding full-resolution polygon in km^2 * 10^p */
;          int container;  /* Id of container polygon that encloses this polygon (-1 if none) */
;          int ancestor;   /* Id of ancestor polygon in the full resolution set that was the source of this polygon (-1 if none) */
;  };

  ; The polygon level as defined in the GSHHS database
  level = 4

  ; Area is the minimum area below which the shoreline features
  ; are not considered. For this, the minimum allowed shoreline
  ; resolution factor is f = 0.04 (corresponding to a 40m shoreline resolution)
  ; and the maximum allowed resolution factor is 1.0 (corresponding to a 1000m
  ; shoreline resolution).
  ; a1 is the standard area based on the 1000m resolution.
  a1 = 0.9 ; km^2, 90% of 1km x 1km = 1.0km^2
  f  = ( 0.04 > Float(resol / 1000.0) < 1.0 )
  area = f * f * a1

  ; get the gshhs file - needed
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
      get_file = Find_Resource_File(filename, SUCCESS = success)
    EndElse
    If success Then Begin
      gshhs_file = get_file
    EndIf Else Begin
      Message, 'Cannot locate the file: ' + filename
      gshhs_file = ""
    EndElse
  EndIf Else Begin
    ; Is this a fully-qualified path to the file?
    If StrUpCase(gshhs_file) EQ StrUpCase(File_Basename(gshhs_file)) Then Begin
      CD, CURRENT = thisDir
      gshhs_file = Filepath(ROOT_DIR = thisDir, gshhs_file)
    EndIf
  EndElse

  Return, gshhs_file
End
