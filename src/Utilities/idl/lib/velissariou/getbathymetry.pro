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
PRO GetBathymetry, FileName, GetRecords = getrecords

   ; error handling.
   catch, theError
   if theError ne 0 then begin
     ok = error_message(/traceback)
     if obj_valid(shapefile) then obj_destroy, shapefile
     if ptr_valid(entities) then heap_free, entities
     return
   endif

; check parameters.
   if n_elements(FileName) eq 0 then begin
      FileName = dialog_pickfile(filter='*.shp')
      if FileName eq "" then $
         message, 'the name of a county shape file must be provided.'
   endif

; open the shape file and create the shape object.
   shapefile = obj_new('IDLffShape', FileName)
   if obj_valid(shapefile) eq 0 then $
      message, 'unable to create shape file object. returning...'

; get the attribute names from the shape file.
   shapefile -> getproperty, attribute_names = theNames
   theNames = strupcase(strtrim(theNames, 2))

; find the ZVALUE attribute index.
   zvalueIndex = where(theNames eq 'ZVALUE', count)
   if (count eq 0) then message, 'unable to find attribute ZVALUE in file. returning...'
   
; find the DEPTH attribute index.
   depthIndex = where(theNames eq 'DEPTH', count)
   if (count eq 0) then message, 'unable to find attribute DEPTH in file. returning...'

; find the DEPTH_SL attribute index.
   depth_slIndex = where(theNames eq 'DEPTH_SL', count)
   if (count eq 0) then message, 'unable to find attribute DEPTH_SL in file. returning...'

; find the SOURCE attribute index.
   sourceIndex = where(theNames eq 'SOURCE', count)
   if (count eq 0) then message, 'unable to find attribute SOURCE in file. returning...'

; find the LEN attribute index.
   lenIndex = where(theNames eq 'LEN', count)
   if (count eq 0) then message, 'unable to find attribute LEN in file. returning...'

; find the AREA attribute index.
   areaIndex = where(theNames eq 'AREA', count)
   if (count eq 0) then message, 'unable to find attribute AREA in file. returning...'

; get all the attribute pointers from the file. these are the entities.
   entities = ptr_new(/allocate_heap)
   *entities = shapefile -> getentity(/all, /attributes)

; cycle through each entity.
   nStart = 0L
   nEnd   = 0L
   nEntities = n_elements(*entities)
   maxREC = nEntities * 500L
   dataStruct = {lat:0.0, lon:0.0, depth:0.0}
   dataArray = replicate(dataStruct, maxREC)

   for j = 0L, nEntities - 1 do begin
     thisEntity = (*entities)[j]

; get the water depth (meters)
     depth = (*thisEntity.attributes).(depthIndex)

; get the records for this entity
     tmpArr = GetEntityRec(thisEntity, num_rec = num_rec)

; fill the dataArray
     nStart = nEnd
     nEnd = nStart + num_rec[0]
     dataArray[nStart:nEnd-1].lon = transpose(tmpArr[0, *])
     dataArray[nStart:nEnd-1].lat = transpose(tmpArr[1, *])
     dataArray[nStart:nEnd-1].depth = float(depth)

     if (nEnd ge maxREC) then message, 'maximum number of records exceeded. returning...'
   endfor ; end of entities loop

   idx = where(dataArray.depth gt 0.0)
   dataArray = dataArray[idx]

   if arg_present(getrecords) then getrecords = dataArray

   ; clean up.
   obj_destroy, shapefile
   heap_free, entities

end
