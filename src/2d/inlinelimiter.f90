!     =====================================================
subroutine limiter(maxm,meqn,mwaves,mbc,mx,wave,s,mthlim)
!     =====================================================
!
!     # Apply a limiter to the waves.  
!
!     # Version of December, 2002.
!     # Modified from the original CLAWPACK routine to eliminate calls 
!     # to philim.  Since philim was called for every wave at each cell
!     # interface, this was adding substantial overhead in some cases.
!
!     # The limiter is computed by comparing the 2-norm of each wave with
!     # the projection of the wave from the interface to the left or
!     # right onto the current wave.  For a linear system this would
!     # correspond to comparing the norms of the two waves.  For a 
!     # nonlinear problem the eigenvectors are not colinear and so the 
!     # projection is needed to provide more limiting in the case where the
!     # neighboring wave has large norm but points in a different direction
!     # in phase space.
!
!     # The specific limiter used in each family is determined by the
!     # value of the corresponding element of the array mthlim.
!     # Note that a different limiter may be used in each wave family.
!
!     # dotl and dotr denote the inner product of wave with the wave to
!     # the left or right.  The norm of the projections onto the wave are then
!     # given by dotl/wnorm2 and dotr/wnorm2, where wnorm2 is the 2-norm
!     # of wave.
!
    implicit double precision (a-h,o-z)
    dimension mthlim(mwaves)
    dimension wave(meqn, mwaves, 1-mbc:maxm+mbc)
    dimension    s(mwaves, 1-mbc:maxm+mbc)

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
            if (s(mw,i) .gt. 0.d0) then
                r = dotl / wnorm2
            else
                r = dotr / wnorm2
            endif

            go to (10,20,30,40,50) mthlim(mw)

            10       continue
!           --------
!           # minmod
!           --------
            wlimitr = dmax1(0.d0, dmin1(1.d0, r))
            go to 170

            20       continue
!           ----------
!           # superbee
!           ----------
            wlimitr = dmax1(0.d0, dmin1(1.d0, 2.d0*r), dmin1(2.d0, r))
            go to 170

            30       continue
!           ----------
!           # van Leer
!           ----------
            wlimitr = (r + dabs(r)) / (1.d0 + dabs(r))
            go to 170

            40       continue
!           ------------------------------
!           # monotinized centered
!           ------------------------------
            c = (1.d0 + r)/2.d0
            wlimitr = dmax1(0.d0, dmin1(c, 2.d0, 2.d0*r))
            go to 170

            50       continue
!           ------------------------------
!           # Beam-Warming
!           ------------------------------
            wlimitr = r
            go to 170

            170       continue
!
!           # apply limiter to waves:
!
            do m=1,meqn
                wave(m,mw,i) = wlimitr * wave(m,mw,i)
            enddo
        enddo
    enddo
    return
end subroutine limiter
