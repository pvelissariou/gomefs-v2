function vl_strleft,instring,pos,length
;+
; NAME: strleft
; PURPOSE: Extract a portion of a string from the left
; CATEGORY: Support
; CALLING SEQUENCE: substring=strleft(string,pos[,length])
; INPUTS:
;   string -- (vector of) string(s) from which substring(s) will be extracted
;   pos -- position of the first character to be extracted, numbering from the
;     left, counting the left-hand-most character as 0.
; OPTIONAL INPUTS:
;   length -- (vector of) length(s) of the substring(s) to be extracted. If
;     there are not enough characters to produce a substring of the requested
;     length, or if the length is omitted, all characters from pos rightwards
;     are returned.
; RETURN VALUE:
;   substring -- (vector of) extracted substring(s)
; EXAMPLES:
;   strleft('abcde',1,3) returns 'bcd'
;   strleft('abcde',2) returns 'cde'
; RESTRICTIONS: Either string OR length may be a vector, not both.
; DESCRIPTION: strleft is just like strmid if all three arguments are
;   supplied. The difference is the possibility of omitting the third.
; MODIFICATION HISTORY: J.M.Gregory 17.9.93
;-
;
; IDL_STATUS: S
;
; Year 2000 compliant: Yes
; Checked by Roger Milton on 23rd August 1998

on_error, 2

nl=n_elements(length)
case nl of
  0: begin
    slength=strlen(instring)
    return,strmid(instring,pos,max([(slength-pos)>0]))
  end
  1: return,strmid(instring,pos,length[0])
  else: begin
    if n_elements(instring) gt 1 $
      then message,'STRING and LENGTH may not both be vectors'
    result=strarr(nl)
    for il=0L,nl-1L do result[il]=strmid(instring,pos,length[il])
    return,result
  end
endcase
end
