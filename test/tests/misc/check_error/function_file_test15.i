# Test for usage of missing function
[Mesh]
  [./square]
    type = GeneratedMeshGenerator
    nx = 2
    ny = 2
    dim = 2
  [../]
[]

[Variables]
  active = 'u'

  [./u]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = FunctionIC
      function = ic_function
    [../]
  [../]

[]

[Functions]
  [./ic_function]
    type = PiecewiseLinear
    data_file = piecewise_linear_rows_more_data.csv
    xy_in_file_only = false
    x_index_in_file = 3 # will generate an error because no forth row of data
    scale_factor = 1.0
  [../]
[]

[Kernels]
  active = 'diff'

  [./diff]
    type = Diffusion
    variable = u
  [../]
[]

[BCs]
  active = 'left right'

  [./left]
    type = DirichletBC
    variable = u
    boundary = 3
    value = 0
  [../]

  [./right]
    type = DirichletBC
    variable = u
    boundary = 1
    value = 1
  [../]
[]

[Executioner]
  type = Steady

  solve_type = 'PJFNK'
[]

[Outputs]
  file_base = out
  exodus = true
[]
