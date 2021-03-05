[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = true
[]

[Problem]
  coord_type = RZ
[]

[Mesh]
  file = gold/TwoD_Model_w_line.e
[]

[Modules/TensorMechanics/Master]
  [./concrete]
    strain = FINITE
    block = '1'
    add_variables = true
    eigenstrain_names = 'thermal_expansion'
    save_in = 'resid_x resid_y'
  [../]
[]

[Modules/TensorMechanics/LineElementMaster]
  [./rebar]
    block = '2'
    truss = true
    area = area_no6
    displacements = 'disp_x disp_y'
    save_in = 'resid_x resid_y'
  [../]
[]

[Constraints]
  [./rebar_x]
    type = EqualValueEmbeddedConstraint
    secondary = 2
    primary = 1
    variable = 'disp_x'
    primary_variable = 'disp_x'
    formulation = penalty
    penalty = 1e12
  [../]
  [./rebar_y]
    type = EqualValueEmbeddedConstraint
    secondary = 2
    primary = 1
    variable = 'disp_y'
    primary_variable = 'disp_y'
    formulation = penalty
    penalty = 1e12
  [../]
[]

[Variables]
  [./T]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
  [./rh]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.6
  [../]
[]

[Kernels]
  [./T_td]
    type     = TimeDerivative
    variable = T
    block = '1'
  [../]
  [./T_diff]
    type     = Diffusion
    variable = T
    block = '1'
  [../]
  [./rh_td]
    type     = TimeDerivative
    variable = rh
    block = '1'
  [../]
  [./heat_dt]
    type = TimeDerivative
    variable = T
    block = '2'
  [../]
[]

[AuxVariables]
  [./resid_x]
  [../]
  [./resid_y]
  [../]
  [./area_no6]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./area_no6]
    type = ConstantAux
    block = '2'
    variable = area_no6
    value = 284e-6
    execute_on = 'initial timestep_begin'
  [../]
[]

[BCs]
  [./x_disp]
    type = DirichletBC
    variable = disp_x
    boundary = '2'
    value    = 0.0
  [../]
  [./y_disp]
    type = DirichletBC
    variable = disp_y
    boundary = '3'
    value    = 0.0
  [../]
  [./y_disp_loading]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = '1'
    function = -1e-1*y*t
  [../]
  [./T]
    type = DirichletBC
    variable = T
    boundary = '4'
    value    = 23.0
  [../]
  [./RH]
    type = DirichletBC
    variable = rh
    boundary = '4'
    value    = 0.7
  [../]
[]

[Materials]
  [thermal_strain_concrete]
    type                                 = ComputeThermalExpansionEigenstrain
    block                                = '1'
    temperature                          = T
    thermal_expansion_coeff              = 8.0e-6
    stress_free_temperature              = 23.0
    eigenstrain_name                     = thermal_expansion
  []
  [./elastic_stress]
    type = ComputeFiniteStrainElasticStress
    block = '1'
  [../]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    poissons_ratio = 0.3
    youngs_modulus = 1e6
    block = '1'
  [../]

  [truss]
    type                                 = LinearElasticTruss
    block                                = '2'
    youngs_modulus                       = 2.14e11
    temperature                          = T
    thermal_expansion_coeff              = 11.3e-6
    temperature_ref                      = 23.0
  []
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type       = Transient
  start_time = 1209600
  dt = 604800
  automatic_scaling = true
  end_time = 630720000

  solve_type = 'PJFNK'
  nl_max_its = 20
  l_max_its = 100
  nl_abs_tol = 1e-5
  nl_rel_tol = 1e-3
  line_search = none
  petsc_options = '-snes_converged_reason'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Outputs]
  perf_graph     = true
  csv = true
  [./Console]
    type = Console
  [../]
  [./Exo]
    type = Exodus
    elemental_as_nodal = true
  [../]
  dofmap = true
[]

[Debug]
  show_var_residual_norms = true
[]
