function vl_strreplace,string,old,new,recursive=recursive
;+
; NAME: strreplace
; PURPOSE: Replace occurrences of substring in a string with new substring
; CATEGORY: Support
; CALLING SEQUENCE: newstring=strreplace(oldstring,oldsub,newsub)
; INPUTS:
;   oldstring -- (vector of) input string(s)
;   oldsub -- (vector of) input substring(s) to be replaced
;   newsub -- substring(s) to insert in place of occurrences of (corresponding
;     element of) oldsub
; KEYWORD PARAMETERS: recursive -- if RECURSIVE gt 0, scan the entire string
;   after each replacement, in case the substitution produces a new instance
;   of the substring to be replaced. Since this can lead to an infinite loop,
;   the string is scanned a maximum of RECURSIVE times.
; RETURN VALUE: newstring -- (vector of) output string(s). In each output
;   string, every element of oldsub is replaced with the corresponding element
;   of newsub.
; MODIFICATION HISTORY: J.M.Gregory 20.4.93
;-
; Year 2000 compliant: Yes
; Checked by Roger Milton on 23rd August 1998

on_error, 2

recur=max(datatype(recursive, 2) eq [1,2,3])
if recur then recur=recursive gt 0
result=string
oldlen=strlen(old) & newlen=strlen(new)

for i=0,n_elements(string)-1 do begin
for j=0,n_elements(old)-1 do begin
  if recur then recurcount=recursive
  index=strpos(result[i],old[j])
  while index ge 0 do begin
; remainder is what appears to the right of the substring to be replaced
    remainder=vl_strleft(result[i],index+oldlen[j])
; concatenate what appears to the left + substitute substring + remainder
    result[i]=strmid(result[i],0,index)+new[j]+remainder
    if recur then begin
      recurcount=recurcount-1
      if recurcount gt 0 then index=strpos(result[i],old[j]) else index=-1
    endif else begin
; look for substring to be replaced in the remainder
      newindex=strpos(remainder,old[j])
; if it's there, compute its position in the whole string
      if newindex ge 0 then newindex=newindex+index+newlen[j]
      index=newindex
    endelse
  endwhile
endfor
endfor

return,result
end
