//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "FVMatAdvectionFunctionBC.h"
#include "INSFVAdvectionBase.h"
#include "FVUtils.h"

/**
 * Implements the momentum equation advection term on boundaries. Only useful
 * for MMS since it requires exact solution information
 */
class INSFVMomentumAdvectionFunctionBC : public FVMatAdvectionFunctionBC,
                                         protected INSFVAdvectionBase
{
public:
  static InputParameters validParams();
  INSFVMomentumAdvectionFunctionBC(const InputParameters & params);

protected:
  /**
   * interpolation overload for the velocity
   */
  void interpolate(Moose::FV::InterpMethod m,
                   ADRealVectorValue & interp_v,
                   const ADRealVectorValue & elem_v,
                   const RealVectorValue & ghost_v);

  ADReal computeQpResidual() override;

  void residualSetup() override { clearRCCoeffs(); }
  void jacobianSetup() override { clearRCCoeffs(); }

  const Function & _pressure_exact_solution;

  /// The dynamic viscosity
  const ADMaterialProperty<Real> & _mu;
};
