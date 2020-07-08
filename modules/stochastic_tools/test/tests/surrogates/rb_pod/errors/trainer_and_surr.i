[StochasticTools]
[]

[Distributions]
  [k_dist]
    type = Uniform
    lower_bound = 2.5
    upper_bound = 7.5
  []
  [alpha_dist]
    type = Uniform
    lower_bound = 2.5
    upper_bound = 7.5
  []
  [S_dist]
    type = Uniform
    lower_bound = 2.5
    upper_bound = 7.5
  []
[]

[Samplers]
  [train_sample]
    type = LatinHypercube
    distributions = 'k_dist alpha_dist S_dist'
    num_rows = 3
    num_bins = 3
    execute_on = PRE_MULTIAPP_SETUP
  []
  [test_sample]
    type = LatinHypercube
    distributions = 'k_dist alpha_dist S_dist'
    num_rows = 10
    num_bins = 3
    seed = 17
    execute_on = PRE_MULTIAPP_SETUP
  []
[]

[MultiApps]
  [sub]
    type = PODFullSolveMultiApp
    input_files = sub.i
    sampler = train_sample
    trainer_name = 'pod_rb'
    execute_on = 'timestep_begin final'
  []
[]

[Transfers]
  [quad]
    type = SamplerParameterTransfer
    multi_app = sub
    sampler = train_sample
    parameters = 'Materials/k/prop_values Materials/alpha/prop_values Kernels/source/value'
    to_control = 'stochastic'
    execute_on = 'timestep_begin'
    check_multiapp_execute_on = false
  []
  [data]
    type = SamplerSolutionTransfer
    multi_app = sub
    sampler = train_sample
    trainer_name = 'pod_rb'
    direction = 'from_multiapp'
    execute_on = 'timestep_begin'
    check_multiapp_execute_on = false
  []
  [mode]
    type = SamplerSolutionTransfer
    multi_app = sub
    sampler = train_sample
    trainer_name = 'pod_rb'
    direction = 'to_multiapp'
    execute_on = 'final'
    check_multiapp_execute_on = false
  []
  [res]
    type = ResidualTransfer
    multi_app = sub
    sampler = train_sample
    trainer_name = "pod_rb"
    execute_on = 'final'
    check_multiapp_execute_on = false
  []
[]

[Trainers]
  [pod_rb]
    type = PODReducedBasisTrainer
    var_names = 'u'
    en_limits = '0.999999999'
    tag_names = 'diff react bodyf'
    independent = '0 0 1'
    execute_on = 'timestep_begin final'
  []
[]

[Surrogates]
  [rbpod]
    type = PODReducedBasisSurrogate
    trainer = pod_rb
  []
[]

[VectorPostprocessors]
  [res]
    type = PODSurrogateTester
    model = rbpod
    sampler = test_sample
    variable_name = "u"
    to_compute = nodal_max
    execute_on = 'final'
  []
[]