#!/bin/bash -l

#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-gpu=1
#SBATCH --mem=120gb
#SBATCH --output=./test.o%j
#SBATCH --error=./test.e%j
#SBATCH --export=NONE
echo "source $HOME/smart/bin/$COMP/env"
source $HOME/smart/bin/$COMP/env

export LD_LIBRARY_PATH=`pwd`:/pawsey/mwa_sles12sp4/devel/binary/cuda/10.2/lib64/stubs/:$LD_LIBRARY_PATH

srun /pawsey/mwa_sles12sp4/apps/cascadelake/gcc/8.3.0/wsclean/2.9/bin/wsclean -name wsclean_1302850528_20210419070602_briggs -j 6 -size 8192 8192  -pol iquv -abs-mem 120 -weight briggs -1 -scale 0.0335 -nmiter 1 -niter 10000 -threshold 0.050 -mgain 0.85 -minuv-l 30 -join-polarizations -use-idg 1302850528_20210419070602.ms



