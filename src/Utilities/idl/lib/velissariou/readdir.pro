FUNCTION readDIR, fname
  on_error, 2

  if ((n_elements(fname) eq 0) or (size(fname, /TYPE) ne 7)) then $
    message, 'readDIR: need a string value for <fname>.'

  return, file_test(fname, /DIRECTORY, /READ)
end
