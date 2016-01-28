PRO Ncdf_PutGlobal_Devel, fid

  Compile_Opt IDL2

  On_Error, 2

  numtypes = [2, 3, 12, 13, 14, 15]
  num_val = where(numtypes eq size(fid, /type))
  if ( num_val[0] eq -1 ) then $
    message, "<fid> should be an integer number."

  ; Set the development date to be used below.
  dev_date = systime(0, /UTC) + ' UTC'

  Ncdf_PutGlobal, fid, 'development_date', dev_date
  Ncdf_PutGlobal, fid, 'developer', 'Panagiotis Velissariou'
  Ncdf_PutGlobal, fid, 'developer_email1', 'pvelissariou@fsu.edu'
  Ncdf_PutGlobal, fid, 'developer_email2', 'velissariou.1@osu.edu'

end
