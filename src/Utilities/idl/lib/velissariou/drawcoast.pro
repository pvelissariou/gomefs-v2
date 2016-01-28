;*******************************************************************************
; START THE MAIN PROGRAM
;*******************************************************************************

PRO DrawCoast_DrawEntity, entity, COLOR=color, LINESTYLE=linestyle, THICK=thick

   ; Error handling.
   Catch, theError
   IF theError NE 0 THEN BEGIN
      ok = Error_Message(/Traceback)
      IF Obj_Valid(shapefile) THEN Obj_Destroy, shapefile
      IF Ptr_Valid(entities) THEN Heap_Free, entities
      RETURN
   ENDIF

   ; Drawing is going to be done based on the shape type.
   CASE 1 OF

      ; Polygon shapes.
      entity.shape_type EQ 5 OR $    ; Polygon.
      entity.shape_type EQ 15 OR $   ; PolygonZ (ignoring Z)
      entity.shape_type EQ 25: BEGIN ; PolygonM (ignoring M)

         IF Ptr_Valid(entity.parts) THEN BEGIN
            cuts = [*entity.parts, entity.n_vertices]
            FOR j=0, entity.n_parts-1 DO BEGIN
               PlotS, (*entity.vertices)[0, cuts[j]:cuts[j+1]-1], $
                  (*entity.vertices)[1, cuts[j]:cuts[j+1]-1], $
                  COLOR=GetColor(color), LINESTYLE=linestyle, THICK=thick
            ENDFOR
         ENDIF
      ENDCASE ; Polygon shapes.

      ; Polyline shapes.
      entity.shape_type EQ  3 OR $   ; PolyLine
      entity.shape_type EQ 13 OR $   ; PolyLineZ (ignoring Z)
      entity.shape_type EQ 23: BEGIN ; PolyLineM (ignoring M)

         IF Ptr_Valid(entity.parts) THEN BEGIN
            cuts = [*entity.parts, entity.n_vertices]
            FOR j=0, entity.n_parts-1 DO BEGIN
               PlotS, (*entity.vertices)[0, cuts[j]:cuts[j+1]-1], $
                  (*entity.vertices)[1, cuts[j]:cuts[j+1]-1], $
                  COLOR=GetColor(color), LINESTYLE=linestyle, THICK=thick
            ENDFOR
         ENDIF
      ENDCASE ; Polyline shapes.

      ELSE: ; All other shapes fall through and are silently ignored.

   ENDCASE

END

;---------------------------------------------------------------------------------
PRO DrawCoast, FileName, $
   COLOR=color, $
   LINESTYLE=linestyle, $
   THICK=thick

   ; Error handling.
   Catch, theError
   IF theError NE 0 THEN BEGIN
      ok = Error_Message(/Traceback)
      IF Obj_Valid(shapefile) THEN Obj_Destroy, shapefile
      IF Ptr_Valid(entities) THEN Heap_Free, entities
      RETURN
   ENDIF

   ; Check parameters.
   IF N_Elements(FileName) EQ 0 THEN BEGIN
      FileName = Dialog_Pickfile(Filter='*.shp')
      IF countryFile EQ "" THEN $
         Message, 'The name of a county shape file must be provided.'
   ENDIF
   IF N_Elements(color) EQ 0 THEN color = 'Sky Blue'
   IF N_Elements(fill) EQ 0 THEN fill = Keyword_Set(fill)
   IF N_Elements(linestyle) EQ 0 THEN linestyle = 0
   IF N_Elements(thick) EQ 0 THEN thick = 1.0

   ; Open the shape file and create the shape object.
   shapefile = Obj_New('IDLffShape', FileName)
   IF Obj_Valid(shapefile) EQ 0 THEN $
      Message, 'Unable to create shape file object. Returning...'

   ; Get all the attribute pointers from the file. These are the entities.
   entities = Ptr_New(/Allocate_Heap)
   *entities = shapefile -> GetEntity(/All, /Attributes)

   ; Cycle through each entity and draw it, if required.
   FOR j=0,N_Elements(*entities)-1 DO BEGIN
      thisEntity = (*entities)[j]
      DrawCoast_DrawEntity, thisEntity, Color=color, $
         LineStyle=linestyle, Thick=thick
   ENDFOR

   ; Clean up.
   Obj_Destroy, shapefile
   Heap_Free, entities

END
