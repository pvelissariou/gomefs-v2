FUNCTION writeDIR, fname
  on_error, 2

  if ((n_elements(fname) eq 0) or (size(fname, /TYPE) ne 7)) then $
    message, 'writeDIR: need a string value for <fname>.'

  return, file_test(fname, /DIRECTORY, /WRITE)
end
