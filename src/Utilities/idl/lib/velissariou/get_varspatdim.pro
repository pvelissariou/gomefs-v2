FUNCTION Get_VarSpatDim, DimType

  Compile_Opt HIDDEN, IDL2

  On_Error, 2

  if ( size(DimType, /TNAME) ne 'STRING' ) then $
    message, "<DimType> should be a string."

  case 1 of
    (strmatch(DimType, '0dvar', /FOLD_CASE) eq 1): $
      var_dim = 0
    (strmatch(DimType, '1dvar', /FOLD_CASE) eq 1): $
      var_dim = 1
    ( (strmatch(DimType, 'p2dvar', /FOLD_CASE) eq 1) or $
      (strmatch(DimType, 'r2dvar', /FOLD_CASE) eq 1) or $
      (strmatch(DimType, 'u2dvar', /FOLD_CASE) eq 1) or $
      (strmatch(DimType, 'v2dvar', /FOLD_CASE) eq 1) ): $
        var_dim = 2
    ( (strmatch(DimType, 'p3dvar', /FOLD_CASE) eq 1) or $
      (strmatch(DimType, 'r3dvar', /FOLD_CASE) eq 1) or $
      (strmatch(DimType, 'u3dvar', /FOLD_CASE) eq 1) or $
      (strmatch(DimType, 'v3dvar', /FOLD_CASE) eq 1) or $
      (strmatch(DimType, 'w3dvar', /FOLD_CASE) eq 1) ): $
        var_dim = 3
    else: var_dim = -1
  endcase

  return, var_dim
end
