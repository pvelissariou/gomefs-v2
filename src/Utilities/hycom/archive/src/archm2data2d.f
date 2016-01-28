      program archv2data2d
      use mod_plot  ! HYCOM plot array interface
      use mod_za    ! HYCOM array I/O interface
c
c --- hycom/micom 2-d diagnostic field extractor
c
      real, allocatable, dimension (:,:)   ::
     &   uflux,vflux,strmf,
     &   dpdx,dpdy, util1,work
      real, allocatable, dimension (:,:,:) ::
     &   utilk,w
      real   depthu,depthv,ubi,vbi,s1,s2
      real*8 strmft,strmfu,strmfv
c
      common/conrng/ amn,amx
c
      character flnm*240,frmt*80,cline*240
      character ctrc_title(99)*80,ctrc_units(99)*80,
     &          ctrc_lname(99)*80,ctrc_sname(99)*80
      logical   smooth,mthin,lsteric,icegln,lperiod,baclin,xyward,barouv
c
      logical          ltheta
      integer          artype,iexpt,iversn,kkin,yrflag,mxlflg
      real             dudxdn,dudxup,dvdydn,dvdyup,dp00f
      double precision time3(3)
      double precision dsumth,dsumdp
c
      real, parameter :: flag = 2.0**100
c
c --- 'lhycom' -- hycom (vs micom) input file
c --- 'trcout' -- tracer input
      logical   lhycom,trcout
      data      lhycom/.false./, trcout/.false./
c
      real      tenm,onem,temcm,onecm,onemm
      data      tenm/10./,onem/1./,tencm/.1/,onecm/.01/,onemm/.001/
c
      logical   initl
      data      initl /.true. /
      real      thref,spcifh
      data      thref/1.e-3/,spcifh/3990./
      character blank*40
      data      blank/'                                        '/
c
      call xcspmd
      call zaiost
      lp=6
c
c --- read model data
c ---   'flnm  ' = name of file containing the actual data
c ---   'frmt  ' = output format or type (HYCOM, BINARY, netCDF)
c ---                see horout for more details on frmt
c ---   'iexpt ' = experiment number x10  (000=from archive file)
c ---   'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3=actual)
c ---   'ntracr' = number of tracers (to output, optional with default 0)
c ---    one name line per tracer: 8-letter plot and units, field, standard_
c ---      or separated by "|" (i.e. plot|units|field|standard).
c ---      the field name must only contain alphanumerics and "_", and 
c ---      the standard_name is either blank or from the CF 1.0 conventions
c ---   'idm   ' = longitudinal array size
c ---   'jdm   ' = latitudinal  array size
c ---   'kdm   ' = number of layers
        read (*,'(a)') flnm
        write (lp,'(2a)') ' input file: ',trim(flnm)
        call flush(lp)
        read (*,'(a)') frmt
        write (lp,'(2a)') 'output type: ',trim(frmt)
        call flush(lp)
        call blkini(iexpt, 'iexpt ')
        call blkini(yrflag,'yrflag')
        call blkini2(i,j,  'ntracr','idm   ')  !read ntracr or idm
        if (j.eq.1) then
          ntracr = i
          do ktr= 1,ntracr
            read(*,'(a)') cline
            i = index(cline,'|')
            if     (i.eq.0) then  !8-letter plot and units, field has no spaces
              ctrc_title(ktr) = cline(1:8)
              ctrc_units(ktr) = cline(9:16)
              cline = cline(17:)
              do
                i = index(cline,' ')
                if     (i.ne.1) then
                  exit
                endif
                cline = cline(2:) !remove a leading space
              enddo
              ctrc_lname(ktr) = cline(1:i-1)
              ctrc_sname(ktr) = cline(i+1:)
            else  !separated by "|" 
              ctrc_title(ktr) = cline(1:i-1)
              cline = cline(i+1:)
              i = index(cline,'|')
              ctrc_units(ktr) = cline(1:i-1)
              cline = cline(i+1:)
              i = index(cline,'|')
              ctrc_lname(ktr) = cline(1:i-1)
              ctrc_sname(ktr) = cline(i+1:)
            endif
            write (lp,'(2x,i2,3a)')
     &        ktr,' title  = "',trim(ctrc_title(ktr)),'"',
     &        ktr,' units  = "',trim(ctrc_units(ktr)),'"',
     &        ktr,' l.name = "',trim(ctrc_lname(ktr)),'"',
     &        ktr,' s.name = "',trim(ctrc_sname(ktr)),'"'
            call flush(lp)
            if     (   index(ctrc_lname(ktr),' ').ne.0 .and.
     &                 index(ctrc_lname(ktr),' ').le.
     &              len_trim(ctrc_lname(ktr))                ) then
              ! does not catch all illegal l.names.
              write(lp,*)
              write(lp,*) 'error - l.name contains spaces'
              write(lp,*)
              call flush(lp)
              stop
            elseif (   index(ctrc_lname(ktr),'-').ne.0) then
              ! still does not catch all illegal l.names.
              write(lp,*)
              write(lp,*) 'error - l.name contains "-"'
              write(lp,*)
              call flush(lp)
              stop
            endif !l.name check
          enddo
          call blkini(ii,  'idm   ')
        else
          ntracr = 0
          ii     = i
        endif
        call blkini(jj,    'jdm   ')
        call blkini(kk,    'kdm   ')
        if     (ii.ne.idm .or. jj.ne.jdm) then
          write(lp,*)
          write(lp,*) 'error - wrong idm or jdm (should be:',
     &                                           idm,jdm,')'
          write(lp,*)
          call flush(lp)
          stop
        endif
c
c ---   'thbase' = reference density (sigma units)
        call blkinr(thbase,
     &             'thbase','("blkinr: ",a6," =",f11.4," sig")')
c
c ---   'smooth' = smooth fields before output
c ---   'mthin ' = mask thin layers from output
        call blkinl(smooth,'smooth')
        call blkinl(mthin, 'mthin ')
c
c ---   'baclin' = extract baroclinic velocity (0=total:DEFAULT,1=baroclinic)
c ---   'xyward' = output original unrotated velocities (0=no:DEFAULT,1=yes)
        call blkini3(i,j,  'baclin','xyward','iorign')  !read one of three
        if (j.eq.1) then
          baclin = i.eq.1  !baroclinic, vs total, velocity
          call blkini2(i,j,  'xyward','iorign')  !read one of two
          if (j.eq.1) then
            xyward = i.eq.1  !x-y, vs east-north, velocity
            call blkini(iorign,'iorign')
          else
            xyward = .false. !eastward,northward velocity
            iorign = i
          endif
        elseif (j.eq.2) then
          baclin = .false. !total velocity
          xyward = i.eq.1  !x-y, vs east-north, velocity
          call blkini(iorign,'iorign')
        else
          baclin = .false. !total velocity
          xyward = .false. !eastward,northward velocity
          iorign = i
        endif
c
c ---   'iorign' = i-origin of sampled subregion
c ---   'jorign' = j-origin of sampled subregion
c ---   'idmp  ' = i-extent of sampled subregion (<=idm; 0 implies idm)
c ---   'jdmp  ' = j-extent of sampled subregion (<=jdm; 0 implies jdm)
*       call blkini(iorign,'iorign')  !see above
        call blkini(jorign,'jorign')
        call blkini(ii,    'idmp  ')
        call blkini(jj,    'jdmp  ')
        if     (ii.eq.0) then
          ii=idm
        endif
        if     (jj.eq.0) then
          jj=jdm
        endif
c ---   'iorign,jorign' denote the origin of the subgrid to be extracted 
c ---   from the full history grid (dimensioned idm x jdm). 
c ---   The size of the subgrid is determined by ii,jj.
        write (lp,'(2(a,i5),9x,2(a,i5))') 'extracting i =',iorign,
     &    ' ...',iorign+ii-1,'j =',jorign,' ...',jorign+jj-1
        call flush(lp)
c
c --- array allocation
c
      call plot_alloc
c
      allocate(  uflux(ii,jj) )
      allocate(  vflux(ii,jj) )
      allocate(  strmf(ii,jj) )
      allocate(   dpdx(ii,jj) )
      allocate(   dpdy(ii,jj) )
      allocate(  util1(ii,jj) )
      allocate(   work(ii,jj) )
c
      allocate(  utilk(ii,jj,kk) )
c
      dpthfil = 'regional.depth'
c
      do j=1,jj
        do i=1,ii
          p(i,j,1)=0.
        enddo
      enddo
c
c --- read the archive file.
c
      if (lhycom) then
        call getdat(flnm,time3,artype,initl,lsteric,icegln,trcout,
     &              iexpt,iversn,yrflag,kkin)       ! hycom input
        time = time3(3)
      else
        call getdtm(flnm,time,initl, thbase)        ! micom input
        lsteric = .false.
        icegln  = .false.
        artype  = 1
        iversn  = 10
      endif
c
*     if     (artype.eq.3) then
*       smooth = .false.
*     endif
c
      write(lp,'(/a,2f8.2/a,2f8.2)') 
     &     'sub-domain longitude range = ',
     &    minval(plon(:,:)),maxval(plon(:,:)),
     &     'sub-domain latitude  range = ',
     &    minval(plat(:,:)),maxval(plat(:,:))
c
      lperiod = ii.eq.idm .and.
     &          maxval(plon(:,:))-minval(plon(:,:)) .gt. 350.0
      if     (lperiod) then
        write(lp,'(/a/)') 'sub-domain assumed to be periodic'
      else
        write(lp,'(/a/)') 'sub-domain assumed to be non-periodic'
      endif
      call flush(lp)
c
      call bigrid(depths)
      call flush(lp)
c
c --- check that bathymetry is consistent with this archive.
c --- only possible with hycom .[ab] file input.
c
      if     (iversn.ge.20) then
        ibadl = 0
        ibads = 0
        do j= 1,jj
          do i= 1,ii
            if     (ip(i,j).eq.1) then
              if     (srfht(i,j).gt.2.0**99) then
                ibads = ibads + 1   ! topo sea, srfht land
*               if     (mod(ibads,100).eq.1) then
*               if     (mod(ibads, 10).eq.1) then
*                 write(lp,*) 'topo sea, srfht land at i,j = ',i,j
*               endif
              endif
            else
              if     (srfht(i,j).lt.2.0**99) then
                ibadl = ibadl + 1   ! topo land, srfht sea
*               if     (mod(ibadl,100).eq.1) then
*               if     (mod(ibadl, 10).eq.1) then
*                 write(lp,*) 'topo land, srfht sea at i,j = ',i,j
*    &                        ,srfht(i,j)
*               endif
              endif
            endif
          enddo
        enddo
        if     (ibads.ne.0) then
          write(lp,*)
          write(lp,*) 'error - wrong bathymetry for this archive file'
          write(lp,*) 'number of topo sea  mismatches = ',ibads
          write(lp,*) 'number of topo land mismatches = ',ibadl
          write(lp,*)
          call flush(lp)
          stop
        endif
        if     (ibadl.ne.0 .and. lhycom) then
          write(lp,*)
*         write(lp,*) 'error - wrong bathymetry for this archive file'
          write(lp,*) 'warning - wrong bathymetry for this archive file'
          write(lp,*) 'number of topo sea  mismatches = ',ibads
          write(lp,*) 'number of topo land mismatches = ',ibadl
          write(lp,*)
          call flush(lp)
*         stop
        endif
      endif !iversn.ge.20
c
      do 3 k=1,kkin
      do 3 j=1,jj
      do 3 i=1,ii
c
c --- convert baroclinic to total velocities by adding barotropic component
c --- note that mean archives already contain total velocity
      if (k.eq.1) then
        if     (iu(i,j).eq.1 .and. artype.eq.1) then
          umix(i,j)=umix(i,j)+ubaro(i,j)  !ignore baclin, always total
        elseif (iu(i,j).ne.1) then
          umix(i,j)=0.
        end if
        if     (iv(i,j).eq.1 .and. artype.eq.1) then
          vmix(i,j)=vmix(i,j)+vbaro(i,j)  !ignore baclin, always total
        elseif (iv(i,j).ne.1) then
          vmix(i,j)=0.
        end if
      endif
      if     (iu(i,j).eq.1) then
        if     (artype.eq.1 .and. .not.baclin) then
          u(i,j,k)=u(i,j,k)+ubaro(i,j)  !total velocity
        elseif (artype.eq.2 .and.      baclin) then
          u(i,j,k)=u(i,j,k)-ubaro(i,j)  !baroclinic velocity
        end if
      else !iu(i,j).ne.1
        u(i,j,k)=0.
      end if
      if     (iv(i,j).eq.1) then
        if     (artype.eq.1 .and. .not.baclin) then
          v(i,j,k)=v(i,j,k)+vbaro(i,j)  !total velocity
        elseif (artype.eq.2 .and.      baclin) then
          v(i,j,k)=v(i,j,k)-vbaro(i,j)  !baroclinic velocity
        end if
      else !iv(i,j).ne.1
        v(i,j,k)=0.
      end if
c
c --- convert layer thickness to meters
      if     (ip(i,j).eq.1) then
        dp(i,j,k)=dp(i,j,k)/9806.
        p(i,j,k+1)=p(i,j,k)+dp(i,j,k)
        if     (artype.eq.3) then
          dpsd(i,j,k)=dpsd(i,j,k)/9806.
        else
          th3d(i,j,k)=th3d(i,j,k)+thbase
        endif
      else
        saln(i,j,k)=flag
        temp(i,j,k)=flag
        th3d(i,j,k)=flag
        dp(i,j,k)=flag
        p(i,j,k+1)=flag
        if     (artype.eq.3) then
          dpsd(i,j,k)=flag
          ke(  i,j,k)=flag
        elseif (artype.eq.2) then
          ke(  i,j,k)=flag
        endif
        do ktr= 1,ntracr
          trcr(i,j,k,ktr)=flag
        enddo
      endif
 3    continue
c
c --- eddy kinetic energy
      if     (artype.eq.3) then
        do k=1,kkin
          do j= 1,jj
            jp1 = min(j+1,jj)
            do i= 1,ii
              if     (ip(i,j).eq.1) then
                if     (i.ne.ii) then
                  ip1 = i+1
                elseif (lperiod) then !i=ii
                  ip1 = 1
                else !i=ii (non-periodic)
                  ip1 = ii
                endif     
c ---           ke = 0.5*( std(u)**2 + std(v)**2 )
                ke(i,j,k)= 0.125*((u(i,j,k)+u(ip1,j,k))**2 +
     &                            (v(i,j,k)+v(i,jp1,k))**2  )
              endif
            enddo !i
          enddo !j
        enddo !k
      endif !std archive
c
c --- w-velocity
      if     (artype.ne.3) then  !not available for std. case
        allocate( w(ii,jj,kk) )
        do j= 1,jj-1
          do i= 1,ii-1
            if     (ip(i,j).eq.1) then
              dudxdn=
     &              (u(i+1,j  ,1)*scuy(i+1,j  )-u(i,j,1)*scuy(i,j))
     &              /(scpx(i,j)*scpy(i,j))
              dvdydn=
     &              (v(i  ,j+1,1)*scvx(i  ,j+1)-v(i,j,1)*scvx(i,j))
     &          /(scpx(i,j)*scpy(i,j))
              w(i,j,1)=0.5*dp(i,j,1)*(dudxdn+dvdydn)
            else
              w(i,j,1) = flag
            endif
          enddo
        enddo
        do i= 1,ii
          w(i ,jj,1) = flag
        enddo
        do j= 1,jj
          w(ii,j ,1) = flag
        enddo
        do k= 2,kkin
          do j= 2,jj
            do i= 2,ii
              if     (iu(i,j).eq.1) then
                dpdx(i,j)=
     &                  (p(i,j,k)*scpy(i,j)-p(i-1,j  ,k)*scpy(i-1,j  ))
     &                  /(scux(i,j)*scuy(i,j))
              else
                dpdx(i,j)=0.0
              endif
            enddo
          enddo
          do j= 2,jj
            do i= 2,ii
              if     (iv(i,j).eq.1) then
                dpdy(i,j)=
     &                  (p(i,j,k)*scpx(i,j)-p(i  ,j-1,k)*scpx(i  ,j-1))
     &                  /(scvx(i,j)*scvy(i,j))
              else
                dpdy(i,j)=0.0
              endif
            enddo
          enddo
          do j= 2,jj-1
            do i= 2,ii-1
              if     (ip(i,j).eq.1) then
                dudxup=
     &                (u(i+1,j  ,k-1)*scuy(i+1,j  )-
     &                 u(i  ,j  ,k-1)*scuy(i  ,j  ))
     &                /(scpx(i,j)*scpy(i,j))
                dvdyup=
     &                (v(i  ,j+1,k-1)*scvx(i  ,j+1)-
     &                 v(i  ,j  ,k-1)*scvx(i  ,j  ))
     &                /(scpx(i,j)*scpy(i,j))
                dudxdn=
     &                (u(i+1,j  ,k  )*scuy(i+1,j  )-
     &                 u(i  ,j  ,k  )*scuy(i  ,j  ))
     &                /(scpx(i,j)*scpy(i,j))
                dvdydn=
     &                (v(i  ,j+1,k  )*scvx(i  ,j+1)-
     &                 v(i  ,j  ,k  )*scvx(i  ,j  ))
     &                /(scpx(i,j)*scpy(i,j))
                w(i,j,k)=w(i,j,k-1)+0.5*(dp(i,j,k-1)*(dudxup+dvdyup)+
     &                                   dp(i,j,k  )*(dudxdn+dvdydn)-
     &                  (u(i  ,j  ,k)-u(i  ,j  ,k-1))*dpdx(i  ,j  )-
     &                  (u(i+1,j  ,k)-u(i+1,j  ,k-1))*dpdx(i+1,j  )-
     &                  (v(i  ,j  ,k)-v(i  ,j  ,k-1))*dpdy(i  ,j  )-
     &                  (v(i  ,j+1,k)-v(i  ,j+1,k-1))*dpdy(i  ,j+1))
              else
                w(i,j,k) = flag
              endif
            enddo
          enddo
          do i= 1,ii
            w(i , 1,k) = flag
            w(i ,jj,k) = flag
          enddo
          do j= 1,jj
            w( 1,j ,k) = flag
            w(ii,j ,k) = flag
          enddo
        enddo !k
c
c ---   w is noisy - smooth at least once.
c
        if     (smooth) then
          do k= 1,kkin
            call msksmoo(w(1,1,k),work)
            call msksmoo(w(1,1,k),work)
          enddo
        else
          do k= 1,kkin
            call msksmoo(w(1,1,k),work)
          enddo
        endif
      endif !artype.ne.3
c
ccc      x=thrufl(107,209,122,212,'(Drake Passage)')
ccc      x=thrufl(41,199,44,201,'(Florida Straits)')
ccc      x=thrufl(63,76,69,94,'(Indonesia)')
c
      do 7 j=1,jj
      jp1 = min(j+1,jj)
      do 7 i=1,ii
      if     (ip(i,j).eq.1) then
        if     (artype.eq.3) then
          if     (i.ne.ii) then
            ip1 = i+1
          elseif (lperiod) then !i=ii
            ip1 = 1
          else !i=ii (non-periodic)
            ip1 = ii
          endif     
c ---     ke = 0.5*( std(u)**2 + std(v)**2 )
          kemix( i,j)=0.125*((umix( i,j)+umix( ip1,j))**2 +
     &                       (vmix( i,j)+vmix( i,jp1))**2  )
          kebaro(i,j)=0.125*((ubaro(i,j)+ubaro(ip1,j))**2 +
     &                       (vbaro(i,j)+vbaro(i,jp1))**2  )
        endif !std archive
        steric(i,j)=steric(i,j)/(thref*98.06)  ! cm
        srfht( i,j)=srfht( i,j)/(thref*98.06)  ! cm
        dpbl(  i,j)=dpbl(  i,j)/9806.          ! m
        dpmixl(i,j)=dpmixl(i,j)/9806.          ! m
        thmix( i,j)=thmix( i,j)+thbase         ! SigmaT
        if     (artype.ne.3) then
          ttrend(i,j)=surflx(i,j)*thref*8.64E4
     &                    /spcifh/max(0.1,dpbl(i,j))    ! deg/day
          strend(i,j)=salflx(i,j)*thref*8.64E4
     &                           /max(0.1,dpbl(i,j))    ! psu/day
          emnp(  i,j)=salflx(i,j)/max(0.1,saln(i,j,1))  ! kg/m^2/s
        else  ! std.dev, archive
          ttrend(i,j)=flag
          strend(i,j)=flag
          emnp(  i,j)=salflx(i,j)/35.00          ! kg/m^2/s
        endif
        if     (covice(i,j).eq.0.0) then
          thkice(i,j)= 0.0
          temice(i,j)=-1.8
        endif
      else
        steric(i,j)=flag
        srfht( i,j)=flag
        surflx(i,j)=flag
        salflx(i,j)=flag
        ttrend(i,j)=flag
        strend(i,j)=flag
          emnp(i,j)=flag
        covice(i,j)=flag
        thkice(i,j)=flag
        temice(i,j)=flag
        dpbl(  i,j)=flag
        dpmixl(i,j)=flag
        tmix( i,j)=flag
        smix( i,j)=flag
        thmix(i,j)=flag
        if     (artype.gt.1) then
          kemix( i,j)=flag
          kebaro(i,j)=flag
        endif
      end if
      if (kkin.eq.1 .or. kkin.lt.kk) then
        if     (ip(i,j).eq.1) then
          p(i,j,kk+1)=depths(i,j)
        else
          p(i,j,kk+1)=flag
        endif
      endif
 7    continue
c
      dpth=0.5*onecm
c
      if (smooth) then
c
c --- smooth mass field variables
c
      call psmoo(temp(1,1,1),work)
      call psmoo(saln(1,1,1),work)
      call psmoo(th3d(1,1,1),work)
      call psmoo(tmix,work)
      call psmoo(smix,work)
      call psmoo(thmix,work)
      do ktr= 1,ntracr
        call psmoo(trcr(1,1,2,ktr),work)
      enddo
c
      do 38 k=2,kkin
c
      do 76 j=1,jj1
      do 76 i=1,ii1
      if     (ip(i,j).eq.1) then
        util1(i,j)=max(onemm,dp(i,j,k))
        temp(i,j,k)=temp(i,j,k)*util1(i,j)
        saln(i,j,k)=saln(i,j,k)*util1(i,j)
        th3d(i,j,k)=th3d(i,j,k)*util1(i,j)
        do ktr= 1,ntracr
          trcr(i,j,k,ktr)=trcr(i,j,k,ktr)*util1(i,j)
        enddo
      else
        temp(i,j,k)=flag
        saln(i,j,k)=flag
        th3d(i,j,k)=flag
        do ktr= 1,ntracr
          trcr(i,j,k,ktr)=flag
        enddo
      end if
 76   continue
c
      call psmoo(util1,      work)
      call psmoo(temp(1,1,k),work)
      call psmoo(saln(1,1,k),work)
      call psmoo(th3d(1,1,k),work)
      do ktr= 1,ntracr
        call psmoo(trcr(1,1,k,ktr),work)
      enddo
c
      do 38 j=1,jj1
      do 38 i=1,ii1
      if     (ip(i,j).eq.1) then
        temp(i,j,k)=temp(i,j,k)/util1(i,j)
        saln(i,j,k)=saln(i,j,k)/util1(i,j)
        th3d(i,j,k)=th3d(i,j,k)/util1(i,j)
        do ktr= 1,ntracr
          trcr(i,j,k,ktr)=trcr(i,j,k,ktr)/util1(i,j)
        enddo
      end if
 38   continue
c
c --- smooth velocity and layer thickness fields
c
      do 30 k=1,kkin
c
      do 31 j=1,jj1
      do 31 i=2,ii1
******if(k.eq.1) umix(i,j)=umix(i,j)*(dpmixl(i,j)+dpmixl(i-1,j))
 31   uflux(i,j)=u(i,j,k)*max(onecm,dp(i,j,k)+dp(i-1,j,k))
c
      do 32 j=2,jj1
      do 32 i=1,ii1
******if(k.eq.1) vmix(i,j)=vmix(i,j)*(dpmixl(i,j)+dpmixl(i,j-1))
 32   vflux(i,j)=v(i,j,k)*max(onecm,dp(i,j,k)+dp(i,j-1,k))
c
      if(k.eq.1) then
        call usmoo(umix,work)
        call vsmoo(vmix,work)
      end if
      call usmoo(uflux,work)
      call vsmoo(vflux,work)
      call psmoo(dp(1,1,k),work)
c --- (warning: smoothed -dp- field unsuitable for deriving interface depths)
c
      do 33 j=1,jj1
      do 33 i=2,ii1
******if(k.eq.1) umix(i,j)=umix(i,j)/(dpmixl(i,j)+dpmixl(i-1,j))
 33   u(i,j,k)=uflux(i,j)/max(onecm,dp(i,j,k)+dp(i-1,j,k))
c
      do 34 j=2,jj1
      do 34 i=1,ii1
******if(k.eq.1) vmix(i,j)=vmix(i,j)/(dpmixl(i,j)+dpmixl(i,j-1))
 34   v(i,j,k)=vflux(i,j)/max(onecm,dp(i,j,k)+dp(i,j-1,k))
c
c --- now smooth layer interfaces and find corresponding -dp- field
      if (k.lt.kkin) call psmo1(p(1,1,k+1),work,p(1,1,kk+1))
c --- now smooth boundary layer thickness and mixed layer base
      if (k.eq.1) then
        call psmo1(dpbl,work,p(1,1,kk+1))
        call psmo1(dpmixl,work,p(1,1,kk+1))
      end if
c
      do 35 j=1,jj1
      do 35 i=1,ii1
      if     (ip(i,j).eq.1) then
        dp(i,j,k)=p(i,j,k+1)-p(i,j,k)
      endif
 35   continue
c
 30   continue
c
      end if			!  smooth = .true.
c
c --- -------------------------
c --- output non-layered fields
c --- -------------------------
c
      k=0
      ltheta=.false.
c
c --- 'areaio' = grid area  I/O unit (0 no I/O) - optional
c --- 'zlayio' = z-layer    I/O unit (0 no I/O) - optional
c --- 'dp00f ' = z-level spacing stretching factor (only for zlayo/=0)
c --- 'botio ' = bathymetry I/O unit (0 no I/O)
      call blkini3(ioin,j,  'areaio','zlayio','botio ')  !read one of three
      if (j.eq.1) then
        if (ioin.gt.0) then
          do j=1,jj
            do i=1,ii
              if (ip(i,j).ne.0) then
                util1(i,j)=scpx(i,j)*scpy(i,j)
              else
                util1(i,j)=flag
              endif
            enddo
          enddo
          call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &                ' grid cell area   ',       ! plot name
     &                'area',                     ! ncdf name
     &                'sea_area',                 ! ncdf standard_name
     &                'm2',                       ! units
     &                k,ltheta, frmt,ioin)
        endif
        call blkini(ioin,'botio ')  !can't have areaio and zlayio
      elseif (j.eq.2) then
        if (ioin.gt.0) then
          call blkinr(dp00f,  
     &               'dp00f ','("blkinr: ",a6," =",f11.4," ")')
          do j=1,jj
            do i=1,ii
              if (ip(i,j).ne.0) then
                util1(i,j)=kk
                 work(i,j)=p(i,j,kk+1)
                do k=2,kk
                  if     (dp(i,j,k).gt.1.1*dp00f*dp(i,j,k-1)) then
                    util1(i,j)=k-1
                     work(i,j)=p(i,j,k)
                    exit
                  endif
                enddo !k
              else
                util1(i,j)=flag
                 work(i,j)=flag
              endif
            enddo
          enddo
          k = 0
          call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &                'no. fixed layers  ',       ! plot name
     &                'zlay',                     ! ncdf name
     &                ' ',                        ! ncdf standard_name
     &                ' ',                        ! units
     &                k,ltheta, frmt,ioin)
          call horout(work,  artype,yrflag,time3,iexpt,lhycom,
     &                'depth fixed layers',       ! plot name
     &                'zldepth',                  ! ncdf name
     &                ' ',                        ! ncdf standard_name
     &                'm',                        ! units
     &                k,ltheta, frmt,ioin)
        endif
        call blkini(ioin,'botio ')  !can't have zlayio and areaio
      endif !areaio:zlayio
      if (ioin.gt.0) then
        do j=1,jj
          do i=1,ii
            util1(i,j)=p(i,j,kk+1)
          enddo
        enddo
        call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &              ' bathymetry       ',       ! plot name
     &              'bathymetry',               ! ncdf name
     &              'sea_floor_depth',          ! ncdf standard_name
     &              'm',                        ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- -------------------
c ---  surface fluxes
c --- -------------------
c
c --- 'flxio ' = surf. heat  flux I/O unit (0 no I/O)
      call blkini(ioin,'flxio ')
      if (ioin.gt.0) then
        call horout(surflx,artype,yrflag,time3,iexpt,lhycom,
     &              ' surf. heat flux  ',                ! plot name
     &              'qtot',                              ! ncdf name (mersea)
     &              'surface_downward_heat_flux_in_air', ! ncdf standard_name
     &              'w/m2',                              ! units
     &              k,ltheta, frmt,ioin)
      endif
c --- 'empio ' = surf. evap-pcip I/O unit (0 no I/O)
      call blkini(ioin,'empio ')
      if (ioin.gt.0) then
        do j=1,jj
          do i=1,ii
            if (ip(i,j).ne.0) then
              util1(i,j)=-emnp(i,j) !water_flux_into_ocean
            else
              util1(i,j)=flag
            endif
          enddo
        enddo
        call horout( util1,artype,yrflag,time3,iexpt,lhycom,
     &              ' surf. water flux ',                 ! plot name
     &              'emp',                                ! ncdf name (mersea)
     &              'water_flux_into_ocean',              ! ncdf standard_name
     &              'kg/m2/s',                            ! units
     &              k,ltheta, frmt,ioin)
      endif
      call blkini2(ioin,i,  'ttrio ','tbfio ')  !read ttrio or tbfio
      if     (i.eq.1) then
c ---   'ttrio ' = surf. temp trend I/O unit (0 no I/O)
        if (ioin.gt.0) then
          call horout(ttrend,artype,yrflag,time3,iexpt,lhycom,
     &                ' surf. temp. trend',         ! plot name
     &                'surface_temperature_trend',  ! ncdf name
     &                ' ',                          ! ncdf standard_name
     &                'degC/day',                   ! units
     &                k,ltheta, frmt,ioin)
        endif
c ---   'strio ' = surf. saln trend I/O unit (0 no I/O)
        call blkini(ioin,'strio ')
        if (ioin.gt.0) then
          call horout(strend,artype,yrflag,time3,iexpt,lhycom,
     &                ' surf. saln. trend',       ! plot name
     &                'surface_salinity_trend',   ! ncdf name
     &                ' ',                        ! ncdf standard_name
     &                'psu/day',                  ! units
     &                k,ltheta, frmt,ioin)
        endif
      else
c ---   'tbfio ' = temp buoyancy flux I/O unit (0 no I/O)
        if (ioin.gt.0) then
          call buoflx(util1, ip, surflx,salflx,
     &                           temp(1,1,1),saln(1,1,1),ii,jj, 1)
          call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &                ' temp. bouy. flux ',         ! plot name
     &                'surface_t_bouyancy_flux',    ! ncdf name
     &                ' ',                          ! ncdf standard_name
     &                'm2/s3',                      ! units
     &                k,ltheta, frmt,ioin)
        endif
c ---   'sbfio ' = saln buoyancy flux I/O unit (0 no I/O)
        call blkini(ioin,'sbfio ')
        if (ioin.gt.0) then
          call buoflx(util1, ip, surflx,salflx,
     &                           temp(1,1,1),saln(1,1,1),ii,jj, 2)
          call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &                ' saln. bouy. flux ',         ! plot name
     &                'surface_s_bouyancy_flux',    ! ncdf name
     &                ' ',                          ! ncdf standard_name
     &                'm2/s3',                      ! units
     &                k,ltheta, frmt,ioin)
        endif
c ---   'abfio ' = tot. buoyancy flux I/O unit (0 no I/O)
        call blkini(ioin,'abfio ')
        if (ioin.gt.0) then
          call buoflx(util1, ip, surflx,salflx,
     &                           temp(1,1,1),saln(1,1,1),ii,jj, 3)
          call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &                ' total bouy. flux ',         ! plot name
     &                'surface_bouyancy_flux',      ! ncdf name
     &                ' ',                          ! ncdf standard_name
     &                'm2/s3',                      ! units
     &                k,ltheta, frmt,ioin)
        endif
      endif
c
c --- -----------------
c --- output ice fields
c --- -----------------
c
c --- 'icvio ' = ice coverage I/O unit (0 no I/O)
      call blkini(ioin,'icvio ')
      if (ioin.gt.0) then
        if     (.not.icegln) then
          write(lp,'(a)') 'error - no Sea Ice available'
          call flush(lp)
          stop
        endif
        call horout(covice,artype,yrflag,time3,iexpt,lhycom,
     &              '     ice coverage ',       ! plot name
     &              'ice_coverage',             ! ncdf name
     &              'sea_ice_area_fraction',    ! ncdf standard_name
     &              ' ',                        ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- 'ithio ' = ice thickness I/O unit (0 no I/O)
      call blkini(ioin,'ithio ')
      if (ioin.gt.0) then
        if     (.not.icegln) then
          write(lp,'(a)') 'error - no Sea Ice available'
          call flush(lp)
          stop
        endif
        call horout(thkice,artype,yrflag,time3,iexpt,lhycom,
     &              '    ice thickness ',       ! plot name
     &              'ice_thickness',            ! ncdf name
     &              'sea_ice_thickness',        ! ncdf standard_name
     &              'm',                        ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- 'ictio ' = ice temperature I/O unit (0 no I/O)
      call blkini(ioin,'ictio ')
      if (ioin.gt.0) then
        if     (.not.icegln) then
          write(lp,'(a)') 'error - no Sea Ice available'
          call flush(lp)
          stop
        endif
        call horout(temice,artype,yrflag,time3,iexpt,lhycom,
     &              '  ice temperature ',       ! plot name
     &              'ice_temperature',          ! ncdf name
     &              ' ',                        ! ncdf standard_name
     &              'degC',                     ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- ---------------------
c --- output surface fields
c --- ---------------------
c
c --- 'atthio' = average density  I/O unit (0 no I/O), OPTIONAL
c --- 'ssshio' = steric     SSH   I/O unit (0 no I/O), OPTIONAL, not with atthio
c --- 'nsshio' = non-steric SSH   I/O unit (0 no I/O), OPTIONAL, after ssshio
c --- 'sshio ' = total      SSH   I/O unit (0 no I/O, -ve MKS for NCOM)
      call blkini3(ioin,j, 'atthio','ssshio','sshio ')  !read one of three
      if (j.eq.1) then !atthio
        if (ioin.gt.0) then
          do j=1,jj
            do i=1,ii
              if (ip(i,j).ne.0) then
                dsumth = 0.d0
                dsumdp = 0.d0
                do k=1,kk
                  dsumth = dsumth + dp(i,j,k)*th3d(i,j,k)
                  dsumdp = dsumdp + dp(i,j,k)
                enddo !k
                util1(i,j)=dsumth/dsumdp - thbase
              else
                util1(i,j)=flag
              endif
            enddo
          enddo
          k = 0
          call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &                'average HYCOM th3d',       ! plot name
     &                'avth',                     ! ncdf name
     &                ' ',                        ! ncdf standard_name
     &                'kg/m^3',                   ! units
     &                k,ltheta, frmt,ioin)
        endif
        call blkini(ioin,'sshio ')
      elseif (j.eq.2) then !ssshio
        if (ioin.gt.0) then
          if     (.not.lsteric) then
            write(lp,'(a)') 'error - no Steric SSH available'
            call flush(lp)
            stop
          endif
          do j=1,jj
            do i=1,ii
              if (ip(i,j).ne.0) then
                util1(i,j)=0.01*steric(i,j)  !MKS
              else
                util1(i,j)=flag
              endif
            enddo
          enddo
          call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &                ' steric SSH       ',       ! plot name
     &                'steric_ssh',               ! ncdf
     &                ' ',                        ! ncdf standard_name
     &                'm',                        ! units
     &                k,ltheta, frmt,ioin)
        endif !ioin
        call blkini2(ioin,j, 'nsshio','sshio ')  !read one of two
        if (j.eq.1) then !nsshio
          if (ioin.gt.0) then
            if     (.not.lsteric) then
              write(lp,'(a)') 'error - no Steric SSH available'
              call flush(lp)
              stop
            endif
            do j=1,jj
              do i=1,ii
                if (ip(i,j).ne.0) then
                  util1(i,j)=0.01*(srfht(i,j)-steric(i,j))  !MKS
                else
                  util1(i,j)=flag
                endif
              enddo
            enddo
            call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &                  ' non-steric SSH   ',       ! plot name
     &                  'nonsteric_ssh',            ! ncdf
     &                  ' ',                        ! ncdf standard_name
     &                  'm',                        ! units
     &                  k,ltheta, frmt,ioin)
          endif !ioin
          call blkini(ioin,'sshio ')
        endif !nsshio
      endif !atthio:ssshio
c --- sshio
      if (ioin.gt.0) then
        do j=1,jj
          do i=1,ii
            if (ip(i,j).ne.0) then
              util1(i,j)=0.01*srfht(i,j)  !MKS
            else
              util1(i,j)=flag
            endif
          enddo
        enddo
        call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &              ' sea surf. height ',       ! plot name
     &              'ssh',                      ! ncdf name (mersea)
     &              'sea_surface_elevation',    ! ncdf standard_name
     &              'm',                        ! units
     &              k,ltheta, frmt,ioin)
      elseif (ioin.lt.0) then
        do j=1,jj
          do i=1,ii
            if (ip(i,j).ne.0) then
              util1(i,j)=0.01*srfht(i,j)  !MKS
            else
              util1(i,j)=0.0
            endif
          enddo
        enddo
        call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &              ' sea surf. height ',       ! plot name
     &              'ssh',                      ! ncdf name (mersea)
     &              'sea_surface_elevation',    ! ncdf standard_name
     &              'm',                        ! units
     &              k,ltheta, frmt,-ioin)
      endif
c
      if     (artype.gt.1) then  ! mean or std. archive
c ---   'bkeio ' = baro. kinetic energy I/O unit (0 no I/O)
        call blkini(ioin,'bkeio ')
        if (ioin.gt.0) then
          call horout(kebaro,artype,yrflag,time3,iexpt,lhycom,
     &                '    baro.k.e./mass',                  ! plot name
     &                'barotropic_kinetic_energy_per_mass',  ! ncdf name
     &                ' ',                          ! ncdf standard_name
     &                'm2/s2',                               ! units
     &                k,ltheta, frmt,ioin)
        endif
      endif  ! mean or std. archive
c
c --- 'buvio ' = baro. u-velocity I/O unit (0 no I/O, -ve on u-grid for NCOM)
      call blkini2(ioin,i,'buvio ','bsfio ')
      if     (i.eq.1) then
        barouv = .true.
      else
        barouv = .false.
        iobsf = ioin
      endif
      if     (barouv) then
        if (ioin.gt.0) then
          do j=1,jj
            jm1 = max(j-1, 1)
            jp1 = min(j+1,jj)
            do i=1,ii
              if (ip(i,j).ne.0) then  !may be approximate at i=ii and j=jj
                if     (i.ne.1) then
                  im1 = i-1
                elseif (lperiod) then !i=1
                  im1 = ii
                else !i=1 (non-periodic)
                  im1 =  1
                endif
                if     (i.ne.ii) then
                  ip1 = i+1
                elseif (lperiod) then !i=ii
                  ip1 = 1
                else !i=ii (non-periodic)
                  ip1 = ii
                endif
c ---           Make transport accurate at the expense of velocity
                if     (xyward .or. pang(i,j).eq.0.0) then
                  util1(i,j)=(ubaro(i,  j)*min(p(i,  j,kk+1),
     &                                         p(im1,j,kk+1) )+
     &                        ubaro(ip1,j)*min(p(ip1,j,kk+1),
     &                                         p(i,  j,kk+1) ) )
     &                       /max(2.0*p(i,j,kk+1),onemm)
                else
c ---             Rotate from Xward and Yward to Eastward
                  util1(i,j)=
     &              (cos( pang(i,j))*(ubaro(i,  j)*min(p(i,  j,kk+1),
     &                                                 p(im1,j,kk+1) )+
     &                                ubaro(ip1,j)*min(p(ip1,j,kk+1),
     &                                                 p(i,  j,kk+1) ) )
     &              +sin(-pang(i,j))*(vbaro(i,j  )*min(p(i,j  ,kk+1),
     &                                                 p(i,jm1,kk+1) )+
     &                                vbaro(i,jp1)*min(p(i,jp1,kk+1),
     &                                                 p(i,j  ,kk+1) ) )
     &              )/max(2.0*p(i,j,kk+1),onemm)
                endif !pang
              else
                util1(i,j)=flag
              endif
            enddo !i
          enddo !j
          if     (xyward) then
          call horout(util1,artype,yrflag,time3,iexpt,lhycom,
     &                '    baro. u-vel.  ',         ! plot name
     &                'u_barotropic_velocity',      ! ncdf name
     &            'barotropic_sea_water_x_velocity',! ncdf standard_name
     &                'm/s',                        ! units
     &                k,ltheta, frmt,ioin)
          else
          call horout(util1,artype,yrflag,time3,iexpt,lhycom,
     &                '    baro. u-vel.  ',         ! plot name
     &                'u_barotropic_velocity',      ! ncdf name
     &     'barotropic_eastward_sea_water_velocity',! ncdf standard_name
     &                'm/s',                        ! units
     &                k,ltheta, frmt,ioin)
          endif !xyward:else
        elseif (ioin.lt.0) then
          do j=1,jj
            do i=1,ii
              if (iu(i,j).ne.0) then
                util1(i,j)=ubaro(i,j)
              else
                util1(i,j)=0.0
              endif
            enddo
          enddo
          call horout(util1,artype,yrflag,time3,iexpt,lhycom,
     &                '    baro. u-vel.  ',         ! plot name
     &                'u_barotropic_velocity',      ! ncdf name
     &                ' ',                          ! ncdf standard_name
     &                'm/s',                        ! units
     &                k,ltheta, frmt,-ioin)
        endif !ioin
c
c ---   'bvvio ' = baro. v-velocity I/O unit (0 no I/O, -ve on v-grid for NCOM)
        call blkini(ioin,'bvvio ')
        if (ioin.gt.0) then
          do j=1,jj
            jm1 = max(j-1, 1)
            jp1 = min(j+1,jj)
            do i=1,ii
              if (ip(i,j).ne.0) then  !may be approximate at i=ii and j=jj
                if     (xyward .or. pang(i,j).eq.0.0) then
                  util1(i,j)=(vbaro(i,j  )*min(p(i,j  ,kk+1),
     &                                         p(i,jm1,kk+1) )+
     &                        vbaro(i,jp1)*min(p(i,jp1,kk+1),
     &                                         p(i,j  ,kk+1) ) )
     &                       /max(2.0*p(i,j,kk+1),onemm)
                else
c ---             Rotate from Xward and Yward to Eastward
                  if     (i.ne.ii) then
                    ip1 = i+1
                  elseif (lperiod) then !i=ii
                    ip1 = 1
                  else !i=ii (non-periodic)
                    ip1 = ii
                  endif
                  if     (i.ne.1) then
                    im1 = i-1
                  elseif (lperiod) then !i=1
                    im1 = ii
                  else !i=1 (non-periodic)
                    im1 =  1
                  endif
                  util1(i,j)=
     &              (cos( pang(i,j))*(vbaro(i,j  )*min(p(i,j  ,kk+1),
     &                                                 p(i,jm1,kk+1) )+
     &                                vbaro(i,jp1)*min(p(i,jp1,kk+1),
     &                                                 p(i,j  ,kk+1) ) )
     &              -sin(-pang(i,j))*(ubaro(i,  j)*min(p(i,  j,kk+1),
     &                                                 p(im1,j,kk+1) )+
     &                                ubaro(ip1,j)*min(p(ip1,j,kk+1),
     &                                                 p(i,  j,kk+1) ) )
     &              )/max(2.0*p(i,j,kk+1),onemm)
                endif !pang
              else
                util1(i,j)=flag
              endif
            enddo
          enddo
          if     (xyward) then
          call horout(util1,artype,yrflag,time3,iexpt,lhycom,
     &                '    baro. v-vel.  ',         ! plot name
     &                'v_barotropic_velocity',      ! ncdf name
     &            'barotropic_sea_water_y_velocity',! ncdf standard_name
     &                'm/s',                        ! units
     &                k,ltheta, frmt,ioin)
          else
          call horout(util1,artype,yrflag,time3,iexpt,lhycom,
     &                '    baro. v-vel.  ',         ! plot name
     &                'v_barotropic_velocity',      ! ncdf name
     &    'barotropic_northward_sea_water_velocity',! ncdf standard_name
     &                'm/s',                        ! units
     &                k,ltheta, frmt,ioin)
          endif !xyward:else
        elseif (ioin.lt.0) then
          do j=1,jj
            do i=1,ii
              if (iv(i,j).ne.0) then
                util1(i,j)=vbaro(i,j)
              else
                util1(i,j)=0.0
              endif
            enddo
          enddo
          call horout(util1,artype,yrflag,time3,iexpt,lhycom,
     &                '    baro. v-vel.  ',         ! plot name
     &                'v_barotropic_velocity',      ! ncdf name
     &                ' ',                          ! ncdf standard_name
     &                'm/s',                        ! units
     &                k,ltheta, frmt,-ioin)
        endif !ioin
c
c ---   'bspio ' = baro. speed I/O unit (0 no I/O)
        call blkini(ioin, 'bspio ')
        if (ioin.gt.0) then
          do j=1,jj
            do i=1,ii
              if (ip(i,j).ne.0 .and. i.lt.ii .and. j.lt.jj) then
                util1(i,j)=0.5*sqrt( (ubaro(i,j)+ubaro(i+1,j))**2 +
     &                               (vbaro(i,j)+vbaro(i,j+1))**2  )
              else
                util1(i,j)=flag
              endif
            enddo
          enddo
          call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &                'barotropic speed ',        ! plot name
     &                'barotropic_speed',         ! ncdf name
     &     'barotropic_sea_water_speed',          ! ncdf standard_name
     &                'm/s',                      ! units
     &                k,ltheta, frmt,ioin)
        endif !ioin
c
      endif !barouv
c
c --- 'bsfio ' = barotropic strmfn. I/O unit (0 no I/O)
      if     (barouv) then
        call blkini(ioin,'bsfio ')
      else
        ioin = iobsf
      endif !barouv:else
      if (ioin.gt.0) then
c
c ---   calculate strmf on the Q grid, mostly using vbaro.
c ---   note that strmf(ii,jj) is always 0.0, but streamfunctions
c ---    are arbitraty w.r.t. a constant offset anyway
        do j=jj,1,-1
          jm1 = max(1,j-1)  !not accurate for j=1, when using a subregion.
          i   = ii
          im1 = ii-1
          if (iu(i,j).eq.1) then
            ubi = ubaro(i,j)*min(p(i,j,kk+1),p(im1,j,kk+1))
          else
            ubi = 0.0
          endif
          if     (j.eq.jj) then
            strmfu = 0.0
          else
            strmfu = strmfu + ubi*scux(i,j)
          endif
          strmf(i,j) = strmfu
          strmft     = strmfu
          do i=ii-1,1,-1
            if (iv(i,j).eq.1) then
              vbi = vbaro(i,j)*min(p(i,j,kk+1),p(i,jm1,kk+1))
            else
              vbi = 0.0
            endif
            strmft = strmft - vbi*scvy(i,j)
            strmf(i,j) = strmft  !m^3/s
          enddo !i
        enddo !j
c
c ---   interpolate from q-grid to p-grid.
        do j=1,jj
          do i=1,ii
            if (ip(i,j).ne.0 .and. i.lt.ii .and. j.lt.jj) then
              s1=0.0
              s2=0.0
              if     (iq(i,  j)  .eq.1) then
                s1 = s1 + 1.0
                s2 = s2 + strmf(i,  j)
              endif
              if     (iq(i+1,j)  .eq.1) then
                s1 = s1 + 1.0
                s2 = s2 + strmf(i+1,j)
              endif
              if     (iq(i,  j+1).eq.1) then
                s1 = s1 + 1.0
                s2 = s2 + strmf(i,  j+1)
              endif
              if     (iq(i+1,j+1).eq.1) then
                s1 = s1 + 1.0
                s2 = s2 + strmf(i+1,j+1)
              endif
              if     (s1.ne.0.0) then
                util1(i,j)=s2/s1
              else
                util1(i,j)=flag
              endif
            else
              util1(i,j)=flag
            endif
          enddo
        enddo
c
ccc     call zebra(util1,ii,ii,jj)
ccc     write (*,'('' shown above: barotropic stream function'')')
c
        call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &              'barotr. strmf. (V)',              ! plot name
     &              'bfsd_v',                          ! ncdf name
     &              'ocean_barotropic_streamfunction', ! ncdf standard_name
     &              'm3/s',                            ! units
     &              k,ltheta, frmt,ioin)
c
c ---   calculate strmf on the Q grid, mostly using ubaro.
c ---   note that strmf(ii,jj) is always 0.0, but streamfunctions
c ---    are arbitraty w.r.t. a constant offset anyway
        do i=ii,1,-1
          im1 = max(1,i-1) !not accurate for i=1, when using a subregion.
          j   = jj
          jm1 = jj-1
          if (iv(i,j).eq.1) then
            vbi = vbaro(i,j)*min(p(i,j,kk+1),p(i,jm1,kk+1))
          else
            vbi = 0.0
          endif
          if     (i.eq.ii) then
            strmfv = 0.0
          else
            strmfv = strmfv - vbi*scvy(i,j)
          endif
          strmf(i,j) = strmfv
          strmft     = strmfv
          do j=jj-1,1,-1
            if (iu(i,j).eq.1) then
              ubi = ubaro(i,j)*min(p(i,j,kk+1),p(im1,j,kk+1))
            else
              ubi = 0.0
            endif
            strmft     = strmft + ubi*scux(i,j)
            strmf(i,j) = strmft  !m^3/s
          enddo !i
        enddo !j
c
c ---   interpolate from q-grid to p-grid.
        do j=1,jj
          do i=1,ii
            if (ip(i,j).ne.0 .and. i.lt.ii .and. j.lt.jj) then
              s1=0.0
              s2=0.0
              if     (iq(i,  j)  .eq.1) then
                s1 = s1 + 1.0
                s2 = s2 + strmf(i,  j)
              endif
              if     (iq(i+1,j)  .eq.1) then
                s1 = s1 + 1.0
                s2 = s2 + strmf(i+1,j)
              endif
              if     (iq(i,  j+1).eq.1) then
                s1 = s1 + 1.0
                s2 = s2 + strmf(i,  j+1)
              endif
              if     (iq(i+1,j+1).eq.1) then
                s1 = s1 + 1.0
                s2 = s2 + strmf(i+1,j+1)
              endif
              if     (s1.ne.0.0) then
                util1(i,j)=s2/s1
              else
                util1(i,j)=flag
              endif
            else
              util1(i,j)=flag
            endif
          enddo
        enddo
c
ccc     call zebra(util1,ii,ii,jj)
ccc     write (*,'('' shown above: barotropic stream function'')')
c
        call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &              'barotr. strmf. (U)',              ! plot name
     &              'bfsd_u',                          ! ncdf name
     &              'ocean_barotropic_streamfunction', ! ncdf standard_name
     &              'm3/s',                            ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- -------------------------
c --- output mixed layer fields
c --- -------------------------
c
c --- 'uvmio ' = mixed layer u-velocity I/O unit (0 no I/O)
      call blkini(ioin, 'uvmio ')
      if (ioin.gt.0) then
        do j=1,jj
          do i=1,ii
            if (ip(i,j).ne.0 .and. i.lt.ii) then
              util1(i,j)=0.5*(umix(i,j)+umix(i+1,j))
            else
              util1(i,j)=flag
            endif
          enddo
        enddo
        call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &              'mix.l. u-velocity ',       ! plot name
     &              'mixed_layer_u_velocity',   ! ncdf name
     &              ' ',                        ! ncdf standard_name
     &              'm/s',                      ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- 'vvmio ' = mixed layer v-velocity I/O unit (0 no I/O)
      call blkini(ioin, 'vvmio ')
      if (ioin.gt.0) then
        do j=1,jj
          do i=1,ii
            if (ip(i,j).ne.0 .and. j.lt.jj) then
              util1(i,j)=0.5*(vmix(i,j)+vmix(i,j+1))
            else
              util1(i,j)=flag
            endif
          enddo
        enddo
        call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &              ' mixl. v-velocity ',       ! plot name
     &              'mixed_layer_v_velocity',   ! ncdf name
     &              ' ',                        ! ncdf standard_name
     &              'm/s',                      ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- 'spmio ' = mixed layer speed I/O unit (0 no I/O)
      call blkini(ioin, 'spmio ')
      if (ioin.gt.0) then
        do j=1,jj
          do i=1,ii
            if (ip(i,j).ne.0 .and. i.lt.ii .and. j.lt.jj) then
              util1(i,j)=0.5*sqrt( (umix(i,j)+umix(i+1,j))**2 +
     &                             (vmix(i,j)+vmix(i,j+1))**2  )
            else
              util1(i,j)=flag
            endif
          enddo
        enddo
        call horout(util1, artype,yrflag,time3,iexpt,lhycom,
     &              'mixed-layer speed ',       ! plot name
     &              'mixed_layer_speed',        ! ncdf name
     &              ' ',                        ! ncdf standard_name
     &              'm/s',                      ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- 'bltio ' = bnd. lay. thick. I/O unit (0 no I/O)
      call blkini(ioin,'bltio ')
      if (ioin.gt.0) then
        call horout(dpbl,  artype,yrflag,time3,iexpt,lhycom,
     &              'bnd.layr.thickness',                ! plot name
     &              'surface_boundary_layer_thickness',  ! ncdf name
     &              ' ',                        ! ncdf standard_name
     &              'm',                                 ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- 'mltio ' = mix. lay. thick. I/O unit (0 no I/O)
      call blkini(ioin,'mltio ')
      if (ioin.gt.0) then
        call horout(dpmixl,artype,yrflag,time3,iexpt,lhycom,
     &              'mix.layr.thickness',          ! plot name
     &              'mixed_layer_thickness',       ! ncdf name
     &              'ocean_mixed_layer_thickness', ! ncdf standard_name
     &              'm',                           ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- 'sstio ' = mix. lay. temp.  I/O unit (0 no I/O)
      call blkini(ioin,'sstio ')
      if (ioin.gt.0) then
        call horout(tmix,  artype,yrflag,time3,iexpt,lhycom,
     &              'mix.layr.temp     ',       ! plot name
     &              'mixed_layer_temperature',  ! ncdf name
     &              ' ',                        ! ncdf standard_name
     &              'degC',                     ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- 'sssio ' = mix. lay. saln.  I/O unit (0 no I/O)
      call blkini(ioin,'sssio ')
      if (ioin.gt.0) then
        call horout(smix,  artype,yrflag,time3,iexpt,lhycom,
     &              'mix.layr.saln     ',       ! plot name
     &              'mixed_layer_salinity',     ! ncdf name
     &              ' ',                        ! ncdf standard_name
     &              'psu',                      ! units
     &              k,ltheta, frmt,ioin)
      endif
c
c --- 'ssdio ' = mix. lay. dens.  I/O unit (0 no I/O)
      call blkini(ioin,'ssdio ')
      if (ioin.gt.0) then
        call horout(thmix, artype,yrflag,time3,iexpt,lhycom,
     &              'mix.layr.dens     ',       ! plot name
     &              'mixed_layer_density',      ! ncdf name
     &              ' ',                        ! ncdf standard_name
     &              'sigma',                    ! units
     &              k,ltheta, frmt,ioin)
      endif
c
      if     (artype.gt.1) then  ! mean or std. archive
c ---   'mkeio ' = m.l. kinetic energy I/O unit (0 no I/O)
        call blkini(ioin,'mkeio ')
        if (ioin.gt.0) then
          call horout(kemix, artype,yrflag,time3,iexpt,lhycom,
     &                '    mixl.k.e./mass',                   ! plot name
     &                'mixed_layer_kinetic_energy_per_mass',  ! ncdf name
     &                ' ',                           ! ncdf standard_name
     &                'm2/s2',                                ! units
     &                k,ltheta, frmt,ioin)
        endif
      endif  ! mean or std. archive
c
c --- ----------------------
c --- output selected layers
c --- ----------------------
c
      do  !layer loop
c
c ---   'kf    ' = first output layer (=0 end output; <0 label with layer #)
c ---   'kl    ' = last  output layer
        call blkini(kin,'kf    ')
        ltheta = kin.gt.0
        kf     = abs(kin)
        if     (kf.eq.0) then
          exit
        endif
        call blkini(kl, 'kl    ')
        kl = abs(kl)
        if     (kl.gt.kkin) then
          write(lp,'(a)') 'error - kl larger than kdm'
          exit
        elseif (kl.lt.kf) then
          write(lp,'(a)') 'error - kl smaller than kf'
          exit
        endif
c
c ---   -------------------
c ---   output layer velocity
c ---   -------------------
c
c ---   'uvlio ' = u-velocity I/O unit (0 no I/O, -ve on u-grid for NCOM)
        call blkini(ioin, 'uvlio ')
        if (ioin.gt.0) then
          do k= kf,kl
          do j=1,jj
            jp1 = min(j+1,jj)
            do i=1,ii
              if (ip(i,j).ne.0) then  !may be approximate at i=ii and j=jj
                if     (i.ne.ii) then
                  ip1 = i+1
                elseif (lperiod) then !i=ii
                  ip1 = 1
                else !i=ii (non-periodic)
                  ip1 = ii
                endif
                if     (xyward .or. pang(i,j).eq.0.0) then
                  utilk(i,j,k)=     0.5*(u(i,j,k)+u(ip1,j,k))
                else
c ---             Rotate from Xward and Yward to Eastward
                  utilk(i,j,k)=
     &              cos( pang(i,j))*0.5*(u(i,j,k)+u(ip1,j,k)) +
     &              sin(-pang(i,j))*0.5*(v(i,j,k)+v(i,jp1,k))
                endif !pang
                if (mthin) then
                  if (p(i,j,k)+onecm.gt.p(i,j,k+1)) then
                    utilk(i,j,k)=flag
                  endif
                else
                  if (p(i,j,k)+onecm.gt.p(i,j,kk+1)) then
                    utilk(i,j,k)=flag
                  endif
                endif
              else
                utilk(i,j,k)=flag
              endif
            enddo
          enddo
          enddo
          if     (baclin) then
          if     (xyward) then
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' u-b.vel.',                   ! plot name
     &                'u_baroclinic_velocity',       ! ncdf name
     &            'baroclinic_sea_water_x_velocity', ! ncdf standard_name
     &                'm/s',                         ! units
     &                kf,kl,ltheta, frmt,ioin)
          else
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' u-b.vel.',                   ! plot name
     &                'u_baroclinic_velocity',       ! ncdf name
     &     'baroclinic_eastward_sea_water_velocity', ! ncdf standard_name
     &                'm/s',                         ! units
     &                kf,kl,ltheta, frmt,ioin)
          endif !xyward:else
          else !total velocity
          if     (xyward) then
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' u-veloc.',                   ! plot name
     &                'u_velocity',                  ! ncdf name
     &                'sea_water_x_velocity',        ! ncdf standard_name
     &                'm/s',                         ! units
     &                kf,kl,ltheta, frmt,ioin)
          else
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' u-veloc.',                   ! plot name
     &                'u_velocity',                  ! ncdf name
     &                'eastward_sea_water_velocity', ! ncdf standard_name
     &                'm/s',                         ! units
     &                kf,kl,ltheta, frmt,ioin)
          endif !xyward:else
          endif !baclin:else
        elseif (ioin.lt.0) then
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              if (iu(i,j).ne.0) then
                utilk(i,j,k)=u(i,j,k)
              else
                utilk(i,j,k)=0.0
              endif
            enddo
          enddo
          enddo
          if     (baclin) then
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' u-b.vel.',                   ! plot name
     &                'u_baroclinic_velocity',       ! ncdf name
     &                ' ',                           ! ncdf standard_name
     &                'm/s',                         ! units
     &                kf,kl,ltheta, frmt,-ioin)
          else !total velocity
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' u-veloc.',                   ! plot name
     &                'u_velocity',                  ! ncdf name
     &                ' ',                           ! ncdf standard_name
     &                'm/s',                         ! units
     &                kf,kl,ltheta, frmt,-ioin)
          endif
        endif
c
c ---   'vvlio ' = v-velocity I/O unit (0 no I/O, -ve on v-grid for NCOM)
        call blkini(ioin, 'vvlio ')
        if (ioin.gt.0) then
          do k= kf,kl
          do j=1,jj
            jp1 = min(j+1,jj)
            do i=1,ii
              if (ip(i,j).ne.0) then  !may be approximate at i=ii and j=jj
                if     (xyward .or. pang(i,j).eq.0.0) then
                  utilk(i,j,k)=     0.5*(v(i,j,k)+v(i,jp1,k))
                else
c ---             Rotate from Xward and Yward to Northward
                  if     (i.ne.ii) then
                    ip1 = i+1
                  elseif (lperiod) then !i=ii
                    ip1 = 1
                  else !i=ii (non-periodic)
                    ip1 = ii
                  endif
                  utilk(i,j,k)=
     &              cos( pang(i,j))*0.5*(v(i,j,k)+v(i,jp1,k)) -
     &              sin(-pang(i,j))*0.5*(u(i,j,k)+u(ip1,j,k))
                endif !pang
                if (mthin) then
                  if (p(i,j,k)+onecm.gt.p(i,j,k+1)) then
                    utilk(i,j,k)=flag
                  endif
                else
                  if (p(i,j,k)+onecm.gt.p(i,j,kk+1)) then
                    utilk(i,j,k)=flag
                  endif
                endif
              else
                utilk(i,j,k)=flag
              endif
            enddo
          enddo
          enddo
          if     (baclin) then
          if     (xyward) then
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' v-b.vel.',                    ! plot name
     &                'v_baroclinic_velocity',        ! ncdf name
     &             'baroclinic_sea_water_y_velocity', ! ncdf standard_name
     &                'm/s',                          ! units
     &                kf,kl,ltheta, frmt,ioin)
          else
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' v-b.vel.',                    ! plot name
     &                'v_baroclinic_velocity',        ! ncdf name
     &     'baroclinic_northward_sea_water_velocity', ! ncdf standard_name
     &                'm/s',                          ! units
     &                kf,kl,ltheta, frmt,ioin)
          endif !xyward:else
          else !total velocity
          if     (xyward) then
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' v-veloc.',                    ! plot name
     &                'v_velocity',                   ! ncdf name
     &                'sea_water_y_velocity',         ! ncdf standard_name
     &                'm/s',                          ! units
     &                kf,kl,ltheta, frmt,ioin)
          else
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' v-veloc.',                    ! plot name
     &                'v_velocity',                   ! ncdf name
     &                'northward_sea_water_velocity', ! ncdf standard_name
     &                'm/s',                          ! units
     &                kf,kl,ltheta, frmt,ioin)
          endif !xyward:else
          endif !baclin:else
        elseif (ioin.lt.0) then
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              if (iv(i,j).ne.0) then
                utilk(i,j,k)=v(i,j,k)
              else
                utilk(i,j,k)=0.0
              endif
            enddo
          enddo
          enddo
          if     (baclin) then
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' v-b.vel.',                ! plot name
     &                'v_baroclinic_velocity',    ! ncdf name
     &                ' ',                        ! ncdf standard_name
     &                'm/s',                      ! units
     &                kf,kl,ltheta, frmt,-ioin)
          else !total velocity
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' v-veloc.',                ! plot name
     &                'v_velocity',               ! ncdf name
     &                ' ',                        ! ncdf standard_name
     &                'm/s',                      ! units
     &                kf,kl,ltheta, frmt,-ioin)
          endif
        endif
c
c ---   'splio ' = speed I/O unit (0 no I/O)
        call blkini(ioin, 'splio ')
        if (ioin.gt.0) then
          do k= kf,kl
          do j=1,jj
            jp1 = min(j+1,jj)
            do i=1,ii
              if (ip(i,j).ne.0) then  !may be approximate at i=ii and j=jj
                if     (i.ne.ii) then
                  ip1 = i+1
                elseif (lperiod) then !i=ii
                  ip1 = 1
                else !i=ii (non-periodic)
                  ip1 = ii
                endif
                utilk(i,j,k)=0.5*sqrt( (u(i,j,k)+u(ip1,j,k))**2 +
     &                                 (v(i,j,k)+v(i,jp1,k))**2  )
                if (mthin) then
                  if (p(i,j,k)+onecm.gt.p(i,j,k+1)) then
                    utilk(i,j,k)=flag
                  endif
                else
                  if (p(i,j,k)+onecm.gt.p(i,j,kk+1)) then
                    utilk(i,j,k)=flag
                  endif
                endif
              else
                utilk(i,j,k)=flag
              endif
            enddo
          enddo
          enddo
          if     (baclin) then
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' bcl.spd.',                ! plot name
     &      'baroclinic_speed',                   ! ncdf name
     &     'baroclinic_sea_water_speed',          ! ncdf standard_name
     &                'm/s',                      ! units
     &                kf,kl,ltheta, frmt,ioin)
          else !total velocity
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' speed   ',                ! plot name
     &                'speed',                    ! ncdf name
     &                'sea_water_speed',          ! ncdf standard_name
     &                'm/s',                      ! units
     &                kf,kl,ltheta, frmt,ioin)
          endif
        endif
c
c --- -----------------------
c --- w-velocity
c --- -----------------------
c
c --- 'wvlio ' = w-velocity I/O unit (0 no I/O)
        call blkini2(ioin,i,'wvlio ','infio ')
        if     (i.eq.1) then
          infio = -99
        else
          infio = max(ioin,-1)
          ioin  = 0
        endif
        if (ioin.gt.0 .and. artype.ne.3) then  !not available for std. case
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              utilk(i,j,k)=w(i,j,k)
              if (mthin) then
                if (p(i,j,k)+onecm.gt.p(i,j,k+1)) then
                  utilk(i,j,k)=flag
                endif
              else
                if (p(i,j,k)+onecm.gt.p(i,j,kk+1)) then
                  utilk(i,j,k)=flag
                endif
              endif
            enddo
          enddo
          enddo
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' w-veloc.',                   ! plot name
     &                'w_velocity',                  ! ncdf name
     &                'upward_sea_water_velocity',   ! ncdf standard_name
     &                'm/s',                         ! units
     &                kf,kl,ltheta, frmt,ioin)
        endif
c
c ---   --------------------
c ---   interface depth
c ---   --------------------
c
c ---   'infio ' = intf. k depth  I/O unit (0 no I/O)
        if     (infio.eq.-99) then
          call blkini(ioin,'infio ')
        else
          ioin = infio
        endif
        if (ioin.gt.0 .and. artype.ne.3) then    !not available for std. case
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              utilk(i,j,k)=p(i,j,k+1)
            enddo
          enddo
          enddo
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                '  i.depth',                ! plot name
     &                'interface_depth',          ! ncdf name
     &                ' ',                        ! ncdf standard_name
     &                'm',                        ! units
     &                kf,kl,ltheta, frmt,ioin)
        endif
c
c ---   --------------------
c ---   layer thickness
c ---   --------------------
c
c ---   'thkio ' = lay.  k thick. I/O unit (0 no I/O)
        call blkini(ioin,'thkio ')
        if (ioin.gt.0) then
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              if     (artype.ne.3) then
                utilk(i,j,k)=dp(  i,j,k)
              else
                utilk(i,j,k)=dpsd(i,j,k)  !artype==3
              endif
              if (p(i,j,k)+onecm.gt.p(i,j,kk+1)) then
                utilk(i,j,k)=flag
              endif
            enddo
          enddo
          enddo
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                '  thknss ',                ! plot name
     &                'layer_thickness',          ! ncdf name
     &                ' ',                        ! ncdf standard_name
     &                'm',                        ! units
     &                kf,kl,ltheta, frmt,ioin)
        endif
c
c ---   ----------------
c ---   temperature
c ---   ----------------
c
c ---   'temio ' = layer k temp I/O unit (0 no I/O, -ve MKS for NCOM)
        call blkini(ioin,'temio ')
        if (ioin.gt.0) then
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              utilk(i,j,k)=temp(i,j,k)
              if (mthin) then
                if (p(i,j,k)+onecm.gt.p(i,j,k+1)) then
                  utilk(i,j,k)=flag
                endif
              else
                if (p(i,j,k)+onecm.gt.p(i,j,kk+1)) then
                  utilk(i,j,k)=flag
                endif
              endif
            enddo
          enddo
          enddo
          if     (kf.ne.1 .or. kf.ne.kl) then
            call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                  '  temp   ',                       ! plot name
     &                  'layer_temperature',               ! ncdf name
     &                  'sea_water_potential_temperature', ! ncdf standard_name
     &                  'degC',                            ! units
     &                  kf,kl,ltheta, frmt,ioin)
          else !kf==kl==1
            call horout(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                  ' sea surf. temp.  ',       ! plot name
     &                  'sst',                      ! ncdf name (mersea)
     &                  'sea_surface_temperature',  ! ncdf standard_name
     &                  'degC',                     ! units
     &                  0,ltheta, frmt,ioin)
          endif
        elseif (ioin.lt.0) then
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              if (ip(i,j).ne.0) then
                utilk(i,j,k)=temp(i,j,k)
*               if (p(i,j,k).ge.p(i,j,kk+1)) then
*                 utilk(i,j,k)=0.0
*               endif
              else
                utilk(i,j,k)=0.0
              endif
            enddo
          enddo
          enddo
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                '  temp   ',                       ! plot name
     &                'layer_temperature',               ! ncdf name
     &                'sea_water_potential_temperature', ! ncdf standard_name
     &                'degC',                            ! units
     &                kf,kl,ltheta, frmt,-ioin)
        endif
c
c ---   -------------
c ---   salinity
c ---   -------------
c
c ---   'salio ' = lay.  k saln. I/O unit (0 no I/O)
        call blkini(ioin,'salio ')
        if (ioin.gt.0) then
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              utilk(i,j,k)=saln(i,j,k)
              if (mthin) then
                if (p(i,j,k)+onecm.gt.p(i,j,k+1)) then
                  utilk(i,j,k)=flag
                endif
              else
                if (p(i,j,k)+onecm.gt.p(i,j,kk+1)) then
                  utilk(i,j,k)=flag
                endif
              endif
            enddo
          enddo
          enddo
          if     (kf.ne.1 .or. kf.ne.kl) then
            call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                  ' salinity',                ! plot name
     &                  'layer_salinity',           ! ncdf name
     &                  'sea_water_salinity',       ! ncdf standard_name
     &                  'psu',                      ! units
     &                  kf,kl,ltheta, frmt,ioin)
          else !kf==kl==1
            call horout(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                  'sea surf. salnity ',       ! plot name
     &                  'sss',                      ! ncdf name (mersea)
     &                  'sea_surface_salinity',     ! ncdf standard_name
     &                  'psu',                      ! units
     &                  0,ltheta, frmt,ioin)
          endif
        elseif (ioin.lt.0) then
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              if (ip(i,j).ne.0) then
                utilk(i,j,k)=saln(i,j,k)
*               if (p(i,j,k).ge.p(i,j,kk+1)) then
*                 utilk(i,j,k)=0.0
*               endif
              else
                utilk(i,j,k)=0.0
              endif
            enddo
          enddo
          enddo
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' salinity',                ! plot name
     &                'layer_salinity',           ! ncdf name
     &                'sea_water_salinity',       ! ncdf standard_name
     &                'psu',                      ! units
     &                kf,kl,ltheta, frmt,-ioin)
        endif
c
c ---   -------------
c ---   density
c ---   -------------
c
c ---   'tthio ' = layer k density I/O unit (0 no I/O)
        call blkini(ioin,'tthio ')
        if (ioin.gt.0) then
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              utilk(i,j,k)=th3d(i,j,k)
              if (mthin) then
                if (p(i,j,k)+onecm.gt.p(i,j,k+1)) then
                  utilk(i,j,k)=flag
                endif
              else
                if (p(i,j,k)+onecm.gt.p(i,j,kk+1)) then
                  utilk(i,j,k)=flag
                endif
              endif
            enddo
          enddo
          enddo
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                ' density ',                   ! plot name
     &                'layer_density',               ! ncdf name
     &                'sea_water_potential_density', ! ncdf standard_name
     &                'sigma',                       ! units
     &                kf,kl,ltheta, frmt,ioin)
        endif
c
c ---   -------------
c ---   tracers
c ---   -------------
c
        do ktr= 1,ntracr
c ---   'trcio ' = layer k tracer I/O unit (0 no I/O)
        call blkini(ioin,'trcio ')
        if (ioin.gt.0) then
          do k= kf,kl
          do j=1,jj
            do i=1,ii
              utilk(i,j,k)=trcr(i,j,k,ktr)
              if (mthin) then
                if (p(i,j,k)+onecm.gt.p(i,j,k+1)) then
                  utilk(i,j,k)=flag
                endif
              else
                if (p(i,j,k)+onecm.gt.p(i,j,kk+1)) then
                  utilk(i,j,k)=flag
                endif
              endif
            enddo
          enddo
          enddo
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                   trim(ctrc_title(ktr)),         ! plot name
     &                   trim(ctrc_lname(ktr)),         ! ncdf name
     &                   trim(ctrc_sname(ktr)),         ! ncdf standard_name
     &                   trim(ctrc_units(ktr)),         ! units
     &                   kf,kl,ltheta, frmt,ioin)
        endif
        enddo  !ktr= 1,ntracr
c
c ---   --------------------------
c ---   layer kinetic energy
c ---   --------------------------
c
        if     (artype.gt.1) then  ! mean or std. archive
c ---     'keio  ' = kinetic energy I/O unit (0 no I/O)
          call blkini(ioin,'keio  ')
          if (ioin.gt.0) then
            do k= kf,kl
            do j=1,jj
              do i=1,ii
                utilk(i,j,k)=ke(i,j,k)
                if (mthin) then
                  if (p(i,j,k)+onecm.gt.p(i,j,k+1)) then
                    utilk(i,j,k)=flag
                  endif
                else
                  if (p(i,j,k)+onecm.gt.p(i,j,kk+1)) then
                    utilk(i,j,k)=flag
                  endif
                endif
              enddo
            enddo
            enddo
            call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                  ' ke/mass ',                      ! plot name
     &                  'layer_kinetic_energy_per_mass',  ! ncdf name
     &                  ' ',                              ! ncdf standard_name
     &                  'm2/s2',                          ! units
     &                  kf,kl,ltheta, frmt,ioin)
          endif
        endif  ! mean or std. archive
c
c ---   --------------------------
c ---   layer stream function
c ---   --------------------------
c
c ---   'sfnio ' = layer k strmfn. I/O unit (0 no I/O)
        call blkini(ioin,'sfnio ')
        if (ioin.gt.0) then
          do k= kf,kl
c
c ---      calculate strmf on the Q grid, mostly using v.k.
c ---      note that strmf(ii,jj) is always 0.0, but streamfunctions
c ---       are arbitraty w.r.t. a constant offset anyway
           do j=jj,1,-1
             jm1 = max(1,j-1)  !not accurate for j=1, when using a subregion.
             i   = ii
             im1 = ii-1
             if (iu(i,j).eq.1) then
c ---          accurate transport calculation, allowing for depthu
               depthu = min(p(i,j,kk+1),p(im1,j,kk+1))
               ubi = u(i,j,k)*
     &                 max(0.0,
     &                     min(depthu,0.5*(p(i,j,k+1)+p(im1,j,k+1)))-
     &                     min(depthu,0.5*(p(i,j,k  )+p(im1,j,k  ))) )
             else
               ubi = 0.0
             endif
             if     (j.eq.jj) then
               strmfu = 0.0
             else
               strmfu = strmfu + ubi*scux(i,j)
             endif
             strmf(i,j) = strmfu
             strmft     = strmfu
             do i=ii-1,1,-1
               if (iv(i,j).eq.1) then
c ---            accurate transport calculation, allowing for depthv
                 depthv = min(p(i,j,kk+1),p(i,jm1,kk+1))
                 vbi = v(i,j,k)*
     &                   max(0.0,
     &                       min(depthv,0.5*(p(i,j,k+1)+p(i,jm1,k+1)))-
     &                       min(depthv,0.5*(p(i,j,k  )+p(i,jm1,k  ))) )
               else
                 vbi = 0.0
               endif
               strmft = strmft - vbi*scvy(i,j)
               strmf(i,j) = strmft  !m^3/s
             enddo !i
           enddo !j
c
c ---     interpolate from q-grid to p-grid.
          do j=1,jj
            do i=1,ii
              if (ip(i,j).ne.0 .and. i.lt.ii .and. j.lt.jj) then
                s1=0.0
                s2=0.0
                if     (iq(i,  j)  .eq.1) then
                  s1 = s1 + 1.0
                  s2 = s2 + strmf(i,  j)
                endif
                if     (iq(i+1,j)  .eq.1) then
                  s1 = s1 + 1.0
                  s2 = s2 + strmf(i+1,j)
                endif
                if     (iq(i,  j+1).eq.1) then
                  s1 = s1 + 1.0
                  s2 = s2 + strmf(i,  j+1)
                endif
                if     (iq(i+1,j+1).eq.1) then
                  s1 = s1 + 1.0
                  s2 = s2 + strmf(i+1,j+1)
                endif
                if     (s1.ne.0.0) then
                  utilk(i,j,k)=s2/s1
                else
                  utilk(i,j,k)=flag
                endif
              else
                utilk(i,j,k)=flag
              endif
            enddo
          enddo
c
ccc       call zebra(utilk(1,1,k),ii,ii,jj)
ccc       write (*,'('' shown above: layer''i3'' stream function'')') k
          enddo !k=kf,kl
c
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                'strmf (V)',                ! plot name
     &                'layer_streamfunction_v',   ! ncdf name
     &                'ocean_streamfunction',     ! ncdf standard_name
     &                'm3/s',                     ! units
     &                kf,kl,ltheta, frmt,ioin)
c
          do k= kf,kl
c
c ---     calculate strmf on the Q grid, mostly using u.k.
c ---     note that strmf(ii,jj) is always 0.0, but streamfunctions
c ---      are arbitraty w.r.t. a constant offset anyway
          do i=ii,1,-1
            im1 = max(1,i-1) !not accurate for i=1, when using a subregion.
            j   = jj
            jm1 = jj-1
            if (iv(i,j).eq.1) then
c ---         accurate transport calculation, allowing for depthv
              depthv = min(p(i,j,kk+1),p(i,jm1,kk+1))
              vbi = v(i,j,k)*
     &                max(0.0,
     &                    min(depthv,0.5*(p(i,j,k+1)+p(i,jm1,k+1)))-
     &                    min(depthv,0.5*(p(i,j,k  )+p(i,jm1,k  ))) )
            else
              vbi = 0.0
            endif
            if     (i.eq.ii) then
              strmfv = 0.0
            else
              strmfv = strmfv - vbi*scvy(i,j)
            endif
            strmf(i,j) = strmfv
            strmft     = strmfv
            do j=jj-1,1,-1
              if (iu(i,j).eq.1) then
c ---           accurate transport calculation, allowing for depthu
                depthu = min(p(i,j,kk+1),p(im1,j,kk+1))
                ubi = u(i,j,k)*
     &                  max(0.0,
     &                      min(depthu,0.5*(p(i,j,k+1)+p(im1,j,k+1)))-
     &                      min(depthu,0.5*(p(i,j,k  )+p(im1,j,k  ))) )
              else
                ubi = 0.0
              endif
              strmft     = strmft + ubi*scux(i,j)
              strmf(i,j) = strmft  !m^3/s
            enddo !i
          enddo !j
c
c ---     interpolate from q-grid to p-grid.
          do j=1,jj
            do i=1,ii
              if (ip(i,j).ne.0 .and. i.lt.ii .and. j.lt.jj) then
                s1=0.0
                s2=0.0
                if     (iq(i,  j)  .eq.1) then
                  s1 = s1 + 1.0
                  s2 = s2 + strmf(i,  j)
                endif
                if     (iq(i+1,j)  .eq.1) then
                  s1 = s1 + 1.0
                  s2 = s2 + strmf(i+1,j)
                endif
                if     (iq(i,  j+1).eq.1) then
                  s1 = s1 + 1.0
                  s2 = s2 + strmf(i,  j+1)
                endif
                if     (iq(i+1,j+1).eq.1) then
                  s1 = s1 + 1.0
                  s2 = s2 + strmf(i+1,j+1)
                endif
                if     (s1.ne.0.0) then
                  utilk(i,j,k)=s2/s1
                else
                  utilk(i,j,k)=flag
                endif
              else
                utilk(i,j,k)=flag
              endif
            enddo
          enddo
c
ccc       call zebra(utilk(1,1,k),ii,ii,jj)
ccc       write (*,'('' shown above: layer''i3'' stream function'')') k
          enddo !k=kf,kl
c
          call horout_3d(utilk, artype,yrflag,time3,iexpt,lhycom,
     &                'strmf (U)',                ! plot name
     &                'layer_streamfunction_u',   ! ncdf name
     &                'ocean_streamfunction',     ! ncdf standard_name
     &                'm3/s',                     ! units
     &                kf,kl,ltheta, frmt,ioin)
        endif
c
      enddo  !layer loop
c
      stop '(normal)'
      end
