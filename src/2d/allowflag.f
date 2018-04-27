c
!> Indicate whether the grid point at (x,y,t) at this refinement level
!! is allowed to be flagged for further refinement.
!! 
!! This is useful if you wish to zoom in on some structure in a 
!! known location but don't want the same level of refinement elsewhere.  
!! Points are flagged only if one of the errors is greater than the 
!! corresponding tolerance.
!! 
!! For example, to allow refinement of Level 1 grids everywhere but
!! of finer grids only for  y >= 0.4:
!! allowed(x,y,t,level) = (level.le.1 .or. y.ge.0.4d0) 
!! 
!! This routine is called from routine flag2refine.
!! If Richardson error estimates are used (if flag_richardson is true) 
!! then this routine is also called from errf1.

c     =========================================
      logical function allowflag(x,y,t,level)
c     =========================================

c     # Indicate whether the grid point at (x,y,t) at this refinement level
c     # is allowed to be flagged for further refinement.
c
c     # This is useful if you wish to zoom in on some structure in a 
c     # known location but don't want the same level of refinement elsewhere.  
c     # Points are flagged only if one of the errors is greater than the 
c     # corresponding tolerance.
c
c     # For example, to allow refinement of Level 1 grids everywhere but
c     # of finer grids only for  y >= 0.4:
c     # allowed(x,y,t,level) = (level.le.1 .or. y.ge.0.4d0) 
c
c     # This routine is called from routine flag2refine.
c     # If Richardson error estimates are used (if flag_richardson is true) 
c     # then this routine is also called from errf1.

      implicit real(CLAW_REAL) (a-h,o-z)

c     # default version allows refinement anywhere:
      allowflag = .true.

      return
      end
