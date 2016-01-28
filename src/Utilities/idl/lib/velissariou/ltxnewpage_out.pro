;-------------------------------------------------------------------------------
pro ltxnewpage_out, lun = lun

on_error, 2

WriteOut = -1
if ( n_elements(lun) eq 1 ) then begin
  if ( lun gt 0 ) then WriteOut = lun
endif

;print, ''
;print, '  \newpage'
;print, ''
printf, WriteOut, ''
printf, WriteOut, '  \newpage'
printf, WriteOut, ''

end
