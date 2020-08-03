//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "libmesh/utility.h"
#include "SurrogateTrainer.h"
#include "MultiApp.h"
#include "MooseTypes.h"
#include "libmesh/parallel.h"
#include "DistributedData.h"

typedef StochasticTools::DistributedData<std::shared_ptr<DenseVector<Real>>> DistributedSnapshots;

class PODReducedBasisTrainer : public SurrogateTrainer
{
public:
  static InputParameters validParams();

  PODReducedBasisTrainer(const InputParameters & parameters);

  virtual void initialSetup() override;

  virtual void initialize() override{};

  virtual void execute() override;

  virtual void finalize() override;

  /// Initializing the reduced operators.
  void initReducedOperators();

  /// Adding a snapshot for a variable.
  void addSnapshot(dof_id_type v_ind,
                   dof_id_type g_ind,
                   const std::shared_ptr<DenseVector<Real>> & snapshot);

  /// Adding the contribution of a residual to the reduced operators.
  void addToReducedOperator(dof_id_type base_i,
                            dof_id_type tag_i,
                            std::vector<DenseVector<Real>> & residual);

  const std::vector<std::string> & getVarNames() const { return _var_names; }

  const std::vector<std::string> & getTagNames() const { return _tag_names; }

  const std::vector<std::string> & getTagTypes() const { return _tag_types; }

  /// Getting the snapshot size across all of the processors.
  dof_id_type getSnapsSize(dof_id_type v_ind);

  /// Getting the base size for a given variable.
  dof_id_type getBaseSize(dof_id_type v_ind) { return _base[v_ind].size(); }

  /// Getting the overall base size, which is the sum of the individial bases.
  dof_id_type getSumBaseSize();

  /// Getting a basis vector for a given variable.
  const DenseVector<Real> & getBasisVector(dof_id_type v_index, dof_id_type base_i) const;

  /// Getting basis vector based on its global index.
  const DenseVector<Real> & getBasisVector(dof_id_type g_index) const;

  /// Getting appropriate variable index for a global base index.
  dof_id_type getVariableIndex(dof_id_type g_index);

protected:
  /// Computes the correlation matrices using the snapshots.
  void computeCorrelationMatrix();

  /// Computes the eigen-decomposition of the stored correlation matrices.
  void computeEigenDecomposition();

  /// Generates the basis vectors using the snapshots together with the
  /// eigendecomposition of the correlation matrices
  void computeBasisVectors();

  /// Prints the eigenvalues of the correlation matrix for each variable.
  void printEigenvalues();

  /// Vector containing the names of the variables we want to use for constructing
  /// the surrogates.
  std::vector<std::string> & _var_names;

  /// Energy limits that define how many basis functions will be kept for each variable.
  std::vector<Real> _error_res;

  /// Names of the tags that should be used to fetch residuals from the MultiApp.
  std::vector<std::string> & _tag_names;

  /// list of bools describing which tag is indepedent of the solution.
  std::vector<std::string> & _tag_types;

  /// Distributed container for snapshots per variable.
  std::vector<DistributedSnapshots> _snapshots;

  /// The correlation matrices for the variables.
  std::vector<DenseMatrix<Real>> _corr_mx;

  /// The eigenvalues of the correalation matrix for each variable.
  std::vector<DenseVector<Real>> _eigenvalues;

  /// The eigenvectors of the correalation matrix for each variable.
  std::vector<DenseMatrix<Real>> _eigenvectors;

  /// The reduced basis for the variables.
  std::vector<std::vector<DenseVector<Real>>> & _base;

  /// The reduced operators that should be transferred to the surrogate.
  std::vector<DenseMatrix<Real>> & _red_operators;

  /// Switch that tells if the object has already computed the necessary basis
  /// vectors. This switch is used in execute() to determine if we want to compute
  /// basis vectors or do something else.
  bool _base_completed;

  /// Flag describing if the reduced operators are empty or not. This is necessary
  /// to be able to do both the base and reduced operator generation in the same
  /// object.
  bool _empty_operators;

private:
  /// Computes the number of bases necessary for a given error indicator. This
  /// needs a sorted vector as input.
  unsigned int determineNumberOfModes(Real error, const std::vector<Real> & inp_vec) const;

  /// Function that manipulates the received objects and computes the
  /// correlation matrices on the fly.
  void receiveObjects(
      ReplicatedMesh & mesh,
      std::unordered_map<dof_id_type, std::vector<std::shared_ptr<DenseVector<Real>>>> &
          received_vectors,
      std::unordered_map<dof_id_type, std::vector<std::shared_ptr<DenseVector<Real>>>> &
          local_vectors,
      processor_id_type /*pid*/,
      const std::vector<std::tuple<dof_id_type, dof_id_type, std::shared_ptr<DenseVector<Real>>>> &
          vectors);
};
