
.. _amrclaw_examples_acoustics_2d_radial:

Two-dimensional acoustics with radially symmetric initial data
==============================================================

This example shows the setup in the benchmark used in the paper: Accelerating wave-propagation algorithms with adaptive mesh refinement using the Graphics Processing Unit (GPU).
It is a 2D acoustics problem with radial symmetric initial conditions.  The solution should remain radially symmetric.  

One should install Clawpack package by following the instructions on: http://www.clawpack.org/developers.html
Then, each sub-module should be checked-out at the branches specified below in order to properly compile the code.
* pyclaw: tag: v5.4.1
* classic: tag: v5.4.1
* visclaw: tag: v5.4.1
* riemann: gpu_amr_paper_benchmark
* clawutil: gpu_amr_paper_benchmark
* amrclaw: gpu_amr_paper_benchmark
