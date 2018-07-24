#!/bin/bash

echo "setting up pyclaw..."
cd ./pyclaw && git checkout v5.4.1 && cd ../

echo "setting up classic..."
cd ./classic && git checkout v5.4.1 && cd ../

echo "setting up visclaw..."
cd ./visclaw && git checkout v5.4.1 && cd ../

echo "setting up geoclaw..."
cd ./geoclaw && git checkout v5.4.1 && cd ../


echo "setting up riemann..."
cd ./riemann && \
git remote add gpu https://github.com/xinshengqin/riemann.git && \
git fetch gpu  --no-tags refs/tags/gpu_amr_paper_benchmark_tag:refs/tags/gpu_amr_paper_benchmark_tag && \
git checkout gpu_amr_paper_benchmark_tag && \
cd ..

echo "setting up clawutil..."
cd ./clawutil && \
git remote add gpu https://github.com/xinshengqin/clawutil.git && \
git fetch gpu --no-tags refs/tags/gpu_amr_paper_benchmark_tag:refs/tags/gpu_amr_paper_benchmark_tag && \
git checkout gpu_amr_paper_benchmark_tag && \
cd ..

echo "setting up amrclaw..."
cd ./amrclaw && \ 
git remote add gpu https://github.com/xinshengqin/amrclaw.git && \
git fetch gpu --no-tags refs/tags/gpu_amr_paper_benchmark_tag:refs/tags/gpu_amr_paper_benchmark_tag && \
git checkout gpu_amr_paper_benchmark_tag && \
cd ..
