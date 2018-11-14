! :::::::::::::::::::::::::: BUFNST :::::::::::::::::::::::::::::::::::
!> After error estimation, need to tag the cell for refinement,
!! buffer the tags, take care of level nesting, etc.
!!
!! \param[in] nvar number of equations for the system
!! \param[in] naux number of auxiliary variables
!! \param[out] numbad number of flagged cells on level **lcheck**
!! \param[in] lbase base AMR level for current refinement, which stays
!!  fixed. Note that **lbase** is always less or equal to **lcheck**
!! \param[in] lcheck AMR level of grid **mptr**
! :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
!
! -------------------------------------------------------------
!
!     this indexing is for amrflags array, in flag2refine from 1-mbuff:mx+mbuff
!     but here is from 1:mibuff
    function iadd_bufnst2(i,j,locamrflags,mibuff) result(p)
        implicit none
        integer :: p,i,j,locamrflags, mibuff
        p = locamrflags + i-1+ mibuff*(j-1)
    end function iadd_bufnst2

      subroutine bufnst2(nvar,naux,numbad,lcheck,lbase)
!
      use amr_module
      implicit real(CLAW_REAL) (a-h,o-z)


      logical    vtime
      integer listgrids(numgrids(lcheck))
      integer omp_get_thread_num, omp_get_max_threads
      integer mythread/0/, maxthreads/1/
      data       vtime/.false./

 
!$    maxthreads = omp_get_max_threads()
!     call prepgrids(listgrids,numgrids(lcheck),lcheck)

      numpro = 0 
      numbad = 0 
      time = rnode(timemult,lstart(lcheck))
      dx = hxposs(lcheck)
      dy = hyposs(lcheck)

!      mptr = lstart(lcheck)
       levSt = listStart(lcheck)
!41   continue
!$OMP PARALLEL DO REDUCTION(+:numbad) &
!$OMP             PRIVATE(jg,mptr,ilo,ihi,jlo,jhi,nx,ny,mitot,mjtot), &
!$OMP             PRIVATE(mibuff,mjbuff,locamrflags,mbuff,ibytesPerDP), &
!$OMP             PRIVATE(loctmp,locbig,j,i,numpro2,numflagged), &
!$OMP             PRIVATE(locdomflags,locdom2), &
!$OMP             SHARED(numgrids, listgrids,nghost,flag_richardson), &
!$OMP             SHARED(nvar,eprint,maxthreads,node,rnode,lbase,ibuff), &
!$OMP             SHARED(alloc,lcheck,numpro,mxnest,dx,dy,time), &
!$OMP             SHARED(levSt,listOfGrids), &
!$OMP             DEFAULT(none), &
!$OMP             SCHEDULE (DYNAMIC,1)
      do  jg = 1, numgrids(lcheck)
!        mptr = listgrids(jg)
         mptr = listOfGrids(levSt+jg-1)
         ilo    = node(ndilo,mptr)
         ihi    = node(ndihi,mptr)
         jlo    = node(ndjlo,mptr)
         jhi    = node(ndjhi,mptr)
         nx     = node(ndihi,mptr) - node(ndilo,mptr) + 1
         ny     = node(ndjhi,mptr) - node(ndjlo,mptr) + 1
         mitot  = nx + 2*nghost
         mjtot  = ny + 2*nghost
         mbuff = max(nghost,ibuff+1)
         mibuff = nx + 2*mbuff
         mjbuff = ny + 2*mbuff
         locamrflags = node(storeflags,mptr)

!     still need to reclaim error est space from spest.f 
!     which was saved for possible errest reuse
         if (flag_richardson) then
         locbig = node(tempptr,mptr)
         call reclam(locbig,mitot*mjtot*nvar)
         endif
!     
         if (eprint .and. maxthreads .eq. 1) then ! otherwise race for printing
            write(outunit,*)" flagged points before projec2", &
                 lcheck," grid ",mptr, " (no buff cells)"
            do j = mjbuff-mbuff, mbuff+1, -1
               write(outunit,100)(int(alloc(iadd_bufnst2(i,j,locamrflags,mibuff))), &
                    i=mbuff+1,mibuff-mbuff)
            enddo
         endif

!     for this version project to each grid separately, no giant iflags
         if (lcheck+2 .le. mxnest) then
            numpro2 = 0
            call projec2(lcheck,numpro2,alloc(locamrflags), &
                 ilo,ihi,jlo,jhi,mbuff)
!            numpro = numpro + numpro2  not used for now. would need critical section for numpro
         endif      

         if (eprint .and. maxthreads .eq. 1) then
            write(outunit,*)" flagged points before buffering on level", &
                 lcheck," grid ",mptr, " (no buff cells)"
            do 47 j = mjbuff-mbuff, mbuff+1, -1
               write(outunit,100)(int(alloc(iadd_bufnst2(i,j,locamrflags,mibuff))), &
                    i=mbuff+1,mibuff-mbuff)
 100           format(80i1)
 47         continue
         endif
!     
         if (eprint .and. maxthreads .eq. 1) then
            write(outunit,*)" flagged points after projecting to level", &
                 lcheck, " grid ",mptr, &
                 "(withOUT buff cells)"
!     .                    "(with buff cells)"
!     buffer zone (wider ghost cell region) now set after buffering
!     so loop over larger span of indices
            do 49 j = mjbuff-mbuff, mbuff+1, -1
               write(outunit,100)(int(alloc(iadd_bufnst2(i,j,locamrflags,mibuff))), &
                    i=mbuff+1,mibuff-mbuff)
 49         continue
         endif

!
!  diffuse flagged points in all 4 directions to make buffer zones 
!  note that this code flags with a same value as true flagged
!  points, not a different number.
      call shiftset2(alloc(locamrflags),ilo,ihi,jlo,jhi,mbuff)

      if (eprint .and. maxthreads .eq. 1) then
         write(outunit,*)" flagged points after buffering on level", &
             lcheck," grid ",mptr," (WITHOUT buff cells))"
         do 51 j = mjbuff-mbuff, mbuff+1, -1
           write(outunit,100)(int(alloc(iadd_bufnst2(i,j,locamrflags,mibuff))), &
                                 i=mbuff+1, mibuff-mbuff)
 51      continue
      endif
!   
!   count up
!
      numflagged = 0
      do 82 j = 1, mjbuff
         do 82 i = 1, mibuff
            if (alloc(iadd_bufnst2(i,j,locamrflags,mibuff)) .ne. DONTFLAG) then 
               numflagged=numflagged + 1
            endif
 82      continue
        ! TODO: this output statement is broken?
!     write(outunit,116) numflagged, mptr
 116     format(i5,' points flagged on level ',i4,' grid ',i4)
         node(numflags,mptr) = numflagged
!$OMP CRITICAL(nb)
         numbad = numbad + numflagged   
!$OMP END CRITICAL(nb)

! ADD WORK THAT USED TO BE IN FLGLVL2 FOR MORE PARALLEL WORK WITHOUT JOINING AND SPAWNING AGAIN
! in effect this is domgrid, but since variables already defined just need half of it, inserted here
#if (CLAW_REAL == 8) 
      ibytesPerDP = 8      
#else
      ibytesPerDP = 4      
#endif
!     bad names, for historical reasons. they are both smae size now
      ! recall that igetsp(1) will allocate 8 bytes
      locdomflags = igetsp( (mibuff*mjbuff)/ibytesPerDP+1)
      locdom2 = igetsp( (mibuff*mjbuff)/ibytesPerDP+1)

      node(domflags_base,mptr) = locdomflags
      node(domflags2,mptr) = locdom2
      call setdomflags(mptr,alloc(locdomflags),ilo,ihi,jlo,jhi, &
                       mbuff,lbase,lcheck,mibuff,mjbuff)


      end do
!$OMP END PARALLEL DO
!     mptr = node(levelptr,mptr)
!     if (mptr .ne. 0) go to 41

      if (verbosity_regrid .ge. lcheck) then
        write(outunit,*)" total flagged points counted on level ", &
                        lcheck," is ",numbad
        write(outunit,*)"this may include double counting buffer cells", &
                        " on  multiple grids"
      endif

      return
      end
