PRO dirsep
  on_error, 2

  COMMON SepChars

  ;----------------------------------------
  ; Set directory and path separation characters according to OS type
  case strupcase(!VERSION.OS_FAMILY) of
    'MACOS'   : begin
                  DIR_SEP = ':'
                  PATH_SEP = ','
                end
    'UNIX'    : begin
                  DIR_SEP = '/'
                  PATH_SEP = ':'
                end
    'VMS'     : begin
                  DIR_SEP = '.'
                  PATH_SEP = ','
                end
    'WINDOWS' : begin
                  DIR_SEP = '\'
                  PATH_SEP = ';'
                end
    else      : begin
                  DIR_SEP = '/'
                  PATH_SEP = ':'
                end
  endcase
end
