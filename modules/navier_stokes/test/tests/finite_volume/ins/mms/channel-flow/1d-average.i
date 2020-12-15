mu=1.1
rho=1.1
advected_interp_method='average'
velocity_interp_method='average'

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 1
    xmin = 0
    xmax = 1
    nx = 2
  []
[]

[Problem]
  kernel_coverage_check = false
[]

[Variables]
  [u]
    order = CONSTANT
    family = MONOMIAL
    fv = true
    initial_condition = 1
  []
  [pressure]
    order = CONSTANT
    family = MONOMIAL
    fv = true
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    vel = 'velocity'
    pressure = pressure
    u = u
    mu = ${mu}
    rho = ${rho}
    flow_boundaries = 'left right'
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
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    pressure = pressure
    u = u
    mu = ${mu}
    rho = ${rho}
    flow_boundaries = 'left right'
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
  [inlet_u]
    type = FVFunctionDirichletBC
    boundary = 'left'
    variable = u
    function = 'exact_u'
  []
  [outlet_p]
    type = FVFunctionDirichletBC
    boundary = 'right'
    variable = pressure
    function = 'exact_p'
  []
[]

[Materials]
  [ins_fv]
    type = INSFVMaterial
    u = 'u'
    pressure = 'pressure'
    rho = ${rho}
  []
[]

[Functions]
[exact_u]
  type = ParsedFunction
  value = 'sin((1/2)*x*pi)'
[]
[exact_rhou]
  type = ParsedFunction
  value = 'rho*sin((1/2)*x*pi)'
  vars = 'rho'
  vals = '${rho}'
[]
[forcing_u]
  type = ParsedFunction
  value = '(1/4)*pi^2*mu*sin((1/2)*x*pi) + pi*rho*sin((1/2)*x*pi)*cos((1/2)*x*pi) - 1/2*pi*sin((1/2)*x*pi)'
  vars = 'mu rho'
  vals = '${mu} ${rho}'
[]
[exact_p]
  type = ParsedFunction
  value = 'cos((1/2)*x*pi)'
[]
[forcing_p]
  type = ParsedFunction
  value = '(1/2)*pi*rho*cos((1/2)*x*pi)'
  vars = 'rho'
  vals = '${rho}'
[]
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = 'asm      100                lu           NONZERO'
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
