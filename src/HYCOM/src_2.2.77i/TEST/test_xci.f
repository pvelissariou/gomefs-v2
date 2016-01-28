      program testxc
      use mod_xc    ! HYCOM communication interface
      implicit none
c
c     test xciput, based on a test for xclput.
c
      integer i,j, i1,j1,nl
      real    atile(1-nbdy:idm+nbdy,1-nbdy:jdm+nbdy)
      real    aline(jtdm+itdm)
      integer ia(jtdm+itdm),ja(jtdm+itdm)
c
c --- machine-specific initialization
c
      call machine
c
c --- initialize SPMD processsing
c
      call xcspmd
c
c --- line in periodic halo zone - 1
c
      nl = 10
      i1 = 1
      j1 = jtdm/2
      do i= 1,nl
        aline(i) = i1-1+i
        ia(i)    = i1-1+i
        ja(i)    = j1
      enddo
      atile(:,:) = 0.0
      if     (mnproc.eq.1) then
        write(6,'(a,3i5,2x,2i2)') 'xciput - ',nl,i1,j1,1,0
      endif
      call xciput(aline,nl, atile, ia,ja)
      call nozero(atile)
      call xcsync(flush_lp)
c
c --- line outside periodic halo zone - 1
c
      nl = 10
      i1 = 7
      j1 = jtdm/2-1
      do i= 1,nl
        aline(i) = i1-1+i
        ia(i)    = i1-1+i
        ja(i)    = j1
      enddo
      atile(:,:) = 0.0
      if     (mnproc.eq.1) then
        write(6,'(a,3i5,2x,2i2)') 'xciput - ',nl,i1,j1,1,0
      endif
      call xciput(aline,nl, atile, ia,ja)
      call nozero(atile)
      call xcsync(flush_lp)
c
c --- line in periodic halo zone - 2
c
      nl = 10
      i1 = itdm+1-nl
      j1 = jtdm/2-4
      do i= 1,nl
        aline(i) = i1-1+i
        ia(i)    = i1-1+i
        ja(i)    = j1
      enddo
      atile(:,:) = 0.0
      if     (mnproc.eq.1) then
        write(6,'(a,3i5,2x,2i2)') 'xciput - ',nl,i1,j1,1,0
      endif
      call xciput(aline,nl, atile, ia,ja)
      call nozero(atile)
      call xcsync(flush_lp)
c
c --- line in periodic halo zone - 3
c
      nl = 3
      i1 = 2
      j1 = jtdm/4 - nl/2
      do i= 1,nl
        aline(i) = j1-1+i
        ja(i)    = j1-1+i
        ia(i)    = i1
      enddo
      atile(:,:) = 0.0
      if     (mnproc.eq.1) then
        write(6,'(a,3i5,2x,2i2)') 'xciput - ',nl,i1,j1,0,1
      endif
      call xciput(aline,nl, atile, ia,ja)
      call nozero(atile)
      call xcsync(flush_lp)
c
c --- line in periodic halo zone - 4
c
      nl = 3
      i1 = itdm-5
      j1 = jtdm/2 - 15
      do i= 1,nl
        aline(i) = j1-1+i
        ja(i)    = j1-1+i
        ia(i)    = i1
      enddo
      atile(:,:) = 0.0
      if     (mnproc.eq.1) then
        write(6,'(a,3i5,2x,2i2)') 'xciput - ',nl,i1,j1,0,1
      endif
      call xciput(aline,nl, atile, ia,ja)
      call nozero(atile)
      call xcsync(flush_lp)
c
c --- line outside periodic halo zone - 4
c
      nl = 10
      i1 = itdm-6
      j1 = 3*jtdm/4 - nl/2
      do i= 1,nl
        aline(i) = j1-1+i
        ja(i)    = j1-1+i
        ia(i)    = i1
      enddo
      atile(:,:) = 0.0
      if     (mnproc.eq.1) then
        write(6,'(a,3i5,2x,2i2)') 'xciput - ',nl,i1,j1,0,1
      endif
      call xciput(aline,nl, atile, ia,ja)
      call nozero(atile)
      call xcsync(flush_lp)
c
      call xcstop('(normal)')
             stop '(normal)'
      end
      subroutine nozero(atile)
      use mod_xc    ! HYCOM communication interface
      implicit none
      real    atile(1-nbdy:idm+nbdy,1-nbdy:jdm+nbdy)
c
c**********
c*
c  1) writes out all non-zero elements
c*
c**********
c
      integer i,j
c
      do j= 1-nbdy,jj+nbdy
        do i= 1-nbdy,ii+nbdy
          if     (atile(i,j).ne.0.0) then
            write(lp,'(a,i4,4i5,f8.1)') 'mn,i,j,it,jt,a = ',
     &                          mnproc,i,j,i+i0,j+j0,atile(i,j)
          endif
        enddo
      enddo
      return
c     end of nozero.
      end
