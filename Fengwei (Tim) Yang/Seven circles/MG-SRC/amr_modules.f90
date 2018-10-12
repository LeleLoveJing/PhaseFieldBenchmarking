!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!  
!!!! Provides modules with common parameters used throughout generic and 
!!!! application specific codes
!!!!  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!  
!!!!  multigrid_parameters
!!!!  * Parameters primarily concerned with MG algorithm, also BCs
!!!!  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!  
!!!!  time_dep_parameters
!!!!  * Timestep sizes, tolerances, etc
!!!!  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!  
!!!!  checkpoint_parameters
!!!!  * Parameters for loading checkpoints from command line arguments
!!!!  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!  
!!!!  generic_parameters
!!!!  * Other parameters not fitting above, e.g. verbosity of output
!!!!  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!  Chris Goodyer, May 2012                                              !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module multigrid_parameters
  ! module that should control everything to do with the multigrid
  ! note this module was the first and will contain anything which hasn't 
  ! subsequently found a more appropriate module
  ! Weighting, probably optimal at 2/3 for linear elliptic, .7-.9 for most others
  double precision :: weight = 0.885!2.0/3.0
  double precision :: weight_2 = 0.885
  double precision :: weight_3 = 0.885
  ! How many pre/post smooths
  integer :: smooth_count_max = 4
  ! How many smooths constitute a full solve
  integer :: solve_count_max = 8
  ! Lowest (coarsest) refinement level which v-cycles go to
  integer :: mg_min_lvl
  ! Highest (finest) ref level, set by amr_mg_get_max_refinement
  integer :: mg_max_level = -1
  ! How many v-cycles to do before giving up and doing something else
  integer :: max_v_cycle_count = 10

  ! tolerance value which the max abs of the defect will be tested against
!  double precision :: defect_tol=1e-10
  double precision :: defect_tol_min = 1e-12    ! Defect test for convergence of timestep 
  double precision :: defect_too_big = 1.0e-7   ! Final defect test for failing timestep
  double precision :: defect_tol_max = 1e3      ! Intermediate defect test for failing timestep
  integer :: low_vcycle_count = 3               ! Has converged too easily
  integer :: high_vcycle_count = 6              ! Has converged too slowly

  double precision :: ep
  integer :: interpolating = 0
  integer :: desired_lvl
  integer :: switch1 = 0

  integer, allocatable, dimension (:) :: nodetype_copy       ! used for guardcell/solution reasons
  logical, allocatable, dimension (:) :: has_children        ! used to limit operations

  ! Variables which are used by the code, lots
  integer :: current_var, total_vars, current_unk, current_work
  ! delta x on finest grid
  double precision :: min_dx
  ! How many variables per variable
  integer, parameter :: nunkvbles = 5
  !Boundary conditions
  integer, parameter :: bc_cond_far = -21    ! Far field
  integer, parameter :: bc_cond_sym = -22    ! Symmetry

  double precision :: grid_max
  double precision :: grid_min

  ! Monitoring value of whether updates have been made in this smooth
  double precision :: mg_update_total = 1.0   ! Positive means will always fail test if not set

end module multigrid_parameters

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module time_dep_parameters
  ! Module for time dependent stuff
  ! Mode controls the time advance code, leave at 1 for now
  integer :: mode_1 = 1
  ! current value for dt, not a parameter for variable dt later
  double precision :: dt = 1.0e-6
  ! old value for dt
  double precision :: dtold
  ! Max possible value of dt
  double precision :: max_dt
  ! Min possible value of dt
  double precision :: min_dt = 1.0e-8
  ! total simulation time (end time-start time, not just end time)
  ! Note start time is set in solution parameters
!  double precision :: simulation_time = 10.0 ! 200
  double precision :: simulation_time = 20000.0
!  double precision :: simulation_time = 1000.0
  ! current value of time
  double precision :: time
  ! max number of dt steps to take, leave this as a biiiiiiiiig number
  integer :: max_time_iter = 300000000

  integer :: shampine_test=1
  double precision :: shampine_beta, shampine_tol = 3.0E-10

  ! Timestep change parameters
  integer :: stepsize_increase_frequency = 1  ! Every how often may timestep increaseses be imposed
  double precision :: lee_tol_failing = 0.1   ! Local error estimation tolerance for failing a timestep
  double precision :: lee_tol_halving = 0.1   ! Local error estimation tolerance for halving the stepsize
  double precision :: lee_tol_decrease = 0.1  ! Local error estimation tolerance for decreasing the stepsize
  double precision :: lee_tol_increase = 0.1  ! Local error estimation tolerance for doubling the stepsize

end module time_dep_parameters

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module refinement_parameters

  ! Are we doing the phase field case trying derefinement whenever all block values are 1
  logical :: allsolid_test = .false.
  ! Error limits which control the refinement and derefinement requests below.
  double precision :: ctore = 0.1                ! Refinement
  double precision :: ctode = 0.01               ! Derefinement

end module refinement_parameters

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module checkpoint_parameters
  ! module for checkpointing information
  integer :: chk_chkpt
  double precision :: chk_dt, chk_t, chk_dtold
  integer :: chk_restart, incset
  character *80 :: chk_checkf
end module checkpoint_parameters

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module generic_parameters
  ! Switches for main code that applications will want to turn on or off as appropriate
  ! Will the amr_test_refinement and amr_refine_derefine calls be made?
  integer :: local_adaptation = 1
  ! How many global refinements are needed
  integer :: numglobalref = 0
  ! Will the domain be allowed to grow as needed?
  integer :: grow = 1
  ! Text output verbosity
  integer :: verbose = 1
  ! How often are the checkpoints, etc, produced in app_output_occasional
  integer :: output_rate = 100

end module 

