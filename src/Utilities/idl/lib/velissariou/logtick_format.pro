;-------------------------------------------------------------------------------
function logtick_format, axis, index, value

  myval  = alog10( value )
  myval1 = abs( myval )

; Default values
  frm = '(i1.1)'
  frmstr = '10' + '!U ' + strtrim(string( 0, format = frm ), 2) + '!N'

  for i = 1, 10 do begin
    i1 = 10^(i - 1)
    i2 = 10^(i)
     if ( (myval1 ge i1) and (myval1 lt i2) ) then begin
       if ( myval ge 0.0 ) then $
         frm = '(i' + strtrim(string(i, format = '(i)'), 2) + ')'
       if ( myval lt 0.0 ) then $
         frm = '(i' + strtrim(string(i+1, format = '(i)'), 2) + ')'
       frmstr = '10' + '!U ' + strtrim(string( myval, format = frm ), 2) + '!N'
       break
     endif
  endfor

return, frmstr
end
