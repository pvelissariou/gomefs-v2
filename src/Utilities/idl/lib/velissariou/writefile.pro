FUNCTION writeFILE, fname
  on_error, 2

  if ((n_elements(fname) eq 0) or (size(fname, /TYPE) ne 7)) then $
    message, 'writeFILE: need a string value for <fname>.'

  if (file_test(fname)) then begin
    return, file_test(fname, /WRITE)
  endif else begin
    return, file_test(file_dirname(fname), /DIRECTORY, /WRITE)
  endelse

end
