;+
; NAME:
;       GetCounties
;
; PURPOSE:
;
;       Gets the coordinates of the  state counties in the USA from county shape files.
;PRO GetCounties, FileName, STATES = states, COUNTIES = counties, GetRecords = getrecords
; AUTHOR:
;
;       Panagiotis Velissariou
;       E-mail: belissariou.1@osu.edu
;
; CATEGORY:

;       Utilities
;
; CALLING SEQUENCE:
;
;       GetCounties, FileName
;
; ARGUMENTS:
;
;       FileName:      The name of the input shapefile containing county boundaries.
;                      Must be defined, for example, 'co1990p020.shp'.
;
; KEYWORDS:
;
;     ATTRIBUTE_NAME:  The name of the attribute in the file that you wish to draw.
;                      By default, this is set to the attribute name "STATE".
;                      (In some shapefiles, the attribute might be named "STATE_ABBR".)
;
;     STATES:          The name(s) of the states you wish to retrieve the county
;                      boundaries. This is an 1D string vector containing the state
;                      abbreviations (e.g 'MI', 'CO', ...) or, 'ALL' which is the
;                      default.
;     COUNTIES:        The name(s) of the counties you wish to retrieve county
;                      boundaries. This is an 1D string vector containing the names
;                      of the counties or, 'ALL' which is the default.
;
;     GETRECORDS:      Use this named variable to output the 1D vector of structures
;                      containing the values of the variables defining the counties.
;                      The structure is of the form:
;                      getrecords = {stID:'', stNM:'', coFIPS:'', coNM:'', part:0L,
;                                    lat:0.0, lon:0.0}
;                      where: stID = the state abbreviation id (e.g 'MI')
;                             stNM = the state official name (e.g 'Michigan')
;                           coFIPS = the county identification code
;                             coNM = the county official name (e.g 'Keweenaw')
;                             part = the county part indices (if consists from more than one partitions)
;                             lat  = the latitude of the vertex for that county
;                             lon  = the longitude of the vertex for that county
;
; RESTRICTIONS:
;
;     Required Coyote Library programs:
;
;       Error_Message
;
; EXAMPLE:
;
;       GetCounties, 'co1990p020.shp', States=['CA', 'OR', 'WA', 'AZ', 'UT', 'ID', 'NV'], $
;          GetRecords=getrecords
;
; MODIFICATION HISTORY:
;
;       Written by Panagiotis Velissariou, March 28, 2006.
;       (the code was extracted from the drawcounties.pro found in Coyote Library and
;        expanded to its present form)
;-
;###########################################################################
FUNCTION GetEntityRec, entity, Num_Rec = num_rec

   maxREC = 10000L
   nStart = 0
   nEnd   = 0
   entityArray = dblarr(2, maxREC)
   recArray = lonarr(entity.n_parts + 2)

   ; Error handling.
   catch, theError
   if theError ne 0 then begin
     ok = error_message(/traceback)
     if obj_valid(shapefile) then obj_destroy, shapefile
     if ptr_valid(entities) then heap_free, entities
     if arg_present(num_rec) then num_rec = recArray
     return, entityArray[*, 0]
   endif

   ; drawing is going to be done based on the shape type.
   case 1 of

      ; polygon shapes.
      entity.shape_type eq 5 or $    ; polygon.
      entity.shape_type eq 15 or $   ; polygonz (ignoring z)
      entity.shape_type eq 25: begin ; polygonm (ignoring m)

      if ptr_valid(entity.parts) then begin
         nParts = entity.n_parts
         cuts = [*entity.parts, entity.n_vertices]
         for i = 0, nParts - 1 do begin
           nStart = nEnd
           nEnd = nStart + cuts[i+1] - cuts[i]
           entityArray[0, nStart:nEnd-1] = (*entity.vertices)[0, cuts[i]:cuts[i+1]-1]
           entityArray[1, nStart:nEnd-1] = (*entity.vertices)[1, cuts[i]:cuts[i+1]-1]
           recArray[i+2] = nEnd - nStart
         endfor
      endif
      endcase ; polygon shapes.

      ; polyline shapes.
      entity.shape_type eq  3 or $   ; polyline
      entity.shape_type eq 13 or $   ; polylinez (ignoring z)
      entity.shape_type eq 23: begin ; polylinem (ignoring m)

      if ptr_valid(entity.parts) then begin
         cuts = [*entity.parts, entity.n_vertices]
         for i = 0, entity.n_parts - 1 do begin
           nStart = nEnd
           nEnd = nStart + cuts[i+1] - cuts[i]
           entityArray[0, nStart:nEnd-1] = (*entity.vertices)[0, cuts[i]:cuts[i+1]-1]
           entityArray[1, nStart:nEnd-1] = (*entity.vertices)[1, cuts[i]:cuts[i+1]-1]
           recArray[i+2] = nEnd - nStart
         endfor
      endif
      endcase ; polyline shapes.

      else: ; all other shapes fall through and are silently ignored.

   endcase

   entityArray = nEnd eq 0 ? entityArray[*, 0] : entityArray[*, 0:nEnd - 1]
   recArray[0] = nEnd
   recArray[1] = entity.n_parts

   if arg_present(num_rec) then num_rec = recArray

   return, entityArray

end

;-------------------------------------------------------------------------
PRO GetCounties, FileName, STATES = states, COUNTIES = counties, GetRecords = getrecords

   ; error handling.
   catch, theError
   if theError ne 0 then begin
     ok = error_message(/traceback)
     if obj_valid(shapefile) then obj_destroy, shapefile
     if ptr_valid(entities) then heap_free, entities
     return
   endif

   maxREC = 200000L
   dataStruct = {stID:'', stNM:'', coFIPS:'', coNM:'', part:0L, lat:0.0, lon:0.0}

   stID = [ 'AL', 'AK', 'AS', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', $
            'FM', 'FL', 'GA', 'GU', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', $
            'KY', 'LA', 'ME', 'MH', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', $
            'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'MP', $
            'OH', 'OK', 'OR', 'PW', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', $
            'TX', 'UT', 'VT', 'VI', 'VA', 'WA', 'WV', 'WI', 'WY' ]

stNM = [ $
                         'Alabama',        'Alaska', 'American Samoa',          'Arizona',                  'Arkansas', $
                      'California',      'Colorado',    'Connecticut',         'Delaware',      'District of Columbia', $
  'Federated States of Micronesia',       'Florida',        'Georgia',             'Guam',                    'Hawaii', $
                           'Idaho',      'Illinois',        'Indiana',             'Iowa',                    'Kansas', $
                        'Kentucky',     'Louisiana',          'Maine', 'Marshall Islands',                  'Maryland', $
                   'Massachusetts',      'Michigan',      'Minnesota',      'Mississippi',                  'Missouri', $
                         'Montana',      'Nebraska',         'Nevada',    'New Hampshire',                'New Jersey', $
                      'New Mexico',      'New York', 'North Carolina',     'North Dakota',  'Northern Mariana Islands', $
                            'Ohio',      'Oklahoma',         'Oregon',            'Palau',              'Pennsylvania', $
                     'Puerto Rico',  'Rhode island', 'South Carolina',     'South Dakota',                 'Tennessee', $
                           'Texas',          'Utah',        'Vermont',   'Virgin Islands',                  'Virginia', $
                      'Washington', 'West Virginia',      'Wisconsin',          'Wyoming' ]

; check parameters.
   if n_elements(FileName) eq 0 then begin
      FileName = dialog_pickfile(filter='*.shp')
      if FileName eq "" then $
         message, 'the name of a county shape file must be provided.'
   endif

; check the states
   theStates = n_elements(states) eq 0 ? 'ALL' : strupcase(strtrim(states, 2))
   idx = where(theStates eq 'ALL', count)
   if (count gt 0) then theStates = 'ALL'

   tmpArr = theStates[uniq(theStates, sort(theStates))]
   if (n_elements(tmpArr) ne n_elements(theStates)) then begin
   tmp = - 1
   for i = 0, n_elements(tmpArr) - 1 do $
     tmp = [tmp, (where(theStates eq tmpArr[i]))[0]]
     tmp = tmp[1:*]
     tmp = tmp[sort(tmp)]
     theStates = theStates[tmp]
   endif

; check the counties
   theCounties = n_elements(counties) eq 0 ? 'ALL' : strupcase(strtrim(counties, 2))
   idx = where(theCounties eq 'ALL', count)
   if (count gt 0) then theCounties = 'ALL'

   tmpArr = theCounties[uniq(theCounties, sort(theCounties))]
   if (n_elements(tmpArr) ne n_elements(theCounties)) then begin
   tmp = - 1
   for i = 0, n_elements(tmpArr) - 1 do $
     tmp = [tmp, (where(theCounties eq tmpArr[i]))[0]]
     tmp = tmp[1:*]
     tmp = tmp[sort(tmp)]
     theCounties = theCounties[tmp]
   endif

; open the shape file and create the shape object.
   shapefile = obj_new('IDLffShape', FileName)
   if obj_valid(shapefile) eq 0 then $
      message, 'unable to create shape file object. returning...'

; get the attribute names from the shape file.
   shapefile -> getproperty, attribute_names = theNames
   theNames = strupcase(strtrim(theNames, 2))

; find the state attribute index.
   stateIndex = where(theNames eq 'STATE', count)
   if (count eq 0) then message, 'unable to find attribute state in file. returning...'

; find the county attribute index.
   countyIndex = where(theNames eq 'COUNTY', count)
   if (count eq 0) then message, 'unable to find attribute county in file. returning...'

; find the fips attribute index.
   fipsIndex = where(theNames eq 'FIPS', count)
   if (count eq 0) then message, 'unable to find attribute fips in file. returning...'

; get all the attribute pointers from the file. these are the entities.
   entities = ptr_new(/allocate_heap)
   *entities = shapefile -> getentity(/all, /attributes)

; cycle through each entity.
   nStart = 0L
   nEnd   = 0L
   dataArray = replicate(dataStruct, maxREC)

   for j = 0L, n_elements(*entities) - 1 do begin
     thisEntity = (*entities)[j]

; check for the state and get its full name
     stateID = strtrim((*thisEntity.attributes).(stateIndex), 2)
     stateTest = theStates[0] eq 'ALL' ? 1 : 0
     if (stateTest eq 0) then $
       stateIDX = where(theStates eq strupcase(stateID), stateTest)

     stateIDX = (where(stID eq stateID, count))[0]
     stateName = (count eq 0) ? '' : stNM[stateIDX]

; this is the state/county code
     countyFips = strtrim((*thisEntity.attributes).(fipsIndex), 2)

; county name(s)
     countyName = strtrim((*thisEntity.attributes).(countyIndex), 2)

; trim out the following substrings from the name (if present)
     tmpstr = ['Borough', 'Census Area', 'County']
     for i = 0, n_elements(tmpstr) - 1 do begin
       countyIDX = strpos(strupcase(countyName), strupcase(tmpstr[i]), /reverse_search)
       if (countyIDX ge 0) then $
         countyName = strtrim(strmid(countyName, 0, countyIDX - 1), 2)
     endfor

; check for the county
     countyTest = theCounties[0] eq 'ALL' ? 1 : 0
     if (countyTest eq 0) then $
       countyIDX = where(theCounties eq strupcase(countyName), countyTest)

; these are the state boundaries, I think
     if (strlen(countyName) eq 0) then countyTest = 0

     if (stateTest eq 1) and (countyTest eq 1) then begin

; get the records for this entity
       tmpArr = GetEntityRec(thisEntity, num_rec = num_rec)

; fill the dataArray
       nStart = nEnd
       nEnd = nStart + num_rec[0]
       dataArray[nStart:nEnd-1].stID = stateID
       dataArray[nStart:nEnd-1].stNM = stateName
       dataArray[nStart:nEnd-1].coFIPS = countyFips
       dataArray[nStart:nEnd-1].coNM = countyName
       dataArray[nStart:nEnd-1].lon = transpose(tmpArr[0, *])
       dataArray[nStart:nEnd-1].lat = transpose(tmpArr[1, *])
; set the parts that the records of each county consist of
       ipart2 = nStart
       for ipart = 0, num_rec[1] - 1 do begin
         ipart1 = ipart2
         ipart2 = ipart1 + num_rec[ipart+2]
         dataArray[ipart1:ipart2-1].part = j + ipart
       endfor
     endif
     if (nEnd ge maxREC) then message, 'maximum number of records exceeded. returning...'
   endfor ; end of entities loop

   dataArray = nEnd eq 0 ? dataArray[0] : dataArray[0:nEnd-1]

; if records were found then re-arrange them by state and by county
   if (nEnd gt 0) then begin

     theStates = theStates[0] eq 'ALL' ? stID : theStates

; create an array of sorted/unique county names if 'ALL'
     if (theCounties[0] eq 'ALL') then begin
       theCounties = dataArray.coNM
       theCounties = theCounties[uniq(theCounties, sort(theCounties))]
       theCounties = strupcase(theCounties)
     endif

     tmpStart = 0L
     tmpEnd   = 0L
     tmpArray = replicate(dataStruct, n_elements(dataArray))

     ; sort alphabetically the county records for each state
     for i = 0, n_elements(theStates) - 1 do begin
       stateIDX = where(dataArray.stID eq theStates[i], stateTest)
       if (stateTest ne 0) then begin
         for j = 0L, n_elements(theCounties) - 1 do begin
           countyIDX = where(strupcase(dataArray[stateIDX].coNM) eq theCounties[j], $
                             countyTest)
           if (countyTest ne 0) then begin
             tmpStart = tmpEnd
             tmpEnd = tmpStart + countyTest
             tmpArray[tmpStart:tmpEnd-1] = dataArray[stateIDX[countyIDX]]
           endif
         endfor
       endif
     endfor
     dataArray = tmpArray

; re-number the parts of the records for each county found starting from 1
     for i = 0L, n_elements(theStates) - 1 do begin
       stateIDX = where(dataArray.stID eq theStates[i], stateTest)
       if (stateTest ne 0) then begin
         for j = 0L, n_elements(theCounties) - 1 do begin
           countyIDX = where(strupcase(dataArray[stateIDX].coNM) eq theCounties[j], $
                             countyTest)
           if (countyTest ne 0) then begin
             indices = stateIDX[countyIDX]
             tmpArray = dataArray[indices].part
             tmpArray = tmpArray[uniq(tmpArray, sort(tmpArray))]
             for k = 0, n_elements(tmpArray) - 1 do begin
               tmpIDX = where(dataArray.part eq tmpArray[k], tmpTest)
               if (tmpTest ne 0) then dataArray[tmpIDX].part = k + 1
             endfor
           endif
         endfor
       endif
     endfor

   endif

   if arg_present(getrecords) then getrecords = dataArray

   ; clean up.
   obj_destroy, shapefile
   heap_free, entities

end
