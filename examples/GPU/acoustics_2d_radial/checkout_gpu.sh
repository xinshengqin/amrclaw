#!/bin/bash

echo "setting up pyclaw..."
cd $CLAW/pyclaw && git checkout v5.4.1

echo "setting up classic..."
cd $CLAW/classic && git checkout v5.4.1

echo "setting up visclaw..."
cd $CLAW/visclaw && git checkout v5.4.1


echo "setting up riemann..."
cd $CLAW/riemann && \
git remote add gpu https://github.com/xinshengqin/riemann.git && \
git fetch gpu && \
git checkout gpu_amr_paper_benchmark_tag

echo "setting up clawutil..."
cd $CLAW/clawutil && \
git remote add gpu https://github.com/xinshengqin/clawutil.git && \
git fetch gpu && \
git checkout gpu_amr_paper_benchmark_tag

echo "setting up amrclaw..."
cd $CLAW/amrclaw && \
git remote add gpu https://github.com/xinshengqin/amrclaw.git && \
git fetch gpu && \
git checkout gpu_amr_paper_benchmark_tag
