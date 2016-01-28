
PRO Try1, zval, insD, outD

  Compile_Opt HIDDEN, IDL2

  on_error, 2

  ; ----- Check for valid input
  badtypes = [0, 6, 7, 8, 9, 10, 11]
  void = where(badtypes eq size(zval, /TYPE), count)
    if (count ne 0) then $
      message, 'Only numbers are valid values for <zval>.'

  zval = zval[0]
  case 1 of
    (zval lt 0):     message, 'Only positive numbers are valid values for <zval>.'
    (zval gt 10000): message, 'zval should be less than 10000 m.'
    else:
  endcase

  DEPS = [                                            $
               0,   10,   20,   30,   50,   75,  100, $
             125,  150,  200,  250,  300,  400,  500, $
             600,  700,  800,  900, 1000, 1100, 1200, $
            1300, 1400, 1500, 1750, 2000, 2500, 3000, $
            3500, 4000, 4500, 5000, 5500, 6000, 7000, $
            8000, 9000,                               $
           10000                                      $
         ]

  insDIST = [                                           $
                 5,   50,   50,   50,   50,   50,   50, $
                50,   50,   50,  100,  100,  100,  100, $
               100,  100,  100,  200,  200,  200,  200, $
               200,  200,  200,  200, 1000, 1000, 1000, $
              1000, 1000, 1000, 1000, 1000, 1000, 1000, $
              1000, 1000,                               $
              1000                                      $
            ]

  outDIST = [                                           $
               200,  200,  200,  200,  200,  200,  200, $
               200,  200,  200,  200,  200,  200,  400, $
               400,  400,  400,  400,  400,  400,  400, $
              1000, 1000, 1000, 1000, 1000, 1000, 1000, $
              1000, 1000, 1000, 1000, 1000, 1000, 1000, $
              1000, 1000,                               $
              1000                                      $
            ]

;  void = min(abs(DEPS - zval), imin)
;  insD = insDIST[imin]
;  outD = outDIST[imin]

  insD = interpol(insDIST, DEPS, zval)
  outD = interpol(outDIST, DEPS, zval)

end

