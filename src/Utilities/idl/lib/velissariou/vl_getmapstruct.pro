FUNCTION VL_GetMapStruct, projection,                          $
                          DATUM = datum,                       $
                          ELLIPSOID = ellipsoid,               $
                          CENTER_LATITUDE  = center_latitude,  $
                          CENTER_LONGITUDE = center_longitude, $
                          SEMIMAJOR_AXIS = semimajor_axis,     $
                          SEMIMINOR_AXIS = semiminor_axis,     $
                          SPHERE_RADIUS = sphere_radius,       $
                          EASTING = easting,                   $
                          NORTHING = northing,                 $
                          RADIANS = radians,                   $
                          LIMIT = limit,                       $
                          ZONE = zone,                         $
                          _EXTRA = _extra
                   
;+++
; NAME:
;	VL_GETMAPSTRUCT
; VERSION:
;	1.0
; PURPOSE:
;       Provides a way to get a map projection structure using only GCTP map 
;       projections normally accessed via Map_Proj_Init. This program
;       is basically a wrapper for Map_Proj_Init. Portions of the code
;       have been borrowed from cgmap__define.pro of the Coyote library.
;         
; CALLING SEQUENCE:
;	VL_GetMapStruct(projection , [other options]
;	On input:
;     projection - The projection name (default is Mercator)
;	On output:
;      mapSTRUCT - The map structure
; SIDE EFFECTS:
;	As far as I know none.
; MODIFICATION HISTORY:
;	Created Oct 22 2013 by Panagiotis Velissariou (pvelissariou@fsu.edu).
;+++

  Compile_Opt IDL2

  ; Error handling.
  on_error, 2

  ; set a default map projection if it is not supplied
  thisPROJ = (n_elements(projection) eq 0) ? 'Mercator' : projection[0]
  chk_thisPROJ = strcompress(strupcase(thisPROJ), /REMOVE_ALL)

  ; set default values for "center_longitude/center_latitude" if they are not supplied
  thisCLON = (n_elements(center_longitude) eq 0) ? 0.0D : center_longitude
  thisCLAT = (n_elements(center_latitude)  eq 0) ? 0.0D : center_latitude

  ; set default values for "semimajor_axis/semiminor_axis" if they are not supplied
  ; defaults are the "GRS 1980/WGS 84" ellipsoid values
  if n_elements(sphere_radius) ne 0 then begin
     thisSEMiMAJ = sphere_radius[0]
     thisSEMiMIN = sphere_radius[0]
  endif
  thisSEMIMAJ = (n_elements(semiminor_axis) eq 0) ? 6378137.0D     : semimajor_axis
  thisSEMIMIN = (n_elements(semiminor_axis) eq 0) ? 6356752.31414D : semiminor_axis

  ; check of supplied values for "datum/ellipsoid"
  if (n_elements(datum) ne 0)     then thisDATUM = datum
  if (n_elements(ellipsoid) ne 0) then thisDATUM = ellipsoid
  if (n_elements(thisDATUM) eq 0) then thisDATUM = 'GRS 1980/WGS 84'

  ; remaining arguments
  if (n_elements(zone) ne 0)  then thisZONE = zone
  if (n_elements(limit) ne 0) then thisLIM = limit
  radians = (keyword_set(radians) eq 1) ? 1 : 0

  ; center latitudes are not allowed in some projections. here are the ones where
  ; they are prohibited.
  centerLATOK = 1
  centerLONOK = 1
  BadProjLATSTR = ['GOODES HOMOLOSINE', 'STATE PLANE', 'MERCATOR', 'SINUSOIDAL', 'EQUIRECTANGULAR', $
     'MILLER CYLINDRICAL', 'ROBINSON', 'SPACE OBLIQUE MERCATOR A', 'SPACE OBLIQUE MERCATOR B', $
     'ALASKA CONFORMAL', 'INTERRUPTED GOODE', 'MOLLWEIDE', 'INTERRUPED MOLLWEIDE', 'HAMMER', $
     'WAGNER IV', 'WAGNER VII', 'INTEGERIZED SINUSOIDAL']
  chk_BadProjLATSTR = strcompress(strupcase(BadProjLATSTR), /REMOVE_ALL)
  void = where(chk_BadProjLATSTR eq chk_thisPROJ, count)
  if (count gt 0) then centerLATOK = 0

  BadProjLONSTR = ['HOTINE OBLIQUE MERCATOR A','HOTINE OBLIQUE MERCATOR B']
  chk_BadProjLONSTR = strcompress(strupcase(BadProjLONSTR), /REMOVE_ALL)
  void = where(chk_BadProjLONSTR eq chk_thisPROJ, count)
  if (count gt 0) then centerLONOK = 0

  ; find if the projection uses only the Sphere datum.
  sphereOnly = 1
  ElipsProjs = ['UTM', 'STATE PLANE', 'ALBERS EQUAL AREA', 'LAMBERT CONFORMAL CONIC',                        $
                 'MERCATOR',  'POLAR STEREOGRAPHIC', 'POLYCONIC', 'EQUIDISTANT CONIC A',                     $
                 'TRANSVERSE MERCATOR', 'STEREOGRAPHIC', 'LAMBERT AZIMUTHAL', 'AZIMUTHAL',                   $
                 'GNOMONIC', 'ORTHOGRAPHIC', 'NEAR SIDE PERSPECTIVE', 'SINUSOIDAL'          ,                $
                 'EQUIRECTANGULAR', 'MILLER CYLINDRICAL', 'VAN DER GRINTEN', 'HOTINE OBLIQUE MERCATOR A',    $
                 'ROBINSON', 'SPACE OBLIQUE MERCATOR A', 'ALASKA CONFORMAL', 'INTERRUPTED GOODE',            $
                 'MOLLWEIDE', 'INTERRUPTED MOLLWEIDE', 'HAMMER', 'WAGNER IV',                                $
                 'WAGNER VII', 'INTEGERIZED SINUSOIDAL', 'EQUIDISTANT CONIC B', 'HOTINE OBLIQUE MERCATOR B', $
                 'SPACE OBLIQUE MERCATOR B']
  if float(!version.release) ge 8.0 then begin
    ElipsProjs = [ElipsProjs, 'Cylindrical Equal Area', 'Lambert Azimuthal']
  endif
  chk_ElipsProjs = strcompress(strupcase(ElipsProjs), /REMOVE_ALL)
  void = where(chk_ElipsProjs eq chk_thisPROJ, count)
  if (count gt 0) then sphereOnly = 0
  
  ; UTM and State Plane projections have to be handled differently.
  if (chk_thisPROJ eq 'UTM') or (chk_thisPROJ eq 'STATEPLANE') then begin
    case strupcase(thisPROJ) of
      'UTM': $
        begin
          if n_elements(zone) ne 0 then begin
              undefine, thisCLON, thisCLAT
          endif
          mapSTRUCT = map_proj_init(thisPROJ, $DATUM = thisDATUM, /GCTP, $
                                    CENTER_LATITUDE = thisCLAT,  $
                                    CENTER_LONGITUDE = thisCLON, $
                                    LIMIT = limit, RADIANS = radians, ZONE = zone)
        end
      'STATEPLANE': $
        begin
          mapSTRUCT = map_proj_init(thisPROJ, DATUM = thisDATUM, /GCTP, $
                                    LIMIT = limit, RADIANS = radians, ZONE = zone)
        end
      endcase
  endif else begin
    case 1 of
      centerLATOK && centerLONOK && sphereOnly: $
        begin
          mapSTRUCT = Map_Proj_Init(thisPROJ, /GCTP, $
                                    CENTER_LATITUDE  = thisCLAT, $
                                    CENTER_LONGITUDE = thisCLON, $
                                    SPHERE_RADIUS = thisSEMIMAJ, $
                                    LIMIT = limit, RADIANS = radians, $
                                    _EXTRA = _extra, $
                                    FALSE_NORTHING = northing, FALSE_EASTING = easting)
        end
      ~centerLATOK && centerLONOK && sphereOnly: $
        begin
          mapSTRUCT = Map_Proj_Init(thisPROJ, /GCTP, $
                                    CENTER_LONGITUDE = thisCLON, $
                                    SPHERE_RADIUS = thisSEMIMAJ, $
                                    LIMIT = limit, RADIANS = radians, $
                                    _EXTRA = _extra, $
                                    FALSE_NORTHING = northing, FALSE_EASTING = easting)
        end
      ~centerLATOK && centerLONOK && ~sphereOnly: $
        begin
          mapSTRUCT = Map_Proj_Init(thisPROJ, /GCTP, $
                                    CENTER_LONGITUDE = thisCLON, $
                                    SEMIMAJOR_AXIS = thisSEMIMAJ, $
                                    SEMIMINOR_AXIS = thisSEMIMIN, $
                                    LIMIT = limit, RADIANS = radians, $
                                    _EXTRA = _extra, $
                                    FALSE_NORTHING = northing, FALSE_EASTING = easting)
        end
      centerLATOK && centerLONOK && ~sphereOnly: $
        begin
          mapSTRUCT = Map_Proj_Init(thisPROJ, /GCTP, $
                                    CENTER_LATITUDE  = thisCLAT, $
                                    CENTER_LONGITUDE = thisCLON, $
                                    SEMIMAJOR_AXIS = thisSEMIMAJ, $
                                    SEMIMINOR_AXIS = thisSEMIMIN, $
                                    LIMIT = limit, RADIANS = radians, $
                                    _EXTRA = _extra, $
                                    FALSE_NORTHING = northing, FALSE_EASTING = easting)
        end
      centerLATOK && ~centerLONOK && ~sphereOnly: $
        begin
          mapSTRUCT = Map_Proj_Init(thisPROJ, /GCTP, $
                                    CENTER_LATITUDE  = thisCLAT, $
                                    SEMIMAJOR_AXIS = thisSEMIMAJ, $
                                    SEMIMINOR_AXIS = thisSEMIMIN, $
                                    LIMIT = limit, RADIANS = radians, $
                                    _EXTRA = _extra, $
                                    FALSE_NORTHING = northing, FALSE_EASTING = easting)
        end
    endcase
  endelse

  return, mapSTRUCT

end
