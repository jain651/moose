mu = 1
rho = 1
k = .01
cp = 1
vel = 'velocity'
velocity_interp_method = 'rc'
advected_interp_method = 'average'

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    nx = 32
    ny = 32
  []
  [pin]
    type = ExtraNodesetGenerator
    input = gen
    new_boundary = 'pin'
    nodes = '0'
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
  []
  [v]
    order = CONSTANT
    family = MONOMIAL
    fv = true
  []
  [pressure]
    order = CONSTANT
    family = MONOMIAL
    fv = true
  []
  [T]
    order = CONSTANT
    family = MONOMIAL
    fv = true
  []
  [lambda]
    family = SCALAR
    order = FIRST
  []
[]

[ICs]
  [T]
    type = ConstantIC
    variable = T
    value = 1
  []
[]

[AuxVariables]
  [U]
    order = CONSTANT
    family = MONOMIAL
    fv = true
  []
[]

[AuxKernels]
  [mag]
    type = VectorMagnitudeAux
    variable = U
    x = u
    y = v
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    vel = ${vel}
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    u = u
    v = v
    pressure = pressure
    mu = ${mu}
    rho = ${rho}
    no_slip_wall_boundaries = 'left right top bottom'
  []
  [mean_zero_pressure]
    type = FVScalarLagrangeMultiplier
    variable = pressure
    lambda = lambda
  []

  [u_time]
    type = INSFVMomentumTimeDerivative
    variable = 'u'
    rho = ${rho}
  []
  [u_advection]
    type = INSFVMomentumAdvection
    variable = u
    advected_quantity = 'rhou'
    vel = ${vel}
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    pressure = pressure
    u = u
    v = v
    mu = ${mu}
    rho = ${rho}
    no_slip_wall_boundaries = 'left right top bottom'
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

  [v_time]
    type = INSFVMomentumTimeDerivative
    variable = v
    rho = ${rho}
  []
  [v_advection]
    type = INSFVMomentumAdvection
    variable = v
    advected_quantity = 'rhov'
    vel = ${vel}
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    pressure = pressure
    u = u
    v = v
    mu = ${mu}
    rho = ${rho}
    no_slip_wall_boundaries = 'left right top bottom'
  []
  [v_viscosity]
    type = FVDiffusion
    variable = v
    coeff = ${mu}
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = v
    momentum_component = 'y'
    p = pressure
  []

  [temp_time]
    type = INSFVEnergyTimeDerivative
    variable = T
    rho = ${rho}
  []
  [temp_conduction]
    type = FVDiffusion
    coeff = 'k'
    variable = T
  []
  [temp_advection]
    type = INSFVEnergyAdvection
    variable = T
    vel = ${vel}
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
    pressure = pressure
    u = u
    v = v
    mu = ${mu}
    rho = ${rho}
    no_slip_wall_boundaries = 'left right top bottom'
  []
[]

[FVBCs]
  [top_x]
    type = FVFunctionDirichletBC
    variable = u
    function = 'lid_function'
    boundary = 'top'
  []

  [no_slip_x]
    type = FVDirichletBC
    variable = u
    value = 0
    boundary = 'left right bottom'
  []

  [no_slip_y]
    type = FVDirichletBC
    variable = v
    value = 0
    boundary = 'left right top bottom'
  []

  [T_hot]
    type = FVDirichletBC
    variable = T
    boundary = 'bottom'
    value = 1
  []

  [T_cold]
    type = FVDirichletBC
    variable = T
    boundary = 'top'
    value = 0
  []
[]

[Materials]
  [const]
    type = ADGenericConstantMaterial
    prop_names = 'k cp'
    prop_values = '${k} ${cp}'
  []
  [ins_fv]
    type = INSFVMaterial
    u = 'u'
    v = 'v'
    pressure = 'pressure'
    temperature = 'T'
    rho = ${rho}
  []
[]

[Functions]
  [lid_function]
    type = ParsedFunction
    value = '4*x*(1-x)'
  []
[]


[Executioner]
  type = Transient
  solve_type = NEWTON
  # Run for 100+ timesteps to reach steady state.
  num_steps = 5
  dt = .5
  dtmin = .5
  petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -ksp_gmres_restart'
  petsc_options_value = 'asm      lu           NONZERO                   200'
  line_search = 'none'
  nl_rel_tol = 1e-12
  nl_max_its = 6
  l_max_its = 200
[]

[Outputs]
  exodus = true
[]
