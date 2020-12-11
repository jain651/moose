//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "Sampler.h"

/**
 * A class used to perform Monte Carlo Sampling
 */
class CSVSampler : public Sampler
{
public:
  static InputParameters validParams();

  CSVSampler(const InputParameters & parameters);

protected:
  /// Return the sample for the given row and column
  virtual Real computeSample(dof_id_type row_index, dof_id_type col_index) override;

  /// Indices of columns that are to be read from the data file
  std::vector<dof_id_type> _indices;

  /// Data read in from the CSV file
  std::vector<std::vector<Real>> _data;

private:
  /// PerfGraph timer
  const PerfID _perf_compute_sample;
};
