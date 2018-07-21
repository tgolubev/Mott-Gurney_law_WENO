# Drift-Diffusion_models

3D Drift Diffusion 

This contains Matlab and C++ implementations for solving the semiconductor drift-diffusion equations in 3D using finite differences. The "Two-charge-carriers" versions of the models currently solve for a solar cell under illumination. The "Single-charge-carrier" versions solve for the current-voltage curve of a material which only has holes as the free carrier and is under a varying applied voltage in the dark.  All of the models can be modified to solve other systems (i.e. through changing the boundary conditions, adding recombination rates, and modifying the generation rate). 

The equations are Poisson eqn, 
continuity equation, and drift-diffusion equation which are solved in a decoupled iterative method (Gummel method). Scharfetter-Gummel
discretization as well as linear mixing of old and new solutions is used to maintain stability.


Periodic boundary conditions are used for the x and y boundaries and Dirichlet boundary conditions are used for the z boundaries in order to be able to apply a voltage in the z direction. The electrodes of the device are assumed to be located at z = 0 and z = Lz.
