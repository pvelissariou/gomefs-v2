FUNCTION Spawn_Cmd, cmd

  ; Error handling.
  on_error, 2

  result = ""
  error_result = ""
  failure = 0

  exe_cmd = strtrim(string(cmd), 2)

  if strupcase(!Version.OS_Family) eq 'WINDOWS' then begin
    spawn, '"' + exe_cmd + '"', /HIDE, /LOG_OUTPUT, result, error_result, EXIT_STATUS = failure
  endif else begin
    spawn, exe_cmd, result, error_result, EXIT_STATUS = failure
  endelse

  if (error_result[0] ne "") then begin
    message, 'ERROR: ' + error_result[0], /informational
  endif

  return, failure

end
