#!/bin/bash -l

# sbatch -p gpuq -M $sbatch_cluster ./pawsey_submit_1second.sh 10

#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=10
#SBATCH --mem=128gb
#SBATCH --output=./test.o%j
#SBATCH --error=./test.e%j
#SBATCH --export=NONE

source $HOME/smart/bin/$COMP/env
# chgcentre_path=""
comp=`hostname`
if [[ $comp == "mwa-process02" ]]; then
   # specific for mwa-process02
   # chgcentre_path="/home/msok/mwa_software/anoko/anoko/chgcentre/build/"
   export PATH=/home/msok/mwa_software/anoko/anoko/chgcentre/build/:$PATH
fi
if [[ -n $cluster ]]; then
   echo "Cluster $cluster detected"
   comp=$cluster
fi


timestep=10
if [[ -n "$1" && "$1" != "-" ]]; then
   timestep=$1
fi
timestep_str=`echo $timestep | awk '{printf("%03d\n",$1);}'`

echo "#########################################################################"
echo "PARAMETERS:"
echo "#########################################################################"
echo "timestep = $timestep -> $timestep_str "
echo "#########################################################################"


# echo "srun wsclean -name wsclean_1103645160_briggs_timeindex010 -j 12 -size 4096 4096  -pol XX,YY,XY,YX -abs-mem 128 -weight briggs 2 -scale 0.0103 -multiscale -mgain 0.8 -niter 100000 -auto-mask 3 -auto-threshold 1.2 -local-rms -circular-beam -minuv-l 30 -interval 10 11 -join-polarizations  1103645160.ms"
# srun wsclean -name wsclean_1103645160_briggs_timeindex010 -j 12 -size 4096 4096  -pol XX,YY,XY,YX -abs-mem 128 -weight briggs 2 -scale 0.0103 -multiscale -mgain 0.8 -niter 100000 -auto-mask 3 -auto-threshold 1.2 -local-rms -circular-beam -minuv-l 30 -interval 10 11 -join-polarizations  1103645160.ms

