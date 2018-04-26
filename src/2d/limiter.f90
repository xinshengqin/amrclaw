!> Apply a limiter to the waves.
!! The limiter is computed by comparing the 2-norm of each wave with
!! the projection of the wave from the interface to the left or
!! right onto the current wave.  For a linear system this would
!! correspond to comparing the norms of the two waves.  For a 
!! nonlinear problem the eigenvectors are not colinear and so the 
!! projection is needed to provide more limiting in the case where the
!! neighboring wave has large norm but points in a different direction
!! in phase space.
!! 
!! The specific limiter used in each family is determined by the
!! value of the corresponding element of the array mthlim, as used in
!! the function philim.
!! Note that a different limiter may be used in each wave family.
!! 
!! dotl and dotr denote the inner product of wave with the wave to
!! the left or right.  The norm of the projections onto the wave are then
!! given by dotl/wnorm2 and dotr/wnorm2, where wnorm2 is the 2-norm
!! of wave.
!
!     =====================================================
subroutine limiter(maxm,meqn,mwaves,mbc,mx,wave,s,mthlim)
!     =====================================================
!
!
    implicit real(CLAW_REAL) (a-h,o-z)
    real(CLAW_REAL), intent(in) :: mthlim(mwaves)
    real(CLAW_REAL), intent(inout) :: wave(meqn, mwaves, 1-mbc:maxm+mbc)
    real(CLAW_REAL), intent(in) ::    s(mwaves, 1-mbc:maxm+mbc)

    do mw=1,mwaves
        if (mthlim(mw) .eq. 0) cycle
        dotr = 0.d0
        do i = 0, mx+1
            wnorm2 = 0.d0
            dotl = dotr
            dotr = 0.d0
            do m=1,meqn
                wnorm2 = wnorm2 + wave(m,mw,i)**2
                dotr = dotr + wave(m,mw,i)*wave(m,mw,i+1)
            enddo
            if (i.eq.0) cycle
            if (wnorm2.eq.0.d0) cycle
            !
            if (s(mw,i) .gt. 0.d0) then
                wlimitr = philim(wnorm2, dotl, mthlim(mw))
            else
                wlimitr = philim(wnorm2, dotr, mthlim(mw))
            endif
            !
            do m=1,meqn
                wave(m,mw,i) = wlimitr * wave(m,mw,i)
            enddo
        enddo
    enddo
    return
end subroutine limiter
