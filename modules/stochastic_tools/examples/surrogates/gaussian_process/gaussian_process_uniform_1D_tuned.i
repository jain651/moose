[StochasticTools]
[]

[Distributions]
  [k_dist]
    type = Uniform
    lower_bound = 1
    upper_bound = 10
  []
  [q_dist]
    type = Uniform
    lower_bound = 9000
    upper_bound = 11000
  []
  [L_dist]
    type = Uniform
    lower_bound = 0.01
    upper_bound = 0.05
  []
  [Tinf_dist]
    type = Uniform
    lower_bound = 290
    upper_bound = 310
  []
[]

[Samplers]
  [train_sample]
    type = MonteCarlo
    num_rows = 6
    distributions = 'q_dist'
    execute_on = PRE_MULTIAPP_SETUP
  []
  [cart_sample]
    type = CartesianProduct
    linear_space_items = '9000 20 100'
    execute_on = initial
  []
[]

[MultiApps]
  [sub]
    type = SamplerFullSolveMultiApp
    input_files = sub.i
    sampler = train_sample
  []
[]

[Controls]
  [cmdline]
    type = MultiAppCommandLineControl
    multi_app = sub
    sampler = train_sample
    param_names = 'Kernels/source/value'
  []
[]

[Transfers]
  [data]
    type = SamplerPostprocessorTransfer
    multi_app = sub
    sampler = train_sample
    to_vector_postprocessor = results
    from_postprocessor = 'avg'
  []
[]

[Trainers]
  [GP_avg_trainer]
    type = GaussianProcessTrainer
    execute_on = timestep_end
    covariance_function = 'rbf'
    standardize_params = 'true'               #Center and scale the training params
    standardize_data = 'true'                 #Center and scale the training data
    distributions = 'q_dist'
    sampler = train_sample
    results_vpp = results
    results_vector = data:avg
    tune = 'true'
    tao_options = '-tao_bncg_type kd'
    tune_parameters = ' signal_variance length_factor'
    tuning_min = ' 1e-9 1e-9'
    tuning_max = ' 1e16  1e16'
    show_tao = 'true'
  []
[]

[Covariance]
  [rbf]
    type=SquaredExponentialCovariance
    signal_variance = 1                       #Use a signal variance of 1 in the kernel
    noise_variance = 1e-3                     #A small amount of noise can help with numerical stability
    length_factor = '0.38971'         #Select a length factor for each parameter (k and q)
  []
  [expon]
    type=ExponentialCovariance
    signal_variance = 1                       #Use a signal variance of 1 in the kernel
    noise_variance = 1e-3                     #A small amount of noise can help with numerical stability
    length_factor = '0.551133'         #Select a length factor for each parameter (k and q)
    gamma = 2
  []
  [matern]
    type=MaternHalfIntCovariance
    signal_variance = 1                       #Use a signal variance of 1 in the kernel
    noise_variance = 1e-3                     #A small amount of noise can help with numerical stability
    length_factor = '0.551133'         #Select a length factor for each parameter (k and q)
    p = 1
  []
[]

[Surrogates]
  [gauss_process_avg]
    type = GaussianProcess
    trainer = 'GP_avg_trainer'
  []
[]

# # Computing statistics
[VectorPostprocessors]
  [results]
    type = StochasticResults
  []
  [hyperparams]
    type = GaussianProcessData
    gp_name = 'gauss_process_avg'
    execute_on = final
  []
  [cart_avg]
    type = GaussianProcessTester
    model = gauss_process_avg
    sampler = cart_sample
    output_samples = true
    execute_on = final
  []
  [train_avg]
    type = GaussianProcessTester
    model = gauss_process_avg
    sampler = train_sample
    output_samples = true
    execute_on = final
  []
[]


[Outputs]
  csv = true
  execute_on = FINAL
[]
