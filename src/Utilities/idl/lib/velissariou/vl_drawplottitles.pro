PRO VL_DrawPlotTitles, titles,                $
                       TL1 = tl1,             $
                       VL1 = vl1,             $
                       TL2 = tl2,             $
                       VL2 = vl2,             $
                       TR1 = tr1,             $
                       VR1 = vr1,             $
                       TR2 = tr2,             $
                       VR2 = vr2,             $
                       RLOGO = rlogo,         $
                       LLOGO = llogo,         $
                       LOGO_FILE = logo_file, $
                       CL1 = cl1,             $
                       CL2 = cl2,             $
                       CR1 = cr1,             $
                       CR2 = cr2,             $
                       COLOR = color,         $
                       _EXTRA = extra

    Compile_Opt IDL2

    on_error, 2

    COMMON PlotParams


    l_logo = (keyword_set(llogo) eq 1) ? 1 : 0
    r_logo = (keyword_set(rlogo) eq 1) ? 1 : 0
    do_logo = r_logo + l_logo
    if ( do_logo gt 1 ) then begin
      message, 'only one of the keywords <RLOGO, LLOGO> should be specified'
    endif

    if (do_logo eq 1) then begin
      if (n_elements(logo_file) eq 0) then begin
        message, 'the logo jpeg file should be specified in order to proceed'
      endif
    endif

    as = !D.Y_VSIZE / Float(!D.X_VSIZE)

    ;xoff = 0.0075
    xoff = 0.0050
    yoff = 0.25 * (xoff / as)
    tsz  = 1.0
    lsp  = 1.25

    tl_xy = PlotTitleText
    tl_xy[2] = tl_xy[0]

    tr_xy = PlotTitleText
    tr_xy[0] = tr_xy[2]

    ; ----------------------------------------
    ; Display the logo image
    if (do_logo gt 0) then begin

      img_ok = 0
      if ((img_ok = query_png(logo_file, logo_info)) gt 0) then begin
        read_png, logo_file, logo_img, TRANSPARENT = transp
      endif else begin
        if ((img_ok = query_jpeg(logo_file, logo_info)) gt 0) then begin
          read_jpeg, logo_file, logo_img
        endif
      endelse
      
      if (img_ok le 0) then $
        message, 'cannot read the logo file: ' + logo_file

      old_dev = !D.NAME
      set_plot, 'Z'
      device, set_resolution = DevResolution
      logo_dims = convert_coord(logo_info.dimensions, /device, /to_normal)
      set_plot, old_dev

      yoff = 0.5 * (PlotTitleBox[3] - PlotTitleBox[1] - logo_dims[1]) > 0.0
      xoff = yoff * as
      ht = logo_dims[1] < (PlotTitleBox[3] - PlotTitleBox[1] - 2 * yoff)
      wd = ht * as

      logo_xy = PlotTitleBox
      if (l_logo gt 0) then begin
        logo_xy[0] = PlotTitleBox[0] + xoff
        logo_xy[1] = PlotTitleBox[1] + yoff
        logo_xy[2] = logo_xy[0] + wd
        logo_xy[3] = logo_xy[1] + ht
        tl_xy[0] = logo_xy[2] + 0.5 * xoff
        tl_xy[2] = tl_xy[0]
      endif else begin
        logo_xy[0] = PlotTitleBox[2] - xoff - wd
        logo_xy[1] = PlotTitleBox[1] + yoff
        logo_xy[2] = logo_xy[0] + wd
        logo_xy[3] = logo_xy[1] + ht
        tr_xy[0] = logo_xy[0] - 0.5 * xoff
        tr_xy[2] = tr_xy[0]
      endelse
      if (n_elements(transp) ne 0) then begin
        cgImage, logo_img, TRANSPARENT = transp, position = logo_xy, /KEEP_ASPECT
      endif else begin
        cgImage, logo_img, position = logo_xy, /KEEP_ASPECT
      endelse
    endif
    ; ----------------------------------------


    ; ----------------------------------------
    ; Left Title Legend 1
    if (n_elements(tl1) ne 0) then begin
      myTL = tl1
      nTEXT = n_elements(myTL)
      for i = 0, nTEXT - 1 do $
        myTL[i] = !D.NAME eq 'PS' ? TextFont(tl1[i], 3) : TextFont(tl1[i], 8)

      myCL = intarr(nTEXT)
      nCLRS = n_elements(cl1)
      case 1 of
        (nCLRS eq 0): myCL[*] = GetColor('Black')
        (nCLRS eq 1): myCL[*] = GetColor(cl1[0])
        else: begin
                myCL[*] = GetColor('Black')
                nCLRS = (nCLRS < nTEXT)
                for i = 0, nCLRS - 1 do $
                  myCL[i] = GetColor(cl1[i])
              end
      endcase

      VL_Legend, [0.0, 0.0], myTL, $
                 charsize = tsz, alignment = 0.0, spacing = lsp, $
                 legdims = leg_dims, /get

      t_wd = leg_dims[2] - leg_dims[0]
      t_ht = leg_dims[3] - leg_dims[1]

      my_tl_xy = tl_xy
      my_tl_xy[0] = tl_xy[2] + xoff
      my_tl_xy[3] = tl_xy[3] - yoff
      my_tl_xy[1] = my_tl_xy[3] - t_ht
      my_tl_xy[2] = my_tl_xy[0] + t_wd

      tl_xy[0] = my_tl_xy[2]
      tl_xy[2] = tl_xy[0]

      VL_Legend, [my_tl_xy[0], my_tl_xy[1]], myTL,  $
                 charsize = tsz, alignment = 0.0, spacing = lsp, $
                 color = myCL

      if (n_elements(vl1) ne 0) then begin
        myVL = strarr(nTEXT)
        nVALS = n_elements(vl1)
        for i = 0, nVALS - 1 do begin
          myVL[i] = !D.NAME eq 'PS' ? TextFont(vl1[i], 3) : TextFont(vl1[i], 8)
          if (i eq (nTEXT - 1)) then break
        endfor

        VL_Legend, [0.0, 0.0], myVL, $
                   charsize = tsz, alignment = 1.0, spacing = lsp, $
                   legdims = leg_dims, /get

        v_wd = leg_dims[2] - leg_dims[0]
        v_ht = leg_dims[3] - leg_dims[1]

        my_vl_xy = tl_xy
        my_vl_xy[0] = tl_xy[2] + xoff
        my_vl_xy[3] = tl_xy[3] - yoff
        my_vl_xy[1] = my_vl_xy[3] - t_ht
        my_vl_xy[2] = my_vl_xy[0] + v_wd

        tl_xy[0] = my_vl_xy[2]
        tl_xy[2] = tl_xy[0]

        VL_Legend, [my_vl_xy[0], my_vl_xy[1]], myVL, $
                   charsize = tsz, alignment = 1.0, spacing = lsp, $
                   color = myCL
      endif
      tl_xy[0] = tl_xy[0] + 0.5 * xoff
      tl_xy[2] = tl_xy[0]
    endif
    ; ----------------------------------------


    ; ----------------------------------------
    ; Left Title Legend 2
    if (n_elements(tl2) ne 0) then begin
      myTL = tl2
      nTEXT = n_elements(myTL)
      for i = 0, nTEXT - 1 do $
        myTL[i] = !D.NAME eq 'PS' ? TextFont(tl2[i], 3) : TextFont(tl2[i], 8)

      myCL = intarr(nTEXT)
      nCLRS = n_elements(cl2)
      case 1 of
        (nCLRS eq 0): myCL[*] = GetColor('Black')
        (nCLRS eq 1): myCL[*] = GetColor(cl2[0])
        else: begin
                myCL[*] = GetColor('Black')
                nCLRS = (nCLRS < nTEXT)
                for i = 0, nCLRS - 1 do $
                  myCL[i] = GetColor(cl2[i])
              end
      endcase

      VL_Legend, [0.0, 0.0], myTL, $
                 charsize = tsz, alignment = 0.0, spacing = lsp, $
                 legdims = leg_dims, /get

      t_wd = leg_dims[2] - leg_dims[0]
      t_ht = leg_dims[3] - leg_dims[1]

      my_tl_xy = tl_xy
      my_tl_xy[0] = tl_xy[2] + xoff
      my_tl_xy[3] = tl_xy[3] - yoff
      my_tl_xy[1] = my_tl_xy[3] - t_ht
      my_tl_xy[2] = my_tl_xy[0] + t_wd

      tl_xy[0] = my_tl_xy[2]
      tl_xy[2] = tl_xy[0]

      VL_Legend, [my_tl_xy[0], my_tl_xy[1]], myTL,  $
                 charsize = tsz, alignment = 0.0, spacing = lsp, $
                 color = myCL

      if (n_elements(vl2) ne 0) then begin
        myVL = strarr(nTEXT)
        nVALS = n_elements(vl2)
        for i = 0, nVALS - 1 do begin
          myVL[i] = !D.NAME eq 'PS' ? TextFont(vl2[i], 3) : TextFont(vl2[i], 8)
          if (i eq (nTEXT - 1)) then break
        endfor

        VL_Legend, [0.0, 0.0], myVL, $
                   charsize = tsz, alignment = 1.0, spacing = lsp, $
                   legdims = leg_dims, /get

        v_wd = leg_dims[2] - leg_dims[0]
        v_ht = leg_dims[3] - leg_dims[1]

        my_vl_xy = tl_xy
        my_vl_xy[0] = tl_xy[2] + xoff
        my_vl_xy[3] = tl_xy[3] - yoff
        my_vl_xy[1] = my_vl_xy[3] - t_ht
        my_vl_xy[2] = my_vl_xy[0] + v_wd

        tl_xy[0] = my_vl_xy[2]
        tl_xy[2] = tl_xy[0]

        VL_Legend, [my_vl_xy[0], my_vl_xy[1]], myVL, $
                   charsize = tsz, alignment = 1.0, spacing = lsp, $
                   color = myCL
      endif
      tl_xy[0] = tl_xy[0] + 0.5 * xoff
      tl_xy[2] = tl_xy[0]
    endif
    ; ----------------------------------------


    ; ----------------------------------------
    ; Right Title Legend 1
    if (n_elements(tr1) ne 0) then begin
      myTR = tr1
      nTEXT = n_elements(myTR)

      for i = 0, nTEXT - 1 do $
        myTR[i] = !D.NAME eq 'PS' ? TextFont(tr1[i], 3) : TextFont(tr1[i], 8)

      myCR = intarr(nTEXT)
      nCLRS = n_elements(cr1)
      case 1 of
        (nCLRS eq 0): myCR[*] = GetColor('Black')
        (nCLRS eq 1): myCR[*] = GetColor(cr1[0])
        else: begin
                myCR[*] = GetColor('Black')
                nCLRS = (nCLRS < nTEXT)
                for i = 0, nCLRS - 1 do $
                  myCR[i] = GetColor(cr1[i])
              end
      endcase

      VL_Legend, [0.0, 0.0], myTR, $
                 charsize = tsz, alignment = 0.0, spacing = lsp, $
                 legdims = leg_dims, /get

      t_wd = leg_dims[2] - leg_dims[0]
      t_ht = leg_dims[3] - leg_dims[1]


      ; -----
      if (n_elements(vr1) ne 0) then begin
        myVR = strarr(nTEXT)
        nVALS = n_elements(vr1)
        for i = 0, nVALS - 1 do begin
          myVR[i] = !D.NAME eq 'PS' ? TextFont(vr1[i], 3) : TextFont(vr1[i], 8)
          if (i eq (nTEXT - 1)) then break
        endfor

        VL_Legend, [0.0, 0.0], myVR, $
                   charsize = tsz, alignment = 1.0, spacing = lsp, $
                   legdims = leg_dims, /get

        v_wd = leg_dims[2] - leg_dims[0]
        v_ht = leg_dims[3] - leg_dims[1]

        my_vr_xy = tr_xy
        my_vr_xy[2] = tr_xy[2] - xoff
        my_vr_xy[3] = tr_xy[3] - yoff
        my_vr_xy[1] = my_vr_xy[3] - t_ht
        my_vr_xy[0] = my_vr_xy[2] - v_wd

        tr_xy[0] = my_vr_xy[0]
        tr_xy[2] = tr_xy[0]

        VL_Legend, [my_vr_xy[0], my_vr_xy[1]], myVR, $
                   charsize = tsz, alignment = 1.0, spacing = lsp, $
                   color = myCR
      endif
      ; -----


      my_tr_xy = tr_xy
      my_tr_xy[2] = tr_xy[2] - xoff
      my_tr_xy[3] = tr_xy[3] - yoff
      my_tr_xy[1] = my_tr_xy[3] - t_ht
      my_tr_xy[0] = my_tr_xy[2] - t_wd

      tr_xy[0] = my_tr_xy[0]
      tr_xy[2] = tr_xy[0]

      VL_Legend, [my_tr_xy[0], my_tr_xy[1]], myTR,  $
                 charsize = tsz, alignment = 0.0, spacing = lsp, $
                 color = myCR

      tr_xy[0] = tr_xy[0] - 0.5 * xoff
      tr_xy[2] = tr_xy[0]
    endif
    ; ----------------------------------------


    ; ----------------------------------------
    ; Right Title Legend 2
    if (n_elements(tr2) ne 0) then begin
      myTR = tr2
      nTEXT = n_elements(myTR)

      for i = 0, nTEXT - 1 do $
        myTR[i] = !D.NAME eq 'PS' ? TextFont(tr2[i], 3) : TextFont(tr2[i], 8)

      myCR = intarr(nTEXT)
      nCLRS = n_elements(cr2)
      case 1 of
        (nCLRS eq 0): myCR[*] = GetColor('Black')
        (nCLRS eq 1): myCR[*] = GetColor(cr2[0])
        else: begin
                myCR[*] = GetColor('Black')
                nCLRS = (nCLRS < nTEXT)
                for i = 0, nCLRS - 1 do $
                  myCR[i] = GetColor(cr2[i])
              end
      endcase

      VL_Legend, [0.0, 0.0], myTR, $
                 charsize = tsz, alignment = 0.0, spacing = lsp, $
                 legdims = leg_dims, /get

      t_wd = leg_dims[2] - leg_dims[0]
      t_ht = leg_dims[3] - leg_dims[1]


      ; -----
      if (n_elements(vr2) ne 0) then begin
        myVR = strarr(nTEXT)
        nVALS = n_elements(vr2)
        for i = 0, nVALS - 1 do begin
          myVR[i] = !D.NAME eq 'PS' ? TextFont(vr2[i], 3) : TextFont(vr2[i], 8)
          if (i eq (nTEXT - 1)) then break
        endfor

        VL_Legend, [0.0, 0.0], myVR, $
                   charsize = tsz, alignment = 1.0, spacing = lsp, $
                   legdims = leg_dims, /get

        v_wd = leg_dims[2] - leg_dims[0]
        v_ht = leg_dims[3] - leg_dims[1]

        my_vr_xy = tr_xy
        my_vr_xy[2] = tr_xy[2] - xoff
        my_vr_xy[3] = tr_xy[3] - yoff
        my_vr_xy[1] = my_vr_xy[3] - t_ht
        my_vr_xy[0] = my_vr_xy[2] - v_wd

        tr_xy[0] = my_vr_xy[0]
        tr_xy[2] = tr_xy[0]

        VL_Legend, [my_vr_xy[0], my_vr_xy[1]], myVR, $
                   charsize = tsz, alignment = 1.0, spacing = lsp, $
                   color = myCR
      endif
      ; -----


      my_tr_xy = tr_xy
      my_tr_xy[2] = tr_xy[2] - xoff
      my_tr_xy[3] = tr_xy[3] - yoff
      my_tr_xy[1] = my_tr_xy[3] - t_ht
      my_tr_xy[0] = my_tr_xy[2] - t_wd

      tr_xy[0] = my_tr_xy[0]
      tr_xy[2] = tr_xy[0]

      VL_Legend, [my_tr_xy[0], my_tr_xy[1]], myTR,  $
                 charsize = tsz, alignment = 0.0, spacing = lsp, $
                 color = myCR

      tr_xy[0] = tr_xy[0] - 0.5 * xoff
      tr_xy[2] = tr_xy[0]
    endif
    ; ----------------------------------------


    ; ----------------------------------------
    ; Center Title Legend
    if (n_elements(titles) ne 0) then begin
      xoff = 0.0
      yoff = 0.0
      tsz  = 1.10
      lsp  = 1.20

      myTITLE = titles
      nTEXT = n_elements(myTITLE)

      myTSZ = make_array(nTEXT, /FLOAT, VALUE = tsz)
      myTSZ[nTEXT - 1] = 1.10 * tsz

      for i = 0, nTEXT - 1 do $
        myTITLE[i] = !D.NAME eq 'PS' ? TextFont(titles[i], 4) : TextFont(titles[i], 16)

      myCL = intarr(nTEXT)
      nCLRS = n_elements(color)
      case 1 of
        (nCLRS eq 0): myCL[*] = GetColor('Black')
        (nCLRS eq 1): myCL[*] = GetColor(color[0])
        else: begin
                myCL[*] = GetColor('Black')
                nCLRS = (nCLRS < nTEXT)
                for i = 0, nCLRS - 1 do $
                  myCL[i] = GetColor(color[i])
              end
      endcase

      VL_Legend, [0.0, 0.0], myTITLE, $
                 charsize = myTSZ, alignment = 0.5, spacing = lsp, $
                 legdims = leg_dims, /get

      t_wd = leg_dims[2] - leg_dims[0]
      t_ht = leg_dims[3] - leg_dims[1]

      my_xy = PlotTitleText
      my_xy[0] = (0.5 * ( (tl_xy[2] + xoff) + (tr_xy[0] - xoff) - t_wd) > 0.0)
      my_xy[3] = (0.5 * (PlotTitleText[3] - PlotTitleText[1] - t_ht) > 0.0)
      my_xy[3] = PlotTitleText[3] - my_xy[3]
      my_xy[1] = my_xy[3] - t_ht
      my_xy[2] = my_xy[0] + t_wd

      VL_Legend, [my_xy[0], my_xy[1]], myTITLE,  $
                 charsize = myTSZ, alignment = 0.5, spacing = lsp, $
                 color = myCL
    endif
    ; ----------------------------------------
end
