;-------------------------------------------------------------------------------
pro ltxeps_out, infile, lun = lun, vspace = vspace, newpage = newpage, width = width

on_error, 2

if n_params() lt 1 then begin
   message, 'Need to supply an input file.'
   return
endif

WriteOut = -1
if ( n_elements(lun) eq 1 ) then begin
  if ( lun gt 0 ) then WriteOut = lun
endif

fwid = 0.85
if ( n_elements(width) eq 1 ) then begin
  if ( width gt 0.0 ) then fwid = width
endif
fwid = string('width=', fwid, '\textwidth', format = '(a, f4.2, a)')

fstr = strsplit( infile, /EXTRACT )
fsz = size( fstr, /N_ELEMENTS )

if keyword_set(vspace) then begin
  printf, WriteOut, ''
  printf, WriteOut, '  \vspace{\fill}'
  printf, WriteOut, ''
endif

printf, WriteOut, '  \begin{center}'

for i = 0, fsz - 1 do begin
  NEWLN = ' \\'
  if ( i eq fsz - 1 ) then NEWLN = ''
  printf, WriteOut, '    \epsfig{file=' + fstr[i] + ', clip=, ' + fwid + '}' + NEWLN
endfor

printf, WriteOut, '  \end{center}'

if keyword_set(newpage) then begin
  if keyword_set(vspace) then begin
    printf, WriteOut, ''
    printf, WriteOut, '  \vspace{\fill}'
    printf, WriteOut, ''
    printf, WriteOut, '  \newpage'
  endif else begin
    printf, WriteOut, ''
    printf, WriteOut, '  \newpage'
    printf, WriteOut, ''
  endelse
endif
end
