#ifndef UTILITIES_H
#define UTILITIES_H

#include <vector>
#include "parameters.h"
#include <fstream>
#include <iomanip>
#include <iostream>

#include <Eigen/Dense>
#include <unsupported/Eigen/CXX11/Tensor>

class Utilities
{
public:
    Utilities();

    //!Applies linear mixing (result = w*new_value + (1-w)*old_value) where w is the mixing factor.
    //! The mixing factor is in the \param params object. The new_values and old_values are of Eigen::Tensor type (to allow reshaping later) and return value is
    //! also of Tensor type.
    Eigen::Tensor<double, 3> linear_mix(const Parameters &params, const Eigen::Tensor<double, 3> &new_values, const Eigen::Tensor<double, 3> &old_values);

    //!This writes to output files the details of voltage \param V, carrier densities \param p and \param n, current \param J_total, net electron generation rate \param Un.
    //! The files are named according to the applied voltage \param Va of this data.
    void write_details(const Parameters &params, double Va, const Eigen::Tensor<double, 3> &fullV, Eigen::Tensor<double, 3> &fullp, const Eigen::Tensor<double, 3> &J_total_Z, const std::vector<double>  &Up);

    //!Writes to a file the JV data. The file contains 3 columns, the applied voltage \param Va, the current \param J_total,
    //! and the number of iterations \param iter required to converge at that voltage.
    void write_JV(const Parameters &params, std::ofstream &JV, double iter, double Va, const Eigen::Tensor<double, 3> &J_total_Z);

};

#endif // UTILITIES_H
