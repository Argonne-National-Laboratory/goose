# run as $DEER_DIR/deer-opt -i ETU10_moose_slice_TEMP.i

# These options are copy/pasted into every block
[GlobalParams]
      displacements = 'disp_x disp_y disp_z'
      temperature   = temp
[]

# Load the mesh from the exodus file
[Mesh]
  file = 'ReflectorBlock_ATR2E.exo'
[]

# Setup the physics we want
[Modules/TensorMechanics/Master]
  [./all]
    incremental =  true
    strain = SMALL                        # Small strains
    add_variables = true                  # Automatically add the displacement variables
    volumetric_locking_correction = true  # Bbar type method
    block = 'all'                         # Apply to all blocks
    eigenstrain_names = 'eigen_swell_per eigen_swell_par eigen_thermal_per eigen_thermal_par'
    # Shortcut for making output
    generate_output = 'strain_xx strain_xy strain_xz strain_yx strain_yy strain_yz strain_zx strain_zy strain_zz stress_xx stress_xy stress_xz stress_yx stress_yy stress_yz stress_zx stress_zy stress_zz vonmises_stress'
  [../]
[]

[Functions]
  [./pull]
    type = PiecewiseLinear
    x = '0       60    120'
    y = '0.000  0.01   0.05'
  [../]

   # How the inner temperature goes, as function of time
  [./Tfuel_infinity]
  	type = PiecewiseLinear
    x = '0   	  120'
    y = '600     600'
  [../]

  # How the outer temperature goes, as function of time
  [./Tcool_infinity]
  	type = PiecewiseLinear
    x = '0        120'
    y = '550     550'
  [../]

  # how the fluence goes, this is basically a boundary condition
 [./fluence_func]
   type = ParsedFunction
   value = '0.5*1000*(t/3600*(2.5^(-2*x/1000)))/48'
 [../]
 [./df_dt]
   type = ParsedFunction
   value = '0.5*1000*(1/3600*(2.5^(-2*x/1000)))/48'
 [../]

 [./cond_par] # FOR THE LOVE OF GOD LEAVE the independent parameter "t" untouched!!! it converts to "temp" down the line
   type = ParsedFunction
   value = '10^(-4.3622*rdose^3 - 1.9778*rdose^2*((t-300)/300) + 8.7567*rdose^2 - 0.7768*rdose*((t-300)/300)^2 + 3.1011*rdose*((t-300)/300) - 5.4755*rdose - 0.2338*((t-300)/300) + 2.0734)'
   vars = 'rdose'
   vals = 'fluence_func'

 [../]

 [./cond_per] # FOR THE LOVE OF GOD LEAVE the independent parameter "t" untouched!!! it converts to "temp" down the line
   type = ParsedFunction
   value = '10^(-4.5948*rdose^3 - 2.3628*rdose^2*((t-300)/300) + 8.9334*rdose^2 - 0.5066*rdose*((t-300)/300)^2 + 3.0211*rdose*((t-300)/300) - 5.369*rdose - 0.1018*((t-300)/300) + 1.9477)'
   vars = 'rdose'
   vals = 'fluence_func'
 [../]
[]

[Variables]
  [./temp]
    order = FIRST
    family = LAGRANGE
    initial_condition = 20 # room temperature
  [../]
[]
[AuxVariables]
  [./rdose]
    order = FIRST
    family = LAGRANGE
  [../]
  [./rdf_dt]
    order = FIRST
    family = LAGRANGE
  [../]
  [./rtemp]
    order = FIRST
    family = LAGRANGE
  [../]
  [./tot_swell_per]
    order = FIRST
    family = LAGRANGE
  [../]
  [./tot_swell_par]
    order = FIRST
    family = LAGRANGE
  [../]
  [./cte_per]
    order = FIRST
    family = LAGRANGE
  [../]
  [./cte_par]
    order = FIRST
    family = LAGRANGE
  [../]
  [./cteoCTE0_per]
    order = FIRST
    family = LAGRANGE
  [../]
  [./cteoCTE0_par]
    order = FIRST
    family = LAGRANGE
  [../]
  [./EoverE0_per]
    order = FIRST
    family = LAGRANGE
  [../]
  [./EoverE0_par]
    order = FIRST
    family = LAGRANGE
  [../]
  [./ftemp_per]
    order = FIRST
    family = LAGRANGE
  [../]
  [./ftemp_par]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]  # Kernels Start
  [./heat]
    type = AnisoHeatConduction
    variable = temp
  [../]
[]

[AuxKernels]
  [./rdose]
    type = FunctionAux
    variable = rdose
    function = fluence_func
  [../]
  [./df_dt_AuxK]
    type = FunctionAux
    variable = rdf_dt
    function = df_dt
  [../]
  [./rtemp]
    type = ParsedAux
    variable = rtemp
    args = 'temp'
    function = '(temp-300)/310'
  [../]
  # Kernels for calculating fluence/Temperature dependent variables (from USNC)
  # [./cond_per]
  #   type = ParsedAux
  #   args = 'rtemp rdose'
  #   variable = cond_per
  #   function = '10^(-4.5948*rdose^3 - 2.3628*rdose^2*rtemp + 8.9334*rdose^2 - 0.5066*rdose*rtemp^2 + 3.0211*rdose*rtemp - 5.369*rdose - 0.1018*rtemp + 1.9477)'
  # [../]
  # [./cond_par]
  #   type = ParsedAux
  #   args = 'rtemp rdose'
  #   variable = cond_par
  #   function = '10^(-4.3622*rdose^3 - 1.9778*rdose^2*rtemp + 8.7567*rdose^2 - 0.7768*rdose*rtemp^2 + 3.1011*rdose*rtemp - 5.4755*rdose - 0.2338*rtemp + 2.0734)'
  # [../]

  [./tot_swell_per]
    type = ParsedAux
    args = 'rtemp rdose'
    variable = tot_swell_per
    function = '0.0457*rdose^3 + 0.5134*rdose^2*rtemp + 0.0652*rdose^2 + 0.0209*rdose*rtemp^2 -0.2533*rdose*rtemp - 0.0805*rdose + 0.0201*rtemp - 0.0013'
  [../]
  [./tot_swell_par]
    type = ParsedAux
    args = 'rtemp rdose'
    variable = tot_swell_par
    function = '0.0154*rdose^3 + 0.3496*rdose^2*rtemp + 0.1194*rdose^2 + 0.0060*rdose*rtemp^2 - 0.1534*rdose*rtemp - 0.1453*rdose + 0.0118*rtemp + 0.0032'
  [../]

  [./cte_per]
    type = ParsedAux
    args = 'rtemp'
    variable = cte_per
    function = '10^(-0.0138*rtemp^2 + 0.0470*rtemp - 5.3266)'
  [../]
  [./cte_par]
    type = ParsedAux
    args = 'rtemp'
    variable = cte_par
    function = '10^(0.0031*rtemp^2 + 0.0311*rtemp - 5.3694)'
  [../]

  [./cteoCTE0_per]
    type = ParsedAux
    args = 'rtemp rdose'
    variable = cteoCTE0_per
    function = 'rdose*(-11.2294*rdose^3 - 0.6773*rdose^2*rtemp + 25.7213*rdose^2 + 0.8668*rdose*rtemp^2 +2.0221*rdose*rtemp - 19.3955*rdose - 1.8212*rtemp + 4.5340)'
  [../]
  [./cteoCTE0_par]
    type = ParsedAux
    args = 'rtemp rdose'
    variable = cteoCTE0_par
    function = 'rdose*(-12.3630*rdose^3 - 1.8131*rdose^2*rtemp + 28.2704*rdose^2 + 0.9908*rdose*rtemp^2 + 2.8790*rdose*rtemp - 20.7107*rdose - 1.8124*rtemp + 4.4968)'
  [../]

  [./EoverE0_per]
    type = ParsedAux
    args = 'rtemp rdose'
    variable = EoverE0_per
    function = '10^(rdose*(-2.0292*rdose^3*rtemp - 3.6907*rdose^3 + 8.0563*rdose^2 - 1.1838*rdose*rtemp^2 -7.2427*rdose + 0.2677*rtemp + 3.2782))'
  [../]
  [./EoverE0_par]
    type = ParsedAux
    args = 'rtemp rdose'
    variable = EoverE0_par
    function = '10^(rdose*(-1.1151*rdose^3*rtemp - 4.0862*rdose^3 + 8.9432*rdose^2 - 1.2401*rdose*rtemp^2 -7.9756*rdose + 0.0426*rtemp + 3.4617))'
  [../]

  [./ftemp_per]
    type = ParsedAux
    args = 'temp'
    variable = ftemp_per
    function = 'temp-20'
  [../]
  [./ftemp_par]
    type = ParsedAux
    args = 'temp'
    variable = ftemp_par
    function = 'temp-20'
  [../]

[]  # Kernels END

[BCs]
  [./nodesbcz]
    type = DirichletBC
    variable = disp_z
    boundary = 'bottom'
    value = 0.0
    preset = true
  [../]

    #Applies the inner temperature
  [./fuelHoles]
    type = ConvectiveFluxFunction
    variable = temp
    boundary = 'small_hole'
    coefficient = 0.0004
    T_infinity = Tfuel_infinity
  [../]

  #Applies the outer temperature
  [./coolantHoles]
    type = ConvectiveFluxFunction
    variable = temp
    boundary = 'big_hole'
    coefficient = 0.0001
    T_infinity = Tcool_infinity
  [../]

[]

[Materials]
  [./var_dependence_EoverEoPar]
    type = DerivativeParsedMaterial
    f_name = var_dep_EoverEoPar
    block = 'all'
    args = EoverE0_par
    function = 'EoverE0_par+0.1'
    outputs = exodus
    output_properties = 'var_dep_EoverEoPar'
    # enable_jit = true
    # derivative_order = 2
  [../]
  [./var_dependence_EoverEoPer]
    type = DerivativeParsedMaterial
    f_name = var_dep_EoverEoPer
    block = 'all'
    args = EoverE0_per
    function = 'EoverE0_per+0.1'
    outputs = exodus
    output_properties = 'var_dep_EoverEoPer'
    # enable_jit = true
    # derivative_order = 2
  [../]
  [./var_dependence_swellPar]
    type = DerivativeParsedMaterial
    f_name = var_dep_swellPar
    block = 'all'
    args = tot_swell_par
    function = 'tot_swell_par*1'
    outputs = exodus
    output_properties = 'var_dep_swellPar'
    enable_jit = true
    derivative_order = 2
  [../]
  [./var_dependence_swellPer]
    type = DerivativeParsedMaterial
    f_name = var_dep_swellPer
    block = 'all'
    args = tot_swell_per
    function = 'tot_swell_per*1'
    outputs = exodus
    output_properties = 'var_dep_swellPer'
    enable_jit = true
    derivative_order = 2
  [../]
  [./var_dependence_thermalPer]
    type = DerivativeParsedMaterial
    f_name = var_dep_thermalPer
    block = 'all'
    args = 'cteoCTE0_per cte_per ftemp_per'
    function = 'cte_per*cteoCTE0_per*ftemp_per'
    outputs = exodus
    output_properties = 'var_dep_thermalPer'
    enable_jit = true
    derivative_order = 2
  [../]
  [./var_dependence_thermalPar]
    type = DerivativeParsedMaterial
    f_name = var_dep_thermalPar
    block = 'all'
    args = 'cteoCTE0_par cte_par ftemp_par'
    function = 'cte_par*cteoCTE0_par*ftemp_par'
    outputs = exodus
    output_properties = 'var_dep_thermalPar'
    enable_jit = true
    derivative_order = 2
  [../]

  [./eigenstrainSwellPer]
    type = ComputeVariableEigenstrain
    block = 'all'
    eigen_base = '0 0 1 0 0 0'
    prefactor = var_dep_swellPer
    args = 'tot_swell_per'
    eigenstrain_name = eigen_swell_per
  [../]
  [./eigenstrainSwellPar]
    type = ComputeVariableEigenstrain
    block = 'all'
    eigen_base = '1 1 0 0 0 0'
    prefactor = var_dep_swellPar
    args = 'tot_swell_par'
    eigenstrain_name = eigen_swell_par
  [../]
  [./eigenstrainThermalPer]
    type = ComputeVariableEigenstrain
    block = 'all'
    eigen_base = '0 0 1 0 0 0'
    prefactor = var_dep_thermalPer
    args = 'cteoCTE0_per cte_per ftemp_per'
    eigenstrain_name = eigen_thermal_per
  [../]
  [./eigenstrainThermalPar]
    type = ComputeVariableEigenstrain
    block = 'all'
    eigen_base = '1 1 0 0 0 0'
    prefactor = var_dep_thermalPar
    args = 'cteoCTE0_par cte_par ftemp_par'
    eigenstrain_name = eigen_thermal_par
  [../]

  [./thermal1]
    type =AnisoHeatConductionMaterialGraphite
    block = 'all'
    thermal_conductivity_x_temperature_function = cond_par
    thermal_conductivity_y_temperature_function = cond_par
    thermal_conductivity_z_temperature_function = cond_per
    temp = temp
  [../]

  [./kelvin_voigt]
    type = GeneralizedKelvinVoigtModelGraphite
    alpha = 1.44 # Primary Creep Constant
    gamma = 2.25 # Primary Creep constant
    kappa = 0.82 # Secondary Creep Constant
    poisson_ratio = 0.15 #for elastic strain
    young_modulus_par = 9167.69 #for elastic strain
    young_modulus_per = 8918.94
    fluence_function_dT = df_dt
    EoverE0_par = var_dep_EoverEoPar
    EoverE0_per = var_dep_EoverEoPer
  [../]

  [./stress]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'creep'
  [../]
  [./creep]
    type = LinearViscoelasticStressUpdate
  [../]
[]

[UserObjects]
 [./update]
   type = LinearViscoelasticityManager
   viscoelastic_model = kelvin_voigt
 [../]
[]

# [Postprocessors]
#   [./temperature]
#     type = AverageNodalVariableValue
#     variable = temp
#     block = 'all'
#   [../]
# []


[Preconditioning]
  [./SMP]
    type = SMP
    full = true                     # Use the full algorithmic tangent
  [../]
[]

[Executioner]
  type = Transient
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'
  #petsc_options_iname = '-pc_type'  # PETSc options:
  #petsc_options_value = 'lu'        # use simple, serial LU factorization
  # petsc_options_iname = '-ksp_type -pc_type -snes_type'
  # petsc_options_value = 'bcgs bjacobi test'
  solve_type = NEWTON               # Use Newton-Raphson, not PJFNK
  line_search = none
  nl_abs_tol = 1e-5
  nl_rel_tol = 1e-2
  l_tol = 1e-5
  dt = 60
  end_time = 120
  l_max_its  = 50
  nl_max_its  = 20
                # End time
[]

[Outputs]
  exodus = true         # Output an exodus file
[]
