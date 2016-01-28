FUNCTION fixDIRname, fname
  on_error, 2

  if ((n_elements(fname) eq 0) or (size(fname, /TYPE) ne 7)) then $
    message, 'fixDIRname: need a string value for <fname>.'

;-------------------------------------------------------------------------------
; Set directory and path separation characters according to OS type
  case strupcase(!VERSION.OS_FAMILY) of
    'MACOS'   : thisSEP = ':'
    'UNIX'    : thisSEP = '/'
    'VMS'     : thisSEP = '.'
    'WINDOWS' : thisSEP = '\'
    else      : thisSEP = '/'
  endcase

; Trim extraneous blanks from the directory name.
  thisFNAME = strcompress(fname, /REMOVE_ALL)

; Trim extraneous slashes from the directory name and delete any
; trailing slashes.
  begslash = ''
  if ( strmid( thisFNAME, 0, 1 ) eq thisSEP ) and $
     ( strmid( thisFNAME, 1, 1 ) ne thisSEP ) then begslash = thisSEP
  thisFNAME = begslash + strjoin( strsplit( thisFNAME, thisSEP, /EXTRACT ), thisSEP )

  if (thisFNAME eq '') or (file_test(thisFNAME, /DIRECTORY, /READ, /WRITE) eq 0) then $
    thisFNAME = 'IS_UNSET'

  return, thisFNAME
end
