PRO make_dir, fname

  if (not writeDIR(fname)) then begin
    if(file_test(fname, /DIRECTORY, /NOEXPAND_PATH) eq 1) then begin
      print, 'the directory:'  + fname
      message, 'exists but write permissions are restricted'
    endif
    if(file_test(fname, /NOEXPAND_PATH) eq 1) then begin
      print, 'the directory:'  + fname
      message, 'exists but is a regular file'
    endif
    file_mkdir, fname, /NOEXPAND_PATH
    print, 'created the directory: ' + fname
  endif
end
