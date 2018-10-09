module helper_module
    implicit none
    interface toString
        module procedure toString1
        module procedure toString2
    end interface toString
contains
    ! Convert integer k to str
    function toString1(k) result(str)
        !   "Convert an integer to string."
        integer, intent(in) :: k
        character(len=20) :: str
        write (str, '(I20)') k
        str = adjustl(str)
    end function toString1

    ! Convert integer k to str
    ! Always output a tring of 'length' characters
    ! Fill empty space on the left of 'k' with '0's
    function toString2(k,length) result(str)
        !   "Convert an integer to string."
        integer, intent(in) :: k, length
        character(len=20) :: str
        character(len=8) :: fmt ! format descriptor

        fmt = '(I'//trim(toString1(length))//'.'//trim(toString1(length))//')' ! an integer of width **length** with zeros at the left
        write (str,fmt) k ! converting integer to string using a 'internal file'
        str = adjustl(str)
    end function toString2
end module helper_module
