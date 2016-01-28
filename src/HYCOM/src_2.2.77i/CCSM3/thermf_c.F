!----------------------------------------------------------------------
!DBI:         This routine is modified for the coupled model.
!
!     In standalone mode thermf is used to determines (surface) forcing
!     functions, i.e., heat and salt fluxes (surflx and salflx) which 
!     are to be used to calculate T/S change in maxlyr. It also obtains
!     friction velocity (ustar) for momtum operation... 
!
!     In coupled mode, surflx, salflx and ustar have been obtained in 
!     recv_from_coupler, so this routine only handles the surface 
!     relaxation issue (i.e., adding the contribution of T/S relaxation
!     into surflx and salflx.)
!
!     hycom receives from the coupler the following 14 fields:
!
!        1: ice fraction                        ==> aice
!        2: mean sea level pressure             (no use)
!        3: taux field                          ==> taux|__ ustar
!        4: tauy field                          ==> tauy|
!        5: shortwave heat flux               |
!        6: sensible heat flux                |
!        7: longwave heat flux (up)           | ==> surflx
!        8: longwave heat flux (down)         |
!        9: heat flux from snow&ice melt      |
!       12: evaporation flux                  |
!       10: salt flux (kg of salt)                      |
!       11: precipitation flux                |         n ==> salflx
!       12: evaporation flux                  | ==> sfwf|
!       13: snow melt flux                    |
!       14: river runoff flux                 |
!               (see routine recv_from_coupler for details)
!........................................................................
      subroutine thermf_c(m,n)
Cpg
      use ccsm3                   ! ccsm3 ocean
      use ccsm3_time_management   ! ccsm3 ocean
Cpg
      use mod_xc,                 ! HYCOM communication interface
     &  only : xcaget, xcsum, xcsync, no_flush, mnproc

      implicit none
c
!      include 'common_blocks.h'
!DBI:
!      include 'hycom_coupling.h'
c
      integer m,n
c
c --- ---------------
c --- thermal forcing
c --- ---------------
c
      integer i,j,k,ktr,nm,l
      real    pwl
      real*8  t1mean,s1mean,tmean,smean,pmean,rmean,
     &        rareac,runsec,secpyr
      real*8  d1,d2,d3,d4
c
      real    pwij(kk+1),trwij(kk,ntracr),
     &        prij(kk+1),trcij(kk,ntracr)
c
      real*8  tmean0,smean0,rmean0
      save    tmean0,smean0,rmean0
!DBI: check fluxes
      real, dimension(itdm,jtdm) :: bchk
!----
c
      include 'stmt_fns.h'
c
      margin = 0  ! no horizontal derivatives
c
!$OMP PARALLEL DO PRIVATE(j,k,l,i,ktr)
!$OMP&         SCHEDULE(STATIC,jblk)
      do j=1-margin,jj+margin
        do k=1,kk
          do l=1,isp(j)
            do i=max(1-margin,ifp(j,l)),min(ii+margin,ilp(j,l))
              p(i,j,k+1)=p(i,j,k)+dp(i,j,k,n)
            enddo
          enddo
        enddo
      enddo
c
c --- ----------------------------
c --- thermal forcing at nestwalls
c --- ----------------------------
c
      if (nestfq.ne.0.0 .and. nstep.gt.2) then
c
!$OMP PARALLEL DO PRIVATE(j,i,k,pwl)
!$OMP&         SCHEDULE(STATIC,jblk)
      do j=1-margin,jj+margin
        do i=1-margin,ii+margin
          if (ip(i,j).eq.1 .and. rmunp(i,j).ne.0.0) then
            k=1
            saln(i,j,k,n)=saln(i,j,k,n)+delt1*rmunp(i,j)*
     &         ((snest(i,j,k,ln0)*wn0+snest(i,j,k,ln1)*wn1)
     &          - saln(i,j,k,n))
            temp(i,j,k,n)=temp(i,j,k,n)+delt1*rmunp(i,j)*
     &         ((tnest(i,j,k,ln0)*wn0+tnest(i,j,k,ln1)*wn1)
     &          - temp(i,j,k,n))
            th3d(i,j,k,n)=sig(temp(i,j,k,n),saln(i,j,k,n))-thbase
c
            if     (hybrid) then
              do k=kk,2,-1
                pwl=pnest(i,j,k,ln0)*wn0+pnest(i,j,k,ln1)*wn1
                if     (pwl.gt.p(i,j,kk+1)-tencm) then
                  pwl=p(i,j,kk+1)
                endif
                p(i,j,k)=min(p(i,j,k+1),
     &                       p(i,j,k)+delt1*rmunp(i,j)*(pwl-p(i,j,k)))
                dp(i,j,k,n)=p(i,j,k+1)-p(i,j,k)
c
                if     (pwl.lt.p(i,j,kk+1)) then
                  saln(i,j,k,n)=saln(i,j,k,n)+delt1*rmunp(i,j)*
     &                 ((snest(i,j,k,ln0)*wn0+snest(i,j,k,ln1)*wn1)
     &                  - saln(i,j,k,n))
                  if     (k.le.nhybrd) then
                    temp(i,j,k,n)=temp(i,j,k,n)+delt1*rmunp(i,j)*
     &                 ((tnest(i,j,k,ln0)*wn0+tnest(i,j,k,ln1)*wn1)
     &                  - temp(i,j,k,n))
                    th3d(i,j,k,n)=sig(temp(i,j,k,n),
     &                                saln(i,j,k,n))-thbase
                  else
                    th3d(i,j,k,n)=       theta(i,j,k)
                    temp(i,j,k,n)=tofsig(theta(i,j,k)+thbase,
     &                                   saln(i,j,k,n))
                  endif
                endif
              enddo  !k
              dp(i,j,1,n)=p(i,j,2)-p(i,j,1)
            else  ! isopyc
              do k=kk,2,-1
                saln(i,j,k,n)=saln(i,j,k,n)+delt1*rmunp(i,j)*
     &             ((snest(i,j,k,ln0)*wn0+snest(i,j,k,ln1)*wn1)
     &              - saln(i,j,k,n))
                temp(i,j,k,n)=tofsig(th3d(i,j,k,n)+thbase,saln(i,j,k,n))
                if (k.ge.3) then
                  pwl=pnest(i,j,k,ln0)*wn0+pnest(i,j,k,ln1)*wn1
                  pwl=max(p(i,j,2),pwl)
                  if     (pwl.gt.p(i,j,kk+1)-tencm) then
                    pwl=p(i,j,kk+1)
                  endif
                  p(i,j,k)=min(p(i,j,k+1),
     &                         p(i,j,k)+delt1*rmunp(i,j)*(pwl-p(i,j,k)))
                endif
                dp(i,j,k,n)=p(i,j,k+1)-p(i,j,k)
              enddo  !k
            endif  ! hybrid:isopyc
c
c ---       minimal tracer support (non-negative in buffer zone).
            do ktr= 1,ntracr
              tracer(i,j,k,n,ktr)=max(tracer(i,j,k,n,ktr),0.0)
            enddo
          endif  !ip.eq.1 .and. rmunp.ne.0.0
c
          if (iu(i,j).eq.1 .and.
     &        max(rmunv(i,j),rmunv(i-1,j)).ne.0.0) then
            do k= 1,kk
              pwl=u(i,j,k,n)
              u(i,j,k,n)=u(i,j,k,n)+delt1*max(rmunv(i,j),rmunv(i-1,j))*
     &           ((unest(i,j,k,ln0)*wn0+unest(i,j,k,ln1)*wn1)
     &               - u(i,j,k,n))
            enddo  !k
          endif  !iu.eq.1 .and. rmunv.ne.0.0
c
          if (iv(i,j).eq.1 .and.
     &        max(rmunv(i,j),rmunv(i,j-1)).ne.0.0) then
            do k= 1,kk
              pwl=v(i,j,k,n)
              v(i,j,k,n)=v(i,j,k,n)+delt1*max(rmunv(i,j),rmunv(i,j-1))*
     &           ((vnest(i,j,k,ln0)*wn0+vnest(i,j,k,ln1)*wn1)
     &               - v(i,j,k,n))
            enddo  !k
          endif  !iu.eq.1 .and. rmunv.ne.0.0
        enddo  !i
      enddo  !j
!$OMP END PARALLEL DO
c
      endif  !  nestfq.ne.0.0
c
c --- ----------------------------
c --- thermal forcing at sidewalls
c --- ----------------------------
c
      if (relax .and. nstep.gt.2) then
c
!$OMP PARALLEL DO PRIVATE(j,l,i,k,pwl)
!$OMP&         SCHEDULE(STATIC,jblk)
      do 53 j=1-margin,jj+margin
      do 53 l=1,isp(j)
      do 53 i=max(1-margin,ifp(j,l)),min(ii+margin,ilp(j,l))
        if (rmu(i,j).ne.0.0) then
          k=1
          saln(i,j,k,n)=saln(i,j,k,n)+delt1*rmu(i,j)*
     &       ((swall(i,j,k,lc0)*wc0+swall(i,j,k,lc1)*wc1
     &        +swall(i,j,k,lc2)*wc2+swall(i,j,k,lc3)*wc3)
     &        - saln(i,j,k,n))
          temp(i,j,k,n)=temp(i,j,k,n)+delt1*rmu(i,j)*
     &       ((twall(i,j,k,lc0)*wc0+twall(i,j,k,lc1)*wc1
     &        +twall(i,j,k,lc2)*wc2+twall(i,j,k,lc3)*wc3)
     &        - temp(i,j,k,n))
          th3d(i,j,k,n)=sig(temp(i,j,k,n),saln(i,j,k,n))-thbase
c
          if     (hybrid) then
            do k=kk,2,-1
              pwl=pwall(i,j,k,lc0)*wc0+pwall(i,j,k,lc1)*wc1
     &           +pwall(i,j,k,lc2)*wc2+pwall(i,j,k,lc3)*wc3
              if     (pwl.gt.p(i,j,kk+1)-tencm) then
                pwl=p(i,j,kk+1)
              endif
              p(i,j,k)=min(p(i,j,k+1),
     &                     p(i,j,k)+delt1*rmu(i,j)*(pwl-p(i,j,k)))
              dp(i,j,k,n)=p(i,j,k+1)-p(i,j,k)
c
              if     (pwl.lt.p(i,j,kk+1)) then
                saln(i,j,k,n)=saln(i,j,k,n)+delt1*rmu(i,j)*
     &             ((swall(i,j,k,lc0)*wc0+swall(i,j,k,lc1)*wc1
     &              +swall(i,j,k,lc2)*wc2+swall(i,j,k,lc3)*wc3)
     &              - saln(i,j,k,n))
                if     (k.le.nhybrd) then
                  temp(i,j,k,n)=temp(i,j,k,n)+delt1*rmu(i,j)*
     &               ((twall(i,j,k,lc0)*wc0+twall(i,j,k,lc1)*wc1
     &                +twall(i,j,k,lc2)*wc2+twall(i,j,k,lc3)*wc3)
     &                - temp(i,j,k,n))
                  th3d(i,j,k,n)=sig(temp(i,j,k,n),saln(i,j,k,n))-thbase
                else
                  th3d(i,j,k,n)=       theta(i,j,k)
                  temp(i,j,k,n)=tofsig(theta(i,j,k)+thbase,
     &                                 saln(i,j,k,n))
                endif !hybrid:else
              endif !pwl.lt.p(i,j,kk+1)
            enddo !k
            dp(i,j,1,n)=p(i,j,2)-p(i,j,1)
          else  ! isopyc
            do k=kk,2,-1
              saln(i,j,k,n)=saln(i,j,k,n)+delt1*rmu(i,j)*
     &           ((swall(i,j,k,lc0)*wc0+swall(i,j,k,lc1)*wc1
     &            +swall(i,j,k,lc2)*wc2+swall(i,j,k,lc3)*wc3)
     &            - saln(i,j,k,n))
              temp(i,j,k,n)=tofsig(th3d(i,j,k,n)+thbase,saln(i,j,k,n))
              if (k.ge.3) then
                pwl=pwall(i,j,k,lc0)*wc0+pwall(i,j,k,lc1)*wc1
     &             +pwall(i,j,k,lc2)*wc2+pwall(i,j,k,lc3)*wc3
                pwl=max(p(i,j,2),pwl)
                if     (pwl.gt.p(i,j,kk+1)-tencm) then
                  pwl=p(i,j,kk+1)
                endif
                p(i,j,k)=min(p(i,j,k+1),
     &                       p(i,j,k)+delt1*rmu(i,j)*(pwl-p(i,j,k)))
              endif !k.ge.3
              dp(i,j,k,n)=p(i,j,k+1)-p(i,j,k)
            enddo !k
          endif !hybrid:isopyc
        endif !rmu(i,j).ne.0.0
 53   continue
c
      endif  !  relax = .true.
c
c --- ----------------------------
c --- tracer forcing at sidewalls
c --- ----------------------------
c
      if (trcrlx .and. nstep.gt.2) then
c
!$OMP   PARALLEL DO PRIVATE(j,l,i,k,ktr,pwij,trwij,prij,trcij)
!$OMP&           SCHEDULE(STATIC,jblk)
        do j=1-margin,jj+margin
          do l=1,isp(j)
            do i=max(1-margin,ifp(j,l)),min(ii+margin,ilp(j,l))
              if     (rmutra(i,j).ne.0.0) then !at least one mask is non-zero
                prij(1)=0.0
                do k=1,kk
                  prij(k+1) =  prij(k)+dp(i,j,k,n)
                  pwij(k)   =  pwall(i,j,k,lc0)*wc0
     &                        +pwall(i,j,k,lc1)*wc1
     &                        +pwall(i,j,k,lc2)*wc2
     &                        +pwall(i,j,k,lc3)*wc3
                  do ktr= 1,ntracr
                    trwij(k,ktr) =  trwall(i,j,k,lc0,ktr)*wc0
     &                             +trwall(i,j,k,lc1,ktr)*wc1
     &                             +trwall(i,j,k,lc2,ktr)*wc2
     &                             +trwall(i,j,k,lc3,ktr)*wc3
                  enddo !ktr
                enddo !k
                pwij(kk+1)=prij(kk+1)
*               call plctrc(trwij,pwij,kk,ntracr,
*    &                      trcij,prij,kk        )
                call plmtrc(trwij,pwij,kk,ntracr,
     &                      trcij,prij,kk        )
                do ktr= 1,ntracr
                  if     (rmutr(i,j,ktr).ne.0.0) then
                    do k=1,kk
                      tracer(i,j,k,n,ktr) = tracer(i,j,k,n,ktr)+
     &                delt1*rmutr(i,j,ktr)*(trcij(k,ktr)-
     &                                      tracer(i,j,k,n,ktr))
                    enddo !k
                  endif !rmutr.ktr.ne.0.0
                enddo !ktr
              endif !rmutra.ne.0.0
            enddo !i
          enddo !l
        enddo !j
!$OMP   END PARALLEL DO
c
      endif  !  trcrlx = .true.

      !sswflx = SHF_QSW     !from recv_from_cpl
      !to be done in thermfj_c 

!DBI: chkeck fluxes (from_cpl):
      IF (.false. .and. mod(nstep,36)==1 ) THEN
      call xcaget(bchk,surflx,0)
      if (mnproc == 1) then
        write(311,'(10e13.5)')bchk
        call flush(311)
      endif
      call xcaget(bchk,sswflx,0)
      if (mnproc == 1) then
        write(312,'(10e13.5)')bchk
        call flush(312)
      endif
      call xcaget(bchk,salflx,0)
      if (mnproc == 1) then
        write(313,'(10e13.5)')bchk
        call flush(313)
      endif
      call xcaget(bchk,ustar,0)
      if (mnproc == 1) then
        write(314,'(10e13.5)')bchk
        call flush(314)
      endif
      ENDIF
!----

c
c --- --------------------------------
c --- thermal forcing of ocean surface
c --- --------------------------------
c
      if (thermo .or. sstflg.gt.0 .or. srelax) then
c
!$OMP PARALLEL DO PRIVATE(j)
!$OMP&             SHARED(m,n)
!$OMP&         SCHEDULE(STATIC,jblk)
!DBI: thermfj_c adds in T/S relaxation to surflx and salflx...
      do j=1-margin,jj+margin
        !call thermfj(m,n, j)
        call thermfj_c(m,n, j)               
      enddo
      call xcsum(d1, util1,ip)
      call xcsum(d2, util2,ip)
      call xcsum(d3, util3,ip)
      call xcsum(d4, util4,ip)
      watcum=watcum+d1
      empcum=empcum+d2
      t1mean=d3
      s1mean=d4
c
      if (nstep.eq.nstep1+1 .or. diagno) then
!$OMP   PARALLEL DO PRIVATE(j,k,nm,l,i)
!$OMP&           SCHEDULE(STATIC,jblk)
        do j=1,jj
          k=1
            nm=n
            if (nstep.eq.nstep1+1) nm=m
            do l=1,isp(j)
              do i=max(1,ifp(j,l)),min(ii,ilp(j,l))
                util1(i,j)=               dp(i,j,k,nm)*scp2(i,j)
                util2(i,j)=temp(i,j,k,nm)*dp(i,j,k,nm)*scp2(i,j)
                util3(i,j)=saln(i,j,k,nm)*dp(i,j,k,nm)*scp2(i,j)
                util4(i,j)=th3d(i,j,k,nm)*dp(i,j,k,nm)*scp2(i,j)
              enddo
            enddo
          do k=2,kk
            nm=n
            if (nstep.eq.nstep1+1) nm=m
            do l=1,isp(j)
              do i=max(1,ifp(j,l)),min(ii,ilp(j,l))
                util1(i,j)=util1(i,j)+    dp(i,j,k,nm)*scp2(i,j)
                util2(i,j)=util2(i,j)+
     &                     temp(i,j,k,nm)*dp(i,j,k,nm)*scp2(i,j)
                util3(i,j)=util3(i,j)+
     &                     saln(i,j,k,nm)*dp(i,j,k,nm)*scp2(i,j)
                util4(i,j)=util4(i,j)+
     &                     th3d(i,j,k,nm)*dp(i,j,k,nm)*scp2(i,j)
              enddo
            enddo
          enddo
        enddo
!$OMP   END PARALLEL DO
        call xcsum(d1, util1,ip)
        call xcsum(d2, util2,ip)
        call xcsum(d3, util3,ip)
        call xcsum(d4, util4,ip)
        pmean=d1
        tmean=d2/pmean
        smean=d3/pmean
        rmean=d4/pmean
        if     (mnproc.eq.1) then
        write (lp,'(i9,a,3f9.3)') 
     &    nstep,' mean basin temp, saln, dens ',
     &    tmean,smean,rmean+thbase
        endif !1st tile
        if     (nstep.eq.nstep1+1) then
c
c ---     save initial basin means.
          tmean0=tmean
          smean0=smean
          rmean0=rmean
        else
c
c ---     diagnostic printout of fluxes.
          rareac=1.0/(area*(nstep-nstep1))
          runsec=   baclin*(nstep-nstep1)
          if      (yrflag.eq.0) then
            secpyr=360.00d0*86400.0d0
          elseif (yrflag.lt.3) then
            secpyr=366.00d0*86400.0d0
          elseif (yrflag.ge.3) then
            secpyr=365.25d0*86400.0d0
          endif
          if     (mnproc.eq.1) then
          write (lp,'(i9,a,2f9.3)') 
     &     nstep,' mean surface temp and saln  ',
     &     t1mean/area,s1mean/area
          write (lp,'(i9,a,2f9.3,a)') 
     &     nstep,' energy residual (atmos,tot) ',
     &     watcum*rareac,
     &     (tmean-tmean0)*(spcifh*avgbot*qthref)/runsec,
     &    ' (w/m**2)'
c ---     note that empcum is now salflx cum.
          write (lp,'(i9,a,2f9.3,a)')
     &     nstep,'  e - p residual (atmos,tot) ',
     &     empcum*(thref/saln0)*rareac*100.0*secpyr,
     &     (smean-smean0)/(saln0*runsec)*avgbot*100.0*secpyr,
     &    ' (cm/year)'
          write (lp,'(i9,a,2f9.3)') 
     &     nstep,' temp drift per century      ',
     &     (watcum*rareac/(spcifh*avgbot*qthref))*(secpyr*100.0d0),
     &     (tmean-tmean0)*(secpyr*100.0d0)/runsec
          write (lp,'(i9,a,2f9.3)') 
     &     nstep,' saln drift per century      ',
     &     (empcum*rareac/(       avgbot*qthref))*(secpyr*100.0d0),
     &     (smean-smean0)*(secpyr*100.0d0)/runsec
          write (lp,'(i9,a,9x,f9.3)') 
     &     nstep,' dens drift per century      ',
     &     (rmean-rmean0)*(secpyr*100.0d0)/runsec
          endif !1st tile
          call xcsync(no_flush) !DBI!
        endif
      endif
c
      endif   !  thermo .or.  sstflg.gt.0 .or. srelax

!DBI: chkeck fluxes (from_cpl + relax):
      IF (.false. .and. mod(nstep,36)==1 ) THEN
      call xcaget(bchk,surflx,0)
      if (mnproc == 1) then
        write(301,'(10e13.5)')bchk
        call flush(301)
      endif
      call xcaget(bchk,sswflx,0)
      if (mnproc == 1) then
        write(302,'(10e13.5)')bchk
        call flush(302)
      endif
      call xcaget(bchk,salflx,0)
      if (mnproc == 1) then
        write(303,'(10e13.5)')bchk
        call flush(303)
      endif
      call xcaget(bchk,ustar,0)
      if (mnproc == 1) then
        write(304,'(10e13.5)')bchk
        call flush(304)
      endif
      !stop 'DBI STOP in thermf_c to check fluxes!'
      ENDIF
!----
c
      return
      end subroutine thermf_c
c
      subroutine thermfj_c(m,n, j)
Cpg
      use ccsm3                   ! ccsm3 ocean
      use ccsm3_time_management   ! ccsm3 ocean
Cpg
c
c --- hycom version 1.0
      implicit none
c
!DBI:      include 'common_blocks.h'
!DBI:
!      include 'hycom_coupling.h'
c
      integer m,n, j
c
      real    sstrlx,rmus,rmut
      integer i,l
c
c --- 'ustrmn' = minimum ustar
c --- 'cormn4' = 4 times minimum coriolis magnitude
c
      real       ustrmn,cormn4,csubp,evaplh,csice
      parameter (ustrmn=1.0e-5, 
     &           cormn4=4.0e-5)  ! corio(4N) is about 1.e-5
c
Cpg - Diurnal cycle
      integer ::
     &  index_qsw
Cpg
      real qsatur
      include 'stmt_fns.h'
c
c --- saturation specific humidity (lowe, j.appl.met., 16, 100-103, 1976)
      qsatur(t)=.622e-3*(6.107799961e+00+t*(4.436518521e-01
     &               +t*(1.428945805e-02+t*(2.650648471e-04
     &               +t*(3.031240396e-06+t*(2.034080948e-08
     &               +t* 6.136820929e-11))))))
c
c --- salinity relaxation coefficient
      rmus=1./(30.*86400.)
c
c --- temperature relaxation coefficient
      rmut=1./(30.*86400.)
c
c --- ------------------------------------------------------
c --- thermal forcing of ocean surface (positive into ocean)
c --- almost all provided by the coupler.
c --- ------------------------------------------------------
c
      do 851 l=1,isp(j)
c
      do 851 i=max(1-margin,ifp(j,l)),min(ii+margin,ilp(j,l))
c
c --- hekman
      ustar( i,j)=max(ustrmn, ustar(i,j))
      hekman(i,j)=ustar(i,j)*(cekman*4.0)/
     &             max( cormn4,
     &                  abs(corio(i,j  ))+abs(corio(i+1,j  ))+
     &                  abs(corio(i,j+1))+abs(corio(i+1,j+1)))
c
c --- relax to surface temperature
      if     (sstflg.eq.1) then !climatological sst
c ---   use a reference relaxation thickness (min. mixed layer depth)
c ---   actual e-folding time is (dpmixl(i,j,n)/(thkmlt*onem))/rmut
        sstrlx=
     &   (rmut*spcifh*thkmlt*onem/g)*
     &   ( ( twall(i,j,1,lc0)*wc0+twall(i,j,1,lc1)*wc1
     &      +twall(i,j,1,lc2)*wc2+twall(i,j,1,lc3)*wc3) -
     &     temp(i,j,1,n) )
        surflx(i,j)=surflx(i,j)+sstrlx
        sstflx(i,j)=sstflx(i,j)+sstrlx
      elseif (sstflg.gt.1) then !synoptic sst
c ---   use a reference relaxation thickness (min. mixed layer depth)
c ---   actual e-folding time is (dpmixl(i,j,n)/(thkmlt*onem))/rmut
        sstrlx=
     &   (rmut*spcifh*thkmlt*onem/g)*
     &   ( ( seatmp(i,j,l0)*w0+seatmp(i,j,l1)*w1
     &      +seatmp(i,j,l2)*w2+seatmp(i,j,l3)*w3) -
     &     temp(i,j,1,n) )
        surflx(i,j)=surflx(i,j)+sstrlx
        sstflx(i,j)=sstflx(i,j)+sstrlx
      endif
c --- sswflx = shortwave radiative energy flux (w/m**2) into ocean
c --- SHF_QSW from recv_from_cpl
!     sswflx(i,j) = SHF_QSW(i,j)

! Jianjun Yin (04/02/2007) done in ccsm3_forcing.F  
!      index_qsw = mod(nsteps_today,nsteps_per_day) + 1
!      sswflx(i,j)=diurnal_cycle_factor(index_qsw)*SHF_QSW(i,j)
!      surflx(i,j)=surflx(i,j)+(sswflx(i,j)-SHF_QSW(i,j))
! Jianjun Yin
!----
c --- relax to surface salinity
      if     (srelax) then
c ---   use a reference relaxation thickness (min. mixed layer depth)
c ---   actual e-folding time is (dpmixl(i,j,n)/(thkmls*onem))/rmus
        sssflx(i,j)=
     &     (rmus*thkmls*onem/g)*
     &     ( ( swall(i,j,1,lc0)*wc0+swall(i,j,1,lc1)*wc1
     &        +swall(i,j,1,lc2)*wc2+swall(i,j,1,lc3)*wc3) -
     &       saln(i,j,1,n) )
        salflx(i,j)=salflx(i,j)+sssflx(i,j)
      else
        sssflx(i,j)=0.0
      endif
c
c --- n o t e : t/s changes due to surflx/salflx are computed in mxlayr routine
c
      util1(i,j)=  surflx(i,j)*scp2(i,j)
      util2(i,j)=  salflx(i,j)*scp2(i,j)
      util3(i,j)=temp(i,j,1,n)*scp2(i,j)
      util4(i,j)=saln(i,j,1,n)*scp2(i,j)
c
!DBI: switch on the following to check when necessary:
      IF (.false.) THEN  !DBI
      if     (i.eq.itest.and.j.eq.jtest) then
        write (lp,100) 
     .  nstep,i0+i,j0+j,
     .  '  surflx      sswflx      salflx      hekman       ustar',
     .  surflx(i,j),sswflx(i,j),salflx(i,j),hekman(i,j),ustar(i,j)
        call flush(lp)
      endif
      ENDIF    !DBI
 100  format(i9,2i5,a/18x,1p5e12.4)
 851  continue
      return
      end subroutine thermfj_c
c
c
c> Revision history:
c>
c> Oct. 1999 - surface flux calculations modified for kpp mixed layer model,
c>             including penetrating solar radiation based on jerlov water type
c> Apr. 2000 - conversion to SI units
c> Oct  2000 - added thermfj to simplify OpenMP logic
c> Dec  2000 - modified fluxes when ice is present
c> Dec  2000 - added Kara bulk air-sea flux parameterization (flxflg=2)
c> May  2002 - buoyfl now calculated in mixed layer routine
c> Aug  2002 - added nested velocity relaxation
c> Nov  2002 - separate sss and sst relaxation time scales (thkml[st])
c> Nov  2002 - save sssflx and sstflx for diagnostics
c> Mar  2003 - longwave radiation correction for model vs "longwave" SST
c> Mar  2003 - SST relaxation to climatology or to synoptic SST
