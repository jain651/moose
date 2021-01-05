mu=1.1
rho=1.1

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 1
    xmin = 2
    xmax = 3
    nx = 2
  []
[]

[Problem]
  coord_type = 'RZ'
  kernel_coverage_check = false
  fv_bcs_integrity_check = false
[]

[Variables]
  [u]
    type = INSFVVelocityVariable
    initial_condition = 1
  []
  [pressure]
    type = INSFVPressureVariable
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    advected_interp_method = 'average'
    velocity_interp_method = 'average'
    vel = 'velocity'
    pressure = pressure
    u = u
    mu = ${mu}
    rho = ${rho}
  []
  [mass_forcing]
    type = FVBodyForce
    variable = pressure
    function = forcing_p
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = u
    advected_quantity = 'rhou'
    vel = 'velocity'
    advected_interp_method = 'average'
    velocity_interp_method = 'average'
    pressure = pressure
    u = u
    mu = ${mu}
    rho = ${rho}
  []
  [u_viscosity]
    type = FVDiffusion
    variable = u
    coeff = ${mu}
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = u
    momentum_component = 'x'
    p = pressure
  []
  [u_forcing]
    type = FVBodyForce
    variable = u
    function = forcing_u
  []

[]

[FVBCs]
  [u_advection]
    type = FVMatAdvectionFunctionBC
    boundary = 'left right'
    variable = u
    vel = 'velocity'
    flux_variable_exact_solution = 'exact_rhou'
    advected_quantity = 'rhou'
    advected_interp_method = 'average'
    vel_x_exact_solution = 'exact_u'
  []
  [u_diffusion]
    type = FVDiffusionFunctionBC
    boundary = 'left right'
    variable = u
    exact_solution = 'exact_u'
    coeff = '${mu}'
    coeff_function = '${mu}'
  []

  [mass_continuity_flux]
    type = FVMatAdvectionFunctionBC
    variable = pressure
    boundary = 'left right'
    vel = 'velocity'
    vel_x_exact_solution = 'exact_u'
    flux_variable_exact_solution = ${rho}
    advected_quantity = ${rho}
  []

  [u_diri]
    type = FVFunctionDirichletBC
    variable = u
    boundary = 'left right'
    function = 'exact_u'
  []
  [p_diri]
    type = FVFunctionDirichletBC
    variable = pressure
    boundary = 'left right'
    function = 'exact_p'
  []
[]

[Materials]
  [ins_fv]
    type = INSFVMaterial
    u = 'u'
    # we need to compute this here for advection in INSFVMomentumPressure
    pressure = 'pressure'
    rho = ${rho}
  []
[]

[Functions]
[exact_u]
  type = ParsedFunction
  value = 'sin(x)'
[]
[exact_rhou]
  type = ParsedFunction
  value = 'rho*sin(x)'
  vars = 'rho'
  vals = '${rho}'
[]
[forcing_u]
  type = ParsedFunction
  value = '-sin(x) - (-x*mu*sin(x) + mu*cos(x))/x + (2*x*rho*sin(x)*cos(x) + rho*sin(x)^2)/x'
  vars = 'mu rho'
  vals = '${mu} ${rho}'
[]
[exact_p]
  type = ParsedFunction
  value = 'cos(x)'
[]
[forcing_p]
  type = ParsedFunction
  value = '(x*rho*cos(x) + rho*sin(x))/x'
  vars = 'rho'
  vals = '${rho}'
[]
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_pc_type -sub_pc_factor_shift_type -ksp_max_it'
  petsc_options_value = 'asm      100                lu           NONZERO                  100'
[]

[Outputs]
  exodus = true
  csv = true
  [dof]
    type = DOFMap
    execute_on = 'initial'
  []
[]

[Postprocessors]
  [h]
    type = AverageElementSize
    outputs = 'console csv'
    execute_on = 'timestep_end'
  []
  [./L2u]
    type = ElementL2Error
    variable = u
    function = exact_u
    outputs = 'console csv'
    execute_on = 'timestep_end'
  [../]
  [./L2p]
    variable = pressure
    function = exact_p
    type = ElementL2Error
    outputs = 'console csv'
    execute_on = 'timestep_end'
  [../]
[]
