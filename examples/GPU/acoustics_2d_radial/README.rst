
.. _amrclaw_examples_acoustics_2d_radial:

Two-dimensional acoustics with radially symmetric initial data
==============================================================

This example shows the setup in the benchmark used in the paper: Accelerating wave-propagation algorithms with adaptive mesh refinement using the Graphics Processing Unit (GPU).
It is a 2D acoustics problem with radial symmetric initial conditions.  The solution should remain radially symmetric.  

One should install Clawpack package by following the instructions on: http://www.clawpack.org/developers.html#installation-instructions-for-developers

After intalling Clawpack, add remote url to the sub-modules (if needed) and check out the tag as instructed below to properly compile the code. Note that $CLAW is the root directory of Clawpack.

* pyclaw: 

.. code-block:: shell

  cd $CLAW/pyclaw 
  git checkout v5.4.1


* classic: 

.. code-block:: shell

  cd $CLAW/classic 
  git checkout v5.4.1

* visclaw: 

.. code-block:: shell

  cd $CLAW/visclaw 
  git checkout v5.4.1

* geoclaw: 

.. code-block:: shell

  cd $CLAW/geoclaw 
  git checkout v5.4.1

* riemann: 

.. code-block:: shell

  cd $CLAW/riemann 
  git remote add gpu https://github.com/xinshengqin/riemann.git
  git fetch gpu --no-tags refs/tags/gpu_amr_paper_benchmark_tag:refs/tags/gpu_amr_paper_benchmark_tag
  git checkout gpu_amr_paper_benchmark_tag

* clawutil: 

.. code-block:: shell

  cd $CLAW/clawutil 
  git remote add gpu https://github.com/xinshengqin/clawutil.git
  git fetch gpu --no-tags refs/tags/gpu_amr_paper_benchmark_tag:refs/tags/gpu_amr_paper_benchmark_tag
  git checkout gpu_amr_paper_benchmark_tag

* amrclaw:

.. code-block:: shell

  cd $CLAW/amrclaw 
  git remote add gpu https://github.com/xinshengqin/amrclaw.git
  git fetch gpu --no-tags refs/tags/gpu_amr_paper_benchmark_tag:refs/tags/gpu_amr_paper_benchmark_tag
  git checkout gpu_amr_paper_benchmark_tag


Alternatively, after intalling Clawpack, one can download the bash script, checkout_gpu.sh, in this directory, put it in Clawpack root directory, $CLAW, and run it with 

.. code-block:: shell

    bash ./checkout_gpu.sh

