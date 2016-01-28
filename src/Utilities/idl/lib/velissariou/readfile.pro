FUNCTION readFILE, fname
  on_error, 2

  if ((n_elements(fname) eq 0) or (size(fname, /TYPE) ne 7)) then $
    message, 'readFILE: need a string value for <fname>.'

  return, file_test(fname, /READ)
end

