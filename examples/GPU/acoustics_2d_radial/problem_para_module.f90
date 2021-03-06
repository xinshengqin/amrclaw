module problem_para_module

    double precision, save :: rho, bulk, cc, zz

    contains
    subroutine setprob
        implicit double precision (a-h,o-z)
        character*25 fname
        ! common /cparam/ rho,bulk,cc,zz

        !
        !     # Set the material parameters for the acoustic equations
        !
        !
        iunit = 7
        fname = 'setprob.data'
        !     # open the unit with new routine from Clawpack 4.4 to skip over
        !     # comment lines starting with #:
        call opendatafile(iunit, fname)

        !
        !     # Density and bulk modulus:

        read(7,*) rho
        read(7,*) bulk
        !
        !     # Compute sound speed and impendance:

        cc = dsqrt(bulk/rho)
        zz = rho*cc

        return
    end subroutine
end module
