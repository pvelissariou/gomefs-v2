; Make sure that very small numbers (almost zero) do not exhibit
; the -0.0000 behavior
FUNCTION ZeroFloatFix, data

   ; Only want to deal with numerical data types.
   ; Return all other kinds.
   dataType = Size(data, /Type)
   nogoodtypes = [0, 7, 8, 10, 11]
   void = where(nogoodTypes eq dataType, count)
   if (count gt 0) then return, data

   ; If this is a very small (almost zero) float number, then fix it.
   ;info = machar(DOUBLE = (dataType EQ 5 OR dataType EQ 9))
   info = machar()
   indices = where(abs(data) le info.eps, count)
   if (count gt 0) then data[indices] = 0

   indices = where(finite(data, /NAN) eq 1, count)
   if (count gt 0) then data[indices] = !VALUES.F_NAN

   ; Return the repaired data.
   return, data
end
