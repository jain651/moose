//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "GeochemicalModelDefinition.h"
#include "GeochemicalSystem.h"
#include "NodalUserObject.h"

/**
 * Base class that controls the spatio-temporal solution of geochemistry reactions
 */
class GeochemistryReactorBase : public NodalUserObject
{
public:
  static InputParameters validParams();
  GeochemistryReactorBase(const InputParameters & parameters);
  virtual void initialize() override;
  virtual void threadJoin(const UserObject & uo) override final;
  virtual void finalize() override;
  virtual void execute() override;

  /**
   * @return a reference to the equilibrium geochemical system at the given point
   * @param point the point of interest
   */
  virtual const GeochemicalSystem & getGeochemicalSystem(const Point & point) const = 0;

  /**
   * @return a reference to the equilibrium geochemical system at the given node
   * @param node_id the ID of the node
   */
  virtual const GeochemicalSystem & getGeochemicalSystem(unsigned node_id) const = 0;

  /**
   * @return a reference to the most recent solver output (containing iteration info, swap info,
   * residuals, etc)
   * @param point the point of interest
   */
  virtual const std::stringstream & getSolverOutput(const Point & point) const = 0;

  /**
   * @return the total number of iterations used by the most recent solve at the point
   * @param point the point of interest
   */
  virtual unsigned getSolverIterations(const Point & point) const = 0;

  /**
   * @return the L1norm of the residual at the end of the most recent solve at the point
   * @param point the point of interest
   */
  virtual Real getSolverResidual(const Point & point) const = 0;

protected:
  /// my copy of the underlying ModelGeochemicalDatabase
  ModelGeochemicalDatabase _mgd;
  /// number of basis species
  const unsigned _num_basis;
  /// number of equilibrium species
  const unsigned _num_eqm;
  /// Initial value of maximum ionic strength
  const Real _initial_max_ionic_str;
  /// The ionic strength calculator
  GeochemistryIonicStrength _is;
  /// The activity calculator
  GeochemistryActivityCoefficientsDebyeHuckel _gac;
  /// Maximum number of swaps allowed during a single solve
  const unsigned _max_swaps_allowed;
  /// The species swapper
  GeochemistrySpeciesSwapper _swapper;
  /// A small value of molality
  const Real _small_molality;
  /// The solver output
  std::stringstream _solver_output;
  /// Number of iterations used by the solver
  unsigned _tot_iter;
  /// L1norm of the solver residual
  Real _abs_residual;
};
