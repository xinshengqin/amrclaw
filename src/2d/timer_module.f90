! =========================================================================
!  Subroutines for timing the code
!  1. cpu_timers is for timing wall time of a section of the code. To use 
!     it:
!     1) call take_cpu_timer(timer_name, timer_id). This will set timer with 
!        id **timer_id** to have name **timer_name**. This subroutine only 
!        takes effect on timer with id **timer_id** the first time it is called.
!     2) call cpu_timer_start(timer_id) with the same id **timer_id** at the 
!        beginning of the code section you want to time.
!     3) call cpu_timer_stop(timer_id) with the same id **timer_id** at the 
!        end of the code section you want to time.
!     4) A summary of all timers that have been taken by doing step 1) will be
!        printed out at the end of the program.
!  2. If OpenMP is used, only the master thread is timed.
! =========================================================================
module timer_module
    use amr_module

    implicit none
    save

    public

    ! initialized to be 0
    integer, parameter :: max_cpu_timers = 20
    integer(kind=8) :: clock_rate
    character(len=364) :: format_string

    type timer_type
        character(len=364) :: timer_name
        logical :: used = .false.
        logical :: running = .false.
        integer(kind=8) :: start_time = 0
        integer(kind=8) :: stop_time = 0
        integer(kind=8) :: accumulated_time = 0 ! in clock_cycle, not seconds
        integer(kind=8) :: n_calls = 0 ! how many times this section is called
    end type timer_type


    ! measure wall time of CPU codes
    type(timer_type) :: cpu_timers(0:max_cpu_timers)

    private :: max_cpu_timers, clock_rate, format_string, timer_type, cpu_timers

#ifdef PROFILE
    ! What's each timer used for
    integer, parameter :: timer_total_run_time = 0

    integer, parameter :: timer_stepgrid = 1
    integer, parameter :: timer_gpu_loop = 2
    integer, parameter :: timer_launch_compute_kernels = 3
    integer, parameter :: timer_copy_old_solution = 4
    integer, parameter :: timer_cfl = 5
    integer, parameter :: timer_aos_to_soa = 6
    integer, parameter :: timer_soa_to_aos = 7
    integer, parameter :: timer_init_cfls = 8
    integer, parameter :: timer_fluxsv_fluxad = 9
    integer, parameter :: timer_advanc = 10
    integer, parameter :: timer_bound = 11
    integer, parameter :: timer_updating = 12
    integer, parameter :: timer_regridding = 13
#endif

contains
    subroutine take_cpu_timer(timer_name_, timer_id)
        implicit none
        character(len=*), intent(in) :: timer_name_
        integer, intent(in) :: timer_id
        !$OMP MASTER
        if (timer_id > max_cpu_timers) then
            print *, "timer_id for the cpu timer should be between 1 and ", max_cpu_timers
            stop
        endif
        if (.not. cpu_timers(timer_id)%used) then
            cpu_timers(timer_id)%timer_name = timer_name_
            cpu_timers(timer_id)%used = .true.
        else
            ! check to make sure we are not trying to give a new name to a existing timer
            if (cpu_timers(timer_id)%timer_name /= timer_name_) then
                print *, "Warning: trying to take a timer that's already assigned"
            endif
        endif
        !$OMP END MASTER
    end subroutine take_cpu_timer 

    subroutine cpu_timer_start(timer_id)
        implicit none
        integer, intent(in) :: timer_id

        !$OMP MASTER
        if (.not. cpu_timers(timer_id)%used) then
            print *, "Warning: Trying to use a non-initialized cpu timer."
        endif
        if (.not. cpu_timers(timer_id)%running) then
            cpu_timers(timer_id)%running = .true.
            cpu_timers(timer_id)%n_calls = cpu_timers(timer_id)%n_calls + 1
            call system_clock(cpu_timers(timer_id)%start_time, clock_rate)
        else
            print *, "Warning: Trying to start a timer that's already running"
        endif
        !$OMP END MASTER
    end subroutine cpu_timer_start

    subroutine cpu_timer_stop(timer_id)
        implicit none
        integer, intent(in) :: timer_id

        !$OMP MASTER
        if (.not. cpu_timers(timer_id)%used) then
            print *, "Warning: Trying to use a non-initialized cpu timer."
        endif
        if (cpu_timers(timer_id)%running) then
            call system_clock(cpu_timers(timer_id)%stop_time, clock_rate)
            cpu_timers(timer_id)%accumulated_time = cpu_timers(timer_id)%accumulated_time + &
                cpu_timers(timer_id)%stop_time - cpu_timers(timer_id)%start_time
            cpu_timers(timer_id)%running = .false.
        else
            print *, "Warning: Trying to stop a timer that's not running"
        endif
        !$OMP END MASTER
    end subroutine cpu_timer_stop

    subroutine print_all_cpu_timers()
        implicit none
        integer :: i
        double precision :: total_run_time

        !$OMP MASTER
        total_run_time = real(cpu_timers(timer_total_run_time)%accumulated_time,kind=8) &
            /real(clock_rate,kind=8) 

        format_string="('Elapsed wall time recorded by all cpu timers: ')"
        write(*,format_string)
        write(outunit,format_string)

        format_string = "(' ')"
        write(*,format_string)
        write(outunit,format_string)

        format_string="('    Wall Time (seconds)          Percentage (%)        # of Calls')"
        write(*,format_string)
        write(outunit,format_string)
        do i = 1, max_cpu_timers
            if (cpu_timers(i)%used) then
                format_string = "('"//trim(cpu_timers(i)%timer_name)//": ')"
                write(*,format_string)
                write(outunit,format_string)
                format_string="(1f15.3,'           ',1f15.2,'        ',i9)"
                write(*,format_string) &
                    real(cpu_timers(i)%accumulated_time,kind=8)/real(clock_rate,kind=8), &
                    real(cpu_timers(i)%accumulated_time,kind=8)/real(clock_rate,kind=8)/total_run_time*100, &
                    cpu_timers(i)%n_calls
                write(outunit,format_string) &
                    real(cpu_timers(i)%accumulated_time,kind=8)/real(clock_rate,kind=8), &
                    real(cpu_timers(i)%accumulated_time,kind=8)/real(clock_rate,kind=8)/total_run_time*100, &
                    cpu_timers(i)%n_calls
                format_string = "(' ')"
                write(*,format_string)
                write(outunit,format_string)

            endif
        enddo
        !$OMP END MASTER
    end subroutine print_all_cpu_timers


end module timer_module
